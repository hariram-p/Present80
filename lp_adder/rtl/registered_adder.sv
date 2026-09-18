module registered_adder #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             valid_i,
    input  logic [WIDTH-1:0] data_a,
    input  logic [WIDTH-1:0] data_b,
    output logic             valid_o,
    output logic [WIDTH:0]   sum
);

    logic [WIDTH-1:0] a_reg;
    logic [WIDTH-1:0] b_reg;
    logic             valid_reg;
    logic [WIDTH:0]   sum_comb;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg     <= '0;
            b_reg     <= '0;
            valid_reg <= 1'b0;
        end else begin
            a_reg     <= data_a;
            b_reg     <= data_b;
            valid_reg <= valid_i;
        end
    end

    assign sum_comb = {1'b0, a_reg} + {1'b0, b_reg};

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum     <= '0;
            valid_o <= 1'b0;
        end else begin
            sum     <= sum_comb;
            valid_o <= valid_reg;
        end
    end
endmodule
