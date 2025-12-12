    .text
    .globl main

main:
    # -----------------------------------------------------
    # Test JAL
    # -----------------------------------------------------

    jal x5, label_jal      # x5 = PC+4 of this instruction

    # If JAL fails, execution continues here
    addi x6, x0, 0xFF      # should NOT execute if JAL is correct


# ------------ JAL target -----------------
label_jal:
    addi x7, x0, 0x11      # x7 = 0x11 (confirm jump landed here)

    # JALR test preparation:
    la   x1, label_jalr    # x1 = absolute address of label_jalr
    addi x1, x1, 0         # ensure exact address

    # -----------------------------------------------------
    # Test JALR
    # -----------------------------------------------------
    jalr x8, 0(x1)          # x8 = PC+4, jump to label_jalr


    # If JALR fails, execution continues here
    addi x9, x0, 0xEE       # should NOT execute if JALR is correct


# ------------ JALR target -----------------
label_jalr:
    addi x10, x0, 0x22     # x10 = 0x22 (confirm jump landed here)

# Stop CPU
end_loop:
    jal x0, end_loop
