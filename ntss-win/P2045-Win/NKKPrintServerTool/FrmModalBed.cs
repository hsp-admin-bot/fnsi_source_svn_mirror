using NKKPrintServerTool.Models;
using NKKWebAccessLib;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using TdcSocketLib;

namespace NKKPrintServerTool
{
    public partial class FrmModalBed : Form
    {
        public static List<PatientEx> patientList = new List<PatientEx>();
        private List<Boolean> patSelectList = new List<Boolean>();

        public FrmModalBed()
        {
            InitializeComponent();

            // add #12210 印刷サーバアプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKPrintServer;
            // add #12210 印刷サーバアプリ&ツール　アイコン差し替え 高 end

            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
            if (FormGUI.useType==2)
            {
                btnGoWeightMeasurementScreen.Text = "更　新";
            }
            else if(FormGUI.useType == 3)
            {
                btnGoWeightMeasurementScreen.Text = "削　除";
            }
            // add FNSI-4749 不要プリンターの削除機能対応 夏 end
            LoadData();
        }

        private void LoadData()
        {
            dgvPatientList.DataSource = patientList;
            foreach (PatientEx row in patientList)
            {
                patSelectList.Add(row.Selected);
            }
        }

        private void dgvPatientList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0)
                return;
            if (e.ColumnIndex == dgvPatientList.Columns[0].Index)
            {
                DataGridViewCheckBoxCell cellSelected = (DataGridViewCheckBoxCell)dgvPatientList.Rows[e.RowIndex].Cells[dgvPatientList.Columns[0].Index];
                if (cellSelected.Value.Equals(true))
                {
                    cellSelected.Value = false;

                }else
                {
                    cellSelected.Value = true;
                }
            }
        }

        private void btnGoWeightMeasurementScreen_Click(object sender, EventArgs e)
        {
            int i = 0;
            this.DialogResult = DialogResult.Cancel;
            foreach (PatientEx row in patientList)
            {
                if (patSelectList[i] != row.Selected)
                {
                    this.DialogResult = DialogResult.OK;
                    break;
                }
                i++;
            }
            if (this.DialogResult == DialogResult.Cancel)
            {
                if (MessageBox.Show("選択チェックボックスは変化されないです。\n\r退出してもよろしいですか？", 
                    "退出確認", 
                    MessageBoxButtons.YesNo, 
                    MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    this.Close();
                }
                else
                {
                    this.DialogResult = DialogResult.None;
                }

            }           
            
        }

        private void FrmModalBed_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }
    }
}