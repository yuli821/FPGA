module vga_sprite_controller (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	input logic key[10],   //A:0 D:1 W:2 F:3 <-:4 ->:5 up:6 sp:7 en:8 esc:9
	input logic [7:0]keycode,
	
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,						// VGA HS/VS
	output logic [3:0] score
);

logic pixel_clk, blank, sync;
logic [9:0] DrawX, DrawY;
logic [7:0] Red, Green, Blue;
logic [6:0] score_num;
logic game_enable,game_end;

// color output
logic [4:0] color_idx, Out, tile_Out, spike_Out[3], coin_Out[10],pf_Out[2], door_Out[2];	
logic [23:0] color;

// tile
logic [7:0] tile_rd_addr;		// pixel idx		
logic [9:0] col, row;			// inside a tile (pixel row/col idx)
logic [9:0] col_tile;			// tile idx
logic [9:0] row_tile;
logic [0:29][0:39] Tile;
logic tile_on;

// spike
logic [12:0] spike_rd_addr[3];
logic [2:0] spike_fr[3];
logic [9:0] spike_row[3], spike_col[3];	// spike position (tile index)
logic [9:0]	col_s_p[3], row_s_p[3];				// inside 
logic spike_on[3], spike_harm[3];

// coin
logic [12:0] coin_rd_addr[10];
logic [2:0] coin_fr;
logic [9:0] coin_row[10], coin_col[10];	// coin position (tile index)
logic [9:0]	col_c_p[10], row_c_p[10];				// inside 
logic coin_on[10], taken[10];

// platform
logic [9:0] pfX[2], pfY[2], buttonX[4], buttonY[4], buttonMotion[2];
logic [9:0] pf_rd_addr[2];
logic trigger[2], pf_on[2], buttonOn[4], buttonTrigger[2][4];

// characters
logic fight[2];
logic [9:0] chX[2], chY[2], chW, chH, Collision_w, Collision_h;
logic move_x_dir[2], dead[2];
logic character_on[2];
logic [4:0] character_Out[2];
logic [14:0] character_read[2];
logic [3:0] character_fr[2];
logic [9:0] DistX[2], DistY[2]; // distance between the drawing pixel and the top left point of the sprite
logic harm_state[2];
logic [1:0] life0, life1;

//doors
logic [10:0] door_read[2];
logic [9:0] door_row[2], door_col[2];   //door position
logic [9:0] col_d_p[2], row_d_p[2];        //inside
logic door_reach[2],door_on[2];

//slim
logic [4:0] slim_idle_out[3];
logic [11:0] slim_idle_read[3];
logic slim_on[3];
logic [9:0] slim_row[3], slim_col[3];
logic [9:0] col_sm_p[3], row_sm_p[3];
logic [2:0] slim_fr[3];
logic slim_not_display[3];
logic slim_dead[3];

//heart
logic [7:0] heart_address0 [3], heart_address1 [3];
logic [4:0] heart_Out0 [3], heart_Out1 [3];
logic heart_on0 [3], heart_on1 [3];
logic [9:0] heart_row0[3], heart_col0[3], heart_row1[3], heart_col1[3];
logic [9:0] col_ht_p0[3], row_ht_p0[3], col_ht_p1[3], row_ht_p1[3];

assign fight[0] = key[3];
assign fight[1] = key[7];

assign heart_row0[0] = 1;
assign heart_col0[0] = 2;
assign heart_row0[1] = 1;
assign heart_col0[1] = 3;
assign heart_row0[2] = 1;
assign heart_col0[2] = 4;
assign heart_row1[0] = 1;
assign heart_col1[0] = 34;
assign heart_row1[1] = 1;
assign heart_col1[1] = 35;
assign heart_row1[2] = 1;
assign heart_col1[2] = 36;


