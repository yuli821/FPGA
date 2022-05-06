module slim_dead( input logic frame_clk, RESET,
						input logic [9:0] DrawX, DrawY,
						input logic [9:0] slim_row[3], slim_col[3],
						input logic dead[3],
						output logic slimDeadOn[3],
						output logic [2:0] frame,
						output logic display[3]);


	logic [5:0] count;
	logic [9:0] sprite_h, sprite_w, slimX[3], slimY[3];
	assign sprite_h = 16;
	assign sprite_w = 32;
	
	genvar i;
	generate
		 for (i=0; i<3; i=i+1) 
		  begin : slim_dead_on // <-- example block name
			 sprite_on slim_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(slimX[i]), .PosY(slimY[i]), 
									.width(sprite_w), .height(sprite_h), .on(slimDeadOn[i]));
			 fsm f0(.dead(dead[i]), .CLK(frame_clk), .RESET, .display(display[i]));
		  end 
	endgenerate
	
	always_comb
	begin
		unique case (count[5:3])
					3'b000: frame = 3'h0;
					3'b001: frame = 3'h0;
					3'b010: frame = 3'h1;
					3'b011: frame = 3'h1;
					3'b100: frame = 3'h2;
					3'b101: frame = 3'h3;
					3'b110: frame = 3'h4;
				endcase
		for (int i = 0; i < 3; i ++)
			begin
				slimX[i] = (slim_col[i]<<4);		// the top left point position of the sprite
				slimY[i] = (slim_row[i]<<4);		// used when calculate sprite_on
			end
		
	end
	
	always_ff@ (posedge RESET or posedge frame_clk)
		begin
			if(RESET) count = 6'b0;
			else if(frame == 3'h4)	count <= count;
			else count <= count + 1'b1;
		end
		
endmodule

module fsm(input logic dead, input logic CLK,RESET, output logic display);

	enum logic {dis, not_display} curr_state, next_state;
	always_ff @(posedge Clk)
		begin
				curr_state <= next_state;
		end
		
	always_comb
		begin
				next_state = curr_state;
				unique case(curr_state)
				
					dis: 					if(RESET) next_state = not_display;
					not_display:		if(dead) next_state = dis;
				
				endcase
				
				case(curr_state)
				
					dis:				display = 1'b1;
					not_display:   display = 1'b0;
					
				endcase
		end

endmodule
