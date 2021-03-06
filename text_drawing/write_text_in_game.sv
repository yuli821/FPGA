module write_text_in_game(input Clk, input Reset,
				input [6:0] team_in,
				input [2:0] team_addr,
				input we,
				input [9:0] DrawX, DrawY,
				input [6:0] score,
				input game_enable,
				output logic on);
			
	logic [10:0] sprite_addr[4], addr;
	logic [9:0] idx; // team name
	logic [7:0] sprite_data;
	logic [6:0] char_code; // in team name
	logic block_on [4];			// on text block
	logic ON[4];
	
	
	font_rom font(.addr(addr),.data(sprite_data));
	//fixed_text
	fixed_text fixed(.DrawX(DrawX), .DrawY(DrawY), .sprite_data(sprite_data), .sprite_addr(sprite_addr[0]),.on(ON[0]));
	sprite_on text_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(256), .PosY(16), .width(48), .height(32), .on(block_on[0]));
	// game title: adventure
	adventure adventure0(.DrawX(DrawX), .DrawY(DrawY), .sprite_data(sprite_data), 
							.sprite_addr(sprite_addr[2]),.on(ON[2]));
	sprite_on adventure_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(160), .PosY(192), .width(288), .height(64), .on(block_on[2]));
	//score
	score score0(.DrawX(DrawX), .DrawY(DrawY), .sprite_data(sprite_data), .score(score),
						.sprite_addr(sprite_addr[1]), .on(ON[1]));
	sprite_on score_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(320), .PosY(16), .width(16), .height(16), .on(block_on[1]));
	
	// team name 
		assign sprite_addr[3] = {char_code,DrawY[3:0]};	
		assign ON[3]=sprite_data[7-DrawX[2:0]];
	sprite_on name_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(320), .PosY(32), .width(56), .height(16), .on(block_on[3]));
	team_name name_reg(.data_In(team_in), .rd_address((DrawX >> 3)-39), .wr_address(team_addr), 
							.we(we), .Clk(Clk), .Reset(Reset), .data_Out(char_code));

	always_comb
	begin
		// fixed text
		if(block_on[0]) 
			begin
				addr = sprite_addr[0];
				on = ON[0];
			end
		// score
		else if(block_on[1])
			begin
				addr = sprite_addr[1];
				on = ON[1];
			end
		// adventure
		else if(block_on[2] && !game_enable)
			begin
				addr = sprite_addr[2];
				on = ON[2];
			end
		// team name
		else if(block_on[3])
			begin
				addr = sprite_addr[3];
				on = ON[3];
			end
		else
			begin
				addr = 0;
				on = 0;
			end
	end

endmodule

module fixed_text(input [9:0] DrawX, DrawY, 
						input [7:0] sprite_data,
						output logic [10:0] sprite_addr,
						output on);
	logic [9:0] idx, col_idx, row_idx;
	logic [6:0] char_code;
	
	textInGame textInGame0(.addr(idx),.data(char_code));

	always_comb
		begin
		col_idx = (DrawX >> 3)-32;	// 
		row_idx = (DrawY >> 4)-1;	// 
		idx = row_idx * 6 + col_idx; // idx of character 
		sprite_addr = {char_code,DrawY[3:0]};	
		on = sprite_data[7-DrawX[2:0]];
		end
		
endmodule

module score (input [9:0] DrawX, DrawY, 
						input [7:0] sprite_data,
						input [6:0] score,
						output logic [10:0] sprite_addr,
						output on);
	logic [9:0] idx;
	logic [6:0] char_code[2];
	
	write_number num(.number(score), .ch_code(char_code));
	
	always_comb
		begin
		idx = (DrawX >> 3)-40;
		sprite_addr = {char_code[idx],DrawY[3:0]};	
		on = sprite_data[7-DrawX[2:0]];
		end
						
endmodule

module write_number(input [6:0] number,
							output [6:0] ch_code[2]);
	always_comb 
	begin
		ch_code[0] = 7'h30 + number/10;
		ch_code[1] = 7'h30 + number%10;
	end
	
endmodule


module adventure (input [9:0] DrawX, DrawY, 
						input [7:0] sprite_data,
						output logic [10:0] sprite_addr,
						output on);
	logic [9:0] idx;
	logic [6:0] char_code;
	
	adventure_text adventure(.addr(idx),.data(char_code));
	
	always_comb
		begin
		idx = (DrawX >> 5)-5;
		sprite_addr = {char_code,DrawY[5:2]};	
		on = sprite_data[7-DrawX[4:2]];
		end
						
endmodule
