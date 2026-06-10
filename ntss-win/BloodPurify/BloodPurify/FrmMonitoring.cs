using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.IO;
using System.Net;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;
using NKK.BloodPurify.Properties;
using NKK.FN3.Common.Library.TcpSocket;
using NKK.FN3.ComServer.Library;
using NKKCommon;
using NKKWebAccessLib;

namespace NKK.BloodPurify
{
    public partial class FrmMonitoring : FrmDarkBase
    {
        /// <summary>
        /// bptxt や 電文記録ファイル のプレフィックス(例.「S_2F個室201_」)
        /// </summary>
        protected string DataFilenamePrefix = "";

        /// <summary>
        /// 次にモニタデータをbptxtに書き込む予定の日時
        /// </summary>
        protected DateTime NextDataPickup = DateTime.MinValue;

        /// <summary>
        /// コンストラクタ引数で呼び出し元からもらうパラメータ
        /// </summary>
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
        //protected (long ordNo, string kurName, string bedName, string patName) ArgParams = (-1, "", "", "");
        protected (long ordNo, string kurName, string bedName, string patName, string hospPatID, string rstTreatmentName) ArgParams = (-1, "", "", "", "", "");
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end

        /// <summary>
        /// 通信ポート番号(接続先 or 待ち受け)
        /// </summary>
        protected int PortNo;

        /// <summary>
        /// コマンド受信処理を一時停止させるフラグ
        /// </summary>
        private bool PauseOnRecv = false;

        protected string _PrevStatus = null;
        /// <summary>
        /// 前回臨床工程 {"null":"不定(通信開始時)", "0":"治療外", "1":"治療中"} ※日機装透析装置はoverrideしています
        /// </summary>
        protected virtual string PrevStatus
        {
            get
            {
                return _PrevStatus;
            }

            set
            {
                _PrevStatus = value;

                if ("1" == _PrevStatus)
                {
                    SetTreatStatus(Color.FromArgb(0, 176, 80), "治療中");

                    // 現在治療の「治療データファイル(アップロードデータのみを収集するファイル)」をRESTで上げるタイマーを設定間隔(分)で開始
                    InvokeTimerUploadStart();
                }
                else // null or "0"
                {
                    SetTreatStatus(Color.Olive, "治療外");

                    // 現在治療の「治療データファイル(アップロードデータのみを収集するファイル)」をRESTで上げるタイマーを停止
                    InvokeTimerUploadStop();
                }
            }
        }

        /// <summary>
        /// 治療データファイル(アップロードデータのみを収集するファイル)のファイル名
        /// </summary>
        protected string BptxtFileName = "";

        /// <summary>
        /// フォームタイトル
        /// </summary>
        protected string FormTitle = "";

        /// <summary>
        /// DGVに表示する内容を保持しているDataTable
        /// </summary>
        protected DataTable MyDataTable = null;

        /// <summary>
        /// OnRecv処理中フラグ
        /// </summary>
        protected bool OnRecv_Process;

        /// <summary>
        /// 前回受信データ
        /// </summary>
        protected string ReceivedDataOld { get; set; } = "";

        /// <summary>
        /// 受信データ処理オブジェクト
        /// </summary>
        protected DialysisComNkk DialysisCom;

        /// <summary>
        /// ソケットインスタンス
        /// </summary>
        protected ComSocket MySock;

        /// <summary>
        /// 閉じる際に確認なしでフォームを閉じさせるかどうか
        /// </summary>
        protected bool IsCloseForced = false;

        /// <summary>
        /// 前回受信電文で[誤電文]と表示していたかどうか
        /// </summary>
        protected bool IsLastDispWrongCmd;

