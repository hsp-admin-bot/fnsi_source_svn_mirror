using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Reflection;
using System.Windows.Forms;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopLog;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopInitialDataManager;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;
using jp.co.nikkiso.fn3.Cooperation.CoopComDBIO;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine;
using Oracle.DataAccess.Client;
using System.Xml;
using System.IO;


namespace FNWCoopStub
{


    public partial class Form1 : Form
    {

        private OracleConnection m_oraConnection = null;
        private OracleTransaction m_oraTransaction = null;
        private readonly Object syncLogObject = new Object();
        private String strFileName = Application.StartupPath + "\\" + DateTime.Now.ToString("yyyyMMdd_HHmmss_") + "StubLog.txt";

        Fn3ComPlugIn iPlugin = null;
        string path = System.IO.Directory.GetCurrentDirectory() + "\\";

        bool blnInitFlag = false;

        /// <summary>
        /// 連携ID
        /// </summary>
        private string m_strCooprationID = "";
        /// <summary>
        /// 連携IDを取得します。
        /// </summary>
        public string CooperationID
        {
            get { return this.m_strCooprationID; }
        }

        public Form1()
        {
            InitializeComponent();

        }

        private void button6_Click(object sender, EventArgs e)
        {
            // プラグイン未選択時は抜け
            if (listBox1.SelectedItem == null)
            {
                return;
            }

            // 決定したらDLLは変更不可
            listBox1.Enabled = false;

            try
            {
                string ipluginName = typeof(IFn3ComPlugIn).FullName;
                string strLoadedAssembly = listBox1.SelectedItem.ToString();
                string strCreatedClass = "";

                System.Reflection.Assembly asm = System.Reflection.Assembly.LoadFrom(strLoadedAssembly);
                foreach (Type t in asm.GetTypes())
                {
                    //アセンブリ内のすべての型について、
                    //プラグインとして有効か調べる
                    if (t.IsClass && t.IsPublic && !t.IsAbstract &&
                        t.GetInterface(ipluginName) != null)
                    {

                        // 最初に見つけたプラグインのインスタンスを作成
                        iPlugin = Activator.CreateInstance(t, BindingFlags.CreateInstance, null, null, null) as Fn3ComPlugIn;

                        // 名称を取得
                        strCreatedClass = t.FullName;

                        break;
                    }
                }

                this.label5.Text = "クラス名：" + strCreatedClass;
                this.Refresh();

                if (iPlugin == null)
                {
                    MessageBox.Show("プラグインdllが見つかりません");
                    return;
                }

                //Fn3DBAccess fn3Db = Fn3DBAccess.GetInstance();
                //Fn3PlugInManager fn3PMan = new Fn3PlugInManager();
                iPlugin.DBAccessDelegate = this.DBAccess;

                //	DB接続チェック
                Fn3DBAccess.GetInstance();
                System.Threading.Thread.Sleep(2000);
                Fn3DBAccess.GetInstance().dgtOutLog = this.OutLog;
                if (this.m_oraConnection == null || Fn3DBAccess.GetInstance().IsConnected(this.m_oraConnection) == false)
                {
                    //	DB接続中ではない場合は再接続
                    if (this.m_oraConnection != null)
                    {
                        //	一旦切断する。
                        Fn3DBAccess.GetInstance().DBDisconnect(this.m_oraConnection);
                        this.m_oraConnection = null;
                    }
                    //	再接続
                    this.m_oraConnection = Fn3DBAccess.GetInstance().DBConnect();
                    if (this.m_oraConnection == null)
                    {
                        //	失敗
                        MessageBox.Show("DBConnectError");
                        //return Fn3CoopRetCode.DBConnectError;
                    }
                }

                this.label6.Text = "DB接続：OK";
                this.label6.ForeColor = Color.Blue;

                // 各種デリゲート設定
                LogManager logMan = LogManager.getInstance();
                InitialDataManager iniData = new InitialDataManager();
                logMan.setdgtGetInitialData = iniData.GetData;

                iPlugin.GetInitialValueDelegate = iniData.GetData;

                // ログマネージャの初期化失敗時は、自前のログ出力を行う
                if (logMan.Initialize())
                {
                    // サービス稼動中はスタブからのログが出力できないため(LogWriterの排他処理？)、必ず自前で出力を行うよう変更
                    //iPlugin.OutLogDelegate = logMan.OutLog;
                    iPlugin.OutLogDelegate = this.OutLog;
                }
                else
                {
                    iPlugin.OutLogDelegate = this.OutLog;
                }


                iPlugin.StatusInformationDelegate = this.StatusInformation;

                button1.Focus();
                //}
                //catch (Exception err)
                //{
                //    System.IO.File.WriteAllText("error.log", err.ToString());
                //}
            }
            catch (Exception ex)
            {
                this.ShowException(ex);                
            }
        }

