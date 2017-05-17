(* MIT License
 * 
 * Copyright (c) 2017 Xavier Van de Woestyne
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)


(** This module provides tools to build a [RoutingTable]. A RoutingTable is a 
    module which have the functionnalities of watching url (hash or history) 
    modification.
*)

(** {2 Routing Method } 
    A router uses a style of routing (using HistoryAPI or Hash).
*)

(** A Separator between members of an URI *)
type separator = string

(** The kind of the routing style. *)
type routing_style = 
  | Hash     (** Uses the hash (url likes [#/foo/bar]) *)
  | History  (** Uses the HistoryAPI (url likes [/foo/bar]) *)
  | Infered  (** Try to uses [History] *)

(** A [routing_method] is a couple between a style and a separator*)
type routing_method = (routing_style * separator)

(** {2 Generics interfaces} *)

(** The requirement to build a RoutingTable *)
module type REQUIREMENT =
sig 

  (** An enumeration of each of the routes members *)
  type t

  val routing_method : routing_method
  (** The routing style *)
end

(** The general interface of a module for routing *)
module type ROUTING_TABLE = 
sig 
  include REQUIREMENT

  (** [watch f] perform f on each url changement *)
  val watch: (string -> 'a) -> 'a
end


(** {2 Functor to build a routing table} *)

module New (M : REQUIREMENT) : ROUTING_TABLE