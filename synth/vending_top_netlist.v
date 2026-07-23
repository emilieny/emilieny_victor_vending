/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : X-2025.06-SP2
// Date      : Thu Jul 23 17:17:09 2026
/////////////////////////////////////////////////////////////


module control_unit ( clk, rst, coin_insert, buy_req, cancel_req, can_sell, 
        credit_load, mem_read, mem_write, dispense, change_valid, error, 
        current_state );
  output [2:0] current_state;
  input clk, rst, coin_insert, buy_req, cancel_req, can_sell;
  output credit_load, mem_read, mem_write, dispense, change_valid, error;
  wire   mem_write, n20, n21, n22, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
         n11, n12, n13, n14, n15;
  assign dispense = mem_write;

  DFFX1_RVT \state_reg[0]  ( .D(n22), .CLK(clk), .Q(current_state[0]), .QN(n14) );
  DFFX1_RVT \state_reg[2]  ( .D(n20), .CLK(clk), .Q(current_state[2]), .QN(n13) );
  DFFX1_RVT \state_reg[1]  ( .D(n21), .CLK(clk), .Q(current_state[1]), .QN(n15) );
  INVX1_RVT U3 ( .A(cancel_req), .Y(n6) );
  AND4X1_RVT U4 ( .A1(current_state[0]), .A2(current_state[2]), .A3(n6), .A4(
        n15), .Y(error) );
  INVX0_RVT U5 ( .A(rst), .Y(n12) );
  NAND3X0_RVT U6 ( .A1(n12), .A2(n6), .A3(n13), .Y(n10) );
  INVX0_RVT U7 ( .A(n10), .Y(n7) );
  NAND2X0_RVT U8 ( .A1(n7), .A2(n15), .Y(n1) );
  AO221X1_RVT U9 ( .A1(current_state[0]), .A2(buy_req), .A3(n14), .A4(
        coin_insert), .A5(n1), .Y(n9) );
  NAND2X0_RVT U10 ( .A1(n14), .A2(n9), .Y(n3) );
  NAND2X0_RVT U11 ( .A1(error), .A2(n12), .Y(n2) );
  OAI221X1_RVT U12 ( .A1(n3), .A2(n10), .A3(n14), .A4(n9), .A5(n2), .Y(n22) );
  AND4X1_RVT U13 ( .A1(current_state[0]), .A2(current_state[1]), .A3(n13), 
        .A4(n6), .Y(mem_write) );
  AND2X1_RVT U14 ( .A1(n6), .A2(n15), .Y(n4) );
  OA221X1_RVT U15 ( .A1(current_state[2]), .A2(coin_insert), .A3(n13), .A4(n14), .A5(n4), .Y(credit_load) );
  NAND3X0_RVT U16 ( .A1(n15), .A2(current_state[2]), .A3(n14), .Y(n5) );
  NAND2X0_RVT U17 ( .A1(n6), .A2(n5), .Y(change_valid) );
  OA221X1_RVT U18 ( .A1(n15), .A2(can_sell), .A3(n15), .A4(n14), .A5(n7), .Y(
        n8) );
  OA221X1_RVT U19 ( .A1(current_state[1]), .A2(current_state[0]), .A3(
        current_state[1]), .A4(n9), .A5(n8), .Y(n21) );
  NOR3X0_RVT U20 ( .A1(can_sell), .A2(n15), .A3(n10), .Y(n11) );
  AO221X1_RVT U21 ( .A1(n12), .A2(error), .A3(n12), .A4(mem_write), .A5(n11), 
        .Y(n20) );
endmodule


