`timescale 1ns/1ps

/// clock gating
module gated_clk (
    input  logic clk_i,
    input  logic en_i,

    output logic clk_gated_o
);

    logic en_latched;

    always_latch begin
        if (!clk_i) begin
            en_latched <= en_i;
        end
    end

	assign clk_gated_o = clk_i & en_latched;

endmodule


module low_power_block(
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);
    logic [7:0] reg_data;
	logic		clk_gated;

	gated_clk u_gated_clk (
		.clk_i(clk),
		.en_i(en),
		.clk_gated_o(clk_gated)
	);


    always_ff @(posedge clk_gated or negedge rst_n) begin
        if (!rst_n)
            reg_data <= 0;
        else if (en)
            reg_data <= data_in;
    end

    assign data_out = reg_data;
endmodule
