import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ReadOnly

# UART helper (you can adjust baud rate / bit time as needed)
async def uart_tx(dut, data_byte, bit_time):
    """Send one byte over UART (8-N-1)."""
    # start bit (low)
    dut.ui_in[0].value = 0
    await Timer(bit_time, units='ns')
    # data bits LSB first
    for i in range(8):
        bit = (data_byte >> i) & 1
        dut.ui_in[0].value = bit
        await Timer(bit_time, units='ns')
    # stop bit (high)
    dut.ui_in[0].value = 1
    await Timer(bit_time, units='ns')

@cocotb.test()
async def test_pwm_output_toggle(dut):
    """
    Test: send a UART command, wait for PWM outputs to change.
    Check that uo_out[0..7] respond as expected (at least toggle).
    """

    # Parameters — adjust to match your design
    clk_period = 20  # in ns, i.e. 50 MHz
    uart_baud = 9600
    # bit_time, approximate time per UART bit
    bit_time = int(1e9 / uart_baud)  

    # Create clock
    cocotb.start_soon(Clock(dut.clk, clk_period, units='ns').start())

    # Reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await Timer(100, units='ns')
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Idle UART line high
    dut.ui_in[0].value = 1

    # Send a known byte (you must know what data makes PWM change)
    test_byte = 0x55  # e.g. 0b0101‐0101
    await uart_tx(dut, test_byte, bit_time)

    # Wait a few PWM cycles (you might need to wait based on your internal logic)
    await Timer(5000, units='ns')

    # Capture output values
    out_vals = [int(dut.uo_out[i].value) for i in range(8)]
    dut._log.info(f"uo_out[0..7] = {out_vals}")

    # Basic assertion: expect at least one output to toggle from its reset/init state
    # (Assumes reset puts PWM outputs to 0)
    assert any(v != 0 for v in out_vals), "Expected at least one PWM output to be non‐zero after sending UART data"

@cocotb.test()
async def test_pkt_count_increments(dut):
    """
    If pkt_count is accessible or can be observed internally (maybe via debug),
    test that sending two valid UART packets increments pkt_count by 2.
    """
    clk_period = 20
    uart_baud = 9600
    bit_time = int(1e9 / uart_baud)

    cocotb.start_soon(Clock(dut.clk, clk_period, units='ns').start())

    # Reset
    dut.rst_n.value = 0
    await Timer(100, units='ns')
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Idle UART
    dut.ui_in[0].value = 1

    # Optionally: read initial pkt_count
    init_cnt = int(dut.pkt_count.value) if hasattr(dut, "pkt_count") else None

    # Send two bytes
    await uart_tx(dut, 0xAA, bit_time)
    await Timer(2000, units='ns')
    await uart_tx(dut, 0xBB, bit_time)
    await Timer(2000, units='ns')

    if init_cnt is not None:
        final_cnt = int(dut.pkt_count.value)
        dut._log.info(f"pkt_count: init={init_cnt}, final={final_cnt}")
        assert final_cnt == init_cnt + 2, f"Expected pkt_count to increase by 2, got {final_cnt - init_cnt}"
    else:
        # If pkt_count is not exposed in the wrapper, skip or mark as TODO
        dut._log.warning("pkt_count not accessible; skipping pkt_count increment test")

