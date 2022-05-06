module color_decoder (input [4:0] index, output logic [23:0] color);
always_comb
begin
	unique case (index)
		0:		color = 24'h000000;
		1:		color = 24'h302C2E;
		2:		color = 24'hCBDBFC;
		3:		color = 24'hBCBCB8;
		4:		color = 24'h868686;
		5:		color = 24'hA0938E;
		6:		color = 24'h555459;
		7:		color = 24'h7D7071;
		8:		color = 24'h3A4542;
		9:		color = 24'h61412B;
		10:	color = 24'hAB765E;
		11:	color = 24'hBF7958;
		12:	color = 24'hF47E1B;
		13:	color = 24'hEEA160;
		14:	color = 24'hF4CCA1;
		15:	color = 24'hCFC6B8;
		16:	color = 24'hF4B41B;
		17:	color = 24'h368899;
		18:	color = 24'h9BADB7;
		19:	color = 24'h234075;
		20:	color = 24'h3A5B94;
		21:	color = 24'h588AE0;
		22:	color = 24'h3D3544;
		23:	color = 24'h34202B;
		24:	color = 24'h4B2C36;
		25:	color = 24'hAB293F;
		26:	color = 24'h8F3232;
		27:	color = 24'hA05B53;
		28:	color = 24'h7A444A;
		29:	color = 24'hD95763;
		30:	color = 24'hF57878;
		31:	color = 24'hE84646;
		32:	color = 24'h264074;
		33:	color = 24'hAFCBF4;
		34:	color = 24'hEB5151;
		35:	color = 24'h476395;
	endcase
end
		
endmodule
