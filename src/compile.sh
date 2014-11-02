#!/bin/bash
set -e

cd /home/kevin/DLisp/src

dmd lisp.d env.d buildData -of../bin/lisp -debug -O
dmd unittests.d -of../bin/unit


# increment the buildID variable
cp buildData.d buildData-temp.d
awk '/long buildID = [0-9]+;/ { printf "long buildID = %d;\n", $4+1 };!/long buildID = [0-9]+;/{print}' < buildData-temp.d > buildData.d

rm buildData-temp.d
rm ../bin/*.o