module credit_reg ( clk, rst, cancel, credit_load, current_state, coin_in, 
        credit );
  input [2:0] current_state;
  input [1:0] coin_in;
  output [7:0] credit;
  input clk, rst, cancel, credit_load;
  wire   n7, n8, n9, n10, n11, n12, n13, n14, \intadd_0/B[1] , \intadd_0/B[0] ,
         \intadd_0/CI , \intadd_0/SUM[2] , \intadd_0/SUM[1] ,
         \intadd_0/SUM[0] , \intadd_0/n3 , \intadd_0/n2 , \intadd_0/n1 , n1,
         n2, n3, n4, n5, n6, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30;

  DFFX1_RVT \credit_reg[7]  ( .D(n7), .CLK(clk), .Q(credit[7]) );
  DFFX1_RVT \credit_reg[6]  ( .D(n8), .CLK(clk), .Q(credit[6]), .QN(n30) );
  DFFX1_RVT \credit_reg[5]  ( .D(n9), .CLK(clk), .Q(credit[5]) );
  DFFX1_RVT \credit_reg[4]  ( .D(n10), .CLK(clk), .Q(credit[4]) );
  DFFX1_RVT \credit_reg[3]  ( .D(n11), .CLK(clk), .Q(credit[3]) );
  DFFX1_RVT \credit_reg[2]  ( .D(n12), .CLK(clk), .Q(credit[2]) );
  DFFX1_RVT \credit_reg[1]  ( .D(n13), .CLK(clk), .Q(credit[1]) );
  DFFX1_RVT \credit_reg[0]  ( .D(n14), .CLK(clk), .Q(credit[0]) );
  FADDX1_RVT \intadd_0/U4  ( .A(\intadd_0/B[0] ), .B(credit[3]), .CI(
        \intadd_0/CI ), .CO(\intadd_0/n3 ), .S(\intadd_0/SUM[0] ) );
  FADDX1_RVT \intadd_0/U3  ( .A(\intadd_0/B[1] ), .B(credit[4]), .CI(
        \intadd_0/n3 ), .CO(\intadd_0/n2 ), .S(\intadd_0/SUM[1] ) );
  FADDX1_RVT \intadd_0/U2  ( .A(coin_in[1]), .B(credit[5]), .CI(\intadd_0/n2 ), 
        .CO(\intadd_0/n1 ), .S(\intadd_0/SUM[2] ) );
  INVX0_RVT U3 ( .A(coin_in[0]), .Y(n19) );
  OR2X1_RVT U4 ( .A1(n19), .A2(coin_in[1]), .Y(n21) );
  INVX0_RVT U5 ( .A(n21), .Y(\intadd_0/B[0] ) );
  NAND2X0_RVT U6 ( .A1(coin_in[1]), .A2(coin_in[0]), .Y(n22) );
  AO22X1_RVT U7 ( .A1(coin_in[1]), .A2(n19), .A3(\intadd_0/B[0] ), .A4(
        credit[0]), .Y(n6) );
  NAND2X0_RVT U8 ( .A1(n6), .A2(credit[1]), .Y(n5) );
  NAND2X0_RVT U9 ( .A1(n22), .A2(n5), .Y(n17) );
  NAND2X0_RVT U10 ( .A1(credit[2]), .A2(n17), .Y(n16) );
  INVX0_RVT U11 ( .A(n16), .Y(\intadd_0/CI ) );
  INVX0_RVT U12 ( .A(current_state[1]), .Y(n1) );
  NAND2X0_RVT U13 ( .A1(credit_load), .A2(n1), .Y(n3) );
  NOR2X0_RVT U14 ( .A1(rst), .A2(cancel), .Y(n2) );
  OA221X1_RVT U15 ( .A1(n3), .A2(current_state[2]), .A3(n3), .A4(
        current_state[0]), .A5(n2), .Y(n29) );
  HADDX1_RVT U16 ( .A0(credit[0]), .B0(\intadd_0/B[0] ), .SO(n4) );
  NOR4X1_RVT U17 ( .A1(rst), .A2(current_state[2]), .A3(cancel), .A4(n3), .Y(
        n27) );
  AO22X1_RVT U18 ( .A1(credit[0]), .A2(n29), .A3(n4), .A4(n27), .Y(n14) );
  OA21X1_RVT U19 ( .A1(n6), .A2(credit[1]), .A3(n5), .Y(n15) );
  AO22X1_RVT U20 ( .A1(n27), .A2(n15), .A3(credit[1]), .A4(n29), .Y(n13) );
  OA21X1_RVT U21 ( .A1(credit[2]), .A2(n17), .A3(n16), .Y(n18) );
  AO22X1_RVT U22 ( .A1(n27), .A2(n18), .A3(credit[2]), .A4(n29), .Y(n12) );
  AO22X1_RVT U23 ( .A1(n27), .A2(\intadd_0/SUM[0] ), .A3(n29), .A4(credit[3]), 
        .Y(n11) );
  NAND2X0_RVT U24 ( .A1(coin_in[1]), .A2(n19), .Y(n20) );
  NAND2X0_RVT U25 ( .A1(n21), .A2(n20), .Y(\intadd_0/B[1] ) );
  AO22X1_RVT U26 ( .A1(n27), .A2(\intadd_0/SUM[1] ), .A3(n29), .A4(credit[4]), 
        .Y(n10) );
  AO22X1_RVT U27 ( .A1(n27), .A2(\intadd_0/SUM[2] ), .A3(n29), .A4(credit[5]), 
        .Y(n9) );
  INVX0_RVT U28 ( .A(n22), .Y(n25) );
  AO22X1_RVT U29 ( .A1(n25), .A2(n30), .A3(n22), .A4(credit[6]), .Y(n23) );
  HADDX1_RVT U30 ( .A0(\intadd_0/n1 ), .B0(n23), .SO(n24) );
  AO22X1_RVT U31 ( .A1(n27), .A2(n24), .A3(n29), .A4(credit[6]), .Y(n8) );
  AO222X1_RVT U32 ( .A1(n25), .A2(credit[6]), .A3(n25), .A4(\intadd_0/n1 ), 
        .A5(credit[6]), .A6(\intadd_0/n1 ), .Y(n26) );
  HADDX1_RVT U33 ( .A0(credit[7]), .B0(n26), .SO(n28) );
  AO22X1_RVT U34 ( .A1(credit[7]), .A2(n29), .A3(n28), .A4(n27), .Y(n7) );
