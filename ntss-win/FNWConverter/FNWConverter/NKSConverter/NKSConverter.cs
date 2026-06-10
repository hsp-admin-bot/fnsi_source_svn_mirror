using ConvertCommon;
using ConvertCommon.Common;
using ConvertCommon.Const;
using ConvertCommon.dao;
using ConvertCommon.dto;
using ConvertCommon.Dto;
using ConvertCommon.parts;
using Fnw.IOControl.DB;
using Fnw.IOControl.Log;
using Newtonsoft.Json;
using NKSConverter.Properties;
using Renci.SshNet;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Windows.Forms;
using static ConvertCommon.Common.CacheInformation;
using static ConvertCommon.Common.CommonConfig;

namespace NKSConverter
{
    public partial class MainForm : Form
    {
        //【実装内容】
        //　■内部機能
        //　　●DBアクセス
        //　　　・Oracleアクセス
        //　　　・RDS（PosgreSQL）アクセス
        //　　●データ取得
        //　　　・Oracleアクセス
        //　　●データ加工
        //　　　・RDS（PosgreSQL）へのInsert用SQL作成
        //　　●データ移行
        //　　　・RDS（PosgreSQL）へのInsert
        //　■画面機能
        //　　●設定画面
        //　　　・Oracleアクセス
        //　　　・RDS（PosgreSQL）アクセス
        //　　　　※EC2経由（SSH接続）でのトンネリング
        //　　●画面制御
        //　　　・データ移行施設（施設コード）指定
        //　　　・患者指定
        //　　　　※全患者指定含む
        //　　　・期間指定（実績などの一部データが対象）
        //　　　・移行データ（テーブル）指定（プロトタイプ版のみ）
        //　　　　※ベースはNTSSのテーブル~
        //　　　・処理ステータス表示
        //　　　　例）処理テーブル、残りの処理レコード数

        public enum Mode
        {
            Convert = 1,
            Export = 2,
            Import = 3,
        }
        //add 7997 start
        public Dictionary<string, List<Dictionary<string, object>>> SelectedRowsByFacility
           = new Dictionary<string, List<Dictionary<string, object>>>();

        Dictionary<string, bool> SelectedchkSelectAllSpan
         = new Dictionary<string, bool>();

        Dictionary<string, bool> SelectedchkEnd
        = new Dictionary<string, bool>();
        

        private bool _isLoadedType = true;

        Dictionary<string, DateTime> SelecteddtpStartDate
           = new Dictionary<string, DateTime>();
        Dictionary<string, DateTime> SelecteddtpEndDate
          = new Dictionary<string, DateTime>();

        //add 7997 end
        public bool IsInit = false;

        private const string FACILITY_CD_KEY = "facilityCd";
        private const string LOG_FILES_KEY = "logFiles";
        private const string LOG_FILES_NAME_KEY = "uploadLogFileName";

        private const string MSG_DB_CONN = "DB接続";
        private const string CMB_SELECT_ALL_RECORD_PAT = "患者情報（掲示板、観察記録、患者イベント含む）";
        private const string CMB_SELECT_ALL_RECORD_MST = "マスター（マスタ、機器保守関連含む）";
        private const string CMB_SELECT_PAT_EXAM = "検査情報（予定/結果/放射線 期間指定可）";
        private const string CMB_SELECT_SPECIFY_PERIOD_PAT = "透析情報（指示/実績/バイタル/モニタ/愁訴処置 期間指定可）";
        private const string CMB_SELECT_SPECIFY_PERIOD = "期間指定移行対象";
        private const string CMB_SELECT_PAT_TREATMENT_PATTERN = "患者治療パターン";
        private const string CMB_SELECT_INDICATES_HISTORY = "指示履歴";
        private const string EXPORT_PROC_NAME = "データコンバートを";
        private const string CONFIRM_MSG = "データコンバートを開始しますか？";
        private const string CMB_SELECT_MNT_MOTION_RECORD = "装置記録（装置自己診断/愁訴処置表示項目含む 期間指定可）";
        private const string CMB_SELECT_ALL = "すべて";
        private const string CMB_SELECT_ALL_ADD = "すべて(追加)";
        private bool _IsConvertAll = false;
        // add FNSI-全ての期間対応 楊 start
        private DateTime _beDtpStartDate = new DateTime();
        // add FNSI-全ての期間対応 楊 end
        SshClient client = null;
        ForwardedPortLocal forward = null;
    
        DBCtrl db = null;

        public TextBox txtFacilityCd = null;
        // Add #7997 趙 Start
        // 旧施設コード
        public TextBox txtSeriesCd = null;
        // メッセージの出力かどうかフラグ
        public string loopKbn = null;
        // キャンセルの場合、次の処理を行うフラグ
        public bool cancelKbn = false;

        // Add #7997 趙 End

        public ComboBox cmb_select = null;

        /// <summary>使用モード</summary>
        private Mode useMode;
        /// <summary>エンコード文字種</summary>
        private Encoding encoding = new System.Text.UTF8Encoding(false);

        /// <summary>患者・期間指定対象コンバートテーブル名</summary>
        private List<string> m_convertTableNames;

        /// <summary>
        /// 出力形式保持用
        /// </summary>
        private int _outputMode;

        /// <summary>
        /// sql文作成状態用
        /// </summary>
        public ListBox _lbSQLFileBuildStatus;
     

        ///コンバート種別 完全 追加 差分
        public string turnType = "";

        // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 start
        public bool tmpChkAllSpan = false;
        public bool tmpChkEndDateControl = false;
        // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 end

        // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
        /// <summary>
        /// スレッド数>1を使用する場合は、複数のスレッドを使用します
        /// </summary>
        //private const int THREAD_NUMS = 5;
        // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end

        // add #9298 マルチスレッド start

        /// <summary>
        /// 
        /// </summary>
        private int isPat = 1;

        private bool isPattern = true;

        /// <summary>
        /// 排他ロック
        /// </summary>
        private object locker = new object();

        struct ConvertPatProcPatidListWork
        {
            public ConvertPatProcPatidListWork(
                IEnumerable<string> procPatidList,
                int startRowIndex)
            {
                this.procPatidList = procPatidList;
                this.startRowIndex = startRowIndex;
            }
            public IEnumerable<string> procPatidList;
            public int startRowIndex;
        }
        // add 2023-07-06 #8585 マルチスレッド end

        /// <summary>
        /// 指定期間を表す構造体
        /// </summary>
        struct SelectSpan
        {
            public DateTime startDate;
            public DateTime endDate;
            public string description;
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public MainForm()
        {
            InitializeComponent();
            // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 start
            tmpChkAllSpan = chkSelectAllSpan.Checked;
            tmpChkEndDateControl = chkEndDateControl.Checked;
            dtpEndDateBefore = dtpEndDate.Value;
            // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 end

            // add 2020-12-11 画面表示設定 う start
            FormShowState();
            // add 2020-12-11 画面表示設定 う end
            dtpEndDate.Value = DateTime.Now;
            //7997 start
            tabControlSd.SelectedIndexChanged += tabControlSd_SelectedIndexChanged;
            LoadTabs();
            //7997 end
        }
         
        private void LoadTabs()
        {
            tabControlSd.TabPages.Clear();
            db = new DBCtrl(null);
            DataTable dt = db.SelectTable(
                "select SERIES_CD, FACILITY_CD from SYNC_FACILITY_CD order by ID"
            );
            foreach (DataRow row in dt.Rows)
            {
                string seriesCd = row["SERIES_CD"].ToString();
                string facilityCd = row["FACILITY_CD"].ToString();

                TabPage tab = new TabPage
                {
                    Text = facilityCd, 
                    Tag = seriesCd   
                };

                tabControlSd.TabPages.Add(tab);
            }

            if (tabControlSd.TabPages.Count > 0)
            {
                tabControlSd.SelectedIndex = 0;
            }
            _currentKey = tabControlSd.SelectedTab.Tag.ToString();
            MovePanelToTab(tabControlSd.SelectedTab);
            setserCdData(_currentKey);

        }
        private void MovePanelToTab(TabPage tab)
        {
            if (panel1.Parent == tab)
                return;
            panel1.Parent?.Controls.Remove(panel1);
            panel1.Dock = DockStyle.Fill;
            tab.Controls.Add(panel1);
        }

        private string _currentKey = null;
        private void tabControlSd_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (tabControlSd.SelectedTab == null)
                return;

            string Key = tabControlSd.SelectedTab.Tag.ToString();
            if (_currentKey != null)
            {
                SaveState(_currentKey);
            }

            MovePanelToTab(tabControlSd.SelectedTab);
            setserCdData(Key);
            _currentKey = Key;
        }

        private void SaveState(string key)
        {
          

            if (!LstDgvPatSelectedIndex.ContainsKey(key))
            {

                LstDgvPatSelectedIndex[key] = new List<int>();
            }
            else
            {
                LstDgvPatSelectedIndex[key].Clear();
            }

            foreach (DataGridViewRow item in dgvPat.SelectedRows)
            {
                LstDgvPatSelectedIndex[key].Add(item.Index);
            }

            SaveSelectedRows(key, dgvPat);
        }

        // add FNSI-差分コンバート対応 楊 start
       

        public void MainForm_Load()
        {

            if (DBCommon.IsConnection(null))
            {
                ConvertBase.WriteTraceLog("FNWDB接続に成功しました。");
                db = new DBCtrl(null);
            }
            else
            {
                ConvertBase.WriteErrorLog("FNWDB接続に失敗しました。");
            }

            useMode = MainForm.Mode.Export;


            try
            {
                // 全件移行対象（マスタ・患者情報）設定ロード
                _convertAllRecordConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_ALL_RECORD_XML_FILE_PATH);
                
                // 患者毎期間指定移行対象設定ロード
                _convertPatSpecifyPeriodConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_PAT_SPECIFY_PERIOD_XML_FILE_PATH);
                
                // add FNSI-検査結果対応 楊 start
                // 検査予定／結果設定ロード
                _convertPatExamRadConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_PAT_EXAM_RAD_XML_FILE_PATH);
                // add FNSI-検査結果対応 楊 end

