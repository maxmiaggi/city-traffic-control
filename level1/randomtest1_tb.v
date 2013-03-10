module randomtest1_tb;
  reg [3:0] Tin;
  wire [3:0] Tout;
  
  randomtest1 RT1(Tin, Tout);
  
  initial
  begin
    #0  Tin = 4'b0100;
    #10 Tin = 4'b0001;
    #30 Tin = 4'b1110;
  end
endmodule