        /// <summary>
        /// 自前のログ出力
        /// </summary>
        /// <param name="logLevel"></param>
        /// <param name="ErrorCode"></param>
        /// <param name="logParameter"></param>
        private void OutLog(CoopLogLevel logLevel, string ErrorCode, LogParameter logParameter)
        {
            lock (this.syncLogObject)
            {
                String strLog = "";
                if (logParameter.ErrorFlg)
                {
                    strLog = DateTime.Now.ToString("yyyy/MM/dd hh:mm:ss.fff") + " : " + logLevel.ToString() + ":" + ErrorCode + ":" + logParameter.ErrorMsg + "\r\n";
                }
                if (logParameter.TraceFlg)
                {
                    strLog = DateTime.Now.ToString("yyyy/MM/dd hh:mm:ss.fff") + " : " + logLevel.ToString() + ":" + ErrorCode + ":" + logParameter.TraceMsg + "\r\n";
                }
                File.AppendAllText(this.strFileName, strLog);
            }
        }

        //private void button6_Click(object sender, EventArgs e)
        //{
        //    //try
        //    //{

        //        //.dllファイルを探す
        //        string[] dlls = System.IO.Directory.GetFiles(path, "*.dll");

        //        string ipluginName = typeof(IFn3ComPlugIn).FullName;
        //        bool blnDllSearch = true;
        //        string strLoadedAssembly = "";
        //        string strCreatedClass = "";

        //        foreach (string dll in dlls)
        //        {
        //            try
        //            {
        //                //アセンブリとして読み込む
        //                System.Reflection.Assembly asm = System.Reflection.Assembly.LoadFrom(dll);
        //                foreach (Type t in asm.GetTypes())
        //                {
        //                    //アセンブリ内のすべての型について、
        //                    //プラグインとして有効か調べる
        //                    if (t.IsClass && t.IsPublic && !t.IsAbstract &&
        //                        t.GetInterface(ipluginName) != null)
        //                    {

        //                        // 最初に見つけたプラグインのインスタンスを作成
        //                        iPlugin = Activator.CreateInstance(t, BindingFlags.CreateInstance, null, null, null) as Fn3ComPlugIn;

        //                        // 名称を取得
        //                        strLoadedAssembly = dll;
        //                        strCreatedClass = t.FullName;

        //                        // サーチフラグOFF
        //                        blnDllSearch = false;
        //                        break;
        //                    }
        //                }
        //            }
        //            catch
        //            {
        //            }

        //            if (!blnDllSearch)
        //            {
        //                break;
        //            }
        //        }

        //        this.label4.Text = "アセンブリ名：" + strLoadedAssembly;
        //        this.label5.Text = "クラス名：" + strCreatedClass;
        //        this.Refresh();

        //        if (iPlugin == null)
        //        {
        //            MessageBox.Show("プラグインdllが見つかりません");
        //            return;
        //        }

        //        //Fn3DBAccess fn3Db = Fn3DBAccess.GetInstance();
        //        //Fn3PlugInManager fn3PMan = new Fn3PlugInManager();
        //        iPlugin.DBAccessDelegate = this.DBAccess;

