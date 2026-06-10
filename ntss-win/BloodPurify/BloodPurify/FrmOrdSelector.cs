using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using System.Threading.Tasks;
using NKK.BloodPurify.Properties;
using LayoutDesignerUtilityLib;
using NKKWebAccessLib;
using System.Reflection;

namespace NKK.BloodPurify
{
    public partial class FrmOrdSelector : FrmDarkBase
    {
        private string UploadFilePath;
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
        //public (long ordNo, string kurName, string bedName, string patName) Selected = (-1, "", "", "");
        public (long ordNo, string kurName, string bedName, string patName,string hospPatID,string rstTreatmentName) Selected = (-1, "", "", "","","");
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
        public enum DgvDataKind
        {
            DetectByUploadFile = 0,
            BloodPurify,
            NkkOffline
        }
        private DgvDataKind MyDgvDataKind;

        public enum InOut : int
        {
            Out = 0,
            In,
            Die,
            Other
        }
        private string InOutToString(int argVal)
        {
            switch (argVal)
            {
                case (int)InOut.Out: return "外来";
                case (int)InOut.In: return "入院";
                case (int)InOut.Die: return "死亡";
                case (int)InOut.Other: return "その他";
            }

            return $"不明({argVal})";
        }

        public enum DialysisState : int
        {
            BeforeSend = 0,
            AfterSend,
            ConfirmSend,
            Dialyzing,
            Drained,
            MeasuredAfterWeight,
            Fixed
        }
        private string DialysisStateToString(int argVal)
        {
            switch (argVal)
            {
                case (int)DialysisState.BeforeSend: return "条件送信前";
                case (int)DialysisState.AfterSend: return "条件送信済";
                case (int)DialysisState.ConfirmSend: return "条件送信確認済";
                case (int)DialysisState.Dialyzing: return "治療中";
                case (int)DialysisState.Drained: return "排液済";
                case (int)DialysisState.MeasuredAfterWeight: return "後体重測定済"; // DB定義は「後体重測定済(実績未確定)」
                case (int)DialysisState.Fixed: return "過去実績"; // DB定義は「後体重測定済(過去実績)」
            }

            return $"不明({argVal})";
        }

        public FrmOrdSelector(string argUploadFilePath, DgvDataKind argDgvDataKind)
        {
            InitializeComponent();

            UploadFilePath = argUploadFilePath;

            if (argDgvDataKind != DgvDataKind.DetectByUploadFile)
            {
                MyDgvDataKind = argDgvDataKind;
            }
            else
            {
                MyDgvDataKind = AppCmn.IsFileBloodPurify(argUploadFilePath) ? DgvDataKind.BloodPurify : DgvDataKind.NkkOffline;
            }
        }

        private void FrmOrdSelector_Load(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[mode:{MyDgvDataKind}]");

            try
            {
                // <> FrmDarkBaseを継承しているもので共通の処理
                SetTitle("予定選択");
                // 全部に「Yu Gothic UI」を適用 → 最小/最大/閉じるボタンに「Segoe MDL2 Assets」を適用
                foreach (Control ctrl in AppCmn.GetAllControls(this))
                {
                    float size = ctrl.Font.Size;
                    ctrl.Font = new Font(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.YU), size);
                }
                SetVisibleBtnMinMaxClose(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.SEGMDL2));
                // </>

                BtnMonthCalendar.Text = DateTime.Now.ToString("yyyy年 MM月 dd日 (ddd)");
                RestDataToDataGridView();

