/*
	Title            		  :- Automatic Door Controller
	register No      		  :- 16CO125 - 16CO254
	Abstract         		  :- Automatic Door Controller
	Functionalities  		  :- 1.If door is closed and person approaches it opens.
                        		 2.After some time it completely opens and if no one is present it closes.
								 3.If the door is closed then it can be locked that will make it bolted.
								 4.If the door is locked and someone approaches then also it does not open.
								 5.3 failed attempts to manually open a lock door triggers the alarm.
								 6.If door is closing and door resistance(person present) in door frame comes
						  		  it opens.
	Brief Description on code:-  In the code main module calls the door module twice, one of them replicates right door other
	                             left door. Counter module is called with Manual open as clock,enable when door is bolted,the alarm buzzes after three failed manual attempts to open door,
								 only setting reset as 1 can then stop the alarm. 
								 Door module calls the nextstate module to get the nextstate value.Nextstate value is calculated 
								 with the help of case statement and different decision making statements. Simlarly output 
								 module is also called to get the desired output of motors.
*/

`include "Verilog-125-254.v"
module VerilogBM_125_254(output bt,
			output[1:0] yt1,// Next State
			output 	r2m,	// right to Middle rotation motor
					m2r,	// Middle to right rotation motor
					l2m,	// left to Middle rotation motor
					m2l,	// Middle to left rotation motor
					alarm,	// Alarm
			input 	pa,		// Person Approaching
					pp,		// Person Present between doors
					mo,		// Manual Opening
					r,		// right limit
					l,		// left limit
					M,		// Middle limit
					lk,		// lock
					clk,	// Clock
					reset,	// reset
			inout[1:0] yt);	// Present State
	wire t1,t2;				// Output of 2-bit counter
	
	// left Door Circuit
	door left_door(bt,yt1,r2m,m2r,pa,pp,mo,r,M,lk,clk,reset,yt);
	// right Door Circuit
	door right_door(bt,yt1,l2m,m2l,pa,pp,mo,l,M,lk,clk,reset,yt);
	// Counter to count Manual open tries when the door is locked
	counter f7(mo,reset,bt,t1,t2);
	// Alarm triggers when 3 times manual opening is tried when door is locked
	and (alarm,t1,t2);

endmodule





/*Door module it stores the current state of door in memory and then 
calculates nextstate and output value*/


module door(output bt,
			output[1:0] yt1,
			output 	r2l,
					l2r,
			input 	pa,
					pp,
					mo,
					r,
					l,
					lk,
					clk,
					reset,
			inout[1:0] yt);

	nextstate f3(yt,yt1,pa,pp,mo,r,l,lk,clk,reset);
	output_   f4 (bt,r2l,l2r,pa,pp,mo,r,l,yt,lk,clk,reset);

endmodule


/*Nextstate module does nextstate vector assignments using present state
and inputs, it is based on data flow modelling*/

module nextstate(output reg[1:0] yt,
				 			 yt1,
				 input 		 pa,
				 			 pp,
				 			 mo,
				 			 r,
				 			 l,
				 			 lk,
				 			 clk,
				 			 reset);
	
	always @(posedge clk) 
	begin
		// Set initial states to 00
		if(reset)
			begin
				yt=2'b00;
				yt1=2'b00;		
			end
		else
			begin
				// Different States for Behavorial modelling
				case (yt)
					2'b00: 			// Closed State
						begin
							if(lk==1'b1)			// If locked, then next state should be closed
								begin
									yt1[0]=0;
									yt1[1]=0;
								end
							else if(((~lk)&(pa|pp|mo))==1'b1)  // If not lock and any external sensor detected, then go to opening
								begin
									yt1[0]=1;
									yt1[1]=0;
								end
						end
					2'b01: 			// Opening State
						begin
							if(r==1'b1 & l==1'b0)	// If door is open, go to opened state
								begin
									yt1[0]=1;
									yt1[1]=1;
								end
							else if(r==0)			// Else stay in opening
								begin
									yt1[0]=1;
									yt1[1]=0;
								end
						end
					2'b11: 			// Opened State
						begin
							if((pa | pp | mo) & r)	// If external sensors detected, stay in opened state
								begin
									yt1[0]=1;
									yt1[1]=1;
								end
							else if(((~pa)&(~pp)&(~mo))==1'b1 & (r)==1'b1)    // Else go to closing state
								begin
									yt1[0]=0;
									yt1[1]=1;

								end
						end
					2'b10: 			// Closing State
						begin
							if(((~l)&(~pa)&(~pp)&(~mo))==1'b1)		// If no external outputs detected, stay in closing state until closed
								begin
									yt1[0]=0;
									yt1[1]=1;
								end
							else if((l&(~pa)&(~pp)&(~mo))==1'b1)	// If closed, go to closed state
								begin
									yt1[0]=0;
									yt1[1]=0;
								end
							else if((pa|pp|mo)==1'b1)				// If external output detected, go to opening state
								begin
									yt1[0]=1;
									yt1[1]=0;
								end
						end
				endcase
				yt<=yt1;		// NextState will now be the present state
			end
		end
endmodule

/*Output module assigns output variable depending on present state value
and other inputs*/

module output_(output reg bt,
			   			  r2l,
			     		  l2r,
			   input 	  pa,
			   			  pp,
			   			  mo,
			   			  r,
			   			  l,
			   input[1:0] yt,
			   input	  lk,
			   			  clk,
			   			  reset);
	
	always @(posedge clk) 
		begin
			// Set initial states to 0
			if(reset)
				begin
					bt=0;
					r2l=0;
					l2r=0;
				end
			else
				begin
					case (yt)
						2'b00: 			// Closed State
							begin
								if(lk==1'b1)  							//If lock is 1 then the output is as follows
									begin	
										bt=1;
										r2l=0;
										l2r=0;
									end
								else if(((~lk)&(pa|pp|mo))==1'b1)     	//If lock is opened and a sensor is detected then motor turns to open door
									begin
										bt=0;
										r2l=0;
										l2r=1;
									end
							end
						2'b01: 			// Opening State
							begin
								if(r==1'b1 & l==1'b0)        			//If right limit is 1 (door opened) and left limit is 0 then motor is stopped
									begin
										bt=0;
										r2l=0;
										l2r=0;
									end
								else if(r==0)              				//If right limit is 0 (door closed) then motor should go from left to right
									begin
										bt=0;
										r2l=0;
										l2r=1;
									end
							end
						2'b11: 			// Opened State
							begin
								if((pa | pp | mo) & r)					// If external outputs detected, then motor shouldn't change state
									begin
										bt=0;
										r2l=0;
										l2r=0;
									end
								else if(((~pa)&(~pp)&(~mo))==1'b1 & (r)==1'b1)		// If external outputs not detected, then motor should go from right to left
									begin
										bt=0;
										r2l=1;
										l2r=0;
									end
							end
						2'b10: 			// Closing State
							begin
								if(((~l)&(~pa)&(~pp)&(~mo))==1'b1)					// If external outputs not detected, then motor should continue going from right to left
									begin
										bt=0;
										r2l=1;
										l2r=0;
									end
								else if((l&(~pa)&(~pp)&(~mo))==1'b1)				// If external outputs not detected, and door completely closed, motor shouldn't rotate
									begin
										bt=0;
										r2l=0;
										l2r=0;
									end
								else if((pa|pp|mo)==1'b1)							// If external outputs detected, motor should rotate from left to right
									begin
										bt=0;
										r2l=0;
										l2r=1;
									end
							end
					endcase	
				end
			end
endmodule


/*
Counter module counts upto 3 to generate the output for alarm, a preset is set for the counter to remain at 3 once the output is 11
, a reset is set for the counter to become 0 upon making that input high. 
*/

module counter(input      clk,				// clock
			   		      reset,			// reset, serves the purpose to reset the circuit
			        	  enable,			// enable here is the lock of the door
			   output reg a0,				// output 0 of 2bit counter
			   			  a1				// output 1 of 2bit counter
			  );
	
	reg preset;
	initial begin
		preset=1'b0;		// Set preset = 0
	end
	always@(posedge clk or reset)
		begin
			if(reset==1'b0)											// If reset is 0, go to counter
				begin
					if(enable)										// If enable(locked) isn't high, we don't want to increase the counter
						begin	
							if(~preset)								// Count until preset becomes one
								begin
									if(a0 & a1)
										begin
											preset<=1'b1;			// if 3 is output, set preset=1
										end
									else
										begin
											a0<=(1^a0);				// Counter equations
											a1<=(a0^a1);			
										end
								end
							else
								begin
									a0=1'b1;
									a1=1'b1;
								end
						end
				end
			else													// Else set the count to 0
				begin
					a0=1'b0;
					a1=1'b0;
				end
		end
endmodule
