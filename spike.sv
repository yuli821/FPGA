module spike(input logic frame_clk, RESET, 
				input logic [9:0]DrawX, DrawY,
				output logic [9:0] spike_row[3], spike_col[3],
				output logic [2:0] frame[3],			// which frame the spike is on of the animation
				output logic on[3],						// whether the current drawing pixel is on the square
				output logic harm[3]);					// whether the spike is harmful at this moment
				
	logic [6:0] count[3];
	logic [9:0] spite_h, spite_w;
	assign spite_h = 24;
	assign spite_w = 32;
				
genvar i;
generate
    for (i=0; i<3; i=i+1) 
	  begin : spike_on // <-- example block name
		 sprite_on spike_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(spike_col[i]<<4), .PosY((spike_row[i]-1)<<4), 
								.width(spite_w), .height(spite_h), .on(on[i]));
	  end 
endgenerate
		
		always_comb
		begin: pos_info
			spike_row[0] = 12;
			spike_col[0] = 10;
			spike_row[1] = 23;
			spike_col[1] = 25;
			spike_row[2] = 29;
			spike_col[2] = 20;
			// determine which animation frame, and whether the spike is harmful at the moment
			for (int i = 0; i < 3; i ++)
			begin
				if (count[i][6]==1'b0) frame[i] = 3'b000;
				else frame[i] = count[i][5:3];
				harm[i] = count[i][6];
			end
		end
		
		always_ff@ (posedge RESET or posedge frame_clk)
		begin
			if(RESET)
			begin
				count[2] <= 7'b0000000;		// 8 frame_clk per pic, half of time is clear
				count[1] <= 7'b0010010;
				count[0] <= 7'b0101000;
			end
			else
			begin
				for (int i = 0; i < 3; i ++)
					count[i] <= count[i]+1'b1;
			end
		end
endmodule
