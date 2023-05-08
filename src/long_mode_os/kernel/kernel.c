
__attribute__((section(".kernel")))

volatile void setup_VESA_VBE();

volatile void main() {
    setup_VESA_VBE();
    return;
}



