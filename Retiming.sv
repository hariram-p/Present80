module retiming(input logic clk,input logic resetn, input logic [31:0] a ,input logic [31:0] b,output logic [31:0] out);
  logic [31:0] a_reg;
  logic [31:0] b_reg;
  always_ff @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      a_reg<=0;
      b_reg<=0;
      out<=0
    end
    else begin
      a_reg<=a;
      b_reg<=b;
      out<=a_reg*b_reg;
    end
  end
endmodule