endmodule


module memory ( clk, rst, item_sel, mem_read, mem_write, price, stock );
  input [1:0] item_sel;
  output [7:0] price;
  output [7:0] stock;
  input clk, rst, mem_read, mem_write;
  wire   \mem_array[0][4] , \mem_array[0][3] , \mem_array[0][2] ,
         \mem_array[0][1] , \mem_array[0][0] , \mem_array[1][4] ,
         \mem_array[1][3] , \mem_array[1][2] , \mem_array[1][1] ,
         \mem_array[1][0] , \mem_array[2][4] , \mem_array[2][3] ,
         \mem_array[2][2] , \mem_array[2][1] , \mem_array[2][0] ,
         \mem_array[3][4] , \mem_array[3][3] , \mem_array[3][2] ,
         \mem_array[3][1] , \mem_array[3][0] , n27, n28, n29, n30, n34, n35,
         n36, n37, n38, n42, n43, n44, n45, n46, n50, n51, n52, n53, n54, n55,
         n47, \sub_x_2/A[5] , \sub_x_2/A[4] , \sub_x_2/A[3] , \sub_x_2/A[2] ,
         \sub_x_2/A[1] , \sub_x_2/A[0] , n1, n2, n3, n4, n5, n6, n7, n8, n9,
         n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
         n24, n25, n26, n31, n32, n33, n39, n40, n41;
  assign price[6] = item_sel[1];
  assign price[5] = item_sel[0];
  assign stock[5] = \sub_x_2/A[5] ;
  assign stock[4] = \sub_x_2/A[4] ;
  assign stock[3] = \sub_x_2/A[3] ;
  assign stock[2] = \sub_x_2/A[2] ;
  assign stock[1] = \sub_x_2/A[1] ;
  assign stock[0] = \sub_x_2/A[0] ;

  DFFX1_RVT \mem_array_reg[3][0]  ( .D(n55), .CLK(clk), .Q(\mem_array[3][0] )
         );
  DFFX1_RVT \mem_array_reg[3][1]  ( .D(n53), .CLK(clk), .Q(\mem_array[3][1] )
         );
  DFFX1_RVT \mem_array_reg[3][2]  ( .D(n52), .CLK(clk), .Q(\mem_array[3][2] )
         );
  DFFX1_RVT \mem_array_reg[3][3]  ( .D(n51), .CLK(clk), .Q(\mem_array[3][3] )
         );
  DFFX1_RVT \mem_array_reg[3][4]  ( .D(n50), .CLK(clk), .Q(\mem_array[3][4] )
         );
  DFFX1_RVT \mem_array_reg[2][0]  ( .D(n46), .CLK(clk), .Q(\mem_array[2][0] )
         );
  DFFX1_RVT \mem_array_reg[2][1]  ( .D(n45), .CLK(clk), .Q(\mem_array[2][1] )
         );
  DFFX1_RVT \mem_array_reg[2][2]  ( .D(n44), .CLK(clk), .Q(\mem_array[2][2] )
         );
  DFFX1_RVT \mem_array_reg[2][3]  ( .D(n43), .CLK(clk), .Q(\mem_array[2][3] )
         );
  DFFX1_RVT \mem_array_reg[2][4]  ( .D(n42), .CLK(clk), .Q(\mem_array[2][4] )
         );
  DFFX1_RVT \mem_array_reg[1][0]  ( .D(n38), .CLK(clk), .Q(\mem_array[1][0] )
         );
  DFFX1_RVT \mem_array_reg[1][2]  ( .D(n36), .CLK(clk), .Q(\mem_array[1][2] )
         );
  DFFX1_RVT \mem_array_reg[1][1]  ( .D(n37), .CLK(clk), .Q(\mem_array[1][1] )
         );
  DFFX1_RVT \mem_array_reg[1][3]  ( .D(n35), .CLK(clk), .Q(\mem_array[1][3] )
         );
  DFFX1_RVT \mem_array_reg[1][4]  ( .D(n34), .CLK(clk), .Q(\mem_array[1][4] )
         );
  DFFX1_RVT \mem_array_reg[0][0]  ( .D(n30), .CLK(clk), .Q(\mem_array[0][0] )
         );
  DFFX1_RVT \mem_array_reg[0][2]  ( .D(n54), .CLK(clk), .Q(\mem_array[0][2] )
         );
  DFFX1_RVT \mem_array_reg[0][1]  ( .D(n29), .CLK(clk), .Q(\mem_array[0][1] )
         );
  DFFX1_RVT \mem_array_reg[0][3]  ( .D(n28), .CLK(clk), .Q(\mem_array[0][3] )
         );
  DFFX1_RVT \mem_array_reg[0][4]  ( .D(n27), .CLK(clk), .Q(\mem_array[0][4] )
         );
  INVX2_RVT U7 ( .A(item_sel[1]), .Y(n47) );
  INVX2_RVT U8 ( .A(item_sel[0]), .Y(price[0]) );
  MUX41X1_RVT U9 ( .A1(\mem_array[3][1] ), .A3(\mem_array[1][1] ), .A2(
        \mem_array[2][1] ), .A4(\mem_array[0][1] ), .S0(n47), .S1(price[0]), 
        .Y(\sub_x_2/A[1] ) );
  MUX41X1_RVT U10 ( .A1(\mem_array[3][0] ), .A3(\mem_array[1][0] ), .A2(
        \mem_array[2][0] ), .A4(\mem_array[0][0] ), .S0(n47), .S1(price[0]), 
        .Y(\sub_x_2/A[0] ) );
  MUX41X1_RVT U11 ( .A1(1'b0), .A3(1'b0), .A2(1'b0), .A4(1'b0), .S0(n47), .S1(
        item_sel[0]), .Y(\sub_x_2/A[5] ) );
  MUX41X1_RVT U12 ( .A1(\mem_array[3][4] ), .A3(\mem_array[1][4] ), .A2(
        \mem_array[2][4] ), .A4(\mem_array[0][4] ), .S0(n47), .S1(price[0]), 
        .Y(\sub_x_2/A[4] ) );
  NAND2X0_RVT U13 ( .A1(item_sel[1]), .A2(item_sel[0]), .Y(n2) );
  INVX0_RVT U14 ( .A(n2), .Y(price[2]) );
  MUX41X1_RVT U15 ( .A1(\mem_array[2][2] ), .A3(\mem_array[0][2] ), .A2(
        \mem_array[3][2] ), .A4(\mem_array[1][2] ), .S0(n47), .S1(item_sel[0]), 
        .Y(\sub_x_2/A[2] ) );
  MUX41X1_RVT U16 ( .A1(\mem_array[2][3] ), .A3(\mem_array[0][3] ), .A2(
        \mem_array[3][3] ), .A4(\mem_array[1][3] ), .S0(n47), .S1(item_sel[0]), 
        .Y(\sub_x_2/A[3] ) );
  NAND2X0_RVT U17 ( .A1(item_sel[0]), .A2(n47), .Y(n20) );
  NAND2X0_RVT U18 ( .A1(item_sel[1]), .A2(price[0]), .Y(n15) );
  NAND2X0_RVT U19 ( .A1(n20), .A2(n15), .Y(price[1]) );
  INVX0_RVT U20 ( .A(\sub_x_2/A[4] ), .Y(n11) );
  NOR4X1_RVT U21 ( .A1(\sub_x_2/A[3] ), .A2(\sub_x_2/A[2] ), .A3(
        \sub_x_2/A[1] ), .A4(\sub_x_2/A[0] ), .Y(n10) );
  NAND2X0_RVT U22 ( .A1(n11), .A2(n10), .Y(n12) );
  OR2X1_RVT U23 ( .A1(\sub_x_2/A[5] ), .A2(n12), .Y(n1) );
  NAND2X0_RVT U24 ( .A1(n1), .A2(mem_write), .Y(n19) );
  INVX0_RVT U25 ( .A(rst), .Y(n31) );
  OA21X1_RVT U26 ( .A1(n2), .A2(n19), .A3(n31), .Y(n14) );
  INVX0_RVT U27 ( .A(\sub_x_2/A[0] ), .Y(n5) );
  INVX0_RVT U28 ( .A(n14), .Y(n7) );
  AND2X1_RVT U29 ( .A1(n31), .A2(n7), .Y(n13) );
  AO22X1_RVT U30 ( .A1(\mem_array[3][0] ), .A2(n14), .A3(n5), .A4(n13), .Y(n55) );
  OR3X1_RVT U31 ( .A1(\sub_x_2/A[2] ), .A2(\sub_x_2/A[1] ), .A3(\sub_x_2/A[0] ), .Y(n8) );
  INVX0_RVT U32 ( .A(n8), .Y(n3) );
  AO221X1_RVT U33 ( .A1(\sub_x_2/A[2] ), .A2(\sub_x_2/A[1] ), .A3(
        \sub_x_2/A[2] ), .A4(\sub_x_2/A[0] ), .A5(n3), .Y(n22) );
  NAND2X0_RVT U34 ( .A1(n47), .A2(price[0]), .Y(n4) );
  OA21X1_RVT U35 ( .A1(n4), .A2(n19), .A3(n31), .Y(n41) );
  INVX0_RVT U36 ( .A(n41), .Y(n26) );
  AO221X1_RVT U37 ( .A1(n22), .A2(n26), .A3(n41), .A4(\mem_array[0][2] ), .A5(
        rst), .Y(n54) );
  INVX0_RVT U38 ( .A(\sub_x_2/A[1] ), .Y(n6) );
  AO22X1_RVT U39 ( .A1(n6), .A2(n5), .A3(\sub_x_2/A[1] ), .A4(\sub_x_2/A[0] ), 
        .Y(n32) );
  AO221X1_RVT U40 ( .A1(n32), .A2(n7), .A3(n14), .A4(\mem_array[3][1] ), .A5(
        rst), .Y(n53) );
  AO22X1_RVT U41 ( .A1(\mem_array[3][2] ), .A2(n14), .A3(n13), .A4(n22), .Y(
        n52) );
  AO21X1_RVT U42 ( .A1(\sub_x_2/A[3] ), .A2(n8), .A3(n10), .Y(n33) );
  AO22X1_RVT U43 ( .A1(\mem_array[3][3] ), .A2(n14), .A3(n13), .A4(n33), .Y(
        n51) );
  INVX0_RVT U44 ( .A(n10), .Y(n9) );
  AO22X1_RVT U45 ( .A1(n11), .A2(n10), .A3(\sub_x_2/A[4] ), .A4(n9), .Y(n39)
         );
  AO22X1_RVT U46 ( .A1(\mem_array[3][4] ), .A2(n14), .A3(n13), .A4(n39), .Y(
        n50) );
  OA21X1_RVT U47 ( .A1(n15), .A2(n19), .A3(n31), .Y(n18) );
  INVX0_RVT U48 ( .A(n18), .Y(n16) );
  NAND2X0_RVT U49 ( .A1(n31), .A2(\sub_x_2/A[0] ), .Y(n25) );
  AO22X1_RVT U50 ( .A1(n18), .A2(\mem_array[2][0] ), .A3(n16), .A4(n25), .Y(
        n46) );
  AO221X1_RVT U51 ( .A1(n32), .A2(n16), .A3(n18), .A4(\mem_array[2][1] ), .A5(
        rst), .Y(n45) );
  AND2X1_RVT U52 ( .A1(n31), .A2(n16), .Y(n17) );
  AO22X1_RVT U53 ( .A1(\mem_array[2][2] ), .A2(n18), .A3(n17), .A4(n22), .Y(
        n44) );
  AO22X1_RVT U54 ( .A1(\mem_array[2][3] ), .A2(n18), .A3(n17), .A4(n33), .Y(
        n43) );
  AO22X1_RVT U55 ( .A1(\mem_array[2][4] ), .A2(n18), .A3(n17), .A4(n39), .Y(
        n42) );
  OA21X1_RVT U56 ( .A1(n20), .A2(n19), .A3(n31), .Y(n24) );
  INVX0_RVT U57 ( .A(n24), .Y(n21) );
  AO22X1_RVT U58 ( .A1(n24), .A2(\mem_array[1][0] ), .A3(n21), .A4(n25), .Y(
        n38) );
  AND2X1_RVT U59 ( .A1(n31), .A2(n21), .Y(n23) );
  AO22X1_RVT U60 ( .A1(\mem_array[1][1] ), .A2(n24), .A3(n23), .A4(n32), .Y(
        n37) );
  AO221X1_RVT U61 ( .A1(n22), .A2(n21), .A3(n24), .A4(\mem_array[1][2] ), .A5(
        rst), .Y(n36) );
  AO22X1_RVT U62 ( .A1(\mem_array[1][3] ), .A2(n24), .A3(n23), .A4(n33), .Y(
        n35) );
  AO22X1_RVT U63 ( .A1(\mem_array[1][4] ), .A2(n24), .A3(n23), .A4(n39), .Y(
        n34) );
  AO22X1_RVT U64 ( .A1(n41), .A2(\mem_array[0][0] ), .A3(n26), .A4(n25), .Y(
        n30) );
  AND2X1_RVT U65 ( .A1(n31), .A2(n26), .Y(n40) );
  AO22X1_RVT U66 ( .A1(\mem_array[0][1] ), .A2(n41), .A3(n40), .A4(n32), .Y(
        n29) );
  AO22X1_RVT U67 ( .A1(\mem_array[0][3] ), .A2(n41), .A3(n40), .A4(n33), .Y(
        n28) );
  AO22X1_RVT U68 ( .A1(\mem_array[0][4] ), .A2(n41), .A3(n40), .A4(n39), .Y(
        n27) );
