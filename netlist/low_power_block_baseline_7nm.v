/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : W-2024.09-SP3
// Date      : Tue Sep 15 23:49:57 2026
/////////////////////////////////////////////////////////////


module low_power_block ( clk, rst_n, en, data_in, data_out );
  input [7:0] data_in;
  output [7:0] data_out;
  input clk, rst_n, en;
  wire   n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
         n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36;

  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_7_ ( .D(n26), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n25) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_6_ ( .D(n24), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n23) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_5_ ( .D(n22), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n21) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_4_ ( .D(n20), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n19) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_3_ ( .D(n18), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n17) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_2_ ( .D(n16), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n15) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_1_ ( .D(n14), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n13) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_0_ ( .D(n12), .CLK(clk), .RESET(n11), 
        .SET(n27), .QN(n10) );
  TIELOx1_ASAP7_75t_R U29 ( .L(n11) );
  INVxp33_ASAP7_75t_R U30 ( .A(rst_n), .Y(n27) );
  NAND2xp33_ASAP7_75t_R U31 ( .A(data_in[4]), .B(en), .Y(n28) );
  OAI21xp33_ASAP7_75t_R U32 ( .A1(n19), .A2(en), .B(n28), .Y(n20) );
  NAND2xp33_ASAP7_75t_R U33 ( .A(data_in[3]), .B(en), .Y(n29) );
  OAI21xp33_ASAP7_75t_R U34 ( .A1(n17), .A2(en), .B(n29), .Y(n18) );
  NAND2xp33_ASAP7_75t_R U35 ( .A(data_in[5]), .B(en), .Y(n30) );
  OAI21xp33_ASAP7_75t_R U36 ( .A1(n21), .A2(en), .B(n30), .Y(n22) );
  NAND2xp33_ASAP7_75t_R U37 ( .A(data_in[2]), .B(en), .Y(n31) );
  OAI21xp33_ASAP7_75t_R U38 ( .A1(n15), .A2(en), .B(n31), .Y(n16) );
  NAND2xp33_ASAP7_75t_R U39 ( .A(data_in[6]), .B(en), .Y(n32) );
  OAI21xp33_ASAP7_75t_R U40 ( .A1(n23), .A2(en), .B(n32), .Y(n24) );
  NAND2xp33_ASAP7_75t_R U41 ( .A(data_in[1]), .B(en), .Y(n33) );
  OAI21xp33_ASAP7_75t_R U42 ( .A1(n13), .A2(en), .B(n33), .Y(n14) );
  NAND2xp33_ASAP7_75t_R U43 ( .A(data_in[0]), .B(en), .Y(n34) );
  OAI21xp33_ASAP7_75t_R U44 ( .A1(n10), .A2(en), .B(n34), .Y(n12) );
  NAND2xp33_ASAP7_75t_R U45 ( .A(data_in[7]), .B(en), .Y(n35) );
  OAI21xp33_ASAP7_75t_R U46 ( .A1(n25), .A2(en), .B(n35), .Y(n26) );
  INVxp33_ASAP7_75t_R U47 ( .A(en), .Y(n36) );
  NOR2xp33_ASAP7_75t_R U48 ( .A(n10), .B(n36), .Y(data_out[0]) );
  NOR2xp33_ASAP7_75t_R U49 ( .A(n13), .B(n36), .Y(data_out[1]) );
  NOR2xp33_ASAP7_75t_R U50 ( .A(n15), .B(n36), .Y(data_out[2]) );
  NOR2xp33_ASAP7_75t_R U51 ( .A(n17), .B(n36), .Y(data_out[3]) );
  NOR2xp33_ASAP7_75t_R U52 ( .A(n19), .B(n36), .Y(data_out[4]) );
  NOR2xp33_ASAP7_75t_R U53 ( .A(n21), .B(n36), .Y(data_out[5]) );
  NOR2xp33_ASAP7_75t_R U54 ( .A(n23), .B(n36), .Y(data_out[6]) );
  NOR2xp33_ASAP7_75t_R U55 ( .A(n25), .B(n36), .Y(data_out[7]) );
endmodule

