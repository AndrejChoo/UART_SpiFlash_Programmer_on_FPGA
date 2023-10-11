using System;
using System.IO;
using System.IO.Ports;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Net.Mime.MediaTypeNames;

namespace FpgaSpiProg
{
    public partial class Form1 : Form
    {
        //Переменные и объекты COM
        SerialPort port = new SerialPort();
        string[] ports;
        bool isOpen = false;

        //Объекты и переменные для fileDialog
        OpenFileDialog openFile = new OpenFileDialog();
        SaveFileDialog saveFile = new SaveFileDialog();
        string filePath; //Строка адреса файла

        //
        byte[] tx_buff = new byte[512];
        byte[] rx_buff = new byte[512];

        byte[] readBuff;
        byte[] writeBuff;

        //
        int fsize;
        int psize;
        int wsize;


        public Form1()
        {
            InitializeComponent();

            //openFile.Filter = "Binary Files(*.bin)|*.bin";

            //Получаем список доступных COM портов
            ports = SerialPort.GetPortNames();
            for (int i = 0; i < ports.Length; i++) portCB.Items.Add(ports[i]);
        }

        //Перевод строки в byte
        static byte strToByte(string data)
        {
            byte temp = 0;
            switch (data[1])
            {
                case '0': { temp = 0x00; break; }
                case '1': { temp = 0x01; break; }
                case '2': { temp = 0x02; break; }
                case '3': { temp = 0x03; break; }
                case '4': { temp = 0x04; break; }
                case '5': { temp = 0x05; break; }
                case '6': { temp = 0x06; break; }
                case '7': { temp = 0x07; break; }
                case '8': { temp = 0x08; break; }
                case '9': { temp = 0x09; break; }
                case 'a': { temp = 0x0A; break; }
                case 'A': { temp = 0x0A; break; }
                case 'b': { temp = 0x0B; break; }
                case 'B': { temp = 0x0B; break; }
                case 'c': { temp = 0x0C; break; }
                case 'C': { temp = 0x0C; break; }
                case 'd': { temp = 0x0D; break; }
                case 'D': { temp = 0x0D; break; }
                case 'e': { temp = 0x0E; break; }
                case 'E': { temp = 0x0E; break; }
                case 'f': { temp = 0x0F; break; }
                case 'F': { temp = 0x0F; break; }
                default: { temp = 0x0F; break; }
            }
            switch (data[0])
            {
                case '0': { temp |= 0x00; break; }
                case '1': { temp |= 0x10; break; }
                case '2': { temp |= 0x20; break; }
                case '3': { temp |= 0x30; break; }
                case '4': { temp |= 0x40; break; }
                case '5': { temp |= 0x50; break; }
                case '6': { temp |= 0x60; break; }
                case '7': { temp |= 0x70; break; }
                case '8': { temp |= 0x80; break; }
                case '9': { temp |= 0x90; break; }
                case 'a': { temp |= 0xA0; break; }
                case 'A': { temp |= 0xA0; break; }
                case 'b': { temp |= 0xB0; break; }
                case 'B': { temp |= 0xB0; break; }
                case 'c': { temp |= 0xC0; break; }
                case 'C': { temp |= 0xC0; break; }
                case 'd': { temp |= 0xD0; break; }
                case 'D': { temp |= 0xD0; break; }
                case 'e': { temp |= 0xE0; break; }
                case 'E': { temp |= 0xE0; break; }
                case 'f': { temp |= 0xF0; break; }
                case 'F': { temp |= 0xF0; break; }
                default: { temp |= 0xF0; break; }
            }
            return temp;
        }

        //Перевод байта в строку (HEX без "0x") 
        static string hbyteToString(byte data)
        {
            string result = null;

            switch (data & 0xF0)
            {
                case 0x00: { result += "0"; break; }
                case 0x10: { result += "1"; break; }
                case 0x20: { result += "2"; break; }
                case 0x30: { result += "3"; break; }
                case 0x40: { result += "4"; break; }
                case 0x50: { result += "5"; break; }
                case 0x60: { result += "6"; break; }
                case 0x70: { result += "7"; break; }
                case 0x80: { result += "8"; break; }
                case 0x90: { result += "9"; break; }
                case 0xA0: { result += "A"; break; }
                case 0xB0: { result += "B"; break; }
                case 0xC0: { result += "C"; break; }
                case 0xD0: { result += "D"; break; }
                case 0xE0: { result += "E"; break; }
                case 0xF0: { result += "F"; break; }
            }

            switch (data & 0x0F)
            {
                case 0x00: { result += "0"; break; }
                case 0x01: { result += "1"; break; }
                case 0x02: { result += "2"; break; }
                case 0x03: { result += "3"; break; }
                case 0x04: { result += "4"; break; }
                case 0x05: { result += "5"; break; }
                case 0x06: { result += "6"; break; }
                case 0x07: { result += "7"; break; }
                case 0x08: { result += "8"; break; }
                case 0x09: { result += "9"; break; }
                case 0x0A: { result += "A"; break; }
                case 0x0B: { result += "B"; break; }
                case 0x0C: { result += "C"; break; }
                case 0x0D: { result += "D"; break; }
                case 0x0E: { result += "E"; break; }
                case 0x0F: { result += "F"; break; }
            }

            return result;
        }

