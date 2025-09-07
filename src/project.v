/*
 * TinyTapeout Example: 8-bit counter
 * Increments on each clock and drives outputs
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs (unused here)
    output wire [7:0] uo_out,   // Outputs (show counter value)
    input  wire [7:0] uio_in,   // IOs (unused here)
    output wire [7:0] uio_out,  // IOs (unused here)
    output wire [7:0] uio_oe,   // IOs (set to input mode)
    input  wire       ena,      // Always 1 (ignore)
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset (active low)
);

  reg [7:0] counter;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      counter <= 8'd0;         // reset counter
    else
      counter <= counter + 1;  // increment
  end

  assign uo_out  = counter;  // send counter value to output pins
  assign uio_out = 8'd0;     // unused, tie off
  assign uio_oe  = 8'd0;     // all uio pins as input

  // prevent warnings about unused signals
  wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule

