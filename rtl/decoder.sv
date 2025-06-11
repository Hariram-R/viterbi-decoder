module decoder
(
   input             clk,
   input             rst,
   input             enable,
   input [1:0]       d_in,
   output logic      d_out);

//bmc module signals  (8 of these)
   wire  [1:0]       bmc0_path_0_bmc;  // N=0,1,...7     N=0,1  (16 2-wire signals in all)
   wire  [1:0]       bmc0_path_1_bmc;
   wire  [1:0]       bmc1_path_0_bmc;
   wire  [1:0]       bmc1_path_1_bmc;
   wire  [1:0]       bmc2_path_0_bmc;
   wire  [1:0]       bmc2_path_1_bmc;
   wire  [1:0]       bmc3_path_0_bmc;
   wire  [1:0]       bmc3_path_1_bmc;
   wire  [1:0]       bmc4_path_0_bmc;
   wire  [1:0]       bmc4_path_1_bmc;
   wire  [1:0]       bmc5_path_0_bmc;
   wire  [1:0]       bmc5_path_1_bmc;
   wire  [1:0]       bmc6_path_0_bmc;
   wire  [1:0]       bmc6_path_1_bmc;
   wire  [1:0]       bmc7_path_0_bmc;
   wire  [1:0]       bmc7_path_1_bmc;


//ACS modules signals (8 of these)
   logic   [7:0]       validity;		//inputs getting flopped from validity_nets, coming from ACSK_valid_o outputs
   logic   [7:0]       selection;		//inputs getting flopped from selection_nets, coming from ACSK_selection outputs
   logic   [7:0]       path_cost   [8];	//inputs getting flopped from ACSK_path_costs outputs, with MSB removed for overflow
   wire    [7:0]       validity_nets;	//outputs getting concatenated from ACSK_valid_o outputs
   wire    [7:0]       selection_nets;	//outputs getting concatenated from ACSK_selection outputs

   wire              ACS0_selection;  // K=0,1,...7		 (i.e., 8 of these)
   wire              ACS1_selection;
   wire              ACS2_selection;
   wire              ACS3_selection;
   wire              ACS4_selection;
   wire              ACS5_selection;
   wire              ACS6_selection;
   wire              ACS7_selection;

   wire              ACS0_valid_o;	  // K=0,1,...7
   wire              ACS1_valid_o;
   wire              ACS2_valid_o;
   wire              ACS3_valid_o;
   wire              ACS4_valid_o;
   wire              ACS5_valid_o;
   wire              ACS6_valid_o;
   wire              ACS7_valid_o;

   wire  [7:0]       ACS0_path_cost;  // K=0,1,...7
   wire  [7:0]       ACS1_path_cost;
   wire  [7:0]       ACS2_path_cost;
   wire  [7:0]       ACS3_path_cost;
   wire  [7:0]       ACS4_path_cost;
   wire  [7:0]       ACS5_path_cost;
   wire  [7:0]       ACS6_path_cost;
   wire  [7:0]       ACS7_path_cost;

//Trelis memory write operation, pipeline delay
   logic   [1:0]       mem_bank;
   logic   [1:0]       mem_bank_Q;
   logic   [1:0]       mem_bank_Q2;
   logic               mem_bank_Q3;
   logic               mem_bank_Q4;
   logic               mem_bank_Q5;
   logic   [9:0]       wr_mem_counter;
   logic   [9:0]       rd_mem_counter;

// 4 memory banks -- address pointers 	  (there are 4 of these)
   logic   [9:0]       addr_mem_A;  // K=A,B,C,D
   logic   [9:0]       addr_mem_B;
   logic   [9:0]       addr_mem_C;
   logic   [9:0]       addr_mem_D;
// write enables
   logic               wr_mem_A;	// K=A,B,C,D
   logic               wr_mem_B;
   logic               wr_mem_C;
   logic               wr_mem_D;
// data to memories
   logic   [7:0]       d_in_mem_A;	// K=A,B,C,D
   logic   [7:0]       d_in_mem_B;
   logic   [7:0]       d_in_mem_C;
   logic   [7:0]       d_in_mem_D;
// data from memories
   wire    [7:0]       d_o_mem_A;	// K=A,B,C,D
   wire    [7:0]       d_o_mem_B;
   wire    [7:0]       d_o_mem_C;
   wire    [7:0]       d_o_mem_D;
		  
