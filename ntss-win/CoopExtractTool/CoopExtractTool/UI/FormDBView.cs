using CoopExtractTool.Datas;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using System.Text.RegularExpressions;
using System.Runtime.InteropServices;
using System.Security;
using System.Text;
using System.Threading.Tasks;

namespace CoopExtractTool
{

    public partial class FormDBView : Form
    {
        /// <summary>
        /// 施設のドロップダウンのデータ用クラス
        /// </summary>
        class FacilityItem
        {
            public string SERIES_CD { get; set; }
            public string SHORT_NAME { get; set; }

            public FacilityItem(string cd, string name)
            {
                SERIES_CD = cd;
                SHORT_NAME = name;
            }
        }

        /// <summary>
        /// FNSiカルテ種別のドロップダウンのデータ用クラス
        /// </summary>
        class MappingFileItem
        {
            public string FileName { get; set; }
            public string FilePath { get; set; }

            public MappingFileItem(string name, string path)
            {
                FileName = name;
                FilePath = path;
            }
        }

        /// <summary>
        /// データグリッドビューに表示される内容
        /// </summary>
        private List<DBDataItem> ViewDBDataList;

        /// <summary>
        /// カルテの一覧（マッピングファイルの一覧）に表示される内容リスト
        /// </summary>
        private List<MappingFileItem> MappingFileItemList;

        /// <summary>
        /// 現在の画面表示モード
        /// </summary>
        private viewModeValue viewMode = viewModeValue.FirstView;
        enum viewModeValue
        {
            FirstView,    // 画面初期表示
            ErrorView,    // エラー表示
            NextView,    // 次画面遷移可能状態
        }

        /// <summary>
        /// 施設に表示される内容リスト
        /// </summary>
        private List<FacilityItem> FacilityList;

        /// <summary>
        /// マッピング処理のタイプ
        /// </summary>
        enum MappingType
        {
            Section = 1,
            Key = 2,
        }

        /// <summary>
        /// 部分一致置換用のデータ
        /// </summary>
        Dictionary<string, string> tempMapValue = new Dictionary<string, string>();
        int counterValue = 0;
        Dictionary<string, string> tempMapDefault_v = new Dictionary<string, string>();
        int counterDefault_v = 0;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FormDBView()
        {
            InitializeComponent();
        }

        /// <summary>
        /// フォームロード時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormDBView_Load(object sender, EventArgs e)
        {
            // 画面タイトルをセット
            var versionInfo = FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location);
            string version = versionInfo.FileVersion;
            this.Text = string.Format("{0}({1}) FNW連携設定情報", Commons.AppName, version);


            ViewDBDataList = new List<DBDataItem>();

            BindingSource source = new BindingSource();
            source.DataSource = ViewDBDataList;
            dgvDBView.DataSource = source;

            dgvDBView.Columns["INI_CLASS"].Width = 80;
            dgvDBView.Columns["INI_SECTION"].Width = 250;
            dgvDBView.Columns["INI_KEY"].Width = 150;
            dgvDBView.Columns["UP_DATE"].Width = 150;
            dgvDBView.Columns["SECTION_TITLE"].Width = 200;
            dgvDBView.Columns["KEY_TITLE"].Width = 200;
            dgvDBView.Columns["INI_VALUE"].Width = 100;
            dgvDBView.Columns["DEFAULT_VALUE"].Width = 100;
            dgvDBView.Columns["MEMO"].Width = 200;
            //dgvDBView.Columns["SERIES_CD"].Width = 80;
            dgvDBView.Columns["SHORT_NAME"].Width = 150;

