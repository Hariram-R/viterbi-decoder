module tbu
(
	input       clk,
	input       rst,
	input       enable,
	input       selection,	//FIXME: who's providing this input?
	input [7:0] d_in_0,		//FIXME: who's providing this input?
	input [7:0] d_in_1,		//FIXME: who's providing this input?
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
					//hemlo deer
					nstate = d_in_0[pstate] ? 1 : 0;
				end
				3'b001: begin
					//hemlo deer
					nstate = d_in_0[pstate] ? 2 : 3;
				end
				3'b010: begin
					//hemlo deer
					nstate = d_in_0[pstate] ? 5 : 4;
				end
				3'b011: begin
					//hemlo deer
					nstate = d_in_0[pstate] ? 6 : 7;
				end
				3'b100: begin
					//hemlo deer
					nstate = d_in_0[pstate] ? 0 : 1;
				end
				3'b101: begin
					//hemlo deer
					nstate = d_in_0[pstate] ? 3 : 2;
				end
				3'b110: begin
					//hemlo deer
					nstate = d_in_0[pstate] ? 4 : 5;
				end
				3'b111: begin
					//hemlo deer
					nstate = d_in_0[pstate] ? 7 : 6;
				end
			endcase
		end
		else begin
			case(pstate)
				3'b000: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 1 : 0;
				end
				3'b001: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 2 : 3;
				end
				3'b010: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 5 : 4;
				end
				3'b011: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 6 : 7;
				end
				3'b100: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 0 : 1;
				end
				3'b101: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 3 : 2;
				end
				3'b110: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 4 : 5;
				end
				3'b111: begin
					//hemlo deer
					nstate = d_in_1[pstate] ? 7 : 6;
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
		if (!rst) pstate <= 0;
		else begin
			if (enable && selection_buf && !selection) pstate <= nstate;
			else pstate <= pstate;
		end
	end


endmodule
