module counter (
	clk,
	rstn,
	start,
	done
);
	parameter COUNT_MAX = 5;
	input wire clk;
	input wire rstn;
	input wire start;
	output reg done;
	reg [$clog2(COUNT_MAX) - 1:0] count;
	always @(posedge clk or negedge rstn)
		if (!rstn) begin
			count <= 0;
			done <= 0;
		end
		else if (start) begin
			if (count < (COUNT_MAX - 1)) begin
				count <= count + 1;
				done <= 0;
			end
			else begin
				count <= 0;
				done <= 1;
			end
		end
endmodule