        private void print_array(byte[] arr)
        {
            string rd;

            StreamWriter sw = new StreamWriter("temp.txt");
            string tmp;

            tmp = "OFFSET   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\r\n";
            sw.WriteLine(tmp);

            for (Int32 m = 0; m < arr.Length; m += 16)
            {
                tmp = "0";
                tmp += hbyteToString(Convert.ToByte(m >> 16 & 0xFF));
                tmp += hbyteToString(Convert.ToByte(m >> 8 & 0xFF));
                tmp += hbyteToString(Convert.ToByte(m & 0xFF)) + "  ";

                for (Int32 n = 0; n < 16; n++)
                {
                    tmp += hbyteToString(arr[m + n]) + " ";
                }

                sw.WriteLine(tmp);
            }
            sw.Close();
            rd = File.ReadAllText("temp.txt");

            if (codeTB.InvokeRequired) codeTB.Invoke((MethodInvoker)delegate
            { codeTB.Text = rd; });
            else codeTB.Text = rd;

            File.Delete("temp.txt");
        }

        //Открытие файла
        void open_file()
        {
            string rd;

            if (openFile.ShowDialog() == DialogResult.OK)
            {
                //Get the path of specified file
                filePath = openFile.FileName;

                if (filePath.Substring(filePath.Length - 4) == ".hex" || filePath.Substring(filePath.Length - 4) == ".HEX")
                {
                    //Открываем файл для чтения
                    StreamReader read = new StreamReader(filePath);
                    Int32 offset = 0, bofs = 0;
                    Int32 curr_offset = 0;
                    Int32 tmp_offs = 0;
                    string rds;
                    wsize = 0;

                    //Рассчитываем дополнительный адрес смещения
                    while ((rds = read.ReadLine()) != null)
                    {
                        if (rds.Substring(7, 2) == "04")
                        {
                            tmp_offs = Convert.ToInt32((strToByte(rds.Substring(9, 2)) << 8) | strToByte(rds.Substring(11, 2)));
                            tmp_offs = tmp_offs << 16;
                        }
                        if (rds.Substring(7, 2) == "00")
                        {
                            curr_offset = Convert.ToInt32((strToByte(rds.Substring(3, 2)) << 8) | strToByte(rds.Substring(5, 2)));
                            curr_offset = curr_offset | tmp_offs;
                            if (curr_offset >= offset)
                            {
                                offset = curr_offset;
                                bofs = Convert.ToInt32(strToByte(rds.Substring(1, 2)));
                            }
                        }
                    }
                    read.Close();
                    read.Dispose();

                    wsize = offset + bofs;
                    if ((wsize % psize) > 0) wsize = wsize + (psize - (wsize % psize));

                    //Конвертируем HEX
                    writeBuff = new byte[wsize];

                    for (Int32 i = 0; i < writeBuff.Length; i++) writeBuff[i] = 0xFF;

                    StreamReader reader = new StreamReader(filePath);

                    offset = 0;

                    while ((rds = reader.ReadLine()) != null)
                    {
                        if (rds.Substring(7, 2) == "04")
                        {
                            offset = Convert.ToInt32(((strToByte(rds.Substring(9, 2)) << 8) | (strToByte(rds.Substring(11, 2)))));

                        }
                        if (rds.Substring(7, 2) == "00")
                        {
                            byte str_size = strToByte(rds.Substring(1, 2));
                            Int32 arr_offset = (strToByte(rds.Substring(5, 2)) | (strToByte(rds.Substring(3, 2)) << 8));
                            arr_offset |= (offset << 16);
                            rds = rds.Substring(9, str_size * 2);

                            for (Int32 h = 0; h < str_size; h++)
                            {
                                writeBuff[arr_offset + h] = strToByte(rds.Substring(h * 2, 2));
                            }
                        }
                    }
                    read.Close();
                    read.Dispose();
                }

                //Если BIN или любой двоичный файл
                else
                {

                    //Рассчитываем размер файла
                    FileInfo fli = new FileInfo(filePath);

                    wsize = Convert.ToInt32(fli.Length);
                    if ((wsize % psize) > 0) wsize = wsize + (psize - (wsize % psize));

                    //Задаём размерность массиву
                    writeBuff = new byte[wsize];

                    //Заполняем массив 0xFF значениями
                    for (Int32 i = 0; i < writeBuff.Length; i++)
                    {
                        writeBuff[i] = 0xFF;
                    }

                    FileStream fs = File.OpenRead(filePath);
                    fs.Read(writeBuff, 0, wsize);
                    fs.Close();


                }
                consoleTB.Text = "Загрузка завершена";
            }

            //Очищаем нужный textBox и выводим в него файл
            codeTB.Clear();
            print_array(writeBuff);

            File.Delete("temp.txt");
        }