            if (DBDataManager.DBDataList.Count == 0)
            {
                MessageBox.Show("FNWのDBの読み込み結果が0件でした。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                viewMode = viewModeValue.ErrorView;
                ViewUpdate();
                return;
            }

            // 施設の一覧を作成
            FacilityList = new List<FacilityItem>();
            foreach (DBFacilityDataItem item in DBDataManager.DBFacilityList)
            {
                FacilityList.Add(new FacilityItem(item.SERIES_CD, item.SHORT_NAME));
            }

            if (FacilityList.Count == 0)
            {
                MessageBox.Show("FNWのDBに施設が登録されていません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                viewMode = viewModeValue.ErrorView;
                ViewUpdate();
                return;
            }

            FacilityList.Insert(0, new FacilityItem("", ""));   // 先頭に追加
            cmbFacility.DataSource = FacilityList;
            cmbFacility.DisplayMember = "SHORT_NAME";
            cmbFacility.ValueMember = "SERIES_CD";
            cmbFacility.SelectedIndex = 0;


            // ---------------------------------------------------
            // カルテの一覧（マッピングファイルの一覧）を作成
            // ---------------------------------------------------
            MappingFileItemList = new List<MappingFileItem>();

            // EXEと同じ場所のパスを取得
            string exePath = AppDomain.CurrentDomain.BaseDirectory;
            string targetFolder = Path.Combine(exePath, "MappingXML");

            if (Directory.Exists(targetFolder))
            {
                string[] xmlFiles = Directory.GetFiles(targetFolder, "*.xml");

                foreach (string file in xmlFiles)
                {
                    MappingFileItemList.Add(new MappingFileItem(Path.GetFileNameWithoutExtension(file), file));
                }
            }

            if (MappingFileItemList.Count == 0)
            {
                MessageBox.Show("MappingXMLファイルが見つかりませんでした。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                viewMode = viewModeValue.ErrorView;
                ViewUpdate();
                return;
            }

            MappingFileItemList.Insert(0, new MappingFileItem("", ""));   // 先頭に追加
            cmbMapping.DataSource = MappingFileItemList;
            cmbMapping.DisplayMember = "FileName";
            cmbMapping.ValueMember = "FilePath";
            cmbMapping.SelectedIndex = 0;

            viewMode = viewModeValue.FirstView;
            ViewUpdate();

            // 画面の準備が整ったのでイベントを登録
            this.cmbFacility.SelectedIndexChanged += new System.EventHandler(this.cmbFacility_SelectedIndexChanged);
            this.cmbMapping.SelectedIndexChanged += new System.EventHandler(this.cmbMapping_SelectedIndexChanged);
        }

        /// <summary>
        /// 最初からボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnBeginning_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// フォームが閉じられようとしたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormDBView_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (e.CloseReason == CloseReason.UserClosing)
            {
                if (this.DialogResult != DialogResult.OK && this.DialogResult != DialogResult.Cancel)
                {
                    // ×ボタンで閉じようとしたときの処理
                    this.DialogResult = DialogResult.No;
                }
            }
        }

        /// <summary>
        /// 画面表示更新処理
        /// </summary>
        private void ViewUpdate()
        {
            if (viewMode == viewModeValue.FirstView)
            {

                grpFacility.Enabled = true;
                grpMapping.Enabled = true;
                grpDBView.Enabled = true;
                btnNext.Enabled = false;
            }
            else if (viewMode == viewModeValue.ErrorView)
            {
                grpFacility.Enabled = false;
                grpMapping.Enabled = false;
                grpDBView.Enabled = false;
                btnNext.Enabled = false;
            }
            else if (viewMode == viewModeValue.NextView)
            {
                grpFacility.Enabled = true;
                grpMapping.Enabled = true;
                grpDBView.Enabled = true;
                btnNext.Enabled = true;
            }
        }

        /// <summary>
        /// FNW対象施設の選択変更時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmbFacility_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(cmbFacility.SelectedValue.ToString()) == false &&
                string.IsNullOrEmpty(cmbMapping.SelectedValue.ToString()) == false)
            {
                viewMode = viewModeValue.NextView;
                ViewUpdate();
            }
            else
            {
                viewMode = viewModeValue.FirstView;
                ViewUpdate();
            }

