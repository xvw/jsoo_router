#!/bin/sh

# Small tools to be fast to generate files
lib=`opam config var lib`
boot="$lib/jsoo_router"

if [ "$1" = "clean" ];
then
    echo "Clean emacs files"
    rm -rf *~
    rm -rf */*~
    rm -rf \#*
    rm -rf */\#*
    make clean
    make distclean

elif [ "$1" = "oasis" ];
then
     echo "Setup Oasis"
     oasis setup -setup-update dynamic
elif [ "$1" = "remove" ];
then
    echo "Erase [Router] localised in [$boot]"
    rm -r $boot
elif [ "$1" = "run" ];
then
    echo "Run OCaml with piplet"
    make
    ocaml -I _build/src unix.cma str.cma Piplet.cma
    echo "Bye"

else
    ocamlc -I _build/lib unix.cma str.cma Piplet.cma $*
fi
