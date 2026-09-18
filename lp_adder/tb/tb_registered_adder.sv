`timescale 1ns/1ps

module tb_registered_adder;
    parameter WIDTH = 8;

    logic clk, rst_n, valid_i;
    logic [WIDTH-1:0] data_a, data_b;
    logic valid_o;
    logic [WIDTH:0] sum;

    registered_adder #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .valid_i(valid_i),
        .data_a(data_a), .data_b(data_b),
        .valid_o(valid_o), .sum(sum)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $fsdbDumpfile("adder.fsdb");
        $fsdbDumpvars(0, tb_registered_adder);
    end

    initial begin
        rst_n = 1'b0;
        valid_i = 1'b0;
        data_a = '0;
        data_b = '0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
    end

    initial begin
        wait(rst_n);
        @(posedge clk);
        valid_i <= 1'b1; data_a <= 8'd5;   data_b <= 8'd3;
        @(posedge clk);
        data_a <= 8'd10;  data_b <= 8'd20;
        @(posedge clk);
        data_a <= 8'd255; data_b <= 8'd1;
        @(posedge clk);
        valid_i <= 1'b0;
        repeat (5) @(posedge clk);
        $finish;
    end

    always @(posedge clk) begin
        $display("T=%0t rst_n=%b valid_i=%b a=%0d b=%0d | valid_o=%b sum=%0d",
                 $time, rst_n, valid_i, data_a, data_b, valid_o, sum);
    end
endmodule
