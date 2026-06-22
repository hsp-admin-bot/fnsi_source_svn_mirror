#region アセンブリ System.Net.Http.WebRequest, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a
// C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5\System.Net.Http.WebRequest.dll
#endregion

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using NKKCommon;
using NKKLoggingLib;
using NKKWebAccessLib;
using SignInLib;

// add #8915 処理中にウインドウズの×を押された時の制御がない 董昊 start
using LayoutDesignerUtilityLib.Controls;
// add #8915 処理中にウインドウズの×を押された時の制御がない 董昊 end

namespace CoopEventCreateOrStopTool
{
    public partial class CoopEventCreatOrStopForm : LayoutDesignerUtilityLib.Controls.frmRldBase
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly String POST_PAT_SEARCH_URI = "/ntss-admin-web/api/pat_event/";
        private static readonly String POST_PAT_SEND_URI = "/ntss-coop-api/journal/create";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 製品名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public const String PRODUCT_NAME = "連携イベント作成・中止ツール";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ope_cd
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly Dictionary<string, (string create, string delete)> OpeCodeMap = new Dictionary<string, (string create, string delete)>()
        {
            { "default",   ("900004", "900004") },
            { "ind_dial",  ("901001", "901002") },
            { "rst_dial",  ("901003", "901004") },
            { "rep_dial",  ("901005", "901006") },
            { "exam_ord",  ("901007", "901008") },
            { "rad_ord",   ("901009", "901010") },
            { "phy_ord",   ("901011", "901012") },

            // 新規のみ
            { "pre_ord",   ("901013", null) },
            { "vit_cop",   ("901014", null) },

            { "karte_ord", ("901015", "901016") },
            { "iji_dial",  ("901017", "901018") }
        };
        
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 作成更新区分
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly String CRUD_CREATE = "C";
        private static readonly String CRUD_DELETE = "D";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 期間開始
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String dateFrom = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 期間終了
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String dateTo = String.Empty;

        /// <summary>
        /// 
        /// </summary>
        private static String facility = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 患者情報取得FLG
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Boolean patInfoFlg = false;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 中断FLG
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Boolean threadFlg = true;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// progressBarの位置
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int iBarpos;

        // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 送信失敗時のエラーメッセージ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String sendErrMsg = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 送信失敗時のポップアップウィンドウの追加情報
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String popUpAddMsg = String.Empty;

        //add #9034 dongzhaolong start
        private static int popUpAddPatCnt = 0;
        //add #9034 dongzhaolong end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 送信失敗時のポップアップウィンドウの追加情報数
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static int popUpAddMsgCnt = 0;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設名前
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String facilityName = String.Empty;
        // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
        //add 9035 zhu start
        List<MyJson.PatInfo> onePatInfo = new List<MyJson.PatInfo>();
        List<MyJson.PatInfo> listDbData = new List<MyJson.PatInfo>();
        //add 9035 zhu end

        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
        private static string percent = string.Empty;
        private static int rowIndex = 0;
        private static bool sendOver = false;
        private static string lastPatID = string.Empty;
        private static int lastSendCount = 0;
        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end


