namespace FpgaSpiProg
{
    partial class Form1
    {
        /// <summary>
        /// Обязательная переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Требуемый метод для поддержки конструктора — не изменяйте 
        /// содержимое этого метода с помощью редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            this.codeTB = new System.Windows.Forms.TextBox();
            this.consoleTB = new System.Windows.Forms.TextBox();
            this.portCB = new System.Windows.Forms.ComboBox();
            this.baudeCB = new System.Windows.Forms.ComboBox();
            this.connectBTN = new System.Windows.Forms.Button();
            this.scanBTN = new System.Windows.Forms.Button();
            this.readBTN = new System.Windows.Forms.Button();
            this.writeBTN = new System.Windows.Forms.Button();
            this.eraseBTN = new System.Windows.Forms.Button();
            this.verifyBTN = new System.Windows.Forms.Button();
            this.openBTN = new System.Windows.Forms.Button();
            this.saveBTN = new System.Windows.Forms.Button();
            this.idBTN = new System.Windows.Forms.Button();
            this.idTB = new System.Windows.Forms.TextBox();
            this.hsregTB = new System.Windows.Forms.TextBox();
            this.msregTB = new System.Windows.Forms.TextBox();
            this.lsregTB = new System.Windows.Forms.TextBox();
            this.rdSregBTN = new System.Windows.Forms.Button();
            this.wrSregBTN = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.modelCB = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.mainPB = new System.Windows.Forms.ProgressBar();
            this.SuspendLayout();
            // 
            // codeTB
            // 
            this.codeTB.Font = new System.Drawing.Font("Consolas", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.codeTB.Location = new System.Drawing.Point(12, 12);
            this.codeTB.Multiline = true;
            this.codeTB.Name = "codeTB";
            this.codeTB.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.codeTB.Size = new System.Drawing.Size(424, 501);
            this.codeTB.TabIndex = 0;
            // 
            // consoleTB
            // 
            this.consoleTB.Location = new System.Drawing.Point(455, 426);
            this.consoleTB.Multiline = true;
            this.consoleTB.Name = "consoleTB";
            this.consoleTB.Size = new System.Drawing.Size(183, 69);
            this.consoleTB.TabIndex = 1;
            // 
            // portCB
            // 
            this.portCB.FormattingEnabled = true;
            this.portCB.Location = new System.Drawing.Point(560, 12);
            this.portCB.Name = "portCB";
            this.portCB.Size = new System.Drawing.Size(78, 24);
            this.portCB.TabIndex = 2;
            // 
            // baudeCB
            // 
            this.baudeCB.FormattingEnabled = true;
            this.baudeCB.Items.AddRange(new object[] {
            "57600",
            "115200",
            "256000",
            "921600",
            "2000000"});
            this.baudeCB.Location = new System.Drawing.Point(560, 42);
            this.baudeCB.Name = "baudeCB";
            this.baudeCB.Size = new System.Drawing.Size(78, 24);
            this.baudeCB.TabIndex = 3;
            this.baudeCB.Text = "921600";
            // 
            // connectBTN
            // 
            this.connectBTN.Location = new System.Drawing.Point(455, 12);
            this.connectBTN.Name = "connectBTN";
            this.connectBTN.Size = new System.Drawing.Size(99, 24);
            this.connectBTN.TabIndex = 4;
            this.connectBTN.Text = "CONNECT";
            this.connectBTN.UseVisualStyleBackColor = true;
            this.connectBTN.Click += new System.EventHandler(this.connectBTN_Click);
            // 
            // scanBTN
            // 
            this.scanBTN.Location = new System.Drawing.Point(455, 42);
            this.scanBTN.Name = "scanBTN";
            this.scanBTN.Size = new System.Drawing.Size(99, 24);
            this.scanBTN.TabIndex = 5;
            this.scanBTN.Text = "SCAN";
            this.scanBTN.UseVisualStyleBackColor = true;
            this.scanBTN.Click += new System.EventHandler(this.scanBTN_Click);
            // 
            // readBTN
            // 
            this.readBTN.Location = new System.Drawing.Point(496, 109);
            this.readBTN.Name = "readBTN";
            this.readBTN.Size = new System.Drawing.Size(99, 33);
            this.readBTN.TabIndex = 6;
            this.readBTN.Text = "READ";
            this.readBTN.UseVisualStyleBackColor = true;
            this.readBTN.Click += new System.EventHandler(this.readBTN_Click);
            // 
            // writeBTN
            // 
            this.writeBTN.Location = new System.Drawing.Point(496, 148);
            this.writeBTN.Name = "writeBTN";
            this.writeBTN.Size = new System.Drawing.Size(99, 33);
            this.writeBTN.TabIndex = 7;
            this.writeBTN.Text = "WRITE";
            this.writeBTN.UseVisualStyleBackColor = true;
            this.writeBTN.Click += new System.EventHandler(this.writeBTN_Click);
            // 
            // eraseBTN
            // 
            this.eraseBTN.Location = new System.Drawing.Point(496, 187);
            this.eraseBTN.Name = "eraseBTN";
            this.eraseBTN.Size = new System.Drawing.Size(99, 33);
            this.eraseBTN.TabIndex = 8;
            this.eraseBTN.Text = "ERASE";
            this.eraseBTN.UseVisualStyleBackColor = true;
            this.eraseBTN.Click += new System.EventHandler(this.eraseBTN_Click);
            // 
            // verifyBTN
            // 
            this.verifyBTN.Location = new System.Drawing.Point(496, 226);
            this.verifyBTN.Name = "verifyBTN";
            this.verifyBTN.Size = new System.Drawing.Size(99, 33);
            this.verifyBTN.TabIndex = 9;
            this.verifyBTN.Text = "VERIFY";
            this.verifyBTN.UseVisualStyleBackColor = true;
            this.verifyBTN.Click += new System.EventHandler(this.verifyBTN_Click);
            // 
            // openBTN
            // 
            this.openBTN.Location = new System.Drawing.Point(442, 266);
            this.openBTN.Name = "openBTN";
            this.openBTN.Size = new System.Drawing.Size(99, 33);
            this.openBTN.TabIndex = 10;
            this.openBTN.Text = "OPEN";
            this.openBTN.UseVisualStyleBackColor = true;
            this.openBTN.Click += new System.EventHandler(this.openBTN_Click);
            // 
            // saveBTN
            // 
            this.saveBTN.Location = new System.Drawing.Point(547, 266);
            this.saveBTN.Name = "saveBTN";
            this.saveBTN.Size = new System.Drawing.Size(99, 33);
            this.saveBTN.TabIndex = 11;
            this.saveBTN.Text = "SAVE";
            this.saveBTN.UseVisualStyleBackColor = true;
            this.saveBTN.Click += new System.EventHandler(this.saveBTN_Click);
            // 
            // idBTN
            // 
            this.idBTN.Location = new System.Drawing.Point(455, 310);
            this.idBTN.Name = "idBTN";
            this.idBTN.Size = new System.Drawing.Size(86, 23);
            this.idBTN.TabIndex = 13;
            this.idBTN.Text = "GET ID";
            this.idBTN.UseVisualStyleBackColor = true;
            this.idBTN.Click += new System.EventHandler(this.idBTN_Click);
            // 
            // idTB
            // 
            this.idTB.Location = new System.Drawing.Point(560, 310);
            this.idTB.Name = "idTB";
            this.idTB.Size = new System.Drawing.Size(72, 22);
            this.idTB.TabIndex = 14;
            // 
            // hsregTB
            // 
            this.hsregTB.Location = new System.Drawing.Point(586, 340);
            this.hsregTB.Name = "hsregTB";
            this.hsregTB.Size = new System.Drawing.Size(46, 22);
            this.hsregTB.TabIndex = 15;
            // 
            // msregTB
            // 
            this.msregTB.Location = new System.Drawing.Point(586, 368);
            this.msregTB.Name = "msregTB";
            this.msregTB.Size = new System.Drawing.Size(46, 22);
            this.msregTB.TabIndex = 16;
            // 
            // lsregTB
            // 
            this.lsregTB.Location = new System.Drawing.Point(586, 396);
            this.lsregTB.Name = "lsregTB";
            this.lsregTB.Size = new System.Drawing.Size(46, 22);
            this.lsregTB.TabIndex = 17;
            // 
            // rdSregBTN
            // 
            this.rdSregBTN.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.rdSregBTN.Location = new System.Drawing.Point(455, 352);
            this.rdSregBTN.Name = "rdSregBTN";
            this.rdSregBTN.Size = new System.Drawing.Size(86, 23);
            this.rdSregBTN.TabIndex = 18;
            this.rdSregBTN.Text = "RD SREG";
            this.rdSregBTN.UseVisualStyleBackColor = true;
            this.rdSregBTN.Click += new System.EventHandler(this.rdSregBTN_Click);
            // 
            // wrSregBTN
            // 
            this.wrSregBTN.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.wrSregBTN.Location = new System.Drawing.Point(455, 381);
            this.wrSregBTN.Name = "wrSregBTN";
            this.wrSregBTN.Size = new System.Drawing.Size(86, 23);
            this.wrSregBTN.TabIndex = 19;
            this.wrSregBTN.Text = "WR SREG";
            this.wrSregBTN.UseVisualStyleBackColor = true;
            this.wrSregBTN.Click += new System.EventHandler(this.wrSregBTN_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(563, 343);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(17, 16);
            this.label1.TabIndex = 20;
            this.label1.Text = "H";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(563, 371);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(18, 16);
            this.label2.TabIndex = 21;
            this.label2.Text = "M";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(564, 399);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(14, 16);
            this.label3.TabIndex = 22;
            this.label3.Text = "L";
            // 
            // modelCB
            // 
            this.modelCB.FormattingEnabled = true;
            this.modelCB.Items.AddRange(new object[] {
            "W25Q40",
            "W25Q80",
            "W25Q16",
            "W25Q32",
            "W25Q64"});
            this.modelCB.Location = new System.Drawing.Point(560, 72);
            this.modelCB.Name = "modelCB";
            this.modelCB.Size = new System.Drawing.Size(78, 24);
            this.modelCB.TabIndex = 23;
            this.modelCB.SelectedIndexChanged += new System.EventHandler(this.modelCB_SelectedIndexChanged);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(489, 77);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(63, 16);
            this.label4.TabIndex = 24;
            this.label4.Text = "Spi Flash";
            // 
            // mainPB
            // 
            this.mainPB.Location = new System.Drawing.Point(455, 501);
            this.mainPB.Name = "mainPB";
            this.mainPB.Size = new System.Drawing.Size(183, 12);
            this.mainPB.TabIndex = 25;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(653, 525);
            this.Controls.Add(this.mainPB);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.modelCB);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.wrSregBTN);
            this.Controls.Add(this.rdSregBTN);
            this.Controls.Add(this.lsregTB);
            this.Controls.Add(this.msregTB);
            this.Controls.Add(this.hsregTB);
            this.Controls.Add(this.idTB);
            this.Controls.Add(this.idBTN);
            this.Controls.Add(this.saveBTN);
            this.Controls.Add(this.openBTN);
            this.Controls.Add(this.verifyBTN);
            this.Controls.Add(this.eraseBTN);
            this.Controls.Add(this.writeBTN);
            this.Controls.Add(this.readBTN);
            this.Controls.Add(this.scanBTN);
            this.Controls.Add(this.connectBTN);
            this.Controls.Add(this.baudeCB);
            this.Controls.Add(this.portCB);
            this.Controls.Add(this.consoleTB);
            this.Controls.Add(this.codeTB);
            this.Name = "Form1";
            this.Text = "FPGA SpiFlash Loader";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox codeTB;
        private System.Windows.Forms.TextBox consoleTB;
        private System.Windows.Forms.ComboBox portCB;
        private System.Windows.Forms.ComboBox baudeCB;
        private System.Windows.Forms.Button connectBTN;
        private System.Windows.Forms.Button scanBTN;
        private System.Windows.Forms.Button readBTN;
        private System.Windows.Forms.Button writeBTN;
        private System.Windows.Forms.Button eraseBTN;
        private System.Windows.Forms.Button verifyBTN;
        private System.Windows.Forms.Button openBTN;
        private System.Windows.Forms.Button saveBTN;
        private System.Windows.Forms.Button idBTN;
        private System.Windows.Forms.TextBox idTB;
        private System.Windows.Forms.TextBox hsregTB;
        private System.Windows.Forms.TextBox msregTB;
        private System.Windows.Forms.TextBox lsregTB;
        private System.Windows.Forms.Button rdSregBTN;
        private System.Windows.Forms.Button wrSregBTN;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox modelCB;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.ProgressBar mainPB;
    }
}

