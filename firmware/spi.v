module spi(
	input wire clk,
	input wire rst,
	input wire start,
	input wire miso,
	input wire[7:0]DIN,
	output wire mosi,
	output wire sck,
	output wire bsy,
	output wire[7:0]DOUT
);

localparam prescaller = 0;

reg[7:0]spdr_r,spdr_t;
reg[4:0]spi_state;
reg[7:0]spi_delay;
reg spi_sck, spi_so, spi_rdy;


always@(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            spi_state <= 0;
            spi_delay <= 0;
            spi_sck <= 0;
            spi_so <= 0;
            spi_rdy <= 0;
            spdr_r <= 0;
            spdr_t <= 0;
        end
    else
        begin
            if(spi_delay > 0) spi_delay <= spi_delay - 1;
            case(spi_state)
                0: //IDDLE
                    begin
                        spi_sck <= 0;
                        spi_so <= 0;
                        spi_rdy <= 0;
                        spi_state <= 0;
                        if(start)
                            begin
                                spi_state <= 1;
                                spi_rdy <= 1;
                                spi_delay <= prescaller;
                            end
                    end
                1: //Load First bit _
                    begin
						spi_so <= DIN[7];
						if(spi_delay == 0)
							begin
								spi_state <= 2;
								spi_delay <= prescaller;
							end
                    end
                2: //SCK HIGH 0
                    begin
						spdr_t[7] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 3;
								spi_delay <= prescaller;
							end						
                    end
                3: //SCK LOW 0
                    begin
						spi_sck <= 0;
						spi_so <= DIN[6];
						if(spi_delay == 0)
							begin
								spi_state <= 4;
								spi_delay <= prescaller;
							end			 
                    end 
                4: //SCK HIGH 1
                    begin
						spdr_t[6] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 5;
								spi_delay <= prescaller;
							end						
                    end
                5: //SCK LOW 1
                    begin
						spi_sck <= 0;
						spi_so <= DIN[5];
						if(spi_delay == 0)
							begin
								spi_state <= 6;
								spi_delay <= prescaller;
							end			 
                    end                    
                6: //SCK HIGH 2
                    begin
						spdr_t[5] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 7;
								spi_delay <= prescaller;
							end						
                    end
                7: //SCK LOW 2
                    begin
						spi_sck <= 0;
						spi_so <= DIN[4];
						if(spi_delay == 0)
							begin
								spi_state <= 8;
								spi_delay <= prescaller;
							end			 
                    end
                8: //SCK HIGH 3
                    begin
						spdr_t[4] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 9;
								spi_delay <= prescaller;
							end						
                    end
                9: //SCK LOW 3
                    begin
						spi_sck <= 0;
						spi_so <= DIN[3];
						if(spi_delay == 0)
							begin
								spi_state <= 10;
								spi_delay <= prescaller;
							end			 
                    end 
                10: //SCK HIGH 4
                    begin
						spdr_t[3] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 11;
								spi_delay <= prescaller;
							end						
                    end
                11: //SCK LOW 4
                    begin
						spi_sck <= 0;
						spi_so <= DIN[2];
						if(spi_delay == 0)
							begin
								spi_state <= 12;
								spi_delay <= prescaller;
							end			 
                    end 
                12: //SCK HIGH 5
                    begin
						spdr_t[2] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 13;
								spi_delay <= prescaller;
							end						
                    end
                13: //SCK LOW 5
                    begin
						spi_sck <= 0;
						spi_so <= DIN[1];
						if(spi_delay == 0)
							begin
								spi_state <= 14;
								spi_delay <= prescaller;
							end			 
                    end
                14: //SCK HIGH 6
                    begin
						spdr_t[1] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 15;
								spi_delay <= prescaller;
							end						
                    end
                15: //SCK LOW 6
                    begin
						spi_sck <= 0;
						spi_so <= DIN[0];
						if(spi_delay == 0)
							begin
								spi_state <= 16;
								spi_delay <= prescaller;
							end			 
                    end 
                16: //SCK HIGH 7
                    begin
						spdr_t[0] <= miso;
						spi_sck <= 1;
						if(spi_delay == 0)
							begin
								spi_state <= 17;
								spi_delay <= prescaller;
							end						
                    end
                17: //SCK LOW 7
                    begin
						spi_sck <= 0;
						if(spi_delay == 0)
							begin
								spi_state <= 18;
								spi_delay <= prescaller;
							end			 
                    end                                                                                                          
                18: //END
                    begin
								spdr_r <= spdr_t;
                        spi_state <= 0;
                        spi_rdy <= 0;
                        spi_so <= 0;
                    end
            endcase
        end
end

assign bsy = spi_rdy;
assign mosi = spi_so;
assign sck = spi_sck;
assign DOUT = spdr_r;

endmodule
