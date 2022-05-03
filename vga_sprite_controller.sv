module vga_sprite_controller (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	input logic key[10],   //A:0 D:1 W:2 F:3 <-:4 ->:5 up:6 sp:7 en:8 esc:9
//	// Avalon-MM Slave Signals
//	input  logic AVL_READ,					// Avalon-MM Read
//	input  logic AVL_WRITE,					// Avalon-MM Write
//	input  logic AVL_CS,					// Avalon-MM Chip Select
//	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
//	input  logic [8:0] AVL_ADDR,			// Avalon-MM Address
//	input  logic [23:0] AVL_WRITEDATA,		// Avalon-MM Write Data
//	output logic [23:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic pixel_clk, blank, sync;
logic [9:0] DrawX, DrawY;
logic [23:0] Out, tile_Out;
logic [7:0] read;
logic [3:0] col, row;
logic [5:0] col_s;
logic [4:0] row_s;
logic [0:29][0:39] Tile;
logic [7:0] Red, Green, Blue;
logic tile_on;
logic [9:0] chX, chY, chW, chH;
logic move_x_dir;

assign col = DrawX % 16;
assign row = DrawY % 16;
assign col_s = DrawX / 16;
assign row_s = DrawY / 16;
assign read = row * 16 + col;
assign tile_on = Tile[row_s][col_s];

vga_controller con(.Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), .pixel_clk(pixel_clk),
							.blank(blank), .sync(sync), .DrawX(DrawX), .DrawY(DrawY));

frameRAM ram0(.data_In(), .write_address(), .read_address(read),
			.we(1'b0), .Clk(CLK), .data_Out(Out));
			
frameRAM_tile tile(.data_In(), .write_address(), .read_address(read), 
			.we(1'b0), .Clk(CLK), .data_Out(tile_Out));
			
tile_rom rom(.Tile);

//character ch(.Reset(RESET), .frame_clk(vs), .tile(Tile), .keycode(keycode), .chX(chX), 
//				.chY(chY), .chW(chW), .chH(chH));

ball b0(.Reset(RESET), .frame_clk(vs), .move_up(key[2]), .move_left(key[0]),.move_right(key[1]),
		.tile(Tile), .Ball_X(chX), .Ball_Y(chY), .BallH(chH), .BallW(chW),.move_x_dir(move_x_dir)); 

logic character_on;
logic [23:0] character_Out;
logic [9:0] character_read;
logic [9:0] DistX, DistY;

always_comb
	begin
		DistX = DrawX - chX;
		DistY = DrawY - chY;
		if(!move_x_dir) character_read = DistY * 23 + DistX;
		else character_read = DistY  * 23 + 22 - DistX;
	end
	  
	  
frameRAM_character character0(.data_In(), .write_address(), .read_address(character_read),
										.we(1'b0), .Clk(CLK), .data_Out(character_Out));
										
always_comb
   begin:ch_on_proc
      if ( DrawX <= chX + chW && DrawX >= chX && DrawY <= chY + chH && DrawY >= chY) 
          character_on = 1'b1;
      else 
			 character_on = 1'b0;
   end 

			
always_comb
begin: VGA_display
		
		Red = tile_Out[23:16];
		Green = tile_Out[15:8];
		Blue = tile_Out[7:0];
		if (blank == 1'b0)//blank is active low, and should be the first of the if statement
		begin
			Red = 8'b0;//display black
			Green = 8'b0;
			Blue = 8'b0;
		end
		else if ((character_on == 1'b1) && !(character_Out[23:16] == 8'hff) && !(character_Out[23:16] == 8'h00)) 
      begin 
         Red = character_Out[23:16];
			Green = character_Out[15:8];
			Blue = character_Out[7:0];
      end    
		else if(tile_on)
		begin
			Red = Out[23:16];
			Green = Out[15:8];
			Blue = Out[7:0];
		end

end
			
always_ff @ (posedge pixel_clk)
begin

		red<=Red[7:4];
		green<=Green[7:4];
		blue<=Blue[7:4];

end
			
endmodule
