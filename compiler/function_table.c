#include "function_table.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

struct function_table
{
  int size;
  struct function functions[100];
};

struct function_table function_table = {0};

void add_function(const char *id, int nb_params, int function_start)
{
  struct function *new = &(function_table.functions[function_table.size]);
  strcpy(new->id, id);
  new->nb_params = nb_params;
  new->function_start = function_start;
  function_table.size++;
}

int get_function_start(const char *id)
{
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *current = &(function_table.functions[i]);
    if (!strcmp(current->id, id))
      return function_table.functions[i].function_start;
  }
  return -1;
}

int get_function_params(const char *id)
{
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *current = &(function_table.functions[i]);
    if (!strcmp(current->id, id))
      return function_table.functions[i].nb_params;
  }
  return -1;
}

void display_functions()
{
  printf("Functions table :\n");
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *current = &(function_table.functions[i]);
    printf("index=%d\t", i);
    printf("id=%s\tparams=%d\tstart=%d\n", current->id, current->nb_params, current->function_start);
  }
  printf("\n");
}
