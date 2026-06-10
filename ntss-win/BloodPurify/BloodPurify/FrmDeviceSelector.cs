using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;
using NKKCommon;
using NKKWebAccessLib;

namespace NKK.BloodPurify
{
    /// <summary>
    /// 装置選択画面
    /// </summary>
    public partial class FrmDeviceSelector : FrmDarkBase
    {
        public FrmDeviceSelector()
        {
            InitializeComponent();
            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);
        }

        /// <summary>
        /// 接続のメッセージを処理する
        /// </summary>
        /// <param name="serverName"></param>
        /// <param name="strStatus"></param>
        /// <param name="dtOccurDate"></param>
        /// <param name="strMessage"></param>
        private void HandleAccessMessage(String serverName, String strStatus, DateTime dtOccurDate, String strMessage)
        {
            switch(strStatus)
            {
                case "Disconnected":
                    {
                        if(LblOnOff.Text == "オンラインモード")
                        {
                            this.SwitchMode();
                        }
                        break;
                    }
                case "Connected":
                    {
                        //if (LblOnOff.Text == "オフラインモード")
                        //{
                        //    this.SwitchMode();
                        //}
                        break;
                    }
                default:
                    {
                        break;
                    }
            }
        }

        /// <summary>
        /// SwitchModeCallback
        /// </summary>
        private delegate void SwitchModeCallback();

        /// <summary>
        /// オンライン・オフラインを変更する
        /// </summary>
        private void SwitchMode()
        {
            if (this.InvokeRequired)
            {
                SwitchModeCallback calback = new SwitchModeCallback(SwitchMode);
                this.Invoke(calback);
            }
            else
            {
                if (AppCmn.IsModeOnline)
                {
                    LblOnOff.Text = "オンラインモード";
                    LblOnOff.BackColor = Color.FromArgb(0, 176, 80);
                    BtnUpload.Visible = true;

                    ToolTip tt = new ToolTip();
                    tt.SetToolTip(LblOnOff, $"ユーザーID「{NKKWebAccess.UserId}」");

                }
                else
                {
                    LblOnOff.Text = "オフラインモード";
                    LblOnOff.BackColor = Color.FromArgb(255, 102, 204);
                    BtnUpload.Visible = false;
                }
            }
        }