endmodule


module comparator ( credit, price, stock, can_sell );
  input [7:0] credit;
  input [7:0] price;
  input [7:0] stock;
  output can_sell;
  wire   n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15;

  NAND2X0_RVT U2 ( .A1(n12), .A2(n11), .Y(n14) );
  INVX0_RVT U3 ( .A(price[1]), .Y(n3) );
  OA22X1_RVT U4 ( .A1(credit[1]), .A2(n3), .A3(price[5]), .A4(credit[0]), .Y(
        n2) );
  AO21X1_RVT U5 ( .A1(n3), .A2(credit[1]), .A3(n2), .Y(n5) );
  INVX0_RVT U6 ( .A(price[2]), .Y(n4) );
  AO222X1_RVT U7 ( .A1(credit[2]), .A2(n5), .A3(credit[2]), .A4(n4), .A5(n5), 
        .A6(n4), .Y(n6) );
  AO222X1_RVT U8 ( .A1(price[5]), .A2(credit[3]), .A3(price[5]), .A4(n6), .A5(
        credit[3]), .A6(n6), .Y(n7) );
  AO222X1_RVT U9 ( .A1(price[6]), .A2(credit[4]), .A3(price[6]), .A4(n7), .A5(
        credit[4]), .A6(n7), .Y(n8) );
  AO222X1_RVT U10 ( .A1(credit[5]), .A2(n8), .A3(credit[5]), .A4(price[0]), 
        .A5(n8), .A6(price[0]), .Y(n10) );
  INVX0_RVT U11 ( .A(price[6]), .Y(n9) );
  AO222X1_RVT U12 ( .A1(credit[6]), .A2(n10), .A3(credit[6]), .A4(n9), .A5(n10), .A6(n9), .Y(n15) );
  INVX0_RVT U13 ( .A(stock[5]), .Y(n12) );
  INVX0_RVT U14 ( .A(stock[4]), .Y(n11) );
  OR4X1_RVT U15 ( .A1(stock[3]), .A2(stock[2]), .A3(stock[1]), .A4(stock[0]), 
        .Y(n13) );
  OA22X1_RVT U16 ( .A1(credit[7]), .A2(n15), .A3(n14), .A4(n13), .Y(can_sell)
         );