        /// <summary>
        /// 連携イベント作成・中止ツール画面を初期化。
        /// </summary>
        /// <returns></returns>
        public CoopEventCreatOrStopForm()
        {
            InitializeComponent();

            // add #12243 連携イベント作成ツール　アイコン差し替え 高 start
            // アイコンの設定
            this.Icon = Properties.Resources.CoopEventCreateTool;
            // add #12243 連携イベント作成ツール　アイコン差し替え 高 end

            LogManagement.LogMessage = "連携イベント作成・中止ツールが起動しました。";
            LogManagement.SetLogingProperties();

            try
            {
                NKKLogging wLogging = NKKLogging.GetInstance();
                // 施設を設定する

                //mod 20210218  #6144 変更施設 鄭 start
                // labHotokoseShow.Text = SignInLib.SignIn.SignInInfo.FacilityCode;
                var retPatInfo = CoopEventCreatOrStopForm.SeachFacilityCd();
                List<string> FacilityCd = MyJson.Conv<List<string>>.Deserialize(retPatInfo.getData);
                if (SignInLib.SignIn.SignInInfo.FacilityCode.Equals("nkknkk"))
                {
                    //add #9434 キャンセルの動きが不正なため不要 donghao start
                    comboBox1.Items.Add("未選択");
                    //add #9434 キャンセルの動きが不正なため不要 donghao end

                    foreach (var item in FacilityCd)
                    {
                        comboBox1.Items.Add(item);
                    }
                    comboBox1.Visible = true;
                    labHotokoseShow.Visible = false;
                    comboBox1.SelectedIndex = 0;
                }
                else
                {
                    labHotokoseShow.Text = SignInLib.SignIn.SignInInfo.FacilityCode;
                    foreach (var item in FacilityCd)
                    {
                        if (item.Split('/')[0].CompareTo(SignInLib.SignIn.SignInInfo.FacilityCode) == 0)
                        {
                            labHotokoseShow.Text = item;
                        }
                    }
                    comboBox1.Visible = false;
                    labHotokoseShow.Visible = true;
                }

                //mod 20210218   #6144: 変更施設 鄭 end

                // 「ComboxXML.xml」に種別が取得し、取得したの種別は画面に設定する
                // mod #6141 患者の抽出条件が不明 歴程 start
                //string path = "comboxXML.xml";
                string RunningPath = AppDomain.CurrentDomain.BaseDirectory;
                string path = RunningPath + "ComboxXML.xml";
                // mod #6141 患者の抽出条件が不明 歴程 end
                XmlDocument xmlDoc = new XmlDocument();
                XmlReaderSettings settings = new XmlReaderSettings
                {
                    IgnoreComments = true
                };
                // 「ComboxXML.xml」の内容を読み込み
                XmlReader reader = XmlReader.Create(path, settings);
                xmlDoc.Load(reader);
                XmlNode xn = xmlDoc.SelectSingleNode("comboxList");
                XmlNodeList xnl = xn.ChildNodes;
                ComboBoxItem comItem = new ComboBoxItem();
                if (xnl.Count == 0)
                {
                    MessageBox.Show(this, "種別が取得失敗。", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                foreach (XmlNode Xnl in xnl)
                {
                    // 取得したの種別は画面に設定する
                    comItem = new ComboBoxItem();
                    XmlElement xe1 = (XmlElement)Xnl;
                    XmlNodeList xnl0 = xe1.ChildNodes;
                    comItem.Value = xnl0.Item(0).InnerText;
                    comItem.Text = xnl0.Item(1).InnerText;
                    comItem.Kbn = xnl0.Item(2).InnerText;

                    //mod 20210218  #6138: <sendKbn>値がSであるカテゴリを表示します 鄭 start
                    //if (string.CompareOrdinal((string)comItem.Kbn, "S") != 0)
                    //{
                    //    comSyubetu.Items.Add(comItem);
                    //}

                    if (string.CompareOrdinal((string)comItem.Kbn, "N") != 0)
                    {
                        comSyubetu.Items.Add(comItem);
                    }
                    //mod 20210218   #6138: <sendKbn>値がSであるカテゴリを表示します 鄭 end
                }

                //add #9434 キャンセルの動きが不正なため不要 donghao start
                if (comboBox1.Text == "未選択")
                {
                    btnSearch.Enabled = false;
                }
                else
                {
                    btnSearch.Enabled = true;
                }
                //add #9434 キャンセルの動きが不正なため不要 donghao end
                // ボタン制御する
                btnSend.Enabled = false;
                //mod 20210218  #6144 非表示ボタンす 鄭 start
                //btnStop.Enabled = false;
                btnStop1.Visible = false;
                //mod 20210218   #6144: 非表示ボタンす 鄭 end
                iBarpos = 0;
                comSyubetu.SelectedIndex = 0;
                dateKikanFrom.Value = DateTime.Now;
                dateKikanTo.Value = DateTime.Now.AddMonths(3);
            }
            catch
            {

                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("連携イベント作成・中止ツール画面を初期化失敗しました。", "", ""));
            }
        }

        /// <summary>
        /// キャンセルボタンを押下する。
        /// </summary>
        /// <returns></returns>
        private void BtnCancel_Click(object sender, EventArgs e)
        {
            // mod #9434 キャンセルの動きが不正  donghao start
            //// 終了確認
            //if (MessageBox.Show(this, "終了してもよろしいですか？", PRODUCT_NAME, MessageBoxButtons.OKCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) == DialogResult.OK)
            //{
            //    // アプリケーションの終了
            //    this.Close();
            //}
            //else
            //{               
            //    return;
            //}
            if (NKKWebAccess.FacilityCd.Equals("nkknkk"))
            {
                comboBox1.Visible = true;
                labHotokoseShow.Visible = false;
                comboBox1.SelectedIndex = 0;
            }
            else
            {
                comboBox1.Visible = false;
                labHotokoseShow.Visible = true;
            }

            comSyubetu.SelectedIndex = 0;

            radioCoopEventCreat.Checked = true;
            radioCoopEventStop.Checked = false;

            dateKikanFrom.Value = DateTime.Now;
            dateKikanTo.Value = DateTime.Now.AddMonths(3);

            dataGridKansya.Refresh();
            dataGridKansya.DataSource = null;
            dataGridKansya.Rows.Clear();
            btnSend.Enabled = false;

            progressBar.Value = 0;
            progressBar.Visible = false;

            //this.Close();
            // mod #9434 キャンセルの動きが不正  donghao end

            LogManagement.LogMessage = "連携イベント作成・中止ツールが初期化しました。";
            LogManagement.SetLogingProperties();
        }

        /// <summary>
        /// 検索ボタンを押下する。
        /// </summary>
        /// <returns></returns>
        private void BtnSearch_Click(object sender, EventArgs e)
        {
            //add 9035 zhu start
            onePatInfo.Clear();
            listDbData.Clear();
            //add 9035 zhu end
            // 検索条件チェック
            dateFrom = dateKikanFrom.Text;
            dateTo = dateKikanTo.Text;

            DateTime dtFrom = Convert.ToDateTime(dateFrom);
            DateTime dtTo = Convert.ToDateTime(dateTo);

            // add 20210820  トグルボタン表示 -- 鄭 start
            btnStop1.Visible = false;
            btnSend.Visible = true;
            btnCancel.Enabled = false;
            // add 20210816 トグルボタン表示 -- 鄭 end

            // add 20210818 選択したカテゴリを取得します,選ばれる連携イベント -- 鄭 start
            // 種別を取得
            ComboBoxItem comItem = (ComboBoxItem)comSyubetu.SelectedItem;
            String strSyubetu = (String)comItem.Value;
            checKBox1.Checked = false;
            string strkbn;
            if (radioCoopEventCreat.Checked)
            {
                strkbn = CRUD_CREATE;
            }
            else
            {
                strkbn = CRUD_DELETE;
            }

            if (NKKWebAccess.FacilityCd.Equals("nkknkk"))
            {
                // mod #6142 施設の変更ができない 歴程 start
                //facility = comboBox1.Text;
                if (comboBox1.Text.IndexOf("/") != -1)
                {
                    facility = comboBox1.Text.Substring(0, comboBox1.Text.IndexOf("/"));
                }
                else
                {
                    facility = comboBox1.Text;
                }
                // mod #6142 施設の変更ができない 歴程 end
            }
            else
            {
                facility = NKKWebAccess.FacilityCd;
            }
            // add 20210818 選択したカテゴリを取得します,選ばれる連携イベント -- 鄭 end
            if (NKKWebAccess.FacilityCd.Equals("nkknkk"))
            {
                if (comboBox1.Text.IndexOf("/") != -1)
                {
                    facilityName = comboBox1.Text.Substring(comboBox1.Text.IndexOf("/") + 1);
                }
                else
                {
                    facilityName = comboBox1.Text;
                }
            }
            else
            {
                if (labHotokoseShow.Text.IndexOf("/") != -1)
                {
                    facilityName = labHotokoseShow.Text.Substring(labHotokoseShow.Text.IndexOf("/") + 1);
                }
                else
                {
                    facilityName = labHotokoseShow.Text;
                }
            }
            // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
            // 施設名前

            // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end

            // 期間指定開始日＞期間指定終了日の場合
            if (DateTime.Compare(dtFrom, dtTo) > 0)
            {
                MessageBox.Show("期間指定終了日は期間指定開始日より以降の日付を入力してください。", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // 患者情報を取得する
#pragma warning disable IDE0042 // 変数の宣言を分解
            var retPatInfo = CoopEventCreatOrStopForm.SeachKansyaInfo(strSyubetu, strkbn);
#pragma warning restore IDE0042 // 変数の宣言を分解

            //List<string> RepeatName;
            if (false == retPatInfo.isSuccess)
            {
                MessageBox.Show($"患者情報の取得に失敗しました。\r\n\r\n[{retPatInfo.errorReasonPhrase}]", Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                patInfoFlg = false;
                return;
            }
            else
            {
                listDbData = MyJson.Conv<List<MyJson.PatInfo>>.Deserialize(retPatInfo.getData);
                onePatInfo = listDbData.GroupBy(d => new { d.PatId }).Select(d => d.First()).ToList();
                patInfoFlg = true;
                // mod #9409 検出された患者が全て同姓同名表示がされてしまっている donghao start
                // add 20210820 重複する名前を探す -- 鄭 start
                /*  List<string> Name = listDbData.Select(x => x.PatNm).ToList();
                  RepeatName = Name.GroupBy(x => x).Where(x => x.Count() > 1).Select(x => x.Key).ToList();*/
                //List<string> Name = onePatInfo.Select(x => x.PatNm).ToList();
                //RepeatName = Name.GroupBy(x => x).Where(x => x.Count() > 1).Select(x => x.Key).ToList();
                // mod #9409 検出された患者が全て同姓同名表示がされてしまっている donghao end

                // add 20210820 重複する名前を探す -- 鄭 start
                //add 9035 zhu start
                //onePatInfo = listDbData.GroupBy(d => new { d.PatId }).Select(d => d.First()).ToList();
                foreach (MyJson.PatInfo patInfo in onePatInfo)
                {
                    patInfo.SumNo = listDbData.FindAll(x => x.PatId == patInfo.PatId).Count;
                }
                //add 9035 zhu end 
            }

            if (patInfoFlg)
            {
                // 患者情報を初期化
                dataGridKansya.Rows.Clear();

                // 患者情報が存在の場合
                if (listDbData.Count > 0)
                {


                    // del 20210220 #6144:患者カードの作成ができないの対応 鄭 start
                    //dataGridKansya.Rows.Add();
                    //dataGridKansya.Rows[0].Cells[1].Value = "全選";
                    //dataGridKansya.Rows[0].Cells[2].Value = "";
                    //dataGridKansya.Rows[0].Cells[3].Value = "";
                    //dataGridKansya.Rows[0].Cells[4].Value = "";
                    //dataGridKansya.Rows[0].Cells[5].Value = "";
                    // del 20210220 #6144:患者カードの作成ができないの対応 鄭 start

                    //mod 2021820  #6144:値を変更する 鄭 start
                    //int i = 1;
                    int i = 0;
                    //mod 2021820  #6144:値を変更する 鄭 end
                    //update 9035 zhu start
                    //foreach (MyJson.PatInfo patInfo in listDbData)
                    foreach (MyJson.PatInfo patInfo in onePatInfo)
                    //update 9035 zhu end
                    {

                        dataGridKansya.Rows.Add();
                        //mod 20210218  #6144: 値の位置を変更します 鄭 start

                        //dataGridKansya.Rows[i].Cells[1].Value = patInfo.PatNm;
                        //dataGridKansya.Rows[i].Cells[2].Value = patInfo.PatId;
                        //dataGridKansya.Rows[i].Cells[3].Value = patInfo.OrdNo;
                        //dataGridKansya.Rows[i].Cells[4].Value = patInfo.TreatDate;
                        //dataGridKansya.Rows[i].Cells[5].Value = patInfo.HosppatId;

                        dataGridKansya.Rows[i].Cells[1].Value = patInfo.HosppatId;

                        // mod 20210820 #6144:同じ名前と名前のロゴを追加します 鄭 start

                        // dataGridKansya.Rows[i].Cells[2].Value = patInfo.PatNm;
                        //mod #9409 検出された患者が全て同姓同名表示がされてしまっている 董 start
                        //if (RepeatName.Contains(patInfo.PatNm))
                        if (!string.IsNullOrEmpty(patInfo.Isname))
                        {
                            if (patInfo.Isname.Contains("1"))
                            {
                                dataGridKansya.Rows[i].Cells[2].Value = patInfo.PatNm;
                                //dataGridKansya.Rows[i].Cells[2].Style.BackColor = System.Drawing.SystemColors.ControlDarkDark;
                                // dataGridKansya.Rows[i].Cells[2].Style.ForeColor = Color.Red;
                                string RunningPath = AppDomain.CurrentDomain.BaseDirectory;
                                Image image = Image.FromFile(RunningPath + "Img\\name.png");
                                dataGridKansya.Rows[i].Cells[6].Value = image;

                            }
                            else
                            {
                                dataGridKansya.Rows[i].Cells[2].Value = patInfo.PatNm;
                                dataGridKansya.Rows[i].Cells[6].Style.NullValue = null;
                            }
                        }
                        else
                        {
                            dataGridKansya.Rows[i].Cells[2].Value = patInfo.PatNm;
                            dataGridKansya.Rows[i].Cells[6].Style.NullValue = null;
                        }
                        // mod 20210820 #6144:同じ名前と名前のロゴを追加します 鄭 end
                        dataGridKansya.Rows[i].Cells[3].Value = patInfo.PatId;
                        dataGridKansya.Rows[i].Cells[4].Value = patInfo.OrdNo;
                        dataGridKansya.Rows[i].Cells[5].Value = patInfo.TreatDate;
                        //mod 20210820  #6144: 値の位置を変更します 鄭 end
                        i++;
                    }
                    dataGridKansya.Refresh();

                    // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
                    dataGridKansya.Columns[0].Frozen = true;
                    // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

                    // 送信ボタンを活性設定
                    btnSend.Enabled = true;
                    progressBar.Visible = false;
                    iBarpos = 0;
                    patInfoFlg = false;
                    btnCancel.Enabled = true;
                }
                // add #6142 施設の変更ができない 歴程 start
                else
                {
                    dataGridKansya.DataSource = null;
                    dataGridKansya.Refresh();

                    // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao start
                    MessageBox.Show(this, "対象データがありません", PRODUCT_NAME, MessageBoxButtons.OK, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
                    // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end

                    // 送信ボタンを活性設定
                    btnSend.Enabled = false;
                }
                // add #6142 施設の変更ができない 歴程 end
            }
            else
            {
                dataGridKansya.DataSource = null;
                dataGridKansya.Refresh();

                // 送信ボタンを活性設定
                btnSend.Enabled = false;
            }
            //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
            lastPatID = string.Empty;
            lastSendCount = 0;
            //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end

            return;
        }


        /// <summary>
        /// 患者情報を取得
        /// </summary>
        /// <returns></returns>
        private static (bool isSuccess, string errorReasonPhrase, string getData) SeachKansyaInfo(string strSyubetu, string strkbn)
        {
            (bool isSuccess, string errorReasonPhrase, string getData) ret = (false, "", "");
            string restUri = "";

            // Uri作成
            string struri = String.Format("{0}{1}", NKKWebAccess.BaseUri, POST_PAT_SEARCH_URI);

            // add 20210816 時間形式を変換する -- 鄭 start
            DateTime dtFrom = Convert.ToDateTime(dateFrom);
            DateTime dtTo = Convert.ToDateTime(dateTo);
            dateFrom = dtFrom.ToString("yyyyMMdd");
            dateTo = dtTo.ToString("yyyyMMdd");
            // add 20210816 時間形式を変換する -- 鄭 end

            try
            {
                //mod 20210823 #6141:パラメータを追加する种别連携イベント  鄭 start
                // restUri = struri + $"PatientInfo/{NKKWebAccess.FacilityCd}/{dateFrom.Replace("/", "")}/{dateTo.Replace("/", "")}";
                restUri = struri + $"PatientInfo/{facility}/{dateFrom.Replace("/", "")}/{dateTo.Replace("/", "")}/{strSyubetu}/{strkbn}";
                //mod 20210823 #6141:パラメータを追加する种别連携イベント  鄭 end

                var restRes = NKKWebAccess.Get("連携イベント作成・中止ツール 検索", restUri, NKKWebAccess.SKIP_OTP).Result;
                ret.isSuccess = restRes.response.IsSuccessStatusCode;
                ret.errorReasonPhrase
                    = string.IsNullOrWhiteSpace(restRes.response.ReasonPhrase) ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : restRes.response.ReasonPhrase;
                if (ret.isSuccess)
                {
                    ret.getData = restRes.strContent;
                }

            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("検索失敗,{0},{1}", restUri, ex.ToString().Replace("\r\n", "{CRLF}")));
            }

            return ret;
        }


        /// <summary>
        /// 患者情報を取得
        /// </summary>
        /// <returns></returns>
        private static (bool isSuccess, string errorReasonPhrase, string getData) SeachFacilityCd()
        {
            (bool isSuccess, string errorReasonPhrase, string getData) ret = (false, "", "");
            string restUri = "";

            // Uri作成
            string struri = String.Format("{0}{1}", NKKWebAccess.BaseUri, POST_PAT_SEARCH_URI);

            try
            {
                restUri = struri + $"FacilityCdInfo";

                var restRes = NKKWebAccess.Get("連携イベント作成・中止ツール 施設", restUri, NKKWebAccess.SKIP_OTP).Result;
                ret.isSuccess = restRes.response.IsSuccessStatusCode;
                ret.errorReasonPhrase
                    = string.IsNullOrWhiteSpace(restRes.response.ReasonPhrase) ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : restRes.response.ReasonPhrase;
                if (ret.isSuccess)
                {
                    ret.getData = restRes.strContent;
                }

            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("施設,{0},{1}", restUri, ex.ToString().Replace("\r\n", "{CRLF}")));
            }

            return ret;
        }
        /// <summary>
        /// 送信ボタンを押下する。
        /// </summary>
        /// <returns></returns>
        private void BtnSend_Click(object sender, EventArgs e)
        {
            // 送信前チーク
            // 種別チーク
            if (String.IsNullOrEmpty(comSyubetu.Text))
            {
                MessageBox.Show("種別を入力してください。", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            // add 20210820  トグルボタン表示 -- 鄭 start
            btnStop1.Visible = true;
            btnSend.Visible = false;
            // add 20210816 トグルボタン表示 -- 鄭 start

            // 患者情報チーク
            Boolean chkFlg = false;

            // mod 2021-08-23 #6142:リスト値を変更する 鄭 start          
            //for (int i = 1; i < dataGridKansya.Rows.Count; i++)
            //{
            //    if (dataGridKansya[0, i].AccessibilityObject != null && dataGridKansya[0, i].AccessibilityObject.Value == "True")
            //    {
            //        chkFlg = true;
            //    }
            //}
            for (int i = 0; i < dataGridKansya.Rows.Count; i++)
            {
                if (dataGridKansya[0, i].AccessibilityObject != null && dataGridKansya[0, i].AccessibilityObject.Value == "True")
                {
                    chkFlg = true;
                }
            }
            // mod 2021-08-23 #6142:リスト値を変更する 鄭 end
            if (!chkFlg)
            {
                MessageBox.Show("患者を選択してください。", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                // add 20210826 #6144 送信見せる中断隠れる -- 鄭 start
                btnStop1.Visible = false;
                btnSend.Visible = true;
                // add 20210826 送信見せる中断隠れる -- 鄭 start
                return;
            }
            // ボタン制御する
            btnSend.Enabled = false;
            btnCancel.Enabled = false;
            btnSearch.Enabled = false;
            winCloseBox.Enabled = false;
            btnStop1.Enabled = true;

            // 画面項目制御する
            dateKikanFrom.Enabled = false;
            dateKikanTo.Enabled = false;
            comSyubetu.Enabled = false;
            // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
            //radioCoopEventCreat.Enabled = false;
            //radioCoopEventStop.Enabled = false;
            if (radioCoopEventCreat.Checked)
            {
                radioCoopEventCreat.Checked = true;
                radioCoopEventStop.Checked = false;

                radioCoopEventStop.Enabled = false;
                radioCoopEventCreat.Enabled = false;
            }
            else
            {
                radioCoopEventCreat.Checked = false;
                radioCoopEventStop.Checked = true;

                radioCoopEventCreat.Enabled = false;
                radioCoopEventStop.Enabled = false;
            }
            // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
            dataGridKansya.Enabled = false;

            // progressBarを設定する
            progressBar.Visible = true;
            int iCount = 0;
            for (int i = 1; i < dataGridKansya.Rows.Count; i++)
            {
                if (dataGridKansya[0, i].AccessibilityObject != null && dataGridKansya[0, i].AccessibilityObject.Value == "True")
                {
                    iCount++;
                }
            }
            progressBar.Value = iBarpos;

            //mod 20210218  #6144:値を変更する 鄭 start
            //progressBar.Maximum = iBarpos + iCount
            progressBar.Maximum = iBarpos + iCount + 1;
            //mod 20210218  #6144:値を変更する 鄭 start
            ;

            // 非同期処理
            Control.CheckForIllegalCrossThreadCalls = false;
            Thread thread = new Thread(new ThreadStart(SendDataCreat));
            threadFlg = true;
            thread.Start();
        }

        /// <summary>
        /// 送信データ作成
        /// </summary>
        /// <returns></returns>
        private void SendDataCreat()
        {
            //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
            sendOver = false;
            //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
            // 種別を取得
            ComboBoxItem comItem = (ComboBoxItem)comSyubetu.SelectedItem;
            String strSyubetu = (String)comItem.Value;

            // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao start
            dateFrom = dateKikanFrom.Text;
            dateTo = dateKikanTo.Text;
            DateTime dtFrom = Convert.ToDateTime(dateFrom);
            DateTime dtTo = Convert.ToDateTime(dateTo);
            // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end

            // 作成更新区分を取得
            string strkbn;
            if (radioCoopEventCreat.Checked)
            {
                strkbn = CRUD_CREATE;
            }
            else
            {
                strkbn = CRUD_DELETE;
            }
            // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao start
            // 期間指定開始日＞期間指定終了日の場合
            if (DateTime.Compare(dtFrom, dtTo) > 0)
            {
                MessageBox.Show("期間指定終了日は期間指定開始日より以降の日付を入力してください。", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                threadFlg = false;

                //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                //Application.ExitThread();
                this.TereadExit();

                this.btnSend.Visible = true;
                this.btnStop1.Visible = false;
                this.btnSend.Enabled = true;
                //progressBar.Visible = false;
                //btnCancel.Enabled = true;
                //btnSearch.Enabled = true;
                //winCloseBox.Enabled = true;
                //dateKikanFrom.Enabled = true;
                //dateKikanTo.Enabled = true;
                //comSyubetu.Enabled = true;
                //radioCoopEventCreat.Enabled = true;
                //radioCoopEventStop.Enabled = true;
                //dataGridKansya.Enabled = true;
                //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end

                return;
            }
            // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end

            // 操作Noを取得
            String strOpecd = OpeCodeMap["default"].create;

            // 操作者IDを取得
            String strUserId = NKKWebAccess.UserNo;

            // 施設コードを取得
            String strFacilityCd = NKKWebAccess.FacilityCd;

            //送信失敗判断FLG
            Boolean judgeFlg = true;

            // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
            // 送信失敗時のポップアップウィンドウの追加情報
            popUpAddMsg = String.Empty;
            popUpAddMsgCnt = 0;

            //add #9034 dongzhaolong start
            popUpAddPatCnt = 0;
            //add #9034 dongzhaolong end

            String strSyubetuName = comItem.Text;
            String startMsg = String.Format("施設:{0}({1}) 種別:{2}({3}) 連携イベント:{4} 期間:{5}～{6}",
                facilityName, facility, strSyubetuName, strSyubetu, (strkbn.Equals(CRUD_CREATE) ? "作成" : "中止"), dateKikanFrom.Text, dateKikanTo.Text);
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.INFO,
                    String.Format("送信開始：{0}", startMsg));
            // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end

            // 送信処理

            //mod 20210218  #6144:値を変更する 鄭 start
            // int iDex = 1;
            int iDex = 0;
            //mod 20210218  #6144:値を変更する 鄭 start

            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            Boolean isFirst = true;
            int rowsNumber = 0;
            int count = dataGridKansya.Height / dataGridKansya.Rows[0].Height - 2;
            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

            // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao start
            var retPatInfo = CoopEventCreatOrStopForm.SeachKansyaInfo(strSyubetu, strkbn);
            List<MyJson.PatInfo> searchDbData = new List<MyJson.PatInfo>();
            searchDbData = MyJson.Conv<List<MyJson.PatInfo>>.Deserialize(retPatInfo.getData);
            if (searchDbData == null || searchDbData.Count == 0)
            {
                dataGridKansya.DataSource = null;
                dataGridKansya.Rows.Clear();
                dataGridKansya.Refresh();

                MessageBox.Show(this, "対象データがありません", PRODUCT_NAME, MessageBoxButtons.OK, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);

                threadFlg = false;

                //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                //Application.ExitThread();
                this.TereadExit();
                this.btnSend.Visible = true;
                this.btnStop1.Visible = false;
                this.btnSend.Enabled = false;
                //progressBar.Visible = false;
                //btnCancel.Enabled = true;
                //btnSearch.Enabled = true;
                //winCloseBox.Enabled = true;
                //dateKikanFrom.Enabled = true;
                //dateKikanTo.Enabled = true;
                //comSyubetu.Enabled = true;
                //radioCoopEventCreat.Enabled = true;
                //radioCoopEventStop.Enabled = true;
                //dataGridKansya.Enabled = true;
                //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end

                return;
            }
            // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end

            if (threadFlg == false)
            {
                //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                //Application.ExitThread();
                this.TereadExit();
                //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end

                return;
            }
            while (threadFlg)
            {
                //add #9034 dongzhaolong start
                string beforePatId = string.Empty;
                //add #9034 dongzhaolong end

                if (dataGridKansya[0, iDex].AccessibilityObject != null && dataGridKansya[0, iDex].AccessibilityObject.Value == "True")
                {
                    //mod 20210218  #6144: 値の位置を変更します 鄭 start
                    //// 患者番号（システム）
                    //String strPatId = (String)dataGridKansya.Rows[iDex].Cells[2].Value;

                    //// （次世代FN)オーダ番号
                    //String strOrdNo = (String)dataGridKansya.Rows[iDex].Cells[3].Value;

                    //// 基準日
                    //String strTreatDate = (String)dataGridKansya.Rows[iDex].Cells[4].Value;

                    //// 患者番号（連携用）
                    //String strHosppatId = (String)dataGridKansya.Rows[iDex].Cells[5].Value;


                    // 患者番号（システム）
                    String strPatId = (String)dataGridKansya.Rows[iDex].Cells[3].Value;
                    //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                    rowIndex = iDex;
                    //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                    //add 9035 zhu start
                    List<MyJson.PatInfo> sendlistDbData = new List<MyJson.PatInfo>();
                    sendlistDbData = listDbData.Where(a => a.PatId == strPatId).ToList();

                    // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end
                    List<MyJson.PatInfo> newsearchDbData = new List<MyJson.PatInfo>();
                    newsearchDbData = searchDbData.Where(a => a.PatId == strPatId).ToList();

                    if (sendlistDbData.All(t => newsearchDbData.Any(b => b.OrdNo == t.OrdNo && b.PatId == t.PatId)) && sendlistDbData.Count == newsearchDbData.Count)
                    {
                        this.btnSend.Enabled = true;
                    }
                    else
                    {
                        //mod #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao start
                        //MessageBox.Show(this, "対象患者の増減がありました。\r\n対象患者リストの内容をご確認ください", PRODUCT_NAME, MessageBoxButtons.OK, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
                        MessageBox.Show(this, "対象患者の増減がありました。\r\n改めて検索を行い対象患者リストの内容をご確認ください", PRODUCT_NAME, MessageBoxButtons.OK, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
                        //mod #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end

                        threadFlg = false;

                        //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                        //Application.ExitThread();
                        this.TereadExit();

                        this.btnSend.Visible = true;
                        this.btnStop1.Visible = false;
                        //mod #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao start
                        //this.btnSend.Enabled = true;
                        this.btnSend.Enabled = false;
                        //mod #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end
                        //progressBar.Visible = false;
                        //btnCancel.Enabled = true;
                        //btnSearch.Enabled = true;
                        //winCloseBox.Enabled = true;
                        //dateKikanFrom.Enabled = true;
                        //dateKikanTo.Enabled = true;
                        //comSyubetu.Enabled = true;
                        //radioCoopEventCreat.Enabled = true;
                        //radioCoopEventStop.Enabled = true;
                        //dataGridKansya.Enabled = true;
                        //edit #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end

                        return;
                    }
                    // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao end

                    //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                    int sendCount = 0;
                    //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
                    foreach (MyJson.PatInfo patInfo in sendlistDbData)
                    {
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                        if (lastPatID.Equals(strPatId) && lastSendCount != 0 && sendCount < lastSendCount)
                        {
                            sendCount++;
                            continue;
                        }
                        else
                        {
                            lastPatID = string.Empty;
                            lastSendCount = 0;
                        }
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end

                        //add 9035 zhu end  
                        //mod 20210823  #6142:値を変更する 鄭 start
                        //sbPostData.Append("{")
                        //         .AppendFormat("\"ope_cd\": \"{0}\",", strOpecd)                  // 操作番号
                        //         .AppendFormat("\"crud\": \"{0}\",", strkbn)                      // 電文作成区分
                        //         .AppendFormat("\"facility_cd\": \"{0}\",", strFacilityCd)        // 施設コード
                        //         .AppendFormat("\"hosp_pat_id\": \"{0}\",", strHosppatId)         // 患者番号(電子カルテ連携システム用)
                        //         .AppendFormat("\"pat_id\": \"{0}\",", strPatId)                  // 患者番号(次世代FutureNet用)
                        //         .AppendFormat("\"ord_no\": \"{0}\",", strOrdNo)                  // 電子カルテ連携システムオーダ番号
                        //         .AppendFormat("\"base_date\": \"{0}\",", strTreatDate)           // 基準日
                        //         .AppendFormat("\"user_id\": \"{0}\",", strUserId)                // 操作者ID
                        //         .AppendFormat("\"coop_cd\": \"{0}\"", strSyubetu)                // 電文種別
                        //         .Append("}");
                        //update zhu 9035 start
                        // （次世代FN)オーダ番号
                        String strOrdNo = patInfo.OrdNo;
                        
                        strUserId = (strSyubetu == "pre_ord") ? "-1" : patInfo.IndUserId;

                        
                        // mod #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao start
                        String strTreatDate = string.Empty;

                        // 基準日
                        if (patInfo.TreatDate.Length != 8)
                        {
                            strTreatDate = Convert.ToDateTime(patInfo.TreatDate).ToString("yyyyMMdd");
                        }
                        //add 9888 生成されたジャーナルに、処理に必要なデータが登録されていない donghao start
                        else
                        {
                            strTreatDate = patInfo.TreatDate;
                        }
                        //add 9888 生成されたジャーナルに、処理に必要なデータが登録されていない donghao end
                        // add #9419 一度送信後、種別を変更しても送信する対象レコードが同じ donghao mod
                        // 
                        // 患者番号（連携用）
                        String strHosppatId = patInfo.HosppatId;
                        //update zhu 9035 end
                        //mod 20210218  #6144: 値の位置を変更します 鄭 end

                        if (OpeCodeMap.TryGetValue(strSyubetu, out var code))
                        {
                            if (strkbn == "D")
                            {
                                // 削除コードが存在する場合のみ
                                strOpecd = !string.IsNullOrEmpty(code.delete)
                                    ? code.delete
                                    : OpeCodeMap["default"].delete;
                            }
                            else
                            {
                                strOpecd = code.create;
                            }
                        }

                        // 送信
                        string strUri = String.Format("{0}{1}", MyConfig.SendUri, POST_PAT_SEND_URI);
                        var sbPostData = new StringBuilder();

                        sbPostData.Append("{")
                               .AppendFormat("\"ope_cd\": \"{0}\",", strOpecd)                  // 操作番号
                               .AppendFormat("\"crud\": \"{0}\",", strkbn)                      // 電文作成区分
                               .AppendFormat("\"facility_cd\": \"{0}\",", facility)             // 施設コード
                               .AppendFormat("\"hosp_pat_id\": \"{0}\",", strHosppatId)         // 患者番号(電子カルテ連携システム用)
                               .AppendFormat("\"pat_id\": \"{0}\",", strPatId)                  // 患者番号(次世代FutureNet用)
                               .AppendFormat("\"ord_no\": \"{0}\",", strOrdNo)                  // 電子カルテ連携システムオーダ番号
                               .AppendFormat("\"base_date\": \"{0}\",", strTreatDate)           // 基準日
                               .AppendFormat("\"user_id\": \"{0}\",", strUserId)                // 操作者ID
                               .AppendFormat("\"coop_cd\": \"{0}\"", strSyubetu)                // 電文種別
                               .Append("}");
                        //mod 20210823  #6142:値を変更する 鄭 start

                        // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
                        // 送信失敗時のエラーメッセージ
                        sendErrMsg = String.Empty;
                        // 患者名
                        String strPatName = (String)dataGridKansya.Rows[iDex].Cells[2].Value;
                        // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end

                        // 送信失敗の場合
                        if (!Send(strUri, sbPostData.ToString()))
                        {
                            // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
                            //NKKLogging.GetInstance().AddLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.ERROR,
                            //        String.Format("送信失敗。「患者番号:{0} 患者名:{1}」",
                            //        (String)dataGridKansya.Rows[iDex].Cells[2].Value,
                            //        (String)dataGridKansya.Rows[iDex].Cells[1].Value));
                            //add 9035 zhu start
                            onePatInfo.Find(a => a.PatId == strPatId).ErrNo++;
                            //add 9035 zhu end
                            // 送信失敗時のエラーメッセージがNULLか
                            if (String.IsNullOrEmpty(sendErrMsg))
                            {
                                sendErrMsg = "エラー不明";
                            }
                            else
                            {
                                if (sendErrMsg.StartsWith("[浄化申し込み・初回指示]データが無し。この患者[") && sendErrMsg.EndsWith("]は連携したことがない。"))
                                {
                                    sendErrMsg = sendErrMsg.Replace("[" + strHosppatId + "]", "");
                                }
                            }

                            String tmpErrorMsg = String.Format("「患者:{0} 番号:{1} 治療日:{2} オーダ番号:{3}」 {4}", strPatName, strHosppatId, strTreatDate, strOrdNo, sendErrMsg);
                            NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.ERROR,
                                String.Format("送信失敗。{0}", tmpErrorMsg));

                            // 送信失敗時のポップアップウィンドウの追加情報
                            if (popUpAddMsgCnt < MyConfig.PopUpMaxMsgs)
                            {
                                popUpAddMsg = popUpAddMsg + "\n　" + tmpErrorMsg;
                            }
                            else if (popUpAddMsgCnt == MyConfig.PopUpMaxMsgs)
                            {
                                popUpAddMsg = popUpAddMsg + "\n　... ...";
                            }
                            popUpAddMsgCnt++;

                            //add #9034 dongzhaolong start
                            if (!string.Equals(beforePatId, strPatId))
                            {
                                popUpAddPatCnt++;
                                beforePatId = strPatId;
                            }
                            //add #9034 dongzhaolong end

                            // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end

                            //  del 2021 - 08 - 23 #6142:消去iDex++,continue  鄭 start
                            // iDex++;                     
                            judgeFlg = false;
                            // continue;
                            // del 2021-08-23 #6142:消去iDex++,continue 鄭 end
                        }
                        // 送信しました
                        else
                        {
                            //del #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                            //if (threadFlg == false)
                            //{
                            //    Application.ExitThread();
                            //    return;
                            //}
                            //del #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
                            //add 9035 zhu start
                            onePatInfo.Find(a => a.PatId == strPatId).SendNo++;
                            //add 9035 zhu end
                            // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
                            //NKKLogging.GetInstance().AddLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.INFO,
                            //        String.Format("送信しました。「患者番号:{0} 患者名:{1}」",
                            //        (String)dataGridKansya.Rows[iDex].Cells[2].Value,
                            //        (String)dataGridKansya.Rows[iDex].Cells[1].Value));
                            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.INFO,
                                String.Format("送信しました。「患者:{0} 番号:{1}」", strPatName, strHosppatId));
                            // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end

                            //del #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                            //if (dataGridKansya.Rows[iDex].Cells[0] != null)
                            //{
                            //    // mod 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf start
                            //    this.Invoke(new RefreshDataGridViewDelegate(RefreshDataGridView), iDex);
                            //    //DataGridViewCheckBoxCell checkCelldatil = (DataGridViewCheckBoxCell)dataGridKansya.Rows[iDex].Cells[0];
                            //    //checkCelldatil.Value = false;
                            //    //checkCelldatil.ReadOnly = true;
                            //    //checkCelldatil.Style.BackColor = System.Drawing.SystemColors.ControlDarkDark;
                            //    // mod 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf end

                            //}
                            //del #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
                        }
                        //add 9035 zhu start
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                        double sendNo = (double)(onePatInfo.Find(a => a.PatId == strPatId).SendNo + onePatInfo.Find(a => a.PatId == strPatId).ErrNo);
                        double sumNo = (double)onePatInfo.Find(a => a.PatId == strPatId).SumNo;
                        //mod #9988 送信処理を中断しても患者リスト欄のステータスが変わらない limingzhe start
                        //percent = (sendNo / sumNo).ToString("P");
                        percent = sendNo.ToString() + "/" + sumNo.ToString();
                        //mod #9988 送信処理を中断しても患者リスト欄のステータスが変わらない limingzhe end
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
                        // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
                        if (onePatInfo.Find(a => a.PatId == strPatId).SumNo == onePatInfo.Find(a => a.PatId == strPatId).SendNo + onePatInfo.Find(a => a.PatId == strPatId).ErrNo)
                        {
                            //mod #9988 送信処理を中断しても患者リスト欄のステータスが変わらない limingzhe start
                            dataGridKansya[7, iDex].Value = onePatInfo.Find(a => a.PatId == strPatId).SendNo.ToString() + "/" + onePatInfo.Find(a => a.PatId == strPatId).SumNo;
                            //mod #9988 送信処理を中断しても患者リスト欄のステータスが変わらない limingzhe end
                            dataGridKansya[8, iDex].Value = onePatInfo.Find(a => a.PatId == strPatId).ErrNo.ToString();

                        }
                        else
                        {
                            dataGridKansya[7, iDex].Value = "処理中";
                            dataGridKansya[8, iDex].Value = string.Empty;
                        }
                        // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                        if (threadFlg == false)
                        {
                            this.TereadExit();
                            lastSendCount = onePatInfo.Find(a => a.PatId == strPatId).SendNo + onePatInfo.Find(a => a.PatId == strPatId).ErrNo;
                            lastPatID = strPatId;
                            if (!sendOver)
                            {
                                dataGridKansya[7, rowIndex].Value = percent;
                                //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない 高 start
                                dataGridKansya[8, rowIndex].Value = onePatInfo.Find(a => a.PatId == strPatId).ErrNo.ToString();
                                //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない 高 end
                            }
                            return;
                        }
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
                    }
                    //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                    if (dataGridKansya.Rows[iDex].Cells[0] != null)
                    {
                        this.Invoke(new RefreshDataGridViewDelegate(RefreshDataGridView), iDex);
                    }
                    //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
                    //add 9035 zhu end

                    // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
                    if (isFirst)
                    {
                        dataGridKansya.FirstDisplayedScrollingRowIndex = iDex;
                        rowsNumber = iDex;
                        isFirst = false;
                    }
                    else
                    {


                        if (iDex > (rowsNumber + count))
                        {

                            dataGridKansya.FirstDisplayedScrollingRowIndex = iDex - count;
                            rowsNumber = iDex - count;
                        }


                    }
                    // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

                    iBarpos++;
                    progressBar.Value = iBarpos;
                }
                iDex++;
                if (iDex == dataGridKansya.Rows.Count)
                {
                    // 処理終設定する
                    threadFlg = false;

                    // 送信成功設定する

                    // del #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
                    // ボタン制御する
                    //btnSend.Enabled = false;
                    // del #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

                    btnCancel.Enabled = true;
                    btnSearch.Enabled = true;
                    winCloseBox.Enabled = true;
                    btnStop1.Enabled = false;

                    // 画面項目制御する
                    dateKikanFrom.Enabled = true;
                    dateKikanTo.Enabled = true;
                    comSyubetu.Enabled = true;
                    radioCoopEventCreat.Enabled = true;
                    radioCoopEventStop.Enabled = true;
                    progressBar.Visible = false;
                    iBarpos = 0;

                    // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
                    dataGridKansya.Refresh();
                    dataGridKansya.Enabled = true;
                    dataGridKansya.Columns[0].ReadOnly = false;
                    dataGridKansya.Columns[0].Frozen = true;
                    // 送信ボタンを活性設定
                    btnSend.Enabled = true;
                    patInfoFlg = false;
                    foreach (MyJson.PatInfo patInfo in onePatInfo)
                    {
                        onePatInfo.Find(a => a.PatId == patInfo.PatId).SendNo = 0;
                        onePatInfo.Find(a => a.PatId == patInfo.PatId).ErrNo = 0;
                    }

                    // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

                    // mod 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf start
                    // 患者情報を初期化
                    //dataGridKansya.Enabled = true;
                    //dataGridKansya.Rows.Clear();

                    // del #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
                    //this.Invoke(new ClearDataGridViewDelegate(ClearDataGridView));
                    // del #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

                    // mod 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf end

                    // add 2021-08-20 #6144:すべて選択解除 鄭 start
                    checKBox1.Checked = false;
                    // add 2021-08-20 #6144:すべて選択解除 鄭 end

                    if (judgeFlg)
                    {

                        MessageBox.Show("送信しました。", Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
                        sendOver = true;
                        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
                        // add 20210820  トグルボタン表示 -- 鄭 start
                        btnStop1.Visible = false;
                        btnSend.Visible = true;
                        // add 20210816 トグルボタン表示 -- 鄭 start
                    }
                    else
                    {
                        // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
                        //MessageBox.Show("送信失敗。患者情報はLOGを見てください。", Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        // 送信失敗時のポップアップウィンドウの追加情報
                        String popUpMsg = "";
                        if (popUpAddMsgCnt <= MyConfig.PopUpMaxMsgs)
                        {
                            popUpMsg = String.Format("以下患者送信失敗。{0}", popUpAddMsg);
                        }
                        else
                        {
                            //add #9034 dongzhaolong start
                            //popUpMsg = String.Format("{0}個患者送信失敗。最大{1}個患者を表示します、その他患者情報はLOGを見てください。{2}", popUpAddMsgCnt, MyConfig.PopUpMaxMsgs, popUpAddMsg);
                            popUpMsg = String.Format("{0}個患者送信失敗。最大{1}個のエラーメッセージを表示します、その他患者情報はLOGを見てください。{2}", popUpAddPatCnt, MyConfig.PopUpMaxMsgs, popUpAddMsg);
                            //add #9034 dongzhaolong end
                        }

                        MessageBox.Show(popUpMsg, Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
                        // add 20210820  トグルボタン表示 -- 鄭 start
                        btnStop1.Visible = false;
                        btnSend.Visible = true;
                        // add 20210816 トグルボタン表示 -- 鄭 start

                    }

                    // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
                    NKKLogging.GetInstance().AddLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.INFO, "送信終了");
                    return;
                    // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
                }
            }

            // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
            if (iDex != dataGridKansya.Rows.Count && !threadFlg)
            {
                NKKLogging.GetInstance().AddLogInfo(DateTime.Now, PRODUCT_NAME, "btnSearch", NKKLogging.LOGGING_CLASS.INFO, "送信中断");
            }
            // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
        }

        /// <summary>
        /// 送信処理
        /// </summary>
        /// <returns></returns>
        private static bool Send(string URL, string centext)
        {
            bool sendFlg = false;
            try
            {
                NKKWebAccessResponse res = CoopEventCreatOrStopForm.Post(URL, centext);
                sendFlg = res.isLogin;
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, PRODUCT_NAME, "btnSend", NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("送信失敗,{0},{1}", URL, ex.ToString().Replace("\r\n", "{CRLF}")));
                // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
                // 送信失敗時のエラーメッセージ
                sendErrMsg = "通信異常、外部連携サービスの状態を確認してください。";
                // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
            }

            return sendFlg;
        }

        /// <summary>
        /// HTTP送信
        /// </summary>
        /// <returns></returns>
        public static NKKWebAccessResponse Post(String strUri, String strdata)
        {
            NKKWebAccessResponse nwar = new NKKWebAccessResponse();
            try
            {
                HttpContent content = new StringContent(strdata, NKKWebAccess.Encoding, "application/json");

                // CSRF用トークンをヘッダに追加
                content.Headers.Add("X-XSRF-TOKEN", NKKWebAccess.GetCSRFToken(strUri));
                // add #11728 連携イベント作成ツールでイベントの作成ができない 高 start
                content.Headers.Add("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK");
                // add #11728 連携イベント作成ツールでイベントの作成ができない 高 end
                nwar.response = Task.Run(() => NKKWebAccess.HttpClient.PostAsync(strUri, content)).Result;

                if (!nwar.response.IsSuccessStatusCode)
                {
                    // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
                    // 送信失敗時のエラーメッセージ
                    nwar.strContent = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;

                    NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, PRODUCT_NAME, "btnSend", NKKLogging.LOGGING_CLASS.DEBUG,
                        String.Format("送信失敗,{0},Result={1}, StatusCode={2}", strUri, nwar.strContent, nwar.response.StatusCode));

                    Dictionary<String, String> tbl = TdcLib.JSONLib.JSONtoData((nwar.strContent));
                    if (tbl.ContainsKey("message") == true)
                    {
                        sendErrMsg = tbl["message"];
                    }
                    // add 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf start
                    else if (tbl.ContainsKey("error_msg") == true)
                    {
                        sendErrMsg = tbl["error_msg"];
                    }
                    // add 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf end
                    else
                    {
                        sendErrMsg = String.Format("HTTP ステータス:{0}", nwar.response.StatusCode);
                    }
                    // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
                    nwar.isLogin = false;
                }
                else
                {
                    nwar.isLogin = true;
                }
            }
            catch (Exception ex)
            {
                nwar.isLogin = false;

                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, PRODUCT_NAME, "btnSend", NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("送信失敗,{0},{1}", strUri, ex.ToString().Replace("\r\n", "{CRLF}")));
                // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
                // 送信失敗時のエラーメッセージ
                sendErrMsg = "通信異常、外部連携サービスの状態を確認してください。";
                // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
            }

            return nwar;
        }

        /// <summary>
        /// 中断ボタンを押下する。
        /// </summary>
        /// <returns></returns>
        private void BtnStop_Click(object sender, EventArgs e)
        {
            // mod #8916 中断時にユーザーに確認メッセージを表示して、意図しない中止を回避する記載がされていません 董昊 start
            /*// 処理終設定する
            threadFlg = false;

            // ボタン制御する
            btnSend.Enabled = true;
            btnCancel.Enabled = true;
            btnSearch.Enabled = true;
            winCloseBox.Enabled = true;
            btnStop1.Enabled = false;

            // 画面項目制御する
            dateKikanFrom.Enabled = true;
            dateKikanTo.Enabled = true;
            comSyubetu.Enabled = true;
            radioCoopEventCreat.Enabled = true;
            radioCoopEventStop.Enabled = true;
            dataGridKansya.Enabled = true;

            // add 20210826 #6144 送信見せる中断隠れる -- 鄭 start
            btnStop1.Visible = false;
            btnSend.Visible = true;
            // add 20210826 #6144 送信見せる中断隠れる -- 鄭 start*/
            // 終了確認
            if (MessageBox.Show(this, "中止してもよろしいですか？", PRODUCT_NAME, MessageBoxButtons.OKCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) == DialogResult.OK)
            {
                // 処理終設定する
                threadFlg = false;

                // ボタン制御する
                btnSend.Enabled = true;
                btnCancel.Enabled = true;
                btnSearch.Enabled = true;
                winCloseBox.Enabled = true;
                btnStop1.Enabled = false;

                // 画面項目制御する
                dateKikanFrom.Enabled = true;
                dateKikanTo.Enabled = true;
                comSyubetu.Enabled = true;
                radioCoopEventCreat.Enabled = true;
                radioCoopEventStop.Enabled = true;
                //dataGridKansya.Enabled = true;

                // add 20210826 #6144 送信見せる中断隠れる -- 鄭 start
                btnStop1.Visible = false;
                btnSend.Visible = true;
                // add 20210826 #6144 送信見せる中断隠れる -- 鄭 start

                return;
            }
            // mod #8916 中断時にユーザーに確認メッセージを表示して、意図しない中止を回避する記載がされていません  董昊 end
        }

        private void DataGridKansya_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            if (dataGridKansya.IsCurrentCellDirty)
            {
                dataGridKansya.CommitEdit(DataGridViewDataErrorContexts.Commit);
            }
        }

        /// <summary>
        /// 全選を設定する。
        /// </summary>
        /// <returns></returns>
        private void DataGridKansya_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0 && e.RowIndex != -1 && !dataGridKansya.Rows[e.RowIndex].IsNewRow)
            {
                if (e.ColumnIndex == 0 && e.RowIndex == 0)
                {
                    if ((bool)this.dataGridKansya[e.ColumnIndex, e.RowIndex].Value == true)
                    {
                        for (int i = 1; i < dataGridKansya.Rows.Count; i++)
                        {
                            DataGridViewCheckBoxCell checkCelldatil = (DataGridViewCheckBoxCell)dataGridKansya.Rows[i].Cells[0];
                            if (!checkCelldatil.ReadOnly)
                            {
                                checkCelldatil.Value = true;
                            }
                        }
                    }
                    else
                    {
                        for (int i = 1; i < dataGridKansya.Rows.Count; i++)
                        {
                            DataGridViewCheckBoxCell checkCelldatil = (DataGridViewCheckBoxCell)dataGridKansya.Rows[i].Cells[0];
                            if (!checkCelldatil.ReadOnly)
                            {
                                checkCelldatil.Value = false;
                            }
                        }
                    }
                    dataGridKansya.Refresh();
                }
            }
        }

