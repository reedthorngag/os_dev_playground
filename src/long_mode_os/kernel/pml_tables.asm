[BITS 64]

pml4:
    times 0x200 dq 0

pml3:
    times 0x200 dq 0

    times 0x200*0x200 dq 0