                if (false == string.IsNullOrWhiteSpace(UploadFilePath))
                {
                    ToolTip tt = new ToolTip();
                    tt.SetToolTip(BtnOk, $"{Path.GetFileName(UploadFilePath)}");
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void FrmOrdSelector_FormClosed(object sender, FormClosedEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);
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

        private void BtnMonthCalendar_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                FrmDateSelector frmMC = new FrmDateSelector(GetYyyymmdd(BtnMonthCalendar.Text));

                if (DialogResult.OK == frmMC.ShowDialog())
                {
                    BtnMonthCalendar.Text = frmMC.MonthCalendar.SelectionStart.ToString("yyyy年 MM月 dd日 (ddd)");
                    MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[選択日付:{BtnMonthCalendar.Text}]");
                    RestDataToDataGridView();
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void BtnKur_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                FrmKurSelector frmKS = new FrmKurSelector(BtnKur.Text);

                if (DialogResult.OK == frmKS.ShowDialog())
                {
                    var selected = frmKS.Selected;
                    BtnKur.Text = selected.kurName;
                    BtnKur.Tag = selected.kurStartHhmmss;
                    RestDataToDataGridView();
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void BtnOk_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                if (1 <= DataGridView.Rows.Count)
                {
                    int selectedRowIdx = DataGridView.CurrentCell.RowIndex;

                    // ファイル名無しでの本画面呼出はオンラインモードで通信を始める際のOrdNo選択のための呼出
                    if (string.IsNullOrWhiteSpace(UploadFilePath))
                    {
                        Selected.ordNo = (long)DataGridView["OrdNo", selectedRowIdx].Value;
                        Selected.kurName = (string)DataGridView["KurName", selectedRowIdx].Value;
                        Selected.bedName = (string)DataGridView["BedName", selectedRowIdx].Value;
                        Selected.patName = (string)DataGridView["PatName", selectedRowIdx].Value;
                        // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
                        if (DataGridView.Rows[selectedRowIdx].Tag != null)
                        {
                            MyJson.BloodPurifyOrdInfo ordInfo = DataGridView.Rows[selectedRowIdx].Tag as MyJson.BloodPurifyOrdInfo;
                            if (ordInfo != null)
                            {
                                Selected.hospPatID = ordInfo.hospPatID;
                                Selected.rstTreatmentName = ordInfo.RstTreatmentName;
                            }
                        }
                        // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
                        DialogResult = DialogResult.OK;
                        Close();
                    }
                    // ファイル名ありでの本画面呼出はファイルアップロード先となるOrdNo選択のための呼出
                    else
                    {
                        long ordNo = (long)DataGridView["OrdNo", selectedRowIdx].Value;
                        var restRes = Task.Run(async () => await MyRest.PostBptxtFile(ordNo, UploadFilePath)).Result;
                        if (restRes.isSuccess)
                        {
                            string ordNoDirPath = $"{MyConfig.DataDir}\\{ordNo:0000000000000000000}";
                            Directory.CreateDirectory(ordNoDirPath);

                            string dstPath = AppCmn.GetDistinctFilePath($"{ordNoDirPath}\\{Path.GetFileName(UploadFilePath)}", 2);
                            AppCmn.MoveWithMutex(UploadFilePath, dstPath);

                            DialogResult = DialogResult.OK;
                            Close();
                        }
                        else
                        {
                            MessageBox.Show($"治療データの登録に失敗しました。\r\n\r\n[{restRes.errorReasonPhrase}]", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }

            Close();
        }

        private void BtnCancel_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                Close();
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "患者検索画面 キャンセルボタン押下", ex);
            }
        }

        private void RestDataToDataGridView()
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                DataGridView.Rows.Clear();

                // <> RESTでDBデータ読み出し
                List<MyJson.BloodPurifyOrdInfo> listDbData = null;

                if (DgvDataKind.BloodPurify == MyDgvDataKind)
                {
                    var restRes = Task.Run(async () => await MyRest.GetBloodPurifyOrdInfoForBloodPurifyDevice(GetYyyymmdd(BtnMonthCalendar.Text))).Result;
                    if (false == restRes.isSuccess)
                    {
                        MessageBox.Show($"治療予定データの取得に失敗しました。\r\n\r\n[{restRes.errorReasonPhrase}]", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }

                    listDbData = MyJson.Conv<List<MyJson.BloodPurifyOrdInfo>>.Deserialize(restRes.getData);
                }
                else if (DgvDataKind.NkkOffline == MyDgvDataKind)
                {
                    var restRes = Task.Run(async () => await MyRest.GetBloodPurifyOrdInfoForNkkDevice(GetYyyymmdd(BtnMonthCalendar.Text))).Result;
                    if (false == restRes.isSuccess)
                    {
                        MessageBox.Show($"治療予定データの取得に失敗しました。\r\n\r\n[{restRes.errorReasonPhrase}]", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }

                    listDbData = MyJson.Conv<List<MyJson.BloodPurifyOrdInfo>>.Deserialize(restRes.getData);
                }

                // クール開始時刻を見て取得クール抽出を実施(※REST側の空引数禁止によりREST側でなくRESTの呼び側で実施)
                if ("999999" != BtnKur.Tag.ToString())
                {
                    int intSelKurStartTime = int.Parse(BtnKur.Tag.ToString());

                    for (int i = listDbData.Count - 1; i >= 0; i--)
                    {
                        // クール開始時刻が範囲外
                        if (false == (int.Parse(listDbData[i].KurStartTime) <= intSelKurStartTime && intSelKurStartTime <= int.Parse(listDbData[i].KurEndTime)))
                        {
                            listDbData.RemoveAt(i);
                        }
                    }
                }
                // </>

                // <> DGVにセット
                int pos = 0;
                foreach (MyJson.BloodPurifyOrdInfo one in listDbData)
                {
                    DataGridView.Rows.Add();

                    DataGridView["KurName", pos].Value = one.ParseNull(one.KurName);
                    DataGridView["BedName", pos].Value = one.ParseNull(one.BedName);

                    DataGridView["SameName", pos].Style.Alignment = DataGridViewContentAlignment.MiddleCenter;
                    if (one.IsSame)
                    {
                        DataGridView["SameName", pos].Value = Resources.nameDuplication;

                        // 該当行の選択色も強調色に変更
                        for (int i = 0; i < DataGridView.Columns.Count; i++)
                        {
                            DataGridView[i, pos].Style.SelectionBackColor = Color.FromArgb(150, 90, 150);
                        }
                    }
                    else
                    {
                        DataGridView["SameName", pos].Value = new Bitmap(1, 1); // ダミービットマップ
                    }

                    DataGridView["PatName", pos].Value = one.ParseNull(one.PatName);
                    DataGridView["TreatState", pos].Value = DialysisStateToString(int.Parse(one.DialysisState));
                    DataGridView["InOutClass", pos].Value = InOutToString(one.InOutClass);
                    DataGridView["OrdNo", pos].Value = one.OrdNo;
                    // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
                    DataGridView.Rows[pos].Tag = one;
                    // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end

                    pos++;
                }
                // </>

                //LogWriter.WriteLog(LogLevel.Debug, "0316000003", "取得した患者一覧表示完了");
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "患者一覧表示データ読込処理例外", ex);
            }
        }

        /// <summary>
        /// 「YYYY年 MM月 DD日 (日)」の文字列から「YYYYMMDD」を取得
        /// </summary>
        /// <param name="argText">「YYYY年 MM月 DD日 (日)」の文字列</param>
        /// <returns>YYYYMDDの文字列</returns>
        private string GetYyyymmdd(string argReadableYyyymmdd)
        {
            return argReadableYyyymmdd.Replace("年 ", "").Replace("月 ", "").Replace("日 ", "").Substring(0, 8);
        }
    }
}