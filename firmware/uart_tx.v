module uart_tx(
	input wire clk,
	input wire rst,
	input wire start,
	input wire[7:0]DIN,
	output wire tx,
	output wire bsy
);


localparam INCLOCK = 40000000;
localparam BAUDE = 921600;
localparam ubrr = INCLOCK / BAUDE;

reg[14:0] utx_counter;
reg[3:0]utx_state;
reg utx, utrdy;


//UART TX State machine	
always@(posedge clk or negedge rst)
	begin
        if(!rst)
            begin
                utx <= 0;
                utrdy <= 0;
                utx_counter <= 0;
                utx_state <= 0;
            end
		 else
            begin
                if(utx_counter > 0) utx_counter <= utx_counter - 1;
                //
                case(utx_state)
                    0:
                        begin
                            utx <= 0;
                            utrdy <= 0; 
                            if(start)
                                begin
                                    utrdy <= 1;
                                    utx <= 1;
                                    utx_counter <= ubrr;
                                    utx_state <= 1;
                                end
                        end
                    1: //START Bit
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[0];
                                    utx_counter <= ubrr;
                                    utx_state <= 2;
                                end
                        end
                    2: //Bit0
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[1];
                                    utx_counter <= ubrr;
                                    utx_state <= 3;
                                end
                        end
                    3: //Bit1
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[2];
                                    utx_counter <= ubrr;
                                    utx_state <= 4;
                                end
                        end
                    4: //Bit2
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[3];
                                    utx_counter <= ubrr;
                                    utx_state <= 5;
                                end
                        end
                    5: //Bit3
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[4];
                                    utx_counter <= ubrr;
                                    utx_state <= 6;
                                end
                        end
                    6: //Bit4
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[5];
                                    utx_counter <= ubrr;
                                    utx_state <= 7  ;
                                end
                        end
                    7: //Bit5
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[6];
                                    utx_counter <= ubrr;
                                    utx_state <= 8;
                                end
                        end
                    8: //Bit6
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= ~DIN[7];
                                    utx_counter <= ubrr;
                                    utx_state <= 9;
                                end
                        end
                    9: //Bit7
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx <= 0;
                                    utx_counter <= ubrr;
                                    utx_state <= 10;
                                end
                        end
                    10: //Stop
                        begin
                            if(utx_counter == 0)
                                begin
                                    utx_counter <= ubrr;
                                    utx_state <= 11;
                                end
                        end
                    11: //Return to IDDLE
                        begin
                            utrdy <= 0;
                            utx_state <= 0;
                        end
                endcase
            end
	end
	
assign tx = ~utx;
assign bsy = utrdy;

endmodule
