using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Threading;
using System.Windows.Forms;
using Fnw.StatisticsTool.Csv;
using Fnw.StatisticsTool.FrmDispCode;
using Fnw.StatisticsTool.FrmMstExamItem;
using Fnw.StatisticsTool.FrmPat;
using Fnw.StatisticsTool.FrmExcel;
using Fnw.StatisticsTool.FrmCustomize;
using Fnw.StatisticsTool.Properties;
using Microsoft.VisualBasic;
using Fnw.StatisticsTool.FrmCsv;
using NKKLoggingLib;
using System.Reflection;
using Fnw.StatisticsTool.Data;
using Fnw.StatisticsTool.Helper;
using System.Threading.Tasks;
using Fnw.StatisticsTool.Models;
using Fnw.StatisticsTool.FrmFnwCode;

namespace Fnw.StatisticsTool
{
    /// <summary>
    /// 統計抽出画面
    /// </summary>
    public partial class FrmStatistics : StatisticsBase
    {
        #region インスタンス変数
        /// <summary>
        /// 処理を行うバックグラウンドワーカ
        /// </summary>
        private BackgroundWorker m_Proc = new BackgroundWorker();
        /// <summary>
        /// 処理患者数
        /// </summary>
        int m_PatCount = 0;
        /// <summary>
        /// 停止フラグ
        /// </summary>
        bool m_IsStop = false;

        /// <summary>
        /// 登録済み患者情報格納
        /// </summary>
        private DataTable m_CsvPatient = null;
        /// <summary>
        /// 患者割当情報格納
        /// </summary>
        private DataTable m_CsvMatchPatient = null;
        /// <summary>
        /// 原疾患(病名)割当情報格納
        /// </summary>
        private static DataTable m_CsvMstDisease = null;
        /// <summary>
        /// 治療方法割当情報格納
        /// </summary>
        private static DataTable m_CsvMstTreatItem = null;
        /// <summary>
        /// 死因割当情報格納
        /// </summary>
        private static DataTable m_CsvMstDie = null;
        /// <summary>
        /// 施設名割当情報格納
        /// </summary>
        private static DataTable m_CsvMstFacility = null;
        /// <summary>
        /// 検査項目割当情報格納
        /// </summary>
        private static DataTable m_CsvMstExamItem = null;
        //2025年度対象項目
        /// <summary>
        /// バスキュラーアクセス割当情報格納
        /// </summary>
        private static DataTable m_CsvMstVa = null;
        //END
        /// <summary>
        /// 感染症割当情報格納
        /// </summary>
        private static DataTable m_CsvMstInfection = null;
        /// <summary>
        /// FNWの施設マスタ情報(キャッシュ用なので『FnwFacility』プロパティを使ってください)
        /// </summary>
        private List<DispCode> m_FnwFacility = null;

        /// <summary>
        /// 統計調査Excelファイルパス
        /// </summary>
        private static string _excelFilePath = string.Empty;

        /// <summary>
        /// 処理ごとの設定内容を保有する辞書（キー：処理名、値：設定内容）
        /// </summary>
        /// <remarks>2015年度対応（マスタ設定・ログのプレビュー表示）</remarks>
        private IDictionary<ProcessId, DataTable> dicProcessData_ = new Dictionary<ProcessId, DataTable>();

        /// <summary>
        /// 確認用の患者設定内容を保有する
        /// </summary>
        private IDictionary<ProcessId, DataTable> dicPatMatchData_ = new Dictionary<ProcessId, DataTable>();

        /// <summary>
        /// 検査結果前後設定区分（1:使用しない, 2:使用する）
        /// </summary>
        private string usingOrderClass = string.Empty;

        /// <summary>
        /// 退避用自施設コード
        /// </summary>
        private string homeFacilityCode = string.Empty;

        /// <summary>
        /// 退避用自施設名
        /// </summary>
        private string homeFacilityName = string.Empty;


        #endregion

        #region プロパティ
        /// <summary>
        /// FNWの施設マスタ情報
        /// </summary>
        private List<DispCode> FnwFacility
        {
            get
            {
                if (null == m_FnwFacility)
                {
                    var wRestRet = Task.Run<RestResultData<List<MstFacilityData>>>(async () => await StatisticsLib.GetMstFactilityList(true)).Result;
                    if (wRestRet.IsSuccess)
                    {
                        // バインド用リストを生成してバインド
                        List<MstFacilityData> list = wRestRet.Data;
                        Dictionary<string, string> columnNames = new Dictionary<string, string>()
                        {
                            { "facilityCd", "FACILITY_CD" },
                            { "facilityName", "FACILITY_NAME" }
                        };

                        // DataTableに変換
                        DataTable dt = StatisticsUtility.ConvertToDataTable(list, columnNames);
                        if (null == dt)
                        {
                            return null;
                        }

                        this.m_FnwFacility = new List<DispCode>();

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            this.m_FnwFacility.Add(new DispCode(dt.Rows[i]["FACILITY_CD"] as string, dt.Rows[i]["FACILITY_NAME"] as string));
                        }

                      }
                    else
                    {
                        return null;
                    }
                }

                return m_FnwFacility;
            }
        }
        #endregion

        #region ENUM 通知種別
        /// <summary>
        /// スレッドからの通知種別
        /// </summary>
        private enum ReportType
        {
            /// <summary>正常終了</summary>
            SUCCESS = 1,
            /// <summary>正常終了したけどエラー患者有り</summary>
            EXIST_ERROR,
            /// <summary>異常終了</summary>
            FAILED,
            /// <summary>停止要求終了</summary>
            STOP,
            /// <summary>一件処理終了</summary>
            ONE_FIN,
            /// <summary>ログ出力</summary>
            LOG,
        }
        #endregion

        #region コンストラクタ
        /// <summary>
        /// 統計抽出処理画面コンストラクタ
        /// </summary>
        public FrmStatistics() :base(isUserLoggedIn:true)
        {
            InitializeComponent();

            // フォーム全体のイベントを登録
            RegisterEvents(this);
            // 抽出処理を行う別スレッドのイベントハンドラ登録
            m_Proc.WorkerReportsProgress = true;
            m_Proc.DoWork += new DoWorkEventHandler(m_Proc_DoWork);
            m_Proc.Disposed += new EventHandler(m_Proc_Disposed);
            m_Proc.RunWorkerCompleted += new RunWorkerCompletedEventHandler(m_Proc_RunWorkerCompleted);
            m_Proc.ProgressChanged += new ProgressChangedEventHandler(m_Proc_ProgressChanged);
            // XMLファイルから設定を読み込む
            CustomizeSettings.LoadFromXmlFile();

        }

        /// <summary>
        /// 子コントロールに対して再帰的にイベントを登録
        /// </summary>
        /// <param name="control"></param>
        private void RegisterEvents(Control control)
        {
            control.MouseEnter += OnUserActivity;
            control.MouseLeave += OnUserActivity;
            control.MouseMove += OnUserActivity;
            control.KeyDown += OnUserActivity;

            foreach (Control child in control.Controls)
            {
                RegisterEvents(child);
            }
        }
        #endregion

        #region イベント処理
        /// <summary>
        /// フォームロード
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmStatistics_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            // 自施設コード
            if (string.IsNullOrEmpty(ConfigHelper.ReadSetting("FacilityCd")))
            {
                txtFacilityCode.Text = string.Empty;
                homeFacilityCode = string.Empty;
                ChangeBottonEnable(false);
            }
            else
            {
                txtFacilityCode.Text = ConfigHelper.ReadSetting("FacilityCd");
                homeFacilityCode = txtFacilityCode.Text;
                ChangeBottonEnable(true);
            }

            // デフォルトの抽出先をフォルダ選択ダイアログに設定
            dirExportDirectory.SelectedPath = Settings.Default.PathExport;

            //【2022年度版対応】2021年度までの未対応分の改修
            DeleteFilePrePeriodSheetSums();

            // 2015年版検査結果前後対応
            this.usingOrderClass = this.GetUsingOrderClass();

            // 自施設取得(学会コードじゃなくてFNWマスタの情報からデータを取得して処理)
            if (null != this.FnwFacility)
            {
                List<DispCode> list = this.FnwFacility.FindAll(ele => ele.Code == this.txtFacilityCode.Text);
                if (1 == list.Count)
                {
                    homeFacilityName = list[0].Name;
                    lblFacilityName.Text = homeFacilityName;
                }
                else
                {
                    lblFacilityName.Text = string.Empty;
                }
            }

            string name = ConfigHelper.ReadSetting("FacilityName");
            if (!string.IsNullOrEmpty(name))
            {
                lblFacilityName.Text = name;
            }

            // 各処理の完了状態を表示する
            ShowAllCompletionStatus();

