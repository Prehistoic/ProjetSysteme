int main() {
    int a = 10;
    printf(a);
    if(a==10) {
      a = 20;
    }
    int b = 50;
    int c = 5;
    while(c<8) {
      c = c+1;
    }
    a = (a+c)*b;
    b = b*2;
    printf(b);
    printf(a);
}
