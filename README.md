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
### Use with OCamlfind

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
### Internals types
### Extract variables from the route
## Example of a simple router