        private void connectBTN_Click(object sender, EventArgs e)
        {
            String portNum = portCB.Text;
            int baude = Convert.ToInt32(baudeCB.Text);

            if (isOpen == false)
            {
                try
                {
                    if (portCB.Text == null) consoleTB.Text = "Не выбран номер COM порта";
                    else
                    {
                        // настройки порта
                        port.PortName = portNum;
                        port.BaudRate = baude;
                        port.DataBits = 8;
                        port.Parity = Parity.None;
                        port.StopBits = StopBits.One;

                        port.ReadTimeout = 1000;
                        port.WriteTimeout = 1000;
                        port.Open();

                        port.RtsEnable = false;
                        isOpen = true;
                        connectBTN.BackColor = Color.LightGreen;
                        connectBTN.Text = "Disconnect";
                        consoleTB.Text = "Порт открыт";
                    }
                }
                catch (Exception)
                {
                    consoleTB.Text = "Ошибка открытия COM порта";
                }
            }
            else
            {
                port.Dispose();
                port.Close();
                isOpen = false;
                connectBTN.BackColor = Color.LightGray;
                connectBTN.Text = "Connect";
                consoleTB.Text = "Порт закрыт";
            }
        }

        private void scanBTN_Click(object sender, EventArgs e)
        {
            portCB.Items.Clear();
            //Получаем список доступных COM портов
            ports = SerialPort.GetPortNames();
            for (int i = 0; i < ports.Length; i++) portCB.Items.Add(ports[i]);
        }

        private void idBTN_Click(object sender, EventArgs e)
        {
            if (isOpen)
            {
                string devId;

                tx_buff[0] = 0x9F;
                tx_buff[1] = 0x00;
                tx_buff[2] = 0x00;
                tx_buff[3] = 0x00;

                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                port.Write(tx_buff, 1, 1);
                port.Write(tx_buff, 2, 1);
                port.Write(tx_buff, 3, 1);
                while (port.BytesToRead < 4);
                port.RtsEnable = false;

                port.Read(rx_buff, 0, 4);

                devId = hbyteToString(rx_buff[1]) + hbyteToString(rx_buff[2]) + hbyteToString(rx_buff[3]);
                idTB.Text = devId;
            }
            else
            {
                consoleTB.Text = "Порт закрыт";
            }
        }

        private void modelCB_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch(modelCB.Text)
            {
                case "W25Q40":
                    {
                        psize = 256;
                        fsize = 524288;
                        break;
                    }
                case "W25Q80":
                    {
                        psize = 256;
                        fsize = 1048576;
                        break;
                    }
                case "W25Q16":
                    {
                        psize = 256;
                        fsize = 2097152;
                        break;
                    }
                case "W25Q32":
                    {
                        psize = 256;
                        fsize = 4194304;
                        break;
                    }
                case "W25Q64":
                    {
                        psize = 256;
                        fsize = 8388608;
                        break;
                    }
            }
        }

