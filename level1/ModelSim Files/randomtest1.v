module randomtest1(Tin, Tout);
  input [3:0] Tin;
  output [3:0] Tout;
  reg [3:0] Tout;
  
 // initial
 //   Tin = 4'b0100;
  
  initial
    Tout = Tin|4'b0010;
  
  always @*
    Tout = Tin|4'b0010;

endmodule
