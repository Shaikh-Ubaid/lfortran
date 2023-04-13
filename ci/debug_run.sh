#!/usr/bin/env bash

set -ex

node -v
which node

node --trace-uncaught src/lfortran/tests/test_lfortran.js

echo $?

echo "I am running fine"
