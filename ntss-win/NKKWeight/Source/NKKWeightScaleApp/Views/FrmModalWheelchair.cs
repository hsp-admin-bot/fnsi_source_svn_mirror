using NKKWeightScaleApp.Controller;
using NKKWeightScaleApp.Models;
using System;
using System.Drawing;
using System.Windows.Forms;
using static NKKWeightScaleApp.Commons.Delegates;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmModalWheelchair : Form
    {
        public SendMessage<Wheelchair> send;

        public FrmModalWheelchair(SendMessage<Wheelchair> sender)
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
            WheelchairController wheelchairController = new WheelchairController();
            dgvWheelchair.DataSource = wheelchairController.GetAll();
        }

        private void dgvWheelchair_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            if (e.ColumnIndex == dgvWheelchair.Columns[0].Index && e.RowIndex >= 0)
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
            if (dgvWheelchair.CurrentCell.ColumnIndex == dgvWheelchair.Columns[0].Index)
            {
                foreach (DataGridViewRow row in dgvWheelchair.Rows)
                {
                    if (row.Index != dgvWheelchair.CurrentCell.RowIndex)
                    {
                        row.Cells[dgvWheelchair.Columns[0].Index].Value = false;
                    }
                }
            }
        }

        private void dgvWheelchair_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            radioButtonChanged();
        }

        private void dgvWheelchair_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0)
                return;
            if (e.ColumnIndex == dgvWheelchair.Columns[0].Index)
            {
                DataGridViewCheckBoxCell cellSelected = (DataGridViewCheckBoxCell)dgvWheelchair.Rows[e.RowIndex].Cells[dgvWheelchair.Columns[0].Index];
                cellSelected.Value = true;
                radioButtonChanged();
            }
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (dgvWheelchair.Rows.Count != 0)
            {
                Wheelchair wheelchair = new Wheelchair();
                bool isSelected = false;
                foreach (DataGridViewRow row in dgvWheelchair.Rows)
                {
                    isSelected = Convert.ToBoolean(row.Cells[0].Value);
                    if (isSelected == true)
                    {
                        wheelchair.Selected = Convert.ToBoolean(row.Cells["Selected"].Value.ToString());
                        if (!string.IsNullOrEmpty(row.Cells["WheelchairName"].Value.ToString()))
                            wheelchair.WheelchairName = row.Cells["WheelchairName"].Value.ToString();
                        else
                            wheelchair.WheelchairName = string.Empty;
                        if (!string.IsNullOrEmpty(row.Cells["Weight"].Value.ToString()))
                            wheelchair.Weight = row.Cells["Weight"].Value.ToString();
                        else
                            wheelchair.Weight = string.Empty;
                        if (!string.IsNullOrEmpty(row.Cells["OwnerPatient"].Value.ToString()))
                            wheelchair.OwnerPatient = row.Cells["OwnerPatient"].Value.ToString();
                        else
                            wheelchair.OwnerPatient = string.Empty;
                        if (!string.IsNullOrEmpty(row.Cells["WheelchairID"].Value.ToString()))
                            wheelchair.WheelchairID = row.Cells["WheelchairID"].Value.ToString();
                        else
                            wheelchair.WheelchairID = string.Empty;
                        break;
                    }
                }
                if (isSelected == false)
                {
                    return;
                }
                send(wheelchair);
                Close();
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void FrmModalWheelchair_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }
    }
}