            // 完了状態によるボタンの押下可否制御
            this.ChangeButtonStatus();
        }

        //【2022年度版対応】2021年度までの未対応分の改修
        /// <summary>
        /// 今年度以外のSheetSum.txt（履歴）を削除する。
        /// </summary>
        public void DeleteFilePrePeriodSheetSums()
        {
            string period = Settings.Default.PeriodStart.ToString("yyyy");

            string[] fileNames = Directory.GetFiles(dirExportDirectory.SelectedPath, Settings.Default.FileSheetSum + ".*.*.bak");
            foreach (string fileName in fileNames)
            {
                try
                {
                    string filePeriod = fileName.Substring(fileName.Length - 26 , 4);
                    if (!filePeriod.Equals(period))
                    {
                        File.Delete(fileName);
                    }
                }
                catch (Exception ex)
                {
                    NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmStatistics), NKKLogging.LOGGING_CLASS.ERROR, String.Format("ファイル削除に失敗 パス：,{0},{1}", fileName, ex.ToString().Replace("\r\n", "{CRLF}")));
                }
            }
        }

        /// <summary>
        /// 閉じられようとしている
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmStatistics_FormClosing(object sender, FormClosingEventArgs e)
        {
            // 別スレッドの処理中は閉じないようにイベントをキャンセル
            if (m_Proc.IsBusy)
            {
                e.Cancel = true;
            }

            // 2015年版対応：検査結果前後対応
            ConfigHelper.WriteSetting("UsingOrderClass", this.usingOrderClass);
        }

        /// <summary>
        /// 登録済み患者一覧作成
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnExcelImport_Click(object sender, EventArgs e)
        {
            // 登録済み患者一覧作成画面を表示(この時、邪魔なので自画面を非表示に)
            using (FrmExcelImport dlg = new FrmExcelImport())
            {
                // 2015年版対応（各処理の完了状態を表示する）
                dlg.ProcItem = CompletionStatus.GetProcessItem(ProcessId.ExcelImport);
                this.Visible = false;
                this.ShowChildForm(dlg, string.Empty, string.Empty);
                // 2015年版対応（各処理の完了状態を表示する）
                ShowCompletionStatus(dlg.ProcItem);
                this.lastActivity = DateTime.Now;
            }
            this.Visible = true;
        }

        /// <summary>
        /// 患者割当
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnPatMatch_Click(object sender, EventArgs e)
        {
            // 患者割当画面を表示(この時、邪魔なので自画面を非表示に)
            using (FrmPatMatch dlg = new FrmPatMatch())
            {
                // 2015年版対応（各処理の完了状態を表示する）
                dlg.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchPatient);
                this.Visible = false;
                this.ShowChildForm(dlg, string.Empty, string.Empty);
                // 2015年版対応（各処理の完了状態を表示する）
                ShowCompletionStatus(dlg.ProcItem);
                // 2015年版対応（マスタ設定・ログのプレビュー表示）
                SetMstDataTable(ProcessId.MatchPatient, dlg.DataPatMatch);
                this.lastActivity = DateTime.Now;
            }
            this.Visible = true;
        }

        /// <summary>
        /// 原疾患設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnMstDiseaseMatch_Click(object sender, EventArgs e)
        {
            // 2015年版対応（各処理の完了状態を表示する）
            this.ProcMatch(MatchType.MST_DISEASE, ProcessId.MatchMstDisease);
        }

        /// <summary>
        /// 治療方法設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnMstTreatItemMatch_Click(object sender, EventArgs e)
        {
            // 2015年版対応（各処理の完了状態を表示する）
            this.ProcMatch(MatchType.MST_TREAT_ITEM, ProcessId.MatchMstTreatItem);
        }

        /// <summary>
        /// 死因設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnMstDieMatch_Click(object sender, EventArgs e)
        {
            // 2015年版対応（各処理の完了状態を表示する）
            this.ProcMatch(MatchType.MST_DIE, ProcessId.MatchMstDie);
        }

        /// <summary>
        /// 施設設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnMstFacilityMatch_Click(object sender, EventArgs e)
        {
            // 2015年版対応（各処理の完了状態を表示する）
            this.ProcMatch(MatchType.MST_FACILITY, ProcessId.MstFacility);
            string name = ConfigHelper.ReadSetting("FacilityName");
            if (!string.IsNullOrEmpty(name))
            {
                lblFacilityName.Text = name;
            }
        }

        /// <summary>
        /// 割当処理
        /// </summary>
        /// <param name="type">割り当て種類</param>
        /// <param name="procName">処理名</param>
        private void ProcMatch(MatchType type, ProcessId procName)
        {
            try
            {
                using (FrmDispCodeMatch frm = new FrmDispCodeMatch())
                {
                    frm.EditType = type;
                    // 2015年版対応（各処理の完了状態を表示する）
                    frm.ProcItem = CompletionStatus.GetProcessItem(procName);
                    frm.FacilityName = homeFacilityName;
                    frm.FacilityCode = homeFacilityCode;
                    this.Visible = false;
                    this.ShowChildForm(frm, string.Empty, string.Empty);
                    // 2015年版対応（各処理の完了状態を表示する）
                    ShowCompletionStatus(frm.ProcItem);
                    // 2015年版対応（マスタ設定・ログのプレビュー表示）
                    SetMstDataTable(procName, frm.DataCodeMatch);
                    this.lastActivity = DateTime.Now;
                }
                this.Visible = true;
            }
            catch (Exception)
            {
            }
        }

        /// <summary>
        /// 検査項目設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnMstExamItemMatch_Click(object sender, EventArgs e)
        {
            try
            {
                using (FrmMstExamItemMatch frm = new FrmMstExamItemMatch())
                {
                    // 2015年版検査結果前後対応
                    FrmMstExamItemMatch.FrmMstExamItemInstance = frm;
                    FrmMstExamItemMatch.FrmMstExamItemInstance.OrderClass = this.usingOrderClass;

                    // 2015年版対応（各処理の完了状態を表示する）
                    frm.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchMstExamItem);
                    this.Visible = false;
                    this.ShowChildForm(frm, string.Empty, string.Empty);
                    // 2015年版検査結果前後対応
                    this.usingOrderClass = FrmMstExamItemMatch.FrmMstExamItemInstance.OrderClass;
                    // 2015年版対応（各処理の完了状態を表示する）
                    ShowCompletionStatus(frm.ProcItem);
                    // 2015年版対応（マスタ設定・ログのプレビュー表示）
                    SetMstDataTable(ProcessId.MatchMstExamItem, frm.DataExamItemMatch);
                    this.lastActivity = DateTime.Now;
                }
                this.Visible = true;
            }
            catch (Exception)
            {
            }
        }

        /// <summary>
        /// 糖尿病設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnDiabetesSelect_Click(object sender, EventArgs e)
        {
            // 2015年版対応（各処理の完了状態を表示する）
            this.ProcSelect(CheckBoxType.MST_DISEASE_DIABETES, ProcessId.SelectMstDiseaseDiabetes);
        }
        
        /// <summary>
        /// 選択処理
        /// </summary>
        /// <param name="type">選択種類</param>
        /// <param name="procName">処理名</param>
        private void ProcSelect(CheckBoxType type, ProcessId procName)
        {
            using (FrmDispCodeCheckBox frm = new FrmDispCodeCheckBox())
            {
                frm.EditType = type;
                // 2015年版対応（各処理の完了状態を表示する）
                frm.ProcItem = CompletionStatus.GetProcessItem(procName);
                this.Visible = false;
                this.ShowChildForm(frm, string.Empty, string.Empty);
                // 2015年版対応（各処理の完了状態を表示する）
                ShowCompletionStatus(frm.ProcItem);
                // 2015年版対応（マスタ設定・ログのプレビュー表示）
                SetMstDataTable(procName, frm.DataCodeMatch);
                this.lastActivity = DateTime.Now;
            }
            this.Visible = true;
        }

        /// <summary>
        /// 抽出
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnExtract_Click(object sender, EventArgs e)
        {
            if (m_Proc.IsBusy)
            {
                // 処理中なのでキャンセルフラグ
                btnExtract.Enabled = false;
                m_IsStop = true;
                return;
            }

            // 出力ファイル削除
            if (false == this.RemoveExtractFiles())
            {
                MessageBox.Show("出力ファイルの削除が出来ません\r\n使用中では無いか確認してください", "ファイル削除エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }

            // 設定を取得(メンバ変数にキャッシュ)
            if (false == this.GetSetting())
            {
                return;
            }

            // ログをクリア
            lstLog.Items.Clear();
            m_PatCount = 0;

            // コントロール変更
            SetCtrlEnable(false);

            // スレッド処理開始
            m_IsStop = false;
            m_Proc.RunWorkerAsync();
        }

        /// <summary>
        /// カスタマイズ設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCustomize_Click(object sender, EventArgs e)
        {
            // カスタマイズ設定画面を表示(この時、邪魔なので自画面を非表示に)
            using (FrmCustomizeSettings dlg = new FrmCustomizeSettings())
            {
                // 2015年版対応（各処理の完了状態を表示する）
                dlg.ProcItem = CompletionStatus.GetProcessItem(ProcessId.CustomizeSettings);
                this.Visible = false;
                //dlg.ShowDialog();
                this.ShowChildForm(dlg, string.Empty, string.Empty);
                // 2015年版対応（各処理の完了状態を表示する）
                ShowCompletionStatus(dlg.ProcItem);
                this.lastActivity = DateTime.Now;
            }
            this.Visible = true;
        }

        #endregion

        #region 2015年度対応：各処理の完了状態を表示する
        /// <summary>
        ///  2015年版対応：各処理の完了状態を表示します。
        /// </summary>
        /// <param name="item">完了状態</param>
        private void ShowCompletionStatus(ProcessItem item)
        {
            // 完了状態によるボタンの押下可否制御
            this.ChangeButtonStatus();

            switch (item.ProcId)
            {
                case ProcessId.ExcelImport:
                    // 登録済み患者一覧作成
                    this.lblExcelImportStatus.Text = item.StatusName;
                    this.lblExcelImportTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MatchPatient:
                    // 患者設定
                    this.lblPatMatchStatus.Text = item.StatusName;
                    this.lblPatMatchTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MatchMstDisease:
                    // 原疾患設定
                    this.lblDiseaseStatus.Text = item.StatusName;
                    this.lblDiseaseTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MatchMstTreatItem:
                    // 治療方法設定
                    this.lblTreatItemStatus.Text = item.StatusName;
                    this.lblTreatItemTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MatchMstDie:
                    // 死因設定
                    this.lblDieStatus.Text = item.StatusName;
                    this.lblDieTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MstFacility:
                    // 施設設定
                    this.lblFacilityStatus.Text = item.StatusName;
                    this.lblFacilityTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MatchMstExamItem:
                    // 検査項目設定
                    this.lblExamItemStatus.Text = item.StatusName;
                    this.lblExamItemTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.SelectMstDiseaseDiabetes:
                    // 糖尿病設定
                    this.lblDiabetesStatus.Text = item.StatusName;
                    this.lblDiabetesTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MatchMstInfection:
                    // 感染症設定
                    this.lblInfectionStatus.Text = item.StatusName;
                    this.lblInfectionTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.MatchMstVa:
                    // バスキュラーアクセス設定
                    this.lblVaStatus.Text = item.StatusName;
                    this.lblVaTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.CustomizeSettings:
                    // 抽出設定
                    this.lblCustomizeStatus.Text = item.StatusName;
                    this.lblCustomizeTimestamp.Text = item.TimestampString;
                    break;
                case ProcessId.ExtractCsv:
                    // 抽出
                    this.lblExtractStatus.Text = item.StatusName;
                    this.lblExtractTimestamp.Text = item.TimestampString;
                    break;
                default:
                    break;
            }
        }

        /// <summary>
        /// すべての処理の完了状態を再表示する
        /// </summary>
        public void ShowAllCompletionStatus()
        {
            //CompletionStatus_YYYY.xmlファイルを読み込む
            CompletionStatus.LoadFromXmlFile();

            //すべての処理の完了状態を再表示する
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.ExcelImport));               //登録済み患者一覧作成
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MatchPatient));              //患者設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MatchMstDisease));           //原疾患設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MatchMstTreatItem));         //治療方法設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MatchMstDie));               //死因設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MstFacility));               //施設設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MatchMstExamItem));          //検査項目設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.SelectMstDiseaseDiabetes));  //糖尿病設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MatchMstInfection));         //感染症設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.MatchMstVa));         //バスキュラーアクセス設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.CustomizeSettings));         //抽出設定
            ShowCompletionStatus(CompletionStatus.GetProcessItem(ProcessId.ExtractCsv));                //抽出
        }
        #endregion

        #region 抽出処理
        /// <summary>
        /// コントロールの有効/無効切替
        /// </summary>
        /// <param name="isEnable">true：有効化 false：無効化</param>
        private void SetCtrlEnable(bool isEnable)
        {
            // 各割当ボタンとテキストボックスは有効/無効切替の対象
            btnExcelImport.Enabled = isEnable;
            btnPatMatch.Enabled = isEnable;
            btnMstDiseaseMatch.Enabled = isEnable;
            btnMstTreatItemMatch.Enabled = isEnable;
            btnMstDieMatch.Enabled = isEnable;
            btnMstFacilityMatch.Enabled = isEnable;
            btnMstExamItemMatch.Enabled = isEnable;
            btnMstInfectionMatch.Enabled = isEnable;
            btnMstVaMatch.Enabled = isEnable;
            btnDiabetesSelect.Enabled = isEnable;
            btnCustomize.Enabled = isEnable;

            // 抽出ボタンは有効化(停止を押した時に無効になっているので元に戻す)とキャプション変更
            btnExtract.Enabled = true;
            if (isEnable)
            {
                btnExtract.Text = "抽出";
            }
            else
            {
                btnExtract.Text = "停止";
            }
        }

        /// <summary>
        /// ログ表示
        /// </summary>
        /// <param name="log"></param>
        private void Log(string log)
        {
            // 同じ内容をログに出力
            //LogManager.WriteTraceLog(null, null, log);

            // ログ表示を最大100行に
            lstLog.Items.Add(log);
            while (100 < lstLog.Items.Count)
            {
                lstLog.Items.RemoveAt(0);
            }

            // 最新(一番下)のログを表示させる
            lstLog.SelectedIndex = lstLog.Items.Count - 1;
        }

        /// <summary>
        /// スレッドからの通知
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void m_Proc_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            // 2015年版対応（各処理の完了状態を表示する）
            bool confirmStatus = false;

            // スレッドからの通知処理
            switch ((ReportType)e.ProgressPercentage)
            {
                case ReportType.SUCCESS:
                    // 異常データ0件で処理終了
                    this.Log("正常終了");
                    //MessageBox.Show(this, "抽出が完了しました\r\n出力先[" + Settings.Default.PathExport + "\\" + Settings.Default.FileSheetSum + "]", "正常終了", MessageBoxButtons.OK);
                    // 2015年版対応（各処理の完了状態を表示する）
                    confirmStatus = true;
                    break;
                case ReportType.EXIST_ERROR:
                    // 処理は終了したけどエラーデータあり
                    this.Log("処理終了");
                    this.Log("出力フォルダ[" + Settings.Default.PathExport + "]");
                    //MessageBox.Show(this, "データ抽出異常が有ります\r\n\r\n異常データリストが出力されているので\r\n出力フォルダを確認して下さい\r\n出力フォルダ[" + Settings.Default.PathExport + "]", "異常データ有り", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    // 2015年版対応（各処理の完了状態を表示する）
                    confirmStatus = true;
                    break;
                case ReportType.FAILED:
                    // 異常が発生して処理を中止
                    this.Log("異常終了");
                    break;
                case ReportType.STOP:
                    // ユーザが停止ボタンを押して処理を終了した
                    this.Log("処理を停止しました");
                    break;
                case ReportType.ONE_FIN:
                    // 一人分の処理が終わった事を通知
                    this.m_PatCount++;
                    this.Log(this.m_PatCount.ToString() + "人目処理終了");
                    break;
                case ReportType.LOG:
                    // ログ通知
                    this.Log(e.UserState as string);
                    break;
                default:
                    break;
            }

            // 抽出結果を表示(この時、邪魔なので自画面を非表示に)
            if (confirmStatus)
            {
                using (FrmCsvViewer dlg = new FrmCsvViewer())
                {
                    this.Visible = false;
                    dlg.ShowDialog();
                }
                this.lastActivity = DateTime.Now;
                this.Visible = true;
            }
            // 2015年版対応（各処理の完了状態を表示する）
            if (confirmStatus)
            {
                this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.ExtractCsv);
                ConfirmCompletionStatus(true);
                ShowCompletionStatus(this.ProcItem);
                this.ProcItem = null;
            }
        }

        /// <summary>
        /// スレッド終了
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void m_Proc_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            // スレッドが終了したらコントロールを元に戻す
            SetCtrlEnable(true);
        }

        /// <summary>
        /// スレッド破棄
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void m_Proc_Disposed(object sender, EventArgs e)
        {
            // 一応、元に戻す
            SetCtrlEnable(true);
        }

        /// <summary>
        /// スレッドメイン処理
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void m_Proc_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                // 非同期処理を実行
                var task = Task.Run(async () =>
                {
                    // 登録済み患者を二重で処理しないように登録した人を格納する
                    List<long> RegisteredPat = new List<long>();
                    // 年末透析未実施患者の抽出
                    List<long> temporaryPat = await this.GetTemporatyPatAsync();

                    var (isRegisteredSuccessful, isRegisteredError) = await ProcRegisteredAsync(RegisteredPat, temporaryPat);
                    if (!isRegisteredSuccessful)
                    {
                        // 失敗
                        m_Proc.ReportProgress((int)ReportType.FAILED);
                        return;
                    }

                    if (this.m_IsStop)
                    {
                        // 処理中断
                        m_Proc.ReportProgress((int)ReportType.STOP);
                        return;
                    }

                    // 登録済みが終わったことを通知
                    m_Proc.ReportProgress((int)ReportType.LOG, "登録済み患者処理終了");

                    // その他を処理
                    var (isSheetProcessedSuccessful, isSheetError) = await ProcSheetOtherAsync(RegisteredPat, temporaryPat);
                    if (!isSheetProcessedSuccessful)
                    {
                        // 失敗
                        m_Proc.ReportProgress((int)ReportType.FAILED);
                        return;
                    }

                    if (m_IsStop)
                    {
                        // 処理中断
                        m_Proc.ReportProgress((int)ReportType.STOP);
                        return;
                    }

                    // エラー患者存在フラグ
                    if (isRegisteredError || isSheetError)
                    {
                        // 異常患者有り
                        m_Proc.ReportProgress((int)ReportType.EXIST_ERROR);
                    }
                    else
                    {
                        // 成功
                        m_Proc.ReportProgress((int)ReportType.SUCCESS);
                    }
                });
                // タスクの完了待機
                task.Wait();
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmStatistics), NKKLogging.LOGGING_CLASS.ERROR, String.Format("抽出に失敗,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
            }
        }

        /// <summary>
        /// 出力結果ファイルを削除
        /// </summary>
        /// <returns></returns>
        private bool RemoveExtractFiles()
        {
            string[] files =
            {
                dirExportDirectory.SelectedPath + "\\" + Settings.Default.FileSheetSum,
                dirExportDirectory.SelectedPath + "\\" + Settings.Default.FileErrorNew,
                dirExportDirectory.SelectedPath + "\\" + Settings.Default.FileErrorOld,
            };

            for (int i = 0; i < files.Length; i++)
            {
                try
                {
                    //【2022年度版対応】2021年度までの未対応分の改修
                    // SheetSum.txtを削除せずに履歴として残す。
                    if (i == 0)
                    {
                        string period = Settings.Default.PeriodStart.ToString(".yyyy");

                        DateTime dt = DateTime.Now;

                        if (File.Exists(files[i]))
                        {
                            File.Copy(files[i], files[i] + period + dt.ToString(".yyyyMMddHHmmssfff") + ".bak");
                        }
                    }
                    else
                    {
                        File.Delete(files[i]);
                    }
                }
                catch (Exception ex)
                {
                    NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmStatistics), NKKLogging.LOGGING_CLASS.ERROR, String.Format("ファイル削除に失敗 パス：,{0},{1}", files[i], ex.ToString().Replace("\r\n", "{CRLF}")));
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// 設定取得
        /// </summary>
        /// <returns></returns>
        private bool GetSetting()
        {
            // 登録済み患者情報および患者割当情報を取得
            m_CsvPatient = FnwCsv.ReadPatientCsv();
            m_CsvMatchPatient = FnwCsv.ReadMatchPatientCsv();

            if (0 == m_CsvPatient.Rows.Count)
            {
                // 登録済み0件(ファイル無し含む(以下、同様))
                if (DialogResult.Yes != MessageBox.Show("登録済み患者が0件ですが続けてよろしいですか？", "登録済み患者無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }
            else if (0 == m_CsvMatchPatient.Rows.Count)
            {
                // 登録済み患者は居るが割当情報無し
                if (DialogResult.Yes != MessageBox.Show("登録済み患者の紐付けが行われていませんが続けてよろしいですか？", "紐付けデータ無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }

            // 病名割当情報取得
            m_CsvMstDisease = FnwCsv.ReadMatchMstDiseaseCsv();
            if (0 == m_CsvMstDisease.Rows.Count)
            {
                // 病名割当情報0件
                if (DialogResult.Yes != MessageBox.Show("原疾患の紐付け情報がありませんが続けてよろしいですか？", "紐付けデータ無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }

            // 治療項目割当情報取得
            m_CsvMstTreatItem = FnwCsv.ReadMatchMstTreatItemCsv();
            if (0 == m_CsvMstTreatItem.Rows.Count)
            {
                if (DialogResult.Yes != MessageBox.Show("治療項目の紐付け情報がありませんが続けてよろしいですか？", "紐付けデータ無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }

            // 死因割当情報取得
            m_CsvMstDie = FnwCsv.ReadMatchMstDieCsv();
            if (0 == m_CsvMstDie.Rows.Count)
            {
                if (DialogResult.Yes != MessageBox.Show("死因の紐付け情報がありませんが続けてよろしいですか？", "紐付けデータ無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }

            // 検査項目割当情報取得
            m_CsvMstExamItem = FnwCsv.ReadMatchMstExamItemCsv();
            if (m_CsvMstExamItem.Rows.Count < 12)
            {
                if (DialogResult.Yes != MessageBox.Show("検査項目の紐付け情報が不足していますが続けてよろしいですか？", "紐付けデータ不足", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }

            //2025年度対象項目
            // バスキュラーアクセス割当情報取得
            m_CsvMstVa = FnwCsv.ReadMatchMstVaCsv();
            if (0 == m_CsvMstVa.Rows.Count)
            {
                if (DialogResult.Yes != MessageBox.Show("バスキュラーアクセスコードの紐付け情報がありませんが続けてよろしいですか？", "紐付けデータ無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }
            //END

            // 糖尿病選択情報取得
            if (0 == FnwCsv.ReadSelectMstDiseaseDiabetesCsv().Rows.Count)
            {
                if (DialogResult.Yes != MessageBox.Show("糖尿病の選択情報がありませんが続けてよろしいですか？", "選択データ無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }

            // 感染症割当情報取得
            m_CsvMstInfection = FnwCsv.ReadMatchMstInfectionCsv();
            if (0 == m_CsvMstInfection.Rows.Count)
            {
                if (DialogResult.Yes != MessageBox.Show("感染症の紐付け情報が不足していますが続けてよろしいですか？", "紐付けデータ不足", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }

            // 施設名割当情報取得
            m_CsvMstFacility = FnwCsv.ReadMatchMstFacilityCsv();
            if (0 == m_CsvMstFacility.Rows.Count)
            {
                if (DialogResult.Yes != MessageBox.Show("施設コードの紐付け情報がありませんが続けてよろしいですか？", "紐付けデータ無し", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    return false;
                }
            }
            return true;
        }

        /// <summary>
        /// 原疾患を学会コードに変換
        /// </summary>
        /// <param name="fnwCode">Fnwコード</param>
        /// <returns>学会コード</returns>
        public static string ConvDisease(int fnwCode)
        {
            DataRow[] work = m_CsvMstDisease.Select(FnwCsv.C_M_DIS1 + " + '$$' = '" + fnwCode + "$$'");
            if (1 != work.Length)
            {
                // 2015年度対応（未設定項目に不明コードを設定）
                //return string.Empty;
                return FnwCsv.C_M_DIS2_Unknown;
            }
            if (work[0][FnwCsv.C_M_DIS2].ToString() == "ZZZ")
            {
                return FnwCsv.C_M_DIS2_Unknown;
            }
            return work[0][FnwCsv.C_M_DIS2] as string;
        }

        /// <summary>
        /// 治療方法コードを学会コードに変換
        /// </summary>
        /// <param name="fnwCode">Fnwコード</param>
        /// <returns>学会コード</returns>
        public static string ConvTreatItem(string fnwCode)
        {
            DataRow[] work = m_CsvMstTreatItem.Select(FnwCsv.C_M_TRE1 + " + '$$' = '" + fnwCode + "$$'");
            if (1 != work.Length)
            {
                return string.Empty;
            }
            if (work[0][FnwCsv.C_M_TRE2].ToString() == "ZZ")
            {
                return string.Empty;
            }
            return work[0][FnwCsv.C_M_TRE2] as string;
        }

        /// <summary>
        /// 死因コードを学会コードに変換
        /// </summary>
        /// <param name="fnwCode">Fnwコード</param>
        /// <returns>学会コード</returns>
        public static string ConvDie(string fnwCode)
        {
            DataRow[] work = m_CsvMstDie.Select(FnwCsv.C_M_DIE1 + " + '$$' = '" + fnwCode + "$$'");
            if (1 != work.Length)
            {
                return string.Empty;
            }
            if (work[0][FnwCsv.C_M_DIE2].ToString() == "ZZZ")
            {
                return string.Empty;
            }

            return work[0][FnwCsv.C_M_DIE2] as string;
        }

        /// <summary>
        /// 施設名を学会コードに変換
        /// </summary>
        /// <param name="fnwName">施設名</param>
        /// <returns>学会コード</returns>
        public static string ConvFacility(string fnwName)
        {
            DataRow[] work = m_CsvMstFacility.Select(FnwCsv.C_M_FAC1 + " + '$$' = '" + fnwName + "$$'");
            if (1 != work.Length)
            {
                return string.Empty;
            }
            if (work[0][FnwCsv.C_M_FAC2].ToString() == "ZZZZZZ")
            {
                return string.Empty;
            }
            return work[0][FnwCsv.C_M_FAC2] as string;
        }

        /// <summary>
        /// 感染症名をFNWコードに変換
        /// </summary>
        /// <param name="infectKey">感染症名</param>
        /// <returns>感染症FNWコード</returns>
        public static string ConvInfect(string infectKey)
        {
            DataRow[] work = m_CsvMstInfection.Select(FnwCsv.C_M_INF1 + " + '$$' = '" + infectKey + "$$'");
            if (1 != work.Length)
            {
                return string.Empty;
            }
            return work[0][FnwCsv.C_M_INF2] as string;
        }

        /// <summary>
        /// StatisticsConstで定義している検査キーを検査項目コードに変換
        /// </summary>
        /// <param name="examKey">検査キー</param>
        /// <returns>検査項目コード</returns>
        public static int ConvExamItem(string examKey)
        {
            DataRow[] work = m_CsvMstExamItem.Select(FnwCsv.C_M_EXA1 + " + '$$' = '" + examKey + "$$'");
            if (1 != work.Length)
            {
                return -1;
            }
            if (work[0][FnwCsv.C_M_EXA2].ToString() == "ZZZZZZZZZZ")
            {
                return -1;
            }
            return int.Parse(work[0][FnwCsv.C_M_EXA2].ToString());
        }

        // 2025年度対象項目
        /// <summary>
        /// バスキュラーアクセスコードを学会コードに変換
        /// </summary>
        /// <param name="fnwCode">Fnwコード</param>
        /// <returns>学会コード</returns>
        public static string ConvVa(string fnwCode)
        {
            DataRow[] work = m_CsvMstVa.Select(FnwCsv.C_M_VA1 + " + '$$' = '" + fnwCode + "$$'");
            if (1 != work.Length)
            {
                return string.Empty;
            }
            if (work[0][FnwCsv.C_M_VA2].ToString() == "ZZ")
            {
                return string.Empty;
            }
            // 学会コードを返す
            return work[0][FnwCsv.C_M_VA2] as string;
        }
        //END

        /// <summary>
        /// 登録済み患者
        /// </summary>
        /// <param name="patIDList">登録済み患者で処理したIDリスト</param>
        /// <param name="isExistError">処理エラーの患者が居たかどうか</param>
        /// <param name="temporaryPat">年末透析未実施患者のIDリスト</param>
        /// <returns>true：成功 false：失敗</returns>
        private async Task<(bool success, bool isExistError)> ProcRegisteredAsync(List<long> patIDList, List<long> temporaryPat)
        {
            bool isExistError = false;
            // 結果格納用のDataTableを作成
            DataTable result = new DataTable();
            for (int i = 0; i < (int)SheetSum.件数_; i++)
            {
                result.Columns.Add();
            }

            // エラー患者格納用のDataTable作成
            DataTable error = new DataTable();
            for (int i = 0; i < (int)ErrorSheetOld.COL_COUNT; i++)
            {
                error.Columns.Add();
            }

            m_Proc.ReportProgress((int)ReportType.LOG, "登録済み患者処理開始 対象人数：" + m_CsvPatient.Rows.Count.ToString() + "人");

            for (int i = 0; i < m_CsvPatient.Rows.Count; i++)
            {
                if (m_IsStop)
                {
                    // 処理中断
                    return (true, isExistError); 
                }

                // CPU稼働率を下げるため1人処理するたびに少し待つ
                //Thread.Sleep(Settings.Default.ProcWait);
                await Task.Delay(Settings.Default.ProcWait);

                ////独自シーケンス作成(2012年度はシーケンスがExcelに記載されていない可能性があるため)
                string strSeq = string.Empty;
                strSeq = i.ToString();

                // 割当患者のIDを取得
                DataRow[] patMatchList = m_CsvMatchPatient.Select(FnwCsv.C_M_PAT1 + " + '$$' = '" + strSeq + "$$'");
                long patID = 0; 
                // 腹膜透析患者フラグ
                bool isPdPat = false;
                if (1 == patMatchList.Length)
                {
                    patID = long.Parse(patMatchList[0][FnwCsv.C_M_PAT2].ToString());
                    isPdPat = System.Convert.ToBoolean(patMatchList[0][FnwCsv.C_M_PAT3]);
                }
                var (isRegisteredPatSuccessful, logStr) = await ProcRegisteredPatAsync(patIDList, patID, m_CsvPatient.Rows[i], result, usingOrderClass, temporaryPat, isPdPat);
                if (!isRegisteredPatSuccessful)
                {
                    // 失敗しても続行
                    DataRow err = error.NewRow();
                    err[(int)ErrorSheetOld.DISP_PATID] = patID;
                    err[(int)ErrorSheetOld.NAME] = m_CsvPatient.Rows[i][(int)SheetSum.C15_氏名_姓_漢字].ToString() + " " + m_CsvPatient.Rows[i][(int)SheetSum.C16_氏名_名_漢字].ToString();
                    err[(int)ErrorSheetOld.SEX] = m_CsvPatient.Rows[i][(int)SheetSum.C20_性別];
                    err[(int)ErrorSheetOld.BIRTHDAY_YEAR] = m_CsvPatient.Rows[i][(int)SheetSum.C21_生年月日_西暦];
                    err[(int)ErrorSheetOld.BIRTHDAY_MONTH] = m_CsvPatient.Rows[i][(int)SheetSum.C22_生年月日_月];
                    err[(int)ErrorSheetOld.BIRTHDAY_DAY] = m_CsvPatient.Rows[i][(int)SheetSum.C23_生年月日_日];

                    error.Rows.Add(err);
                }

                if (false == string.IsNullOrEmpty(logStr))
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, logStr);
                }

                m_Proc.ReportProgress((int)ReportType.ONE_FIN);
            }

            if (false == FnwCsv.Write(dirExportDirectory.SelectedPath + "\\" + Settings.Default.FileSheetSum, result))
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "既存情報保存失敗");
                return (false, isExistError);
            }

            if (0 != error.Rows.Count)
            {
                // エラー患者0件じゃない時はファイル出力
                if (false == FnwCsv.Write(dirExportDirectory.SelectedPath + "\\" + Settings.Default.FileErrorOld, error))
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "既存情報処理エラー患者リスト保存失敗");
                    return (false, isExistError);
                }
                isExistError = true;
            }

            return (true, isExistError);
        }

        /// <summary>
        /// 登録済み患者1人分の処理
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="patIDList">登録済み患者で処理したIDリスト</param>
        /// <param name="patID">処理する患者の内部ID</param>
        /// <param name="csvPatientRow">登録済み患者の情報</param>
        /// <param name="result">DBから取得した情報を格納する先</param>
        /// <param name="logStr">ログ出力が必要なら情報を格納</param>
        /// <param name="usingOrderClass">検査結果前後使用区分</param>
        /// <param name="temporaryPat">年末透析未実施患者のIDリスト</param>
        /// <param name="isPdPat">腹膜透析患者フラグ(true:腹膜透析患者、false:血液透析患者)</param>
        /// <returns>true：成功 false：失敗</returns>
        private async Task<(bool success, string logStr)> ProcRegisteredPatAsync(
            List<long> patIDList, 
            long patID, 
            DataRow csvPatientRow, 
            DataTable result,  
            string usingOrderClass, 
            List<long> temporaryPat,
            bool isPdPat)
        {
            string logStr = null;
            // DBから取得した患者基本情報を格納
            DataRow dbInfo = null;
            DataTable workTable = await StaticFunctions.GetPatBasicInfoAsync(patID);

            if (null == workTable)
            {
                logStr = "患者情報取得失敗";
                return (false, logStr);
            }

            if (1 == workTable.Rows.Count)
            {
                dbInfo = workTable.Rows[0];
                patIDList.Add((long)dbInfo["PATID"]);
            }

            DataRow row = result.NewRow();
            if (null == dbInfo && false == isPdPat)
            {
                // DBにヒットする人が居ない時は情報をそのまま出力
                for (int j = 0; j < (int)SheetSum.件数_; j++)
                {
                    row[j] = csvPatientRow[j];
                }

                //患者区分だけ書き換え
                //区分9:該当者なし
                row[(int)SheetSum.C13_患者区分] = "9";
            }
            else
            {
                //登録済み患者のうち変更項目があった場合
                //備考欄に変更項目を明記する為
                //リストに変更項目を格納する
                string[,] UpdateBefore = new string[(int)SheetSum.件数_,2];
                string[] UpdateAfter = new string[(int)SheetSum.件数_];

                //カラム名称を保存
                StaticFunctions.SetBeforeName(ref UpdateBefore);

                // Excelシートの記述内容をそのままコピー
                //row[(int)SheetSum.C00_管理通番] = csvPatientRow[(int)SheetSum.C00_管理通番];
                row[(int)SheetSum.C13_患者区分] = csvPatientRow[(int)SheetSum.C13_患者区分];
                //row[(int)SheetSum.C01_氏名] = csvPatientRow[(int)SheetSum.C01_氏名];
                //row[(int)SheetSum.C02_事務局使用欄1] = csvPatientRow[(int)SheetSum.C02_事務局使用欄1];
                //row[(int)SheetSum.C03_配布時姓] = csvPatientRow[(int)SheetSum.C03_配布時姓];
                //row[(int)SheetSum.C04_配布時名] = csvPatientRow[(int)SheetSum.C04_配布時名];
                //row[(int)SheetSum.C05_事務局使用欄4] = csvPatientRow[(int)SheetSum.C05_事務局使用欄4];
                //row[(int)SheetSum.C06_事務局使用欄5] = csvPatientRow[(int)SheetSum.C06_事務局使用欄5];
                //row[(int)SheetSum.C07_事務局使用欄6] = csvPatientRow[(int)SheetSum.C07_事務局使用欄6];
                //row[(int)SheetSum.C08_事務局使用欄7] = csvPatientRow[(int)SheetSum.C08_事務局使用欄7];
                //row[(int)SheetSum.C09_事務局使用欄8] = csvPatientRow[(int)SheetSum.C09_事務局使用欄8];
                //row[(int)SheetSum.C10_事務局使用欄9] = csvPatientRow[(int)SheetSum.C10_事務局使用欄9];
                //row[(int)SheetSum.C11_事務局使用欄10] = csvPatientRow[(int)SheetSum.C11_事務局使用欄10];
                //row[(int)SheetSum.C12_事務局使用欄11] = csvPatientRow[(int)SheetSum.C12_事務局使用欄11];
                row[(int)SheetSum.C19_並び替え] = csvPatientRow[(int)SheetSum.C19_並び替え];
                row[(int)SheetSum.C20_性別] = csvPatientRow[(int)SheetSum.C20_性別];
                row[(int)SheetSum.C21_生年月日_西暦] = csvPatientRow[(int)SheetSum.C21_生年月日_西暦];
                row[(int)SheetSum.C22_生年月日_月] = csvPatientRow[(int)SheetSum.C22_生年月日_月];
                row[(int)SheetSum.C23_生年月日_日] = csvPatientRow[(int)SheetSum.C23_生年月日_日];
                row[(int)SheetSum.C25_導入年月_西暦] = csvPatientRow[(int)SheetSum.C25_導入年月_西暦];
                row[(int)SheetSum.C26_導入年月_月] = csvPatientRow[(int)SheetSum.C26_導入年月_月].ToString().Trim();    // 2021年度対応　Trim()を付加。
                row[(int)SheetSum.C28_原疾患] = csvPatientRow[(int)SheetSum.C28_原疾患];
                row[(int)SheetSum.C29_在住県コード] = csvPatientRow[(int)SheetSum.C29_在住県コード];
                row[(int)SheetSum.C30_転入_西暦年] = csvPatientRow[(int)SheetSum.C30_転入_西暦年];
                row[(int)SheetSum.C31_転入_月] = csvPatientRow[(int)SheetSum.C31_転入_月];
                row[(int)SheetSum.C32_転入_転入前の施設コード] = csvPatientRow[(int)SheetSum.C32_転入_転入前の施設コード];
                row[(int)SheetSum.C33_転帰欄_転帰区分] = csvPatientRow[(int)SheetSum.C33_転帰欄_転帰区分];
                row[(int)SheetSum.C34_転帰欄_西暦年] = csvPatientRow[(int)SheetSum.C34_転帰欄_西暦年];
                row[(int)SheetSum.C35_転帰欄_月] = csvPatientRow[(int)SheetSum.C35_転帰欄_月];
                row[(int)SheetSum.C36_転帰欄_転出先の施設コード] = csvPatientRow[(int)SheetSum.C36_転帰欄_転出先の施設コード];
                row[(int)SheetSum.C37_転帰欄_死因コード] = csvPatientRow[(int)SheetSum.C37_転帰欄_死因コード];
                row[(int)SheetSum.C39_備考] = String.Empty;
                row[(int)SheetSum.C40_備考後ろの謎枠] = csvPatientRow[(int)SheetSum.C40_備考後ろの謎枠];
                row[(int)SheetSum.C41_糖尿病の既往] = csvPatientRow[(int)SheetSum.C41_糖尿病の既往];
                row[(int)SheetSum.C42_心筋梗塞の既往] = csvPatientRow[(int)SheetSum.C42_心筋梗塞の既往];
                row[(int)SheetSum.C43_脳出血の既往] = csvPatientRow[(int)SheetSum.C43_脳出血の既往];
                row[(int)SheetSum.C44_脳梗塞の既往] = csvPatientRow[(int)SheetSum.C44_脳梗塞の既往];
                row[(int)SheetSum.C45_四肢切断の有無] = csvPatientRow[(int)SheetSum.C45_四肢切断の有無];
                row[(int)SheetSum.C46_大腿骨頸部骨折の既往] = csvPatientRow[(int)SheetSum.C46_大腿骨頸部骨折の既往];
                row[(int)SheetSum.C47_被嚢性腹膜硬化症の既往] = csvPatientRow[(int)SheetSum.C47_被嚢性腹膜硬化症の既往];
                row[(int)SheetSum.C48_降圧薬使用の有無] = csvPatientRow[(int)SheetSum.C48_降圧薬使用の有無];
                //2025年度対象外項目
                ////2024年度対応 新設項目
                //row[(int)SheetSum.C49_アンジオテンシン受容体ネプリライシン阻害薬使用の有無] = csvPatientRow[(int)SheetSum.C49_アンジオテンシン受容体ネプリライシン阻害薬使用の有無];
                //row[(int)SheetSum.C50_カルシウム拮抗薬使用の有無] = csvPatientRow[(int)SheetSum.C50_カルシウム拮抗薬使用の有無];
                //row[(int)SheetSum.C51_レニンアンジオテンシン系阻害薬使用の有無] = csvPatientRow[(int)SheetSum.C51_レニンアンジオテンシン系阻害薬使用の有無];
                //row[(int)SheetSum.C52_ミネラルコルチコイド受容体拮抗薬使用の有無] = csvPatientRow[(int)SheetSum.C52_ミネラルコルチコイド受容体拮抗薬使用の有無];
                //row[(int)SheetSum.C53_β遮断薬使用の有無] = csvPatientRow[(int)SheetSum.C53_β遮断薬使用の有無];
                //row[(int)SheetSum.C54_その他の降圧薬使用の有無] = csvPatientRow[(int)SheetSum.C54_その他の降圧薬使用の有無];
                //row[(int)SheetSum.C55_利尿薬使用の有無と種類] = csvPatientRow[(int)SheetSum.C55_利尿薬使用の有無と種類];
                ////END
                //END               
                row[(int)SheetSum.C49_喫煙の有無] = csvPatientRow[(int)SheetSum.C49_喫煙の有無];
                //2025年度対象項目
                row[(int)SheetSum.C50_ﾊﾞｽｷｭﾗｰｱｸｾｽ] = csvPatientRow[(int)SheetSum.C50_ﾊﾞｽｷｭﾗｰｱｸｾｽ];
                //END
                row[(int)SheetSum.C51_治療方法] = csvPatientRow[(int)SheetSum.C51_治療方法];
                row[(int)SheetSum.C52_β2ミクログロブリン吸着カラム使用の有無] = csvPatientRow[(int)SheetSum.C52_β2ミクログロブリン吸着カラム使用の有無];
                row[(int)SheetSum.C53_腹膜透析の経験] = csvPatientRow[(int)SheetSum.C53_腹膜透析の経験];
                row[(int)SheetSum.C54_レシピエントとしての腎移植の回数] = csvPatientRow[(int)SheetSum.C54_レシピエントとしての腎移植の回数];
                row[(int)SheetSum.C55_ドナーとしての腎提供の既往] = csvPatientRow[(int)SheetSum.C55_ドナーとしての腎提供の既往];
                row[(int)SheetSum.C56_腎提供年月_西暦年] = csvPatientRow[(int)SheetSum.C56_腎提供年月_西暦年];
                row[(int)SheetSum.C57_腎提供年月_月] = csvPatientRow[(int)SheetSum.C57_腎提供年月_月];
                //2024年度対応 削除項目
                //row[(int)SheetSum.C57_新型コロナの既往] = csvPatientRow[(int)SheetSum.C57_新型コロナの既往];
                //row[(int)SheetSum.C58_2023年中の陽性診断月] = csvPatientRow[(int)SheetSum.C58_2023年中の陽性診断月];
                //END
                row[(int)SheetSum.C58_週透析回数] = csvPatientRow[(int)SheetSum.C58_週透析回数];
                row[(int)SheetSum.C59_透析時間] = csvPatientRow[(int)SheetSum.C59_透析時間];
                row[(int)SheetSum.C60_血流量] = csvPatientRow[(int)SheetSum.C60_血流量];
                row[(int)SheetSum.C61_HDF希釈の方法] = csvPatientRow[(int)SheetSum.C61_HDF希釈の方法];
                row[(int)SheetSum.C62_1セッションあたりの置換液量] = csvPatientRow[(int)SheetSum.C62_1セッションあたりの置換液量];
                row[(int)SheetSum.C63_身長] = csvPatientRow[(int)SheetSum.C63_身長];
                row[(int)SheetSum.C64_体重_透析前] = csvPatientRow[(int)SheetSum.C64_体重_透析前];
                row[(int)SheetSum.C65_体重_透析後] = csvPatientRow[(int)SheetSum.C65_体重_透析後];
                row[(int)SheetSum.C66_透析前収縮期血圧] = csvPatientRow[(int)SheetSum.C66_透析前収縮期血圧];
                row[(int)SheetSum.C67_透析前拡張期血圧] = csvPatientRow[(int)SheetSum.C67_透析前拡張期血圧];
                row[(int)SheetSum.C68_透析前脈拍] = csvPatientRow[(int)SheetSum.C68_透析前脈拍];
                //2025年度対象外項目
                //// 2024年度対応 新設項目
                //row[(int)SheetSum.C75_家庭での血圧測定の有無] = csvPatientRow[(int)SheetSum.C75_家庭での血圧測定の有無];
                //// END
                //END
                row[(int)SheetSum.C69_BUN_透析前] = csvPatientRow[(int)SheetSum.C69_BUN_透析前];
                row[(int)SheetSum.C70_BUN_透析後] = csvPatientRow[(int)SheetSum.C70_BUN_透析後];
                row[(int)SheetSum.C71_クレアチニン濃度_透析前] = csvPatientRow[(int)SheetSum.C71_クレアチニン濃度_透析前];
                row[(int)SheetSum.C72_クレアチニン濃度_透析後] = csvPatientRow[(int)SheetSum.C72_クレアチニン濃度_透析後];
                row[(int)SheetSum.C73_透析前アルブミン濃度] = csvPatientRow[(int)SheetSum.C73_透析前アルブミン濃度];
                row[(int)SheetSum.C74_透析前CRP濃度] = csvPatientRow[(int)SheetSum.C74_透析前CRP濃度];
                row[(int)SheetSum.C75_透析前カルシウム濃度] = csvPatientRow[(int)SheetSum.C75_透析前カルシウム濃度];
                row[(int)SheetSum.C76_透析前リン濃度] = csvPatientRow[(int)SheetSum.C76_透析前リン濃度];
                row[(int)SheetSum.C77_PTH測定法] = csvPatientRow[(int)SheetSum.C77_PTH測定法];
                row[(int)SheetSum.C78_PTH値] = csvPatientRow[(int)SheetSum.C78_PTH値];
                row[(int)SheetSum.C79_透析前ヘモグロビン濃度] = csvPatientRow[(int)SheetSum.C79_透析前ヘモグロビン濃度];
                row[(int)SheetSum.C80_総コレステロール濃度] = csvPatientRow[(int)SheetSum.C80_総コレステロール濃度];
                row[(int)SheetSum.C81_HDL_C濃度] = csvPatientRow[(int)SheetSum.C81_HDL_C濃度];
                //2025年度対象外項目
                //// 2024年度対応　新設項目
                //row[(int)SheetSum.C89_LDL_コレステロール濃度] = csvPatientRow[(int)SheetSum.C89_LDL_コレステロール濃度];
                //row[(int)SheetSum.C90_中性脂肪] = csvPatientRow[(int)SheetSum.C90_中性脂肪];
                //row[(int)SheetSum.C91_スタチン使用の有無] = csvPatientRow[(int)SheetSum.C91_スタチン使用の有無];
                //row[(int)SheetSum.C92_エゼチミブ使用の有無] = csvPatientRow[(int)SheetSum.C92_エゼチミブ使用の有無];
                //row[(int)SheetSum.C93_ペマフィブラート使用の有無] = csvPatientRow[(int)SheetSum.C93_ペマフィブラート使用の有無];
                ////END
                //END
                // 2024年度対応　新設項目
                row[(int)SheetSum.C82_HBs抗原] = csvPatientRow[(int)SheetSum.C82_HBs抗原];
                row[(int)SheetSum.C83_HBs抗体] = csvPatientRow[(int)SheetSum.C83_HBs抗体];
                row[(int)SheetSum.C84_HBc抗体] = csvPatientRow[(int)SheetSum.C84_HBc抗体];
                row[(int)SheetSum.C85_HBV_DNA検査] = csvPatientRow[(int)SheetSum.C85_HBV_DNA検査];
                row[(int)SheetSum.C86_HCV抗体] = csvPatientRow[(int)SheetSum.C86_HCV抗体];
                row[(int)SheetSum.C87_HCV_RNA検査] = csvPatientRow[(int)SheetSum.C87_HCV_RNA検査];
                // END
                // 2024年度対応　削除項目
                //row[(int)SheetSum.C83_有酸素運動_透析中] = csvPatientRow[(int)SheetSum.C83_有酸素運動_透析中];
                //row[(int)SheetSum.C84_有酸素運動_透析中以外] = csvPatientRow[(int)SheetSum.C84_有酸素運動_透析中以外];
                //row[(int)SheetSum.C85_レジスタンス運動_透析中] = csvPatientRow[(int)SheetSum.C85_レジスタンス運動_透析中];
                //row[(int)SheetSum.C86_レジスタンス運動_透析中以外] = csvPatientRow[(int)SheetSum.C86_レジスタンス運動_透析中以外];
                //row[(int)SheetSum.C87_1年以内の栄養指導] = csvPatientRow[(int)SheetSum.C87_1年以内の栄養指導];
                //row[(int)SheetSum.C88_生活活動度] = csvPatientRow[(int)SheetSum.C88_生活活動度];
                //row[(int)SheetSum.C89_悪性腫瘍の新規発症と種類] = csvPatientRow[(int)SheetSum.C89_悪性腫瘍の新規発症と種類];
                //row[(int)SheetSum.C90_深部静脈血栓発症の有無] = csvPatientRow[(int)SheetSum.C90_深部静脈血栓発症の有無];
                //row[(int)SheetSum.C91_肺塞栓症発症の有無] = csvPatientRow[(int)SheetSum.C91_肺塞栓症発症の有無];
                //row[(int)SheetSum.C92_シャント閉塞発症の有無] = csvPatientRow[(int)SheetSum.C92_シャント閉塞発症の有無];
                //row[(int)SheetSum.C93_眼底出血発症の有無] = csvPatientRow[(int)SheetSum.C93_眼底出血発症の有無];
                //row[(int)SheetSum.C94_入院の有無] = csvPatientRow[(int)SheetSum.C94_入院の有無];
                //row[(int)SheetSum.C95_入院理由1] = csvPatientRow[(int)SheetSum.C95_入院理由1];
                //row[(int)SheetSum.C96_入院理由2] = csvPatientRow[(int)SheetSum.C96_入院理由2];
                //row[(int)SheetSum.C97_入院理由3] = csvPatientRow[(int)SheetSum.C97_入院理由3];
                // END
                row[(int)SheetSum.C88_現在施行中のPD歴_月] = csvPatientRow[(int)SheetSum.C88_現在施行中のPD歴_月];
                row[(int)SheetSum.C89_2025年中のPD実施月数_月] = csvPatientRow[(int)SheetSum.C89_2025年中のPD実施月数_月];
                row[(int)SheetSum.C90_PET施行の有無] = csvPatientRow[(int)SheetSum.C90_PET施行の有無];
                row[(int)SheetSum.C91_PET_CR_DP比] = csvPatientRow[(int)SheetSum.C91_PET_CR_DP比];
                row[(int)SheetSum.C92_イコデキストリン透析液使用の有無] = csvPatientRow[(int)SheetSum.C92_イコデキストリン透析液使用の有無];
                row[(int)SheetSum.C93_一日透析液使用量] = csvPatientRow[(int)SheetSum.C93_一日透析液使用量];
                row[(int)SheetSum.C94_残存腎機能] = csvPatientRow[(int)SheetSum.C94_残存腎機能];
                row[(int)SheetSum.C95_一日平均除水量] = csvPatientRow[(int)SheetSum.C95_一日平均除水量];
                row[(int)SheetSum.C96_残腎KT_V] = csvPatientRow[(int)SheetSum.C96_残腎KT_V];
                row[(int)SheetSum.C97_PD_KT_V] = csvPatientRow[(int)SheetSum.C97_PD_KT_V];
                row[(int)SheetSum.C98_APD] = csvPatientRow[(int)SheetSum.C98_APD];
                row[(int)SheetSum.C99_PD透析液交換方法] = csvPatientRow[(int)SheetSum.C99_PD透析液交換方法];
                row[(int)SheetSum.C100_2025年中の腹膜炎罹患回数] = csvPatientRow[(int)SheetSum.C100_2025年中の腹膜炎罹患回数];
                row[(int)SheetSum.C101_2025年中の出口部感染罹患回数] = csvPatientRow[(int)SheetSum.C101_2025年中の出口部感染罹患回数];

                // 腹膜透析患者の場合は処理終了
                // ※FNW+には存在しない情報での比較を行うことになる為、昨年度末の情報をセットして終了.
                if (true == isPdPat)
                {
                    row[(int)SheetSum.C13_患者区分] = "3";
                    row[(int)SheetSum.C14_診察券番号] = csvPatientRow[(int)SheetSum.C14_診察券番号];
                    row[(int)SheetSum.C15_氏名_姓_漢字] = csvPatientRow[(int)SheetSum.C15_氏名_姓_漢字];
                    row[(int)SheetSum.C16_氏名_名_漢字] = csvPatientRow[(int)SheetSum.C16_氏名_名_漢字];
                    row[(int)SheetSum.C17_氏名_姓_カナ] = csvPatientRow[(int)SheetSum.C17_氏名_姓_カナ];
                    row[(int)SheetSum.C18_氏名_名_カナ] = csvPatientRow[(int)SheetSum.C18_氏名_名_カナ];
                    result.Rows.Add(row);
                    logStr = null;
                    return (true,logStr);
                }

                //バックアップの作成
                for (int numLoop = 0; numLoop < (int)SheetSum.C39_備考; numLoop++)
                {
                    UpdateBefore[numLoop,0] = row[numLoop].ToString();
                }

                string buf = null;

                //---------------------------------------------
                // 2015年版対応（エクセルレイアウト対応）START
                //---------------------------------------------
                //診察券番号（DISP_PATIDを出力）
                buf = dbInfo["DISP_PATID"] as string;
                if (false == string.IsNullOrEmpty(buf))
                {
                    Double dPatId = 0;
                    if (double.TryParse(buf, out dPatId))
                    {
                        row[(int)SheetSum.C14_診察券番号] = dPatId;
                    }
                    else
                    {
                        row[(int)SheetSum.C14_診察券番号] = buf;
                    }
                }

                //氏名
                buf = dbInfo["NAME"] as string;
                if (false == string.IsNullOrEmpty(buf))
                {
                    buf = buf.Replace(" ", "　");
                    string[] splitName = buf.Split('　');
                    row[(int)SheetSum.C15_氏名_姓_漢字] = splitName[0];

                    string strName = "";
                    if (splitName.Length >= 2)
                    {
                        for (int i = 1; i < splitName.Length; i++)
                        {
                            strName += splitName[i];
                        }
                    }
                    row[(int)SheetSum.C16_氏名_名_漢字] = strName;
                }
                buf = dbInfo["NAME_KANA"] as string;
                if (false == string.IsNullOrEmpty(buf))
                {
                    buf = buf.Replace(" ", "　");
                    string[] splitName = buf.Split('　');
                    row[(int)SheetSum.C17_氏名_姓_カナ] = splitName[0];

                    string strName = "";
                    for (int i = 1; i < splitName.Length; i++)
                    {
                        strName += splitName[i];
                    }
                    row[(int)SheetSum.C18_氏名_名_カナ] = strName;
                }
                //---------------------------------------------
                // 2015年版対応（エクセルレイアウト対応）END
                //---------------------------------------------

                //患者区分をセット
                //区分3:登録済み患者
                row[(int)SheetSum.C13_患者区分] = "3";

                //2017年度対応：前年度の不適合修正(並び替え)
                // 登録済み患者情報に姓カタカナがある場合は、そこから並び替え文字を作成する。
                //buf = row[(int)SheetSum.C05_事務局使用欄4] as string;
                //if (false == string.IsNullOrEmpty(buf))
                //{
                //    buf = Strings.StrConv(buf, VbStrConv.Katakana, 0);
                //    buf = Strings.StrConv(buf, VbStrConv.Narrow, 0);
                //    row[(int)SheetSum.C19_並び替え] = buf[0].ToString();
                //}
                // 並び替え文字がない場合は、DBから取得した患者情報から並び替え文字を作成する。
                if (string.IsNullOrEmpty(row[(int)SheetSum.C19_並び替え] as string))
                {
                    buf = dbInfo["NAME_KANA"] as string;
                    if (false == string.IsNullOrEmpty(buf))
                    {
                        buf = Strings.StrConv(buf, VbStrConv.Katakana, 0);
                        buf = Strings.StrConv(buf, VbStrConv.Narrow, 0);
                        row[(int)SheetSum.C19_並び替え] = buf[0].ToString();
                    }
                }

                //2016年度版対応：前年度の不適合修正
                // FNWにデータが存在している場合、エクセルシートを上書きする
                // FNWにデータが存在していない場合、エクセルシートには上書きしない
                if (false == String.IsNullOrEmpty(dbInfo["SEX_CD"] as string))
                {
                    switch (dbInfo["SEX_CD"] as string)
                    {
                        case "0":
                            row[(int)SheetSum.C20_性別] = "M";
                            break;
                        case "1":
                            row[(int)SheetSum.C20_性別] = "F";
                            break;
                    }
                }

                //2016年度版対応：前年度の不適合修正
                // FNWにデータが存在している場合、エクセルシートを上書きする
                // FNWにデータが存在していない場合、エクセルシートには上書きしない
                if (false == String.IsNullOrEmpty(dbInfo["BIRTHDAY"] as string))
                {
                    StaticFunctions.SetBirthday(
                        dbInfo["BIRTHDAY"] as string,
                        ref row,
                        (int)SheetSum.C21_生年月日_西暦,
                        (int)SheetSum.C22_生年月日_月,
                        (int)SheetSum.C23_生年月日_日);
                }

                DateTime day;
                DateTime day1;

                day = StaticFunctions.YyyyMmDdToDay(dbInfo["DIAL_START_DATE"] as string);
                if (day >= Settings.Default.PeriodEnd)
                {
                    day = DateTime.MinValue;
                }
                //透析導入日の取得（転入出履歴より）
                DateTime initiationDate = await　StaticFunctions.GetPatUniqueInitDateAsync(patID);
                day1 = StaticFunctions.YyyyMmDdToDay(initiationDate.ToString("yyyyMMdd"));

                // 両方とも有効な日付かどうかを確認
                DateTime selectedDay = DateTime.MinValue;

                // 両方とも有効な日付かどうかを確認して古い方を選択
                if (day != DateTime.MinValue && day1 != DateTime.MinValue)
                {
                    selectedDay = day < day1 ? day : day1;
                }
                else if (day != DateTime.MinValue)
                {
                    selectedDay = day;
                }
                else if (day1 != DateTime.MinValue)
                {
                    selectedDay = day1;
                }

                //選択された日付をセット
                if (selectedDay != DateTime.MinValue)
                {
                    row[(int)SheetSum.C25_導入年月_西暦] = selectedDay.ToString("yyyy");
                    row[(int)SheetSum.C26_導入年月_月] = selectedDay.Month;
                }
                else
                {
                    // エクセルシートがnull且つFNWにデータがない場合、9999 99 を書き込む
                    if (true == String.IsNullOrEmpty(csvPatientRow[(int)SheetSum.C25_導入年月_西暦] as string) &&
                        true == String.IsNullOrEmpty(csvPatientRow[(int)SheetSum.C26_導入年月_月] as string))
                    {
                        row[(int)SheetSum.C25_導入年月_西暦] = "9999";
                        row[(int)SheetSum.C26_導入年月_月] = "99";
                    }
                }

                // VB-Reportでは[**]で始まる値を変数として扱う仕様となっている為、先頭に[']を付与することで出力値とする([']はExcel出力時に消えます)
                row[(int)SheetSum.C30_転入_西暦年] = "****";
                row[(int)SheetSum.C31_転入_月] = "**";
                row[(int)SheetSum.C32_転入_転入前の施設コード] = "******";

                //2016年度版対応：前年度の不適合修正
                // FNWにデータが存在している場合、エクセルシートを上書きする
                // FNWにデータが存在していない場合、エクセルシートには上書きしない
                if (false == String.IsNullOrEmpty(dbInfo["BASE_DISEASE_CD"] as string))
                {
                    // 2021年度対応　原疾患で「210：不明」が選択されている場合に昨年の原疾患を上書きしないに対応
                    //row[(int)SheetSum.C28_原疾患] = FrmStatistics.ConvDisease(dbInfo["BASE_DISEASE_CD"] as string);
                    string convDiseaseCd = FrmStatistics.ConvDisease((int)dbInfo["BASE_DISEASE_CD"]);
                    if (convDiseaseCd.Equals(FnwCsv.C_M_DIS2_Unknown) == false || String.IsNullOrEmpty(row[(int)SheetSum.C28_原疾患] as string) == true)
                    {
                        row[(int)SheetSum.C28_原疾患] = convDiseaseCd;
                    }
                }

                //2016年度版対応：前年度の不適合修正
                // FNWにデータが存在している場合、エクセルシートを上書きする
                // FNWにデータが存在していない場合、エクセルシートには上書きしない
                var zipCode = await StaticFunctions.GetZipCodeAsync((long)dbInfo["PATID"]);
                if (false == String.IsNullOrEmpty(zipCode))
                {
                    row[(int)SheetSum.C29_在住県コード] = zipCode;
                }
 
                //2014年版修正（転出・転帰パターン対応）
                //SetOutInfo内で死因コード入れるところもまとめたほうがいい 2012.12.02
                string pat_inoutCd = await StaticFunctions.GetInoutCircumstanceAsync((long)dbInfo["PATID"]);
                if (!(pat_inoutCd.Equals("1") || pat_inoutCd.Equals("4")))
                {
                    var (sccess, updateRow) = await StaticFunctions.SetOutInfoAsync(
                        (long)dbInfo["PATID"],
                         row,
                        (int)SheetSum.C33_転帰欄_転帰区分,
                        (int)SheetSum.C34_転帰欄_西暦年,
                        (int)SheetSum.C35_転帰欄_月,
                        (int)SheetSum.C36_転帰欄_転出先の施設コード,
                        (int)SheetSum.C37_転帰欄_死因コード,
                        (int)SheetSum.C51_治療方法,
                        dbInfo["DIE_DATE"].ToString(),
                        dbInfo["DIE_CD"].ToString()
                        );
                    if (!sccess)
                    {
                        logStr = "転出情報取得失敗";
                        return (false,logStr);
                    }
                    else
                    {
                        row = updateRow;
                    }
                }

                //2013年版修正(「糖尿病の既往」自動設定)
                if ("B" != row[(int)SheetSum.C41_糖尿病の既往] as string)
                {
                    if (("1" == dbInfo["DIABETES"] as string) || (await StaticFunctions.IsDiabetesAsync((long)dbInfo["PATID"])))
                    {
                        row[(int)SheetSum.C41_糖尿病の既往] = "B";
                    }
                }
                
                // 最終透析
                string dNo = await StaticFunctions.GetDialysisNoAsync((long)dbInfo["PATID"]);
                if (null == dNo)
                {
                    logStr = "透析番号取得失敗";
                    return (false, logStr);
                }

                //2025年度対象項目
                if (false == string.IsNullOrEmpty(dNo))
                {
                    buf = await StaticFunctions.GetVaAsync(long.Parse(dNo));
                    if (null == buf)
                    {
                        m_Proc.ReportProgress((int)ReportType.LOG, "バスキュラーアクセス取得失敗");
                        return (false, logStr);
                    }
                    row[(int)SheetSum.C50_ﾊﾞｽｷｭﾗｰｱｸｾｽ] = buf;
                }
                //END

                if (false == string.IsNullOrEmpty(dNo))
                {
                    buf = await StaticFunctions.GetTreatItemAsync(long.Parse(dNo));
                    if (null == buf)
                    {
                        logStr = "治療方法取得失敗";
                        return (false, logStr);
                    }
                    //2014年版修正（離脱・移植の追加）
                    //透析離脱（70）以外の場合
                    if (!row[(int)SheetSum.C51_治療方法].ToString().Equals("70"))
                    {
                        //【2022年度版対応】治療方法のECUMをExcelへ出力しない。(Start)
                        if (buf.Equals("YY"))
                        {
                            row[(int)SheetSum.C51_治療方法] = string.Empty;
                        }
                        else
                        {
                            row[(int)SheetSum.C51_治療方法] = buf;
                        }
                        //row[(int)SheetSum.C50_治療方法] = buf;
                        //【2022年度版対応】治療方法のECUMをExcelへ出力しない。(End)
                    }

                    buf = await StaticFunctions.GetDialysisWeeklyCountAsync(long.Parse(dNo));
                    if (null == buf)
                    {
                        logStr = "週透析回数取得失敗";
                        return (false, logStr);
                    }
                    row[(int)SheetSum.C58_週透析回数] = buf;

                    buf = await StaticFunctions.GetDialysisTimeAsync(long.Parse(dNo));
                    if (null == buf)
                    {
                        m_Proc.ReportProgress((int)ReportType.LOG, "透析時間取得失敗");
                    }
                    row[(int)SheetSum.C59_透析時間] = buf;

                    buf = await StaticFunctions .GetDialysisBloodAsync(long.Parse(dNo));
                    if (null == buf)
                    {
                        logStr = "透析血流量取得失敗";
                        return (false, logStr);
                    }
                    row[(int)SheetSum.C60_血流量] = buf;

                    //2013年版修正(「HDF希釈の方法」「1セッションあたりの置換液量」FNWデータ取得化)
                    //治療方法がHDFの場合のみ設定
                    switch (row[(int)SheetSum.C51_治療方法] as string)
                    {
                        case "10":  //血液透析濾過(ボトル型HDF）
                        case "11":  //血液透析濾過(オンラインHDF）
                        case "12":  //血液透析濾過(プッシュプルHDF）
                        case "13":  //アセテートフリーバイオフィルトレーション
                            buf = await StaticFunctions.GetDilutionAsync(long.Parse(dNo));
                            if (null == buf)
                            {
                                logStr = "HDF希釈の方法取得失敗";
                                return (false, logStr);
                            }
                            row[(int)SheetSum.C61_HDF希釈の方法] = buf;

                            buf = await StaticFunctions.GetFluidReplacementAsync(long.Parse(dNo));
                            if (null == buf)
                            {
                                logStr = "1セッションあたりの置換液量取得失敗";
                                return (false, logStr);
                            }
                            row[(int)SheetSum.C62_1セッションあたりの置換液量] = buf;

                            break;

                        // 2019年度対応
                        case "14":  //間歇的血液透析濾過(IHDF）
                            row[(int)SheetSum.C61_HDF希釈の方法] = "D";

                            break;
                    }

                    var(sccess, updatedRow) = await  StaticFunctions.getBpAndPulseAsync(
                                                    long.Parse(dNo),
                                                     row,
                                                    (int)SheetSum.C66_透析前収縮期血圧,
                                                    (int)SheetSum.C67_透析前拡張期血圧,
                                                    (int)SheetSum.C68_透析前脈拍
                                                  );
                    if (sccess)
                    {
                        row = updatedRow;
                    }
                }

                //（身長）
                string height = await StaticFunctions.GetHeightAsync(patID);
                if (!height.Equals("false"))
                {
                    row[(int)SheetSum.C63_身長] = height;
                }

                //第１透析日データ取得
                DataTable dtFirstDialysisDay = await StaticFunctions.GetFirstDialysisDayAsync((long)dbInfo["PATID"]);
  
                if (null == dtFirstDialysisDay)
                {
                    logStr = "第１透析日データ取得失敗";
                    return (false, logStr);
                }

                // 2020年版対応（血圧の取得変更対応）
                string dNo2 = String.Empty;
                //【2022年度版対応】2021年度までの未対応分の改修
                DateTime examDate = DateTime.MinValue;

                var (isWeightSetSuccess, updatedRowWeight, updatedDialysisNo, updatedExamDate) = await StaticFunctions.SetWeightAsync(
                    (long)dbInfo["PATID"],
                    row,
                    //2013年版修正(検査結果の第１透析日判定機能を追加)
                    dtFirstDialysisDay,
                    (int)SheetSum.C64_体重_透析前,
                    (int)SheetSum.C65_体重_透析後,
                    (int)SheetSum.C69_BUN_透析前,
                    (int)SheetSum.C70_BUN_透析後,
                    //2013年版修正(クレアチニン濃度も体重とセットで格納するように変更)
                    (int)SheetSum.C71_クレアチニン濃度_透析前,
                    (int)SheetSum.C72_クレアチニン濃度_透析後,
                    // 2015年版検査結果前後対応
                    usingOrderClass,
                    // 2020年版対応（血圧の取得変更対応）
                    dNo2,
                    //【2022年度版対応】2021年度までの未対応分の改修
                    examDate
                    );
                if (isWeightSetSuccess)
                {
                    row = updatedRowWeight;
                    dNo2 = updatedDialysisNo;
                    examDate = updatedExamDate;
                }
                else
                {
                    logStr = "体重/BUN情報取得失敗";
                    return (false, logStr);
                }

                // 2020年版対応（血圧の取得変更対応）
                if (dNo != dNo2)
                {
                    var (isBpAndPulseSuccess, updatedRowPulse) =  await StaticFunctions.getBpAndPulseAsync(
                                                    long.Parse(dNo),
                                                    row,
                                                    (int)SheetSum.C66_透析前収縮期血圧,
                                                    (int)SheetSum.C67_透析前拡張期血圧,
                                                    (int)SheetSum.C68_透析前脈拍
                                                  );
                    if (isBpAndPulseSuccess)
                    {
                        row = updatedRowPulse;
                    }
                }

                //検査時の項目の為、特殊血液浄化は関係なし。
                var (successSetOtherExam, updatedRowSetOtherExam) = await StaticFunctions.SetOtherExamAsync(
                    (long)dbInfo["PATID"],
                    row,
                    //2013年版修正(検査結果の第１透析日判定機能を追加)
                    dtFirstDialysisDay,
                    (int)SheetSum.C75_透析前カルシウム濃度,
                    (int)SheetSum.C76_透析前リン濃度,
                    (int)SheetSum.C73_透析前アルブミン濃度,
                    (int)SheetSum.C74_透析前CRP濃度,
                    (int)SheetSum.C79_透析前ヘモグロビン濃度,
                    (int)SheetSum.C78_PTH値,
                    (int)SheetSum.C80_総コレステロール濃度,
                    (int)SheetSum.C81_HDL_C濃度,
                    //2025年度対象外項目
                    //(int)SheetSum.C89_LDL_コレステロール濃度,
                    //(int)SheetSum.C90_中性脂肪,
                    //END
                    usingOrderClass, //2015年版：検査結果前後対応
                    examDate //【2022年度版対応】2021年度までの未対応分の改修
                    );
                if (!successSetOtherExam)
                {
                    logStr = "検査結果取得失敗";
                    return (false, logStr);
                }
                row = updatedRowSetOtherExam;

                //患者感染症情報格納処理（2024年度対応　新設項目）
                var (successSetfect, updatedRowfect) = await StaticFunctions.SetInfectAsync(
                    (long)dbInfo["PATID"],
                    row,
                    (int)SheetSum.C82_HBs抗原,
                    (int)SheetSum.C83_HBs抗体,
                    (int)SheetSum.C84_HBc抗体,
                    (int)SheetSum.C85_HBV_DNA検査,
                    (int)SheetSum.C86_HCV抗体,
                    (int)SheetSum.C87_HCV_RNA検査
                    );
                if (!successSetfect)
                {
                    logStr = "患者感染症取得失敗";
                    return (false, logStr);
                }
                row = updatedRowfect;

                //最新のデータを取得
                for (int numLoop = 0; numLoop < (int)SheetSum.C39_備考; numLoop++)
                {
                    UpdateAfter[numLoop] = row[numLoop].ToString();
                }
                if (!StaticFunctions.ChangeUpdate(UpdateBefore, UpdateAfter, ref row, (int)SheetSum.C39_備考, (int)SheetSum.C38_患者情報変更訂正区分))
                {
                    logStr = "備考設定失敗";
                    return (false, logStr);
                }
                // 年末透析未実施患者を備考に設定
                if (temporaryPat.Contains(patID) == true)
                {
                    if (string.IsNullOrEmpty(row[(int)SheetSum.C39_備考].ToString()))
                    {
                        row[(int)SheetSum.C39_備考] = "12月透析未実施";
                    }
                    else
                    {
                        row[(int)SheetSum.C39_備考] = row[(int)SheetSum.C39_備考] + ", 12月透析未実施";
                    }
                    // 糖尿病の既往以降の項目を出力しない
                    // 2020年度修正(12月に透析実施が存在しない患者のデータクリア)（Start）
                    row = DataClear(row);
                    // 2020年度修正(12月に透析実施が存在しない患者のデータクリア)（End）
                }
            }

            result.Rows.Add(row);
            logStr = null;
            return (false, logStr);
        }

        /// <summary>
        /// 2020年度修正
        /// 糖尿病の既往以降のデータをクリアする.
        /// </summary>
        /// <param name="row">対象のDataRow</param>
        /// <returns></returns>
        private static DataRow DataClear(DataRow row)
        {
            row[(int)SheetSum.C41_糖尿病の既往] = String.Empty;
            row[(int)SheetSum.C42_心筋梗塞の既往] = String.Empty;
            row[(int)SheetSum.C43_脳出血の既往] = String.Empty;
            row[(int)SheetSum.C44_脳梗塞の既往] = String.Empty;
            row[(int)SheetSum.C45_四肢切断の有無] = String.Empty;
            row[(int)SheetSum.C46_大腿骨頸部骨折の既往] = String.Empty;
            row[(int)SheetSum.C47_被嚢性腹膜硬化症の既往] = String.Empty;
            row[(int)SheetSum.C48_降圧薬使用の有無] = String.Empty;
            //2025年度対象外項目
            //// 2024年度対応  新設項目
            //row[(int)SheetSum.C49_アンジオテンシン受容体ネプリライシン阻害薬使用の有無] = String.Empty;
            //row[(int)SheetSum.C50_カルシウム拮抗薬使用の有無] = String.Empty;
            //row[(int)SheetSum.C51_レニンアンジオテンシン系阻害薬使用の有無] = String.Empty;
            //row[(int)SheetSum.C52_ミネラルコルチコイド受容体拮抗薬使用の有無] = String.Empty;
            //row[(int)SheetSum.C53_β遮断薬使用の有無] = String.Empty;
            //row[(int)SheetSum.C54_その他の降圧薬使用の有無] = String.Empty;
            //row[(int)SheetSum.C55_利尿薬使用の有無と種類] = String.Empty;
            //// END
            //END
            row[(int)SheetSum.C49_喫煙の有無] = String.Empty;
            //2025年度対象項目
            row[(int)SheetSum.C50_ﾊﾞｽｷｭﾗｰｱｸｾｽ] = String.Empty;
            //END
            //【2022年度版対応】治療方法のECUMをExcelへ出力しない。(Start)
            if (!row[(int)SheetSum.C51_治療方法].ToString().Equals("YY"))
            {
                row[(int)SheetSum.C51_治療方法] = String.Empty;
            }
            row[(int)SheetSum.C52_β2ミクログロブリン吸着カラム使用の有無] = String.Empty;
            row[(int)SheetSum.C53_腹膜透析の経験] = String.Empty;
            row[(int)SheetSum.C54_レシピエントとしての腎移植の回数] = String.Empty;
            row[(int)SheetSum.C55_ドナーとしての腎提供の既往] = String.Empty;
            row[(int)SheetSum.C56_腎提供年月_西暦年] = String.Empty;
            row[(int)SheetSum.C57_腎提供年月_月] = String.Empty;
            // 2024年度対応  削除項目
            //row[(int)SheetSum.C57_新型コロナの既往] = String.Empty;
            //row[(int)SheetSum.C58_2023年中の陽性診断月] = String.Empty;
            // END
            row[(int)SheetSum.C58_週透析回数] = String.Empty;
            row[(int)SheetSum.C59_透析時間] = String.Empty;
            row[(int)SheetSum.C60_血流量] = String.Empty;
            row[(int)SheetSum.C61_HDF希釈の方法] = String.Empty;
            row[(int)SheetSum.C62_1セッションあたりの置換液量] = String.Empty;
            row[(int)SheetSum.C63_身長] = String.Empty;
            row[(int)SheetSum.C64_体重_透析前] = String.Empty;
            row[(int)SheetSum.C65_体重_透析後] = String.Empty;
            row[(int)SheetSum.C66_透析前収縮期血圧] = String.Empty;
            row[(int)SheetSum.C67_透析前拡張期血圧] = String.Empty;
            row[(int)SheetSum.C68_透析前脈拍] = String.Empty;
            row[(int)SheetSum.C69_BUN_透析前] = String.Empty;
            row[(int)SheetSum.C70_BUN_透析後] = String.Empty;
            row[(int)SheetSum.C71_クレアチニン濃度_透析前] = String.Empty;
            row[(int)SheetSum.C72_クレアチニン濃度_透析後] = String.Empty;
            row[(int)SheetSum.C73_透析前アルブミン濃度] = String.Empty;
            row[(int)SheetSum.C74_透析前CRP濃度] = String.Empty;
            row[(int)SheetSum.C75_透析前カルシウム濃度] = String.Empty;
            row[(int)SheetSum.C76_透析前リン濃度] = String.Empty;
            row[(int)SheetSum.C77_PTH測定法] = String.Empty;
            row[(int)SheetSum.C78_PTH値] = String.Empty;
            row[(int)SheetSum.C79_透析前ヘモグロビン濃度] = String.Empty;
            row[(int)SheetSum.C80_総コレステロール濃度] = String.Empty;
            row[(int)SheetSum.C81_HDL_C濃度] = String.Empty;
            // 2024年度対応  削除項目
            //row[(int)SheetSum.C83_有酸素運動_透析中] = String.Empty;
            //row[(int)SheetSum.C84_有酸素運動_透析中以外] = String.Empty;
            //row[(int)SheetSum.C85_レジスタンス運動_透析中] = String.Empty;
            //row[(int)SheetSum.C86_レジスタンス運動_透析中以外] = String.Empty;
            //row[(int)SheetSum.C87_1年以内の栄養指導] = String.Empty;
            //row[(int)SheetSum.C88_生活活動度] = String.Empty;
            //row[(int)SheetSum.C89_悪性腫瘍の新規発症と種類] = String.Empty;
            //row[(int)SheetSum.C90_深部静脈血栓発症の有無] = String.Empty;
            //row[(int)SheetSum.C91_肺塞栓症発症の有無] = String.Empty;
            //row[(int)SheetSum.C92_シャント閉塞発症の有無] = String.Empty;
            //row[(int)SheetSum.C93_眼底出血発症の有無] = String.Empty;
            //row[(int)SheetSum.C94_入院の有無] = String.Empty;
            //row[(int)SheetSum.C95_入院理由1] = String.Empty;
            //row[(int)SheetSum.C96_入院理由2] = String.Empty;
            //row[(int)SheetSum.C97_入院理由3] = String.Empty;
            // END
            //2025年度対象外項目
            //// 2024年度対応　新設項目
            //row[(int)SheetSum.C89_LDL_コレステロール濃度] = String.Empty;
            //row[(int)SheetSum.C90_中性脂肪] = String.Empty;
            //row[(int)SheetSum.C91_スタチン使用の有無] = String.Empty;
            //row[(int)SheetSum.C92_エゼチミブ使用の有無] = String.Empty;
            //row[(int)SheetSum.C93_ペマフィブラート使用の有無] = String.Empty;
            //// END
            //END
            // 2024年度対応　新設項目
            row[(int)SheetSum.C82_HBs抗原] = String.Empty;
            row[(int)SheetSum.C83_HBs抗体] = String.Empty;
            row[(int)SheetSum.C84_HBc抗体] = String.Empty;
            row[(int)SheetSum.C85_HBV_DNA検査] = String.Empty;
            row[(int)SheetSum.C86_HCV抗体] = String.Empty;
            row[(int)SheetSum.C87_HCV_RNA検査] = String.Empty;
            // END
            row[(int)SheetSum.C88_現在施行中のPD歴_月] = String.Empty;
            row[(int)SheetSum.C89_2025年中のPD実施月数_月] = String.Empty;
            row[(int)SheetSum.C90_PET施行の有無] = String.Empty;
            row[(int)SheetSum.C91_PET_CR_DP比] = String.Empty;
            row[(int)SheetSum.C92_イコデキストリン透析液使用の有無] = String.Empty;
            row[(int)SheetSum.C93_一日透析液使用量] = String.Empty;
            row[(int)SheetSum.C94_残存腎機能] = String.Empty;
            row[(int)SheetSum.C95_一日平均除水量] = String.Empty;
            row[(int)SheetSum.C96_残腎KT_V] = String.Empty;
            row[(int)SheetSum.C97_PD_KT_V] = String.Empty;
            row[(int)SheetSum.C98_APD] = String.Empty;
            row[(int)SheetSum.C99_PD透析液交換方法] = String.Empty;
            row[(int)SheetSum.C100_2025年中の腹膜炎罹患回数] = String.Empty;
            row[(int)SheetSum.C101_2025年中の出口部感染罹患回数] = String.Empty;
            return row;
        }

        /// <summary>
        /// 2012.11.22 k.kudou, 2014年版修正（戻り値の型をbool→stringに変更）
        /// 統合シート用取得関数
        /// </summary>
        /// <param name="patID">患者Id</param>
        /// <param name="row">DataRow</param>
        /// <param name="temporaryPat">年末透析未実施患者のIDリスト</param>
        /// <returns></returns>
        private async Task<(string success, DataRow row)> ProcSheetSumAsync(long patID, DataRow row, List<long> temporaryPat)
        {
            DataRow dbInfo;
            DataTable workTable = await StaticFunctions.GetPatBasicInfoAsync(patID);

            if (null == workTable)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "患者情報取得失敗");
                return ("false", row);
            }

            if (1 != workTable.Rows.Count)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "患者情報取得失敗");
                return ("false", row);
            }

            string buf = null;

            // 対象外
            //2015年版対応（Excelレイアウト変更による）START
            //row[(int)SheetSum.C00_管理通番] = "";
            //row[(int)SheetSum.C02_事務局使用欄1] = "";
            //row[(int)SheetSum.C03_配布時姓] = "";
            //row[(int)SheetSum.C04_配布時名] = "";
            //row[(int)SheetSum.C05_事務局使用欄4] = "";
            //row[(int)SheetSum.C06_事務局使用欄5] = "";
            //row[(int)SheetSum.C07_事務局使用欄6] = "";
            //row[(int)SheetSum.C08_事務局使用欄7] = "";
            //row[(int)SheetSum.C09_事務局使用欄8] = "";
            //row[(int)SheetSum.C10_事務局使用欄9] = "";
            //row[(int)SheetSum.C11_事務局使用欄10] = "";
            //row[(int)SheetSum.C12_事務局使用欄11] = "";
            row[(int)SheetSum.C14_診察券番号] = "";
            row[(int)SheetSum.C15_氏名_姓_漢字] = "";
            row[(int)SheetSum.C16_氏名_名_漢字] = "";
            row[(int)SheetSum.C17_氏名_姓_カナ] = "";
            row[(int)SheetSum.C18_氏名_名_カナ] = "";
            row[(int)SheetSum.C24_12月末の年齢] = "";
            row[(int)SheetSum.C27_12月末の透析歴] = "";
            row[(int)SheetSum.C38_患者情報変更訂正区分] = "";
            row[(int)SheetSum.C39_備考] = "";
            row[(int)SheetSum.C40_備考後ろの謎枠] = "";
            row[(int)SheetSum.C42_心筋梗塞の既往] = "";
            row[(int)SheetSum.C43_脳出血の既往] = "";
            row[(int)SheetSum.C44_脳梗塞の既往] = "";
            row[(int)SheetSum.C45_四肢切断の有無] = "";
            row[(int)SheetSum.C46_大腿骨頸部骨折の既往] = "";
            row[(int)SheetSum.C47_被嚢性腹膜硬化症の既往] = "";
            row[(int)SheetSum.C48_降圧薬使用の有無] = "";
            //2025年度対象外項目
            //// 2024年度対応　新設項目
            //row[(int)SheetSum.C49_アンジオテンシン受容体ネプリライシン阻害薬使用の有無] = "";
            //row[(int)SheetSum.C50_カルシウム拮抗薬使用の有無] = "";
            //row[(int)SheetSum.C51_レニンアンジオテンシン系阻害薬使用の有無] = "";
            //row[(int)SheetSum.C52_ミネラルコルチコイド受容体拮抗薬使用の有無] = "";
            //row[(int)SheetSum.C53_β遮断薬使用の有無] = "";
            //row[(int)SheetSum.C54_その他の降圧薬使用の有無] = "";
            //row[(int)SheetSum.C55_利尿薬使用の有無と種類] = "";
            //// END
            //END
            row[(int)SheetSum.C49_喫煙の有無] = "";
            //2025年度対象項目
            row[(int)SheetSum.C50_ﾊﾞｽｷｭﾗｰｱｸｾｽ] = "";
            //END
            row[(int)SheetSum.C52_β2ミクログロブリン吸着カラム使用の有無] = "";
            row[(int)SheetSum.C53_腹膜透析の経験] = "";
            row[(int)SheetSum.C54_レシピエントとしての腎移植の回数] = "";
            row[(int)SheetSum.C55_ドナーとしての腎提供の既往] = "";
            row[(int)SheetSum.C56_腎提供年月_西暦年] = "";
            row[(int)SheetSum.C57_腎提供年月_月] = "";
            // 2024年度対応　削除項目
            //row[(int)SheetSum.C57_新型コロナの既往] = "";
            //row[(int)SheetSum.C58_2023年中の陽性診断月] = "";
            // END
            row[(int)SheetSum.C58_週透析回数] = "";
            row[(int)SheetSum.C59_透析時間] = "";
            row[(int)SheetSum.C60_血流量] = ""; 
            row[(int)SheetSum.C61_HDF希釈の方法] = "";
            row[(int)SheetSum.C62_1セッションあたりの置換液量] = "";
            row[(int)SheetSum.C63_身長] = "";
            row[(int)SheetSum.C64_体重_透析前] = "";
            row[(int)SheetSum.C65_体重_透析後] = "";
            row[(int)SheetSum.C66_透析前収縮期血圧] = "";
            row[(int)SheetSum.C67_透析前拡張期血圧] = "";
            row[(int)SheetSum.C68_透析前脈拍] = "";
            //2025年度対象外項目
            //// 2024年度対応　新設項目
            //row[(int)SheetSum.C75_家庭での血圧測定の有無] = "";
            //// END
            //END
            row[(int)SheetSum.C69_BUN_透析前] = "";
            row[(int)SheetSum.C70_BUN_透析後] = "";
            row[(int)SheetSum.C71_クレアチニン濃度_透析前] = "";
            row[(int)SheetSum.C72_クレアチニン濃度_透析後] = "";
            row[(int)SheetSum.C73_透析前アルブミン濃度] = "";
            row[(int)SheetSum.C74_透析前CRP濃度] = "";
            row[(int)SheetSum.C75_透析前カルシウム濃度] = "";
            row[(int)SheetSum.C76_透析前リン濃度] = "";
            row[(int)SheetSum.C77_PTH測定法] = "";
            row[(int)SheetSum.C78_PTH値] = "";
            row[(int)SheetSum.C79_透析前ヘモグロビン濃度] = "";
            row[(int)SheetSum.C80_総コレステロール濃度] = "";
            row[(int)SheetSum.C81_HDL_C濃度] = "";
            //2025年度対象外項目
            //// 2024年度対応　新設項目
            //row[(int)SheetSum.C89_LDL_コレステロール濃度] = "";
            //row[(int)SheetSum.C90_中性脂肪] = "";
            //row[(int)SheetSum.C91_スタチン使用の有無] = "";
            //row[(int)SheetSum.C92_エゼチミブ使用の有無] = "";
            //row[(int)SheetSum.C93_ペマフィブラート使用の有無] = "";
            //// END
            //END
            // 2024年度対応　新設項目
            row[(int)SheetSum.C82_HBs抗原] = "";
            row[(int)SheetSum.C83_HBs抗体] = "";
            row[(int)SheetSum.C84_HBc抗体] = "";
            row[(int)SheetSum.C85_HBV_DNA検査] = "";
            row[(int)SheetSum.C86_HCV抗体] = "";
            row[(int)SheetSum.C87_HCV_RNA検査] = "";
            // END
            // 2024年度対応　削除項目
            //row[(int)SheetSum.C83_有酸素運動_透析中] = "";
            //row[(int)SheetSum.C84_有酸素運動_透析中以外] = "";
            //row[(int)SheetSum.C85_レジスタンス運動_透析中] = "";
            //row[(int)SheetSum.C86_レジスタンス運動_透析中以外] = "";
            //row[(int)SheetSum.C87_1年以内の栄養指導] = "";
            //row[(int)SheetSum.C88_生活活動度] = "";
            //row[(int)SheetSum.C89_悪性腫瘍の新規発症と種類] = "";
            //row[(int)SheetSum.C90_深部静脈血栓発症の有無] = "";
            //row[(int)SheetSum.C91_肺塞栓症発症の有無] = "";
            //row[(int)SheetSum.C92_シャント閉塞発症の有無] = "";
            //row[(int)SheetSum.C93_眼底出血発症の有無] = "";
            //row[(int)SheetSum.C94_入院の有無] = "";
            //row[(int)SheetSum.C95_入院理由1] = "";
            //row[(int)SheetSum.C96_入院理由2] = "";
            //row[(int)SheetSum.C97_入院理由3] = "";
            // END
            row[(int)SheetSum.C88_現在施行中のPD歴_月] = "";
            row[(int)SheetSum.C89_2025年中のPD実施月数_月] = "";
            row[(int)SheetSum.C90_PET施行の有無] = "";
            row[(int)SheetSum.C91_PET_CR_DP比] = "";
            row[(int)SheetSum.C93_一日透析液使用量] = "";
            row[(int)SheetSum.C94_残存腎機能] = "";
            row[(int)SheetSum.C95_一日平均除水量] = "";
            row[(int)SheetSum.C96_残腎KT_V] = "";
            row[(int)SheetSum.C97_PD_KT_V] = "";
            row[(int)SheetSum.C98_APD] = "";
            row[(int)SheetSum.C99_PD透析液交換方法] = "";
            row[(int)SheetSum.C100_2025年中の腹膜炎罹患回数] = "";
            row[(int)SheetSum.C101_2025年中の出口部感染罹患回数] = "";

            dbInfo = workTable.Rows[0];

            //取得可能項目をセットしていく
            //区分の取得
            // 導入施設コードを自施設コードと比較
            // 区分:1 - 貴院導入
            string Kbn = string.Empty;
            DateTime day = StaticFunctions.YyyyMmDdToDay(dbInfo["DIAL_START_DATE"] as string);
            if (day < Settings.Default.PeriodStart || day >= Settings.Default.PeriodEnd)
            {
                day = DateTime.MinValue;
            }

            string facility = lblFacilityName.Text;
            //透析導入日の取得（転入出履歴より）
            var (initiationDate, initiationFacility) = await StaticFunctions.GetPatIntroduceToHospitalAsync(patID, facility);
            DateTime day1 = StaticFunctions.YyyyMmDdToDay(initiationDate.ToString("yyyyMMdd"));
            // 両方とも有効な日付かどうかを確認
            DateTime selectedDay = DateTime.MinValue;
            string selectedFacility = string.Empty;
            // 両方とも有効な日付かどうかを確認して古い方を選択
            if (day != DateTime.MinValue && day1 != DateTime.MinValue)
            {
                if (day < day1)
                {
                    selectedDay = day;
                    selectedFacility = dbInfo["INSTITUTION_CD"] as string;
                }
                else
                {
                    selectedDay = day1;
                    selectedFacility = initiationFacility;
                }
            }
            else if (day != DateTime.MinValue)
            {
                selectedDay = day;
                selectedFacility = dbInfo["INSTITUTION_CD"] as string;
            }
            else if (day1 != DateTime.MinValue)
            {
                selectedDay = day1;
                selectedFacility = initiationFacility;
            }

            if ((Settings.Default.PeriodStart <= selectedDay)
                && (selectedDay < Settings.Default.PeriodEnd))
            {
                if (selectedFacility != null)
                {
                    if (selectedFacility == string.Empty)
                    {
                        Kbn = "1";
                    }
                    else 
                    {
                        string matchcode = ConvFacility(selectedFacility);
                        string configCode = ConfigHelper.ReadSetting("FacilityCode") ?? "";
                        if (matchcode == configCode)
                        {
                            Kbn = "1";
                        }
                    }
                }
            }

            string pat_inoutCd = "";
            //区分:2 - 転入
            if (string.IsNullOrEmpty(Kbn))
            {
                //"PAT_INOUT"."INOUT_CD"をチェック
                //FNW+の区分[1:転入 2:転出 3:死亡]
                //2014年版修正（転帰パターン対応）
                //対象年(今回であれば2013年度)のデータのみを抽出
                string pat_inoutCdHave = await StaticFunctions.getInoutCdAsync((long)dbInfo["PATID"]);
                pat_inoutCd = await StaticFunctions.GetInoutCircumstanceAsync((long)dbInfo["PATID"]);

                //登録不要
                if (pat_inoutCd.Equals("5"))
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "転入後転出患者のためエクセルへ未出力　患者氏名：" + dbInfo["NAME"] as string);
                    return ("NonOutput", row); 
                }

                //転入
                if (pat_inoutCdHave.Equals("2"))
                {
                    Kbn = "2";
                }

                //区分:4 - 登録漏れ
                if (string.IsNullOrEmpty(Kbn))
                {
                    Kbn = "4";
                }
            }
            row[(int)SheetSum.C13_患者区分] = Kbn;
            //区分設定ここまで

            //診察券番号（DISP_PATIDを出力）
            buf = dbInfo["DISP_PATID"] as string;
            if (false == string.IsNullOrEmpty(buf))
            {
                Double dPatId = 0;
                if (double.TryParse(buf, out dPatId))
                {
                    row[(int)SheetSum.C14_診察券番号] = dPatId;
                }
                else
                {
                    row[(int)SheetSum.C14_診察券番号] = buf;
                }
            }

            //氏名
            buf = dbInfo["NAME"] as string;
            if (false == string.IsNullOrEmpty(buf))
            {
                buf = buf.Replace(" ", "　");
                string[] splitName = buf.Split('　');
                row[(int)SheetSum.C15_氏名_姓_漢字] = splitName[0];

                string strName = "";
                if (splitName.Length >= 2)
                {
                    for (int i = 1; i < splitName.Length; i++)
                    {
                        strName += splitName[i];
                    }
                }
                row[(int)SheetSum.C16_氏名_名_漢字] = strName;
            }
            buf = dbInfo["NAME_KANA"] as string;
            if (false == string.IsNullOrEmpty(buf))
            {
                buf = buf.Replace(" ", "　");
                string[] splitName = buf.Split('　');
                row[(int)SheetSum.C17_氏名_姓_カナ] = splitName[0];

                string strName = "";
                for (int i = 1; i < splitName.Length; i++)
                {
                    strName += splitName[i];
                }
                row[(int)SheetSum.C18_氏名_名_カナ] = strName;
            }

            buf = dbInfo["NAME_KANA"] as string;
            if (false == string.IsNullOrEmpty(buf))
            {
                buf = Strings.StrConv(buf, VbStrConv.Katakana, 0);
                buf = Strings.StrConv(buf, VbStrConv.Narrow, 0);
                row[(int)SheetSum.C19_並び替え] = buf[0].ToString();
            }

            switch (short.Parse(dbInfo["SEX_CD"].ToString()))
            {
                case 1:
                    row[(int)SheetSum.C20_性別] = "M";
                    break;
                case 2:
                    row[(int)SheetSum.C20_性別] = "F";
                    break;
            }

            StaticFunctions.SetBirthday(
                dbInfo["BIRTHDAY"] as string,
                ref row,
                (int)SheetSum.C21_生年月日_西暦,
                (int)SheetSum.C22_生年月日_月,
                (int)SheetSum.C23_生年月日_日);

            DateTime days;
            DateTime days1;

            days = StaticFunctions.YyyyMmDdToDay(dbInfo["DIAL_START_DATE"] as string);
            if (days >= Settings.Default.PeriodEnd)
            {
                days = DateTime.MinValue;
            }

            //透析導入日の取得（転入出履歴より）
            DateTime initiationDates = await StaticFunctions.GetPatUniqueInitDateAsync(patID);
            days1 = StaticFunctions.YyyyMmDdToDay(initiationDates.ToString("yyyyMMdd"));

            // 両方とも有効な日付かどうかを確認
            DateTime selectedDays = DateTime.MinValue;

            // 両方とも有効な日付かどうかを確認して古い方を選択
            if (days != DateTime.MinValue && days1 != DateTime.MinValue)
            {
                selectedDays = days < days1 ? days : days1;
            }
            else if (days != DateTime.MinValue)
            {
                selectedDays = days;
            }
            else if (days1 != DateTime.MinValue)
            {
                selectedDays = days1;
            }

            //選択された日付をセット
            if (selectedDays != DateTime.MinValue)
            {
                row[(int)SheetSum.C25_導入年月_西暦] = selectedDays.ToString("yyyy");
                row[(int)SheetSum.C26_導入年月_月] = selectedDays.Month;
            }
            else
            {
                row[(int)SheetSum.C25_導入年月_西暦] = "9999";
                row[(int)SheetSum.C26_導入年月_月] = "99";
            }

            //2014年版修正（転入・転帰パターン対応）
            //if (!pat_inoutCd.Equals("4"))
            //{
            // 2021年度対応　転入の施設が自施設だったら転入欄を出力しない。
            var (acquiredDate, fromFicilityName, toFicilityName) = await StaticFunctions.GetInDayAsync(patID, pat_inoutCd);
                 if (DateTime.MinValue != acquiredDate)
                {
                    if (!txtFacilityCode.Text.Equals(fromFicilityName) && !lblFacilityName.Text.Equals(fromFicilityName))
                    {
                        row[(int)SheetSum.C30_転入_西暦年] = acquiredDate.ToString("yyyy");
                        row[(int)SheetSum.C31_転入_月] = acquiredDate.Month;
                        row[(int)SheetSum.C32_転入_転入前の施設コード] = FrmStatistics.ConvFacility(fromFicilityName);
                    }
                    else
                    {
                        row[(int)SheetSum.C30_転入_西暦年] = " ";
                        row[(int)SheetSum.C31_転入_月] = " ";
                        row[(int)SheetSum.C32_転入_転入前の施設コード] = " ";
                    }
                }
            //}
            int code;
            //潜在してた不具合？？？
            if (dbInfo["BASE_DISEASE_CD"] == DBNull.Value)
            {
                code = -1; // またはデフォルト値
            }
            else
            {
                code = (int)dbInfo["BASE_DISEASE_CD"];
            }
            row[(int)SheetSum.C28_原疾患] = FrmStatistics.ConvDisease(code);
            row[(int)SheetSum.C29_在住県コード] = await StaticFunctions.GetZipCodeAsync((long)dbInfo["PATID"]);

            //2014年版修正（転入・転帰パターン対応）
            if (!(pat_inoutCd.Equals("1") || pat_inoutCd.Equals("4")))
            {
                var (sccess, updatedRow1) = await StaticFunctions.SetOutInfoAsync(
                    (long)dbInfo["PATID"],
                    row,
                    (int)SheetSum.C33_転帰欄_転帰区分,
                    (int)SheetSum.C34_転帰欄_西暦年,
                    (int)SheetSum.C35_転帰欄_月,
                    (int)SheetSum.C36_転帰欄_転出先の施設コード,
                    (int)SheetSum.C37_転帰欄_死因コード,
                    (int)SheetSum.C51_治療方法,
                    dbInfo["DIE_DATE"].ToString(),
                    dbInfo["DIE_CD"].ToString()
                    );
                if (!sccess)
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "転出情報取得失敗");
                    return ("false", row);
                }
                else
                {
                    row = updatedRow1;
                }
            }

            // 年末透析未実施患者を備考に設定
            if (temporaryPat.Contains(patID) == true)
            {
                if (string.IsNullOrEmpty(row[(int)SheetSum.C39_備考].ToString()))
                {
                    row[(int)SheetSum.C39_備考] = "12月透析未実施";
                }
                else
                {
                    row[(int)SheetSum.C39_備考] = row[(int)SheetSum.C39_備考] + ", 12月透析未実施";
                }
            }

            //2013年版修正(「糖尿病の既往」自動設定)
            if (("1" == dbInfo["DIABETES"] as string) || (await StaticFunctions.IsDiabetesAsync((long)dbInfo["PATID"])))
            {
                row[(int)SheetSum.C41_糖尿病の既往] = "B";
            }
            else
            {
                row[(int)SheetSum.C41_糖尿病の既往] = "";
            }

            // 最終透析
            string dNo = await StaticFunctions.GetDialysisNoAsync((long)dbInfo["PATID"]);
            if (null == dNo)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "透析番号取得失敗");
                return ("false", row);
            }

            //2025年度対象項目
            if (false == string.IsNullOrEmpty(dNo))
            {
                buf = await StaticFunctions.GetVaAsync(long.Parse(dNo));
                if (null == buf)
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "バスキュラーアクセス取得失敗");
                    return ("false", row);
                }
                row[(int)SheetSum.C50_ﾊﾞｽｷｭﾗｰｱｸｾｽ] = buf;
            }
            //END

            if (false == string.IsNullOrEmpty(dNo))
            {
                buf = await StaticFunctions.GetTreatItemAsync(long.Parse(dNo));
                if (null == buf)
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "治療方法取得失敗");
                    return ("false", row);
                }
                //2014年版修正（離脱・移植の追加）
                //透析離脱（70）以外の場合
                if (!row[(int)SheetSum.C51_治療方法].ToString().Equals("70"))
                {
                    row[(int)SheetSum.C51_治療方法] = buf;
                }
                //2012.11.29 週回数から特殊血液浄化の回数を除外するように変更
                buf = await StaticFunctions.GetDialysisWeeklyCountAsync(long.Parse(dNo));

                if (null == buf)
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "週透析回数取得失敗");
                    return ("false", row);
                }
                row[(int)SheetSum.C58_週透析回数] = buf;

                buf = await StaticFunctions.GetDialysisTimeAsync(long.Parse(dNo));
                if (null == buf)
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "透析時間取得失敗");
                }
                row[(int)SheetSum.C59_透析時間] = buf;

                buf = await StaticFunctions.GetDialysisBloodAsync(long.Parse(dNo));
                if(null == buf)
                {
                    m_Proc.ReportProgress((int)ReportType.LOG, "透析血流量取得失敗");
                    return ("false", row);
                }
                row[(int)SheetSum.C60_血流量] = buf;

                //2013年版修正(「HDF希釈の方法」「1セッションあたりの置換液量」FNWデータ取得化)
                //治療方法がHDFの場合のみ設定
                switch (row[(int)SheetSum.C51_治療方法] as string)
                {
                    case "10":  //血液透析濾過(ボトル型HDF）
                    case "11":  //血液透析濾過(オンラインHDF）
                    case "12":  //血液透析濾過(プッシュプルHDF）
                    case "13":  //アセテートフリーバイオフィルトレーション
                        buf = await StaticFunctions.GetDilutionAsync(long.Parse(dNo));
                        if (null == buf)
                        {
                            m_Proc.ReportProgress((int)ReportType.LOG, "HDF希釈の方法取得失敗");
                            return ("false", row);
                        }
                        row[(int)SheetSum.C61_HDF希釈の方法] = buf;

                        buf = await StaticFunctions.GetFluidReplacementAsync(long.Parse(dNo));
                        if (null == buf)
                        {
                            m_Proc.ReportProgress((int)ReportType.LOG, "1セッションあたりの置換液量取得失敗");
                            return ("false", row);
                        }
                        row[(int)SheetSum.C62_1セッションあたりの置換液量] = buf;

                        break;
                    case "14":  //間歇的血液透析濾過(IHDF）
                        row[(int)SheetSum.C61_HDF希釈の方法] = "D";
                        break;
                }

                var (sccess, updatedRow1) = await StaticFunctions.getBpAndPulseAsync(
                                                long.Parse(dNo),
                                                row,
                                                (int)SheetSum.C66_透析前収縮期血圧,
                                                (int)SheetSum.C67_透析前拡張期血圧,
                                                (int)SheetSum.C68_透析前脈拍
                                              );

                if (sccess)
                {
                    row = updatedRow1;
                }
            }

            //"PAT_CTR"."STATURE"カラムが存在する場合、身長の処理
            string height = await StaticFunctions.GetHeightAsync(patID);
            if (!height.Equals("false"))
            {
                row[(int)SheetSum.C63_身長] = height;
            }

            //第１透析日データ取得
            DataTable dtFirstDialysisDay = await StaticFunctions.GetFirstDialysisDayAsync((long)dbInfo["PATID"]);

            if (null == dtFirstDialysisDay)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "第１透析日データ取得失敗");
                return ("false", row);
            }

            string dNo2 = String.Empty;
            DateTime examDate = DateTime.MinValue;

            var (isWeightSetSuccess, updatedRowWeight, updatedDialysisNo, updatedExamDate) = await StaticFunctions.SetWeightAsync(
            (long)dbInfo["PATID"],
            row,
            //2013年版修正(検査結果の第１透析日判定機能を追加)
            dtFirstDialysisDay,
            (int)SheetSum.C64_体重_透析前,
            (int)SheetSum.C65_体重_透析後,
            (int)SheetSum.C69_BUN_透析前,
            (int)SheetSum.C70_BUN_透析後,
            //2013年版修正(クレアチニン濃度も体重とセットで格納するように変更)
            (int)SheetSum.C71_クレアチニン濃度_透析前,
            (int)SheetSum.C72_クレアチニン濃度_透析後,
            // 2015年版検査結果前後対応
            usingOrderClass,
            // 2020年版対応（血圧の取得変更対応）
            dNo2,
            //【2022年度版対応】2021年度までの未対応分の改修
            examDate
            );
            if (isWeightSetSuccess)
            {
                row = updatedRowWeight;
                dNo2 = updatedDialysisNo;
                examDate = updatedExamDate;
            }
            else
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "体重/BUN情報取得失敗");
                return ("false", row);
            }

            // 2020年版対応（血圧の取得変更対応）
            if (dNo != dNo2)
            {
                var (isBpAndPulseSuccess, updatedRowPulse) = await StaticFunctions.getBpAndPulseAsync(
                                                long.Parse(dNo),
                                                row,
                                                (int)SheetSum.C66_透析前収縮期血圧,
                                                (int)SheetSum.C67_透析前拡張期血圧,
                                                (int)SheetSum.C68_透析前脈拍
                                              );
                if (isBpAndPulseSuccess)
                {
                    row = updatedRowPulse;
                }
            }

            ////血清鉄濃度・総鉄結合能・血清フェリチンを追加
            //ヘモグロビンA1c・グリコアルブミンを追加
            var (successSetOtherExam, updatedRowSetOtherExam) = await StaticFunctions.SetOtherExamAsync(
                (long)dbInfo["PATID"],
                row,
                //2013年版修正(検査結果の第１透析日判定機能を追加)
                dtFirstDialysisDay,
                (int)SheetSum.C75_透析前カルシウム濃度,
                (int)SheetSum.C76_透析前リン濃度,
                (int)SheetSum.C73_透析前アルブミン濃度,
                (int)SheetSum.C74_透析前CRP濃度,
                (int)SheetSum.C79_透析前ヘモグロビン濃度,
                (int)SheetSum.C78_PTH値,
                (int)SheetSum.C80_総コレステロール濃度,
                (int)SheetSum.C81_HDL_C濃度,
                //2025年度対象外項目
                //(int)SheetSum.C89_LDL_コレステロール濃度,
                //(int)SheetSum.C90_中性脂肪,
                //END
                this.usingOrderClass,    //2015年版：検査結果前後対応
                examDate //【2022年度版対応】2021年度までの未対応分の改修
                );
            if (!successSetOtherExam)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "検査結果取得失敗");
                return ("false", row);
            }
            row = updatedRowSetOtherExam;


            //患者感染症情報格納処理（2024年度対応　新設項目）
            var (successSetfect, updatedRowfect) = await StaticFunctions.SetInfectAsync(
                (long)dbInfo["PATID"],
                row,
                (int)SheetSum.C82_HBs抗原,
                (int)SheetSum.C83_HBs抗体,
                (int)SheetSum.C84_HBc抗体,
                (int)SheetSum.C85_HBV_DNA検査,
                (int)SheetSum.C86_HCV抗体,
                (int)SheetSum.C87_HCV_RNA検査
                );
            if (!successSetfect)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "患者感染症取得失敗");
                return ("false", row);
            }
            row = updatedRowfect;



            //2012年度追加
            //必須出力項目が空文字で出力される場合
            //補える範囲で不明値をセットする
            var (sccuess, updatedRow) = await StaticFunctions.ChkRequiredItemAsync(row, (long)dbInfo["PATID"], pat_inoutCd);

            if (!sccuess)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "必須出力項目の設定失敗");
                return ("false", row);
            }
            row = updatedRow;
            // 2020年度修正(12月に透析実施が存在しない患者のデータクリア)（Start）
            if (temporaryPat.Contains(patID) == true)
            {
                // 糖尿病の既往以降の項目を出力しない
                row = DataClear(row);
            }

            return ("true", row);
        }

        /// <summary>
        /// 登録済み患者"以外"を処理
        /// </summary>
        /// <param name="patProcedList">登録済みリスト</param>
        /// <param name="isExistError">Errorリスト</param>
        /// <param name="temporaryPat">年末透析未実施患者のIDリスト</param>
        /// <returns>true:成功 false:失敗</returns>
        private async Task<(bool success, bool isExistError)> ProcSheetOtherAsync(List<long> patProcedList, List<long> temporaryPat)
        {
            bool isExistError = false;

            //2013年版修正(ECUMについてはDBバージョンに関わらず除外する)
            //特殊透析のみの患者は対象外とする
            //指定期間内に実績が1件でも有る患者が処理対象
            DataTable dt1;
            OrdMainOtherPatDataResponse ordMainOtherPatResult = await StatisticsLib.GetOrdMainOtherPatData(
                new SysDataSetRequest(
                    sqlCd: -1000006,
                    fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                    toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<OrdMainOtherPatDataType> ordMainOtherPatList = ordMainOtherPatResult.Data;
            // DataTableに変換
            dt1 = StatisticsUtility.ConvertToDataTable(ordMainOtherPatList, null);
            if (null == dt1)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "患者一覧取得失敗");
                return (false, isExistError);
            }
            // 指定期間内に実績が1件でも有る患者が処理対象
            DataTable dt2;
            PatPersonalDataResponse patPersonalResult = await StatisticsLib.GetPatPersonalData(
                new SysDataSetRequest(
                    sqlCd: -1000103
                )
            );
            List<PatPersonalDataType> patPersonalList = patPersonalResult.Data;
            // DataTableに変換
            dt2 = StatisticsUtility.ConvertToDataTable(patPersonalList, null);
            if (null == dt2)
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "患者一覧取得失敗");
                return (false, isExistError);
            }

            // 結果を保持するためのDataTableを作成
            DataTable dt = new DataTable();
            dt.Columns.Add("PATID", typeof(long));
            dt.Columns.Add("DISP_PATID", typeof(string));
            dt.Columns.Add("DIAL_START_DATE", typeof(string));
            dt.Columns.Add("INSTITUTION_CD", typeof(string));

            // テーブルのpatidに基づいて、テーブルからdisp_patidを取得し、結合する
            foreach (DataRow rowTemp in dt1.Rows)
            {
                DataRow newRow = dt.NewRow();
                newRow["PATID"] = rowTemp["PATID"];
                newRow["DIAL_START_DATE"] = rowTemp["DIAL_START_DATE"];
                newRow["INSTITUTION_CD"] = rowTemp["INSTITUTION_CD"];

                // テーブルからpatidをキーにdisp_patidを探す
                DataRow[] matchingRows = dt2.Select($"PATID = {rowTemp["PATID"]}");
                if (matchingRows.Length > 0)
                {
                    newRow["DISP_PATID"] = matchingRows[0]["DISP_PATID"];

                }
                else
                {
                    newRow["DISP_PATID"] = DBNull.Value; // マッチしない場合はNULLをセット

                }
                dt.Rows.Add(newRow);
            }

            // DataViewを使用してソート
            DataView view = dt.DefaultView;
            view.Sort = "DISP_PATID ASC";  // Age列で昇順にソート

            // ソートされたDataTableを取得
            DataTable patList = view.ToTable();

            // 結果出力用のテーブル作成
            DataTable sumTable = new DataTable();
            DataTable errSumTable = new DataTable();

            for (int i = 0; i < (int)SheetSum.件数_; i++)
            {
                sumTable.Columns.Add();
            }

            for (int i = 0; i < (int)ErrorSheetNew.COL_COUNT; i++)
            {
                errSumTable.Columns.Add();
            }

            m_Proc.ReportProgress((int)ReportType.LOG, "未登録患者処理開始 対象人数：約" + patList.Rows.Count.ToString() + "人(重複含む)");

            // 取得した患者数分処理を開始
            for (int i = 0; i < patList.Rows.Count; i++)
            {
                if (m_IsStop)
                {
                    // 処理中断
                    return (false, isExistError);
                }

                // CPU稼働率を下げるため1人処理するたびに少し待つ
                await Task.Delay(Settings.Default.ProcWait);

                // 患者ID作成
                long id = (long)patList.Rows[i]["PATID"];
                if (id == 0)
                {
                    // いくらなんでも患者IDが無いのは考えにくいが一応チェックしてスキップ
                    continue;
                }

                if (patProcedList.Contains(id))
                {
                    // 登録済み患者の処理済患者一覧に載っている場合はスキップ
                    continue;
                }

                DataRow sumRow = sumTable.NewRow();

                //2014年版修正（転出・転帰パターン対応）
                var(valueBrocSheetSum, updatedRow) = await ProcSheetSumAsync(id, sumRow, temporaryPat);
                if ("false" == valueBrocSheetSum)
                {
                    DataRow err = errSumTable.NewRow();
                    err[(int)ErrorSheetNew.DISP_PATID] = (patList.Rows[i]["DISP_PATID"]).ToString().TrimStart('0');
                    errSumTable.Rows.Add(err);
                }
                else if ("NonOutput" == valueBrocSheetSum)
                {
                }
                else
                {
                    sumTable.Rows.Add(updatedRow);
                }
                m_Proc.ReportProgress((int)ReportType.ONE_FIN);
            }

            if (false == FnwCsv.AppendWrite(dirExportDirectory.SelectedPath + "\\" + Settings.Default.FileSheetSum, sumTable))
            {
                m_Proc.ReportProgress((int)ReportType.LOG, "情報保存失敗");
                return (false, isExistError);
            }

            if (0 != errSumTable.Rows.Count)
            {
                if (false == FnwCsv.Write(dirExportDirectory.SelectedPath + "\\" + Settings.Default.FileErrorNew, errSumTable))
                {
                    return (false, isExistError);
                }

                isExistError = true;
            }

            return (true, isExistError);
        }
        #endregion

        #region 2015年版対応:各項目の完了状態の確認
        /// <summary>
        /// 状態によるボタンの押下可否制御/メッセージ制御を行います。
        /// </summary>
        private void ChangeButtonStatus()
        {
            Boolean boolExtract = false;

            // 完了状態による抽出ボタンの押下可否制御
            if (this.CheckStatus() == false || this.txtFacilityCode.Text.Equals(String.Empty) || this.txtFacilityCode.Text.Equals("_"))
            {
                this.btnExtract.Enabled = false;
                boolExtract = false;
            }
            else
            {
                this.btnExtract.Enabled = true;
                boolExtract = true;
            }

            //状態によるメッセージの出力
            if (this.btnExtract.Enabled == false)
            {
                this.lblStatusMassage.Text = "抽出を行うには登録済み患者一覧作成～抽出設定まで完了させてください";
            }
            else if (boolExtract == true)
            {
                this.lblStatusMassage.Text = "抽出を行うことが可能です。";
            }
            else
            {
                this.lblStatusMassage.Text = "";
            }
        }

        /// <summary>
        /// 各項目の状態をチェックします。
        /// </summary>
        /// <returns></returns>
        private Boolean CheckStatus()
        {
            List<ProcessItem> allStatus = CompletionStatus.GetProcessItems();

            foreach (ProcessItem itemStatus in allStatus)
            {
                if (itemStatus.Id != "ExtractCsv")
                {
                    if (itemStatus.Status == 0)
                    {
                        return false;
                    }
                }
            }

            return true;
        }
        #endregion

        #region 2015年度対応（マスタ設定・ログのプレビュー表示）
        /// <summary>
        /// 指定の処理名の設定内容を退避します。
        /// </summary>
        /// <param name="procName">処理名</param>
        /// <param name="dt">設定内容</param>
        private void SetMstDataTable(ProcessId procName, DataTable dt)
        {
            if (this.dicProcessData_.ContainsKey(procName) && this.dicProcessData_[procName] != null)
            {
                // 前回設定済みの内容は破棄する
                this.dicProcessData_[procName].Dispose();
                this.dicProcessData_[procName] = null;
            }
            if (dt == null)
            {
                return;
            }
            // 今回の設定内容をコピー設定する
            this.dicProcessData_[procName] = dt.Copy();
        }
        #endregion

        #region 2015年版対応：検査結果前後設定使用区分の取得
        /// <summary>
        /// 設定ファイルより検査結果前後設定使用区分を取得します。
        /// </summary>
        /// <returns></returns>
        private string GetUsingOrderClass()
        {
            if (string.IsNullOrEmpty(ConfigHelper.ReadSetting("UsingOrderClass")))
            {
                // 未設定の場合
                ConfigHelper.WriteSetting("UsingOrderClass", "2");
                return ConfigHelper.ReadSetting("UsingOrderClass");
            }
            else
            {
                return ConfigHelper.ReadSetting("UsingOrderClass");
            }
        }
        #endregion

        #region 期間内の透析実施患者を取得
        /// <summary>
        /// 期間内の実績のある患者を抽出
        /// </summary>
        private async Task<DataTable> GetTreatPatAsync(DateTime periodStart, DateTime periodEnd)
        {
            DataTable dt1;
            OrdMainOtherPatDataResponse ordMainOtherPatResult = await StatisticsLib.GetOrdMainOtherPatData(
                new SysDataSetRequest(
                    sqlCd: -1000006,
                    fromDate: periodStart.ToString("yyyy/MM/dd"),
                    toDate: periodEnd.ToString("yyyy/MM/dd")
                )
            );
            List<OrdMainOtherPatDataType> ordMainOtherPatList = ordMainOtherPatResult.Data;
            // DataTableに変換
            dt1 = StatisticsUtility.ConvertToDataTable(ordMainOtherPatList, null);
            if (null == dt1)
            {
                return null;
            }
            DataTable dt2;
            PatPersonalDataResponse patPersonalResult = await StatisticsLib.GetPatPersonalData(
                new SysDataSetRequest(
                    sqlCd: -1000103
                )
            );
            List<PatPersonalDataType> patPersonalList = patPersonalResult.Data;
            // DataTableに変換
            dt2 = StatisticsUtility.ConvertToDataTable(patPersonalList, null);
            // 結果を保持するためのDataTableを作成
            DataTable dt = new DataTable();
            dt.Columns.Add("PATID", typeof(long));
            dt.Columns.Add("DISP_PATID", typeof(string));
            dt.Columns.Add("NAME", typeof(string));
            dt.Columns.Add("DIAL_START_DATE", typeof(string));
            dt.Columns.Add("INSTITUTION_CD", typeof(string));

            // テーブルのpatidに基づいて、テーブルからdisp_patidを取得し、結合する
            foreach (DataRow rowTemp in dt1.Rows)
            {
                DataRow newRow = dt.NewRow();
                newRow["PATID"] = rowTemp["PATID"];
                newRow["DIAL_START_DATE"] = rowTemp["DIAL_START_DATE"];
                newRow["INSTITUTION_CD"] = rowTemp["INSTITUTION_CD"];

                // テーブルからpatidをキーにdisp_patidを探す
                DataRow[] matchingRows = dt2.Select($"PATID = {rowTemp["PATID"]}");
                if (matchingRows.Length > 0)
                {
                    newRow["DISP_PATID"] = matchingRows[0]["DISP_PATID"];
                    newRow["NAME"] = matchingRows[0]["NAME"];
                }
                else
                {
                    newRow["DISP_PATID"] = DBNull.Value; // マッチしない場合はNULLをセット
                    newRow["NAME"] = DBNull.Value; // マッチしない場合はNULLをセット
                }
                dt.Rows.Add(newRow);
            }

            // DataViewを使用してソート
            DataView view = dt.DefaultView;
            view.Sort = "DISP_PATID ASC";  // Age列で昇順にソート

            // ソートされたDataTableを取得
            DataTable patList = view.ToTable();

            return patList;
        }
        #endregion

        #region 年末透析未実施患者の抽出
        /// <summary>
        /// 年末透析未実施患者の抽出
        /// </summary>
        /// <returns></returns>
        private async Task<List<long>> GetTemporatyPatAsync()
        {
            // 年末透析未実施患者のリスト
            List<long> temporatyPats = new List<long>();

            // 年内の透析実績の患者を抽出
            DataTable dtPatListYear = await GetTreatPatAsync(Settings.Default.PeriodStart, Settings.Default.PeriodEnd);

            if (null == dtPatListYear)
            {
                return temporatyPats;
            }

            //対象患者情報が1件以上存在するとき
            if (0 < dtPatListYear.Rows.Count)
            {
                // 12月に実績のある患者を抽出
                DataTable dtPatListDecember = await GetTreatPatAsync(Settings.Default.PeriodEnd.AddMonths(-1), Settings.Default.PeriodEnd);
                //DataTable dtPatListDecember = await GetTreatPatAsync(Settings.Default.PeriodStart, Settings.Default.PeriodEnd);
                // 年内に実績があり、12月に実績のない患者のリスト
                foreach (DataRow dRowYear in dtPatListYear.Rows)
                {
                    Boolean temporaryFlg = true;
                    foreach (DataRow dRowDec in dtPatListDecember.Rows)
                    {
                        if (dRowYear["PATID"].Equals(dRowDec["PATID"]))
                        {
                            temporaryFlg = false;
                            break;
                        }
                    }
                    if (temporaryFlg == true)
                    {
                        temporatyPats.Add((long)dRowYear["PATID"]);
                    }
                }
            }
            return temporatyPats;
        }
        #endregion

        #region 処理状況更新
        private void UpdateAllProcessCompletionStatus()
        {
            string facilityCd = txtFacilityCode.Text.Trim();

            // 設定ファイルの期間を更新するかチェック
            if (facilityCd == ConfigHelper.ReadSetting("FacilityCd"))
            {
                return;
            }
            ConfigHelper.WriteSetting("FacilityCd", facilityCd);

            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.ExcelImport);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchPatient);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchMstDisease);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchMstTreatItem);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchMstDie);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MstFacility);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchMstExamItem);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.SelectMstDiseaseDiabetes);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.CustomizeSettings);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.ExtractCsv);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchMstInfection);
            ConfirmCompletionStatus(false);
            this.ProcItem = CompletionStatus.GetProcessItem(ProcessId.MatchMstVa);
            ConfirmCompletionStatus(false);

            this.ProcItem = null;
            ShowAllCompletionStatus();
        }
        #endregion

        #region 自施設によるボタン可否制御
        private void ChangeBottonEnable(bool value)
        {
            btnExcelImport.Enabled = value;
            btnPatMatch.Enabled = value;
            btnMstDiseaseMatch.Enabled = value;
            btnMstTreatItemMatch.Enabled = value;
            btnMstDieMatch.Enabled = value;
            btnMstFacilityMatch.Enabled = value;
            btnMstExamItemMatch.Enabled = value;
            btnMstInfectionMatch.Enabled = value;
            btnMstVaMatch.Enabled = value;
            btnDiabetesSelect.Enabled = value;
            btnCustomize.Enabled = value;
        }
        #endregion

        /// <summary>
        /// 感染症設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnMstInfectionMatch_Click(object sender, EventArgs e)
        {
            this.ProcFnwMatch(FnwMatchType.MST_INFECTION, ProcessId.MatchMstInfection);
        }

        /// <summary>
        /// FNWコード割当処理
        /// </summary>
        /// <param name="type"></param>
        /// <param name="procName"></param>
        private void ProcFnwMatch(FnwMatchType type, ProcessId procName)
        {
            using (FrmFnwCodeMatch frm = new FrmFnwCodeMatch())
            {
                frm.EditType = type;
                frm.ProcItem = CompletionStatus.GetProcessItem(procName);
                this.Visible = false;

                frm.ShowDialog();
                // 完了状態を表示する
                ShowCompletionStatus(frm.ProcItem);
                // マスタ設定・ログのプレビュー表示
                SetMstDataTable(procName, frm.DataCodeMatch);
            }
            this.Visible = true;
        }

        /// <summary>
        /// バスキュラーアクセス設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnMstVaMatch_Click(object sender, EventArgs e)
        {
            this.ProcMatch(MatchType.MST_VA_ACCESS, ProcessId.MatchMstVa);
        }
    }
}