always_comb
begin: rd_addr_calculate
	
	col = DrawX[3:0];
	row = DrawY[3:0];
	col_tile = DrawX >> 4;
	row_tile = DrawY >> 4;
	tile_rd_addr = (row << 4) + col;
	tile_on = Tile[row_tile][col_tile];
	
	// spike
	for (int i = 0; i < 3; i ++)
	begin
		row_s_p[i] = DrawY-((spike_row[i]-1)<<4);		// top: (row_idx-1)*16
		col_s_p[i] = DrawX-(spike_col[i]<<4);			// left: col_idx*16
		spike_rd_addr[i] = (row_s_p[i] << 8) + (spike_fr[i] << 5) + col_s_p[i]; // 256; 32
	end
	
	// coin
	for (int i = 0; i < 10; i ++)
	begin
		row_c_p[i] = DrawY-((coin_row[i]<<4)-10);		// top: (row_idx)*16
		col_c_p[i] = DrawX-((coin_col[i]<<4)-8);			// left: col_idx*16
		coin_rd_addr[i] = ((row_c_p[i] << 5) * 6) + (coin_fr << 5) + col_c_p[i]; // 256; 32
	end
	
	// platform
	for (int i = 0; i < 2; i ++)
	begin
		pf_rd_addr[i] = (DrawY-pfY[i] << 4)*3  + DrawX-pfX[i];
	end
	
	//door
	for(int i = 0; i < 2; i++)
	begin
		
		row_d_p[i] = DrawY-((door_row[i]-1)<<4);
		col_d_p[i] = DrawX-(door_col[i]<<4);
		door_read[i] = (row_d_p[i]<<6) + (door_reach[i]<<5) + col_d_p[i];
	end
	
	//slim
	for(int i = 0; i < 3; i++)
	begin
		
		row_sm_p[i] = DrawY-((slim_row[i]-1)<<4);
		col_sm_p[i] = DrawX-(slim_col[i]<<4);
		slim_idle_read[i] = ((row_sm_p[i]<<5)*7) + (slim_fr[i]<<5) + col_sm_p[i];
	end
	
	//heart0
	for(int i = 0; i < 3; i++)
	begin
		
		row_ht_p0[i] = DrawY-((heart_row0[i]-1)<<4);
		col_ht_p0[i] = DrawX-(heart_col0[i]<<4);
		heart_address0[i] = ((row_ht_p0[i]<<4)) + col_ht_p0[i];
	
	end
	
	//heart1
	for(int i = 0; i < 3; i++)
	begin
		
		row_ht_p1[i] = DrawY-((heart_row1[i]-1)<<4);
		col_ht_p1[i] = DrawX-(heart_col1[i]<<4);
		heart_address1[i] = ((row_ht_p1[i]<<4)) + col_ht_p1[i];
	
	end
	
end


always_comb
	begin: ch_read
	for (int i = 0; i < 2; i ++)
		begin
			DistX[i] = DrawX - chX[i];
			DistY[i] = DrawY - chY[i];
			
			if(!move_x_dir[i]) character_read[i] = DistY[i] * chW * 10 + character_fr[i] * chW + DistX[i]; // 4: the total frame number
			else character_read[i] = DistY[i] * chW * 10 + character_fr[i] * chW + chW-1 - DistX[i];
		end	
	end

vga_controller con(.Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), .pixel_clk(pixel_clk),
							.blank(blank), .sync(sync), .DrawX(DrawX), .DrawY(DrawY));

