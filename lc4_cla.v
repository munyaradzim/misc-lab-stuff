/* TODO: INSERT NAME AND PENNKEY HERE */

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);
   wire c_out_temp_in, p_one_zero, c_two_in_one, c_two_in_two, g_three_two, p_three_two;
   wire p_g_temp_in, p_g_temp, cout_two_temp, gout_temp;

   assign c_out_temp_in = pin[0] & cin;
   assign cout[0] = gin[0] | c_out_temp_in;
   assign p_one_zero = pin[1] & pin[0];
   assign c_two_in_one = p_one_zero & cin;
   assign p_g_temp_in = pin[1] & gin[0];
   assign c_two_in_two = p_g_temp_in | gin[1]; // g_1-0
   assign cout[1] = c_two_in_one | c_two_in_two;
   assign p_three_two = pin[2] & pin[3];
   assign p_g_temp = pin[3] & gin[2];
   assign g_three_two = p_g_temp | gin[3]; 
   assign cout_two_temp = p_three_two & cout[1];
   assign cout[2] = gin[2] | (pin[2] & cout[1]);
   assign pout = p_three_two & p_one_zero;
   assign gout_temp = c_two_in_two & p_three_two; 
   assign gout = gout_temp | g_three_two;



endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);

   

endmodule


/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);
 
endmodule
