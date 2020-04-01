void pri(int a, int b)
{
  a = 10;
  printf(b);
}

void main()
{
  int a = 10;
  if (a == 10)
  {
    int b = 50;
    if (b == 40) {
      printf(b);
    }
    else {
      while (b < 60) {
        printf(b);
        b = b + 1;
      }
    }
  }
  printf(a);
}
