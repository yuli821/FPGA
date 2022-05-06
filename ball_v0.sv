


module  ball ( input logic Reset, frame_clk,
					input logic move_up, move_left, move_right,
					input logic [9:0] init_X, init_Y,
					input logic [0:29][0:39] tile,
					input [9:0] buttonX[4], buttonY[4], buttonMotion[2], pfX[2], pfY[2],
					input logic [9:0] spike_row[3], spike_col[3],
					input logic spike_harm[3],								// at this moment, is the spike harmful?
					input logic [9:0] slim_row[3], slim_col[3],
					input logic slim_dead[3],
               output logic [9:0]  Ball_X, Ball_Y, BallH, BallW, Collision_h, Collision_w,
					output logic move_x_dir, dead,
					output logic [3:0] frame,
					output logic harm_state,
					output logic [1:0] harm,
					output logic buttonOn[4]); 
    
    logic [9:0] Ball_X_Motion, Ball_Y_Motion, BallX, BallY;
	 logic [9:0] Ball_X_Pos_n, Ball_Y_Pos_n;		// ignore collision
	 logic [9:0] Ball_Height, Ball_Width;
	 logic up, left, right, down, ground; // collision
	 logic harm_spike, harm_slim;			// go dead straight or can be harmed several times?
	 logic left_pf[2], right_pf[2], up_pf[2], down_pf[2], ground_pf[2];	// collistion with platform
	 logic [1:0] count_acc;
	 logic [4:0] count_idle;
	 logic [5:0] count_run;
	 logic animation;  // 0: idle; 1: run
	 logic [5:0] count;
	 	 
	 assign Ball_X_Pos_n = BallX + Ball_X_Motion;
	 assign Ball_Y_Pos_n = BallY + Ball_Y_Motion;
	 assign dead = ((~harm[0]) && (~harm[1]));//harm = 00
	 
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
	 
	 // size of the box collider
	 assign Collision_h = 15;
	 assign Collision_w = 4;
	 // size of the player
    assign Ball_Height = 37;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Ball_Width = 50;
	 
   logic [9:0] col_left, col_right, row_up, row_down, row_ground, col;
	
	ch_spike harmBySpike(.col_left(col_left), .col_right(col_right), .row_ground(row_ground),
				.spike_row(spike_row), .spike_col(spike_col), .spike_harm(spike_harm), .ch_harm(harm_spike));
	
	ch_slim harmBySlim(.col_left(col_left), .col_right(col_right), .row_ground(row_ground),
				.slim_dead(slim_dead), .slim_row(slim_row), .slim_col(slim_col),.ch_harm(harm_slim));
				
	ch_button triggerbutton(.BallX(BallX), .row_ground(row_ground),
						.buttonX(buttonX), .buttonY(buttonY),
						.buttonOn(buttonOn));
				
