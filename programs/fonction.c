int f(int a,int b) {
  printf(a);
  int c = a + b;
  return c;
}

void g(int a,int b) {
  printf(b);
}

void main() {
  int x = 10;
  int y = 20;
  int z = f(x,y);
  printf(z);
  g(x,y);
}
