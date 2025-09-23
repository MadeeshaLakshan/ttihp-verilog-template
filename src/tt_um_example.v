`default_nettype none

module tt_um_madeesha (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Outputs
    input  wire [7:0] uio_in,   // IOs (unused)
    output wire [7:0] uio_out,  // IOs (unused)
    output wire [7:0] uio_oe,   // IOs (set to input mode)
    input  wire       ena,      // Always 1 (ignore)
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset (active low)
);

    // === Internal signals ===
    wire [8:0] pwm_out;
    wire [6:0] seg0, seg1, seg2, seg3;
    wire [3:0] pkt_count;

    // === DUT instantiation ===
    uart_pwm_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(ui_in[0]),   // Map UART RX to ui_in[0]

        .pwm_out(pwm_out),

        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),

        .pkt_count(pkt_count)
    );

    // === Assign outputs ===
    // Map 8 outputs: pick important signals
    assign uo_out[0] = pwm_out[0];   // PWM0
    assign uo_out[1] = pwm_out[1];   // PWM1
    assign uo_out[2] = pwm_out[2];   // PWM2
    assign uo_out[3] = pwm_out[3];   // PWM3
    assign uo_out[4] = pwm_out[4];   // PWM4
    assign uo_out[5] = pwm_out[5];   // PWM5
    assign uo_out[6] = pwm_out[6];   // PWM6
    assign uo_out[7] = pwm_out[7];   // PWM7
    // Note: pwm_out[8], segments, and pkt_count not connected (too many signals for 8-bit out)

    // === Tie off unused IOs ===
    assign uio_out = 8'd0;
    assign uio_oe  = 8'd0;

    // Prevent unused warnings
    wire _unused = &{ena, uio_in, pwm_out[8], seg0, seg1, seg2, seg3, pkt_count, 1'b0};

endmodule
