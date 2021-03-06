module team_name
(
		input [6:0] data_In,	// char code
		input [2:0] rd_address,
		input [2:0] wr_address,
		input we, Clk, Reset,

		output logic [6:0] data_Out
);

logic [6:0] mem [0:7];
always_ff @ (posedge Clk or posedge we)// or posedge Reset)// or posedge we) 
begin
//		begin
//			mem[0]<=7'h61;
//			mem[1]<=7'h62;
//			mem[2]<=7'h63;
//			mem[3]<=7'h64;
//			mem[4]<=7'h65;
//			mem[5]<=7'h66;
//			mem[6]<=7'h67;
//			mem[7]<=7'h68;
//		end
	if (we) mem[wr_address] <= data_In;
	else if (Reset) for(int i=0; i<8; i++) mem[i]<=0;
	data_Out<= mem[rd_address];
end

endmodule