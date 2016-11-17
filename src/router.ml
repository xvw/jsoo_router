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
let window   = Dom_html.window
let location = window##.location 

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
