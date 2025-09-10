`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Outputs
    input  wire [7:0] uio_in,   // IOs (unused)
    output wire [7:0] uio_out,  // IOs (unused)
    output wire [7:0] uio_oe,   // IOs (set to input mode)
    input  wire       ena,      // Always 1 (ignore)
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset (active low)
);

    // === Signal mapping ===
    wire spi_clk, spi_data, cs_n;

    top_module uut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(ui_in[0]),           // UART input
        .din_en(ui_in[1]),       // Data input enable
        .start_sending(ui_in[2]),// Start sending

        .spi_clock(spi_clk),
        .spi_data(spi_data),
        .cs_n(cs_n),

        // Debug signals left unconnected
        .seg1(), .seg2(), .seg3(), .seg4(),
        .done_send(),
        .m_valid(),
        .addr()
    );

    // === Assign outputs ===
    assign uo_out[0] = spi_clk;
    assign uo_out[1] = spi_data;
    assign uo_out[2] = cs_n;
    assign uo_out[7:3] = 5'b00000; // unused outputs

    // === Tie off unused IOs ===
    assign uio_out = 8'd0;
    assign uio_oe  = 8'd0;

    // Prevent unused warnings
    wire _unused = &{ena, uio_in, 1'b0};

endmodule
