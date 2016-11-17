(*
 * Router for Js_of_ocaml
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

(* Useful tools *)
exception Runtime_error of string

let window   = Dom_html.window
let location = window##.location

let raise_ message =
  let _ = window##alert (Js.string message) in
  let _ = Firebug.console##log(Js.string message) in
  raise (Runtime_error message)

let watch_once event args f =
  let%lwt result = event args in
  let _ = f result in
  Lwt.return ()

let rec watch event args f =
  let%lwt _ = watch_once event args f in
  watch event args f

(* start the routing *)
let start f =
  let _ = watch_once Lwt_js_events.onload  () (fun _ -> f()) in
  let _ = watch Lwt_js_events.onhashchange () (fun _ -> f()) in
  ()

(* Get the current hash *)
let get_hash () =
  let hash = Js.to_string (location##.hash) in
  if (String.length hash) > 1
  then Scanf.sscanf hash "#%s" (fun x -> x)
  else ""

(* Set the current Hash *)
let set_hash value =
  let hash = Js.string ("#"^value) in
  location##.hash := hash

(* Clean the current hash *)
let clean_hash () = set_hash ""

(* Alias for conveinence *)
let get_route   = get_hash
let set_route   = set_hash
let clean_route = clean_hash

(* Coersion tools *)
 let coersion_int = function
  | Some str -> begin
      try int_of_string str
      with _ -> raise_ "Unable to coers string into int"
    end 
  | None -> raise_ "Unable to coers string into int"
        

let coersion_float = function
  | Some str -> begin
      try float_of_string str
      with _ -> raise_ "Unable to coers string into float"
    end
  | None -> raise_ "Unable to coers string into float"
              
let coersion_bool = function
  | Some str -> str <> "false"
  | None -> raise_ "Unable to coers string into bool"


let coersion_char = function
  | Some str ->
    if (String.length str) <> 1 then
      raise_ "Unable to coers string into char"
    else str.[0]
  | None -> raise_ "Unable to coers string into char"
    

let coersion_string = function
  | Some str -> str
| None -> raise_ "Unable to coers string into string"