        //        //	DB接続チェック
        //        if (this.m_oraConnection == null || Fn3DBAccess.GetInstance().IsConnected(this.m_oraConnection) == false)
        //        {
        //            //	DB接続中ではない場合は再接続
        //            if (this.m_oraConnection != null)
        //            {
        //                //	一旦切断する。
        //                Fn3DBAccess.GetInstance().DBDisconnect(this.m_oraConnection);
        //                this.m_oraConnection = null;
        //            }
        //            //	再接続
        //            this.m_oraConnection = Fn3DBAccess.GetInstance().DBConnect();
        //            if (this.m_oraConnection == null)
        //            {
        //                //	失敗
        //                MessageBox.Show("DBConnectError");
        //                //return Fn3CoopRetCode.DBConnectError;
        //            }
        //        }

        //        this.label6.Text = "DB接続：OK";
        //        this.label6.ForeColor = Color.Blue;

        //        // 各種デリゲート設定
        //        LogManager logMan = LogManager.getInstance();
        //        InitialDataManager iniData = new InitialDataManager();
        //        logMan.setdgtGetInitialData = iniData.GetData;

        //        iPlugin.GetInitialValueDelegate = iniData.GetData;

        //        logMan.Initialize();
        //        iPlugin.OutLogDelegate = logMan.OutLog;


        //        iPlugin.StatusInformationDelegate = this.StatusInformation;

        //        button1.Focus();
        //    //}
        //    //catch (Exception err)
        //    //{
        //    //    System.IO.File.WriteAllText("error.log", err.ToString());
        //    //}
        //}

        /// <summary>
        /// Initializeボタン
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button1_Click(object sender, EventArgs e)
        {
            if (iPlugin != null)
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(path + "MST_COOP_ID.xml");
                iPlugin.InitializeCooperation(xmlDoc.OuterXml);

                blnInitFlag = true;

                button2.Focus();
            }
        }

        /// <summary>
        /// Startボタン
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button2_Click(object sender, EventArgs e)
        {
            if (iPlugin != null)
            {
                iPlugin.StartCooperation();

                button3.Focus();
            }

        }