        private void rdSregBTN_Click(object sender, EventArgs e)
        {
            if(isOpen && modelCB.Text != "")
            {
                tx_buff[0] = 0x05;
                tx_buff[1] = 0x00;
                tx_buff[2] = 0x35;
                tx_buff[3] = 0x00;
                tx_buff[4] = 0x15;
                tx_buff[5] = 0x00;

                port.RtsEnable = true;
                for (int i = 0; i < 6; i++) port.Write(tx_buff, i, 1);
                while(port.BytesToRead < 6);
                port.RtsEnable = false;

                port.Read(rx_buff, 0, 6);

                lsregTB.Text = hbyteToString(rx_buff[1]);
                msregTB.Text = hbyteToString(rx_buff[3]);
                hsregTB.Text = hbyteToString(rx_buff[5]);
            }
            else
            {
                consoleTB.Text = "Проверьте подключение и выбор модели FLASH";
            }
        }

        private void readBTN_Click(object sender, EventArgs e)
        {
            if (isOpen && modelCB.Text != "")
            {
                readBuff = new byte[fsize];

                mainPB.Maximum = fsize;
                mainPB.Value = 0;

                consoleTB.Text = "Чтение...";
                
                tx_buff[0] = 0x03;
                tx_buff[1] = 0x00;
                tx_buff[2] = 0x00;
                tx_buff[3] = 0x00;
                port.RtsEnable = true;
                for (int i = 0; i < 4; i++) port.Write(tx_buff, i, 1);
                Thread.Sleep(1);
                port.Read(rx_buff, 0, 4);

                for(int i = 0; i < fsize; i+= 128)
                {
                    for(int k = 0; k < 128; k++) port.Write(tx_buff, 1, 1);
                    mainPB.Value = i;
                    while(port.BytesToRead < 128);
                    port.Read(readBuff, i, 128);       
                }
                port.RtsEnable = false;

                mainPB.Value = 0;

                print_array(readBuff);
                consoleTB.Text = "Чтение завершено";
            }
        }

        private void eraseBTN_Click(object sender, EventArgs e)
        {
            if (isOpen && modelCB.Text != "")
            {
                consoleTB.Text = "Стирание...";

                tx_buff[0] = 0x06; //Write enable
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                while (port.BytesToRead < 1);
                port.Read(rx_buff, 0, 1);                
                port.RtsEnable = false;

                Thread.Sleep(5);

                tx_buff[0] = 0xC7; //ERASE
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                while (port.BytesToRead < 1) ;
                port.Read(rx_buff, 0, 1);
                port.RtsEnable = false;
                
                //Read SREG1 and wait while BSY
                tx_buff[0] = 0x05;
                tx_buff[1] = 0x00;
                while(true)
                { 
                    port.RtsEnable = true;
                    for (int i = 0; i < 2; i++) port.Write(tx_buff, i, 1);
                    while (port.BytesToRead < 2) ;
                    port.Read(rx_buff, 0, 2);
                    port.RtsEnable = false;
                    if ((rx_buff[1] & 0x01) == 0x00) break;
                }

                consoleTB.Text = "Стирание завершено";
            }
        }
        private void openBTN_Click(object sender, EventArgs e)
        {
            if (modelCB.Text != "")
            {
                open_file();
            }
        }

        private void writeBTN_Click(object sender, EventArgs e)
        {
            if (isOpen && modelCB.Text != "")
            {
                mainPB.Maximum = wsize;
                mainPB.Value = 0;

                consoleTB.Text = "Запись...";

                for (int i = 0; i < wsize; i += psize)
                {
                    //Write enable
                    tx_buff[0] = 0x06;
                    port.RtsEnable = true;
                    port.Write(tx_buff, 0, 1);
                    while (port.BytesToRead < 1) ;
                    port.Read(rx_buff, 0, 1);
                    port.RtsEnable = false;

                    tx_buff[0] = 0x02; //Page Write
                    tx_buff[1] = Convert.ToByte((i >> 16) & 0xFF);
                    tx_buff[2] = Convert.ToByte((i >> 8) & 0xFF);
                    tx_buff[3] = Convert.ToByte(i & 0xFF);
                    port.RtsEnable = true;
                    for (int j = 0; j < 4; j++) port.Write(tx_buff, j, 1);
                    for (int k = 0; k < psize; k++) port.Write(writeBuff, i + k, 1);
                    while (port.BytesToRead < (psize + 4)) ;
                    port.Read(rx_buff, 0, (psize + 4));
                    port.RtsEnable = false;
                    mainPB.Value = i;

                    //Read SREG1 and wait while BSY
                    tx_buff[0] = 0x05;
                    tx_buff[1] = 0x00;
                    while (true)
                    {
                        port.RtsEnable = true;
                        for (int g = 0; g < 2; g++) port.Write(tx_buff, g, 1);
                        while (port.BytesToRead < 2) ;
                        port.Read(rx_buff, 0, 2);
                        port.RtsEnable = false;
                        if ((rx_buff[1] & 0x01) == 0x00) break;
                    }
                }
                mainPB.Value = 0;
                consoleTB.Text = "Запись завершена";
            }
        }

