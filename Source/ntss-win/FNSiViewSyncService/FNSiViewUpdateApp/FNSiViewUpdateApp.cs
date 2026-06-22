using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using System.Windows.Forms.VisualStyles;
using System.Xml;
using FNSiViewSyncLogicLib;
using NKKLoggingLib;
using TdcLib;
using FNSiViewSyncLogicLib.Common.Utilities;
using System.ComponentModel;
using System.Reflection;
using System.Text.RegularExpressions;

using FNSiViewSyncLogicLib.Services;

namespace FNSiViewUpdateApp
{

    public partial class FNSiViewUpdateApp : Form
    {
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        private readonly String CONFIG_FILE_NAME = "FNSiViewUpdateApp.config";

        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        //Config同期結果の保存先
        /// </summary>
        public readonly String CONFIG_RESULT_RESULTFOLDER = "Settings\\Result";

        /// <summary>
        /// 設定ファイル内[ファイル共有]セッション識別子
        /// </summary>
        private readonly String CONFIG_SHARE_SECTION = "Settings\\Share";

        /// <summary>
        /// 設定ファイル内[ログ設定]セッション識別子
        /// </summary>
        private readonly string CONFIG_LOG_SERVICE = "Settings\\service";

        /// <summary>
        /// XMLファイル名
        /// </summary>
        private readonly String XMLG_FILE_NAME = "FNSiViewSync.xml";

        /// <summary>
        /// サービスのIP
        /// </summary>
        private String m_strServiceIPAddress = "127.0.0.1";

        /// <summary>
        /// サービスのポートNo
        /// </summary>
        private int m_nrServicePortNo = 7013;

        /// <summary>
        /// サービスのファイル共有のUserId
        /// </summary>
        private String m_nrShareUserId = "";

        /// <summary>
        /// サービスのファイル共有のパスワード
        /// </summary>
        private String m_nrSharePW = "";

        /// <summary>
        /// サービスのファイル共有のXMLパス
        /// </summary>
        private String m_nrShareXmlPath = "";

        /// <summary>
        /// サービスのファイル共有のログパス
        /// </summary>
        private String m_nrShareLogPath = "";

        /// <summary>
        /// サービスのファイル共有のログディレクトリ名
        /// </summary>
        private String m_nrShareLogDirectory = "";

        /// <summary>
        /// サービスのリトライ回数
        /// </summary>
        private int m_XmlRetryCount = 30;

        /// <summary>
        /// サービスのリトライ間隔ミリ秒
        /// </summary>
        private int m_XmlRetryInterval = 100;


        /// <summary>
        /// サービスのファイル共有のUserId
        /// </summary>
        private String m_ServiceUserId = "";

        /// <summary>
        /// サービスのファイル共有のパスワード
        /// </summary>
        private String m_ServicePW = "";

        /// <summary>
        /// サービスのファイル共有のログパス
        /// </summary>
        private String m_ServiceLogPath = "";

        /// <summary>
        /// ログ送信スレッド
        /// </summary>
        private Thread logWorkerThread;


        DateTimePicker dtp = new DateTimePicker();
        DataTable dt = new DataTable();
        DataTable dt2 = new DataTable();


        /// <summary>
        /// スレッドオブジェクト
        /// </summary>
        private readonly Thread m_Thread = null;

        /// <summary>
        /// スレッド終了用シグナル
        /// </summary>
        private readonly System.Threading.ManualResetEvent m_evFinish = new ManualResetEvent(false);


        public FNSiViewUpdateApp()
        {

            if (this.m_Thread != null)
            {
                // スレッド停止
                this.m_evFinish.Set();
            }

            InitializeComponent();

            this.FormClosing += new FormClosingEventHandler(FNSiViewUpdateApp_FormClosing);


            this.definitionInitLoad();

            this.table_struct();

            this.StartLogWorker();

            //this.xmlLoad();

        }

        ~FNSiViewUpdateApp()
        {
            if (this.m_Thread != null)
            {
                // スレッド停止
                this.m_evFinish.Set();
                AddLogInfo("スレッド停止: デストラクタ");
            }
        }

