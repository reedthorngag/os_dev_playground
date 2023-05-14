

volatile void main() {
    int a = 45324;
    int* b = (int*)0xDEADBEEF;
    a += *b;
}

