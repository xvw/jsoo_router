OCAML    = ocamlfind ocamlc -g -package js_of_ocaml -package js_of_ocaml.ppx
ROUTER   = -package jsoo_router -package jsoo_router.ppx
JSOCAML  = js_of_ocaml +weak.js +toplevel.js

.PHONY: src/example.ml

# Specific rule
all: example.js
	rm -rf src/*.byte
	rm -rf src/*.cm*


# Generic rules

%.byte: src/%.ml
	$(OCAML) $(ROUTER) -dsource -linkpkg -o $(@) $(<)

%.js: %.byte
	$(JSOCAML) -o $(@) $(<)
