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
	                             left door. Counter module is called with Manual open as clock. enable when door is bolted,the alarm buzzes after 
								 three failed manual attempts to open door, only setting reset as 1 can then stop the alarm. 
								 Door module calls the d-flipflop to store the current state of door in memory, then it calls the 
								 nextstate module to get the nextstate value depending upon input and current state. Simlarly output 
								 module is also called to get the desired output of motors based on current state and input.
*/



`include "Verilog-125-254.v"
module VerilogDM_125_254(output bt,    	  	//bolt lock
						 output [1:0]yt1, 	//door nextstate
						 output r2m,       	//right to middle rotation motor (door close)
						        m2r,       	//middle to right rotation motor (door open)
						        l2m,       	//left to middle rotation motor (door close)
						        m2l,       	//middle to right rotation motor (door open)
						       alarm,      	//alarm (3 failed attempts to manually open locked door)
						   
						 input  pa,        	//person approaching sensor
						        pp,        	//person present inside door frame
						        mo,        	//manually open the door
						        r,         	//right limit of door(opened)
						        l,         	//left limit door(opened)
						        m,         	//middle limit door(closed)
						        lk,        	//lock
						        clk,       	//clock
						        reset,     	//reset
						 inout [1:0]yt);   	//present state of door
	wire t1,   //intermediate wires
		 t2;
	
	
	door f5(bt,r2m,m2r,yt1,pa,pp,mo,r,m,lk,clk,reset,yt);     //module call for right door
	door f6 (bt,l2m,m2l,yt1,pa,pp,mo,l,m,lk,clk,reset,yt);    //module call for left door

	counter f7(mo,reset,bt,t1,t2);
	// Alarm triggers when 3 times manual opening is tried when door is locked
	and (alarm,t1,t2);

endmodule

/*Door module it stores the current state of door in memory and then 
calculates nextstate and output value*/


module door(output bt,
                   r2l,
				   l2r,
			output [1:0]yt1,	   
			input  pa,
			       pp,
				   mo,
				   r,
				   l,
				   lk,
				   clk,
				   reset,
			inout [1:0]yt);


	dff f1(yt[0],clk,reset,yt1[0]);            //storing present state value in flipflop
	dff f2(yt[1],clk,reset,yt1[1]);            


	nextstate f3(yt,pa,pp,mo,r,l,lk,clk,reset,yt1); //nextstate module call 


	output_   f4 (bt,r2l,l2r,pa,pp,mo,r,l,lk,clk,reset,yt);  //output module call

endmodule


/*Nextstate module does nextstate vector assignments using present state
and inputs, it is based on data flow modelling*/

module nextstate (output [1:0]yt1,
                  input   pa,
				          pp,
						  mo,
						  r,
						  l,
						  lk,
						  clk,
						  reset,
					input[1:0]yt);


	assign yt1[1]=(~yt[1]&yt[0]&r)|(yt[1]&yt[0])|(yt[1]&~yt[0]&~l&~(pa|pp|mo));    //assigning value to nextstate vector


	assign yt1[0]=(~yt[1]&~yt[0]&~lk&(pa|pp|mo))|(~yt[1]&yt[0])|(yt[1]&(pa|pp|mo));


endmodule



/*Output module assigns output variable depending on present state value
and other inputs*/


module output_(output bt,
                      r2l,
					  l2r,
			    input pa,
				      pp,
					  mo,
					  r,
					  l,
					  lk,
					  clk,
					  reset,
				  input[1:0]yt);

	assign bt=~yt[1]&~yt[0]&lk;                      //assigning value to output variables

	assign r2l=(yt[1]|~lk&~l&~(pa|pp|mo))&~yt[0];

	assign l2r=(~yt[1]|~r&(pa|pp|mo))&yt[0];

endmodule


/*D-flipflop module stores the value of present state in memory*/


module dff(input d,                 //input to d-flipflop
                clk,                //input clock
				reset,              //input reset
		output reg q);              //output of flipflop
	always @ (posedge clk)
		if(reset==1)
			q<=0;
		else
			q<=d;

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
