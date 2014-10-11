#!/bin/bash

dmd scheme.d env.d -ofscheme
dmd unittests.d -ofunit

rm *.o
