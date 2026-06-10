namespace LayoutDesigner
{
    partial class frmMainMenuChildMakeReport
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
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMainMenuChildMakeReport));
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.pnlFacility = new System.Windows.Forms.Panel();
            this.dgvFacilityData = new System.Windows.Forms.DataGridView();
            this.lblKey = new System.Windows.Forms.Label();
            this.txtFacility = new System.Windows.Forms.TextBox();
            this.rldFacillitySearch = new LayoutDesigner.RldDropDownButton();
            this.pnlSearch = new System.Windows.Forms.Panel();
            this.btnSearchOK = new System.Windows.Forms.Button();
            this.rldTriStateTreeViewSearch = new LayoutDesigner.RldTriStateTreeView();
            this.imageList = new System.Windows.Forms.ImageList(this.components);
            this.lblFree = new System.Windows.Forms.Label();
            this.btnSearchClear = new System.Windows.Forms.Button();
            this.txtFree = new System.Windows.Forms.TextBox();
            this.rldDropDownButtonSearch = new LayoutDesigner.RldDropDownButton();
            this.dgvData = new System.Windows.Forms.DataGridView();
            this.lblSample = new System.Windows.Forms.Label();
            this.picThumb = new System.Windows.Forms.PictureBox();
            this.pnlFooter = new System.Windows.Forms.Panel();
            this.lblFacilityCd = new System.Windows.Forms.Label();
            this.btnOK = new System.Windows.Forms.Button();
            this.toolTipMainMenuChildMakeReport = new System.Windows.Forms.ToolTip(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.pnlFacility.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvFacilityData)).BeginInit();
            this.pnlSearch.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvData)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picThumb)).BeginInit();
            this.pnlFooter.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(709, 509);
            this.btnStop.TabIndex = 5;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(4, 0);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(4, 18);
            this.btnFocusControl.TabIndex = 3;
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(784, 0);
            this.winlblTitle.Text = "";
            // 
            // splitContainer
            // 
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.splitContainer.IsSplitterFixed = true;
            this.splitContainer.Location = new System.Drawing.Point(0, 0);
            this.splitContainer.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.pnlFacility);
            this.splitContainer.Panel1.Controls.Add(this.rldFacillitySearch);
            this.splitContainer.Panel1.Controls.Add(this.pnlSearch);
            this.splitContainer.Panel1.Controls.Add(this.rldDropDownButtonSearch);
            this.splitContainer.Panel1.Controls.Add(this.dgvData);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.lblSample);
            this.splitContainer.Panel2.Controls.Add(this.picThumb);
            this.splitContainer.Size = new System.Drawing.Size(784, 484);
            this.splitContainer.SplitterDistance = 450;
            this.splitContainer.SplitterWidth = 5;
            this.splitContainer.TabIndex = 2;
            // 
            // pnlFacility
            // 
            this.pnlFacility.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(90)))), ((int)(((byte)(90)))), ((int)(((byte)(90)))));
            this.pnlFacility.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlFacility.Controls.Add(this.dgvFacilityData);
            this.pnlFacility.Controls.Add(this.lblKey);
            this.pnlFacility.Controls.Add(this.txtFacility);
            this.pnlFacility.Location = new System.Drawing.Point(243, 34);
            this.pnlFacility.Name = "pnlFacility";
            this.pnlFacility.Size = new System.Drawing.Size(200, 220);
            this.pnlFacility.TabIndex = 1;
            this.pnlFacility.Visible = false;
            // 
            // dgvFacilityData
            // 
            this.dgvFacilityData.AllowUserToAddRows = false;
            this.dgvFacilityData.AllowUserToDeleteRows = false;
            this.dgvFacilityData.AllowUserToResizeRows = false;
            this.dgvFacilityData.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvFacilityData.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvFacilityData.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvFacilityData.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvFacilityData.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            this.dgvFacilityData.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvFacilityData.ColumnHeadersHeight = 32;
            this.dgvFacilityData.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.dgvFacilityData.ColumnHeadersVisible = false;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvFacilityData.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvFacilityData.EnableHeadersVisualStyles = false;
            this.dgvFacilityData.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvFacilityData.Location = new System.Drawing.Point(3, 31);
            this.dgvFacilityData.MultiSelect = false;
            this.dgvFacilityData.Name = "dgvFacilityData";
            this.dgvFacilityData.ReadOnly = true;
            this.dgvFacilityData.RowHeadersVisible = false;
            dataGridViewCellStyle3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle3.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.White;
            this.dgvFacilityData.RowsDefaultCellStyle = dataGridViewCellStyle3;
            this.dgvFacilityData.RowTemplate.Height = 25;
            this.dgvFacilityData.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvFacilityData.Size = new System.Drawing.Size(190, 180);
            this.dgvFacilityData.TabIndex = 2;
            this.dgvFacilityData.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvFacilityData_CellClick);
            // 
            // lblKey
            // 
            this.lblKey.AutoSize = true;
            this.lblKey.Location = new System.Drawing.Point(3, 7);
            this.lblKey.Name = "lblKey";
            this.lblKey.Size = new System.Drawing.Size(56, 15);
            this.lblKey.TabIndex = 0;
            this.lblKey.Text = "フリーワード";
            // 
            // txtFacility
            // 
            this.txtFacility.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFacility.Location = new System.Drawing.Point(65, 4);
            this.txtFacility.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtFacility.Name = "txtFacility";
            this.txtFacility.Size = new System.Drawing.Size(128, 23);
            this.txtFacility.TabIndex = 1;
            this.txtFacility.TextChanged += new System.EventHandler(this.txtFacility_TextChanged);
            // 
            // rldFacillitySearch
            // 
            this.rldFacillitySearch.DropDownClient = this.pnlFacility;
            this.rldFacillitySearch.DroppedDown = false;
            this.rldFacillitySearch.Location = new System.Drawing.Point(243, 4);
            this.rldFacillitySearch.Name = "rldFacillitySearch";
            this.rldFacillitySearch.Size = new System.Drawing.Size(200, 23);
            this.rldFacillitySearch.TabIndex = 1;
            this.rldFacillitySearch.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.rldFacillitySearch.Visible = false;
            this.rldFacillitySearch.TextChanged += new System.EventHandler(this.rldFacillitySearch_TextChanged);
            // 
            // pnlSearch
            // 
            this.pnlSearch.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(90)))), ((int)(((byte)(90)))), ((int)(((byte)(90)))));
            this.pnlSearch.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlSearch.Controls.Add(this.btnSearchOK);
            this.pnlSearch.Controls.Add(this.rldTriStateTreeViewSearch);
            this.pnlSearch.Controls.Add(this.lblFree);
            this.pnlSearch.Controls.Add(this.btnSearchClear);
            this.pnlSearch.Controls.Add(this.txtFree);
            this.pnlSearch.Location = new System.Drawing.Point(8, 34);
            this.pnlSearch.Name = "pnlSearch";
            this.pnlSearch.Size = new System.Drawing.Size(220, 250);
            this.pnlSearch.TabIndex = 1;
            // 
            // btnSearchOK
            // 
            this.btnSearchOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnSearchOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSearchOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSearchOK.Location = new System.Drawing.Point(163, 221);
            this.btnSearchOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnSearchOK.Name = "btnSearchOK";
            this.btnSearchOK.Size = new System.Drawing.Size(50, 23);
            this.btnSearchOK.TabIndex = 4;
            this.btnSearchOK.Text = "OK";
            this.btnSearchOK.Click += new System.EventHandler(this.btnSearchOK_Click);
            // 
            // rldTriStateTreeViewSearch
            // 
            this.rldTriStateTreeViewSearch.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.rldTriStateTreeViewSearch.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(55)))), ((int)(((byte)(55)))), ((int)(((byte)(55)))));
            this.rldTriStateTreeViewSearch.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.rldTriStateTreeViewSearch.CheckBoxes = true;
            this.rldTriStateTreeViewSearch.CheckedImageIndex = 1;
            this.rldTriStateTreeViewSearch.ForeColor = System.Drawing.Color.White;
            this.rldTriStateTreeViewSearch.ImageIndex = 0;
            this.rldTriStateTreeViewSearch.ImageList = this.imageList;
            this.rldTriStateTreeViewSearch.IndeterminateImageIndex = 2;
            this.rldTriStateTreeViewSearch.ItemHeight = 17;
            this.rldTriStateTreeViewSearch.LineColor = System.Drawing.Color.White;
            this.rldTriStateTreeViewSearch.Location = new System.Drawing.Point(3, 31);
            this.rldTriStateTreeViewSearch.Name = "rldTriStateTreeViewSearch";
            this.rldTriStateTreeViewSearch.SelectedImageIndex = 0;
            this.rldTriStateTreeViewSearch.Size = new System.Drawing.Size(210, 180);
            this.rldTriStateTreeViewSearch.TabIndex = 2;
            this.rldTriStateTreeViewSearch.UncheckedImageIndex = 3;
            this.rldTriStateTreeViewSearch.UseCustomImages = true;
            // 
            // imageList
            // 
            this.imageList.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imageList.ImageStream")));
            this.imageList.TransparentColor = System.Drawing.Color.Fuchsia;
            this.imageList.Images.SetKeyName(0, "");
            this.imageList.Images.SetKeyName(1, "");
            this.imageList.Images.SetKeyName(2, "");
            this.imageList.Images.SetKeyName(3, "");
            // 
            // lblFree
            // 
            this.lblFree.AutoSize = true;
            this.lblFree.Location = new System.Drawing.Point(3, 7);
            this.lblFree.Name = "lblFree";
            this.lblFree.Size = new System.Drawing.Size(56, 15);
            this.lblFree.TabIndex = 0;
            this.lblFree.Text = "フリーワード";
            // 
            // btnSearchClear
            // 
            this.btnSearchClear.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnSearchClear.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSearchClear.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSearchClear.Location = new System.Drawing.Point(107, 221);
            this.btnSearchClear.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnSearchClear.Name = "btnSearchClear";
            this.btnSearchClear.Size = new System.Drawing.Size(50, 23);
            this.btnSearchClear.TabIndex = 3;
            this.btnSearchClear.Text = "クリア";
            this.btnSearchClear.Click += new System.EventHandler(this.btnSearchClear_Click);
            // 
            // txtFree
            // 
            this.txtFree.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFree.Location = new System.Drawing.Point(65, 4);
            this.txtFree.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtFree.Name = "txtFree";
            this.txtFree.Size = new System.Drawing.Size(148, 23);
            this.txtFree.TabIndex = 1;
            this.txtFree.KeyDown += new System.Windows.Forms.KeyEventHandler(this.txtFree_KeyDown);
            // 
            // rldDropDownButtonSearch
            // 
            this.rldDropDownButtonSearch.DropDownClient = this.pnlSearch;
            this.rldDropDownButtonSearch.DroppedDown = false;
            this.rldDropDownButtonSearch.Location = new System.Drawing.Point(8, 4);
            this.rldDropDownButtonSearch.Name = "rldDropDownButtonSearch";
            this.rldDropDownButtonSearch.Size = new System.Drawing.Size(220, 23);
            this.rldDropDownButtonSearch.TabIndex = 0;
            this.rldDropDownButtonSearch.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // dgvData
            // 
            this.dgvData.AllowUserToAddRows = false;
            this.dgvData.AllowUserToDeleteRows = false;
            this.dgvData.AllowUserToResizeRows = false;
            this.dgvData.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvData.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvData.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvData.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle4.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            this.dgvData.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle4;
            this.dgvData.ColumnHeadersHeight = 32;
            this.dgvData.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle5.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            dataGridViewCellStyle5.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle5.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle5.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle5.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle5.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvData.DefaultCellStyle = dataGridViewCellStyle5;
            this.dgvData.EnableHeadersVisualStyles = false;
            this.dgvData.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvData.Location = new System.Drawing.Point(4, 31);
            this.dgvData.MultiSelect = false;
            this.dgvData.Name = "dgvData";
            this.dgvData.ReadOnly = true;
            this.dgvData.RowHeadersVisible = false;
            dataGridViewCellStyle6.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle6.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle6.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle6.SelectionForeColor = System.Drawing.Color.White;
            this.dgvData.RowsDefaultCellStyle = dataGridViewCellStyle6;
            this.dgvData.RowTemplate.Height = 25;
            this.dgvData.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvData.Size = new System.Drawing.Size(443, 448);
            this.dgvData.TabIndex = 2;
            this.dgvData.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvData_CellDoubleClick);
            this.dgvData.RowEnter += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvData_RowEnter);
            // 
            // lblSample
            // 
            this.lblSample.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblSample.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(100)))), ((int)(((byte)(100)))));
            this.lblSample.Location = new System.Drawing.Point(29, 210);
            this.lblSample.Name = "lblSample";
            this.lblSample.Size = new System.Drawing.Size(251, 65);
            this.lblSample.TabIndex = 0;
            this.lblSample.Text = "サンプル画像はありません";
            this.lblSample.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // picThumb
            // 
            this.picThumb.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(100)))), ((int)(((byte)(100)))));
            this.picThumb.Dock = System.Windows.Forms.DockStyle.Fill;
            this.picThumb.Location = new System.Drawing.Point(0, 0);
            this.picThumb.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.picThumb.Name = "picThumb";
            this.picThumb.Size = new System.Drawing.Size(329, 484);
            this.picThumb.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picThumb.TabIndex = 2;
            this.picThumb.TabStop = false;
            // 
            // pnlFooter
            // 
            this.pnlFooter.Controls.Add(this.lblFacilityCd);
            this.pnlFooter.Controls.Add(this.btnOK);
            this.pnlFooter.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlFooter.Location = new System.Drawing.Point(0, 484);
            this.pnlFooter.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlFooter.Name = "pnlFooter";
            this.pnlFooter.Size = new System.Drawing.Size(784, 40);
            this.pnlFooter.TabIndex = 4;
            // 
            // lblFacilityCd
            // 
            this.lblFacilityCd.AutoSize = true;
            this.lblFacilityCd.Location = new System.Drawing.Point(23, 16);
            this.lblFacilityCd.Name = "lblFacilityCd";
            this.lblFacilityCd.Size = new System.Drawing.Size(0, 15);
            this.lblFacilityCd.TabIndex = 0;
            this.lblFacilityCd.Visible = false;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.Location = new System.Drawing.Point(581, 5);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(200, 30);
            this.btnOK.TabIndex = 0;
            this.btnOK.Text = "選択した帳票を作成";
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // frmMainMenuChildMakeReport
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(784, 524);
            this.CloseBox = false;
            this.CloseEscapeKey = false;
            this.Controls.Add(this.splitContainer);
            this.Controls.Add(this.pnlFooter);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmMainMenuChildMakeReport";
            this.ShowInTaskbar = false;
            this.Controls.SetChildIndex(this.pnlFooter, 0);
            this.Controls.SetChildIndex(this.splitContainer, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.pnlFacility.ResumeLayout(false);
            this.pnlFacility.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvFacilityData)).EndInit();
            this.pnlSearch.ResumeLayout(false);
            this.pnlSearch.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvData)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picThumb)).EndInit();
            this.pnlFooter.ResumeLayout(false);
            this.pnlFooter.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer;
        private RldDropDownButton rldDropDownButtonSearch;
        private System.Windows.Forms.Panel pnlSearch;
        private System.Windows.Forms.Button btnSearchOK;
        private RldTriStateTreeView rldTriStateTreeViewSearch;
        private System.Windows.Forms.Label lblFree;
        private System.Windows.Forms.Button btnSearchClear;
        private System.Windows.Forms.TextBox txtFree;
        private System.Windows.Forms.DataGridView dgvData;
        private System.Windows.Forms.Label lblSample;
        private System.Windows.Forms.PictureBox picThumb;
        private System.Windows.Forms.Panel pnlFooter;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.ImageList imageList;
        private System.Windows.Forms.ToolTip toolTipMainMenuChildMakeReport;
        private RldDropDownButton rldFacillitySearch;
        private System.Windows.Forms.Panel pnlFacility;
        private System.Windows.Forms.DataGridView dgvFacilityData;
        private System.Windows.Forms.Label lblKey;
        private System.Windows.Forms.TextBox txtFacility;
        private System.Windows.Forms.Label lblFacilityCd;
    }
}