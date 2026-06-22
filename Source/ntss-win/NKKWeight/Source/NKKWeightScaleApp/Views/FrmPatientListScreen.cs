using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Controller;
using NKKWeightScaleApp.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmPatientListScreen : Form
    {
        public FrmPatientListScreen()
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            LoadData();
        }

        private void LoadData()
        {
            PatientController patientService = new PatientController();
            List<PatientEx> patientList = patientService.GetAll();
            dgvPatientList.DataSource = patientList;
        }

        protected override void OnLoad(EventArgs e)
        {
            btnClear.Size = new Size(25, txtSearch.ClientSize.Height + 2);
            btnClear.Location = new Point(txtSearch.ClientSize.Width - btnClear.Width, -1);
            txtSearch.Controls.Add(btnClear);
            SendMessage(txtSearch.Handle, 0xd3, (IntPtr)2, (IntPtr)(btnClear.Width << 16));
            base.OnLoad(e);
        }

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        private static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wp, IntPtr lp);

        private void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            ConvertTool ConvertTool = new ConvertTool();
            PatientController patientService = new PatientController();
            List<PatientEx> patientList = patientService.GetAll();
            DataTable dataTable = ConvertTool.ConvertListToDataTable(patientList);
            var rows = dataTable.Select(string.Format("PatientID LIKE '%{0}%' Or PatientName LIKE '%{0}%'", txtSearch.Text));
            if (rows.Count() > 0)
            {
                dgvPatientList.DataSource = rows.CopyToDataTable();
                dgvPatientList.Refresh();
            }
            else
            {
                dataTable = dataTable.Clone();
                dgvPatientList.DataSource = dataTable;
            }
        }

        private void dgvPatientList_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            if (e.ColumnIndex == dgvPatientList.Columns[0].Index && e.RowIndex >= 0)
            {
                e.PaintBackground(e.ClipBounds, true);
                Rectangle rectRadioButton = new Rectangle();
                rectRadioButton.Width = 40;
                rectRadioButton.Height = 40;
                rectRadioButton.X = e.CellBounds.X + (e.CellBounds.Width - rectRadioButton.Width) / 2;
                rectRadioButton.Y = e.CellBounds.Y + (e.CellBounds.Height - rectRadioButton.Height) / 2;
                ButtonState buttonState;
                if (e.Value == DBNull.Value || (bool)(e.Value) == false)
                {
                    buttonState = ButtonState.Normal;
                }
                else
                {
                    buttonState = ButtonState.Checked;
                }
                ControlPaint.DrawRadioButton(e.Graphics, rectRadioButton, buttonState);
                e.Paint(e.ClipBounds, DataGridViewPaintParts.Focus);
                e.Handled = true;
            }
        }

        private void radioButtonChanged()
        {
            if (dgvPatientList.CurrentCell.ColumnIndex == dgvPatientList.Columns[0].Index)
            {
                foreach (DataGridViewRow row in dgvPatientList.Rows)
                {
                    if (row.Index != dgvPatientList.CurrentCell.RowIndex)
                    {
                        row.Cells[dgvPatientList.Columns[0].Index].Value = false;
                    }
                }
            }
        }

        private void dgvPatientList_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            radioButtonChanged();
        }

        private void dgvPatientList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0)
                return;
            if (e.ColumnIndex == dgvPatientList.Columns[0].Index)
            {
                DataGridViewCheckBoxCell cellSelected = (DataGridViewCheckBoxCell)dgvPatientList.Rows[e.RowIndex].Cells[dgvPatientList.Columns[0].Index];
                cellSelected.Value = true;
                radioButtonChanged();
            }
        }

        private void btnGoWeightMeasurementScreen_Click(object sender, EventArgs e)
        {
            if (dgvPatientList.Rows.Count != 0)
            {
                PatientEx patient = new PatientEx();
                bool isSelected = false;
                foreach (DataGridViewRow row in dgvPatientList.Rows)
                {
                    isSelected = Convert.ToBoolean(row.Cells[0].Value);
                    if (isSelected == true)
                    {
                        patient.Selected = Convert.ToBoolean(row.Cells[0].Value.ToString());
                        if (!string.IsNullOrEmpty(row.Cells[1].Value.ToString()))
                            patient.PatientID = row.Cells[1].Value.ToString();
                        else
                            patient.PatientID = string.Empty;
                        if (!string.IsNullOrEmpty(row.Cells[2].Value.ToString()))
                            patient.PatientName = row.Cells[2].Value.ToString();
                        else
                            patient.PatientName = string.Empty;
                        break;
                    }
                }
                if (isSelected == false)
                {
                    return;
                }
                FrmWeightMeasurementScreen frmWeightMeasurementScreen = new FrmWeightMeasurementScreen(patient, string.Empty);
                Close();
                Hide();
                frmWeightMeasurementScreen.ShowDialog();
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void FrmPatientListScreen_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }
    }
}