#!/bin/bash
set -e

cd /home/kevin/DLisp/src

dmd lisp.d env.d -of../bin/lisp -debug -O
dmd unittests.d -of../bin/unit


# increment the buildID variable
cp lisp.d lisp-temp.d
awk '/long buildID = [0-9]+;/ { printf "long buildID = %d;\n", $4+1 };!/long buildID = [0-9]+;/{print}' < lisp-temp.d > lisp.d

rm lisp-temp.d
rm ../bin/*.o
