`include "counter.v"
module washer_ctrl (
	clk,
	rstn,
	start,
	door_open,
	water_full,
	drained,
	dry_sensor,
	cancel,
	water_fill,
	motor_wash,
	motor_spin,
	drain,
	fault
);
	reg _sv2v_0;
	parameter T_WASH = 10;
	parameter T_SPIN_MAX = 12;
	parameter N_REWASH = 3;
	input wire clk;
	input wire rstn;
	input wire start;
	input wire door_open;
	input wire water_full;
	input wire drained;
	input wire dry_sensor;
	input wire cancel;
	output reg water_fill;
	output reg motor_wash;
	output reg motor_spin;
	output reg drain;
	output reg fault;
	reg [2:0] state;
	reg [2:0] next_state;
	reg wash_timer_start;
	wire wash_timer_done;
	reg spin_timer_start;
	wire spin_timer_done;
	reg [$clog2(N_REWASH) - 1:0] rewash_count;
	counter #(.COUNT_MAX(T_WASH)) wash_timer(
		.clk(clk),
		.rstn(rstn),
		.start(wash_timer_start),
		.done(wash_timer_done)
	);
	counter #(.COUNT_MAX(T_SPIN_MAX)) spin_timer(
		.clk(clk),
		.rstn(rstn),
		.start(spin_timer_start),
		.done(spin_timer_done)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		case (state)
			3'd0: next_state = (start ? 3'd1 : 3'd0);
			3'd1: next_state = (water_full ? 3'd2 : 3'd1);
			3'd2: next_state = (wash_timer_done ? 3'd3 : 3'd2);
			3'd3: next_state = ((drained == 1) && (rewash_count == 0) ? 3'd4 : ((drained == 1) && (rewash_count != 0) ? 3'd1 : 3'd3));
			3'd4: next_state = ((spin_timer_done == 1) || (dry_sensor == 1) ? 3'd5 : 3'd4);
			3'd5: next_state = (drained ? 3'd0 : 3'd5);
			default: next_state = 3'd0;
		endcase
	end
	always @(posedge clk or negedge rstn)
		if (!rstn )
			state <= 3'd0;
		else if (cancel)
			state <= 3'd0;
		else if (door_open)
			state <= 3'd6;
		else
			state <= next_state;
	always @(posedge clk or negedge rstn)
		if (!rstn)
			rewash_count <= N_REWASH;
		else
			case (state)
				3'd0: begin
					{water_fill, motor_wash, motor_spin, drain, fault, wash_timer_start, spin_timer_start} <= 7'b0000000;
					rewash_count <= N_REWASH;
				end
				3'd1: begin
					water_fill <= 1;
					drain <= 0;
				end
				3'd2: begin
					motor_wash <= 1;
					water_fill <= 0;
					wash_timer_start <= 1;
				end
				3'd3: begin
					drain <= 1;
					motor_wash <= 0;
					if (drained)
						rewash_count <= rewash_count - 1;
				end
				3'd4: begin
					drain <= 0;
					motor_spin <= 1;
					spin_timer_start <= 1;
				end
				3'd5: begin
					drain <= 1;
					motor_spin <= 0;
				end
				3'd6: begin
					fault <= 1;
					water_fill <= 0;
					motor_wash <= 0;
					motor_spin <= 0;
					drain <= 0;
				end
				default : begin end 
			endcase
	initial _sv2v_0 = 0;
endmodule
