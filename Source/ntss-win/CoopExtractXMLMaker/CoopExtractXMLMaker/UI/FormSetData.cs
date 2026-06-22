using CsvHelper;
//using System.Text.Json;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace CoopExtractXMLMaker
{
    public partial class FormSetData : Form
    {
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FormSetData()
        {
            InitializeComponent();

            // 画面右下のリサイズグリップを表示
            this.SizeGripStyle = SizeGripStyle.Show;

            chkJson.Checked = false;
            txtJson.Enabled = false;

            // 起動時は「デフォルト定義ファイルからXMLを新規作成」にチェックする
            rdoFromDefinition.Checked = true;
            //txtFNWCsvPath.Text = @"C:\Users\hirotaka.akita\Documents\fnw_22.csv";
            txtFNSiCsvPath.Text = "";
            chkJson.Checked = false;
            txtJson.Text = "";
            txtXMLReeditPath.Text = "";
        }

        /// <summary>
        /// フォームロード時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormSetData_Load(object sender, EventArgs e)
        {
            // 画面タイトルをセット
            var versionInfo = FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location);
            string version = versionInfo.FileVersion;
            this.Text = string.Format("{0}({1}) 設定値読み込み", Commons.AppName, version);
        }

        /// <summary>
        /// 「次へ」ボタン押下
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnNext_Click(object sender, EventArgs e)
        {
            string strFNWCsvPath = txtFNWCsvPath.Text;
            string strFNSiCsvPath = "";
            string strJson = "";
            string strXMLReeditPath = "";

            // ----------------------------------------
            // 入力チェック
            // ----------------------------------------
            if (string.IsNullOrEmpty(strFNWCsvPath) == true)
            {
                MessageBox.Show("FNWのCSVファイルが指定されていません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (File.Exists(strFNWCsvPath) == false)
            {
                MessageBox.Show("FNWのCSVファイルが存在しません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (chkJson.Checked == false)
            {
                strFNSiCsvPath = txtFNSiCsvPath.Text;

                if (string.IsNullOrEmpty(strFNSiCsvPath) == true)
                {
                    MessageBox.Show("FNSiのCSVファイルが指定されていません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                if (File.Exists(strFNSiCsvPath) == false)
                {
                    MessageBox.Show("FNSiのCSVファイルが存在しません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }
            else
            {
                strJson = txtJson.Text;

                if (string.IsNullOrEmpty(strJson) == true)
                {
                    MessageBox.Show("FNSiのJSONが未入力です。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            // モードの選択状態を保持 モードによってはファイルの存在チェック
            if (rdoFromDefinition.Checked == true)
            {
                // デフォルト定義ファイルからXMLを新規作成

                ConfigSettingManager.Data.ConversionDefinition = ConversionDefinitionType.FromDefinition;

                // 自動マッピングON
                ConfigSettingManager.Data.AutoMapping = true;

                string strExeDir = AppDomain.CurrentDomain.BaseDirectory;
                strXMLReeditPath = Path.Combine(strExeDir, "DefaultDefinition.xml");

                if (File.Exists(strXMLReeditPath) == false)
                {
                    MessageBox.Show("デフォルト定義ファイルが存在しないため、自動マッピングのみを実行します。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
            else if (rdoXMLReedit.Checked == true)
            {
                // XMLを再編集

                ConfigSettingManager.Data.ConversionDefinition = ConversionDefinitionType.XMLReedit;

                // 自動マッピングOFF
                ConfigSettingManager.Data.AutoMapping = false;

                strXMLReeditPath = txtXMLReeditPath.Text;

                if (string.IsNullOrEmpty(strXMLReeditPath) == true)
                {
                    MessageBox.Show("再編集するXMLファイルが指定されていません。	", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                if (File.Exists(strXMLReeditPath) == false)
                {
                    MessageBox.Show("再編集するXMLファイルが存在しません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                // XMLファイルのパスを保持する
                ConfigSettingManager.Data.XMLReeditFilePath = strXMLReeditPath;
            }
            else
            {
                // デフォルト定義ファイルを修正

                ConfigSettingManager.Data.ConversionDefinition = ConversionDefinitionType.OverwriteDefaultDefinition;

                // 自動マッピングOFF
                ConfigSettingManager.Data.AutoMapping = false;

                string strExeDir = AppDomain.CurrentDomain.BaseDirectory;
                strXMLReeditPath = Path.Combine(strExeDir, "DefaultDefinition.xml");

                if (File.Exists(strXMLReeditPath) == false)
                {
                    MessageBox.Show("デフォルト定義ファイルが存在しないため、新規作成します。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }

            // ----------------------------------
            // FNWのデータの読み込み
            // ----------------------------------
            FNWDataManager.FNWDataList = new List<FNWDataItem>();
            ConversionFNWDataManager.ConversionFNWDataList = new BindingList<ConversionFNWDataItem>();

            // CSVファイルの読み込み
            using (var reader = new StreamReader(strFNWCsvPath, Encoding.UTF8))
            using (var csv = new CsvReader(reader))
            {
                try
                {
                    var records = csv.GetRecords<FNWDataItem>();

                    foreach (var record in records)
                    {
                        FNWDataManager.FNWDataList.Add(record);
                    }
                }
                catch
                {
                    MessageBox.Show("FNWのCSVファイルの読み込みに失敗しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            // ソートする
            //FNWDataManager.FNWDataList.Sort(FNWDataManager.CompareFNWData);
            FNWDataManager.FNWDataList.Sort(new ComparerFNWData());

            // ----------------------------------
            // FNSiのデータの読み込み
            // ----------------------------------
            if (chkJson.Checked == false)
            {
                // CSVファイルの読み込み
                using (var reader = new StreamReader(strFNSiCsvPath, Encoding.UTF8))
                using (var csv = new CsvReader(reader))
                {
                    try
                    {
                        var records = csv.GetRecords<FNSiDataItem>();

                        foreach (var record in records)
                        {
                            strJson = record.coop_ini_info;
                            break; // 一件目だけ取得
                        }
                    }
                    catch
                    {
                        MessageBox.Show("FNSiのCSVファイルの読み込みに失敗しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                }

                if (string.IsNullOrEmpty(strJson) == true)
                {
                    MessageBox.Show("FNSiのCSVのcoop_ini_infoにJSONが設定されていません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            // ---------------------------------------
            // JSON文字列の解析
            // ---------------------------------------
            try
            {
                JSONDataManager.JSONDataList = JsonConvert.DeserializeObject<List<JSONDataItem>>(strJson);
            }
            catch
            {
                MessageBox.Show("FNSiのJSON形式の解析に失敗しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // ソートする
            //JSONDataManager.FNSiDataList.Sort(JSONDataManager.CompareFNSiData);
            JSONDataManager.JSONDataList.Sort(new ComparerJSONData());

            // ---------------------------------------
            // XMLの読み込み
            // ---------------------------------------
            if (MappingSettingManager.ReadXML(strXMLReeditPath, true) == Commons.RetCode_Error)
            {
                if (rdoXMLReedit.Checked == true)
                {
                    MessageBox.Show("再編集するXMLファイルの読み込みに失敗しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                else
                {
                    MessageBox.Show("デフォルト定義ファイルの読み込みに失敗しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                return;
            }

            // Key1とKwy2にNULLならINI_SECTIONとINI_KEYから値をコピーする
            MappingSettingManager.SetKeyNull(false, true);

            if (rdoOverwriteDefaultDefinition.Checked == true)
            {
                // デフォルト定義ファイルを修正

                // INI_CLASS=0 以外の設定項目があったらインフォメーション表示
                bool exists = FNWDataManager.FNWDataList.Any(item => item.INI_CLASS != "0");
                if (exists == true)
                {
                    MessageBox.Show("FNWのCSVファイルに INI_CLASS=0 以外の設定項目が含まれています。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }

            // ---------------------------------------
            // 読み込みデータをもとに内部データを生成
            // ---------------------------------------
            ConversionDataManager.ConversionDataList = new BindingList<ConversionDataItem>();

            MappingSettingManager.Initialization();

            List<string> key1List = new List<string>();

            // ------------------------------------
            // FNSi表示用のデータを作成
            // ------------------------------------
            foreach (JSONDataItem row in JSONDataManager.JSONDataList)
            {
                ConversionDataItem addData = new ConversionDataItem();
                addData.key1 = row.key1;
                addData.key2 = row.key2;
                addData.value = row.value;
                addData.default_v = row.default_v;
                addData.comment = row.comment;

                // XMLの内容によりkey1+key2マッピング
                var wkItem = MappingSettingManager.GetIndividualItem_FNSi(row.key1, row.key2, true);
                if (wkItem != null)
                {
                    int FNWIndex = FNWDataManager.FNWDataList.FindIndex(d => d.INI_SECTION == wkItem.INI_SECTION && d.INI_KEY == wkItem.INI_KEY);
                    if (FNWIndex >= 0)
                    {
                        // FNWのデータを発見
                        FNWDataItem rowFNW = FNWDataManager.FNWDataList[FNWIndex];

                        addData.ConvTarget = "key1+key2";
                        addData.INI_SECTION = rowFNW.INI_SECTION;
                        addData.INI_KEY = rowFNW.INI_KEY;
                        addData.INI_VALUE = rowFNW.INI_VALUE;
                        addData.DEFAULT_VALUE = rowFNW.DEFAULT_VALUE;
                        addData.KEY_TITLE = rowFNW.KEY_TITLE;
                        addData.MEMO = rowFNW.MEMO;
                        addData.FnwPos = FNWIndex;
                        addData.Is_TempAdd = false;

                        // 変換設定をコピーして追加
                        MappingSettingManager.AddIndividualItem(wkItem.Clone());
                    }
                }

                // key1
                if (key1List.Contains(row.key1) == false)
                {
                    key1List.Add(row.key1);
                }

                ConversionDataManager.ConversionDataList.Add(addData);
            }

            // ------------------------------------
            // FNW表示用のデータを作成
            // ------------------------------------
            for (int i = 0; i < FNWDataManager.FNWDataList.Count; i++)
            {

                int j = 0;
                for (; j < ConversionDataManager.ConversionDataList.Count; j++)
                {
                    if (ConversionDataManager.ConversionDataList[j].FnwPos == i)
                    {
                        break;
                    }
                }

                if (j >= ConversionDataManager.ConversionDataList.Count)
                {
                    // マッチングしていない場合

                    FNWDataItem rowFNW = FNWDataManager.FNWDataList[i];

                    ConversionFNWDataItem addFNWData = new ConversionFNWDataItem();
                    addFNWData.INI_SECTION = rowFNW.INI_SECTION;
                    addFNWData.INI_KEY = rowFNW.INI_KEY;
                    addFNWData.INI_VALUE = rowFNW.INI_VALUE;
                    addFNWData.DEFAULT_VALUE = rowFNW.DEFAULT_VALUE;
                    addFNWData.KEY_TITLE = rowFNW.KEY_TITLE;
                    addFNWData.MEMO = rowFNW.MEMO;
                    addFNWData.FnwPos = i;
                    ConversionFNWDataManager.ConversionFNWDataList.Add(addFNWData);
                }
            }

            // ------------------------------------
            // XMLの内容によりkey1マッピング
            // ------------------------------------
            foreach (string key1 in key1List)
            {
                var wkItem = MappingSettingManager.GetSectionItem_FNSi(key1, true);
                if (wkItem == null)
                {
                    continue;
                }

                // key1マッピングを実行
                Commons.key1Func(wkItem.Key1, wkItem.INI_SECTION, true, false);

                // 変換設定をコピーして追加
                MappingSettingManager.AddSectionItem(wkItem.Clone());
            }

            // ------------------------------------
            // 自動マッピング
            // ------------------------------------
            if (ConfigSettingManager.Data.AutoMapping == true)
            {
                // 自動マッチングをする場合
                for (int j = 0; j < ConversionDataManager.ConversionDataList.Count; j++)
                {
                    var row = ConversionDataManager.ConversionDataList[j];

                    if (ConversionDataManager.ConversionDataList[j].FnwPos != -1)
                    {
                        // 既にマッピング済みの場合
                        continue;
                    }

                    for (int i = 0; i < ConversionFNWDataManager.ConversionFNWDataList.Count; i++)
                    {
                        ConversionFNWDataItem rowFNW = ConversionFNWDataManager.ConversionFNWDataList[i];

                        if (row.key1 == rowFNW.INI_SECTION &&
                            row.key2 == rowFNW.INI_KEY)
                        {
                            // key1とINI_SECTIONが同じ
                            // key2とINI_KEYが同じ

                            // 除外設定があるか取得する
                            var wkItem = MappingSettingManager.GetExcludeIndividualItem(rowFNW.INI_SECTION, rowFNW.INI_KEY, true);
                            if (wkItem != null)
                            {
                                // 除外設定があるのでマッピングしない
                                break;
                            }

                            row.ConvTarget = "key1+key2";
                            row.INI_SECTION = rowFNW.INI_SECTION;
                            row.INI_KEY = rowFNW.INI_KEY;
                            row.INI_VALUE = rowFNW.INI_VALUE;
                            row.DEFAULT_VALUE = rowFNW.DEFAULT_VALUE;
                            row.KEY_TITLE = rowFNW.KEY_TITLE;
                            row.MEMO = rowFNW.MEMO;
                            row.FnwPos = i;
                            row.Is_TempAdd = false;


                            Item item = new Item();
                            item.INI_SECTION = row.INI_SECTION;
                            item.INI_KEY = row.INI_KEY;
                            item.Key1 = row.key1;
                            item.Key2 = row.key2;
                            item.PublicList = null;
                            item.LocalList = null;
                            MappingSettingManager.AddIndividualItem(item);

                            // FNWのリストから削除
                            ConversionFNWDataManager.ConversionFNWDataList.Remove(rowFNW);

                            break;
                        }
                    }

                }
            }

            // ------------------------------------
            // 共通値変換設定をコピーする
            // ------------------------------------
            var publicValueMappingList = MappingSettingManager.GetPublicValueMappingList(true);
            if (publicValueMappingList != null)
            {
                List<ValueMappingList> addList = new List<ValueMappingList>();
                foreach (ValueMappingList additem in publicValueMappingList)
                {
                    addList.Add(additem.Clone());
                }
                MappingSettingManager.SetPublicValueMappingList(addList);
            }


            this.DialogResult = DialogResult.OK;
            this.Hide();
//            this.Close();
        }

        /// <summary>
        /// 「終了」ボタン押下
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// 「XMLを再編集」のチェックボックスのチェック変更時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ConversionDefinition_CheckedChanged(object sender, EventArgs e)
        {
            if (rdoXMLReedit.Checked == true)
            {
                // 「XMLを再編集」の入力項目を活性化
                groupBox5.Enabled = true;
            }
            else
            {
                // 「XMLを再編集」の入力項目を非活性化
                groupBox5.Enabled = false;
            }
        }

        /// <summary>
        /// 「JSON形式貼り付け」チェックボックスの選択変更時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkJson_CheckedChanged(object sender, EventArgs e)
        {
            if (chkJson.Checked == false)
            {
                // JSON形式の入力欄を非活性
                txtJson.Enabled = false;
            }
            else
            {
                // JSON形式の入力欄を活性
                txtJson.Enabled = true;
            }
        }

        /// <summary>
        /// FNW CSVファイルの「参照」ボタン押下
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnFNWCsv_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();

            // フィルター（表示するファイルの種類を指定）
            openFileDialog.Filter = "CSVファイル (*.csv)|*.csv|すべてのファイル (*.*)|*.*";

            // 初期フォルダ（任意）
            openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

            // ダイアログを表示
            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                // 選択されたファイルのパスを取得
                txtFNWCsvPath.Text = openFileDialog.FileName;
            }
        }

        /// <summary>
        /// FNSi CSVファイルの「参照」ボタン押下
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnFNSiCsv_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();

            // フィルター（表示するファイルの種類を指定）
            openFileDialog.Filter = "CSVファイル (*.csv)|*.csv|すべてのファイル (*.*)|*.*";

            // 初期フォルダ（任意）
            openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

            // ダイアログを表示
            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                // 選択されたファイルのパスを取得
                txtFNSiCsvPath.Text = openFileDialog.FileName;
            }
        }

        /// <summary>
        /// XMLを再編集 XMLファイルの「参照」ボタン押下
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnXMLReedit_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();

            // フィルター（表示するファイルの種類を指定）
            openFileDialog.Filter = "XMLファイル (*.xml)|*.xml|すべてのファイル (*.*)|*.*";

            // 初期フォルダ（任意）
            openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

            // ダイアログを表示
            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                // 選択されたファイルのパスを取得
                txtXMLReeditPath.Text = openFileDialog.FileName;
            }
        }
    }
}
