module low_power_block (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);

    logic [7:0] reg_data;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            reg_data <= 8'h00;
        else if (en)
            reg_data <= data_in;
    end

    assign data_out = reg_data;

endmodule

