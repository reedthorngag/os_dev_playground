[BITS 64]

;pml4:
;    times 0x200 dq 0

section .pml_map

global pml3
global pml2
global pml1
global pml_space_start

pml_space_start:
pml3:
    times 0x200 dq 0
pml2:
    times 0x400 dq 0
pml1:
    times 0x200*0x200 dq 0

global pml_table_end
pml_table_end:

global _physical_kernel_start
_physical_kernel_start:
