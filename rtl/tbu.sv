module tbu
(
	input       clk,
	input       rst,
	input       enable,
	input       selection,	//set/unset by ping pong mechanism in decoder
	input [7:0] d_in_0,		//Comes from rotating memory banks
	input [7:0] d_in_1,		//Comes from rotating memory banks
	output logic  d_o,
	output logic  wr_en);
	
	logic         d_o_reg;
	logic         wr_en_reg;
	
	logic   [2:0] pstate;
	logic   [2:0] nstate;
	
	logic         selection_buf;

/*  combinational logic drives:
wr_en_reg, d_o_reg, nstate (next state)
from selection, d_in_1[pstate], d_in_0[pstate]
See assignment text for details
*/

	assign wr_en_reg = selection;
	assign d_o_reg = selection ? d_in_1[pstate] : 0;
	
	always_comb begin
		if (!selection) begin
			case(pstate)
				3'b000: begin
					nstate = d_in_0[pstate] ? 3'd1 : 3'd0;
				end
				3'b001: begin
					nstate = d_in_0[pstate] ? 3'd2 : 3'd3;
				end
				3'b010: begin
					nstate = d_in_0[pstate] ? 3'd5 : 3'd4;
				end
				3'b011: begin
					nstate = d_in_0[pstate] ? 3'd6 : 3'd7;
				end
				3'b100: begin
					nstate = d_in_0[pstate] ? 3'd0 : 3'd1;
				end
				3'b101: begin
					nstate = d_in_0[pstate] ? 3'd3 : 3'd2;
				end
				3'b110: begin
					nstate = d_in_0[pstate] ? 3'd4 : 3'd5;
				end
				3'b111: begin
					nstate = d_in_0[pstate] ? 3'd7 : 3'd6;
				end
			endcase
		end
		else begin
			case(pstate)
				3'b000: begin
					nstate = d_in_1[pstate] ? 3'd1 : 3'd0;
				end
				3'b001: begin
					nstate = d_in_1[pstate] ? 3'd2 : 3'd3;
				end
				3'b010: begin
					nstate = d_in_1[pstate] ? 3'd5 : 3'd4;
				end
				3'b011: begin
					nstate = d_in_1[pstate] ? 3'd6 : 3'd7;
				end
				3'b100: begin
					nstate = d_in_1[pstate] ? 3'd0 : 3'd1;
				end
				3'b101: begin
					nstate = d_in_1[pstate] ? 3'd3 : 3'd2;
				end
				3'b110: begin
					nstate = d_in_1[pstate] ? 3'd4 : 3'd5;
				end
				3'b111: begin
					nstate = d_in_1[pstate] ? 3'd7 : 3'd6;
				end
			endcase
		end
	end


	always @(posedge clk)    begin
		selection_buf  <= selection;
		wr_en          <= wr_en_reg;
		d_o            <= d_o_reg;
	end

	always @(posedge clk, negedge rst) begin
    //reset p state to 0
    //exception:  rst = enable = selection_buf = 1, but selection = 0, then go to n_state
		if (!rst) pstate <= 3'b000;
		else begin
			//FIXME: This condition seems dodgy
			if (enable && !selection_buf && selection) pstate <= nstate;
			else pstate <= 3'b000;
		end
	end


endmodule
