#!/bin/bash

dmd -debug scheme.d env.d -ofscheme
dmd unittests.d -ofunit

rm *.o
