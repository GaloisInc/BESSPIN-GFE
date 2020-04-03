`ifndef TIMESCALE
    `define TIMESCALE 1ns/1ps
`endif

`timescale `TIMESCALE

module xtime
    ( input logic [7:0] x,
      output logic [7:0] out
    );
    assign out = {x[6:0], 1'h0} ^ (x[7] ? 8'h1b : 8'h0);
endmodule

module mult
    ( input logic [3:0] a,
      input logic [7:0] b,
      output logic [7:0] out
    );
    var logic a3;
    var logic a2;
    var logic a1;
    var logic a0;
    var logic [7:0] b1;
    var logic [7:0] b2;
    var logic [7:0] b3;
    assign a3 = a[3];
    assign a2 = a[2];
    assign a1 = a[1];
    assign a0 = a[0];
    xtime xtime_inst1 (b, b1);
    xtime xtime_inst2 (b1, b2);
    xtime xtime_inst3 (b2, b3);
    assign out = (a0 ? b : 8'h0) ^ (a1 ? b1 : 8'h0) ^ (a2 ? b2 : 8'h0) ^ (a3 ? b3 : 8'h0);
endmodule

module dot
    ( input logic [3:0][3:0] row,
      input logic [3:0][7:0] col,
      output logic [7:0] out
    );
    var logic [3:0][7:0] m;
    var logic [7:0] m0;
    var logic [7:0] m1;
    var logic [7:0] m2;
    var logic [7:0] m3;
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        var logic [3:0] r;
        assign r = row[3 - gv0];
        var logic [7:0] c;
        assign c = col[3 - gv0];
        mult mult_inst1 (r, c, m[3 - gv0]);
      end
    assign m0 = m[3];
    assign m1 = m[2];
    assign m2 = m[1];
    assign m3 = m[0];
    assign out = m0 ^ m1 ^ m2 ^ m3;
endmodule

module Sbox
    ( input logic [7:0] b,
      output logic [7:0] out
    );
    var logic [255:0][7:0] box;
    assign box[255] = 8'h63;
    assign box[254] = 8'h7c;
    assign box[253] = 8'h77;
    assign box[252] = 8'h7b;
    assign box[251] = 8'hf2;
    assign box[250] = 8'h6b;
    assign box[249] = 8'h6f;
    assign box[248] = 8'hc5;
    assign box[247] = 8'h30;
    assign box[246] = 8'h1;
    assign box[245] = 8'h67;
    assign box[244] = 8'h2b;
    assign box[243] = 8'hfe;
    assign box[242] = 8'hd7;
    assign box[241] = 8'hab;
    assign box[240] = 8'h76;
    assign box[239] = 8'hca;
    assign box[238] = 8'h82;
    assign box[237] = 8'hc9;
    assign box[236] = 8'h7d;
    assign box[235] = 8'hfa;
    assign box[234] = 8'h59;
    assign box[233] = 8'h47;
    assign box[232] = 8'hf0;
    assign box[231] = 8'had;
    assign box[230] = 8'hd4;
    assign box[229] = 8'ha2;
    assign box[228] = 8'haf;
    assign box[227] = 8'h9c;
    assign box[226] = 8'ha4;
    assign box[225] = 8'h72;
    assign box[224] = 8'hc0;
    assign box[223] = 8'hb7;
    assign box[222] = 8'hfd;
    assign box[221] = 8'h93;
    assign box[220] = 8'h26;
    assign box[219] = 8'h36;
    assign box[218] = 8'h3f;
    assign box[217] = 8'hf7;
    assign box[216] = 8'hcc;
    assign box[215] = 8'h34;
    assign box[214] = 8'ha5;
    assign box[213] = 8'he5;
    assign box[212] = 8'hf1;
    assign box[211] = 8'h71;
    assign box[210] = 8'hd8;
    assign box[209] = 8'h31;
    assign box[208] = 8'h15;
    assign box[207] = 8'h4;
    assign box[206] = 8'hc7;
    assign box[205] = 8'h23;
    assign box[204] = 8'hc3;
    assign box[203] = 8'h18;
    assign box[202] = 8'h96;
    assign box[201] = 8'h5;
    assign box[200] = 8'h9a;
    assign box[199] = 8'h7;
    assign box[198] = 8'h12;
    assign box[197] = 8'h80;
    assign box[196] = 8'he2;
    assign box[195] = 8'heb;
    assign box[194] = 8'h27;
    assign box[193] = 8'hb2;
    assign box[192] = 8'h75;
    assign box[191] = 8'h9;
    assign box[190] = 8'h83;
    assign box[189] = 8'h2c;
    assign box[188] = 8'h1a;
    assign box[187] = 8'h1b;
    assign box[186] = 8'h6e;
    assign box[185] = 8'h5a;
    assign box[184] = 8'ha0;
    assign box[183] = 8'h52;
    assign box[182] = 8'h3b;
    assign box[181] = 8'hd6;
    assign box[180] = 8'hb3;
    assign box[179] = 8'h29;
    assign box[178] = 8'he3;
    assign box[177] = 8'h2f;
    assign box[176] = 8'h84;
    assign box[175] = 8'h53;
    assign box[174] = 8'hd1;
    assign box[173] = 8'h0;
    assign box[172] = 8'hed;
    assign box[171] = 8'h20;
    assign box[170] = 8'hfc;
    assign box[169] = 8'hb1;
    assign box[168] = 8'h5b;
    assign box[167] = 8'h6a;
    assign box[166] = 8'hcb;
    assign box[165] = 8'hbe;
    assign box[164] = 8'h39;
    assign box[163] = 8'h4a;
    assign box[162] = 8'h4c;
    assign box[161] = 8'h58;
    assign box[160] = 8'hcf;
    assign box[159] = 8'hd0;
    assign box[158] = 8'hef;
    assign box[157] = 8'haa;
    assign box[156] = 8'hfb;
    assign box[155] = 8'h43;
    assign box[154] = 8'h4d;
    assign box[153] = 8'h33;
    assign box[152] = 8'h85;
    assign box[151] = 8'h45;
    assign box[150] = 8'hf9;
    assign box[149] = 8'h2;
    assign box[148] = 8'h7f;
    assign box[147] = 8'h50;
    assign box[146] = 8'h3c;
    assign box[145] = 8'h9f;
    assign box[144] = 8'ha8;
    assign box[143] = 8'h51;
    assign box[142] = 8'ha3;
    assign box[141] = 8'h40;
    assign box[140] = 8'h8f;
    assign box[139] = 8'h92;
    assign box[138] = 8'h9d;
    assign box[137] = 8'h38;
    assign box[136] = 8'hf5;
    assign box[135] = 8'hbc;
    assign box[134] = 8'hb6;
    assign box[133] = 8'hda;
    assign box[132] = 8'h21;
    assign box[131] = 8'h10;
    assign box[130] = 8'hff;
    assign box[129] = 8'hf3;
    assign box[128] = 8'hd2;
    assign box[127] = 8'hcd;
    assign box[126] = 8'hc;
    assign box[125] = 8'h13;
    assign box[124] = 8'hec;
    assign box[123] = 8'h5f;
    assign box[122] = 8'h97;
    assign box[121] = 8'h44;
    assign box[120] = 8'h17;
    assign box[119] = 8'hc4;
    assign box[118] = 8'ha7;
    assign box[117] = 8'h7e;
    assign box[116] = 8'h3d;
    assign box[115] = 8'h64;
    assign box[114] = 8'h5d;
    assign box[113] = 8'h19;
    assign box[112] = 8'h73;
    assign box[111] = 8'h60;
    assign box[110] = 8'h81;
    assign box[109] = 8'h4f;
    assign box[108] = 8'hdc;
    assign box[107] = 8'h22;
    assign box[106] = 8'h2a;
    assign box[105] = 8'h90;
    assign box[104] = 8'h88;
    assign box[103] = 8'h46;
    assign box[102] = 8'hee;
    assign box[101] = 8'hb8;
    assign box[100] = 8'h14;
    assign box[99] = 8'hde;
    assign box[98] = 8'h5e;
    assign box[97] = 8'hb;
    assign box[96] = 8'hdb;
    assign box[95] = 8'he0;
    assign box[94] = 8'h32;
    assign box[93] = 8'h3a;
    assign box[92] = 8'ha;
    assign box[91] = 8'h49;
    assign box[90] = 8'h6;
    assign box[89] = 8'h24;
    assign box[88] = 8'h5c;
    assign box[87] = 8'hc2;
    assign box[86] = 8'hd3;
    assign box[85] = 8'hac;
    assign box[84] = 8'h62;
    assign box[83] = 8'h91;
    assign box[82] = 8'h95;
    assign box[81] = 8'he4;
    assign box[80] = 8'h79;
    assign box[79] = 8'he7;
    assign box[78] = 8'hc8;
    assign box[77] = 8'h37;
    assign box[76] = 8'h6d;
    assign box[75] = 8'h8d;
    assign box[74] = 8'hd5;
    assign box[73] = 8'h4e;
    assign box[72] = 8'ha9;
    assign box[71] = 8'h6c;
    assign box[70] = 8'h56;
    assign box[69] = 8'hf4;
    assign box[68] = 8'hea;
    assign box[67] = 8'h65;
    assign box[66] = 8'h7a;
    assign box[65] = 8'hae;
    assign box[64] = 8'h8;
    assign box[63] = 8'hba;
    assign box[62] = 8'h78;
    assign box[61] = 8'h25;
    assign box[60] = 8'h2e;
    assign box[59] = 8'h1c;
    assign box[58] = 8'ha6;
    assign box[57] = 8'hb4;
    assign box[56] = 8'hc6;
    assign box[55] = 8'he8;
    assign box[54] = 8'hdd;
    assign box[53] = 8'h74;
    assign box[52] = 8'h1f;
    assign box[51] = 8'h4b;
    assign box[50] = 8'hbd;
    assign box[49] = 8'h8b;
    assign box[48] = 8'h8a;
    assign box[47] = 8'h70;
    assign box[46] = 8'h3e;
    assign box[45] = 8'hb5;
    assign box[44] = 8'h66;
    assign box[43] = 8'h48;
    assign box[42] = 8'h3;
    assign box[41] = 8'hf6;
    assign box[40] = 8'he;
    assign box[39] = 8'h61;
    assign box[38] = 8'h35;
    assign box[37] = 8'h57;
    assign box[36] = 8'hb9;
    assign box[35] = 8'h86;
    assign box[34] = 8'hc1;
    assign box[33] = 8'h1d;
    assign box[32] = 8'h9e;
    assign box[31] = 8'he1;
    assign box[30] = 8'hf8;
    assign box[29] = 8'h98;
    assign box[28] = 8'h11;
    assign box[27] = 8'h69;
    assign box[26] = 8'hd9;
    assign box[25] = 8'h8e;
    assign box[24] = 8'h94;
    assign box[23] = 8'h9b;
    assign box[22] = 8'h1e;
    assign box[21] = 8'h87;
    assign box[20] = 8'he9;
    assign box[19] = 8'hce;
    assign box[18] = 8'h55;
    assign box[17] = 8'h28;
    assign box[16] = 8'hdf;
    assign box[15] = 8'h8c;
    assign box[14] = 8'ha1;
    assign box[13] = 8'h89;
    assign box[12] = 8'hd;
    assign box[11] = 8'hbf;
    assign box[10] = 8'he6;
    assign box[9] = 8'h42;
    assign box[8] = 8'h68;
    assign box[7] = 8'h41;
    assign box[6] = 8'h99;
    assign box[5] = 8'h2d;
    assign box[4] = 8'hf;
    assign box[3] = 8'hb0;
    assign box[2] = 8'h54;
    assign box[1] = 8'hbb;
    assign box[0] = 8'h16;
    assign out = box[255 - b];
endmodule

module SubBytes
    ( input logic [3:0][3:0][7:0] state,
      output logic [3:0][3:0][7:0] out
    );
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        var logic [3:0][7:0] col;
        assign col = state[3 - gv0];
        for (genvar gv1 = 0; gv1 < 4; gv1++)
          begin
            var logic [7:0] b;
            assign b = col[3 - gv1];
            Sbox Sbox_inst1 (b, out[3 - gv0][3 - gv1]);
          end
      end
endmodule

module ShiftRows
    ( input logic [3:0][3:0][7:0] state,
      output logic [3:0][3:0][7:0] out
    );
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        localparam logic [1:0] c = gv0;
        for (genvar gv1 = 0; gv1 < 4; gv1++)
          begin
            localparam logic [1:0] r = gv1;
            var logic [1:0] c1;
            assign c1 = c + r;
            assign out[3 - gv0][3 - gv1] = state[3 - c1][3 - r];
          end
      end
endmodule

module MixColumns
    ( input logic [3:0][3:0][7:0] state,
      output logic [3:0][3:0][7:0] out
    );
    var logic [3:0][3:0][3:0] m;
    assign m[3][3] = 4'h2;
    assign m[3][2] = 4'h3;
    assign m[3][1] = 4'h1;
    assign m[3][0] = 4'h1;
    assign m[2][3] = 4'h1;
    assign m[2][2] = 4'h2;
    assign m[2][1] = 4'h3;
    assign m[2][0] = 4'h1;
    assign m[1][3] = 4'h1;
    assign m[1][2] = 4'h1;
    assign m[1][1] = 4'h2;
    assign m[1][0] = 4'h3;
    assign m[0][3] = 4'h3;
    assign m[0][2] = 4'h1;
    assign m[0][1] = 4'h1;
    assign m[0][0] = 4'h2;
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        var logic [3:0][7:0] col;
        assign col = state[3 - gv0];
        for (genvar gv1 = 0; gv1 < 4; gv1++)
          begin
            var logic [3:0][3:0] row;
            assign row = m[3 - gv1];
            dot dot_inst1 (row, col, out[3 - gv0][3 - gv1]);
          end
      end
endmodule

module AddRoundKey
    ( input logic [3:0][3:0][7:0] state,
      input logic [3:0][3:0][7:0] rk,
      output logic [3:0][3:0][7:0] out
    );
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        localparam logic [1:0] c = gv0;
        for (genvar gv1 = 0; gv1 < 4; gv1++)
          begin
            localparam logic [1:0] r = gv1;
            assign out[3 - gv0][3 - gv1] = state[3 - c][3 - r] ^ rk[3 - c][3 - r];
          end
      end
endmodule

module Round
    ( input logic [3:0][3:0][7:0] s,
      input logic [3:0][3:0][7:0] rk,
      output logic [3:0][3:0][7:0] out
    );
    var logic [3:0][3:0][7:0] s_box;
    var logic [3:0][3:0][7:0] s_row;
    var logic [3:0][3:0][7:0] m_col;
    SubBytes SubBytes_inst1 (s, s_box);
    ShiftRows ShiftRows_inst1 (s_box, s_row);
    MixColumns MixColumns_inst1 (s_row, m_col);
    AddRoundKey AddRoundKey_inst1 (m_col, rk, out);
endmodule

module flopMux #(
    parameter DATA_WIDTH = 128
) (
    input logic clk,    // Clock
    input logic bypass, // True -> bypass the flop
    input logic [DATA_WIDTH-1:0] d,
    output logic [DATA_WIDTH-1:0] q,
    // Scan signals
    input logic sen, si, 
    output logic so
);
  logic [DATA_WIDTH-1:0] flop_out;
  logic [DATA_WIDTH-1:0] scan_input;

  assign scan_input[0] = si;
  generate
    for (genvar i = 1; i < DATA_WIDTH; i++) begin
      assign scan_input[i] = flop_out[i-1];
    end
  endgenerate  

  generate
  for (genvar i = 0; i < DATA_WIDTH; i++) begin : flopMuxGen
    logic flop_in;
    assign flop_in = sen ? scan_input[i] : d[i];
    always_ff @(posedge clk) begin : proc_q
        flop_out[i] <= flop_in;
    end 
  end      
  endgenerate

  assign q = flop_out;
  assign so = flop_out[DATA_WIDTH-1];
endmodule

module Cipher
    #(parameter int Nr)
    ( input logic [Nr:0][3:0][3:0][7:0] k_sch,
      input logic [3:0][3:0][7:0] in,
      output logic [3:0][3:0][7:0] out,
      input logic [Nr - 1:0] clk,
      input logic [Nr - 1:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    var logic [3:0][3:0][7:0] rk0;
    var logic [Nr - 2:0][3:0][3:0][7:0] rks;
    var logic [3:0][3:0][7:0] rkf;
    var logic [3:0][3:0][7:0] s0;
    var logic [Nr - 2:0][3:0][3:0][7:0] rounds;
    var logic [Nr - 1:0][3:0][3:0][7:0] states;
    var logic [Nr - 2:0][3:0][3:0][7:0] prev;
    var logic [3:0][3:0][7:0] sf;
    var logic [3:0][3:0][7:0] s_box;
    var logic [3:0][3:0][7:0] s_row;
    var logic [3:0][3:0][7:0] in_flopped;

    // scan signals
    var logic [Nr - 1:0] so_flops;

    assign rk0 = k_sch[Nr];
    assign rks = k_sch[Nr - 1:Nr - Nr + 1];
    assign rkf = k_sch[Nr - Nr];
    flopMux #(.DATA_WIDTH(128)) round_flop(clk[0], flop_bypass[0], in, in_flopped, sen, si, so_flops[0]);
    AddRoundKey AddRoundKey_inst1 (in_flopped, rk0, s0);
    for (genvar gv0 = 0; gv0 < Nr - 1; gv0++)
      begin
        var logic [3:0][3:0][7:0] round_group_out;
        var logic [3:0][3:0][7:0] s;
        assign s = prev[Nr - gv0 - 2];
        var logic [3:0][3:0][7:0] rk;
        assign rk = rks[Nr - gv0 - 2];
        Round Round_inst1 (s, rk, round_group_out);
        flopMux #(.DATA_WIDTH(128)) round_flop(
            clk[gv0 + 1], flop_bypass[gv0 + 1], round_group_out, rounds[Nr - gv0 - 2], sen, so_flops[gv0], so_flops[gv0 + 1]);
      end
    assign states = {{s0}, rounds};
    assign prev = states[Nr - 1:Nr - Nr + 1];
    assign sf = states[Nr - Nr];
    SubBytes SubBytes_inst1 (sf, s_box);
    ShiftRows ShiftRows_inst1 (s_box, s_row);
    AddRoundKey AddRoundKey_inst2 (s_row, rkf, out);
    assign so = so_flops[Nr - 1];
endmodule

module SubWord
    ( input logic [3:0][7:0] bs,
      output logic [3:0][7:0] out
    );
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        var logic [7:0] b;
        assign b = bs[3 - gv0];
        Sbox Sbox_inst1 (b, out[3 - gv0]);
      end
endmodule

module RotWord
    ( input logic [3:0][7:0] in,
      output logic [3:0][7:0] out
    );
    var logic [7:0] a0;
    var logic [7:0] a1;
    var logic [7:0] a2;
    var logic [7:0] a3;
    assign a0 = in[3];
    assign a1 = in[2];
    assign a2 = in[1];
    assign a3 = in[0];
    assign out[3] = a1;
    assign out[2] = a2;
    assign out[1] = a3;
    assign out[0] = a0;
endmodule

module KeyExpansion
    #(parameter int Nk, parameter int Nr)
    ( input logic [Nk - 1:0][3:0][7:0] key,
      output logic [Nr:0][3:0][3:0][7:0] out
    );
    var logic [254:0][7:0] Rcon;
    var logic [4 * (Nr + 1) - 1:0][3:0][7:0] w;
    assign Rcon[254] = 8'h8d;
    assign Rcon[253] = 8'h1;
    assign Rcon[252] = 8'h2;
    assign Rcon[251] = 8'h4;
    assign Rcon[250] = 8'h8;
    assign Rcon[249] = 8'h10;
    assign Rcon[248] = 8'h20;
    assign Rcon[247] = 8'h40;
    assign Rcon[246] = 8'h80;
    assign Rcon[245] = 8'h1b;
    assign Rcon[244] = 8'h36;
    assign Rcon[243] = 8'h6c;
    assign Rcon[242] = 8'hd8;
    assign Rcon[241] = 8'hab;
    assign Rcon[240] = 8'h4d;
    assign Rcon[239] = 8'h9a;
    assign Rcon[238] = 8'h2f;
    assign Rcon[237] = 8'h5e;
    assign Rcon[236] = 8'hbc;
    assign Rcon[235] = 8'h63;
    assign Rcon[234] = 8'hc6;
    assign Rcon[233] = 8'h97;
    assign Rcon[232] = 8'h35;
    assign Rcon[231] = 8'h6a;
    assign Rcon[230] = 8'hd4;
    assign Rcon[229] = 8'hb3;
    assign Rcon[228] = 8'h7d;
    assign Rcon[227] = 8'hfa;
    assign Rcon[226] = 8'hef;
    assign Rcon[225] = 8'hc5;
    assign Rcon[224] = 8'h91;
    assign Rcon[223] = 8'h39;
    assign Rcon[222] = 8'h72;
    assign Rcon[221] = 8'he4;
    assign Rcon[220] = 8'hd3;
    assign Rcon[219] = 8'hbd;
    assign Rcon[218] = 8'h61;
    assign Rcon[217] = 8'hc2;
    assign Rcon[216] = 8'h9f;
    assign Rcon[215] = 8'h25;
    assign Rcon[214] = 8'h4a;
    assign Rcon[213] = 8'h94;
    assign Rcon[212] = 8'h33;
    assign Rcon[211] = 8'h66;
    assign Rcon[210] = 8'hcc;
    assign Rcon[209] = 8'h83;
    assign Rcon[208] = 8'h1d;
    assign Rcon[207] = 8'h3a;
    assign Rcon[206] = 8'h74;
    assign Rcon[205] = 8'he8;
    assign Rcon[204] = 8'hcb;
    assign Rcon[203] = 8'h8d;
    assign Rcon[202] = 8'h1;
    assign Rcon[201] = 8'h2;
    assign Rcon[200] = 8'h4;
    assign Rcon[199] = 8'h8;
    assign Rcon[198] = 8'h10;
    assign Rcon[197] = 8'h20;
    assign Rcon[196] = 8'h40;
    assign Rcon[195] = 8'h80;
    assign Rcon[194] = 8'h1b;
    assign Rcon[193] = 8'h36;
    assign Rcon[192] = 8'h6c;
    assign Rcon[191] = 8'hd8;
    assign Rcon[190] = 8'hab;
    assign Rcon[189] = 8'h4d;
    assign Rcon[188] = 8'h9a;
    assign Rcon[187] = 8'h2f;
    assign Rcon[186] = 8'h5e;
    assign Rcon[185] = 8'hbc;
    assign Rcon[184] = 8'h63;
    assign Rcon[183] = 8'hc6;
    assign Rcon[182] = 8'h97;
    assign Rcon[181] = 8'h35;
    assign Rcon[180] = 8'h6a;
    assign Rcon[179] = 8'hd4;
    assign Rcon[178] = 8'hb3;
    assign Rcon[177] = 8'h7d;
    assign Rcon[176] = 8'hfa;
    assign Rcon[175] = 8'hef;
    assign Rcon[174] = 8'hc5;
    assign Rcon[173] = 8'h91;
    assign Rcon[172] = 8'h39;
    assign Rcon[171] = 8'h72;
    assign Rcon[170] = 8'he4;
    assign Rcon[169] = 8'hd3;
    assign Rcon[168] = 8'hbd;
    assign Rcon[167] = 8'h61;
    assign Rcon[166] = 8'hc2;
    assign Rcon[165] = 8'h9f;
    assign Rcon[164] = 8'h25;
    assign Rcon[163] = 8'h4a;
    assign Rcon[162] = 8'h94;
    assign Rcon[161] = 8'h33;
    assign Rcon[160] = 8'h66;
    assign Rcon[159] = 8'hcc;
    assign Rcon[158] = 8'h83;
    assign Rcon[157] = 8'h1d;
    assign Rcon[156] = 8'h3a;
    assign Rcon[155] = 8'h74;
    assign Rcon[154] = 8'he8;
    assign Rcon[153] = 8'hcb;
    assign Rcon[152] = 8'h8d;
    assign Rcon[151] = 8'h1;
    assign Rcon[150] = 8'h2;
    assign Rcon[149] = 8'h4;
    assign Rcon[148] = 8'h8;
    assign Rcon[147] = 8'h10;
    assign Rcon[146] = 8'h20;
    assign Rcon[145] = 8'h40;
    assign Rcon[144] = 8'h80;
    assign Rcon[143] = 8'h1b;
    assign Rcon[142] = 8'h36;
    assign Rcon[141] = 8'h6c;
    assign Rcon[140] = 8'hd8;
    assign Rcon[139] = 8'hab;
    assign Rcon[138] = 8'h4d;
    assign Rcon[137] = 8'h9a;
    assign Rcon[136] = 8'h2f;
    assign Rcon[135] = 8'h5e;
    assign Rcon[134] = 8'hbc;
    assign Rcon[133] = 8'h63;
    assign Rcon[132] = 8'hc6;
    assign Rcon[131] = 8'h97;
    assign Rcon[130] = 8'h35;
    assign Rcon[129] = 8'h6a;
    assign Rcon[128] = 8'hd4;
    assign Rcon[127] = 8'hb3;
    assign Rcon[126] = 8'h7d;
    assign Rcon[125] = 8'hfa;
    assign Rcon[124] = 8'hef;
    assign Rcon[123] = 8'hc5;
    assign Rcon[122] = 8'h91;
    assign Rcon[121] = 8'h39;
    assign Rcon[120] = 8'h72;
    assign Rcon[119] = 8'he4;
    assign Rcon[118] = 8'hd3;
    assign Rcon[117] = 8'hbd;
    assign Rcon[116] = 8'h61;
    assign Rcon[115] = 8'hc2;
    assign Rcon[114] = 8'h9f;
    assign Rcon[113] = 8'h25;
    assign Rcon[112] = 8'h4a;
    assign Rcon[111] = 8'h94;
    assign Rcon[110] = 8'h33;
    assign Rcon[109] = 8'h66;
    assign Rcon[108] = 8'hcc;
    assign Rcon[107] = 8'h83;
    assign Rcon[106] = 8'h1d;
    assign Rcon[105] = 8'h3a;
    assign Rcon[104] = 8'h74;
    assign Rcon[103] = 8'he8;
    assign Rcon[102] = 8'hcb;
    assign Rcon[101] = 8'h8d;
    assign Rcon[100] = 8'h1;
    assign Rcon[99] = 8'h2;
    assign Rcon[98] = 8'h4;
    assign Rcon[97] = 8'h8;
    assign Rcon[96] = 8'h10;
    assign Rcon[95] = 8'h20;
    assign Rcon[94] = 8'h40;
    assign Rcon[93] = 8'h80;
    assign Rcon[92] = 8'h1b;
    assign Rcon[91] = 8'h36;
    assign Rcon[90] = 8'h6c;
    assign Rcon[89] = 8'hd8;
    assign Rcon[88] = 8'hab;
    assign Rcon[87] = 8'h4d;
    assign Rcon[86] = 8'h9a;
    assign Rcon[85] = 8'h2f;
    assign Rcon[84] = 8'h5e;
    assign Rcon[83] = 8'hbc;
    assign Rcon[82] = 8'h63;
    assign Rcon[81] = 8'hc6;
    assign Rcon[80] = 8'h97;
    assign Rcon[79] = 8'h35;
    assign Rcon[78] = 8'h6a;
    assign Rcon[77] = 8'hd4;
    assign Rcon[76] = 8'hb3;
    assign Rcon[75] = 8'h7d;
    assign Rcon[74] = 8'hfa;
    assign Rcon[73] = 8'hef;
    assign Rcon[72] = 8'hc5;
    assign Rcon[71] = 8'h91;
    assign Rcon[70] = 8'h39;
    assign Rcon[69] = 8'h72;
    assign Rcon[68] = 8'he4;
    assign Rcon[67] = 8'hd3;
    assign Rcon[66] = 8'hbd;
    assign Rcon[65] = 8'h61;
    assign Rcon[64] = 8'hc2;
    assign Rcon[63] = 8'h9f;
    assign Rcon[62] = 8'h25;
    assign Rcon[61] = 8'h4a;
    assign Rcon[60] = 8'h94;
    assign Rcon[59] = 8'h33;
    assign Rcon[58] = 8'h66;
    assign Rcon[57] = 8'hcc;
    assign Rcon[56] = 8'h83;
    assign Rcon[55] = 8'h1d;
    assign Rcon[54] = 8'h3a;
    assign Rcon[53] = 8'h74;
    assign Rcon[52] = 8'he8;
    assign Rcon[51] = 8'hcb;
    assign Rcon[50] = 8'h8d;
    assign Rcon[49] = 8'h1;
    assign Rcon[48] = 8'h2;
    assign Rcon[47] = 8'h4;
    assign Rcon[46] = 8'h8;
    assign Rcon[45] = 8'h10;
    assign Rcon[44] = 8'h20;
    assign Rcon[43] = 8'h40;
    assign Rcon[42] = 8'h80;
    assign Rcon[41] = 8'h1b;
    assign Rcon[40] = 8'h36;
    assign Rcon[39] = 8'h6c;
    assign Rcon[38] = 8'hd8;
    assign Rcon[37] = 8'hab;
    assign Rcon[36] = 8'h4d;
    assign Rcon[35] = 8'h9a;
    assign Rcon[34] = 8'h2f;
    assign Rcon[33] = 8'h5e;
    assign Rcon[32] = 8'hbc;
    assign Rcon[31] = 8'h63;
    assign Rcon[30] = 8'hc6;
    assign Rcon[29] = 8'h97;
    assign Rcon[28] = 8'h35;
    assign Rcon[27] = 8'h6a;
    assign Rcon[26] = 8'hd4;
    assign Rcon[25] = 8'hb3;
    assign Rcon[24] = 8'h7d;
    assign Rcon[23] = 8'hfa;
    assign Rcon[22] = 8'hef;
    assign Rcon[21] = 8'hc5;
    assign Rcon[20] = 8'h91;
    assign Rcon[19] = 8'h39;
    assign Rcon[18] = 8'h72;
    assign Rcon[17] = 8'he4;
    assign Rcon[16] = 8'hd3;
    assign Rcon[15] = 8'hbd;
    assign Rcon[14] = 8'h61;
    assign Rcon[13] = 8'hc2;
    assign Rcon[12] = 8'h9f;
    assign Rcon[11] = 8'h25;
    assign Rcon[10] = 8'h4a;
    assign Rcon[9] = 8'h94;
    assign Rcon[8] = 8'h33;
    assign Rcon[7] = 8'h66;
    assign Rcon[6] = 8'hcc;
    assign Rcon[5] = 8'h83;
    assign Rcon[4] = 8'h1d;
    assign Rcon[3] = 8'h3a;
    assign Rcon[2] = 8'h74;
    assign Rcon[1] = 8'he8;
    assign Rcon[0] = 8'hcb;
    for (genvar gv0 = 0; gv0 < 4 * (Nr + 1); gv0++)
      begin
        localparam logic [7:0] i = gv0;
        if (i < Nk)
          begin
            assign w[4 * (Nr + 1) - gv0 - 1] = key[Nk - i - 1];
          end
        else
          begin
            if (i % Nk == 8'h0)
              begin
                var logic [3:0][7:0] r_w;
                var logic [3:0][7:0] s_w;
                RotWord RotWord_inst1 (w[4 * (Nr + 1) - i], r_w);
                SubWord SubWord_inst1 (r_w, s_w);
                assign w[4 * (Nr + 1) - gv0 - 1] = w[4 * (Nr + 1) - (i - Nk) - 1] ^ s_w ^ {Rcon[254 - i / Nk], 8'h0, 8'h0, 8'h0};
              end
            else
              begin
                if ((Nk > 8'h6) & (i % Nk == 8'h4))
                  begin
                    var logic [3:0][7:0] s_w;
                    SubWord SubWord_inst1 (w[4 * (Nr + 1) - i], s_w);
                    assign w[4 * (Nr + 1) - gv0 - 1] = w[4 * (Nr + 1) - (i - Nk) - 1] ^ s_w;
                  end
                else
                  begin
                    assign w[4 * (Nr + 1) - gv0 - 1] = w[4 * (Nr + 1) - (i - Nk) - 1] ^ w[4 * (Nr + 1) - i];
                  end
              end
          end
      end
    assign out = w;
endmodule

module InvShiftRows
    ( input logic [3:0][3:0][7:0] state,
      output logic [3:0][3:0][7:0] out
    );
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        localparam logic [1:0] c = gv0;
        for (genvar gv1 = 0; gv1 < 4; gv1++)
          begin
            localparam logic [1:0] r = gv1;
            var logic [1:0] c1;
            assign c1 = c - r;
            assign out[3 - gv0][3 - gv1] = state[3 - c1][3 - r];
          end
      end
endmodule

module InvSbox
    ( input logic [7:0] b,
      output logic [7:0] out
    );
    var logic [255:0][7:0] box;
    assign box[255] = 8'h52;
    assign box[254] = 8'h9;
    assign box[253] = 8'h6a;
    assign box[252] = 8'hd5;
    assign box[251] = 8'h30;
    assign box[250] = 8'h36;
    assign box[249] = 8'ha5;
    assign box[248] = 8'h38;
    assign box[247] = 8'hbf;
    assign box[246] = 8'h40;
    assign box[245] = 8'ha3;
    assign box[244] = 8'h9e;
    assign box[243] = 8'h81;
    assign box[242] = 8'hf3;
    assign box[241] = 8'hd7;
    assign box[240] = 8'hfb;
    assign box[239] = 8'h7c;
    assign box[238] = 8'he3;
    assign box[237] = 8'h39;
    assign box[236] = 8'h82;
    assign box[235] = 8'h9b;
    assign box[234] = 8'h2f;
    assign box[233] = 8'hff;
    assign box[232] = 8'h87;
    assign box[231] = 8'h34;
    assign box[230] = 8'h8e;
    assign box[229] = 8'h43;
    assign box[228] = 8'h44;
    assign box[227] = 8'hc4;
    assign box[226] = 8'hde;
    assign box[225] = 8'he9;
    assign box[224] = 8'hcb;
    assign box[223] = 8'h54;
    assign box[222] = 8'h7b;
    assign box[221] = 8'h94;
    assign box[220] = 8'h32;
    assign box[219] = 8'ha6;
    assign box[218] = 8'hc2;
    assign box[217] = 8'h23;
    assign box[216] = 8'h3d;
    assign box[215] = 8'hee;
    assign box[214] = 8'h4c;
    assign box[213] = 8'h95;
    assign box[212] = 8'hb;
    assign box[211] = 8'h42;
    assign box[210] = 8'hfa;
    assign box[209] = 8'hc3;
    assign box[208] = 8'h4e;
    assign box[207] = 8'h8;
    assign box[206] = 8'h2e;
    assign box[205] = 8'ha1;
    assign box[204] = 8'h66;
    assign box[203] = 8'h28;
    assign box[202] = 8'hd9;
    assign box[201] = 8'h24;
    assign box[200] = 8'hb2;
    assign box[199] = 8'h76;
    assign box[198] = 8'h5b;
    assign box[197] = 8'ha2;
    assign box[196] = 8'h49;
    assign box[195] = 8'h6d;
    assign box[194] = 8'h8b;
    assign box[193] = 8'hd1;
    assign box[192] = 8'h25;
    assign box[191] = 8'h72;
    assign box[190] = 8'hf8;
    assign box[189] = 8'hf6;
    assign box[188] = 8'h64;
    assign box[187] = 8'h86;
    assign box[186] = 8'h68;
    assign box[185] = 8'h98;
    assign box[184] = 8'h16;
    assign box[183] = 8'hd4;
    assign box[182] = 8'ha4;
    assign box[181] = 8'h5c;
    assign box[180] = 8'hcc;
    assign box[179] = 8'h5d;
    assign box[178] = 8'h65;
    assign box[177] = 8'hb6;
    assign box[176] = 8'h92;
    assign box[175] = 8'h6c;
    assign box[174] = 8'h70;
    assign box[173] = 8'h48;
    assign box[172] = 8'h50;
    assign box[171] = 8'hfd;
    assign box[170] = 8'hed;
    assign box[169] = 8'hb9;
    assign box[168] = 8'hda;
    assign box[167] = 8'h5e;
    assign box[166] = 8'h15;
    assign box[165] = 8'h46;
    assign box[164] = 8'h57;
    assign box[163] = 8'ha7;
    assign box[162] = 8'h8d;
    assign box[161] = 8'h9d;
    assign box[160] = 8'h84;
    assign box[159] = 8'h90;
    assign box[158] = 8'hd8;
    assign box[157] = 8'hab;
    assign box[156] = 8'h0;
    assign box[155] = 8'h8c;
    assign box[154] = 8'hbc;
    assign box[153] = 8'hd3;
    assign box[152] = 8'ha;
    assign box[151] = 8'hf7;
    assign box[150] = 8'he4;
    assign box[149] = 8'h58;
    assign box[148] = 8'h5;
    assign box[147] = 8'hb8;
    assign box[146] = 8'hb3;
    assign box[145] = 8'h45;
    assign box[144] = 8'h6;
    assign box[143] = 8'hd0;
    assign box[142] = 8'h2c;
    assign box[141] = 8'h1e;
    assign box[140] = 8'h8f;
    assign box[139] = 8'hca;
    assign box[138] = 8'h3f;
    assign box[137] = 8'hf;
    assign box[136] = 8'h2;
    assign box[135] = 8'hc1;
    assign box[134] = 8'haf;
    assign box[133] = 8'hbd;
    assign box[132] = 8'h3;
    assign box[131] = 8'h1;
    assign box[130] = 8'h13;
    assign box[129] = 8'h8a;
    assign box[128] = 8'h6b;
    assign box[127] = 8'h3a;
    assign box[126] = 8'h91;
    assign box[125] = 8'h11;
    assign box[124] = 8'h41;
    assign box[123] = 8'h4f;
    assign box[122] = 8'h67;
    assign box[121] = 8'hdc;
    assign box[120] = 8'hea;
    assign box[119] = 8'h97;
    assign box[118] = 8'hf2;
    assign box[117] = 8'hcf;
    assign box[116] = 8'hce;
    assign box[115] = 8'hf0;
    assign box[114] = 8'hb4;
    assign box[113] = 8'he6;
    assign box[112] = 8'h73;
    assign box[111] = 8'h96;
    assign box[110] = 8'hac;
    assign box[109] = 8'h74;
    assign box[108] = 8'h22;
    assign box[107] = 8'he7;
    assign box[106] = 8'had;
    assign box[105] = 8'h35;
    assign box[104] = 8'h85;
    assign box[103] = 8'he2;
    assign box[102] = 8'hf9;
    assign box[101] = 8'h37;
    assign box[100] = 8'he8;
    assign box[99] = 8'h1c;
    assign box[98] = 8'h75;
    assign box[97] = 8'hdf;
    assign box[96] = 8'h6e;
    assign box[95] = 8'h47;
    assign box[94] = 8'hf1;
    assign box[93] = 8'h1a;
    assign box[92] = 8'h71;
    assign box[91] = 8'h1d;
    assign box[90] = 8'h29;
    assign box[89] = 8'hc5;
    assign box[88] = 8'h89;
    assign box[87] = 8'h6f;
    assign box[86] = 8'hb7;
    assign box[85] = 8'h62;
    assign box[84] = 8'he;
    assign box[83] = 8'haa;
    assign box[82] = 8'h18;
    assign box[81] = 8'hbe;
    assign box[80] = 8'h1b;
    assign box[79] = 8'hfc;
    assign box[78] = 8'h56;
    assign box[77] = 8'h3e;
    assign box[76] = 8'h4b;
    assign box[75] = 8'hc6;
    assign box[74] = 8'hd2;
    assign box[73] = 8'h79;
    assign box[72] = 8'h20;
    assign box[71] = 8'h9a;
    assign box[70] = 8'hdb;
    assign box[69] = 8'hc0;
    assign box[68] = 8'hfe;
    assign box[67] = 8'h78;
    assign box[66] = 8'hcd;
    assign box[65] = 8'h5a;
    assign box[64] = 8'hf4;
    assign box[63] = 8'h1f;
    assign box[62] = 8'hdd;
    assign box[61] = 8'ha8;
    assign box[60] = 8'h33;
    assign box[59] = 8'h88;
    assign box[58] = 8'h7;
    assign box[57] = 8'hc7;
    assign box[56] = 8'h31;
    assign box[55] = 8'hb1;
    assign box[54] = 8'h12;
    assign box[53] = 8'h10;
    assign box[52] = 8'h59;
    assign box[51] = 8'h27;
    assign box[50] = 8'h80;
    assign box[49] = 8'hec;
    assign box[48] = 8'h5f;
    assign box[47] = 8'h60;
    assign box[46] = 8'h51;
    assign box[45] = 8'h7f;
    assign box[44] = 8'ha9;
    assign box[43] = 8'h19;
    assign box[42] = 8'hb5;
    assign box[41] = 8'h4a;
    assign box[40] = 8'hd;
    assign box[39] = 8'h2d;
    assign box[38] = 8'he5;
    assign box[37] = 8'h7a;
    assign box[36] = 8'h9f;
    assign box[35] = 8'h93;
    assign box[34] = 8'hc9;
    assign box[33] = 8'h9c;
    assign box[32] = 8'hef;
    assign box[31] = 8'ha0;
    assign box[30] = 8'he0;
    assign box[29] = 8'h3b;
    assign box[28] = 8'h4d;
    assign box[27] = 8'hae;
    assign box[26] = 8'h2a;
    assign box[25] = 8'hf5;
    assign box[24] = 8'hb0;
    assign box[23] = 8'hc8;
    assign box[22] = 8'heb;
    assign box[21] = 8'hbb;
    assign box[20] = 8'h3c;
    assign box[19] = 8'h83;
    assign box[18] = 8'h53;
    assign box[17] = 8'h99;
    assign box[16] = 8'h61;
    assign box[15] = 8'h17;
    assign box[14] = 8'h2b;
    assign box[13] = 8'h4;
    assign box[12] = 8'h7e;
    assign box[11] = 8'hba;
    assign box[10] = 8'h77;
    assign box[9] = 8'hd6;
    assign box[8] = 8'h26;
    assign box[7] = 8'he1;
    assign box[6] = 8'h69;
    assign box[5] = 8'h14;
    assign box[4] = 8'h63;
    assign box[3] = 8'h55;
    assign box[2] = 8'h21;
    assign box[1] = 8'hc;
    assign box[0] = 8'h7d;
    assign out = box[255 - b];
endmodule

module InvSubBytes
    ( input logic [3:0][3:0][7:0] state,
      output logic [3:0][3:0][7:0] out
    );
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        var logic [3:0][7:0] col;
        assign col = state[3 - gv0];
        for (genvar gv1 = 0; gv1 < 4; gv1++)
          begin
            var logic [7:0] b;
            assign b = col[3 - gv1];
            InvSbox InvSbox_inst1 (b, out[3 - gv0][3 - gv1]);
          end
      end
endmodule

module InvMixColumns
    ( input logic [3:0][3:0][7:0] state,
      output logic [3:0][3:0][7:0] out
    );
    var logic [3:0][3:0][3:0] m;
    assign m[3][3] = 4'he;
    assign m[3][2] = 4'hb;
    assign m[3][1] = 4'hd;
    assign m[3][0] = 4'h9;
    assign m[2][3] = 4'h9;
    assign m[2][2] = 4'he;
    assign m[2][1] = 4'hb;
    assign m[2][0] = 4'hd;
    assign m[1][3] = 4'hd;
    assign m[1][2] = 4'h9;
    assign m[1][1] = 4'he;
    assign m[1][0] = 4'hb;
    assign m[0][3] = 4'hb;
    assign m[0][2] = 4'hd;
    assign m[0][1] = 4'h9;
    assign m[0][0] = 4'he;
    for (genvar gv0 = 0; gv0 < 4; gv0++)
      begin
        var logic [3:0][7:0] col;
        assign col = state[3 - gv0];
        for (genvar gv1 = 0; gv1 < 4; gv1++)
          begin
            var logic [3:0][3:0] row;
            assign row = m[3 - gv1];
            dot dot_inst1 (row, col, out[3 - gv0][3 - gv1]);
          end
      end
endmodule

module InvRound
    ( input logic [3:0][3:0][7:0] s,
      input logic [3:0][3:0][7:0] rk,
      output logic [3:0][3:0][7:0] out
    );
    var logic [3:0][3:0][7:0] s1;
    var logic [3:0][3:0][7:0] s2;
    var logic [3:0][3:0][7:0] s3;
    InvShiftRows InvShiftRows_inst1 (s, s1);
    InvSubBytes InvSubBytes_inst1 (s1, s2);
    AddRoundKey AddRoundKey_inst1 (s2, rk, s3);
    InvMixColumns InvMixColumns_inst1 (s3, out);
endmodule

module InvCipher
    #(parameter int Nr)
    ( input logic [Nr:0][3:0][3:0][7:0] ks,
      input logic [3:0][3:0][7:0] in,
      output logic [3:0][3:0][7:0] out,
      input logic [Nr - 1:0] clk,
      input logic [Nr - 1:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    var logic [3:0][3:0][7:0] rk0;
    var logic [Nr - 2:0][3:0][3:0][7:0] rks;
    var logic [3:0][3:0][7:0] rkf;
    var logic [3:0][3:0][7:0] s0;
    var logic [Nr - 2:0][3:0][3:0][7:0] rounds;
    var logic [Nr - 1:0][3:0][3:0][7:0] states;
    var logic [Nr - 2:0][3:0][3:0][7:0] prev;
    var logic [3:0][3:0][7:0] sf;
    var logic [3:0][3:0][7:0] s1;
    var logic [3:0][3:0][7:0] s2;
    var logic [3:0][3:0][7:0] in_flopped;

    // scan signals
    var logic [Nr - 1:0] so_flops;

    assign rk0 = ks[Nr];
    assign rks = ks[Nr - 1:Nr - Nr + 1];
    assign rkf = ks[Nr - Nr];
    flopMux #(.DATA_WIDTH(128)) round_flop(clk[0], flop_bypass[0], in, in_flopped, sen, si, so_flops[0]);
    AddRoundKey AddRoundKey_inst1 (in_flopped, rkf, s0);
    for (genvar gv0 = 0; gv0 < Nr - 1; gv0++)
      begin
        var logic [3:0][3:0][7:0] round_group_out;
        var logic [3:0][3:0][7:0] s;
        assign s = prev[Nr - gv0 - 2];
        var logic [3:0][3:0][7:0] rk;
        assign rk = rks[Nr - gv0 - 2];
        InvRound InvRound_inst1 (s, rk, round_group_out);
        flopMux #(.DATA_WIDTH(128)) round_flop(
            clk[Nr - gv0 - 1], flop_bypass[Nr - gv0 - 1], round_group_out, rounds[Nr - gv0 - 2], sen, so_flops[Nr - gv0 - 2], so_flops[Nr - gv0 - 1]);
      end
    assign states = {rounds, {s0}};
    assign prev = states[Nr - 2:Nr - Nr];
    assign sf = states[Nr - 1];
    InvShiftRows InvShiftRows_inst1 (sf, s1);
    InvSubBytes InvSubBytes_inst1 (s1, s2);
    AddRoundKey AddRoundKey_inst2 (s2, rk0, out);
    assign so = so_flops[Nr - 1];
endmodule

module encrypt
    #(parameter int Nk, parameter int Nr)
    ( input logic [32 * Nk - 1:0] key,
      input logic [127:0] pt,
      output logic [127:0] ct,
      input logic [Nr - 1:0] clk,
      input logic [Nr - 1:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    var logic [Nk - 1:0][3:0][7:0] k;
    var logic [Nr:0][3:0][3:0][7:0] k_sch;
    var logic [3:0][3:0][7:0] s_pt;
    var logic [3:0][3:0][7:0] s_ct;
    assign k = key;
    KeyExpansion #(Nk, Nr) KeyExpansion_inst1 (k, k_sch);
    assign s_pt = pt;
    Cipher #(Nr) Cipher_inst1 (k_sch, s_pt, s_ct, clk, flop_bypass, sen, si, so);
    assign ct = s_ct;
endmodule

module decrypt
    #(parameter int Nk, parameter int Nr)
    ( input logic [32 * Nk - 1:0] key,
      input logic [127:0] ct,
      output logic [127:0] pt,
      input logic [Nr - 1:0] clk,
      input logic [Nr - 1:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    var logic [Nk - 1:0][3:0][7:0] k;
    var logic [Nr:0][3:0][3:0][7:0] k_sch;
    var logic [3:0][3:0][7:0] s_ct;
    var logic [3:0][3:0][7:0] s_pt;
    assign k = key;
    KeyExpansion #(Nk, Nr) KeyExpansion_inst1 (k, k_sch);
    assign s_ct = ct;
    InvCipher #(Nr) InvCipher_inst1 (k_sch, s_ct, s_pt, clk, flop_bypass, sen, si, so);
    assign pt = s_pt;
endmodule

module enc_dec
    #(parameter int Nk, parameter int Nr, parameter int LOCKUP = 0)
    ( input logic mode,
      input logic [32 * Nk - 1:0] key,
      input logic [127:0] in,
      output logic [127:0] out,
      input logic [Nr - 1:0] clk_cipher,
      input logic [Nr - 1:0] clk_invcipher,
      input logic [Nr - 1:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    var logic [Nk - 1:0][3:0][7:0] k;
    var logic [Nr:0][3:0][3:0][7:0] k_sch;
    var logic [3:0][3:0][7:0] s_in;
    var logic [3:0][3:0][7:0] s_enc;
    var logic [3:0][3:0][7:0] s_dec;
    var logic [3:0][3:0][7:0] s_out;
    var logic so_cipher;
    var logic so_invcipher;
    var logic si_invcipher;
    assign k = key;
    KeyExpansion #(Nk, Nr) KeyExpansion_inst1 (k, k_sch);
    assign s_in = in;
    Cipher #(Nr) Cipher_inst1 (k_sch, s_in, s_enc, clk_cipher, flop_bypass, sen, si, so_cipher);
    generate
       if (LOCKUP == 0) begin
          assign si_invcipher = so_cipher;
          assign so = so_invcipher;
       end
       else begin
           always_latch
           begin : CIPHER_LOCKUP
               if (~clk_cipher[Nr-1]) si_invcipher = so_cipher;
           end
           always_latch
           begin
               if (~clk_invcipher[Nr-1]) so = so_invcipher;
           end
       end
    endgenerate
    InvCipher #(Nr) InvCipher_inst1 (k_sch, s_in, s_dec, clk_invcipher, flop_bypass, sen, si_invcipher, so_invcipher);
    assign s_out = mode ? s_enc : s_dec;
    assign out = s_out;
endmodule

module AES128_enc
    ( input logic [127:0] key,
      input logic [127:0] pt,
      output logic [127:0] out,
      input logic [9:0] clk,
      input logic [9:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    encrypt #(4, 10) encrypt_inst1 (key, pt, out, clk, flop_bypass, sen, si, so);
endmodule

module AES128_dec
    ( input logic [127:0] key,
      input logic [127:0] ct,
      output logic [127:0] out,
      input logic [9:0] clk,
      input logic [9:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    decrypt #(4, 10) decrypt_inst1 (key, ct, out, clk, flop_bypass, sen, si, so);
endmodule

module AES256_enc
    ( input logic [255:0] key,
      input logic [127:0] pt,
      output logic [127:0] out,
      input logic [13:0] clk,
      input logic [13:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    encrypt #(8, 14) encrypt_inst1 (key, pt, out, clk, flop_bypass, sen, si, so);
endmodule

module AES256_dec
    ( input logic [255:0] key,
      input logic [127:0] ct,
      output logic [127:0] out,
      input logic [13:0] clk,
      input logic [13:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    decrypt #(8, 14) decrypt_inst1 (key, ct, out, clk, flop_bypass, sen, si, so);
endmodule

module AES128
    ( input logic mode,
      input logic [127:0] key,
      input logic [127:0] in,
      output logic [127:0] out,
      input logic [9:0] clk_cipher,
      input logic [9:0] clk_invcipher,
      input logic [9:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    enc_dec #(4, 10) enc_dec_inst1 (mode, key, in, out, clk_cipher, clk_invcipher, flop_bypass, sen, si, so);
endmodule

module AES256 #(parameter int LOCKUP = 0)
    ( input logic mode,
      input logic [255:0] key,
      input logic [127:0] in,
      output logic [127:0] out,
      input logic [13:0] clk_cipher,
      input logic [13:0] clk_invcipher,
      input logic [13:0] flop_bypass,
      // scan signals
      input logic sen, si,
      output logic so
    );
    enc_dec #(8, 14, LOCKUP) enc_dec_inst1 (mode, key, in, out, clk_cipher, clk_invcipher, flop_bypass, sen, si, so);
endmodule
