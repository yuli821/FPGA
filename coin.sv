module coin(input logic frame_clk, RESET, 
				input logic [9:0]DrawX, DrawY, BallX[2], BallY[2], Collision_w, Collision_h,
				output logic [9:0] coin_row[10], coin_col[10],
				output logic [2:0] frame,			// which frame the coin is on of the animation
				output logic on[10],					// whether the corrent drawing pixel is on the square
				output logic taken[10]);			// determine whether the coin should be displayed
	
	logic [5:0] count;
	logic [9:0] sprite_h, sprite_w, coinX[10], coinY[10];
	logic reach[10]; 	// whether the player is overlap with the coin
	// size of the sprite
	assign sprite_h = 24;
	assign sprite_w = 32;

genvar i;
generate
    for (i=0; i<10; i=i+1) 
	  begin : coin_on // <-- example block name
		 sprite_on coin_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(coinX[i]), .PosY(coinY[i]), 
								.width(sprite_w), .height(sprite_h), .on(on[i]));
		 pick_coin pick(.RESET(RESET), .reach(reach[i]), .taken(taken[i]));
	  end 
endgenerate


always_comb
	begin: pos_info
		coin_row[0] = 23;
		coin_col[0] = 10;
		coin_row[1] = 4;
		coin_col[1] = 18;
		coin_row[2] = 19;
		coin_col[2] = 20;
		coin_row[3] = 10;
		coin_col[3] = 3;
		coin_row[4] = 11;
		coin_col[4] = 2;
		coin_row[5] = 10;
		coin_col[5] = 5;
		coin_row[6] = 11;
		coin_col[6] = 4;
		coin_row[7] = 10;
		coin_col[7] = 38;
		coin_row[8] = 14;
		coin_col[8] = 2;
		coin_row[9] = 21;
		coin_col[9] = 38;
		
		// determine which animation frame
				unique case (count[5:3])
					3'b000: frame = 3'h0;
					3'b001: frame = 3'h0;
					3'b010: frame = 3'h0;
					3'b011: frame = 3'h1;
					3'b100: frame = 3'h2;
					3'b101: frame = 3'h3;
					3'b110: frame = 3'h4;
					3'b111: frame = 3'h5;
				endcase
			
		for (int i = 0; i < 10; i ++)
			begin
				coinX[i] = (coin_col[i]<<4)-8;		// the top left point position of the sprite
				coinY[i] = (coin_row[i]<<4)-10;		// used when calculate sprite_on
				// the top left point of the player collider
				reach[i] = (BallX[1]+25 > (coin_col[i]<<4) && BallX[1]+25 < (coin_col[i]<<4)+sprite_w
					&& BallY[1]+7 > (coin_row[i]<<4)-Collision_h && BallY[1]+7 < (coin_row[i]<<4)+sprite_h)
					|| (BallX[0]+25 > (coin_col[i]<<4) && BallX[0]+25 < (coin_col[i]<<4)+sprite_w 
					&& BallY[0]+7 > (coin_row[i]<<4)-Collision_h && BallY[0]+7 < (coin_row[i]<<4)+sprite_h);
			end
	end
	
	always_ff@ (posedge RESET or posedge frame_clk)
		begin
			if(RESET) count = 6'b0;
			else count <= count + 1'b1;
		end
	
	endmodule
	

module pick_coin (input reach, RESET, output logic taken);	
	always_ff@ (posedge RESET or posedge reach)
		begin
			if (RESET) taken <= 1'b0;
			else if (reach) taken <= 1'b1;
		end
endmodule
