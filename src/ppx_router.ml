(*
 * Router for Js_of_ocaml (Extension point)
 *
 * Copyright (C) 2016  Xavier Van de Woestyne <xaviervdw@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
*)

(* Raise an error (with the location) *)
let raise_error ?(loc = !Ast_helper.default_loc) message =
  let open Location in
raise (Error (error ~loc message))


(* Regexp utils *)
module Reg =
struct

  (* Record all types in a Hashtbl *)
  let _types = Hashtbl.create 6
  let _ =
    let add = Hashtbl.add in
    add _types "int" "(-?[0-9]+)";
    add _types "float" "(-?[0-9]+.[0-9]*)";
    add _types "char" "(.)";
    add _types "bool" "(true|false)"; 
    add _types "string" "(.+)"

  (* Create regex *)
  let cons = Printf.sprintf "%s%c"
  let create str =
    let hash = Hashtbl.create 10 in 
    let len  = String.length str in
    let rec aux accn acc i =
      if i = len then (acc, accn, hash)
      else
        match str.[i] with
        | '{' ->
          let (r, new_index) = variable "" (succ i) in
          let index = succ accn in
          let _ = Hashtbl.add hash index r in
          aux index (acc ^ (Hashtbl.find _types r)) new_index
        | c   -> aux accn (cons acc c) (succ i)
    and variable acc i =
      if i = len then raise_error "Malformed route"
      else
        match str.[i] with
        | '}' ->
          if Hashtbl.mem _types acc then (acc, succ i)
          else raise_error "Unknown type in route"
        | c -> variable (cons acc c) (succ i)
                 
    in aux 0 "" 0

end


(* Open common libs *)
open Parsetree
open Asttypes
open Ast_helper


(* Usefuls tools for elt creation *)
module Util =
struct

  (* Define a simple location *)
  let define_loc ?(loc = !default_loc) value =
    { txt = value; loc = loc }
  let loc = define_loc

  (* Define an identifier *)
  let ident ?(loc = !default_loc) value =
    define_loc ~loc (Longident.Lident value)

  (* Define recurrent expresions *)
  let exp_ident x  = Exp.ident (ident x)
  let string value = Exp.constant (Const.string value)
  let int value    = Exp.constant (Const.int value)
  let pattern s    = Pat.var (loc s)
  let _unit        = Exp.construct (ident "()") None
  (* let some x       = Exp.construct (ident "Some") (Some x) *)

  (* Import a function *)
  let import_function modname funcname =
    loc Longident.(Ldot (Lident modname, funcname))
    |> Exp.ident

end

(* Check if a match expression is a router *)
let match_route exp =
  match exp.pexp_desc with
  | Pexp_extension
      ({txt = "routes"; loc=_},  _) -> true
  | _ -> false

(* Merge old guard with new guards *)
let merge_guard other = function
  | None -> Some other
  | Some x ->
    Some
      Exp.(apply (Util.exp_ident "&&") [
          Nolabel, x
        ; Nolabel, other
        ])

(* Extract pattern (with a regex) from a string *)
let extract_pattern_regex str =
  let (r,i, hash) = Reg.create str in
  let matcher = Printf.sprintf "^%s$" r
  in (matcher, i, hash)

(* Empty hash placeholder *)
let empty_hash = Hashtbl.create 10

(* Extract the regexp from an expression *)
let extract_regex = function
  | PStr [{pstr_desc = Pstr_eval (e, _); _}] ->
    begin
      match e.pexp_desc with
      | Pexp_constant (Pconst_string (str, _)) ->
        extract_pattern_regex str
      | _ -> (".*", 0, empty_hash)
    end
  | _ -> (".*", 0, empty_hash)

(* Create the matched function *)
let create_matched hash i =
  let k = Hashtbl.find hash i in
  let f = Util.import_function "Regexp" "matched_group" in
  let coersion = Util.import_function "Router" ("coersion_"^k) in
  let e = Exp.( apply f [
      Nolabel, Util.exp_ident "result"
    ; Nolabel, Util.int i
    ])
  in
Exp.(apply coersion [Nolabel, e])

(* Create the expresion function to match arguments *)
let expr_fun len guard hash =
  let err = Util.import_function "Router" "raise_" in
  let result = Exp.let_ Nonrecursive [Vb.mk (Util.pattern "raw_result") guard] in
  let rec aux acc i =
    if i > len then List.rev acc
    else aux ((create_matched hash i)::acc) (succ i)
  in
  let expr =
    if len > 1 then Exp.tuple (aux [] 1)
    else create_matched hash 1 in 
  result (
    Exp.match_
      (Util.exp_ident "raw_result")
      [
        Exp.case
          (Pat.construct (Util.ident "Some") (Some (Util.pattern "result")))
          expr
      ; Exp.case
          (Pat.construct (Util.ident "None") None)
          (Exp.apply err [Nolabel, Util.string "Error during matching route"])
      ]
  )

(* Create the function to extract arguments *)
let route_args_function guard gexp i case hash=
  let f =
    if i >= 1 then 
      Exp.let_ Nonrecursive [
        Vb.mk
          (Util.pattern "route_arguments")
          (Exp.fun_ Nolabel None (Util.pattern "()") (expr_fun i gexp hash))
      ] case.pc_rhs
    else case.pc_rhs     
  in  {
    pc_lhs    = Util.pattern "router_route_uri"
  ; pc_guard  = merge_guard guard case.pc_guard
  ; pc_rhs    = f
}

(* Create the regexp expression *)
let create_regex reg =
  let to_reg = Util.import_function "Regexp" "regexp" in
  let matchs = Util.import_function "Regexp" "string_match" in
  let to_opt = Util.import_function "Router" "is_some" in 
  let str    = Util.string reg in
  let regex  = Exp.(apply to_reg [Nolabel, str]) in
  let app    =
    Exp.(apply matchs [
        Nolabel, regex
      ; Nolabel, Util.exp_ident "router_route_uri"
      ; Nolabel, Util.int 0
      ])
  in (Exp.(apply to_opt [Nolabel, app]), app)

(* Mapper for case expression *)
let case_mapper mapper case =
    match case.pc_lhs.ppat_desc with
  | Ppat_extension ({txt = "route"; loc=_}, pl) ->
    let (reg, clause, hash) = extract_regex pl in
    let (guard, gexp) = create_regex reg in
    route_args_function guard gexp clause case hash
  | _ -> Ast_mapper.(default_mapper.case mapper case)



(* Mapper for expression *)
let expr_mapper mapper expr =
  match expr.pexp_desc with
  | Pexp_match (exp, cases) when match_route exp ->
    let f = Util.import_function "Router" "get_route" in
    Exp.(
      Exp.match_
        (apply f [Nolabel, Util._unit])
        (List.map (case_mapper mapper) cases)
    )
  | _ -> Ast_mapper.(default_mapper.expr mapper expr)

(* General mapper *)
let router_mapper = Ast_mapper.{ default_mapper with expr = expr_mapper }
let () = Ast_mapper.run_main (fun _ -> router_mapper)