        // add 2021-08-20 #6144:追加[すべて選択]ボタン 鄭 start   
        private void checKBox1_CheckedChanged(object sender, EventArgs e)
        {

            if (checKBox1.Checked)
            {
                for (int i = 0; i < dataGridKansya.Rows.Count; i++)
                {
                    DataGridViewCheckBoxCell checkCelldatil = (DataGridViewCheckBoxCell)dataGridKansya.Rows[i].Cells[0];
                    if (!checkCelldatil.ReadOnly)
                    {
                        checkCelldatil.Value = true;
                    }
                }
            }
            else
            {
                for (int i = 0; i < dataGridKansya.Rows.Count; i++)
                {
                    DataGridViewCheckBoxCell checkCelldatil = (DataGridViewCheckBoxCell)dataGridKansya.Rows[i].Cells[0];
                    if (!checkCelldatil.ReadOnly)
                    {
                        checkCelldatil.Value = false;
                    }
                }
            }
            dataGridKansya.Refresh();

        }
        // add 2021-08-20 #6144:追加[すべて選択]ボタン 鄭 end   

        // add 20210823  リンケージ -- 鄭 start
        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            //add #9434 キャンセルの動きが不正なため不要 donghao start
            if (comboBox1.Text == "未選択")
            {
                btnSearch.Enabled = false;
            }
            else
            {
                btnSearch.Enabled = true;
            }
            //add #9434 キャンセルの動きが不正なため不要 donghao end

