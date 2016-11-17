OCAML    = ocamlfind ocamlc -g -package js_of_ocaml -package js_of_ocaml.ppx
ROUTER   = -package router -package router.ppx
JSOCAML  = js_of_ocaml +weak.js +toplevel.js

.PHONY: src/example.ml

# Specific rule
all: example.js
	rm -rf *.byte
	rm -rf *.cm*


# Generic rules

%.byte: src/%.ml
	$(OCAML) $(QUASAR) -dsource -linkpkg -o $(@) $(<)

%.js: %.byte
	$(JSOCAML) -o $(@) $(<)
