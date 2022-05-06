module heart
		(		
				input logic frame_clk, RESET, 
				input logic [9:0]DrawX, DrawY,
				input logic [1:0] life,
				input logic [9:0] heart_row[3], heart_col[3],
				output logic hearton[3]
		);
		
		logic isOn[3];
		logic [2:0] dis;
		logic [9:0] sprite_w, sprite_h, heartX[3], heartY[3];
		
		assign sprite_w = 16;
		assign sprite_h = 16;
		
		assign hearton[0] = isOn[0] & dis[0];
		assign hearton[1] = isOn[1] & dis[1];
		assign hearton[2] = isOn[2] & dis[2];
		
		genvar i;
		generate
			for(i=0 ; i<3; i=i+1)
			begin: heart_on
			
				sprite_on heart_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(heartX[i]),
						.PosY(heartY[i]), .width(sprite_w), .height(sprite_h), .on(isOn[i]));
			end
		
		endgenerate
		
		always_comb
		begin
			for(int i = 0 ; i < 3; i++)
			begin
				heartX[i] = (heart_col[i]<<4);		// the top left point position of the sprite
				heartY[i] = (heart_row[i]<<4);		// used when calculate sprite_on
			end
			
			unique case(life)
					2'b11: dis = 3'b111;
					2'b10: dis = 3'b011;
					2'b01: dis = 3'b001;
					2'b00: dis = 3'b000;
			endcase
	
		end
		
endmodule
