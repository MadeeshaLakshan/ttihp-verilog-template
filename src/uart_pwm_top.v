module uart_pwm_top (
    input  wire        clk,        // System clock
    input  wire        rst_n,      // Active low reset
    input  wire        uart_rx,    // UART RX input
    output wire [8:0]  pwm_out,    // 9 PWM outputs

    // === Added for 4 seven-segment displays ===
    output wire [6:0] seg0,
    output wire [6:0] seg1,
    output wire [6:0] seg2,
    output wire [6:0] seg3,
	 output reg [3:0]  pkt_count
);

    // UART receiver signals
    wire        rx_valid;
    wire [15:0] rx_data;

    // Instantiate UART receiver
    uart_rx #(.CLOCKS_PER_PULSE(434), // Assuming 50MHz clock and 115200 baud rate
              .BITS_PER_WORD(8),     // 16 bits per word
              .W_OUT(16) 
    ) uart_rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_rx),
        .m_data(rx_data),
        .m_valid(rx_valid)
    );

    // Duty registers
    reg [15:0] duty_reg [0:8];
    //reg [3:0]  pkt_count;  // count 0-8

    // Update duty registers when new packet received
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pkt_count <= 4'd0;
        end else if (rx_valid) begin
            duty_reg[pkt_count] <= rx_data;
            if (pkt_count == 4'd8)
                pkt_count <= 4'd0;
            else
                pkt_count <= pkt_count + 1;
        end
    end

    // Instantiate PWM generator (9 channels)
    pwm_9ch #(
        .RESOLUTION(16)
    ) pwm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .duty0(duty_reg[0]),
        .duty1(duty_reg[1]),
        .duty2(duty_reg[2]),
        .duty3(duty_reg[3]),
        .duty4(duty_reg[4]),
        .duty5(duty_reg[5]),
        .duty6(duty_reg[6]),
        .duty7(duty_reg[7]),
        .duty8(duty_reg[8]),
        .pwm_out(pwm_out)
    );

    // === Added: Display last received rx_data on 4 seven-segment displays ===
    wire [3:0] digit0 = rx_data[3:0];    // Least significant nibble
    wire [3:0] digit1 = rx_data[7:4];
    wire [3:0] digit2 = rx_data[11:8];
    wire [3:0] digit3 = rx_data[15:12];  // Most significant nibble

    sev_seg_decorder seg_inst0 (.digit(digit0), .seg(seg0));
    sev_seg_decorder seg_inst1 (.digit(digit1), .seg(seg1));
    sev_seg_decorder seg_inst2 (.digit(digit2), .seg(seg2));
    sev_seg_decorder seg_inst3 (.digit(digit3), .seg(seg3));

endmodule