        /// <summary>
        /// コンストラクタ(VSデザイナで必要)
        /// </summary>
        public FrmMonitoring()
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
        protected void HandleAccessMessage(String serverName, String strStatus, DateTime dtOccurDate, String strMessage)
        {
            switch (strStatus)
            {
                case "Disconnected":
                    {
                        if (!LblOnOff.Text.Equals("オフラインモード"))
                        {
                            GoToOfflineMode();
                        }
                        break;
                    }
                case "Connected":
                    {
                        //if (!LblOnOff.Text.Equals("オンラインモード"))
                        //{
                        //    GoToOnlineMode();
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
        /// コンストラクタ
        /// </summary>
        /// <param name="argParams">呼び出し元が渡すパラメータ(※予定選択で得られるタプルの形)</param>
        /// <param name="argPortNo">通信ポート番号(接続先 or 待ち受け)</param>
        /// <param name="argDataFileNamePrefix">bptxt や 電文記録ファイル のプレフィックス(例.「S_2F個室201_」)</param>
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
        //public FrmMonitoring((long ordNo, string kurName, string bedName, string patName) argParams, int argPortNo, string argDataFileNamePrefix)
        public FrmMonitoring((long ordNo, string kurName, string bedName, string patName, string hospPatID, string rstTreatmentName) argParams, int argPortNo, string argDataFileNamePrefix)
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
        {
            InitializeComponent();

            CreateMyDataTable();
            AddRowsToMyDataTable();
            DataGridView.RowCount = MyDataTable.Rows.Count;

            ArgParams = argParams;
            PortNo = argPortNo;
            DataFilenamePrefix = argDataFileNamePrefix;
        }

        private void FrmMonitoring_Load(object sender, EventArgs e)
        {
            // <> FrmDarkBaseを継承しているもので共通の処理
            SetTitle(FormTitle);
            // 全部に「Yu Gothic UI」を適用 → 最小/最大/閉じるボタンに「Segoe MDL2 Assets」を適用
            foreach (Control ctrl in AppCmn.GetAllControls(this))
            {
                float size = ctrl.Font.Size;
                ctrl.Font = new Font(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.YU), size);
            }
            SetVisibleBtnMinMaxClose(LayoutDesignerUtility.GetResourceFontFamily(LayoutDesignerUtility.ResourceFont.SEGMDL2));
            // </>

            // ランプ系ラベルを丸くする
            AppCmn.MakeControlCircle(LblDevLamp);
            AppCmn.MakeControlCircle(LblDbLamp);

            // DGVの各列の寄せを調整(※デザインでうまくいかなかったのでコードで直接実施)
            for (int i = 0; i < DataGridView.RowCount; i++)
            {
                DataGridView["DataName", i].Style.Alignment = DataGridViewContentAlignment.MiddleRight;
                DataGridView["DataValue", i].Style.Alignment = DataGridViewContentAlignment.MiddleCenter;
                DataGridView["DataUnit", i].Style.Alignment = DataGridViewContentAlignment.MiddleLeft;
            }

            if (!DesignMode)
            {
                if (AppCmn.IsModeOnline)
                {
                    GoToOnlineMode();
                }
                else
                {
                    GoToOfflineMode();
                }

                if (0 != Directory.GetFiles(MyConfig.DataDir, $"{DataFilenamePrefix}*～.bptxt").Length)
                {
                    // 収集済みの治療データファイルが存在する場合にだけ追記するかを聞く
                    if (DialogResult.Yes == MessageBox.Show("既に収集済みの治療データに追記しますか？", FormTitle, MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                    {
                        OpenFileDialog ofd = new OpenFileDialog()
                        {
                            Title = "追記する治療データを選択して下さい。",
                            Filter = $"|{DataFilenamePrefix}*～.bptxt",
                            InitialDirectory = MyConfig.DataDir
                        };
                        if (DialogResult.OK == ofd.ShowDialog())
                        {
                            BptxtFileName = ofd.SafeFileName;
                            PrevStatus = "1";

                            if (AppCmn.IsModeOnline)
                            {
                                UploadTreatingFileByRest(false);
                            }
                        }
                    }
                }
            }
        }

        private void FrmMonitoring_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (false == IsCloseForced)
            {
                if (DialogResult.OK != MessageBox.Show("装置との通信を切断してアプリを終了します。\nよろしいですか？",
                    Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question))
                {
                    e.Cancel = true; // モニタリング画面を閉じるのをキャンセル
                    return;
                }

                if ("1" == PrevStatus)
                {
                    if (DialogResult.OK != MessageBox.Show("現在治療中のため治療データ収集が継続しています。\n本当に終了してもよろしいですか？",
                        Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Warning))
                    {
                        e.Cancel = true; // モニタリング画面を閉じるのをキャンセル
                        return;
                    }
                }
            }
        }

        private void BtnEnd_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            Close();
        }

        private void DataGridView_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Enter]");

                e.Handled = true; // Enterによるセルカーソル移動をさせない
            }
            else if (e.KeyCode == Keys.Escape)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Esc]");

