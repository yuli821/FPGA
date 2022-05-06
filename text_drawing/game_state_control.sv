module game_state(input Clk, Reset, game_end, 
							input  [7:0]keycode,
							output logic we, game_enable,
							output logic [4:0] state,
							output logic [2:0] addr,
							output logic [7:0] key_input
							);

	enum logic [4:0] {reset, read_key1, wait_key1, read_key2, wait_key2, read_key3, wait_key3, 
							read_key4, wait_key4, read_key5, wait_key5, read_key6, wait_key6, read_key7, wait_key7, 
							read_key8, wait_key8, 
							wait_key01, wait_key02, wait_key03, wait_key04, wait_key05, wait_key06, wait_key07, wait_key08, 
							game, fin} 
							curr_state, next_state; 
	assign state = curr_state;
	assign key_input = curr_key;
	parameter [7:0] ent = 40;
	logic [7:0] curr_key, next_key;

	 always_ff @ (posedge Clk)  
    begin
        if (Reset)
				begin
            curr_state <= reset;
				curr_key <= 0;
				end
        else 
            curr_state <= next_state;
				curr_key <= next_key;
    end
	 
	 always_comb
    begin
		  next_state  = curr_state;	//required because I haven't enumerated all possibilities below
		  next_key = curr_key;
		  case (curr_state)
				read_key2, read_key3, read_key4, read_key5, read_key6, read_key7, read_key8:
					if(keycode!=0)next_key <= keycode;
			endcase
        case (curr_state) 
				reset	:	if (keycode!=0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key2;
								end
//				read_key1:if (keycode == 0)
//								next_state = wait_key01;
				read_key2:if (keycode == 0)
								next_state = wait_key02;
				read_key3:if (keycode == 0)
								next_state = wait_key03;
				read_key4:if (keycode == 0)
								next_state = wait_key04;
				read_key5:if (keycode == 0)
								next_state = wait_key05;
				read_key6:if (keycode == 0)
								next_state = wait_key06;
				read_key7:if (keycode == 0)
								next_state = wait_key07;
				read_key8:if (keycode == 0)
								next_state = wait_key08;
								
				wait_key01: next_state = wait_key1;
				wait_key02: next_state = wait_key2;
				wait_key03: next_state = wait_key3;
				wait_key04: next_state = wait_key4;
				wait_key05: next_state = wait_key5;
				wait_key06: next_state = wait_key6;
				wait_key07: next_state = wait_key7;
				wait_key08: next_state = wait_key8;
				
								
				wait_key1:if (keycode != 0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key2;
								end
				wait_key2:if (keycode != 0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key3;
								end
				wait_key3:if (keycode != 0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key4;
								end
				wait_key4:if (keycode != 0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key5;
								end
				wait_key5:if (keycode != 0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key6;
								end
				wait_key6:if (keycode != 0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key7;
								end
				wait_key7:if (keycode != 0)
								begin
								if(keycode==ent) next_state = game;
								else next_state = read_key8;
								end
				wait_key8:if (keycode == ent)
								next_state = game;
								
				game: 	if(game_end)
								next_state = fin;
				fin: 		if(keycode == ent)
								next_state = reset;
        endcase
		  
		  game_enable = 1'b0;
		  we = 1'b0;
		  addr = 3'h0;
		case (curr_state)
				reset	:	addr = 3'b0;
				read_key1: 
					begin
						we = 1'b1;
						addr = 3'h0;
					end
				read_key2:
					begin
						we = 1'b1;
						addr = 3'h1;
					end
				read_key3:
					begin
						we = 1'b1;
						addr = 3'h2;
					end
				read_key4:
					begin
						we = 1'b1;
						addr = 3'h3;
					end
				read_key5:
					begin
						we = 1'b1;
						addr = 3'h4;
					end
				read_key6:
					begin
						we = 1'b1;
						addr = 3'h5;
					end
				read_key7:
					begin
						we = 1'b1;
						addr = 3'h6;
					end
				read_key8:
					begin
						we = 1'b1;
						addr = 3'h7;
					end
				wait_key1: addr= 3'h1;
				wait_key2: addr= 3'h2;
				wait_key3: addr= 3'h3;
				wait_key4: addr= 3'h4;
				wait_key5: addr= 3'h5;
				wait_key6: addr= 3'h6;
				wait_key7: addr= 3'h7;
				wait_key8: addr= 3'h0;
				
				wait_key01: addr= 3'h0;
				wait_key02: addr= 3'h1;
				wait_key03: addr= 3'h2;
				wait_key04: addr= 3'h3;
				wait_key05: addr= 3'h4;
				wait_key06: addr= 3'h5;
				wait_key07: addr= 3'h6;
				wait_key08: addr= 3'h7;
				game:
					game_enable = 1'b1;
		endcase
	end
endmodule
