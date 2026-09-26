/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : W-2024.09-SP3
// Date      : Wed Sep 16 19:19:58 2026
/////////////////////////////////////////////////////////////


module low_power_block ( clk, rst_n, en, data_in, data_out );
  input [7:0] data_in;
  output [7:0] data_out;
  input clk, rst_n, en;
  wire   clk_gated, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21,
         n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35,
         n36, n37, n38;

  DLLx1_ASAP7_75t_R u_gated_clk_en_latched_reg ( .CLK(clk), .D(n28), .Q(n27)
         );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_7_ ( .D(n26), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n25) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_6_ ( .D(n24), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n23) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_5_ ( .D(n22), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n21) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_4_ ( .D(n20), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n19) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_3_ ( .D(n18), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n17) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_2_ ( .D(n16), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n15) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_1_ ( .D(n14), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n13) );
  ASYNC_DFFHx1_ASAP7_75t_R reg_data_reg_0_ ( .D(n12), .CLK(clk_gated), .RESET(
        n11), .SET(n29), .QN(n10) );
  TIELOx1_ASAP7_75t_R U31 ( .L(n11) );
  INVxp33_ASAP7_75t_R U32 ( .A(rst_n), .Y(n29) );
  INVxp33_ASAP7_75t_R U33 ( .A(n25), .Y(data_out[7]) );
  INVxp33_ASAP7_75t_R U34 ( .A(n10), .Y(data_out[0]) );
  INVxp33_ASAP7_75t_R U35 ( .A(n13), .Y(data_out[1]) );
  INVxp33_ASAP7_75t_R U36 ( .A(n15), .Y(data_out[2]) );
  INVxp33_ASAP7_75t_R U37 ( .A(n17), .Y(data_out[3]) );
  INVxp33_ASAP7_75t_R U38 ( .A(n19), .Y(data_out[4]) );
  INVxp33_ASAP7_75t_R U39 ( .A(n21), .Y(data_out[5]) );
  INVxp33_ASAP7_75t_R U40 ( .A(n23), .Y(data_out[6]) );
  INVxp33_ASAP7_75t_R U41 ( .A(en), .Y(n28) );
  NAND2xp33_ASAP7_75t_R U42 ( .A(data_in[3]), .B(en), .Y(n30) );
  OAI21xp33_ASAP7_75t_R U43 ( .A1(n17), .A2(en), .B(n30), .Y(n18) );
  NAND2xp33_ASAP7_75t_R U44 ( .A(data_in[6]), .B(en), .Y(n31) );
  OAI21xp33_ASAP7_75t_R U45 ( .A1(n23), .A2(en), .B(n31), .Y(n24) );
  NAND2xp33_ASAP7_75t_R U46 ( .A(data_in[5]), .B(en), .Y(n32) );
  OAI21xp33_ASAP7_75t_R U47 ( .A1(n21), .A2(en), .B(n32), .Y(n22) );
  NAND2xp33_ASAP7_75t_R U48 ( .A(data_in[2]), .B(en), .Y(n33) );
  OAI21xp33_ASAP7_75t_R U49 ( .A1(n15), .A2(en), .B(n33), .Y(n16) );
  NAND2xp33_ASAP7_75t_R U50 ( .A(data_in[7]), .B(en), .Y(n34) );
  OAI21xp33_ASAP7_75t_R U51 ( .A1(n25), .A2(en), .B(n34), .Y(n26) );
  NAND2xp33_ASAP7_75t_R U52 ( .A(data_in[0]), .B(en), .Y(n35) );
  OAI21xp33_ASAP7_75t_R U53 ( .A1(n10), .A2(en), .B(n35), .Y(n12) );
  NAND2xp33_ASAP7_75t_R U54 ( .A(data_in[1]), .B(en), .Y(n36) );
  OAI21xp33_ASAP7_75t_R U55 ( .A1(n13), .A2(en), .B(n36), .Y(n14) );
  NAND2xp33_ASAP7_75t_R U56 ( .A(data_in[4]), .B(en), .Y(n37) );
  OAI21xp33_ASAP7_75t_R U57 ( .A1(n19), .A2(en), .B(n37), .Y(n20) );
  INVxp33_ASAP7_75t_R U58 ( .A(clk), .Y(n38) );
  NOR2xp33_ASAP7_75t_R U59 ( .A(n27), .B(n38), .Y(clk_gated) );
endmodule