        private void verifyBTN_Click(object sender, EventArgs e)
        {
            if (isOpen && modelCB.Text != "" && writeBuff.Length > 0)
            {
                readBuff = new byte[fsize];
                int errors = 0;

                mainPB.Maximum = fsize;
                mainPB.Value = 0;

                consoleTB.Text = "Чтение...";

                tx_buff[0] = 0x03;
                tx_buff[1] = 0x00;
                tx_buff[2] = 0x00;
                tx_buff[3] = 0x00;
                port.RtsEnable = true;
                for (int i = 0; i < 4; i++) port.Write(tx_buff, i, 1);
                Thread.Sleep(1);
                port.Read(rx_buff, 0, 4);

                for (int i = 0; i < fsize; i += 128)
                {
                    for (int k = 0; k < 128; k++) port.Write(tx_buff, 1, 1);
                    mainPB.Value = i;
                    while (port.BytesToRead < 128) ;
                    port.Read(readBuff, i, 128);
                }
                port.RtsEnable = false;

                mainPB.Value = 0;

                for(int i = 0; i < writeBuff.Length; i++) if (writeBuff[i] != readBuff[i]) errors++;
                if (errors > 0) consoleTB.Text = errors.ToString() + " ошибок";
                else consoleTB.Text = "Ошибок нет";
            }
        }

        private void wrSregBTN_Click(object sender, EventArgs e)
        {
            if (isOpen && modelCB.Text != "")
            {
                consoleTB.Text = "Запись SREG...";

                tx_buff[0] = 0x50; //Write enable
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                while (port.BytesToRead < 1) ;
                port.Read(rx_buff, 0, 1);
                port.RtsEnable = false;

                Thread.Sleep(5);

                tx_buff[0] = 0x01; //Write SREG1
                tx_buff[1] = strToByte(lsregTB.Text);
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                port.Write(tx_buff, 1, 1);
                while (port.BytesToRead < 2) ;
                port.Read(rx_buff, 0, 2);
                port.RtsEnable = false;

                Thread.Sleep(5);

                tx_buff[0] = 0x50; //Write enable
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                while (port.BytesToRead < 1) ;
                port.Read(rx_buff, 0, 1);
                port.RtsEnable = false;

                Thread.Sleep(5);

                tx_buff[0] = 0x31; //Write SREG2
                tx_buff[1] = strToByte(msregTB.Text);
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                port.Write(tx_buff, 1, 1);
                while (port.BytesToRead < 2) ;
                port.Read(rx_buff, 0, 2);
                port.RtsEnable = false;

                Thread.Sleep(5);

                tx_buff[0] = 0x50; //Write enable
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                while (port.BytesToRead < 1) ;
                port.Read(rx_buff, 0, 1);
                port.RtsEnable = false;

                Thread.Sleep(5);

                tx_buff[0] = 0x11; //Write SREG3
                tx_buff[1] = strToByte(hsregTB.Text);
                port.RtsEnable = true;
                port.Write(tx_buff, 0, 1);
                port.Write(tx_buff, 1, 1);
                while (port.BytesToRead < 2) ;
                port.Read(rx_buff, 0, 2);
                port.RtsEnable = false;

                consoleTB.Text = "Запись SREG завершена";
            }
        }

        private void saveBTN_Click(object sender, EventArgs e)
        {
            if (readBuff != null) //Если массив не пустой
            {
                if (saveFile.ShowDialog() == DialogResult.OK)
                {
                    //Get the path of specified file
                    filePath = saveFile.FileName;

                    //Обрезаем лишние 0xFF с конца массива
                    Int32 index = 0;
                    byte ff;
                    do
                    {
                        ff = readBuff[(readBuff.Length - 1) - index];
                        if (ff == 0xFF) { index++; }
                    }
                    while (ff == 0xFF);

                    if (index == 0) { File.WriteAllBytes(filePath, readBuff); }
                    else
                    {
                        byte[] temp_arr = new byte[readBuff.Length - index];
                        for (int x = 0; x < temp_arr.Length; x++)
                        {
                            temp_arr[x] = readBuff[x];
                        }
                        File.WriteAllBytes(filePath, temp_arr);
                    }
                }
            }
        }
    }
}
