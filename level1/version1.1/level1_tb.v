// testbench for level 1 design

`define TRUE      1'b1
`define FALSE     1'b0 

`define RD_EMPTY  3'd0    // 3'b000 = EMPTY
`define RD_LESS   3'd1    // 3'b001 = LESS CROWDED
`define RD_MORE   3'd3    // 3'b011 = MORE CROWDED
`define RD_FULL   3'd7    // 3'b111 = FULL CROWDED

module level1_tb;
  wire    [1:0] T1, T2, T3, T4;       // these are outputs of the program
  wire    [3:0] T;                    // output which maintains cycle
  reg     [2:0] S1, S2, S3, S4;       // these are inputs to the program
  reg     clock, clear;               // these are also inputs to the program
  
  // instantiate the level1 program
  level1 L1(T, T1, T2, T3, T4, S1, S2, S3, S4, clock, clear);
  
  // set up monitor
  initial
  begin
    $monitor($time, " T = %b T1 = %b T2 = %b T3 = %b T4 = %b S1 = %b S2 = %b S3 = %b S4 = %b", T, T1, T2, T3, T4, S1, S2, S3, S4);
  end
  
  // set up clock
  initial
  begin
    clock = `FALSE;
    forever #5  clock = ~clock;
  end
  
  // control clear signal
  initial
  begin
    clear = `TRUE;
    // repeat(5) @(negedge clock);
    # 5 clear = `FALSE;
  end
  
  // apply stimulus
  initial
  begin
    S1 = `RD_EMPTY; S2 = `RD_EMPTY; S3 = `RD_EMPTY; S4 = `RD_EMPTY;
  
    #10     S1 = `RD_FULL;  S2 = `RD_MORE;   S3 = `RD_MORE;   S4 = `RD_MORE;
    #10     S1 = `RD_MORE;  S2 = `RD_MORE;   S3 = `RD_MORE;   S4 = `RD_MORE;
    #10     S1 = `RD_MORE;  S2 = `RD_MORE;   S3 = `RD_FULL;   S4 = `RD_MORE;
    #10     S1 = `RD_MORE;  S2 = `RD_FULL;   S3 = `RD_MORE;   S4 = `RD_FULL;
    #30     S1 = `RD_MORE;  S2 = `RD_LESS;   S3 = `RD_MORE;   S4 = `RD_FULL;
    #40     S1 = `RD_FULL;  S2 = `RD_MORE;   S3 = `RD_MORE;   S4 = `RD_MORE;
    
    #100    $stop;
  end
endmodule
    
    