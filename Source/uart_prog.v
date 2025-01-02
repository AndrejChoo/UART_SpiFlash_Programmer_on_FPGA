module uart_prog(
	input wire clk,
	input wire rst,
	//UART
	input wire rx,
	output wire tx,
	//SPI FLASH
	input wire miso,
	output wire mosi,
	output wire sck,
	output wire cs,
	output wire wp,
	output wire hold,
    //Debug
    output wire led0,
    output wire led1
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

assign wp = 1;
assign hold = 1;


//Interconnect
uart_rx urx0(
        .clk(clk),
        .rx(rx),
        .clock(URX_RDY),
        .DOUT(URX_DATA));

uart_tx utx0(
        .clk(clk),
        .rst(rst),
        .tx(tx),
        .start(UTX_START),
        .bsy(UTX_BSY),
        .DIN(UTX_DATA));

spi     msp0(
        .clk(clk),
        .rst(rst),
        .miso(miso),
        .mosi(mosi),
        .sck(sck),
        .bsy(SPI_BSY),
        .start(SPI_START),
        .DOUT(SPI_DOUT),
        .DIN(SPI_DIN));

//Memory array
wire[7:0]EXCHANGE_R,EXCHANGE_W,MAIN_BUFF_R,MAIN_BUFF_W;
wire[9:0]EXCHANGE_ADD,MAIN_BUFF_ADD;
wire EXCHANGE_CLK,EXCHANGE_WR,MAIN_BUFF_CLK,MAIN_BUFF_WR;

//Gowin dualport RAM
SRAM_DP share_mem(
        .douta(EXCHANGE_R), //output [7:0] douta
        .doutb(MAIN_BUFF_R), //output [7:0] doutb
        .clka(EXCHANGE_CLK), //input clka
        .ocea(1'b1), //input ocea
        .cea(1'b1), //input cea
        .reseta(1'b0), //input reseta
        .wrea(EXCHANGE_WR), //input wrea
        .clkb(MAIN_BUFF_CLK), //input clkb
        .oceb(1'b1), //input oceb
        .ceb(1'b1), //input ceb
        .resetb(1'b0), //input resetb
        .wreb(MAIN_BUFF_WR), //input wreb
        .ada(EXCHANGE_ADD), //input [9:0] ada
        .dina(EXCHANGE_W), //input [7:0] dina
        .adb(MAIN_BUFF_ADD), //input [9:0] adb
        .dinb(MAIN_BUFF_W) //input [7:0] dinb
    );

/*
//Altera dualport RAM
SRAM_DP share_mem(
        .q_a(EXCHANGE_R), //output [7:0] douta
        .q_b(MAIN_BUFF_R), //output [7:0] doutb
        .clock_a(EXCHANGE_CLK), //input clka
        .wren_a(EXCHANGE_WR), //input wrea
        .clock_b(MAIN_BUFF_CLK), //input clkb
        .wren_b(MAIN_BUFF_WR), //input wreb
        .address_a(EXCHANGE_ADD), //input [9:0] ada
        .data_a(EXCHANGE_W), //input [7:0] dina
        .address_b(MAIN_BUFF_ADD), //input [9:0] adb
        .data_b(MAIN_BUFF_W) //input [7:0] dinb
    );
*/

////////////////////////////////////////RX State machine///////////////////////////////////////////
localparam WR_ROUTINE = 13;
localparam RD_ROUTINE = 10;


reg[7:0]rx_counter = 0, packet_size = 0;
reg full_buff = 0, read_bsy = 0;
reg[3:0]rxm_state = 0, rxm_ret;
//RAM control regs
reg ex_clk, ex_wr;
reg[7:0]exchange;
reg[9:0]ex_add;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            rxm_state <= 0;
            rxm_ret <= 0;
            rx_counter <= 0;
            packet_size <= 0;
            full_buff <= 0;
            read_bsy <= 0;
            //RAM control
            ex_clk <= 0;
            ex_wr <= 0;
            ex_add <= 0;
            exchange <= 0;
        end
    else
        begin
            case(rxm_state)
                0: //IDDLE
                    begin
                        if(URX_RDY) rxm_state <= 1;
                        else rxm_state <= 0;
                    end
                1: //Load byte
                    begin
                        ex_add <= rx_counter;
                        exchange <= URX_DATA;
                        rxm_ret <= 2;
                        rxm_state <= WR_ROUTINE;
                    end
                2: //Inc counter
                    begin
                        rx_counter <= rx_counter + 1;
                        rxm_state <= 3;
                    end
                3: //Read exchange[1]
                    begin
                        ex_add <= 1;
                        rxm_state <= RD_ROUTINE;
                        rxm_ret <= 4;
                    end
                4: //Behavior 1
                    begin
                        if(rx_counter == 3)
                            begin
                                packet_size <= EXCHANGE_R;
                                rxm_state <= 0;
                            end
                        else if(packet_size > 0 && rx_counter == (packet_size + 3)) //Execute command
                            begin
                                rxm_state <= 5;
                            end
                        else //Continue receive
                            begin
                                rxm_state <= 0;
                            end
                    end
                5: //Read exchange[2]
                    begin
                        ex_add <= 2;
                        rxm_state <= RD_ROUTINE;
                        rxm_ret <= 6;
                    end
                6: //Set flags
                    begin
                        rx_counter <= 0;
                        packet_size <= 0;
                        if(EXCHANGE_R == 8'h3D) read_bsy <= 1;
                        else full_buff <= 1;
                        rxm_state <= 7;
                    end
                7: //Wait 1 cycle
                    begin
                        rxm_state <= 8;
                    end
                8: //Clear flags & Return
                    begin
                        full_buff <= 0; //
                        read_bsy <= 0;  //
                        rxm_state <= 0;
                    end
/////////////////////////////////////////////////////////////////////////////////
                10: //Read RAM routine
                    begin
                        ex_wr <= 0;
                        rxm_state <= 11;
                    end
                11: //
                    begin
                        ex_clk <= 1;
                        rxm_state <= 12;
                    end
                12: //
                    begin
                        ex_clk <= 0;
                        rxm_state <= rxm_ret;
                    end
//////////////////////////////////////////////////////////////////////////////////
                13: //Write RAM routine
                    begin
                        ex_wr <= 1;
                        rxm_state <= 14;
                    end
                14: //
                    begin
                        ex_clk <= 1;
                        rxm_state <= 15;
                    end
                15: //
                    begin
                        ex_clk <= 0;
                        rxm_state <= rxm_ret;
                    end
//////////////////////////////////////////////////////////////////////////////////
                default:
                    begin
                        rxm_state <= 0;
                    end
            endcase
        end
end

assign EXCHANGE_CLK = ex_clk;
assign EXCHANGE_WR = ex_wr;
assign EXCHANGE_ADD = ex_add;
assign EXCHANGE_W = exchange;

//Debug
reg full_buff_led, read_bsy_led;

always@(posedge full_buff) full_buff_led <= ~full_buff_led;
always@(posedge read_bsy) read_bsy_led <= ~read_bsy_led;

assign led0 = full_buff_led;
assign led1 = read_bsy_led;


//////////////////////////////////////////////Progger state machine/////////////////////////////////////////////////////////
localparam HIGH_MASK = 10'b1000000000;
localparam WR1_ROUTINE = 253;
localparam RD1_ROUTINE = 250;
localparam SEND_ARR_ROUTINE = 243;
localparam WR_HEADER_ROUTINE = 240;
localparam SPI_EXCHANGE_ROUTINE = 237;
localparam READ_REG_ROUTINE = 233;

//STACK
reg[7:0]stack[0:3];
reg[2:0]sp;

reg[7:0]main_buff;
reg[7:0]send_data, send_count;
reg send_clk;
//
reg[7:0]prg_state,ret;
reg[7:0]arr_count;
reg[2:0]delay;
reg tx_start;
//SPI FLASH
reg flcs, flsend;
reg[7:0]flcmd;
reg[25:0]f_size,offset;
reg[31:0]tmp32,tmp32_1;
reg[7:0]tmp0,tmp1;
reg[8:0]block,p_size;
//RAM regs
reg mb_clk, mb_wr;
reg[9:0]mb_add;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            prg_state <= 0;
            arr_count <= 0;
            delay <= 0;
            tx_start <= 0;
            //SPI Flash
            flcs <= 0;
            flcmd <= 0;
            ret <= 0;
            flsend <= 0;
            f_size <= 0;
            tmp32 <= 0;
            tmp0 <= 0;
            block <= 0;
            p_size <= 0;
            offset <= 0;
            //UART_TX
            send_clk <= 0;
            send_count <= 0;
            send_data <= 0;
			//Stack
			sp <= 0;
        end
    else
        begin
            if(delay > 0) delay <= delay - 1;
            case(prg_state)
                0: //IDDLE
                    begin
                        if(full_buff) prg_state <= 1;
                        else prg_state <= 0;
                    end
                1: //Change operation
                    begin
                        mb_add <= 2;
                        ret <= 2;
                        prg_state <= RD1_ROUTINE;
                    end
                2: //Change operation
                    begin
                        case(MAIN_BUFF_R)
                            8'hCC: prg_state <= 3; //Send success connection
                            8'hF0: prg_state <= 5; //SPI Flash get ID
                            8'hF1: prg_state <= 14; //SPI Flash get SREG1,2
                            8'hF2: prg_state <= 20; //SPI Flash Read
                            8'hF3: prg_state <= 65; //SPI Flash set SREG1,2
                            8'hF4: prg_state <= 35; //SPI Flash Erase
                            8'hF5: prg_state <= 43; //SPI Flash Prepare to Write
                            8'hF6: prg_state <= 48; //SPI Flash Write
                            default: prg_state <= 0;
                        endcase
                    end
/////////////////////////////////////////////////////////////////////////////////////////
                3: //Success connection
                    begin
                        tmp32[7:0] <= 8'hFE;
                        tmp32[15:8] <= 8'h01;
                        tmp32[23:16] <= 8'hCC;
                        ret <= 4;
                        prg_state <= WR_HEADER_ROUTINE;
                    end
                4: //Send buffer
                    begin
                        arr_count <= 4;
                        ret <= 0;
                        prg_state <= SEND_ARR_ROUTINE;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                5: //Get Id
                    begin
                        tmp32[7:0] <= 8'hFE;
                        tmp32[15:8] <= 8'h03;
                        tmp32[23:16] <= 8'hF0;
                        ret <= 6;
                        prg_state <= WR_HEADER_ROUTINE;
                    end
                6: //SPI write 0xF9
                    begin
                        flcs <= 1;
                        flcmd <= 8'h9F;
                        ret <= 7;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                7: //SPI write 0x00
                    begin
                        flcmd <= 8'h00;
                        ret <= 8;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                8: //Write to main_buff
                    begin
                        main_buff <= SPI_DOUT;
                        mb_add <= (5 | HIGH_MASK);
                        ret <= 9;
                        prg_state <= WR1_ROUTINE;
                    end
                9: //SPI write 0x00
                    begin
                        ret <= 10;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                10: //Write to main_buff
                    begin
                        main_buff <= SPI_DOUT;
                        mb_add <= (3 | HIGH_MASK);
                        ret <= 11;
                        prg_state <= WR1_ROUTINE;
                    end
                11: //SPI write 0x00
                    begin
                        ret <= 12;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                12: //Write to main_buff
                    begin
                        main_buff <= SPI_DOUT;
                        mb_add <= (4 | HIGH_MASK);
                        ret <= 13;
                        prg_state <= WR1_ROUTINE;
                    end
                13: //Send buffer
                    begin
                        flcs <= 0;
                        arr_count <= 6;
                        ret <= 0;
                        prg_state <= SEND_ARR_ROUTINE;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                14: //Read SREG
                    begin
                        tmp1 <= 8'h05;
                        ret <= 15;
                        prg_state <= READ_REG_ROUTINE;
                    end
                15: //
                    begin
                        main_buff <= SPI_DOUT;
                        mb_add <= (3 | HIGH_MASK);
                        ret <= 16;
                        prg_state <= WR1_ROUTINE;
                    end
                16: //
                    begin
                        tmp1 <= 8'h35;
                        ret <= 17;
                        prg_state <= READ_REG_ROUTINE;
                    end
                17: //
                    begin
                        main_buff <= SPI_DOUT;
                        mb_add <= (4 | HIGH_MASK);
                        ret <= 18;
                        prg_state <= WR1_ROUTINE;
                    end
                18: //
                    begin
                        tmp32[7:0] <= 8'hFE;
                        tmp32[15:8] <= 8'h02;
                        tmp32[23:16] <= 8'hF1;
                        ret <= 19;
                        prg_state <= WR_HEADER_ROUTINE;
                    end
                19: //Send buffer
                    begin
                        arr_count <= 5;
                        ret <= 0;
                        prg_state <= SEND_ARR_ROUTINE;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                20: //Read Flash
                    begin
                        tmp0 <= 0;
                        tmp32_1 <= 0;
                        mb_add <= 3;
                        ret <= 21;
                        prg_state <= RD1_ROUTINE;
                    end
                21: //
                    begin
                        f_size[25:24] <= MAIN_BUFF_R[1:0];
                        mb_add <= 4;
                        ret <= 22;
                        prg_state <= RD1_ROUTINE;
                    end
                22: //
                    begin
                        f_size[23:16] <= MAIN_BUFF_R[7:0];
                        mb_add <= 5;
                        ret <= 23;
                        prg_state <= RD1_ROUTINE;
                    end
                23: //
                    begin
                        f_size[15:8] <= MAIN_BUFF_R[7:0];
                        mb_add <= 6;
                        ret <= 24;
                        prg_state <= RD1_ROUTINE;
                    end
                24: //
                    begin
                        f_size[7:0] <= MAIN_BUFF_R[7:0];
                        ret <= 25;
                        prg_state <= RD1_ROUTINE;
                    end
                25: //
                    begin
                        flcs <= 1;
                        flcmd <= 8'h03;
                        ret <= 26;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                26: //Send ADD 24'h00_00_00
                    begin
                        flcmd <= 8'h00;
                        ret <= 27;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                27: //Send ADD 24'h00_00_00
                    begin
                        ret <= 28;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                28: //Send ADD 24'h00_00_00
                    begin
                        ret <= 29;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                29: //Read cycle begin
                    begin
                        ret <= 30;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                30: //
                    begin
                        main_buff <= SPI_DOUT;
                        mb_add <= (tmp0 + 3) | HIGH_MASK;
                        tmp0 <= tmp0 + 1;
                        ret <= 31;
                        prg_state <= WR1_ROUTINE;
                    end
                31: //
                    begin
                        if(tmp0 == 128) 
                            begin
                                tmp0 <= 0;
                                tmp32[7:0] <= 8'hFE;
                                tmp32[15:8] <= 8'h80;
                                tmp32[23:16] <= 8'hF2;
                                ret <= 32;
                                prg_state <= WR_HEADER_ROUTINE;
                            end
                        else prg_state <= 29;                            
                    end
                32: //Send buffer
                    begin
                        tmp32_1 <= tmp32_1 + 128;
                        arr_count <= 131;
                        ret <= 33;
                        prg_state <= SEND_ARR_ROUTINE;
                    end
                33: //Wait read_bsy
                    begin
                        if(read_bsy) prg_state <= 34;
                        else prg_state <= 33;
                    end
                34: //End cycle?
                    begin
                        if(tmp32_1 == f_size) 
                            begin
                                tmp32_1 <= 0;
                                flcs <= 0;
                                prg_state <= 0;
                            end
                        else prg_state <= 29;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                35: //Flash erase
                    begin
                        flcmd <= 8'h06; //Write ENABLE command
                        flcs <= 1;
                        ret <= 36;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                36: //Read SREG1
                    begin
                        flcs <= 0;
                        tmp1 <= 8'h05; //
                        ret <= 37;
                        prg_state <= READ_REG_ROUTINE;
                    end
                37: //While !WEL bit
                    begin
                        if(SPI_DOUT[1]) prg_state <= 38;
                        else prg_state <= 36;
                    end
                38: //Erase command
                    begin
                        flcmd <= 8'hC7; //Erase command
                        flcs <= 1;
                        ret <= 39;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                39: //Read SREG1
                    begin
                        flcs <= 0;
                        tmp1 <= 8'h05; //
                        ret <= 40;
                        prg_state <= READ_REG_ROUTINE;
                    end
                40: //While BSY bit
                    begin
                        if(SPI_DOUT[0]) prg_state <= 39;
                        else prg_state <= 41;
                    end
                41: //Fill header
                    begin
                        tmp32[7:0] <= 8'hFE;
                        tmp32[15:8] <= 8'h01;
                        tmp32[23:16] <= 8'hF4;
                        ret <= 42;
                        prg_state <= WR_HEADER_ROUTINE;
                    end
                42: //Send answer
                    begin
                        arr_count <= 4;
                        ret <= 0;
                        prg_state <= SEND_ARR_ROUTINE;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                43: //Prepare to WRITE
                    begin
                        block <= 0;
						offset <= 0;
						tmp32 <= 0;
                        mb_add <= 3;
                        ret <= 44;
                        prg_state <= RD1_ROUTINE;
                    end
                44: //
                    begin
                        p_size[8] <= MAIN_BUFF_R[0];
                        mb_add <= 4;
                        ret <= 45;
                        prg_state <= RD1_ROUTINE;
                    end
                45: //
                    begin
                        p_size[7:0] <= MAIN_BUFF_R[7:0];
                        prg_state <= 46;
                    end
                46: //Send answer
                    begin
                        tmp32[7:0] <= 8'hFE;
                        tmp32[15:8] <= 8'h01;
                        tmp32[23:16] <= 8'hF6;
                        ret <= 47;
                        prg_state <= WR_HEADER_ROUTINE;
                    end
                47: //Send buffer
                    begin
                        arr_count <= 4;
                        ret <= 0;
                        prg_state <= SEND_ARR_ROUTINE;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                48: //Write flash
                    begin
                        mb_add <= tmp0 + 3;
                        ret <= 49;
                        prg_state <= RD1_ROUTINE;
                    end
                49: //
                    begin
                        mb_add <= (block + tmp0 + 5) | HIGH_MASK;
                        main_buff <= MAIN_BUFF_R;
                        ret <= 50;
                        prg_state <= WR1_ROUTINE;
                    end
                50: //
                    begin
                        tmp0 <= tmp0 + 1;
                        prg_state <= 51;
                    end
                51: //
                    begin
                        if(tmp0 == 128) 
                            begin                               
                                tmp0 <= 0;
                                block <= block + 128;
                                prg_state <= 52;
                            end
                        else prg_state <= 48;
                    end
                52: //
                    begin
                        if(block == p_size)
                            begin
                                block <= 0;
                                prg_state <= 53;
                            end
                        else prg_state <= 46;
                    end
                53: //Write enable command
                    begin
                        flcmd <= 8'h06;
                        flcs <= 1;
                        ret <= 54;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                54: //Read SREG1
                    begin
                        flcs <= 0;
                        tmp1 <= 8'h05; //Read SREG1
                        ret <= 55;
                        prg_state <= READ_REG_ROUTINE;
                    end
                55: //While !WEL bit
                    begin
                        if(SPI_DOUT[1]) prg_state <= 56;
                        else prg_state <= 54;
                    end
                56: //Write command
                    begin
                        flcmd <= 8'h02;
                        flcs <= 1;
                        ret <= 57;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                57: //Write HADD
                    begin
                        flcmd <= offset[23:16];
                        ret <= 58;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                58: //Write MADD
                    begin
                        flcmd <= offset[15:8];
                        ret <= 59;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                59: //Write LADD
                    begin
                        flcmd <= offset[7:0];
                        ret <= 60;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                60: //Read byte
                    begin
                        mb_add <= (block + 5) | HIGH_MASK;
                        ret <= 61;
                        prg_state <= RD1_ROUTINE;
                    end
                61: //Write byte
                    begin
                        flcmd <= MAIN_BUFF_R;
                        ret <= 62;
                        block <= block + 1;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                62: //
                    begin
                        if(block == p_size)
                            begin
                                block <= 0;
                                flcs <= 0;
                                offset <= offset + p_size;
                                prg_state <= 63;
                            end
                        else prg_state <= 60;
                    end
                63: //Read SREG1
                    begin
                        flcs <= 0;
                        tmp1 <= 8'h05; //
                        ret <= 64;
                        prg_state <= READ_REG_ROUTINE;
                    end
                64: //While BSY bit
                    begin
                        if(SPI_DOUT[0]) prg_state <= 63;
                        else prg_state <= 46;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                65: //WRITE SREG1,2
                    begin
                        mb_add <= 3; //SREG2
                        ret <= 66;
                        prg_state <= RD1_ROUTINE;
                    end
                66: //
                    begin
						tmp32[7:0] <= MAIN_BUFF_R; 
                        mb_add <= 4; //SREG1
                        ret <= 67;
                        prg_state <= RD1_ROUTINE;
                    end
                67: //
                    begin
                        tmp32[15:8] <= MAIN_BUFF_R;
                        flcs <= 1;
                        flcmd <= 8'h50;
                        ret <= 68;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                68: //Read SREG1
                    begin
                        flcs <= 0;
                        tmp1 <= 8'h05; //
                        ret <= 69;
                        prg_state <= READ_REG_ROUTINE;
                    end
                69: //While !WEL bit
                    begin
                        if(SPI_DOUT[1]) prg_state <= 70;
                        else prg_state <= 68;
                    end
                70: //WRITE Sreg command
                    begin
                        flcs <= 1;
                        flcmd <= 8'h01;
                        ret <= 71;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                71: //WRITE Sreg1
                    begin
                        flcmd <= tmp32[15:8];
                        ret <= 72;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                72: //WRITE Sreg2
                    begin
                        flcmd <= tmp32[7:0];
                        ret <= 73;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                73: //
                    begin
                        flcs <= 0;
                        prg_state <= 74;
                    end
                74: //WRITE Sreg disable
                    begin
                        flcs <= 1;
                        flcmd <= 8'h04;
                        ret <= 75;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                75: //Send answer
                    begin
                        tmp32[7:0] <= 8'hFE;
                        tmp32[15:8] <= 8'h01;
                        tmp32[23:16] <= 8'hF3;
                        ret <= 76;
                        prg_state <= WR_HEADER_ROUTINE;
                    end
                76: //Send buffer
                    begin
                        arr_count <= 4;
                        ret <= 0;
                        prg_state <= SEND_ARR_ROUTINE;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                233: //Read REG routine
                    begin
                        stack[sp] <= ret; //PUSH Return address
                        sp <= sp + 1;
                        prg_state <= 234;
                    end                
                234: //Read REG routine
                    begin
                        flcs <= 1;
                        flcmd <= tmp1; //Reg address
                        ret <= 235;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                235: //
                    begin
                        flcmd <= 8'h00; 
                        ret <= 236;
                        prg_state <= SPI_EXCHANGE_ROUTINE;
                    end
                236: //Read SREG1 routine
                    begin
                        flcs <= 0;
                        ret <= stack[sp - 1]; //POP return address
                        prg_state <= stack[sp - 1]; 
                        sp <= sp - 1;
                    end 
//////////////////////////////////////////////////////////////////////////////////////////
                237: //SPI Flash exchange routine
                    begin
                        flsend <= 1;
                        delay <= 2;
                        prg_state <= 238;
                    end
                238: //
                    begin
                        if(delay == 0)
                            begin
                                flsend <= 0;
                                delay <= 2;
                                prg_state <= 239;
                            end
                        else prg_state <= 238;
                    end
                239: //
                    begin
                        if(delay == 0 && SPI_BSY == 0) prg_state <= ret;
                        else prg_state <= 239;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
                240: //WRITE Header routine
                    begin
                        stack[sp] <= ret; //PUSH return address
								sp <= sp + 1;
                        main_buff <= tmp32[7:0];
                        mb_add <= (0 | HIGH_MASK);
                        ret <= 241;
                        prg_state <= WR1_ROUTINE;
                    end
                241: //
                    begin
                        main_buff <= tmp32[15:8];
                        mb_add <= (1 | HIGH_MASK);
                        ret <= 242;
                        prg_state <= WR1_ROUTINE;
                    end
                242: //
                    begin
                        main_buff <= tmp32[23:16];
                        mb_add <= (2 | HIGH_MASK);
                        ret <= stack[sp - 1]; //POP return address
								sp <= sp - 1;
                        prg_state <= WR1_ROUTINE;
                    end
//////////////////////////////////////////////////////////////////////////////////////////
				243: //Send array routine
                    begin
                        stack[sp] <= ret; //PUSH return address
								sp <= sp + 1;
                        prg_state <= 244;
                    end                
				244: //Send array routine
                    begin
                        mb_add[9:0] <= {2'b10,send_count[7:0]};
                        ret <= 245;
                        prg_state <= RD1_ROUTINE;
                    end                
                245: //Send byte
                    begin
                        send_data <= MAIN_BUFF_R;
                        send_clk <= 1;
                        prg_state <= 246;
                    end
                246: //Wait until !UTX_BSY
                    begin
                        if(UTX_BSY)
                            begin
                                send_count <= send_count + 1;
                                send_clk <= 0;
                                prg_state <= 247;
                            end
                        else prg_state <= 246;
                    end
                247: //Wait until UTX_BSY 
                    begin
                        if(UTX_BSY) prg_state <= 247;
                        else prg_state <= 248;
                    end
                248: //Check count
                    begin
                        if(send_count >= arr_count) prg_state <= 249;
                        else prg_state <= 244;
                    end
                249: //Return
                    begin
                        send_count <= 0;
                        ret <= stack[sp - 1]; //POP return address
                        prg_state <= stack[sp - 1];
								sp <= sp - 1;
                    end
////////////////////////////////////////////////////////////////////////////////////////////////
                250: //Read RAM routine
                    begin
                        mb_wr <= 0;
                        prg_state <= 251;
                    end
                251: //
                    begin
                        mb_clk <= 1;
                        prg_state <= 252;
                    end
                252: //
                    begin
                        mb_clk <= 0;
                        prg_state <= ret;
                    end
//////////////////////////////////////////////////////////////////////////////////
                253: //Write RAM routine
                    begin
                        mb_wr <= 1;
                        prg_state <= 254;
                    end
                254: //
                    begin
                        mb_clk <= 1;
                        prg_state <= 255;
                    end
                255: //
                    begin
                        mb_clk <= 0;
                        prg_state <= ret;
                    end
////////////////////////////////////////////////////////////////////////////////////////////////
                default:
                    begin
                        prg_state <= 0;
                    end
            endcase
        end
end


//SPI Flash
assign cs = ~flcs;
assign SPI_DIN = flcmd;
assign SPI_START = flsend;
//Send to UART_TX
assign UTX_START = send_clk;
assign UTX_DATA = send_data;
//RAM wires
assign MAIN_BUFF_CLK = mb_clk;
assign MAIN_BUFF_WR  = mb_wr;
assign MAIN_BUFF_ADD = mb_add;
assign MAIN_BUFF_W   = main_buff;


endmodule












