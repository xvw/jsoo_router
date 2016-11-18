(* Small example of routing *)

(* Easy getElementById *)
let getById idt =
  Dom_html.document##getElementById(Js.string idt)
  |> Js.Opt.to_option

(* Output functions *)
let alert s = Dom_html.window##alert(Js.string s)
let log s   = Firebug.console##log(Js.string s)

(* Remove all childs of a node *)
let remove_childs node =
  let rec iter node =
    match Js.Opt.to_option (node##.firstChild) with
    | None -> ()
    | Some child ->
      node##removeChild(child);
      iter node
  in iter node

(* Write text into an element *)
let write_in elt text =
  let _    = remove_childs elt in
  let node = Dom_html.document##createTextNode (Js.string text) in
  let p    = Dom_html.(createP document) in
  let _    = Dom.appendChild p node in
  let _    = Dom.appendChild elt p  in
  ()
  

(* Routing function *)
let routing elt () =
  match [%routes] with

  
  | [%route "hello-{string}"] ->
    (* Extract arguments of the route *)
    let name = route_arguments () in
    write_in elt ("Hello " ^ name)
      
  | [%route "age-{int}-name-{string}"] ->
    (* Extract arguments of the route *)
    let age, name = route_arguments () in
    write_in elt (Printf.sprintf "Hello %s, you are %d" name age)

  (* Home page *)
  | "" -> write_in elt "Home page" 

  (* Non managed page*)
  | _ -> write_in elt "Erreur 404"

let () =
  match (getById "app") with
  | None -> alert "Error"
  | Some elt -> Router.start (fun () ->
      match [%routes] with
      | "foo"                    -> alert "Foo's page"
      | "bar"                    -> alert "Bar's page"
      | [%route "foo-(bar|foo)"] -> alert "Using regex"
      | [%route "digit-[0-9]"]   -> alert "Regex with a digit"
      | ""                       -> alert "Index's page"
      | _                        -> alert "Unmanaged page"
    )