//	always_ff @ (posedge Reset or posedge harm_spike or posedge harm_slim)
//	begin
//				if(count == 4'b0)		harm_state <= 1'b1;
//				if(harm_spike || harm_slim)
//				begin
//					if(harm_state == 1'b1)
//					begin
//							harm_state <= 1'b0;
//							harm <= harm-1'b1;
//					end
//				end
//	end
	
	always_ff @ (posedge Reset or posedge frame_clk)
	begin
			if(Reset) count<=6'b0;
			else if(harm_state)	count<=count+1'b1;
			else	count <= 6'b0;
	end
				
	always_comb
		begin: get_frame
			if (animation==1'b0) frame = {1'b0,count_idle[4:3]};	// idle
			else		// run
				begin
					unique case (count_run[5:3])
						3'b000: frame = 3'h4;
						3'b001: frame = 3'h5;
						3'b010: frame = 3'h5;
						3'b011: frame = 3'h6;
						3'b100: frame = 3'h7;
						3'b101: frame = 3'h8;
						3'b110: frame = 3'h8;
						3'b111: frame = 3'h9;
					endcase
				end
		end

	always_comb
		begin: collision_check
			col_left = (BallX-Collision_w-1-Ball_X_Step)>>4;			
			col_right = (BallX+Collision_w+1+Ball_X_Step)>>4;		
			row_up = (Ball_Y_Pos_n-Collision_h-1)>>4;			// up
			row_down = (Ball_Y_Pos_n+Collision_h)>>4;			// down
			row_ground = (BallY+Collision_h+1)>>4;	
			
			// collision in the next frame in 4 directions?
			left = tile[(BallY-Collision_h)>>4][col_left] 
						|| tile[(BallY+Collision_h)>>4][col_left] 
						|| tile[BallY>>4][col_left]
						|| left_pf[0] || left_pf[1];
			right = tile[(BallY-Collision_h)>>4][col_right] 
						|| tile[(BallY+Collision_h)>>4][col_right] 
						|| tile[BallY>>4][col_right]
						|| right_pf[0] || right_pf[1];
			up = tile[row_up][(BallX-Collision_w)>>4] 
						|| tile[row_up][(BallX+Collision_w)>>4];
			down = tile[row_down][(BallX-Collision_w)>>4] 
						|| tile[row_down][(BallX+Collision_w)>>4];
			ground = tile[row_ground][(BallX-Collision_w)>>4] 
						|| tile[row_ground][(BallX+Collision_w)>>4]
						|| ground_pf[0] || ground_pf[1];
			for(int i=0; i<2; i++)
				begin
					left_pf[i] = (BallX - 5 <= pfX[i]+48) 
						&& (BallX - 5 >= pfX[i]) 
						&& (BallY>pfY[i]-Collision_h) 
						&& (BallY<pfY[i]+Collision_h+16);
					right_pf[i] = (BallX + 5 >= pfX[i])
						&& (BallX + 5 <= pfX[i]+48)
						&& (BallY>pfY[i]-Collision_h) 
						&& (BallY<pfY[i]+Collision_h+16);
					up_pf[i] = (Ball_Y_Pos_n-Collision_h <= pfY[i]+buttonMotion[i]+16) // the botton of the pf is lower than the top of ch
						&& (Ball_Y_Pos_n-Collision_h >= pfY[i]+buttonMotion[i])
						&& (BallX>pfX[i]-Collision_w) 
						&& (BallX<pfX[i]+Collision_w+48);
					down_pf[i] = (Ball_Y_Pos_n+Collision_h >= pfY[i]+buttonMotion[i]) // the top of the pf is higher than the bottom of ch
						&& (Ball_Y_Pos_n+Collision_h <= pfY[i]+buttonMotion[i]+16)
						&& (BallX>pfX[i]-Collision_w) 
						&& (BallX<pfX[i]+Collision_w+48);
					ground_pf[i] = (BallY+Collision_h == pfY[i]) 
						&& (BallX>pfX[i]-Collision_w) 
						&& (BallX<pfX[i]+Collision_w+48);
				end
		end
	
	
    always_ff @ (posedge Reset or posedge dead or posedge frame_clk )
    begin: Move_Ball
		  if (Reset)  // Asynchronous Reset
        begin 
            Ball_X_Motion <= 10'd0; //Ball_Y_Step;
				Ball_Y_Motion <= 10'd0; //Ball_X_Step;
				BallY <= init_Y;
				BallX <= init_X;
				count_acc <= 2'b00;
				count_idle <= 5'b0;
				count_run <= 6'b0;
				move_x_dir <= 1'b0;
				harm <= 2'b11;
				animation <= 1'b0;
				//dead <= 1'b0;
        end
        else if(dead)
		  begin
				Ball_Y_Motion <= 0;
				Ball_X_Motion <= 0;
				move_x_dir <= move_x_dir;
		  end
		  else
        begin
				// get next Y_motion
				if(ground)
					begin
						// first check spike
						if(move_up) Ball_Y_Motion <= -5;
						else Ball_Y_Motion <= 0;
						count_acc <= 2'b00;
					end
				else if (up | down | up_pf[0] | up_pf[1] | down_pf[0] | down_pf[1]) Ball_Y_Motion <= 0;	// up collision
				else if (Ball_Y_Motion[9]==0 && (Ball_Y_Motion > 14)) Ball_Y_Motion <= 15; // max motion
				else 	// in the air and no obstacle， have acceleration
					begin
						count_acc <= count_acc + 1;
						if (count_acc == 2'b00) Ball_Y_Motion <= Ball_Y_Motion + 1;
					end
				
				// get next X_motion
				case ({move_left, move_right})
					2'b01 : 
					begin
						begin
							if (!right) 
							begin
								Ball_X_Motion <= Ball_X_Step; // move right
								animation <= 1'b1;				// enter running animation when having horizontal position change
							end
							move_x_dir <= 0;
						end
					end
					2'b10 : 
					begin
						begin
							if (!left && BallX>30) 
							begin
								Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  	// 2's complement; move left
								animation <= 1'b1;
							end
							move_x_dir <= 1;
						end
					end
					default : 
						begin
							Ball_X_Motion <= 1'b0;
						end
				endcase
				
				// get next position
				if(BallX<=30 && move_left) BallX <= 30;
				else if ((left & move_left) | (right & move_right)) BallX <= BallX;
				else BallX <= BallX+Ball_X_Motion;
				
				if (down) BallY <= (row_down<< 4) - Collision_h - 1; //BallY; -1 prevent it from stucking horizontally
				else if(up) BallY <= ((row_up + 1) << 4) + Collision_h + 1;
				else if (down_pf[0]) BallY <= pfY[0] + buttonMotion[0] - Collision_h;
				else if (down_pf[1]) BallY <= pfY[1] + buttonMotion[1] - Collision_h;
				else if (up_pf[0]) BallY <= pfY[0] + buttonMotion[0] + 16 - Collision_h;
				else if (up_pf[1]) BallY <= pfY[1] + buttonMotion[1] + 16 - Collision_h;
				else BallY <= BallY+Ball_Y_Motion;
				
				// update frame counter
				count_idle <= count_idle + 1;
				if (animation == 1'b1) count_run <= count_run + 1;		// count only in the running animation
				if (Ball_X_Motion==0) animation <= 1'b0;	// exit when finish displaying 8 fr

				
				if(count == 6'hFF)	
				begin
					harm_state <= 1'b0;
				end
				if(count == 6'h01)	harm <= harm - 1'b1;
				
				if(harm_spike || harm_slim)
				begin
					//if(harm_state == 1'b0)		harm <= harm--;
					harm_state<=1'b1;
				end
		end  
    end
       

	 // size of the character
    assign BallH = Ball_Height;
	 assign BallW = Ball_Width;
	 
	 assign Ball_X = BallX-25;
	 assign Ball_Y = BallY-21;
	 
	 //assign move_x_dir = Ball_X_Motion[9];

endmodule


module ch_spike (input [9:0] col_left, col_right, row_ground,
						input [9:0] spike_row[3], spike_col[3],
						input spike_harm[3], output logic ch_harm);
						
	logic spike_attack[3];
	always_comb
	begin
		for(int i=0; i<3; i++)
		begin
			if((spike_col[i]==col_left || spike_col[i]==col_right || spike_col[i]+1'b1==col_left || spike_col[i]+1'b1==col_right)
				&& spike_row[i]==row_ground && spike_harm[i]==1'b1)
				spike_attack[i] = 1'b1;	
			else spike_attack[i] = 1'b0;	
		end
		ch_harm = spike_attack[0] || spike_attack[1] || spike_attack[2];
	end
endmodule

module ch_slim (input [9:0] col_left, col_right, row_ground,
						input [9:0] slim_row[3], slim_col[3],
						input slim_dead[3],
						output logic ch_harm);
	logic slim_attack[3];
	always_comb
	begin
		for(int i=0; i<3; i++)
		begin
			if((slim_col[i]==col_left || slim_col[i]==col_right || slim_col[i]+1'b1==col_left || slim_col[i]+1'b1==col_right)
				&& (slim_row[i]-2) < row_ground && (slim_row[i]+2) > row_ground && (slim_dead[i] == 1'b0))
				slim_attack[i] = 1'b1;	
			else slim_attack[i] = 1'b0;	
		end
		ch_harm = slim_attack[0] || slim_attack[1] || slim_attack[2];
	end	
						
endmodule

module ch_button (input [9:0] BallX, row_ground,
						input [9:0] buttonX[4], buttonY[4],
						output logic buttonOn[4]);
	always_comb
	begin
		for(int i=0; i<4; i++)
		begin
			if(BallX > (buttonX[i]<<4) && BallX < (buttonX[i]<<4)+16
				&& buttonY[i]==row_ground)
				buttonOn[i] = 1'b1;	
			else buttonOn[i] = 1'b0;	
		end
	end
endmodule
						