endmodule


module subtractor ( credit, price, cancel_req, change );
  input [7:0] credit;
  input [7:0] price;
  output [7:0] change;
  input cancel_req;
  wire   n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21;

  INVX0_RVT U2 ( .A(price[6]), .Y(n18) );
  INVX0_RVT U3 ( .A(price[2]), .Y(n9) );
  OR2X1_RVT U4 ( .A1(credit[0]), .A2(price[5]), .Y(n4) );
  INVX0_RVT U5 ( .A(price[1]), .Y(n2) );
  AO222X1_RVT U6 ( .A1(credit[1]), .A2(n4), .A3(credit[1]), .A4(n2), .A5(n4), 
        .A6(n2), .Y(n8) );
  AO222X1_RVT U7 ( .A1(price[6]), .A2(n13), .A3(price[6]), .A4(credit[4]), 
        .A5(n13), .A6(credit[4]), .Y(n15) );
  AO222X1_RVT U8 ( .A1(n15), .A2(price[0]), .A3(n15), .A4(credit[5]), .A5(
        price[0]), .A6(credit[5]), .Y(n17) );
  INVX0_RVT U9 ( .A(cancel_req), .Y(n3) );
  OA21X1_RVT U10 ( .A1(n21), .A2(credit[7]), .A3(n3), .Y(n20) );
  INVX0_RVT U11 ( .A(n4), .Y(n6) );
  AO21X1_RVT U12 ( .A1(n20), .A2(price[5]), .A3(cancel_req), .Y(n5) );
  AO22X1_RVT U13 ( .A1(n20), .A2(n6), .A3(credit[0]), .A4(n5), .Y(change[0])
         );
  FADDX1_RVT U14 ( .A(n6), .B(credit[1]), .CI(price[1]), .S(n7) );
  AO22X1_RVT U15 ( .A1(cancel_req), .A2(credit[1]), .A3(n20), .A4(n7), .Y(
        change[1]) );
  FADDX1_RVT U16 ( .A(n9), .B(credit[2]), .CI(n8), .CO(n11), .S(n10) );
  AO22X1_RVT U17 ( .A1(cancel_req), .A2(credit[2]), .A3(n20), .A4(n10), .Y(
        change[2]) );
  FADDX1_RVT U18 ( .A(price[5]), .B(credit[3]), .CI(n11), .CO(n13), .S(n12) );
  AO22X1_RVT U19 ( .A1(cancel_req), .A2(credit[3]), .A3(n20), .A4(n12), .Y(
        change[3]) );
  FADDX1_RVT U20 ( .A(price[6]), .B(n13), .CI(credit[4]), .S(n14) );
  AO22X1_RVT U21 ( .A1(cancel_req), .A2(credit[4]), .A3(n20), .A4(n14), .Y(
        change[4]) );
  FADDX1_RVT U22 ( .A(n15), .B(price[0]), .CI(credit[5]), .S(n16) );
  AO22X1_RVT U23 ( .A1(cancel_req), .A2(credit[5]), .A3(n20), .A4(n16), .Y(
        change[5]) );
  FADDX1_RVT U24 ( .A(n18), .B(credit[6]), .CI(n17), .CO(n21), .S(n19) );
  AO22X1_RVT U25 ( .A1(cancel_req), .A2(credit[6]), .A3(n20), .A4(n19), .Y(
        change[6]) );
  OA21X1_RVT U26 ( .A1(cancel_req), .A2(n21), .A3(credit[7]), .Y(change[7]) );