        private void FNSiViewUpdateApp_FormClosing(object sender, FormClosingEventArgs e)
        {
            AddLogInfo("アプリケーション終了");
            Environment.Exit(0);
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

            // Config 共有設定:ファイル共有のUserId
            m_nrShareUserId = sys.GetSingleLineValue(CONFIG_SHARE_SECTION, "UserId", String.Empty).Trim();

            // Config 共有設定:ファイル共有のPW
            m_nrSharePW = sys.GetSingleLineValue(CONFIG_SHARE_SECTION, "PW", String.Empty).Trim();


            // Config 共有設定:ファイル共有のLogパス
            m_nrShareLogPath = sys.GetSingleLineValue(CONFIG_SHARE_SECTION, "LogPath", String.Empty).Trim();

            // Config 共有設定:ファイル共有のLogディレクトリ名
            m_nrShareLogDirectory = sys.GetSingleLineValue(CONFIG_SHARE_SECTION, "LogFolder", String.Empty).Trim();
            if (String.IsNullOrEmpty(m_nrShareLogDirectory))
            {
                m_nrShareLogDirectory = "Log";
            }

            // ログ初期化
            InitializeSharedLog();

            // Config共通設定:初期更新日付(yyyyMMddhhmmss)
            FNSiViewSyncSetting.InitialUpdatedDate = "19700101000000";

            // Config Socket設定:IFエッジサービスのポートNo
            if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_RESULT_RESULTFOLDER, "ReSyncPortNo", String.Empty).Trim(), out int nwork10))
            {
                m_nrServicePortNo = nwork10;
            }

            // Config Socket設定:IFエッジサービスのIPアドレス
            m_strServiceIPAddress = sys.GetSingleLineValue(CONFIG_RESULT_RESULTFOLDER, "ReSyncIPAddress", String.Empty).Trim();

            // Config 共有設定:ファイル共有のXMLパス
            m_nrShareXmlPath = sys.GetSingleLineValue(CONFIG_SHARE_SECTION, "XmlPath", String.Empty).Trim();

            // Config 共有設定:リトライ回数
            m_XmlRetryCount = int.Parse(sys.GetSingleLineValue(CONFIG_SHARE_SECTION, "XMLRetryCount", "30")); 

            // Config 共有設定:リトライ間隔ミリ秒
            m_XmlRetryInterval = int.Parse(sys.GetSingleLineValue(CONFIG_SHARE_SECTION, "XMLRetryInterval", "100"));

            // サービス側設定
            // Config 共有設定:サービス側のUserId
            m_ServiceUserId = sys.GetSingleLineValue(CONFIG_LOG_SERVICE, "UserId", String.Empty).Trim();

            // Config 共有設定:サービス側のPW
            m_ServicePW = sys.GetSingleLineValue(CONFIG_LOG_SERVICE, "PW", String.Empty).Trim();

            // Config 共有設定:サービス側のLogパス
            m_ServiceLogPath = sys.GetSingleLineValue(CONFIG_LOG_SERVICE, "LogPath", String.Empty).Trim();

            // Config 共有設定:サービス側のLog送信時間
            FNSiViewSyncSetting.SendLogToBoxPath = sys.GetSingleLineValue(this.CONFIG_LOG_SERVICE, "SendLogToBox", "0000").Trim();

            this.dataGridView1.Columns[0].Visible = false;
            this.dataGridView1.Columns[1].Visible = false;
            this.dataGridView1.Columns[2].Visible = false;
            this.dataGridView1.Columns[3].Visible = false;
            this.dataGridView1.Columns[4].Visible = false;
            this.dataGridView1.Columns[5].Visible = false;
            this.dataGridView1.Columns[6].Visible = false;
            this.dataGridView1.Columns[7].Visible = false;
            this.dataGridView1.Columns[8].Visible = false;


            DataGridViewDisableButtonColumn column1 = new DataGridViewDisableButtonColumn();
            column1.Name = "更新ボタン";
            this.dataGridView1.Columns.Add(column1);

            DataGridViewTextBoxColumn column2 = new DataGridViewTextBoxColumn();
            column2.Name = "status";
            column2.HeaderText = "状態";
            column2.DataPropertyName = "status";
            this.dataGridView1.Columns.Add(column2);
        }


        private void table_struct()
        {
            dt.Columns.Add("name");
            dt.Columns.Add("key_name");
            dt.Columns.Add("disp_name");
            dt.Columns.Add("desc");
            dt.Columns.Add("sqlcd");
            dt.Columns.Add("Mode");
            dt.Columns.Add("is_init");
            dt.Columns.Add("once_flg");
            dt.Columns.Add("is_effect");
            dt.Columns.Add("keep_old_limit");
            dt.Columns.Add("keep_new_limit");
            dt.Columns.Add("past_range_total");
            dt.Columns.Add("future_range_total");
            dt.Columns.Add("up_range");
            dt.Columns.Add("updateInterval");
            dt.Columns.Add("time");
            dt.Columns.Add("week");
            dt.Columns.Add("last_start_date");
            dt.Columns.Add("last_end_date");
            dt.Columns.Add("exec_interval");
            dt.Columns.Add("button");
            dt.Columns.Add("status");

            dt2.Columns.Add("name");
            dt2.Columns.Add("key_name");
            dt2.Columns.Add("disp_name");
            dt2.Columns.Add("desc");
            dt2.Columns.Add("sqlcd");
            dt2.Columns.Add("Mode");
            dt2.Columns.Add("is_init");
            dt2.Columns.Add("once_flg");
            dt2.Columns.Add("is_effect");
            dt2.Columns.Add("keep_old_limit");
            dt2.Columns.Add("keep_new_limit");
            dt2.Columns.Add("past_range_total");
            dt2.Columns.Add("future_range_total");
            dt2.Columns.Add("up_range");
            dt2.Columns.Add("updateInterval");
            dt2.Columns.Add("time");
            dt2.Columns.Add("week");
            dt2.Columns.Add("last_start_date");
            dt2.Columns.Add("last_end_date");
            dt2.Columns.Add("exec_interval");
            dt2.Columns.Add("button");
            dt2.Columns.Add("status");

        }


        private String readShareXml()
        {
            string xmlString = "";

            string filePath = Path.Combine(m_nrShareXmlPath, XMLG_FILE_NAME);

            // ネットワーク共有へのアクセスを試みる
            try
            {
                // ネットワーク資格情報を使用して共有フォルダにアクセス
                using (new NetworkConnection(m_nrShareXmlPath, new NetworkCredential(m_nrShareUserId, m_nrSharePW)))
                {
                    // ファイルが存在するかチェック
                    if (File.Exists(filePath))
                    {
                        // ファイルの内容を読み取る
                        xmlString = File.ReadAllText(filePath);
                        Console.WriteLine("ファイルの内容:");
                        Console.WriteLine(xmlString);
                    }
                    else
                    {
                        AddLogInfo("ファイルが存在しません。");
                    }
                }
            }
            catch (Exception ex)
            {
                AddLogError($"エラーが発生しました: { ex.Message}");
            }

            return xmlString;
        }

        /// <summary>
        /// XML読み込み
        /// </summary>
        private void xmlLoad()
        {
            XmlDocument xdoc = new XmlDocument();

            // XMLドキュメントのロードと更新をリトライ
            int retries = m_XmlRetryCount;
            int retryMax = m_XmlRetryCount;
            int delay = m_XmlRetryInterval;

            while (true)
            {
                try
                {
                    if (string.IsNullOrEmpty(m_nrShareUserId) || string.IsNullOrEmpty(m_nrSharePW) || string.IsNullOrEmpty(m_nrShareXmlPath))
                    {
                        // XMLファイル名作成
                        String xmlfile = AppDomain.CurrentDomain.BaseDirectory;
                        xmlfile = getParentDirectory(xmlfile);
                        if (xmlfile.EndsWith("\\") == false)
                        {
                            xmlfile += "\\";
                        }
                        xmlfile += this.XMLG_FILE_NAME;

                        xdoc = CommonUtil.LoadDecryptedXml(xmlfile);
                    }
                    else
                    {
                        // XMLファイル名作成
                        String xmlString = readShareXml();
                        if (string.IsNullOrEmpty(xmlString))
                        {
                            AddLogInfo($"XML読み込みに失敗しました");
                            return;
                        }

                        using (FileStream fs = new FileStream(xmlString, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                        {
                            // テーブル情報取得(XMLより)
                            xdoc.Load(fs);
                        }
                    }
                    break; // 成功したらループを抜ける
                }
                catch (IOException ex)
                {
                    if (retries-- <= 0)
                    {
                        AddLogError($"XML読み込みに失敗しました: {ex.Message}");
                        MessageBox.Show("最新化処理に失敗しました 時間をおいて再度実行してください");
                        return;
                    }
                    AddLogInfo($"ファイルの読み込みに失敗したためリトライします。 {retryMax - retries}回目 {delay / 1000.0}秒間隔");
                    Thread.Sleep(delay);
                }
            }

            XmlNodeList xnlView = xdoc.SelectNodes("//viewList/view");

            dt.Clear();
            dt2.Clear();

            foreach (XmlNode xn in xnlView)
            {
                if (checkXmlNode(xn))
                {
                    Boolean isExists = false;
                    foreach (DataRow row in dt.Rows)
                    {
                        if (getXmlToString(xn, "disp_name").Equals(row[2].ToString()))
                        {
                            isExists = true;
                        }
                    }

                    if (!isExists)
                    {
                        dt.Rows.Add(
                            getXmlToString(xn, "name"),
                            getXmlToString(xn, "key_name"),
                            getXmlToString(xn, "disp_name"),
                            getXmlToString(xn, "desc"),
                            getXmlToString(xn, "sqlcd"),
                            getXmlToString(xn, "Mode"),
                            getXmlToString(xn, "is_init"),
                            getXmlToString(xn, "once_flg"),
                            getXmlToString(xn, "is_effect"),
                            getXmlToString(xn, "keep_old_limit"),
                            getXmlToString(xn, "keep_new_limit"),
                            getXmlToString(xn, "past_range_total"),
                            getXmlToString(xn, "future_range_total"),
                            getXmlToString(xn, "up_range"),
                            getXmlToString(xn, "updateInterval"),
                            getXmlToString(xn, "time"),
                            getXmlToString(xn, "week"),
                            getXmlToString(xn, "last_start_date"),
                            getXmlToString(xn, "last_end_date"),
                            getXmlToString(xn, "exec_interval"),
                            "更新",
                            getStatus(xn)
                            );
                    }
                    dt2.Rows.Add(
                        getXmlToString(xn, "name"),
                        getXmlToString(xn, "key_name"),
                        getXmlToString(xn, "disp_name"),
                        getXmlToString(xn, "desc"),
                        getXmlToString(xn, "sqlcd"),
                        getXmlToString(xn, "Mode"),
                        getXmlToString(xn, "is_init"),
                        getXmlToString(xn, "once_flg"),
                        getXmlToString(xn, "is_effect"),
                        getXmlToString(xn, "keep_old_limit"),
                        getXmlToString(xn, "keep_new_limit"),
                        getXmlToString(xn, "past_range_total"),
                        getXmlToString(xn, "future_range_total"),
                        getXmlToString(xn, "up_range"),
                        getXmlToString(xn, "updateInterval"),
                        getXmlToString(xn, "time"),
                        getXmlToString(xn, "week"),
                        getXmlToString(xn, "last_start_date"),
                        getXmlToString(xn, "last_end_date"),
                        getXmlToString(xn, "exec_interval"),
                        "更新",
                        getStatus(xn)
                        );
                }
                else
                {
                    AddLogInfo($"非表示テーブル:key_name={xn.Attributes["key_name"].Value.Trim()}");
                }
            }


            if (this.InvokeRequired)
            {
                this.Invoke(new Action(this.dataGridView1Refresh));
            }
            else
            {
                this.dataGridView1Refresh();
            }
            AddLogInfo($"XML読み込み成功");
        }

        private void dataGridView1Refresh()
        {
            dataGridView1.AutoGenerateColumns = false;
            dataGridView1.DataSource = dt;
            this.dataGridView1.Invalidate();

            for (int i = 0; i < dataGridView1.RowCount; i++)
            {
                dataGridView1.Rows[i].Cells["更新ボタン"].Value = "更新 ";


                DataGridViewDisableButtonCell buttonCell = (DataGridViewDisableButtonCell)dataGridView1.Rows[i].Cells["更新ボタン"];

                if (string.IsNullOrEmpty(dataGridView1.Rows[i].Cells["status"].Value.ToString().Trim()))
                {
                    buttonCell.Enabled = true;
                }
                else
                {
                    buttonCell.Enabled = false;

                }

            }

            dataGridView1.Invalidate();


        }

        private string getXmlToString(XmlNode xn, String key)
        {
            try
            {
                return xn.Attributes[key].Value.Trim();
            }
            catch
            {
                return "";
            }
        }


        /// <summary>
        /// テーブル毎のXmlのチェック
        /// </summary>
        /// <param name="xn"></param>
        /// <returns></returns>
        private bool checkXmlNode(XmlNode xn)
        {
            if (string.IsNullOrEmpty(xn.Attributes["disp_name"].Value.Trim()))
                return false;

            if (!IsNumeric(xn.Attributes["Mode"].Value.Trim()))
                return false;

            if (!IsNumeric(xn.Attributes["exec_interval"].Value.Trim()))
            {
                return false;

            }
            else
            {
                if (xn.Attributes["exec_interval"].Value.Trim().Equals("0"))
                    return false;
            }

            if ("1".Equals(xn.Attributes["Mode"].Value.Trim()))
            {
                if (!IsNumeric(xn.Attributes["keep_old_limit"].Value.Trim()))
                    return false;

                if (!IsNumeric(xn.Attributes["keep_new_limit"].Value.Trim()))
                    return false;

                if (!IsNumeric(xn.Attributes["past_range_total"].Value.Trim()))
                    return false;

                if (!IsNumeric(xn.Attributes["future_range_total"].Value.Trim()))
                    return false;

                if (!IsNumeric(xn.Attributes["up_range"].Value.Trim()))
                    return false;

            }

            return true;
        }

        /// <summary>
        /// ステータス取得
        /// </summary>
        /// <param name="xn"></param>
        /// <returns></returns>
        private string getStatus(XmlNode xn)
        {
            DateTime last_start_date = string.IsNullOrEmpty(xn.Attributes["last_start_date"].Value.Trim()) ? DateTime.ParseExact(FNSiViewSyncSetting.InitialUpdatedDate, "yyyyMMddHHmmss", null) : DateTime.ParseExact(xn.Attributes["last_start_date"].Value.Trim(), "yyyyMMddHHmmss", null);
            DateTime last_end_date = string.IsNullOrEmpty(xn.Attributes["last_end_date"].Value.Trim()) ? DateTime.ParseExact(FNSiViewSyncSetting.InitialUpdatedDate, "yyyyMMddHHmmss", null) : DateTime.ParseExact(xn.Attributes["last_end_date"].Value.Trim(), "yyyyMMddHHmmss", null);
            DateTime system_date = DateTime.Now;
            int exec_interval = int.Parse(xn.Attributes["exec_interval"].Value.Trim());

            if (last_start_date > last_end_date)
                return "処理中";

            if (last_end_date.AddMinutes(exec_interval) > system_date)
                return "処理中";


            return "";
        }

        /// <summary>
        /// 日付チェック
        /// </summary>
        /// <param name="strDate"></param>
        /// <returns></returns>
        private bool IsDate(string strDate)
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

        /// <summary>
        /// 数値チェック
        /// </summary>
        /// <param name="strData"></param>
        /// <returns></returns>
        private bool IsNumeric(string strData)
        {
            try
            {
                int.Parse(strData);
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 画面を閉じる
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_close_Click(object sender, EventArgs e)
        {
            Close();
        }

        /// <summary>
        /// データ送信実行
        /// </summary>
        private void DoWork(string name)
        {
            // オブジェクト
            Socket clientSocket = null;

            try
            {
                // ソケット構築
                clientSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                // 接続
                clientSocket.Connect(new IPEndPoint(IPAddress.Parse(this.m_strServiceIPAddress), this.m_nrServicePortNo));

                // 送信データを作成する
                String sendData = GetSendData(name);

                // 文字列をバイト シーケンスにエンコードする
                byte[] bdata = Encoding.UTF8.GetBytes(sendData);

                // 送信
                clientSocket.Send(bdata);

                // 切断
                clientSocket.Close();


                for (int i = 0; i < dataGridView1.RowCount; i++)
                {
                    dataGridView1.Rows[i].Cells["更新ボタン"].Value = "更新 ";

                    if (name.Equals(dataGridView1.Rows[i].Cells[9].Value))
                    {
                        DataGridViewDisableButtonCell buttonCell = (DataGridViewDisableButtonCell)dataGridView1.Rows[i].Cells["更新ボタン"];
                        buttonCell.Enabled = false;
                    }

                }

                dataGridView1.Invalidate();

            }
            catch (Exception ex)
            {
                if (clientSocket != null && clientSocket.Connected)
                {
                    clientSocket.Close();
                }
                AddLogError($"{ ex.Message}");
                MessageBox.Show(ex.Message);
            }
        }

        /// <summary>
        /// 送信データを作成する
        /// </summary>
        private String GetSendData(string name)
        {
            AddLogInfo($"更新ボタン押下: {name}");
            int sendDataCount = 0;
            List<string> keyNameList = new List<string>();
            StringBuilder sendData = new StringBuilder();
            for (int i = 0; i < dt2.Rows.Count; i++)
            {

                if (name.Equals(dt2.Rows[i][2].ToString()))
                {
                    sendDataCount++;
                    keyNameList.Add(dt2.Rows[i][1].ToString());
                    if (sendData.Length == 0)
                    {
                        sendData.Append("[");
                    }
                    else
                    {
                        sendData.Append(",");
                    }

                    sendData.Append("{");
                    sendData.Append(String.Format("\"key_name\":\"{0}\"", dt2.Rows[i][1].ToString()));
                    sendData.Append("}");

                }
            }
            sendData.Append("]");
            if(sendDataCount == 1)
            {
                AddLogInfo($"単独テーブル実行: {name}");
            }
            else
            {
                AddLogInfo($"複数テーブル実行: {name}:key_name:{string.Join(",", keyNameList.ToArray())}");
            }
            return sendData.ToString();
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            DataGridView dgv = (DataGridView)sender;
            //"Button"列ならば、ボタンがクリックされた
            if (dgv.Columns[e.ColumnIndex].Name == "更新ボタン" && e.RowIndex > -1)
            {
                SaveState(dataGridView1, out int selectedRowIndex, out int firstDisplayedScrollingRowIndex, out int selectedColumnIndex);

                this.xmlLoad();

                RestoreState(dataGridView1, selectedRowIndex, firstDisplayedScrollingRowIndex, selectedColumnIndex);

                DataGridViewDisableButtonCell buttonCell = (DataGridViewDisableButtonCell)dataGridView1.Rows[e.RowIndex].Cells["更新ボタン"];
                if (buttonCell.Enabled)
                {
                    string name = dataGridView1.Rows[e.RowIndex].Cells[9].Value.ToString();

                    DoWork(name);
                }
            }
        }

        private void dataGridView1_Sorted(object sender, EventArgs e)
        {
            dataGridView1Refresh();
        }

        private int isRunning = 0;

        /// <summary>
        /// 最新化
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_update_status_Click(object sender, EventArgs e)
        {
            button_update_status.Enabled = false;
            if (Interlocked.Exchange(ref isRunning, 1) == 1)
            {
                Console.WriteLine($"{DateTime.Now:HH:mm:ss.fff} [SKIP] 実行中クリックを無視");
                return;
            }


            try
            {
                AddLogInfo($"最新化開始");

                DataTable old_dt = dt.Copy();
                SaveState(dataGridView1, out int selectedRowIndex, out int scrollingPosition, out int selectedColumnIndex);

                // XML読み込み
                this.xmlLoad();

                RestoreState(dataGridView1, selectedRowIndex, scrollingPosition, selectedColumnIndex);
                DataTable changes = GetChanges(old_dt, dt);

                // 差分をログに記録
                foreach (DataRow row in changes.Rows)
                {
                    AddLogInfo($"disp_name: {row[0]} 処理中解除");
                }

                AddLogInfo($"最新化終了");
            }
            finally
            {
                button_update_status.Enabled = true;
                Interlocked.Exchange(ref isRunning, 0);
            }
        }

        private DataTable GetChanges(DataTable oldDt, DataTable newDt)
        {
            // 差分を格納するデータテーブル
            DataTable changes = newDt.Clone();

            // oldDtの行をキーを基準に検索し、比較
            foreach (DataRow oldRow in oldDt.Rows)
            {
                string key = oldRow[1].ToString();
                string oldStatus = oldRow[21].ToString();

                // 新しいデータテーブルからキーを基準に行を検索
                DataRow[] newRows = newDt.Select($"key_name = '{key}'");

                if (newRows.Length > 0)
                {
                    DataRow newRow = newRows[0];
                    string newStatus = newRow[21].ToString();

                    if (oldStatus == "処理中" && string.IsNullOrEmpty(newStatus))
                    {
                        changes.ImportRow(newRow);
                    }
                }
            }

            return changes;
        }


        private void FNSiViewUpdateApp_Load(object sender, EventArgs e)
        {
            // XML読み込み
            this.xmlLoad();
        }


        public static void SaveState(DataGridView dataGridView, out int selectedRowIndex, out int scrollingPosition, out int selectedColumnIndex)
        {
            // 現在の選択状態とスクロール位置を保存
            selectedRowIndex = dataGridView.CurrentCell != null ? dataGridView.CurrentCell.RowIndex : -1;
            selectedColumnIndex = dataGridView.CurrentCell != null ? dataGridView.CurrentCell.ColumnIndex : -1;
            scrollingPosition = dataGridView.FirstDisplayedScrollingRowIndex;
        }

        public static void RestoreState(DataGridView dataGridView, int selectedRowIndex, int scrollingPosition, int selectedColumnIndex)
        {
            // 選択状態を復元
            if (selectedRowIndex >= 0 && selectedRowIndex < dataGridView.Rows.Count &&
                selectedColumnIndex >= 0 && selectedColumnIndex < dataGridView.Columns.Count)
            {
                try
                {
                    dataGridView.CurrentCell = dataGridView.Rows[selectedRowIndex].Cells[selectedColumnIndex];
                }
                // 選択状態を復元出来なかった場合（更新後選択箇所が無くなっていた等）
                catch (InvalidOperationException)
                {
                    // セル選択を解除
                    dataGridView.CurrentCell = null;
                }
            }

            // スクロール位置を復元
            if (scrollingPosition >= 0 && scrollingPosition < dataGridView.Rows.Count)
            {
                try
                {
                    dataGridView.FirstDisplayedScrollingRowIndex = scrollingPosition;
                }
                // スクロール位置を復元出来なかった場合（更新後スクロール位置が無くなっていた等）
                catch (InvalidOperationException)
                {
                    // 一番上に移動
                    dataGridView.FirstDisplayedScrollingRowIndex = 0;
                }
            }
        }

        /// <summary>
        /// 親ディレクト取得
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        private string getParentDirectory(string path)
        {
            if (path.EndsWith(Path.DirectorySeparatorChar.ToString())) path = path.Substring(0, path.Length - 1);
            return Path.GetDirectoryName(path);
        }

        private void InitializeSharedLog()
        {
            try
            {
                NKKLogging log = NKKLogging.GetInstance();
                log.LogExt = "FNSiViewUpdateApp";
                if (string.IsNullOrEmpty(m_nrShareUserId) || string.IsNullOrEmpty(m_nrSharePW) || string.IsNullOrEmpty(m_nrShareLogPath))
                {
                    String path = AppDomain.CurrentDomain.BaseDirectory;
                    path = getParentDirectory(path);
                    string directoryPath = Path.Combine(path, m_nrShareLogDirectory);
                    log.LogFolder = directoryPath;
                }
                else
                {
                    // ネットワーク共有へのアクセスを試みる
                    string directoryPath = Path.Combine(m_nrShareLogPath, m_nrShareLogDirectory);

                    // ネットワーク資格情報を使用して共有フォルダにアクセス
                    using (new NetworkConnection(m_nrShareLogPath, new NetworkCredential(m_nrShareUserId, m_nrSharePW)))
                    {
                        log.LogFolder = directoryPath;
                    }
                }
                AddLogInfo("アプリケーション起動");
            }
            catch (Exception ex)
            {
                NKKLogging log = NKKLogging.GetInstance();
                log.LogExt = "FNSiViewUpdateApp";
                String path = AppDomain.CurrentDomain.BaseDirectory;
                path = getParentDirectory(path);
                string directoryPath = Path.Combine(path, m_nrShareLogDirectory);
                log.LogFolder = directoryPath;
                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "共有フォルダアクセス時に認証エラーが発生したため、ログ出力先をローカルに切り替えます");
                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "アプリケーション起動");
            }
        }

        private void AddLogInfo(String strMesssage)
        {
            // ネットワーク共有へのアクセスを試みる
            try
            {
                if (string.IsNullOrEmpty(m_nrShareUserId) || string.IsNullOrEmpty(m_nrSharePW) || string.IsNullOrEmpty(m_nrShareLogPath))
                {
                    FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strMesssage);

                }else{
                    // ネットワーク資格情報を使用して共有フォルダにアクセス
                    using (new NetworkConnection(m_nrShareLogPath, new NetworkCredential(m_nrShareUserId, m_nrSharePW)))
                    {
                        FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strMesssage);
                    }
                }

            }
            catch (Exception ex)
            {
                NKKLogging log = NKKLogging.GetInstance();
                log.LogExt = "FNSiViewUpdateApp";
                String path = AppDomain.CurrentDomain.BaseDirectory;
                path = getParentDirectory(path);
                string directoryPath = Path.Combine(path, m_nrShareLogDirectory);
                log.LogFolder = directoryPath;

                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "共有フォルダアクセス時に認証エラーが発生したため、ログ出力先をローカルに切り替えます");
                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strMesssage);
            }
        }

        private void AddLogError(String strMesssage)
        {
            // ネットワーク共有へのアクセスを試みる
            try
            {
                if (string.IsNullOrEmpty(m_nrShareUserId) || string.IsNullOrEmpty(m_nrSharePW) || string.IsNullOrEmpty(m_nrShareLogPath))
                {
                    FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strMesssage);

                }
                else
                {
                    // ネットワーク資格情報を使用して共有フォルダにアクセス
                    using (new NetworkConnection(m_nrShareLogPath, new NetworkCredential(m_nrShareUserId, m_nrSharePW)))
                    {
                        FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strMesssage);
                    }
                }

            }
            catch (Exception ex)
            {
                NKKLogging log = NKKLogging.GetInstance();
                log.LogExt = "FNSiViewUpdateApp";
                String path = AppDomain.CurrentDomain.BaseDirectory;
                path = getParentDirectory(path);
                string directoryPath = Path.Combine(path, m_nrShareLogDirectory);
                log.LogFolder = directoryPath;

                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "共有フォルダアクセス時に認証エラーが発生したため、ログ出力先をローカルに切り替えます");
                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strMesssage);
            }
        }

        private void StartLogWorker()
        {
            if (this.logWorkerThread != null && this.logWorkerThread.IsAlive)
            {
                return;
            }
            this.m_evFinish.Reset();
            this.logWorkerThread = new Thread(new ThreadStart(this.SendLogWorker))
            {
                Name = "Viewログ送信スレッド",
                IsBackground = true
            };
            this.logWorkerThread.Start();
        }

        private void SendLogWorker()
        {
            // 基準日
            string date = DateTime.Now.ToString("yyyyMMdd");

            while (!this.m_evFinish.WaitOne(0))
            {
                string dateTime = date + FNSiViewSyncSetting.SendLogToBox;
                string endDate = DateTime.Now.ToString("yyyyMMddHHmm");

                if (dateTime.CompareTo(endDate) <= 0)
                {
                    try
                    {
                        List<FileInfo> files = this.Createlog();

                        foreach (var fi in files)
                        {
                            if (fi == null || !fi.Exists)
                            {
                                continue;
                            }

                            if (CopyLogFilesToShare(fi))
                            {
                                this.AddLogInfo("サービス側にlog送信に成功");
                            }
                            else
                            {
                                this.AddLogInfo("サービス側にlog送信に失敗");
                            }
                        }

                        // 基準日を翌日に設定
                        date = DateTime.Now.AddDays(1.0).ToString("yyyyMMdd");
                    }
                    catch (Exception ex)
                    {
                        this.AddLogError("固定時間アップロード中に例外発生: " + ex.Message);
                    }
                }

                if (this.m_evFinish.WaitOne(60000))
                {
                    this.AddLogInfo("ログ送信スレッド終了(待機中)");
                    return;
                }
            }
            this.AddLogInfo("ログ送信スレッド終了");
        }


        private List<FileInfo> Createlog()
        {
            string basePath = GetBaseLogPath();

            bool useShare =
                !string.IsNullOrEmpty(m_nrShareUserId) &&
                !string.IsNullOrEmpty(m_nrSharePW) &&
                !string.IsNullOrEmpty(m_nrShareLogPath);

            if (useShare)
            {
                using (new NetworkConnection(
                           m_nrShareLogPath,
                           new NetworkCredential(m_nrShareUserId, m_nrSharePW)))
                {
                    return CreatelogCore(basePath);
                }
            }

            return CreatelogCore(basePath);
        }

        private List<FileInfo> CreatelogCore(string basePath)
        {
            var result = new List<FileInfo>();

            bool checkPath = this.IsValidFolderPath(basePath);
            if (!checkPath)
            {
                LogService.AddLogInfo(DateTime.Now,NKKLogging.LOGGING_CLASS.ERROR,
                    "LogFolderの指定されたパスが無効です。" + basePath);
                return result;
            }

            // 昨日のログ
            result.Add(new FileInfo(Path.Combine(
                basePath,
                $"FNSiViewUpdateApp_{DateTime.Now.AddDays(-1):yyyyMMdd}.log")));

            // 今日のログ
            result.Add(new FileInfo(Path.Combine(
                basePath,
                $"FNSiViewUpdateApp_{DateTime.Now:yyyyMMdd}.log")));

            return result;
        }

        private bool IsValidFolderPath(string val)
        {
            return new Regex("^([a-zA-Z]:\\\\)([-\\u4e00-\\u9fa5\\w\\s.()~!@#$%^&()\\[\\]{}+=]+\\\\?)*$").Match(val).Success;
        }

        private string GetBaseLogPath()
        {
            try
            {
                bool useShare =
                    !string.IsNullOrEmpty(m_nrShareUserId) &&
                    !string.IsNullOrEmpty(m_nrSharePW) &&
                    !string.IsNullOrEmpty(m_nrShareLogPath);

                if (useShare)
                {
                    return Path.Combine(m_nrShareLogPath, m_nrShareLogDirectory);
                }

                string exeDir = AppDomain.CurrentDomain.BaseDirectory;
                string parent = getParentDirectory(exeDir);
                return Path.Combine(parent, m_nrShareLogDirectory);
            }
            catch (Exception)
            {
                NKKLogging log = NKKLogging.GetInstance();
                log.LogExt = "FNSiViewUpdateApp";
                String parent = AppDomain.CurrentDomain.BaseDirectory;
                parent = getParentDirectory(parent);
                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "共有フォルダアクセス時に認証エラーが発生したため、ログ出力先をローカルに切り替えます");
                return Path.Combine(parent, m_nrShareLogDirectory);
            }
        }

        /// <summary>
        /// 共有フォルダにログファイルをコピーする
        /// </summary>
        private bool CopyLogFilesToShare(params FileInfo[] files)
        {
            bool useShare =
                !string.IsNullOrEmpty(m_ServiceUserId) &&
                !string.IsNullOrEmpty(m_ServicePW) &&
                !string.IsNullOrEmpty(m_ServiceLogPath);

            if (!useShare)
            {
                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "共有フォルダの設定が不完全なため、ログを送信できません。");
                return false;
            }

            string logDir = m_ServiceLogPath;

            try
            {
                using (new NetworkConnection(logDir,
                           new NetworkCredential(m_ServiceUserId, m_ServicePW)))
                {
                    foreach (var file in files)
                    {
                        if (file == null || !file.Exists)
                        {
                            continue;
                        }

                        string logPath = Path.Combine(logDir, file.Name);

                        File.Copy(file.FullName, logPath, overwrite: true);
                    }
                }
            }
            catch (Exception ex)
            {
                FNSiViewSyncLogicLib.Services.LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "共有フォルダへのコピー中に例外発生: " + ex.Message);
            }
            return true;
        }

    }


    public class DataGridViewDisableButtonColumn : DataGridViewButtonColumn
    {
        public DataGridViewDisableButtonColumn()
        {
            this.CellTemplate = new DataGridViewDisableButtonCell();
        }
    }

    public class DataGridViewDisableButtonCell : DataGridViewButtonCell
    {
        private bool enabledValue;
        public bool Enabled
        {
            get
            {
                return enabledValue;
            }
            set
            {
                enabledValue = value;
            }
        }

        public override object Clone()
        {
            DataGridViewDisableButtonCell cell =
                (DataGridViewDisableButtonCell)base.Clone();
            cell.Enabled = this.Enabled;
            return cell;
        }

        public DataGridViewDisableButtonCell()
        {
            this.enabledValue = true;
        }

        protected override void Paint(Graphics graphics,
            Rectangle clipBounds, Rectangle cellBounds, int rowIndex,
            DataGridViewElementStates elementState, object value,
            object formattedValue, string errorText,
            DataGridViewCellStyle cellStyle,
            DataGridViewAdvancedBorderStyle advancedBorderStyle,
            DataGridViewPaintParts paintParts)
        {
            if (!this.enabledValue)
            {
                if ((paintParts & DataGridViewPaintParts.Background) ==
                    DataGridViewPaintParts.Background)
                {
                    SolidBrush cellBackground =
                        new SolidBrush(cellStyle.BackColor);
                    graphics.FillRectangle(cellBackground, cellBounds);
                    cellBackground.Dispose();
                }

                if ((paintParts & DataGridViewPaintParts.Border) ==
                    DataGridViewPaintParts.Border)
                {
                    PaintBorder(graphics, clipBounds, cellBounds, cellStyle,
                        advancedBorderStyle);
                }

                Rectangle buttonArea = cellBounds;
                Rectangle buttonAdjustment =
                    this.BorderWidths(advancedBorderStyle);
                buttonArea.X += buttonAdjustment.X;
                buttonArea.Y += buttonAdjustment.Y;
                buttonArea.Height -= buttonAdjustment.Height;
                buttonArea.Width -= buttonAdjustment.Width;

                ButtonRenderer.DrawButton(graphics, buttonArea,
                    PushButtonState.Disabled);

                if (this.FormattedValue is String)
                {
                    TextRenderer.DrawText(graphics,
                        (string)this.FormattedValue,
                        this.DataGridView.Font,
                        buttonArea, SystemColors.GrayText);
                }
            }
            else
            {
                base.Paint(graphics, clipBounds, cellBounds, rowIndex,
                    elementState, value, formattedValue, errorText,
                    cellStyle, advancedBorderStyle, paintParts);
            }
        }
    }
}
