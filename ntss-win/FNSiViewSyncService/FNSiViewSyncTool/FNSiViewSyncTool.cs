using System;
using System.Windows.Forms;
using TdcLib;
using FNSiViewSyncLogicLib;
using System.Xml;
using System.ServiceProcess;
using System.Drawing;
using System.Collections;
using System.IO;
using System.Data;
using System.Collections.Generic;
using NKKLoggingLib;
using System.Runtime.InteropServices;
using System.Text;
using System.Net;
using System.Threading;
using System.Net.Sockets;
using System.Globalization;
using System.Linq;
using FNSiViewSyncLogicLib.Common.Utilities;

namespace FNSiViewSyncTool
{

    public partial class FNSiViewSyncTool : Form
    {
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        private readonly String CONFIG_FILE_NAME = "FNSiViewSync.config";

        /// <summary>
        /// 設定ファイル内[更新設定1]設定セッション識別子
        /// </summary>
        public static readonly String CONFIG_UPDATE_DEFINITION_1_SECTION = "Settings\\UpdateDefinition\\Definition1";

        /// <summary>
        /// 設定ファイル内[更新設定2]設定セッション識別子
        /// </summary>
        public static readonly String CONFIG_UPDATE_DEFINITION_2_SECTION = "Settings\\UpdateDefinition\\Definition2";

        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);


        /// <summary>
        //Config同期結果の保存先
        /// </summary>
        public readonly String CONFIG_RESULT_RESULTFOLDER = "Settings\\Result";

        /// <summary>
        /// 設定ファイル内[共通設定]セッション識別子
        /// </summary>
        private readonly String CONFIG_COMMON_SECTION = "Settings\\Common";

        /// <summary>
        /// XMLファイル名
        /// </summary>
        private readonly String XMLG_FILE_NAME = "FNSiViewSync.xml";

        #region zhao add
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        private Exception m_Exception = null;

        /// <summary>
        /// ローカルサービスのIP
        /// </summary>
        private String m_strLocalIPAddress = "127.0.0.1";

        /// <summary>
        /// ローカルサービスのポートNo
        /// </summary>
        private int m_nrLocalPortNo = 7013;

        /// <summary>
        /// 出力先テーブル情報配列
        /// </summary>
        private ArrayList m_viewTableInfoList = new ArrayList();

        /// <summary>
        /// 選択の日時
        /// </summary>
        private TreeNode lastRightClickedNode;

        #endregion

        // 行番号
        private readonly int number_name = 1;
        private readonly int number_key_name = 2;
        private readonly int number_disp_name = 3;
        private readonly int number_desc = 4;
        private readonly int number_sqlcd = 5;
        private readonly int number_Mode = 6;
        private readonly int number_updateInterval = 7;
        private readonly int number_time = 8;
        private readonly int number_week = 9;
        private readonly int number_is_init = 15;
        private readonly int number_once_flg = 16;
        private readonly int number_is_effect = 17;
        private readonly int number_keep_old_limit = 18;
        private readonly int number_keep_new_limit = 19;
        private readonly int number_past_range_total = 20;
        private readonly int number_future_range_total = 21;
        private readonly int number_up_range = 22;
        private readonly int number_last_start_date = 23;
        private readonly int number_last_end_date = 24;
        private readonly int number_exec_interval = 25;
        private readonly int number_sqlfile = 26;

        DateTimePicker dtp = new DateTimePicker();
        DateTimePicker timingDtp = new DateTimePicker();
        Rectangle _Rectangle;
        DataTable dt = new DataTable();
        string[] file_names;
        Dictionary<string, string> file_updatetime = new Dictionary<string, string>();

        public FNSiViewSyncTool()
        {
            InitializeComponent();

            this.definitionInitLoad();

            this.xmlInitLoad();

            this.treeView1.CheckBoxes = true;
            
            this.table_struct();

            // 全選択を追加　cc start 2022/6/1
            this.SelectCheckBoxsFormLoad();
            // 全選択を追加　cc end 2022/6/1

            // 入力フォーカスがコントロールを離れると発生、更新間隔は符号なし整数値のみ入力可 cc start 2022/6/6
            updateIntervalTextBox.Leave += updateIntervalTextBox_Leave;
            updateIntervalTextBox.KeyPress += updateIntervalTextBox_KeyPress;
            // 入力フォーカスがコントロールを離れると発生、更新間隔は符号なし整数値のみ入力可 cc end 2022/6/6

            // tabPage1を非表示する
            tabPage1.Parent = null;
            // tabPage2を非表示する
            tabPage2.Parent = null;
        }

        public FNSiViewSyncTool(ArrayList viewTableInfoList)
        {
            m_viewTableInfoList = new ArrayList(viewTableInfoList);
        }


        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                if (this.IsXmlNameExisted())
                {
                    MessageBox.Show("nameが重複しています");
                    return;
                }

                if (int.Parse(this.textBox1.Text) < 300)
                {
                    MessageBox.Show("更新間隔（秒）300秒以上の値を入力してください");
                    return;
                }

                SystemSettingInfo sys = SystemSettingInfo.GetInstance();