        /// <summary>
        /// Executeボタン
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button3_Click(object sender, EventArgs e)
        {
            if (iPlugin != null)
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(path + "COP_EVENT_MANAGE.xml");
                XmlNodeList xmlNodes = xmlDoc.GetElementsByTagName("COOP_ID");
                m_strCooprationID = xmlNodes.Item(0).InnerXml;
                iPlugin.ExecuteCooperation(xmlDoc.OuterXml);

                button4.Focus();
            }
 
        }

        /// <summary>
        /// Stopボタン
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button4_Click(object sender, EventArgs e)
        {
            if (iPlugin != null)
            {
                iPlugin.StopCooperation();

                button5.Focus();
            }
        }

        /// <summary>
        /// Releaseボタン
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button5_Click(object sender, EventArgs e)
        {
            if (iPlugin != null)
            {
                iPlugin.ReleaseCooperation();

                blnInitFlag = false;

            }
        }



        protected virtual void StatusInformation
            (string CoopID, jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine.StatusCode Status)
        {

        }

        /// <summary>
        /// DBアクセス
        /// </summary>
        /// <param name="type">タイプ</param>
        /// <param name="strInXml">入力パラメータ</param>
        /// <param name="strOutXml">出力パラメータ</param>
        /// <param name="objExInParam">拡張パラメータ（入力）</param>
        /// <param name="objExOutParam">拡張パラメータ（出力）</param>
        /// <returns>処理結果</returns>
        private Fn3ReturnCode DBAccess(DBAccessType type, string strInXml, ref string strOutXml, object objExInParam, ref object objExOutParam)
        {
            switch (type)
            {
                case DBAccessType.Transaction:
                    {
                        //	トランザクション開始
                        if (this.m_oraTransaction != null)
                        {
                            //	既にトランザクションが開始されている。
                            return Fn3CoopRetCode.AlreadyTransaction;
                        }

                        //	トランザクションの開始
                        this.m_oraTransaction = Fn3DBAccess.GetInstance().StartTransaction(this.m_oraConnection);

                        if (this.m_oraTransaction == null)
                        {
                            //	トランザクションの開始に失敗
                            return Fn3CoopRetCode.TransactionError;
                        }

                        //	トランザクションの開始に成功
                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.Commit:
                    {
                        if (this.m_oraTransaction == null)
                        {
                            //	トランザクションが開始されていない
                            return Fn3CoopRetCode.NotStartTransaction;
                        }

                        if (Fn3DBAccess.GetInstance().CommitTransaction(this.m_oraTransaction) == false)
                        {
                            //	コミットに失敗
                            this.m_oraTransaction = null;
                            return Fn3CoopRetCode.CommitError;
                        }

                        this.m_oraTransaction = null;

                        //	コミットに成功
                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.Rollback:
                    {
                        if (this.m_oraTransaction == null)
                        {
                            //	トランザクションが開始されていない
                            return Fn3CoopRetCode.NotStartTransaction;
                        }

                        if (Fn3DBAccess.GetInstance().RollbackTransaction(this.m_oraTransaction) == false)
                        {
                            //	ロールバックに失敗
                            this.m_oraTransaction = null;
                            return Fn3CoopRetCode.RollbackError;
                        }

                        this.m_oraTransaction = null;

                        //	ロールバックに成功
                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.Select:
                    {
                        XmlDocument inXml = new XmlDocument();
                        inXml.LoadXml(strInXml);
                        XmlNode outXml = null;

                        if (Fn3DBAccess.GetInstance().SelectSql(inXml.DocumentElement, ref outXml, this.m_oraConnection, this.m_oraTransaction) == false)
                        {
                            //	SELECT文の実行に失敗
                            return Fn3CoopRetCode.SelectError;
                        }

                        strOutXml = outXml.OuterXml;

                        //	SELECT文の実行に成功
                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.SelectCoopInfo:
                    {
                        XmlDocument inXml = new XmlDocument();
                        inXml.LoadXml(strInXml);
                        string strTableName = (string)objExInParam;
                        XmlNode outXml = null;

                        if (Fn3DBAccess.GetInstance().SelectCoopInfo(strTableName, inXml.DocumentElement, ref outXml, this.m_oraConnection, this.m_oraTransaction) == false)
                        {
                            //	連携関連情報の取得に失敗
                            return Fn3CoopRetCode.SelectCoopInfoError;
                        }

                        strOutXml = outXml.OuterXml;

                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.UpdateCoopInfo:
                    {
                        XmlDocument inXml = new XmlDocument();
                        inXml.LoadXml(strInXml);
                        string strTableName = (string)objExInParam;

                        int intUpdateNum = Fn3DBAccess.GetInstance().UpdateCoopInfo(strTableName, inXml.DocumentElement, this.m_oraConnection, this.m_oraTransaction);
                        if (intUpdateNum == -1)
                        {
                            //	連携情報の更新に失敗
                            objExOutParam = 0;
                            return Fn3CoopRetCode.UpdateCoopInfoError;
                        }

                        objExOutParam = intUpdateNum;

                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.Update:
                    {
                        XmlDocument inXml = new XmlDocument();
                        inXml.LoadXml(strInXml);

                        int intUpdateNum = Fn3DBAccess.GetInstance().UpdateSql(inXml.DocumentElement, this.m_oraConnection, this.m_oraTransaction);
                        if (intUpdateNum == -1)
                        {
                            //	UPDATE/INSERTの実行に失敗
                            objExOutParam = 0;
                            return Fn3CoopRetCode.UpdateError;
                        }

                        objExOutParam = intUpdateNum;

                        //	UPDATE/INSERTの実行に成功
                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.GetSendHist:
                    {
                        string strSpecificKey = (string)objExInParam;
                        XmlNode outXml = null;

                        if (Fn3DBAccess.GetInstance().GetSendHstInfo(this.CooperationID, strSpecificKey, ref outXml, this.m_oraConnection, this.m_oraTransaction) == false)
                        {
                            return Fn3CoopRetCode.GetSendHistError;
                        }

                        if (outXml != null)
                        {
                            strOutXml = outXml.OuterXml;
                        }
                        else
                        {
                            strOutXml = "";
                        }

                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.UpdateSendHist:
                    {
                        XmlDocument inXml = new XmlDocument();
                        inXml.LoadXml(strInXml);

                        if (Fn3DBAccess.GetInstance().SetSendHstInfo(inXml.DocumentElement, this.m_oraConnection, this.m_oraTransaction) == false)
                        {
                            //	送信履歴テーブルの更新に失敗
                            return Fn3CoopRetCode.UpdateSendHistError;
                        }

                        //	送信履歴テーブルの更新に成功
                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.ExecQuery:
                    {
                        XmlDocument inXml = new XmlDocument();
                        inXml.LoadXml(strInXml);
                        XmlNode outXml = null;

                        if (Fn3DBAccess.GetInstance().ExecQuery(iPlugin.CooperationID, (string)objExInParam, inXml.DocumentElement, ref outXml, this.m_oraConnection, this.m_oraTransaction) == false)
                        {
                            //	クエリ実行の失敗
                            return Fn3CoopRetCode.ExecQueryError;
                        }

                        strOutXml = outXml.OuterXml;

                        //	クエリ実行に成功
                        return Fn3CoopRetCode.Success;
                    }
                case DBAccessType.CheckConnect:
                    {
                        if (this.m_oraConnection == null || Fn3DBAccess.GetInstance().IsConnected(this.m_oraConnection) == false)
                        {
                            //	接続状態にないので再接続処理
                            if (this.m_oraConnection != null)
                            {
                                //	OracleConnectionインスタンスが存在する場合は切断
                                Fn3DBAccess.GetInstance().DBDisconnect(this.m_oraConnection);
                                this.m_oraConnection = null;
                            }

                            //	接続
                            this.m_oraConnection = Fn3DBAccess.GetInstance().DBConnect();
                            if (this.m_oraConnection == null)
                            {
                                //	接続失敗
                                return Fn3CoopRetCode.DBConnectError;
                            }
                        }

                        return Fn3CoopRetCode.Success;
                    }
            }

            //	不正なDBアクセス
            return Fn3CoopRetCode.InjusticeDBAccess;
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (blnInitFlag)
            {
                this.button5_Click(sender, e);
                MessageBox.Show("プラグインのReleaseを自動実行しました。");
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // メインスレッド用のキャッチ出来ない例外用イベントハンドラ
            Application.ThreadException += new System.Threading.ThreadExceptionEventHandler(Application_ThreadException);

            // 他スレッド用のキャッチ出来ない例外用イベントハンドラ
            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(CurrentDomain_UnhandledException);


            //.dllファイルを探す
            string[] dlls = System.IO.Directory.GetFiles(path, "*.dll");

            string ipluginName = typeof(IFn3ComPlugIn).FullName;

            foreach (string dll in dlls)
            {
                try
                {
                    //アセンブリとして読み込む
                    System.Reflection.Assembly asm = System.Reflection.Assembly.LoadFrom(dll);
                    foreach (Type t in asm.GetTypes())
                    {
                        //アセンブリ内のすべての型について、
                        //プラグインとして有効か調べる
                        if (t.IsClass && t.IsPublic && !t.IsAbstract &&
                            t.GetInterface(ipluginName) != null)
                        {
                            // プラグインをリストアップ
                            this.listBox1.Items.Add(dll);

                            break;
                        }
                    }
                }
                catch
                {
                }

            }

        }

        // メインスレッド用のキャッチ出来ない例外用イベントハンドラ
        private void Application_ThreadException(object sender, System.Threading.ThreadExceptionEventArgs e)
        {
            this.ShowException(e.Exception);
        }

        // 他スレッド用のキャッチ出来ない例外用イベントハンドラ
        private void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            this.ShowException(e.ExceptionObject as Exception);
        }

        private void ShowException(Exception ex)
        {
            String strLog = ex.Message + "：" + ex.Source + "：" + ex.TargetSite.ToString() + "：" + ex.StackTrace;
            //this.textBox1.AppendText(strLog);
            File.AppendAllText(Application.StartupPath + "\\StubLog.txt", DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss：") + strLog + "\r\n");
        }

        private void listBox1_KeyDown(object sender, KeyEventArgs e)
        {
            if ((listBox1.SelectedItem != null) && (e.KeyCode == Keys.Enter))
            {
                this.button6_Click(sender, e);
            }
        }

    }
}
