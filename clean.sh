#! /bin/bash
# clean.sh

cd compiler
make clean
cd ../interpreter
make clean
cd ../programs
rm *.asm