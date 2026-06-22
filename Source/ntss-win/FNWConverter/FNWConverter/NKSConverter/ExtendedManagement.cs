using ConvertCommon;
using ConvertCommon.Common;
using ConvertCommon.dto;
using ConvertCommon.parts;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Windows.Forms;
namespace NKSConverter
{
    public partial class  ExtendedManagement : Form
    {
        private DataGridView dataGridView1;
        private DataGridViewTextBoxColumn No;
        private DataGridViewTextBoxColumn facilityCd;
        private DataGridViewTextBoxColumn facilityName;
        private DataGridViewTextBoxColumn isSchextException;
        private DataGridViewButtonColumn ChangeBtn;


        ConvertForm cf;

        private void InitializeComponent()
        {
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ExtendedManagement));
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.No = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.facilityCd = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.facilityName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.isSchextException = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ChangeBtn = new System.Windows.Forms.DataGridViewButtonColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.No,
            this.facilityCd,
            this.facilityName,
            this.isSchextException,
            this.ChangeBtn});
            this.dataGridView1.Location = new System.Drawing.Point(43, 29);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.RowTemplate.Height = 21;
            this.dataGridView1.Size = new System.Drawing.Size(804, 429);
            this.dataGridView1.TabIndex = 0;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // No
            // 
            this.No.DataPropertyName = "no";
            this.No.HeaderText = "No";
            this.No.Name = "No";
            // 
            // facilityCd
            // 
            this.facilityCd.DataPropertyName = "facilityCd";
            this.facilityCd.HeaderText = "施設コード";
            this.facilityCd.Name = "facilityCd";
            this.facilityCd.Width = 150;
            // 
            // facilityName
            // 
            this.facilityName.DataPropertyName = "facilityName";
            this.facilityName.HeaderText = "施設名";
            this.facilityName.Name = "facilityName";
            this.facilityName.Width = 350;
            // 
            // isSchextException
            // 
            this.isSchextException.DataPropertyName = "isSchextException";
            this.isSchextException.HeaderText = "処理状態";
            this.isSchextException.Name = "isSchextException";
            // 
            // ChangeBtn
            // 
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.NullValue = "变更";
            this.ChangeBtn.DefaultCellStyle = dataGridViewCellStyle1;
            this.ChangeBtn.HeaderText = "操作";
            this.ChangeBtn.Name = "ChangeBtn";
            this.ChangeBtn.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.ChangeBtn.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
            // 
            // ExtendedManagement
            // 
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.ClientSize = new System.Drawing.Size(893, 488);
            this.Controls.Add(this.dataGridView1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "ExtendedManagement";
            this.Text = "コンバータによるスケジュール延長管理";
            this.Load += new System.EventHandler(this.ExtendedManagement_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);

        }
        public ExtendedManagement(ConvertForm cf) {
            this.cf = cf;
            InitializeComponent();
            dataGridView1.CellFormatting += new DataGridViewCellFormattingEventHandler(dataGridView1_CellFormatting);
        }


        private void ExtendedManagement_Load(object sender, EventArgs e)
        {
            List<MstFacilityDto> dataList = getMstFacility();
            dataGridView1.DataSource = dataList;
        }

        private List<MstFacilityDto> getMstFacility() {

            string url = getUrl("select");
            string valueString = Newtonsoft.Json.JsonConvert.SerializeObject(CommonConfig.HashValueSet.Values);
            Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", valueString } };
            string body = HttpControl.sendWebRequestPost(url, parameters);
            if (!string.IsNullOrEmpty(body))
            {
                return JsonConvert.DeserializeObject<List<MstFacilityDto>>(body);
            }
            else {
                List<MstFacilityDto> mf = new List<MstFacilityDto>();
                return mf;
            }
           
        }

        private string getUrl(string type) {

            string url =string.Empty;
            switch (type)
            {
                case "select":
                    url = NKSConverter.Properties.Settings.Default.ConvertgetMstFacilityUrlFormat;
                    break;
                case "update":
                    url = NKSConverter.Properties.Settings.Default.ConvertUpdateMstFacilityUrlFormat;
                    break;
            }
            return url;
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.Columns[e.ColumnIndex].Name == "ChangeBtn" && e.RowIndex >= 0)
            {
                
                MstFacilityDto facilityDto = dataGridView1.Rows[e.RowIndex].DataBoundItem as MstFacilityDto;
                if (facilityDto != null)
                {
                    string flag = facilityDto.isSchextException;
                    string Message = string.Empty;
                    string Change = string.Empty;
                    if (flag.Equals("1"))
                    {
                        Message = "「実行→停止」";
                    }
                    else {
                        Message = "「停止→実行」";
                    }
                    string sMessage = @"対象施設：" + facilityDto.facilityName + "（" + facilityDto.facilityCd + ")" + System.Environment.NewLine + "コンバータによるスケジュール延長状態を" + Message + "に変更する" + System.Environment.NewLine + "よろしいでしょうか？";
                    if (MessageBox.Show(sMessage, "", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                    {
                        Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", "[\""+CommonConfig.HashValueSet[facilityDto.facilityCd].ToString()+"\"]" }, { "flag", flag } };
                        string url = getUrl("update");
                        string response = HttpControl.sendWebRequestPost(url, parameters);
                        Change = "はい";
                        if (response != null)
                        {
                            if (response.Equals("ok"))
                            {
                                List<MstFacilityDto> dataList = getMstFacility();
                                dataGridView1.DataSource = dataList;
                                cf.SetSeriesCdAndFacilityCdToDataTable();
                            }
                            else
                            {
                                MessageBox.Show(this, Message, "延長状態操作失败", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            }
                        }
                        else
                        {
                            MessageBox.Show(this, Message, "延長状態操作失败", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        }
                    }
                    else {
                        Change = "いいえ";
                    }
                    ConvertBase.WriteTraceLog("コンバータによるスケジュール延長管理操作：{0}", Message+ "選択: " + Change);
                }
            }
        }

        private void dataGridView1_CellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
        {
            if (dataGridView1.Columns[e.ColumnIndex].Name == "isSchextException" && e.RowIndex >= 0) 
            {
                int value = (e.Value != null) ? Convert.ToInt32(e.Value) : 0;
      
                switch (value)
                {
                    case 1:
                        e.Value = "実行";
                        e.FormattingApplied = true; 
                        break;
                    case 0:
                        e.Value = "停止";
                        e.FormattingApplied = true; 
                        break;
                }
            }
        }
       
    }
}
