# -----------------------------
# I-TYPE INSTRUCTION TEST
# -----------------------------
    addi x1, x0, 5        # x1 = 5
    addi x2, x0, 10       # x2 = 10

    # ----- ADDI -----
    addi x5, x1, 3        # x5 = 5 + 3 = 8

    # ----- SLTI (signed) -----
    slti x6, x1, 10       # x6 = 1  (5 < 10)
    slti x7, x2, 5        # x7 = 0  (10 < 5 false)

    # ----- SLTIU (unsigned) -----
    sltiu x8, x1, 10      # x8 = 1
    sltiu x9, x2, 5       # x9 = 0

    # ----- XORI -----
    xori x10, x1, 7       # x10 = 5 XOR 7 = 2

    # ----- ORI -----
    ori  x11, x1, 16      # x11 = 5 OR 16 = 21

    # ----- ANDI -----
    andi x12, x2, 7       # x12 = 10 AND 7 = 2

    # ----- SLLI -----
    slli x13, x1, 1       # x13 = 5 << 1 = 10

    # ----- SRLI -----
    srli x14, x2, 1       # x14 = 10 >> 1 = 5

    # ----- SRAI -----
    srai x15, x2, 1       # x15 = arithmetic shift → 10 >> 1 = 5

# End: infinite loop so CPU doesn't fetch garbage
end_loop:
    jal x0, end_loop
