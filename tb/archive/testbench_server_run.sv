`timescale 1ns/1ps

import uvm_pkg::*;
import UPF::*;
`include "uvm_macros.svh"

interface lp_if(input logic clk);
    logic rst_n;
    logic en;
    logic [7:0] data_in;
    logic [7:0] data_out;
endinterface

class lp_seq_item extends uvm_sequence_item;

	rand logic       en;
	rand logic [7:0] data_in;

	logic            rst_n;
	logic [7:0]      data_out;

	`uvm_object_param_utils_begin(lp_seq_item)
		`uvm_field_int(rst_n, UVM_DEFAULT)
		`uvm_field_int(en, UVM_DEFAULT)
		`uvm_field_int(data_in, UVM_DEFAULT)
		`uvm_field_int(data_out, UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "lp_seq_item");
		super.new(name);
	endfunction

endclass

class lp_active_sequence extends uvm_sequence #(lp_seq_item);

    `uvm_object_utils(lp_active_sequence)

    function new(string name = "lp_active_sequence");
        super.new(name);
    endfunction

    task body();
        repeat (10) begin
            lp_seq_item tx;

            tx = lp_seq_item::type_id::create("tx");

            start_item(tx);

            if (!tx.randomize() with { en == 1'b1; })
                `uvm_fatal("ACTIVE_SEQ", "Transaction randomization failed")

            finish_item(tx);
        end
    endtask

endclass


class lp_idle_sequence extends uvm_sequence #(lp_seq_item);

    `uvm_object_utils(lp_idle_sequence)

    function new(string name = "lp_idle_sequence");
        super.new(name);
    endfunction

    task body();
        repeat (20) begin
            lp_seq_item tx;

            tx = lp_seq_item::type_id::create("tx");

            start_item(tx);

            if (!tx.randomize() with { en == 1'b0; })
                `uvm_fatal("IDLE_SEQ", "Transaction randomization failed")

            finish_item(tx);
        end
    endtask

endclass


/// clock gated sequence
class lp_clock_gating_sequence extends uvm_sequence #(lp_seq_item);

    `uvm_object_utils(lp_clock_gating_sequence)

    function new(string name = "lp_clock_gating_sequence");
        super.new(name);
    endfunction

    task body();
        lp_seq_item tx;
	
	repeat (10) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            if (!tx.randomize() with { en == 1'b0; })
                `uvm_fatal("SEQ", "Transaction randomization failed")
            finish_item(tx);
        end

        repeat (10) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            if (!tx.randomize() with { en == 1'b1; })
                `uvm_fatal("SEQ", "Transaction randomization failed")
            finish_item(tx);
        end

        repeat (20) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            if (!tx.randomize() with { en == 1'b0; })
                `uvm_fatal("SEQ", "Transaction randomization failed")
            finish_item(tx);
        end

        repeat (10) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            if (!tx.randomize() with { en == 1'b1; })
                `uvm_fatal("SEQ", "Transaction randomization failed")
            finish_item(tx);
        end

        repeat (10) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            if (!tx.randomize() with { en == 1'b0; })
                `uvm_fatal("SEQ", "Transaction randomization failed")
            finish_item(tx);
        end
    endtask

endclass


/// kind of stress sequence for the design
class lp_dff_stress_sequence extends uvm_sequence #(lp_seq_item);

    `uvm_object_utils(lp_dff_stress_sequence)

    function new(string name = "lp_dff_stress_sequence");
        super.new(name);
    endfunction

    task body();
        lp_seq_item tx;

	// Enable the DFF and force large data transitions.
        for (int i = 0; i < 8; i++) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            tx.en = 1'b1;
            tx.data_in = (i % 2 == 0) ? 8'h00 : 8'hFF;
            finish_item(tx);
        end

        // Disable the DFF while data_in continues toggling. data_out must retain the last captured value.
        for (int i = 0; i < 8; i++) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            tx.en = 1'b0;
            tx.data_in = (i % 2 == 0) ? 8'hAA : 8'h55;
            finish_item(tx);
        end

        // Alternate enabled and disabled cycles.
        for (int i = 0; i < 16; i++) begin
            tx = lp_seq_item::type_id::create("tx");
            start_item(tx);
            tx.en = (i % 2 == 0) ? 1'b0 : 1'b1;
            tx.data_in = 8'hA5 ^ i;
            finish_item(tx);
        end
    endtask

endclass



class lp_sequencer extends uvm_sequencer #(lp_seq_item);

	`uvm_component_utils(lp_sequencer)

	function new(string name = "lp_sequencer", uvm_component parent = null);
		super.new(name,parent);
	endfunction

endclass

class lp_driver extends uvm_driver#(lp_seq_item);
    
	`uvm_component_utils(lp_driver)
	virtual lp_if vif;

	function new(string name = "lp_driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual lp_if)::get(this,"","vif",vif)) begin
			`uvm_fatal(get_type_name(),"failed to get the virtual interface from config db")
		end
	endfunction

	task run_phase(uvm_phase phase);
	lp_seq_item tx;

	// waiting here until reset is released.
	wait (vif.rst_n === 1'b1);

	forever begin
		seq_item_port.get_next_item(tx);

		@(negedge vif.clk);
		vif.en      <= tx.en;
		vif.data_in <= tx.data_in;

		seq_item_port.item_done();
	end
endtask

endclass

class lp_monitor extends uvm_monitor;
   
	`uvm_component_utils(lp_monitor)	

	virtual lp_if vif;
    uvm_analysis_port#(lp_seq_item) ap;

	function new(string name = "lp_monitor", uvm_component parent = null);
		super.new(name,parent);
		ap = new("ap",this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual lp_if)::get(this,"","vif",vif)) begin
			`uvm_fatal(get_type_name(),"failed to get the virtual interface from config db")
		end
	endfunction

	task run_phase(uvm_phase phase);
		lp_seq_item tx;

		forever begin
			@(posedge vif.clk);

			// wait for some time t sample after DUT's NB assignment
			#1step;

			tx = lp_seq_item::type_id::create("tx");

			tx.rst_n    = vif.rst_n;
			tx.en       = vif.en;
			tx.data_in  = vif.data_in;
			tx.data_out = vif.data_out;

			ap.write(tx);
		end
	endtask
endclass


class lp_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(lp_scoreboard)

    uvm_analysis_imp #(lp_seq_item, lp_scoreboard) ap;

    logic [7:0] expected_data;
    logic [7:0] expected_queue[$];

    function new(string name = "lp_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
        expected_data = 8'h00;
    endfunction

    function void write(lp_seq_item tx);
        logic [7:0] expected_output;

        if (!tx.rst_n) begin
            expected_data = 8'h00;
            expected_queue.delete();
        end
        else if (tx.en) begin
            expected_data = tx.data_in;
        end

        expected_queue.push_back(expected_data);

        if (expected_queue.size() == 0) begin
            `uvm_error("SCOREBOARD", "Expected queue is empty")
            return;
        end

        expected_output = expected_queue.pop_front();

        if (tx.data_out !== expected_output) begin
            `uvm_error("SCOREBOARD", $sformatf("Mismatch: en=%0b data_in=%02h data_out=%02h expected=%02h", tx.en, tx.data_in, tx.data_out, expected_output))
        end
        else begin
            `uvm_info("SCOREBOARD", $sformatf("Match: data_out=%02h expected=%02h", tx.data_out, expected_output), UVM_LOW)
        end
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        if (expected_queue.size() != 0) begin
            `uvm_error("SCOREBOARD", $sformatf("%0d expected values remain in the queue", expected_queue.size()))
        end
    endfunction

endclass


class lp_agent extends uvm_agent;

	`uvm_component_utils(lp_agent)

	// define the design blocks of the design
	lp_sequencer sqr;
	lp_driver drv;
	lp_monitor mon;

	uvm_analysis_port #(lp_seq_item) analysis_port;

	function new(input string name = "lp_agent", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon = lp_monitor::type_id::create("mon",this);
		sqr = lp_sequencer::type_id::create("sqr",this);
		drv = lp_driver::type_id::create("drv",this);
		analysis_port = new("analysis_port", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(sqr.seq_item_export);
		mon.ap.connect(analysis_port);
	endfunction

endclass


class lp_env extends uvm_env;

	`uvm_component_utils(lp_env)

	lp_agent agnt;
	lp_scoreboard scrbd;

	function new(input string name = "lp_env", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agnt = lp_agent::type_id::create("agnt",this);
		scrbd = lp_scoreboard::type_id::create("scrbd",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agnt.analysis_port.connect(scrbd.ap);
	endfunction

endclass


class lp_test extends uvm_test;

	`uvm_component_utils(lp_test)

	lp_env env;

	function new(input string name = "lp_test",uvm_component parent = null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = lp_env::type_id::create("env",this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		lp_active_sequence active_seq;
		lp_idle_sequence idle_seq;
		lp_clock_gating_sequence gating_seq;
		lp_dff_stress_sequence stress_seq;

		phase.raise_objection(this, "Starting low-power block sequences");

			//active_seq = lp_active_sequence::type_id::create("active_seq");
			//active_seq.start(env.agnt.sqr);

			//idle_seq = lp_idle_sequence::type_id::create("idle_seq");
			//idle_seq.start(env.agnt.sqr);

			//gating_seq = lp_clock_gating_sequence::type_id::create("gating_seq");
			//gating_seq.start(env.agnt.sqr);

			stress_seq = lp_dff_stress_sequence::type_id::create("stress_seq");
			stress_seq.start(env.agnt.sqr);

			repeat (2) @(posedge env.agnt.drv.vif.clk);

		phase.drop_objection(this, "Completed low-power block sequences");
	endtask

endclass


module top_tb;
    logic clk;
    lp_if intf(clk);

    initial clk = 1'b0;
    always #5 clk = ~clk;

// for upf check
	bit vdd_status;
	bit vss_status;

    low_power_block dut (
        .clk(clk),
        .rst_n(intf.rst_n),
        .en(intf.en),
        .data_in(intf.data_in),
        .data_out(intf.data_out)
    );


	initial begin
        	intf.rst_n = 1'b0;
		intf.en = 1'b0;
		intf.data_in = 8'h00;

		vdd_status = supply_on("VDD",1.0);
		vss_status = supply_on("VSS",0.0);

		if (!vdd_status)
        		$fatal(1, "Failed to turn on UPF supply port VDD");

		if (!vss_status)
        		$fatal(1, "Failed to turn on UPF supply port VSS");

    		repeat (2) @(posedge clk);
    		intf.rst_n <= 1'b1;
    	end

/*
	initial begin
        	intf.rst_n   = 1'b0;
        	intf.en      = 1'b0;
        	intf.data_in = 8'h00;

	        repeat (2) @(posedge clk);
        	intf.rst_n <= 1'b1;
    	end
*/
    initial begin
		uvm_config_db #(virtual lp_if)::set(null,"uvm_test_top.env.agnt.*","vif",intf);
        run_test("lp_test");
    end
endmodule