                // 患者治療パターン移行対象設定ロード
                _convertPatTreatmentPatternConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_PAT_TREATMENT_PATTERN_XML_FILE_PATH);
                
                // 指示履歴コンバート移行対象設定ロード
                _convertIndHistoryConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CMB_SELECT_INDICATES_HISTORY_XML_FILE_PATH);
                
                // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
                // 装置記録コンバート移行対象設定ロード
                _convertMotionConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CMB_SELECT_MOTION_XML_FILE_PATH);
                // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("func(getConfigXml)" + System.Environment.NewLine +
                    ex.ToString());
            }

            // 権限設定XML初期設定
            // 権限設定XMLファイル、SQLファイルが存在しない場合処理終了
            // エクセプションが飛ぶ
            try
            {
                AuthoritySettingsDtoUtil.init();
                ConvertBase.WriteTraceLog("AuthoritySettingsDtoUtil.init 成功");
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("権限設定XML初期設定時にエラーが発生しました。" + System.Environment.NewLine +
                    ex.ToString());
            }

            CommonConfig.isDiff = true;

            try
            {
                chkSelectAllPat.Enabled = true;
                chkSelectAllSpan.Enabled = true;
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("初期設定 失敗 " + System.Environment.NewLine +
                    ex.ToString());
            }

            // 対象患者表示
            var isSuccess = ShowTargetPat();
            if (isSuccess == false)
            {
                ConvertBase.WriteErrorLog("データ移行対象患者の取得に失敗しました。");
            }
        }
        public bool EventConvertAllTableForService()
        {
            if (!CheckFacilityCd())
            {
                ConvertBase.WriteTraceLog("施設コードを設定してください。");
                return false;
            }

            ConvertBase.WriteTraceLog("データコンバートを開始します。");
            //add #12229 start
            ConvertTss.Initialize(db);
            //add #12229 end
            this._IsConvertAll = true;
            //10112 zc start
            getAV_SN();
            //10112 zc end
			//add #11383 zc start
            CommonConfig.diffPatMainAll = false;
            CommonConfig.diffPatPersonalMainAll = false;
            CommonConfig.diffPatMainMongo = false;
            CommonConfig.diffPatPersonalMainMongo = false;
            //add #11383 zc end

            //add 11753 start
            CommonConfig.examinPatid = null;
            //add 11753 end

            // 更新日付を設定
            var dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;
            
            //mod 8400 zc start
            dtpStartDate.Value = new DateTime(1900, 01, 01);
         
            //mod 8400 zc start
            dtpEndDate.Value = dtNow.AddYears(1);
            //mod 8400 zc end
            this._outputMode = (int)CommonConstants.OutputFormat.SQL;
            // 出力済を除外するオプションボタンの値を共通クラスへ設定する
            CommonConfig.isExclusion = false;
            // Mod #7997 趙 Start
           
            CommonConfig.seriesCd = txtSeriesCd.Text;
            // Mod #7997 趙 End
            // 全件移行対象（マスタ）
            
            //add 11588 start
            getPatIdLatestNo(this.txtFacilityCd.Text);
            //add 9688 start
            ConvertSQL cs = new ConvertSQL();
            //cs.SetMEDICINELATESTNO(db);
            cs.SetDiffMEDICINELATESTNO(this.txtFacilityCd.Text, CommonConfig.seriesCd);
            //add  9688 end
            //add 11588 end


            //add  #10840 COP_EVENT_MANAGEの最新連携種別を取得する　　start
            //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
            cs.GetRenkeiType("透析実績,患者情報受信,バイタル送信,透析レポート");
            //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
            //add  #10840 COP_EVENT_MANAGEの最新連携種別を取得する　 end

            //add 8400 zc start           
            CommonConfig.UpDate = DateTime.Now;
            //add 8400 zc end

            // mod 7853-差分コンバートで更新/削除ができない 楊 end

            //mod #12484  差分の場合　コンバートツールで処理種別の除外ができない　start
            string sql = "select DISTINCT TABLE_KIND from  SYNC_CONVERT_HISTORY where (TABLE_NAME !='diff' OR TABLE_NAME IS NULL)and FACILITY_CD=:FACILITY_CD";
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":FACILITY_CD", this.txtFacilityCd.Text);
             DataTable  dt  = db.SelectTable(sql, param.GetParam());

              List<string> tableKindSet = dt.AsEnumerable()
                .Select(r => r["TABLE_KIND"].ToString().Trim())
                .ToList();

            // 全件移行対象（マスタ）
            if (tableKindSet.Contains("MST")) {
                if (!this.ShowTargetTable(CMB_SELECT_ALL_RECORD_MST))
                {
                    ConvertBase.WriteTraceLog("データ移行対象テーブル情報の取得に失敗しました。");
                }
                dgvPat.SelectAll();
                this.ConvertAllRecordForService("convert(mst)[diff]");
            }

            // 指示履歴
            if (tableKindSet.Contains("HIS")) { 
            
                if (!this.ShowIndHistoryTable(CMB_SELECT_INDICATES_HISTORY))
                {
                    ConvertBase.WriteTraceLog("データ移行対象テーブル情報の取得に失敗しました。");
                }
                dgvPat.SelectAll();
                this._outputMode = (int)CommonConstants.OutputFormat.JSON;
                m_convertTableNames = GetProcTargetTables(_convertIndHistoryConfig);
                // mod 7853-差分コンバートで更新/削除ができない 楊 start
                this.ConvertMongoDBForService("indicatorShoe[diff]");
                // mod 7853-差分コンバートで更新/削除ができない 楊 end     
            }

            // 全件移行対象（患者情報）
            if (tableKindSet.Contains("PAT")) {

                if (!this.ShowTargetTable(CMB_SELECT_ALL_RECORD_PAT))
                {
                    ConvertBase.WriteTraceLog("データ移行対象テーブル情報の取得に失敗しました。");
                }
                dgvPat.SelectAll();
                // mod 7853-差分コンバートで更新/削除ができない 楊 start
                this.ConvertAllRecordForService("convert(pat)[diff]");
               
                // mod 7853-差分コンバートで更新/削除ができない 楊 end
            }

            // 検査予定／結果
            if (tableKindSet.Contains("EXM")) {
                this._outputMode = (int)CommonConstants.OutputFormat.SQL;
                if (!this.ShowTargetPat())
                {
                    ConvertBase.WriteTraceLog("データ移行対象テーブル情報の取得に失敗しました。");
                }
                m_convertTableNames = GetProcTargetTables(_convertPatExamRadConfig);
                dgvPat.SelectAll();
                // mod 7853-差分コンバートで更新/削除ができない 楊 start
                this.ConvertPatSpecifyPeriodForService(true, "inspectionSchedule／result[diff]");
                // mod 7853-差分コンバートで更新/削除ができない 楊 end

            }

            // 透析（または患者毎期間指定移行対象）
            if (tableKindSet.Contains("ORD")) {
                this._outputMode = (int)CommonConstants.OutputFormat.SQL;            
                if (!this.ShowTargetPat())
                {
                    ConvertBase.WriteTraceLog("データ移行対象テーブル情報の取得に失敗しました。");
                }
                m_convertTableNames = GetProcTargetTables(_convertPatSpecifyPeriodConfig);
                dgvPat.SelectAll();
                // mod 7853-差分コンバートで更新/削除ができない 楊 start
                this.ConvertPatSpecifyPeriodForService(true, "dialysis[diff]");
                // mod 7853-差分コンバートで更新/削除ができない 楊 end
                // 患者治療パターン
                if (!this.ShowTargetPat())
                {
                    ConvertBase.WriteTraceLog("データ移行対象テーブル情報の取得に失敗しました。");
                }
                dgvPat.SelectAll();
                m_convertTableNames = GetProcTargetTables(_convertPatTreatmentPatternConfig);
                // mod 7853-差分コンバートで更新/削除ができない 楊 start
                this.ConvertPatSpecifyPeriodForService(false, "patientTreatmentPattern[diff]");
                // mod 7853-差分コンバートで更新/削除ができない 楊 end
            }


            // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
            // 装置記録
            if (tableKindSet.Contains("REC")) {

                if (!this.ShowMotionTargetTable(CMB_SELECT_MNT_MOTION_RECORD))
                {
                    ConvertBase.WriteTraceLog("データ移行対象テーブル情報の取得に失敗しました。");
                }
                dgvPat.SelectAll();

                // mod 7853-差分コンバートで更新/削除ができない 楊 start
                this._outputMode = (int)CommonConstants.OutputFormat.CSV;
                this.ConvertMotionForService("convert(motion)[diff]");
                // mod 7853-差分コンバートで更新/削除ができない 楊 end

                // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
            }
            //mod #12484  差分の場合　コンバートツールで処理種別の除外ができない　end


            // #9814 limingyang start
            // ファイルをアップロードする
            string url = NKSConverter.Properties.Settings.Default.ConvertLogFileUploadUrlFormat;
            url = string.Format(url,
                CommonConfig.ConvertRestWebServerIp,
                CommonConfig.ConvertRestWebServerPort
                );
            string strfolder = AppDomain.CurrentDomain.BaseDirectory;
            strfolder += "LOG\\";
            // 書き込みが完了するのを待って、logファイルを圧縮します
            Thread.Sleep(2000);
            // ログファイルを圧縮する
            ZipLogFiles(strfolder);

            List<string> uploadFiles = new List<string>();

            // ログファイル格納先に格納されている圧縮ファイルを全て取得する
            string[] logfiles = System.IO.Directory.GetFiles(strfolder, "*.ZIP", System.IO.SearchOption.TopDirectoryOnly);
            string facilityCd = string.Empty;
            if (CommonConfig.HashValueSet.TryGetValue(this.txtFacilityCd.Text, out var value))
            {
                facilityCd = $"[\"{value}\"]";
            }
            foreach (string strfile in logfiles)
            {
                uploadFiles.Clear();
                uploadFiles.Add(strfile);

                // ファイル名(+拡張子)のみ取得
                string strfilename = System.IO.Path.GetFileName(strfile);

                // ファイルサイズを取得
                System.IO.FileInfo file = new System.IO.FileInfo(strfile);

                Dictionary<string, object> parameters = new Dictionary<string, object>();
                FilePropertyDto fileD = new FilePropertyDto(File.ReadAllBytes(strfile), file.Name, "application/zip");
                parameters[FACILITY_CD_KEY] = facilityCd;
                parameters[LOG_FILES_KEY] = fileD;
                parameters[LOG_FILES_NAME_KEY] = file.Name;

                string msg = FileUploadControl.MultipartPostResquest(url, parameters);
                // アップロード結果判定
                if ("Log uploaded successfully".Equals(msg))
                {
                    // 成功
                    // アップロード対象のログファイルを削除
                    System.IO.File.Delete(strfile);
                }
            }
            // #9814 limingyang end

            ConvertBase.WriteTraceLog("データコンバートが完了しました。");

            this._IsConvertAll = false;
            return true;
        }
        private void getPatIdLatestNo(string facilityCd)
        {

            string key = string.Empty;
            if (CommonConfig.HashValueSet.TryGetValue(facilityCd, out var value))
            {
                key = $"[\"{value}\"]";
            }
            string PatLatestNourl = NKSConverter.Properties.Settings.Default.ConvertgetPatLatestNo;
            string result = HttpControl.sendWebRequestPost(PatLatestNourl, new Dictionary<String, String> { { "facilityCd", key } });
            List<PatIdLatestNo> patList = JsonConvert.DeserializeObject<List<PatIdLatestNo>>(result);

            //#12229 データベースへの一括コミットに変更 start
            string sqlDel = "DELETE FROM SYNC_FNSI_MEDICINE_LATEST_NO WHERE FACILITYCD= :FACILITYCD ";
            IMakeSqlParameters paramDel = db.GetIMakeSqlParameters();
            paramDel.AddParam(":FACILITYCD", this.txtFacilityCd.Text);
            db.ExecuteSQL(sqlDel, paramDel.GetParam());
            int BATCH_SIZE = 1000;
            
            for (int i = 0; i < patList.Count; i += BATCH_SIZE)
            {
                var batch = patList.Skip(i).Take(BATCH_SIZE).ToList();

                StringBuilder sql = new StringBuilder();
                var param = db.GetIMakeSqlParameters();

                sql.AppendLine(
                    "INSERT INTO SYNC_FNSI_MEDICINE_LATEST_NO " +
                    "(PATID, NO, FACILITYCD)"
                );

                for (int idx = 0; idx < batch.Count; idx++)
                {
                    var item = batch[idx];

                    string patIdKey = $":pat_id_{idx}";
                    string noKey = $":no_{idx}";
                    string facKey = $":fac_{idx}";

                    if (idx > 0)
                    {
                        sql.AppendLine("UNION ALL");
                    }

                    sql.AppendLine(
                        $"SELECT {patIdKey}, {noKey}, {facKey} FROM DUAL"
                    );

                    param.AddParam(patIdKey, item.fn_pat_id);
                    param.AddParam(noKey, int.Parse(item.mediInfoNo ?? "0"));
                    param.AddParam(facKey, facilityCd);
                }

                db.ExecuteSQL(sql.ToString(), param.GetParam());
            }

            //#12229 データベースへの一括コミットに変更 end
        }

        private class PatIdLatestNo
        {
            public string patId { get; set; }
            public string mediInfoNo { get; set; }
            public string fn_pat_id { get; set; }
        }
        private bool ZipLogFiles(string strfolder)
        {
            bool bret = true;
            try
            {
                string strfilename;
                // ログファイル格納先に格納されているファイルを全て取得する
                string[] logfiles = System.IO.Directory.GetFiles(strfolder, "*.LOG", System.IO.SearchOption.TopDirectoryOnly);
                string suffix = "";
                foreach (string strfile in logfiles)
                {
                    if (strfile.Contains("TRACE_NKSConverter"))
                    {
                        suffix = strfile.Substring(strfile.Length - 20, 16);
                        break;
                    }
                }
                foreach (string strfile in logfiles)
                {
                    try
                    {
                        // ファイル名(+拡張子)のみ取得
                        strfilename = System.IO.Path.GetFileName(strfile);

                        // 圧縮ファイル名作成
                        string zipfilename = System.IO.Path.ChangeExtension(strfile, "zip");
                        if (zipfilename.Contains("[completely]") || zipfilename.Contains("[diff]") || zipfilename.Contains("[add]"))
                        {
                            zipfilename = zipfilename.Substring(0, zipfilename.Length - 4) + suffix + ".ZIP";
                        }

                        // 圧縮済ファイル名チェック
                        if (System.IO.File.Exists(zipfilename))
                        {
                            // 圧縮済ファイルを削除する
                            System.IO.File.Delete(zipfilename);
                        }

                        // 取得ファイルを圧縮する
                        bool res = TdcLib.TdcLib.CompressZipFile(System.Text.Encoding.GetEncoding("UTF-8"), zipfilename, strfile, string.Empty, null);

                        // 取得ファイルから更新日時を取得する
                        DateTime dtlastwrite = System.IO.File.GetLastWriteTime(strfile);

                        // 本日より前のファイルの場合は削除する

                        // ファイル削除
                        System.IO.File.Delete(strfile);


                    }
                    catch (Exception ex)
                    {
                        ConvertBase.WriteErrorLog("ZipLogFiles:{0}", ex.Message);
                        bret = false;
                    }
                }

            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("ZipLogFiles:{0}", ex.Message);
                bret = false;
            }
            return (bret);
        }
        public void getAV_SN()
        {

            // mod #10178 djy start 
            string sql = @"select ISCHECKED,LINENUMBER,BOOLD,P_A,P_V,P_SN,SERIES_CD from  SYNC_CONDSET";
            // mod #10178 djy end
            DataTable dt = db.SelectTable(sql);
            if (dt != null)
            {
               
                foreach (DataRow row in dt.Rows)
                {
                    string seriesCd = row["SERIES_CD"].ToString(); // key

                    var booldValues = row["Boold"] == DBNull.Value ? new List<string>() : row["Boold"].ToString().Split(',').ToList();
                    var p_AValues = row["p_A"] == DBNull.Value ? new List<string>() : row["p_A"].ToString().Split(',').ToList();
                    var p_VValues = row["p_V"] == DBNull.Value ? new List<string>() : row["p_V"].ToString().Split(',').ToList();
                    var p_SNValues = row["p_SN"] == DBNull.Value ? new List<string>() : row["p_SN"].ToString().Split(',').ToList();
                    CommonConfig.Boold[seriesCd] = booldValues;
                    CommonConfig.p_A[seriesCd] = p_AValues;
                    CommonConfig.p_V[seriesCd] = p_VValues;
                    CommonConfig.p_SN[seriesCd] = p_SNValues;
                                       
                }
              
            }

        }

        private void ConvertAllRecordForService(string dataType)
        {
            // 日時をスタティッククラスに格納

            DateTime dtNow = DateTime.Now;
            //del 8400 zc start
            //CommonConfig.UpDate = dtNow;
            //del 8400 zc end

            // Mod #7997 趙 Start
            //string exportFolderPath = AppDomain.CurrentDomain.BaseDirectory + Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType);
            string exportFolderPath = AppDomain.CurrentDomain.BaseDirectory + Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd + "\\" + string.Format(@"\{2}-ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType, txtFacilityCd.Text);
            // Mod #7997 趙 End
            if (!MakeExportFolderPath(exportFolderPath)) return;

           
            List<string> listSelectedTableLog = GetDgvSelectedRow(dgvPat);
            // mod 8248 患者イベントが一部コンバートされていない 楊 end           
            // 選択したデータグリッドの行Dtoリスト取得
            List<DgvPatRowDto> listSelectedRowList = GetDgvSelectedRowToDto(dgvPat);
            //add #7997 転院患者 start
            if (dataType.Contains("pat") && CacheInformation.Instance.FacilityCd.Equals("1"))
            {

                string sql = @"SELECT
	                    PATID,
	                    FACILITY_CD,PROC_DATE
                    FROM
	                    SYS_PAT_MOVE_PLAN P
	                    INNER JOIN SYNC_FACILITY_CD  F ON P.FROM_SERIES_CD=F.SERIES_CD
                    WHERE
	                    UP_DATE > (
	                    SELECT
		                    max( CONVERT_DATETIME ) 
	                    FROM
		                    SYNC_CONVERT_HISTORY 
	                    WHERE
	                    TABLE_KIND = 'PAT' 
	                    AND FACILITY_CD =:FACILITY_CD ) and  FROM_SERIES_CD=:FROM_SERIES_CD  AND  STATUS='1'  and DEL_FLG='0'";
               
                IMakeSqlParameters param = db.GetIMakeSqlParameters();
                param.AddParam(":FACILITY_CD", CommonConfig.FacilityCd);
                param.AddParam(":FROM_SERIES_CD", CommonConfig.seriesCd);
                DataTable dt = db.SelectTable(sql, param.GetParam());
                if (dt.Rows.Count > 0)
                {
                    using (StreamWriter sw = new StreamWriter(exportFolderPath + "/SYS_PAT_SERIES_FACILITY.txt"))
                    {
                        sw.WriteLine("PATID,FACILITY_CD,PROC_DATE");

                        foreach (DataRow row in dt.Rows)
                        {
                            string patId = row["PATID"].ToString();
                            string facilityCd = row["FACILITY_CD"].ToString();
                            string procDate =row["PROC_DATE"].ToString();
                            sw.WriteLine($"{patId},{facilityCd},{procDate}");
                        }
                    }
                }
                sql = @"SELECT
                        DISTINCT
	                    PATID,PROC_DATE,
                         CASE
                            WHEN NOT EXISTS (
                                SELECT 1
                                FROM SYS_PAT_MOVE_PLAN P2
                                WHERE P2.PATID = P.PATID
                                  AND P2.FROM_SERIES_CD = :SERIES_CD
                                  AND P2.DEL_FLG = '0' and  p2.STATUS = '1'
                                  AND P2.UP_DATE < P.UP_DATE
                            )
                            THEN '1'   
                            ELSE '0'   
                        END AS IS_FIRST
                    FROM
	                    SYS_PAT_MOVE_PLAN P
	                    
                    WHERE
	                    UP_DATE > (
	                    SELECT
		                    max( CONVERT_DATETIME ) 
	                    FROM
		                    SYNC_CONVERT_HISTORY 
	                    WHERE
	                    TABLE_KIND = 'PAT' 
	                    AND FACILITY_CD =:FACILITY_CD ) and  TO_SERIES_CD=:SERIES_CD  AND  STATUS='1'  and DEL_FLG='0'";

                IMakeSqlParameters param1 = db.GetIMakeSqlParameters();
                param1.AddParam(":FACILITY_CD", CommonConfig.FacilityCd);
                param1.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                dt = db.SelectTable(sql, param1.GetParam());
                CommonConfig.patProcInfoList.Clear();
                foreach (DataRow row in dt.Rows)
                {
                    string patId = row["PATID"]?.ToString();
                    if (string.IsNullOrEmpty(patId)) continue;
                    CommonConfig.patProcInfoList.Add(new PatProcInfo
                    {
                        PatId = patId,
                        ProcDate = row["PROC_DATE"].ToString(),
                        isFirst= row["IS_FIRST"].ToString(),
                    });
                }

            }
            //add #7997 転院患者 end
            // コンバート実施
            if (!ConvertTableForAllRecord(listSelectedRowList,
                exportFolderPath,
                null,
                false))
                return;

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);

            Application.DoEvents();
            // コンバート履歴テーブルに登録する
            SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
            SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
            dto.facilityCd = this.txtFacilityCd.Text;
            //mod 8400 zc start
            dto.tableName = "diff";
            var typeKind = "MST";
            if (dataType.Contains("pat"))
            {
                typeKind = "PAT";
            }
            dto.tableKind = typeKind;
            //mod 8400 zc end
            dto.convertDatetime = CommonConfig.UpDate;
            dto.startDate = dtpStartDate.Value.Date;
            dto.endDate = dtpEndDate.Value;
            dto.patidList = new List<String>(listSelectedTableLog);

            dao.Insert(dto);
            if (!_IsConvertAll)
                ShowMsgBoxInfo("データコンバートが完了しました。");
        }

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        private void ConvertMotionForService(string dataType)
        {
            // 日時をスタティッククラスに格納
            DateTime dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;

            // 出力先フォルダ作成
            // Mod #7997 趙 Start
            //string exportFolderPath = AppDomain.CurrentDomain.BaseDirectory + Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType);
            string exportFolderPath = AppDomain.CurrentDomain.BaseDirectory + Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd + string.Format(@"\{2}-ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType, txtFacilityCd.Text);
            // Mod #7997 趙 End

            if (!MakeExportFolderPath(exportFolderPath)) return;

            // 選択したテーブルのリスト取得
            List<string> listSelectedTable = GetDgvSelectedRow(dgvPat, "ntssTable");
            // 選択したデータグリッドの行Dtoリスト取得
            List<DgvPatRowDto> listConvertTableInfoDto = GetDgvSelectedRowToDto(dgvPat);
            // 処理対象のテーブルの進捗状況作成
            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
           // ShowTargetTable(listSelectedTable);
            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
            // 処理対象のテーブルの進捗状況チェックボックス作成
          

            // コンバート実施
            if (!ConvertTableForMotion(listConvertTableInfoDto,
                exportFolderPath,
                false))
                return;

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);

            Application.DoEvents();
            // コンバート履歴テーブルに登録する
            SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
            SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
            dto.facilityCd = this.txtFacilityCd.Text;
            dto.tableKind = "REC";
            dto.convertDatetime = CommonConfig.UpDate;
            dto.startDate = dtpStartDate.Value.Date;
            dto.endDate = dtpEndDate.Value;
            //add 8400 zc start
            dto.tableName = "diff";
            //add 8400 zc end
            dto.patidList = new List<String>(listSelectedTable);

            dao.Insert(dto);
            if (!_IsConvertAll)
                ShowMsgBoxInfo("データコンバートが完了しました。");
        }
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end

        HashSet<string> patIdSet = new HashSet<string>();
        private void ConvertPatSpecifyPeriodForService(bool isRegistConvertHistory, string fileNamePrefix)
        {
            // 患者選択チェック
            if (!CheckPatSelect()) return;

            // 施設コードの入力チェック
            //if (!CheckFacilityCd()) return;

            // 出力先フォルダ作成
            // Mod #7997 趙 Start
            //string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_" + fileNamePrefix, CommonConfig.UpDate.ToString("yyyyMMddHHmmss"));
            string exportFolderPath = Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd+ string.Format(@"\{1}-ExportData_{0}_" + fileNamePrefix, CommonConfig.UpDate.ToString("yyyyMMddHHmmss"), txtFacilityCd.Text);
            // Mod #7997 趙 End

            if (!MakeExportFolderPath(exportFolderPath)) return;

            // 確認ダイアログ(共通処理)
            ConvertBase.WriteTraceLog(string.Format("データエクスポートを開始します。\n対象期間：{0} ～ {1}", dtpStartDate.Value.Date.ToString("yyyy/MM/dd"), dtpEndDate.Value.Date.ToString("yyyy/MM/dd")));

           

            #region 患者情報コンバート処理

            // 選択した患者IDのリスト
            DateTime now = DateTime.Now;
            DateTime planEndDay = new DateTime(now.Year, now.Month, DateTime.DaysInMonth(now.Year, now.Month)).AddYears(1);
            List<string> listSelectedPatId = GetDgvSelectedRow(dgvPat, "PATID");
            if (fileNamePrefix.Equals("dialysis[diff]") && CommonConfig.isDiff)
            {
               
                // 前回実行時間を取得する
                object objRunningStartDate = GetLastDateForDiff("ORD");
                DateTime runningStartDate = (DateTime)objRunningStartDate;

                //mod #10378-24-日次 djy start
                //CreateSyncTable(listSelectedPatId, runningStartDate, planEndDay);
                int yearsDiff = DateTime.Now.Year - runningStartDate.Year;
                int monthsDiff = yearsDiff * 12 + DateTime.Now.Month - runningStartDate.Month;
                if (monthsDiff == 0)
                {
                    listSelectedPatId.Clear();
                    listSelectedPatId = ConvertControl.DiffPatidList(dtpStartDateBefore, dtpEndDateBefore, db);
                    //add 7997 start
                    if (CacheInformation.Instance.FacilityCd.Equals("1")) {

                        string sql = @"SELECT DISTINCT PATID
                                    FROM(
                                    SELECT PATID, FROM_SERIES_CD AS SERIES_CD
                                    FROM SYS_PAT_MOVE_PLAN where STATUS = '1'
                                    UNION ALL
                                    SELECT PATID, TO_SERIES_CD
                                    FROM SYS_PAT_MOVE_PLAN where STATUS = '1'
                                    UNION ALL
                                    SELECT PATID, SERIES_CD
                                    FROM SYS_PAT_SERIES_FACILITY where MAIN_FLG = '1'
                                    ) where SERIES_CD = :SERIES_CD";

                        IMakeSqlParameters param = db.GetIMakeSqlParameters();
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                        DataTable dtPATID = db.SelectTable(sql, param.GetParam());
                         patIdSet = new HashSet<string>(
                                dtPATID.AsEnumerable()
                                       .Select(r => r["PATID"].ToString())
                            );
                        listSelectedPatId = listSelectedPatId
                            .Where(id => patIdSet.Contains(id))
                            .ToList();

                        foreach (PatProcInfo pp in CommonConfig.patProcInfoList)
                        {
                            string patid = pp.PatId;
                            if (!string.IsNullOrEmpty(patid))
                            {
                                listSelectedPatId.Add(patid);
                            }
                        }

                        listSelectedPatId = listSelectedPatId
                            .Distinct()
                            .ToList();
                    }
                    //add 7997 end

                }

                CreateSyncTable(listSelectedPatId, runningStartDate, planEndDay, monthsDiff);
                //mod #10378-24-日次 djy end
                CreateSyncCKHistTable(runningStartDate, planEndDay);
                // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end

                
                if (listSelectedPatId.Count > 0)
                {
                    List<string> plandt = GetLastOrdData(listSelectedPatId, runningStartDate, planEndDay, objRunningStartDate).AsEnumerable().Select(r => r["PATID"].ToString()).ToList<string>();
                    int itemsPerLine = 1000;
                    if (plandt.Count > 0)
                    {
                        using (StreamWriter sw = new StreamWriter(exportFolderPath + "/DelOrdMain.txt"))
                        {
                            for (int i = 0; i < plandt.Count; i += itemsPerLine)
                            {
                                int end = Math.Min(i + itemsPerLine, plandt.Count);
                                List<string> batch = plandt.GetRange(i, end - i);
                                string commaSeparatedString = string.Join(",", batch);
                                sw.WriteLine(commaSeparatedString);
                            }
                        }

                    }

                    //mod #10418 start
                    CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("PATID", 1000, listSelectedPatId, "P_");
                    string rstDelsql =$"SELECT DIALYSIS_NO FROM RST_DIALYSIS WHERE {inResult.Clause} AND DEL_FLG = '1' AND UP_DATE >=:UP_DATE";
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    foreach (var p in inResult.Parameters)
                    {
                        Sqlparam.AddParam(p.Key, p.Value);
                    }
                    Sqlparam.AddParam(":UP_DATE", (DateTime)objRunningStartDate);
                    List<string> rstDel = db.SelectTable(rstDelsql, Sqlparam.GetParam()).AsEnumerable().Select(r => r["DIALYSIS_NO"].ToString()).ToList<string>();
                    //mod #10418 end

                    if (rstDel.Count > 0)
                    {
                        using (StreamWriter sw = new StreamWriter(exportFolderPath + "/DelOrdMainRst.txt"))
                        {
                            for (int i = 0; i < rstDel.Count; i += itemsPerLine)
                            {
                                int end = Math.Min(i + itemsPerLine, rstDel.Count);
                                List<string> batch = rstDel.GetRange(i, end - i);
                                string commaSeparatedString = string.Join(",", batch);
                                sw.WriteLine(commaSeparatedString);
                            }
                        }
                    }
                }
                //mod #10675 & #10676 djy end
            }

            // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
            if (fileNamePrefix.Equals("patientTreatmentPattern[diff]"))
            {
                // 前回実行時間を取得する
    
                // 前回実行開始時間と今回実行開始時間と比べ、同じ月かを判定
                // 同じ月: 更新日が前回コンバートする以降、変更がある患者IDリストを取得する
                // 同じ月じゃない: 全患者を対象として、リストを作成する
                DateTime objRunningStartDate = GetLastDateForDiff("PER");
                if (DateTime.Now.Month == objRunningStartDate.Month)
                {
                    listSelectedPatId.Clear();
                    listSelectedPatId = ConvertControl.DiffPatTreatmentPatternPatidList(db);
                }
                //add 7997 start
                if (CacheInformation.Instance.FacilityCd.Equals("1"))
                {
                    listSelectedPatId = listSelectedPatId
                            .Where(id => patIdSet.Contains(id))
                            .ToList();
                    foreach (PatProcInfo pp in CommonConfig.patProcInfoList)
                    {
                        string patid = pp.PatId;
                        if (!string.IsNullOrEmpty(patid))
                        {
                            listSelectedPatId.Add(patid);
                        }
                    }

                    listSelectedPatId = listSelectedPatId
                        .Distinct()
                        .ToList();
                }
                //add 7997 end
            }
            // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end

            // add #11210 djy start
            if (fileNamePrefix.Equals("inspectionSchedule／result[diff]"))
            {

                if (CommonConfig.isDiff)
                {
                        DateTime objRunningStartDate = GetLastDateForDiff("EXM");
                        //mod #10418 start
                        StringBuilder sb = new StringBuilder();
                        sb.Append("SELECT PATID||TO_CHAR(REG_DATE,'yyyy-mm-dd hh24:mi:ss')");
                        sb.Append("||TO_CHAR(REG_EXAM_DATE,'yyyy-mm-dd hh24:mi:ss')||");
                        sb.Append("CASE REG_ORDER_CLASS WHEN '0' THEN '1' WHEN '1' THEN '2' WHEN '2' THEN '0' END AS KEY");
                        sb.Append(" FROM PAT_EXAMIN_HST_BK WHERE UP_DATE >=:UP_DATE");
                        
                        string delExamSql = sb.ToString();
                        IMakeSqlParameters param = db.GetIMakeSqlParameters();
                        param.AddParam(":UP_DATE", (DateTime)objRunningStartDate);
                        List<string> delExamList = db.SelectTable(delExamSql, param.GetParam()).AsEnumerable().Select(r => r["KEY"].ToString()).ToList<string>();
                        //mod #10418 end
                        if (delExamList.Count > 0)
                        {
                            int itemsPerLine = 1000;
                            using (StreamWriter sw = new StreamWriter(exportFolderPath + "/DelExam.txt"))
                            {
                                for (int i = 0; i < delExamList.Count; i += itemsPerLine)
                                {
                                    int end = Math.Min(i + itemsPerLine, delExamList.Count);
                                    List<string> batch = delExamList.GetRange(i, end - i);
                                    string commaSeparatedString = string.Join(",", batch);
                                    sw.WriteLine(commaSeparatedString);
                                }
                            }
                        }
                }

            }
            // add #11210 djy end

            // 指定期間のリスト
            List<SelectSpan> listSelectSpan = GetSelectSpan(dtpStartDate.Value.Date, planEndDay);


            // 正常終了した患者IDのリスト
            List<string> completedPatIdList;
            // エラーになった患者IDのリスト
            List<string> errorPatIdList = new List<string>();
            completedPatIdList = ConvertPatProcPatidListForService(listSelectedPatId,
                listSelectSpan,
                exportFolderPath,
                errorPatIdList,
                fileNamePrefix
            );

            #endregion

            // add PatTreatmentPattern再構築対応 zkm start
            if (fileNamePrefix.Equals("patientTreatmentPattern[diff]") && listSelectedPatId.Count > 0)
            {
                int itemsPerLine = 1000;
                using (StreamWriter sw = new StreamWriter(exportFolderPath + "/DelPatientTreatmentPattern.txt"))
                {
                    for (int i = 0; i < listSelectedPatId.Count; i += itemsPerLine)
                    {
                        int end = Math.Min(i + itemsPerLine, listSelectedPatId.Count);
                        List<string> batch = listSelectedPatId.GetRange(i, end - i);
                        string commaSeparatedString = string.Join(",", batch);
                        sw.WriteLine(commaSeparatedString);
                    }
                }

            }
            // add PatTreatmentPattern再構築対応 zkm end

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);


            if (isRegistConvertHistory)
            {
                // 処理した患者IDと期間をコンバート履歴テーブルに登録する
                // （処理した患者が存在する場合のみ実行）
                if (completedPatIdList.Count > 0)
                {
                    SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
                    SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
                    dto.facilityCd = this.txtFacilityCd.Text;
                    // mod 7853-差分コンバートで更新/削除ができない 楊 start
                    //dto.tableKind = "ORD";
                    if ("dialysis[diff]".Equals(fileNamePrefix))
                    {

                        dto.tableKind = "ORD";
                    }
                    else
                    {

                        dto.tableKind = "EXM";
                    }
                    // mod 7853-差分コンバートで更新/削除ができない 楊 end
                    //add 8400  zc start
                    dto.tableName = "diff";
                    //add 8400  zc end
                    dto.convertDatetime = CommonConfig.UpDate;
                    dto.startDate = dtpStartDate.Value.Date;
                    dto.endDate = dtpEndDate.Value;
                    dto.patidList = new List<String>(completedPatIdList);
                    dao.Insert(dto);
                }
            }
            else
            {
                // todo yangmj 削除待ち
                // 処理した患者IDと期間をコンバート履歴テーブルに登録する
                // （処理した患者が存在する場合のみ実行）
                if (completedPatIdList.Count > 0)
                {
                    SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
                    SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
                    dto.facilityCd = this.txtFacilityCd.Text;
                    dto.tableKind = "PER";
                    //add 8400  zc start
                    dto.tableName = "diff";
                    //add 8400  zc end
                    dto.convertDatetime = CommonConfig.UpDate;
                    dto.startDate = dtpStartDate.Value.Date;
                    dto.endDate = dtpEndDate.Value;
                    dto.patidList = new List<String>(completedPatIdList);
                    dao.Insert(dto);
                }
            }

            if (errorPatIdList.Count() > 0)
            {
                ConvertBase.WriteTraceLog("データコンバートは完了しましたが、エラーが発生しています。");
            }
            else
            {
                if (!_IsConvertAll)
                    ConvertBase.WriteTraceLog("データコンバートが完了しました。");
            }

            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
            if (m_convertTableNames.Contains("ord_main"))
            {
                // ord-main導出実行完成した後、一時テーブルを作成する
                DelSyncOrdMainSchPlanTemporaryTbl("SYNC_ORD_MAIN_SCH_PLAN");
            }
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end

            // ord_checklist導出実行完成した後、一時データをクリアする
            if (m_convertTableNames.Contains("ord_checklist"))
            {
                ClearDBWithChecklist();
            }

            // 画面設定条件の保存
            SaveAppConfigInputStatus();
        }

        //add #10675 & #10676 djy start     
        private DataTable GetLastOrdData(List<string> listParam,
            DateTime? startDate,
            DateTime? endDate,
            Object lastDate)
        {
            DataTable dt = new DataTable();

            if (listParam.Count < 1)
            {
                return dt;
            }

            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = Path.Combine("SQL\\ord_main_diff", "ORD_MAIN_DIFF_LAST" + ".sql");


            // 患者ID 1000個ずつでループ
            
            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }
            LogManager.WriteTraceLog(null, null, "[情報]" + string.Format("実行SQL：{0}", sqlFilePath));
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    if (sVALUE.Equals("0"))
                    {
                        Regex reg = new Regex(@"(\s)([A-Za-z\._]*\s*=\s*'\{4\}')");
                        sql = reg.Replace(sql, "  1=1");

                    }
                    else {
                        sql = sql.Replace("{4}", ":SERIES_CD");
                    }

                    ////mod #10418 start
                    CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("IND_PLAN.PATID", 1000, listParam, "P_");
                    string listInClauseParam = inResult.Clause;

                    var param = db.GetIMakeSqlParameters();
                    foreach (var p in inResult.Parameters)
                    {
                        param.AddParam(p.Key, p.Value);
                    }
                    param.AddParam(":START_DATE", ((DateTime)startDate).ToString("yyyyMMdd"));
                    param.AddParam(":END_DATE", ((DateTime)endDate).ToString("yyyyMMdd"));
                    param.AddParam(":LASTDATE", (DateTime)lastDate);
                    
                    if (sql.Contains(":SERIES_CD"))
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                    sql = string.Format(sql, new string[] { listInClauseParam});
                    dt = db.SelectTable(sql, param.GetParam());
                }
            }
            catch (Exception e)
            {
                LogManager.WriteErrorLog(null, null, "[エラー]" + "コンバート元データ取得に失敗しました。", e);
            }
            return dt;
        }
        //add #10675 & #10676 djy end

        private DateTime GetLastDateForDiff(string tableKind)
        {
            string dialysisPlanAddTbl = null;
            //add 11753 start
            string dialysisPatid = null;
            //add 11753 end
            //add #12229 start
            ConvertDatetimeResult result = CacheInformation.Instance.GetEffectiveConvertDatetime(tableKind);
            DateTime convertDateTime = result.ConvertDatetime;
            if (result.HasDiff)
            {
                
                dialysisPlanAddTbl = " ( SELECT"
                           + $"  TO_DATE('{convertDateTime}', 'yyyy-MM-dd hh24:mi:ss') AS CONVERT_DATETIME,"
                           + "            START_DATE,"
                           + "             CASE"
                           + "                 WHEN CONVERT_DATETIME = MIN(CONVERT_DATETIME)"
                           + "                      OVER()"
                           + "                THEN  LAST_DAY(ADD_MONTHS(SYSDATE, 12))"
                           + "                 ELSE END_DATE"
                           + "            END AS END_DATE"
                           + "        FROM sync_convert_history"
                           + "         WHERE FACILITY_CD =  :facility_cd"
                           + "          AND TABLE_KIND = '" + tableKind + "'"
                           + "           AND(TABLE_NAME <> 'diff'  OR TABLE_NAME IS NULL)"
                           + "        ) ";


                //add 11753 start
                
                dialysisPatid = " ( SELECT"
                         + $"  TO_DATE('{convertDateTime}', 'yyyy-MM-dd hh24:mi:ss') AS CONVERT_DATETIME,"
                         + "            TO_CHAR(START_DATE, 'YYYYMMDD' ) AS START_DATE,"
                         + "             CASE"
                         + "                 WHEN CONVERT_DATETIME = MIN(CONVERT_DATETIME)"
                         + "                      OVER()"
                         + "                THEN  TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE, 12)), 'YYYYMMDD' )"
                         + "                 ELSE TO_CHAR(END_DATE, 'YYYYMMDD' )  "
                         + "            END AS END_DATE"
                         + "        FROM sync_convert_history"
                         + "         WHERE FACILITY_CD = :facility_cd"
                         + "          AND TABLE_KIND = 'ORD'"
                         + "           AND(TABLE_NAME <> 'diff'  OR TABLE_NAME IS NULL)"
                         + "        ) ";
                //add 11753 end
            }
            else
            {
                
                dialysisPlanAddTbl = " ("
                    + " SELECT CONVERT_DATETIME,START_DATE,  LAST_DAY(ADD_MONTHS(SYSDATE, 12)) AS end_date "
                    + $"FROM sync_convert_history  where CONVERT_DATETIME =TO_DATE('{convertDateTime}', 'yyyy-MM-dd hh24:mi:ss') "
                    + " and facility_cd =:facility_cd  and  table_kind = '" + tableKind + "') ";

                //add 11753 start
                dialysisPatid = @" (SELECT
                   CONVERT_DATETIME,
                    TO_CHAR(START_DATE, 'YYYYMMDD') AS START_DATE,
                    TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE, 12)) +1, 'YYYYMMDD')  AS END_DATE
                  FROM
                    (SELECT CONVERT_DATETIME, START_DATE FROM SYNC_CONVERT_HISTORY WHERE TABLE_KIND = 'ORD' AND FACILITY_CD = :facility_cd  ORDER BY CONVERT_DATETIME)
                  WHERE
                    ROWNUM = 1) ";

            }
           
            CommonConfig.dialysisPlanHistTblSql = dialysisPlanAddTbl;

            //add #12229 start
            if (tableKind.Equals("ORD")) {
                //add #12229 end
                CommonConfig.dialysisPatidTblSql = dialysisPatid;
                //add 11753 end
            }
            //add #12229 end
            return convertDateTime;
        }

        private string MakeInClause(string columnName, int chunkSize, List<string> list)
        {

            string inClause = "(" + string.Join(" OR ", list.Select((v, i) => new { v, i })
                .GroupBy(x => x.i / chunkSize)
                .Select(g => columnName + " in (" + string.Join(",", g.Select(x => "'" + x.v + "'").ToArray()) + ")")
                .ToArray()) + ")";

            return inClause;
        }

        private List<string> ConvertPatProcPatidListForService(List<string> listSelectedPatId,
            List<SelectSpan> listSelectSpan,
            string exportFolderPath,
            List<string> listErrorPatAll,
            String fileNamePrefix
            )
        {
            string[] filesp = exportFolderPath.Split('_');
            string fileName = "";
            BuildConvertStatus bcs = new BuildConvertStatus();
            bool issaveStatus = true;
            List<string> fileStatus = new List<string>();
            string LogInfo = "";
            _lbSQLFileBuildStatus.Items.Clear();
            if (filesp.Length == 3)
            {
                //mod #9696 djy start
                //fileName = filesp[2];
                fileName = ReplaceLogName(filesp[2]);
                //mod #9696 djy end
                if (bcs.CreateStatusFile(fileName))
                {
                    LogInfo = fileName + "ファイル作成の進捗";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo);
                    issaveStatus = true;
                }
                else
                {
                    issaveStatus = false;
                }
            }
            else
            {
                issaveStatus = false;
            }

            // 選択されている患者IDを処理件数ずつに分割
            int chunkSize = 20;
            // #10679 add マルチスレッドを追加しました start
            int threadSize = 1;
            bool useMultiThread = false;

            var writerMap = new ConcurrentDictionary<string, SqlBatchFileWriter>();
            if (CommonConfig.isDiff && fileNamePrefix.Equals("dialysis[diff]"))
            {
                useMultiThread = true;
                //chunkSize = NKSConverter.Properties.Settings.Default.dialysisChunkSize;
                threadSize = NKSConverter.Properties.Settings.Default.dialysisThreadSize;

                //add #12229 患者データはすべて一つのファイルに書き込まれる start
                if (listSelectedPatId.Count >0) {
                    chunkSize = 8;
                    foreach (string tableName1 in m_convertTableNames)
                    {
                        
                        string tableName;
                        int idx = tableName1.IndexOf('-');
                        if (idx >= 0)
                        {
                            tableName = tableName1.Substring(idx + 1);
                        }
                        else
                        {

                            tableName = tableName1;
                        }
                        string exportFolderPaths = Path.Combine(exportFolderPath, CommonConfig.FacilityCd);
                        writerMap.TryAdd(
                            tableName,
                            new SqlBatchFileWriter(
                                exportFolderPaths,
                                tableName,
                                tableName.EndsWith(".csv") ? ".csv" : ".sql",
                                new UTF8Encoding(false),
                                tableName.EndsWith(".csv") ? BatchFileType.Csv : BatchFileType.Sql
                            )
                        );
                    }
                    CommonConfig.writerMapType = writerMap;
                }
                //add #12229  患者データはすべて一つのファイルに書き込まれる end
            }
            // #10679 add マルチスレッドを追加しました end
            var listPatidList = listSelectedPatId.Select((patid, index) => new { patid, index })
                .GroupBy(x => x.index / chunkSize)
                .Select(g => g.Select(x => x.patid));
            // 処理対象患者件数
            int patIdCount = listSelectedPatId.Count;
            // #10679 del
            // 処理済患者件数
            //int finishedPatIdCount = 0;
            // #10679 del
            // 処理正常終了患者IDリスト
            List<string> completedPatIdList = new List<string>();
            // 患者IDエラーリスト
            if (listErrorPatAll == null)
                listErrorPatAll = new List<string>();

            
            if (useMultiThread)
            {
                int startRowIndex = 0;
                ConverterTaskGroup<ConvertPatProcPatidListWork> taskGroup = new ConverterTaskGroup<ConvertPatProcPatidListWork>(threadSize);
                foreach (var procPatidList in listPatidList)
                {
                    taskGroup.addWork(new ConvertPatProcPatidListWork(procPatidList, startRowIndex));
                    startRowIndex++;
                }
                
                taskGroup.run((work) =>
                {

                    ConvertPatProcPatidListDiffFunc(
                        listSelectSpan,
                        exportFolderPath,
                        listErrorPatAll,
                        fileName,
                        bcs,
                        issaveStatus,
                        completedPatIdList,
                        ref work.startRowIndex,
                        work.procPatidList,
                        true);
                });

                //add #12229 差分の場合,患者データはすべて一つのファイルに書き込まれる start
                if (CommonConfig.isDiff && fileNamePrefix.Equals("dialysis[diff]") && listSelectedPatId.Count>0) {
                    foreach (var writer in writerMap.Values)
                    {
                        writer.Dispose();
                    }
                }
                //add #12229 差分の場合,患者データはすべて一つのファイルに書き込まれる end
            }
            else
            {
                int chkRowIndex = 0;
                foreach (var procPatidList in listPatidList)
                {
                    ConvertPatProcPatidListDiffFunc(
                        listSelectSpan,
                        exportFolderPath,
                        listErrorPatAll,
                        fileName,
                        bcs,
                        issaveStatus,
                        completedPatIdList,
                        ref chkRowIndex,
                        procPatidList,
                        false);

                }
            }
            // #10679 add マルチスレッドを追加しました end

            // エラー患者ID一覧を出力
            if (listErrorPatAll.Count > 0)
            {
                ConvertBase.WriteTraceLog("エラー患者ID一覧：");
                listErrorPatAll.ForEach(s => ConvertBase.WriteTraceLog(s));
                if (issaveStatus)
                {
                    string LogInfo1 = "エラー患者ID一覧：";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                    listErrorPatAll.ForEach(s => fileStatus.Add(s));
                    listErrorPatAll.ForEach(s => _lbSQLFileBuildStatus.Items.Add(s));
                }
            }
            return completedPatIdList.Distinct().ToList();
        }

        // #10679 add 患者IDリストで差分コンバート処理を実施する start
        /// <summary>
        /// 患者IDリストで差分コンバート処理を実施する
        /// </summary>
        /// <param name="listSelectSpan">対象期間</param>
        /// <param name="exportFolderPath">出力パス</param>
        /// <param name="listErrorPatAll">エラー患者IDリスト</param>
        /// <param name="fileName"></param>
        /// <param name="bcs"></param>
        /// <param name="issaveStatus"></param>
        /// <param name="completedPatIdList"></param>
        /// <param name="chkRowIndex"></param>
        /// <param name="procPatidList"></param>
        /// <param name="useMultiThread"></param>
        /// 
        private void ConvertPatProcPatidListDiffFunc(
            List<SelectSpan> listSelectSpan,
            string exportFolderPath,
            List<string> listErrorPatAll,
            string fileName,
            BuildConvertStatus bcs,
            bool issaveStatus,
            List<string> completedPatIdList,
            ref int chkRowIndex,
            IEnumerable<string> procPatidList,
            bool useMultiThread)
        {
            List<string> fileStatus = new List<string>();

            // 選択した患者リストへ分割した患者リストを代入
            List<string> chunkPatIdList = procPatidList.ToList();

            // コンバートクラスインスタンス化
            ConvertControl convertControl = CreateConvertControl(ConvertControl.CONV_TYPE.PAT_SPECIFY_PERIOD);

            ConvertBase.WriteTraceLog("##### 患者IDグループ処理開始 #####");
            ConvertBase.WriteTraceLog("対象患者ID：{0}", string.Join(",", chunkPatIdList.ToArray()));

            if (issaveStatus)
            {
                string LogInfo1 = "##### 患者IDグループ処理開始 #####";
                string LogInfo2 = string.Format("対象患者ID：{0}", string.Join(",", chunkPatIdList.ToArray()));
                SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                SaveAndShowLogStr(bcs, fileName, "", LogInfo2);
            }

            // 指定期間ごとにコンバート
            foreach (var selectSpan in listSelectSpan)
            {
                foreach (string convertTableName in m_convertTableNames)
                {
                    GC.Collect();
                    GC.WaitForPendingFinalizers();
                    string[] tableNameVS = convertTableName.Split('-');
                    string tableName = tableNameVS[tableNameVS.Length - 1];

                    Stopwatch stopwatch = Stopwatch.StartNew();

                    ConvertBase.WriteTraceLog("##### データエクスポート開始 #####");
                    ConvertBase.WriteTraceLog("テーブル名：{0}", convertTableName);
                    if (issaveStatus)
                    {
                        string LogInfo1 = "##### データエクスポート開始 #####";
                        string LogInfo2 = string.Format("テーブル名：{0}", tableName);
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo2);
                    }

                    #region 初期化処理(共通処理)

                    DBCtrl dbWork;
                    if (useMultiThread)
                    {
                        dbWork = ConvertControl.DBConnectFnw();
                    }
                    else
                    {
                        dbWork = this.db;
                    }
                    var isSuccess = convertControl.Init(dbWork, convertTableName);
                    if (isSuccess == false)
                    {
                        if (issaveStatus)
                        {
                            string LogInfo1 = "初期化に失敗しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                        continue;
                    }
                    if (issaveStatus)
                    {
                        string LogInfo1 = "初期化に成功しました。";
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                    }
                    #endregion

                    #region コンバート元データ取得(コンバート/エクスポート用処理)

                    if (useMode == Mode.Convert || useMode == Mode.Export)
                    {
                        Application.DoEvents();

                        // コンバート元データ取得
                        isSuccess = convertControl.SetFnwData(chunkPatIdList, null, selectSpan.startDate, selectSpan.endDate, false);
                        // 対象期間をログ出力
                        ConvertBase.WriteTraceLog("取得対象期間：{0} ～ {1}", selectSpan.startDate.ToString("yyyy/MM/dd"), selectSpan.endDate.ToString("yyyy/MM/dd"));

                        if (isSuccess == false)
                        {
                            if (issaveStatus)
                            {
                                string LogInfo1 = "コンバート元データ取得に失敗しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // 取得失敗
                            continue;
                        }
                        else if (convertControl.GetFnwDataRowCount() == 0)
                        {
                            if (issaveStatus)
                            {
                                string LogInfo1 = "元のデータは存在しない。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // 選択した全患者において元データが存在しない場合は次のテーブルへ
                            continue;
                        }
                        if (issaveStatus)
                        {
                            string LogInfo1 = "コンバート元データ取得に成功しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                    }
                    #endregion

                    #region コンバート実施(コンバート/エクスポート用処理)

                    if (useMode == Mode.Convert || useMode == Mode.Export)
                    {
                        Application.DoEvents();
                        // 患者IDエラーリスト
                        var listErrorPat = new List<string>();

                        // コンバート実施
                        isSuccess = convertControl.Convert(listErrorPat);
                        if (isSuccess == false)
                        {
                            if (issaveStatus)
                            {
                                string LogInfo1 = "コンバート実施に失敗しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // 失敗時は次のテーブルへ
                            continue;
                        }
                        else if (listErrorPat.Count > 0)
                        {
                            // 患者IDエラーリストへエラー患者IDを追加
                            listErrorPatAll.AddRange(listErrorPat);
                        }
                        if (issaveStatus)
                        {
                            string LogInfo1 = "コンバート実施に成功しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                    }
                    #endregion

                    #region エクスポート(エクスポート用処理)

                    if (useMode == Mode.Export)
                    {
                        Application.DoEvents();
                        //#12229 mni_monitor sql-> scv start
                        // 常にInsert文を作成
                        isSuccess = convertControl.Export(exportFolderPath,
                        encoding, true,
                        true,
                        (CommonConstants.OutputFormat)Enum.ToObject(typeof(CommonConstants.OutputFormat), "ord_checklist".Equals(convertTableName) || "mni_monitor".Equals(convertTableName) ? 1 : this._outputMode),
                        int.Parse(Settings.Default.ChunkSize));
                        //#12229 mni_monitor sql-> scv end

                        if (isSuccess == false)
                        {
                            if (issaveStatus)
                            {
                                string LogInfo1 = "Insert文の制作に失敗しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            continue;
                        }
                        if (issaveStatus)
                        {
                            string LogInfo1 = "Insert文の制作に成功しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                    }

                    #endregion

                    ConvertBase.WriteTraceLog("経過時間：{0}:{1}", stopwatch.Elapsed.Minutes.ToString("00"), stopwatch.Elapsed.Seconds.ToString("00"));
                    ConvertBase.WriteTraceLog("##### データエクスポート完了 #####");

                    if (issaveStatus)
                    {
                        string LogInfo1 = String.Format("達成時間：{0}", DateTime.Now.ToLongTimeString());
                        string LogInfo2 = "##### データエクスポート完了 #####";
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo2);
                    }
                }
            }
            chkRowIndex++;
            // 正常終了患者IDリストへ追加
            List<string> completedPatIdListWork = new List<string>(chunkPatIdList);
            completedPatIdListWork.RemoveAll(s => listErrorPatAll.Contains(s));
            lock (locker)
            {
                completedPatIdList.AddRange(completedPatIdListWork);
            }
            ConvertBase.WriteTraceLog("##### 患者IDグループ処理終了 #####");
            if (issaveStatus)
            {
                string LogInfo1 = "##### 患者IDグループ処理終了 #####";
                SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
            }
            GC.Collect();
            GC.WaitForPendingFinalizers();
        }
        // #10679 add 患者IDリストで差分コンバート処理を実施する end

        private void ConvertMongoDBForService(string fileNamePrefix)
        {
            var dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;

            // 患者選択チェック
            //if (!CheckPatSelect()) return;

            // 施設コードの入力チェック
            if (!CheckFacilityCd()) return;

            // 出力先フォルダ作成
            string turnType = checkTurnType();
            // Mod #7997 趙 Start
            //string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_" + fileNamePrefix + "[" + turnType + "]", dtNow.ToString("yyyyMMddHHmmss"));
            string exportFolderPath = Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd+"\\"+ string.Format(@"\{1}-ExportData_{0}_" + fileNamePrefix + "[" + turnType + "]", dtNow.ToString("yyyyMMddHHmmss"), txtFacilityCd.Text);
            // Mod #7997 趙 End

            if (!MakeExportFolderPath(exportFolderPath)) return;

            #region 患者情報コンバート処理

            // 選択した患者IDのリスト
            List<string> listSelectedPatId = GetDgvSelectedRow(dgvPat, "ntssTable");
            // 指定期間のリスト
            List<SelectSpan> listSelectSpan = GetSelectSpan(dtpStartDate.Value.Date, dtpEndDate.Value.Date);
            // 正常終了した患者IDのリスト
            List<string> completedPatIdList;
            // エラーになった患者IDのリスト
            List<string> errorPatIdList = new List<string>();
            completedPatIdList = ConvertMongoDBList(listSelectedPatId,
                listSelectSpan,
                exportFolderPath,
                errorPatIdList
            );

            #endregion

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);


            // 処理した患者IDと期間をコンバート履歴テーブルに登録する
            // （処理した患者が存在する場合のみ実行）
            if (completedPatIdList.Count > 0)
            {
                SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
                SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
                dto.facilityCd = this.txtFacilityCd.Text;
                dto.tableKind = "HIS";
                //add 8400 zc start
                dto.tableName = "diff";
                //add 8400 zc end
                dto.convertDatetime = CommonConfig.UpDate;
                dto.startDate = dtpStartDate.Value.Date;
                dto.endDate = dtpEndDate.Value;
                dto.patidList = new List<String>(completedPatIdList);
                dao.Insert(dto);
            }

            if (errorPatIdList.Count() > 0)
            {
                // Mod #7997 趙 Start
                //ShowMsgBoxWarning("データコンバートは完了しましたが、エラーが発生しています。");
                ShowMsgBoxWarning("データコンバートは完了しましたが、エラーが発生しています。" + "施設コード：" + txtFacilityCd.Text);
                // Mod #7997 趙 End
            }
            else
            {
                if (!_IsConvertAll)
                    ShowMsgBoxInfo("データコンバートが完了しました。");
            }
            // 画面設定条件の保存
            SaveAppConfigInputStatus();
        }
        // add FNSI-差分コンバート対応 楊 end

        // add 2020-12-11 画面表示設定 う start
        public void FormShowState()
        {
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
        }
        // add 2020-12-11 画面表示設定 う end

        public DataGridView CurrentDgv { get => dgvPat; }
        public ComboBox CurrentcmbDataType { get => cmbDataType; }

        public string StartDate => dtpStartDate.Value.ToString("yyyyMMdd");
        public string EndDate => dtpEndDate.Value.ToString("yyyyMMdd");

        // Mod #7997 趙 Start
        //public string public_txtFacilityCd { get => txtFacilityCd.Text; }
        public string public_txtFacilityCd { get => txtFacilityCd != null ? txtFacilityCd.Text : ""; }
        // Mod #7997 趙 End

        public bool IsUserClose = false;

        /// <summary>
        /// 全件移行対象（マスタ・患者情報）設定
        /// 起動時に設定XMLからロード
        /// </summary>
        public ConfigInfoDto _convertAllRecordConfig;

        /// <summary>
        /// 患者毎期間指定移行対象設定
        /// 起動時に設定XMLからロード
        /// </summary>
        public ConfigInfoDto _convertPatSpecifyPeriodConfig;

        // add FNSI-検査結果対応 楊 start
        /// <summary>
        /// 患者毎期間検査結果設定
        /// 起動時に設定XMLからロード
        /// </summary>
        public ConfigInfoDto _convertPatExamRadConfig;
        // add FNSI-検査結果対応 楊 end

        /// <summary>
        /// 患者治療パターン移行対象設定
        /// 起動時に設定XMLからロード
        /// </summary>
        public ConfigInfoDto _convertPatTreatmentPatternConfig;

        /// <summary>
        /// 指示履歴コンバート移行対象設定
        /// 起動時に設定XMLからロード
        /// </summary>
        public ConfigInfoDto _convertIndHistoryConfig;

        //add 6886  鄭    インポートmongo  start
        /// <summary>
        /// 患者情報MONGOコンバート移行対象設定
        /// 起動時に設定XMLからロード
        /// </summary>
        public ConfigInfoDto _convertPatMongoConfig;
        //add 6886  鄭    インポートmongo  end

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// 装置記録情報コンバート移行対象設定
        /// 起動時に設定XMLからロード
        /// </summary>
        public ConfigInfoDto _convertMotionConfig;
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end

        private Dictionary<string,List<int>> LstDgvPatSelectedIndex = new Dictionary<string, List<int>>();

        private bool isAddItems(DataTable dt, string key)
        {
            return dt.AsEnumerable().Where(r => key.Equals(r["TABLE_KIND"].ToString())).Count()>0;
        }

        /// <summary>
        /// フォームロード処理
        /// </summary>
        /// <remarks>
        /// 使用モードに応じたDB接続を行う
        /// </remarks>
        public void MainForm_Load(object sender, EventArgs e)
        {
            if (IsInit)
            {
                return;
            }
  

            // add FNSI-差分コンバート対応 楊 start
            CommonConfig.isDiff = false;
            // add FNSI-差分コンバート対応 楊 end

            var isDBSuccessFnw = DBConnectFnw();
            if (isDBSuccessFnw == false)
            {
                ShowMsgBoxError("DB接続に失敗しました。\nFNW+DBに接続できる環境で使用してください。");
                Close();
                return;
            }

            useMode = MainForm.Mode.Export;

            // データ種別コンボボックスの初期化
            //10859-2 LSN MOD START

            // 7997 start
           
            string serCd = tabControlSd.SelectedTab.Tag.ToString();
            setcmbDataType(serCd);
            
            //10859 - 2 LSN MOD END


            // 系列施設コード設定
           // SetCmbSeriesCd();

            // add zl start
            LoadReturnRecords();
            // add zl end

            // 全件移行対象（マスタ・患者情報）設定ロード
            _convertAllRecordConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_ALL_RECORD_XML_FILE_PATH);

            // 患者毎期間指定移行対象設定ロード
            _convertPatSpecifyPeriodConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_PAT_SPECIFY_PERIOD_XML_FILE_PATH);

            // add FNSI-検査結果対応 楊 start
            // 患者毎検査結果設定ロード
            _convertPatExamRadConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_PAT_EXAM_RAD_XML_FILE_PATH);
            // add FNSI-検査結果対応 楊 end

            // 患者治療パターン移行対象設定ロード
            _convertPatTreatmentPatternConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CONVERT_PAT_TREATMENT_PATTERN_XML_FILE_PATH);

            // 2021-1-12 601 指示履歴コンバート   う   Start
            // 指示履歴コンバート移行対象設定ロード
            _convertIndHistoryConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CMB_SELECT_INDICATES_HISTORY_XML_FILE_PATH);

            //add 6886  鄭    患者情報インポートmongo  start
            _convertPatMongoConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CMB_SELECT_PAT_PERSONAL_MAIN_HISTORY_XML_FILE_PATH);
            //add 6886  鄭    患者情報インポートmongo  end

            // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
            // 装置記録コンバート移行対象設定ロード
            _convertMotionConfig = ConfigInfoDtoUtil.getConfigXml(CommonConstants.CMB_SELECT_MOTION_XML_FILE_PATH);
            // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end

            // 権限設定XML初期設定
            // 権限設定XMLファイル、SQLファイルが存在しない場合処理終了
            // エクセプションが飛ぶ
            try
            {
                AuthoritySettingsDtoUtil.init();
            }
            catch (Exception ex)
            {
                ShowMsgBoxError("権限設定XML初期設定時にエラーが発生しました。" + System.Environment.NewLine +
                    ex.ToString());
                Close();
            }

            chkSelectAllPat.Enabled = true;
            chkSelectAllSpan.Enabled = true;

            if (cmbDataType.Items.Contains(CMB_SELECT_ALL_RECORD_PAT)) 
            {
                // 対象患者表示
                var isSuccess = ShowTargetPat();
                if (isSuccess == false)
                {
                    ShowMsgBoxError("データ移行対象患者の取得に失敗しました。");
                    Close();
                    return;
                }
            }
            this.cmb_select = cmbDataType;
           
        }

        /// <summary>
        /// 完全 追加 差分
        /// </summary>
        /// <param name="dataType"></param>
        /// <returns></returns>
        private string checkTurnType()
        {
            string TurnType = "";
            if (dgvPat.Rows.Count == dgvPat.SelectedRows.Count)
            {
                //TurnType = "完全";
                TurnType = "completely";
            }
            else
            {
                //TurnType = "追加";
                TurnType = "add";
            }
            if (chkExclusion.Enabled == true && chkExclusion.Checked == true)
            {
                //TurnType = "差分";
                // TurnType = "diff";
                TurnType = "exclusion";
            }
            return TurnType;
        }

      

        /// <summary>
        /// ConfigDtoから処理対象テーブルのリストを取得する
        /// </summary>
        /// <param name="dto"></param>
        /// <returns></returns>
        private List<string> GetProcTargetTables(ConfigInfoDto dto)
        {
            List<string> ret = new List<string>();
            foreach (rootNodeTableInfo info in dto.tableInfo)
            {
                if (info.fnwTableName != null && !info.fnwTableName.Equals(""))
                {
                    string convertTableName = info.fnwTableName.ToString() + "-" + info.ntssTableName.ToString();
                    ret.Add(convertTableName);
                }
                else
                {
                    ret.Add(info.ntssTableName.ToString());
                }
            }
            return ret;
        }

        //add 7726   抽出された繰返し日の取得 鄭 start
        private string GeWithdrawalDateTables(string type, string name)
        {
           
            string log = string.Empty;
            // mod #12484 コンバートツールで処理種別の除外ができない limingzhe start
            
            List<string> listSelectedPatId = new List<string>();
            if (!this.cmbDataType.SelectedItem.ToString().Contains(CMB_SELECT_ALL))
            {
                listSelectedPatId = GetDgvSelectedRow(dgvPat, "PATID");
            }
            // mod #12484 コンバートツールで処理種別の除外ができない limingzhe end

            //mod #10148 start
            string sql = @" select a.START_DATE, a.END_DATE, b.CONVERTTS
                        from SYNC_CONVERT_HISTORY a
                        join SYNC_CONVERT_HISTORY_DTL b on a.SEQ_NO = b.SEQ_NO
                        where a.TABLE_KIND = :TABLE_KIND
                        and a.TABLE_NAME = :TABLE_NAME";

            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":TABLE_KIND", type);
            param.AddParam(":TABLE_NAME", name);
            
            if (listSelectedPatId != null && listSelectedPatId.Count > 0)
            {
                CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition(" b.CONVERTTS", 1000, listSelectedPatId, "P_");
                string inClause = inResult.Clause;         
                foreach (var p in inResult.Parameters)
                {
                    param.AddParam(p.Key, p.Value);
                }
                sql += $" and {inClause}";
            }
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10148 end

            if (dt.Rows.Count == 0)
            {
                return "";
            }
            else
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    DateTime start = (DateTime)dt.Rows[i]["START_DATE"];
                    DateTime end = (DateTime)dt.Rows[i]["END_DATE"];
                    if (DateTime.Compare(dtpEndDate.Value.Date, start) < 0 || DateTime.Compare(end, dtpStartDate.Value.Date) < 0)
                    {
                        continue;
                    }
                    else
                    {
                        log = @"指定期間(" + start.ToString("yyyy-MM-dd") + "～" + end.ToString("yyyy-MM-dd") + ")に重複が発生しています。既にコンバートされているデータはスキップされます。コンバートを実行しますか？";
                        break;
                    }

                }
            }

            return log;

        }
        //add 7726  抽出された繰返し日の取得 鄭 end
        /// <summary>
        /// コンバート対象患者をデータグリッドビューに表示
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        private bool ShowTargetPat()
        {

            string sVALUE = "0";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }


            var sql = new StringBuilder(@"
                        SELECT
                            a.PATID,
                            a.DISP_PATID,
                            a.NAME 
                        FROM
                            pat_basic_info a
                            INNER JOIN pat_index_info b ON a.patid = b.patid AND a.reg_date = b.pat_reg_date
                            INNER JOIN (SELECT DISTINCT PATID, SERIES_CD
				            FROM (
				            SELECT PATID, FROM_SERIES_CD AS SERIES_CD
				            FROM SYS_PAT_MOVE_PLAN where  STATUS='1'  and DEL_FLG='0'
				            UNION ALL
				            SELECT PATID, TO_SERIES_CD
				            FROM SYS_PAT_MOVE_PLAN where  STATUS='1'  and DEL_FLG='0'
				            UNION ALL
				            SELECT PATID, SERIES_CD
				            FROM SYS_PAT_SERIES_FACILITY where MAIN_FLG='1'
				            )) d ON a.patid = d.patid
                        WHERE
                            b.PAT_STATUS = '0'
                        ");

            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            

            if (sVALUE.Equals("1"))
            {
                if (CommonConfig.isDiff)
                {
                    sql.Append(" AND d.SERIES_CD = :SERIES_CD");
                    param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                }
                else {
                    sql.Append(" AND d.SERIES_CD = :SERIES_CD");
                    param.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
                }
               
            }

            sql.Append(" ORDER BY a.patid");

            var tbPat = db.SelectTable(sql.ToString(), param.GetParam());
            if (tbPat == null)
            {
                ConvertBase.WriteErrorLog("コンバート対象患者の取得に失敗しました。");
                return false;
            }
            dgvPat.DataSource = tbPat;
            // セルを未選択状態にする
            dgvPat.CurrentCell = null;
            return true;
        }

        /// <summary>
        /// 期間指定対象テーブルを取得・表示する
        /// </summary>
        /// <returns></returns>
        private bool ShowTargetTableForSpecifyPeriod()
        {
            // 設定XMLファイル一覧取得
            string[] filePaths = Directory.GetFiles(
                CommonConstants.PERIOD_XML_FILE_PATH, "*.xml");

            DataTable convertInfo = new DataTable();
            convertInfo.Columns.Add("table");
            convertInfo.Columns.Add("ntssTable");
            foreach (string filePath in filePaths)
            {
                // DTOに変換
                ConfigInfoDto dto = ConfigInfoDtoUtil.getConfigXml(filePath);

                DataRow newRow = convertInfo.NewRow();
                newRow["table"] = dto.tableInfo[0].fnwTableName;
                newRow["ntssTable"] = dto.tableInfo[0].ntssTableName;
                convertInfo.Rows.Add(newRow);
            }

            dgvPat.DataSource = convertInfo;
            // セルを未選択状態にする
            dgvPat.CurrentCell = null;
            return true;
        }

        public List<DgvPatRowDto> GetListMstAndPat()
        {
            List<DgvPatRowDto> res = new List<DgvPatRowDto>();
            foreach (rootNodeTableInfo node in _convertAllRecordConfig.tableInfo)
            {
                if (node.convertKind.ToString() == "MST")
                {
                    res.Add(new DgvPatRowDto()
                    {
                        fkey = node.fnwPk,
                        fnwTableName = node.fnwTableName,
                        ntssTableName = node.ntssTableName,
                        type = CMB_SELECT_ALL_RECORD_MST
                    });
                }
                else if (node.convertKind.ToString() == "PAT")
                {
                    res.Add(new DgvPatRowDto()
                    {
                        fkey = node.fnwPk,
                        fnwTableName = node.fnwTableName,
                        ntssTableName = node.ntssTableName,
                        type = CMB_SELECT_ALL_RECORD_PAT
                    });
                }
                // mod FNSI-指示履歴の修正 楊 start
                else if (node.convertKind.ToString() == "IND")
                {
                    res.Add(new DgvPatRowDto()
                    {
                        fkey = node.fnwPk,
                        fnwTableName = node.fnwTableName,
                        ntssTableName = node.ntssTableName,
                        type = CMB_SELECT_INDICATES_HISTORY
                    });
                }
                // mod FNSI-指示履歴の修正 楊 end
            }
            return res;
        }

        // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
        public string GetConvertKindByConvertType(string convertType)
        {
            string convertKind = string.Empty;
            switch (convertType)
            {
                // 患者情報
                case CMB_SELECT_ALL_RECORD_PAT:
                    convertKind = "PAT";
                    break;
                // マスタ情報
                case CMB_SELECT_ALL_RECORD_MST:
                    convertKind = "MST";
                    break;
                // 指示履歴
                case CMB_SELECT_INDICATES_HISTORY:
                    convertKind = "IND";
                    break;
            }
            return convertKind;
        }
        public List<DgvPatRowDto> GetConvertInfoListByConvertType(string convertType)
        {
            string convertKind = GetConvertKindByConvertType(convertType);
            List<DgvPatRowDto> res = new List<DgvPatRowDto>();
            foreach (rootNodeTableInfo node in _convertAllRecordConfig.tableInfo)
            {
                if (node.convertKind.ToString() == convertKind)
                {
                    res.Add(new DgvPatRowDto()
                    {
                        fkey = node.fnwPk,
                        fnwTableName = node.fnwTableName,
                        ntssTableName = node.ntssTableName,
                        type = convertType
                    });
                }
            }
            return res;
        }
        private bool ShowTargetType(string dataType)
        {
            DataTable convertInfo = new DataTable();
            convertInfo.Columns.Add("dataType");
            convertInfo.Columns.Add("kind");
            List<String> list = GetTargetType();
            foreach (var item in list)
            {
                DataRow newRow = convertInfo.NewRow();
                newRow["dataType"] = item;
                newRow["kind"] = dataType;
                convertInfo.Rows.Add(newRow);
            }
            dgvPat.DataSource = convertInfo;
            dgvPat.Columns["kind"].Visible = false;
            dgvPat.Columns["dataType"].HeaderText = "移行データ種別名";
            dgvPat.CurrentCell = null;
            return true;
        }
        public List<String> GetTargetType()
        {
            List<String> list = new List<string>();
            foreach (var item in cmbDataType.Items)
            {
                if (item.ToString().Contains(CMB_SELECT_ALL)) continue;
                list.Add(item.ToString());
            }
            return list;
        }
        // add #12484 コンバートツールで処理種別の除外ができない limingzhe end
        /// <summary>
        /// コンバート対象をデータグリッドビューに表示
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        private bool ShowTargetTable(string dataType)
        {
            if (CMB_SELECT_ALL.Equals(dataType))
            {
                dgvPat.DataSource = null;
                return true;
            }
            if (CMB_SELECT_ALL_ADD.Equals(dataType))
            {
                dgvPat.DataSource = null;
                return true;
            }

            DataTable convertInfo = new DataTable();
            convertInfo.Columns.Add("table");
            convertInfo.Columns.Add("ntssTable");
            convertInfo.Columns.Add("type");
            convertInfo.Columns.Add("fkey");

            foreach (rootNodeTableInfo node in _convertAllRecordConfig.tableInfo)
            {
                if (null == node.fnwTableName)
                    continue;
                DataRow newRow = convertInfo.NewRow();
                newRow["table"] = node.fnwTableName;
                newRow["ntssTable"] = node.ntssTableName;
                newRow["type"] = dataType;
                newRow["fkey"] = node.fnwPk;
                if (node.convertKind == null || node.convertKind.Equals(""))
                {
                    ConvertBase.WriteTraceLog("convertKind未設定テーブルあり：" + node.ntssTableName);
                    continue;
                }
                string convertKind = node.convertKind.ToString();
                switch (dataType)
                {
                    case CMB_SELECT_ALL_RECORD_PAT:
                        if (convertKind.Equals("PAT") &&
                            string.IsNullOrEmpty(node.hidden))
                        {
                            convertInfo.Rows.Add(newRow);
                        }
                        break;
                    case CMB_SELECT_ALL_RECORD_MST:
                        if (convertKind.Equals("MST") &&
                            string.IsNullOrEmpty(node.hidden))
                        {
                            convertInfo.Rows.Add(newRow);
                        }
                        break;
                }
            }
            dgvPat.DataSource = convertInfo;
            dgvPat.Columns["type"].Visible = false;
            dgvPat.Columns["fkey"].Visible = false;
            dgvPat.Columns["table"].HeaderText = "移行元テーブル名";
            dgvPat.Columns["ntssTable"].HeaderText = "移行先テーブル名";
            dgvPat.Sort(dgvPat.Columns["ntssTable"], System.ComponentModel.ListSortDirection.Ascending);
            // セルを未選択状態にする
            dgvPat.CurrentCell = null;
            return true;
        }

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// コンバート対象をデータグリッドビューに表示
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        private bool ShowMotionTargetTable(string dataType)
        {

            DataTable convertInfo = new DataTable();
            convertInfo.Columns.Add("table");
            convertInfo.Columns.Add("ntssTable");
            convertInfo.Columns.Add("type");
            convertInfo.Columns.Add("fkey");

            foreach (rootNodeTableInfo node in _convertMotionConfig.tableInfo)
            {
                if (null == node.fnwTableName)
                    continue;
                DataRow newRow = convertInfo.NewRow();
                newRow["table"] = node.fnwTableName;
                newRow["ntssTable"] = node.ntssTableName;
                newRow["type"] = dataType;
                newRow["fkey"] = node.fnwPk;
                if (node.convertKind == null || node.convertKind.Equals(""))
                {
                    ConvertBase.WriteTraceLog("convertKind未設定テーブルあり：" + node.ntssTableName);
                    continue;
                }
                string convertKind = node.convertKind.ToString();
                switch (dataType)
                {
                    case CMB_SELECT_MNT_MOTION_RECORD:
                        if (convertKind.Equals("MOTION") &&
                            string.IsNullOrEmpty(node.hidden))
                        {
                            convertInfo.Rows.Add(newRow);
                        }
                        break;
                }
            }
            dgvPat.DataSource = convertInfo;
            dgvPat.Columns["type"].Visible = false;
            dgvPat.Columns["fkey"].Visible = false;
            dgvPat.Columns["table"].HeaderText = "移行元テーブル名";
            dgvPat.Columns["ntssTable"].HeaderText = "移行先テーブル名";
            dgvPat.Sort(dgvPat.Columns["ntssTable"], System.ComponentModel.ListSortDirection.Ascending);
            // セルを未選択状態にする
            dgvPat.CurrentCell = null;
            return true;
        }
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end

        /// <summary>
        /// 指示履歴コンバート
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        private bool ShowIndHistoryTable(string dataType)
        {

            DataTable convertInfo = new DataTable();
            convertInfo.Columns.Add("table");
            convertInfo.Columns.Add("ntssTable");
            convertInfo.Columns.Add("type");
            convertInfo.Columns.Add("fkey");

            foreach (rootNodeTableInfo node in _convertIndHistoryConfig.tableInfo)
            {
                if (null == node.fnwTableName)
                    continue;
                DataRow newRow = convertInfo.NewRow();
                newRow["table"] = node.fnwTableName;
                newRow["ntssTable"] = node.ntssTableName;
                newRow["type"] = dataType;
                newRow["fkey"] = node.fnwPk;
                if (node.convertKind == null || node.convertKind.Equals(""))
                {
                    ConvertBase.WriteTraceLog("convertKind未設定テーブルあり：" + node.ntssTableName);
                    continue;
                }
                string convertKind = node.convertKind.ToString();
                switch (dataType)
                {
                    case CMB_SELECT_ALL_RECORD_PAT:
                        if (convertKind.Equals("PAT") &&
                            string.IsNullOrEmpty(node.hidden))
                        {
                            convertInfo.Rows.Add(newRow);
                        }
                        break;
                    case CMB_SELECT_ALL_RECORD_MST:
                        if (convertKind.Equals("MST") &&
                            string.IsNullOrEmpty(node.hidden))
                        {
                            convertInfo.Rows.Add(newRow);
                        }
                        break;
                    case CMB_SELECT_INDICATES_HISTORY:
                        if (convertKind.Equals("IND") &&
                            string.IsNullOrEmpty(node.hidden))
                        {
                            convertInfo.Rows.Add(newRow);
                        }
                        break;
                }
            }
            dgvPat.DataSource = convertInfo;
            dgvPat.Columns["type"].Visible = false;
            dgvPat.Columns["fkey"].Visible = false;
            dgvPat.Columns["table"].HeaderText = "移行元テーブル名";
            dgvPat.Columns["ntssTable"].HeaderText = "移行先テーブル名";
            dgvPat.Sort(dgvPat.Columns["ntssTable"], System.ComponentModel.ListSortDirection.Ascending);
            // セルを未選択状態にする
            dgvPat.CurrentCell = null;
            return true;
        }



        /// <summary>
        /// FNWDB接続
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        private bool DBConnectFnw()
        {
            db = ConvertControl.DBConnectFnw();
            if (db == null)
            {
                return false;
            }

            return true;
        }


        /// <summary>
        /// フォームクローズ処理
        /// </summary>
        private void MainForm_FormClosed(object sender, FormClosedEventArgs e)
        {
          
            if (null != forward)
            {
                forward.Stop();
            }
            if (null != client)
            {
                client.RemoveForwardedPort(forward);
                client.Disconnect();
            }
            if (null != forward)
            {
                forward.Dispose();
            }
            if (null != client)
            {
                client.Dispose();
            }

            // 画面設定情報保存
            SaveAppConfigInputStatus();
            this.Hide();
        }

        

       

        public void BtnConvertCall()
        {
            BtnConvert_Click(null, null);
        }

        /// <summary>
        /// コンバートボタンクリック
        /// </summary>
        private void BtnConvert_Click(object sender, EventArgs e)
        {
            string dataType = CommonConfig.SelectedTypeByFacility[CommonConfig.seriesCd];
            if (dataType.Contains("すべて")) {
                dataType = this.cmbDataType.SelectedItem.ToString();
            }
            //
            if (dataType == null || string.IsNullOrEmpty(dataType.ToString()))
            {
                ShowMsgBoxWarning("データ種別を選択してください。");
                return;
            }

            // 2019/11/6 CSV出力機能は非表示にして使用させない
            if (dataType.ToString().Equals(CMB_SELECT_INDICATES_HISTORY))
            {
                this._outputMode = (int)CommonConstants.OutputFormat.JSON;
            }
           
            else
            {
                this._outputMode = (int)CommonConstants.OutputFormat.SQL;
            }

            // 出力済を除外するオプションボタンの値を共通クラスへ設定する
            CommonConfig.isExclusion = this.chkExclusion.Checked;

            // Mod #7997 趙 Start
            CommonConfig.seriesCd = txtSeriesCd.Text;
            // Mod #7997 趙 End

            switch (dataType.ToString())
            {
                // add FNSI-検査結果対応 楊 start
                // 検査予定／結果
                case CMB_SELECT_PAT_EXAM:
                    // 処理対象テーブルの取得・設定
                    m_convertTableNames = GetProcTargetTables(_convertPatExamRadConfig);
                    //add 7726  抽出された繰返し日の取得 鄭 start
                    string sbl = GeWithdrawalDateTables("ORD", "inspectionSchedule／result");
                    //add 7726  抽出された繰返し日の取得 鄭 end
                    this.ConvertPatSpecifyPeriod(true, "inspectionSchedule／result", sbl);
                    break;
                // add FNSI-検査結果対応 楊 end
                // 透析（または患者毎期間指定移行対象）
                case CMB_SELECT_SPECIFY_PERIOD_PAT:
                    //add 9298 zc start
                    //mod #10418 start
                    var param = db.GetIMakeSqlParameters();
                    param.AddParam(":FACILITY_CD", txtFacilityCd.Text);
                    string sql = "select count(*) as len from SYNC_CONVERT_HISTORY where TABLE_KIND='PER' and FACILITY_CD=:FACILITY_CD";
                    isPat = int.Parse(db.SelectTable(sql, param.GetParam()).Rows[0]["len"].ToString());
                    //mod #10418 end

                    //add 9298 zc end
                    // 処理対象テーブルの取得・設定
                    m_convertTableNames = GetProcTargetTables(_convertPatSpecifyPeriodConfig);
                    //add 7726  抽出された繰返し日の取得 鄭 start
                    string sblPAT = GeWithdrawalDateTables("ORD", "dialysis");
                    //add 7726  抽出された繰返し日の取得 鄭 end

                    this.ConvertPatSpecifyPeriod(true, "dialysis", sblPAT);
                    //add 9298 zc start
                        if (isPat == 0 && isPattern)
                    {
                        m_convertTableNames = GetProcTargetTables(_convertPatTreatmentPatternConfig);
                        this.ConvertPatSpecifyPeriod(true, "patientTreatmentPattern", "");
                            
                    }
                        isPattern = true;
                    //add 9298 zc end
                    break;
                // 全件移行対象（患者情報）
                case CMB_SELECT_ALL_RECORD_PAT:

                    this.ConvertAllRecord("convert(pat)");
                    break;
                // 全件移行対象（マスタ）
                case CMB_SELECT_ALL_RECORD_MST:

                    this.ConvertAllRecord("convert(mst)");
                    break;
                // 期間指定移行対象
                case CMB_SELECT_SPECIFY_PERIOD:
                    this.ConvertSpecifyPeriod();
                    break;
                
                case CMB_SELECT_INDICATES_HISTORY:
                    // 処理対象テーブルの取得・設定

                    m_convertTableNames = GetProcTargetTables(_convertIndHistoryConfig);
                    //add 9906
                    m_convertTableNames.Remove("LOG_CHANGE_LOG-rst_history");
                    //add 9906
                    // add FNSI-差分コンバート対応 楊 start
                    this.ConvertMongoDB(true, "indicatorShoe");
                    // add FNSI-差分コンバート対応 楊 end
                    break;
                
                // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
                case CMB_SELECT_MNT_MOTION_RECORD:
                    // 7341 AWS側アプリの処理が遅い start
                    this._outputMode = (int)CommonConstants.OutputFormat.CSV;
                    // 7341 AWS側アプリの処理が遅い end
                    this.ConvertMotion("convert(motion)");
                    break;
                // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
                default:
                    break;
            }
            // add 2020-12-10 FNSI-仕様修正 デフォルトで全対象とする。設定がある場合は、指定データだけをコンバートする。実行しても設定画面を開かないようにする。start
            //mod  設定画面を開くと、前回選択されるデータ種別が「すべて」に変わること。改修後にはデータ種別が前回選択されると同じです zc start
            int number = this.cmbDataType.SelectedIndex;
            this.cmbDataType.SelectedIndex = number;
            //this.cmbDataType.SelectedIndex = 0;
            //mod  設定画面を開くと、前回選択されるデータ種別が「すべて」に変わること。改修後にはデータ種別が前回選択されると同じです zc end
            // add 2020-12-10 FNSI-仕様修正 デフォルトで全対象とする。設定がある場合は、指定データだけをコンバートする。実行しても設定画面を開かないようにする。end
        }

        /// <summary>
        /// 患者一覧の選択チェック
        /// </summary>
        /// <returns></returns>
        private bool CheckPatSelect()
        {
            int conunt = 0;
            if (CommonConfig.isDiff) {
                conunt = dgvPat.SelectedCells.Count;

            }
            else {
                conunt = SelectedRowsByFacility[CommonConfig.seriesCd].Count;
            }
            if (conunt == 0)
            {
                ShowMsgBoxWarning("患者を選択してください。");
                return false;
            }
            else
            {
                return true;
            }
        }


        /// <summary>
        /// 患者IDリストでコンバート処理を実施する
        /// </summary>
        /// <param name="listSelectedPatId">患者IDリスト</param>
        /// <param name="listSelectSpan">対象期間</param>
        /// <param name="exportFolderPath">出力パス</param>
        /// <param name="listErrorPatAll">エラー患者IDリスト</param>
        /// <param name="fileNamePrefix">エラー患者IDリスト</param>
        /// 
        /// <returns></returns>
        private List<string> ConvertPatProcPatidList(List<string> listSelectedPatId,
            List<SelectSpan> listSelectSpan,
            string exportFolderPath,
            List<string> listErrorPatAll,
            string fileNamePrefix
            )
        {
            // add 2020-12-13 594 ログファイルを作成または開きます う start
            string[] filesp = exportFolderPath.Split('_');
            string fileName = "";
            BuildConvertStatus bcs = new BuildConvertStatus();
            bool issaveStatus = true;
            List<string> fileStatus = new List<string>();
            string LogInfo = "";
            _lbSQLFileBuildStatus.Items.Clear();
            if (filesp.Length == 3)
            {
                //mod #9696 djy start
                //fileName = filesp[2];
                fileName = ReplaceLogName(filesp[2]);
                //mod #9696 djy end
                if (bcs.CreateStatusFile(fileName))
                {
                    LogInfo = fileName + "ファイル作成の進捗";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo);
                    issaveStatus = true;
                }
                else
                {
                    issaveStatus = false;
                }
            }
            else
            {
                issaveStatus = false;
            }
            // add 2020-12-13 594 ログファイルを作成または開きます う end

            //add 11161 start
            if (!CommonConfig.isDiff)
            {
                string start = string.Empty;
                if (CommonConfig.AUTOMATIC.Equals("0"))
                {
                    start = "いいえ";
                }
                else
                {
                    start = "はい";
                }
                SaveAndShowLogStr(bcs, fileName, "", "処理切替え自動:" + start);
            }
            //add 11161 start
            // 選択されている患者IDを処理件数ずつに分割
            int chunkSize = 20;
            //add #10401 djy start
            int threadSize = 1;
            //add #10401 djy end
            // add 2023-07-06 #8585 マルチスレッド start
            bool useMultiThread = false;
            var dataType = this.cmbDataType.SelectedItem;
            // 患者毎期間指定移行対象 
            if (!CommonConfig.isDiff && dataType.ToString().Equals(CMB_SELECT_SPECIFY_PERIOD_PAT) && fileNamePrefix.Equals("dialysis"))
            {
                useMultiThread = true;
            }

            if (useMultiThread)
            {
                //mod #10401 djy start
                //chunkSize = 1;
                chunkSize = NKSConverter.Properties.Settings.Default.dialysisChunkSize;
                threadSize = NKSConverter.Properties.Settings.Default.dialysisThreadSize;
                //mod #10401 djy end
            }
            // add 2023-07-06 #8585 マルチスレッド end
            var listPatidList = listSelectedPatId.Select((patid, index) => new { patid, index })
                .GroupBy(x => x.index / chunkSize)
                .Select(g => g.Select(x => x.patid));
            // 処理対象患者件数
            int patIdCount = listSelectedPatId.Count;

            // del 2023-07-06 #8585 マルチスレッド start
            // // 処理済患者件数
            // int finishedPatIdCount = 0;
            // del 2023-07-06 #8585 マルチスレッド end

            // 処理正常終了患者IDリスト
            List<string> completedPatIdList = new List<string>();
            // 患者IDエラーリスト
            if (listErrorPatAll == null)
                listErrorPatAll = new List<string>();
            // 進捗表示用のデータグリッドビュー作成
            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
            // this.MakeDataGridViewForConvertProgress(dgvConvertTable, m_convertTableNames, listPatidList);
            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
            // SYNC_ORD_MAIN_SCH_PLANテーブルを一時作成する(ord-mainレコードを導出するように)
            if (m_convertTableNames.Contains("ord_main"))
            {
                //mod #10378-24-日次 djy start
                //CreateSyncTable(listSelectedPatId, listSelectSpan[0].startDate, listSelectSpan[0].endDate);
                CreateSyncTable(listSelectedPatId, listSelectSpan[0].startDate, listSelectSpan[0].endDate, 0);
                //mod #10378-24-日次 djy end
            }
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
            if (m_convertTableNames.Contains("ord_checklist"))
            {
                CreateSyncCKHistTable(listSelectSpan[0].startDate, listSelectSpan[0].endDate);
            }

            // mod #10835 体重計測定記録の一部がFNWからコンバートされていない zkm start
            if (m_convertTableNames.Contains("ord_weight_scale")) {
                CommonConfig.WeightScaleNoPatConvertMark = listSelectedPatId[0];
            }
            // mod #10835 体重計測定記録の一部がFNWからコンバートされていない zkm end
            // add 2023-07-06 #8585 マルチスレッド start
            if (useMultiThread)
            {
                int startRowIndex = 0;
                //mod #10401 djy start
                //ConverterTaskGroup<ConvertPatProcPatidListWork> taskGroup = new ConverterTaskGroup<ConvertPatProcPatidListWork>(1);
                ConverterTaskGroup<ConvertPatProcPatidListWork> taskGroup = new ConverterTaskGroup<ConvertPatProcPatidListWork>(threadSize);
                //mod #10401 djy end
                foreach (var procPatidList in listPatidList)
                {
                    taskGroup.addWork(new ConvertPatProcPatidListWork(procPatidList, startRowIndex));
                    startRowIndex++;
                }
                taskGroup.run((work) =>
                {
                    ConvertPatProcPatidListFunc(
                        listSelectSpan,
                        exportFolderPath,
                        listErrorPatAll,
                        fileName,
                        bcs,
                        issaveStatus,
                        // fileStatus,
                        // ref finishedPatIdCount,
                        completedPatIdList,
                        ref work.startRowIndex,
                        work.procPatidList,
                        true);
                });
            }
            else
            {
                int chkRowIndex = 0;
                foreach (var procPatidList in listPatidList)
                {
                    ConvertPatProcPatidListFunc(
                        listSelectSpan,
                        exportFolderPath,
                        listErrorPatAll,
                        fileName,
                        bcs,
                        issaveStatus,
                        // fileStatus,
                        // ref finishedPatIdCount,
                        completedPatIdList,
                        ref chkRowIndex,
                        procPatidList,
                        false);

                }
            }
            // add 2023-07-06 #8585 マルチスレッド end

            // del 2023-07-06 #8585 マルチスレッド start
            // move to function ConvertPatProcPatidListFunc()
            // del 2023-07-06 #8585 マルチスレッド end

            // エラー患者ID一覧を出力
            if (listErrorPatAll.Count > 0)
            {
                ConvertBase.WriteTraceLog("エラー患者ID一覧：");
                listErrorPatAll.ForEach(s => ConvertBase.WriteTraceLog(s));
                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "エラー患者ID一覧：";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                    listErrorPatAll.ForEach(s => fileStatus.Add(s));
                    listErrorPatAll.ForEach(s => _lbSQLFileBuildStatus.Items.Add(s));
                }
                // add 2020-12-13 594 ログを書き込む う end
            }

            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
            if (m_convertTableNames.Contains("ord_main"))
            {
                // ord-main導出実行完成した後、一時テーブルを作成する
                DelSyncOrdMainSchPlanTemporaryTbl("SYNC_ORD_MAIN_SCH_PLAN");
            }
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end

            // ord_checklist導出実行完成した後、一時データをクリアする
            if (m_convertTableNames.Contains("ord_checklist"))
            {
                ClearDBWithChecklist();
            }
            return completedPatIdList.Distinct().ToList();
        }

        private void ClearDBWithChecklist()
        {
            db.ExecuteSQL("TRUNCATE TABLE SYNC_SYS_CHECKLIST");
            db.ExecuteSQL("TRUNCATE TABLE SYNC_CHECKLIST_HIST");
            db.ExecuteSQL(@"
                    DELETE FROM SYNC_ORD_CHECKLIST_HIST
                    WHERE (PATID, IND_ID, UP_DATE) NOT IN (
		                SELECT PATID, IND_ID, MAX(UP_DATE) MAX_UP_DATE
				        FROM SYNC_ORD_CHECKLIST_HIST
				        GROUP BY PATID, IND_ID
		            )");
        }

        private void DelSyncOrdMainSchPlanTemporaryTbl(String tableName)
        {
            db.SelectTable(@"
                declare
                      num number;
                begin
                    select count(1) into num from user_tables where table_name = upper('" + tableName + @"') ;
                    if num > 0 then
                        execute immediate 'drop table " + tableName + @" CASCADE CONSTRAINTS' ;
                    end if;
                end;");
        }

        //add #10418 start
        private void CreateSyncOrdMainSchPlanTemporaryTbl(String tableName)
        {
            string sql = $@"
                    CREATE TABLE NKK.{tableName}
                    (
                       DIALYSIS_DATE VARCHAR2(8),
                            PATID CHAR(12),
                            PLURAL NUMBER(1, 0),
                            IND_ID VARCHAR2(60),
                            VALUE VARCHAR2(40),
                            OPE_IND_PLAN CHAR(1),
                            CYCLE_WEEK NUMBER(1, 0),
                            INDICATOR_CD CHAR(10),
                            UPDATE_STAFF_CD CHAR(10),
                            UP_DATE DATE
                    )";

            db.ExecuteSQL(sql);


        }
        //add #10418 end

        /// <summary>
        /// 透析系テーブルデータを一時テーブルに格納する
        /// </summary>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// </param>
        //mod #10378-24-日次 djy start

        private void CreateSyncTable(List<string> listParam,
            DateTime? startDate,
            DateTime? endDate,
            int monthsDiff)
        //mod #10378-24-日次 djy end
        {
            DelSyncOrdMainSchPlanTemporaryTbl("SYNC_ORD_MAIN_SCH_PLAN");
            if (listParam.Count < 1)
            {
                return;
            }

            //add #10418 start
            CreateSyncOrdMainSchPlanTemporaryTbl("SYNC_ORD_MAIN_SCH_PLAN");
            // 患者ID 1000個ずつでループ, 選択患者リストからSQLのin句の生成
            CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("IND_PLAN.PATID", 1000, listParam, "P_");
            string listInClauseParam = inResult.Clause;
            //add #10418 end

            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = Path.Combine("SQL\\ord_main", "SYNC_ORD_MAIN_SCH_PLAN" + ".sql");

           
            LogManager.WriteTraceLog(null, null, "[情報]" + string.Format("実行SQL：{0}", sqlFilePath));
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //add  7997  zc start
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = sql.Replace("{NoWITHIndTimePeriod}", "");
                        sql = sql.Replace("{IndTimePeriodWhere}", "");
                        sql = sql.Replace("{SERIES_CD}", "");
                        
                    }
                    else {

                        sql = sql.Replace("{NoWITHIndTimePeriod}", CommonConfig.NoWITHIndTimePeriod);
                        string IndTimePeriodWhere = "INNER JOIN  IndTimePeriod  i on i.PATID=S.PATID and i.SERIES_CD=:SERIES_CD and  S.DIALYSIS_DATE >=i.START_DATE  AND  S.DIALYSIS_DATE <END_DATE";
                        sql = sql.Replace("{IndTimePeriodWhere}", IndTimePeriodWhere);
                        sql = sql.Replace("{SERIES_CD}", "AND SERIES_CD =:SERIES_CD");
                        
                    }
                    //mod #10378-24-日次 djy start
                    sql = string.Format(sql, listInClauseParam);
                    //mod #10378-24-日次 djy end
                    //add  7997  zc end

                    //mod #10418 start
                    var param = db.GetIMakeSqlParameters();
                    if (sql.Contains(":SERIES_CD"))
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    param.AddParam(":START_DATE", ((DateTime)startDate).ToString("yyyyMMdd"));
                    param.AddParam(":END_DATE", ((DateTime)endDate).ToString("yyyyMMdd"));
                    param.AddParam(":MONTHSDIFF", monthsDiff);
                    foreach (var p in inResult.Parameters)
                    {
                        param.AddParam(p.Key, p.Value);
                    }
                    //mod #10418 end

                    db.SelectTable(sql, param.GetParam());
                }
            }
            catch (Exception e)
            {
                LogManager.WriteErrorLog(null, null, "[エラー]" + "コンバート元データ取得に失敗しました。", e);
            }
        }

        /// <summary>
        /// 透析系テーブルデータを一時テーブルに格納する
        /// </summary>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// 
        /// </param>
        private void CreateSyncCKHistTable(DateTime startDate,
            DateTime endDate)
        {
            try
            {
                //mod #12229 start
                db.ExecuteSQL("TRUNCATE TABLE SYNC_CHECKLIST_HIST");

                CommonConfig.targetYmList = CommonFunc.GetYmList("RST_CHECKLIST", startDate, endDate,db);
                CommonConfig.targetYmList.Add("RST_CHECKLIST");
                //mod #12229 end
            }
            catch (Exception e)
            {
                LogManager.WriteErrorLog(null, null, "[エラー]" + "コンバート元データ取得に失敗しました。", e);
            }
        }


        // add 2023-07-06 #8585 マルチスレッド start
        /// <summary>
        /// 
        /// </summary>
        /// <param name="listSelectSpan">対象期間</param>
        /// <param name="exportFolderPath">出力パス</param>
        /// <param name="listErrorPatAll">エラー患者IDリスト</param>
        /// <param name="fileName"></param>
        /// <param name="bcs"></param>
        /// <param name="issaveStatus"></param>
        /// <param name="completedPatIdList"></param>
        /// <param name="chkRowIndex"></param>
        /// <param name="procPatidList"></param>
        /// <param name="useMultiThread"></param>
        /// 
        private void ConvertPatProcPatidListFunc(
            List<SelectSpan> listSelectSpan,
            string exportFolderPath,
            List<string> listErrorPatAll,
            string fileName,
            BuildConvertStatus bcs,
            bool issaveStatus,
            List<string> completedPatIdList,
            ref int chkRowIndex,
            IEnumerable<string> procPatidList,
            bool useMultiThread)
        {
            // add 2023-07-06 #8585 マルチスレッド start
            List<string> fileStatus = new List<string>();
            // 出力形式保持用
            int outputMode = this._outputMode;
            // add 2023-07-06 #8585 マルチスレッド start

            // 選択した患者リストへ分割した患者リストを代入
            List<string> chunkPatIdList = procPatidList.ToList();

            // コンバートクラスインスタンス化
            ConvertControl convertControl = CreateConvertControl(ConvertControl.CONV_TYPE.PAT_SPECIFY_PERIOD);

            ConvertBase.WriteTraceLog("##### 患者IDグループ処理開始 #####");
            ConvertBase.WriteTraceLog("対象患者ID：{0}", string.Join(",", chunkPatIdList.ToArray()));

            // add 2020-12-13 594 ログを書き込む う start
            if (issaveStatus)
            {
                string LogInfo1 = "##### 患者IDグループ処理開始 #####";
                string LogInfo2 = string.Format("対象患者ID：{0}", string.Join(",", chunkPatIdList.ToArray()));
                SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                SaveAndShowLogStr(bcs, fileName, "", LogInfo2);
            }
            // add 2020-12-13 594 ログを書き込む う end

            // 指定期間ごとにコンバート
            foreach (var selectSpan in listSelectSpan)
            {
                // 対象テーブルごとに処理
                foreach (string convertTableName in m_convertTableNames)
                {

                    // add 2023-07-06 #8585 マルチスレッド start
                    GC.Collect();
                    GC.WaitForPendingFinalizers();
                    // add 2023-07-06 #8585 マルチスレッド end

                    string[] tableNameVS = convertTableName.Split('-');
                    string tableName = tableNameVS[tableNameVS.Length - 1];

                    Stopwatch stopwatch = Stopwatch.StartNew();
                    // 進捗チェックボックス設定
             
                    ConvertBase.WriteTraceLog("##### データエクスポート開始 #####");
                    ConvertBase.WriteTraceLog("テーブル名：{0}", convertTableName);
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "##### データエクスポート開始 #####";
                        string LogInfo2 = string.Format("テーブル名：{0}", tableName);
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo2);
                    }
                    // add 2020-12-13 594 ログを書き込む う end

                    #region 初期化処理(共通処理)

                    // mod 2023-07-06 #8585 マルチスレッド start
                    DBCtrl dbWork;
                    if (useMultiThread)
                    {
                        dbWork = ConvertControl.DBConnectFnw();
                    }
                    else
                    {
                        dbWork = this.db;
                    }
                    var isSuccess = convertControl.Init(dbWork, convertTableName);
                    // mod 2023-07-06 #8585 マルチスレッド end
                    if (isSuccess == false)
                    {
                        // add 2020-12-13 594 ログを書き込む う start
                        if (issaveStatus)
                        {
                            string LogInfo1 = "初期化に失敗しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                        // add 2020-12-13 594 ログを書き込む う end
                       
                        continue;
                    }
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "初期化に成功しました。";
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                    #endregion

                    #region コンバート元データ取得(コンバート/エクスポート用処理)

                    if (useMode == Mode.Convert || useMode == Mode.Export)
                    {
                        

                        Application.DoEvents();

                        // コンバート元データ取得
                        isSuccess = convertControl.SetFnwData(chunkPatIdList, null, selectSpan.startDate, selectSpan.endDate, false);
                        // 対象期間をログ出力
                        ConvertBase.WriteTraceLog("取得対象期間：{0} ～ {1}", selectSpan.startDate.ToString("yyyy/MM/dd"), selectSpan.endDate.ToString("yyyy/MM/dd"));

                        if (isSuccess == false)
                        {
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "コンバート元データ取得に失敗しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                            // 取得失敗
                           
                            continue;
                        }
                        else if (convertControl.GetFnwDataRowCount() == 0)
                        {
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "元のデータは存在しない。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                            // 選択した全患者において元データが存在しない場合は次のテーブルへ
                            
                            continue;
                        }
                        // add 2020-12-13 594 ログを書き込む う start
                        if (issaveStatus)
                        {
                            string LogInfo1 = "コンバート元データ取得に成功しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                        // add 2020-12-13 594 ログを書き込む う end
                    }

                    #endregion

                    #region コンバート実施(コンバート/エクスポート用処理)

                    if (useMode == Mode.Convert || useMode == Mode.Export)
                    {
                        

                        Application.DoEvents();

                        // 患者IDエラーリスト
                        var listErrorPat = new List<string>();

                        // コンバート実施
                        isSuccess = convertControl.Convert(listErrorPat);
                        if (isSuccess == false)
                        {
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "コンバート実施に失敗しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                            // 失敗時は次のテーブルへ
                           
                            continue;
                        }
                        // add コンバートのデータは存在しない場合次のテーブルへ 楊 start
                        else if (convertControl.GetConvertRecordCount() == 0)
                        {
                            if (issaveStatus)
                            {
                                string LogInfo1 = "コンバートのデータは存在しない。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // 選択した全患者において元データが存在しない場合は次のテーブルへ
                            
                            continue;
                        }
                        // add コンバートのデータは存在しない場合次のテーブルへ 楊 end
                        else if (listErrorPat.Count > 0)
                        {
                            // 患者IDエラーリストへエラー患者IDを追加
                            // mod 2023-07-06 #8585 マルチスレッド start
                            // listErrorPatAll.AddRange(listErrorPat);
                            lock (locker)
                            {
                                listErrorPatAll.AddRange(listErrorPat);
                            }
                            // mod 2023-07-06 #8585 マルチスレッド end
                            
                        }
                        // add 2020-12-13 594 ログを書き込む う start
                        if (issaveStatus)
                        {
                            string LogInfo1 = "コンバート実施に成功しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                        // add 2020-12-13 594 ログを書き込む う end
                    }

                    #endregion

                    #region エクスポート(エクスポート用処理)

                    if (useMode == Mode.Export)
                    {
                        

                        Application.DoEvents();

                        // 常にInsert文を作成
                        // 7341 AWS側アプリの処理が遅い start
                        // this._outputMode = (int)CommonConstants.OutputFormat.SQL;
                        if (CommonConstants.CONVERT_CSV.Contains(tableName))
                        {
                            this._outputMode = (int)CommonConstants.OutputFormat.CSV;
                            // add 2023-07-06 #8585 マルチスレッド start
                            outputMode = (int)CommonConstants.OutputFormat.CSV;
                            // add 2023-07-06 #8585 マルチスレッド end
                        }
                        //add #12229 ord_weight_scale start
                        else if ("ord_weight_scale".Equals(tableName))
                        {
                            outputMode = (int)CommonConstants.OutputFormat.JSON;
                        }
                        //add #12229 ord_weight_scale end
                        else
                        {
                            this._outputMode = (int)CommonConstants.OutputFormat.SQL;
                            // add 2023-07-06 #8585 マルチスレッド start
                            outputMode = (int)CommonConstants.OutputFormat.SQL;
                            // add 2023-07-06 #8585 マルチスレッド end
                        }
                        // 7341 AWS側アプリの処理が遅い end

                        // mod 2023-07-06 #8585 マルチスレッド start
                        isSuccess = convertControl.Export(exportFolderPath,
                        encoding, true,
                        true,
                        (CommonConstants.OutputFormat)Enum.ToObject(typeof(CommonConstants.OutputFormat), outputMode),
                        int.Parse(Settings.Default.ChunkSize));
                        // mod 2023-07-06 #8585 マルチスレッド end

                        if (isSuccess == false)
                        {
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "Insert文の制作に失敗しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                            
                            continue;
                        }
                        // add 2020-12-13 594 ログを書き込む う start
                        if (issaveStatus)
                        {
                            string LogInfo1 = "Insert文の制作に成功しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                        // add 2020-12-13 594 ログを書き込む う end
                    }

                    #endregion

                    

                    Application.DoEvents();

                    ConvertBase.WriteTraceLog("経過時間：{0}:{1}", stopwatch.Elapsed.Minutes.ToString("00"), stopwatch.Elapsed.Seconds.ToString("00"));
                    ConvertBase.WriteTraceLog("##### データエクスポート完了 #####");


                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = String.Format("達成時間：{0}", DateTime.Now.ToLongTimeString());
                        string LogInfo2 = "##### データエクスポート完了 #####";
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        SaveAndShowLogStr(bcs, fileName, tableName, LogInfo2);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                }
            }
            chkRowIndex++;
            // 正常終了患者IDリストへ追加
            List<string> completedPatIdListWork = new List<string>(chunkPatIdList);
            completedPatIdListWork.RemoveAll(s => listErrorPatAll.Contains(s));

            // mod 2023-07-06 #8585 マルチスレッド start
            // completedPatIdList.AddRange(completedPatIdListWork);
            lock (locker)
            {
                completedPatIdList.AddRange(completedPatIdListWork);
            }
            // mod 2023-07-06 #8585 マルチスレッド end

            

            ConvertBase.WriteTraceLog("##### 患者IDグループ処理終了 #####");
            // add 2020-12-13 594 ログを書き込む う start
            if (issaveStatus)
            {
                string LogInfo1 = "##### 患者IDグループ処理終了 #####";
                SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
            }
            // add 2020-12-13 594 ログを書き込む う end

            // add 2023-07-06 #8585 マルチスレッド start
            GC.Collect();
            GC.WaitForPendingFinalizers();
            // add 2023-07-06 #8585 マルチスレッド end

        }
        // add 2023-07-06 #8585 マルチスレッド end

        /// <summary>
        /// 患者、期間を指定してコンバート処理
        /// </summary>
        private void ConvertPatSpecifyPeriod(bool isRegistConvertHistory, string fileNamePrefix, string test)
        {


            var dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;

            // 患者選択チェック
            if (!CheckPatSelect()) return;

            // 施設コードの入力チェック
            if (!CheckFacilityCd()) return;

            // 出力先フォルダ作成
            // mod 2020-12-21 594 コンバートが進歩:差分・完全・追加。 う　start
            string turnType = checkTurnType();
            // Mod #7997 趙 Start
            string exportFolderPath = Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd+string.Format(@"\{1}-ExportData_{0}_" + fileNamePrefix + "[" + turnType + "]", dtNow.ToString("yyyyMMddHHmmss"), this.txtFacilityCd.Text);
            // Mod #7997 趙 End
            // mod 2020-12-21 594 コンバートが進歩:差分・完全・追加。 う　end
            if (!MakeExportFolderPath(exportFolderPath)) return;

            // 確認ダイアログ(共通処理)
           
            //mod  9298 zc start
            if (!fileNamePrefix.Equals("patientTreatmentPattern"))
            {

                if (!_IsConvertAll)
                    isPattern = DisplayConfirmationDialog(test);
                    if (!isPattern) return;
            }
           

            // ボタン活性変更(共通処理)
            EnableControl(false);

            

            #region 患者情報コンバート処理
            //mod  9298 zc start
            if (fileNamePrefix.Equals("patientTreatmentPattern"))
            {
                dgvPat.SelectAll();
            }
            //mod  9298 zc end

            // 選択した患者IDのリスト
            List<string> listSelectedPatId = GetDgvSelectedRow(dgvPat, "PATID");

            if (fileNamePrefix.Equals("patientTreatmentPattern") && CacheInformation.Instance.FacilityCd.Equals("1")) {

                listSelectedPatId.Clear();
                var sql = new StringBuilder(@"
                        SELECT
                            a.PATID   
                        FROM
                            pat_basic_info a
                            INNER JOIN pat_index_info b ON a.patid = b.patid AND a.reg_date = b.pat_reg_date
                            INNER JOIN  SYS_PAT_SERIES_FACILITY s on s.patid= b.patid and s.SERIES_CD = :SERIES_CD  and MAIN_FLG='1'
                        WHERE
                            b.PAT_STATUS = '0' ORDER BY a.patid
                        ");
                IMakeSqlParameters param = db.GetIMakeSqlParameters();
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                var tbPat = db.SelectTable(sql.ToString(), param.GetParam());
                foreach (DataRow item in tbPat.Rows)
                {
                    listSelectedPatId.Add(item["PATID"].ToString());
                }
              
            }
            // 指定期間のリスト
            List<SelectSpan> listSelectSpan = GetSelectSpan(SelecteddtpStartDate[CommonConfig.seriesCd], SelecteddtpEndDate[CommonConfig.seriesCd]);
            // 正常終了した患者IDのリスト
            List<string> completedPatIdList;
            // エラーになった患者IDのリスト
            List<string> errorPatIdList = new List<string>();

            completedPatIdList = ConvertPatProcPatidList(listSelectedPatId,
                listSelectSpan,
                exportFolderPath,
                errorPatIdList,
                fileNamePrefix
            );

            #endregion

            

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);

            Application.DoEvents();

            if (isRegistConvertHistory)
            {
                // 処理した患者IDと期間をコンバート履歴テーブルに登録する
                // （処理した患者が存在する場合のみ実行）
                if (completedPatIdList.Count > 0)
                {
                    SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
                    SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
                    dto.facilityCd = this.txtFacilityCd.Text;
                    // add 7853-差分コンバートで更新/削除ができない 楊 start
                    //dto.tableKind = "ORD";
                    if ("dialysis".Equals(fileNamePrefix))
                    {
                        dto.tableKind = "ORD";
                    }
                    //add 8400 zc start
                    else if (fileNamePrefix.Equals("patientTreatmentPattern"))
                    {
                        dto.tableKind = "PER";
                    }
                    //add 8400 zc end
                    else
                    {
                        dto.tableKind = "EXM";
                    }
                    // add 7853-差分コンバートで更新/削除ができない 楊 end
                    //add   抽出された繰返し日の取得 鄭 start
                    dto.tableName = fileNamePrefix;
                    //add   抽出された繰返し日の取得 鄭 end
                    dto.convertDatetime = dtNow;
                    dto.startDate = SelecteddtpStartDate[CommonConfig.seriesCd];
                    dto.endDate = SelecteddtpEndDate[CommonConfig.seriesCd];
                    dto.patidList = new List<String>(completedPatIdList);
                    dao.Insert(dto);
                }
            }

            if (!_IsConvertAll)
                // Add #7997 趙 Start
                if ("1" == loopKbn || "2" == loopKbn)
                    // Add #7997 趙 End
                    //mod 9298 zc start
                    if ("dialysis".Equals(fileNamePrefix))
                    {
                        if (isPat != 0)
                        {
                            ShowMsgBoxInfo("データコンバートが完了しました。");
                        }
                    }
                    else
                    {
                        ShowMsgBoxInfo("データコンバートが完了しました。");
                    }
            //ShowMsgBoxInfo("データコンバートが完了しました。");
            //mod 9298 zc end

            // 画面設定条件の保存
            SaveAppConfigInputStatus();

            EnableControl(true);
        }

        /// <summary>
        /// 患者IDリストでコンバート処理を実施する
        /// </summary>
        /// <param name="listSelectedPatId">患者IDリスト</param>
        /// <param name="listSelectSpan">対象期間</param>
        /// <param name="exportFolderPath">出力パス</param>
        /// <param name="listErrorPatAll">エラー患者IDリスト</param>
        /// 
        /// <returns></returns>
        private List<string> ConvertMongoDBList(List<string> listSelectedPatId,
            List<SelectSpan> listSelectSpan,
            string exportFolderPath,
            List<string> listErrorPatAll
            )
        {
            // add 2020-12-13 594 ログファイルを作成または開きます う start
            string[] filesp = exportFolderPath.Split('_');
            string fileName = "";
            BuildConvertStatus bcs = new BuildConvertStatus();
            bool issaveStatus = true;
            List<string> fileStatus = new List<string>();
            string LogInfo = "";
            _lbSQLFileBuildStatus.Items.Clear();
            if (filesp.Length == 3)
            {
                //mod #9696 djy start
                //fileName = filesp[2];
                fileName = ReplaceLogName(filesp[2]);
                //mod #9696 djy end
                if (bcs.CreateStatusFile(fileName))
                {
                    LogInfo = fileName + "ファイル作成の進捗";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo);
                    issaveStatus = true;
                }
                else
                {
                    issaveStatus = false;
                }
            }
            else
            {
                issaveStatus = false;
            }
            // add 2020-12-13 594 ログファイルを作成または開きます う end
            //add 11161 start
            if (!CommonConfig.isDiff)
            {
                string start = string.Empty;
                if (CommonConfig.AUTOMATIC.Equals("0"))
                {
                    start = "いいえ";
                }
                else
                {
                    start = "はい";
                }
                SaveAndShowLogStr(bcs, fileName, "", "処理切替え自動:" + start);
            }
            //add 11161 start


            // 選択されている患者IDを処理件数ずつに分割
            int chunkSize = 20;
            var listPatidList = listSelectedPatId.Select((patid, index) => new { patid, index })
                .GroupBy(x => x.index / chunkSize)
                .Select(g => g.Select(x => x.patid));
            // 処理対象患者件数
            int patIdCount = listSelectedPatId.Count;
            // 処理済患者件数
            int finishedPatIdCount = 0;
            // 処理正常終了患者IDリスト
            List<string> completedPatIdList = new List<string>();
            // 患者IDエラーリスト
            if (listErrorPatAll == null)
                listErrorPatAll = new List<string>();
            // 進捗表示用のデータグリッドビュー作成
            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
            //this.MakeDataGridViewForConvertProgress(dgvConvertTable, m_convertTableNames, listPatidList);
            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
            int chkRowIndex = 0;
            foreach (var procPatidList in listPatidList)
            {
                // 選択した患者リストへ分割した患者リストを代入
                List<string> chunkPatIdList = procPatidList.ToList();

                // コンバートクラスインスタンス化
                ConvertControl convertControl = CreateConvertControl(ConvertControl.CONV_TYPE.PAT_SPECIFY_PERIOD);

                ConvertBase.WriteTraceLog("##### " + fileName + "処理開始 #####");
                ConvertBase.WriteTraceLog("対象：{0}", string.Join(",", chunkPatIdList.ToArray()));

                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "##### " + fileName + "処理開始 #####";
                    string LogInfo2 = string.Format("対象：{0}", string.Join(",", chunkPatIdList.ToArray()));
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo2);
                }
                // add 2020-12-13 594 ログを書き込む う end

                // 指定期間ごとにコンバート
                foreach (var selectSpan in listSelectSpan)
                {
                    // 対象テーブルごとに処理
                    foreach (string convertTableName in m_convertTableNames)
                    {
                        string[] tableNameVS = convertTableName.Split('-');
                        string tableName = tableNameVS[tableNameVS.Length - 1];

                        Stopwatch stopwatch = Stopwatch.StartNew();
                        // 進捗チェックボックス設定
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        //var chkCell = dgvConvertTable[chkColumnIndex++, chkRowIndex];
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                        ConvertBase.WriteTraceLog("##### データエクスポート開始 #####");
                        ConvertBase.WriteTraceLog("テーブル名：{0}", convertTableName);
                        // add 2020-12-13 594 ログを書き込む う start
                        if (issaveStatus)
                        {
                            string LogInfo1 = "##### データエクスポート開始 #####";
                            string LogInfo2 = string.Format("テーブル名：{0}", tableName);
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo2);
                        }
                        // add 2020-12-13 594 ログを書き込む う end

                        #region 初期化処理(共通処理)

                        var isSuccess = convertControl.Init(db, convertTableName);
                        if (isSuccess == false)
                        {
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "初期化に失敗しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                            //SetCellColor(chkCell, Color.Red);
                            //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                            continue;
                        }
                        // add 2020-12-13 594 ログを書き込む う start
                        if (issaveStatus)
                        {
                            string LogInfo1 = "初期化に成功しました。";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                        }
                        // add 2020-12-13 594 ログを書き込む う end
                        #endregion

                        #region コンバート元データ取得(コンバート/エクスポート用処理)

                        if (useMode == Mode.Convert || useMode == Mode.Export)
                        {
                            //// 進捗情報
                            //stlblTable.Text = "[処理内容]：元データ取得";
                            //stlblProcess.Text = "[対象テーブル]：" + convertTableName;
                            //// 処理件数の進捗を表示
                            //stlblRecordNum.Text = "処理完了患者数 "
                            //    + finishedPatIdCount.ToString()
                            //    + "/"
                            //    + patIdCount.ToString();
                        
                            Application.DoEvents();

                            // コンバート元データ取得
                            isSuccess = convertControl.SetFnwData(chunkPatIdList, null, selectSpan.startDate, selectSpan.endDate, false);
                            // 対象期間をログ出力
                            ConvertBase.WriteTraceLog("取得対象期間：{0} ～ {1}", selectSpan.startDate.ToString("yyyy/MM/dd"), selectSpan.endDate.ToString("yyyy/MM/dd"));

                            if (isSuccess == false)
                            {
                                // add 2020-12-13 594 ログを書き込む う start
                                if (issaveStatus)
                                {
                                    string LogInfo1 = "コンバート元データ取得に失敗しました。";
                                    SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                                }
                                // add 2020-12-13 594 ログを書き込む う end
                                // 取得失敗
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                                //SetCellColor(chkCell, Color.Red);
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                                continue;
                            }
                            else if (convertControl.GetFnwDataRowCount() == 0)
                            {
                                // add 2020-12-13 594 ログを書き込む う start
                                if (issaveStatus)
                                {
                                    string LogInfo1 = "元のデータは存在しない。";
                                    SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                                }
                                // add 2020-12-13 594 ログを書き込む う end
                                // 選択した全患者において元データが存在しない場合は次のテーブルへ
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                               // SetCellColor(chkCell, Color.Gray);
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                                continue;
                            }
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "コンバート元データ取得に成功しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                        }

                        #endregion

                        #region コンバート実施(コンバート/エクスポート用処理)

                        if (useMode == Mode.Convert || useMode == Mode.Export)
                        {
                            //// 進捗情報
                            //stlblTable.Text = "[処理内容]：コンバート実施";
                            //// 処理件数の進捗を表示
                            //stlblRecordNum.Text = "処理対象件数：" + convertControl.GetFnwDataRowCount().ToString()
                            //    + " "
                            //    + "処理完了患者数："
                            //    + finishedPatIdCount.ToString()
                            //    + "/"
                            //    + patIdCount.ToString();
                            
                            Application.DoEvents();

                            // 患者IDエラーリスト
                            var listErrorPat = new List<string>();

                            // コンバート実施
                            if (!tableName.Equals("ind_history") && !tableName.Equals("rst_history"))
                            {
                                isSuccess = convertControl.Convert(listErrorPat);
                            }
                            else
                            {
                                isSuccess = true;
                            }

                            if (isSuccess == false)
                            {
                                // add 2020-12-13 594 ログを書き込む う start
                                if (issaveStatus)
                                {
                                    string LogInfo1 = "コンバート実施に失敗しました。";
                                    SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                                }
                                // add 2020-12-13 594 ログを書き込む う end
                                // 失敗時は次のテーブルへ
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                                //SetCellColor(chkCell, Color.Red);
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                                continue;
                            }
                            else if (listErrorPat.Count > 0)
                            {
                                // 患者IDエラーリストへエラー患者IDを追加
                                listErrorPatAll.AddRange(listErrorPat);
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                                //SetCellColor(chkCell, Color.Red);
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                            }
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "コンバート実施に成功しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                        }

                        #endregion

                        #region エクスポート(エクスポート用処理)

                        if (useMode == Mode.Export)
                        {
                            //// 進捗情報
                            //stlblTable.Text = "[処理内容]：ファイルエクスポート";
                            //stlblProcess.Text = "[対象テーブル]：" + convertTableName;
                            //// 処理件数の進捗を表示
                            //stlblRecordNum.Text = "処理対象件数：" + convertControl.GetFnwDataRowCount().ToString()
                            //    + " "
                            //    + "処理完了患者数 "
                            //    + finishedPatIdCount.ToString()
                            //    + "/"
                            //    + patIdCount.ToString();
                           
                            Application.DoEvents();

                            // 常にInsert文を作成
                            isSuccess = convertControl.Export(exportFolderPath,
                            encoding, true,
                            true,
                            (CommonConstants.OutputFormat)Enum.ToObject(typeof(CommonConstants.OutputFormat), this._outputMode),
                            int.Parse(Settings.Default.ChunkSize));
                            if (isSuccess == false)
                            {
                                // add 2020-12-13 594 ログを書き込む う start
                                if (issaveStatus)
                                {
                                    string LogInfo1 = "Insert文の制作に失敗しました。";
                                    SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                                }
                                // add 2020-12-13 594 ログを書き込む う end
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                                // SetCellColor(chkCell, Color.Red);
                                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                                continue;
                            }
                            // add 2020-12-13 594 ログを書き込む う start
                            if (issaveStatus)
                            {
                                string LogInfo1 = "Insert文の制作に成功しました。";
                                SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            }
                            // add 2020-12-13 594 ログを書き込む う end
                        }

                        #endregion

                        // 進捗チェックボックスにチェック
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        // chkCell.Value = true;
                        // dgvConvertTable.CurrentCell = dgvConvertTable.Rows[chkRowIndex == 0 ? 0 : chkRowIndex - 1].Cells[chkColumnIndex == 0 ? 0 : chkColumnIndex - 1];
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                        Application.DoEvents();

                        ConvertBase.WriteTraceLog("経過時間：{0}:{1}", stopwatch.Elapsed.Minutes.ToString("00"), stopwatch.Elapsed.Seconds.ToString("00"));
                        ConvertBase.WriteTraceLog("##### データエクスポート完了 #####");


                        // add 2020-12-13 594 ログを書き込む う start
                        if (issaveStatus)
                        {
                            string LogInfo1 = String.Format("達成時間：{0}", DateTime.Now.ToLongTimeString());
                            string LogInfo2 = "##### データエクスポート完了 #####";
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo1);
                            SaveAndShowLogStr(bcs, fileName, tableName, LogInfo2);
                        }
                        // add 2020-12-13 594 ログを書き込む う end
                    }
                }
                chkRowIndex++;
                // 正常終了患者IDリストへ追加
                List<string> completedPatIdListWork = new List<string>(chunkPatIdList);
                completedPatIdListWork.RemoveAll(s => listErrorPatAll.Contains(s));

                completedPatIdList.AddRange(completedPatIdListWork);

                // 処理済患者件数に加算
                finishedPatIdCount += chunkPatIdList.Count;
                ConvertBase.WriteTraceLog("##### " + fileName + "処理終了 #####");
                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "##### " + fileName + "処理終了 #####";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                }
                // add 2020-12-13 594 ログを書き込む う end
            }
            // エラー患者ID一覧を出力
            if (listErrorPatAll.Count > 0)
            {
                ConvertBase.WriteTraceLog("エラー患者ID一覧：");
                listErrorPatAll.ForEach(s => ConvertBase.WriteTraceLog(s));
                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "エラー患者ID一覧：";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                    listErrorPatAll.ForEach(s => fileStatus.Add(s));
                    listErrorPatAll.ForEach(s => _lbSQLFileBuildStatus.Items.Add(s));
                }
                // add 2020-12-13 594 ログを書き込む う end
            }

            return completedPatIdList.Distinct().ToList();
        }


        /// <summary>
        /// 患者、期間を指定してコンバート処理
        /// </summary>
        private void ConvertMongoDB(bool isRegistConvertHistory, string fileNamePrefix)
        {
            var dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;
            if (!_IsConvertAll)
            {
                if (!DisplayConfirmationDialog("")) return;
            }
            // 患者選択チェック
            //if (!CheckPatSelect()) return;

            // 施設コードの入力チェック
            if (!CheckFacilityCd()) return;

            // 出力先フォルダ作成
            // mod 2020-12-21 594 コンバートが進歩:差分・完全・追加。 う　start
            string turnType = checkTurnType();
            // Mod #7997 趙 Start
            //string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_" + fileNamePrefix + "[" + turnType + "]", dtNow.ToString("yyyyMMddHHmmss"));
            string exportFolderPath = Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd + string.Format(@"\{1}-ExportData_{0}_" + fileNamePrefix + "[" + turnType + "]", dtNow.ToString("yyyyMMddHHmmss"), this.txtFacilityCd.Text);
            // Mod #7997 趙 End
            //string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_" + fileNamePrefix, dtNow.ToString("yyyyMMddHHmmss"));
            // mod 2020-12-21 594 コンバートが進歩:差分・完全・追加。 う　end
            if (!MakeExportFolderPath(exportFolderPath)) return;

            // 確認ダイアログ(共通処理)
            //string confirmMsg = string.Format("データエクスポートを開始します。\n対象期間：{0} ～ {1}", dtpStartDate.Value.Date.ToString("yyyy/MM/dd"), dtpEndDate.Value.Date.ToString("yyyy/MM/dd"));
            //if (!_IsConvertAll)
            //    if (!DisplayConfirmationDialog(confirmMsg)) return;

            // ボタン活性変更(共通処理)
            EnableControl(false);

            // エクスポート先フォルダ作成(エクスポート用処理)
            // 出力しない
            // if (!MakeConvertInfoPat(dtNow, exportFolderPath)) return;

            // 透析条件設定CommonConfigにセット
            //CommonConfig.Boold = ComParam.Boold;
            //CommonConfig.p_A = ComParam.p_A;
            //CommonConfig.p_V = ComParam.p_V;
            //CommonConfig.p_SN = ComParam.p_SN;

            #region 患者情報コンバート処理

            // 選択した患者IDのリスト
            List<string> listSelectedPatId = GetDgvSelectedRow(dgvPat, "ntssTable");
            // 指定期間のリスト
            List<SelectSpan> listSelectSpan = GetSelectSpan(dtpStartDate.Value.Date, dtpEndDate.Value.Date);
            // 正常終了した患者IDのリスト
            List<string> completedPatIdList;
            // エラーになった患者IDのリスト
            List<string> errorPatIdList = new List<string>();

            //listSelectedPatId.RemoveAt(1);

            completedPatIdList = ConvertMongoDBList(listSelectedPatId,
                listSelectSpan,
                exportFolderPath,
                errorPatIdList
            );

            #endregion

           

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);

           
            Application.DoEvents();

            if (isRegistConvertHistory)
            {
                // 処理した患者IDと期間をコンバート履歴テーブルに登録する
                // （処理した患者が存在する場合のみ実行）
                if (completedPatIdList.Count > 0)
                {
                    SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
                    SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
                    dto.facilityCd = this.txtFacilityCd.Text;
                    dto.tableKind = "HIS";
                    dto.convertDatetime = dtNow;
                    dto.startDate = dtpStartDate.Value.Date;
                    dto.endDate = dtpEndDate.Value.Date;
                    dto.patidList = new List<String>(completedPatIdList);
                    dao.Insert(dto);
                }
            }

            if (errorPatIdList.Count() > 0)
            {
                // Mod #7997 趙 Start
                //ShowMsgBoxWarning("データコンバートは完了しましたが、エラーが発生しています。");
                ShowMsgBoxWarning("データコンバートは完了しましたが、エラーが発生しています。" + "施設コード：" + txtFacilityCd.Text);
                // Mod #7997 趙 End
            }
            else
            {
                if (!_IsConvertAll)
                    // Add #7997 趙 Start
                    if ("1" == loopKbn || "2" == loopKbn)
                        // Add #7997 趙 End
                        ShowMsgBoxInfo("データコンバートが完了しました。");
            }


            // 画面設定条件の保存
            SaveAppConfigInputStatus();

            EnableControl(true);
        }

       

        private void compressFolder(string exportFolderPath)
        {
            // フォルダ圧縮
            ZipControl zc = new ZipControl();

            // mod FNSI-差分コンバート対応 楊 start
            // フォルダにファイルがないの場合、圧縮ファイル作成不要
            System.IO.DirectoryInfo di = new System.IO.DirectoryInfo(exportFolderPath);
            // フォルダにファイルがないの場合、圧縮ファイル作成不要
            bool hasAnyFile = di.GetFiles("*", SearchOption.AllDirectories).Length > 0;
            if (!hasAnyFile)
            {
                // 元フォルダの削除
                System.IO.Directory.Delete(exportFolderPath, true);
                ConvertBase.WriteTraceLog("コンバート元データがないので、圧縮ファイル作成しない。");
                return;
            }
            // mod FNSI-差分コンバート対応 楊 end

            // mod settingファイルより、選定されていないアップロードファイル判定を追加する  楊 start
            zc.compress(exportFolderPath + ".zip", exportFolderPath, CommonConfig.ZipFilePassword, int.Parse(Settings.Default.maxFileSize));
            // mod settingファイルより、選定されていないアップロードファイル判定を追加する  楊 end
            // 元フォルダの削除
            System.IO.Directory.Delete(exportFolderPath, true);
        }

        /// <summary>
        /// エクスポート用フォルダ作成及びエクスポート情報出力
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        private bool MakeExportFolderPath(string exportFolderPath)
        {
            try
            {
                Directory.CreateDirectory(exportFolderPath);
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog(ex, "データエクスポート先フォルダの作成に失敗しました。");
                ShowMsgBoxError("データエクスポートに失敗しました。");
                return false;
            }
            return true;
        }

      

        /// <summary>
        /// ConvertControlを生成して返す
        /// </summary>
        /// <returns>生成されたConvertControl</returns>
        private ConvertControl CreateConvertControl(ConvertControl.CONV_TYPE convertType)
        {
            // mod FNSI-seriesCd取得修正 楊 start
            // seriesCd = string.Empty;
            //if (null != cmbSeriesCd.SelectedValue)
            //{
            //    seriesCd = cmbSeriesCd.SelectedValue.ToString();
            //}
            // Add #7997 趙 Start
            string seriesCd = txtSeriesCd.Text;
            // Add #7997 趙 End
            // mod FNSI-seriesCd取得修正 楊 end  
            ConvertControl convertControl = new ConvertControl(txtFacilityCd.Text,
                // mod FNSI-seriesCd取得修正 楊 start
                // cmbSeriesCd.Text,
                seriesCd,
                // mod FNSI-seriesCd取得修正 楊 end
                Directory.GetCurrentDirectory() + @"\SQL",
                convertType);

            return convertControl;
        }

        /// <summary>
        /// テーブルのリスト、期間を指定してコンバート処理を行う
        /// （期間指定用）
        /// </summary>
        /// <param name="listConvertTableInfoDto"></param>
        /// <param name="dtNow"></param>
        /// <param name="exportFolderPath"></param>
        /// <returns></returns>
        private bool ConvertTableForSpecifyPeriod(
            List<DgvPatRowDto> listConvertTableInfoDto,
            string exportFolderPath,
            DateTime dtStartDate,
            DateTime dtEndDate,
            bool isSync)
        {
            // add 2020-12-14 594 ログファイルを作成または開きます う start
            string[] filesp = exportFolderPath.Split('_');
            string fileName = "";
            BuildConvertStatus bcs = new BuildConvertStatus();
            bool issaveStatus = true;
            List<string> fileStatus = new List<string>();
            _lbSQLFileBuildStatus.Items.Clear();
            if (filesp.Length == 3)
            {
                //mod #9696 djy start
                //fileName = filesp[2];
                fileName = ReplaceLogName(filesp[2]);
                //mod #9696 djy end
                if (bcs.CreateStatusFile(fileName))
                {
                    string LogInfo1 = fileName + "ファイル作成の進捗";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                    issaveStatus = true;
                }
                else
                {
                    issaveStatus = false;
                }
            }
            else
            {
                issaveStatus = false;
            }
            // add 2020-12-14 594 ログファイルを作成または開きます う end

            // 対象テーブルごとに処理
            foreach (DgvPatRowDto dto in listConvertTableInfoDto)
            {
                ConvertControl convertControl = CreateConvertControl(ConvertControl.CONV_TYPE.ALL_RECORD);

                // 紐付けテーブルの読み込み
                if (convertControl.GetRelationTable(
                    dto.ntssTableName) == false)
                {
                    // add 2020-12-14 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = dto.ntssTableName + "の紐付け情報読み込みに失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-14 594 ログを書き込む う end
                    ShowMsgBoxError(dto.ntssTableName + "の紐付け情報読み込みに失敗しました。");
                    return false;
                }

                Stopwatch stopwatch = Stopwatch.StartNew();
                // 進捗チェックボックス設定
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                //var chkCell = dgvConvertTable[chkColumnIndex, chkRowIndex++];
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                ConvertBase.WriteTraceLog("##### {0}開始 #####", EXPORT_PROC_NAME);
                ConvertBase.WriteTraceLog("テーブル名：{0}", dto.ntssTableName);

                // add 2020-12-14 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = string.Format("##### {0}開始 #####", EXPORT_PROC_NAME);
                    string LogInfo2 = string.Format("テーブル名：{0}", dto.ntssTableName);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo2);
                }
                // add 2020-12-14 594 ログを書き込む う end

                #region 初期化処理(共通処理)

                bool isSuccess = convertControl.Init(db, dto);
                if (isSuccess == false)
                {
                    // add 2020-12-14 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "初期化に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-14 594 ログを書き込む う end\
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                // add 2020-12-14 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "初期化に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }
                // add 2020-12-14 594 ログを書き込む う end
                #endregion

                #region コンバート元データ取得(コンバート/エクスポート用処理)

                
                Application.DoEvents();

                // コンバート元データ取得
                isSuccess = convertControl.SetFnwDataSprcifyPeriod(dtStartDate, dtEndDate, isSync);

                if (isSuccess == false)
                {
                    // add 2020-12-14 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "コンバート元データ取得に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-14 594 ログを書き込む う end
                    // 取得失敗
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    continue;
                }
                else if (convertControl.GetFnwDataRowCount() == 0)
                {
                    // add 2020-12-14 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "元のデータは存在しない。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-14 594 ログを書き込む う end
                    // 元データが存在しない場合は次のテーブルへ
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Gray);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                // add 2020-12-14 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "コンバート元データ取得に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }
                // add 2020-12-14 594 ログを書き込む う end
                #endregion

                #region コンバート実施(コンバート/エクスポート用処理)
                var listErrorKey = new List<string>();
                // コンバート実施
                isSuccess = convertControl.Convert(listErrorKey);
                if (isSuccess == false)
                {
                    // add 2020-12-14 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "コンバート実施に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-14 594 ログを書き込む う end
                    // 失敗時は次のテーブルへ
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                //else if (listErrorKey.Count > 0)
                //{
                //  SetCellColor(chkCell, Color.Red);
                //}
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                // add 2020-12-14 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "コンバート実施に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }
                // add 2020-12-14 594 ログを書き込む う end
                #endregion

                #region エクスポート(エクスポート用処理)
                // 進捗情報
               
                Application.DoEvents();

                // エクスポート実施
                // 常にInsert文のみ作成
                isSuccess = convertControl.Export(exportFolderPath,
                    encoding,
                    true,
                    false,
                    (CommonConstants.OutputFormat)Enum.ToObject(typeof(CommonConstants.OutputFormat), this._outputMode),
                    int.Parse(Settings.Default.ChunkSize));
                if (isSuccess == false)
                {
                    // add 2020-12-14 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "Insert文の制作に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-14 594 ログを書き込む う end
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                // add 2020-12-14 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "Insert文の制作に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }
                // add 2020-12-14 594 ログを書き込む う end
                #endregion

                // 進捗チェックボックスにチェック
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                //chkCell.Value = true;
                //dgvConvertTable.CurrentCell = dgvConvertTable.Rows[chkRowIndex - 1].Cells[chkColumnIndex];
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                Application.DoEvents();

                ConvertBase.WriteTraceLog("経過時間：{0}:{1}", stopwatch.Elapsed.Minutes.ToString("00"), stopwatch.Elapsed.Seconds.ToString("00"));
                ConvertBase.WriteTraceLog("##### {0}完了 #####", EXPORT_PROC_NAME);
                // add 2020-12-14 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = String.Format("達成時間：{0}", DateTime.Now.ToLongTimeString());
                    string LogInfo2 = String.Format("##### {0}完了 #####", EXPORT_PROC_NAME);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo2);
                }
                // add 2020-12-14 594 ログを書き込む う end
            }
            // add 2020-12-14 594 ログを書き込む う start
            if (issaveStatus)
            {
                string LogInfo1 = "全部完成した。";
                SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
            }
            // add 2020-12-14 594 ログを書き込む う end
            return true;
        }

        //11667 日常点検コンバート修正 start
        //11667 日常点検コンバート修正 end
        /// <summary>
        /// テーブルのリストを指定してコンバート処理を行う
        /// valueOfPrimaryKeyが指定されている場合は、そのデータを対象に処理を行う
        /// </summary>
        /// <param name="listConvertTableInfoDto"></param>
        /// <param name="exportFolderPath"></param>
        /// <param name="valueOfPrimaryKey"></param>
        private bool ConvertTableForAllRecord(
            List<DgvPatRowDto> listConvertTableInfoDto,
            string exportFolderPath,
            string valueOfPrimaryKey,
            bool isMakePatidFolder)
        {
            // add 2020-12-13 594 ログファイルを作成または開きます う start
            string[] filesp = exportFolderPath.Split('_');
            string fileName = "";
            BuildConvertStatus bcs = new BuildConvertStatus();
            bool issaveStatus = true;
            List<string> fileStatus = new List<string>();
            _lbSQLFileBuildStatus.Items.Clear();
            if (filesp.Length == 3)
            {
                //mod #9696 djy start
                //fileName = filesp[2];
                fileName = ReplaceLogName(filesp[2]);
                //mod #9696 djy end
                if (bcs.CreateStatusFile(fileName))
                {
                    string LogInfo1 = fileName + "ファイル作成の進捗";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                    issaveStatus = true;
                }
                else
                {
                    issaveStatus = false;
                }
            }
            else
            {
                issaveStatus = false;
            }
            // add 2020-12-13 594 ログファイルを作成または開きます う end

            //add 11161 start
            if (!CommonConfig.isDiff) {
                string start = string.Empty;
                if (CommonConfig.AUTOMATIC.Equals("0"))
                {
                    start = "いいえ";
                }
                else
                {
                    start = "はい";
                }
                SaveAndShowLogStr(bcs, fileName, "", "処理切替え自動:" + start);
            }
            
            //add 11161 start
            // 対象テーブルごとに処理
            CommonConfig.Mst_select = new List<string>();
            //9862
            CommonConfig.Mst_DEL = new List<string>();
            //9862
            //add #10663 djy start
            if (exportFolderPath.Contains("convert(mst)"))
            {
                var sqlSurveyType = Path.Combine("SQL\\SYNC_WATER_SURVEY_TYPE_TEXT", "INSERT_BY_SURVEY_TYPE" + ".sql");
                insertSyncWaterText(sqlSurveyType);
                //add 12160 start
                var sqlFnsiSurveyType = Path.Combine("SQL\\SYNC_WATER_SURVEY_TYPE_TEXT", "FNSI_INSERT_BY_SURVEY" + ".sql");
                insertSyncWaterText(sqlFnsiSurveyType);
                //add 12160 end
                var sqlSurvey = Path.Combine("SQL\\SYNC_WATER_SURVEY_TYPE_TEXT", "INSERT_BY_SURVEY" + ".sql");
                insertSyncWaterText(sqlSurvey);
            }
            //add #10663 djy end
            foreach (DgvPatRowDto dto in listConvertTableInfoDto)
            {

                if (CommonConstants.NO_DIFF_TABLES.Contains(dto.fnwTableName+ "-" + dto.ntssTableName) && CommonConfig.isDiff)
                {
                    continue;
                }
                if (dto.ntssTableName.Equals("mst_pat_list_layout"))
                {
                    var sqlFilePath = Path.Combine("SQL\\config", "mst_pat_list_layout.sql");
                    try
                    {
                        insertMstPatLlistLayoutText(sqlFilePath, exportFolderPath);
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, "Insert文の制作に成功しました。");
                        continue;
                    }
                    catch (Exception)
                    {
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, "Insert文の制作に失敗しました。");
                        continue;
                    }

                }
                // コンバートコントロールクラスインスタンス化(共通処理)
                ConvertControl convertControl = CreateConvertControl(ConvertControl.CONV_TYPE.ALL_RECORD);

                // 紐付けテーブルの読み込み
                if (convertControl.GetRelationTable(
                    dto.ntssTableName) == false)
                {
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = dto.ntssTableName + "の紐付け情報読み込みに失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                    ShowMsgBoxError(dto.ntssTableName + "の紐付け情報読み込みに失敗しました。");
                    return false;
                }

                var listErrorPat = new List<string>();
                Stopwatch stopwatch = Stopwatch.StartNew();
                // 進捗チェックボックス設定
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                // var chkCell = dgvConvertTable[chkColumnIndex, chkRowIndex++];
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                ConvertBase.WriteTraceLog("##### {0}開始 #####", EXPORT_PROC_NAME);
                ConvertBase.WriteTraceLog("テーブル名：{0}", dto.ntssTableName);

                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = string.Format("##### {0}開始 #####", EXPORT_PROC_NAME);
                    string LogInfo2 = string.Format("テーブル名：{0}", dto.ntssTableName);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo2);
                }
                // add 2020-12-13 594 ログを書き込む う end

                #region 初期化処理(共通処理)

                bool isSuccess = convertControl.Init(db, dto);
                if (isSuccess == false)
                {
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "初期化に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "初期化に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }






                // add 2020-12-13 594 ログを書き込む う end

                #endregion

                #region コンバート元データ取得(コンバート/エクスポート用処理)

                // 進捗情報
               
                Application.DoEvents();

                // コンバート元データ取得
                //mod  7403  2022-06-1 鄭 start
                string url = "";
                isSuccess = convertControl.SetFnwDataFromXmlConfig(url, valueOfPrimaryKey, (valueOfPrimaryKey == null ? false : true));
                //isSuccess = convertControl.SetFnwDataFromXmlConfig(valueOfPrimaryKey, (valueOfPrimaryKey == null ? false : true));
                //mod  7403   2022-06-1 鄭 end

                if (isSuccess == false)
                {
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "コンバート元データ取得に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                    // 取得失敗
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                else if (convertControl.GetFnwDataRowCount() == 0)
                {
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "元のデータは存在しない。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                    // 元データが存在しない場合は次のテーブルへ
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Gray);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "コンバート元データ取得に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }
                // add 2020-12-13 594 ログを書き込む う end

                #endregion

                #region コンバート実施(コンバート/エクスポート用処理)
                // 進捗情報
                
                Application.DoEvents();

                // コンバート実施
                isSuccess = convertControl.Convert(listErrorPat);
                if (isSuccess == false)
                {
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "コンバート実施に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                    // 失敗時は次のテーブルへ
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                else if (listErrorPat.Count > 0)
                {
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                }
                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "コンバート実施に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }
                // add 2020-12-13 594 ログを書き込む う end

                #endregion

                #region エクスポート(エクスポート用処理)
                // 進捗情報
               
                Application.DoEvents();

                // エクスポート実施
                // 常にInsert文のみ作成
                //pat_unique_history変更csv
                if ("pat_unique_history".Equals(dto.ntssTableName) || "mst_favorite_facility".Equals(dto.ntssTableName))
                {
                    this._outputMode = (int)CommonConstants.OutputFormat.CSV;
                }
                else
                {
                    this._outputMode = (int)CommonConstants.OutputFormat.SQL;
                }
                //pat_unique_history変更csv
                isSuccess = convertControl.Export(exportFolderPath,
                encoding,
                true,
                isMakePatidFolder,
                (CommonConstants.OutputFormat)Enum.ToObject(typeof(CommonConstants.OutputFormat), this._outputMode),
                int.Parse(Settings.Default.ChunkSize));
                if (isSuccess == false)
                {
                    // add 2020-12-13 594 ログを書き込む う start
                    if (issaveStatus)
                    {
                        string LogInfo1 = "Insert文の制作に失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    // add 2020-12-13 594 ログを書き込む う end
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                    //SetCellColor(chkCell, Color.Red);
                    //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    continue;
                }
                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = "Insert文の制作に成功しました。";
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                }
                // add 2020-12-13 594 ログを書き込む う end

                #endregion

                // 進捗チェックボックスにチェック
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                //chkCell.Value = true;
                //dgvConvertTable.CurrentCell = dgvConvertTable.Rows[chkRowIndex - 1].Cells[chkColumnIndex];
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                Application.DoEvents();

                ConvertBase.WriteTraceLog("経過時間：{0}:{1}", stopwatch.Elapsed.Minutes.ToString("00"), stopwatch.Elapsed.Seconds.ToString("00"));
                ConvertBase.WriteTraceLog("##### {0}完了 #####", EXPORT_PROC_NAME);

                // add 2020-12-13 594 ログを書き込む う start
                if (issaveStatus)
                {
                    string LogInfo1 = String.Format("達成時間：{0}", DateTime.Now.ToLongTimeString());
                    string LogInfo2 = String.Format("##### {0}完了 #####", EXPORT_PROC_NAME);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo2);
                }
                // add 2020-12-13 594 ログを書き込む う end
            }
            // add 2020-12-13 594 ログを書き込む う start
            if (issaveStatus)
            {
                string LogInfo1 = "全部完成した。";
                SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
            }
            // add 2020-12-13 594 ログを書き込む う end
            //add 9668  zc start
            if (CommonConfig.Mst_select.Count > 0 && CommonConfig.isDiff)
            {
                using (FileStream fsWrite = new FileStream(exportFolderPath + "/Mst_select.txt", FileMode.Append, FileAccess.Write))
                {
                    byte[] myByte = null;
                    myByte = Encoding.UTF8.GetBytes(String.Join("\r\n", CommonConfig.Mst_select.ToList()));
                    fsWrite.Write(myByte, 0, myByte.Length);
                }
            }
            //add 9668  zc end
            //add 9862  zc start
            if (CommonConfig.Mst_DEL.Count > 0 && CommonConfig.isDiff)
            {
                using (FileStream fsWrite = new FileStream(exportFolderPath + "/Mst_DEL.txt", FileMode.Append, FileAccess.Write))
                {
                    byte[] myByte = null;
                    myByte = Encoding.UTF8.GetBytes(String.Join("\r\n", CommonConfig.Mst_DEL.ToList()));
                    fsWrite.Write(myByte, 0, myByte.Length);
                }
            }
            //add 9862  zc end
            return true;
        }

        //add #10663 djy start
        /// <summary>
        /// insertSyncWaterText
        /// </summary>
        /// <param name="sqlFilePath"></param>
        private void insertSyncWaterText(String sqlFilePath)
        {
            LogManager.WriteTraceLog(null, null, "[情報]" + string.Format("実行SQL：{0}", sqlFilePath));
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    //mod #10418 start
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    var param = db.GetIMakeSqlParameters();
                    if (sql.Contains(":SERIES_CD"))
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                    db.SelectTable(sql, param.GetParam());
                    //mod #10418 end
                }
            }
            catch (Exception e)
            {
                LogManager.WriteErrorLog(null, null, "[エラー]" + "コンバート元データ取得に失敗しました。", e);
            }
        }
        //add #10663 djy end

        //add #8459 zc start
        /// <summary>
        /// insertMstPatLlistLayoutText
        /// </summary>
        /// <param name="sqlFilePath"></param>
        private void insertMstPatLlistLayoutText(String sqlFilePath, string exportFolderPath)
        {
            LogManager.WriteTraceLog(null, null, "[情報]" + string.Format("mst_pat_list_layout：{0}", sqlFilePath));
            try
            {
                string sql;
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    sql = sr.ReadToEnd().Replace("{facility_cd}", txtFacilityCd.Text);

                }
                using (FileStream fsWrite = new FileStream(
                            Path.Combine(exportFolderPath, "mst_pat_list_layout_0001.sql"),
                            FileMode.Append,
                            FileAccess.Write))
                {
                    byte[] myByte = Encoding.UTF8.GetBytes(sql);
                    fsWrite.Write(myByte, 0, myByte.Length);
                }
            }
            catch (Exception e)
            {
                LogManager.WriteErrorLog(null, null, "[エラー]" + "mst_pat_list_layoutデータ取得に失敗しました。", e);
            }
        }
        //add #8459 zc end

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// テーブルのリストを指定してコンバート処理を行う
        /// </summary>
        /// <param name="listConvertTableInfoDto"></param>
        /// <param name="exportFolderPath"></param>
        /// <param name="isMakePatidFolder">患者毎にPATIDでフォルダを作成する</param>
        /// <returns></returns>
        private bool ConvertTableForMotion(
            List<DgvPatRowDto> listConvertTableInfoDto,
            string exportFolderPath,
            bool isMakePatidFolder)
        {
            string[] filesp = exportFolderPath.Split('_');
            string fileName = "";
            BuildConvertStatus bcs = new BuildConvertStatus();
            bool issaveStatus = true;
            List<string> fileStatus = new List<string>();
            _lbSQLFileBuildStatus.Items.Clear();
            if (filesp.Length == 3)
            {
                //mod #9696 djy start
                //fileName = filesp[2];
                fileName = ReplaceLogName(filesp[2]);
                //mod #9696 djy end
                if (bcs.CreateStatusFile(fileName))
                {
                    string LogInfo1 = fileName + "ファイル作成の進捗";
                    SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
                    issaveStatus = true;
                }
                else
                {
                    issaveStatus = false;
                }
            }
            else
            {
                issaveStatus = false;
            }
            //add 11161 start
            if (!CommonConfig.isDiff)
            {
                string start = string.Empty;
                if (CommonConfig.AUTOMATIC.Equals("0"))
                {
                    start = "いいえ";
                }
                else
                {
                    start = "はい";
                }
                SaveAndShowLogStr(bcs, fileName, "", "処理切替え自動:" + start);
            }
            //add 11161 start
            // 対象テーブルごとに処理
            foreach (DgvPatRowDto dto in listConvertTableInfoDto)
            {
                // コンバートコントロールクラスインスタンス化(共通処理)
                ConvertControl convertControl = CreateConvertControl(ConvertControl.CONV_TYPE.MOTION);

                // 紐付けテーブルの読み込み
                if (convertControl.GetRelationTable(
                    dto.ntssTableName) == false)
                {
                    if (issaveStatus)
                    {
                        string LogInfo1 = dto.ntssTableName + "の紐付け情報読み込みに失敗しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    ShowMsgBoxError(dto.ntssTableName + "の紐付け情報読み込みに失敗しました。");
                    return false;
                }

                var listErrorPat = new List<string>();
                Stopwatch stopwatch = Stopwatch.StartNew();
                // 進捗チェックボックス設定
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                //var chkCell = dgvConvertTable[chkColumnIndex, chkRowIndex++];
                //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                // #8400 zl start
                var yearMonthList = new List<string>();
                if (!CommonConfig.isDiff)
                {
                    // 全期間はチェックする場合
                    if (chkSelectAllSpan.Checked)
                    {
                        // mod #11067 【たくしん会】装置記録出力時にエラーが発生する limingyang start
                        //mod #10418 start
                        string sql = @"
                                    SELECT MIN(TABLE_NAME) AS TABLE_NAME
                                    FROM USER_TABLES
                                    WHERE TABLE_NAME LIKE :LIKE_NAME
                                    AND TABLE_NAME != :EXACT_NAME
                                    AND REGEXP_LIKE(TABLE_NAME, '.*_[12][0-9]{3}[0-9]{2}$')";

                        IMakeSqlParameters param = db.GetIMakeSqlParameters();
                        param.AddParam(":LIKE_NAME", "%" + dto.fnwTableName + "%");
                        param.AddParam(":EXACT_NAME", dto.fnwTableName);
                        DataTable dt = db.SelectTable(sql, param.GetParam());
                        //mod #10418 end
                        string yyyyMMdd;
                        //if (dt.Rows.Count == 0)
                        if (string.IsNullOrWhiteSpace(dt.Rows[0]["TABLE_NAME"].ToString()))
                        {
                            yyyyMMdd = DateTime.Now.AddMonths(-2).ToString("yyyyMM") + "01";
                        }
                        else
                        {
                            string tableName = dt.Rows[0]["TABLE_NAME"].ToString();
                            yyyyMMdd = tableName.Replace(dto.fnwTableName + "_", "") + "01";
                        }
                        DateTime startDt = DateTime.Now.Date;
                        try
                        {
                            startDt = DateTime.ParseExact(yyyyMMdd, "yyyyMMdd", System.Globalization.CultureInfo.CurrentCulture);
                        }
                        catch (Exception e)
                        {
                            string LogInfo = e.Message;
                            SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo);
                            throw e;
                        }
                        //DateTime startDt = DateTime.ParseExact(yyyyMMdd, "yyyyMMdd", System.Globalization.CultureInfo.CurrentCulture);
                        // mod #11067 【たくしん会】装置記録出力時にエラーが発生する limingyang end
                        DateTime endDt = DateTime.Now.Date;
                        for (DateTime dateTime = startDt; dateTime <= endDt; dateTime = dateTime.AddMonths(1))
                        {
                            yearMonthList.Add(dateTime.ToString("yyyyMM"));
                        }
                    }
                    else
                    {
                        for (DateTime dt = SelecteddtpStartDate[CommonConfig.seriesCd]; dt <= SelecteddtpEndDate[CommonConfig.seriesCd]; dt = dt.AddMonths(1))
                        {
                            yearMonthList.Add(dt.ToString("yyyyMM"));
                        }
                    }
                }
                else
                {
                    DateTime startDt = DateTime.Now.Date.AddMonths(-3);
                    DateTime endDt = DateTime.Now.Date;
                    for (DateTime dateTime = startDt; dateTime <= endDt; dateTime = dateTime.AddMonths(1))
                    {
                        yearMonthList.Add(dateTime.ToString("yyyyMM"));
                    }
                }
               
                // #8400 zl end
                for (int i = 0; i < yearMonthList.Count; i++)
                {

                    ConvertBase.WriteTraceLog("##### {0}開始 #####", EXPORT_PROC_NAME);
                    ConvertBase.WriteTraceLog("テーブル名：{0}", dto.ntssTableName);

                    if (issaveStatus)
                    {
                        string LogInfo1 = string.Format("##### {0}開始 #####", EXPORT_PROC_NAME);
                        string LogInfo2 = string.Format("テーブル名：{0}", dto.ntssTableName);
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo2);
                    }

                    #region 初期化処理(共通処理)

                    bool isSuccess = convertControl.Init(db, dto);
                    if (isSuccess == false)
                    {
                        if (issaveStatus)
                        {
                            string LogInfo1 = "初期化に失敗しました。";
                            SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                        }
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        //SetCellColor(chkCell, Color.Red);
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                        continue;
                    }

                    if (issaveStatus)
                    {
                        string LogInfo1 = "初期化に成功しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    #endregion

                    #region コンバート元データ取得(コンバート/エクスポート用処理)
                    // 進捗情報
                   
                    Application.DoEvents();

                    // #8400 zl start
                    //mod #10418 start
                    string selSql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME = :TABLE_NAME ";
                    var param1 = db.GetIMakeSqlParameters();
                    param1.AddParam(":TABLE_NAME", dto.fnwTableName + "_" + yearMonthList[i]);
                    DataTable dataTable = db.SelectTable(selSql, param1.GetParam());
                    //mod #10418 end
                    string targetTableName = dto.fnwTableName;
                    if (dataTable.Rows.Count > 0)
                    {
                        targetTableName = dataTable.Rows[0]["TABLE_NAME"].ToString();
                    }
                    DateTime startDt = DateTime.ParseExact(yearMonthList[i] + "01", "yyyyMMdd", System.Globalization.CultureInfo.CurrentCulture);
                    DateTime endDt = startDt.AddDays(1 - startDt.Day).AddMonths(1).AddDays(-1);
                    if (!chkSelectAllSpan.Checked)
                    {
                        if (yearMonthList.Count == 1)
                        {
                            startDt = dtpStartDate.Value.Date;
                            endDt = dtpEndDate.Value.Date;
                        }
                        else
                        {
                            if (i == 0)
                            {
                                startDt = dtpStartDate.Value.Date;
                                endDt = startDt.AddDays(1 - startDt.Day).AddMonths(1).AddDays(-1);
                            }
                            else if (i == yearMonthList.Count - 1)
                            {
                                startDt = DateTime.ParseExact(yearMonthList[i] + "01", "yyyyMMdd", System.Globalization.CultureInfo.CurrentCulture);
                                endDt = dtpEndDate.Value.Date;
                            }
                        }
                    }
                    // #8400 zl end

                    // コンバート元データ取得
                    string url = "";
                    // #8400 zl start
                    //isSuccess = convertControl.SetFnwDataFromXmlConfigForMotion(url, dtpStartDate.Value.Date, dtpEndDate.Value.Date, targetTableList[i]);
                    isSuccess = convertControl.SetFnwDataFromXmlConfigForMotion(url, startDt.Date, endDt.Date, targetTableName);
                    // #8400 zl end

                    if (isSuccess == false)
                    {
                        if (issaveStatus)
                        {
                            string LogInfo1 = "コンバート元データ取得に失敗しました。";
                            SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                        }
                        // 取得失敗
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        // SetCellColor(chkCell, Color.Red);
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                        continue;
                    }
                    else if (convertControl.GetFnwDataRowCount() == 0)
                    {

                        if (issaveStatus)
                        {
                            string LogInfo1 = "元のデータは存在しない。";
                            SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                        }
                        // 元データが存在しない場合は次のテーブルへ
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        //SetCellColor(chkCell, Color.Gray);
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                        continue;
                    }

                    if (issaveStatus)
                    {
                        string LogInfo1 = "コンバート元データ取得に成功しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    #endregion

                    #region コンバート実施(コンバート/エクスポート用処理)
                    // 進捗情報
                    
                    Application.DoEvents();

                    // コンバート実施
                    isSuccess = convertControl.Convert(listErrorPat);
                    if (isSuccess == false)
                    {
                        if (issaveStatus)
                        {
                            string LogInfo1 = "コンバート実施に失敗しました。";
                            SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                        }
                        // 失敗時は次のテーブルへ
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        //SetCellColor(chkCell, Color.Red);
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                        continue;
                    }
                    else if (listErrorPat.Count > 0)
                    {
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        //SetCellColor(chkCell, Color.Red);
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                    }

                    if (issaveStatus)
                    {
                        string LogInfo1 = "コンバート実施に成功しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    #endregion

                    #region エクスポート(エクスポート用処理)
                    // 進捗情報
                 
                    Application.DoEvents();

                    // エクスポート実施
                    // 常にInsert文のみ作成
                    isSuccess = convertControl.Export(exportFolderPath,
                    encoding,
                    true,
                    isMakePatidFolder,
                    (CommonConstants.OutputFormat)Enum.ToObject(typeof(CommonConstants.OutputFormat), this._outputMode),
                    int.Parse(Settings.Default.ChunkSize));
                    if (isSuccess == false)
                    {
                        if (issaveStatus)
                        {
                            string LogInfo1 = "Insert文の制作に失敗しました。";
                            SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                        }
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl start
                        //SetCellColor(chkCell, Color.Red);
                        //del 10859_5 設定画面のSTATUSが用途不明　-使用していない場合は削除すること hyl end
                        continue;
                    }

                    if (issaveStatus)
                    {
                        string LogInfo1 = "Insert文の制作に成功しました。";
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                    }
                    #endregion

                    // 進捗チェックボックスにチェック
                    
                    Application.DoEvents();

                    ConvertBase.WriteTraceLog("経過時間：{0}:{1}", stopwatch.Elapsed.Minutes.ToString("00"), stopwatch.Elapsed.Seconds.ToString("00"));
                    ConvertBase.WriteTraceLog("##### {0}完了 #####", EXPORT_PROC_NAME);

                    if (issaveStatus)
                    {
                        string LogInfo1 = String.Format("達成時間：{0}", DateTime.Now.ToLongTimeString());
                        string LogInfo2 = String.Format("##### {0}完了 #####", EXPORT_PROC_NAME);
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo1);
                        SaveAndShowLogStr(bcs, fileName, dto.ntssTableName, LogInfo2);
                    }
                }
            }
            if (issaveStatus)
            {
                string LogInfo1 = "全部完成した。";
                SaveAndShowLogStr(bcs, fileName, "", LogInfo1);
            }
            return true;
        }
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end

    


        private void SaveAndShowLogStr(BuildConvertStatus bcs, string fileName, string tableName, string LogInfo)
        {
            //mod 7997 start
            string logStr = BuildLogStr(tableName, LogInfo);
            bcs.OpenAndWriteStatusFile(fileName, logStr);
            LBAddItem(_lbSQLFileBuildStatus, logStr);
            //mod 7997 end
        }

        private string BuildLogStr(string tableName, string text)
        {
           
            //mod 7997 start
            var now = DateTime.Now;
            var prefix = string.IsNullOrEmpty(tableName)
                ? " "
                : $"table {tableName} ";

            return $"「{CommonConfig.FacilityCd}」" +
                   $"{now:yyyy-MM-dd} {now:HH:mm:ss} : {prefix}実行 {text}";
            //mod 7997 end
        }

        delegate void AddItemCallback(ListBox listBoxMsg, string text);
        private void LBAddItem(ListBox listBoxMsg, string text)
        {
            // mod 2023-07-06 #8585 マルチスレッド start
            if (listBoxMsg.InvokeRequired)
            {
                //mod 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
                //this.BeginInvoke(new Action(() =>
                listBoxMsg.BeginInvoke(new Action(() =>
                //mod 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
                {
                    bool scroll = false;
                    if (listBoxMsg.TopIndex == listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight))
                        scroll = true;
                    listBoxMsg.Items.Add(text);
                    if (scroll)
                        listBoxMsg.TopIndex = listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight);
                }));
            }
            else
            {
                bool scroll = false;
                if (listBoxMsg.TopIndex == listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight))
                    scroll = true;
                listBoxMsg.Items.Add(text);
                if (scroll)
                    listBoxMsg.TopIndex = listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight);
            }
            // mod 2023-07-06 #8585 マルチスレッド end
        }


        /// <summary>
        /// 期間指定してコンバートの場合
        /// </summary>
        private void ConvertSpecifyPeriod()
        {
            // スタティッククラスに格納
            DateTime dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;

            // テーブル選択チェックｔ
            if (!CheckTableSelect()) return;

            // 施設コードの入力チェック
            if (!CheckFacilityCd()) return;

            // 確認ダイアログ表示
            if (!_IsConvertAll)
                if (!DisplayConfirmationDialog("")) return;

            // ボタン活性変更(共通処理)
            EnableControl(false);

            // 出力先フォルダ作成
            string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), "period");
            if (!MakeExportFolderPath(exportFolderPath)) return;

            
            List<DgvPatRowDto> listSelectedRowList = GetDgvSelectedRowToDto(dgvPat);
           
            // コンバート実施
            if (!ConvertTableForSpecifyPeriod(listSelectedRowList,
                exportFolderPath,
                dtpStartDate.Value,
                dtpEndDate.Value,
                false))
                return;

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);

            foreach (DgvPatRowDto dto in listSelectedRowList)
            {
                // 処理したテーブルと期間をコンバート履歴テーブルに登録する
                SyncConvertHistoryDao hdao = new SyncConvertHistoryDao(db);
                SyncConvertHistoryDto hdto = new SyncConvertHistoryDto();
                hdto.facilityCd = this.txtFacilityCd.Text;
                hdto.tableKind = "PER";
                hdto.tableName = dto.ntssTableName;
                hdto.convertDatetime = dtNow;
                hdto.startDate = dtpStartDate.Value.Date;
                hdto.endDate = dtpEndDate.Value.Date;
                hdao.InsertOnlySyncConvertHistory(hdto);
            }

      
            Application.DoEvents();
            if (!_IsConvertAll)
                ShowMsgBoxInfo("データコンバートが完了しました。");

            // 画面設定条件の保存
            SaveAppConfigInputStatus();

            EnableControl(true);
        }

        /// <summary>
        /// 対象テーブル全件移行対象のテーブルコンバート処理
        /// （マスタ・患者ともに共通処理）
        /// </summary>
        /// <param name="dataType">マスタ・患者のデータ種別</param>
        private void ConvertAllRecord(string dataType)
        {

            // 日時をスタティッククラスに格納
            DateTime dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;

            // テーブル選択チェックｔ
            if (!CheckTableSelect()) return;

            // 施設コードの入力チェック
            if (!CheckFacilityCd()) return;

            // 確認ダイアログ表示
            if (!_IsConvertAll)
                if (!DisplayConfirmationDialog("")) return;

            // ボタン活性変更(共通処理)
            EnableControl(false);

            // 出力先フォルダ作成// mod 2020-12-21 594 コンバートが進歩:差分・完全・追加。 う　start
            string turnType = checkTurnType();
            // Mod #7997 趙 Start
            //string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType + "[" + turnType + "]");
            string exportFolderPath = Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd  + string.Format(@"\{2}-ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType + "[" + turnType + "]", this.txtFacilityCd.Text);
            // Mod #7997 趙 End
            //string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType);
            // 出力先フォルダ作成// mod 2020-12-21 594 コンバートが進歩:差分・完全・追加。 う　start
            if (!MakeExportFolderPath(exportFolderPath)) return;

            // 選択したテーブルのリスト取得
         
            // mod 8248 患者イベントが一部コンバートされていない 楊 start
            List<string> listSelectedTableLog = GetDgvSelectedRow(dgvPat);
            // mod 8248 患者イベントが一部コンバートされていない 楊 end
            // 選択したデータグリッドの行Dtoリスト取得
            List<DgvPatRowDto> listSelectedRowList = GetDgvSelectedRowToDto(dgvPat);
        

            // コンバート実施
            if (!ConvertTableForAllRecord(listSelectedRowList,
                exportFolderPath,
                null,
                false))
                return;

            

            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);

            Application.DoEvents();
            // add FNSI-差分コンバート対応 楊 start
            // コンバート履歴テーブルに登録する
            SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
            SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
            dto.facilityCd = this.txtFacilityCd.Text;
            var typeKind = "MST";
            if (dataType.Contains("pat"))
            {
                typeKind = "PAT";
            }
            dto.tableKind = typeKind;
            dto.convertDatetime = CommonConfig.UpDate;
            dto.startDate = dtpStartDate.Value.Date;
            dto.endDate = dtpEndDate.Value;
            dto.patidList = new List<String>(listSelectedTableLog);

            dao.Insert(dto);
            // add FNSI-差分コンバート対応 楊 end
            if (!_IsConvertAll)
                // Add #7997 趙 Start
                if ("1" == loopKbn || "2" == loopKbn)
                    // Add #7997 趙 End
                    ShowMsgBoxInfo("データコンバートが完了しました。");

            // 画面設定条件の保存
            SaveAppConfigInputStatus();

            EnableControl(true);

        }

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// 対象テーブル全件移行対象のテーブルコンバート処理
        /// （装置記録に共通処理）
        /// </summary>
        /// <param name="dataType">装置記録のデータ種別</param>
        private void ConvertMotion(string dataType)
        {

            // 日時をスタティッククラスに格納
            DateTime dtNow = DateTime.Now;
            CommonConfig.UpDate = dtNow;

            // テーブル選択チェックｔ
            if (!CheckTableSelect()) return;

            // 施設コードの入力チェック
            if (!CheckFacilityCd()) return;

            // 確認ダイアログ表示
            if (!_IsConvertAll)
                if (!DisplayConfirmationDialog("")) return;

            // ボタン活性変更(共通処理)
            EnableControl(false);

            // 出力先フォルダ作成
            string turnType = checkTurnType();
            // Mod #7997 趙 Start
            //string exportFolderPath = Settings.Default.DefaultExportFolderPath + string.Format(@"\ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType + "[" + turnType + "]");
            string exportFolderPath = Settings.Default.DefaultExportFolderPath + "\\" + CommonConfig.FacilityCd+ string.Format(@"\{2}-ExportData_{0}_{1}", dtNow.ToString("yyyyMMddHHmmss"), dataType + "[" + turnType + "]", txtFacilityCd.Text);
            // Mod #7997 趙 End
            // 出力先フォルダ作成
            if (!MakeExportFolderPath(exportFolderPath)) return;

            // 選択したテーブルのリスト取得
            List<string> listSelectedTable = GetDgvSelectedRow(dgvPat, "ntssTable");
            // 選択したデータグリッドの行Dtoリスト取得
            List<DgvPatRowDto> listConvertTableInfoDto = GetDgvSelectedRowToDto(dgvPat);
            

            // コンバート実施
            if (!ConvertTableForMotion(listConvertTableInfoDto,
                exportFolderPath,
                false))
                return;
            // ZIPファイルの作成
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", exportFolderPath);
            compressFolder(exportFolderPath);

            Application.DoEvents();

            // コンバート履歴テーブルに登録する
            SyncConvertHistoryDao dao = new SyncConvertHistoryDao(db);
            SyncConvertHistoryDto dto = new SyncConvertHistoryDto();
            dto.facilityCd = this.txtFacilityCd.Text;
            dto.tableKind = "REC";
            dto.convertDatetime = CommonConfig.UpDate;
            dto.startDate = SelecteddtpStartDate[CommonConfig.seriesCd];
            dto.endDate = SelecteddtpEndDate[CommonConfig.seriesCd];
            dto.patidList = new List<String>(listSelectedTable);
            dao.Insert(dto);

            if (!_IsConvertAll)
                // Add #7997 趙 Start
                if ("1" == loopKbn || "2" == loopKbn)
                    // Add #7997 趙 End
                    ShowMsgBoxInfo("データコンバートが完了しました。");

            // 画面設定条件の保存
            SaveAppConfigInputStatus();

            EnableControl(true);
        }

        

        /// <summary>
        /// データ種別の値でコントロールの有効・無効を切り替える
        /// </summary>
        /// <param name="dataType"></param>
        /// <param name="isEnable"></param>
        private void EnableControl(bool isEnable)
        {
            // 共通
            cmbDataType.Enabled = isEnable;
            //cmbSeriesCd.Enabled = isEnable;
            chkSelectAllPat.Enabled = isEnable;
            switch (cmbDataType.SelectedItem.ToString())
            {
                // マスタ
                case CMB_SELECT_ALL_RECORD_MST:
                    dtpStartDate.Enabled = false;
                    dtpEndDate.Enabled = false;
                    chkSelectAllSpan.Enabled = false;
                    if (!this._IsConvertAll)
                    {
                        chkSelectAllSpan.Checked = true;
                    }
                    chkExclusion.Enabled = false;
                    btnDialysisCondSet.Enabled = isEnable;
                    chkEndDateControl.Enabled = false;
                    break;
                // 患者
                case CMB_SELECT_ALL_RECORD_PAT:
                    dtpStartDate.Enabled = false;
                    dtpEndDate.Enabled = false;
                    chkSelectAllSpan.Enabled = false;
                    if (!this._IsConvertAll)
                    {
                        chkSelectAllSpan.Checked = true;
                    }
                    chkExclusion.Enabled = false;
                    btnDialysisCondSet.Enabled = false;
                    chkEndDateControl.Enabled = false;

                    break;
                // 透析
                case CMB_SELECT_SPECIFY_PERIOD_PAT:
                    dtpStartDate.Enabled = isEnable;
                    if (!chkEndDateControl.Checked)
                    {
                        dtpEndDate.Enabled = false;
                    }
                    else
                    {
                        dtpEndDate.Enabled = isEnable;
                    }
                    chkSelectAllSpan.Enabled = isEnable;
                    chkExclusion.Enabled = isEnable;
                    btnDialysisCondSet.Enabled = isEnable;
                    chkEndDateControl.Enabled = isEnable;
                    chkSelectAllSpan.Checked = tmpChkAllSpan;
                    chkEndDateControl.Checked = tmpChkEndDateControl;
                    break;
                // 患者治療パターン
                case CMB_SELECT_PAT_TREATMENT_PATTERN:
                    dtpStartDate.Enabled = false;
                    dtpEndDate.Enabled = false;
                    chkSelectAllSpan.Enabled = false;
                    if (!this._IsConvertAll)
                    {
                        chkSelectAllSpan.Checked = true;
                    }
                    chkExclusion.Enabled = false;
                    btnDialysisCondSet.Enabled = false;
                    chkEndDateControl.Enabled = false;
                    break;
                // 
                case CMB_SELECT_INDICATES_HISTORY:
                    dtpStartDate.Enabled = false;
                    dtpEndDate.Enabled = false;
                    chkSelectAllSpan.Enabled = false;
                    if (!this._IsConvertAll)
                    {
                        chkSelectAllSpan.Checked = true;
                    }
                    chkExclusion.Enabled = false;
                    btnDialysisCondSet.Enabled = false;
                    chkEndDateControl.Enabled = false;
                    break;

                // 検査予定／結果
                case CMB_SELECT_PAT_EXAM:
                    dtpStartDate.Enabled = isEnable;
                    if (!chkEndDateControl.Checked)
                    {
                        dtpEndDate.Enabled = false;
                    }
                    else
                    {
                        dtpEndDate.Enabled = isEnable;
                    }
                    chkSelectAllSpan.Enabled = isEnable;
                    chkExclusion.Enabled = isEnable;
                    btnDialysisCondSet.Enabled = isEnable;
                    chkEndDateControl.Enabled = isEnable;
                    chkSelectAllSpan.Checked = tmpChkAllSpan;
                    chkEndDateControl.Checked = tmpChkEndDateControl;
                    break;


                case CMB_SELECT_MNT_MOTION_RECORD:
                    dtpStartDate.Enabled = isEnable;
                    if (!chkEndDateControl.Checked)
                    {
                        dtpEndDate.Enabled = false;
                    }
                    else
                    {
                        dtpEndDate.Enabled = isEnable;
                    }
                    chkSelectAllSpan.Enabled = isEnable;
                    chkExclusion.Enabled = isEnable;
                    btnDialysisCondSet.Enabled = false;

                    chkEndDateControl.Enabled = isEnable;
                    chkSelectAllSpan.Checked = tmpChkAllSpan;
                    chkEndDateControl.Checked = tmpChkEndDateControl;
                    break;
                // mod #12484 コンバートツールで処理種別の除外ができない limingzhe start
                //case "すべて":
                case CMB_SELECT_ALL:
                // mod #12484 コンバートツールで処理種別の除外ができない limingzhe end
                    dtpStartDate.Enabled = isEnable;
                    if (!chkEndDateControl.Checked)
                    {
                        dtpEndDate.Enabled = false;
                    }
                    else
                    {
                        dtpEndDate.Enabled = isEnable;
                    }
                    chkSelectAllSpan.Enabled = isEnable;
                    chkExclusion.Enabled = false;
                    btnDialysisCondSet.Enabled = true;
                    // del #12484 コンバートツールで処理種別の除外ができない limingzhe start
                    //chkSelectAllPat.Enabled = false;
                    // del #12484 コンバートツールで処理種別の除外ができない limingzhe end
                    chkEndDateControl.Enabled = isEnable;
                    chkSelectAllSpan.Checked = tmpChkAllSpan;
                    chkEndDateControl.Checked = tmpChkEndDateControl;
                    break;
                //#10859_2 データ種別が「初回」も「追加」も変わらないため重複出力してしまう hyl start
                // mod #12484 コンバートツールで処理種別の除外ができない limingzhe start
                //case "すべて(追加)":
                case CMB_SELECT_ALL_ADD:
                // mod #12484 コンバートツールで処理種別の除外ができない limingzhe end
                    dtpStartDate.Enabled = isEnable;
                    if (!chkEndDateControl.Checked)
                    {
                        dtpEndDate.Enabled = false;
                    }
                    else
                    {
                        dtpEndDate.Enabled = isEnable;
                    }
                    chkSelectAllSpan.Enabled = isEnable;
                    chkExclusion.Enabled = false;
                    btnDialysisCondSet.Enabled = true;
                    // del #12484 コンバートツールで処理種別の除外ができない limingzhe start
                    //chkSelectAllPat.Enabled = false;
                    // del #12484 コンバートツールで処理種別の除外ができない limingzhe end
                    chkEndDateControl.Enabled = isEnable;
                    chkSelectAllSpan.Checked = tmpChkAllSpan;
                    chkEndDateControl.Checked = tmpChkEndDateControl;
                    break;
                    //#10859_2 データ種別が「初回」も「追加」も変わらないため重複出力してしまう hyl end
            }
        }

        /// <summary>
        /// 指定期間に対する優先期間とそれ以外の期間を取得
        /// </summary>
        /// <remarks>
        /// [備考]
        /// ・優先期間、優先期間以降の期間、優先期間以前の期間の順で格納される
        /// 　(過去のデータの方が多いはずなので後回しにする)
        /// ・2019/12/2 優先期間の概念を削除し、指定された期間のみ動作するように修正
        /// </remarks>
        /// <returns>指定期間のリスト</returns>
        private List<SelectSpan> GetSelectSpan(DateTime startDate, DateTime endDate)
        {

            // 指定期間リスト作成
            var listSelectSpan = new List<SelectSpan>();
            listSelectSpan.Add(new SelectSpan() { startDate = startDate, endDate = endDate, description = "処理期間" });

            return listSelectSpan;
        }

        

        /// <summary>
        /// データグリッドビュー選択行の値取得
        /// </summary>
        /// <param name="dgv">データグリッドビュー</param>
        /// <param name="columnName">取得する列名</param>
        /// <returns>値のリスト</returns>
        private List<string> GetDgvSelectedRow(DataGridView dgv, string columnName)
        {
            if (CommonConfig.isDiff || CacheInformation.Instance.FacilityCd.Equals("0"))
            {
                var list = new List<string>();
                var selectedRows = dgv.SelectedRows;
                foreach (DataGridViewRow row in selectedRows)
                {
                    string str = dgv[columnName, row.Index]?.Value.ToString();
                    list.Add(str);
                }
                // 行の選択順で並びが変わるのでソート
                list.Sort();
                return list;
            }
            else {
                var result = new List<string>();
                if (columnName.Equals("PATID") && CommonConfig.SelectedTypeByFacility[CommonConfig.seriesCd].Contains("すべて")
                    && CacheInformation.Instance.FacilityCd.Equals("1"))
                {
                    var sql = new StringBuilder(@"
                        SELECT
                            a.PATID   
                        FROM
                            pat_basic_info a
                            INNER JOIN pat_index_info b ON a.patid = b.patid AND a.reg_date = b.pat_reg_date
                            INNER JOIN  (SELECT DISTINCT PATID, SERIES_CD
				            FROM (
				            SELECT PATID, FROM_SERIES_CD AS SERIES_CD
				            FROM SYS_PAT_MOVE_PLAN where  STATUS='1'  and DEL_FLG='0'
				            UNION ALL
				            SELECT PATID, TO_SERIES_CD
				            FROM SYS_PAT_MOVE_PLAN where  STATUS='1'  and DEL_FLG='0'
				            UNION ALL
				            SELECT PATID, SERIES_CD
				            FROM SYS_PAT_SERIES_FACILITY where MAIN_FLG='1'
				            )) d ON a.patid = d.patid
                        WHERE
                            b.PAT_STATUS = '0'
                        ");
                    IMakeSqlParameters param = db.GetIMakeSqlParameters();
                    sql.Append(" AND d.SERIES_CD = :SERIES_CD");
                    param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                    sql.Append(" ORDER BY a.patid");

                    var tbPat = db.SelectTable(sql.ToString(), param.GetParam());
                    foreach (DataRow item in tbPat.Rows)
                    {
                        result.Add(item["PATID"].ToString());
                    }
                    result.Sort();
                    return result;
                }

                if (SelectedRowsByFacility.TryGetValue(CommonConfig.seriesCd, out var rows))
                {
                    foreach (var rowDict in rows)
                    {
                        if (rowDict.TryGetValue(columnName, out var value))
                        {
                            result.Add(value?.ToString());
                        }
                    }
                }

                result.Sort();
                return result;
            }
           
            
        }
        // mod 8248 患者イベントが一部コンバートされていない 楊 start
        /// <summary>
        /// データグリッドビュー選択行の値取得
        /// </summary>
        /// <param name="dgv">データグリッドビュー</param>
        /// <param name="columnName">取得する列名</param>
        /// <returns>値のリスト</returns>
        private List<string> GetDgvSelectedRow(DataGridView dgv)
        {
            var list = new List<string>();
            if (CommonConfig.isDiff || CacheInformation.Instance.FacilityCd.Equals("0"))
            {
                var selectedRows = dgv.SelectedRows;
                foreach (DataGridViewRow row in selectedRows)
                {
                    string strNtss = dgv["ntssTable", row.Index]?.Value.ToString();
                    string str = dgv["table", row.Index]?.Value.ToString();
                    list.Add(str + strNtss);
                }
                // 行の選択順で並びが変わるのでソート
                list.Sort();
                return list;
            }
            else {
                if (SelectedRowsByFacility == null)
                    return list;

                if (!SelectedRowsByFacility.TryGetValue(CommonConfig.seriesCd, out var rows))
                    return list;

                foreach (var rowDict in rows)
                {
                    string str = null;
                    string strNtss = null;

                    if (rowDict.TryGetValue("table", out var obj1) && obj1 != null)
                        str = obj1.ToString();

                    if (rowDict.TryGetValue("ntssTable", out var obj2) && obj2 != null)
                        strNtss = obj2.ToString();

                    list.Add((str ?? "") + (strNtss ?? ""));
                }

                list.Sort();
                return list;
            }
          
            //var list = new List<string>();

            



        }
        // mod 8248 患者イベントが一部コンバートされていない 楊 end
        /// <summary>
        /// データグリッドビュー選択行の値取得後、DTOのリストへ格納する
        /// </summary>
        /// <param name="dgv">データグリッドビュー</param>
        /// <returns>値のリスト</returns>
        private List<DgvPatRowDto> GetDgvSelectedRowToDto(DataGridView dgv)
        {
            
            if (CommonConfig.isDiff || CacheInformation.Instance.FacilityCd.Equals("0"))
            {
                var list = new List<DgvPatRowDto>();
                var selectedRows = dgv.SelectedRows;
                foreach (DataGridViewRow row in selectedRows)
                {
                    DgvPatRowDto dto = new DgvPatRowDto()
                    {
                        fnwTableName = dgv["table", row.Index].Value.ToString(),
                        ntssTableName = dgv["ntssTable", row.Index].Value.ToString()
                    };

                    list.Add(dto);
                }
                // 行の選択順で並びが変わるのでソート
                var sortedList = list.OrderBy(x => x.ntssTableName)
                    .ThenBy(x => x.fnwTableName)
                    .ToList();
                return sortedList;
            }
            else {
                var result = new List<DgvPatRowDto>();

                if (!SelectedRowsByFacility.TryGetValue(CommonConfig.seriesCd, out var rows))
                    return result;

                foreach (var rowDict in rows)
                {
                    string fnw = rowDict.ContainsKey("table") ? rowDict["table"]?.ToString() : "";
                    string ntss = rowDict.ContainsKey("ntssTable") ? rowDict["ntssTable"]?.ToString() : "";

                    var dto = new DgvPatRowDto
                    {
                        fnwTableName = fnw,
                        ntssTableName = ntss
                    };

                    result.Add(dto);
                }

                return result
                    .OrderBy(x => x.ntssTableName)
                    .ThenBy(x => x.fnwTableName)
                    .ToList();

            }

        }

        private void ShowMsgBoxInfo(string msg)
        {
            if (msg.Equals("データコンバートが完了しました。"))
            {   
                //mod 7997 進捗バー修正 start
                CommonConfig.CONVEND[CommonConfig.FacilityCd] = true;
                //mod 7997 進捗バー修正 end
                //add  11161 start
                if (CommonConfig.AUTOMATIC.Equals("1") && CommonConfig.LoginUrl != null)
                {
                    return;
                }
                //add  11161 end
            }
            MessageBox.Show(msg, "", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void ShowMsgBoxWarning(string msg)
        {
            MessageBox.Show(msg, "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        private void ShowMsgBoxError(string msg)
        {
            MessageBox.Show(msg, "", MessageBoxButtons.OK, MessageBoxIcon.Stop);
        }

        private void chkSelectAllPat_CheckedChanged(object sender, EventArgs e)
        {
            if (chkSelectAllPat.Checked)
            {
                dgvPat.SelectAll();
                //add #7997 start
                string seriesCd = string.Empty;
                if (String.IsNullOrEmpty(CommonConfig.seriesCd))
                {
                    seriesCd = tabControlSd.SelectedTab.Tag.ToString();
                }
                else {
                    seriesCd = CommonConfig.seriesCd;
                }
                SaveSelectedRows(seriesCd, dgvPat);
                //add #7997 end
            }
            else
            {
                dgvPat.ClearSelection();
            }
        }

        // 入力値保存用
        private DateTime dtpStartDateBefore = new DateTime(1990, 01, 01);
        // mod FNSI-終了日初期値修正 楊 start
        // private DateTime dtpEndDateBefore = new DateTime(2100, 12, 31);
        private DateTime dtpEndDateBefore = System.DateTime.Now;
        // mod FNSI-終了日初期値修正 楊 end
        private void chkSelectAllSpan_CheckedChanged(object sender, EventArgs e)
        {



            string dataType;
            string key = tabControlSd.SelectedTab.Tag.ToString();
            if (CommonConfig.SelectedTypeByFacility.TryGetValue(key, out string valueType))
            {
                dataType = valueType;
            }
            else {
                dataType = cmbDataType.SelectedItem.ToString();
            }
            
            if (CMB_SELECT_ALL.Equals(dataType) ||
                CMB_SELECT_ALL_ADD.Equals(dataType) ||
                CMB_SELECT_PAT_EXAM.Equals(dataType) ||
                CMB_SELECT_SPECIFY_PERIOD_PAT.Equals(dataType) ||
                CMB_SELECT_MNT_MOTION_RECORD.Equals(dataType))
            {
                tmpChkAllSpan = chkSelectAllSpan.Checked;
            }

            SelectedchkSelectAllSpan[tabControlSd.SelectedTab.Tag.ToString()] = chkSelectAllSpan.Checked;

            if (chkSelectAllSpan.Checked && !_IsConvertAll)
            {
                dtpStartDate.Enabled = false;
                dtpEndDate.Enabled = false;
                dtpEndDate.Format = DateTimePickerFormat.Long;
                dtpEndDate.CustomFormat = null;
                dtpStartDateBefore = dtpStartDate.Value;

                if (!chkEndDateControl.Checked)
                {
                    dtpEndDateBefore = endDateBefore;
                }
                else
                {
                    dtpEndDateBefore = dtpEndDate.Value;
                }
                dtpStartDate.Value = dtpStartDate.MinDate;
                DateTime currentDate = DateTime.Now;
                dtpEndDate.Value = new DateTime(currentDate.Year, currentDate.Month, DateTime.DaysInMonth(currentDate.Year, currentDate.Month)).AddYears(1).AddDays(1).AddSeconds(-1);
                chkEndDateControl.Enabled = false;
                chkEndDateControl.Checked = true;
                chkEndDateControl.Checked = false;
                endDateBefore = dtpEndDate.Value;
                dtpEndDate.Enabled = false;
                dtpEndDate.Format = DateTimePickerFormat.Custom;
                dtpEndDate.CustomFormat = " ";
            }
            else
            {
                dtpStartDate.Enabled = true;
                dtpEndDate.Enabled = true;

                if (SelecteddtpStartDate.TryGetValue(tabControlSd.SelectedTab.Tag.ToString(), out var value))
                {
                    dtpStartDate.Value = value;
                }
                else {
                    dtpStartDate.Value = dtpStartDateBefore;
                }
                if (SelecteddtpEndDate.TryGetValue(tabControlSd.SelectedTab.Tag.ToString(), out var valueEnd))
                {
                    dtpEndDate.Value = valueEnd.Date;
                }
                else {
                    dtpEndDate.Value = endDateBefore;
                }
                
                chkEndDateControl.Enabled = true;
                chkEndDateControl.Checked = true;
                //dtpEndDate.Format = DateTimePickerFormat.Custom;
                if (chkSelectAllSpan.Checked)
                {
                    dtpEndDate.Enabled = false;
                }
                else
                {
                    dtpEndDate.Enabled = true;
                }
                //dtpEndDate.Format = DateTimePickerFormat.Long;
               // dtpEndDate.CustomFormat = null;
            }
        }

        private void btnSelectExportFolder_Click(object sender, EventArgs e)
        {
            // フォルダブラウザダイアログ
            var fbd = new FolderBrowserDialog();
            fbd.Description = "移行データ出力先フォルダを選択してください";
            fbd.SelectedPath = Directory.Exists(Settings.Default.DefaultExportFolderPath) ? Settings.Default.DefaultExportFolderPath : Directory.GetCurrentDirectory();
            if (fbd.ShowDialog() == DialogResult.Cancel)
            {
                return;
            }
            Settings.Default.DefaultExportFolderPath = fbd.SelectedPath;
        }

        private void dtpStartDate_Validated(object sender, EventArgs e)
        {
            if (dtpEndDate.Value < dtpStartDate.Value)
            {
                //mod 2022-03-31 値が設定範囲を超えている問題  鄭  start
                //dtpEndDate.Value = dtpStartDate.Value;
                dtpStartDate.Value = dtpStartDate.MinDate;
                //mod 2022-03-31 値が設定範囲を超えている問題  鄭  end
            }
        }

        private void dtpEndDate_Validated(object sender, EventArgs e)
        {
            // 終了日時の期間を修正する　LL START
            // mod #10199 limingyang start
            //DateTime currentDate = DateTime.Now.AddYears(1);
            DateTime currentDate = new DateTime(DateTime.Now.Year + 1, DateTime.Now.Month, DateTime.DaysInMonth(DateTime.Now.Year + 1, DateTime.Now.Month));
            // mod #10199 limingyang end
            if (dtpEndDate.Value < dtpStartDate.Value)
            {
                //mod 2022-03-31 値が設定範囲を超えている問題  鄭  start
                // dtpStartDate.Value = dtpEndDate.Value;
                dtpEndDate.Value = currentDate;
                //mod 2022-03-31 値が設定範囲を超えている問題  鄭  end
            }

            if (dtpEndDate.Value > currentDate)
            {
                dtpEndDate.Value = currentDate;
            }
            // 終了日時の期間を修正する　LL END
        }

        public void EventConvertAllTable()
        {
            if (!CheckFacilityCd())
            {
                this.Show();
                return;
            }
            //add 7726   抽出された繰返し日の取得 鄭 start
            string sblPAT = GeWithdrawalDateTables("ORD", "inspectionSchedule／result");
            string sblORD = string.Empty;
            if (string.IsNullOrEmpty(sblPAT))
            {
                sblORD = GeWithdrawalDateTables("ORD", "dialysis");
            }
            //add 7726   抽出された繰返し日の取得 鄭 end
            if (!DisplayConfirmationDialog(sblPAT + sblORD))
            {
                this.Hide();
                return;
            }
            else
            {
                //this.Show();
            }
            this._IsConvertAll = true;


            //add 7997 start 
            if (CacheInformation.Instance.FacilityCd.Equals("1")) {
                setcmbDataType(CommonConfig.seriesCd);
            }
            //add 7997 end

            // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
            int dgvPatIndex = -1;
            // add #12484 コンバートツールで処理種別の除外ができない limingzhe end

            for (int i = 0; i < cmbDataType.Items.Count; i++)
            {
                // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
                if (cmbDataType.Items[i].ToString().Contains(CMB_SELECT_ALL)) continue;
                if (CommonConfig.SelectedTypeByFacility[CommonConfig.seriesCd].Contains(CMB_SELECT_ALL))
                {
                    dgvPatIndex++;
                    if (!LstDgvPatSelectedIndex[CommonConfig.seriesCd].Contains(dgvPatIndex)) continue;
                    List<String> list = GetTargetType();
                    if (list.IndexOf(cmbDataType.Items[i].ToString()) != dgvPatIndex) continue;
                }
                // add #12484 コンバートツールで処理種別の除外ができない limingzhe end
                _isLoadedType = false;
                cmbDataType.SelectedIndex = i;
				// add #12484 コンバートツールで処理種別の除外ができない limingzhe start
                if (chkSelectAllPat.Checked)
                {
                    chkSelectAllPat_CheckedChanged(null, null);
                }
				// add #12484 コンバートツールで処理種別の除外ができない limingzhe end
                chkSelectAllPat.Checked = true;
                BtnConvert_Click(null, null);
                _isLoadedType = true;

            }
            // Add #7997 趙 Start
            if ("1" == loopKbn || "2" == loopKbn)
                // Add #7997 趙 End
                ShowMsgBoxInfo("データコンバートが完了しました。");
            this._IsConvertAll = false;
        }

        public void setcmbDataType(string serCd) {
            cmbDataType.Items?.Clear();
            DataTable source = CacheInformation.Instance.GetTableKind(serCd);
            var query = source.AsEnumerable()
                .Where(r => r.Field<string>("SERIES_CD") == serCd);
            DataTable dt = query.Any()
                ? query.CopyToDataTable()
                : source.Clone();
            if (isAddItems(dt, "MST") || isAddItems(dt, "PAT") || isAddItems(dt, "HIS"))
            {
                cmbDataType.Items.Add(CMB_SELECT_ALL_ADD);
            }
            else
            {
                cmbDataType.Items.Add(CMB_SELECT_ALL);
            }
            if (false == isAddItems(dt, "MST"))
            {
                cmbDataType.Items.Add(CMB_SELECT_ALL_RECORD_MST);
            }
            if (false == isAddItems(dt, "PAT"))
            {
                cmbDataType.Items.Add(CMB_SELECT_ALL_RECORD_PAT);
            }
            cmbDataType.Items.Add(CMB_SELECT_PAT_EXAM);
            cmbDataType.Items.Add(CMB_SELECT_SPECIFY_PERIOD_PAT);
            if (false == isAddItems(dt, "HIS"))
            {
                cmbDataType.Items.Add(CMB_SELECT_INDICATES_HISTORY);
            }
            cmbDataType.Items.Add(CMB_SELECT_MNT_MOTION_RECORD);

        }

        /// <summary>
        /// データ種別ボックスの選択イベント処理
        /// </summary>
        private void cmbDataType_SelectedIndexChanged(object sender, EventArgs e)
        {
            string dataType = this.cmbDataType.SelectedItem.ToString();

            // add 7997 start
            if (_isLoadedType) {
                string facilityCd = tabControlSd.SelectedTab.Tag.ToString();
                CommonConfig.SelectedTypeByFacility[facilityCd] = dataType;
            }
            // add 7997 end

            // コントロールを有効にする
            EnableControl(true);
            // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
            if(!dataType.Contains(CMB_SELECT_ALL) && _isLoadedType)
            // add #12484 コンバートツールで処理種別の除外ができない limingzhe end
                chkSelectAllPat.Checked = false;

            switch (dataType)
            {
                // 透析
                case CMB_SELECT_SPECIFY_PERIOD_PAT:
                    grpPeriod.Enabled = true;
                    if (chkSelectAllSpan.Checked)
                    {
                        dtpStartDate.Enabled = false;
                        dtpEndDate.Enabled = false;
                        chkEndDateControl.Enabled = false;
                    }
                    else
                    {
                        dtpStartDate.Enabled = true;
                        if (chkEndDateControl.Checked)
                        {
                            dtpEndDate.Enabled = true;
                        }
                        chkEndDateControl.Enabled = true;
                    }

                    // 対象患者をグリッドビュー表示
                    if (false == this.ShowTargetPat())
                    {
                        ShowMsgBoxError("データ移行対象患者の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象患者リスト";
                    break;
                // 患者
                case CMB_SELECT_ALL_RECORD_PAT:
                    grpPeriod.Enabled = true;
                    // 対象患者をグリッドビュー表示
                    if (false == this.ShowTargetTable(CMB_SELECT_ALL_RECORD_PAT))
                    {
                        ShowMsgBoxError("データ移行対象テーブル情報の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象テーブル";
                    break;
                // マスタ
                case CMB_SELECT_ALL_RECORD_MST:
                    grpPeriod.Enabled = false;
                    // 対象マスタをグリッドビュー表示
                    if (false == this.ShowTargetTable(CMB_SELECT_ALL_RECORD_MST))
                    {
                        ShowMsgBoxError("データ移行対象テーブル情報の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象テーブル";
                    break;
                // 患者毎期間指定移行対象
                case CMB_SELECT_SPECIFY_PERIOD:
                    grpPeriod.Enabled = true;
                    // 対象テーブルをグリッドビュー表示
                    if (false == this.ShowTargetTableForSpecifyPeriod())
                    {
                        ShowMsgBoxError("データ移行対象テーブル情報の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象テーブル";
                    break;
                // 患者治療パターン
                case CMB_SELECT_PAT_TREATMENT_PATTERN:
                    // 対象患者をグリッドビュー表示
                    if (false == this.ShowTargetPat())
                    {
                        ShowMsgBoxError("データ移行対象患者の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象患者リスト";
                    break;
                //指示履歴
                case CMB_SELECT_INDICATES_HISTORY:
                    grpPeriod.Enabled = true;
                    // 対象テーブルをグリッドビュー表示
                    if (false == this.ShowIndHistoryTable(CMB_SELECT_INDICATES_HISTORY))
                    {
                        ShowMsgBoxError("データ移行対象テーブル情報の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象患者リスト";
                    break;

                //検査予定／結果
                case CMB_SELECT_PAT_EXAM:
                    grpPeriod.Enabled = true;
                    if (chkSelectAllSpan.Checked)
                    {
                        dtpStartDate.Enabled = false;
                        dtpEndDate.Enabled = false;
                        chkEndDateControl.Enabled = false;
                    }
                    else
                    {
                        dtpStartDate.Enabled = true;
                        if (chkEndDateControl.Checked)
                        {
                            dtpEndDate.Enabled = true;
                        }
                        chkEndDateControl.Enabled = true;
                    }

                    // 対象患者をグリッドビュー表示
                    if (false == this.ShowTargetPat())
                    {
                        ShowMsgBoxError("データ移行対象患者の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象患者リスト";
                    break;

                case CMB_SELECT_ALL:
                case CMB_SELECT_ALL_ADD:
                    grpPeriod.Enabled = true;
                    if (chkSelectAllSpan.Checked)
                    {
                        dtpStartDate.Enabled = false;
                        dtpEndDate.Enabled = false;
                        chkEndDateControl.Enabled = false;
                    }
                    else
                    {
                        dtpStartDate.Enabled = true;
                        if (chkEndDateControl.Checked)
                        {
                            dtpEndDate.Enabled = true;
                        }
                        chkEndDateControl.Enabled = true;
                    }
                    // mod #12484 コンバートツールで処理種別の除外ができない limingzhe start
                    //lblDataConvertPatList.Text = CMB_SELECT_ALL;
                    //this.ShowTargetTable(CMB_SELECT_ALL);
                    // 対象患者をグリッドビュー表示
                    if (false == this.ShowTargetType(dataType))
                    {
                        ShowMsgBoxError("データ移行対象患者の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = dataType;
                    if (chkSelectAllPat.Checked)
                    {
                        chkSelectAllPat_CheckedChanged(null, null);
                    }
                    chkSelectAllPat.Checked = true;
                    // mod #12484 コンバートツールで処理種別の除外ができない limingzhe end
                    break;


                case CMB_SELECT_MNT_MOTION_RECORD:
                    grpPeriod.Enabled = true;

                    if (chkSelectAllSpan.Checked)
                    {
                        dtpStartDate.Enabled = false;
                        dtpEndDate.Enabled = false;
                        chkEndDateControl.Enabled = false;
                    }
                    else
                    {
                        dtpStartDate.Enabled = true;
                        if (chkEndDateControl.Checked)
                        {
                            dtpEndDate.Enabled = true;
                        }
                        chkEndDateControl.Enabled = true;
                    }

                    // 対象テーブルをグリッドビュー表示
                    if (false == this.ShowMotionTargetTable(CMB_SELECT_MNT_MOTION_RECORD))
                    {
                        ShowMsgBoxError("データ移行対象テーブル情報の取得に失敗しました。");
                        return;
                    }
                    lblDataConvertPatList.Text = "データ移行対象テーブル";
                    break;
                // その他
                default:
                    this.ShowMsgBoxInfo("選択したタイプは対応していません。");
                    break;
            }
        }

        // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
        private void dgvPat_SelectionChanged(object sender, EventArgs e)
        {
            dgvPat.SelectionChanged -= dgvPat_SelectionChanged;
            chkSelectAllPat.CheckedChanged -= chkSelectAllPat_CheckedChanged;
            string dataType = this.cmbDataType.SelectedItem?.ToString();
            if (!String.IsNullOrEmpty(dataType) && dataType.Equals(CMB_SELECT_ALL))
            {
                if (dgvPat.Rows.Count > 0)
                {
                    foreach (DataGridViewRow row in dgvPat.Rows)
                    {
                        if (row.Cells.Count > 0)
                        {
                            if (row.Cells[0].Value.Equals(CMB_SELECT_ALL_RECORD_MST) || row.Cells[0].Value.Equals(CMB_SELECT_ALL_RECORD_PAT))
                            {
                                row.Selected = true;
                            }
                        }
                    }
                }
            }
            chkSelectAllPat.Checked = (dgvPat.SelectedRows.Count == dgvPat.Rows.Count && dgvPat.Rows.Count > 0);
            chkSelectAllPat.CheckedChanged += chkSelectAllPat_CheckedChanged;
            dgvPat.SelectionChanged += dgvPat_SelectionChanged;
        }
        // add #12484 コンバートツールで処理種別の除外ができない limingzhe end
        #region 入力チェック

        /// <summary>
        /// コンバート対象テーブルが選択されているかチェックする
        /// </summary>
        /// <returns></returns>
        private bool CheckTableSelect()
        {
            //if (!Validator.CheckDataGridViewSelect(dgvPat))
            if (SelectedRowsByFacility[CommonConfig.seriesCd].Count==0)
            {
                ShowMsgBoxWarning("処理対象テーブルを選択してください。");
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// 施設コードの入力チェック
        /// </summary>
        /// <returns></returns>
        private bool CheckFacilityCd()
        {
            if (!Validator.CheckHalfWidthAlphaNumeric(6, txtFacilityCd.Text))
            {
                ShowMsgBoxWarning("施設コードは半角英数字6桁で入力してください。");
                txtFacilityCd.Focus();
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// コンバート開始確認ダイアログ表示
        /// </summary>
        /// <param name="confirmMsg">確認メッセージ</param>
        /// <returns></returns>
        private bool DisplayConfirmationDialog(string confirmMsg)
        {
            // Add #7997 趙 Start
            if ("2" == loopKbn || "3" == loopKbn)
            {
                return true;
            }
            // Add #7997 趙 End
            //mod 7726  抽出された繰返し日の取得 鄭 start
            DialogResult result;
            if (!string.IsNullOrEmpty(confirmMsg))
            {
                result = MessageBox.Show(confirmMsg, "", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
            }
            else
            {
                result = MessageBox.Show(CONFIRM_MSG, "", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
            }
            // DialogResult result = MessageBox.Show(CONFIRM_MSG, "", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
            //mod 7726  抽出された繰返し日の取得 鄭 start
            if (result == DialogResult.Cancel)
            {
                CommonConfig.RUN = false;
                // Add #7997 趙 Start
                cancelKbn = true;
                // Add #7997 趙 End
                ShowMsgBoxInfo("処理をキャンセルしました。");
                return false;
            }
            else
            {
                CommonConfig.RUN = true;
                return true;
            }
        }

        #endregion

        /// <summary>
        /// 条件設定画面を開く
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnDialysisCondSet_Click(object sender, EventArgs e)
        {
            DialysisCondSet f = new DialysisCondSet();
            // Mod #7997 趙 Start
            f.seriesCd = tabControlSd.SelectedTab.Tag.ToString();
            // Mod #7997 趙 End
            f.ShowDialog(this);
            f.Dispose();

        }

        /// <summary>
        /// 画面設定情報をAppConfigに保存
        /// </summary>
        private void SaveAppConfigInputStatus()
        {
            
            // 画面設定情報をAppConfigに保存
            global::NKSConverter.Properties.Settings.Default.Save();

        }

        


        private void btnConfirm_Click_1(object sender, EventArgs e)
        {
           
            string key = tabControlSd.SelectedTab.Tag.ToString();

            if (!LstDgvPatSelectedIndex.ContainsKey(key))
            {

                LstDgvPatSelectedIndex[key] = new List<int>();
            }
            else {
                LstDgvPatSelectedIndex[key].Clear();
            }

            foreach (DataGridViewRow item in dgvPat.SelectedRows)
            {
                LstDgvPatSelectedIndex[key].Add(item.Index);
            }

             SaveState(key);
            
            // add FNSI-全ての期間対応 楊 start
            if (cmb_select.SelectedIndex == 0)
            {
                _beDtpStartDate = dtpStartDate.Value;
            }
            // add FNSI-全ての期間対応 楊 end
            // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
            foreach (var facilityRows in SelectedRowsByFacility)
            {
                if(facilityRows.Value.Count == 0)
                {
                    string mag = string.Format("施設「{0}」のデータ移行対象は設定されておりません、コンバートできません。", string.Join(",", facilityRows.Key));
                    MessageBox.Show(
                        mag,
                        "注意",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                        );
                    return;
                }
            }
            // add #12484 コンバートツールで処理種別の除外ができない limingzhe end
            if (SelectedRowsByFacility.Keys.Count == tabControlSd.TabPages.Count)
            {
                this.Hide();
            }
            else {
               
                var selectedKeys = new HashSet<string>(SelectedRowsByFacility.Keys);

                var missingValues = tabControlSd.TabPages
                    .Cast<TabPage>()
                    .Where(p =>
                        p.Tag != null &&
                        !selectedKeys.Contains(p.Tag.ToString())
                    )
                    .Select(p => p.Text) 
                    .ToList();

                if (missingValues.Any())
                {
                    string mag=string.Format("施設「{0}」のデータ種別は設定されておりません、コンバートできません。", string.Join(",", missingValues));
                    MessageBox.Show(
                        mag,
                        "注意",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                        );
                    return;
                }
               
            }
            


        }
        private void SaveSelectedRows(string seriesCd, DataGridView dgvPat)
        {

            if (!SelectedRowsByFacility.ContainsKey(seriesCd))
            {

                LstDgvPatSelectedIndex[seriesCd] = new List<int>();
            }
            else
            {
                SelectedRowsByFacility[seriesCd].Clear();
            }
            
            List<Dictionary<string, object>> selectedRows = new List<Dictionary<string, object>>();

            foreach (DataGridViewRow row in dgvPat.SelectedRows)
            {
                Dictionary<string, object> rowData = new Dictionary<string, object>();

                foreach (DataGridViewCell cell in row.Cells)
                {
                    string colName = dgvPat.Columns[cell.ColumnIndex].Name;
                    rowData[colName] = cell.Value;
                }

                selectedRows.Add(rowData);
            }

            SelectedRowsByFacility[seriesCd] = selectedRows;
            SelecteddtpStartDate[seriesCd] = dtpStartDate.Value.Date;
            SelecteddtpEndDate[seriesCd] = dtpEndDate.Value.Date;
        }

        private void MainForm_Shown(object sender, EventArgs e)
        {
            // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
            string dataType = this.cmbDataType.SelectedItem?.ToString();
            // add #12484 コンバートツールで処理種別の除外ができない limingzhe end
            if (CommonConfig.SelectedTypeByFacility.TryGetValue(tabControlSd.SelectedTab.Tag.ToString(), out var value))
            {
                cmbDataType.SelectedItem = value;
                // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
                if (value.Equals(dataType) && dataType.Contains(CMB_SELECT_ALL))
                {
                    chkSelectAllPat_CheckedChanged(null, null);
                }
                // add #12484 コンバートツールで処理種別の除外ができない limingzhe end
            }
            if (cmbDataType.SelectedIndex == -1)
            {
                cmbDataType.SelectedIndex = 0;
            }
            // del #12484 コンバートツールで処理種別の除外ができない limingzhe start
            //if (LstDgvPatSelectedIndex.Count > 0)
            //{
            //    dgvPat.ClearSelection();
                
            //}
            // del #12484 コンバートツールで処理種別の除外ができない limingzhe end
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (e.CloseReason == CloseReason.UserClosing)
            {
                e.Cancel = true;
                this.IsUserClose = true;
                Hide();
            }
            else
            {
                this.IsUserClose = false;
            }
        }

        // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 start
        private DateTime endDateBefore = System.DateTime.Now;

        private void chkEndDateControl_CheckedChanged(object sender, EventArgs e)
        {
            // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 start

            string dataType = CommonConfig.SelectedTypeByFacility[tabControlSd.SelectedTab.Tag.ToString()];
            if (string.IsNullOrEmpty(dataType))
            {
                dataType = cmbDataType.SelectedItem.ToString();
            }
            if (CMB_SELECT_ALL.Equals(dataType) ||
                CMB_SELECT_ALL_ADD.Equals(dataType) ||
                CMB_SELECT_PAT_EXAM.Equals(dataType) ||
                CMB_SELECT_SPECIFY_PERIOD_PAT.Equals(dataType) ||
                CMB_SELECT_MNT_MOTION_RECORD.Equals(dataType))
            {
                tmpChkEndDateControl = chkEndDateControl.Checked;
            }
            // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 end
            if (!_isInitializing) {
                SelectedchkEnd[tabControlSd.SelectedTab.Tag.ToString()] = chkEndDateControl.Checked;
            }
          
            if (!chkSelectAllSpan.Checked)
            {
                if (chkEndDateControl.Checked == false)
                {
                    dtpStartDateBefore = dtpEndDate.Value;
                    endDateBefore = dtpEndDate.Value;
                    // 終了日時の期間を修正する LL START
                    //dtpEndDate.Value = dtpEndDate.MaxDate;
                    //DateTime currentDate = DateTime.Now.AddYears(1);
                    DateTime currentDate = DateTime.Now;
                    dtpEndDate.Value = new DateTime(currentDate.Year, currentDate.Month, DateTime.DaysInMonth(currentDate.Year, currentDate.Month)).AddYears(1).AddDays(1).AddSeconds(-1);

                    // 終了日時の期間を修正する LL END
                    dtpEndDate.Enabled = false;
                    dtpEndDate.Format = DateTimePickerFormat.Custom;
                    //dtpEndDate.Value = currentDate;
                    dtpEndDate.CustomFormat = " ";
                }
                else
                {
                    if (SelecteddtpEndDate.TryGetValue(tabControlSd.SelectedTab.Tag.ToString(), out var valueEnd))
                    {
                        dtpEndDate.Value = valueEnd.Date;
                    }
                    else
                    {
                        dtpEndDate.Value = endDateBefore;
                    }

                    if (chkSelectAllSpan.Checked)
                    {
                        dtpEndDate.Enabled = false;
                    }
                    else
                    {
                        dtpEndDate.Enabled = true;
                    }
                    dtpEndDate.Format = DateTimePickerFormat.Long;
                    dtpEndDate.CustomFormat = null;
                }
            }
        }
        // add #7696 コンバータツールの対象期間範囲が想定と違った動きをする 歴程 end
        // Add #8111、#8109 趙 Start
        /// <summary>
        /// radioButton3の選択後のイベント
        /// <param>sender</param>
        /// <param>e</param>
        /// </summary>
        private void radioButPartId3_CheckedChanged(object sender, EventArgs e)
        {
            if (radioButPartId3.Checked)
            {
                comDataPartId.Enabled = true;
            }
            else
            {
                comDataPartId.Enabled = false;
            }
            //add 8431 zc start
            string Checked = "1";
            if (radioButPartId2.Checked)
            {
                Checked = "2";
            }
            else if (radioButPartId3.Checked)
            {
                Checked = "3";
            }

            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
            param.AddParam(":CHECKED", Checked);
            String sql = @"update  SYNC_CONDSET set
                            IsChecked=:CHECKED  where SERIES_CD=:SERIES_CD";
            db.SelectTable(sql, param.GetParam());
            //add 8431 zc end
        }

        

        private void comDataPartId_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (_isInitializing)
                return;
            //add 8431 zc start
            string sDataPartId = Convert.ToString(comDataPartId.SelectedItem);
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
            param.AddParam(":SDATAPARTID", sDataPartId);
            String sql = @"update  SYNC_CONDSET set                         
                            LineNumber = :SDATAPARTID where SERIES_CD=:SERIES_CD";
            db.SelectTable(sql, param.GetParam());
            //add 8431 zc end
        }

        private void radioButPartId1_CheckedChanged(object sender, EventArgs e)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
            //add 8431 zc start          
            String sql = @"update  SYNC_CONDSET set
                            IsChecked='1' where SERIES_CD=:SERIES_CD";
            db.SelectTable(sql, param.GetParam());
            //add 8431 zc end
        }

        private void radioButPartId2_CheckedChanged(object sender, EventArgs e)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
            //add 8431 zc start          
            String sql = @"update  SYNC_CONDSET set
                            IsChecked='2' where SERIES_CD=:SERIES_CD";
            db.SelectTable(sql, param.GetParam());
            //add 8431 zc end
        }
        // Add #8111、#8109 趙 End

        // add zl start
        private void LoadReturnRecords()
        {
            //cmbReturnRecords.Items?.Clear();
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
            string strSQL = @"SELECT
                                a.KIND_ID,
		                        KIND_NAME
                            FROM
                                MST_LLT_KIND a
                                inner join MST_LLT_KIND_SUB_NEW b
                                    on(a.KIND_ID = b.KIND_ID and a.UP_DATE = b.UP_DATE)
                            WHERE
                                a.kind_id <> 0  and SERIES_CD =:SERIES_CD
                             ORDER BY
                                a.KIND_ID ";

            // SQL実行
            DataTable dt = db.SelectTable(strSQL, param.GetParam());
            if (null == dt)
            {
                MessageBox.Show("観察記録種別マスタ情報の取得に失敗しました。", "", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }

            DataRow dr = dt.NewRow();
            dr["KIND_NAME"] = string.Empty;
            dr["KIND_ID"] = DBNull.Value;
            dt.Rows.InsertAt(dr, 0);

            this.cmbReturnRecords.DataSource = dt;
            this.cmbReturnRecords.DisplayMember = "KIND_NAME";
            this.cmbReturnRecords.ValueMember = "KIND_ID";

            IMakeSqlParameters param1 = db.GetIMakeSqlParameters();
            param1.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
            String sql = "select R_R from  SYNC_CONDSET where SERIES_CD =:SERIES_CD";
            DataTable pdt = db.SelectTable(sql, param1.GetParam());

            if (pdt.Rows[0]["R_R"].ToString() != string.Empty)
            {
                string rRecord = pdt.Rows[0]["R_R"].ToString();
                this.cmbReturnRecords.SelectedValue = rRecord;
            }
        }

        private void cmbReturnRecords_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (_isInitializing) {
                return;
            }
            string value = this.cmbReturnRecords.SelectedValue.ToString();
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SERIES_CD", tabControlSd.SelectedTab.Tag.ToString());
            //mod #10418 start
            string sql = "update SYNC_CONDSET set R_R = :R_R where SERIES_CD = :SERIES_CD";
            if (value != string.Empty)
            {
                int c;
                if (Int32.TryParse(value, out c))
                {
                    param.AddParam(":R_R", value);
                   
                }
                else
                {
                    return; 
                }
            }
            else
            {
                param.AddParam(":R_R", DBNull.Value);
            }
            db.SelectTable(sql, param.GetParam());
            //mod  #10418 end
            
        }
        // add zl end

        //add #9696 djy start
        /// <summary>
        /// ReplaceLogName
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public string ReplaceLogName(string fileName)
        {

            if (CommonConfig.FacilityCd == null)
            {
                IMakeSqlParameters param = db.GetIMakeSqlParameters();
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                string sql = "select FACILITY_CD from SYNC_FACILITY_CD where  SERIES_CD=:SERIES_CD";
                CommonConfig.FacilityCd = db.SelectTable(sql, param.GetParam()).Rows[0]["FACILITY_CD"].ToString();
            }

            string logFile = CommonConfig.FacilityCd + "_ConvertTool_";
            string[] filesp = fileName.Split('[');

            if (filesp.Length >= 2)
            {
                string fileafter = filesp[0];
                string filebefore = filesp[1];

                if (filebefore.Contains("completely"))
                {
                    logFile = logFile + "first_all_";
                }
                else if (filebefore.Contains("diff"))
                {
                    logFile = logFile + "diff_";
                }
                else
                {
                    logFile = logFile + "first_part_";
                }

                switch (fileafter)
                {
                    case "convert(mst)":
                        logFile = logFile + "master_";
                        break;
                    case "convert(pat)":
                        logFile = logFile + "patMain_";
                        break;
                    case "convert(motion)":
                        logFile = logFile + "motion_";
                        break;
                    case "inspectionSchedule／result":
                        logFile = logFile + "inspectionSchedule_result_";
                        break;
                    default:
                        logFile = logFile + fileafter + "_";
                        break;
                }
            }
            else
            {
                logFile = logFile + fileName + "_";
            }
            DateTime now = DateTime.Now;
            string formattedDateTime = now.ToString("yyyyMMdd_HHmmss");
            logFile = logFile + formattedDateTime;

            return logFile;
        }

        private void setcomDataPartId(string serCd) {

            comDataPartId.Items.Clear();
            comDataPartId.Items.Add("11");
            comDataPartId.Items.Add("10");
            comDataPartId.Items.Add("9");
            comDataPartId.Items.Add("8");
            comDataPartId.Items.Add("7");
            comDataPartId.Items.Add("6");
            comDataPartId.Items.Add("5");
            comDataPartId.Items.Add("4");
            comDataPartId.Items.Add("3");
            comDataPartId.Items.Add("2");
            comDataPartId.Items.Add("1");
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SERIES_CD", serCd);
            string sql = "select * from SYNC_CONDSET where SERIES_CD=:SERIES_CD";
            DataTable dt = db.SelectTable(sql, param.GetParam());

            comDataPartId.Text = dt.Rows[0]["LINENUMBER"].ToString();

            if (dt.Rows[0]["IsChecked"].Equals("1"))
            {
                radioButPartId1.Checked = true;
            }
            else if (dt.Rows[0]["IsChecked"].Equals("2"))
            {
                radioButPartId2.Checked = true;
            }
            else
            {
                radioButPartId3.Checked = true;
                comDataPartId.Enabled = true;
            }
            this.cmbReturnRecords.SelectedValue = dt.Rows[0]["R_R"];
        }

        //add #9696 djy end

        //7997  画面編集データか、ページ読み込みのエコーバックデータか start
        private bool _isInitializing;
        //7997  画面編集データか、ページ読み込みのエコーバックデータか end
        private void setserCdData(string serCd) {

            _isInitializing = true;
            setcomDataPartId(serCd);
            //7997 start
            setcmbDataType(serCd);
            //7997 end
            
            if (CommonConfig.SelectedTypeByFacility.TryGetValue(tabControlSd.SelectedTab.Tag.ToString(), out var values))
            {
                cmbDataType.SelectedItem = values;
            }
            if (cmbDataType.SelectedIndex == -1)
            {
                cmbDataType.SelectedIndex = 0;
            }

            
            if (SelectedchkSelectAllSpan.TryGetValue(serCd, out var valuechk))
            {
                chkSelectAllSpan.Checked = valuechk;
            }
            if (SelectedchkEnd.TryGetValue(serCd, out var valuechkEnd))
            {
                chkEndDateControl.Checked = valuechkEnd;
            }
            if (SelecteddtpStartDate.TryGetValue(serCd, out var value))
            {
                dtpStartDate.Value = value;
            }
            if (SelecteddtpEndDate.TryGetValue(serCd, out var valueEnd))
            {
                dtpEndDate.Value = valueEnd;
            }
           

            // del #12484 コンバートツールで処理種別の除外ができない limingzhe start
            //if (LstDgvPatSelectedIndex.Count > 0)
            //{
            //    dgvPat.ClearSelection();
                
            //}
            // del #12484 コンバートツールで処理種別の除外ができない limingzhe end
            _isInitializing = false;
        }

        public void Reload()
        {
            setserCdData(tabControlSd.SelectedTab.Tag.ToString());
        }
    }
}
