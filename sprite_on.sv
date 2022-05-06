/* given the position of the currently drawing pixel: (DrawX, DrawY), 
 * and the position (top left pixel coordinate) and the size of the sprite
 * calculate whether the currently drawing pixel is on the sprite
 */

module sprite_on(input [9:0] DrawX, DrawY, PosX, PosY, width, height,
					output logic on);
always_comb
   begin
      if ( DrawX <= PosX + width && DrawX >= PosX && DrawY <= PosY + height && DrawY >= PosY) 
          on = 1'b1;
      else 
			 on = 1'b0;
   end 
					
endmodule
