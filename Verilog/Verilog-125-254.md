Title of Project:- Automatic Door Controller
Two types of Verilog Coding is done: 1)Behavorial Modelling
				     2)Dataflow Modelling

Brief about Behavorial Modelling:- In the code main module calls the door module twice, one of them replicates right door other
	                           left door. Counter module is called with Manual open as clock,enable when door is bolted,the alarm buzzes 					   after three failed manual attempts to open door, only setting reset as 1 can then stop the alarm. 
    				   Door module calls the nextstate module to get the nextstate value.Nextstate value is calculated 
				   with the help of case statement and different decision making statements. Simlarly output 
				   module is also called to get the desired output of motors.
Brief about DataFlow Modelling:-   In the code main module calls the door module twice, one of them replicates right door other
	                           left door. Counter module is called with Manual open as clock. enable when door is bolted,the alarm buzzes 					   after three failed manual attempts to open door, only setting reset as 1 can then stop the alarm. 
				   Door module calls the d-flipflop to store the current state of door in memory, then it calls the 
				   nextstate module to get the nextstate value depending upon input and current state. Simlarly output 
				   module is also called to get the desired output of motors based on current state and input.

Brief about Functionalities:-      Initially door is closed, then a person approaches(pa=1) and door starts opening(m2r=1 , m2l=1)
				   After sometime, door fully opens(r=1 , l=1),
                                   As no activity found , door starts closing(rm2=1 , l2m=1)
			           After sometime, door fully closes(m=1)
				   Now the door is locked(lk=1, output: bt=1),
				   Now three times the door is being tried to manually open(mo=1),
				   As the door is locked, after three tries alarm buzzes,(alarm=1)
				   NOTE: Alarm can be set off only after reset=1
				   Now lock is opened, and door is manually opened(mo=1) and door starts opening(m2r=1 , m2l=1)
				   After sometime door fully opens(r=1 , l=1)
				   Now person approaches, door remains opened
				   Now person present inside door frame, doors remain open
				   Now as no activity found, the door closes.

Applications:- Automatic Door controllers have become a common sight, in malls, hotels, hospitals, banks, office spaces etc.
	       The prototype model of door built here can also be used in security purposes in jewellery shops, at homes etc.

Submitted by:-	Mishal Shah(16CO125)
		Samyak Jain(16CO254)
				  


