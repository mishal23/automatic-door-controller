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
	Brief Description on code:-  All the functionalities of the project are one by one at every positive edge of clock pulse
	                             are fed to the respective top level files. Gtkwave is generated to verify the result.
*/

`timescale 1ns/1ps
module Verilog_125_254;
	wire bt,				// Bolted
		r2m,				// right to middle motor
		m2r,				// middle to right motor
		m2l,				// middle to left motor
		l2m,				// left to middle motor
		alarm;				// Alarm
	reg pa,					// Person Approaching
		pp,					// Person Present between door
		mo,					// manual Opening
		r,					// right limit
		m,					// middle limit
		l,					// left limit
		lk,					// lock
		clk,				// clock
		reset;				// reset
	wire[1:0] yt,			// PresentState
			  yt1;			// NextState
	
	//DataFlow Modelling
	/*
	// Calling the main module
	VerilogDM_125_254 f(bt,yt1,r2m,m2r,l2m,m2l,alarm,pa,pp,mo,r,l,m,lk,clk,reset,yt);
	
	// GTKWave Generation for DataFlow Modelling
	initial begin
		$dumpfile("VerilogDM-125-254.vcd");
		$dumpvars(0,Verilog_125_254);
	end
	*/
	
	//Behavorial Modelling
	
	// Calling the main module
	VerilogBM_125_254 f(bt,yt1,r2m,m2r,l2m,m2l,alarm,pa,pp,mo,r,l,m,lk,clk,reset,yt);
	
	// GTKWave Generation for Behavorial Modelling
	initial begin
		$dumpfile("VerilogBM-125-254.vcd");
		$dumpvars(0,Verilog_125_254);
	end
	
	
	// Toggle the input clock after every 10, initial clock set to 1
	initial begin
		clk=1'b1;
		repeat(65)
			#10 clk=~clk;
	end
	
	initial begin
		$display("AUTOMATIC DOOR CONTROLLER\n");
	end

	initial begin
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
			reset=1;
		$monitor("Reset=%b both doors closed",reset);
		
		//TestCase1:- Both Doors Closed
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
			reset=0;
		
		//TestCase2:- Person Approaching
		#20;
			pa=1;
			pp=0;
			mo=0;
			r=0;
			m=0;
			lk=0;
			l=0;
			reset=0;
		$monitor("Person approaching=%b  Door opening=%b",pa,yt);
		//TestCase3:- Person Approaching
		#20;
			pa=1;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
			reset=0;
		$monitor("Person approaching=%b  Door opened=%b",pa,yt);
		//TestCase4:- Both Doors open 
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
			reset=0;
		$monitor("Person approaching=%b  Door closing=%b",pa,yt);
		//TestCase5:- doors closing
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
		    reset=0;
		
		//TestCase6:- Doors completely closed
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
		    reset=0;
		$monitor("No external sensor triggered, Door closed=%b",yt);
		//TestCase7:- Doors completely closed
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
		    reset=0;
		//TestCase8:- Doors completely closed
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
		    reset=0;
		//TestCase9:- Doors closed and locked
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=1;
			l=0;
		    reset=0;
		$monitor("Door closed=%b, Door locked=%b",yt,lk);
		//TestCase10:- locked door, tried to open manually(first trial)
		#20;
			pa=0;
			pp=0;
			mo=1;
			r=0;
			m=1;
			lk=1;
			l=0;
		    reset=0;
		$monitor("Door locked=%b, manual open=%b first time, alarm=%b",lk,mo,alarm);
		//TestCase11:- locked door, tried to manually open(first trial)
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=1;
			l=0;
		    reset=0;
		
		//TestCase12:- locked door
		#20;
			pa=0;
			pp=0;
			mo=1;
			r=0;
			m=1;
			lk=1;
			l=0;
		    reset=0;
		$monitor("Door locked=%b, manual open=%b second time, alarm=%b",lk,mo,alarm);
		//TestCase13:- locked door, tried to manually open(second trial), alarm off
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=1;
			l=0;
		    reset=0;
		
		//TestCase14:- locked door
		#20;
			pa=0;
			pp=0;
			mo=1;
			r=0;
			m=1;
			lk=1;
			l=0;
		    reset=0;
		$monitor("Door locked=%b, manual open=%b third time, alarm=%b",lk,mo,alarm);
		//TestCase15:- locked door, tried to manually open(third trial), alarm on
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=1;
			l=0;
		   reset=1;
		$monitor("Reset=%b To stop alarm",reset);
		//TestCase16:- reset=1
		#20;
			pa=0;
			pp=0;
			mo=1;
			r=0;
			m=1;
			lk=0;
			l=0;
		   reset=0;
		$monitor("Door locked=%b, manual open=%b door opening=%b",lk,mo,yt);
		//TestCase17:- Manually opened, door opening
		#20;
			pa=1;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
		   reset=0;
		$monitor("Person approaching=%b door opened=%b",pa,yt);
		//TestCase18:- Person approaching, doors remain open
		#20;
			pa=0;
			pp=1;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
		   reset=0;
		$monitor("Person present=%b door opened=%b",pp,yt);
		//TestCase19:- doors open, person present 
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
		    reset=0;
		$monitor("No external sensors trigered doors closing=%b",yt);
		//TestCase20:- Doors closing
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
		    reset=0;
		$monitor("doors fully closed=%b",yt);
		//TestCase21:- doors closed
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
		   reset=0;
		//TestCase22:- doors closed
		#20;
			pa=1;
			pp=0;
			mo=0;
			r=0;
			m=0;
			lk=0;
			l=0;
		   reset=0;
		$monitor("Person approaching=%b door opening=%b",pa,yt);
		//TestCase23:- Person Approaching, Doors opening
		#20;
			pa=1;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
		    reset=0;
		$monitor("Person approaching=%b door opened=%b",pa,yt);
		//TestCase24:- Doors Open
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
		    reset=0;
		$monitor("No external sensors triggered doors closing=%b",yt);
		//TestCase25:- Doors closing
		#40;
			pa=0;
			pp=0;
			mo=0;
			r=1;
			m=0;
			lk=0;
			l=1;
		    reset=0;
		//TestCase26:- Doors closing
		#40;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=0;
			lk=0;
			l=0;
		   reset=0;
		//TestCase27:- Doors closed
		#20;
			pa=0;
			pp=0;
			mo=0;
			r=0;
			m=1;
			lk=0;
			l=0;
		   reset=0;
		$monitor("doors closed=%b",yt);
	end
endmodule