module keycode_reader (input [7:0] keycode [6],
								output logic key[10]);
	// A	D	W	F	<-	->	/\	sp	en	esc
	//	0	1	2	3	4	5	6	7	8	9
	parameter [7:0] A		=	8'h04;
	parameter [7:0] D		=	8'h07;
	parameter [7:0] W		=	8'h1A;
	parameter [7:0] F		=	8'h09;
	parameter [7:0] left	=	8'h50;
	parameter [7:0] right=	8'h4F;
	parameter [7:0] up	=	8'h52;
	parameter [7:0] sp	=	8'h2C;
	parameter [7:0] enter=	8'h28;
	parameter [7:0] esc	=	8'h29;

		finder find0 (.keycode(keycode),.key(A),.have(key[0]));
		finder find1 (.keycode(keycode),.key(D),.have(key[1]));
		finder find2 (.keycode(keycode),.key(W),.have(key[2]));
		finder find3 (.keycode(keycode),.key(F),.have(key[3]));
		finder find4 (.keycode(keycode),.key(left),.have(key[4]));
		finder find5 (.keycode(keycode),.key(right),.have(key[5]));
		finder find6 (.keycode(keycode),.key(up),.have(key[6]));
		finder find7 (.keycode(keycode),.key(sp),.have(key[7]));
		finder find8 (.keycode(keycode),.key(enter),.have(key[8]));
		finder find9 (.keycode(keycode),.key(esc),.have(key[9]));
	
endmodule

module finder (input [7:0] keycode [6],
					input [7:0] key,
					output logic have);
	assign have = (keycode[0]==key) || (keycode[1]==key) || (keycode[2]==key) || (keycode[3]==key) || (keycode[4]==key) || (keycode[5]==key);
endmodule