            checKBox1.Checked = false;
            btnStop1.Visible = false;
            btnSend.Visible = true;
            // 患者情報を初期化
            dataGridKansya.Enabled = true;
            dataGridKansya.Rows.Clear();
            radioCoopEventCreat.Checked = true;
        }
        // add 20210823 リンケージ -- 鄭 end

        #region add 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf start
        /// <summary>
        /// マスタースレッドへのDataGridViewの更新の委任
        /// </summary>
        /// <param name="index"></param>
        public delegate void RefreshDataGridViewDelegate(int index);

        /// <summary>
        /// マスタースレッドへのDataGridView更新方法の委任
        /// </summary>
        /// <param name="index">DataGridView行数</param>
        private void RefreshDataGridView(int index)
        {
            DataGridViewCheckBoxCell checkCelldatil = (DataGridViewCheckBoxCell)dataGridKansya.Rows[index].Cells[0];
            checkCelldatil.Value = false;
            checkCelldatil.ReadOnly = true;
            checkCelldatil.Style.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            return;
        }

        /// <summary>
        /// マスタースレッドに委任してDataGridViewを空にする
        /// </summary>
        public delegate void ClearDataGridViewDelegate();

        /// <summary>
        /// マスタースレッドに委任してDataGridViewメソッドを空にする
        /// </summary>
        private void ClearDataGridView()
        {
            dataGridKansya.Enabled = true;
            dataGridKansya.Rows.Clear();
            return;
        }
        #endregion mod 2023-3-15 bug #8461 透析予約イベントの作成でエラーが発生しイベント作成ができない lmf end

        // add #8915 処理中にウインドウズの×を押された時の制御がない 董昊 start
        private void winCloseBox_Exit_Click(object sender, EventArgs e)
        {

            // 終了確認
            if (MessageBox.Show(this, "終了してもよろしいですか？", PRODUCT_NAME, MessageBoxButtons.OKCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) == DialogResult.OK)
            {
                // アプリケーションの終了
                this.Close();
            }
            else
            {
                WindowCloseBox.flg = true;
                return;
            }

            WindowCloseBox.flg = false;
        }
        // add #8915 処理中にウインドウズの×を押された時の制御がない 董昊 end
        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong start
        private void TereadExit()
        {
            Application.ExitThread();
            // 画面項目制御する
            progressBar.Visible = false;
            btnCancel.Enabled = true;
            btnSearch.Enabled = true;
            winCloseBox.Enabled = true;
            dateKikanFrom.Enabled = true;
            dateKikanTo.Enabled = true;
            comSyubetu.Enabled = true;
            radioCoopEventCreat.Enabled = true;
            radioCoopEventStop.Enabled = true;
            dataGridKansya.Enabled = true;
        }
        //add #9988 送信処理を中断しても患者リスト欄のステータスが変わらない dongzhaolong end
    }
}
