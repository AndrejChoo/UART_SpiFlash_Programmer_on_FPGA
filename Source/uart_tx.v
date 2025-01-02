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
reg[3:0]utx_state,ucnt;
reg[9:0]udr;
reg utx, utrdy;
////////////////////////////// stop   data   start
always@(posedge start) udr <= {1'b1,DIN[7:0],1'b0};

//UART TX State machine	
always@(posedge clk or negedge rst)
	begin
        if(!rst)
            begin
                utx <= 0;
                utrdy <= 0;
                utx_counter <= 0;
                utx_state <= 0;
                ucnt <= 0;
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
                            if(start) utx_state <= 1;
                        end
                    1: //
                        begin
                            utrdy <= 1;
                            utx_state <= 2;
                        end
                    2: //
                        begin
                            utx_counter <= ubrr;
                            utx <= ~udr[ucnt];
                            ucnt <= ucnt + 1;
                            utx_state <= 3;
                        end
                    3: //
                        begin
                            if(utx_counter == 0)
                                begin
                                    if(ucnt == 10) utx_state <= 4;
                                    else utx_state <= 2;
                                end
                            else utx_state <= 3;
                        end
                    4: //
                        begin
                            utx <= 0;
                            utrdy <= 0;
                            ucnt <= 0;
                            utx_state <= 0;
                        end
                endcase
            end
	end
	
assign tx = ~utx;
assign bsy = utrdy;

endmodule
