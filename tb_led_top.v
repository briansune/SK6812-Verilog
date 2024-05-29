//  ____         _                ____                      
// | __ )  _ __ (_)  __ _  _ __  / ___|  _   _  _ __    ___ 
// |  _ \ | '__|| | / _` || '_ \ \___ \ | | | || '_ \  / _ \
// | |_) || |   | || (_| || | | | ___) || |_| || | | ||  __/
// |____/ |_|   |_| \__,_||_| |_||____/  \__,_||_| |_| \___|
//                                                          
// Programed By: BrianSune
// Contact: briansune@gmail.com
// 


`timescale 1ns/1ps


module tb_led_top;
	
	reg		clk;
	reg		nrst;
	
	always begin
		#10.0 clk = ~clk;
	end
	
	led_top DUT1(
		.sys_clk		(clk),
		.sys_nrst		(nrst)
	);
	
	initial begin
		fork begin
			
			#0 clk = 1'b0;
			nrst = 1'b0;
			
			#1000 nrst <= 1'b1;
			
		end join
	end
	
endmodule
