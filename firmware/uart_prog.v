module uart_prog(
	input wire clk,
	input wire rst,
	//UART
	input wire rx,
	input wire rts,
	output wire tx,
	//SPI FLASH
	input wire miso,
	output wire mosi,
	output wire sck,
	output wire cs,
	output wire wp,
	output wire hold
);


//UART RX wires
wire URX_RDY;
wire[7:0] URX_DATA;
//UART TX wires
wire UTX_BSY, UTX_START;
wire[7:0] UTX_DATA;
//SPI WIRES
wire SPI_START,SPI_BSY;
wire[7:0]SPI_DIN,SPI_DOUT;

assign cs = rts;
assign wp = 1;
assign hold = 1;


//Interconnect
uart_rx urx0(.clk(clk),.rx(rx),.clock(URX_RDY),.DOUT(URX_DATA));
uart_tx utx0(.clk(clk),.rst(rst),.tx(tx),.start(UTX_START),.bsy(UTX_BSY),.DIN(UTX_DATA));
spi     msp0(.clk(clk),.rst(rst),.miso(miso),.mosi(mosi),.sck(sck),.bsy(SPI_BSY),.start(SPI_START),.DOUT(SPI_DOUT),.DIN(SPI_DIN));


//MAIN STATE MACHINE
reg[3:0]state;
reg[7:0]DATA_SI; //Data from UART_RX to SPI
reg[7:0]DATA_SO; //Data from SPI to UART_TX
reg spi_send, uart_send;

assign SPI_DIN = DATA_SO;
assign UTX_DATA = DATA_SI;
assign SPI_START = spi_send;
assign UTX_START = uart_send;

always@(negedge SPI_BSY) DATA_SI <= SPI_DOUT;

always@(posedge clk or negedge rst)
	begin
		if(!rst)
			begin
				state <= 0;
				DATA_SO <= 0;
				spi_send <= 0;
				uart_send <= 0;
			end
		else
			begin
				case(state)
					0: //IDDLE
						begin
							if(URX_RDY) state <= 1;									
						end
					1: //COPY UART_RX DATA
						begin
							if(!URX_RDY) 
								begin
									DATA_SO <= URX_DATA;
									state <= 2;
								end
							else state <= 1;									
						end
					2: //SEND TO SPI
						begin
							spi_send <= 1;
							if(SPI_BSY) state <= 3;
							else state <= 2;
						end
					3: //WAIT SPI sending
						begin
							spi_send <= 0;
							if(!SPI_BSY) state <= 4;
							else state <= 3;
						end
					4: //SEND TO UART
						begin
							uart_send <= 1;
							if(UTX_BSY) state <= 5;
							else state <= 4;
						end
					5: //WAIT UART sending
						begin
							uart_send <= 0;
							if(!UTX_BSY) state <= 0;
							else state <= 5;
						end
				endcase
			end
	end

endmodule




