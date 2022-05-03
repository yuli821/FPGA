module color_mapper(input logic [9:0] chX, chY, DrawX, DrawY, chW, chH,
							input logic Clk,
							input logic [7:0] bkg_r, bkg_g, bkg_b,
                       output logic [7:0]  Red, Green, Blue );
							  
							  
	logic character_on;
	logic [23:0] Out;
	logic [9:0] read;
	  
	 assign read = (DrawY - chX) * 23 + DrawX - chY;
    int DistX, DistY;
	 assign DistX = DrawX - chX;
    assign DistY = DrawY - chY;
	  
	  
	 frameRAM_character character(.data_In(), .write_address(), .read_address(read),
											.we(1'b0), .Clk, .data_Out(Out));
    always_comb
    begin:ch_on_proc
        if ( DistX <= chW && DistX >= 0 && DistY <= chH && DistY >= 0) 
            character_on = 1'b1;
        else 
				character_on = 1'b0;
     end 
       
    always_comb
    begin:RGB_Display
        if ((character_on == 1'b1) && !(Out[23:16] == 8'hff)) 
        begin 
            Red = Out[23:16];
				Green = Out[15:8];
				Blue = Out[7:0];
        end       
        else 
        begin 
            Red = bkg_r; 
            Green = bkg_g;
            Blue = bkg_b;
        end      
    end 
    
endmodule
