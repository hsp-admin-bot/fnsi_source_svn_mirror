using System;
using System.Collections.Generic;
using System.Drawing;
using System.Reflection;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;

namespace NKK.BloodPurify
{
    public partial class FrmKurSelector : FrmDarkBase
    {
        public (string kurName, string kurStartHhmmss) Selected;

        public FrmKurSelector(string argInitSelectedKurName)
        {
            InitializeComponent();

            Selected.kurName = argInitSelectedKurName;
        }

        private void FrmKurSelector_Load(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            // <> FrmDarkBaseを継承しているもので共通の処理
            SetTitle("クール選択");
            // 全部に「Yu Gothic UI」を適用 → 最小/最大/閉じるボタンに「Segoe MDL2 Assets」を適用
            foreach (Control ctrl in AppCmn.GetAllControls(this))
            {
                float size = ctrl.Font.Size;
                ctrl.Font = new Font(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.YU), size);
            }
            SetVisibleBtnMinMaxClose(null);
            // </>

            try
            {
                // アプリ起動後のDB初回接続時に同期される「クール情報jsonファイル」を読み出し
                List<MyJson.KurInfo> listKur = MyJson.Conv<List<MyJson.KurInfo>>.DeserializeFromFile(AppCmn.GetExeDir(true) + "kur.json");

                // 1行目は[指定なし]
                int rowIdx = 0;
                DataGridView.Rows.Add();
                DataGridView["KurName", rowIdx].Value = "指定なし";
                DataGridView["KurStartTime", rowIdx].Value = "999999";
                DataGridView["KurEndTime", rowIdx].Value = "999999";

                // 2行目からクール情報をセット
                rowIdx++;
                foreach (MyJson.KurInfo one in listKur)
                {
                    DataGridView.Rows.Add();
                    DataGridView["KurName", rowIdx].Value = one.ParseNull(one.KurName);
                    DataGridView["KurStartTime", rowIdx].Value = one.ParseNull(one.KurStartTime);
                    DataGridView["KurEndTime", rowIdx].Value = one.ParseNull(one.KurEndTime);

                    // 選択中のクール名が一致する行を選択状態＋フォーカスを当てる
                    if (DataGridView["KurName", rowIdx].Value.ToString().Equals(Selected.kurName))
                    {
                        DataGridView.Rows[rowIdx].Selected = true;
                        DataGridView.CurrentCell = DataGridView.Rows[rowIdx].Cells[0];

                        Selected.kurStartHhmmss = DataGridView["KurStartTime", rowIdx].Value.ToString();
                    }

                    rowIdx++;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "クール一覧表示データ読込処理例外", ex);
            }
        }

        private void FrmKurSelector_FormClosed(object sender, FormClosedEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);
        }

        private void BtnOk_Click(object sender, EventArgs e)
        {
            int selRowIdx = DataGridView.CurrentCell.RowIndex;
            Selected.kurName = DataGridView["KurName", selRowIdx].Value.ToString();
            Selected.kurStartHhmmss = DataGridView["KurStartTime", selRowIdx].Value.ToString();

            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[選択クール:{Selected.kurName}]");

            DialogResult = DialogResult.OK;
            Close();
        }

        private void BtnCancel_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            Close();
        }

        private void DataGridView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダー以外
            if (0 <= e.RowIndex)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

                BtnOk_Click(sender, e);
            }
        }

        private void DataGridView_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Enter]");

                BtnOk_Click(sender, e);
                e.Handled = true; // Enterによるセルカーソル移動をさせない
            }
            else if (e.KeyCode == Keys.Escape)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Esc]");

                Close();
            }
        }
    }
}