        private void FrmDeviceSelector_Load(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            // <> FrmDarkBaseを継承しているもので共通の処理
            SetTitle("装置選択");
            // 全部に「Yu Gothic UI」を適用 → 最小/最大/閉じるボタンに「Segoe MDL2 Assets」を適用
            foreach (Control ctrl in AppCmn.GetAllControls(this))
            {
                float size = ctrl.Font.Size;
                ctrl.Font = new Font(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.YU), size);
            }
            SetVisibleBtnMinMaxClose(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.SEGMDL2));
            // </>

            // <> device.csvを読みだしてDGVにセット
            string path = AppCmn.GetExeDir(true) + "device.csv";

            // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 start
            // 接続確認
            if (NKKWebAccess.Login)
            {
                // 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する
                var restRes = System.Threading.Tasks.Task.Run(async () => await MyRest.GetDialysisDevice()).Result;
                if (restRes.isSuccess)
                {
                    List<MyJson.DialysisDeviceInfo> deviceList = MyJson.Conv<List<MyJson.DialysisDeviceInfo>>.Deserialize(restRes.getData);
                    try
                    {
                        List<string> list = new List<string>();
                        foreach (MyJson.DialysisDeviceInfo item in deviceList)
                        {
                            list.Add(item.BloodPurifyType + "," + item.MachineName + "," + item.IPAddress + "," + item.Port);
                        }

                        if (list.Count > 0)
                        {
                            File.WriteAllLines(path, list.ToArray(), System.Text.Encoding.UTF8);
                        }
                    }
                    catch (Exception ex)
                    {
                        MyLog.AddLogInfo(this, "FrmDeviceSelector.FrmDeviceSelector_Load", ex);
                    }
                }
            }
            // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 end

            if (File.Exists(path))
            {
                string[] allLines = File.ReadAllLines(path);
                foreach (string oneLine in allLines)
                {
                    string[] colValues = { "", "", "(待ち受け式のためIPアドレス設定は未使用)", "" };

                    string[] splits = oneLine.Split(',');
                    for (int i = 0; i < splits.Length; i++)
                    {
                        if (0 == i)
                        {
                            // 機種番号を機種名に変換
                            switch (splits[i])
                            {
                                case "1": colValues[i] = "ACH-Σ"; break;
                                case "2": colValues[i] = "KM-8900"; break;
                                case "3": colValues[i] = "プラソートiQ21"; break;
                                case "4": colValues[i] = "KM-9000"; break;
                                case "5": colValues[i] = "日機装透析装置"; break;
                            }
                        }
                        else if (2 == i)
                        {
                            if ("ACH-Σ" == colValues[0])
                            {
                                colValues[i] = splits[i];
                            }
                        }
                        else
                        {
                            colValues[i] = splits[i];
                        }
                    }

                    // update 2021-02-10 FNSI-仕様追加  馮 start
/*                    if (AppCmn.IsModeOnline && "日機装透析装置" == colValues[0])
                    {
                        break; // 日機装透析装置はオンライン非対応なのでDGVにセットしない
                    }
                    else
                    {
                        DataGridView.Rows.Add(colValues);
                    }*/

                    DataGridView.Rows.Add(colValues);

                    // update 2021-02-10 FNSI-仕様追加 馮 end
                }
            }
            // </>

            if (AppCmn.IsModeOnline)
            {
                LblOnOff.Text = "オンラインモード";
                LblOnOff.BackColor = Color.FromArgb(0, 176, 80);
                BtnUpload.Visible = true;

                ToolTip tt = new ToolTip();
                tt.SetToolTip(LblOnOff, $"ユーザーID「{NKKWebAccess.UserId}」");

            }
            else
            {
                LblOnOff.Text = "オフラインモード";
                LblOnOff.BackColor = Color.FromArgb(255, 102, 204);
                BtnUpload.Visible = false;
            }
        }

        private void FrmDeviceSelector_FormClosed(object sender, FormClosedEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);
        }

        private void BtnStart_Click(object sender, EventArgs e)
        {
            int rowIndex = DataGridView.CurrentRow.Index;
            //LogWriter.WriteLog(LogLevel.Debug, "0316000043", "装置選択画面 開始ボタン押下[装置index:{0}]", rowIndex);

            try
            {
                string deviceModel = DataGridView["DeviceModel", rowIndex].Value.ToString();
                string idName = DataGridView["IdName", rowIndex].Value.ToString();
                string ipAddr = DataGridView["IpAddr", rowIndex].Value.ToString();
                int portNo = int.Parse(DataGridView["PortNo", rowIndex].Value.ToString());

                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[装置識別名:{idName}]");

                FrmOrdSelector.DgvDataKind dgvDataKind = FrmOrdSelector.DgvDataKind.BloodPurify;
                if ("日機装透析装置" == deviceModel)
                {
                    dgvDataKind = FrmOrdSelector.DgvDataKind.NkkOffline;
                }

                bool showFrmComm = false;
                var frmOS = new FrmOrdSelector("", dgvDataKind);
                //if (AppCmn.IsModeOnline && !deviceModel.Equals("日機装透析装置"))
                if (AppCmn.IsModeOnline)
                {
                    if (DialogResult.OK == frmOS.ShowDialog())
                    {
                        showFrmComm = true;
                    }
                }
                else
                {
                    showFrmComm = true;
                }
                var selected = frmOS.Selected;

                FrmMonitoring frmMonitor;
                switch (deviceModel)
                {
                    case "ACH-Σ":
                        frmMonitor = new FrmSigma(selected, portNo, $"S_{idName}_", ipAddr);
                        break;
                    case "KM-8900":
                        frmMonitor = new FrmKM8900(selected, portNo, $"K_{idName}_", new KM8900Data());
                        break;
                    case "プラソートiQ21":
                        frmMonitor = new FrmIQ21(selected, portNo, $"i_{idName}_");
                        break;
                    case "KM-9000":
                        frmMonitor = new FrmKM9000(selected, portNo, $"9_{idName}_", new KM9000Data());
                        break;
                    case "日機装透析装置":
                        frmMonitor = new FrmNkkDevice(selected, portNo, $"N_{idName}_");
                        dgvDataKind = FrmOrdSelector.DgvDataKind.NkkOffline;
                        break;
                    default:
                        MessageBox.Show("選択された装置は設定に不備があります。", Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return; // ここでメソッド自体を抜ける
                }

                if (true == showFrmComm)
                {
                    Hide();
                    frmMonitor.ShowDialog();
                    Close();

                    // add mongodbに転載、サーバー停止ログ。 陳 start
                    if (NKKWebAccess.Login)
                    {
                        LogManagement.LogMessage = "特殊浄化通信アプリサーバーが停止しました。";
                        LogManagement.SetLogingProperties();
                    }
                    // add mongodbに転載、サーバー停止ログ。 陳 end
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void BtnEnd_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            Close();

            // add mongodbに転載、サーバー停止ログ。 陳 start
            if (NKKWebAccess.Login)
            {              
                LogManagement.LogMessage = "特殊浄化通信アプリサーバーが停止しました。";
                LogManagement.SetLogingProperties();            
            }
            // add mongodbに転載、サーバー停止ログ。 陳 end
        }

        private void BtnUpload_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                OpenFileDialog ofd = new OpenFileDialog()
                {
                    Title = "治療データを選択して下さい。",
                    Filter = $"|*.bptxt",
                    InitialDirectory = MyConfig.DataDir
                };
                if (DialogResult.OK == ofd.ShowDialog(this))
                {
                    using (FrmOrdSelector frmOS = new FrmOrdSelector(ofd.FileName, FrmOrdSelector.DgvDataKind.DetectByUploadFile))
                    {
                        if (DialogResult.OK == frmOS.ShowDialog())
                        {
                            var parsed = AppCmn.BptxtFileNameParser(ofd.FileName);
                            string msg = $"「{parsed["DeviceModel"]}：{parsed["IdName"]}」の\n";
                            msg += "治療データのアップロードが完了しました。";
                            MessageBox.Show(msg, Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void DataGridView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            // ヘッダー以外
            if (0 <= e.RowIndex)
            {
                BtnStart_Click(sender, e);
            }
        }

        private void DataGridView_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Enter]");

                BtnStart_Click(sender, e);
                e.Handled = true; // Enterによるセルカーソル移動をさせない
            }
            else if (e.KeyCode == Keys.Escape)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Esc]");

                Close();

                // add mongodbに転載、サーバー停止ログ。 陳 start
                if (NKKWebAccess.Login)
                {
                    LogManagement.LogMessage = "特殊浄化通信アプリサーバーが停止しました。";
                    LogManagement.SetLogingProperties();
                }
                // add mongodbに転載、サーバー停止ログ。 陳 end
            }
        }
    }
}

