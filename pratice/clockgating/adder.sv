module math_mul (input logic [31:0] a, b,
              output logic [31:0] sum,
              output logic carry_out
              output [64:0] multiplier
              input clk,
              input rst);

    assign sum = a + b; 
    assign multiplier = a * b;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 0;
            carry_out <= 0;
            multiplier <= 0;
        end else begin
            {carry_out, sum} <= a + b;
            multiplier<= a * b;
        end
    end

endmodule
module math_add (input logic [31:0] a, b,
              output logic [31:0] sum,
              output logic carry_out
              output [64:0] multiplier
              input clk,
              input rst);

    assign sum = a + b; 
    assign multiplier = a * b;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 0;
            carry_out <= 0;
            multiplier <= 0;
        end else begin
            {carry_out, sum} <= a + b;
            multiplier<= a * b;
        end
    end

endmodule
