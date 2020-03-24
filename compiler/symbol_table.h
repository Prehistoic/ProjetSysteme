#ifndef SYMBOL_TABLES_H
#define SYMBOL_TABLES_H

struct symbol
{
  char id[256];
  int depth;
  int constant;
  int initialized;
};

int push_symbol(const char *id, int depth, int constant);

void pop_symbol();

int find_symbol(const char *id, int depth);

int get_last_symbol();

void set_initialized(const char *id, int depth);

int get_initialized(const char *id, int depth);

int get_const(const char *id, int depth);

void display_table();

#endif