namespace LayoutDesigner
{
    partial class frmDesignChildLayout
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if( disposing && (components != null) ) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.pnlDesigner = new System.Windows.Forms.Panel();
            this.tabDesigner = new System.Windows.Forms.TabControl();
            this.tbpParam = new System.Windows.Forms.TabPage();
            this.tbpTmpl = new System.Windows.Forms.TabPage();
            this.tbpGroup = new System.Windows.Forms.TabPage();
            this.tbpTotal = new System.Windows.Forms.TabPage();
            this.topDevice = new System.Windows.Forms.TabPage();
            this.pnlDesigner.SuspendLayout();
            this.tabDesigner.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(3, 478);
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(3, 21);
            // 
            // winlblTitle
            // 
            this.winlblTitle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.winlblTitle.Size = new System.Drawing.Size(296, 18);
            this.winlblTitle.Text = "　デザイナーウィンドウ";
            // 
            // pnlDesigner
            // 
            this.pnlDesigner.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlDesigner.Controls.Add(this.tabDesigner);
            this.pnlDesigner.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlDesigner.Location = new System.Drawing.Point(2, 20);
            this.pnlDesigner.Name = "pnlDesigner";
            this.pnlDesigner.Size = new System.Drawing.Size(296, 562);
            this.pnlDesigner.TabIndex = 4;
            // 
            // tabDesigner
            // 
            this.tabDesigner.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tabDesigner.Controls.Add(this.tbpParam);
            this.tabDesigner.Controls.Add(this.tbpTmpl);
            this.tabDesigner.Controls.Add(this.tbpGroup);
            this.tabDesigner.Controls.Add(this.tbpTotal);
            this.tabDesigner.Controls.Add(this.topDevice);
            this.tabDesigner.HotTrack = true;
            this.tabDesigner.Location = new System.Drawing.Point(-4, 0);
            this.tabDesigner.Name = "tabDesigner";
            this.tabDesigner.SelectedIndex = 0;
            this.tabDesigner.Size = new System.Drawing.Size(302, 564);
            this.tabDesigner.TabIndex = 0;
            // 
            // tbpParam
            // 
            this.tbpParam.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.tbpParam.Location = new System.Drawing.Point(4, 24);
            this.tbpParam.Name = "tbpParam";
            this.tbpParam.Size = new System.Drawing.Size(294, 536);
            this.tbpParam.TabIndex = 0;
            this.tbpParam.Text = "パラメータ";
            // 
            // tbpTmpl
            // 
            this.tbpTmpl.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.tbpTmpl.Location = new System.Drawing.Point(4, 24);
            this.tbpTmpl.Name = "tbpTmpl";
            this.tbpTmpl.Size = new System.Drawing.Size(294, 536);
            this.tbpTmpl.TabIndex = 1;
            this.tbpTmpl.Text = "テンプレート";
            // 
            // tbpGroup
            // 
            this.tbpGroup.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.tbpGroup.Location = new System.Drawing.Point(4, 24);
            this.tbpGroup.Name = "tbpGroup";
            this.tbpGroup.Size = new System.Drawing.Size(294, 536);
            this.tbpGroup.TabIndex = 2;
            this.tbpGroup.Text = "グループ";
            // 
            // tbpTotal
            // 
            this.tbpTotal.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.tbpTotal.Location = new System.Drawing.Point(4, 24);
            this.tbpTotal.Name = "tbpTotal";
            this.tbpTotal.Size = new System.Drawing.Size(294, 536);
            this.tbpTotal.TabIndex = 3;
            this.tbpTotal.Text = "集計内訳";
            // 
            // topDevice
            // 
            this.topDevice.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.topDevice.Location = new System.Drawing.Point(4, 24);
            this.topDevice.Name = "topDevice";
            this.topDevice.Size = new System.Drawing.Size(294, 536);
            this.topDevice.TabIndex = 4;
            this.topDevice.Text = "レイアウト";
            // 
            // frmDesignChildLayout
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(300, 584);
            this.Controls.Add(this.pnlDesigner);
            this.MinimumSize = new System.Drawing.Size(300, 400);
            this.Name = "frmDesignChildLayout";
            this.Activated += new System.EventHandler(this.frmDesignChildLayout_Activated);
            this.Deactivate += new System.EventHandler(this.frmDesignChildLayout_Deactivate);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.pnlDesigner, 0);
            this.pnlDesigner.ResumeLayout(false);
            this.tabDesigner.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlDesigner;
        private System.Windows.Forms.TabControl tabDesigner;
        private System.Windows.Forms.TabPage tbpParam;
        private System.Windows.Forms.TabPage tbpTmpl;
        private System.Windows.Forms.TabPage tbpGroup;
        private System.Windows.Forms.TabPage tbpTotal;
        private System.Windows.Forms.TabPage topDevice;
    }
}