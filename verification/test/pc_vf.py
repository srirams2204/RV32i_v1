# -----------------------------------------------------------
# test_pc.py
# Cocotb testbench for the Program Counter (pc) module
# -----------------------------------------------------------
import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import random

@cocotb.test()
async def pc_reset_test(dut):
    """Test the reset functionality of the PC module."""

    # Set initial values
    dut.pc_in.value = 0
    dut.pc_jmp.value = 0
    dut.rst.value = 1

    # Create a clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Wait for a couple of clock cycles while reset is high
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Check that pc_out is 0 after reset
    cocotb.log.info(f"Checking reset value. pc_out should be 0. Current value: {dut.pc_out.value}")
    assert dut.pc_out.value == 0, "PC did not reset to 0"

    # Deassert reset
    dut.rst.value = 0
    await RisingEdge(dut.clk)
    
    cocotb.log.info("Reset test passed.")

@cocotb.test()
async def pc_increment_test(dut):
    """Test the increment functionality of the PC module."""
    
    # Set initial values and start the clock
    dut.rst.value = 0
    dut.pc_jmp.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Wait for the clock to settle
    await RisingEdge(dut.clk)
    
    # Get the initial PC value
    initial_pc = dut.pc_out.value.integer
    
    # Wait for several cycles and check for correct increment
    for i in range(5):
        expected_pc = initial_pc + (i + 1) * 4
        await RisingEdge(dut.clk)
        current_pc = dut.pc_out.value.integer
        cocotb.log.info(f"Cycle {i+1}: Expected pc_out = {hex(expected_pc)}, Actual = {hex(current_pc)}")
        assert current_pc == expected_pc, f"PC did not increment correctly. Expected: {expected_pc}, Actual: {current_pc}"
        
    cocotb.log.info("Increment test passed.")

@cocotb.test()
async def pc_jump_test(dut):
    """Test the jump functionality of the PC module."""
    
    # Set initial values and start the clock
    dut.rst.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Get a random jump address
    jump_address = random.randint(0, 2**32 - 1)
    
    # Wait for the next clock cycle
    await RisingEdge(dut.clk)

    # Set the jump signal and jump address
    dut.pc_in.value = jump_address
    dut.pc_jmp.value = 1
    
    # Wait for the next clock cycle to see the jump happen
    await RisingEdge(dut.clk)

    # Check the jumped value
    cocotb.log.info(f"Checking jump functionality. Expected pc_out = {hex(jump_address)}, Actual = {hex(dut.pc_out.value.integer)}")
    assert dut.pc_out.value.integer == jump_address, f"PC did not jump to the correct address. Expected: {jump_address}, Actual: {dut.pc_out.value.integer}"
    
    cocotb.log.info("Jump test passed.")