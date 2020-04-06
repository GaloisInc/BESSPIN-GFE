module MessageSchedule_next5
    ( input logic [15:0][63:0] M,
      output logic [4:0][63:0] out
    );
    assign out = M[15:11];
endmodule

module MessageSchedule_step
    ( input logic [15:0][63:0] M,
      output logic [15:0][63:0] out
    );
    var logic [20:0][63:0] W;
    for (genvar gv0 = 0; gv0 < 21; gv0++)
      begin
        localparam logic [6:0] t = gv0;
        if (t < 7'h10)
          begin
            assign W[20 - gv0] = M[15 - t];
          end
        else
          begin
            var logic [63:0] sigma1_out;
            sigma1 sigma1_inst1 (W[22 - t], sigma1_out);
            var logic [63:0] sigma0_out;
            sigma0 sigma0_inst1 (W[35 - t], sigma0_out);
            assign W[20 - gv0] = sigma1_out + W[27 - t] + sigma0_out + W[36 - t];
          end
      end
    assign out = W[15:0];
endmodule

module compress5
    ( input logic [4:0][63:0] ks,
      input logic [4:0][63:0] ws,
      input logic [7:0][63:0] h0,
      output logic [7:0][63:0] hf
    );
    var logic [4:0][7:0][63:0] prev;
    var logic [4:0][7:0][63:0] next;
    var logic [5:0][7:0][63:0] temp1;
    assign temp1 = {{h0}, next};
    assign prev = temp1[5:1];
    for (genvar gv0 = 0; gv0 < 5; gv0++)
      begin
        var logic [63:0] k;
        assign k = ks[4 - gv0];
        var logic [63:0] w;
        assign w = ws[4 - gv0];
        var logic [7:0][63:0] h;
        assign h = prev[4 - gv0];
        compress1 compress1_inst1 (k, w, h, next[4 - gv0]);
      end
    var logic [5:0][7:0][63:0] temp2;
    assign temp2 = {{h0}, next};
    assign hf = temp2[0];
endmodule

module RoundKey
    ( input logic [3:0] i,
      output logic [4:0][63:0] out
    );
    var logic [15:0][4:0][63:0] K;
    assign K[15][4] = 64'h428a2f98d728ae22;
    assign K[15][3] = 64'h7137449123ef65cd;
    assign K[15][2] = 64'hb5c0fbcfec4d3b2f;
    assign K[15][1] = 64'he9b5dba58189dbbc;
    assign K[15][0] = 64'h3956c25bf348b538;
    assign K[14][4] = 64'h59f111f1b605d019;
    assign K[14][3] = 64'h923f82a4af194f9b;
    assign K[14][2] = 64'hab1c5ed5da6d8118;
    assign K[14][1] = 64'hd807aa98a3030242;
    assign K[14][0] = 64'h12835b0145706fbe;
    assign K[13][4] = 64'h243185be4ee4b28c;
    assign K[13][3] = 64'h550c7dc3d5ffb4e2;
    assign K[13][2] = 64'h72be5d74f27b896f;
    assign K[13][1] = 64'h80deb1fe3b1696b1;
    assign K[13][0] = 64'h9bdc06a725c71235;
    assign K[12][4] = 64'hc19bf174cf692694;
    assign K[12][3] = 64'he49b69c19ef14ad2;
    assign K[12][2] = 64'hefbe4786384f25e3;
    assign K[12][1] = 64'hfc19dc68b8cd5b5;
    assign K[12][0] = 64'h240ca1cc77ac9c65;
    assign K[11][4] = 64'h2de92c6f592b0275;
    assign K[11][3] = 64'h4a7484aa6ea6e483;
    assign K[11][2] = 64'h5cb0a9dcbd41fbd4;
    assign K[11][1] = 64'h76f988da831153b5;
    assign K[11][0] = 64'h983e5152ee66dfab;
    assign K[10][4] = 64'ha831c66d2db43210;
    assign K[10][3] = 64'hb00327c898fb213f;
    assign K[10][2] = 64'hbf597fc7beef0ee4;
    assign K[10][1] = 64'hc6e00bf33da88fc2;
    assign K[10][0] = 64'hd5a79147930aa725;
    assign K[9][4] = 64'h6ca6351e003826f;
    assign K[9][3] = 64'h142929670a0e6e70;
    assign K[9][2] = 64'h27b70a8546d22ffc;
    assign K[9][1] = 64'h2e1b21385c26c926;
    assign K[9][0] = 64'h4d2c6dfc5ac42aed;
    assign K[8][4] = 64'h53380d139d95b3df;
    assign K[8][3] = 64'h650a73548baf63de;
    assign K[8][2] = 64'h766a0abb3c77b2a8;
    assign K[8][1] = 64'h81c2c92e47edaee6;
    assign K[8][0] = 64'h92722c851482353b;
    assign K[7][4] = 64'ha2bfe8a14cf10364;
    assign K[7][3] = 64'ha81a664bbc423001;
    assign K[7][2] = 64'hc24b8b70d0f89791;
    assign K[7][1] = 64'hc76c51a30654be30;
    assign K[7][0] = 64'hd192e819d6ef5218;
    assign K[6][4] = 64'hd69906245565a910;
    assign K[6][3] = 64'hf40e35855771202a;
    assign K[6][2] = 64'h106aa07032bbd1b8;
    assign K[6][1] = 64'h19a4c116b8d2d0c8;
    assign K[6][0] = 64'h1e376c085141ab53;
    assign K[5][4] = 64'h2748774cdf8eeb99;
    assign K[5][3] = 64'h34b0bcb5e19b48a8;
    assign K[5][2] = 64'h391c0cb3c5c95a63;
    assign K[5][1] = 64'h4ed8aa4ae3418acb;
    assign K[5][0] = 64'h5b9cca4f7763e373;
    assign K[4][4] = 64'h682e6ff3d6b2b8a3;
    assign K[4][3] = 64'h748f82ee5defb2fc;
    assign K[4][2] = 64'h78a5636f43172f60;
    assign K[4][1] = 64'h84c87814a1f0ab72;
    assign K[4][0] = 64'h8cc702081a6439ec;
    assign K[3][4] = 64'h90befffa23631e28;
    assign K[3][3] = 64'ha4506cebde82bde9;
    assign K[3][2] = 64'hbef9a3f7b2c67915;
    assign K[3][1] = 64'hc67178f2e372532b;
    assign K[3][0] = 64'hca273eceea26619c;
    assign K[2][4] = 64'hd186b8c721c0c207;
    assign K[2][3] = 64'heada7dd6cde0eb1e;
    assign K[2][2] = 64'hf57d4f7fee6ed178;
    assign K[2][1] = 64'h6f067aa72176fba;
    assign K[2][0] = 64'ha637dc5a2c898a6;
    assign K[1][4] = 64'h113f9804bef90dae;
    assign K[1][3] = 64'h1b710b35131c471b;
    assign K[1][2] = 64'h28db77f523047d84;
    assign K[1][1] = 64'h32caab7b40c72493;
    assign K[1][0] = 64'h3c9ebe0a15c9bebc;
    assign K[0][4] = 64'h431d67c49c100d4c;
    assign K[0][3] = 64'h4cc5d4becb3e42b6;
    assign K[0][2] = 64'h597f299cfc657e2a;
    assign K[0][1] = 64'h5fcb6fab3ad6faec;
    assign K[0][0] = 64'h6c44198c4a475817;
    assign out = K[15 - i];
endmodule

module addState
    ( input logic [7:0][63:0] h0,
      input logic [7:0][63:0] hf,
      output logic [7:0][63:0] out
    );
    for (genvar gv0 = 0; gv0 < 8; gv0++)
      begin
        var logic [63:0] x;
        assign x = h0[7 - gv0];
        var logic [63:0] y;
        assign y = hf[7 - gv0];
        assign out[7 - gv0] = x + y;
      end
endmodule

module join_16_64
    ( input logic [15:0][63:0] __p17,
      output logic [1023:0] out
    );
    var logic [63:0] b0;
    var logic [63:0] b1;
    var logic [63:0] b2;
    var logic [63:0] b3;
    var logic [63:0] b4;
    var logic [63:0] b5;
    var logic [63:0] b6;
    var logic [63:0] b7;
    var logic [63:0] b8;
    var logic [63:0] b9;
    var logic [63:0] ba;
    var logic [63:0] bb;
    var logic [63:0] bc;
    var logic [63:0] bd;
    var logic [63:0] be;
    var logic [63:0] bf;
    assign b0 = __p17[15];
    assign b1 = __p17[14];
    assign b2 = __p17[13];
    assign b3 = __p17[12];
    assign b4 = __p17[11];
    assign b5 = __p17[10];
    assign b6 = __p17[9];
    assign b7 = __p17[8];
    assign b8 = __p17[7];
    assign b9 = __p17[6];
    assign ba = __p17[5];
    assign bb = __p17[4];
    assign bc = __p17[3];
    assign bd = __p17[2];
    assign be = __p17[1];
    assign bf = __p17[0];
    assign out = {b0, {b1, {b2, {b3, {b4, {b5, {b6, {b7, {b8, {b9, {ba, {bb, {bc, {bd, {be, bf}}}}}}}}}}}}}}};
endmodule

module join_8_64
    ( input logic [7:0][63:0] __p18,
      output logic [511:0] out
    );
    var logic [63:0] b0;
    var logic [63:0] b1;
    var logic [63:0] b2;
    var logic [63:0] b3;
    var logic [63:0] b4;
    var logic [63:0] b5;
    var logic [63:0] b6;
    var logic [63:0] b7;
    assign b0 = __p18[7];
    assign b1 = __p18[6];
    assign b2 = __p18[5];
    assign b3 = __p18[4];
    assign b4 = __p18[3];
    assign b5 = __p18[2];
    assign b6 = __p18[1];
    assign b7 = __p18[0];
    assign out = {b0, {b1, {b2, {b3, {b4, {b5, {b6, b7}}}}}}};
endmodule

module ProcessBlock_init
    ( input logic [7:0][63:0] h0,
      input logic [15:0][63:0] m0,
      output logic [2051:0] out
    );
    var logic [511:0] join_8_64_out;
    join_8_64 join_8_64_inst1 (h0, join_8_64_out);
    var logic [511:0] join_8_64_out1;
    join_8_64 join_8_64_inst2 (h0, join_8_64_out1);
    var logic [1023:0] join_16_64_out;
    join_16_64 join_16_64_inst1 (m0, join_16_64_out);
    assign out = {4'h0, {join_8_64_out, {join_8_64_out1, join_16_64_out}}};
endmodule

module ProcessBlock_step
    ( input logic [2051:0] __p7,
      output logic [2051:0] out
    );
    var logic [3:0] i;
    var logic [511:0] h0;
    var logic [511:0] h_prev_;
    var logic [1023:0] m_prev_;
    var logic [7:0][63:0] h_prev;
    var logic [15:0][63:0] m_prev;
    var logic [7:0][63:0] h_next;
    var logic [15:0][63:0] m_next;
    assign i = __p7[2051:2048];
    assign h0 = __p7[2047:1536];
    assign h_prev_ = __p7[1535:1024];
    assign m_prev_ = __p7[1023:0];
    assign h_prev = h_prev_;
    assign m_prev = m_prev_;
    var logic [4:0][63:0] RoundKey_out;
    RoundKey RoundKey_inst1 (i, RoundKey_out);
    var logic [4:0][63:0] MessageSchedule_next5_out;
    MessageSchedule_next5 MessageSchedule_next5_inst1 (m_prev, MessageSchedule_next5_out);
    compress5 compress5_inst1 (RoundKey_out, MessageSchedule_next5_out, h_prev, h_next);
    MessageSchedule_step MessageSchedule_step_inst1 (m_prev, m_next);
    var logic [511:0] join_8_64_out;
    join_8_64 join_8_64_inst1 (h_next, join_8_64_out);
    var logic [1023:0] join_16_64_out;
    join_16_64 join_16_64_inst1 (m_next, join_16_64_out);
    assign out = {i + 4'h1, {h0, {join_8_64_out, join_16_64_out}}};
endmodule

module ProcessBlock_final
    ( input logic [2051:0] __p15,
      output logic [7:0][63:0] out
    );
    var logic [511:0] h0_;
    var logic [511:0] hf_;
    var logic [7:0][63:0] h0;
    var logic [7:0][63:0] hf;
    assign h0_ = __p15[2047:1536];
    assign hf_ = __p15[1535:1024];
    assign h0 = h0_;
    assign hf = hf_;
    addState addState_inst1 (h0, hf, out);
endmodule

module MessageSchedule_decomposed
    ( input logic [15:0][63:0] m0,
      output logic [15:0][4:0][63:0] ws
    );
    var logic [15:0][15:0][63:0] ms;
    var logic [14:0][15:0][63:0] temp1;
    for (genvar gv0 = 0; gv0 < 15; gv0++)
      begin
        var logic [15:0][63:0] m;
        assign m = ms[15 - gv0];
        MessageSchedule_step MessageSchedule_step_inst1 (m, temp1[14 - gv0]);
      end
    assign ms = {{m0}, temp1};
    for (genvar gv0 = 0; gv0 < 16; gv0++)
      begin
        var logic [15:0][63:0] m;
        assign m = ms[15 - gv0];
        MessageSchedule_next5 MessageSchedule_next5_inst1 (m, ws[15 - gv0]);
      end
endmodule

module padLastBlock
    ( input logic [127:0] l,
      input logic [15:0][63:0] b,
      output logic [2048:0] out
    );
    var logic [127:0] bl;
    var logic needBlock2;
    var logic [2047:0] mask;
    var logic [2047:0] onebit;
    var logic [2047:0] lenbits;
    var logic [2047:0] bs;
    assign bl = l == 128'h0 ? 128'h0 : (l - 128'h1) % 128'h400 + 128'h1;
    assign needBlock2 = bl > 128'h400 - 128'h81;
    assign mask = ~ 2048'h0 << (128'h800 - bl);
    assign onebit = {1'h1, 2047'h0} >> bl;
    assign lenbits = needBlock2 ? {1920'h0, l} : {896'h0, {l, 1024'h0}};
    var logic [1023:0] join_16_64_out;
    join_16_64 join_16_64_inst1 (b, join_16_64_out);
    assign bs = {join_16_64_out, 1024'h0} & mask ^ onebit ^ lenbits;
    assign out = {bs, {needBlock2}};
endmodule

module ProcessBlock_decomposed
    ( input logic [7:0][63:0] h0,
      input logic [15:0][63:0] m0,
      output logic [7:0][63:0] out
    );
    var logic [15:0][2051:0] s_init;
    var logic [15:0][2051:0] s_tail;
    var logic [2051:0] sf;
    var logic [2051:0] ProcessBlock_init_out;
    ProcessBlock_init ProcessBlock_init_inst1 (h0, m0, ProcessBlock_init_out);
    var logic [16:0][2051:0] temp1;
    var logic [2051:0] ProcessBlock_init_out1;
    ProcessBlock_init ProcessBlock_init_inst2 (h0, m0, ProcessBlock_init_out1);
    assign temp1 = {{ProcessBlock_init_out1}, s_tail};
    assign s_init = temp1[16:1];
    for (genvar gv0 = 0; gv0 < 16; gv0++)
      begin
        var logic [2051:0] s;
        assign s = s_init[15 - gv0];
        ProcessBlock_step ProcessBlock_step_inst1 (s, s_tail[15 - gv0]);
      end
    var logic [2051:0] ProcessBlock_init_out2;
    ProcessBlock_init ProcessBlock_init_inst3 (h0, m0, ProcessBlock_init_out2);
    var logic [16:0][2051:0] temp2;
    var logic [2051:0] ProcessBlock_init_out3;
    ProcessBlock_init ProcessBlock_init_inst4 (h0, m0, ProcessBlock_init_out3);
    assign temp2 = {{ProcessBlock_init_out3}, s_tail};
    assign sf = temp2[0];
    ProcessBlock_final ProcessBlock_final_inst1 (sf, out);
endmodule