            if (string.IsNullOrEmpty(cmbFacility.SelectedValue.ToString()) == false)
            {
                string facility = cmbFacility.SelectedValue.ToString();

                ViewDBDataList.Clear();
                foreach (DBDataItem item in DBDataManager.DBDataList)
                {
                    if (item.SERIES_CD == "all")
                    {
                        // allで対象施設のレコードを発見した
                        if (DBDataManager.DBDataList.FindIndex(d =>
                            d.INI_CLASS == item.INI_CLASS &&
                            d.INI_SECTION == item.INI_SECTION &&
                            d.INI_KEY == item.INI_KEY &&
                            d.SERIES_CD == facility
                            ) >= 0)
                        {
                            // 対象施設のSERIES_CDを指定したデータがある場合
                            continue;
                        }
                    }
                    else if (item.SERIES_CD != facility)
                    {
                        // 別の施設の場合
                        continue;
                    }

                    try
                    {
                        // 同一でより新しいレコードを発見した
                        if (DBDataManager.DBDataList.FindIndex(d =>
                            d.INI_CLASS == item.INI_CLASS &&
                            d.INI_SECTION == item.INI_SECTION &&
                            d.INI_KEY == item.INI_KEY &&
                            d.SERIES_CD == item.SERIES_CD &&
                            DateTime.Parse(d.UP_DATE) > DateTime.Parse(item.UP_DATE)
                            ) >= 0)
                        {
                            continue;
                        }
                    }
                    catch { }  // Parseをしているので念のために

                    try
                    {
                        // 同一UP_DATEのレコードを発見した場合（ないと思うけど念のため）
                        if (ViewDBDataList.FindIndex(d =>
                            d.INI_CLASS == item.INI_CLASS &&
                            d.INI_SECTION == item.INI_SECTION &&
                            d.INI_KEY == item.INI_KEY &&
                            d.SERIES_CD == item.SERIES_CD &&
                            DateTime.Parse(d.UP_DATE) == DateTime.Parse(item.UP_DATE)
                            ) >= 0)
                        {
                            continue;
                        }
                    }
                    catch { }  // Parseをしているので念のために

                    ViewDBDataList.Add(item);
                }

                BindingSource source = new BindingSource();
                source.DataSource = ViewDBDataList;
                dgvDBView.DataSource = source;
            }
            else
            {
                ViewDBDataList.Clear();
                BindingSource source = new BindingSource();
                source.DataSource = ViewDBDataList;
                dgvDBView.DataSource = source;
            }

        }

