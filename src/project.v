/*
 * TinyTapeout Example: 8-bit counter
 * Increments on each clock and drives outputs
 */

`default_nettype none
`include "washer_ctrl.v"
module tt_um_washer_ctrl (
    input  wire [7:0] ui_in,    // Inputs from pins
    output wire [7:0] uo_out,   // Outputs to pins
    input  wire [7:0] uio_in,   // Bidirectional inputs
    output wire [7:0] uio_out,  // Bidirectional outputs
    output wire [7:0] uio_oe,   // IO direction control
    input  wire       ena,      // Enable (unused)
    input  wire       clk,      // System clock
    input  wire       rst_n      // Active-low reset
);

    /* -----------------------------
       Input signal mapping
       ----------------------------- */
    wire start       = ui_in[0];
    wire door_open   = ui_in[1];
    wire water_full  = ui_in[2];
    wire drained     = ui_in[3];
    wire dry_sensor  = ui_in[4];
    wire cancel      = ui_in[5];

    /* -----------------------------
       Output wires
       ----------------------------- */
    wire water_fill;
    wire motor_wash;
    wire motor_spin;
    wire drain;
    wire fault;

    /* -----------------------------
       DUT instantiation
       ----------------------------- */
    washer_ctrl dut (
        .clk(clk),
        .rstn(rst_n),
        .start(start),
        .door_open(door_open),
        .water_full(water_full),
        .drained(drained),
        .dry_sensor(dry_sensor),
        .cancel(cancel),
        .water_fill(water_fill),
        .motor_wash(motor_wash),
        .motor_spin(motor_spin),
        .drain(drain),
        .fault(fault)
    );

    /* -----------------------------
       Output mapping
       ----------------------------- */
    assign uo_out[0] = water_fill;
    assign uo_out[1] = motor_wash;
    assign uo_out[2] = motor_spin;
    assign uo_out[3] = drain;
    assign uo_out[4] = fault;
    assign uo_out[7:5] = 3'b000;

    /* -----------------------------
       Unused bidirectional IOs
       ----------------------------- */
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000; // all uio pins as inputs

    /* -----------------------------
       Prevent unused warnings
       ----------------------------- */
    wire _unused = &{ena, uio_in, 1'b0};

endmodule