//Trace back module signals
   logic               selection_tbu_0;
   logic               selection_tbu_1;

   logic   [7:0]       d_in_0_tbu_0;
   logic   [7:0]       d_in_1_tbu_0;
   logic   [7:0]       d_in_0_tbu_1;
   logic   [7:0]       d_in_1_tbu_1;

   wire                d_o_tbu_0;
   wire                d_o_tbu_1;

   logic               enable_tbu_0;
   logic               enable_tbu_1;

//Display memory operations 
   wire                wr_disp_mem_0;
   wire                wr_disp_mem_1;

   wire                d_in_disp_mem_0;
   wire                d_in_disp_mem_1;

   logic   [9:0]       wr_mem_counter_disp;
   logic   [9:0]       rd_mem_counter_disp;

   logic   [9:0]       addr_disp_mem_0;
   logic   [9:0]       addr_disp_mem_1;

   logic d_o_disp_mem_0;
   logic d_o_disp_mem_1;

//Branch metric calculation modules	(8 total)
   bmc0   bmc0_inst(d_in,bmc0_path_0_bmc,bmc0_path_1_bmc);
   bmc1   bmc1_inst(d_in,bmc1_path_0_bmc,bmc1_path_1_bmc);
   bmc2   bmc2_inst(d_in,bmc2_path_0_bmc,bmc2_path_1_bmc);
   bmc3   bmc3_inst(d_in,bmc3_path_0_bmc,bmc3_path_1_bmc);
   bmc4   bmc4_inst(d_in,bmc4_path_0_bmc,bmc4_path_1_bmc);
   bmc5   bmc5_inst(d_in,bmc5_path_0_bmc,bmc5_path_1_bmc);
   bmc6   bmc6_inst(d_in,bmc6_path_0_bmc,bmc6_path_1_bmc);
   bmc7   bmc7_inst(d_in,bmc7_path_0_bmc,bmc7_path_1_bmc);
/* K=0,1,...7 
*/

