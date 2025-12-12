    .text
    .globl main

main:

    # ----------------------------
    # Load address of data area
    # ----------------------------
    la x1, data_area          # x1 = base pointer

    # ----------------------------
    # Load values into registers
    # (li is a pseudo-instruction, expands into RV32I code)
    # ----------------------------
    li x2, 0x1234             # value for SH
    li x3, 0xAB               # value for SB
    li x4, 0x55667788         # value for SW

    # ----------------------------
    # STORE TESTS
    # ----------------------------
    sb x3, 0(x1)              # store byte 0xAB
    sh x2, 2(x1)              # store halfword 0x1234
    sw x4, 4(x1)              # store word 0x55667788

    # ----------------------------
    # LOAD TESTS
    # ----------------------------
    lb  x10, 0(x1)            # signed byte
    lbu x11, 0(x1)            # unsigned byte

    lh  x12, 2(x1)            # signed halfword
    lhu x13, 2(x1)            # unsigned halfword

    lw  x14, 4(x1)            # full word

    # Additional offset tests
    lb  x15, 1(x1)
    lbu x16, 1(x1)

    lh  x17, 4(x1)
    lhu x18, 4(x1)

    lb  x19, 5(x1)
    lbu x20, 5(x1)

# Endless loop (prevent execution into unknown memory)
end_loop:
    jal x0, end_loop


# ============================
# DATA SECTION
# ============================
.data
.align 4
data_area:
    .word 0
    .word 0
    .word 0
