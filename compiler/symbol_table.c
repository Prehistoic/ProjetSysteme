#include "symbol_table.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

struct table
{
    int size;
    struct symbol symbols[500];
};

struct table my_table = {0};

int push_symbol(const char* id, int depth, int constant)
{
    struct symbol* new = &(my_table.symbols[my_table.size]);
    strcpy(new->id, id);
    new->initialized = 0;
    new->depth = depth;
    new->constant = constant;
    my_table.size++;
    return my_table.size-1;
}

void pop_symbol(){
    my_table.size--;
}

int find_symbol(const char* id, int depth)
{
    for(int i=0; i<my_table.size; i++)
    {
        struct symbol* current = &(my_table.symbols[i]);
        if(current->depth <= depth)
            if(!strcmp(current->id, id))
                return i;
    }
    return -1;
}

int get_last_symbol()
{
    return my_table.size-1;
}

void set_initialized(const char* id, int depth)
{
    int adr = find_symbol(id, depth);
    my_table.symbols[adr].initialized = 1;
}

int get_initialized(const char* id, int depth)
{
    int adr = find_symbol(id, depth);
    return my_table.symbols[adr].initialized;
}

int get_const(const char* id, int depth)
{
    int adr = find_symbol(id, depth);
    return my_table.symbols[adr].constant;
}

void display_table()
{
    printf("Symbol table :\n");
    for(int i=0; i<my_table.size; i++)
    {
        struct symbol* current = &(my_table.symbols[i]);
        int depth = current->depth;
        printf("index=%d\t", i);
        printf("id=%s\tconst=%d\tinit=%d\tdepth=%d\n",current->id,current->constant,current->initialized,current->depth);
    }
    printf("\n");
}
