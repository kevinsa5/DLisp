#!/bin/bash

dmd scheme.d env.d -ofscheme -debug -O
dmd unittests.d -ofunit

rm *.o
