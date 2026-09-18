


module synchronizer (
    input logic clk,  
    input logic rst_n,
    input logic async_signal,
    output logic sync_signal
);

    logic sync_reg1, sync_reg2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg1 <= 1'b0;
            sync_reg2 <= 1'b0;
        end else begin
            sync_reg1 <= async_signal;
            sync_reg2 <= sync_reg1;
        end
    end

    assign sync_signal = sync_reg2;
    
endmodule