                Close();
            }
        }

        private void DataGridView_CellValueNeeded(object sender, DataGridViewCellValueEventArgs e)
        {
            try
            {
                // 更新要求のあったセルに描画内容をDataTableより検索して渡す(※バーチャルモード使用のためDataSource紐づけできないので)
                e.Value = MyDataTable.Rows[e.RowIndex][(sender as DataGridView).Columns[e.ColumnIndex].DataPropertyName];
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void TimerUpload_Tick(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                PauseOnRecv = true;
                UploadTreatingFileByRest(false);
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
            finally
            {
                PauseOnRecv = false;
            }
        }

        private void LblOnOff_Click(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            if (!AppCmn.IsModeOnline)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[オフラインモード、かつ、日機装透析装置以外の装置]");

                // サインインに成功するとメソッド内部でNKKWebAccessに各種の必要パラメータがセットされます
                // mod #12204 特殊浄化通信アプリ　アイコン差し替え 高 start
                //var ret = SignInLib.FrmSignIn.ShowSignInDialog(Resources.nkk, MyConfig.SaveFacilityHash);
                var ret = SignInLib.FrmSignIn.ShowSignInDialog(Resources.BloodPurify, MyConfig.SaveFacilityHash);
                // mod #12204 特殊浄化通信アプリ　アイコン差し替え 高 end
                if (DialogResult.Cancel == ret)
                {
                    return;
                }
            }

            if (NKKWebAccess.Login)
            {
                // add mongodbに転載、サーバー起動ログ。 陳 start
                LogManagement.LogMessage = "特殊浄化通信アプリサーバーが起動しました。";
                LogManagement.SetLogingProperties();
                // add mongodbに転載、サーバー起動ログ。 陳 end

                // RESTでmst_kurテーブルのデータを読み出して「クール情報jsonファイル」に保存
                var restRes = Task.Run(async () => await MyRest.GetMstKur()).Result;
                if (false == restRes.isSuccess)
                {
                    MessageBox.Show($"クール情報の取得に失敗しました。\r\n\r\n[{restRes.errorReasonPhrase}]", Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                else
                {
                    List<MyJson.KurInfo> listDbData = MyJson.Conv<List<MyJson.KurInfo>>.Deserialize(restRes.getData);
                    MyJson.Conv<List<MyJson.KurInfo>>.SerializeToFile(listDbData, AppCmn.GetExeDir(true) + "kur.json");
                }

                // 予定選択画面で上げ先を選択
                FrmOrdSelector.DgvDataKind dgvDataKind = AppCmn.IsFileBloodPurify(DataFilenamePrefix) ? FrmOrdSelector.DgvDataKind.BloodPurify : FrmOrdSelector.DgvDataKind.NkkOffline;
                var frmOS = new FrmOrdSelector("", dgvDataKind);
                if (DialogResult.OK == frmOS.ShowDialog())
                {
                    ArgParams = frmOS.Selected;
                    AppCmn.IsModeOnline = true;
                    MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[オンラインモードに遷移]");
                    GoToOnlineMode();

                    if ("1" == PrevStatus)
                    {
                        UploadTreatingFileByRest(false);
                    }
                }
            }
        }

        private delegate void GoToOfflineModeCallback();

        /// <summary>
        /// オフラインモードに遷移した際の処理
        /// </summary>
        private void GoToOfflineMode()
        {
            if (this.InvokeRequired)
            {
                GoToOfflineModeCallback calback = new GoToOfflineModeCallback(GoToOfflineMode);
                this.Invoke(calback);
            }
            else
            {
                LblOnOff.Text = "オフラインモード";
                LblOnOff.BackColor = Color.FromArgb(255, 102, 204);

                ToolTip tt = new ToolTip();
                tt.SetToolTip(LblDevTitle, $"装置 識別名「{DataFilenamePrefix.Substring(2).TrimEnd('_')}」");

                SetDbTitleAndLampAndStatusVisible(false);
            }
        }

        private delegate void GoToOnlineModeCallback();

        /// <summary>
        /// オンラインモードに遷移した際の処理
        /// </summary>
        private void GoToOnlineMode()
        {
            if (this.InvokeRequired)
            {
                GoToOnlineModeCallback calback = new GoToOnlineModeCallback(GoToOnlineMode);
                this.Invoke(calback);
            }
            else
            {
                LblOnOff.Text = "オンラインモード";
                LblOnOff.BackColor = Color.FromArgb(0, 176, 80);

                ToolTip tt = new ToolTip();
                tt.SetToolTip(LblOnOff, $"ユーザーID「{NKKWebAccess.UserId}」");
                tt.SetToolTip(LblTreatStatus, $"透析番号「{ArgParams.ordNo}」\nクール「{ArgParams.kurName}」\nベッド名「{ArgParams.bedName}」\n患者名「{ArgParams.patName}」");
                tt.SetToolTip(LblDevTitle, $"装置 識別名「{DataFilenamePrefix.Substring(2).TrimEnd('_')}」");
                tt.SetToolTip(LblDbTitle, $"サーバ「{NKKWebAccess.BaseUri}」");

                SetDbTitleAndLampAndStatusVisible(true);

                TimerUpload.Interval = MyConfig.DataUploadIntervalMinutes * 60 * 1000;

                // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
                if (!string.IsNullOrEmpty(ArgParams.hospPatID))
                {
                    lblID.Text = "ID： " + ArgParams.hospPatID + "  " + ArgParams.patName;
                    lblKur.Text = ArgParams.kurName + "   " + ArgParams.rstTreatmentName;
                }
                // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
            }
        }

        /// <summary>
        /// UIスレッド側からタイマーを開始(※UIスレッドから操作しないとうまくいかないので)
        /// </summary>
        private void InvokeTimerUploadStart()
        {
            Invoke((MethodInvoker)(() => TimerUpload.Start()));
        }

        /// <summary>
        /// UIスレッド側からタイマーを停止(※UIスレッドから操作しないとうまくいかないので)
        /// </summary>
        private void InvokeTimerUploadStop()
        {
            Invoke((MethodInvoker)(() => TimerUpload.Stop()));
        }

        /// <summary>
        /// 現在治療中の「治療データファイル(アップロードデータのみを収集するファイル)」をRESTで上げる
        /// </summary>
        /// <param name="argIsDel">{"true":"上げたファイルを消す", "false":"上げたファイルと同名の空ファイルを作成"}</param>
        protected void UploadTreatingFileByRest(bool argIsDel)
        {
            string bptxtFilePath = $"{MyConfig.DataDir}\\{BptxtFileName}";

            if (false == AppCmn.IsModeOnline)
            {
                return;
            }

            // (仕様設計上は無いはずだが)ファイルが存在しない場合
            if (false == File.Exists(bptxtFilePath))
            {
                return;
            }

            if (0 == AccessorBptxtFile.IsFileNoEmpty(bptxtFilePath))
            {
                return;
            }

            DateTime startDt = DateTime.Now;
            var restRes = Task.Run(async () => await MyRest.PostBptxtFile(ArgParams.ordNo, bptxtFilePath)).Result;
            if (restRes.isSuccess)
            {
                string ordNoDirPath = $"{MyConfig.DataDir}\\{ArgParams.ordNo:0000000000000000000}";
                Directory.CreateDirectory(ordNoDirPath);

                string dstPath = AppCmn.GetDistinctFilePath($"{ordNoDirPath}\\{BptxtFileName}", 2);
                AppCmn.MoveWithMutex(bptxtFilePath, dstPath);

                if (false == argIsDel)
                {
                    AccessorBptxtFile.Write(bptxtFilePath, null); // 空ファイルを作成(一度アプリ終了して継続をするときに中身空でも必要)
                }

                SetDbLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{startDt:yyyy/MM/dd HH:mm:ss} 書込");
                BeginInvoke((MethodInvoker)delegate
                {
                    LblDbErrorDetail.Visible = false;
                    LblDbStatus.ForeColor = Color.White;
                });
            }
            else
            {
                SetDbLampColorAndStatusText(Color.FromArgb(255, 102, 204), $"{startDt:yyyy/MM/dd HH:mm:ss} 失敗");

                if (HttpStatusCode.Unauthorized == restRes.statusCode || HttpStatusCode.Forbidden == restRes.statusCode)
                {
                    BeginInvoke((MethodInvoker)delegate
                    {
                        LblDbErrorDetail.Visible = true;
                        LblDbErrorDetail.Text = restRes.errorReasonPhrase;
                        LblDbStatus.ForeColor = Color.Red;
                    });
                }
                else
                {
                    BeginInvoke((MethodInvoker)delegate
                    {
                        LblDbErrorDetail.Visible = false;
                        LblDbStatus.ForeColor = Color.White;
                    });
                }
            }
        }

        /// <summary>
        /// DGVの表示／非表示をセット
        /// </summary>
        protected void SetDgvVisible(bool argVisible)
        {
            DataGridView.Visible = argVisible;
        }

        /// <summary>
        /// DGVに表示する内容を保持しているDataTableにテーブル構造を構築
        /// </summary>
        protected void CreateMyDataTable()
        {
            MyDataTable = new DataTable();
            MyDataTable.Columns.Add("DataName", typeof(String));
            MyDataTable.Columns.Add("DataValue", typeof(String));
            MyDataTable.Columns.Add("DataUnit", typeof(String));
        }

        /// <summary>
        /// DGVに表示する内容を保持しているDataTableに1行を登録
        /// </summary>
        /// <param name="argDataName">データ名称</param>
        /// <param name="argDataUnit">データ単位値</param>
        protected void AddOneRowToMyDataTable(String argDataName, String argDataUnit)
        {
            try
            {
                DataRow dr = MyDataTable.NewRow();

                dr["DataName"] = argDataName;
                dr["DataUnit"] = argDataUnit;

                MyDataTable.Rows.Add(dr);
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// [override必須] DGVに表示する内容を保持しているDataTableの全行登録
        /// </summary>
        protected virtual void AddRowsToMyDataTable() {; }

        /// <summary>
        /// DGVに表示する内容を保持しているDataTableの値を更新
        /// </summary>
        /// <param name="argRowIdx">更新対象レコードのRowIndex</param>
        /// <param name="argDataValue">値</param>
        /// <returns>{"true":"値変更ありで更新実施", "false":"値変更なしで更新なし"}</returns>
        protected void UpdateMyDataTable(Int32 argRowIdx, String argDataValue)
        {
            try
            {
                DataRow dr = MyDataTable.Rows[argRowIdx];

                if (null != dr && argDataValue != dr["DataValue"].ToString())
                {
                    dr.BeginEdit();
                    dr["DataValue"] = argDataValue;
                    dr.EndEdit();

                    InvalidateCellOfDataGridView(argRowIdx);
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// 非同期(※複数セル更新時の高速化を意図)でDGVの値を更新
        /// </summary>
        protected void InvalidateCellOfDataGridView(int argRowIdx)
        {
            BeginInvoke((MethodInvoker)(() => DataGridView.InvalidateCell(DataGridView["DataValue", argRowIdx])));
        }

        /// <summary>
        /// 電文記録ファイルの書き出し
        /// </summary>
        /// <param name="argContent">出力内容</param>
        /// <param name="argNow">固定化された現在日時</param>
        protected void CommDataWriter(string argContent, DateTime argNow)
        {
            try
            {
                Directory.CreateDirectory(AppCmn.GetCommDataDir());

                AppCmn.WriteToFile(argContent, $"{AppCmn.GetCommDataDir()}\\{argNow:yyyyMMdd}_{DataFilenamePrefix.TrimEnd('_')}.log", argNow);
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// [サーバ]のステータスランプとラベルの表示／非表示をセット
        /// </summary>
        protected void SetDbTitleAndLampAndStatusVisible(bool argVisible)
        {
            LblDbTitle.Visible = argVisible;
            LblDbLamp.Visible = argVisible;
            LblDbStatus.Visible = argVisible;
        }

        /// <summary>
        /// [装置]のステータスランプ色とラベルの変更(※通信スレッドからの呼出を考慮してInvoke)
        /// </summary>
        /// <param name="argColor">色</param>
        /// <param name="argText">テキスト</param>
        protected void SetDevLampColorAndStatusText(Color argColor, string argText)
        {
            try
            {
                BeginInvoke((MethodInvoker)(() => LblDevLamp.BackColor = argColor));
                BeginInvoke((MethodInvoker)(() => LblDevStatus.Text = argText));
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// [サーバ]のステータスランプ色とラベルの変更(※通信スレッドからの呼出を考慮してInvoke)
        /// </summary>
        /// <param name="argColor">色</param>
        /// <param name="argText">テキスト</param>
        protected void SetDbLampColorAndStatusText(Color argColor, string argText)
        {
            try
            {
                BeginInvoke((MethodInvoker)(() => LblDbLamp.BackColor = argColor));
                BeginInvoke((MethodInvoker)(() => LblDbStatus.Text = argText));
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// [治療外／治療中]のラベルの変更(※通信スレッドからの呼出を考慮してInvoke)
        /// </summary>
        /// <param name="argColor">色</param>
        /// <param name="argText">テキスト</param>
        protected void SetTreatStatus(Color argColor, string argText)
        {
            try
            {
                BeginInvoke((MethodInvoker)(() => LblTreatStatus.BackColor = argColor));
                BeginInvoke((MethodInvoker)(() => LblTreatStatus.Text = argText));
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// [override必須] 受信イベントの処理
        /// </summary>
        /// <param name="sender">データを受信したBaseSocketインスタンス</param>
        protected virtual void ProcReceivedData(BaseSocket sender) {; }

        /// <summary>
        /// データ受信時コールバック関数(KM-8900/KM-9000/日機装透析装置) ※ACH-Σ/プラソートiQ21はoverrideしています
        /// </summary>
        /// <param name="sender">データを受信したBaseSocketインスタンス</param>
        protected virtual void OnRecv(BaseSocket sender)
        {
            try
            {
                // 「一時停止中/前回データ受信時コールバック処理中」は何もしない(※後で受信データを取り出せるので捨てるわけではない)
                if (true == PauseOnRecv || true == OnRecv_Process)
                {
                    return;
                }

                OnRecv_Process = true;
                try
                {
                    lock (DialysisCom)
                    {
                        ProcReceivedData(sender);
                    }

                }
                catch (Exception ex)
                {
                    MyLog.AddLogInfo(this, "", ex);
                }
                finally
                {
                    OnRecv_Process = false;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// 受信データの経過時間(分)から治療開始日時を算出し治療データファイル(アップロードデータのみを収集するファイル)に記録
        /// </summary>
        /// <param name="argNow">現在日時</param>
        /// <param name="argRecvElapsedMinutes">受信データの経過時間(分)</param>
        protected void CalcAndWriteStartDateTimeFromRecvElapseMinutes(DateTime argNow, string argRecvElapsedMinutes)
        {
            DateTime calcStartDt = argNow.AddMinutes(-1 * int.Parse(argRecvElapsedMinutes));
            AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={calcStartDt:yyyyMMddHHmmss}");
        }
    }
}

