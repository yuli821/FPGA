module door(input logic frame_clk, RESET, 
				input logic [9:0] DrawX, DrawY, BallX[2], BallY[2], Collision_w, Collision_h,
				output logic [9:0] door_row[2], door_col[2],
				output logic reach[2],
				output logic on[2]);
				
		logic	[9:0] door_w, door_h;
		assign door_w = 32;
		assign door_h = 32;
		
genvar i;
generate
    for (i=0; i<2; i=i+1) 
	  begin : door_on // <-- example block name
		 sprite_on door_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(door_col[i]<<4), 
							.PosY((door_row[i]-1)<<4), .width(door_w), 
							.height(door_h), .on(on[i]));
	  end 
endgenerate
				
		always_comb
		begin: pos_info
			door_row[0] = 5;
			door_col[0] = 33;
			door_row[1] = 5;
			door_col[1] = 35;
			// determine which animation frame, and whether the character on the door
			for (int i = 0; i < 2; i ++)
			begin
				reach[i] = (BallX[1]+25 > (door_col[i]<<4) && BallX[1]+25 < (door_col[i]<<4)+door_w
				&& BallY[1]+7 > (door_row[i]<<4)-Collision_h && BallY[1]+7 < (door_row[i]<<4)+door_h)
				|| (BallX[0]+25 > (door_col[i]<<4) && BallX[0]+25 < (door_col[i]<<4)+door_w 
				&& BallY[0]+7 > (door_row[i]<<4)-Collision_h && BallY[0]+7 < (door_row[i]<<4)+door_h);
			end
			
			
		end


endmodule
