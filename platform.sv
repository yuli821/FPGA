module platform(input frame_clk, RESET, buttonTrigger[2][4],
					input [9:0]DrawX, DrawY, 
					output logic [9:0] pfX[2], pfY[2], buttonX[4], buttonY[4], motion[2],
					output logic on[2], buttonOn[4]);
					
logic [9:0] col[2], rowup[2], rowdown[2];
logic trigger[2];

always_comb
begin
	trigger[0] = buttonTrigger[0][0] | buttonTrigger[1][0] | buttonTrigger[0][1] | buttonTrigger[1][1];
	trigger[1] = buttonTrigger[0][2] | buttonTrigger[1][2] | buttonTrigger[0][3] | buttonTrigger[1][3];
end

genvar i;
generate
    for (i=0; i<2; i=i+1) 
	  begin : pf_on // <-- example block name
		 sprite_on pf_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(pfX[i]), .PosY(pfY[i]), 
								.width(48), .height(16), .on(on[i]));
	  end 
endgenerate

genvar j;
generate
    for (j=0; j<4; j=j+1) 
	  begin : button_on // <-- example block name
		 sprite_on button_sprite(.DrawX(DrawX), .DrawY(DrawY), .PosX(buttonX[j]<<4), .PosY(buttonY[j]<<4), 
								.width(16), .height(4), .on(buttonOn[j]));
	  end 
endgenerate

always_comb
	begin: pos_info
		col[0]=1;
		rowup[0]=16;
		rowdown[0]=20;
		col[1]=36;
		rowup[1]=12;
		rowdown[1]=19;
		pfX[0]=col[0]<<4;
		pfX[1]=col[1]<<4;
		buttonX[0]=15;
		buttonY[0]=21;
		buttonX[1]=10;
		buttonY[1]=16;
		buttonX[2]=20;
		buttonY[2]=16;
		buttonX[3]=28;
		buttonY[3]=12;
	end

always_ff @ (posedge RESET or posedge frame_clk)
	begin
		if(RESET) for(int i=0; i<2; i++) pfY[i]<=rowup[i]<<4;
		else
			begin
				for(int i=0; i<2; i++)
					begin
						if(trigger[i])		// move toward the down position
							begin
								if(pfY[i]<(rowdown[i]<<4)) 
									begin
										pfY[i]<=pfY[i]+1;
										motion[i]<=1;
									end
								else 
									begin
										pfY[i]<=rowdown[i]<<4;
										motion[i]<=0;
									end
							end
						else					// move toward the up position
							begin
								if(pfY[i]>(rowup[i]<<4)) 
									begin
										pfY[i]<=pfY[i]-1;
										motion[i]=-1;
									end
								else 
									begin
										pfY[i]<=rowup[i]<<4;
										motion[i]<=0;
									end
							end
					end
			end
	end
endmodule
