/* TODO: INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/
      wire [15:0] div1, div2, div3, div4, div5, div6, div7, div8, div9, div10, div11, div12, div13, div14, div15, div16;
      wire [15:0] rem1, rem2, rem3, rem4, rem5, rem6, rem7, rem8, rem9, rem10, rem11, rem12, rem13, rem14, rem15;
      wire [15:0] quo1, quo2, quo3, quo4, quo5, quo6, quo7, quo8, quo9, quo10, quo11, quo12, quo13, quo14, quo15;
      
      lc4_divider_one_iter d0(.i_dividend(i_dividend), .i_divisor(i_divisor), .i_remainder(16'b0000000000000000), .i_quotient(16'b0000000000000000), .o_dividend(div1), .o_remainder(rem1), .o_quotient(quo1));
      lc4_divider_one_iter d1(.i_dividend(div1), .i_divisor(i_divisor), .i_remainder(rem1), .i_quotient(quo1), .o_dividend(div2), .o_remainder(rem2), .o_quotient(quo2));
      lc4_divider_one_iter d2(.i_dividend(div2), .i_divisor(i_divisor), .i_remainder(rem2), .i_quotient(quo2), .o_dividend(div3), .o_remainder(rem3), .o_quotient(quo3));
      lc4_divider_one_iter d3(.i_dividend(div3), .i_divisor(i_divisor), .i_remainder(rem3), .i_quotient(quo3), .o_dividend(div4), .o_remainder(rem4), .o_quotient(quo4));
      lc4_divider_one_iter d4(.i_dividend(div4), .i_divisor(i_divisor), .i_remainder(rem4), .i_quotient(quo4), .o_dividend(div5), .o_remainder(rem5), .o_quotient(quo5));
      lc4_divider_one_iter d5(.i_dividend(div5), .i_divisor(i_divisor), .i_remainder(rem5), .i_quotient(quo5), .o_dividend(div6), .o_remainder(rem6), .o_quotient(quo6));
      lc4_divider_one_iter d6(.i_dividend(div6), .i_divisor(i_divisor), .i_remainder(rem6), .i_quotient(quo6), .o_dividend(div7), .o_remainder(rem7), .o_quotient(quo7));
      lc4_divider_one_iter d7(.i_dividend(div7), .i_divisor(i_divisor), .i_remainder(rem7), .i_quotient(quo7), .o_dividend(div8), .o_remainder(rem8), .o_quotient(quo8));
      lc4_divider_one_iter d8(.i_dividend(div8), .i_divisor(i_divisor), .i_remainder(rem8), .i_quotient(quo8), .o_dividend(div9), .o_remainder(rem9), .o_quotient(quo9));
      lc4_divider_one_iter d9(.i_dividend(div9), .i_divisor(i_divisor), .i_remainder(rem9), .i_quotient(quo9), .o_dividend(div10), .o_remainder(rem10), .o_quotient(quo10));
      lc4_divider_one_iter d10(.i_dividend(div10), .i_divisor(i_divisor), .i_remainder(rem10), .i_quotient(quo10), .o_dividend(div11), .o_remainder(rem11), .o_quotient(quo11));
      lc4_divider_one_iter d11(.i_dividend(div11), .i_divisor(i_divisor), .i_remainder(rem11), .i_quotient(quo11), .o_dividend(div12), .o_remainder(rem12), .o_quotient(quo12));
      lc4_divider_one_iter d12(.i_dividend(div12), .i_divisor(i_divisor), .i_remainder(rem12), .i_quotient(quo12), .o_dividend(div13), .o_remainder(rem13), .o_quotient(quo13));
      lc4_divider_one_iter d13(.i_dividend(div13), .i_divisor(i_divisor), .i_remainder(rem13), .i_quotient(quo13), .o_dividend(div14), .o_remainder(rem14), .o_quotient(quo14));
      lc4_divider_one_iter d14(.i_dividend(div14), .i_divisor(i_divisor), .i_remainder(rem14), .i_quotient(quo14), .o_dividend(div15), .o_remainder(rem15), .o_quotient(quo15));
      lc4_divider_one_iter d15(.i_dividend(div15), .i_divisor(i_divisor), .i_remainder(rem15), .i_quotient(quo15), .o_dividend(div16), .o_remainder(o_remainder), .o_quotient(o_quotient));
      

endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/

      wire [15:0] remainder_temp = (i_remainder << 1) | ((i_dividend >> 15) & 16'b1); // upper right corner
      wire [15:0] quo_shift_one = i_quotient << 1; // into the quotient mux
      wire [15:0] rem_divisor_comp = remainder_temp < i_divisor;
      wire [15:0] q_temp = rem_divisor_comp ? (quo_shift_one) : (quo_shift_one | 16'b1); //check ordering of tenary op
      wire [15:0] divisor_check = i_divisor ^ 16'b0;
      assign o_quotient = (i_divisor ^ 16'b0) ? q_temp : 16'b0;
      assign o_dividend = i_dividend << 1;     
      wire [15:0] temp_remainder =  (rem_divisor_comp) ? (remainder_temp) : (remainder_temp - i_divisor);
      assign o_remainder = (divisor_check) ? temp_remainder : 16'b0; // forgot to do this check in our schematic (whoops)




endmodule
