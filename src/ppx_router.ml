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

  (*  Define an identifier *)
  let ident ?(loc = !default_loc) value =
    define_loc ~loc (Longident.Lident value)

  (* Define recurrent expresions *)
  let exp_ident x  = Exp.ident (ident x)
  let string value = Exp.constant (Const.string value)
  let int value    = Exp.constant (Const.int value)
  let _true        = Exp.construct (ident "true") None
  let _false       = Exp.construct (ident "false") None
  let pattern s    = Pat.var (loc s)
  let _unit        = Exp.construct (ident "()") None
  let some x       = Exp.construct (ident "Some") (Some x)

end


