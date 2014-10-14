#!/bin/bash
set -e
dmd lisp.d env.d -oflisp -debug -O
dmd unittests.d -ofunit

rm *.o
