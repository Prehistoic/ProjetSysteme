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

int get_func_index(const char *id) {
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *current = &(function_table.functions[i]);
    if (!strcmp(current->id, id))
      return i;
  }
  return -1;
}

void add_function(const char *id)
{
  struct function *new = &(function_table.functions[function_table.size]);
  strcpy(new->id, id);
  new->params_code = 0;
  function_table.size++;
}

void set_function_attributes(const char *id, int nb_params, int function_start, int return_type)
{
  int index;
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *tmp = &(function_table.functions[i]);
    if (!strcmp(tmp->id, id))
      index = i;
  }
  struct function *current = &(function_table.functions[index]);
  current->nb_params = nb_params;
  current->function_start = function_start;
  current->return_type = return_type;
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

int return_pointer(const char *id)
{
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *current = &(function_table.functions[i]);
    if (!strcmp(current->id, id))
      return function_table.functions[i].return_type;
  }
  return -1;
}

int get_params_code(const char *id)
{
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *current = &(function_table.functions[i]);
    if (!strcmp(current->id, id))
      return function_table.functions[i].params_code;
  }
  return -1;
}

void add_to_params_code(const int index, int elem)
{
  int code = function_table.functions[index].params_code;
  if(code == 0) {
    code = elem;
  }
  else {
    code = code * 10 + elem;
  }
  function_table.functions[index].params_code = code;
}

void display_functions()
{
  printf("Functions table :\n");
  for (int i = 0; i < function_table.size; i++)
  {
    struct function *current = &(function_table.functions[i]);
    printf("index=%d\t", i);
    printf("id=%s\tparams=%d\tcode=%d\tstart=%d\n", current->id, current->nb_params, current->params_code, current->function_start);
  }
  printf("\n");
}
