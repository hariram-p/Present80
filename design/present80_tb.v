`timescale 1ns / 1ps

module tb_top;

    reg         clk;
    reg         rstn;
    wire        i_ready;
    reg         i_valid;
    reg  [63:0] i_plaintext;
    wire        o_valid;
    reg         o_ready;
    wire [63:0] o_ciphertext;
    reg         mode;

    // DUT Instantiation
    top dut (
        .clk(clk),
        .rstn(rstn),
        .i_ready(i_ready),
        .i_valid(i_valid),
        .i_plaintext(i_plaintext),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_ciphertext(o_ciphertext),
        .mode(mode)
    );

    // 500 MHz Clock Generation (Period = 2.0 ns)
    always #1.0 clk = ~clk;

    // VCD Dump Directive for PrimePower Activity Analysis
    initial begin
        $dumpfile("sim_activity.vcd");
        $dumpvars(0, tb_top);
    end

    // Task for streaming data to DUT
    task send_block(input [63:0] data, input op_mode);
        begin
            @(posedge clk);
            mode        <= op_mode;
            i_plaintext <= data;
            i_valid     <= 1'b1;
            
            // Wait for handshake
            wait (i_ready == 1'b1);
            @(posedge clk);
            i_valid     <= 1'b0;

            // Wait for completion
            wait (o_valid == 1'b1);
            $display("[T=%0t ns] Output Valid! Data = 0x%016h (Mode=%0b)", $time, o_ciphertext, op_mode);
            @(posedge clk);
        end
    endtask

    // Main Test Stimulus
    initial begin
        clk         = 0;
        rstn        = 0;
        i_valid     = 0;
        o_ready     = 1;
        i_plaintext = 64'd0;
        mode        = 1;

        // Reset Pulse
        #10;
        rstn = 1;
        #10;

        $display("-------------------------------------------------------");
        $display("Starting PRESENT Encryption & Pass-through Tests...");
        $display("-------------------------------------------------------");

        // Test 1: Encryption Mode
        send_block(64'h0000000000000000, 1'b1);
        send_block(64'hFFFFFFFFFFFFFFFF, 1'b1);
        send_block(64'h0123456789ABCDEF, 1'b1);

        // Test 2: Pass-Through Mode
        send_block(64'hA5A5A5A55A5A5A5A, 1'b0);
        send_block(64'h1122334455667788, 1'b0);

        #50;
        $display("-------------------------------------------------------");
        $display("All test vectors processed. Simulation complete.");
        $display("-------------------------------------------------------");
        $finish;
    end

endmodule