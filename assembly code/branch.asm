.text
.globl main

main:

    ############################################################
    # INITIAL SETUP
    ############################################################
    li x1, 5              # rs1 = 5
    li x2, 5              # rs2 = 5   (equal)
    li x3, 3              # less than x1
    li x4, 9              # greater than x1

    li x10, 0             # BEQ  result register
    li x11, 0             # BNE  result register
    li x12, 0             # BLT  result register
    li x13, 0             # BGE  result register
    li x14, 0             # BLTU result register
    li x15, 0             # BGEU result register

    ############################################################
    # TEST 1: BEQ (x1 == x2)
    ############################################################
    beq x1, x2, BEQ_TAKEN
    li x10, 1             # Should NOT execute if branch works
    j BEQ_DONE
BEQ_TAKEN:
    li x10, 2             # This should run (correct case)
BEQ_DONE:

    ############################################################
    # TEST 2: BNE (x1 != x3)
    ############################################################
    bne x1, x3, BNE_TAKEN
    li x11, 1             # Should NOT execute if branch works
    j BNE_DONE
BNE_TAKEN:
    li x11, 2             # Expected
BNE_DONE:

    ############################################################
    # TEST 3: BLT (signed compare: 3 < 5)
    ############################################################
    blt x3, x1, BLT_TAKEN
    li x12, 1
    j BLT_DONE
BLT_TAKEN:
    li x12, 2             # Expected
BLT_DONE:

    ############################################################
    # TEST 4: BGE (signed compare: 5 >= 3)
    ############################################################
    bge x1, x3, BGE_TAKEN
    li x13, 1
    j BGE_DONE
BGE_TAKEN:
    li x13, 2             # Expected
BGE_DONE:

    ############################################################
    # TEST 5: BLTU (unsigned: 3 < 5)
    ############################################################
    bltu x3, x1, BLTU_TAKEN
    li x14, 1
    j BLTU_DONE
BLTU_TAKEN:
    li x14, 2             # Expected
BLTU_DONE:

    ############################################################
    # TEST 6: BGEU (unsigned: 5 >= 3)
    ############################################################
    bgeu x1, x3, BGEU_TAKEN
    li x15, 1
    j BGEU_DONE
BGEU_TAKEN:
    li x15, 2             # Expected
BGEU_DONE:

    ############################################################
    # END — Loop forever to prevent executing random memory
    ############################################################
end_loop:
    j end_loop
