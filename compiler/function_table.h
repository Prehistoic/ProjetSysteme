#ifndef FUNCTION_TABLES_H
#define FUNCTION_TABLES_H

struct function
{
  char id[256];
  int nb_params;
  int function_start;
  int return_type;
  int params_code;
};

int get_func_index(const char *id);

void add_function(const char *id);

void set_function_attributes(const char *id, int nb_params, int function_start, int return_type);

int return_pointer(const char *id);

int get_function_start(const char *id);

int get_function_params(const char *id);

int get_params_code(const char *id);

void add_to_params_code(const int index, int elem);

void display_functions();

#endif
