############################################
# RV32I R-TYPE INSTRUCTION TEST PROGRAM
# Designed for CPU hardware verification
############################################

    .text
    .globl main
main:

    # -----------------------------------
    # Initialize registers
    # -----------------------------------
    li x1, 10        # rs1 = 10
    li x2, 3         # rs2 = 3
    li x3, -5        # negative number for SLT/SRA tests
    li x4, 1         # shift amount (rs2)

    # -----------------------------------
    # ADD & SUB
    # -----------------------------------
    add x5, x1, x2     # 10 + 3  = 13
    sub x6, x1, x2     # 10 - 3  = 7

    # -----------------------------------
    # LOGICAL OPERATIONS
    # -----------------------------------
    and x7,  x1, x2    # 10 & 3 = 2
    or  x8,  x1, x2    # 10 | 3 = 11
    xor x9,  x1, x2    # 10 ^ 3 = 9

    # -----------------------------------
    # SHIFT OPERATIONS
    # -----------------------------------
    sll x10, x1, x4    # 10 << 1 = 20
    srl x11, x1, x4    # 10 >> 1 = 5
    sra x12, x3, x4    # -5 >>> 1 = arithmetic shift

    # -----------------------------------
    # SET LESS THAN
    # -----------------------------------
    slt  x13, x3, x1   # -5 < 10 (signed) = 1
    sltu x14, x3, x1   # compare unsigned

    # -----------------------------------
    # End: infinite loop so simulation doesn't run out
    # -----------------------------------
done:
    beq x0, x0, done   # loop forever
