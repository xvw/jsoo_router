> This readme is work in progress

# JSOO_Router

> Jsoo_router is a tool to facilitate front-end routing. 
> This library uses a syntax extension (ppx). This tool was extracted from Work In Progress
> Quasar Famework : https://github.com/xvw/quasar

**Jsoo_router** is a tool that allows to easily realize single-page-app via a router
On the hash ( `# url`). The library exposes a function to start routing and a syntax 
extension to use pattern matching to define routes. The documentation of the Router module 
is available [here](https://xvw.github.io/jsoo_router/doc/).


## Installation

Use `opam install jsoo_router`

### Use with OCamlfind

Add the flags `-package jsoo_router -package jsoo_router.ppx`

## Watch hash transformation
The module `Router` expose a `start : (unit -> 'a) -> unit` function. `Router.start f` execute
`f` when the hash is changed. For example you can try this code
: `Router.start (fun () -> alert "changement")`

## Manage routes
You can match routes using `match [%routes] with ...`. For example :

```ocaml
Router.start (fun () ->
  match [%routes] with
  | "foo" -> alert "Foo's page"
  | "bar" -> alert "Bar's page"
  | ""    -> alert "Index's page"
  | _     -> alert "Unmanaged page"
)

```

### [%route] for complex routes construction

```ocaml
Router.start (fun () ->
  match [%routes] with
  | "foo"                    -> alert "Foo's page"
  | "bar"                    -> alert "Bar's page"
  | ""                       -> alert "Index's page"
  | [%route "foo-(bar|foo)"] -> alert "Using regex"
  | [%route "digit-[0-9]"]   -> alert "Regex with a digit"
  | _                        -> alert "Unmanaged page"
)
```

Using `[%route ...]` you can use regex in the route definition.


## Routes with variables

You can use `[%route "some-{type}-{other-type}"]` to define variables 
into route. Here is the list of available types :

#### Internals types

-  `string`
-  `int`
-  `bool`
-  `char`
-  `float`

### Extract variables from the route

Those variables could be extract with the function `route_arguments ()`. This function 
returns a n-uplet of the all extracted variables in the order of their definition.

```ocaml
let alert s = Dom_html.window##alert(Js.string s)

let () =
  Router.start (fun () ->
      match [%routes] with
      | "foo"                            -> alert "Foo's page"
      | "bar"                            -> alert "Bar's page"
      | [%route "foo-(bar|foo)"]         -> alert "FooBar or FooFoo"
      | [%route "digit-[0-9]"]           -> alert "Regex with a digit"

      | [%route "code-{int}"]            -> (* HERE A DEFINITION WITH JUST AN INT *)
        let code = route_arguments () in
        alert (Printf.sprintf "The code is : %d" code)

      | [%route "people-{string}-{int}"] -> (* HERE A DEFINITION WITH A STRING AND AN INT *)
        let name, age = route_arguments () in
        alert (Printf.sprintf "Hi %s, you are %d !" name age)

          
      | ""                               -> alert "Index's page"
      | _                                -> alert "Unmanaged page"
    )

```

## Examples

-  [A simple example](https://github.com/xvw/jsoo_router/tree/master/examples/simple-routing)
-  [A simple example in Quasar (It is the same router)](https://github.com/xvw/quasar/tree/master/examples/simple-routing)


