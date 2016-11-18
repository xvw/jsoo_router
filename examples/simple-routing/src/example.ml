(* Small example of routing *)


let alert s = Dom_html.window##alert(Js.string s)

let () =
  Router.start (fun () ->
      match [%routes] with
      | "foo"                            -> alert "Foo's page"
      | "bar"                            -> alert "Bar's page"
      | [%route "foo-(bar|foo)"]         -> alert "FooBar or FooFoo"
      | [%route "digit-[0-9]"]           -> alert "Regex with a digit"

      | [%route "code-{int}"]            ->
        let code = route_arguments () in
        alert (Printf.sprintf "The code is : %d" code)

      | [%route "people-{string}-{int}"] ->
        let name, age = route_arguments () in
        alert (Printf.sprintf "Hi %s, you are %d !" name age)

          
      | ""                               -> alert "Index's page"
      | _                                -> alert "Unmanaged page"
    )


