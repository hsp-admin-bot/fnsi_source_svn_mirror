using NKKWeightScaleApp.Models;
using NKKWeightScaleApp.Services;
using System;
using System.Drawing;
using System.Windows.Forms;
using static NKKWeightScaleApp.Commons.Delegates;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmModalBed : Form
    {
        public SendMessage<Bed> send;

        public FrmModalBed(SendMessage<Bed> sender)
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            LoadData();
            send = sender;
        }

        private void LoadData()
        {
            BedController bedService = new BedController();
            dgvBed.DataSource = bedService.GetAll();
        }

        private void dgvBed_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            if (e.ColumnIndex == dgvBed.Columns[0].Index && e.RowIndex >= 0)
            {
                SolidBrush sb = new SolidBrush(Color.Red);
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
            if (dgvBed.CurrentCell.ColumnIndex == dgvBed.Columns[0].Index)
            {
                foreach (DataGridViewRow row in dgvBed.Rows)
                {
                    if (row.Index != dgvBed.CurrentCell.RowIndex)
                    {
                        row.Cells[dgvBed.Columns[0].Index].Value = false;
                    }
                }
            }
        }

        private void dgvBed_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            radioButtonChanged();
        }

        private void dgvBed_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0)
                return;
            if (e.ColumnIndex == dgvBed.Columns[0].Index)
            {
                DataGridViewCheckBoxCell cellSelected = (DataGridViewCheckBoxCell)dgvBed.Rows[e.RowIndex].Cells[dgvBed.Columns[0].Index];
                cellSelected.Value = true;
                radioButtonChanged();
            }
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (dgvBed.Rows.Count != 0)
            {
                Bed bed = new Bed();
                bool isSelected = false;
                foreach (DataGridViewRow row in dgvBed.Rows)
                {
                    isSelected = Convert.ToBoolean(row.Cells[0].Value);
                    if (isSelected == true)
                    {
                        bed.Selected = Convert.ToBoolean(row.Cells[0].Value.ToString());
                        if (!string.IsNullOrEmpty(row.Cells[1].Value.ToString()))
                            bed.BedName = row.Cells[1].Value.ToString();
                        else
                            bed.BedName = string.Empty;
                        if (!string.IsNullOrEmpty(row.Cells[2].Value.ToString()))
                            bed.ConnectedDevice = row.Cells[2].Value.ToString();
                        else
                            bed.ConnectedDevice = string.Empty;
                        if (!string.IsNullOrEmpty(row.Cells[3].Value.ToString()))
                            bed.BedID = row.Cells[3].Value.ToString();
                        else
                            bed.BedID = string.Empty;
                        break;
                    }
                }
                if (isSelected == false)
                {
                    return;
                }
                send(bed);
                Close();
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void FrmModalBed_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }
    }
}