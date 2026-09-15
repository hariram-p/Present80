`timescale 1ns / 1ps

// ============================================================================
// 4-bit S-Box for PRESENT Block Cipher
// ============================================================================
module SUB_encrypt (
    output reg [3:0] output_data, 
    input      [3:0] input_data
);  
    always @(*) begin
        case (input_data)
            4'h0: output_data = 4'hC;
            4'h1: output_data = 4'h5;
            4'h2: output_data = 4'h6;
            4'h3: output_data = 4'hB;
            4'h4: output_data = 4'h9;
            4'h5: output_data = 4'h0;
            4'h6: output_data = 4'hA;
            4'h7: output_data = 4'hD;
            4'h8: output_data = 4'h3;
            4'h9: output_data = 4'hE;
            4'hA: output_data = 4'hF;
            4'hB: output_data = 4'h8;
            4'hC: output_data = 4'h4;
            4'hD: output_data = 4'h7;
            4'hE: output_data = 4'h1;
            4'hF: output_data = 4'h2;
            default: output_data = 4'h0;
        endcase 
    end
endmodule 

// ============================================================================
// 64-bit Permutation Layer
// ============================================================================
module PERM_encrypt (
    output [63:0] output_data, 
    input  [63:0] input_data
);
    assign output_data[0]  = input_data[0];
    assign output_data[16] = input_data[1];
    assign output_data[32] = input_data[2];
    assign output_data[48] = input_data[3];
    assign output_data[1]  = input_data[4];
    assign output_data[17] = input_data[5];
    assign output_data[33] = input_data[6];
    assign output_data[49] = input_data[7];
    assign output_data[2]  = input_data[8];
    assign output_data[18] = input_data[9];
    assign output_data[34] = input_data[10];
    assign output_data[50] = input_data[11];
    assign output_data[3]  = input_data[12];
    assign output_data[19] = input_data[13];
    assign output_data[35] = input_data[14];
    assign output_data[51] = input_data[15];
    assign output_data[4]  = input_data[16];
    assign output_data[20] = input_data[17];
    assign output_data[36] = input_data[18];
    assign output_data[52] = input_data[19];
    assign output_data[5]  = input_data[20];
    assign output_data[21] = input_data[21];
    assign output_data[37] = input_data[22];
    assign output_data[53] = input_data[23];
    assign output_data[6]  = input_data[24];
    assign output_data[22] = input_data[25];
    assign output_data[38] = input_data[26];
    assign output_data[54] = input_data[27];
    assign output_data[7]  = input_data[28];
    assign output_data[23] = input_data[29];
    assign output_data[39] = input_data[30];
    assign output_data[55] = input_data[31];
    assign output_data[8]  = input_data[32];
    assign output_data[24] = input_data[33];
    assign output_data[40] = input_data[34];
    assign output_data[56] = input_data[35];
    assign output_data[9]  = input_data[36];
    assign output_data[25] = input_data[37];
    assign output_data[41] = input_data[38];
    assign output_data[57] = input_data[39];
    assign output_data[10] = input_data[40];
    assign output_data[26] = input_data[41];
    assign output_data[42] = input_data[42];
    assign output_data[58] = input_data[43];
    assign output_data[11] = input_data[44];
    assign output_data[27] = input_data[45];
    assign output_data[43] = input_data[46];
    assign output_data[59] = input_data[47];
    assign output_data[12] = input_data[48];
    assign output_data[28] = input_data[49];
    assign output_data[44] = input_data[50];
    assign output_data[60] = input_data[51];
    assign output_data[13] = input_data[52];
    assign output_data[29] = input_data[53];
    assign output_data[45] = input_data[54];
    assign output_data[61] = input_data[55];
    assign output_data[14] = input_data[56];
    assign output_data[30] = input_data[57];
    assign output_data[46] = input_data[58];
    assign output_data[62] = input_data[59];
    assign output_data[15] = input_data[60];
    assign output_data[31] = input_data[61];
    assign output_data[47] = input_data[62];
    assign output_data[63] = input_data[63];
endmodule

// ============================================================================
// Core PRESENT Encryption Engine (31 Rounds)
// ============================================================================
module encrypt (
    input             clk,
    input             reset,
    input             en,
    input             load,
    input      [63:0] plaintext,
    input      [79:0] key,
    output     [63:0] ciphertext,
    output reg        ready
);
    reg [63:0] data_register;
    reg [79:0] masterkey;
    reg [4:0]  round;

    wire [79:0] next_roundkey;
    wire [63:0] permutation_data;
    wire [63:0] sub_data;

    // 16 S-Boxes processing the 64-bit current state
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sboxes
            SUB_encrypt s_inst (
                .output_data(sub_data[4*i+3 : 4*i]),
                .input_data(ciphertext[4*i+3 : 4*i])
            );
        end
    endgenerate

    PERM_encrypt p1 (
        .output_data(permutation_data),
        .input_data(sub_data)
    );

    // Key schedule updates
    SUB_encrypt key_sub (
        .output_data(next_roundkey[79:76]),
        .input_data(masterkey[18:15])
    );
    assign next_roundkey[14:0]  = masterkey[33:19];               
    assign next_roundkey[19:15] = masterkey[38:34] ^ round;        
    assign next_roundkey[60:20] = masterkey[79:39];
    assign next_roundkey[75:61] = masterkey[14:0];

    // Add round key
    assign ciphertext = data_register ^ masterkey[79:16];

    always @(posedge clk) begin
        if (reset) begin
            data_register <= 64'd0;
            masterkey     <= 80'd0;
            ready         <= 1'b0;
            round         <= 5'd1;
        end else if (en) begin
            if (load) begin
                data_register <= plaintext;
                masterkey     <= key;
                ready         <= 1'b0;
                round         <= 5'd1;
            end else if (!ready) begin
                masterkey     <= next_roundkey;
                data_register <= permutation_data;
                round         <= round + 1'b1;
                if (round == 5'd31) begin
                    ready <= 1'b1;
                end
            end
        end
    end
endmodule

// ============================================================================
// Top-Level Module with Stream Handshake Protocol
// ============================================================================
module top (
    input             clk,
    input             rstn,
    output            i_ready,
    input             i_valid,
    input      [63:0] i_plaintext,

    output            o_valid,
    input             o_ready,
    output reg [63:0] o_ciphertext,
    input             mode // 1: Encryption mode, 0: Pass-through mode
);
    localparam [79:0] CIPHER_KEY = 80'h0000_0000_0000_0001_2345;

    // FSM States
    localparam IDLE      = 2'd0;
    localparam LOAD_CORE = 2'd1;
    localparam COMPUTING = 2'd2;
    localparam HOLD_OUT  = 2'd3;

    reg [1:0]  state;
    reg        enc_load;
    reg [63:0] reg_plaintext;
    wire [63:0] enc_ciphertext;
    wire       enc_done;
    wire       enc_reset = ~rstn;

    // Core Instantiation
    encrypt enc_inst (
        .clk(clk),
        .reset(enc_reset),
        .en(mode),
        .load(enc_load),
        .plaintext(reg_plaintext),
        .key(CIPHER_KEY),
        .ciphertext(enc_ciphertext),
        .ready(enc_done)
    );

    // Dynamic output multiplexing and valid-ready assignments
    assign i_ready = (mode) ? (state == IDLE) : o_ready;
    assign o_valid = (mode) ? (state == HOLD_OUT) : i_valid;

    always @(*) begin
        if (!mode) begin
            o_ciphertext = i_plaintext;
        end else begin
            o_ciphertext = enc_ciphertext;
        end
    end

    // Encryption Control Path FSM
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state         <= IDLE;
            enc_load      <= 1'b0;
            reg_plaintext <= 64'd0;
        end else if (mode) begin
            case (state)
                IDLE: begin
                    enc_load <= 1'b0;
                    if (i_valid) begin
                        reg_plaintext <= i_plaintext;
                        enc_load      <= 1'b1;
                        state         <= COMPUTING;
                    end
                end

                COMPUTING: begin
                    enc_load <= 1'b0;
                    if (enc_done) begin
                        state <= HOLD_OUT;
                    end
                end

                HOLD_OUT: begin
                    if (o_ready) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end else begin
            state    <= IDLE;
            enc_load <= 1'b0;
        end
    end
endmodule