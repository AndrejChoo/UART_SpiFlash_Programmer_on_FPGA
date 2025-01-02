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

localparam prescaller = 1;

reg[7:0]spdr_r,spdr_t, spidr_w;
reg[4:0]spi_state, spi_cnt;
reg[7:0]spi_delay;
reg spi_sck, spi_so, spi_rdy;

//Latch spi data to send
always@(posedge start) spidr_w <= DIN;


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
            spi_cnt <= 0;
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
                        if(start)spi_state <= 1;
                    end
                1: //
                    begin
                        spi_cnt <= 8;
                        spi_rdy <= 1;
                        spi_state <= 2;
                    end
                2: //
                    begin
                        spi_so <= spidr_w[spi_cnt - 1];
                        spi_delay <= prescaller;
                        spi_state <= 3;
                    end              
                3: //
                    begin
                        if(spi_delay == 0)
                            begin
                                spi_sck <= 1;
                                spi_delay <= prescaller;
                                spi_state <= 4;
                            end
                        else spi_state <= 3;
                    end
                4: //
                    begin
                        if(spi_delay == 0)
                            begin
                                spi_sck <= 0;
                                spdr_t[spi_cnt - 1] <= miso;
                                spi_cnt <= spi_cnt - 1;
                                spi_delay <= prescaller;
                                spi_state <= 5;
                            end
                        else spi_state <= 4;
                    end  
                5: //
                    begin
                        if(spi_cnt == 0) spi_state <= 6;
                        else spi_state <= 2;
                    end 

                                          
                6: //END
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