endmodule


module vending_top ( clk, rst, coin_insert, coin_in, buy_req, item_sel, 
        cancel_req, dispense, change_out, change, error, display, state_out );
  input [1:0] coin_in;
  input [1:0] item_sel;
  output [7:0] change_out;
  output [7:0] change;
  output [7:0] display;
  output [2:0] state_out;
  input clk, rst, coin_insert, buy_req, cancel_req;
  output dispense, error;
  wire   state_out_0, state_out_2, w_can_sell, w_credit_load, w_mem_write,
         w_change_valid, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15,
         net1128, net1129, net1130, net1131, net1132, net1133, net1134,
         net1135, net1136;
  wire   [7:0] w_price;
  wire   [7:0] w_stock;
  wire   SYNOPSYS_UNCONNECTED__0, SYNOPSYS_UNCONNECTED__1, 
        SYNOPSYS_UNCONNECTED__2, SYNOPSYS_UNCONNECTED__3, 
        SYNOPSYS_UNCONNECTED__4;
  assign state_out[2] = state_out_0;
  assign state_out[0] = state_out_2;

  control_unit u_control_unit ( .clk(clk), .rst(rst), .coin_insert(coin_insert), .buy_req(buy_req), .cancel_req(cancel_req), .can_sell(w_can_sell), 
        .credit_load(w_credit_load), .mem_write(w_mem_write), .dispense(
        dispense), .change_valid(w_change_valid), .error(error), 
        .current_state({state_out_0, state_out[1], state_out_2}) );
  credit_reg u_credit_reg ( .clk(clk), .rst(rst), .cancel(cancel_req), 
        .credit_load(w_credit_load), .current_state({state_out_0, state_out[1], 
        state_out_2}), .coin_in(coin_in), .credit(display) );
  memory u_memory ( .clk(clk), .rst(rst), .item_sel(item_sel), .mem_read(
        net1136), .mem_write(w_mem_write), .price({SYNOPSYS_UNCONNECTED__0, 
        w_price[6:5], SYNOPSYS_UNCONNECTED__1, SYNOPSYS_UNCONNECTED__2, 
        w_price[2:0]}), .stock({SYNOPSYS_UNCONNECTED__3, 
        SYNOPSYS_UNCONNECTED__4, w_stock[5:0]}) );
  comparator u_comparator ( .credit(display), .price({net1131, w_price[6:5], 
        net1132, net1133, w_price[2:0]}), .stock({net1134, net1135, 
        w_stock[5:0]}), .can_sell(w_can_sell) );
  subtractor u_subtrator ( .credit(display), .price({net1128, w_price[6:5], 
        net1129, net1130, w_price[2:0]}), .cancel_req(cancel_req), .change(
        change) );
  DFFX1_RVT \change_out_reg[7]  ( .D(n12), .CLK(clk), .Q(change_out[7]) );
  DFFX1_RVT \change_out_reg[6]  ( .D(n11), .CLK(clk), .Q(change_out[6]) );
  DFFX1_RVT \change_out_reg[5]  ( .D(n10), .CLK(clk), .Q(change_out[5]) );
  DFFX1_RVT \change_out_reg[4]  ( .D(n9), .CLK(clk), .Q(change_out[4]) );
  DFFX1_RVT \change_out_reg[3]  ( .D(n8), .CLK(clk), .Q(change_out[3]) );
  DFFX1_RVT \change_out_reg[2]  ( .D(n7), .CLK(clk), .Q(change_out[2]) );
  DFFX1_RVT \change_out_reg[1]  ( .D(n6), .CLK(clk), .Q(change_out[1]) );
  DFFX1_RVT \change_out_reg[0]  ( .D(n5), .CLK(clk), .Q(change_out[0]) );
  NOR2X0_RVT U16 ( .A1(rst), .A2(w_change_valid), .Y(n15) );
  INVX0_RVT U17 ( .A(rst), .Y(n13) );
  AND2X1_RVT U18 ( .A1(w_change_valid), .A2(n13), .Y(n14) );
  AO22X1_RVT U19 ( .A1(n15), .A2(change_out[7]), .A3(n14), .A4(change[7]), .Y(
        n12) );
  AO22X1_RVT U20 ( .A1(n15), .A2(change_out[6]), .A3(n14), .A4(change[6]), .Y(
        n11) );
  AO22X1_RVT U21 ( .A1(n15), .A2(change_out[5]), .A3(n14), .A4(change[5]), .Y(
        n10) );
  AO22X1_RVT U22 ( .A1(n15), .A2(change_out[4]), .A3(n14), .A4(change[4]), .Y(
        n9) );
  AO22X1_RVT U23 ( .A1(n15), .A2(change_out[3]), .A3(n14), .A4(change[3]), .Y(
        n8) );
  AO22X1_RVT U24 ( .A1(n15), .A2(change_out[2]), .A3(n14), .A4(change[2]), .Y(
        n7) );
  AO22X1_RVT U25 ( .A1(n15), .A2(change_out[1]), .A3(n14), .A4(change[1]), .Y(
        n6) );
  AO22X1_RVT U26 ( .A1(n15), .A2(change_out[0]), .A3(n14), .A4(change[0]), .Y(
        n5) );
endmodule

