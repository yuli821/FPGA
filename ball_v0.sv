//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk,
					input move_up, move_left, move_right,
					input logic [0:29][0:39] tile,
               output logic [9:0]  Ball_X, Ball_Y, BallH, BallW,
					output logic move_x_dir);
    
    logic [9:0] Ball_X_Motion, Ball_Y_Motion, BallX, BallY;
	 logic [9:0] Ball_X_Pos_n, Ball_Y_Pos_n;		// ignore collision
	 logic [9:0] Ball_Height, Ball_Width, Collision_h, Collision_w;
	 logic up, left, right, down, ground; // collision
	 logic count;
	 	 
	 assign Ball_X_Pos_n = BallX + Ball_X_Motion;
	 assign Ball_Y_Pos_n = BallY + Ball_Y_Motion;
	 
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
	 
	 // size of the box collider
	 assign Collision_h = 16;
	 assign Collision_w = 8;
	 // size of the player
    assign Ball_Height = 30;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Ball_Width = 23;
   
	logic [9:0] col_left, col_right, row_up, row_down, row_ground;
	always_comb
		begin: collision_check
			col_left = (BallX-Collision_w-1-Ball_X_Step)>>4;			
			col_right = (BallX+Collision_w+1+Ball_X_Step)>>4;		
			row_up = (Ball_Y_Pos_n-Collision_h-1)>>4;			// up
			row_down = (Ball_Y_Pos_n+Collision_h)>>4;			// down
			row_ground = (BallY+Collision_h+1)>>4;	
			
			// collision in the next frame in 4 directions?
			left = tile[(BallY-16)>>4][col_left] || tile[(BallY+16)>>4][col_left] || tile[BallY>>4][col_left];
			right = tile[(BallY-16)>>4][col_right] || tile[(BallY+16)>>4][col_right] || tile[BallY>>4][col_right];
			up = tile[row_up][(BallX-8)>>4] || tile[row_up][(BallX+8)>>4];
			down = tile[row_down][(BallX-8)>>4] || tile[row_down][(BallX+8)>>4];
			ground = tile[row_ground][(BallX-8)>>4] || tile[row_ground][(BallX+8)>>4];
		end
	
	
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
		  if (Reset)  // Asynchronous Reset
        begin 
            Ball_X_Motion <= 10'd0; //Ball_Y_Step;
				Ball_Y_Motion <= 10'd0; //Ball_X_Step;
				BallY <= 479-43;
				BallX <= 48;
				count <= 1'b0;
				move_x_dir <= 0;
        end
        else 
        begin
				count = ~count; // acceleration is 1 per 2 frame clk;
				// get next Y_motion
				if(ground)
					begin
						if(move_up) Ball_Y_Motion <= -7;
						else Ball_Y_Motion <= 0;
					end
				else if (up) Ball_Y_Motion <= 0;	// up collision
				else if (down)	Ball_Y_Motion <= 0;	// down collision should include ground
				else if (Ball_Y_Motion[9]==0 && (Ball_Y_Motion > 14)) Ball_Y_Motion <= 15; // max motion
				else if (count) Ball_Y_Motion <= Ball_Y_Motion + 1;
				
				// get next X_motion
				case ({move_left, move_right})
					2'b01 : 
					begin
						if (!right) Ball_X_Motion <= Ball_X_Step; 					// move right
						move_x_dir <= 0;
					end
					2'b10 : 
					begin
						if (!left) Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  	// 2's complement; move left
						move_x_dir <= 1;
					end
					default : Ball_X_Motion <= 0;
				endcase
				
				// get next position
				if ((left & move_left) || (right && move_right)) BallX <= BallX;
				else BallX <= BallX+Ball_X_Motion;
				//BallY <= Ball_Y_Pos_n;
				if (down) BallY <= (row_down<< 4) + (~ (Collision_h) + 1'b1) - 1; //BallY; -1 prevent it from stucking horizontally
				else if(up) BallY <= ((row_up + 1) << 4) + Collision_h + 1;
				else BallY <= BallY+Ball_Y_Motion;
		end  
    end
       

	 // size of the character
    assign BallH = Ball_Height;
	 assign BallW = Ball_Width;
	 
	 assign Ball_X = BallX-11;
	 assign Ball_Y = BallY-14;
	 
	 //assign move_x_dir = Ball_X_Motion[9];

endmodule

