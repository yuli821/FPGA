module character(input Reset, frame_clk,
					input [7:0] keycode,
					input [29:0][39:0] tile,
               output [9:0]  chX, chY, chW, chH);
					
	logic [9:0] ch_X_Pos, ch_X_Motion, ch_Y_Pos, ch_Y_Motion, ch_width, ch_height;
	logic isTile_left, isTile_right, isTile_up, isTile_down;
	logic [4:0] row_u, row_d;
	logic [5:0] col_l, col_r;
	 
    parameter [9:0] ch_X_Center=80;  // upper left position on the X axis
    parameter [9:0] ch_Y_Center=64;  // upper left position on the Y axis
    parameter [9:0] ch_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] ch_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] ch_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] ch_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] ch_X_Step=1;      // Step size on the X axis
    parameter [9:0] ch_Y_Step=1;      // Step size on the Y axis

    assign ch_width = 23;
	 assign ch_height = 30;
	 assign row_u = ch_Y_Pos / 16;
	 assign col_l = ch_X_Pos / 16;
	 assign row_d = (ch_Y_Pos + ch_height) / 16;
	 assign col_r = (ch_X_Pos + ch_width) / 16;
	 assign isTile_left = tile[row_d][col_l] || tile[row_u][col_l];
	 assign isTile_right = tile[row_d][col_r] || tile[row_u][col_r];
	 assign isTile_down = tile[row_d][col_r] || tile[row_d][col_l];
	 assign isTile_up = tile[row_u][col_r] || tile[row_u][col_l];
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_character
        if (Reset)  // Asynchronous Reset
        begin 
            ch_Y_Motion <= 10'd0; //Ball_Y_Step;
				ch_X_Motion <= 10'd0; //Ball_X_Step;
				ch_Y_Pos <= ch_Y_Center;
				ch_X_Pos <= ch_X_Center;
        end
           
        else 
        begin 
				 if ( (ch_Y_Pos + ch_height) >= ch_Y_Max - 17 )  // Character is at the bottom edge, stop
					  ch_Y_Motion <= 10'b0;
					  
				 else if ( ch_Y_Pos <= ch_Y_Min + 17)  // Character is at the top edge, stop
					  ch_Y_Motion <= 10'b0;
					  
				  else if ( (ch_X_Pos + ch_width) >= ch_X_Max - 17 )  // Character is at the Right edge, stop
					  ch_X_Motion <= 10'b0;
					  
				 else if ( ch_X_Pos <= ch_X_Min + 17 )  // Character is at the Left edge, stop
					  ch_X_Motion <= 10'b0;
					  
//				 else 
//					  ch_Y_Motion <= ch_Y_Motion;  // Character is somewhere in the middle, don't bounce, just keep moving

				 
				 case (keycode)
					8'h04 : begin
								if(isTile_left)
									ch_X_Motion<= 0;
								else if ( ch_X_Pos > ch_X_Min)
									ch_X_Motion <= -1;//A
								ch_Y_Motion<= 0;
							  end
					        
					8'h07 : begin
								if(isTile_right)
									ch_X_Motion <= 0;
								else if ( (ch_X_Pos + ch_width) < ch_X_Max)
									ch_X_Motion <= 1;//D
							  ch_Y_Motion <= 0;
							  end

							  
					8'h16 : begin
								if(isTile_down)
									ch_Y_Motion <= 0;
								if ( (ch_Y_Pos + ch_height) < ch_Y_Max)
									ch_Y_Motion <= 1;//S
							  ch_X_Motion <= 0;
							  end
							  
					8'h1A : begin
								if(isTile_up)
									ch_Y_Motion <= 0;
								else if ( ch_Y_Pos > ch_Y_Min)
									ch_Y_Motion <= -1;//W
							  ch_X_Motion <= 0;
							  end	  
					default:begin
								
								ch_Y_Motion<=0;
								ch_X_Motion<=0;
							
							  end
			   endcase
				 
				 ch_Y_Pos <= (ch_Y_Pos + ch_Y_Motion);  // Update character position
				 ch_X_Pos <= (ch_X_Pos + ch_X_Motion);
			
		end  
    end
       
    assign chX = ch_X_Pos;
   
    assign chY = ch_Y_Pos;
   
    assign chW = ch_width;
	 
	 assign chH = ch_height;
    

endmodule
