// trail code for level 1 implementation

`define TRUE      1'b1
`define FALSE     1'b0

`define RED       2'd0    // 2'b00 = RED
`define YELLOW    2'd1    // 2'b01 = YELLOW
`define GREEN     2'd2    // 2'b10 = GREEN

`define Y2RDELAY  3       // Delay from Y to R (number of posedges of clock)
`define G2YDELAY  2       // Delay from G to Y (number of posedges of clock)

`define RD_EMPTY  3'd0    // 3'b000 = EMPTY
`define RD_LESS   3'd1    // 3'b001 = LESS CROWDED
`define RD_MORE   3'd3    // 3'b011 = MORE CROWDED
`define RD_FULL   3'd7    // 3'b111 = FULL CROWDED

// state definition
`define T1G       3'd0    // 3'b000 = State 0 = T1 GREEN
`define T1Y       3'd1    // 3'b001 = State 1 = T1 YELLOW
`define T2G       3'd2    // 3'b010 = State 2 = T2 GREEN
`define T2Y       3'd3    // 3'b011 = State 3 = T2 YELLOW
`define T3G       3'd4    // 3'b100 = State 4 = T3 GREEN
`define T3Y       3'd5    // 3'b101 = State 5 = T3 YELLOW
`define T4G       3'd6    // 3'b110 = State 6 = T4 GREEN
`define T4Y       3'd7    // 3'b111 = State 7 = T4 YELLOW

module level1(T, T1, T2, T3, T4, S1, S2, S3, S4, clock, clear);
  output  [1:0] T1, T2, T3, T4;     // four traffic lights
  reg     [1:0] T1, T2, T3, T4;
  input   [2:0] S1, S2, S3, S4;     // four sets of three sensors per road
  input   clock, clear;   
  
  output  [3:0] T;                  // to maintain cycle operation among T1, T2, T3, T4
  reg     [3:0] T;
  
  reg     [2:0] state, next_state;  // internal state variables

  // initially T1 is green, rest all are red
  // initial state is T1GREEN (T1G)
  
  always @(clear)
  // initial
  begin
    state = `T1G;
    next_state = `T1G;
    T1 = `GREEN;
    T2 = `RED;
    T3 = `RED;
    T4 = `RED;
    T  = 4'd8;        // initialize cycle to 4'b1000
  end
  
  // state changes only at posedge of clock
  always @(posedge clock)
    state = next_state;
  
  // compute traffic light values
  always @(state)
  begin
    case (state)
      `T1G: begin T1 = `GREEN;  T2 = `RED;    T3 = `RED;    T4 = `RED;    end
      `T1Y: begin T1 = `YELLOW; T2 = `RED;    T3 = `RED;    T4 = `RED;    end 
      `T2G: begin T1 = `RED;    T2 = `GREEN;  T3 = `RED;    T4 = `RED;    end 
      `T2Y: begin T1 = `RED;    T2 = `YELLOW; T3 = `RED;    T4 = `RED;    end 
      `T3G: begin T1 = `RED;    T2 = `RED;    T3 = `GREEN;  T4 = `RED;    end 
      `T3Y: begin T1 = `RED;    T2 = `RED;    T3 = `YELLOW; T4 = `RED;    end  
      `T4G: begin T1 = `RED;    T2 = `RED;    T3 = `RED;    T4 = `GREEN;  end
      `T4Y: begin T1 = `RED;    T2 = `RED;    T3 = `RED;    T4 = `YELLOW; end
    endcase
  end
  
  // function to compute the probable next state based upon
  // sensor values and cycle value of T
  function [2:0] prob_next_state; // probable next state as output
    input [2:0] S1, S2, S3, S4;   // four sensor values as input
    input [3:0] T;                // cycle variable as input
    begin
      
      // case structure to ensure cyclic response
      // T = [T1, T2, T3, T4]
      // only 8 cases are considered out of 16 since T1 will always be made green
      // at the start of every cycle
      
      case (T)
        4'b0000:  begin
                    prob_next_state = `T1G;   // T1 GREEN
                    T = T|4'b1000;            // update T
                  end
                  
        4'b1000:  begin
                    if (S2 >= S3)
                    begin
                      if (S2 >= S4)
                      begin
                        prob_next_state = `T2G; // T2 GREEN
                        T = T|4'b0100;          // update T
                      end
                      else begin
                        prob_next_state = `T4G; // T4 GREEN
                        T = T|4'b0001;          // update T
                      end
                    end     // end of first if half
                    else begin
                      if (S3 >= S4)  begin
                        prob_next_state = `T3G; // T3 GREEN
                        T = T|4'b0010;          // update T
                      end
                      else begin
                        prob_next_state = `T4G; // T4 GREEN
                        T = T|4'b0001;          // update T
                      end
                    end     // end of if-else
                  end   // end of first case
                  
        4'b1001:  begin
                    if (S2 >= S3)  begin
                      prob_next_state = `T2G;   // T2 GREEN
                      T = T|4'b0100;            // update T
                    end
                    else begin
                      prob_next_state = `T3G;   // T3 GREEN
                      T = T|4'b0010;            // update T
                    end
                  end
        
        4'b1010:  begin
                    if (S2 >= S4)  begin
                      prob_next_state = `T2G;   // T2 GREEN
                      T = T|4'b0100;            // update T
                    end
                    else begin
                      prob_next_state = `T4G;   // T4 GREEN
                      T = T|4'b0001;             // update T
                    end
                  end
                  
        4'b1100:  begin
                    if (S3 >= S4)  begin
                      prob_next_state = `T3G;   // T3 GREEN
                      T = T|4'b0010;             // update T
                    end
                    else begin
                      prob_next_state = `T4G;   // T4 GREEN
                      T = T|4'b0001;             // update T
                    end
                  end 
                  
        4'b1011:  begin
                    prob_next_state = `T2G;   // T2 GREEN
                    T = 4'b0000;              // update T   
                  end
                  
        4'b1101:  begin
                    prob_next_state = `T3G;   // T3 GREEN
                    T = 4'b0000;              // update T   
                  end
                  
        4'b1110:  begin
                    prob_next_state = `T4G;   // T4 GREEN
                    T = 4'b0000;              // update T   
                  end
      endcase     // end of case
    end           // end of function begin
  endfunction     // end of function
  
  // state machine using case statement
  // always @(state, clear, S1, S2, S3, S4, T)
  always @*
  begin
    if (clear)
      next_state = `T1G;                      // reset state is T1 GREEN
    
    else begin
      case (state)
        `T1G: begin
                repeat(`G2YDELAY) @(posedge clock);               // wait from G to Y
                next_state = `T1Y;                                // next state is Y of same G
              end
        
        `T1Y: begin
                repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                next_state = prob_next_state(S1, S2, S3, S4, T);  // prob next state is returned from function
              end
              
        `T2G: begin
                repeat(`G2YDELAY) @(posedge clock);               // wait from G to Y
                next_state = `T2Y;                                // next state is Y of same G
              end
        
        `T2Y: begin
                repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                next_state = prob_next_state(S1, S2, S3, S4, T);  // prob next state is returned from function
              end
              
        `T3G: begin
                repeat(`G2YDELAY) @(posedge clock);               // wait from G to Y
                next_state = `T3Y;                                // next state is Y of same G
              end
        
        `T3Y: begin
                repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                next_state = prob_next_state(S1, S2, S3, S4, T);  // prob next state is returned from function
              end
              
        `T4G: begin
                repeat(`G2YDELAY) @(posedge clock);               // wait from G to Y
                next_state = `T4Y;                                // next state is Y of same G
              end
        
        `T4Y: begin
                repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                next_state = prob_next_state(S1, S2, S3, S4, T);  // prob next state is returned from function
              end
              
      endcase   // end of case
    end     // end of if-else
  end    // end of always
                  
          
endmodule