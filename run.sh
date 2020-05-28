#! /bin/bash
# run.sh

FILE=${1:-my_program}

printf "make compiler :\n"
cd compiler
make
printf "\n\n"

printf "make interpreter :\n"
cd ../interpreter
make
printf "\n\n"

cd ../
./compiler/compiler programs/$FILE.c programs/$FILE.asm
printf "\n\n"

read -n 1 -p "Press a key to run interpreter :"
clear
./interpreter/interpreter programs/$FILE.asm