// background
frameRAM ram0(.data_In(), .write_address(), .read_address(tile_rd_addr),
			.we(1'b0), .Clk(CLK), .data_Out(Out));

// tile
frameRAM_tile tile(.data_In(), .write_address(), .read_address(tile_rd_addr), 
			.we(1'b0), .Clk(CLK), .data_Out(tile_Out));
			
tile_rom rom(.Tile);

// platform
platform pt(.frame_clk(vs), .RESET(RESET), .buttonTrigger(buttonTrigger), .DrawX(DrawX), .DrawY(DrawY),
				.pfX(pfX), .pfY(pfY), .buttonX(buttonX), .buttonY(buttonY), .motion(buttonMotion),
				.on(pf_on), .buttonOn(buttonOn));
frameRAM_platform pf_rom0(.data_In(), .write_address(), .read_address(pf_rd_addr[0]), 
			.we(1'b0), .Clk(CLK), .data_Out(pf_Out[0]));
frameRAM_platform pf_rom1(.data_In(), .write_address(), .read_address(pf_rd_addr[1]), 
			.we(1'b0), .Clk(CLK), .data_Out(pf_Out[1]));
			

//door			
frameRAM_door door_rom0(.data_In(), .write_address(), .read_address(door_read[0]),
			.we(1'b0),.Clk(CLK), .data_Out(door_Out[0]));
			
frameRAM_door door_rom1(.data_In(), .write_address(), .read_address(door_read[1]),
			.we(1'b0),.Clk(CLK), .data_Out(door_Out[1]));

door door0(.frame_clk(vs), .RESET, .DrawX, .DrawY, .BallX(chX), .BallY(chY),
				.Collision_w, .Collision_h, .door_row, .door_col, .reach(door_reach),
				.on(door_on));
				
//slim
frameRAM_slim_idle slim_idle_rom0(.data_In(), .wirte_address(), 
		.read_address(slim_idle_read[0]),.we(1'b0), .Clk(CLK), .data_Out(slim_idle_out[0]));
					
frameRAM_slim_idle slim_idle_rom1(.data_In(), .wirte_address(), 
		.read_address(slim_idle_read[1]),.we(1'b0), .Clk(CLK), .data_Out(slim_idle_out[1]));

frameRAM_slim_idle slim_idle_rom2(.data_In(), .wirte_address(), 
		.read_address(slim_idle_read[2]),.we(1'b0), .Clk(CLK), .data_Out(slim_idle_out[2]));
		
slim m0(.frame_clk(vs), .RESET(RESET), .DrawX, .DrawY, .BallX(chX), .BallY(chY), .fight,
			.Collision_w, .Collision_h, .slimOn(slim_on), .slim_row, .slim_col,
			.frame(slim_fr), .not_display(slim_not_display), .dead(slim_dead));

			
//heart
ram_heart h0(.data_In(), .write_address(), .read_address(heart_address0[0]),
				.we(1'b0),.Clk(CLK), .data_Out(heart_Out0[0]));

ram_heart h1(.data_In(), .write_address(), .read_address(heart_address0[1]),
				.we(1'b0),.Clk(CLK), .data_Out(heart_Out0[1]));

ram_heart h2(.data_In(), .write_address(), .read_address(heart_address0[2]),
				.we(1'b0),.Clk(CLK), .data_Out(heart_Out0[2]));
				
ram_heart h3(.data_In(), .write_address(), .read_address(heart_address1[0]),
				.we(1'b0),.Clk(CLK), .data_Out(heart_Out1[0]));
			
ram_heart h4(.data_In(), .write_address(), .read_address(heart_address1[1]),
				.we(1'b0),.Clk(CLK), .data_Out(heart_Out1[1]));
				
ram_heart h5(.data_In(), .write_address(), .read_address(heart_address1[2]),
				.we(1'b0),.Clk(CLK), .data_Out(heart_Out1[2]));
				
heart heart0(.frame_clk(vs), .RESET, .DrawX, .DrawY,.life(life0), .heart_row(heart_row0),
				.heart_col(heart_col0), .hearton(heart_on0));
				
heart heart1(.frame_clk(vs), .RESET, .DrawX, .DrawY,.life(life1), .heart_row(heart_row1),
				.heart_col(heart_col1), .hearton(heart_on1));
			


//coins
genvar i;
generate
    for (i=0; i<10; i=i+1) 
	  begin : coin_rom // <-- example block name
		 frameRAM_coin coin_rom(.data_In(), .write_address(), .read_address(coin_rd_addr[i]), 
			.we(1'b0), .Clk(CLK), .data_Out(coin_Out[i]));
	  end 
endgenerate

coin coin0(.frame_clk(vs), .RESET(RESET), .DrawX(DrawX), .DrawY(DrawY),
				.BallX(chX), .BallY(chY), .Collision_w(Collision_w), .Collision_h(Collision_h),
				.coin_row(coin_row), .coin_col(coin_col), .frame(coin_fr), .on(coin_on), .taken(taken));

//spikes
genvar j;
generate
    for (j=0; j<3; j=j+1) 
	  begin : spike_rom // <-- example block name
		 frameRAM_spike spike_rom(.data_In(), .write_address(), .read_address(spike_rd_addr[j]), 
			.we(1'b0), .Clk(CLK), .data_Out(spike_Out[j]));
	  end 
endgenerate

spike spike0(.frame_clk(vs), .RESET(RESET), .DrawX(DrawX), .DrawY(DrawY),
				.spike_row(spike_row), .spike_col(spike_col), .frame(spike_fr), .on(spike_on), .harm(spike_harm));

// players
ball ch1(.Reset(RESET), .frame_clk(vs), .move_up(key[2]&game_enable), .move_left(key[0]&game_enable),.move_right(key[1]&game_enable), .init_X(48), .init_Y(436),//48, 436
		.tile(Tile), .spike_row(spike_row), .spike_col(spike_col), .spike_harm(spike_harm), .slim_row, .slim_col, .slim_dead,
		.buttonX(buttonX), .buttonY(buttonY), .buttonOn(buttonTrigger[0]), .buttonMotion(buttonMotion),
		.pfX(pfX), .pfY(pfY),
		.Ball_X(chX[0]), .Ball_Y(chY[0]), .BallH(chH), .BallW(chW), .Collision_w(Collision_w), .Collision_h(Collision_h),
		.move_x_dir(move_x_dir[0]), .dead(dead[0]), .frame(character_fr[0]), .harm_state(harm_state[0]),
		.harm(life0)); 

ball ch2(.Reset(RESET), .frame_clk(vs), .move_up(key[6]&game_enable), .move_left(key[4]&game_enable),.move_right(key[5]&game_enable), .init_X(48), .init_Y(372),
		.tile(Tile), .spike_row(spike_row), .spike_col(spike_col), .spike_harm(spike_harm), .slim_row, .slim_col, .slim_dead,
		.buttonX(buttonX), .buttonY(buttonY), .buttonOn(buttonTrigger[1]), .buttonMotion(buttonMotion),
		.pfX(pfX), .pfY(pfY),
		.Ball_X(chX[1]), .Ball_Y(chY[1]), .BallH(), .BallW(), .Collision_w(), .Collision_h(),
		.move_x_dir(move_x_dir[1]), .dead(dead[1]), .frame(character_fr[1]), .harm_state(harm_state[1]),
		.harm(life1)); 

	  
frameRAM_character character0(.data_In(), .write_address(), .read_address(character_read[0]),
										.we(1'b0), .Clk(CLK), .data_Out(character_Out[0]));

frameRAM_character character1(.data_In(), .write_address(), .read_address(character_read[1]),
										.we(1'b0), .Clk(CLK), .data_Out(character_Out[1]));
										
sprite_on ch_on_proc_0(.DrawX(DrawX), .DrawY(DrawY), .PosX(chX[0]), .PosY(chY[0]), 
								.width(chW), .height(chH), .on(character_on[0]));
								
sprite_on ch_on_proc_1(.DrawX(DrawX), .DrawY(DrawY), .PosX(chX[1]), .PosY(chY[1]), 
								.width(chW), .height(chH), .on(character_on[1]));

color_decoder color_decoder0(.index(color_idx),.color(color));

logic [2:0]team_addr;
logic team_name_we;
logic [7:0]key_input;

// text
write_text_in_game text(.Clk(vs), .Reset(RESET), 
								.team_in(key_input+61), .team_addr(team_addr), .we(team_name_we),
								.DrawX(DrawX), .DrawY(DrawY), .score(score_num), .on(text_on), .game_enable(game_enable));

// game_state
game_state control(.Clk(Clk), .Reset(RESET),
						.game_end(1'b0), //(door_reach[1]&door_reach[0])|(~heart_on0[0]&~heart_on0[1]&~heart_on0[2]&~heart_on1[0]&~heart_on1[1]&~heart_on1[2])
						.keycode(keycode), .we(team_name_we), .addr(team_addr),
						.game_enable(game_enable), .state(), .key_input(key_input));
			
			
always_comb
begin: VGA_display

		color_idx = tile_Out;
		if (blank == 1'b0)//blank is active low, and should be the first of the if statement
			color_idx = 0; // display black
		else if (text_on)
			color_idx = 14;
		else if(!game_enable) color_idx = 0;
		//spike
		else if ((spike_on[0] == 1'b1) && !(spike_Out[0] == 5'h0)) 
			color_idx = spike_Out[0]; 
		else if ((spike_on[1] == 1'b1) && !(spike_Out[1] == 5'h0)) 
			color_idx = spike_Out[1]; 
		else if ((spike_on[2] == 1'b1) && !(spike_Out[2] == 5'h0)) 
			color_idx = spike_Out[2];
		//coin
		else if ((coin_on[0] == 1'b1) && (taken[0] == 1'b0) && !(coin_Out[0] == 5'h0)) 
			color_idx = coin_Out[0]; 
		else if ((coin_on[1] == 1'b1) && (taken[1] == 1'b0) && !(coin_Out[1] == 5'h0)) 
			color_idx = coin_Out[1]; 
		else if ((coin_on[2] == 1'b1) && (taken[2] == 1'b0) && !(coin_Out[2] == 5'h0)) 
			color_idx = coin_Out[2];
		else if ((coin_on[3] == 1'b1) && (taken[3] == 1'b0) && !(coin_Out[3] == 5'h0)) 
			color_idx = coin_Out[3]; 
		else if ((coin_on[4] == 1'b1) && (taken[4] == 1'b0) && !(coin_Out[4] == 5'h0)) 
			color_idx = coin_Out[4]; 
		else if ((coin_on[5] == 1'b1) && (taken[5] == 1'b0) && !(coin_Out[5] == 5'h0)) 
			color_idx = coin_Out[5];
		else if ((coin_on[6] == 1'b1) && (taken[6] == 1'b0) && !(coin_Out[6] == 5'h0)) 
			color_idx = coin_Out[6]; 
		else if ((coin_on[7] == 1'b1) && (taken[7] == 1'b0) && !(coin_Out[7] == 5'h0)) 
			color_idx = coin_Out[7]; 
		else if ((coin_on[8] == 1'b1) && (taken[8] == 1'b0) && !(coin_Out[8] == 5'h0)) 
			color_idx = coin_Out[8];
		else if ((coin_on[9] == 1'b1) && (taken[9] == 1'b0) && !(coin_Out[9] == 5'h0)) 
			color_idx = coin_Out[9];
		//platform
		else if ((pf_on[0] == 1'b1) && !(pf_Out[0] == 5'h0)) 
			color_idx = pf_Out[0];//pf_Out[0];
		else if ((pf_on[1] == 1'b1) && !(pf_Out[1] == 5'h0)) 
			color_idx = pf_Out[1];//pf_Out[1];
		//slim
		else if((slim_on[0] == 1'b1) && (slim_not_display[0] == 1'b0) && !(slim_idle_out[0] == 5'h0))
			color_idx = slim_idle_out[0];
		else if((slim_on[1] == 1'b1) && (slim_not_display[1] == 1'b0) && !(slim_idle_out[1] == 5'h0))
			color_idx = slim_idle_out[1];
		else if((slim_on[2] == 1'b1) && (slim_not_display[2] == 1'b0) && !(slim_idle_out[2] == 5'h0))
			color_idx = slim_idle_out[2];
		//button
		else if (buttonOn[0] == 1'b1)
			color_idx = 30;
		else if (buttonOn[1] == 1'b1)
			color_idx = 30;
		else if (buttonOn[2] == 1'b1)
			color_idx = 9;
		else if (buttonOn[3] == 1'b1)
			color_idx = 9;
		
		//character
		else if ((character_on[0] == 1'b1) && !(character_Out[0] == 5'h0)) 
         begin
				if(dead[0]) color_idx = 0;
				else if(harm_state[0] == 1'b1)	color_idx = 10;//harm state color
				else color_idx = character_Out[0];
			end
		else if ((character_on[1] == 1'b1) && !(character_Out[1] == 5'h0)) 
			begin
				if(dead[1]) color_idx = 0;
				else if(harm_state[1] == 1'b1)   color_idx = 10;//harm state color
				else color_idx = character_Out[1];
			end
		//door
		else if ((door_on[0] == 1'b1) && !(door_Out[0] == 5'h0))
			begin
				color_idx = door_Out[0];
			end
		else if ((door_on[1] == 1'b1) && !(door_Out[1] == 5'h0))
			begin
				color_idx = door_Out[1];
			end
			
		//heart
		else if(heart_on0[0] == 1'b1 && !(heart_Out0[0] == 5'h0)) 
				color_idx = heart_Out0[0];
		else if(heart_on0[1] == 1'b1 && !(heart_Out0[1] == 5'h0)) 
				color_idx = heart_Out0[1];
		else if(heart_on0[2] == 1'b1 && !(heart_Out0[2] == 5'h0)) 
				color_idx = heart_Out0[2];
		else if(heart_on1[0] == 1'b1 && !(heart_Out1[0] == 5'h0)) 
				color_idx = heart_Out1[0];
		else if(heart_on1[1] == 1'b1 && !(heart_Out1[1] == 5'h0)) 
				color_idx = heart_Out1[1];
		else if(heart_on1[2] == 1'b1 && !(heart_Out1[2] == 5'h0)) 
				color_idx = heart_Out1[2];
		
		else if(tile_on)
			color_idx = Out;
			
		// color palette decoder
		Red = color[23:16];
		Green = color[15:8];
		Blue = color[7:0];
end
			
always_ff @ (posedge pixel_clk)
begin
		red<=Red[7:4];
		green<=Green[7:4];
		blue<=Blue[7:4];

end

assign score_num = (taken[0] + taken[1] + taken[2] + taken[3] + taken[4] 
		+ taken[5] + taken[6] + taken[7] + taken[8] + taken[9]) * 7
		+ (slim_dead[0] + slim_dead[1] + slim_dead[2])*2;			
endmodule
