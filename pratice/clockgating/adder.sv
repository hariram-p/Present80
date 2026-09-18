module math_mul (input logic [31:0] a, b,
              output [64:0] multiplier
              input clk,
              input rst);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin

            multiplier <= 0;
        end else begin
            multiplier<= a * b;
        end
    end

endmodule
module math_add (input logic [31:0] a, b,
              output logic [31:0] sum,
              output logic carry_out
              input clk,
              input rst);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 0;
            carry_out <= 0;
        end else begin
            {carry_out, sum} <= a + b;
        end
    end

endmodule
