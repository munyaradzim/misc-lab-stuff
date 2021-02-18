/* INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ps

`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);

      /*** YOUR CODE HERE ***/

endmodule



module alu_final (input wire [3:0] instr, input wire [15:0] branch_mux, input wire [15:0] out_arith_mux,
        input wire [15:0] out_cmp_mux, input wire [15:0] jsr_mux, input wire [15:0] logic_mux, input wire [15:0] ldr_cla_mux, 
        input wire [15:0] str_cla_mux, input wire [15:0] r1_rti, input wire [15:0] const, input wire [15:0] shft_mux, 
        input wire [15:0] jmp_mux, input wire [15:0] hi_const, input wire [15:0] out_trap, output wire[15:0] Out);

assign Out = (instr == 4'd0) ? branch_mux :
             (instr == 4'd1) ? out_arith_mux :
             (instr == 4'd2) ? out_cmp_mux :
             (instr == 4'd4) ? jsr_mux :
             (instr == 4'd5) ? logic_mux :
             (instr == 4'd6) ? ldr_cla_mux :
             (instr == 4'd7) ? str_cla_mux :
             (instr == 4'd8) ? r1_rti :
             (instr == 4'd9) ? const :
             (instr == 4'd10) ? shft_mux :
             (instr == 4'd12) ? jmp_mux :
             (instr == 4'd13) ? hi_const :
             (instr == 4'd15) ? out_trap :
             16'd0;
endmodule



module arith_mux (input wire [15:0] instr, input wire [15:0] rs, input wire [15:0] rt, output wire [15:0] Out);
wire mul_calc[15:0] = r2 * rt;
wire [15:0] div_lc4, dummy;
lc4_divider div(rs, rt, dummy, div_lc4);

assign Out = (instr[5:3] == 3'd0) ? add_cla :
             (instr[5:3] == 3'd1) ? mul_calc :
             (instr[5:3] == 3'd2) ? sub_cla:
             (instr[5:3] == 3'd3) ? div_lc4 :
             add_imm_cla;
endmodule



module trap_calc (input wire [7:0] instr, output wire [15:0] Out);

assign Out = {8{1'd0}, instr} | (16'h8000);

endmodule



module jsr_mux (input wire [15:0] pc, input wire [15:0] rs, input wire [10:0] instr, output wire [15:0] Out);

wire jsr_calc = (pc & 16'h8000) | (instr[10] ? {5{1'd1}, instr}: {5{1'd0}, instr}) << 4 //sign ext
assign Out = instr[11] ? jsr_calc : rs;

endmodule



module cmp_mux (input wire [15:0] instr, input wire [15:0] rs, input wire [15:0] rt, output wire [15:0] Out);
wire rt_val, rs_val;

//rs val is doing what cmp_mux_a does
assign rt_val = (instr[8:7] == 2'd0) ? rs :
                (instr[8:7] == 2'd1) ? $unsigned(rs) :
                (instr[8:7] == 2'd2) ? rs:
                $unsigned(rs);

//rt val is doing what cmp_mux_b does
assign rt_val = (instr[8:7] == 2'd0) ? rt :
                (instr[8:7] == 2'd1) ? $unsigned(rt) :
                (instr[8:7] == 2'd2) ? instr[6] ? {9{1'd1}, instr[6:0]}: {9 {1'd0}, instr[6:0]}:
                {9 {1'd0}, instr[6:0]};

wire less_than_comp = (rs_val < rt_val);
wire equal_comp = (rs_val == rt_val);

assign Out = less_than_comp ? {16{1'b1}} : //nzp -1 if less than
             equal_comp ? 16'b0 : //nzp if equal
             16'b1; //nzp 1 otherwise

endmodule 




module logic_mux (input wire [15:0] instr, input wire [15:0] rs, input wire [15:0] rt, output wire [15:0] Out);

wire and_calc = rs & rt;
wire or_calc = rs | rt;
wire not_calc = ~rs;
wire xor_calc = rt ^ rs;
wire and_imm = rs & {instr[4] ? {11{1'd1}, instr[4:0]}: {11 {1'd0}, instr[4:0]}};

assign Out = (instr[5:3] == 3'd0) ? and_calc :
             (instr[5:3] == 3'd1) ? not_calc :
             (instr[5:3] == 3'd2) ? or_calc :
             (instr[5:3] == 3'd3) ? xor_calc :
             and_imm;

endmodule



module rti_calc (input wire [15:0] rs, output wire [15:0] Out); //trivial but included for sanity

assign Out = rs;

endmodule



module shift_mux (input wire [15:0] instr, input wire [15:0] rs, output wire [15:0] Out);

wire uimm4 = {12{1'b0}, instr[3:0]};
wire sll_calc = rs << uimm4;
wire sra_calc = rs >>> uimm4;
wire srl_calc = rs >> uimm4;

wire mod_calc, dummy; //do this and assign
lc4_divider div(rs, rt, mod_calc, dummy);

assign Out = (instr[5:4] == 2'd0) ? sll_calc :
             (instr[5:4] == 2'd1) ? sra_calc :
             (instr[5:4] == 2'd2) ? srl_calc :
             (instr[5:4] == 2'd3) ? mod_calc :
             16'd0;

endmodule


//jmp depends on cla for one of them

module hiconst (input wire [15:0] instr, input wire [15:0] rd, output wire [15:0] Out);
wire uimm8 = {8{1'b0}, instr[7:0]};
assign Out = (rd & 16'hFF) | (uimm8 << 8);

endmodule
