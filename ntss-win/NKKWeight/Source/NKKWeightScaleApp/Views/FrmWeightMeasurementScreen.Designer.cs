namespace NKKWeightScaleApp.Views
{
    partial class FrmWeightMeasurementScreen
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
            if (disposing && (components != null))
            {
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
            this.label2 = new System.Windows.Forms.Label();
            this.lblPatientID = new System.Windows.Forms.Label();
            this.btnDetail = new System.Windows.Forms.Button();
            this.label5 = new System.Windows.Forms.Label();
            this.btnTreatmentConditions = new System.Windows.Forms.Button();
            this.btnWeightAndWheelchair = new System.Windows.Forms.Button();
            this.btnSelectWheelchair = new System.Windows.Forms.Button();
            this.lblWheelchairValue = new System.Windows.Forms.Label();
            this.btnPacking = new System.Windows.Forms.Button();
            this.btnWaterRemovalRestriction = new System.Windows.Forms.Button();
            this.lblPackingValue = new System.Windows.Forms.Label();
            this.lblWaterRemovalCompensationValue = new System.Windows.Forms.Label();
            this.btnSend = new System.Windows.Forms.Button();
            this.txtMeasuredValue = new System.Windows.Forms.TextBox();
            this.txtWeightValue = new System.Windows.Forms.TextBox();
            this.btnCancel = new System.Windows.Forms.Button();
            this.lblPatientName = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.lblDialysisTime = new System.Windows.Forms.Label();
            this.btnSelectBed = new System.Windows.Forms.Button();
            this.lblUnit0 = new System.Windows.Forms.Label();
            this.lblUnit1 = new System.Windows.Forms.Label();
            this.ckbPrint = new System.Windows.Forms.CheckBox();
            this.lblPatientSame = new System.Windows.Forms.Label();
            this.listViewError = new System.Windows.Forms.ListView();
            this.columnHeader1 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader2 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.btnWheelchair = new System.Windows.Forms.Button();
            this.btnWeight = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(373, 109);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(58, 38);
            this.label2.TabIndex = 0;
            this.label2.Text = "ID:";
            // 
            // lblPatientID
            // 
            this.lblPatientID.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPatientID.Location = new System.Drawing.Point(441, 109);
            this.lblPatientID.Name = "lblPatientID";
            this.lblPatientID.Size = new System.Drawing.Size(422, 48);
            this.lblPatientID.TabIndex = 0;
            this.lblPatientID.Text = "000000000000";
            // 
            // btnDetail
            // 
            this.btnDetail.BackColor = System.Drawing.Color.Goldenrod;
            this.btnDetail.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnDetail.ForeColor = System.Drawing.Color.White;
            this.btnDetail.Location = new System.Drawing.Point(1038, 107);
            this.btnDetail.Name = "btnDetail";
            this.btnDetail.Size = new System.Drawing.Size(202, 50);
            this.btnDetail.TabIndex = 5;
            this.btnDetail.Text = "詳細";
            this.btnDetail.UseVisualStyleBackColor = false;
            this.btnDetail.Click += new System.EventHandler(this.btnDetail_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 30F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label5.Location = new System.Drawing.Point(4, 273);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(167, 46);
            this.label5.TabIndex = 0;
            this.label5.Text = "測定値 :";
            // 
            // btnTreatmentConditions
            // 
            this.btnTreatmentConditions.BackColor = System.Drawing.Color.Goldenrod;
            this.btnTreatmentConditions.Font = new System.Drawing.Font("Microsoft Sans Serif", 39.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnTreatmentConditions.ForeColor = System.Drawing.Color.White;
            this.btnTreatmentConditions.Location = new System.Drawing.Point(854, 260);
            this.btnTreatmentConditions.Name = "btnTreatmentConditions";
            this.btnTreatmentConditions.Size = new System.Drawing.Size(386, 67);
            this.btnTreatmentConditions.TabIndex = 7;
            this.btnTreatmentConditions.Text = "治療条件";
            this.btnTreatmentConditions.UseVisualStyleBackColor = false;
            this.btnTreatmentConditions.Click += new System.EventHandler(this.btnTreatmentConditions_Click);
            // 
            // btnWeightAndWheelchair
            // 
            this.btnWeightAndWheelchair.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnWeightAndWheelchair.Font = new System.Drawing.Font("Microsoft Sans Serif", 39.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnWeightAndWheelchair.Location = new System.Drawing.Point(437, 10);
            this.btnWeightAndWheelchair.Name = "btnWeightAndWheelchair";
            this.btnWeightAndWheelchair.Size = new System.Drawing.Size(377, 83);
            this.btnWeightAndWheelchair.TabIndex = 3;
            this.btnWeightAndWheelchair.Text = "体重 + 車いす";
            this.btnWeightAndWheelchair.UseVisualStyleBackColor = true;
            this.btnWeightAndWheelchair.Click += new System.EventHandler(this.btnWeightAndWheelchair_Click);
            // 
            // btnSelectWheelchair
            // 
            this.btnSelectWheelchair.BackColor = System.Drawing.Color.Goldenrod;
            this.btnSelectWheelchair.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSelectWheelchair.ForeColor = System.Drawing.Color.White;
            this.btnSelectWheelchair.Location = new System.Drawing.Point(1038, 165);
            this.btnSelectWheelchair.Name = "btnSelectWheelchair";
            this.btnSelectWheelchair.Size = new System.Drawing.Size(202, 50);
            this.btnSelectWheelchair.TabIndex = 6;
            this.btnSelectWheelchair.Text = "車いす選択";
            this.btnSelectWheelchair.UseVisualStyleBackColor = false;
            this.btnSelectWheelchair.Click += new System.EventHandler(this.btnSelectWheelchair_Click);
            // 
            // lblWheelchairValue
            // 
            this.lblWheelchairValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.lblWheelchairValue.Location = new System.Drawing.Point(1038, 220);
            this.lblWheelchairValue.Name = "lblWheelchairValue";
            this.lblWheelchairValue.Size = new System.Drawing.Size(202, 31);
            this.lblWheelchairValue.TabIndex = 0;
            this.lblWheelchairValue.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btnPacking
            // 
            this.btnPacking.BackColor = System.Drawing.Color.Goldenrod;
            this.btnPacking.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnPacking.ForeColor = System.Drawing.Color.White;
            this.btnPacking.Location = new System.Drawing.Point(854, 335);
            this.btnPacking.Name = "btnPacking";
            this.btnPacking.Size = new System.Drawing.Size(190, 50);
            this.btnPacking.TabIndex = 8;
            this.btnPacking.Text = "風袋";
            this.btnPacking.UseVisualStyleBackColor = false;
            this.btnPacking.Click += new System.EventHandler(this.btnPacking_Click);
            // 
            // btnWaterRemovalRestriction
            // 
            this.btnWaterRemovalRestriction.BackColor = System.Drawing.Color.Goldenrod;
            this.btnWaterRemovalRestriction.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnWaterRemovalRestriction.ForeColor = System.Drawing.Color.White;
            this.btnWaterRemovalRestriction.Location = new System.Drawing.Point(1050, 335);
            this.btnWaterRemovalRestriction.Name = "btnWaterRemovalRestriction";
            this.btnWaterRemovalRestriction.Size = new System.Drawing.Size(190, 50);
            this.btnWaterRemovalRestriction.TabIndex = 9;
            this.btnWaterRemovalRestriction.Text = "除水補正";
            this.btnWaterRemovalRestriction.UseVisualStyleBackColor = false;
            this.btnWaterRemovalRestriction.Click += new System.EventHandler(this.btnWaterRemovalRestriction_Click);
            // 
            // lblPackingValue
            // 
            this.lblPackingValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.lblPackingValue.Location = new System.Drawing.Point(854, 389);
            this.lblPackingValue.Name = "lblPackingValue";
            this.lblPackingValue.Size = new System.Drawing.Size(186, 31);
            this.lblPackingValue.TabIndex = 0;
            this.lblPackingValue.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWaterRemovalCompensationValue
            // 
            this.lblWaterRemovalCompensationValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.lblWaterRemovalCompensationValue.Location = new System.Drawing.Point(1050, 389);
            this.lblWaterRemovalCompensationValue.Name = "lblWaterRemovalCompensationValue";
            this.lblWaterRemovalCompensationValue.Size = new System.Drawing.Size(190, 31);
            this.lblWaterRemovalCompensationValue.TabIndex = 0;
            this.lblWaterRemovalCompensationValue.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btnSend
            // 
            this.btnSend.BackColor = System.Drawing.Color.Goldenrod;
            this.btnSend.Font = new System.Drawing.Font("Microsoft Sans Serif", 39.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSend.ForeColor = System.Drawing.Color.White;
            this.btnSend.Location = new System.Drawing.Point(854, 579);
            this.btnSend.Name = "btnSend";
            this.btnSend.Size = new System.Drawing.Size(386, 66);
            this.btnSend.TabIndex = 12;
            this.btnSend.Text = "送信";
            this.btnSend.UseVisualStyleBackColor = false;
            this.btnSend.Click += new System.EventHandler(this.btnSend_Click);
            // 
            // txtMeasuredValue
            // 
            this.txtMeasuredValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 48F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtMeasuredValue.Location = new System.Drawing.Point(192, 273);
            this.txtMeasuredValue.MaxLength = 8;
            this.txtMeasuredValue.Name = "txtMeasuredValue";
            this.txtMeasuredValue.ShortcutsEnabled = false;
            this.txtMeasuredValue.Size = new System.Drawing.Size(545, 80);
            this.txtMeasuredValue.TabIndex = 0;
            this.txtMeasuredValue.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtMeasuredValue.TextChanged += new System.EventHandler(this.txtMeasuredValue_TextChanged);
            this.txtMeasuredValue.Enter += new System.EventHandler(this.TextBox_Enter);
            this.txtMeasuredValue.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.TextBox_KeyPress);
            this.txtMeasuredValue.Leave += new System.EventHandler(this.TextBox_Leave);
            // 
            // txtWeightValue
            // 
            this.txtWeightValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 48F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtWeightValue.Location = new System.Drawing.Point(192, 404);
            this.txtWeightValue.MaxLength = 8;
            this.txtWeightValue.Name = "txtWeightValue";
            this.txtWeightValue.ReadOnly = true;
            this.txtWeightValue.ShortcutsEnabled = false;
            this.txtWeightValue.Size = new System.Drawing.Size(545, 80);
            this.txtWeightValue.TabIndex = 1;
            this.txtWeightValue.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // btnCancel
            // 
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCancel.Location = new System.Drawing.Point(12, 579);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(177, 66);
            this.btnCancel.TabIndex = 13;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // lblPatientName
            // 
            this.lblPatientName.Font = new System.Drawing.Font("Microsoft Sans Serif", 36F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPatientName.Location = new System.Drawing.Point(373, 165);
            this.lblPatientName.Name = "lblPatientName";
            this.lblPatientName.Size = new System.Drawing.Size(463, 105);
            this.lblPatientName.TabIndex = 0;
            this.lblPatientName.Text = "患者名";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 30F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label6.Location = new System.Drawing.Point(4, 404);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(167, 46);
            this.label6.TabIndex = 0;
            this.label6.Text = "体重値 :";
            // 
            // lblDialysisTime
            // 
            this.lblDialysisTime.AutoSize = true;
            this.lblDialysisTime.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.lblDialysisTime.Font = new System.Drawing.Font("Microsoft Sans Serif", 39.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblDialysisTime.Location = new System.Drawing.Point(15, 109);
            this.lblDialysisTime.Name = "lblDialysisTime";
            this.lblDialysisTime.Size = new System.Drawing.Size(81, 61);
            this.lblDialysisTime.TabIndex = 0;
            this.lblDialysisTime.Text = "前";
            // 
            // btnSelectBed
            // 
            this.btnSelectBed.BackColor = System.Drawing.SystemColors.Control;
            this.btnSelectBed.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSelectBed.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSelectBed.ForeColor = System.Drawing.Color.Black;
            this.btnSelectBed.Location = new System.Drawing.Point(854, 433);
            this.btnSelectBed.Name = "btnSelectBed";
            this.btnSelectBed.Size = new System.Drawing.Size(386, 50);
            this.btnSelectBed.TabIndex = 10;
            this.btnSelectBed.Text = "ベッド選択";
            this.btnSelectBed.UseVisualStyleBackColor = false;
            this.btnSelectBed.Click += new System.EventHandler(this.btnSelectBed_Click);
            // 
            // lblUnit0
            // 
            this.lblUnit0.Font = new System.Drawing.Font("Microsoft Sans Serif", 24F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblUnit0.Location = new System.Drawing.Point(739, 270);
            this.lblUnit0.Name = "lblUnit0";
            this.lblUnit0.Size = new System.Drawing.Size(66, 80);
            this.lblUnit0.TabIndex = 48;
            this.lblUnit0.Tag = "unit";
            this.lblUnit0.Text = "kg";
            this.lblUnit0.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblUnit1
            // 
            this.lblUnit1.Font = new System.Drawing.Font("Microsoft Sans Serif", 24F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblUnit1.Location = new System.Drawing.Point(739, 404);
            this.lblUnit1.Name = "lblUnit1";
            this.lblUnit1.Size = new System.Drawing.Size(66, 80);
            this.lblUnit1.TabIndex = 49;
            this.lblUnit1.Tag = "unit";
            this.lblUnit1.Text = "kg";
            this.lblUnit1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ckbPrint
            // 
            this.ckbPrint.AutoSize = true;
            this.ckbPrint.Font = new System.Drawing.Font("Microsoft Sans Serif", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ckbPrint.Location = new System.Drawing.Point(749, 579);
            this.ckbPrint.Name = "ckbPrint";
            this.ckbPrint.Size = new System.Drawing.Size(87, 35);
            this.ckbPrint.TabIndex = 11;
            this.ckbPrint.Text = "印刷";
            this.ckbPrint.UseVisualStyleBackColor = true;
            // 
            // lblPatientSame
            // 
            this.lblPatientSame.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPatientSame.ForeColor = System.Drawing.Color.Red;
            this.lblPatientSame.Location = new System.Drawing.Point(101, 109);
            this.lblPatientSame.Name = "lblPatientSame";
            this.lblPatientSame.Size = new System.Drawing.Size(268, 38);
            this.lblPatientSame.TabIndex = 50;
            this.lblPatientSame.Text = "同姓同名患者あり";
            // 
            // listViewError
            // 
            this.listViewError.BackColor = System.Drawing.SystemColors.Control;
            this.listViewError.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.listViewError.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeader1,
            this.columnHeader2});
            this.listViewError.Font = new System.Drawing.Font("Microsoft Sans Serif", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.listViewError.GridLines = true;
            this.listViewError.HeaderStyle = System.Windows.Forms.ColumnHeaderStyle.None;
            this.listViewError.Location = new System.Drawing.Point(11, 496);
            this.listViewError.Name = "listViewError";
            this.listViewError.Size = new System.Drawing.Size(1229, 75);
            this.listViewError.Sorting = System.Windows.Forms.SortOrder.Ascending;
            this.listViewError.TabIndex = 51;
            this.listViewError.UseCompatibleStateImageBehavior = false;
            this.listViewError.View = System.Windows.Forms.View.Details;
            this.listViewError.ItemSelectionChanged += new System.Windows.Forms.ListViewItemSelectionChangedEventHandler(this.listViewError_ItemSelectionChanged);
            // 
            // columnHeader1
            // 
            this.columnHeader1.Width = 0;
            // 
            // columnHeader2
            // 
            this.columnHeader2.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.columnHeader2.Width = 1229;
            // 
            // btnWheelchair
            // 
            this.btnWheelchair.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnWheelchair.Font = new System.Drawing.Font("Microsoft Sans Serif", 39.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnWheelchair.Image = global::NKKWeightScaleApp.Properties.Resources.wheelchair;
            this.btnWheelchair.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnWheelchair.Location = new System.Drawing.Point(863, 10);
            this.btnWheelchair.Name = "btnWheelchair";
            this.btnWheelchair.Size = new System.Drawing.Size(377, 83);
            this.btnWheelchair.TabIndex = 4;
            this.btnWheelchair.Text = "車いす";
            this.btnWheelchair.UseVisualStyleBackColor = true;
            this.btnWheelchair.Click += new System.EventHandler(this.btnWheelchair_Click);
            // 
            // btnWeight
            // 
            this.btnWeight.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnWeight.Font = new System.Drawing.Font("Microsoft Sans Serif", 39.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnWeight.Image = global::NKKWeightScaleApp.Properties.Resources.bodyweight;
            this.btnWeight.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnWeight.Location = new System.Drawing.Point(11, 10);
            this.btnWeight.Name = "btnWeight";
            this.btnWeight.Size = new System.Drawing.Size(377, 83);
            this.btnWeight.TabIndex = 2;
            this.btnWeight.Text = "体重";
            this.btnWeight.UseVisualStyleBackColor = true;
            this.btnWeight.Click += new System.EventHandler(this.btnWeight_Click);
            // 
            // FrmWeightMeasurementScreen
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1253, 655);
            this.Controls.Add(this.listViewError);
            this.Controls.Add(this.lblPatientSame);
            this.Controls.Add(this.ckbPrint);
            this.Controls.Add(this.lblUnit1);
            this.Controls.Add(this.lblUnit0);
            this.Controls.Add(this.btnSelectBed);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnSend);
            this.Controls.Add(this.btnTreatmentConditions);
            this.Controls.Add(this.btnWaterRemovalRestriction);
            this.Controls.Add(this.btnPacking);
            this.Controls.Add(this.btnSelectWheelchair);
            this.Controls.Add(this.btnDetail);
            this.Controls.Add(this.btnWheelchair);
            this.Controls.Add(this.btnWeightAndWheelchair);
            this.Controls.Add(this.btnWeight);
            this.Controls.Add(this.txtWeightValue);
            this.Controls.Add(this.txtMeasuredValue);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.lblPatientID);
            this.Controls.Add(this.lblPatientName);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.lblDialysisTime);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.lblWaterRemovalCompensationValue);
            this.Controls.Add(this.lblPackingValue);
            this.Controls.Add(this.lblWheelchairValue);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "FrmWeightMeasurementScreen";
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Show;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "体重測定（簡易）画面";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmWeightMeasurementScreen_FormClosed);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnWeight;
        private System.Windows.Forms.Label lblPatientID;
        private System.Windows.Forms.Button btnDetail;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button btnTreatmentConditions;
        private System.Windows.Forms.Button btnWeightAndWheelchair;
        private System.Windows.Forms.Button btnWheelchair;
        private System.Windows.Forms.Button btnSelectWheelchair;
        private System.Windows.Forms.Label lblWheelchairValue;
        private System.Windows.Forms.Button btnPacking;
        private System.Windows.Forms.Button btnWaterRemovalRestriction;
        private System.Windows.Forms.Label lblPackingValue;
        private System.Windows.Forms.Label lblWaterRemovalCompensationValue;
        private System.Windows.Forms.Button btnSend;
        private System.Windows.Forms.TextBox txtMeasuredValue;
        private System.Windows.Forms.TextBox txtWeightValue;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label lblPatientName;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label lblDialysisTime;
        private System.Windows.Forms.Button btnSelectBed;
        private System.Windows.Forms.Label lblUnit0;
        private System.Windows.Forms.Label lblUnit1;
        private System.Windows.Forms.CheckBox ckbPrint;
        private System.Windows.Forms.Label lblPatientSame;
        private System.Windows.Forms.ListView listViewError;
        private System.Windows.Forms.ColumnHeader columnHeader1;
        private System.Windows.Forms.ColumnHeader columnHeader2;
    }
}