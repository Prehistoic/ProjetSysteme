#! /bin/bash
# run.sh

./compiler/compiler compiler/tests/my_program.c my_program.asm
./interpreter/interpreter my_program.asm 