                sys.SetValue(CONFIG_COMMON_SECTION, "ViewSyncTimeSpan", this.textBox1.Text);
                sys.SetValue(CONFIG_COMMON_SECTION, "InitialUpdatedDate", this.updateDateTimePicker1.Value.ToString("yyyyMMddHHmmss"));

                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Time", this.dateTimePicker1.Value.ToString("HH:mm"));
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Monday", this.weekCheckBox1.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Tuesday", this.weekCheckBox2.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Wednesday", this.weekCheckBox3.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Thursday", this.weekCheckBox4.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Friday", this.weekCheckBox5.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Saturday", this.weekCheckBox6.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_1_SECTION, "Sunday", this.weekCheckBox7.Checked.ToString());

                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Time", this.dateTimePicker2.Value.ToString("HH:mm"));
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Monday", this.weekCheckBox11.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Tuesday", this.weekCheckBox12.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Wednesday", this.weekCheckBox13.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Thursday", this.weekCheckBox14.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Friday", this.weekCheckBox15.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Saturday", this.weekCheckBox16.Checked.ToString());
                sys.SetValue(FNSiViewSyncLogic.CONFIG_UPDATE_DEFINITION_2_SECTION, "Sunday", this.weekCheckBox17.Checked.ToString());   
                sys.Save();

                // XMLファイル名作成
                String xmlfile = AppDomain.CurrentDomain.BaseDirectory;
                if (xmlfile.EndsWith("\\") == false)
                {
                    xmlfile += "\\";
                }
                xmlfile += this.XMLG_FILE_NAME;

                XmlDocument doc = new XmlDocument();
                XmlDeclaration dec = doc.CreateXmlDeclaration("1.0", "utf-8", null);
                doc.AppendChild(dec);

                XmlNode rootNode = doc.CreateElement("viewList");
                doc.AppendChild(rootNode);

                foreach (DataGridViewRow row in dataGridView1.Rows)
                {
                    if (String.IsNullOrEmpty((string)row.Cells[0].Value))
                    {
                        continue;
                    }

                    XmlNode rootViewNode = doc.CreateElement("view");

                    XmlAttribute nameAttr = doc.CreateAttribute("name");
                    nameAttr.Value = (string)row.Cells[0].Value;
                    rootViewNode.Attributes.Append(nameAttr);

                    XmlAttribute descAttr = doc.CreateAttribute("desc");
                    descAttr.Value = (string)row.Cells[1].Value;
                    rootViewNode.Attributes.Append(descAttr);

                    XmlAttribute sqlcdAttr = doc.CreateAttribute("sqlcd");
                    sqlcdAttr.Value = (string)row.Cells[2].Value;
                    rootViewNode.Attributes.Append(sqlcdAttr);

                    XmlAttribute modeAttr = doc.CreateAttribute("Mode");
                    modeAttr.Value = (string)row.Cells[3].Value;
                    rootViewNode.Attributes.Append(modeAttr);

                    XmlAttribute definition1Attr = doc.CreateAttribute("Definition1");
                    definition1Attr.Value = (row.Cells[4].Value == null ? "false" : row.Cells[4].Value.ToString());
                    rootViewNode.Attributes.Append(definition1Attr);

                    XmlAttribute definition2Attr = doc.CreateAttribute("Definition2");
                    definition2Attr.Value = (row.Cells[5].Value == null ? "false" : row.Cells[5].Value.ToString());
                    rootViewNode.Attributes.Append(definition2Attr);

                    XmlAttribute viewSyncTimeSpanAttr = doc.CreateAttribute("ViewSyncTimeSpan");
                    viewSyncTimeSpanAttr.Value = (row.Cells[6].Value == null ? "false" : row.Cells[6].Value.ToString());
                    rootViewNode.Attributes.Append(viewSyncTimeSpanAttr);

                    XmlAttribute fromDateAttr = doc.CreateAttribute("FromDate");
                    fromDateAttr.Value =
                        string.IsNullOrEmpty((string)row.Cells[7].Value) ? this.updateDateTimePicker1.Value.ToString("yyyyMMddHHmmss") :
                        DateTime.ParseExact((string)row.Cells[7].Value, "yyyy/MM/dd HH:mm:ss", null).ToString("yyyyMMddHHmmss");
                    rootViewNode.Attributes.Append(fromDateAttr);

                    XmlAttribute toDateAttr = doc.CreateAttribute("ToDate");
                    toDateAttr.Value =
                        string.IsNullOrEmpty((string)row.Cells[8].Value) ? this.updateDateTimePicker1.Value.ToString("yyyyMMddHHmmss") :
                        DateTime.ParseExact((string)row.Cells[8].Value, "yyyy/MM/dd HH:mm:ss", null).ToString("yyyyMMddHHmmss");
                    rootViewNode.Attributes.Append(toDateAttr);

                    rootNode.AppendChild(rootViewNode);
                }

                doc.Save(xmlfile);

                MessageBox.Show("保存しました");

                this.definitionInitLoad();

                this.xmlInitLoad();
            }
            catch (Exception ex)
            {
                MessageBox.Show("保存エラー");
            }
        }

        private void definitionInitLoad()
        {
            // 設定ファイル名作成
            String strfile = AppDomain.CurrentDomain.BaseDirectory;
            if (strfile.EndsWith("\\") == false)
            {
                strfile += "\\";
            }
            strfile += this.CONFIG_FILE_NAME;

            // システム共通設定クラス初期化
            SystemSettingInfo sys = SystemSettingInfo.GetInstance();
            
            
            if (sys.Load(strfile) == false)
            {
                // 設定読み込み失敗
                throw (new Exception(String.Format("Config,{0}", SystemSettingInfo.GetInstance().Error.ToString())));
            }

            // Config共通設定:更新間隔(秒)
            if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "ViewSyncTimeSpan", String.Empty).Trim(), out int nwork1) && 0 <= nwork1)
            {
                // 更新間隔(秒)
                FNSiViewSyncSetting.ViewSyncTimeSpan = nwork1;
            }

            // Config共通設定:初期更新日付(yyyyMMddhhmmss)
            FNSiViewSyncSetting.InitialUpdatedDate = sys.GetSingleLineValue(CONFIG_COMMON_SECTION, "InitialUpdatedDate", String.Empty).Trim();
            if (String.IsNullOrEmpty(FNSiViewSyncSetting.InitialUpdatedDate))
            {
                FNSiViewSyncSetting.InitialUpdatedDate = "19700101000000";
            }

            // Config更新頻度設定1:更新時刻(01:00)
            FNSiViewSyncSetting.Definition1.Time = (string.IsNullOrEmpty(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Time", String.Empty)) 
                ? "01:00" : sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Time", String.Empty).Trim());

            // Config更新頻度設定1:月曜日更新フラグ
            FNSiViewSyncSetting.Definition1.Monday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Monday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定1:火曜日更新フラグ
            FNSiViewSyncSetting.Definition1.Tuesday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Tuesday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定1:水曜日更新フラグ
            FNSiViewSyncSetting.Definition1.Wednesday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Wednesday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定1:木曜日更新フラグ
            FNSiViewSyncSetting.Definition1.Thursday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Thursday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定1:金曜日更新フラグ
            FNSiViewSyncSetting.Definition1.Friday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Friday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定1:土曜日更新フラグ
            FNSiViewSyncSetting.Definition1.Saturday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Saturday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定1:日曜日更新フラグ
            FNSiViewSyncSetting.Definition1.Sunday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_1_SECTION, "Sunday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定2:更新時刻(01:00)
            FNSiViewSyncSetting.Definition2.Time = (string.IsNullOrEmpty(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Time", String.Empty))
                ? "01:00" : sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Time", String.Empty).Trim());

            // Config更新頻度設定2:月曜日更新フラグ
            FNSiViewSyncSetting.Definition2.Monday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Monday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定2:火曜日更新フラグ
            FNSiViewSyncSetting.Definition2.Tuesday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Tuesday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定2:水曜日更新フラグ
            FNSiViewSyncSetting.Definition2.Wednesday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Wednesday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定2:木曜日更新フラグ
            FNSiViewSyncSetting.Definition2.Thursday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Thursday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定2:金曜日更新フラグ
            FNSiViewSyncSetting.Definition2.Friday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Friday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定2:土曜日更新フラグ
            FNSiViewSyncSetting.Definition2.Saturday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Saturday", String.Empty).Trim().ToLower()) ? true : false;

            // Config更新頻度設定2:日曜日更新フラグ
            FNSiViewSyncSetting.Definition2.Sunday = "true".Equals(sys.GetSingleLineValue(CONFIG_UPDATE_DEFINITION_2_SECTION, "Sunday", String.Empty).Trim().ToLower()) ? true : false;


            // Config Socket設定:IFエッジサービスのポートNo
            if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_RESULT_RESULTFOLDER, "ReSyncPortNo", String.Empty).Trim(), out int nwork10))
            {
                m_nrLocalPortNo = nwork10;
            }

            this.textBox1.Text = FNSiViewSyncSetting.ViewSyncTimeSpan.ToString();
            this.updateDateTimePicker1.Value = DateTime.ParseExact(FNSiViewSyncSetting.InitialUpdatedDate, "yyyyMMddHHmmss", null);

            // 初期データ日付の値を設定する。
            this.initialUpdatedDateDateTimePicker.Value = DateTime.ParseExact(FNSiViewSyncSetting.InitialUpdatedDate, "yyyyMMddHHmmss", null);

            if (FNSiViewSyncSetting.ViewSyncTimeSpan == 0)
            {
                this.textBox1.ReadOnly = true;
                this.textBox1.Enabled = false;

                this.radioButton1.Checked = false;
                this.radioButton2.Checked = true;

                this.dateTimePicker1.Enabled = true;
                this.weekCheckBox1.Enabled = true;
                this.weekCheckBox2.Enabled = true;
                this.weekCheckBox3.Enabled = true;
                this.weekCheckBox4.Enabled = true;
                this.weekCheckBox5.Enabled = true;
                this.weekCheckBox6.Enabled = true;
                this.weekCheckBox7.Enabled = true;

                this.dateTimePicker2.Enabled = true;
                this.weekCheckBox11.Enabled = true;
                this.weekCheckBox12.Enabled = true;
                this.weekCheckBox13.Enabled = true;
                this.weekCheckBox14.Enabled = true;
                this.weekCheckBox15.Enabled = true;
                this.weekCheckBox16.Enabled = true;
                this.weekCheckBox17.Enabled = true;

                this.dataGridView1.Columns[4].Visible = true;
                this.dataGridView1.Columns[5].Visible = true;
                this.dataGridView1.Columns[6].Visible = false;

            } 
            else
            {
                this.textBox1.ReadOnly = false;
                this.textBox1.Enabled = true;

                this.radioButton1.Checked = true;
                this.radioButton2.Checked = false;

                this.dateTimePicker1.Enabled = false;
                this.weekCheckBox1.Enabled = false;
                this.weekCheckBox2.Enabled = false;
                this.weekCheckBox3.Enabled = false;
                this.weekCheckBox4.Enabled = false;
                this.weekCheckBox5.Enabled = false;
                this.weekCheckBox6.Enabled = false;
                this.weekCheckBox7.Enabled = false;

                this.dateTimePicker2.Enabled = false;
                this.weekCheckBox11.Enabled = false;
                this.weekCheckBox12.Enabled = false;
                this.weekCheckBox13.Enabled = false;
                this.weekCheckBox14.Enabled = false;
                this.weekCheckBox15.Enabled = false;
                this.weekCheckBox16.Enabled = false;
                this.weekCheckBox17.Enabled = false;

                this.dataGridView1.Columns[4].Visible = false;
                this.dataGridView1.Columns[5].Visible = false;
                this.dataGridView1.Columns[6].Visible = true;
            }

            this.dateTimePicker1.Value = DateTime.ParseExact(FNSiViewSyncSetting.Definition1.Time, "HH:mm", null);
            this.weekCheckBox1.Checked = FNSiViewSyncSetting.Definition1.Monday;
            this.weekCheckBox2.Checked = FNSiViewSyncSetting.Definition1.Tuesday;
            this.weekCheckBox3.Checked = FNSiViewSyncSetting.Definition1.Wednesday;
            this.weekCheckBox4.Checked = FNSiViewSyncSetting.Definition1.Thursday;
            this.weekCheckBox5.Checked = FNSiViewSyncSetting.Definition1.Friday;
            this.weekCheckBox6.Checked = FNSiViewSyncSetting.Definition1.Saturday;
            this.weekCheckBox7.Checked = FNSiViewSyncSetting.Definition1.Sunday;

            this.dateTimePicker2.Value = DateTime.ParseExact(FNSiViewSyncSetting.Definition2.Time, "HH:mm", null);
            this.weekCheckBox11.Checked = FNSiViewSyncSetting.Definition2.Monday;
            this.weekCheckBox12.Checked = FNSiViewSyncSetting.Definition2.Tuesday;
            this.weekCheckBox13.Checked = FNSiViewSyncSetting.Definition2.Wednesday;
            this.weekCheckBox14.Checked = FNSiViewSyncSetting.Definition2.Thursday;
            this.weekCheckBox15.Checked = FNSiViewSyncSetting.Definition2.Friday;
            this.weekCheckBox16.Checked = FNSiViewSyncSetting.Definition2.Saturday;
            this.weekCheckBox17.Checked = FNSiViewSyncSetting.Definition2.Sunday;

            // ボタンの初期状態を設定する
            setSyncModeStatus();
        }

        private void xmlInitLoad()
        {
            // XMLファイル名作成
            String xmlfile = AppDomain.CurrentDomain.BaseDirectory;
            if (xmlfile.EndsWith("\\") == false)
            {
                xmlfile += "\\";
            }
            xmlfile += this.XMLG_FILE_NAME;

            // テーブル情報取得(XMLより)
            XmlDocument xdoc = CommonUtil.LoadDecryptedXml(xmlfile);
            XmlNodeList xnlView = xdoc.SelectNodes("//viewList/view");

            while (this.dataGridView1.Rows.Count != 1)
            {
                this.dataGridView1.Rows.RemoveAt(0);
            }

            dataGridView1.Controls.Add(dtp);
            dtp.Visible = false;
            dtp.Format = DateTimePickerFormat.Custom;
            dtp.CustomFormat = "yyyy/MM/dd HH:mm:ss";
            dtp.TextChanged += new EventHandler(dtp_TextChange);

            foreach (XmlNode xn in xnlView)
            {
                string[] colValues = { xn.Attributes["name"].Value.Trim(),
                    xn.Attributes["desc"].Value.Trim(),
                    xn.Attributes["sqlcd"].Value.Trim()};

                dataGridView1.Rows.Add(colValues);
            }

            dataGridView1.Refresh();


            // タイミング設定の初期化
            // タイミング設定にデーブルの初期化
            while (this.dataGridView3.Rows.Count != 1)
            {
                this.dataGridView3.Rows.RemoveAt(0);
            }

            dataGridView3.Controls.Add(timingDtp);
            timingDtp.Visible = false;
            timingDtp.Format = DateTimePickerFormat.Custom;
            timingDtp.CustomFormat = "yyyy/MM/dd HH:mm:ss";
            timingDtp.TextChanged += new EventHandler(timingDtp_TextChange);

            foreach (XmlNode xn in xnlView)
            {
                string[] colValues = { "false".ToLower(),
                    xn.Attributes["name"].Value.Trim(),
                    xn.Attributes["key_name"].Value.Trim(),
                    xn.Attributes["disp_name"].Value.Trim(),
                    xn.Attributes["desc"].Value.Trim(),
                    xn.Attributes["sqlcd"].Value.Trim(),
                    xn.Attributes["Mode"].Value.Trim(),
                    xn.Attributes["updateInterval"].Value.Trim(),
                    xn.Attributes["time"].Value.Trim(),
                    xn.Attributes["week"].Value.Trim(),
                    "",
                    "",
                    "",
                    "",
                    "",
                    xn.Attributes["is_init"].Value.Trim(),
                    xn.Attributes["once_flg"].Value.Trim(),
                    xn.Attributes["is_effect"].Value.Trim(),
                    xn.Attributes["keep_old_limit"].Value.Trim(),
                    xn.Attributes["keep_new_limit"].Value.Trim(),
                    xn.Attributes["past_range_total"].Value.Trim(),
                    xn.Attributes["future_range_total"].Value.Trim(),
                    xn.Attributes["up_range"].Value.Trim(),
                    xn.Attributes["last_start_date"].Value.Trim(),
                    xn.Attributes["last_end_date"].Value.Trim(),
                    xn.Attributes["exec_interval"].Value.Trim(),
                    xn.Attributes["sqlfile"].Value.Trim()
                };

                int rowIndex = dataGridView3.Rows.Add(colValues);

                // 上限と下限をタグとして各項目に追加する
                dataGridView3.Rows[rowIndex].Cells[number_past_range_total].Tag = 
                    new string[] { xn.Attributes["min_past_range_total"].Value.Trim(), 
                        xn.Attributes["max_past_range_total"].Value.Trim() };
                dataGridView3.Rows[rowIndex].Cells[number_future_range_total].Tag =
                    new string[] { xn.Attributes["min_future_range_total"].Value.Trim(),
                        xn.Attributes["max_future_range_total"].Value.Trim() };
                dataGridView3.Rows[rowIndex].Cells[number_up_range].Tag =
                    new string[] { xn.Attributes["min_up_range"].Value.Trim(),
                        xn.Attributes["max_up_range"].Value.Trim() };
                dataGridView3.Rows[rowIndex].Cells[number_updateInterval].Tag =
                    new string[] { xn.Attributes["min_updateInterval"].Value.Trim(),
                        xn.Attributes["max_updateInterval"].Value.Trim() };
            }

            dataGridView3.Refresh();
        }

        private void dtp_TextChange(object sender, EventArgs e)
        {
            dataGridView1.CurrentCell.Value = dtp.Text.ToString();
        }

        private void timingDtp_TextChange(object sender, EventArgs e)
        {
            dataGridView3.CurrentCell.Value = timingDtp.Text.ToString();
        }

        private void dataGridView1_CellClick_1(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 7 || e.ColumnIndex == 8)
            {
                _Rectangle = dataGridView1.GetCellDisplayRectangle(e.ColumnIndex, e.RowIndex, true);
                dtp.Size = new Size(_Rectangle.Width, _Rectangle.Height);
                dtp.Location = new Point(_Rectangle.X, _Rectangle.Y);
                dtp.Visible = true;

                string dataStr = dataGridView1.Rows[e.RowIndex].Cells[e.ColumnIndex].Value.ToString();

                if (string.IsNullOrEmpty(dataStr))
                {
                    this.dtp.Value = this.updateDateTimePicker1.Value;
                } else
                {
                    this.dtp.Value = DateTime.ParseExact(dataStr, "yyyy/MM/dd HH:mm:ss", null);
                }
            }
            else
                dtp.Visible = false;
        }

        private void dataGridView1_CellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
        {
            if (dataGridView1.Columns["Column3"] == null) return;
            if (dataGridView1.Columns["Column3"].Index == e.ColumnIndex)
            {
                if (e.Value == null)
                {
                    return;
                }

                if (!System.Text.RegularExpressions.Regex.IsMatch(e.Value.ToString(), @"^[0-9,\-]*$"))
                {
                    e.Value = "";
                    return;
                }
            }
        }

        private void dataGridView1_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.Rows[e.RowIndex].Cells[0].Value == null)
            {
                dataGridView1.Rows[e.RowIndex].Cells[0].Value = "";
                dataGridView1.Rows[e.RowIndex].Cells[1].Value = "";
                dataGridView1.Rows[e.RowIndex].Cells[2].Value = "";
                dataGridView1.Rows[e.RowIndex].Cells[3].Value = "";
                dataGridView1.Rows[e.RowIndex].Cells[4].Value = "false";
                dataGridView1.Rows[e.RowIndex].Cells[5].Value = "false";
                dataGridView1.Rows[e.RowIndex].Cells[6].Value = "false";
            }
        }

        private void dataGridView1_ColumnWidthChanged_1(object sender, DataGridViewColumnEventArgs e)
        {
            dtp.Visible = false;
        }

        private void dataGridView1_Scroll_1(object sender, ScrollEventArgs e)
        {
            dtp.Visible = false;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Close();
        }

        public static bool IsServiceExisted(string NameService)
        {
            try
            {
                ServiceController[] services = ServiceController.GetServices();
                foreach (ServiceController s in services)
                {
                    if (s.ServiceName.ToLower() == NameService.ToLower())
                    {
                        return true;
                    }
                }
            }
            catch (Exception e)
            {
                MessageBox.Show("サービス再起動エラー");
            }
            return false;
        }

        // upd 2023-07-11 bug #8503 FNSiViewSyncServiceのCPU負荷が高い 崔 start
        private bool ServiceStart(string serviceName)
        {
            bool flg = true;
            try
            {
                if (IsServiceExisted(serviceName))
                {
                    using (ServiceController control = new ServiceController(serviceName))
                    {
                        if (control.Status == ServiceControllerStatus.Running)
                        {
                            control.Stop();
                            control.WaitForStatus(ServiceControllerStatus.Stopped);
                        }
                        control.Start();
                        control.WaitForStatus(ServiceControllerStatus.Running);
                        
                        MessageBox.Show(string.Format("{0}しました。", this.startServiceButton.Text));
                    }
                }
            }
            catch
            {
                MessageBox.Show(string.Format("{0}起動エラー。", this.startServiceButton.Text));
                flg = false;
            }

            return flg;
        }
        // upd 2023-07-11 bug #8503 FNSiViewSyncServiceのCPU負荷が高い 崔 end

        private void button3_Click(object sender, EventArgs e)
        {
            ServiceStart("FNSiViewSyncService");
        }

        private void radioButton1_Click(object sender, EventArgs e)
        {
            this.textBox1.ReadOnly = false;
            this.textBox1.Enabled = true;
            this.textBox1.Text = "300";

            this.radioButton1.Checked = true;
            this.radioButton2.Checked = false;

            this.dateTimePicker1.Enabled = false;
            this.weekCheckBox1.Enabled = false;
            this.weekCheckBox2.Enabled = false;
            this.weekCheckBox3.Enabled = false;
            this.weekCheckBox4.Enabled = false;
            this.weekCheckBox5.Enabled = false;
            this.weekCheckBox6.Enabled = false;
            this.weekCheckBox7.Enabled = false;

            this.dateTimePicker2.Enabled = false;
            this.weekCheckBox11.Enabled = false;
            this.weekCheckBox12.Enabled = false;
            this.weekCheckBox13.Enabled = false;
            this.weekCheckBox14.Enabled = false;
            this.weekCheckBox15.Enabled = false;
            this.weekCheckBox16.Enabled = false;
            this.weekCheckBox17.Enabled = false;

            this.dataGridView1.Columns[6].Visible = false;
            this.dataGridView1.Columns[7].Visible = false;
            this.dataGridView1.Columns[8].Visible = true;

        }

        private void radioButton2_Click(object sender, EventArgs e)
        {
            this.textBox1.Text = "0";
            this.textBox1.ReadOnly = true;
            this.textBox1.Enabled = false;

            this.radioButton1.Checked = false;
            this.radioButton2.Checked = true;

            this.dateTimePicker1.Enabled = true;
            this.weekCheckBox1.Enabled = true;
            this.weekCheckBox2.Enabled = true;
            this.weekCheckBox3.Enabled = true;
            this.weekCheckBox4.Enabled = true;
            this.weekCheckBox5.Enabled = true;
            this.weekCheckBox6.Enabled = true;
            this.weekCheckBox7.Enabled = true;

            this.dateTimePicker2.Enabled = true;
            this.weekCheckBox11.Enabled = true;
            this.weekCheckBox12.Enabled = true;
            this.weekCheckBox13.Enabled = true;
            this.weekCheckBox14.Enabled = true;
            this.weekCheckBox15.Enabled = true;
            this.weekCheckBox16.Enabled = true;
            this.weekCheckBox17.Enabled = true;

            this.dataGridView1.Columns[4].Visible = true;
            this.dataGridView1.Columns[5].Visible = true;
            this.dataGridView1.Columns[6].Visible = false;
        }

        private bool IsXmlNameExisted()
        {
            ArrayList checkList = new ArrayList();
            foreach (DataGridViewRow row in dataGridView1.Rows)
            {
                if (String.IsNullOrEmpty((string)row.Cells[0].Value))
                {
                    continue;
                }

                if (checkList.Contains((string)row.Cells[0].Value))
                {
                    return true;
                }

                checkList.Add((string)row.Cells[0].Value);
            }

            return false;
        }

        public bool IsDate(string strDate)
        {
            try
            {
                DateTime.Parse(strDate);
                return true;
            }
            catch
            {
                return false;
            }
        }

        private void textBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!(e.KeyChar == '\b' || (e.KeyChar >= '0' && e.KeyChar <= '9')))
            {
                e.Handled = true;
            }
        }

        private void button_read_Click(object sender, EventArgs e)
        {
            dt.Clear();
            foreach (TreeNode n in treeView1.Nodes)
            {
                TreeNode node = n;
                if (node.Checked == true)
                {
                    string name = node.Text;
                    this.getdata(name);
                }
            }
        }

        private void getdata(string name)
        {
            if (file_names != null)
            {
                foreach (string s in file_names)
                {
                    if (s.Contains(name))
                    {
                        XmlDocument doc = new XmlDocument();
                        doc.Load(s);
                        XmlNode xn = doc.SelectSingleNode("ResultList");
                        XmlNodeList xnl = xn.ChildNodes;

                        foreach (XmlNode node in xnl)
                        {
                            XmlElement xe = (XmlElement)node;
                            DataRow row = dt.NewRow();

                            if (check_Success.Checked)
                            {
                                if (xe.GetAttribute("Status") == "1:成功")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else if (check_Start.Checked)
                            {
                                if (xe.GetAttribute("Status") == "0:開始")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else if (check_Fail.Checked)
                            {
                                if (xe.GetAttribute("Status") == "2:失敗")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else if (check_Warn.Checked)
                            {
                                if (xe.GetAttribute("Status") == "3:警告")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else
                            {
                                getDate(row, xe);
                            }
                            if (row["Status"].ToString() == "") { }
                            else
                                dt.Rows.Add(row);
                        }
                        dataGridView2.DataSource = dt;

                        for (int i = 0; i < dataGridView2.Rows.Count - 1; i++)
                        {
                            if (dataGridView2.Rows[i].Cells[13].Value.ToString() == "1:成功")
                            {
                                dataGridView2.Rows[i].Cells[0].ReadOnly = true;
                            }
                        }
                        dataGridView2.Columns["check"].Frozen = true;
                        dataGridView2.Columns["name"].Frozen = true;
                        dataGridView2.Columns["desc"].Frozen = true;
                    }
                }
            }
            
        }

        private void table_struct()
        {
            dt.Columns.Add("check", System.Type.GetType("System.Boolean"));
            dt.Columns.Add("name");
            dt.Columns.Add("key_name");
            dt.Columns.Add("disp_name");
            dt.Columns.Add("desc");
            dt.Columns.Add("sqlcd");
            dt.Columns.Add("Mode");
            dt.Columns.Add("Definition1");
            dt.Columns.Add("Definition2");
            dt.Columns.Add("ViewSyncTimeSpan");
            dt.Columns.Add("FromDate");
            dt.Columns.Add("ToDate");
            dt.Columns.Add("RegDate");
            dt.Columns.Add("UpDate");
            dt.Columns.Add("SyncMode");
            dt.Columns.Add("Status");
            dt.Columns.Add("Message");
            dt.Columns.Add("CntOk");
            dt.Columns.Add("CntNg");

        }

        private void selectAll_Click(object sender, EventArgs e)
        {
            if (selectAll.Checked)
            {
                foreach (TreeNode treeNode in treeView1.Nodes)
                {
                    treeNode.Checked = true;
                }
            }
            else
            {
                foreach (TreeNode treeNode in treeView1.Nodes)
                {
                    treeNode.Checked = false;
                }
            }
        }

        private void treeView1_AfterSelect(object sender, TreeViewEventArgs e)
        {
            string name = treeView1.SelectedNode.Text;
            gettreeViewData(name);
        }

        private void gettreeViewData(string name)
        {
            if (file_names != null)
            {
                foreach (string s in file_names)
                {
                    if (s.Contains(name))
                    {
                        XmlDocument doc = new XmlDocument();
                        doc.Load(s);
                        XmlNode xn = doc.SelectSingleNode("ResultList");
                        XmlNodeList xnl = xn.ChildNodes;
                        dt.Clear();
                        foreach (XmlNode node in xnl)
                        {
                            XmlElement xe = (XmlElement)node;
                            DataRow row = dt.NewRow();

                            if (check_Success.Checked)
                            {
                                if (xe.GetAttribute("Status") == "1:成功")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else if (check_Start.Checked)
                            {
                                if (xe.GetAttribute("Status") == "0:開始")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else if (check_Fail.Checked)
                            {
                                if (xe.GetAttribute("Status") == "2:失敗")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else if (check_Warn.Checked)
                            {
                                if (xe.GetAttribute("Status") == "3:警告")
                                {
                                    getDate(row, xe);
                                }
                            }
                            else
                            {
                                getDate(row, xe);
                            }
                            if (row["Status"].ToString() == "") { }
                            else
                                dt.Rows.Add(row);
                        }

                        dataGridView2.DataSource = dt;

                        for (int i = 0; i < dataGridView2.Rows.Count - 1; i++)
                        {
                            if (dataGridView2.Rows[i].Cells[13].Value.ToString() == "1:成功")
                            {
                                dataGridView2.Rows[i].Cells[0].ReadOnly = true;
                            }
                        }
                        dataGridView2.Columns["check"].Frozen = true;
                        dataGridView2.Columns["name"].Frozen = true;
                        dataGridView2.Columns["desc"].Frozen = true;
                    }
                }
            }
        }

        private void getDate(DataRow row, XmlElement xe)
        {
            row["name"] = xe.GetAttribute("name");
            row["desc"] = xe.GetAttribute("desc");
            row["sqlcd"] = xe.GetAttribute("sqlcd");
            row["Mode"] = xe.GetAttribute("Mode");
            row["Definition1"] = xe.GetAttribute("Definition1");
            row["Definition2"] = xe.GetAttribute("Definition2");
            row["ViewSyncTimeSpan"] = xe.GetAttribute("ViewSyncTimeSpan");
            row["FromDate"] = "";
            if (!String.IsNullOrEmpty(xe.GetAttribute("FromDate")))
            {
                row["FromDate"] = DateTime.ParseExact(xe.GetAttribute("FromDate"), "yyyyMMddHHmmss", null).ToString("yyyy/MM/dd HH:mm:ss");

            }
            row["ToDate"] = "";
            if (!String.IsNullOrEmpty(xe.GetAttribute("ToDate")))
            {
                row["ToDate"] = DateTime.ParseExact(xe.GetAttribute("ToDate"), "yyyyMMddHHmmss", null).ToString("yyyy/MM/dd HH:mm:ss");
            }
            row["RegDate"] = "";
            if (!String.IsNullOrEmpty(xe.GetAttribute("RegDate")))
            {
                row["RegDate"] = DateTime.ParseExact(xe.GetAttribute("RegDate"), "yyyyMMddHHmmss", null).ToString("yyyy/MM/dd HH:mm:ss");
            }
            row["UpDate"] = "";
            if (!String.IsNullOrEmpty(xe.GetAttribute("UpDate")))
            {
                row["UpDate"] = DateTime.ParseExact(xe.GetAttribute("UpDate"), "yyyyMMddHHmmss", null).ToString("yyyy/MM/dd HH:mm:ss");

            }
            row["SyncMode"] = xe.GetAttribute("SyncMode");
            row["Status"] = xe.GetAttribute("Status");
            row["Message"] = xe.GetAttribute("Message");
            row["CntOk"] = xe.GetAttribute("CntOk");
            row["CntNg"] = xe.GetAttribute("CntNg");
        }

        private void button_synchronization_Click(object sender, EventArgs e)
        {
            this.DoWork();
        }

        public void DoWork()
        {
            // オブジェクト
            Socket clientSocket = null;

            try
            {
                // ソケット構築
                clientSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                // 接続
                clientSocket.Connect(new IPEndPoint(IPAddress.Parse(this.m_strLocalIPAddress), this.m_nrLocalPortNo));

                // 送信データを作成する
                String sendData = GetSendData();

                // 文字列をバイト シーケンスにエンコードする
                byte[] bdata = Encoding.UTF8.GetBytes(sendData);

                // 送信
                clientSocket.Send(bdata);


                // 受信データ
                byte[] cRecvData = new byte[1024];

                // 受信
                int len = clientSocket.Receive(cRecvData);

                // 受信データの文字列化
                string strdata = Encoding.Default.GetString(cRecvData, 0, len);

                // 切断
                clientSocket.Close();

                // 受信データを解析する
                GetReceivedData(strdata);
            }
            catch (Exception ex)
            {
                if (clientSocket != null && clientSocket.Connected)
                {
                    clientSocket.Close();
                }
                MessageBox.Show(ex.Message);
            }
        }


        /// <summary>
        /// 送信データを作成する
        /// </summary>
        private String GetSendData()
        {

            StringBuilder sendData = new StringBuilder();
            for (int i = 0; i < dataGridView2.Rows.Count; i++)
            {
                if ((bool)dataGridView2.Rows[i].Cells[0].EditedFormattedValue == true)
                {
                    if (sendData.Length == 0)
                    {
                        sendData.Append("[");
                    }
                    else
                    {
                        sendData.Append(",");
                    }

                    StringBuilder lineData = new StringBuilder();
                    lineData.Append("{");
                    lineData.Append(String.Format( "\"TableName\":\"{0}\"",        dataGridView2.Rows[i].Cells[1].Value));
                    lineData.Append(String.Format(",\"Description\":\"{0}\"",      dataGridView2.Rows[i].Cells[2].Value));
                    lineData.Append(String.Format(",\"SqlCd\":\"{0}\"",            dataGridView2.Rows[i].Cells[3].Value));
                    lineData.Append(String.Format(",\"Mode\":\"{0}\"",             dataGridView2.Rows[i].Cells[4].Value));
                    lineData.Append(String.Format(",\"Definition1Flag\":\"{0}\"",  dataGridView2.Rows[i].Cells[5].Value));
                    lineData.Append(String.Format(",\"Definition2Flag\":\"{0}\"",  dataGridView2.Rows[i].Cells[6].Value));
                    lineData.Append(String.Format(",\"ViewSyncTimeSpan\":\"{0}\"", dataGridView2.Rows[i].Cells[7].Value));
                    lineData.Append(String.Format(",\"FromDate\":\"{0}\"", DateTime.ParseExact((string)dataGridView2.Rows[i].Cells[8].Value, "yyyy/MM/dd HH:mm:ss", null).ToString("yyyyMMddHHmmss")));
                    lineData.Append(String.Format(",\"ToDate\":\"{0}\"",   DateTime.ParseExact((string)dataGridView2.Rows[i].Cells[9].Value, "yyyy/MM/dd HH:mm:ss", null).ToString("yyyyMMddHHmmss")));

                    // 以下項目は実行結果を利用する
                    lineData.Append(String.Format(",\"RegDate\":\"{0}\"",  DateTime.ParseExact((string)dataGridView2.Rows[i].Cells[10].Value, "yyyy/MM/dd HH:mm:ss", null).ToString("yyyyMMddHHmmss")));
                    lineData.Append(String.Format(",\"UpDate\":\"{0}\"",   DateTime.ParseExact((string)dataGridView2.Rows[i].Cells[11].Value, "yyyy/MM/dd HH:mm:ss", null).ToString("yyyyMMddHHmmss")));
                    lineData.Append(String.Format(",\"SyncMode\":\"{0}\"",         dataGridView2.Rows[i].Cells[12].Value));
                    lineData.Append(String.Format(",\"Status\":\"{0}\"",           dataGridView2.Rows[i].Cells[13].Value));
                    lineData.Append(String.Format(",\"Message\":\"{0}\"",          ""));
                    lineData.Append(String.Format(",\"CntOk\":\"{0}\"",            dataGridView2.Rows[i].Cells[15].Value));
                    lineData.Append(String.Format(",\"CntNg\":\"{0}\"",            dataGridView2.Rows[i].Cells[16].Value));

                    lineData.Append("}");

                    sendData.Append(lineData.ToString());
                }
            }
            sendData.Append("]");
            return sendData.ToString();
        }

        /// <summary>
        /// 受信データを解析する
        /// </summary>
        ///// <param name="strdata">受信データ</param>
        private void GetReceivedData(String strdata)
        {
            Dictionary<String, String> tbl = new Dictionary<string, string>();
            String errorCode = "";
            String errorMessage = "";

            // 受信データがJSONか
            if (JSONLib.IsJSONData(strdata))
            {
                // JSON分解
                tbl = TdcLib.JSONLib.JSONtoData(strdata);

                // エラーコード取得
                if (tbl.ContainsKey("ErrorCode") == true)
                {
                    errorCode = tbl["ErrorCode"];
                }

                // エラーメッセージ取得
                if (tbl.ContainsKey("ErrorMessage") == true)
                {
                    errorMessage = tbl["ErrorMessage"];
                }
            }

            if ("0000".Equals(errorCode))
            {
                MessageBox.Show("再同期します。");
            }
            else
            {
                MessageBox.Show("再同期失敗。[" + errorMessage + "]");
            }
        }

        private void check_Start_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void selectAll_CheckedChanged(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// タイミング設定に画面を閉じる
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        private void CloseButton_Click(object sender, EventArgs e)
        {
            Close();
        }

        /// <summary>
        /// 更新間隔同期を押す
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        private void syncModeRadioButton1_Click(object sender, EventArgs e)
        {
            setSyncModeStatus();
        }

        /// <summary>
        /// ボタンの状態を設定する
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        private void setSyncModeStatus()
        {
            // 更新間隔同期のチェック状態
            this.syncModeRadioButton1.Checked = true;
            // 固定時間同期のチェック状態
            this.syncModeRadioButton2.Checked = false;

            // 更新間隔(1回/何分)を設定する。
            this.updateIntervalTextBox.ReadOnly = false;
            this.updateIntervalTextBox.Enabled = true;
            this.updateIntervalTextBox.Text = "300";

            // 日時の時間
            this.timeDateTimePicker.Enabled = false;
            // 追加ボタン
            this.addButton.Enabled = false;
            // すべて日時データ
            this.timeTreeView.Enabled = false;

            // 月曜日
            this.monCheckBox.Enabled = false;
            // 火曜日
            this.tueCheckBox.Enabled = false;
            // 水曜日
            this.wedCheckBox.Enabled = false;
            // 木曜日
            this.thuCheckBox.Enabled = false;
            // 金曜日
            this.friCheckBox.Enabled = false;
            // 土曜日
            this.satCheckBox.Enabled = false;
            // 日曜日
            this.sunCheckBox.Enabled = false;

            // add 2023-07-11 bug #8503 FNSiViewSyncServiceのCPU負荷が高い 崔 start
            string serviceName = "FNSiViewSyncService";
            if (IsServiceExisted(serviceName))
            {
                using (ServiceController control = new ServiceController(serviceName))
                {
                    if (control.Status == ServiceControllerStatus.Running)
                    {
                        this.startServiceButton.Text = "サービス再起動";
                    }
                }
            }
            // add 2023-07-11 bug #8503 FNSiViewSyncServiceのCPU負荷が高い 崔 end
        }

        /// <summary>
        /// 固定時間同期を押す
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        private void syncModeRadioButton2_Click(object sender, EventArgs e)
        {
            // 更新間隔同期のチェック状態
            this.syncModeRadioButton1.Checked = false;
            // 固定時間同期のチェック状態
            this.syncModeRadioButton2.Checked = true;

            // 更新間隔(1回/何分)を設定する。
            this.updateIntervalTextBox.ReadOnly = true;
            this.updateIntervalTextBox.Enabled = false;
            this.updateIntervalTextBox.Text = "0";

            // 日時の時間
            this.timeDateTimePicker.Enabled = true;
            // 追加ボタン
            this.addButton.Enabled = true;
            // すべて日時データ
            this.timeTreeView.Enabled = true;

            // 月曜日
            this.monCheckBox.Enabled = true;
            // 火曜日
            this.tueCheckBox.Enabled = true;
            // 水曜日
            this.wedCheckBox.Enabled = true;
            // 木曜日
            this.thuCheckBox.Enabled = true;
            // 金曜日
            this.friCheckBox.Enabled = true;
            // 土曜日
            this.satCheckBox.Enabled = true;
            // 日曜日
            this.sunCheckBox.Enabled = true;
        }


        /// <summary>
        /// 日時の追加ボタンを押す
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        private void AddButton_Click(object sender, EventArgs e)
        {
            RemoveDeleteButton();

            // 追加の日時を取得する。
            DateTime selectedDateTime = timeDateTimePicker.Value;
            string time = selectedDateTime.ToString("HH:mm");

            // 日時は空の場合
            if (timeTreeView.Nodes.Count == 0)
            {
                // 日時を追加する。
                timeTreeView.Nodes.Add(time);
            }
            else {
                foreach (TreeNode node in timeTreeView.Nodes)
                {
                    // 同じ値の判断
                    if (node.Text.Equals(time))
                    {
                        return;
                    }
                }

                // add 2023-06-26 bug #6632 取込を行わない設定ができない  崔 start
                this.checkTimeAdd(time);
                // add 2023-06-26 bug #6632 取込を行わない設定ができない  崔 end
            }
        }

        /// <summary>
        /// 追加の日時を押す
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        private void timeTreeView_NodeMouseClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            if (lastRightClickedNode != e.Node)
            {
                RemoveDeleteButton();
            }

            if (e.Button == MouseButtons.Right)
            {
                // ノードを取得する。
                TreeNode node = e.Node;

                // 削除ボタンを初期化
                Button deleteButton = new Button();
                deleteButton.Text = "✖";
                deleteButton.Size = new Size(20, 20);
                deleteButton.Click += new EventHandler(DeleteButton_Click);
                Point location = new Point(e.Node.Bounds.Right + 5, e.Node.Bounds.Top + e.Node.Bounds.Height / 2 - deleteButton.Height / 2);
                deleteButton.Location = timeTreeView.PointToClient(timeTreeView.PointToScreen(location));
                timeTreeView.Controls.Add(deleteButton);
                deleteButton.Tag = node;

                timeTreeView.SelectedNode = e.Node;

                node.Tag = deleteButton;
                lastRightClickedNode = node;
            }
        }

        /// <summary>
        /// 削除ボタンを削除する。
        /// <param name="node"></param>
        /// </summary>
        private void RemoveDeleteButton()
        {
            if (lastRightClickedNode != null)
            {
                Button deleteButton = lastRightClickedNode.Tag as Button;
                timeTreeView.Controls.Remove(deleteButton);
                lastRightClickedNode = null;
            }
        }

        /// <summary>
        /// 日時データを削除する。
        /// <param name="node"></param>
        /// </summary>
        private void DeleteButton_Click(object sender, EventArgs e)
        {
            Button deleteButton = sender as Button;
            TreeNode node = deleteButton.Tag as TreeNode;

            // データを削除する
            timeTreeView.Nodes.Remove(node);

            timeTreeView.Controls.Remove(deleteButton);
        }

        /// <summary>
        /// View設定ボタンを押す。
        /// <param name="node"></param>
        /// </summary>
        private void setViewButton_Click(object sender, EventArgs e)
        {
            // View選択の判断  cc start 2022/6/6
            int checkCount = this.checkSelectCheck();
            if (checkCount == dataGridView3.Rows.Count)
            {
                MessageBox.Show("Viewを選択してください。");
                return;
            }
            // View選択の判断  cc end 2022/6/6

            // 更新間隔同期の場合
            if (this.syncModeRadioButton1.Checked)
            {
                foreach (DataGridViewRow row in dataGridView3.Rows)
                {
                    // View選択の判断
                    if (row.Cells[0].Value != null && bool.Parse(row.Cells[0].Value.ToString()))
                    {
                        // updateIntervalのバリデーションチェック
                        string updateInterval = this.updateIntervalTextBox.Text;
                        string min = ((string[])row.Cells[number_updateInterval].Tag)[0];
                        string max = ((string[])row.Cells[number_updateInterval].Tag)[1];
                        // 数値チェック
                        if (IsNumeric(updateInterval) == false)
                        {
                            MessageBox.Show("updateInterval" + "は数値で入力してください");
                        }
                        // 範囲チェック
                        if (IsWithinRange(updateInterval, min, max))
                        {
                            // updateIntervalを設定する
                            row.Cells[7].Value = this.updateIntervalTextBox.Text;
                            // timeを設定する
                            row.Cells[8].Value = "";
                            // weekを設定する
                            row.Cells[9].Value = "";
                        }
                        else
                        {
                            MessageBox.Show((string)row.Cells[number_name].Value + "のupdateIntervalは"+ min +"と"+ max +"の範囲で入力してください");
                            return;
                        }
                    }
                }
            }

            // 固定時間同期の場合
            if (this.syncModeRadioButton2.Checked)
            {
                foreach (DataGridViewRow row in dataGridView3.Rows)
                {
                    // View選択の判断
                    if (row.Cells[0].Value != null && bool.Parse(row.Cells[0].Value.ToString()))
                    {
                        // updateIntervalを設定する
                        row.Cells[7].Value = "";

                        // timeを設定する
                        List<string> nodeTextList = new List<string>();
                        foreach (TreeNode node in timeTreeView.Nodes)
                        {
                            nodeTextList.Add(node.Text);
                        }
                        string allNodeText = string.Join(",", nodeTextList);
                        row.Cells[8].Value = allNodeText;

                        // weekを設定する
                        List<string> weekList = new List<string>();
                        // 月曜日の判断
                        if (monCheckBox.Checked)
                        {
                            weekList.Add("1");
                        }
                        // 火曜日の判断
                        if (tueCheckBox.Checked)
                        {
                            weekList.Add("2");
                        }
                        // 水曜日の判断
                        if (wedCheckBox.Checked)
                        {
                            weekList.Add("3");
                        }
                        // 木曜日の判断
                        if (thuCheckBox.Checked)
                        {
                            weekList.Add("4");
                        }
                        // 金曜日の判断
                        if (friCheckBox.Checked)
                        {
                            weekList.Add("5");
                        }
                        // 土曜日の判断
                        if (satCheckBox.Checked)
                        {
                            weekList.Add("6");
                        }
                        // 日曜日の判断
                        if (sunCheckBox.Checked)
                        {
                            weekList.Add("0");
                        }
                        string weekText = string.Join(",", weekList);
                        row.Cells[9].Value = weekText;
                    }
                }
            }
        }

        /// <summary>
        /// 保存
        /// <param name="node"></param>
        /// </summary>
        private void saveButton_Click(object sender, EventArgs e)
        {
            try
            {
                // エラーチェック
                if (this.checkInputErr() == false)
                {
                    return;
                }

                // XMLファイル名作成
                String xmlfile = AppDomain.CurrentDomain.BaseDirectory;
                if (xmlfile.EndsWith("\\") == false)
                {
                    xmlfile += "\\";
                }
                xmlfile += this.XMLG_FILE_NAME;

                XmlDocument doc = new XmlDocument();
                XmlDeclaration dec = doc.CreateXmlDeclaration("1.0", "utf-8", null);
                doc.AppendChild(dec);

                XmlNode rootNode = doc.CreateElement("viewList");
                doc.AppendChild(rootNode);

                foreach (DataGridViewRow row in dataGridView3.Rows)
                {
                    if (String.IsNullOrEmpty((string)row.Cells[1].Value))
                    {
                        continue;
                    }

                    XmlNode rootViewNode = doc.CreateElement("view");

                    // name
                    XmlAttribute nameAttr = doc.CreateAttribute("name");
                    nameAttr.Value = (string)row.Cells[number_name].Value;
                    rootViewNode.Attributes.Append(nameAttr);

                    // key_name
                    XmlAttribute keyNameAttr = doc.CreateAttribute("key_name");
                    keyNameAttr.Value = (string)row.Cells[number_key_name].Value;
                    rootViewNode.Attributes.Append(keyNameAttr);

                    // disp_name
                    XmlAttribute dispNameAttr = doc.CreateAttribute("disp_name");
                    dispNameAttr.Value = (string)row.Cells[number_disp_name].Value;
                    rootViewNode.Attributes.Append(dispNameAttr);

                    // desc
                    XmlAttribute descAttr = doc.CreateAttribute("desc");
                    descAttr.Value = (string)row.Cells[number_desc].Value;
                    rootViewNode.Attributes.Append(descAttr);

                    // sqlcd
                    XmlAttribute sqlcdAttr = doc.CreateAttribute("sqlcd");
                    sqlcdAttr.Value = (string)row.Cells[number_sqlcd].Value;
                    rootViewNode.Attributes.Append(sqlcdAttr);

                    // Mode
                    XmlAttribute modeAttr = doc.CreateAttribute("Mode");
                    modeAttr.Value = (string)row.Cells[number_Mode].Value;
                    rootViewNode.Attributes.Append(modeAttr);


                    // is_init
                    XmlAttribute isInitAttr = doc.CreateAttribute("is_init");
                    isInitAttr.Value = (string)row.Cells[number_is_init].Value;
                    rootViewNode.Attributes.Append(isInitAttr);

                    // once_flg
                    XmlAttribute onceFlgAttr = doc.CreateAttribute("once_flg");
                    onceFlgAttr.Value = (string)row.Cells[number_once_flg].Value;
                    rootViewNode.Attributes.Append(onceFlgAttr);

                    // is_effect
                    XmlAttribute isEffectAttr = doc.CreateAttribute("is_effect");
                    isEffectAttr.Value = (string)row.Cells[number_is_effect].Value;
                    rootViewNode.Attributes.Append(isEffectAttr);

                    // keep_old_limit
                    XmlAttribute keepOldLimitAttr = doc.CreateAttribute("keep_old_limit");
                    keepOldLimitAttr.Value = (string)row.Cells[number_keep_old_limit].Value;
                    rootViewNode.Attributes.Append(keepOldLimitAttr);

                    // keep_new_limit
                    XmlAttribute keepNewLimitAttr = doc.CreateAttribute("keep_new_limit");
                    keepNewLimitAttr.Value = (string)row.Cells[number_keep_new_limit].Value;
                    rootViewNode.Attributes.Append(keepNewLimitAttr);

                    // past_range_total
                    XmlAttribute pastRangeTotalAttr = doc.CreateAttribute("past_range_total");
                    pastRangeTotalAttr.Value = (string)row.Cells[number_past_range_total].Value;
                    rootViewNode.Attributes.Append(pastRangeTotalAttr);

                    // future_range_total
                    XmlAttribute futureRangeTotalAttr = doc.CreateAttribute("future_range_total");
                    futureRangeTotalAttr.Value = (string)row.Cells[number_future_range_total].Value;
                    rootViewNode.Attributes.Append(futureRangeTotalAttr);

                    // up_range
                    XmlAttribute upRangeAttr = doc.CreateAttribute("up_range");
                    upRangeAttr.Value = (string)row.Cells[number_up_range].Value;
                    rootViewNode.Attributes.Append(upRangeAttr);

                    // updateInterval
                    XmlAttribute updateIntervalAttr = doc.CreateAttribute("updateInterval");
                    updateIntervalAttr.Value = (string)row.Cells[number_updateInterval].Value;
                    rootViewNode.Attributes.Append(updateIntervalAttr);

                    // time
                    XmlAttribute timeAttr = doc.CreateAttribute("time");
                    timeAttr.Value = (string)row.Cells[number_time].Value;
                    rootViewNode.Attributes.Append(timeAttr);

                    // week
                    XmlAttribute weekAttr = doc.CreateAttribute("week");
                    weekAttr.Value = (string)row.Cells[number_week].Value;
                    rootViewNode.Attributes.Append(weekAttr);


                    // テーブル情報取得(XMLより)
                    String lastStartDateStr = "";
                    String lastEndDateStr = "";

                    XmlDocument xdoc = CommonUtil.LoadDecryptedXml(xmlfile);
                    XmlNodeList xnlView = xdoc.SelectNodes("//viewList/view");

                    while (this.dataGridView1.Rows.Count != 1)
                    {
                        this.dataGridView1.Rows.RemoveAt(0);
                    }

                    foreach (XmlNode xn in xnlView)
                    {
                        if (xn.Attributes["key_name"].Value.Trim().Equals((string)row.Cells[2].Value))
                        {
                            lastStartDateStr = xn.Attributes["last_start_date"].Value.Trim();
                            lastEndDateStr = xn.Attributes["last_end_date"].Value.Trim();
                            break;
                        }
                    }

                    // last_start_date
                    XmlAttribute lastStartDateAttr = doc.CreateAttribute("last_start_date");
                    lastStartDateAttr.Value = lastStartDateStr;
                    rootViewNode.Attributes.Append(lastStartDateAttr);

                    // last_end_date
                    XmlAttribute lastEndDateAttr = doc.CreateAttribute("last_end_date");
                    lastEndDateAttr.Value = lastEndDateStr;
                    rootViewNode.Attributes.Append(lastEndDateAttr);

                    // exec_interval
                    XmlAttribute execIntervalAttr = doc.CreateAttribute("exec_interval");
                    execIntervalAttr.Value = (string)row.Cells[25].Value;
                    rootViewNode.Attributes.Append(execIntervalAttr);

                    // sqlfile
                    XmlAttribute sqlfileAttr = doc.CreateAttribute("sqlfile");
                    sqlfileAttr.Value = (string)row.Cells[26].Value;
                    rootViewNode.Attributes.Append(sqlfileAttr);

                    // min_past_range_total
                    XmlAttribute minPastRangeTotalAttr = doc.CreateAttribute("min_past_range_total");
                    minPastRangeTotalAttr.Value = ((string[])row.Cells[number_past_range_total].Tag)[0];
                    rootViewNode.Attributes.Append(minPastRangeTotalAttr);

                    // max_past_range_total
                    XmlAttribute maxPastRangeTotalAttr = doc.CreateAttribute("max_past_range_total");
                    maxPastRangeTotalAttr.Value = ((string[])row.Cells[number_past_range_total].Tag)[1];
                    rootViewNode.Attributes.Append(maxPastRangeTotalAttr);

                    // min_past_range_total
                    XmlAttribute minFutureRangeTotalAttr = doc.CreateAttribute("min_future_range_total");
                    minFutureRangeTotalAttr.Value = ((string[])row.Cells[number_future_range_total].Tag)[0];
                    rootViewNode.Attributes.Append(minFutureRangeTotalAttr);

                    // max_past_range_total
                    XmlAttribute maxFutureRangeTotalAttr = doc.CreateAttribute("max_future_range_total");
                    maxFutureRangeTotalAttr.Value = ((string[])row.Cells[number_future_range_total].Tag)[1];
                    rootViewNode.Attributes.Append(maxFutureRangeTotalAttr);

                    // min_up_range
                    XmlAttribute minUpRangeAttr = doc.CreateAttribute("min_up_range");
                    minUpRangeAttr.Value = ((string[])row.Cells[number_up_range].Tag)[0];
                    rootViewNode.Attributes.Append(minUpRangeAttr);

                    // max_up_range
                    XmlAttribute maxUpRangeAttr = doc.CreateAttribute("max_up_range");
                    maxUpRangeAttr.Value = ((string[])row.Cells[number_up_range].Tag)[1];
                    rootViewNode.Attributes.Append(maxUpRangeAttr);

                    // min_updateInterval
                    XmlAttribute minUpdateIntervalAttr = doc.CreateAttribute("min_updateInterval");
                    minUpdateIntervalAttr.Value = ((string[])row.Cells[number_updateInterval].Tag)[0];
                    rootViewNode.Attributes.Append(minUpdateIntervalAttr);

                    // max_updateInterval
                    XmlAttribute maxUpdateIntervalAttr = doc.CreateAttribute("max_updateInterval");
                    maxUpdateIntervalAttr.Value = ((string[])row.Cells[number_updateInterval].Tag)[1];
                    rootViewNode.Attributes.Append(maxUpdateIntervalAttr);

                    rootNode.AppendChild(rootViewNode);
                }

                doc.Save(xmlfile);

                MessageBox.Show("保存しました");

                this.definitionInitLoad();

                this.xmlInitLoad();

                // 全選択「CheckBox」を追加
                this.SelectCheckBoxsFormLoad();
            }
            catch (Exception ex)
            {
                MessageBox.Show("保存エラー");
            }
        }

        private bool DataGridView3IsXmlKeyNameExisted()
        {
            ArrayList checkList = new ArrayList();
            foreach (DataGridViewRow row in dataGridView3.Rows)
            {
                String keyName = (string)row.Cells[2].Value;
                if (String.IsNullOrEmpty(keyName))
                {
                    continue;
                }

                if (checkList.Contains(keyName))
                {
                    return true;
                }

                checkList.Add(keyName);
            }

            return false;
        }

        /// <summary>
        /// サービス再起動
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>

        private void startServiceButton_Click(object sender, EventArgs e)
        {
            // 不具合対応済 #6290 cc start 2023/6/7
            // 初期データ日付
            DateTime time1 = initialUpdatedDateDateTimePicker.Value;
            // システム時間
            DateTime time2 = DateTime.Now;
            if (DateTime.Compare(time1, time2) > 0)
            {
                MessageBox.Show("初期データ日付を未来日に設定することはできません。");
                return;
            }
            // 不具合対応済 #6290 cc end 2023/6/7

            // 初期データ日付を設定する。
            SystemSettingInfo sys = SystemSettingInfo.GetInstance();

            // 「fromDateColumnとtoDateColumn」Cell値を削除
            this.ValueClear();

            // FNSiViewSync.configにInitialUpdatedDateを設定する。
            sys.SetValue(CONFIG_COMMON_SECTION, "InitialUpdatedDate", this.initialUpdatedDateDateTimePicker.Value.ToString("yyyyMMddHHmmss"));

            sys.Save();

            // add 2023-07-11 bug #8503 FNSiViewSyncServiceのCPU負荷が高い 崔 start
            bool result = ServiceStart("FNSiViewSyncService");
            if (result)
            {
                this.startServiceButton.Text = "サービス再起動";
            }
            // add 2023-07-11 bug #8503 FNSiViewSyncServiceのCPU負荷が高い 崔 end
        }

        #region 全選択「CheckBox」を追加
        public delegate void DatagridviewcheckboxHeaderEventHander(object sender, DatagridviewCheckboxHeaderEventArgs e);
        private void SelectCheckBoxsFormLoad()
        {
            var ch = new DatagridviewCheckboxHeaderCell();
            ch.OnCheckBoxClicked += new DatagridviewcheckboxHeaderEventHander(ch_OnCheckBoxClicked);
            var checkboxCol = this.dataGridView3.Columns[0] as DataGridViewCheckBoxColumn;
            checkboxCol.HeaderCell = ch;
            checkboxCol.HeaderCell.Value = string.Empty;

            dataGridView3.Columns["fromDateColumn"].Visible = false;
            dataGridView3.Columns["toDateColumn"].Visible = false;
        }
        public class DatagridviewCheckboxHeaderCell : DataGridViewColumnHeaderCell
        {
            Point checkBoxLocation;
            Size checkBoxSize;
            bool _checked = false;
            Point _cellLocation = new Point();
            System.Windows.Forms.VisualStyles.CheckBoxState _cbState = System.Windows.Forms.VisualStyles.CheckBoxState.UncheckedNormal;
            public event DatagridviewcheckboxHeaderEventHander OnCheckBoxClicked;
            protected override void Paint(System.Drawing.Graphics graphics,
                                          System.Drawing.Rectangle clipBounds,
                                          System.Drawing.Rectangle cellBounds,
                                          int rowIndex,
                                          DataGridViewElementStates dataGridViewElementState,
                                          object value,
                                          object formattedValue,
                                          string errorText,
                                          DataGridViewCellStyle cellStyle,
                                          DataGridViewAdvancedBorderStyle advancedBorderStyle,
                                          DataGridViewPaintParts paintParts)
            {
                base.Paint(graphics, clipBounds, cellBounds, rowIndex, dataGridViewElementState, value, formattedValue, errorText, cellStyle, advancedBorderStyle, paintParts);
                Point p = new Point();
                Size s = CheckBoxRenderer.GetGlyphSize(graphics,
                System.Windows.Forms.VisualStyles.CheckBoxState.UncheckedNormal);
                p.X = cellBounds.Location.X + (cellBounds.Width / 2) - (s.Width / 2) - 1;
                p.Y = cellBounds.Location.Y + (cellBounds.Height / 2) - (s.Height / 2);
                _cellLocation = cellBounds.Location;
                checkBoxLocation = p;
                checkBoxSize = s;
                if (_checked)
                    _cbState = System.Windows.Forms.VisualStyles.CheckBoxState.CheckedNormal;
                else
                    _cbState = System.Windows.Forms.VisualStyles.CheckBoxState.UncheckedNormal;
                CheckBoxRenderer.DrawCheckBox(graphics, checkBoxLocation, _cbState);
            }
            protected override void OnMouseClick(DataGridViewCellMouseEventArgs e)
            {
                var p = new Point(e.X + _cellLocation.X, e.Y + _cellLocation.Y);
                if (p.X >= checkBoxLocation.X && p.X <= checkBoxLocation.X + checkBoxSize.Width && p.Y >= checkBoxLocation.Y && p.Y <= checkBoxLocation.Y + checkBoxSize.Height)
                {
                    _checked = !_checked;
                    var ex = new DatagridviewCheckboxHeaderEventArgs { CheckedState = _checked };
                    var sender = new object();
                    if (OnCheckBoxClicked != null)
                    {
                        OnCheckBoxClicked(sender, ex);
                        this.DataGridView.InvalidateCell(this);
                    }
                }
                base.OnMouseClick(e);
            }
        }
        public class DatagridviewCheckboxHeaderEventArgs : EventArgs
        {
            public DatagridviewCheckboxHeaderEventArgs() { CheckedState = false; }
            public bool CheckedState { get; set; }
        }
        private void ch_OnCheckBoxClicked(object sender, DatagridviewCheckboxHeaderEventArgs e)
        {
            // 現在のセルの編集操作をコミットして終了
            dataGridView3.EndEdit();
            for (int i = 0; i < dataGridView3.Rows.Count - 1; i++)
            {
                dataGridView3.Rows[i].Cells[0].Value = e.CheckedState;
            }
        }
        #endregion

        /// <summary>
        /// 「fromDateColumnとtoDateColumn」Cell値を削除
        /// </summary>
        private void ValueClear()
        {
            foreach (DataGridViewRow row in dataGridView3.Rows)
            {
                row.Cells["fromDateColumn"].Value = "";
                row.Cells["toDateColumn"].Value = "";
            }
        }

        /// <summary>
        /// 更新間隔は符号なし整数値のみ入力可
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void updateIntervalTextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!(e.KeyChar == '\b' || (e.KeyChar >= '0' && e.KeyChar <= '9')))
            {
                e.Handled = true;
            }
        }

        /// <summary>
        /// 入力フォーカスがコントロールを離れると発生
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void updateIntervalTextBox_Leave(object sender, EventArgs e)
        {
            if (this.updateIntervalTextBox.Text != null && int.Parse(this.updateIntervalTextBox.Text) < 5)
            {
                MessageBox.Show("更新間隔（分）5分以上の値を入力してください");
                updateIntervalTextBox.Focus();
            }
        }

        /// <summary>
        /// View選択の判断
        /// </summary>
        /// <returns></returns>
        private int checkSelectCheck()
        {
            int checkCount = 0;
            for (int i = 0; i < dataGridView3.Rows.Count; i++)
            {
                // View選択の判断
                if (dataGridView3.Rows[i].Cells["selectColumn"].Value == null ||
                    !bool.Parse(dataGridView3.Rows[i].Cells["selectColumn"].Value.ToString()))
                {
                    checkCount++;
                }
            }
            return checkCount;
        }

        // add 2023-06-14 bug #6205 取込を行わない設定ができない  崔 start
        /// <summary>
        /// 削除設定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void reSetViewButton_Click(object sender, EventArgs e)
        {
            foreach (DataGridViewRow row in dataGridView3.Rows)
            {
                // View選択の判断
                if (row.Cells[0].Value != null && bool.Parse(row.Cells[0].Value.ToString()))
                {
                    row.Cells[number_updateInterval].Value = "";
                    row.Cells[number_time].Value = "";
                    row.Cells[number_week].Value = "";
                }
            }
        }
        // add 2023-06-14 bug #6205 取込を行わない設定ができない  崔 end

        /// <summary>
        /// 入力時間チェック処理
        /// </summary>
        /// <param name="addTime"></param>
        private void checkTimeAdd(string addTime)
        {
            try
            {
                timeTreeView.Nodes.Add(addTime);
                timeTreeView.Sort();

                for (int i = 0; i < timeTreeView.Nodes.Count - 1; i++)
                {
                    for (int j = 0; j < timeTreeView.Nodes.Count - 1; j++)
                    {
                        int k = j + 1;
                        DateTime nodeFirst = DateTime.ParseExact(timeTreeView.Nodes[j].Text, "HH:mm", CultureInfo.InvariantCulture);
                        DateTime nodeSecond = DateTime.ParseExact(timeTreeView.Nodes[k].Text, "HH:mm", CultureInfo.InvariantCulture);
                        TimeSpan duration = nodeSecond - nodeFirst;
                        if (duration.Hours == 0 && duration.Minutes < 5)
                        {
                            if (addTime.Equals(timeTreeView.Nodes[j].Text))
                            {
                                timeTreeView.Nodes.Remove(timeTreeView.Nodes[j]);
                            }
                            else if (addTime.Equals(timeTreeView.Nodes[k].Text))
                            {
                                timeTreeView.Nodes.Remove(timeTreeView.Nodes[k]);
                            }
                            MessageBox.Show("更新間隔（分）5分以上の値を入力してください");
                            break;
                        }
                    }
                }
            }
            catch
            {
                // Exception
            }
        }
        /// <summary>
        /// コピー
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void copyButton_Click(object sender, EventArgs e)
        {
            int checkCount = this.checkSelectCheck();
            if (checkCount == dataGridView3.Rows.Count)
            {
                MessageBox.Show("Viewを選択してください。");
                return;
            }

            for (int i = 0; i < dataGridView3.Rows.Count; i++)
            {
                if (dataGridView3.Rows[i].Cells[0].Value != null && bool.Parse(dataGridView3.Rows[i].Cells[0].Value.ToString()))
                {
                    // 新しい行を指定した位置に挿入
                    DataGridViewRow row = (DataGridViewRow)dataGridView3.Rows[i].Clone();
                    row.Cells[0].Value = dataGridView3.Rows[i].Cells[0].Value;
                    row.Cells[1].Value = dataGridView3.Rows[i].Cells[1].Value;
                    row.Cells[2].Value = dataGridView3.Rows[i].Cells[2].Value;
                    row.Cells[3].Value = dataGridView3.Rows[i].Cells[3].Value;
                    row.Cells[4].Value = dataGridView3.Rows[i].Cells[4].Value;
                    row.Cells[5].Value = dataGridView3.Rows[i].Cells[5].Value;
                    row.Cells[6].Value = dataGridView3.Rows[i].Cells[6].Value;
                    row.Cells[7].Value = dataGridView3.Rows[i].Cells[7].Value;
                    row.Cells[8].Value = dataGridView3.Rows[i].Cells[8].Value;
                    row.Cells[9].Value = dataGridView3.Rows[i].Cells[9].Value;
                    row.Cells[10].Value = dataGridView3.Rows[i].Cells[10].Value;
                    row.Cells[11].Value = dataGridView3.Rows[i].Cells[11].Value;
                    row.Cells[12].Value = dataGridView3.Rows[i].Cells[12].Value;
                    row.Cells[13].Value = dataGridView3.Rows[i].Cells[13].Value;
                    row.Cells[14].Value = dataGridView3.Rows[i].Cells[14].Value;
                    row.Cells[15].Value = dataGridView3.Rows[i].Cells[15].Value;
                    row.Cells[16].Value = dataGridView3.Rows[i].Cells[16].Value;
                    row.Cells[17].Value = dataGridView3.Rows[i].Cells[17].Value;
                    row.Cells[18].Value = dataGridView3.Rows[i].Cells[18].Value;
                    row.Cells[19].Value = dataGridView3.Rows[i].Cells[19].Value;
                    row.Cells[20].Value = dataGridView3.Rows[i].Cells[20].Value;
                    row.Cells[21].Value = dataGridView3.Rows[i].Cells[21].Value;
                    row.Cells[22].Value = dataGridView3.Rows[i].Cells[22].Value;
                    row.Cells[23].Value = dataGridView3.Rows[i].Cells[23].Value;
                    row.Cells[24].Value = dataGridView3.Rows[i].Cells[24].Value;
                    row.Cells[25].Value = dataGridView3.Rows[i].Cells[25].Value;
                    row.Cells[26].Value = dataGridView3.Rows[i].Cells[26].Value;
                    dataGridView3.Rows.Insert(i+1, row);
                    i++;
                }
            }

            dataGridView3.Invalidate();

        }


        /// <summary>
        /// 入力値エラーチェック
        /// </summary>
        /// <returns>正常:true/異常:false</returns>
        private bool checkInputErr()
        {

            if (this.DataGridView3IsXmlKeyNameExisted())
            {
                MessageBox.Show("key_nameが重複しています");
                return false;
            }


            for (int i = 0; i < dataGridView3.Rows.Count; i++)
            {
                if(dataGridView3.Rows[i].Cells[1].Value != null)
                {
                    // 必須チェック
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_name].Value) == false)
                    {
                        MessageBox.Show("name" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_key_name].Value) == false)
                    {
                        MessageBox.Show("key_name" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_desc].Value) == false)
                    {
                        MessageBox.Show("desc" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_sqlcd].Value) == false)
                    {
                        MessageBox.Show("sqlcd" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_Mode].Value) == false)
                    {
                        MessageBox.Show("Mode" + "を入力してください");
                        return false;
                    }
                    int mode = Int32.Parse(dataGridView3.Rows[i].Cells[number_Mode].Value.ToString());
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_is_init].Value) == false)
                    {
                        MessageBox.Show("is_init" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_once_flg].Value) == false)
                    {
                        MessageBox.Show("once_flg" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_is_effect].Value) == false)
                    {
                        MessageBox.Show("is_effect" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_past_range_total].Value) == false && Mode.ACCUMULATION == mode)
                    {
                        MessageBox.Show("past_range_total" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_future_range_total].Value) == false && Mode.ACCUMULATION == mode)
                    {
                        MessageBox.Show("future_range_total" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_keep_old_limit].Value) == false && Mode.ACCUMULATION == mode)
                    {
                        MessageBox.Show("keep_old_limit" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_keep_new_limit].Value) == false && Mode.ACCUMULATION == mode)
                    {
                        MessageBox.Show("keep_new_limit" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_up_range].Value) == false && Mode.ACCUMULATION == mode)
                    {
                        MessageBox.Show("up_range" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_updateInterval].Value) == false &&
                        (IsRequired((string)dataGridView3.Rows[i].Cells[number_time].Value) == false && IsRequired((string)dataGridView3.Rows[i].Cells[number_week].Value) == false))
                    {
                        MessageBox.Show("updateIntervalまたはtime・week" + "を入力してください");
                        return false;
                    }
                    if (IsRequired((string)dataGridView3.Rows[i].Cells[number_exec_interval].Value) == false)
                    {
                        MessageBox.Show("exec_interval" + "を入力してください");
                        return false;
                    }

                    // 数値チェック
                    if (IsNumeric((string)dataGridView3.Rows[i].Cells[number_past_range_total].Value) == false)
                    {
                        MessageBox.Show("past_range_total" + "は数値で入力してください");
                        return false;
                    }
                    if (IsNumeric((string)dataGridView3.Rows[i].Cells[number_future_range_total].Value) == false)
                    {
                        MessageBox.Show("future_range_total" + "は数値で入力してください");
                        return false;
                    }
                    if (IsNumeric((string)dataGridView3.Rows[i].Cells[number_keep_old_limit].Value) == false)
                    {
                        MessageBox.Show("keep_old_limit" + "は数値で入力してください");
                        return false;
                    }
                    if (IsNumeric((string)dataGridView3.Rows[i].Cells[number_keep_new_limit].Value) == false)
                    {
                        MessageBox.Show("keep_new_limit" + "は数値で入力してください");
                        return false;
                    }
                    if (IsNumeric((string)dataGridView3.Rows[i].Cells[number_up_range].Value) == false)
                    {
                        MessageBox.Show("up_range" + "は数値で入力してください");
                        return false;
                    }
                    if (IsNumeric((string)dataGridView3.Rows[i].Cells[number_updateInterval].Value) == false)
                    {
                        MessageBox.Show("updateInterval" + "は数値で入力してください");
                        return false;
                    }
                    if (IsNumeric((string)dataGridView3.Rows[i].Cells[number_exec_interval].Value) == false)
                    {
                        MessageBox.Show("exec_interval" + "は数値で入力してください");
                        return false;
                    }

                    // 範囲チェック
                    string data = (string)dataGridView3.Rows[i].Cells[number_updateInterval].Value;
                    string min = ((string[])dataGridView3.Rows[i].Cells[number_updateInterval].Tag)[0];
                    string max = ((string[])dataGridView3.Rows[i].Cells[number_updateInterval].Tag)[1];
                    if (!IsWithinRange(data, min, max))
                    {
                        MessageBox.Show((string)dataGridView3.Rows[i].Cells[number_name].Value + "のupdateIntervalは" + min + "と" + max + "の範囲で入力してください");
                        return false;
                    }
                    data = (string)dataGridView3.Rows[i].Cells[number_past_range_total].Value;
                    min = ((string[])dataGridView3.Rows[i].Cells[number_past_range_total].Tag)[0];
                    max = ((string[])dataGridView3.Rows[i].Cells[number_past_range_total].Tag)[1];
                    if (!IsWithinRange(data, min, max))
                    {
                        MessageBox.Show((string)dataGridView3.Rows[i].Cells[number_name].Value + "のpast_range_totalは" + min + "と" + max + "の範囲で入力してください");
                        return false;
                    }
                    data = (string)dataGridView3.Rows[i].Cells[number_future_range_total].Value;
                    min = ((string[])dataGridView3.Rows[i].Cells[number_future_range_total].Tag)[0];
                    max = ((string[])dataGridView3.Rows[i].Cells[number_future_range_total].Tag)[1];
                    if (!IsWithinRange(data, min, max))
                    {
                        MessageBox.Show((string)dataGridView3.Rows[i].Cells[number_name].Value + "のfuture_range_totalは" + min + "と" + max + "の範囲で入力してください");
                        return false;
                    }
                    data = (string)dataGridView3.Rows[i].Cells[number_up_range].Value;
                    min = ((string[])dataGridView3.Rows[i].Cells[number_up_range].Tag)[0];
                    max = ((string[])dataGridView3.Rows[i].Cells[number_up_range].Tag)[1];
                    if (!IsWithinRange(data, min, max))
                    {
                        MessageBox.Show((string)dataGridView3.Rows[i].Cells[number_name].Value + "のup_rangeは" + min + "と" + max + "の範囲で入力してください");
                        return false;
                    }
                }

            }
            return true;
        }

        /// <summary>
        /// 数値チェック
        /// </summary>
        /// <param name="strData"></param>
        /// <returns></returns>
        private bool IsNumeric(string strData)
        {
            try
            {
                if (String.IsNullOrEmpty(strData))
                {
                    return true;
                }
                int.Parse(strData);
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 必須チェック
        /// </summary>
        /// <param name="strData"></param>
        /// <returns></returns>
        private bool IsRequired(string strData)
        {
            if (String.IsNullOrEmpty(strData))
            {
                return false;
            }
            return true;
        }

        /// <summary>
        /// 範囲チェック
        /// </summary>
        /// <param name="strData"></param>
        /// <returns></returns>
        private bool IsWithinRange(string strData, string min, string max)
        {
            try
            {
                if (int.Parse(strData) <= int.Parse(max) && int.Parse(strData) >= int.Parse(min)){
                    return true;
                } else
                {
                    return false;
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 同期設定が変更される
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// </summary>
        private void dataGridView3_CellValidated(object sender, DataGridViewCellEventArgs e)
        {
            int row = e.RowIndex;
            int column = e.ColumnIndex;

            // past_range_total、future_range_total、up_range以外はチェックしない
            if (row < 0 || !(column == number_past_range_total
                 || column == number_future_range_total || column == number_up_range))
            {
                return;
            }

            // xmlをロード中にはチェックしない
            if (String.IsNullOrEmpty((string)dataGridView3.Rows[row].Cells[column].Value))
            {
                return;
            }

            string data = (string)dataGridView3.Rows[row].Cells[column].Value;
            string min = ((string[])dataGridView3.Rows[row].Cells[column].Tag)[0];
            string max = ((string[])dataGridView3.Rows[row].Cells[column].Tag)[1];
            if (!IsWithinRange(data, min, max))
            {
                MessageBox.Show((string)dataGridView3.Rows[row].Cells[number_name].Value + "の" +
                    dataGridView3.Columns[column].Name + "は" + min + "と" + max + "の範囲で入力してください");
            }
        }
    }
}
