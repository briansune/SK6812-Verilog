//  ____         _                ____                      
// | __ )  _ __ (_)  __ _  _ __  / ___|  _   _  _ __    ___ 
// |  _ \ | '__|| | / _` || '_ \ \___ \ | | | || '_ \  / _ \
// | |_) || |   | || (_| || | | | ___) || |_| || | | ||  __/
// |____/ |_|   |_| \__,_||_| |_||____/  \__,_||_| |_| \___|
//                                                          
// Programed By: BrianSune
// Contact: briansune@gmail.com
// Purpose: Serial LED Test
// 


`timescale 1ns/1ps

module led_top(
	
	input	sys_clk,
	input	sys_nrst,
	
	output	led_sig
);
	
	localparam integer trst		= 800;
	localparam integer tcode0H	= 3;
	localparam integer tcode0L	= 9;
	localparam integer tcode1H	= 6;
	localparam integer tcode1L	= 6;
	localparam [23:0] led_code	= 24'b1100_0000_1100_0000_1100_0000;
	
	wire		glb_clk;
	wire		glb_nrst;
	
	reg		[3 : 0]		fsm_state;
	reg		[10 : 0]	cnt_fsm;
	reg		[4 : 0]		cnt_data;
	
	reg		[23 : 0]	led_color;
	reg		[6 : 0]		cnt_led_load;
	
	reg					low_en;
	reg					led_sig_r;
	
	assign led_sig = led_sig_r;
	
	// 10 MHz generate
	usb_pd_pll usb_pd_pll_u0(
		.clk0_out	(glb_clk),
		.extlock	(glb_nrst),
		
		.reset		(~sys_nrst),
		.refclk		(sys_clk)
	);
	
	always@(posedge glb_clk or negedge glb_nrst)begin
		if(!glb_nrst)begin
			fsm_state <= 4'd0;
			cnt_fsm <= 11'd0;
			cnt_led_load <= 7'd0;
			cnt_data <= 5'd0;
			led_sig_r <= 1'b1;
			// G R B
			led_color <= led_code;
		end else begin
			case(fsm_state)
				
				4'd0: begin
					fsm_state <= 4'd1;
					led_sig_r <= 1'b1;
					cnt_fsm <= 11'd0;
					cnt_led_load <= 7'd0;
					cnt_data <= 5'd0;
				end
				
				4'd1: begin
					if(cnt_fsm >= (trst-1) )begin
						cnt_fsm <=11'd0;
						led_sig_r <= 1'b1;
						fsm_state <= 4'd2;
					end else begin
						cnt_fsm <= cnt_fsm + 1'b1;
						led_sig_r <= 1'b0;
					end
				end
				
				4'd2: begin
					if(cnt_fsm >= 11'd11)begin
						cnt_fsm <=11'd0;
						led_sig_r <= 1'b1;
						if(cnt_data >= 5'd23)begin
							cnt_data <= 5'd0;
							led_color <= {led_color[15:0], led_color[23:16]};
							if(cnt_led_load >= 7'd99)begin
								cnt_led_load <= 7'd0;
								fsm_state <= 4'd3;
							end else begin
								cnt_led_load <= cnt_led_load + 1'b1;
							end
						end else begin
							cnt_data <= cnt_data + 1'b1;
						end
					end else begin
						cnt_fsm <= cnt_fsm + 1'b1;
					end
					
					if(led_color[23-cnt_data])begin
						if(cnt_fsm == (tcode1H-1))
							led_sig_r <= 1'b0;
					end else begin
						if(cnt_fsm == (tcode0H-1))
							led_sig_r <= 1'b0;
					end
				end
				
				4'd3: begin
					led_color <= led_code;
					fsm_state <= 4'd1;
					led_sig_r <= 1'b1;
					cnt_fsm <=11'd0;
					cnt_data <= 5'd0;
				end
				
			endcase
		end
	end
	
endmodule
