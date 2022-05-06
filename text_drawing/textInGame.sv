module textInGame ( input [3:0]	addr,
						output logic [6:0] data
					 );

	always_comb
	begin
		unique case (addr)
		  0: data=7'h73; // s  
        1: data=7'h63; // c
        2: data=7'h6f; // o
		  3: data=7'h72; // r
        4: data=7'h65; // e
        5: data=7'h3a; // :
		  6: data=7'h74; // t
        7: data=7'h65; // e
        8: data=7'h61; // a
		  9: data=7'h6d; // m
        10: data=7'h3a; // :
        11: data=7'h0; // 
		  default: data=7'h0;
		 endcase
	end
//	
//	assign data = ROM[addr];
//				
//	// ROM definition				
//	parameter [0:11][6:0] ROM = {
//        6'h73, // s
//        6'h63, // c
//        6'h6f, // o
//		  6'h72, // r
//        6'h65, // e
//        6'h3a, // :
//		  6'h74, // t
//        6'h65, // e
//        6'h61, // a
//		  6'h6d, // m
//        6'h3a, // :
//        6'h0 // 
//		};
		  
endmodule
