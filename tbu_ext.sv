module tbu (
    input       clk,
    input       rst,
    input       enable,
    input       selection,
    input [7:0] d_in_0,
    input [7:0] d_in_1,
    output logic  d_o,
    output logic  wr_en
);

    logic         d_o_reg;
    logic         wr_en_reg;

    logic   [2:0] pstate;
    logic   [2:0] nstate;

    logic         selection_buf;

    always @(posedge clk)    begin
        selection_buf  <= selection;
        wr_en          <= wr_en_reg;
        d_o            <= d_o_reg;
    end

    always @(posedge clk, negedge rst) begin
        // reset p state to 0
        // exception:  rst = enable = selection_buf = 1, but selection = 0, then go to n_state
        if (!rst)
            pstate  <= 3'b000;
        else if (!enable)
            pstate  <= 3'b000;
        else if (selection_buf & !selection)
            pstate  <= 3'b000;
        else
            pstate  <= nstate;
    end

/*  combinational logic drives:
wr_en_reg, d_o_reg, nstate (next state)
from selection, d_in_1[pstate], d_in_0[pstate]
See assignment text for details
*/
    always_comb begin
        wr_en_reg = selection;
        d_o_reg = (selection) ? d_in_1[pstate] : 0;
        if ((!selection & !d_in_0[pstate]) | (selection & !d_in_1[pstate])) begin            
            case(pstate)
                3'b000:
                    nstate = 3'b000;
                3'b001:
                    nstate = 3'b011;
                3'b010:
                    nstate = 3'b100;
                3'b011:
                    nstate = 3'b111;
                3'b100:
                    nstate = 3'b001;
                3'b101:
                    nstate = 3'b010;
                3'b110:
                    nstate = 3'b101;
                3'b111:
                    nstate = 3'b110;
            endcase
        end else if ((!selection & d_in_0[pstate]) | (selection & d_in_1[pstate])) begin
            case(pstate)
                3'b000:
                    nstate = 3'b001;
                3'b001:
                    nstate = 3'b010;
                3'b010:
                    nstate = 3'b101;
                3'b011:
                    nstate = 3'b110;
                3'b100:
                    nstate = 3'b000;
                3'b101:
                    nstate = 3'b011;
                3'b110:
                    nstate = 3'b100;
                3'b111:
                    nstate = 3'b111;
            endcase

        end else begin
            nstate = pstate;            
        end
    end
endmodule
