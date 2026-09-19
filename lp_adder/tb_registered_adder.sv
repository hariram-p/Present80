`timescale 1ns/1ps

module tb_registered_adder;

    parameter WIDTH = 8;

    logic clk, rst_n;
    logic valid_i;
    logic [WIDTH-1:0] data_a, data_b;
    logic valid_o;
    logic [WIDTH:0] sum;

    int expected_queue[$];
    int expected;
    int num_tests = 1000;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    registered_adder #(.WIDTH(WIDTH)) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .valid_i (valid_i),
        .data_a  (data_a),
        .data_b  (data_b),
        .valid_o (valid_o),
        .sum     (sum)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------
    // FSDB for Verdi
    // ------------------------------------------------------------
    initial begin
        $fsdbDumpfile("adder.fsdb");
        $fsdbDumpfile("adder.vcd");
        $fsdbDumpvars(0, tb_registered_adder);
    end

    // ============================================================
    // CONSTRAINED RANDOM VERIFICATION
    // ============================================================

    class adder_transaction;

        rand bit [WIDTH-1:0] a;
        rand bit [WIDTH-1:0] b;
        rand bit              valid;

        // Make valid transactions reasonably frequent.
        constraint valid_c {
            valid dist {
                1'b1 := 80,
                1'b0 := 20
            };
        }

        // Bias testing toward interesting boundary values.
        constraint data_c {
            a dist {
                0       := 10,
                1       := 5,
                8'h7F   := 5,
                8'h80   := 5,
                8'hFE   := 5,
                8'hFF   := 10,
                [2:126] := 60
            };

            b dist {
                0       := 10,
                1       := 5,
                8'h7F   := 5,
                8'h80   := 5,
                8'hFE   := 5,
                8'hFF   := 10,
                [2:126] := 60
            };
        }

    endclass

    adder_transaction tr;

    // ============================================================
    // FUNCTIONAL COVERAGE
    // ============================================================

    covergroup adder_cg @(posedge clk);

        cp_valid: coverpoint valid_i {
            bins invalid = {0};
            bins valid   = {1};
        }

        cp_a: coverpoint data_a {
            bins zero = {0};
            bins one  = {1};
            bins low  = {[2:63]};
            bins mid  = {[64:191]};
            bins high = {[192:254]};
            bins max  = {255};
        }

        cp_b: coverpoint data_b {
            bins zero = {0};
            bins one  = {1};
            bins low  = {[2:63]};
            bins mid  = {[64:191]};
            bins high = {[192:254]};
            bins max  = {255};
        }

        // Important arithmetic corner cases
        cp_sum: coverpoint ({1'b0,data_a} + {1'b0,data_b}) {
            bins zero      = {0};
            bins no_carry  = {[1:255]};
            bins carry     = {[256:510]};
        }

        // Cross coverage
        a_b_cross: cross cp_a, cp_b;

    endgroup

    adder_cg cov = new();

    // ============================================================
    // RESET
    // ============================================================

    initial begin
        rst_n   = 0;
        valid_i = 0;
        data_a  = 0;
        data_b  = 0;

        repeat (3) @(posedge clk);
        rst_n = 1;
    end

    // ============================================================
    // SCOREBOARD / RANDOM STIMULUS
    // ============================================================

    initial begin
        wait(rst_n == 1);

        for (int i = 0; i < num_tests; i++) begin

            tr = new();

            if (!tr.randomize()) begin
                $fatal("Randomization failed");
            end

            @(negedge clk);

            valid_i = tr.valid;
            data_a  = tr.a;
            data_b  = tr.b;

            // Store expected result only for valid transaction.
            if (tr.valid) begin
                expected = tr.a + tr.b;
                expected_queue.push_back(expected);
            end
        end

        @(negedge clk);
        valid_i = 0;
        data_a  = 0;
        data_b  = 0;

        repeat (5) @(posedge clk);

        $display("========================================");
        $display("Functional Coverage = %0.2f%%",
                 cov.get_coverage());
        $display("========================================");

        $finish;
    end

    // ============================================================
    // SCOREBOARD
    // ============================================================

    always @(posedge clk) begin

        if (!rst_n) begin
            if (valid_o !== 1'b0)
                $error("valid_o should be 0 during reset");

            if (sum !== '0)
                $error("sum should be 0 during reset");
        end

        else if (valid_o) begin

            if (expected_queue.size() == 0) begin
                $error("Scoreboard queue empty");
            end
            else begin

                expected = expected_queue.pop_front();

                if (sum !== expected) begin
                    $error(
                        "Mismatch: expected=%0d actual=%0d",
                        expected,
                        sum
                    );
                end
                else begin
                    $display(
                        "PASS: expected=%0d actual=%0d",
                        expected,
                        sum
                    );
                end
            end
        end
    end

    // ============================================================
    // SYSTEMVERILOG ASSERTIONS
    // ============================================================

    // valid_o must follow valid_i after the pipeline latency.
    property p_valid_latency;
        @(posedge clk)
        disable iff (!rst_n)
        valid_i |-> ##2 valid_o;
    endproperty

    assert property (p_valid_latency)
        else $error("VALID latency assertion failed");

    // When a valid transaction occurs, output must equal
    // the corresponding input addition after two clock edges.
    property p_addition_correct;
        @(posedge clk)
        disable iff (!rst_n)
        valid_i |-> ##2
            (sum == ($past(data_a,2) + $past(data_b,2)));
    endproperty

    assert property (p_addition_correct)
        else $error("Addition correctness assertion failed");

    // Output must not be valid when the corresponding input
    // transaction was invalid.
    property p_no_spurious_valid;
        @(posedge clk)
        disable iff (!rst_n)
        !valid_i |-> ##2 !valid_o;
    endproperty

    assert property (p_no_spurious_valid)
        else $error("Spurious valid_o detected");

endmodule
