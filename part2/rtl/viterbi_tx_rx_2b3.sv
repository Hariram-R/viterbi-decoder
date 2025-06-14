// contains convolutional encoder,
//  (possibly corrupting) channel,
//  and Viterbi decoder
// parameter N sets the channel bit error rate
// this time, bit[0] every 16 clocks
module viterbi_tx_rx #(parameter N=4) (
   input    clk,
   input    rst,
   input    encoder_i,
   input    enable_encoder_i,
   output   decoder_o);

   wire  [1:0] encoder_o;  // connects encoder to decoder

   int           error_counter,	err_trig,
                 bad_bit_ct,
                 word_ct, err_set;
   logic   [1:0] encoder_o_reg0,
                 encoder_o_reg;
   logic         encoder_i_reg;
   logic         enable_decoder_in;
   logic         enable_encoder_i_reg;
   wire          valid_encoder_o;
   logic   [1:0] err_inj;

   always @ (posedge clk, negedge rst) 
      if(!rst) begin  
	  $display("viterbi_tx_rx2.sv");
         error_counter        <= 'd0;
         encoder_o_reg        <= 'b0;		 
		   encoder_o_reg0       <= 'b0;
         enable_decoder_in    <= 'b0;
		   enable_encoder_i_reg <= 'b0;
		   word_ct              <= 'b0;
         err_set              <= 'b0;
      end
      else begin 
         enable_encoder_i_reg <= enable_encoder_i;  
         enable_decoder_in    <= valid_encoder_o; 
         // bit error injection in encoder_o_reg        					           					           
         encoder_i_reg     <= encoder_i;
         encoder_o_reg0    <= encoder_o;
         // word_ct[N-1:0] generates strings of 2**N consecutive errors
         word_ct              <= word_ct + 1;
         if(err_set==1'b0 && word_ct[3:0]=='0) begin	
            //err_trig =  error_counter*8+($random % (7 + 1));
            err_trig =  ($random % (15 + 1));
            err_set = 1'b1;
         end
         //if(err_trig)

         if((word_ct<256) &&((word_ct[3:0]==err_trig[3:0]))) begin	 // err_trig[N-1:0]
            error_counter   <= error_counter + 2;
            //  N controls average rate of error injection
            err_set <= 1'b0;
            //if(err_set!=2'b2) begin
            err_inj        <= 2'b11;
            //end
            encoder_o_reg  <= encoder_o^err_inj;	 // inject bad bits 
            //encoder_o_reg  <= encoder_o;
         end
         else begin       		   // clean version
            err_inj        <= 2'b00;
            encoder_o_reg  <= encoder_o;
		end
        if(word_ct<256) begin
          bad_bit_ct  <= bad_bit_ct + (encoder_o_reg0[1]^encoder_o_reg[1])
		                      + (encoder_o_reg0[0]^encoder_o_reg[0]);
		  $display("error_counter,err_inj = %h %b %d %d",
		         error_counter,err_inj,bad_bit_ct,word_ct);
        end
      end   

																				   
// insert your convolutional encoder here
// change port names and module name as necessary/desired
   encoder encoder1	     (
      .clk(clk),
      .rst(rst),
      .enable_i(enable_encoder_i), //_reg),
      .d_in    (encoder_i),        //_reg),
      .valid_o (valid_encoder_o),
      .d_out   (encoder_o)   );

// insert your term project code here 
   decoder decoder1	     (
      .clk(clk),
      .rst(rst),
      .enable (enable_decoder_in),
      .d_in   (encoder_o_reg),
      .d_out  (decoder_o)   );

endmodule
