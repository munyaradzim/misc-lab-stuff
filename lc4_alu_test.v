/* INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ps

`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);

      /*** YOUR CODE HERE ***/
      wire [15:0] arith, trap, jsr, cmp, logic, rti, shift, hiconst, cla, const, jmp;

      assign rti = i_r1data;
      assign trap = {{8{1'd0}}, i_insn[7:0]} | 16'h8000;
      assign const = i_insn[8] ? {{7{1'd1}}, i_insn[8:0]} : {{7{1'd0}}, i_insn[8:0]};
      jmp_mux j0(.instr(i_insn), .rs(i_r1data), .cla(cla), .Out(jmp));
      arith_mux a0(.instr(i_insn), .rs(i_r1data), .rt(i_r2data), .cla(cla), .Out(arith));
      jsr_mux j1(.instr(i_insn), .pc(i_pc), .rs(i_r1data), .Out(jsr));
      cmp_mux c0(.instr(i_insn), .rs(i_r1data), .rt(i_r2data), .Out(cmp));
      logic_mux l0(.instr(i_insn), .rs(i_r1data), .rt(i_r2data), .Out(logic));
      shft_mux s0(.instr(i_insn), .rs(i_r1data), .rt(i_r2data), .Out(shift));
      hiconst_calc h0(.instr(i_insn), .rd(i_r1data), .Out(hiconst));
      cla_mux c1(.instr(i_insn), .rs(i_r1data), .rt(i_r2data), .pc(i_pc), .Out(cla));

      alu_final a1(.instr(i_insn), .branch(cla), .out_arith_mux(arith), .out_cmp_mux(cmp),
                  .jsr_mux(jsr), .logic_mux(logic), .ldr_cla_mux(cla), .str_cla_mux(cla), .r1_rti(rti), .const(const),
                  .shft_mux(shift), .jmp_mux(jmp), .hi_const(hiconst), .out_trap(trap), .Out(o_result));

endmodule



module alu_final (input wire [15:0] instr, input wire [15:0] branch, input wire [15:0] out_arith_mux,
        input wire [15:0] out_cmp_mux, input wire [15:0] jsr_mux, input wire [15:0] logic_mux, input wire [15:0] ldr_cla_mux, 
        input wire [15:0] str_cla_mux, input wire [15:0] r1_rti, input wire [15:0] const, input wire [15:0] shft_mux, 
        input wire [15:0] jmp_mux, input wire [15:0] hi_const, input wire [15:0] out_trap, output wire [15:0] Out);

      assign Out = (instr[15:12] == 4'd0) ? branch :
                  (instr[15:12] == 4'd1) ? out_arith_mux :
                  (instr[15:12] == 4'd2) ? out_cmp_mux :
                  (instr[15:12] == 4'd4) ? jsr_mux :
                  (instr[15:12] == 4'd5) ? logic_mux :
                  (instr[15:12] == 4'd6) ? ldr_cla_mux :
                  (instr[15:12] == 4'd7) ? str_cla_mux :
                  (instr[15:12] == 4'd8) ? r1_rti :
                  (instr[15:12] == 4'd9) ? const :
                  (instr[15:12] == 4'd10) ? shft_mux :
                  (instr[15:12] == 4'd12) ? jmp_mux :
                  (instr[15:12] == 4'd13) ? hi_const :
                  (instr[15:12] == 4'd15) ? out_trap :
                  16'd0;
endmodule



module arith_mux (input wire [15:0] instr, input wire [15:0] rs, input wire [15:0] rt, input wire [15:0] cla,
                  output wire [15:0] Out);
      wire [15:0] mul_calc = rs * rt;
      wire [15:0] div_lc4;
      lc4_divider d0(.i_divisor(rt), .i_dividend(rs), .o_remainder(), .o_quotient(div_lc4));

      assign Out = (instr[5:3] == 3'd0) ? cla : //add
                  (instr[5:3] == 3'd1) ? mul_calc :
                  (instr[5:3] == 3'd2) ? cla : //sub
                  (instr[5:3] == 3'd3) ? div_lc4 :
                  cla; //add_imm
endmodule



module jsr_mux (input wire [15:0] pc, input wire [15:0] rs, input wire [15:0] instr, output wire [15:0] Out);

      wire[15:0] jsr_calc = (pc & 16'h8000) | ((instr[10] ? {{5{1'd1}}, instr[10:0]}: {{5{1'd0}}, instr[10:0]}) << 4); //sign ext
      assign Out = instr[11] ? jsr_calc : rs;

endmodule



module cmp_mux (input wire [15:0] instr, input wire [15:0] rs, input wire [15:0] rt, output wire [15:0] Out);
      wire [15:0] rt_val; 
      wire [15:0] rs_val;

      //rs val is doing what cmp_mux_a does
      assign rs_val = (instr[8:7] == 2'd0) ? rs :
                  (instr[8:7] == 2'd1) ? $unsigned(rs) :
                  (instr[8:7] == 2'd2) ? rs :
                  $unsigned(rs);

      //rt val is doing what cmp_mux_b does
      assign rt_val = (instr[8:7] == 2'd0) ? rt :
                  (instr[8:7] == 2'd1) ? $unsigned(rt) :
                  (instr[8:7] == 2'd2) ? (instr[6] ? {{9{1'd1}}, instr[6:0]} : {{9{1'd0}}, instr[6:0]}) :
                  {{9 {1'd0}}, instr[6:0]};

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
      wire and_imm = rs & (instr[4] ? {{11{1'd1}}, instr[4:0]}: {{11{1'd0}}, instr[4:0]});

      assign Out = (instr[5:3] == 3'd0) ? and_calc :
                  (instr[5:3] == 3'd1) ? not_calc :
                  (instr[5:3] == 3'd2) ? or_calc :
                  (instr[5:3] == 3'd3) ? xor_calc :
                  and_imm;

endmodule



module shft_mux (input wire [15:0] instr, input wire [15:0] rs, input wire [15:0] rt, output wire [15:0] Out);

      wire uimm4 = {{12{1'b0}}, instr[3:0]};
      wire sll_calc = rs << uimm4;
      wire sra_calc = rs >>> uimm4;
      wire srl_calc = rs >> uimm4;

      wire [15:0] mod_calc; 
      lc4_divider div(.i_divisor(rt), .i_dividend(rs), .o_remainder(mod_calc), .o_quotient());

      assign Out = (instr[5:4] == 2'd0) ? sll_calc :
                  (instr[5:4] == 2'd1) ? sra_calc :
                  (instr[5:4] == 2'd2) ? srl_calc :
                  (instr[5:4] == 2'd3) ? mod_calc :
                  16'd0;

endmodule


module jmp_mux (input wire [15:0] instr, input wire [15:0] cla, input wire [15:0] rs, output wire [15:0] Out);
      assign Out = instr[11] ? cla : rs;
endmodule


module hiconst_calc (input wire [15:0] instr, input wire [15:0] rd, output wire [15:0] Out);
      wire uimm8 = {{8{1'b0}}, instr[7:0]};
      assign Out = (rd & 16'hFF00) | ($unsigned(uimm8) << 8);

endmodule



module cla_mux (input wire [15:0] instr, input wire [15:0] rs, input wire [15:0] rt,
                input wire [15:0] pc, output wire [15:0] Out);
      
      wire imm9 = instr[8] ? {{7{1'd1}}, instr[8:0]} : {{7{1'd0}}, instr[8:0]};
      wire imm5 = instr[4] ? {{11{1'd1}}, instr[4:0]}: {{11{1'd0}}, instr[4:0]};
      wire imm6 = instr[5] ? {{10{1'd1}}, instr[5:0]}: {{10{1'd0}}, instr[5:0]};
      wire imm11 = instr[10] ? {{5{1'd1}}, instr[10:0]}: {{5{1'd0}}, instr[10:0]};

      wire cla_carry = (instr[15:12] == 4'b0) ? 16'b1 : //branch or nop
                  (instr[15:12] == 4'd12) ? 16'b1 : //jmp
                  (instr[15:12] == 4'd1 && instr[5:3] == 3'd2) ? 16'b1 : //sub
                  16'b0;
                        
      wire cla_input_a = (instr[15:12] == 4'b0) ? pc : //branch
                        (instr[15:12] == 4'd1) ? rs : //add
                        (instr[15:12] == 4'd6) ? rs : //ldr
                        (instr[15:12] == 4'd7) ? rs : //str
                        (instr[15:12] == 4'd12) ? pc : //jmp
                        16'b0;

      wire cla_input_b = (instr[15:12] == 4'b0) ? imm9 : //branch
                        (instr[15:12] == 4'd1 && instr[5:3] == 3'd0) ? rt : //add
                        (instr[15:12] == 4'd1 && instr[5:3] == 3'd2) ? ~rt : //sub
                        (instr[15:12] == 4'd1 && instr[5] == 1'd1) ? imm5 : //add imm
                        (instr[15:12] == 4'd6) ? imm6 : //ldr
                        (instr[15:12] == 4'd7) ? imm6 : //str
                        (instr[15:11] == 5'b11001) ? imm11 : //jmp
                        16'b0;

      cla16 c0(.a(cla_input_a), .b(cla_input_b), .cin(cla_carry), .sum(Out));

endmodule

