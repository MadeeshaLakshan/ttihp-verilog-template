module data_mem(
    input clk,we,
    input [23:0] data_in,
    input [4:0] addr,
    output reg [23:0]data_out
);
    reg [23:0] memory [0:15]; // 16x24-bit memory

    // Initialize memory with hardcoded values
    initial begin
        memory[0] = 24'h008000;
        memory[1] = 24'h008000;
        memory[2] = 24'h070000;
        memory[3] = 24'h654321;
        memory[4] = 24'h123456;
        memory[5] = 24'h654321;
        memory[6] = 24'h123456;
        memory[7] = 24'h654321;
        memory[8] = 24'h999999;
    end
always @(posedge clk) 
begin
    if(we) memory[addr] <= data_in; // Write data to memory
    data_out <= memory[addr]; // Read data from memory
 end
endmodule