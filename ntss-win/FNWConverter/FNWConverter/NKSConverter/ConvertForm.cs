using ConvertCommon;
using ConvertCommon.Common;
using ConvertCommon.Const;

using ConvertCommon.dto;
using ConvertCommon.Dto;
using ConvertCommon.parts;
using Fnw.IOControl.DB;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NKSConverter.Properties;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NKSConverter
{
    public partial class ConvertForm : Form
    {
        // Add #7340 PC側アプリの出力が遅い 趙 Start
        [DllImport("kernel32.dll", EntryPoint = "SetProcessWorkingSetSize")]
        public static extern int SetProcessWorkingSetSize(IntPtr process, int minSize, int maxSize);
        // Add #7340 PC側アプリの出力が遅い 趙 End
        #region Const value

        private const string FACILITY_CD_KEY = "facilityCd";
        private const string LOG_FILES_KEY = "logFiles";
        private const string LOG_FILES_NAME_KEY = "uploadLogFileName";
        //mod #10859_1 文言修正 hyl start
        private const string CMB_SELECT_ALL = "すべて";
        private const string CMB_SELECT_ALL_ADD = "すべて(追加)";
        private const string CMB_SELECT_ALL_RECORD_PAT = "患者情報（掲示板、観察記録、患者イベント含む）";
        private const string CMB_SELECT_PAT_EXAM = "検査情報（予定/結果/放射線 期間指定可）";
        private const string CMB_SELECT_ALL_RECORD_MST = "マスター（マスタ、機器保守関連含む）";
        //private const string CMB_SELECT_ALL_RECORD_MST = "全件移行対象（マスタ）";
        //mod #10859_1文言修正 hyl end
        private const string CMB_SELECT_SPECIFY_PERIOD_PAT = "透析情報（指示/実績/バイタル/モニタ/愁訴処置 期間指定可）";

        // mod FNSI-指示履歴の修正 楊 start
        private const string CMB_SELECT_INDICATES_HISTORY = "指示履歴";
        // mod FNSI-指示履歴の修正 楊 end

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        //mod #10859_1 文言修正 hyl start
        //private const string CMB_SELECT_ALL_MNT_MOTION_RECORD = "装置記録";
        private const string CMB_SELECT_ALL_MNT_MOTION_RECORD = "装置記録（装置自己診断/愁訴処置表示項目含む 期間指定可）";
        //mod #10859_1文言修正 hyl end
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end
        #endregion

        #region Properties

        DBCtrl db = null;

        private bool IsConvertAll = false;

        private NKSConverter.MainForm _settingConvertForm;

        // mod ProgressBarの修正 楊 end
        // Add #7997 趙 Start
        private DataTable dtSeriesCdAndFacilityCdList;
        private DataRow[] facilityAndSeries;
        // Add #7997 趙 End
        ConvertSQL cs = new ConvertSQL();
        private int msPat = 0;
        private int fmsPat = 0;
        private int Monnum = 0;
        private int Indnum = 0;

       
        #endregion

        public ConvertForm()
        {
            InitializeComponent();
            //add 7838  鄭   start
            db = ConvertControl.DBConnectFnw();
            //add  7838  鄭   end
            RegisterEnvent();
            InitForm();
            ShowInfo(); // mod 2020-12-11 594 FNWの情報を取得状況。 う
            FormShowState(); // mod 2020-12-11 画面表示設定 う
            // Add #7997 趙 Start
            SetSeriesCdAndFacilityCdToDataTable();
            //add 8502 zc start
            DialysisSetDisp();
            //add 8502 zc end
            facilityAndSeries = dtSeriesCdAndFacilityCdList.Select(" FACILITY_CD <> ''");
            StringBuilder facilityCd = new StringBuilder();
            for (int j = 0; j < facilityAndSeries.Length; j++)
            {
                if (j != 0)
                {
                    facilityCd.Append(",");
                }
               
                facilityCd.Append(Convert.ToString(facilityAndSeries[j]["FACILITY_CD"]));
            }
            ConvertBase.WriteTraceLog("facilityCd取得する：" + facilityCd.ToString());

            if (string.IsNullOrEmpty(CommonConfig.LoginUrl))
            {
                ExtendButton.Enabled = false;
            }
            // Add #7997 趙 End

            //Add #7997 進捗バー 修正　start
            DataTable dt = db.SelectTable("select FACILITY_CD from SYNC_FACILITY_CD");
            foreach (var item in dt.Select())
            {
                AddFacilityProgressBar(item["FACILITY_CD"].ToString());
            }
            //Add #7997　進捗バー 修正 end
        }

        //Add #7997 進捗バー 修正　start
        private void AddFacilityProgressBar(string facilityName)
        {
            Panel panel = new Panel
            {
                Width = panel1.Width - 10, 
                Height = 30,
                Margin = new Padding(5),
                Anchor = AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Top
            };

            Label lbl = new Label
            {
                Text = $"「{facilityName}」:",
                Width = 65,
                Height = 28,
                Location = new Point(0, 5),
                TextAlign = ContentAlignment.MiddleLeft
            };

            SafeProgressBar progressBar = new SafeProgressBar
            {
                Width = panel.Width - lbl.Width - 10, 
                Height = 28,
                Location = new Point(lbl.Width + 10, 2),
                Value = 0,
                TextFont = new Font("Arial", 10, FontStyle.Bold)
            };

            panel.Controls.Add(lbl);
            panel.Controls.Add(progressBar);

            int nextY = 10;
            if (panel1.Controls.Count > 0)
            {
                Control last = panel1.Controls[panel1.Controls.Count - 1];
                nextY = last.Bottom + 5;
            }
            panel.Location = new Point(10, nextY);

            panel1.Controls.Add(panel);
            progressBars.Add(facilityName, progressBar);
        }
       
        private Dictionary<string, SafeProgressBar> progressBars = new Dictionary<string, SafeProgressBar>();
        private int finishedFacilityCount = 0;
        private object lockObj = new object();
         //Add #7997 進捗バー 修正　end

        //add 8502 zc Start
        public void DialysisSetDisp()
        {

            String sql = @"select Boold,p_A,p_V,p_SN,SERIES_CD from  SYNC_CONDSET";
            DataTable dt = db.SelectTable(sql);
            if (dt != null)
            {
                foreach (DataRow row in dt.Rows)
                {
                    string seriesCd = row["SERIES_CD"].ToString();

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
        public void getToken(DBCtrl db) {

            DataTable dt=db.SelectTable("select * from SYNC_LOGIN");

            DataTable fcdt = db.SelectTable("select FACILITY_CD from SYNC_FACILITY_CD   ORDER BY ID");
            if (dt.Rows[0]["PASS"] != null && dt.Rows[0]["LOGIN"] != null && fcdt.Rows.Count>0)
            {
                HashSet<string> facilitycdList = new HashSet<string>();
                foreach (DataRow dr in fcdt.Rows)
                {
                    facilitycdList.Add(dr["FACILITY_CD"].ToString());
                }

                string facilitycd = string.Join(",", facilitycdList);
                string user = dt.Rows[0]["LOGIN"].ToString();
                string pass = dt.Rows[0]["PASS"].ToString();
                string url = NKSConverter.Properties.Settings.Default.ConvertLogin;
                Dictionary<string, string> parameters = new Dictionary<String, String> { { "login", user }, { "password", pass }, { "facilitycd", facilitycd } };
                CommonConfig.LoginUrl = url;
                string response = HttpControl.sendWebRequestPost(url, parameters);
                JObject jsonObject = JObject.Parse(response);
                string code = (string)jsonObject["code"];
                if (code.Equals("200"))
                {
                    CommonConfig.token = (string)jsonObject["token"];
                    var hashValueDict = jsonObject["hashvalue"].ToObject<Dictionary<string, string>>();
                    foreach (var item in hashValueDict)
                    {
                        IMakeSqlParameters param = db.GetIMakeSqlParameters();
                        param.AddParam(":FACILITY_CD", item.Key);
                        param.AddParam(":HASH_VALUE", item.Value);
                        CommonConfig.HashValueSet[item.Key] = item.Value;
                       
                    }
                    var hashValueDicts = jsonObject["hashvalue"].ToObject<Dictionary<string, string>>();
                    var onlyValues = hashValueDicts.Values.ToList();
                    
                }
            }
            else {
                CommonConfig.token = null;
                CommonConfig.LoginUrl = null;
                CommonConfig.HashValueSet = new Dictionary<string, string>();
            }
           
        }
        //add 8502 zc end
        // add FNSI-差分コンバート対応 楊 start
        public ConvertForm(ref bool flag)
        {
            InitializeComponent();
            RegisterEnvent();
            db = ConvertControl.DBConnectFnw();
            if (null == db)
            {
                flag = false;
                return;
            };
            //add 10333
            getToken(db);
            //add 10333
            //FNSi 接続状態
            string url = NKSConverter.Properties.Settings.Default.ConvertRestCheckConnection;
            if (!HttpControl.isFNsiConnection(url))
            {
                flag = false;
                return;
            }
            _settingConvertForm = new MainForm();
            _settingConvertForm.MainForm_Load();
            // Mod #7997 趙 Start
            SetSeriesCdAndFacilityCdToDataTable();
            // Mod #7997 趙 End
            SetCmbSeriesCd();

            _settingConvertForm.IsInit = true;
            CommonConfig.isDiff = true;
        }

        public bool makeSqlFlow()
        {
            var flag = true;
            var ret = true;
            if (!DBCommon.IsConnection(null))
            {
                return false;
            }

            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
            CommonConfig.appStartTime = DateTime.Now;
            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end

            // add 8396 差分コンバート実行時に初回ファイルも転送されてしまう start
            bakFiles();
            // add 8396 差分コンバート実行時に初回ファイルも転送されてしまう end

            // Add #7997 趙 Start
            // 施設コードを取得する
            DataRow[] dataRow = dtSeriesCdAndFacilityCdList.Select(" FACILITY_CD <> ''");
            for (int j = 0; j < dataRow.Length; j++)
            {
                _settingConvertForm.loopKbn = null;
                TextBox txtFacilityCdValue = new TextBox();
                txtFacilityCdValue.Text = Convert.ToString(dataRow[j]["FACILITY_CD"]);
                _settingConvertForm.txtFacilityCd = txtFacilityCdValue;
                TextBox txtSeriesCdValue = new TextBox();
                txtSeriesCdValue.Text = Convert.ToString(dataRow[j]["SERIES_CD"]);
                _settingConvertForm.txtSeriesCd = txtSeriesCdValue;
                // Add #7997 趙 End
                // sql作成
                _settingConvertForm._lbSQLFileBuildStatus = this.lstLog;
                this.IsConvertAll = true;
                CommonConfig.FacilityCd = txtFacilityCdValue.Text;
                ret = this._settingConvertForm.EventConvertAllTableForService();

                if (!ret)
                {
                    return flag;
                }

                // ファイルアップロッド
                UploadForm uploadForm = new UploadForm
                {
                    // Mod #7997 趙 Start
                    //facilityCd = _settingConvertForm.public_txtFacilityCd
                    facilityCd = Convert.ToString(dataRow[j]["FACILITY_CD"])
                    // Mod #7997 趙 End  
                };
                uploadForm.Owner = this;
                ret = uploadForm.UploadFiles(txtFacilityCdValue.Text);
                if (!ret)
                {
                    return flag;
                }

                // コンバート実行
                ret = uploadForm.ExecuteJob();
                if (!ret)
                {
                    return flag;
                }
                Task.Run(() =>
                {
                    UpdateLogforServer(txtFacilityCdValue.Text);
                });
               // this.UpdateLogforServer(txtFacilityCdValue.Text);
            }
            // server側のログ出力
            return ret;
        }

        // add 8396 差分コンバート実行時に初回ファイルも転送されてしまう start
        public void bakFiles()
        {

            DataTable dt = db.SelectTable("select FACILITY_CD from SYNC_FACILITY_CD");
            foreach (DataRow dr in dt.Rows)
            {
         
                List<FilePropertyDto> listFiles = new List<FilePropertyDto>();

                // 出力先フォルダ作成
                string exportFolderPath = NKSConverter.Properties.Settings.Default.DefaultExportFolderPath;
                exportFolderPath += "\\" + dr["FACILITY_CD"];
                // add #10859 exportフォルダが存在しない場合、自動送信ONで出力するとエラーになります start
                string fullPath = Path.GetFullPath(exportFolderPath);
                if (!Directory.Exists(fullPath))
                {
                    Directory.CreateDirectory(fullPath);
                }
                // add #10859 exportフォルダが存在しない場合、自動送信ONで出力するとエラーになります end
                DirectoryInfo folder = new DirectoryInfo(exportFolderPath);
                foreach (FileInfo file in folder.GetFiles("*.Z*"))
                {
                    FilePropertyDto f = new FilePropertyDto(File.ReadAllBytes(file.FullName), file.Name, "application/zip");
                    listFiles.Add(f);
                }

                // アップロッドされたファイルを移動
                // bakフォルダ作成
                string exportBakFolderPath = exportFolderPath + string.Format(@"\bak_{0}", DateTime.Now.ToString("yyyyMMddHHmmss"));
                if (listFiles.Count > 0)
                {
                    if (!Directory.Exists(exportBakFolderPath))
                    {
                        Directory.CreateDirectory(exportBakFolderPath);
                    }

                    foreach (FilePropertyDto files in listFiles)
                    {
                        // bakフォルダに移動
                        File.Move(exportFolderPath + "/" + files.FileName, exportBakFolderPath + "/" + files.FileName);
                    }

                }
                //add 9641 zc start
                string[] len = System.IO.Directory.GetDirectories(exportFolderPath);
                if (len.Length >= int.Parse(CommonConfig.DefaultExportFolderPathLen))
                {
                    for (int i = 0; i < len.Length - int.Parse(CommonConfig.DefaultExportFolderPathLen) + 1; i++)
                    {
                        Directory.Delete(len[i], true);
                    }
                }
                //add 9641 zc end
            }
            //add 9641 zc end
        }

        // add 8396 差分コンバート実行時に初回ファイルも転送されてしまう end
        private void UpdateLogforServer(string fCd)
        {
            bool timeFlag = true;
            //add #7997 進捗バー 修正　start
            IList<BatchConvertTableLogDto> batchConvertTableLogDtoList = new List<BatchConvertTableLogDto>();
            string orderNo = "0";
            int showLineCount = 0;
            //add #7997 進捗バー 修正　end
            while (timeFlag)
            {
                List<string> writeInfos = new List<string>();
                //add #7997 進捗バー 修正　start
                this.getConvertTableLog(fCd,ref batchConvertTableLogDtoList,ref orderNo);
                //add #7997 進捗バー 修正　end
                for (int i = showLineCount + 1; i < batchConvertTableLogDtoList.Count; i++)
                {
                    BatchConvertTableLogDto item = batchConvertTableLogDtoList[i];
                    writeInfos.Add(item.reg_date + " : table " + item.table_name + " 移行" + item.content);
                }
                //servertログ出力
                //OpenAndWriteCLogFile(writeInfos);
                showLineCount = batchConvertTableLogDtoList.Count;

                if (batchConvertTableLogDtoList.Count > 0)
                {
                    string stopShowMsg = batchConvertTableLogDtoList[batchConvertTableLogDtoList.Count - 1].content;
                    // add FNSI-FNSI-ジョブ実行修正 楊 start
                    if (stopShowMsg == "ジョブ正常終了" || stopShowMsg == "ジョブ停止（処理対象SQLファイルなし）")
                    // add FNSI-FNSI-ジョブ実行修正 楊 end
                    {
                        timeFlag = false;
                        return;
                    }
                }
                // mod #10674 convertdb service is abnormal, Sleep for 30 seconds before making another request zkm start
                Thread.Sleep(5000);
                // mod #10674 convertdb service is abnormal, Sleep for 30 seconds before making another request zkm end
            }
        }

        /// <summary>
        /// コンボボックス設定
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        private void SetCmbSeriesCd()
        {
            // 系列施設マスタテーブル取得
            cmbSeriesCd.DataSource = db.SelectTable("select SERIES_CD from SYS_SERIES_FACILITY where '0' = DEL_FLG and '1' = DISP_FLG order by DISP_ORDER, SERIES_CD");
            // 表示は系列施設コード
            cmbSeriesCd.DisplayMember = "SERIES_CD";
            // 値は系列施設コード
            cmbSeriesCd.ValueMember = "SERIES_CD";
            // 初期値
            cmbSeriesCd.SelectedIndex = 0;
        }
        // add FNSI-差分コンバート対応 楊 end

        // add 2020-12-11 画面表示設定 う start
        public void FormShowState()
        {
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.WindowState = FormWindowState.Maximized;
        }
        // add 2020-12-11 画面表示設定 う end

        // add 2020-12-11 594 FNWの情報を取得状況。 う start
        public void ShowInfo()
        {
            lstStatus.Items.Clear();
            lstStatus.Items.Add("FNWの情報を取得しています。");
            lstStatus.Items.Add("しばらくお待ち下さい。");
        }
        // add 2020-12-11 594 FNWの情報を取得状況。 う end

        #region Event Form
        private void RegisterEnvent()
        {
            btnSetting.Click += new EventHandler(BtnSetting_Click);
            btnConvert.Click += new EventHandler(BtnConvert_Click);
            btnUpload.Click += new EventHandler(BtnUpload_Click);
            //updateLogBtn.Click += new EventHandler(UpdateLogBtn_Click);
            updateLogBtn.Click += new EventHandler(UpdateLogBtn_Click1);
            //updateProgressBarBtn.Click += new EventHandler(UpdateProgressBarBtn_Click);
            updateProgressBarBtn.Click += new EventHandler(UpdateProgressBarBtn_Click1);
            convertInfoUpdatebtn.Click += new EventHandler(ConvertInfoUpdatebtn_Click);
            btnConvertAllTable.Click += new EventHandler(BtnConvertAllTable_Click);
        }

        private void ShowMsgBoxWarning(string msg)
        {
            MessageBox.Show(msg, "", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        /// <summary>
        /// 施設コードの入力チェック
        /// </summary>
        /// <returns></returns>
        private bool CheckFacilityCd()
        {
            // Mod #7997 趙 Start
            //if (!Validator.CheckHalfWidthAlphaNumeric(6, txtFacilityCd.Text))
            if (!Validator.CheckHalfWidthAlphaNumeric(6, _settingConvertForm.txtFacilityCd.Text))
            // Mod #7997 趙 End
            {
                ShowMsgBoxWarning("施設コードは半角英数字6桁で入力してください。");
                // Del #7997 趙 Start
                //txtFacilityCd.Focus();
                // Del #7997 趙 End
                return false;
            }
            else
            {
                return true;
            }
        }

        private void BtnConvertAllTable_Click(object sender, EventArgs e)
        {
            if (!CheckFacilityCd()) return;
            this.IsConvertAll = true;
            this._settingConvertForm.EventConvertAllTable();
            this.IsConvertAll = false;
        }

        private void BtnUpload_Click(object sender, EventArgs e)
        {

            UploadForm uploadForm = new UploadForm
            {
                // Mod #7997 趙 Start
                //facilityCd = _settingConvertForm.public_txtFacilityCd
                facilityCdList = dtSeriesCdAndFacilityCdList.Select(" FACILITY_CD <> ''")
                // Mod #7997 趙 End
            };
            uploadForm.Owner = this;
            //mod 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
            //uploadForm.Show();
            uploadForm.ShowDialog();
            //mod 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
        }

        private Dictionary<string, string> getTypeSeriesCd() {

            var typeToFacilityMap = new Dictionary<string, List<string>>();

            foreach (var item in CommonConfig.SelectedTypeByFacility)
            {
                string facility = item.Key;
                string type = item.Value;

                if (!typeToFacilityMap.TryGetValue(type, out var list))
                {
                    list = new List<string>();
                    typeToFacilityMap[type] = list;
                }

                list.Add(facility);
            }

            var typeToInSqlMap = new Dictionary<string, string>();

            foreach (var kv in typeToFacilityMap)
            {
                string type = kv.Key;
                List<string> facilities = kv.Value;

                string inSql = string.Join(",", facilities.Select(f => $"{f}"));
                typeToInSqlMap[type] = inSql;
            }

            return typeToInSqlMap;


        }

        private Dictionary<string, string> getTableSeriesCd()
        {

           
            var typeFacilityMap = new Dictionary<string, List<string>>();

            foreach (var facilityEntry in _settingConvertForm.SelectedRowsByFacility)
            {
                string facility = facilityEntry.Key;
                var rows = facilityEntry.Value;
         
                foreach (var row in rows)
                {

                    if (!row.TryGetValue("table", out var typeValue) || typeValue == null)
                    {
                        continue;
                    }

                    string type = typeValue.ToString();

                    if (!typeFacilityMap.TryGetValue(type, out var facilityList))
                    {
                        facilityList = new List<string>();
                        typeFacilityMap[type] = facilityList;
                    }

                    if (!facilityList.Contains(facility))
                    {
                        facilityList.Add(facility);
                    }
                }
            }
            var typeFacilityStringMap = typeFacilityMap
                .ToDictionary(
                    kv => kv.Key,
                    kv => string.Join(",", kv.Value.Select(f => $"'{f}'"))
                );
            return typeFacilityStringMap;

        }

        // add #12484 コンバートツールで処理種別の除外ができない limingzhe start
        private Dictionary<string, string> getSelectType()
        {
            var typeFacilityMap = new Dictionary<string, List<string>>();
            foreach (var facilityEntry in _settingConvertForm.SelectedRowsByFacility)
            {
                string facility = facilityEntry.Key;
                var rows = facilityEntry.Value;
                foreach (var row in rows)
                {
                    if (!row.TryGetValue("dataType", out var typeValue) || typeValue == null)
                    {
                        continue;
                    }

                    string type = typeValue.ToString();
                    if (!typeFacilityMap.TryGetValue(type, out var facilityList))
                    {
                        facilityList = new List<string>();
                        typeFacilityMap[type] = facilityList;
                    }

                    if (!facilityList.Contains(facility))
                    {
                        facilityList.Add(facility);
                    }
                }
            }
            var typeFacilityStringMap = typeFacilityMap
                .ToDictionary(
                    kv => kv.Key,
                    kv => string.Join(",", kv.Value.Select(f => $"'{f}'"))
                );
            return typeFacilityStringMap;
        }

        public void ConvertInfoUpdatebtn_Click(object sender, EventArgs e)
        {
            convertInfoUpdatebtn.Enabled = false;
            lstStatus.Items.Clear();

            Dictionary<string, string> dataType = getTypeSeriesCd();
            Dictionary<string, string> tableType = getTableSeriesCd();
            Dictionary<string, string> selectType = getSelectType();

            bool exists = dataType.Keys.Any(k => k.Contains(CMB_SELECT_ALL));
            if (exists)
            {
                this.IsConvertAll = true;
            }

            //get selected tables
            // 患者情報、マスタ情報
            int patTotalRecord = CountPatientInfo(dataType, selectType, tableType);
            int mstTotalRecord = CountMasterInfo(dataType, selectType, tableType);
            msPat = patTotalRecord + mstTotalRecord;
            // 指示情報、実績情報
            int indRecords, rstRecords;
            CountPlanAndResult(dataType, selectType, out indRecords, out rstRecords);
            fmsPat = indRecords + rstRecords;
            // 指示履歴
            int hisTotalRecord = CountIndicateHistory(dataType, selectType);
            Indnum = hisTotalRecord;
            // 装置記録情報
            int motionTotalRecord = CountMotionRecords(dataType, selectType, tableType);
            Monnum = motionTotalRecord;

            //Fill to View
            ShowResult(patTotalRecord, mstTotalRecord, indRecords, rstRecords, hisTotalRecord, motionTotalRecord);
            CommonConfig.allLen = patTotalRecord + patTotalRecord + mstTotalRecord + indRecords + rstRecords + hisTotalRecord + motionTotalRecord;
            CommonConfig.schLen = 0;

            convertInfoUpdatebtn.Enabled = true;
            this.IsConvertAll = false;
        }

        private List<DgvPatRowDto> GetSelectedTables(Dictionary<string, string> dataType, string convertType)
        {
            return !string.Equals(convertType, string.Empty)
                ? _settingConvertForm.GetConvertInfoListByConvertType(convertType)
                : GetDTOFromDgvSelectedRow(dataType);
        }

        private string BuildSeriesValue(
            string tableName,
            Dictionary<string, string> dataType,
            Dictionary<string, string> tableType, IMakeSqlParameters param
         )
        {
           
            string value = string.Join(",",
                new[] { tableName }
                .Where(k => tableType.ContainsKey(k))
                .Select(k => tableType[k]));

            List<string> values = value
                  .Replace("'", "")
                  .Split(',')
                  .Select(x => x.Trim())
                  .Where(x => !string.IsNullOrEmpty(x))
                  .ToList();

            // 「すべて」選択時の補正
            if (dataType.Keys.Any(k => k.IndexOf(CMB_SELECT_ALL, StringComparison.OrdinalIgnoreCase) >= 0))
            {
                var item = dataType.FirstOrDefault(kv =>
                    kv.Key.IndexOf(CMB_SELECT_ALL, StringComparison.OrdinalIgnoreCase) >= 0);

                if (!string.IsNullOrEmpty(item.Key))
                {
                    values.AddRange(item.Value.Split(',').ToList());
                }
            }
            List<string> paramNames = new List<string>();

            for (int i = 0; i < values.Count; i++)
            {
                string paramName = ":SERIES_CD_" + i;
                paramNames.Add(paramName);
                param.AddParam(paramName, values[i]);
            }

            return string.Join(",", paramNames);
            //return value;
        }

        /// <summary>
        /// シリーズ条件生成
        /// </summary>
        private string BuildSeriesValuebyType(
            Dictionary<string, string> dataType,
            Dictionary<string, string> selectType,
            string convertType
        )
        {
            List<string> typeList = new List<string>();
            typeList.Add(convertType);
            if (selectType.Keys.Contains(convertType))
            {
                typeList.Add(CMB_SELECT_ALL);
                typeList.Add(CMB_SELECT_ALL_ADD);
            }
            string value = string.Join(",",
                typeList
                .Where(k => dataType.ContainsKey(k))
                .Select(k => dataType[k])
            );
            return value;
        }

        private int CountPatientInfo(
            Dictionary<string, string> dataType,
            Dictionary<string, string> selectType,
            Dictionary<string, string> tableType
        )
        {
            int total = 0;
            List<DgvPatRowDto> patSelected = GetSelectedTables(dataType, selectType.Keys.Contains(CMB_SELECT_ALL_RECORD_PAT) ? CMB_SELECT_ALL_RECORD_PAT : string.Empty);
            patSelected = patSelected.Where(item => item.type == CMB_SELECT_ALL_RECORD_PAT).ToList();
            foreach (var item in patSelected)
            {
                var param = db.GetIMakeSqlParameters();
                string value = BuildSeriesValue(item.fnwTableName, dataType, tableType, param);
                if (string.IsNullOrEmpty(value)) continue;

                string sql = BuildPatientSql(item, value);
                var dt = db.SelectTable(sql, param.GetParam());

                if (dt != null)
                    total += dt.Rows.Count;
            }
            return total;
        }

        private string BuildPatientSql(DgvPatRowDto item, string value)
        {
            // 特殊テーブル分岐
            if (item.ntssTableName.Equals("pat_group_detail_history"))
            {
                return $@"select {GetSelectKey(item)} from {item.fnwTableName} a
                  where SERIES_CD IN ({value})";
            }

            if (CommonConstants.TABLE_SERIES_CD.Contains(item.fnwTableName + "-" + item.ntssTableName))
            {
                return $@"select {GetSelectKey(item, true)} from {item.fnwTableName} a
                  where SERIES_CD IN ({value})";
            }

            return $@"select {GetSelectKey(item, true)} from {item.fnwTableName} a 
              INNER JOIN SYS_PAT_SERIES_FACILITY S 
              ON S.PATID = a.PATID 
              AND MAIN_FLG='1' 
              AND s.SERIES_CD IN ({value})";
        }

        /// <summary>
        /// SELECT句のキー項目を生成する
        /// </summary>
        /// <param name="item">対象テーブル情報</param>
        /// <param name="useDistinct">DISTINCTを付けるか</param>
        /// <returns>SELECT句のカラム部分</returns>
        private string GetSelectKey(DgvPatRowDto item, bool useDistinct = false)
        {
            // 主キーの場合は全件取得
            if (item.fkey == "PKEY" || item.fkey == "KEY")
            {
                return "*";
            }

            // DISTINCT 指定あり
            if (useDistinct)
            {
                return $"distinct a.{item.fkey}";
            }

            // 通常カラム
            return $"a.{item.fkey}";
        }

        /// <summary>
        /// マスタ情報の件数を取得する
        /// </summary>
        private int CountMasterInfo(
            Dictionary<string, string> dataType,
            Dictionary<string, string> selectType,
            Dictionary<string, string> tableType
        ) {
            int mstTotalRecord = 0;
            var mstSelected = GetSelectedTables(dataType, selectType.Keys.Contains(CMB_SELECT_ALL_RECORD_MST) ? CMB_SELECT_ALL_RECORD_MST : string.Empty);
            mstSelected = mstSelected.Where(item => item.type == CMB_SELECT_ALL_RECORD_MST).ToList();
            foreach (DgvPatRowDto item in mstSelected)
            {
                // テーブル名が空の場合はスキップ
                if (string.IsNullOrEmpty(item.fnwTableName))
                    continue;

                // SERIES_CDカラムの存在チェック
                bool hasSeriesCd = HasSeriesCdColumn(item.fnwTableName);

                // ベースSQL生成
                string mstSql = BuildMasterBaseSql(item);
                var param = db.GetIMakeSqlParameters();
                DataTable mstDataTable = new DataTable();
                // シリーズ条件生成
                string value = BuildSeriesValue(item.fnwTableName, dataType, tableType, param);

                // SERIES_CD条件付与
                if (hasSeriesCd && !string.IsNullOrEmpty(value))
                {
                    if (!IsSpecialViewerLayout(item))
                    {
                        mstSql += $" where SERIES_CD IN ({value})";
                    }
                    
                }
              
                // 実行
                if (mstSql.Contains(":SERIES_CD"))
                {
                    // 実行
                    mstDataTable = db.SelectTable(mstSql, param.GetParam());
                }
                else {
                    // 実行
                    mstDataTable = db.SelectTable(mstSql);
                }
                //DataTable mstDataTable = db.SelectTable(mstSql, param.GetParam());
                if (mstDataTable != null)
                    mstTotalRecord += mstDataTable.Rows.Count;
            }

            return mstTotalRecord;
        }
        
        /// <summary>
        /// SERIES_CDカラムが存在するか確認
        /// </summary>
        private bool HasSeriesCdColumn(string tableName)
        {
            string sql = @"
            SELECT COUNT(*) AS CNT
            FROM USER_TAB_COLUMNS
            WHERE TABLE_NAME = UPPER(:TABLE_NAME)
            AND COLUMN_NAME = 'SERIES_CD'";

            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":TABLE_NAME", tableName);

            DataTable dt = db.SelectTable(sql, param.GetParam());

            return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0]["CNT"]) > 0;
        }

        /// <summary>
        /// マスタ用の基本SQLを生成
        /// </summary>
        private string BuildMasterBaseSql(DgvPatRowDto item)
        {
            if (item.fnwTableName.Equals("SYS_CHECKLST_SETTING"))
            {
                return "select distinct LIST_CD from SYS_CHECKLST_SETTING";
            }
            else if (item.fnwTableName.Equals("MST_CHECKLIST_ITEM_DAILY"))
            {
                return "select distinct DEVICE_TYPE_CD from V_MST_CHECKLIST_PERIOD_DETAIL";
            }
            else if (item.ntssTableName.Equals("mst_pat_event_sub_category"))
            {
                return "select distinct EVENT_CATEGORY_CD_2 from MST_EVENT_CATEGORY_2";
            }
            else if (item.fnwTableName.Equals("MST_CHECKLIST_PERIOD"))
            {
                return @"SELECT MANUAL_NO_NAME 
                 FROM V_MST_CHECKLIST_PERIOD 
                 WHERE SUBSTR(DEVICE_TYPE_CD, 1, 1) = '0' 
                   AND DEL_FLG='0' 
                 GROUP BY MANUAL_NO_NAME, APPENDIX_NO_PERIOD, APPENDIX_NO_PARTS";
            }
            else if (IsSpecialViewerLayout(item))
            {
                return "select 1 from dual";
            }
            else
            {
                return $"select {(item.fkey == "PKEY" || item.fkey == "KEY" ? "*" : $" distinct {item.fkey} ")} from {item.fnwTableName}";
            }
        }

        /// <summary>
        /// 特殊レイアウトテーブル判定
        /// </summary>
        private bool IsSpecialViewerLayout(DgvPatRowDto item)
        {
            //mod 12612 患者カレンダーレイアウトマスタがコンバートされない start
            return (item.fnwTableName + "-" + item.ntssTableName).Equals("SYS_ACTCHART_DEFINE-mst_pat_viewer_layout")
                  || (item.fnwTableName + "-" + item.ntssTableName).Equals("DUAL-mst_pat_calendar_layout");
            //mod 12612　患者カレンダーレイアウトマスタがコンバートされない　 end
        }

        /// <summary>
        /// 指示履歴の件数を取得する
        /// </summary>
        private int CountIndicateHistory(
            Dictionary<string, string> dataType,
            Dictionary<string, string> selectType
        ) {
            int hisTotalRecord = 0;

            // SERIES_CD 条件生成
            string value = BuildSeriesValuebyType(dataType, selectType, CMB_SELECT_INDICATES_HISTORY);

            if (string.IsNullOrEmpty(value))
                return 0;

            // 指示履歴対象テーブル取得
            var hisSelected = GetSelectedTables(dataType, selectType.Keys.Contains(CMB_SELECT_INDICATES_HISTORY) ? CMB_SELECT_INDICATES_HISTORY : string.Empty);
            hisSelected = hisSelected.Where(item => item.type == CMB_SELECT_INDICATES_HISTORY).ToList();
            foreach (DgvPatRowDto item in hisSelected)
            {
                string hisSql = BuildIndicateHistorySql(value);

                // 件数取得
                hisTotalRecord = int.Parse(
                    db.SelectTable(hisSql).Rows[0]["COUNT"].ToString()
                );
            }

            return hisTotalRecord;
        }

        /// <summary>
        /// 指示履歴検索SQL生成
        /// </summary>
        private string BuildIndicateHistorySql(string value)
        {
            return $@"
            select count(1) as COUNT  
            from IND_DIALYSIS_CONFIRM_DETAIL a 
            INNER JOIN (
                SELECT DISTINCT PATID, SERIES_CD
                FROM (
                    SELECT PATID, FROM_SERIES_CD AS SERIES_CD
                    FROM SYS_PAT_MOVE_PLAN
                    UNION ALL
                    SELECT PATID, TO_SERIES_CD
                    FROM SYS_PAT_MOVE_PLAN
                    UNION ALL
                    SELECT PATID, SERIES_CD
                    FROM SYS_PAT_SERIES_FACILITY  
                    where MAIN_FLG='1'
                )
            ) S 
            ON S.PATID = a.PATID 
            and S.SERIES_CD IN ({value})  
            where DISP_FLG = '1'";
        }

        /// <summary>
        /// 装置記録情報の件数を取得
        /// </summary>
        private int CountMotionRecords(
            Dictionary<string, string> dataType,
            Dictionary<string, string> selectType,
            Dictionary<string, string> tableType
        )
        {
            string series = BuildSeriesValuebyType(dataType, selectType, CMB_SELECT_ALL_MNT_MOTION_RECORD);

            if (string.IsNullOrEmpty(series))
                return 0;

            int motionTotalRecord = 0;

            // 対象テーブルリスト取得
            List<string> sRows = GetMotionTargetTables(selectType, tableType);

            foreach (string row in sRows)
            {
                var param = db.GetIMakeSqlParameters();
                string value = BuildSeriesValue(row, dataType, tableType, param);

                // 対象テーブル展開
                List<string> targetTableList = GetTableList(row);
                targetTableList.Add(row);

                foreach (string target in targetTableList.Distinct())
                {
                    motionTotalRecord += CountMotionByTable(target, value, param);
                }
            }

            return motionTotalRecord;
        }
        
        /// <summary>
        /// 装置記録対象テーブル取得
        /// </summary>
        private List<string> GetMotionTargetTables(
            Dictionary<string, string> selectType,
            Dictionary<string, string> tableType
        )
        {
            List<string> sRows = new List<string>();
            
            if (selectType.Keys.Contains(CMB_SELECT_ALL_MNT_MOTION_RECORD))
            {
                sRows.AddRange(new[]
                {
                    "LOG_DEV_LOG",
                    "LOG_DEV_MENTE",
                    "LOG_MCN_MENTE"
                });
            }
            else
            {
                sRows.AddRange(tableType.Keys);
            }

            return sRows.Distinct().ToList();
        }

        /// <summary>
        /// 単一テーブルの装置記録件数取得
        /// </summary>
        private int CountMotionByTable(string tableName, string value, IMakeSqlParameters param1)
        {
            //mod #10418 start
            var param = db.GetIMakeSqlParameters();
            foreach (object obj in param1.GetParam())
            {
                dynamic p = obj;
                param.AddParam(p.ParameterName, p.Value);
            }
            //mod #10418 end
            string fromTableSql = MakeFromTable(tableName);

            string startDate = Convert.ToDateTime(
                _settingConvertForm.StartDate.Substring(0, 4) + "-" +
                _settingConvertForm.StartDate.Substring(4, 2) + "-" +
                _settingConvertForm.StartDate.Substring(6, 2)
            ).ToString("yyyy-MM-dd");

            string endDate = Convert.ToDateTime(
                _settingConvertForm.EndDate.Substring(0, 4) + "-" +
                _settingConvertForm.EndDate.Substring(4, 2) + "-" +
                _settingConvertForm.EndDate.Substring(6, 2)
            ).AddDays(1).ToString("yyyy-MM-dd");

            string swhere = tableName.Contains("LOG_MCN_MENTE")
                ? "and (PIPE_MEASURE_DATE IS NOT NULL or DILUTION_MEASURE_DATE IS NOT NULL)"
                : string.Empty;

            string sql;
            //mod #10418 start
            if (tableName.Contains("LOG_DEV_MENTE"))
            {
                sql = BuildLogDevMenteSql(fromTableSql, value);
            }
            else
            {
                sql = $@"
            SELECT COUNT(*) AS COUNT 
            FROM ({fromTableSql}) ldl 
            INNER JOIN MST_DEVICE d  
                ON ldl.DEVICE_NO = d.DEVICE_NO 
               AND d.SERIES_CD in ({value})  
            WHERE ldl.OCCUR_DATE <= :endDate 
              AND ldl.OCCUR_DATE > :startDate
              {swhere}";
            }
            param.AddParam(":endDate", endDate);
            param.AddParam(":startDate", startDate);
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10418 end
            return dt == null ? 0 : int.Parse(dt.Rows[0]["COUNT"].ToString());
        }
        /// <summary>
        /// LOG_DEV_MENTE用SQL生成
        /// </summary>
        private string BuildLogDevMenteSql(
            string fromTableSql,
            string value)
        {
            DataTable dt = db.SelectTable(
                $"select count(*) as COUNT from all_tab_columns " +
                $"where table_name='LOG_DEV_MENTE' " +
                $"and column_name='CCP_SELFDIAG_MEASURE_DATE'"
            );

            bool hasCcp = dt != null && int.Parse(dt.Rows[0]["COUNT"].ToString()) > 0;

            string baseSql = hasCcp
                ? @"WITH UFRC_DATE AS (
                SELECT * FROM ({0}) ldm WHERE UFRC_MEASURE_DATE IS NOT NULL
            ), LEAK_DATE AS (
                SELECT * FROM ({0}) ldm WHERE LEAK_MEASURE_DATE IS NOT NULL
            ), QD_DATE AS (
                SELECT * FROM ({0}) ldm WHERE QD_MEASURE_DATE IS NOT NULL
            ), DENSITY_DATE AS (
                SELECT * FROM ({0}) ldm WHERE DENSITY_MEASURE_DATE IS NOT NULL
            ), CCP_SELFDIAG_DATE AS (
                SELECT * FROM ({0}) ldm WHERE CCP_SELFDIAG_MEASURE_DATE IS NOT NULL
            )
            select COUNT(*) AS COUNT from(
                SELECT * FROM UFRC_DATE UNION ALL
                SELECT * FROM LEAK_DATE UNION ALL
                SELECT * FROM QD_DATE UNION ALL
                SELECT * FROM DENSITY_DATE UNION ALL
                SELECT * FROM CCP_SELFDIAG_DATE
            ) ldl"
                : @"WITH UFRC_DATE AS (
                SELECT * FROM ({0}) ldm WHERE UFRC_MEASURE_DATE IS NOT NULL
            ), LEAK_DATE AS (
                SELECT * FROM ({0}) ldm WHERE LEAK_MEASURE_DATE IS NOT NULL
            ), QD_DATE AS (
                SELECT * FROM ({0}) ldm WHERE QD_MEASURE_DATE IS NOT NULL
            ), DENSITY_DATE AS (
                SELECT * FROM ({0}) ldm WHERE DENSITY_MEASURE_DATE IS NOT NULL
            )
            select COUNT(*) AS COUNT from(
                SELECT * FROM UFRC_DATE UNION ALL
                SELECT * FROM LEAK_DATE UNION ALL
                SELECT * FROM QD_DATE UNION ALL
                SELECT * FROM DENSITY_DATE
            ) ldl";

            string sql = string.Format(baseSql, fromTableSql);
            //mod #10418 start
            sql += $@"
        INNER JOIN MST_DEVICE d  
            ON ldl.DEVICE_NO = d.DEVICE_NO 
           AND d.SERIES_CD in ({value})  
        WHERE ldl.OCCUR_DATE <=:startDate 
          AND ldl.OCCUR_DATE > :endDate";
            //mod #10418 end
            return sql;
        }

        /// <summary>
        /// 指示情報・実績情報の件数を取得
        /// </summary>
        private void CountPlanAndResult(
            Dictionary<string, string> dataType,
            Dictionary<string, string> selectType,
            out int indRecords,
            out int rstRecords
        )
        {
            indRecords = 0;
            rstRecords = 0;

            // SERIES_CD 条件生成
            string value = BuildSeriesValuebyType(dataType, selectType, CMB_SELECT_SPECIFY_PERIOD_PAT);

            if (string.IsNullOrEmpty(value))
                return;

            // 対象PATID取得
            List<string> patidWhere = GetTargetPatIds(value);

            // 1000件ずつ分割して検索
            CountPlanByChunk(patidWhere, ref indRecords);
            CountResultByChunk(patidWhere, ref rstRecords);
        }
        
        /// <summary>
        /// 対象PATID取得
        /// </summary>
        private List<string> GetTargetPatIds(string value)
        {
            List<string> patidWhere = new List<string>();

            if (IsConvertAll)
            {

                //add #10418 start
                var    param = db.GetIMakeSqlParameters();
                var seriesList = value
                 .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                 .Select(v => v.Trim().Trim('\''))
                 .Where(v => !string.IsNullOrEmpty(v))
                 .Distinct()
                 .ToList();
                List<string> paramNames = new List<string>();

                for (int i = 0; i < seriesList.Count; i++)
                {
                    string paramName = ":SERIES_CD_" + i;
                    paramNames.Add(paramName);
                    param.AddParam(paramName, seriesList[i]);
                }
                string inClause = string.Join(",", paramNames);
                //add #10418 end

                // 全件対象
                string sqlPat = $@"
            select distinct p.PATID 
            from PAT_BASIC_INFO p 
            INNER JOIN (
                SELECT DISTINCT PATID, SERIES_CD
                FROM (
                    SELECT PATID, FROM_SERIES_CD AS SERIES_CD FROM SYS_PAT_MOVE_PLAN
                    UNION ALL
                    SELECT PATID, TO_SERIES_CD FROM SYS_PAT_MOVE_PLAN
                    UNION ALL
                    SELECT PATID, SERIES_CD FROM SYS_PAT_SERIES_FACILITY where MAIN_FLG='1'
                )
            ) s 
            on s.PATID = p.PATID 
           and s.SERIES_CD in ({inClause})";

                var dtPat = db.SelectTable(sqlPat, param.GetParam());

                foreach (DataRow row in dtPat.Rows)
                {
                    patidWhere.Add($"{row[0]}");
                }
            }
            else
            {
                // 選択行のみ
                foreach (var facilityRows in _settingConvertForm.SelectedRowsByFacility.Values)
                {
                    foreach (var row in facilityRows)
                    {
                        if (row.TryGetValue("PATID", out var patid) && patid != null)
                        {
                            patidWhere.Add($"{patid}");
                        }
                    }
                }
            }

            return patidWhere;
        }
        /// <summary>
        /// 指示情報件数取得（分割処理）
        /// </summary>
        private void CountPlanByChunk(List<string> patidWhere, ref int indRecords)
        {
            double len = Math.Ceiling(patidWhere.Count / 1000.00);

            for (int i = 0; i < len; i++)
            {
                var batch = patidWhere.Skip(i * 1000).Take(999).ToList();
                //mod #10418 start 
                List<string> paramNames = new List<string>();
                var param = db.GetIMakeSqlParameters();
                param.AddParam(":EndDate", _settingConvertForm.EndDate);
                param.AddParam(":StartDate", _settingConvertForm.StartDate);
                for (int j = 0; j < batch.Count; j++)
                {
                    string paramName = ":PATID_" + j;
                    paramNames.Add(paramName);
                    param.AddParam(paramName, batch[j]);
                }
                string inClause = string.Join(",", paramNames);
                string sql = $@"
                    select count(*) as COUNT  
                    from SCH_DIALYSIS_PLAN 
                    where PATID in ({inClause}) 
                  and to_date(DIALYSIS_DATE, 'yyyyMMdd') <= to_date(:EndDate, 'yyyyMMdd') 
                  and to_date(DIALYSIS_DATE, 'yyyyMMdd') >= to_date(:StartDate, 'yyyyMMdd')"; 

                var dt = db.SelectTable(sql, param.GetParam());
                //mod #10418 end

                indRecords += dt == null ? 0 : int.Parse(dt.Rows[0]["COUNT"].ToString());
            }
        }
        /// <summary>
        /// 実績情報件数取得（分割処理）
        /// </summary>
        private void CountResultByChunk(List<string> patidWhere, ref int rstRecords)
        {
            double len = Math.Ceiling(patidWhere.Count / 1000.00);

            for (int i = 0; i < len; i++)
            {
                var batch = patidWhere.Skip(i * 1000).Take(999).ToList();
                //mod #10418 start 
                List<string> paramNames = new List<string>();
                var param = db.GetIMakeSqlParameters();
                param.AddParam(":EndDate", _settingConvertForm.EndDate);
                param.AddParam(":StartDate", _settingConvertForm.StartDate);
                for (int j = 0; j < batch.Count; j++)
                {
                    string paramName = ":PATID_" + j;
                    paramNames.Add(paramName);
                    param.AddParam(paramName, batch[j]);
                }
                string inClause = string.Join(",", paramNames);
                string sqlRST = $@"
                    select count(*) as COUNT  
                    from RST_DIALYSIS 
                    where PATID in ({inClause}) 
                  and to_char(START_DATE, 'yyyyMMdd') >= :StartDate 
                  and to_char(START_DATE, 'yyyyMMdd') <= :EndDate";
                var dtRST = db.SelectTable(sqlRST, param.GetParam());
                //mod #10418 end 
                rstRecords += dtRST == null ? 0 : int.Parse(dtRST.Rows[0]["COUNT"].ToString());
            }
        }
        /// <summary>
        /// コンバート対象情報
        /// </summary>
        private void ShowResult(
            int patTotalRecord,
            int mstTotalRecord,
            int indRecords,
            int rstRecords,
            int hisTotalRecord,
            int motionTotalRecord)
        {
            lstStatus.Items.Add($"患者情報　　： {patTotalRecord} 件");
            lstStatus.Items.Add($"マスタ情報　： {mstTotalRecord} 件");
            lstStatus.Items.Add($"指示情報　　： {indRecords} 件");
            lstStatus.Items.Add($"実績情報　　： {rstRecords} 件");
            lstStatus.Items.Add($"指示履歴　　： {hisTotalRecord} 件");
            lstStatus.Items.Add($"装置記録情報： {motionTotalRecord} 件");
        }
        // add #12484 コンバートツールで処理種別の除外ができない limingzhe end

        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 start
        /// <summary>
        /// テーブル名と開始日と終了日から
        /// テーブル名DB存在をチェックし、存在するテーブル名のリストを返す
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns></returns>
        public List<string> GetTableList(string tableName)
        {
            List<string> retList = new List<string>();
            string workStartDate = _settingConvertForm.StartDate.Substring(0, 6);
            string workEndDate = _settingConvertForm.EndDate.Substring(0, 6);
            //mod #10418 start
            string startTableName = $"{tableName}_{workStartDate}";
            string endTableName = $"{tableName}_{workEndDate}";
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":START_TABLE", startTableName);
            param.AddParam(":END_TABLE", endTableName);
            string sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME BETWEEN :START_TABLE AND :END_TABLE ORDER BY TABLE_NAME";
            DataTable dt = db.SelectTable(sql,param.GetParam());
            //mod #10418 end
            retList = dt.AsEnumerable().Select(r => r["TABLE_NAME"].ToString()).ToList<string>();
            return retList;
        }

        /// <summary>
        /// テーブル名をSQL句へ変換する
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns></returns>
        public string MakeFromTable(string tableName)
        {
            string ret = "SELECT * FROM " + tableName;
            return ret;
        }
        // add #7407 コンバートした施設で遠隔監視画面に過去の装置記録が表示されない 歴程 end


        // add 2020-12-16 FNSI-仕様修正 594 更新進捗イベントを変更します う start
        private void UpdateProgressBarBtn_Click1(object sender, EventArgs e)
        {
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
            updateProgressBarBtn.Enabled = false;
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl end
            //mod 7997 進捗バー修正 start 
            for (int j = 0; j < facilityAndSeries.Length; j++)
            {
                ShowProgressStart(true, Convert.ToString(facilityAndSeries[j]["FACILITY_CD"]));
            }
            //mod 7997 進捗バー修正 end 
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
            updateProgressBarBtn.Enabled = true;
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl end
        }
        // add 2020-12-16 FNSI-仕様修正 594 更新進捗イベントを変更します う start


        private void ShowProgress(int isAutoMode,string fCd)
        {

            //mod 7997 進捗バー修正 start 
            if (!progressBars.TryGetValue(fCd, out SafeProgressBar bar))
                    return;
            Task.Run(() => UpdateProgressForItem(fCd, bar, isAutoMode));
            //mod 7997 進捗バー修正 end 

        }
        //add 7997 進捗バー修正 start 
        private void UpdateProgressForItem(string item, SafeProgressBar bar, int isAutoMode)
        {

            int value = (isAutoMode == 2) ? 50 : 0;
            int showLineCount = 0;
            DateTime convertStartTime = DateTime.Now;

            IList<BatchConvertTableStatusDto> localStatusList = new List<BatchConvertTableStatusDto>();
            System.Timers.Timer timer = new System.Timers.Timer();
            bool timeOut = false;
            string orderNoStatus = "0";
            while (true)
            {
                localStatusList.Clear();
                this.getConvertTableStatus(item, ref localStatusList,ref orderNoStatus);

                if (localStatusList.Count > 0)
                {
                    var last = localStatusList[localStatusList.Count - 1];
                    string string_status = last.status;
                    string string_content = last.content;

                    if (!string.IsNullOrEmpty(string_status))
                    {
                        double[] element = Array.ConvertAll(string_status.Split('/'), s => double.Parse(s));
                        double display_value = 0;

                        if (element.Length >= 2 && element[0] != 0 && element[1] != 0)
                        {
                            display_value = ((double)element[0] / (double)element[1]) * 100;
                            int progress = value + (int)Math.Floor(display_value) / isAutoMode;
                            bar.Invoke(new Action(() =>
                            {
                                bar.Value =progress;
                            }));
                           
                            showTime(convertStartTime, (int)Math.Ceiling(display_value));
                        }
                    }
                    else
                    {
                        bar.Invoke(new Action(() =>
                        {
                            bar.Value = value + showLineCount / isAutoMode;
                        }));
                        showTime(convertStartTime, showLineCount);
                    }
                    if (string_content == "ジョブ正常終了")
                    {
                        lock (lockObj)
                        {
                            finishedFacilityCount += 1;
                        }
                        string nowTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                        ConvertBase.WriteTraceLog("送信終了時間：" + nowTime + "--------------------------------------------------");

                        bar.Invoke(new Action(() => { bar.Value = 100; }));
                        ShowConvertLogStop(last.facility_cd);
                        UpdateUIFromNonUIThread();
                        break;
                    }
                }
                else
                {
                    if (!timeOut)
                    {
                        timer.Interval = 50000;
                        timer.Elapsed += delegate
                        {
                            progressTimerCall(null, bar);
                            timer.Dispose();
                        };
                        timer.Start();
                        timeOut = true;
                    }
                }

                Thread.Sleep(5000);
            }
        }
        //add 7997 進捗バー修正 end

        // add #11859_7 limingyang start
        private void UpdateUIFromNonUIThread()
        {
            //add #7997 進捗バー 修正　start
            if (facilityAndSeries.Length != finishedFacilityCount  && CommonConfig.AUTOMATIC.Equals("1")) 
            {
                return;
            }
            //add 7997 進捗バー修正 end

            if (this.InvokeRequired)
            {
                this.Invoke(new Action(UpdateUIFromNonUIThread));
            }
            else
            {
                MessageBox.Show(this, "移行ジョブ正常終了", "通知", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }
        // mod #11859_7 limingyang end

       
        private void CONShowProgress(string facilityName, int isAutoMode)
        {
            //add 7997 進捗バー修正 start
            if (!progressBars.TryGetValue(facilityName, out SafeProgressBar bar))
                return;
            Task.Run(() =>
            {
                while (true)
                {
                    double ll = 0;
                    if (CommonConfig.allLen > 0)
                    {
                        ll = (CommonConfig.schLen * 1.0 / CommonConfig.allLen) * 100;
                        if (ll >= 100/isAutoMode && !CommonConfig.CONVEND[facilityName])
                            ll = 98/isAutoMode;
                    }

                    if (CommonConfig.CONVEND[facilityName])
                    {
                        ll = 100/isAutoMode;
                    }

                    int progressValue = (int)Math.Round(ll);


                    bar.BeginInvoke(new Action(() =>
                    {
                        bar.Value = Math.Min(bar.Maximum, Math.Max(bar.Minimum, progressValue));
                        ConshowTime(convertStartTime, facilityName);
                    }));

                    if (CommonConfig.CONVEND[facilityName])
                        break;

                    Thread.Sleep(1000);
                }
            });
            //add 7997 進捗バー修正 end
        }
        // add #8175 コンバートツールの予想完了日時が異常 歴程 start
        private void showTime(DateTime convertStartTime, int showLineCount)
        {
            DateTime currentTime = DateTime.Now;
            if (showLineCount <= 100)
            {   
                //add 7997 進捗バー修正 start
                if (showLineCount == 0)
                {
                    elapsedTimeLb.Invoke(new Action(() =>
                    {
                        elapsedTimeLb.Text = currentTime.AddSeconds(((currentTime - convertStartTime).TotalSeconds) * 100).ToString("yyyy/MM/dd HH:mm:ss");
                    }));
                }
                else
                {
                    elapsedTimeLb.Invoke(new Action(() =>
                    {
                        elapsedTimeLb.Text = currentTime.AddSeconds(((currentTime - convertStartTime).TotalSeconds / showLineCount) * (100 - showLineCount)).ToString("yyyy/MM/dd HH:mm:ss");
                    }));
                 //add 7997 進捗バー修正 end
                }
            }
        }
        //add 7997 進捗バー修正 start
        private void ConshowTime(DateTime convertStartTime,string facilityName)
        {
            string time = convertStartTime.AddSeconds(msPat * 0.02).AddSeconds(Monnum * 0.00063).AddSeconds(Indnum * 0.000083).AddMinutes(fmsPat * 0.01).ToString("yyyy/MM/dd HH:mm:ss");
            elapsedTimeLb.Text = time;
            if (DateTime.Now > Convert.ToDateTime(time))
            {
                elapsedTimeLb.Text = DateTime.Now.AddMinutes(2).ToString("yyyy/MM/dd HH:mm:ss");
            }
            if (CommonConfig.CONVEND[facilityName])
            {
                elapsedTimeLb.Text = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss");
            }
        }
        //add 7997 進捗バー修正 end
        // add #8175 コンバートツールの予想完了日時が異常 歴程 end

        private void progressTimerCall(object obj,SafeProgressBar bar)
        {
            //add 7997 進捗バー修正 start
            if (obj != null)
            {
                bar.EndInvoke((IAsyncResult)obj);
            }
            ShowProgressStop();
            //add 7997 進捗バー修正 end
        }

        Thread threadProgressBar = null;
        // add #8175 コンバートツールの予想完了日時が異常 歴程 start
        DateTime convertStartTime = DateTime.Now;
        // add #8175 コンバートツールの予想完了日時が異常 歴程 end
        public void ShowProgressStart(bool type,string FacilityCd)
        {
            //add 7997 進捗バー修正 start
            if (!progressBars.TryGetValue(FacilityCd, out SafeProgressBar bar))
                return;
           
            int isAutoMode = 1;
            if (type)
            {
                isAutoMode = 2;
                bar.Value = 50;
            }
            else 
            {
                bar.Value = 0;
            }
           
            threadProgressBar = new Thread(() =>
            {
                ShowProgress(isAutoMode, FacilityCd);
            });
            //add 7997 進捗バー修正 end
            threadProgressBar.Name = "ShowConvertProgress";
            threadProgressBar.IsBackground = true;
            threadProgressBar.Start();
            threadProgressBar.DisableComObjectEagerCleanup();        
        }

        public void ShowProgressStop()
        {
            if (threadProgressBar != null && threadProgressBar.ThreadState != System.Threading.ThreadState.Aborted && threadProgressBar.ThreadState != System.Threading.ThreadState.Stopped)
            {
                // mod ProgressBarの修正 楊 start
                //threadProgressBar.Join();
                threadProgressBar.Abort();
                threadProgressBar.Join();
                // mod ProgressBarの修正 楊 end
                Thread.EndThreadAffinity();
                threadProgressBar.DisableComObjectEagerCleanup();
            }
            else
            {
                threadProgressBar.DisableComObjectEagerCleanup();
            }
        }


        private readonly object progressLock = new object();
        private void getConvertTableStatus(string facilitycd,
               ref IList<BatchConvertTableStatusDto> batchConvertTableStatusDtoList,ref string orderNoStatus)
        {
            string url = NKSConverter.Properties.Settings.Default.ConvertRestTableStatusUrlFormat;
                IList<BatchConvertTableStatusDto> addList =
                    HttpControl.getBatchConvertTableStatus(url, facilitycd, orderNoStatus);

                if (addList != null && addList.Count > 0)
                {
                    var newList = addList
                        .OrderBy(t => t.order_no)
                        .ToList();

                    orderNoStatus = newList.Last().order_no.ToString();

                    batchConvertTableStatusDtoList =
                        batchConvertTableStatusDtoList
                            .Union(newList)
                            .ToList();
                }  
            
        }



        delegate void AddItemCallback(ListBox listBoxMsg, string text);
        private void LBAddItem(ListBox listBoxMsg, string text)
        {
            bool scroll = false;
            if (listBoxMsg.TopIndex == listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight))
                scroll = true;
            if (listBoxMsg.InvokeRequired)
            {
                AddItemCallback d = new AddItemCallback(LBAddItem);
                this.Invoke(d, new object[] { listBoxMsg, text });
            }
            else
            {
                listBoxMsg.Items.Add(text);
            }
            if (scroll)
                listBoxMsg.TopIndex = listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight);
        }

        private void ShowUpdateLog(string FacilityCd)
        {
            bool timeOut = false;
            System.Timers.Timer timer = new System.Timers.Timer();
             //add #7997 進捗バー 修正　start
            // add ログ出力修正 楊 start
           IList<BatchConvertTableLogDto> batchConvertTableLogDtoList = new List<BatchConvertTableLogDto>();
            // add ログ出力修正 楊 end
            int _lastShownLogIndex = 0;
            string orderNo = "0";
            //add #7997 進捗バー 修正　end
            while (true)
            {
                
                IAsyncResult result = lstLog.BeginInvoke(new Action(() =>
                {
                     //add #7997 進捗バー 修正　start
                     this.getConvertTableLog(FacilityCd, ref batchConvertTableLogDtoList,ref orderNo);
                     //add #7997 進捗バー 修正　start
                    int showLineCount = lstLog.Items.Count;
                    for (int i = _lastShownLogIndex; i < batchConvertTableLogDtoList.Count; i++)
                    {
                        // mod 10859_6 OrdMaterialSaveにログ追加 hyl start
                        BatchConvertTableLogDto item = batchConvertTableLogDtoList[i];
                        if (item.content .Contains("ord_materail_save")) 
                        {
                            LBAddItem(lstLog, "「" + item.facility_cd + "」"+item.reg_date + " : table " + item.content);
                        }
                        else{
                            LBAddItem(lstLog, "「" + item.facility_cd + "」" + item.reg_date + " : table " + item.table_name + " 移行" + item.content);
                        }   
                        // mod 10859_6 OrdMaterialSaveにログ追加 hyl end
                    }
                    _lastShownLogIndex = batchConvertTableLogDtoList.Count;
                }));
                if (batchConvertTableLogDtoList.Count > 0)
                {
                    timer.Stop();
                    timeOut = false;
                    string stopShowMsg = batchConvertTableLogDtoList[batchConvertTableLogDtoList.Count - 1].content;
                    // add FNSI-FNSI-ジョブ実行修正 楊 start
                    if (stopShowMsg == "ジョブ正常終了")
                    // add FNSI-FNSI-ジョブ実行修正 楊 end
                    {
                        timer.Dispose();
                        lstLog.EndInvoke(result);
                        ShowConvertLogStop(FacilityCd);
                        break;
                    }
                }
                else
                {
                    if (timeOut == false)
                    {
                        timer.Interval = 50000;

                        timer.Elapsed += delegate
                        {
                            timerCall(result, FacilityCd);
                            timer.Dispose();
                        };
                        timer.Start();
                    }
                }
                // add ログ出力修正 楊 start
                Thread.Sleep(5000);
                // add ログ出力修正 楊 end
            }
        }

        private void timerCall(object obj,string facilityCd)
        {
            if (obj != null)
            {
                lstLog.EndInvoke((IAsyncResult)obj);
            }
            ShowConvertLogStop(facilityCd);
        }

        //add 7997 進捗バー修正 start 
        private Dictionary<string, Thread> threadConvertLogs = new Dictionary<string, Thread>();
        public void ShowConvertLogStart(string facilityCd)
        {

            Thread thread = null;
            if (!threadConvertLogs.TryGetValue(facilityCd, out thread)
               || thread == null
               || thread.ThreadState == System.Threading.ThreadState.Aborted
               || thread.ThreadState == System.Threading.ThreadState.Stopped)
            {
                thread = new Thread(() =>
                {
                    ShowUpdateLog(facilityCd);
                });

                thread.Name = "ShowConvertLog_" + facilityCd;
                thread.IsBackground = true;

                threadConvertLogs[facilityCd] = thread;

                thread.Start();
            }
        }

        public void ShowConvertLogStop(string facilityCd)
        {
            Thread threadConvertLog = null;
            if (threadConvertLogs.TryGetValue(facilityCd, out threadConvertLog)) {

                return;
            }
            if (threadConvertLog != null && threadConvertLog.ThreadState != System.Threading.ThreadState.Aborted && threadConvertLog.ThreadState != System.Threading.ThreadState.Stopped)
            {
                // mod ログ出力修正 楊 start
                //threadConvertLog.Join();
                threadConvertLog.Abort();
                threadConvertLog.Join();
                // mod ログ出力修正 楊 end
                Thread.EndThreadAffinity();
                threadConvertLog.DisableComObjectEagerCleanup();
            }
            else
            {
                if (threadConvertLog != null)
                {
                    threadConvertLog.DisableComObjectEagerCleanup();
                }
            }
        }
        //add 7997 進捗バー修正 end 

        // mod 2020-11-25 FNSI-仕様修正 594 進捗のステータスであれば、メイン画面のログに表示させたい。 う start 
        private void UpdateLogBtn_Click1(object sender, EventArgs e)
        {
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
            updateLogBtn.Enabled = false;
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl end
            //add 7997 進捗バー修正 start 
            for (int j = 0; j < facilityAndSeries.Length; j++)
            {
                ShowConvertLogStart(Convert.ToString(facilityAndSeries[j]["FACILITY_CD"]));
            }
            //add 7997 進捗バー修正 end 
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
            updateLogBtn.Enabled = true;
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl end
        }
        // mod 2020-11-25 FNSI-仕様修正 594 進捗のステータスであれば、メイン画面のログに表示させたい。 う end  

        private void getConvertTableLog(string fCd, ref IList<BatchConvertTableLogDto> batchConvertTableLogDtoList,ref  string orderNo)
        {
            string url = NKSConverter.Properties.Settings.Default.ConvertRestTableLogUrlFormat;
            string facilityCd = string.Empty;
            if(CommonConfig.HashValueSet.TryGetValue(fCd, out var value))
            {
                facilityCd = $"[\"{value}\"]";
                
            }
            IList<BatchConvertTableLogDto> addList = HttpControl.getBatchConvertTableLog(url, orderNo, facilityCd);

            if (null != addList && addList.Count > 0)
            {
                var newlist = (from BatchConvertTableLogDto t in addList
                               orderby t.order_no
                               select t).ToList();

                orderNo = newlist.Last().order_no;

                batchConvertTableLogDtoList = batchConvertTableLogDtoList.Union(newlist).ToList<BatchConvertTableLogDto>();

            }
            // add ログ出力修正 楊 end
        }

        private void RetryOpenSettingForm(int retryCount = 3)
        {
            try
            {
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う start
                //_settingConvertForm.Show();
                this.BeginInvoke(new Action(() =>
                {
                    _settingConvertForm.Show();
                }));
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う end
            }
            catch
            {
                if (retryCount <= 0)
                    return;
                Thread.Sleep(300);
                retryCount -= 1;

                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う start
                //await RetryOpenSettingForm(retryCount);
                this.BeginInvoke(new Action(() =>
                {
                    RetryOpenSettingForm(retryCount);
                }));
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う end
            }
        }

        private void BtnConvert_Click(object sender, EventArgs e)
        {

            if (facilityAndSeries.Length != CommonConfig.SelectedTypeByFacility.Keys.Count)
            {
                ShowMsgBoxWarning("まだ施設が未確認です");
                return;
            }
            // Add #7997 趙 Start
            _settingConvertForm.loopKbn = null;
            _settingConvertForm.cancelKbn = false;
            if (0 == facilityAndSeries.Length)
            {
                ShowMsgBoxWarning("施設コードを選択してください。");
                return;
            }
            //#10840  COP_EVENT_MANAGEの最新連携種別を取得する start
            //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
            cs.GetRenkeiType("透析実績,患者情報受信,バイタル送信,透析レポート");
            //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
            //10840  COP_EVENT_MANAGEの最新連携種別を取得する end

            //add #12229 start
              ConvertTss.Initialize(db);
            //add #12229 end
            //mod 7997 進捗バー修正 start
            CommonConfig.dtSeriesCdAndFacilityCdSet = new HashSet<string>();
            //mod 7997 進捗バー修正 end
            //add 11161  start
            checkAutomatic.Enabled = false;
            if (CommonConfig.AUTOMATIC.Equals("1"))
            {
                bakFiles();
            }
            //add 11161  end
            UploadForm uploadForm = new UploadForm();
            uploadForm.Owner = this;
            for (int j = 0; j < facilityAndSeries.Length; j++)
            {
                //add 9688 start
                cs.SetMEDICINELATESTNO(Convert.ToString(facilityAndSeries[j]["SERIES_CD"]));
                //add  9688 end
                int result = (int)Math.Floor(100.0 / facilityAndSeries.Length);
                int maxResult = result * (j + 1);

                // キャンセルの場合、次の処理行う。
                if (_settingConvertForm.cancelKbn)
                    break;
 
                TextBox txtFacilityCdValue = new TextBox();
                txtFacilityCdValue.Text = Convert.ToString(facilityAndSeries[j]["FACILITY_CD"]);
                _settingConvertForm.txtFacilityCd = txtFacilityCdValue;
                //add 7997 start
                CommonConfig.FacilityCd = txtFacilityCdValue.Text;
                if (CommonConfig.HashValueSet.ContainsKey(txtFacilityCdValue.Text.ToString()))
                {
                    CommonConfig.HashValue ="["+ CommonConfig.HashValueSet[txtFacilityCdValue.Text]+"]";
                }
               
                //add 7997 end
                TextBox txtSeriesCdValue = new TextBox();
                txtSeriesCdValue.Text = Convert.ToString(facilityAndSeries[j]["SERIES_CD"]);
                _settingConvertForm.txtSeriesCd = txtSeriesCdValue;
                CommonConfig.seriesCd = txtSeriesCdValue.Text;
                // メッセージの出力の設定
                // 1件の場合
                if (1 == facilityAndSeries.Length)
                {
                    _settingConvertForm.loopKbn = "1";
                }
                else
                {
                    // 複数件の場合、１件目の場合
                    if (j == 0)
                    {
                        _settingConvertForm.loopKbn = "0";
                    }
                    // 複数件の場合、最後件目の場合
                    else if (j == facilityAndSeries.Length - 1)
                    {
                        _settingConvertForm.loopKbn = "2";
                    }
                    else
                    {
                        _settingConvertForm.loopKbn = "3";
                    }
                }
               
                _settingConvertForm._lbSQLFileBuildStatus = this.lstLog;
                //add 9815 zc start
                //mod  7997  進行状況バーの修正 start 
                CommonConfig.CONVEND[txtFacilityCdValue.Text] = false;
                
                getCONShowProgress(txtFacilityCdValue.Text);
                //mod  7997  進行状況バーの修正 end 
                //add 9815 zc end
                // add FNSI_全ての初期化追加 楊 end

                //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
                CommonConfig.appStartTime = DateTime.Now;
                //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end
                string  type=CommonConfig.SelectedTypeByFacility[txtSeriesCdValue.Text] ;
                if (!type.Contains("すべて"))
                //if (_settingConvertForm.cmb_select.SelectedIndex > 0)
                {
                   
                    _settingConvertForm.BtnConvertCall();
                }
                else
                {
                    BtnConvertAllTable_Click(null, null);
                }
                WaitingForm waitingForm = new WaitingForm();
                waitingForm.Show();
                Application.DoEvents();
                // #9814 limingyang start
                // ファイルをアップロードする
                string url = NKSConverter.Properties.Settings.Default.ConvertLogFileUploadUrlFormat;
                url = string.Format(url,
                    CommonConfig.ConvertRestWebServerIp,
                     CommonConfig.ConvertRestWebServerPort
                    );
                string strfolder = AppDomain.CurrentDomain.BaseDirectory;
                strfolder += "LOG\\";
                // ログファイルを圧縮する
                ZipLogFiles(strfolder);

                List<string> uploadFiles = new List<string>();

                // ログファイル格納先に格納されている圧縮ファイルを全て取得する
                string[] logfiles = System.IO.Directory.GetFiles(strfolder, "*.ZIP", System.IO.SearchOption.TopDirectoryOnly);


                string facilityCd = string.Empty;
                if (CommonConfig.HashValueSet.TryGetValue(facilityAndSeries[j]["FACILITY_CD"].ToString(), out var value))
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

                    this.BeginInvoke(new Action(() =>
                    {
                        string msg = FileUploadControl.MultipartPostResquest(url, parameters);
                        // アップロード結果判定
                        if ("Log uploaded successfully".Equals(msg))
                        {
                            // 成功
                            // アップロード対象のログファイルを削除
                            System.IO.File.Delete(strfile);
                        }
                    }));
                }
                // #9814 limingyang end
                waitingForm.Close();

                //add 7997  start
                if (CommonConfig.AUTOMATIC.Equals("1") && CommonConfig.RUN && CommonConfig.LoginUrl != null) {

                    string facilityCds = CommonConfig.FacilityCd;
                    Task.Run(() =>
                    {
                        uploadForm.facilityCd = facilityCds;
                        uploadForm.UploadFiles(facilityCds);
                        CommonConfig.dtSeriesCdAndFacilityCdSet.Add(facilityCds);
                        uploadForm.ExecuteJob();

                        this.BeginInvoke(new Action(() =>
                        {
                            //add #7997 進捗バー 修正　start
                            ShowConvertLogStart(facilityCds);
                            ShowProgressStart(true, facilityCds);
                            //add #7997 進捗バー 修正　end
                        }));
                    });

                }
               
                CommonConfig.CONVEND[txtFacilityCdValue.Text] = true;
                CommonConfig.schLen = 0;
                //add  7997 進行状況バーの修正 end
            }
            //add #7997 start
            CommonConfig.SelectedTypeByFacility.Clear();
            _settingConvertForm.SelectedRowsByFacility.Clear();
            //_settingConvertForm.setSeriesCd(null);
            //add #7997 end
            // Add #7340 PC側アプリの出力が遅い 趙 Start
            GC.Collect();
            GC.WaitForPendingFinalizers();
            if (Environment.OSVersion.Platform == PlatformID.Win32NT)
            {
                SetProcessWorkingSetSize(Process.GetCurrentProcess().Handle, -1, -1);
            }
            // Add #7340 PC側アプリの出力が遅い 趙 End

          
            checkAutomatic.Enabled = true;
            //add 11161  end

            //add 7997 strt
            CacheInformation.Instance.RefreshAllTableKind();
            //add  7997 strt
        }
        public class WaitingForm : Form
        {
            public WaitingForm()
            {
                InitializeForm();
            }

            public void InitializeForm()
            {
                Label label = new Label();
                label.TabIndex = 0;
                label.Text = "ログファイルをアップロードしています";
                label.AutoSize = true;
                label.BringToFront();
                label.Visible = true;
                label.Dock = DockStyle.Fill;
                label.TextAlign = ContentAlignment.MiddleCenter;
                label.Padding = new Padding(10);
                label.ForeColor = Color.Red;
                int labelWidth = label.PreferredWidth + 20;
                int labelHeight = label.PreferredHeight + 20;
                this.ClientSize = new Size(labelWidth, labelHeight);

                this.Text = "少々お待ちください";
                this.FormBorderStyle = FormBorderStyle.FixedDialog;
                this.StartPosition = FormStartPosition.CenterScreen;
                this.ControlBox = false;
                
                this.Controls.Add(label);
            }
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
                ConvertBase.WriteErrorLog("ZipLogFiles1:{0}", ex.Message);
                bret = false;
            }
            return (bret);
        }

        private void ConvertForm_Load(object sender, EventArgs e)
        {
            bool isDBSuccessFnw = DBConnectFnw();
            if (isDBSuccessFnw == false)
            {
                ShowMsgBoxError("DB接続に失敗しました。\nFNW+DBに接続できる環境で使用してください。");
                Close();
                return;
            }
        }

        private void BtnSetting_Click(object sender, EventArgs e)
        {
            //add 11161 start
            _settingConvertForm.IsUserClose= false;
            //add 11161 end
            //add 8431 zc start
            if (0 == facilityAndSeries.Length)
            {
                ShowMsgBoxWarning("施設コードを選択してください。");
                return;
            }
            //if (dtSeriesCdAndFacilityCdList.Select("FACILITY_CD is null").Length > 0)
            //{
            //    ShowMsgBoxWarning("選択したレコードの施設コードを入力してください。");
            //    return;
            //}
            //add 8431 zc end
            IsConvertAll = false;
           
            //_settingConvertForm.cmbSeriesCd = cmbSeriesCd;
            _settingConvertForm.VisibleChanged -= new EventHandler(SettingConvertForm_VisibleChanged);
            _settingConvertForm.VisibleChanged += new EventHandler(SettingConvertForm_VisibleChanged);

            
            //add #7997 start
            CommonConfig.seriesCd = null;
            

            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl start
            //add 7997 start
            if (CommonConfig.SelectedTypeByFacility.Keys.Count==0) {
                _settingConvertForm.Reload();
            }
            //add 7997 end
            _settingConvertForm.ShowDialog();
            _settingConvertForm.BringToFront();
            //add 10859_7 処理が開始されたら、ボタンを非活性にすること。 hyl end
        }

        private void SettingConvertForm_VisibleChanged(object sender, EventArgs e)
        {
            if (!_settingConvertForm.Visible && !_settingConvertForm.IsUserClose)
                ConvertInfoUpdatebtn_Click(null, null);
        }
        private void SettingConvertForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            
        }

        private void ShowMsgBoxError(string msg)
        {
            MessageBox.Show(msg, "", MessageBoxButtons.OK, MessageBoxIcon.Stop);
        }

        #endregion

        #region Initial Form

        private void InitForm()
        {
            DBConnectFnw();
            DBConnectFnsi();
            InitSettingForm();
            if (db != null)
            {
                this.FNW_Status.BackColor = Color.Green;
            }
            else
            {
                this.FNW_Status.BackColor = Color.Red;
            }

            //add  11161 start
            getAUTOMATIC();
            //add  11161 end
        }
        //add  11161 start
        private void getAUTOMATIC() {
            string sql = "select AUTOMATIC from SYNC_CONDSET";
            DataTable dt = db.SelectTable(sql);
            if (dt.Rows[0]["AUTOMATIC"].ToString().Equals("1"))
            {
                    checkAutomatic.Checked = true;
            }
             CommonConfig.AUTOMATIC = dt.Rows[0]["AUTOMATIC"].ToString();    
        }

        //add  11161 end

        private void InitSettingForm()
        {
            _settingConvertForm = new MainForm();
            // Del #7997 趙 Start
            //_settingConvertForm.txtFacilityCd = txtFacilityCd;
            // Del #7997 趙 End
            //_settingConvertForm.cmbSeriesCd = cmbSeriesCd;
            _settingConvertForm.Show();
            _settingConvertForm.FormClosing += new FormClosingEventHandler(SettingConvertForm_FormClosing);
            _settingConvertForm.Hide();
            _settingConvertForm.IsInit = true;
        }

        private bool DBConnectFnw()
        {
            db = ConvertControl.DBConnectFnw();
            if (db == null)
            {
                this.FNW_Status.Text = "FNW DB接続状態：NG";
                return false;
            }

            this.FNW_Status.Text = "FNW DB接続状態：OK";
            return true;
        }

        private void DBConnectFnsi()
        {
            string url = NKSConverter.Properties.Settings.Default.ConvertRestCheckConnection;
           
            if (HttpControl.isFNsiConnection(url))
            {
                FNSi_Status.Text = "FNSi 接続状態：OK";
                FNSi_Status.BackColor = Color.Green;
            }
            else
            {
                FNSi_Status.Text = "FNSi 接続状態：NG";
                FNSi_Status.BackColor = Color.Red;
            }
        }
     
        #endregion

        private List<DgvPatRowDto> GetDTOFromDgvSelectedRow(Dictionary<string, string> dataType)
        {
            var list = new List<DgvPatRowDto>();
            // mod FNSI-指示履歴の修正 楊 start
            //if (dataType.Equals(CMB_SELECT_ALL_RECORD_MST, StringComparison.InvariantCultureIgnoreCase) || dataType.Equals(CMB_SELECT_ALL_RECORD_PAT, StringComparison.InvariantCultureIgnoreCase))
            //if (dataType.Equals(CMB_SELECT_ALL_RECORD_MST, StringComparison.InvariantCultureIgnoreCase) || dataType.Equals(CMB_SELECT_ALL_RECORD_PAT, StringComparison.InvariantCultureIgnoreCase) || dataType.Equals(CMB_SELECT_INDICATES_HISTORY, StringComparison.InvariantCultureIgnoreCase))
            // mod FNSI-指示履歴の修正 楊 end
            if (
                    dataType.ContainsKey(CMB_SELECT_ALL_RECORD_MST)
                 || dataType.ContainsKey(CMB_SELECT_ALL_RECORD_PAT)
                 || dataType.ContainsKey(CMB_SELECT_INDICATES_HISTORY)
)
            {
                // del #12484 コンバートツールで処理種別の除外ができない limingzhe start
                //if (IsConvertAll)
                //{
                //    var selectedRows = dgv.Rows;
                //    foreach (DataGridViewRow row in selectedRows)
                //    {
                //        DgvPatRowDto dto = new DgvPatRowDto()
                //        {
                //            fnwTableName = dgv["table", row.Index].Value.ToString(),
                //            ntssTableName = dgv["ntssTable", row.Index].Value.ToString(),
                //            type = dgv["type", row.Index].Value.ToString(),
                //            fkey = dgv["fkey", row.Index].Value.ToString()
                //        };

                //        list.Add(dto);
                //    }
                //}
                //else
                //{
                // del #12484 コンバートツールで処理種別の除外ができない limingzhe end
                    
                    foreach (var facilityItem in _settingConvertForm.SelectedRowsByFacility)
                    {
                        foreach (var row in facilityItem.Value)
                        {
                            var dto = new DgvPatRowDto
                            {
                                fnwTableName = row.TryGetValue("table", out var fnw) ? fnw?.ToString() : null,
                                ntssTableName = row.TryGetValue("ntssTable", out var ntss) ? ntss?.ToString() : null,
                                type = row.TryGetValue("type", out var t) ? t?.ToString() : null,
                                fkey = row.TryGetValue("fkey", out var fk) ? fk?.ToString() : null
                            };

                            list.Add(dto);
                        }
                    }
                   
                    //var selectedRows = dgv.SelectedRows;
                    //foreach (DataGridViewRow row in selectedRows)
                    //{
                    //    DgvPatRowDto dto = new DgvPatRowDto()
                    //    {
                    //        fnwTableName = dgv["table", row.Index].Value.ToString(),
                    //        ntssTableName = dgv["ntssTable", row.Index].Value.ToString(),
                    //        type = dgv["type", row.Index].Value.ToString(),
                    //        fkey = dgv["fkey", row.Index].Value.ToString()
                    //    };

                    //    list.Add(dto);
                    //}
                // del #12484 コンバートツールで処理種別の除外ができない limingzhe start
                //}
                // del #12484 コンバートツールで処理種別の除外ができない limingzhe end
            }
            // 行の選択順で並びが変わるのでソート
            //var sortedList = list.OrderBy(x => x.ntssTableName)
            //    .ThenBy(x => x.fnwTableName)
            //    .ToList();
            var sortedList = list
                       .Where(x => x != null)
                       .GroupBy(x => new
                       {
                           x.fnwTableName,
                           x.ntssTableName,
                           x.type,
                           x.fkey
                       })
                       .Select(g => g.First()).OrderBy(x => x.ntssTableName)
               .ThenBy(x => x.fnwTableName)
               .ToList();
            return sortedList;
        }

        private void ConvertForm_FormClosing(object sender, FormClosingEventArgs e)
        { 
            Settings.Default.Save();
            CommonConfig.token = null;
            CommonConfig.LoginUrl= null;
            Environment.Exit(0);
        }
        // Add #7997 趙 Start
        /// <summary>
        /// データテーブルの設定
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        public void SetSeriesCdAndFacilityCdToDataTable()
        {
            
            // 検索SQL文の書く
            StringBuilder builder = new StringBuilder();
            builder.Append(" SELECT 'データ移行元施設コード' AS SERIES, S1.SERIES_CD,'データ移行先施設コード' AS FACILITY ,FACILITY_CD,'コンバータによるスケジュール延長状態：' AS STATE ");
            builder.Append(" FROM SYNC_FACILITY_CD S1 ");
            builder.Append(" ORDER BY S1.SERIES_CD ");

            // 系列施設マスタテーブル取得
            dtSeriesCdAndFacilityCdList = db.SelectTable(builder.ToString());
            if (dtSeriesCdAndFacilityCdList.Rows.Count == 0)
            {
                DataRow newRow = dtSeriesCdAndFacilityCdList.NewRow();
                newRow["SERIES"] = "データ移行元施設コード";
                newRow["SERIES_CD"] = "001";
                newRow["FACILITY"] = "データ移行先施設コード";
                newRow["FACILITY_CD"] = "";
                newRow["STATE"] = "コンバータによるスケジュール延長状態：";
                dtSeriesCdAndFacilityCdList.Rows.Add(newRow);
            }

            // ディフォルト1件目は選択の状態です。
           
            int y = 12;
            string url = NKSConverter.Properties.Settings.Default.ConvertgetMstFacilityUrlFormat;
            string valueString = Newtonsoft.Json.JsonConvert.SerializeObject(CommonConfig.HashValueSet.Values);
            Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", valueString } };
            string response = HttpControl.sendWebRequestPost(url, parameters);
            string flag =string.Empty;
            List<MstFacilityDto> mf = new List<MstFacilityDto>();
            if (!string.IsNullOrEmpty(response)) {
                 mf = JsonConvert.DeserializeObject<List<MstFacilityDto>>(response);
                
            }
            panelFacilityCdList.Controls.Clear();
            for (int j = 0; j < dtSeriesCdAndFacilityCdList.Rows.Count; j++)
            {
                if (mf.Count>0 && j< mf.Count) {
                    flag = mf[j].isSchextException;
                }
                int x = 20;
               
               

                // データ移行元施設コード
                Label labelGen = new Label();
                labelGen.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["SERIES"]);
                x = x + 17;
                labelGen.Location = new Point(x, y);
                labelGen.Size = new Size(160, 14);
                labelGen.Name = "SERIES" + j;
                labelGen.TextAlign = ContentAlignment.MiddleCenter;

                // 元施設コード
                TextBox textBoxGen = new TextBox();
                textBoxGen.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["SERIES_CD"]);
                textBoxGen.Enabled = false;
                x = x + 162;
                textBoxGen.Location = new Point(x, y);
                textBoxGen.Size = new Size(100, 14);
                textBoxGen.Name = "SERIES_CD" + j;

                // データ移行先施設コード
                Label labelSaki = new Label();
                labelSaki.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["FACILITY"]);
                x = x + 105;
                labelSaki.Location = new Point(x, y);
                labelSaki.Size = new Size(160, 14);
                labelSaki.Name = "FACILITY" + j;
                labelSaki.TextAlign = ContentAlignment.MiddleCenter;

                // 先施設コード
                TextBox textBoxSaki = new TextBox();
                textBoxSaki.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["FACILITY_CD"]);
                //textBoxSaki.Text = CommonConfig.FacilityCd;
                textBoxSaki.ReadOnly = true;
                textBoxSaki.Enabled = true;
                textBoxSaki.Enabled = true;
                x = x + 162;
                textBoxSaki.Location = new Point(x, y);
                textBoxSaki.Size = new Size(100, 14);
                textBoxSaki.Name = "FACILITY_CD" + j;
                //textBoxSaki.LostFocus += new EventHandler(FACILITY_CD_LostFocus);





                // コンバータによるスケジュール延長状態
                Label labelState = new Label();
                labelState.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["STATE"]);
                x = x + 105;
                labelState.Location = new Point(x, y);
                labelState.Size = new Size(220, 14);
                labelState.Name = "STATE" + j;
                labelState.TextAlign = ContentAlignment.MiddleCenter;

               
                // 先施設コード
                TextBox textBoxState = new TextBox();
                textBoxState.ReadOnly = true;
                if (flag.Equals("1"))
                {
                    textBoxState.Text = "実行";
                    textBoxState.BackColor = Color.Green;
                }
                else if(flag.Equals("0"))
                {
                    textBoxState.Text = "停止";
                    textBoxState.BackColor = Color.Red;
                }
                textBoxState.BorderStyle = BorderStyle.None;

                x = x + 220;
                textBoxState.Location = new Point(x, y);
                textBoxState.Size = new Size(35, 14);
                textBoxState.Name = "STATE" + j;
               

                // 追加
            
                panelFacilityCdList.Controls.Add(labelGen);
                panelFacilityCdList.Controls.Add(textBoxGen);
                panelFacilityCdList.Controls.Add(labelSaki);
                panelFacilityCdList.Controls.Add(textBoxSaki);

                panelFacilityCdList.Controls.Add(labelState);
                if (!string.IsNullOrEmpty(flag))
                {
                    panelFacilityCdList.Controls.Add(textBoxState);
                }
                
                y += 23;
            }
            
        }

       

        /// <summary>
        /// テーブルSYNC_FACILITY_CDに反映
        /// </summary>
        public void setFacilityCd(string facilityCd)
        {
            TextBox txtFacilityCdValue = new TextBox();
            txtFacilityCdValue.Text = facilityCd;
            if (_settingConvertForm.IsDisposed)
            {
                _settingConvertForm = new MainForm();
                _settingConvertForm.MainForm_Load();
            }
            _settingConvertForm.txtFacilityCd = txtFacilityCdValue;
        }

        public void getCONShowProgress(string facilityName)
        {
            //mod  #7997 進行状況バーの修正 start
            if (!progressBars.TryGetValue(facilityName, out SafeProgressBar bar))
                return;
            bar.Value = 0;

            int isAutoMode = 1;
            if (CommonConfig.AUTOMATIC.Equals("1") && FNSi_Status.BackColor == Color.Green) {
                isAutoMode = 2;
            }
            if (threadProgressBar == null || threadProgressBar.ThreadState == System.Threading.ThreadState.Aborted || threadProgressBar.ThreadState == System.Threading.ThreadState.Stopped)
            {
                threadProgressBar = new Thread(() =>
                {
                    CONShowProgress(facilityName, isAutoMode);
                });
                //mod  #7997 進行状況バーの修正 end
                threadProgressBar.Name = "ShowConvertProgress";
                threadProgressBar.IsBackground = true;
                threadProgressBar.Start();
            }
        }

        private void ExtendButton_Click(object sender, EventArgs e)
        {
            SetSeriesCdAndFacilityCdToDataTable();
            ExtendedManagement em = new ExtendedManagement(this);
            em.ShowDialog();
        }
       
        // Add #7997 趙 End

        //add 11161 start
        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            string Sql = "update SYNC_CONDSET set AUTOMATIC=:automatic";
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            int automatic = 0;
            if (checkAutomatic.Checked)
            {
                automatic = 1;
            }
            param.AddParam("automatic", automatic);
            db.SelectTable(Sql, param.GetParam());
            CommonConfig.AUTOMATIC = automatic.ToString();
        }
        //add  11161 end
    }
}
