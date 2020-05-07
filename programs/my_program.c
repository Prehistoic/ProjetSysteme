int f(int a, int b)
{
  int c = b / a;
  printf(c);
  return c;
}

int * g(int * a) {
  return a;
}

void main()
{
  int a = 10;
  int b = 50;
  int c = f(a,b);
  int * d = g(&c);
  int e = *d;
  if(c == *d) {
    printf(b);
  }
  printf(e);
}
