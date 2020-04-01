void pri(int c, int d)
{
  c = 10;
  printf(d);
}

void main()
{
  int a = 10;
  if (a == 10)
  {
    int b = 50;
    a = 20;
    pri(a,b);
  }
  printf(a);
}
