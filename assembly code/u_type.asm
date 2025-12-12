    .text
    .globl main

main:

    ############################################################
    # TEST 1: LUI — Load Upper Immediate
    # rd = imm[31:12] << 12
    ############################################################
    lui x5, 0x12345        # x5 = 0x12345_000

    lui x6, 0xFFFFF        # x6 = 0xFFFFF_000 (sign-extension varies in CPU)
                           # Expected: 0xFFFFF000


    ############################################################
    # TEST 2: AUIPC — Add Upper Immediate to PC
    # rd = PC + (imm << 12)
    ############################################################

    # NOTE: RARS PC starts at 0x00400000
    # Your CPU PC probably starts at 0x00000000
    # So results will differ in the upper bits!

    auipc x7, 0x1          # x7 = PC + 0x1_000
                           # RARS PC ≈ 0x00400000 → x7 ≈ 0x00401000
                           # Your CPU PC ≈ 0x00000000 → x7 ≈ 0x00001000

    auipc x8, 0xABCDE      # x8 = PC + (0xABCDE << 12)
                           # RARS → ≈ 0xABCDE000 + PC
                           # Your CPU → ≈ 0xABCDE000 (PC small)


    ############################################################
    # TEST 3: Show LUI + AUIPC combined behavior
    ############################################################
    lui   x9, 0x10000      # x9 = 0x10000_000
    auipc x9, 0            # x9 = PC + 0


    ############################################################
    # END OF PROGRAM
    ############################################################
    li a7, 10
    ecall
