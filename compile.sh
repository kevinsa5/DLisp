#!/bin/bash
set -e

dmd lisp.d env.d -oflisp -debug -O
dmd unittests.d -ofunit


# increment the buildID variable
cp lisp.d lisp-temp.d
awk '/long buildID = [0-9]+;/ { printf "long buildID = %d;\n", $4+1 };!/long buildID = [0-9]+;/{print}' < lisp-temp.d > lisp.d

rm lisp-temp.d
rm *.o
