module Ch
    ( input logic [63:0] x,
      input logic [63:0] y,
      input logic [63:0] z,
      output logic [63:0] out
    );
    assign out = x & y ^ ~ x & z;
endmodule

module Maj
    ( input logic [63:0] x,
      input logic [63:0] y,
      input logic [63:0] z,
      output logic [63:0] out
    );
    assign out = x & y ^ x & z ^ y & z;
endmodule

module Sigma0
    ( input logic [63:0] x,
      output logic [63:0] out
    );
    var logic [127:0] temp1;
    assign temp1 = {x, x};
    var logic [127:0] temp2;
    assign temp2 = {x, x};
    var logic [127:0] temp3;
    assign temp3 = {x, x};
    assign out = temp1[91:28] ^ temp2[97:34] ^ temp3[102:39];
endmodule

module Sigma1
    ( input logic [63:0] x,
      output logic [63:0] out
    );
    var logic [127:0] temp1;
    assign temp1 = {x, x};
    var logic [127:0] temp2;
    assign temp2 = {x, x};
    var logic [127:0] temp3;
    assign temp3 = {x, x};
    assign out = temp1[77:14] ^ temp2[81:18] ^ temp3[104:41];
endmodule

module sigma0
    ( input logic [63:0] x,
      output logic [63:0] out
    );
    var logic [127:0] temp1;
    assign temp1 = {x, x};
    var logic [127:0] temp2;
    assign temp2 = {x, x};
    assign out = temp1[64:1] ^ temp2[71:8] ^ (x >> 3'h7);
endmodule

module sigma1
    ( input logic [63:0] x,
      output logic [63:0] out
    );
    var logic [127:0] temp1;
    assign temp1 = {x, x};
    var logic [127:0] temp2;
    assign temp2 = {x, x};
    assign out = temp1[82:19] ^ temp2[124:61] ^ (x >> 3'h6);
endmodule

module h512
    ( output logic [7:0][63:0] out
    );
    assign out[7] = 64'h6a09e667f3bcc908;
    assign out[6] = 64'hbb67ae8584caa73b;
    assign out[5] = 64'h3c6ef372fe94f82b;
    assign out[4] = 64'ha54ff53a5f1d36f1;
    assign out[3] = 64'h510e527fade682d1;
    assign out[2] = 64'h9b05688c2b3e6c1f;
    assign out[1] = 64'h1f83d9abfb41bd6b;
    assign out[0] = 64'h5be0cd19137e2179;
endmodule

module h384
    ( output logic [7:0][63:0] out
    );
    assign out[7] = 64'hcbbb9d5dc1059ed8;
    assign out[6] = 64'h629a292a367cd507;
    assign out[5] = 64'h9159015a3070dd17;
    assign out[4] = 64'h152fecd8f70e5939;
    assign out[3] = 64'h67332667ffc00b31;
    assign out[2] = 64'h8eb44a8768581511;
    assign out[1] = 64'hdb0c2e0d64f98fa7;
    assign out[0] = 64'h47b5481dbefa4fa4;
endmodule

module MessageSchedule
    ( input logic [15:0][63:0] M,
      output logic [79:0][63:0] W
    );
    for (genvar gv0 = 0; gv0 < 80; gv0++)
      begin
        localparam logic [6:0] t = gv0;
        if (t < 7'h10)
          begin
            assign W[79 - gv0] = M[15 - t];
          end
        else
          begin
            var logic [63:0] sigma1_out;
            sigma1 sigma1_inst1 (W[81 - t], sigma1_out);
            var logic [63:0] sigma0_out;
            sigma0 sigma0_inst1 (W[94 - t], sigma0_out);
            assign W[79 - gv0] = sigma1_out + W[86 - t] + sigma0_out + W[95 - t];
          end
      end
endmodule

module compress1
    ( input logic [63:0] k,
      input logic [63:0] w,
      input logic [7:0][63:0] H,
      output logic [7:0][63:0] out
    );
    var logic [63:0] a;
    var logic [63:0] b;
    var logic [63:0] c;
    var logic [63:0] d;
    var logic [63:0] e;
    var logic [63:0] f;
    var logic [63:0] g;
    var logic [63:0] h;
    var logic [63:0] T1;
    var logic [63:0] T2;
    assign a = H[7];
    assign b = H[6];
    assign c = H[5];
    assign d = H[4];
    assign e = H[3];
    assign f = H[2];
    assign g = H[1];
    assign h = H[0];
    var logic [63:0] Sigma1_out;
    Sigma1 Sigma1_inst1 (e, Sigma1_out);
    var logic [63:0] Ch_out;
    Ch Ch_inst1 (e, f, g, Ch_out);
    assign T1 = h + Sigma1_out + Ch_out + k + w;
    var logic [63:0] Sigma0_out;
    Sigma0 Sigma0_inst1 (a, Sigma0_out);
    var logic [63:0] Maj_out;
    Maj Maj_inst1 (a, b, c, Maj_out);
    assign T2 = Sigma0_out + Maj_out;
    assign out[7] = T1 + T2;
    assign out[6] = a;
    assign out[5] = b;
    assign out[4] = c;
    assign out[3] = d + T1;
    assign out[2] = e;
    assign out[1] = f;
    assign out[0] = g;
endmodule

module compress
    ( input logic [7:0][63:0] h0,
      input logic [79:0][63:0] ws,
      output logic [7:0][63:0] out
    );
    var logic [79:0][63:0] K;
    var logic [79:0][7:0][63:0] prev;
    var logic [79:0][7:0][63:0] next;
    var logic [7:0][63:0] hf;
    assign K[79] = 64'h428a2f98d728ae22;
    assign K[78] = 64'h7137449123ef65cd;
    assign K[77] = 64'hb5c0fbcfec4d3b2f;
    assign K[76] = 64'he9b5dba58189dbbc;
    assign K[75] = 64'h3956c25bf348b538;
    assign K[74] = 64'h59f111f1b605d019;
    assign K[73] = 64'h923f82a4af194f9b;
    assign K[72] = 64'hab1c5ed5da6d8118;
    assign K[71] = 64'hd807aa98a3030242;
    assign K[70] = 64'h12835b0145706fbe;
    assign K[69] = 64'h243185be4ee4b28c;
    assign K[68] = 64'h550c7dc3d5ffb4e2;
    assign K[67] = 64'h72be5d74f27b896f;
    assign K[66] = 64'h80deb1fe3b1696b1;
    assign K[65] = 64'h9bdc06a725c71235;
    assign K[64] = 64'hc19bf174cf692694;
    assign K[63] = 64'he49b69c19ef14ad2;
    assign K[62] = 64'hefbe4786384f25e3;
    assign K[61] = 64'hfc19dc68b8cd5b5;
    assign K[60] = 64'h240ca1cc77ac9c65;
    assign K[59] = 64'h2de92c6f592b0275;
    assign K[58] = 64'h4a7484aa6ea6e483;
    assign K[57] = 64'h5cb0a9dcbd41fbd4;
    assign K[56] = 64'h76f988da831153b5;
    assign K[55] = 64'h983e5152ee66dfab;
    assign K[54] = 64'ha831c66d2db43210;
    assign K[53] = 64'hb00327c898fb213f;
    assign K[52] = 64'hbf597fc7beef0ee4;
    assign K[51] = 64'hc6e00bf33da88fc2;
    assign K[50] = 64'hd5a79147930aa725;
    assign K[49] = 64'h6ca6351e003826f;
    assign K[48] = 64'h142929670a0e6e70;
    assign K[47] = 64'h27b70a8546d22ffc;
    assign K[46] = 64'h2e1b21385c26c926;
    assign K[45] = 64'h4d2c6dfc5ac42aed;
    assign K[44] = 64'h53380d139d95b3df;
    assign K[43] = 64'h650a73548baf63de;
    assign K[42] = 64'h766a0abb3c77b2a8;
    assign K[41] = 64'h81c2c92e47edaee6;
    assign K[40] = 64'h92722c851482353b;
    assign K[39] = 64'ha2bfe8a14cf10364;
    assign K[38] = 64'ha81a664bbc423001;
    assign K[37] = 64'hc24b8b70d0f89791;
    assign K[36] = 64'hc76c51a30654be30;
    assign K[35] = 64'hd192e819d6ef5218;
    assign K[34] = 64'hd69906245565a910;
    assign K[33] = 64'hf40e35855771202a;
    assign K[32] = 64'h106aa07032bbd1b8;
    assign K[31] = 64'h19a4c116b8d2d0c8;
    assign K[30] = 64'h1e376c085141ab53;
    assign K[29] = 64'h2748774cdf8eeb99;
    assign K[28] = 64'h34b0bcb5e19b48a8;
    assign K[27] = 64'h391c0cb3c5c95a63;
    assign K[26] = 64'h4ed8aa4ae3418acb;
    assign K[25] = 64'h5b9cca4f7763e373;
    assign K[24] = 64'h682e6ff3d6b2b8a3;
    assign K[23] = 64'h748f82ee5defb2fc;
    assign K[22] = 64'h78a5636f43172f60;
    assign K[21] = 64'h84c87814a1f0ab72;
    assign K[20] = 64'h8cc702081a6439ec;
    assign K[19] = 64'h90befffa23631e28;
    assign K[18] = 64'ha4506cebde82bde9;
    assign K[17] = 64'hbef9a3f7b2c67915;
    assign K[16] = 64'hc67178f2e372532b;
    assign K[15] = 64'hca273eceea26619c;
    assign K[14] = 64'hd186b8c721c0c207;
    assign K[13] = 64'heada7dd6cde0eb1e;
    assign K[12] = 64'hf57d4f7fee6ed178;
    assign K[11] = 64'h6f067aa72176fba;
    assign K[10] = 64'ha637dc5a2c898a6;
    assign K[9] = 64'h113f9804bef90dae;
    assign K[8] = 64'h1b710b35131c471b;
    assign K[7] = 64'h28db77f523047d84;
    assign K[6] = 64'h32caab7b40c72493;
    assign K[5] = 64'h3c9ebe0a15c9bebc;
    assign K[4] = 64'h431d67c49c100d4c;
    assign K[3] = 64'h4cc5d4becb3e42b6;
    assign K[2] = 64'h597f299cfc657e2a;
    assign K[1] = 64'h5fcb6fab3ad6faec;
    assign K[0] = 64'h6c44198c4a475817;
    var logic [80:0][7:0][63:0] temp1;
    assign temp1 = {{h0}, next};
    assign prev = temp1[80:1];
    for (genvar gv0 = 0; gv0 < 80; gv0++)
      begin
        var logic [63:0] k;
        assign k = K[79 - gv0];
        var logic [63:0] w;
        assign w = ws[79 - gv0];
        var logic [7:0][63:0] h;
        assign h = prev[79 - gv0];
        compress1 compress1_inst1 (k, w, h, next[79 - gv0]);
      end
    var logic [80:0][7:0][63:0] temp2;
    assign temp2 = {{h0}, next};
    assign hf = temp2[0];
    for (genvar gv0 = 0; gv0 < 8; gv0++)
      begin
        var logic [63:0] x;
        assign x = h0[7 - gv0];
        var logic [63:0] y;
        assign y = hf[7 - gv0];
        assign out[7 - gv0] = x + y;
      end
endmodule

module ProcessBlock
    ( input logic [7:0][63:0] H,
      input logic [15:0][63:0] M,
      output logic [7:0][63:0] out
    );
    var logic [79:0][63:0] MessageSchedule_out;
    MessageSchedule MessageSchedule_inst1 (M, MessageSchedule_out);
    compress compress_inst1 (H, MessageSchedule_out, out);
endmodule

module padSmallBlock
    ( input logic [127:0] l,
      input logic [15:0][63:0] B,
      output logic [15:0][63:0] out
    );
    var logic [63:0] l0;
    var logic [63:0] l1;
    var logic [63:0] w;
    var logic [13:0][63:0] b;
    assign l0 = l[127:64];
    assign l1 = l[63:0];
    assign w = {58'h0, l[5:0]};
    for (genvar gv0 = 0; gv0 < 14; gv0++)
      begin
        localparam logic [127:0] i = gv0;
        assign b[13 - gv0] = i < l % 128'h400 / 128'h40 ? B[15 - i] : i == l % 128'h400 / 128'h40 ? B[15 - i] & (64'hffffffffffffffff << (64'h40 - w)) | (64'h8000000000000000 >> w) : 64'h0;
      end
    assign out = {b, {l0, l1}};
endmodule

module padLargeBlock
    ( input logic [127:0] l,
      input logic [15:0][63:0] B,
      output logic [1:0][15:0][63:0] out
    );
    var logic [127:0] padword;
    var logic [63:0] l0;
    var logic [63:0] l1;
    var logic [63:0] w;
    var logic [13:0][63:0] Z;
    var logic [29:0][63:0] B_;
    var logic [29:0][63:0] b;
    var logic [15:0][63:0] b0;
    var logic [15:0][63:0] b1;
    var logic [127:0] W;
    assign W = l % 128'h400 / 128'h40;
    assign padword = W == 128'h0 ? 128'h10 : W;
    assign l0 = l[127:64];
    assign l1 = l[63:0];
    assign w = {58'h0, l[5:0]};
    assign Z = 896'h0;
    assign B_ = {B, Z};
    for (genvar gv0 = 0; gv0 < 30; gv0++)
      begin
        localparam logic [127:0] i = gv0;
        assign b[29 - gv0] = i < padword ? B_[29 - i] : i == padword ? B_[29 - i] & (64'hffffffffffffffff << (64'h40 - w)) | (64'h8000000000000000 >> w) : 64'h0;
      end
    var logic [31:0][63:0] temp1;
    assign temp1 = {b, {l0, l1}};
    assign b0 = temp1[31:16];
    var logic [31:0][63:0] temp2;
    assign temp2 = {b, {l0, l1}};
    assign b1 = temp2[15:0];
    assign out[1] = b0;
    assign out[0] = b1;
endmodule

module processLastBlock
    ( input logic [127:0] l,
      input logic [7:0][63:0] H,
      input logic [15:0][63:0] B,
      output logic [7:0][63:0] out
    );
    var logic [15:0][63:0] b0;
    var logic [15:0][63:0] b1;
    var logic [1:0][15:0][63:0] padLargeBlock_out;
    padLargeBlock padLargeBlock_inst1 (l, B, padLargeBlock_out);
    assign b0 = padLargeBlock_out[1];
    var logic [1:0][15:0][63:0] padLargeBlock_out1;
    padLargeBlock padLargeBlock_inst2 (l, B, padLargeBlock_out1);
    assign b1 = padLargeBlock_out1[0];
    var logic [127:0] m;
    assign m = l % 128'h400;
    var logic [7:0][63:0] ProcessBlock_out;
    var logic [15:0][63:0] padSmallBlock_out;
    padSmallBlock padSmallBlock_inst1 (l, B, padSmallBlock_out);
    ProcessBlock ProcessBlock_inst1 (H, padSmallBlock_out, ProcessBlock_out);
    var logic [7:0][63:0] ProcessBlock_out1;
    var logic [7:0][63:0] ProcessBlock_out2;
    ProcessBlock ProcessBlock_inst3 (H, b0, ProcessBlock_out2);
    ProcessBlock ProcessBlock_inst2 (ProcessBlock_out2, b1, ProcessBlock_out1);
    assign out = (l == 128'h0) | (m != 128'h0) & (m < 128'h380) ? ProcessBlock_out : ProcessBlock_out1;
endmodule
