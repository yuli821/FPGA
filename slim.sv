module slim(input logic frame_clk, RESET, 
				input logic [9:0] DrawX, DrawY,
				input logic fight[2],
				input logic [9:0] BallX[2],BallY[2], Collision_w, Collision_h,
				output logic slimOn[3],
				output logic [9:0] slim_row[3], slim_col[3],
				output logic [2:0] frame [3],
				output logic not_display[3],
				output logic dead[3]
				);

	logic [5:0] count_idle [3];
	logic [5:0] count_dead [3];
	logic [9:0] sprite_h, sprite_w, slimX[3], slimY[3];
	logic reach0[3], reach1[3]; 	// whether the player is near the slim
	// size of the sprite
	assign sprite_h = 16;
	assign sprite_w = 32;

genvar i;
generate
    for (i=0; i<3; i=i+1) 
	  begin : slim_on // <-- example block name
		 sprite_on slim_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(slimX[i]), .PosY(slimY[i]), 
								.width(sprite_w), .height(sprite_h), .on(slimOn[i]));
//		fight_slim fight0(.ft0(fight[0]),.ft1(fight[1]),.CLK(frame_clk),.reach0(reach0[i]), 
//								.reach1(reach1[i]), .RESET,.slim_dead(dead[i]));
		control_slim sm0(.ft0(fight[0]),.ft1(fight[1]),.CLK(frame_clk),.reach0(reach0[i]), 
						.reach1(reach1[i]), .RESET(RESET),.slim_dead(dead[i]));
	  end 
endgenerate


always_comb
	begin: pos_info
		slim_row[0] = 24;
		slim_col[0] = 10;
		slim_row[1] = 11;
		slim_col[1] = 18;
		slim_row[2] = 15;
		slim_col[2] = 24;
		
		// determine which animation frame
		for(int i = 0 ; i < 3 ; i++)
		begin
				if(dead[i] == 1'b1)
				begin
					unique case(count_dead[i][5:3])
						3'b000: frame[i] = 3'h5;
						3'b001: frame[i] = 3'h5;
						3'b010: frame[i] = 3'h6;
						3'b011: frame[i] = 3'h6;
						3'b100: frame[i] = 3'h0;
						3'b101: frame[i] = 3'h0;
						3'b110: frame[i] = 3'h1;
						3'b111: frame[i] = 3'h1;
					endcase
				end
				else
				begin
					if(count_idle[i][5:4] == 2'b00)	frame[i] = 3'h2;
					else if(count_idle[i][5:4] == 2'b01) frame[i] = 3'h3;
					else if(count_idle[i][5:4] == 2'b10) frame[i] = 3'h4;
					else	frame[i] = 3'h2;
				end
		
		end
				
				

			
		for (int i = 0; i < 3; i ++)
			begin
				slimX[i] = (slim_col[i]<<4);		// the top left point position of the sprite
				slimY[i] = (slim_row[i]<<4);		// used when calculate sprite_on
				// the top left point of the player collider
				reach1[i] = (BallX[1] + 25 > ((slim_col[i]<<4)-20) && BallX[1] + 25 < ((slim_col[i]<<4)+sprite_w + 20 )
					&& BallY[1]+7 > (slim_row[i]<<4)-Collision_h && BallY[1]+7 < (slim_row[i]<<4)+sprite_h);
				reach0[i] = (BallX[0] + 25 > ((slim_col[i]<<4)-20) && BallX[0] + 25 < ((slim_col[i]<<4)+sprite_w + 20 )
					&& BallY[0]+7 > (slim_row[i]<<4)-Collision_h && BallY[0]+7 < (slim_row[i]<<4)+sprite_h);
			end
	end
	
	always_ff@ (posedge RESET or posedge frame_clk)
		begin
			if(RESET) 
			begin
				count_idle[2] <= 6'b0;
				count_idle[1] <= 6'b0;
				count_idle[0] <= 6'b0;
				count_dead[2] <= 6'b0;
				count_dead[1] <= 6'b0;
				count_dead[0] <= 6'b0;
				not_display[2] <= 1'b0;
				not_display[1] <= 1'b0;
				not_display[0] <= 1'b0;
			end
			else 
			begin
				for(int i = 0 ; i < 3 ; i++)
				begin
					if((dead[i] == 1'b1) && (count_dead[i] == 6'hff))
						not_display[i] <= 1'b1;
					count_idle[i] <= count_idle[i] + 1'b1;
					if(dead[i] == 1'b1)	count_dead[i]<=count_dead[i] + 1'b1;
				end
			end
		end
	
endmodule
	

module control_slim (input logic ft0, ft1,
						input logic CLK,
						input logic reach0,reach1,
						input logic RESET,
						output logic slim_dead);
	
//		enum logic {idle,dead}curr_state, next_state;
//		
		logic d;
		assign d = (ft0 && reach0) || (ft1 && reach1);
		
		always_ff @(posedge RESET or posedge d)
		begin
				if(RESET)	slim_dead<=1'b0;
				else if(d)			slim_dead<=1'b1;
		end

endmodule