        /// <summary>
        /// FNSiカルテ種別の選択変更時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmbMapping_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(cmbFacility.SelectedValue.ToString()) == false &&
                string.IsNullOrEmpty(cmbMapping.SelectedValue.ToString()) == false)
            {
                viewMode = viewModeValue.NextView;
                ViewUpdate();
            }
            else
            {
                viewMode = viewModeValue.FirstView;
                ViewUpdate();
            }
        }

        /// <summary>
        /// FNSi連携設定項目への変換ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnNext_Click(object sender, EventArgs e)
        {

            string mappingFilePath = cmbMapping.SelectedValue.ToString();

            // Mapping設定ファイルを読み込む
            var ret = MappingSettingManager.ReadXML(mappingFilePath);
            if (ret == Commons.RetCode_Nothing)
            {
                MessageBox.Show(cmbMapping.Text + "のXMLファイルがMappingXMLフォルダ内に見つかりませんでした。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            else if (ret == Commons.RetCode_Error)
            {
                MessageBox.Show(Path.GetFileName(mappingFilePath) + "の読み込み中にエラーが発生しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // -------------------------------------------
            // ログ出力
            // -------------------------------------------

            // EXEと同じ場所のパスを取得
            string exePath = AppDomain.CurrentDomain.BaseDirectory;
            string logRootPath = Path.Combine(exePath, "Log");
            // フォルダが存在しない場合は作成
            if (!Directory.Exists(logRootPath))
            {
                Directory.CreateDirectory(logRootPath);
            }

            // 現在の日時を取得してフォルダ名に変換
            string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            string logFolderPath = Path.Combine(logRootPath, timestamp);
            // フォルダが存在しない場合は作成
            if (!Directory.Exists(logFolderPath))
            {
                Directory.CreateDirectory(logFolderPath);
            }

            // マッピングXMLファイルをログとしてコピー
            string xmlFileName = Path.GetFileName(mappingFilePath);
            string xmlFilePath = Path.Combine(logFolderPath, xmlFileName);
            // ファイルをコピー（上書き許可）
            File.Copy(mappingFilePath, xmlFilePath, overwrite: true);

            // クエリ結果をログとして保存
            string queryResultPath = Path.Combine(logFolderPath, "QueryResult.txt");
            using (var writer = new StreamWriter(queryResultPath))
            {
                foreach (DBDataItem item in DBDataManager.DBDataList)
                {
                    string line = "";
                    line += GetQueryResult("", item.INI_CLASS) + ",";
                    line += GetQueryResult("", item.INI_SECTION) + ",";
                    line += GetQueryResult("", item.INI_KEY) + ",";
                    line += GetQueryResult("TIMESTAMP", item.UP_DATE) + ",";
                    line += GetQueryResult("", item.SECTION_TITLE) + ",";
                    line += GetQueryResult("", item.KEY_TITLE) + ",";
                    line += GetQueryResult("", item.DATA_TYPE) + ",";
                    line += GetQueryResult("", item.INI_VALUE) + ",";
                    line += GetQueryResult("", item.MAX_VALUE) + ",";
                    line += GetQueryResult("", item.MIN_VALUE) + ",";
                    line += GetQueryResult("", item.DEFAULT_VALUE) + ",";
                    line += GetQueryResult("", item.MEMO) + ",";
                    line += GetQueryResult("", item.SERIES_CD);
                    writer.WriteLine(line);
                }
            }

            // -------------------------------------------
            // マッピングしてCSV結果のデータ生成
            // -------------------------------------------
            CSVDataManager.CSVDataList = new List<CSVDataItem>();

            // 変換結果をログとして保存
            string convertLogPath = Path.Combine(logFolderPath, "ConvertLog.txt");
            using (var writer = new StreamWriter(convertLogPath, false, new UTF8Encoding(true))) //UTF8(BOM付き)
            {
                writer.WriteLine(GetLogValue("変換日時:" + timestamp));
                writer.WriteLine(GetLogValue("FNW対象施設:" + cmbFacility.Text + "(SERIES_CD:" + cmbFacility.SelectedValue + ")"));
                writer.WriteLine(GetLogValue("FNSiカルテ種別:" + cmbMapping.Text));

                writer.WriteLine("INI_CLASS,INI_SECTION,INI_KEY,UP_DATE,SECTION_TITLE,KEY_TITLE,INI_VALUE,DEFAULT_VALUE,MEMO,SERIES_CD,→,key0,key1,key2,value,comment,default_v");

                foreach (DataGridViewRow row in dgvDBView.Rows)
                {
                    // 一行ずつデータを取り出す
                    DBDataItem dataItem = (DBDataItem)row.DataBoundItem;

                    // 取り出した一行のデータに変換処理を行う
                    CSVDataItem addItem;
                    MappingFunc(cmbMapping.Text, dataItem, out addItem);

                    // CSV結果の一行を追加
                    CSVDataManager.CSVDataList.Add(addItem);

                    // ログを一行出力
                    string line = "";
                    line += GetLogValue(dataItem.INI_CLASS) + ",";
                    line += GetLogValue(dataItem.INI_SECTION) + ",";
                    line += GetLogValue(dataItem.INI_KEY) + ",";
                    DateTime dateTime;
                    string tmp = dataItem.UP_DATE;
                    if (DateTime.TryParse(dataItem.UP_DATE, out dateTime) == true)
                    {
                        // DateTimeに変換が成功したら
                        tmp = dateTime.ToString("yyyy/MM/dd HH:mm:ss");
                    }
                    line += GetLogValue(tmp) + ",";
                    line += GetLogValue(dataItem.SECTION_TITLE) + ",";
                    line += GetLogValue(dataItem.KEY_TITLE) + ",";
                    line += GetLogValue(dataItem.INI_VALUE) + ",";
                    line += GetLogValue(dataItem.DEFAULT_VALUE) + ",";
                    line += GetLogValue(dataItem.MEMO) + ",";
                    line += GetLogValue(dataItem.SERIES_CD) + ",";
                    line += GetLogValue("→") + ",";
                    line += GetLogValue(addItem.key0) + ",";
                    line += GetLogValue(addItem.key1) + ",";
                    line += GetLogValue(addItem.key2) + ",";
                    line += GetLogValue(addItem.value) + ",";
                    line += GetLogValue(addItem.comment) + ",";
                    line += GetLogValue(addItem.default_v);

                    writer.WriteLine(line);
                }

                CSVDataManager.key0 = cmbMapping.Text;
            }

            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// QueryResultのログ出力文字を取得
        /// </summary>
        /// <param name="prefix"></param>
        /// <param name="value"></param>
        private string GetQueryResult(string prefix, string value)
        {
            string tmp = value;

            if (prefix != "")
            {
                if (tmp == null)
                {
                    return string.Format(" {0} NULL", prefix, tmp);
                }
                else
                {
                    if (prefix == "TIMESTAMP")
                    {
                        DateTime dateTime;
                        if(DateTime.TryParse(tmp, out dateTime) == true)
                        {
                            // DateTimeに変換が成功したら
                            tmp = dateTime.ToString("yyyy-MM-dd HH:mm:ss.ffffff");
                        }
                    }

                    tmp = tmp.Replace("\'", "\'\'");

                    return string.Format(" {0} \'{1}\'", prefix, tmp);
                }
            }
            else
            {
                if (tmp == null)
                {
                    return " NULL ";
                }
                else
                {
                    tmp = tmp.Replace("\'", "\'\'");

                    return string.Format(" \'{0}\'", tmp);
                }
            }
        }


        private string GetLogValue(string value)
        {
            if (value == null)
            {
                return "\"\"";
            }
            else {
                return "\"" + value.Replace("\"", "\"\"") + "\"";
            }
        }

        /// <summary>
        /// 変換（マッピング）処理を実施する
        /// </summary>
        /// <param name="key0"></param>
        /// <param name="dataItem"></param>
        /// <param name="addItem"></param>
        private void MappingFunc(string key0, DBDataItem dataItem, out CSVDataItem addItem)
        {
            addItem = null;

            if (MappingSettingManager.Data.Include != null)
            {
                // 変換設定 key1とkey2に対応する変換を行う　<Include><Individual>の設定
                if (MappingCondition(MappingType.Key, MappingSettingManager.Data.Include.Individual, key0, dataItem, out addItem) == Commons.RetCode_Success)
                {
                    // 変換成功したので抜ける
                    return;
                }
            }

            if (MappingSettingManager.Data.Exclude != null)
            {
                // 除外設定 key1とkey2に対応する変換を行う　<Exclude><Individual>の設定
                if (MappingCondition(MappingType.Key, MappingSettingManager.Data.Exclude.Individual, key0, dataItem, out addItem) == Commons.RetCode_Success)
                {
                    addItem.isExclude = true;
                    // 変換成功したので抜ける
                    return;
                }
            }

            if (MappingSettingManager.Data.Include != null)
            {
                // 変換設定 key1に対応する変換を行う　<Include><Section>の設定
                if (MappingCondition(MappingType.Section, MappingSettingManager.Data.Include.Section, key0, dataItem, out addItem) == Commons.RetCode_Success)
                {
                    // 変換成功したので抜ける
                    return;
                }
            }

            if (MappingSettingManager.Data.Exclude != null)
            {
                // 除外設定 key1に対応する変換を行う　<Exclude><Section>の設定
                if (MappingCondition(MappingType.Section, MappingSettingManager.Data.Exclude.Section, key0, dataItem, out addItem) == Commons.RetCode_Success)
                {
                    addItem.isExclude = true;
                    // 変換成功したので抜ける
                    return;
                }
            }

            // 変換されなかった場合は元データをそのまま出力する
            addItem = new CSVDataItem();
            addItem.key0 = key0;
            addItem.key1 = dataItem.INI_SECTION;
            addItem.key2 = dataItem.INI_KEY;
            addItem.comment = dataItem.KEY_TITLE + " " + dataItem.MEMO;
            addItem.value = dataItem.INI_VALUE;
            addItem.default_v = dataItem.DEFAULT_VALUE;
        }

        /// <summary>
        /// 設定単位で変換を実施
        /// </summary>
        /// <param name="mappingType"></param>
        /// <param name="conditionItem"></param>
        /// <param name="key0"></param>
        /// <param name="dataItem"></param>
        /// <param name="addItem"></param>
        /// <returns></returns>
        private int MappingCondition(MappingType mappingType, ConditionItem conditionItem, string key0, DBDataItem dataItem, out CSVDataItem addItem)
        {
            addItem = null;

            if(conditionItem == null)
            {
                // 設定がない場合
                return Commons.RetCode_Nothing;
            }

            // 設定の中から今の変換対象のデータに一致する変換設定を取得する
            int index = -1;
            if (mappingType == MappingType.Key)
            {
                index = conditionItem.Items.FindIndex(d => d.INI_SECTION == dataItem.INI_SECTION && d.INI_KEY == dataItem.INI_KEY);
            }
            if (mappingType == MappingType.Section)
            {
                index = conditionItem.Items.FindIndex(d => d.INI_SECTION == dataItem.INI_SECTION);
            }

            if (index == -1)
            {
                // 設定がみつからなかった場合
                return Commons.RetCode_Nothing;
            }

            Item item = conditionItem.Items[index];
            addItem = new CSVDataItem();

            // ------------------------
            // Key0
            // ------------------------
            addItem.key0 = key0;

            // ------------------------
            // Key1
            // ------------------------
            if (string.IsNullOrEmpty(item.Key1) == false)
            {
                addItem.key1 = item.Key1;
            }
            else
            {
                // 設定がない場合
                addItem.key1 = dataItem.INI_SECTION;
            }

            // ------------------------
            // Key2
            // ------------------------
            if (string.IsNullOrEmpty(item.Key2) == false)
            {
                addItem.key2 = item.Key2;
            }
            else
            {
                // 設定がない場合
                addItem.key2 = dataItem.INI_KEY;
            }

            // ------------------------
            // comment
            // ------------------------
            if (string.IsNullOrEmpty(dataItem.KEY_TITLE) == false && string.IsNullOrEmpty(dataItem.MEMO) == false)
            {
                // 両方に有効な文字列がある場合は半角スペースで連結する
                addItem.comment = dataItem.KEY_TITLE + " " + dataItem.MEMO;
            }
            else
            {
                addItem.comment = dataItem.KEY_TITLE + dataItem.MEMO;
            }

            // ------------------------
            // value　default_v
            // ------------------------
            bool isSetValue = false;
            bool isSetDefault_v = false;

            tempMapValue = new Dictionary<string, string>();
            counterValue = 0;
            tempMapDefault_v = new Dictionary<string, string>();
            counterDefault_v = 0;

            string value = dataItem.INI_VALUE;
            if (value == null) value = "";
            string default_v = dataItem.DEFAULT_VALUE;
            if (default_v == null) default_v = "";

            //--------------------------
            // 個別リストからの変換
            //--------------------------
            if (item.LocalList != null)
            {
                // 個別のリストがある場合
                foreach (ValueMappingList list in item.LocalList)
                {
                    if (isSetValue == false)
                    {
                        if (MappingValue(false, list, value, out value) == true)
                        {
                            // 変換された場合
                            if (list.Type != "1")
                            {
                                // 部分一致ではない場合
                                isSetValue = true;
                            }
                        }
                    }

                    if (isSetDefault_v == false)
                    {
                        if (MappingValue(true, list, default_v, out default_v) == true)
                        {
                            // 変換された場合
                            if (list.Type != "1")
                            {
                                // 部分一致ではない場合
                                isSetDefault_v = true;
                            }
                        }
                    }

                    if (isSetValue == true && isSetDefault_v == true)
                    {
                        break;
                    }
                }
            }

            //--------------------------
            // 共通リストからの変換
            //--------------------------
            if ((isSetValue == false || isSetDefault_v == false) &&
                string.IsNullOrEmpty(item.PublicList) == false)
            {
                // 変換可能な値と、共有の変換リストの設定がある場合

                int listpos = MappingSettingManager.Data.PublicValueMappingList.FindIndex(d => d.Name == item.PublicList);
                if (listpos >= 0)
                {
                    // 共通リストを発見
                    ValueMappingList list = MappingSettingManager.Data.PublicValueMappingList[listpos];

                    if (isSetValue == false)
                    {
                        if (MappingValue(false, list, value, out value) == true)
                        {
                            // 変換された場合
                            if (list.Type != "1")
                            {
                                // 部分一致ではない場合
                                isSetValue = true;
                            }
                        }
                    }

                    if (isSetDefault_v == false)
                    {
                        if (MappingValue(true, list, default_v, out default_v) == true)
                        {
                            // 変換された場合
                            if (list.Type != "1")
                            {
                                // 部分一致ではない場合
                                isSetDefault_v = true;
                            }
                        }
                    }
                }
            }

            // 部分一致用のマーカーを最終文字列に置換
            foreach (var kvp in tempMapValue)
            {
                value = value.Replace(kvp.Key, kvp.Value);
            }
            addItem.value = value;

            foreach (var kvp in tempMapDefault_v)
            {
                default_v = default_v.Replace(kvp.Key, kvp.Value);
            }
            addItem.default_v = default_v;

            return Commons.RetCode_Success;
        }

        /// <summary>
        /// valueの変換を行う（default_vも共用）
        /// </summary>
        /// <param name="isDefault"></param>
        /// <param name="list"></param>
        /// <param name="inValue"></param>
        /// <param name="mapValue"></param>
        /// <returns></returns>
        private bool MappingValue(bool isDefault, ValueMappingList list,string inValue, out string mapValue)
        {
            mapValue = inValue;

            if (list.Type == "1")
            {
                // 部分一致の場合
                foreach (ValueMappingListItem valueitem in list.ValueList)
                {
                    if (valueitem.Before == null || valueitem.After == null) continue;

                    //mapValue = mapValue.Replace(valueitem.Before, valueitem.After);

                    if (isDefault == false)
                    {
                        bool replaced = false;
                        string marker = $"\a__MARKER_{counterValue}__\a";
                        string pattern = @"(\a.*?\a)|" + Regex.Escape(valueitem.Before);

                        // \aで囲まれた部分以外を置換
                        mapValue = Regex.Replace(mapValue, pattern,
                            m =>
                            {
                                // \aで囲まれている部分はそのまま
                                if (m.Value.StartsWith("\a") && m.Value.EndsWith("\a"))
                                    return m.Value;

                                // それ以外を置換
                                replaced = true;
                                return marker;
                            });

                        if (replaced)
                        {
                            tempMapValue[marker] = valueitem.After;
                            counterValue++;
                        }
                    }
                    else
                    {
                        bool replaced = false;
                        string marker = $"\a__MARKER_{counterDefault_v}__\a";
                        string pattern = @"(\a.*?\a)|" + Regex.Escape(valueitem.Before);

                        // \aで囲まれた部分以外を置換
                        mapValue = Regex.Replace(mapValue, pattern,
                            m =>
                            {
                                // \aで囲まれている部分はそのまま
                                if (m.Value.StartsWith("\a") && m.Value.EndsWith("\a"))
                                    return m.Value;

                                // それ以外を置換
                                replaced = true;
                                return marker;
                            });

                        if (replaced)
                        {
                            tempMapDefault_v[marker] = valueitem.After;
                            counterDefault_v++;
                        }
                    }
                }                
            }
            else
            {
                // 完全一致の場合
                foreach (ValueMappingListItem valueitem in list.ValueList)
                {
                    if (valueitem.Before == null || valueitem.After == null) continue;

                    if (valueitem.Before == "*" || mapValue == valueitem.Before)
                    {
                        mapValue = valueitem.After;
                        return true;    // 完全一致は一つでも一致したら変換完了とするためtrueで抜ける
                    }
                }
            }

            return false;
        }
        
    }
}
