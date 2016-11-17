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

(** {2 Utils functions} *)

(** [Router.get_hash ()] returns the value of the current hash *)
val get_hash : unit -> string

(** [Router.set_hash "foo"] sets the current hash with [#foo] *)
val set_hash : string -> unit

(** [Router.clean_hash ()] remove the hash *)
val clean_hash : unit -> unit
