#!/bin/bash
set -e

cd /home/kevin/DLisp/src

# the version of dmd in the d-apt repo produced really slow code
# use http://dlang.org/download.html for fast code

dmd lisp.d env.d buildData -of../bin/lisp -debug -O
dmd unittests.d -of../bin/unit

#gdc lisp.d env.d buildData.d -o ../bin/lisp -O3
#gdc unittests.d -o ../bin/unit -O3

# increment the buildID variable
cp buildData.d buildData-temp.d
awk '/long buildID = [0-9]+;/ { printf "long buildID = %d;\n", $4+1 };!/long buildID = [0-9]+;/{print}' < buildData-temp.d > buildData.d

rm buildData-temp.d
rm ../bin/*.o
