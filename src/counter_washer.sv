module counter #(
    parameter COUNT_MAX = 5
) (
    input logic clk, rstn, start,
    output logic done
);

logic [$clog2(COUNT_MAX)-1:0] count;

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        count <= 0;
        done <= 0;
    end else if(start) begin
        if (count < COUNT_MAX - 1) begin
            count <= count + 1;
            done <= 0;
        end else begin
            count <= 0;
            done <= 1;
        end
    end
end
    
endmodule