// trail code for level 1 implementation
// version 1.2:   Fixed Delay Implementation (21-02-2013)
// version 1.3:   Implemented in Altera Quartus II: Multiple driver error (03-03-2013)
// version 1.4:   Successful compilation and synthesis in Altera (06-03-2013), Error in Functional Analysis
// version 1.5:   Successful Functional Analysis of v1.4 in ModelSim (18-03-2013)
// version 1.6:   Implemented clock division and hardware implementation (04-04-2013)
// version 1.6.1: Minor changes in v1.6 (11-04-2013)
// version 1.7:   Removed task from v1.6 and repeated the code everywhere but no success (12-04-2013)

`define TRUE      1'b1
`define FALSE     1'b0

`define RED       3'b100  // 2'b00 = RED
`define YELLOW    3'b010  // 2'b01 = YELLOW
`define GREEN     3'b001  // 2'b10 = GREEN

`define Y2RDELAY  7       // Delay from Y to R (number of posedges of clock)
`define G2YDELAY  10      // Delay from G to Y (number of posedges of clock)

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

module level1(T, T1, T2, T3, T4, S1, S2, S3, S4, clk, clear, delay_counter);
  output  [2:0] T1, T2, T3, T4;     // four traffic lights
  reg     [2:0] T1, T2, T3, T4;
  input   [2:0] S1, S2, S3, S4;     // four sets of three sensors per road
  input   clk, clear;				// 'clk' is input from the board. 24MHz.   
  reg     [24:0] clkdiv;			// to count posedge of 'clk'
  
  reg     clock;					// 'clock' used in the entire program
  reg	  flag;						// chooses between G2Ysignal and Y2Rsignal (v1.6.1)
  
  output  [3:0] T;                  // to maintain cycle operation among T1, T2, T3, T4
  reg     [3:0] T;                  // output only to view it from testbench
  reg	  [3:0] TT;					// temp register for task operation of T
  
  reg     [2:0] state, next_state;  // internal state variables
  
  output  [3:0] delay_counter;      // counter to control delay, introduced in v1.2
  reg     [3:0] delay_counter;      // output only to view it from testbench
  
  // introduced in v1.4
  // intermediate signals to connect two always blocks
  reg	  Y2Rsignal;				// becomes HIGH when delay = Y2RDELAY
  reg	  G2Ysignal;				// becomes HIGH when delay = G2YDELAY
  reg	  delay_counter_clear;		// when this is HIGH, clear delay_counter

  // initially T1 is green, rest all are red
  // initial state is T1GREEN (T1G)
  
  /*** initialize block is commented
  // always @(clear)
  initial
  begin
    state = `T1G;
    next_state = `T1G;
    T1 = `GREEN;
    T2 = `RED;
    T3 = `RED;
    T4 = `RED;
    T  = 4'd8;        // initialize cycle to 4'b1000
    delay_counter = 4'd0; // initialize delay counter to zero
  end
  *****/
  
  
  // clock division to get a delay of 1 sec (v1.6)
  // 'clk' is internal clock of FPGA running at 25 MHz.
  // 'clk' is divided into 'clock' of time period 1 sec.
  always @(posedge clk)
  begin
	clkdiv = clkdiv + 1;
	if(clear) begin
		clkdiv = 25'd0;
		clock = 1'b0;
	end
	
	if(clkdiv == 25'b0_1011_0111_0001_1011_0000_0000) begin		// 25M = 25'b1_0111_1101_0111_1000_0100_0000 and 24M = 25'b1_0110_1110_0011_0110_0000_0000
		clock = ~clock;
		clkdiv = 1'b0;
	end
  end		// end of always
  
  
  // state changes only at posedge of clock
  // delay counter increases at posedge of clock
  // always @(posedge clock, delay_counter_clear)	// error since edge and level triggered cannot be together (v1.4)
  always @(posedge clock)
  begin
    
    if(clear) begin									// clear/reset conditions
	    state = `T1G;
	    delay_counter = 4'd0;
	    Y2Rsignal = 1'b0;
	    G2Ysignal = 1'b0;
	  end		// end of if
    
    state = next_state;								// state changes only at posedge of clock
    delay_counter = delay_counter + 1;				// delay counter increases at posedge of clock
    
    // check for delay counter values (v1.4)
    // if counter >= required delay, set 1 or else 0
    if((flag) && (delay_counter >= `Y2RDELAY)) begin			// >= used instead of == for safety
	// if((delay_counter >= `Y2RDELAY)) begin
	  Y2Rsignal = 1'b1;								// = is blocking operator
	end
	else begin Y2Rsignal = 1'b0; // clears intermediate signal
	end    // end of if-else
	
	if((!flag) && (delay_counter >= `G2YDELAY)) begin
	// if((delay_counter >= `G2YDELAY)) begin
	  G2Ysignal = 1'b1;								// intermediate signals are generated
	end
	else begin
	  G2Ysignal = 1'b0;								// clears intermediate signal
	end		// end of if-else
	
	if(delay_counter_clear) begin
	  delay_counter = 1'b0;							// clear delay_counter here (v1.4)
	end		// end of if
	
  end		// end of always
  
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
      default: begin T1 = `GREEN;  T2 = `RED;    T3 = `RED;    T4 = `RED;    end
    endcase
    
    if(clear)
			begin T1 = `GREEN;  T2 = `RED;    T3 = `RED;    T4 = `RED;    end	// end of if
  
  end	// end of always
  
  // task to compute the probable next state based upon
  // sensor values and cycle value of T
  task calc_prob_next_state; // probable next state as output
    output [2:0] next_state;  // probable next state as output
    input  [2:0] S1, S2, S3, S4;   // four sensor values as input
    input  [3:0] t;                // cycle variable as input
    output [3:0] tt;			   // modified cycle variable as output
    begin
      
      // case structure to ensure cyclic response
      // T = [T1, T2, T3, T4]
      // only 8 cases are considered out of 16 since T1 will always be made green
      // at the start of every cycle
      
      case (t)
        4'b0000:  begin
                    next_state = `T1G;   // T1 GREEN
                    tt = t|4'b1000;            // update T
                  end
                  
        4'b1000:  begin
                    if (S2 >= S3)
                    begin
                      if (S2 >= S4)
                      begin
                        next_state = `T2G; // T2 GREEN
                        // tt = t|4'b0100;          // update T
                        tt = 4'b1100;
                      end
                      else begin
                        next_state = `T4G; // T4 GREEN
                        tt = t|4'b0001;          // update T
                      end
                    end     // end of first if half
                    else begin
                      if (S3 >= S4)  begin
                        next_state = `T3G; // T3 GREEN
                        tt = t|4'b0010;          // update T
                      end
                      else begin
                        next_state = `T4G; // T4 GREEN
                        tt = t|4'b0001;          // update T
                      end
                    end     // end of if-else
                  end   // end of first case
                  
        4'b1001:  begin
                    if (S2 >= S3)  begin
                      next_state = `T2G;   // T2 GREEN
                      // tt = t|4'b0100;            // update T
                    end
                    else begin
                      next_state = `T3G;   // T3 GREEN
                      tt = t|4'b0010;            // update T
                    end
                  end
        
        4'b1010:  begin
                    if (S2 >= S4)  begin
                      next_state = `T2G;   // T2 GREEN
                      tt = t|4'b0100;            // update T
                    end
                    else begin
                      next_state = `T4G;   // T4 GREEN
                      tt = t|4'b0001;             // update T
                    end
                  end
                  
        4'b1100:  begin
                    if (S3 >= S4)  begin
                      next_state = `T3G;   // T3 GREEN
                      // tt = t|4'b0010;             // update T
                      tt = 4'b1110;
                    end
                    else begin
                      next_state = `T4G;   // T4 GREEN
                      tt = t|4'b0001;             // update T
                    end
                  end 
                  
        4'b1011:  begin
                    next_state = `T2G;   // T2 GREEN
                    tt = 4'b0000;              // update T   
                  end
                  
        4'b1101:  begin
                    next_state = `T3G;   // T3 GREEN
                    tt = 4'b0000;              // update T   
                  end
                  
        4'b1110:  begin
                    next_state = `T4G;   // T4 GREEN
                    tt = 4'b0000;              // update T   
                  end
        
        default:  begin
                    next_state = `T1G;   // T1 GREEN
                    tt = 4'b1000;              // update T
                  end
                  
      endcase     // end of case
    end           // end of task begin
  endtask         // end of task
  
  // state machine using case statement
  always @(state, clear, S1, S2, S3, S4, T, Y2Rsignal, G2Ysignal)	// added intermediate signals (v1.4) 
  // always @*
  begin
	  if (clear) begin
		next_state = `T1G;
		T  = 4'd8;
		delay_counter_clear = 1'b0;
      end
    
      else begin
      case (state)
        `T1G: begin
                flag = 1'b0;										// flag = 0 = choose G2Ysignal
                // repeat(`G2YDELAY) @(posedge clock);              // wait from G to Y
                // if(delay_counter >= `G2YDELAY) begin                // wait from G to Y (v1.2)
                if(G2Ysignal) begin									// TRUE when wait from G to Y is over (v1.4)
                  next_state = `T1Y;                                // next state is Y of same G
                  // delay_counter = 4'd0;                             // clear counter upon state change (v1.2)
                  delay_counter_clear = 1'b1;						// this signal will clear the counter (v1.4)
                end
                else begin
				  delay_counter_clear = 1'b0;						// this is to ensure counter keeps ticking
				end
              end
        
        `T1Y: begin
                flag = 1'b1;										// flag = 1 = choose Y2Rsignal
                // repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                // if(delay_counter >= `Y2RDELAY) begin                 // wait from Y to R (v1.2)
                if(Y2Rsignal) begin									 // wait from Y to R (v1.4)
                  // calc_prob_next_state(next_state, S1, S2, S3, S4, T, TT); // calling task to update next_state and T
                  // delay_counter = 4'd0;                              // clear counter upon state change (v1.2)
                  
                  //******************** FROM TASK ***************//
				  case (T)
					4'b0000:  begin
								next_state = `T1G;   // T1 GREEN
								TT = T|4'b1000;            // update T
							  end
							  
					4'b1000:  begin
								if (S2 >= S3)
								begin
								  if (S2 >= S4)
								  begin
									next_state = `T2G; // T2 GREEN
									TT = T|4'b0100;          // update T
									// TT = 4'b1100;
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of first if half
								else begin
								  if (S3 >= S4)  begin
									next_state = `T3G; // T3 GREEN
									TT = T|4'b0010;          // update T
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of if-else
							  end   // end of first case
							  
					4'b1001:  begin
								if (S2 >= S3)  begin
								  next_state = `T2G;   // T2 GREEN
								  // TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;            // update T
								end
							  end
					
					4'b1010:  begin
								if (S2 >= S4)  begin
								  next_state = `T2G;   // T2 GREEN
								  TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end
							  
					4'b1100:  begin
								if (S3 >= S4)  begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;             // update T
								  // TT = 4'b1110;
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end 
							  
					4'b1011:  begin
								next_state = `T2G;   // T2 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1101:  begin
								next_state = `T3G;   // T3 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1110:  begin
								next_state = `T4G;   // T4 GREEN
								TT = 4'b0000;              // update T   
							  end
					
					default:  begin
								next_state = `T1G;   // T1 GREEN
								TT = 4'b1000;              // update T
							  end
							  
				  endcase     // end of case
				  //************ END OF TASK PART **********//
                  
                  delay_counter_clear = 1'b1;						 // this signal will clear the counter (v1.4)
                  T = TT;											 // Assign TT to T
                end
                else begin
				  delay_counter_clear = 1'b0;						 // this is to ensure counter keeps ticking
				end
              end
              
        `T2G: begin
                flag = 1'b0;										// flag = 0 = choose G2Ysignal
                // repeat(`G2YDELAY) @(posedge clock);              // wait from G to Y
                // if(delay_counter >= `G2YDELAY) begin                // wait from G to Y (v1.2)
                if(G2Ysignal) begin									// TRUE when wait from G to Y is over (v1.4)
                  next_state = `T2Y;                                // next state is Y of same G
                  // delay_counter = 4'd0;                             // clear counter upon state change (v1.2)
                  delay_counter_clear = 1'b1;						// this signal will clear the counter (v1.4)
                end
                else begin
				  delay_counter_clear = 1'b0;						// this is to ensure counter keeps ticking
				end
              end
        
        `T2Y: begin
                flag = 1'b1;										// flag = 1 = choose Y2Rsignal
                // repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                // if(delay_counter >= `Y2RDELAY) begin                 // wait from Y to R (v1.2)
                if(Y2Rsignal) begin									 // wait from Y to R (v1.4)
                  // calc_prob_next_state(next_state, S1, S2, S3, S4, T, TT); // calling task to update next_state and T
                  // delay_counter = 4'd0;                              // clear counter upon state change (v1.2)
                  
                  //******************** FROM TASK ***************//
				  case (T)
					4'b0000:  begin
								next_state = `T1G;   // T1 GREEN
								TT = T|4'b1000;            // update T
							  end
							  
					4'b1000:  begin
								if (S2 >= S3)
								begin
								  if (S2 >= S4)
								  begin
									next_state = `T2G; // T2 GREEN
									TT = T|4'b0100;          // update T
									// TT = 4'b1100;
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of first if half
								else begin
								  if (S3 >= S4)  begin
									next_state = `T3G; // T3 GREEN
									TT = T|4'b0010;          // update T
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of if-else
							  end   // end of first case
							  
					4'b1001:  begin
								if (S2 >= S3)  begin
								  next_state = `T2G;   // T2 GREEN
								  // TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;            // update T
								end
							  end
					
					4'b1010:  begin
								if (S2 >= S4)  begin
								  next_state = `T2G;   // T2 GREEN
								  TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end
							  
					4'b1100:  begin
								if (S3 >= S4)  begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;             // update T
								  // TT = 4'b1110;
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end 
							  
					4'b1011:  begin
								next_state = `T2G;   // T2 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1101:  begin
								next_state = `T3G;   // T3 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1110:  begin
								next_state = `T4G;   // T4 GREEN
								TT = 4'b0000;              // update T   
							  end
					
					default:  begin
								next_state = `T1G;   // T1 GREEN
								TT = 4'b1000;              // update T
							  end
							  
				  endcase     // end of case
				  //************ END OF TASK PART **********//
                  
                  delay_counter_clear = 1'b1;						 // this signal will clear the counter (v1.4)
                  T = TT;											 // Assign TT to T
                end
                else begin
				  delay_counter_clear = 1'b0;						 // this is to ensure counter keeps ticking
				end
              end
              
        `T3G: begin
                flag = 1'b0;										// flag = 0 = choose G2Ysignal
                // repeat(`G2YDELAY) @(posedge clock);              // wait from G to Y
                // if(delay_counter >= `G2YDELAY) begin                // wait from G to Y (v1.2)
                if(G2Ysignal) begin									// TRUE when wait from G to Y is over (v1.4)
                  next_state = `T3Y;                                // next state is Y of same G
                  // delay_counter = 4'd0;                             // clear counter upon state change (v1.2)
                  delay_counter_clear = 1'b1;						// this signal will clear the counter (v1.4)
                end
                else begin
				  delay_counter_clear = 1'b0;						// this is to ensure counter keeps ticking
				end
              end
        
        `T3Y: begin
                flag = 1'b1;										// flag = 1 = choose Y2Rsignal
                // repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                // if(delay_counter >= `Y2RDELAY) begin                 // wait from Y to R (v1.2)
                if(Y2Rsignal) begin									 // wait from Y to R (v1.4)
                  // calc_prob_next_state(next_state, S1, S2, S3, S4, T, TT); // calling task to update next_state and T
                  // delay_counter = 4'd0;                              // clear counter upon state change (v1.2)
                  
                  //******************** FROM TASK ***************//
				  case (T)
					4'b0000:  begin
								next_state = `T1G;   // T1 GREEN
								TT = T|4'b1000;            // update T
							  end
							  
					4'b1000:  begin
								if (S2 >= S3)
								begin
								  if (S2 >= S4)
								  begin
									next_state = `T2G; // T2 GREEN
									TT = T|4'b0100;          // update T
									// TT = 4'b1100;
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of first if half
								else begin
								  if (S3 >= S4)  begin
									next_state = `T3G; // T3 GREEN
									TT = T|4'b0010;          // update T
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of if-else
							  end   // end of first case
							  
					4'b1001:  begin
								if (S2 >= S3)  begin
								  next_state = `T2G;   // T2 GREEN
								  // TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;            // update T
								end
							  end
					
					4'b1010:  begin
								if (S2 >= S4)  begin
								  next_state = `T2G;   // T2 GREEN
								  TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end
							  
					4'b1100:  begin
								if (S3 >= S4)  begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;             // update T
								  // TT = 4'b1110;
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end 
							  
					4'b1011:  begin
								next_state = `T2G;   // T2 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1101:  begin
								next_state = `T3G;   // T3 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1110:  begin
								next_state = `T4G;   // T4 GREEN
								TT = 4'b0000;              // update T   
							  end
					
					default:  begin
								next_state = `T1G;   // T1 GREEN
								TT = 4'b1000;              // update T
							  end
							  
				  endcase     // end of case
				  //************ END OF TASK PART **********//
                  
                  delay_counter_clear = 1'b1;						 // this signal will clear the counter (v1.4)
                  T = TT;											 // Assign TT to T
                end
                else begin
				  delay_counter_clear = 1'b0;						 // this is to ensure counter keeps ticking
				end
              end
              
        `T4G: begin
                flag = 1'b0;										// flag = 0 = choose G2Ysignal
                // repeat(`G2YDELAY) @(posedge clock);              // wait from G to Y
                // if(delay_counter >= `G2YDELAY) begin                // wait from G to Y (v1.2)
                if(G2Ysignal) begin									// TRUE when wait from G to Y is over (v1.4)
                  next_state = `T4Y;                                // next state is Y of same G
                  // delay_counter = 4'd0;                             // clear counter upon state change (v1.2)
                  delay_counter_clear = 1'b1;						// this signal will clear the counter (v1.4)
                end
                else begin
				  delay_counter_clear = 1'b0;						// this is to ensure counter keeps ticking
				end
              end
        
        `T4Y: begin
                flag = 1'b1;										// flag = 1 = choose Y2Rsignal
                // repeat(`Y2RDELAY) @(posedge clock);               // wait from Y to R
                // if(delay_counter >= `Y2RDELAY) begin                 // wait from Y to R (v1.2)
                if(Y2Rsignal) begin									 // wait from Y to R (v1.4)
                  // calc_prob_next_state(next_state, S1, S2, S3, S4, T, TT); // calling task to update next_state and T
                  // delay_counter = 4'd0;                              // clear counter upon state change (v1.2)
                  
                  //******************** FROM TASK ***************//
				  case (T)
					4'b0000:  begin
								next_state = `T1G;   // T1 GREEN
								TT = T|4'b1000;            // update T
							  end
							  
					4'b1000:  begin
								if (S2 >= S3)
								begin
								  if (S2 >= S4)
								  begin
									next_state = `T2G; // T2 GREEN
									TT = T|4'b0100;          // update T
									// TT = 4'b1100;
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of first if half
								else begin
								  if (S3 >= S4)  begin
									next_state = `T3G; // T3 GREEN
									TT = T|4'b0010;          // update T
								  end
								  else begin
									next_state = `T4G; // T4 GREEN
									TT = T|4'b0001;          // update T
								  end
								end     // end of if-else
							  end   // end of first case
							  
					4'b1001:  begin
								if (S2 >= S3)  begin
								  next_state = `T2G;   // T2 GREEN
								  // TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;            // update T
								end
							  end
					
					4'b1010:  begin
								if (S2 >= S4)  begin
								  next_state = `T2G;   // T2 GREEN
								  TT = T|4'b0100;            // update T
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end
							  
					4'b1100:  begin
								if (S3 >= S4)  begin
								  next_state = `T3G;   // T3 GREEN
								  TT = T|4'b0010;             // update T
								  // TT = 4'b1110;
								end
								else begin
								  next_state = `T4G;   // T4 GREEN
								  TT = T|4'b0001;             // update T
								end
							  end 
							  
					4'b1011:  begin
								next_state = `T2G;   // T2 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1101:  begin
								next_state = `T3G;   // T3 GREEN
								TT = 4'b0000;              // update T   
							  end
							  
					4'b1110:  begin
								next_state = `T4G;   // T4 GREEN
								TT = 4'b0000;              // update T   
							  end
					
					default:  begin
								next_state = `T1G;   // T1 GREEN
								TT = 4'b1000;              // update T
							  end
							  
				  endcase     // end of case
				  //************ END OF TASK PART **********//
                  
                  delay_counter_clear = 1'b1;						 // this signal will clear the counter (v1.4)
                  T = TT;											 // Assign TT to T
                end
                else begin
				  delay_counter_clear = 1'b0;						 // this is to ensure counter keeps ticking
				end
              end
              
       endcase   // end of case
    end     // end of if-else
  end    // end of always                
          
endmodule
