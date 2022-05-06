module RAM_audio
		(
			input [15:0] data_In,
			input [13:0] write_address, read_address,
			input we, Clk,

			output logic [15:0] data_Out
		);
			
	// mem has width of 24 bits and a total of 256 addresses
logic [15:0] mem [0:8957];

initial
begin
	 $readmemh("jump.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end


endmodule
