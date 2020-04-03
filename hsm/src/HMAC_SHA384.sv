module IKeyInit_unprocessed
    ( input logic [1023:0] k,
      output logic [15:0][63:0] out
    );
    var logic [15:0][63:0] ipad;
    var logic [15:0][63:0] key;
    for (genvar gv0 = 0; gv0 < 16; gv0++)
      begin
        localparam logic [3:0] i = gv0;
        assign ipad[15 - gv0] = 64'h3636363636363636;
      end
    for (genvar gv0 = 0; gv0 < 16; gv0++)
      begin
        localparam logic [9:0] i = gv0;
        for (genvar gv1 = 0; gv1 < 64; gv1++)
          begin
            localparam logic [9:0] j = gv1;
            assign key[15 - gv0][63 - gv1] = k[1023 - (10'h40 * i + j)];
          end
      end
    assign out = key ^ ipad;
endmodule

module IKeyInit
    ( input logic [1023:0] k,
      output logic [7:0][63:0] out
    );
    var logic [15:0][63:0] IKeyInit_unprocessed_out;
    IKeyInit_unprocessed IKeyInit_unprocessed_inst1 (k, IKeyInit_unprocessed_out);
    ProcessBlock ProcessBlock_inst1 (h384, IKeyInit_unprocessed_out, out);
endmodule

module OKeyInit_unprocessed
    ( input logic [1023:0] k,
      output logic [15:0][63:0] out
    );
    var logic [15:0][63:0] opad;
    var logic [15:0][63:0] key;
    for (genvar gv0 = 0; gv0 < 16; gv0++)
      begin
        localparam logic [3:0] i = gv0;
        assign opad[15 - gv0] = 64'h5c5c5c5c5c5c5c5c;
      end
    for (genvar gv0 = 0; gv0 < 16; gv0++)
      begin
        localparam logic [9:0] i = gv0;
        for (genvar gv1 = 0; gv1 < 64; gv1++)
          begin
            localparam logic [9:0] j = gv1;
            assign key[15 - gv0][63 - gv1] = k[1023 - (10'h40 * i + j)];
          end
      end
    assign out = key ^ opad;
endmodule

module OKeyInit
    ( input logic [1023:0] k,
      output logic [7:0][63:0] out
    );
    var logic [15:0][63:0] OKeyInit_unprocessed_out;
    OKeyInit_unprocessed OKeyInit_unprocessed_inst1 (k, OKeyInit_unprocessed_out);
    ProcessBlock ProcessBlock_inst1 (h384, OKeyInit_unprocessed_out, out);
endmodule

module Finalize_unprocessed
    ( input logic [7:0][63:0] hash,
      output logic [15:0][63:0] m
    );
    for (genvar gv0 = 0; gv0 < 16; gv0++)
      begin
        localparam logic [3:0] i = gv0;
        if (i < 4'h6)
          begin
            assign m[15 - gv0] = hash[7 - i];
          end
        else
          begin
            if (i == 4'h6)
              begin
                assign m[15 - gv0] = 64'h8000000000000000;
              end
            else
              begin
                if (i == 4'hf)
                  begin
                    assign m[15 - gv0] = 64'h400 + 64'h180;
                  end
                else
                  begin
                    assign m[15 - gv0] = 64'h0;
                  end
              end
          end
      end
endmodule

module Finalize
    ( input logic [7:0][63:0] ok,
      input logic [7:0][63:0] hash,
      output logic [7:0][63:0] out
    );
    var logic [15:0][63:0] Finalize_unprocessed_out;
    Finalize_unprocessed Finalize_unprocessed_inst1 (hash, Finalize_unprocessed_out);
    ProcessBlock ProcessBlock_inst1 (ok, Finalize_unprocessed_out, out);
endmodule

module padLastBlock_hmac
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
    var logic [127:0] l_;
    assign l_ = l + 128'h400;
    assign lenbits = needBlock2 ? {1920'h0, l_} : {896'h0, {l_, 1024'h0}};
    var logic [1023:0] join_16_64_out;
    join_16_64 join_16_64_inst1 (b, join_16_64_out);
    assign bs = {join_16_64_out, 1024'h0} & mask ^ onebit ^ lenbits;
    assign out = {bs, {needBlock2}};
endmodule
