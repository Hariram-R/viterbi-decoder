/*ARJIT: THIS UNIT HELPS DETERMINE THE OPTIMAL PATH AT EACH STATE*/

module ACS		                        // add-compare-select
(  input       path_0_valid,
   input       path_1_valid,
   input [1:0] path_0_bmc,	            // branch metric computation
   input [1:0] path_1_bmc,				
   input [7:0] path_0_pmc,				// path metric computation
   input [7:0] path_1_pmc,

   output logic        selection,
   output logic        valid_o,
   output      [7:0] path_cost);  

   wire  [7:0] path_cost_0;			   // branch metric + path metric
   wire  [7:0] path_cost_1;

/* Fill in the guts per ACS instructions*/
   assign valid_o = path_0_valid | path_1_valid; //valid path exists if path_0 or path_1 are valid

   //Add
   assign path_cost_0 = path_0_pmc + path_0_bmc; //accumulated cost so far + current cost
   assign path_cost_1 = path_1_pmc + path_1_bmc; //accumulated cost so far + current cost

   wire both_paths_valid;
   assign both_paths_valid = path_0_valid && path_1_valid;

   wire path_1_shorter;
   assign path_1_shorter = (path_cost_1 < path_cost_0) ? 1 : 0;
  
   //If both paths are valid and path1 is shorter, set to path_cost_1
   //If both paths are valid and path1 is not shorter, set to path_cost_0

  
  //If both paths are not valid and path1 is valid, set to path_cost_1
  //If both apths are not valid and path1 is not valid, set to path_cost_0
  assign path_cost = both_paths_valid ? (path_1_shorter ? path_cost_1 : path_cost_0) : (path_1_valid ? path_cost_1 : path_cost_0);
  
  assign selection = both_paths_valid ? (path_1_shorter ? 1'b1 : 1'b0) : (path_1_valid ? 1'b1 : 1'b0);
  
   /*
   //Compare and Select
   always_comb begin
      if (path_0_valid && path_1_valid) begin
         if (path_cost_0 < path_cost_1) begin
            selection = 1'b0; //select path_0 if that is shorter
            path_cost = path_cost_0; //select path_0 if that is shorter
         end
         else if (path_cost_0 > path_cost_1) begin
            selection = 1'b1; //select path_1 if that is shorter
            path_cost = path_cost_1; //select path_1 if that is shorter
         end
         else begin
            selection = 1'b0; //select path_0 if both are equal
            path_cost = path_cost_0; //select path_0 if both are equal
         end
      end
      else if (path_0_valid && !path_1_valid) begin
         selection = 1'b0; //select path_0 if only that is valid
         path_cost = path_cost_0; //select path_0 if only that is valid
      end
      else if (!path_0_valid && path_1_valid) begin
         selection = 1'b1; //select path_1 if only that is valid
         path_cost = path_cost_1; //select path_1 if only that is valid
      end
      else begin
         selection = 1'b0; //select path_0 if neither is valid
         path_cost = path_cost_0; //select path_0 if neither is valid
      end
   end
   */
endmodule
