#! /bin/bash
# run.sh

cd compiler
make
cd ../interpreter
make
cd ../
./compiler/compiler programs/my_program.c programs/my_program.asm
./interpreter/interpreter programs/my_program.asm
