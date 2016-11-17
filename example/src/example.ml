(* Small example of routing *)

(* Easy getElementById *)
let getById idt =
  Dom_html.document##getElementById(Js.string idt)
  |> Js.Opt.to_option

let alert s =
   Dom_html.window##alert(Js.string s)

let () =
  match (getById "") with
  | None -> alert "Error"
  | Some elt ->
    Router.start (fun () ->
        match [%routes] with
        | _ -> alert "element"
      )


