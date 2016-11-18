(* Small example of routing *)

(* Utils *)
module Util =
struct

  let getById id =
    Dom_html.document##getElementById(Js.string id)
    |> Js.Opt.to_option

end
