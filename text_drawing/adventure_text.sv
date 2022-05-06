module adventure_text( input [3:0]	addr,
						output logic [6:0] data
					 );

	always_comb
	begin
		unique case (addr)
		  0: data=7'h41; // A  
        1: data=7'h44; // D
        2: data=7'h56; // V
		  3: data=7'h45; // E
        4: data=7'h4E; // N
        5: data=7'h54; // T
		  6: data=7'h55; // U
        7: data=7'h52; // R
        8: data=7'h45; // E
		 
		  default: data=7'h0;
		 endcase
	end

		  
endmodule