//Add Compare Select Modules (8 copies -- note pattern in connections!!)
// i = 0, 1, ... 7        j = 0, 3, 4, 7, 1, 2, 5, 6       k = 1, 2, 5, 6, 0, 3, 4, 7  -- these create lattice butterfly connection pattern
   ACS   ACS0(
      //in
      .path_0_valid(validity[0]),
      .path_1_valid(validity[1]),
      .path_0_bmc(bmc0_path_0_bmc),
      .path_1_bmc(bmc0_path_1_bmc),
      .path_0_pmc(path_cost[0]),
      .path_1_pmc(path_cost[1]),
      //out
      .selection(ACS0_selection),
      .valid_o(ACS0_valid_o),
      .path_cost(ACS0_path_cost)
      );

   ACS   ACS1(validity[3],validity[2],bmc1_path_0_bmc,bmc1_path_1_bmc,path_cost[3],path_cost[2],ACS1_selection,ACS1_valid_o,ACS1_path_cost);
   ACS   ACS2(validity[4],validity[5],bmc2_path_0_bmc,bmc2_path_1_bmc,path_cost[4],path_cost[5],ACS2_selection,ACS2_valid_o,ACS2_path_cost);
   ACS   ACS3(validity[7],validity[6],bmc3_path_0_bmc,bmc3_path_1_bmc,path_cost[7],path_cost[6],ACS3_selection,ACS3_valid_o,ACS3_path_cost);
   ACS   ACS4(validity[1],validity[0],bmc4_path_0_bmc,bmc4_path_1_bmc,path_cost[1],path_cost[0],ACS4_selection,ACS4_valid_o,ACS4_path_cost);
   ACS   ACS5(validity[2],validity[3],bmc5_path_0_bmc,bmc5_path_1_bmc,path_cost[2],path_cost[3],ACS5_selection,ACS5_valid_o,ACS5_path_cost);
   ACS   ACS6(validity[5],validity[4],bmc6_path_0_bmc,bmc6_path_1_bmc,path_cost[5],path_cost[4],ACS6_selection,ACS6_valid_o,ACS6_path_cost);
   ACS   ACS7(validity[6],validity[7],bmc7_path_0_bmc,bmc7_path_1_bmc,path_cost[6],path_cost[7],ACS7_selection,ACS7_valid_o,ACS7_path_cost);

   
   assign selection_nets  = {ACS7_selection,ACS6_selection,ACS5_selection,ACS4_selection,ACS3_selection,ACS2_selection,ACS1_selection,ACS0_selection}; // concatenate ACS7 ,,, ACS0 _selections (use { ,  } format)
   assign validity_nets   = {ACS7_valid_o,ACS6_valid_o,ACS5_valid_o,ACS4_valid_o,ACS3_valid_o,ACS2_valid_o,ACS1_valid_o,ACS0_valid_o};                 // same for ACSK_valid_os 

   always @ (posedge clk, negedge rst) begin
      if(!rst)  begin
         validity          <= 8'b1;
         selection         <= 8'b0;
         for(int i=0;i<8;i++) begin
            path_cost[i]      <= 8'd0;
         end      
      end
      else if(!enable)   begin
         validity          <= 8'b1;
         selection         <= 8'b0;
         for(int i=0;i<8;i++) begin
            path_cost[i]      <= 8'd0;
         end 
      end
      else if (&{path_cost[7][7], path_cost[6][7], path_cost[5][7], path_cost[4][7],
               path_cost[3][7], path_cost[2][7], path_cost[1][7], path_cost[0][7]}) begin // reduction & of all path_costs' MSBs
         validity          <= validity_nets;
         selection         <= selection_nets;
         
         path_cost[0]      <= 8'b01111111 & ACS0_path_cost;	 // K = 0, 1, ..., 7
         path_cost[1]      <= 8'b01111111 & ACS1_path_cost;
         path_cost[2]      <= 8'b01111111 & ACS2_path_cost;
         path_cost[3]      <= 8'b01111111 & ACS3_path_cost;
         path_cost[4]      <= 8'b01111111 & ACS4_path_cost;
         path_cost[5]      <= 8'b01111111 & ACS5_path_cost;
         path_cost[6]      <= 8'b01111111 & ACS6_path_cost;
         path_cost[7]      <= 8'b01111111 & ACS7_path_cost;
      end
      else   begin
         validity          <= validity_nets;
         selection         <= selection_nets;

         path_cost[0]      <= ACS0_path_cost;	          // K = 0, 1, ..., 7
         path_cost[1]      <= ACS1_path_cost;
         path_cost[2]      <= ACS2_path_cost;
         path_cost[3]      <= ACS3_path_cost;
         path_cost[4]      <= ACS4_path_cost;
         path_cost[5]      <= ACS5_path_cost;
         path_cost[6]      <= ACS6_path_cost;
         path_cost[7]      <= ACS7_path_cost;
      end
   end

   always @ (posedge clk)    begin
      d_in_mem_A  <= selection;		  // k = A, B, C, D
      d_in_mem_B  <= selection;		  
      d_in_mem_C  <= selection;		  
      d_in_mem_D  <= selection;		  

   end

   always @ (posedge clk, negedge rst) begin	  // wr_mem_counter   commands
   // if rst (active low) or not enabling (active high), force to 0; else, increment by 1
      if(!rst)  begin
         wr_mem_counter <= 10'd0;
      end
      else if(!enable) begin
         wr_mem_counter <= 10'd0;
      end
      else begin
         wr_mem_counter <= wr_mem_counter + 1'b1;
      end
   end

   always @ (posedge clk, negedge rst) begin
      if(!rst)
         rd_mem_counter <= 10'd1023;// set to max value
      else if(enable)
         rd_mem_counter <= rd_mem_counter - 1'b1; // count down by 1
   end


   always @ (posedge clk, negedge rst) begin
      if(!rst)
         mem_bank <= 2'b0;
      else begin
         if(wr_mem_counter == 10'b1111111111) begin  //fill in the guts
               mem_bank <= mem_bank + 2'b1;
         end
      end
   end

// memory bank management: always write to one, read from two others, keep address at 0 (no writing) for fourth one
   always @ (posedge clk)   begin  	  // in each case, the memory bank w/ the wr_mem_counter needs a write enable; all others = 0
      case(mem_bank)
         2'b00: begin        	 // write to A, clear C, read from others
            wr_mem_A <= 1'b1;
            addr_mem_A <= wr_mem_counter;

            wr_mem_B <= 1'b0;
            addr_mem_B <= rd_mem_counter;

            wr_mem_C <= 1'b0;
            addr_mem_C <= 10'd0;

            wr_mem_D <= 1'b0;
            addr_mem_D <= rd_mem_counter;
         end
         2'b01: begin
            wr_mem_A <= 1'b0;
            addr_mem_A <= rd_mem_counter;

            wr_mem_B <= 1'b1; // write to B, clear D, read from others
            addr_mem_B <= wr_mem_counter;

            wr_mem_C <= 1'b0;
            addr_mem_C <= rd_mem_counter;

            wr_mem_D <= 1'b0;
            addr_mem_D <= 10'd0;
         end
         2'b10: begin      		 // write to C, clear A, read from others
            wr_mem_A <= 1'b0;
            addr_mem_A <= 10'd0;

            wr_mem_B <= 1'b0;
            addr_mem_B <= rd_mem_counter;

            wr_mem_C <= 1'b1;
            addr_mem_C <= wr_mem_counter;

            wr_mem_D <= 1'b0;
            addr_mem_D <= rd_mem_counter;
         end
         2'b11: begin              // write to D, clear B, read from others  
            wr_mem_A <= 1'b0;
            addr_mem_A <= rd_mem_counter;

            wr_mem_B <= 1'b0;
            addr_mem_B <= 10'd0;
                        
            wr_mem_C <= 1'b0;
            addr_mem_C <= rd_mem_counter;

            wr_mem_D <= 1'b1;
            addr_mem_D <= wr_mem_counter;
            
         end		       
      endcase
  end

//Trelis memory module instantiation

   mem   trelis_mem_A   (
      .clk  (clk),
      .wr   (wr_mem_A),
      .addr (addr_mem_A),
      .d_i  (d_in_mem_A),
      .d_o  (d_o_mem_A)
   );
/* likewise for trelis_memB, C, D
*/
   mem   trelis_mem_B   (
      .clk  (clk),
      .wr   (wr_mem_B),
      .addr (addr_mem_B),
      .d_i  (d_in_mem_B),
      .d_o  (d_o_mem_B)
   );

   mem   trelis_mem_C   (
      .clk  (clk),
      .wr   (wr_mem_C),
      .addr (addr_mem_C),
      .d_i  (d_in_mem_C),
      .d_o  (d_o_mem_C)
   );

   mem   trelis_mem_D   (
      .clk  (clk),
      .wr   (wr_mem_D),
      .addr (addr_mem_D),
      .d_i  (d_in_mem_D),
      .d_o  (d_o_mem_D)
   );

//Trace back module operation

   always @(posedge clk) begin
/* create mem_bank, mem_bank_Q1, mem_bank_Q2 pipeline */
      // if(!rst) begin
      //    mem_bank_Q <= 2'b00;
      //    mem_bank_Q2 <= 2'b00;
      // end
      // else begin
         mem_bank_Q <= mem_bank;
         mem_bank_Q2 <= mem_bank_Q;
      // end
   end

   always @ (posedge clk, negedge rst)
      if(!rst)
            enable_tbu_0   <= 1'b0;
      else if(mem_bank_Q2==2'b10)
            enable_tbu_0   <= 1'b1;

   always @ (posedge clk, negedge rst)
      if(!rst)
            enable_tbu_1   <= 1'b0;
      else if(mem_bank_Q2==2'b11)
            enable_tbu_1   <= 1'b1;
   
   always @ (posedge clk)
      case(mem_bank_Q2)
         2'b00:	  begin
            d_in_0_tbu_0   <= d_o_mem_D;
            d_in_1_tbu_0   <= d_o_mem_C;
            
            d_in_0_tbu_1   <= d_o_mem_C;
            d_in_1_tbu_1   <= d_o_mem_B;

            selection_tbu_0<= 1'b0;
            selection_tbu_1<= 1'b1;

         end
         2'b01:	   begin
            d_in_0_tbu_0   <= d_o_mem_D;
            d_in_1_tbu_0   <= d_o_mem_C;
            
            d_in_0_tbu_1   <= d_o_mem_A;
            d_in_1_tbu_1   <= d_o_mem_D;
            
            selection_tbu_0<= 1'b1;
            selection_tbu_1<= 1'b0;
         end
         2'b10:	   begin
            d_in_0_tbu_0   <= d_o_mem_B;
            d_in_1_tbu_0   <= d_o_mem_A;
            
            d_in_0_tbu_1   <= d_o_mem_A;
            d_in_1_tbu_1   <= d_o_mem_D;

            selection_tbu_0<= 1'b0;
            selection_tbu_1<= 1'b1;
         end
         2'b11:	  begin
            d_in_0_tbu_0   <= d_o_mem_B;
            d_in_1_tbu_0   <= d_o_mem_A;
            
            d_in_0_tbu_1   <= d_o_mem_C;
            d_in_1_tbu_1   <= d_o_mem_B;

            selection_tbu_0<= 1'b1;
            selection_tbu_1<= 1'b0;
         end
      endcase

//Trace-Back modules instantiation

   tbu tbu_0   (
      .clk(clk),
      .rst(rst),
      .enable(enable_tbu_0),
      .selection(selection_tbu_0),
      .d_in_0(d_in_0_tbu_0),
      .d_in_1(d_in_1_tbu_0),
      .d_o(d_o_tbu_0),
      .wr_en(wr_disp_mem_0)
   );

/* analogous for tbu_1
*/
   tbu tbu_1   (
      .clk(clk),
      .rst(rst),
      .enable(enable_tbu_1),
      .selection(selection_tbu_1),
      .d_in_0(d_in_0_tbu_1),
      .d_in_1(d_in_1_tbu_1),
      .d_o(d_o_tbu_1),
      .wr_en(wr_disp_mem_1)
   );

//Display Memory modules Instantioation
assign   d_in_disp_mem_0   =  d_o_tbu_0;  // K=0,1
assign   d_in_disp_mem_1   =  d_o_tbu_1;

  mem_disp   disp_mem_0	  (
      .clk(clk),
      .wr(wr_disp_mem_0),
      .addr(addr_disp_mem_0),
      .d_i(d_in_disp_mem_0),
      .d_o(d_o_disp_mem_0)
   );
/* analogous for disp_mem_1
*/
   mem_disp   disp_mem_1  (
      .clk(clk),
      .wr(wr_disp_mem_1),
      .addr(addr_disp_mem_1),
      .d_i(d_in_disp_mem_1),
      .d_o(d_o_disp_mem_1)
   );

// Display memory module operation
   always @ (posedge clk) begin
      /*if(!rst) begin//TODO: to reset or not to reset
         mem_bank_Q3 <= 1'b0;
      end*/
      //else begin
      mem_bank_Q3 <= mem_bank_Q2[0];
      //end
   end

   always @ (posedge clk) begin
      if(!rst)
         wr_mem_counter_disp  <= 10'd2;//TODO: min value + 2
      else if(!enable)
         wr_mem_counter_disp  <= 10'd2;//TODO: same
      else begin
         wr_mem_counter_disp <= wr_mem_counter_disp - 10'b1;
      end
   end
//       decrement wr_mem_counter_disp    

   always @ (posedge clk) begin
      if(!rst)
         rd_mem_counter_disp  <= 10'd1021;//TODO:max value - 2
      else if(!enable)
         rd_mem_counter_disp  <= 10'd1021;//TODO:same
      else begin        // increment    rd_mem_counter_disp  
         rd_mem_counter_disp  <= rd_mem_counter_disp + 1'b1;
      end   
   end

   always @ (posedge clk) begin
       if (!mem_bank_Q3)
         begin
            addr_disp_mem_0   <= rd_mem_counter_disp; 
            addr_disp_mem_1   <= wr_mem_counter_disp;
         end
       else begin // swap rd and wr
		//TODO: 
         addr_disp_mem_1   <= rd_mem_counter_disp; 
         addr_disp_mem_0   <= wr_mem_counter_disp;
       end
      //endcase
   end

   always @ (posedge clk) 	 begin
      // if(!rst) begin
      //    mem_bank_Q4 <= 1'b0;
      //    mem_bank_Q5 <= 1'b0;
      // end
      // else begin
         mem_bank_Q4 <= mem_bank_Q3;
         mem_bank_Q5 <= mem_bank_Q4;

         d_out <= (!mem_bank_Q5) ? d_o_disp_mem_0 : d_o_disp_mem_1;
      // end
   end
 
/* pipeline mem_bank_Q3 to Q4 to Q5
 also  d_out = d_o_disp_mem_i 
    i = mem_bank_Q5 
*/
   //assign d_out = (!mem_bank_Q5) ? d_o_disp_mem_0 : d_o_disp_mem_1;
endmodule
