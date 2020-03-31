void pri()
{
  int a = 10;
  printf(3 + 2 + a);
}

void main()
{
  int a = 10;
  if (a == 10)
  {
    a = 20;
    pri();
  }
  printf(a);
}
