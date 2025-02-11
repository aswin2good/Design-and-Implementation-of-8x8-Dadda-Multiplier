`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.11.2024 21:24:03
// Design Name: 
// Module Name: dadda_8x8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//Achutha Aswin Naick
//S3 ECE 
//Roll no. 03
//LCD Course Project
// 8 x 8 Dadda multiplier Verilog HDL Design
// A - 8 bits , B - 8bits, y(output) - 16bits

module half_adder(a, b, Sum, Cout);

input a, b; // a and b are inputs with size 1-bit
output Sum, Cout; // Sum and Cout are outputs with size 1-bit

assign Sum = a ^ b; 
assign Cout = a & b; 

endmodule

//carry save adder/full adder -- for implementing dadda multiplier

module full_adder(A,B,Cin,Y,Cout);
input A,B,Cin;
output Y,Cout;
    
assign Y = A^B^Cin;
assign Cout = (A&B)|(A&Cin)|(B&Cin);
    
endmodule


module dadda_8x8(
    input [7:0] A, // 8-bit input A
    input [7:0] B, // 8-bit input B
    output wire [15:0] y // 16-bit output y (product of A and B)
                          /* y is wire type as Dadda Multiplier's output is of type wire,
                            there is no need to store values in the output. */ 
    );
    //now we start implementing different stages in order to get partial products
    wire gen_pp [0:7][7:0] ; // 2D array of wires to hold the partial products 
                           /* first index [0:7] represents the 8 rows corresponding to each bit of the input B
                              second bit [7:0] represents the 8 columns corresponding to each bit of the input A */

    // stage-1 sum and carry (6 bits) (for d=6)
    wire [0:5] s1,c1; 
    
    // stage-2 sum and carry (14 bits)  (for d=4)
    wire [0:13] s2,c2; /*the number of rows is decreased 
                      while the width of each row grows, due to the addition of carries.*/
                      
    // stage-3 sum and carry (10 bits) (for d=3)
    wire [0:9] s3,c3; /*reduction process has produced a smaller set of rows,
                       but the widths have shifted accordingly */
                       
    // stage-4 sum and carry (12 bits)  (for d=2)
    wire [0:11] s4,c4; /* sum and carry widths are adjusted again based on the Dadda reduction logic*/
    
    // stage-5 sum and carry (14 bits)  
    wire [0:13]s5,c5; /*  final reduction stage where the sum and carry are reduced to a manageable level 
                          that can be fed into the final summation step to produce the 16-bit result*/
                          
    // generating partial products (generating hardware structures during synthesis)
    genvar i;  //i are loop indices used to iterate over the bits of B
    genvar j;  //j are loop indices used to iterate over the bits of A

    //starting the iteration
    for (i = 0; i < 8; i = i + 1) begin     //iterating through each bit of B
          for(j = 0; j < 8; j = j+1) begin  //iterating through each bit of A
          assign gen_pp [i][j] = A[j]*B[i];  //bitwise multiplication and generation of partial products
          end
    end 
    
    //REDUCTION BY STAGES
    // d values ranges are = 2,3,4,6,9,13...
    
    //Since our Dadda Multiplier is 8x8, we reduce 8 bits to 6 bits and continue further
    //Stage 1 - reducing from 8 to 6 
    
    half_adder h1_1(.a(gen_pp[6][0]),.b(gen_pp[5][1]),.Sum(s1[0]),.Cout(c1[0]));
    half_adder h1_2(.a(gen_pp[4][3]),.b(gen_pp[3][4]),.Sum(s1[2]),.Cout(c1[2]));
    half_adder h1_3(.a(gen_pp[4][4]),.b(gen_pp[3][5]),.Sum(s1[4]),.Cout(c1[4]));
    
    full_adder f1_1(.A(gen_pp[7][0]),.B(gen_pp[6][1]),.Cin(gen_pp[5][2]),.Y(s1[1]),.Cout(c1[1]));
    full_adder f1_2(.A(gen_pp[7][1]),.B(gen_pp[6][2]),.Cin(gen_pp[5][3]),.Y(s1[3]),.Cout(c1[3]));
    full_adder f1_3(.A(gen_pp[7][2]),.B(gen_pp[6][3]),.Cin(gen_pp[5][4]),.Y(s1[5]),.Cout(c1[5]));
    
    
    //Stage 2 - reducing from 6 to 4

    half_adder h2_1(.a(gen_pp[4][0]),.b(gen_pp[3][1]),.Sum(s2[0]),.Cout(c2[0]));
    half_adder h2_2(.a(gen_pp[2][3]),.b(gen_pp[1][4]),.Sum(s2[2]),.Cout(c2[2]));
    
    full_adder f2_1(.A(gen_pp[5][0]),.B(gen_pp[4][1]),.Cin(gen_pp[3][2]),.Y(s2[1]),.Cout(c2[1]));
    full_adder f2_2(.A(s1[0]),.B(gen_pp[4][2]),.Cin(gen_pp[3][3]),.Y(s2[3]),.Cout(c2[3]));
    full_adder f2_3(.A(gen_pp[2][4]),.B(gen_pp[1][5]),.Cin(gen_pp[0][6]),.Y(s2[4]),.Cout(c2[4]));
    full_adder f2_4(.A(s1[1]),.B(s1[2]),.Cin(c1[0]),.Y(s2[5]),.Cout(c2[5]));
    full_adder f2_5(.A(gen_pp[2][5]),.B(gen_pp[1][6]),.Cin(gen_pp[0][7]),.Y(s2[6]),.Cout(c2[6]));
    full_adder f2_6(.A(s1[3]),.B(s1[4]),.Cin(c1[1]),.Y(s2[7]),.Cout(c2[7]));
    full_adder f2_7(.A(c1[2]),.B(gen_pp[2][6]),.Cin(gen_pp[1][7]),.Y(s2[8]),.Cout(c2[8]));
    full_adder f2_8(.A(s1[5]),.B(c1[3]),.Cin(c1[4]),.Y(s2[9]),.Cout(c2[9]));
    full_adder f2_9(.A(gen_pp[4][5]),.B(gen_pp[3][6]),.Cin(gen_pp[2][7]),.Y(s2[10]),.Cout(c2[10]));
    full_adder f2_10(.A(gen_pp[7][3]),.B(c1[5]),.Cin(gen_pp[6][4]),.Y(s2[11]),.Cout(c2[11]));
    full_adder f2_11(.A(gen_pp[5][5]),.B(gen_pp[4][6]),.Cin(gen_pp[3][7]),.Y(s2[12]),.Cout(c2[12]));
    full_adder f2_12(.A(gen_pp[7][4]),.B(gen_pp[6][5]),.Cin(gen_pp[5][6]),.Y(s2[13]),.Cout(c2[13]));
    

    //Stage 3 - reducing from 4 to 3
    
    half_adder h3_1(.a(gen_pp[3][0]),.b(gen_pp[2][1]),.Sum(s3[0]),.Cout(c3[0]));
    
    full_adder c3_1(.A(s2[0]),.B(gen_pp[2][2]),.Cin(gen_pp[1][3]),.Y(s3[1]),.Cout(c3[1]));
    full_adder c3_2(.A(s2[1]),.B(s2[2]),.Cin(c2[0]),.Y(s3[2]),.Cout(c3[2]));
    full_adder c3_3(.A(c2[1]),.B(c2[2]),.Cin(s2[3]),.Y(s3[3]),.Cout(c3[3]));
    full_adder c3_4(.A(c2[3]),.B(c2[4]),.Cin(s2[5]),.Y(s3[4]),.Cout(c3[4]));
    full_adder c3_5(.A(c2[5]),.B(c2[6]),.Cin(s2[7]),.Y(s3[5]),.Cout(c3[5]));
    full_adder c3_6(.A(c2[7]),.B(c2[8]),.Cin(s2[9]),.Y(s3[6]),.Cout(c3[6]));
    full_adder c3_7(.A(c2[9]),.B(c2[10]),.Cin(s2[11]),.Y(s3[7]),.Cout(c3[7]));
    full_adder c3_8(.A(c2[11]),.B(c2[12]),.Cin(s2[13]),.Y(s3[8]),.Cout(c3[8]));
    full_adder c3_9(.A(gen_pp[7][5]),.B(gen_pp[6][6]),.Cin(gen_pp[5][7]),.Y(s3[9]),.Cout(c3[9]));
    
    
    //Stage 4 - reducing from 3 to 2
    
    half_adder h4_1(.a(gen_pp[2][0]),.b(gen_pp[1][1]),.Sum(s4[0]),.Cout(c4[0]));


    full_adder c4_1(.A(s3[0]),.B(gen_pp[1][2]),.Cin(gen_pp[0][3]),.Y(s4[1]),.Cout(c4[1]));
    full_adder c4_2(.A(c3[0]),.B(s3[1]),.Cin(gen_pp[0][4]),.Y(s4[2]),.Cout(c4[2]));
    full_adder c4_3(.A(c3[1]),.B(s3[2]),.Cin(gen_pp[0][5]),.Y(s4[3]),.Cout(c4[3]));
    full_adder c4_4(.A(c3[2]),.B(s3[3]),.Cin(s2[4]),.Y(s4[4]),.Cout(c4[4]));
    full_adder c4_5(.A(c3[3]),.B(s3[4]),.Cin(s2[6]),.Y(s4[5]),.Cout(c4[5]));
    full_adder c4_6(.A(c3[4]),.B(s3[5]),.Cin(s2[8]),.Y(s4[6]),.Cout(c4[6]));
    full_adder c4_7(.A(c3[5]),.B(s3[6]),.Cin(s2[10]),.Y(s4[7]),.Cout(c4[7]));
    full_adder c4_8(.A(c3[6]),.B(s3[7]),.Cin(s2[12]),.Y(s4[8]),.Cout(c4[8]));
    full_adder c4_9(.A(c3[7]),.B(s3[8]),.Cin(gen_pp[4][7]),.Y(s4[9]),.Cout(c4[9]));
    full_adder c4_10(.A(c3[8]),.B(s3[9]),.Cin(c2[13]),.Y(s4[10]),.Cout(c4[10]));
    full_adder c4_11(.A(c3[9]),.B(gen_pp[7][6]),.Cin(gen_pp[6][7]),.Y(s4[11]),.Cout(c4[11]));
    
    
    //Stage 5 - reducing fom 2 to 1
    // adding total sum and carry to get final output

    half_adder h5_1(.a(gen_pp[1][0]),.b(gen_pp[0][1]),.Sum(y[1]),.Cout(c5[0]));



    full_adder c5_1(.A(s4[0]),.B(gen_pp[0][2]),.Cin(c5[0]),.Y(y[2]),.Cout(c5[1]));
    full_adder c5_2(.A(c4[0]),.B(s4[1]),.Cin(c5[1]),.Y(y[3]),.Cout(c5[2]));
    full_adder c5_3(.A(c4[1]),.B(s4[2]),.Cin(c5[2]),.Y(y[4]),.Cout(c5[3]));
    full_adder c5_4(.A(c4[2]),.B(s4[3]),.Cin(c5[3]),.Y(y[5]),.Cout(c5[4]));
    full_adder c5_5(.A(c4[3]),.B(s4[4]),.Cin(c5[4]),.Y(y[6]),.Cout(c5[5]));
    full_adder c5_6(.A(c4[4]),.B(s4[5]),.Cin(c5[5]),.Y(y[7]),.Cout(c5[6]));
    full_adder c5_7(.A(c4[5]),.B(s4[6]),.Cin(c5[6]),.Y(y[8]),.Cout(c5[7]));
    full_adder c5_8(.A(c4[6]),.B(s4[7]),.Cin(c5[7]),.Y(y[9]),.Cout(c5[8]));
    full_adder c5_9(.A(c4[7]),.B(s4[8]),.Cin(c5[8]),.Y(y[10]),.Cout(c5[9]));
    full_adder c5_10(.A(c4[8]),.B(s4[9]),.Cin(c5[9]),.Y(y[11]),.Cout(c5[10]));
    full_adder c5_11(.A(c4[9]),.B(s4[10]),.Cin(c5[10]),.Y(y[12]),.Cout(c5[11]));
    full_adder c5_12(.A(c4[10]),.B(s4[11]),.Cin(c5[11]),.Y(y[13]),.Cout(c5[12]));
    full_adder c5_13(.A(c4[11]),.B(gen_pp[7][7]),.Cin(c5[12]),.Y(y[14]),.Cout(c5[13]));
    
    assign y[0] =  gen_pp[0][0]; //least significant bit (LSB) of the final product
    assign y[15] = c5[13];       //most significant bit (MSB) of the final product
    
endmodule



