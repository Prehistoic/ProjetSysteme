void g()
{
  int a = 100-5;
  while(a>=90) {
      printf(a);
      a = a - 1;
  }
}

int f(int a, int b)
{
  g();
  int c = b / a;
  int d = b - a;
  printf(c);
  printf(d);
  return c;
}

void main()
{
  int a = 10;
  if(a == 10) {
    int b = 50;
    int c = f(a,b);
    g();
    while(c<10) {
      c = c + 1;
      printf(c);
    }
  } else {
    printf(a);
  }
  printf(a);
}
