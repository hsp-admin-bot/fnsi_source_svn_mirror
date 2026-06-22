using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Collections;
using System.Reflection;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;


namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    public class Fn3CSICoopDialysisReportSendStd : Fn3ComPlugIn
    {
        #region 定数（共通化を考慮して個別に定義しておく）
        /// <summary>
        /// 情報区分「共通」
        /// </summary>
        public const string SYS_DIV_COMMON = "0";
        /// <summary>
        /// 情報区分「個別」
        /// </summary>
        public const string SYS_DIV_UNIQUE = "1";
        /// <summary>
        /// PDFサーバ情報XML
        /// </summary>
        public const string FILENAME_PDFSERVERINFO = "PdfServerInfo.xml";
        /// <summary>
        /// 患者情報XML
        /// </summary>
        public const string FILENAME_PATIENTINFO = "PatientInfo.xml";
        /// <summary>
        /// セクション名（共通）
        /// </summary>
        public const string SYS_SECT_COMMON = "CSI_COMMON";
        /// <summary>
        /// セクション名（個別設定）
        /// </summary>
        public const string SYS_SECT_ORG = "CSI_DIALYSISREPORTSND";
        /// <summary>
        /// キー名（PDFサーバフォルダ）
        /// </summary>
        public const string SYS_KEY_PDF_SERVER_FOLDER = "PDF_SERVER_FOLDER";
        /// <summary>
        /// キー名（連携先患者ID桁数）
        /// </summary>
        //public const string SYS_KEY_PATID_LEN = "PATID_LEN";
        public const string SYS_KEY_PATID_LEN = "SEND_PATID_FIGURES";
        /// <summary>
        /// セクション名（レポート情報）
        /// </summary>
        public const string SYS_SECT_REPORT_INFO = "REPORT_INFO";
        /// <summary>
        /// キー名（連携FWレポート移動先フォルダ）
        /// </summary>
        public const string SYS_KEY_REPORT_STORE_FORDER = "REPORT_STORE_FORDER";
        #endregion

        #region メンバ変数
        /// <summary>
        /// 共通設定値
        /// </summary>
        Hashtable m_hstCommonSettings = new Hashtable();
        /// <summary>
        /// 個別設定値
        /// </summary>
        Hashtable m_hstOrgSettings = new Hashtable();
        /// <summary>
        /// レポート情報設定値
        /// </summary>
        Hashtable m_hstReportInfo = new Hashtable();
        #endregion

        #region メンバ変数（設定値保持用）
        /// <summary>
        /// PDFサーバフォルダ（ファイル移動先パス）
        /// </summary>
        string m_strPdfServerFolder = "";
        /// <summary>
        /// PDF参照元パス
        /// </summary>
        string m_strReportStoreFolder = "";
        /// <summary>
        /// 連携先患者ID桁数
        /// </summary>
        int m_intPatId_len = 0;
        #endregion

        #region メンバ変数（ログ出力用値保持）
        /// <summary>
        /// 患者ID
        /// </summary>
        private string m_strForMsgPatId = "";
        /// <summary>
        /// 表示用患者ID
        /// </summary>
        private string m_strForMsgDispPatId = "";
        /// <summary>
        /// 透析番号
        /// </summary>
        private string m_strForMsgDialysisNo = "";
        /// <summary>
        /// 版番
        /// </summary>
        private string m_strForMsgEdition = "";
        #endregion

        #region フォーマット文字列
        /// <summary>
        /// 連携初期設定情報関連のログ出力用フォーマット文字列
        /// </summary>
        /// <remarks>
        /// 以下、使用例。
        /// Fn3ReturnCode retCode = this.GetInitialValue((設定区分), (セクション名), (キー名), ref (値));
        /// if (retCode.IsError || retCode.IsException || strValue.Trim().Equals(""))
        /// {
        ///     this.TraceOut(retCode, string.Format(CSICommonConst.SYS_LOG_FORMAT, (セクション名), (キー名), (値)) )
        /// }
        /// </remarks>
        public const string SYS_LOG_FORMAT = "Section=\"{0}\", Key=\"{1}\", Value=\"{2}\"";
        /// <summary>
        /// ログ種別・致命的エラー（エラートレース用）
        /// </summary>
        public const string LOGTYPE_FTL = "【致命的エラー】";
        /// <summary>
        /// ログ種別・通常エラー
        /// </summary>
        public const string LOGTYPE_ERR = "【エラー】";
        /// <summary>
        /// ログ種別・警告
        /// </summary>
        public const string LOGTYPE_WNG = "【警告】";
        /// <summary>
        /// ログ種別・デバック（デバックトレース用）
        /// </summary>
        public const string LOGTYPE_DBG = "【デバック】";
        /// <summary>
        /// モジュール名・透析レポート送信
        /// </summary>
        public const string MODULE_MNAME_DRS = "【透析レポート送信】";
        /// <summary>
        /// デバックトレース用・処理成功メッセージヘッダ
        /// </summary>
        public const string DEBUGTRACE_PRE_SUCCESS_MSG = "【処理成功】";
        #endregion

        #region リターンコード関連
        /// <summary>
        /// 個別処理区分ID
        /// </summary>
        private static readonly string strCPId_ReportSnd = "500";
        /// <summary>
        /// コードオフセット値
        /// </summary>
        private static int CodeOffset_ReportSnd = 0;

        public static readonly Fn3ReturnCode ERR_PDFSERVERMAN_GET_SETTINGS =
            new Fn3ReturnCode(strCPId_ReportSnd, CodeOffset_ReportSnd + 001, MODULE_MNAME_DRS + LOGTYPE_ERR + "PDFサーバ管理で初期設定の取得に失敗しました。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PDFSERVERMAN_FOLDER_NOT_EXISTS =
            new Fn3ReturnCode(strCPId_ReportSnd, CodeOffset_ReportSnd + 002, MODULE_MNAME_DRS + LOGTYPE_ERR + "PDFサーバフォルダが存在しません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PDFSERVERMAN_NODE_NULL =
            new Fn3ReturnCode(strCPId_ReportSnd, CodeOffset_ReportSnd + 003, MODULE_MNAME_DRS + LOGTYPE_ERR + "PDFサーバ管理で指定のXMLノードがNULLです。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode ERR_PDFSERVERMAN_PDF_NOT_EXISTS =
            new Fn3ReturnCode(strCPId_ReportSnd, CodeOffset_ReportSnd + 004, MODULE_MNAME_DRS + LOGTYPE_ERR + "PDFサーバ管理で指定のPDFファイルが見つかりません。", ReturnCodeType.Error);

        public static readonly Fn3ReturnCode FTL_PDFSERVERMAN_EXCEPTION =
            new Fn3ReturnCode(strCPId_ReportSnd, CodeOffset_ReportSnd + 004, MODULE_MNAME_DRS + LOGTYPE_FTL + "PDFサーバ管理の処理中に例外が発生しました。", ReturnCodeType.Exception);

        public static readonly Fn3ReturnCode ERR_PDFSERVERMAN_GET_PATID =
            new Fn3ReturnCode(strCPId_ReportSnd, CodeOffset_ReportSnd + 005, MODULE_MNAME_DRS + LOGTYPE_ERR + "有効な患者IDの取得に失敗しました。", ReturnCodeType.Error);
        #endregion

        #region 列挙型
        /// <summary>
        /// ノードソートの種類
        /// </summary>
        enum NodeSortType
        {
            ASC,
            DESC
        }
        #endregion

        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <returns></returns>
        protected override Fn3ReturnCode Initialize()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 共通設定値を読み込む
            m_hstCommonSettings.Clear();
            this.GetInitialValue(SYS_DIV_UNIQUE, SYS_SECT_COMMON, ref m_hstCommonSettings);

            // 個別設定値を読み込む
            m_hstOrgSettings.Clear();
            this.GetInitialValue(SYS_DIV_UNIQUE, SYS_SECT_ORG, ref m_hstOrgSettings);

            // レポート情報設定値を読み込む
            this.GetInitialValue(SYS_DIV_COMMON, SYS_SECT_REPORT_INFO, ref m_hstReportInfo);

            //----------------------------------------------------------------
            // 設定値の取得
            //----------------------------------------------------------------

            #region 設定値取得

            //-- 参照元パスを取得
            if (!this.m_hstReportInfo.ContainsKey(SYS_KEY_REPORT_STORE_FORDER))
            {
                // 初期化失敗
                this.TraceOut(ERR_PDFSERVERMAN_GET_SETTINGS, string.Format(SYS_LOG_FORMAT,
                                                                                       SYS_SECT_REPORT_INFO,
                                                                                       SYS_KEY_REPORT_STORE_FORDER,
                                                                                       ""));
                return ERR_PDFSERVERMAN_GET_SETTINGS;
            }
            else
            {
                m_strReportStoreFolder = m_hstReportInfo[SYS_KEY_REPORT_STORE_FORDER].ToString();
                if (m_strReportStoreFolder.Substring(m_strReportStoreFolder.Length - 1, 1) != @"\")
                {
                    m_strReportStoreFolder += @"\";
                }
            }

            //-- PDFサーバフォルダを取得
            if (!this.m_hstOrgSettings.ContainsKey(SYS_KEY_PDF_SERVER_FOLDER))
            {
                // 初期化失敗
                this.TraceOut(ERR_PDFSERVERMAN_GET_SETTINGS, string.Format(SYS_LOG_FORMAT,
                                                                                       SYS_SECT_ORG,
                                                                                       SYS_KEY_PDF_SERVER_FOLDER,
                                                                                       ""));
                return ERR_PDFSERVERMAN_GET_SETTINGS;
            }
            else
            {
                m_strPdfServerFolder = m_hstOrgSettings[SYS_KEY_PDF_SERVER_FOLDER].ToString();
                if (m_strPdfServerFolder.Substring(m_strPdfServerFolder.Length - 1, 1) != @"\")
                {
                    m_strPdfServerFolder += @"\";
                }
            }

            //-- 患者ID桁数
            if (!this.m_hstCommonSettings.ContainsKey(SYS_KEY_PATID_LEN))
            {
                // 初期化失敗
                this.TraceOut(ERR_PDFSERVERMAN_GET_SETTINGS, string.Format(SYS_LOG_FORMAT,
                                                                           SYS_SECT_COMMON,
                                                                           //SYS_SECT_ORG,
                                                                           SYS_KEY_PATID_LEN,
                                                                           ""));
                return ERR_PDFSERVERMAN_GET_SETTINGS;
            }
            else
            {
                m_intPatId_len = int.Parse(m_hstCommonSettings[SYS_KEY_PATID_LEN].ToString());
            }

            

            #endregion

            // PDFサーバフォルダの存在チェック
            if (!Directory.Exists(m_strPdfServerFolder))
            {
                // 初期化失敗
                this.TraceOut(ERR_PDFSERVERMAN_FOLDER_NOT_EXISTS, m_strPdfServerFolder);
                return ERR_PDFSERVERMAN_FOLDER_NOT_EXISTS;
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());

            // 
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 連携開始処理
        /// </summary>
        /// <returns></returns>
        protected override Fn3ReturnCode Start()
        {
            // ※特に処理はなし
            
            // 
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 1ポーリング単位の開始処理
        /// </summary>
        /// <returns></returns>
        protected override Fn3ReturnCode StartProcess()
        {
            // ※特に処理はなし
            
            // 
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 送信系モジュールのイベント処理
        /// </summary>
        /// <param name="exeInfo"></param>
        /// <returns></returns>
        protected override Fn3ReturnCode Execute(Fn3ExecuteInfo exeInfo)
        {
            Fn3ReturnCode fn3Ret;

            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            m_strForMsgPatId = string.Empty;
            m_strForMsgDispPatId = string.Empty;
            m_strForMsgDialysisNo = string.Empty;
            m_strForMsgEdition = string.Empty;

            try
            {

                // 処理区分が削除以外
                if (exeInfo.SendClass != "2")
                {
                    string strPatId;
                    string strPatientFolder;
                    string strPatientInfoXml;
                    string strPdfServerInfoXml;
                    long dispPatid = 0;

                    #region フォルダ、ファイル存在チェック
                    // 患者フォルダの存在チェック
                    // 2010/12/10 中村
                    // fn3Ret = getNodeString(out strPatId, "//rootNode/PAT_BASIC_INFO/PATID", exeInfo);
                    fn3Ret = getNodeString(out strPatId, "//rootNode/PAT_BASIC_INFO/DISP_PATID", exeInfo);
                    if (fn3Ret.IsError || fn3Ret.IsException)
                    {
                        return fn3Ret;
                    }

                    // 2010/12/10 中村
                    // strPatientFolder = m_strPdfServerFolder + strPatId + @"\";                    
                    if (!long.TryParse(strPatId, out dispPatid))
                    {
                        fn3Ret = ERR_PDFSERVERMAN_GET_PATID;
                        this.TraceOut(fn3Ret, strPatId);
                        return fn3Ret;
                    }
                    strPatientFolder = m_strPdfServerFolder + dispPatid.ToString() + @"\";
                    if (!Directory.Exists(strPatientFolder))
                    {
                        //-- なければ作成する
                        Directory.CreateDirectory(strPatientFolder);
                    }

                    // PDFサーバ情報XMLの存在チェック
                    strPdfServerInfoXml = m_strPdfServerFolder + FILENAME_PDFSERVERINFO;
                    if (!File.Exists(strPdfServerInfoXml))
                    {
                        //-- なければ作成する
                        XmlDocument xmlDoc = new XmlDocument();
                        createXmlDecAndRoot(ref xmlDoc);
                        xmlDoc.Save(strPdfServerInfoXml);

                    }

                    // 患者情報XMLの存在チェック
                    strPatientInfoXml = strPatientFolder + FILENAME_PATIENTINFO;
                    if (!File.Exists(strPatientInfoXml))
                    {
                        //-- なければ作成する
                        XmlDocument xmlDoc = new XmlDocument();
                        createPatientXmlTemplate(ref xmlDoc);
                        xmlDoc.Save(strPatientInfoXml);
                    }
                    #endregion

                    // PDFファイルの移動
                    string strPdfFilePath = this.m_strReportStoreFolder + exeInfo.EvtMngMemo;
                    if (!File.Exists(strPdfFilePath))
                    {
                        //-- ファイルが存在しない（有り得ないが）
                        fn3Ret = ERR_PDFSERVERMAN_PDF_NOT_EXISTS;
                        this.TraceOut(fn3Ret, strPdfFilePath);
                        return fn3Ret;
                    }
                    else
                    {
                        //-- 移動
                        File.Move(strPdfFilePath, strPatientFolder + exeInfo.EvtMngMemo);
                    }

                    // 患者情報XMLファイル更新
                    fn3Ret = updatePatientInfoXml(strPatientInfoXml, exeInfo);
                    if (fn3Ret.IsError || fn3Ret.IsException)
                    {
                        return fn3Ret;
                    }

                    // PDFサーバ情報XMLファイル更新
                    fn3Ret = updatePdfServerInfoXml(strPdfServerInfoXml, exeInfo);
                    if (fn3Ret.IsError || fn3Ret.IsException)
                    {
                        return fn3Ret;
                    }

                    // トレース出力
                    this.DebugTraceOut(MODULE_MNAME_DRS + LOGTYPE_DBG + DEBUGTRACE_PRE_SUCCESS_MSG +
                                       String.Format("PDFサーバ管理モジュールの処理に成功しました。({0})",
                                       String.Format("患者ID：{0} 表示用患者ID：{1} 透析番号：{2} 版番：{3}",
                                                     this.m_strForMsgPatId,
                                                     this.m_strForMsgDispPatId,
                                                     this.m_strForMsgDialysisNo,
                                                     this.m_strForMsgEdition)));
                }
                // 2015/10/23 中村 削除した透析実績の非表示対応 Add Start
                else
                {
                    // 最新の透析実績情報の取得
                    string strInXml = string.Format("<rootNode><DIALYSIS_NO>{0}</DIALYSIS_NO></rootNode>", exeInfo.SpecificKey);
                    string strOutXml = string.Empty;
                    fn3Ret = base.DBExecQuery("00001", strInXml, ref strOutXml);
                    if (fn3Ret.IsError || fn3Ret.IsException)
                    {
                        return fn3Ret;
                    }
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(strOutXml);
                    string delFlg = Fn3ComTool.GetXmlValue(xmlDoc.LastChild, "//rootNode/RST_DIALYSIS/DEL_FLG");
                    if (!delFlg.Equals("1"))
                    {
                        // 変更による削除・新規の削除であるため、タグ変更はスキップ。
                        return Fn3ReturnCode.Success;
                    }

                    // 患者ID
                    string strPatId;
                    getNodeString(out strPatId, "//rootNode/PAT_BASIC_INFO/PATID", exeInfo);

                    // 表示用患者IDを取得
                    string strDispPatId;
                    fn3Ret = getNodeString(out strDispPatId, "//rootNode/PAT_BASIC_INFO/DISP_PATID", exeInfo);
                    if (fn3Ret.IsError || fn3Ret.IsException)
                    {
                        return fn3Ret;
                    }
                    long dispPatid;
                    if (!long.TryParse(strDispPatId, out dispPatid))
                    {
                        fn3Ret = ERR_PDFSERVERMAN_GET_PATID;
                        this.TraceOut(fn3Ret, strDispPatId);
                        return fn3Ret;
                    }
                    // 患者情報XMLの取得
                    string strPatientInfoXml = m_strPdfServerFolder + dispPatid.ToString() + @"\" + FILENAME_PATIENTINFO;
                    if (!File.Exists(strPatientInfoXml))
                    {
                        // トレース出力
                        this.DebugTraceOut(MODULE_MNAME_DRS + LOGTYPE_DBG + LOGTYPE_WNG +
                                           String.Format("対象の透析レポート情報が存在しない為、PDFサーバ管理モジュールの処理をスキップしました。({0})",
                                           String.Format("患者ID：{0} 表示用患者ID：{1} 透析番号：{2}",
                                                         strPatId,
                                                         strDispPatId,
                                                         exeInfo.SpecificKey)));
                        return Fn3ReturnCode.Success;
                    }
                    XmlDataDocument xmlPatInfo = new XmlDataDocument();
                    xmlPatInfo.Load(strPatientInfoXml);

                    // 透析レポート情報ルートの取得
                    XmlNode reportRoot = xmlPatInfo.SelectSingleNode("//rootNode/REPORTS");
                    if (reportRoot == null)
                    {
                        // トレース出力
                        this.DebugTraceOut(MODULE_MNAME_DRS + LOGTYPE_DBG + LOGTYPE_WNG +
                                           String.Format("対象の透析レポート情報が存在しない為、PDFサーバ管理モジュールの処理をスキップしました。({0})",
                                           String.Format("患者ID：{0} 表示用患者ID：{1} 透析番号：{2}",
                                                         strPatId,
                                                         strDispPatId,
                                                         exeInfo.SpecificKey)));
                        return Fn3ReturnCode.Success;
                    }

                    // 削除対象ノードの取得
                    XmlNode xmlDelSrc = xmlPatInfo.SelectSingleNode(string.Format("//rootNode/REPORTS/REPORT[@DIALYSIS_NO='{0}']", exeInfo.SpecificKey));
                    if (xmlDelSrc == null)
                    {
                        // トレース出力
                        this.DebugTraceOut(MODULE_MNAME_DRS + LOGTYPE_DBG + LOGTYPE_WNG +
                                           String.Format("対象の透析レポート情報が存在しない為、PDFサーバ管理モジュールの処理をスキップしました。({0})",
                                           String.Format("患者ID：{0} 表示用患者ID：{1} 透析番号：{2}",
                                                         strPatId,
                                                         strDispPatId,
                                                         exeInfo.SpecificKey)));
                        return Fn3ReturnCode.Success;
                    }

                    // REPORT_DELノードの作成
                    XmlElement xmlDelDes = xmlPatInfo.CreateElement("REPORT_DEL");
                    for (int i = 0; i < xmlDelSrc.Attributes.Count; i++)
                    {
                        xmlDelDes.Attributes.Append(xmlPatInfo.CreateAttribute(xmlDelSrc.Attributes[i].Name));
                        xmlDelDes.Attributes[xmlDelSrc.Attributes[i].Name].Value = xmlDelSrc.Attributes[i].Value;
                    }
                    // REPORTノードとREPORT_DELノードの置き換え
                    reportRoot.ReplaceChild(xmlDelDes, xmlDelSrc);
                    // 患者情報XMLの保存
                    xmlPatInfo.Save(strPatientInfoXml);

                    // トレース出力
                    this.DebugTraceOut(MODULE_MNAME_DRS + LOGTYPE_DBG + DEBUGTRACE_PRE_SUCCESS_MSG +
                                       String.Format("PDFサーバ管理モジュールの削除処理に成功しました。({0})",
                                       String.Format("患者ID：{0} 表示用患者ID：{1} 透析番号：{2}",
                                                     strPatId,
                                                     strDispPatId,
                                                     exeInfo.SpecificKey)));
                }
                // 2015/10/23 中村 削除した透析実績の非表示対応 Add End
            }
            catch (Exception ex)
            {
                fn3Ret = FTL_PDFSERVERMAN_EXCEPTION;
                this.ErrorTraceOut(fn3Ret, ex);
                return fn3Ret;
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());

            // 
            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 1ポーリング単位の終了処理
        /// </summary>
        protected override void EndProcess()
        {
            // ※特に処理はなし
            // 
        }

        /// <summary>
        /// 連携終了処理
        /// </summary>
        protected override void Stop()
        {
            // ※特に処理はなし
            // 
        }

        /// <summary>
        /// 解放処理
        /// </summary>
        protected override void Release()
        {
            // ※特に処理はなし
            // 
        }


        #region プライベートメソッド
        /// <summary>
        /// PDFサーバ情報XML更新処理
        /// </summary>
        /// <param name="strPdfServerInfoXml"></param>
        /// <param name="exeInfo"></param>
        /// <returns></returns>
        private Fn3ReturnCode updatePdfServerInfoXml(string strPdfServerInfoXml, Fn3ExecuteInfo exeInfo)
        {
            Fn3ReturnCode fn3Ret;
            string strNodeValue;
            string strEventValue;
            bool modFlag = false;
            
            //-- ファイルのロード
            XmlDocument xmlLoadDoc = new XmlDocument();
            xmlLoadDoc.Load(strPdfServerInfoXml);

            //------------------------------------------------------------
            // 対象ノードの選択
            //------------------------------------------------------------

            // 患者IDを取得
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/PATID", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }

            // 該当するノードを探す
            XmlNode targetNode = null;
            XmlNode rootNode = xmlLoadDoc.SelectSingleNode("//rootNode");
            XmlNodeList nodeList = rootNode.ChildNodes;
            foreach (XmlNode node in nodeList)
            {
                strNodeValue = node.Attributes.GetNamedItem("PATID").Value;
                if (strNodeValue == strEventValue)
                {
                    targetNode = node;
                    break;
                }
            }

            // なければ空の子ノードを追加
            if (targetNode == null)
            {
                XmlElement xmlEle = xmlLoadDoc.CreateElement("PATIENT");
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("DISP_PATID"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("PATID"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("NAME"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("KANA"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("SEX"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("BLOODABO"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("BLOODRH"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("AGE"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("UPDATE_DATETIME"));
                rootNode.AppendChild(xmlEle);

                targetNode = (XmlNode)xmlEle;
            }

            //------------------------------------------------------------
            // 属性の更新
            //------------------------------------------------------------
            //-- 表示用患者ID
            strNodeValue = targetNode.Attributes.GetNamedItem("DISP_PATID").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/DISP_PATID", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            // 2010/12/10 中村  
#if false
            //---- 桁補正
            if (m_intPatId_len < strEventValue.Length)
            {
                strEventValue = strEventValue.Substring(strEventValue.Length - m_intPatId_len, m_intPatId_len);
            }
            else
            {
                int intValue;
                if (int.TryParse(strEventValue, out intValue))
                {
                    strEventValue = string.Format("{0:D" + m_intPatId_len.ToString() + "}", intValue);
                }
            }
#else
            long longValue;
            if (long.TryParse(strEventValue, out longValue))
            {
                strEventValue = longValue.ToString();
            }
#endif
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("DISP_PATID").Value = strEventValue;
                modFlag = true;
            }

            //-- 患者ID
            strNodeValue = targetNode.Attributes.GetNamedItem("PATID").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/PATID", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("PATID").Value = strEventValue;
                modFlag = true;
            }

            //-- 患者名
            strNodeValue = targetNode.Attributes.GetNamedItem("NAME").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/NAME", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("NAME").Value = strEventValue;
                modFlag = true;
            }

            //-- フリガナ
            strNodeValue = targetNode.Attributes.GetNamedItem("KANA").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/NAME_KANA", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("KANA").Value = strEventValue;
                modFlag = true;
            }

            //-- 性別
            strNodeValue = targetNode.Attributes.GetNamedItem("SEX").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/SEX_CD", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("SEX").Value = strEventValue;
                modFlag = true;
            }

            //-- 血液型ABO
            strNodeValue = targetNode.Attributes.GetNamedItem("BLOODABO").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/BLOOD_TYPE_ABO", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("BLOODABO").Value = strEventValue;
                modFlag = true;
            }

            //-- 血液型RH
            strNodeValue = targetNode.Attributes.GetNamedItem("BLOODRH").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/BLOOD_TYPE_RH", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("BLOODRH").Value = strEventValue;
                modFlag = true;
            }

            //-- 年齢
            strNodeValue = targetNode.Attributes.GetNamedItem("AGE").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/BIRTHDAY", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- 書式化
            if (strEventValue.Length != 0)
            {
                strEventValue = strEventValue.Substring(0, 4) + "/" +
                                strEventValue.Substring(4, 2) + "/" +
                                strEventValue.Substring(6, 2);
            }
            //---- 誕生日から年齢へ
            strEventValue = getAgeFromBirthday(strEventValue);
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("AGE").Value = strEventValue;
                modFlag = true;
            }

            //-- 変更ありの場合のみ
            if (modFlag)
            {
                //-- 更新日時を更新
                DateTime dtNow = DateTime.Now;
                strEventValue = dtNow.ToString("yyyy/MM/dd HH:mm:ss");
                targetNode.Attributes.GetNamedItem("UPDATE_DATETIME").Value = strEventValue;
            }

            //------------------------------------------------------------
            // ソート
            //------------------------------------------------------------
            attributeSortNodeList(ref rootNode, "DISP_PATID", NodeSortType.ASC);

            //------------------------------------------------------------
            // ファイル更新
            //------------------------------------------------------------

            //-- 変更があれば、更新
            if (modFlag)
            {
                //-- ファイル更新
                xmlLoadDoc.Save(strPdfServerInfoXml);

            }
            return fn3Ret;
        }

        /// <summary>
        /// 患者情報XML更新処理
        /// </summary>
        /// <param name="strPatientInfoXml"></param>
        /// <param name="exeInfo"></param>
        /// <returns></returns>
        private Fn3ReturnCode updatePatientInfoXml(string strPatientInfoXml, Fn3ExecuteInfo exeInfo)
        {
            Fn3ReturnCode fn3Ret;
            XmlNode selNode;
            string strNodeValue;
            string strEventValue;
            bool modFlag = false;

            //------------------------------------------------------------
            // 患者情報部
            //------------------------------------------------------------

            //-- ファイルのロード
            XmlDocument xmlLoadDoc = new XmlDocument();
            xmlLoadDoc.Load(strPatientInfoXml);

            //-- 表示用患者ID
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/DISP_PATID");
            strNodeValue = selNode.InnerText;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/DISP_PATID", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }

            // 2010/12/10 中村
#if false
            //---- 桁補正
            if (m_intPatId_len < strEventValue.Length)
            {
                strEventValue = strEventValue.Substring(strEventValue.Length - m_intPatId_len, m_intPatId_len);
            }
            else
            {
                int intValue;
                if (int.TryParse(strEventValue, out intValue))
                {
                    strEventValue = string.Format("{0:D" + m_intPatId_len.ToString() + "}", intValue);
                }
            }
#else
            long longValue;
            if (long.TryParse(strEventValue, out longValue))
            {
                strEventValue = longValue.ToString();
            }
#endif
            m_strForMsgDispPatId = strEventValue;
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- 患者ID
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/PATID");
            strNodeValue = selNode.InnerText;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/PATID", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            m_strForMsgPatId = strEventValue;
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- 名前
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/NAME");
            strNodeValue = selNode.InnerText;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/NAME", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- フリガナ
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/KANA");
            strNodeValue = selNode.InnerText;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/NAME_KANA", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- 生年月日
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/BIRTHDAY");
            strNodeValue = selNode.InnerText;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/BIRTHDAY", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- 書式化
            if (strEventValue.Length != 0)
            {
                strEventValue = strEventValue.Substring(0, 4) + "/" +
                                strEventValue.Substring(4, 2) + "/" +
                                strEventValue.Substring(6, 2);
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- 年齢
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/AGE");
            strNodeValue = selNode.InnerText;
            //---- 誕生日から年齢へ
            strEventValue = getAgeFromBirthday(strEventValue);
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- 性別
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/SEX");
            strNodeValue = selNode.InnerText;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/SEX_CD", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- 入外区分
            selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT/INOUT");
            strNodeValue = selNode.InnerText;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/PAT_BASIC_INFO/INOUT_FLG", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                selNode.InnerText = strEventValue;
                modFlag = true;
            }

            //-- 変更ありの場合のみ
            if (modFlag)
            {
                //-- 更新日時を更新
                DateTime dtNow = DateTime.Now;
                strEventValue = dtNow.ToString("yyyy/MM/dd HH:mm:ss");

                selNode = xmlLoadDoc.SelectSingleNode("//rootNode/PATIENT");
                XmlNode attrNode = selNode.Attributes.GetNamedItem("UPDATE_DATETIME");
                attrNode.Value = strEventValue;
            }
                        
            //------------------------------------------------------------
            // レポート一覧部
            //------------------------------------------------------------
            bool reportModFlag = false;

            // 透析番号を取得
            fn3Ret = getNodeString(out strEventValue, "//rootNode/RST_DIALYSIS_HST/DIALYSIS_NO", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //-- フル桁に補完
            //strEventValue = string.Format("{0:D12}", int.Parse(strEventValue));

            // 該当するノードを探す
            XmlNode targetNode = null;
            XmlNode reportRoot = xmlLoadDoc.SelectSingleNode("//rootNode/REPORTS");
            XmlNodeList nodeList = reportRoot.ChildNodes;
            foreach (XmlNode node in nodeList)
            {
                strNodeValue = node.Attributes.GetNamedItem("DIALYSIS_NO").Value;
                if (strNodeValue == strEventValue)
                {
                    targetNode = node;
                    break;
                }
            }

            // なければ空の子ノードを追加
            if (targetNode == null)
            {
                XmlElement xmlEle = xmlLoadDoc.CreateElement("REPORT");
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("STARTDATE"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("STARTTIME"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("DATETIMEVALUE"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("BEDNAME"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("DIALYSIS_NO"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("EDITION"));
                xmlEle.Attributes.Append(xmlLoadDoc.CreateAttribute("UPDATE_DATETIME"));
                reportRoot.AppendChild(xmlEle);

                targetNode = (XmlNode)xmlEle;
            }

            //-- 開始日＆開始時刻
            fn3Ret = getNodeString(out strEventValue, "//rootNode/RST_DIALYSIS_HST/START_DATE", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- 日付を切り出し
            string strStartDate = strEventValue.Substring(0, 10);
            strNodeValue = targetNode.Attributes.GetNamedItem("STARTDATE").Value;
            //---- セット
            if (strNodeValue != strStartDate)
            {
                targetNode.Attributes.GetNamedItem("STARTDATE").Value = strStartDate;
                reportModFlag = true;
            }
            //---- 時刻を切り出し
            string strStartTime = strEventValue.Substring(11, 8);
            strNodeValue = targetNode.Attributes.GetNamedItem("STARTTIME").Value;
            //---- セット
            if (strNodeValue != strStartTime)
            {
                targetNode.Attributes.GetNamedItem("STARTTIME").Value = strStartTime;
                reportModFlag = true;
            }
            //---- 日付と時刻を区切りナシで連結
            strEventValue = strStartDate.Replace("/", "") + strStartTime.Replace(":", "");
            strNodeValue = targetNode.Attributes.GetNamedItem("DATETIMEVALUE").Value;
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("DATETIMEVALUE").Value = strEventValue;
                reportModFlag = true;
            }

            //-- ベッド名
            strNodeValue = targetNode.Attributes.GetNamedItem("BEDNAME").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/RST_DIALYSIS_HST/MST_BED/BED_NAME", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("BEDNAME").Value = strEventValue;
                reportModFlag = true;
            }

            //-- 透析番号
            strNodeValue = targetNode.Attributes.GetNamedItem("DIALYSIS_NO").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/RST_DIALYSIS_HST/DIALYSIS_NO", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            m_strForMsgDialysisNo = strEventValue;
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("DIALYSIS_NO").Value = strEventValue;
                reportModFlag = true;
            }

            //-- 版番
            strNodeValue = targetNode.Attributes.GetNamedItem("EDITION").Value;
            fn3Ret = getNodeString(out strEventValue, "//rootNode/RST_DIALYSIS_HST/EDITION", exeInfo);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                return fn3Ret;
            }
            m_strForMsgEdition = strEventValue;
            //---- セット
            if (strNodeValue != strEventValue)
            {
                targetNode.Attributes.GetNamedItem("EDITION").Value = strEventValue;
                reportModFlag = true;
            }

            //-- 変更ありの場合のみ
            if (reportModFlag)
            {
                //-- 更新日時を更新
                DateTime dtNow = DateTime.Now;
                strEventValue = dtNow.ToString("yyyy/MM/dd HH:mm:ss");
　              targetNode.Attributes.GetNamedItem("UPDATE_DATETIME").Value = strEventValue;
            }

            //------------------------------------------------------------
            // ソート
            //------------------------------------------------------------
            attributeSortNodeList(ref reportRoot, "DATETIMEVALUE", NodeSortType.DESC);

            //------------------------------------------------------------
            // ファイル更新
            //------------------------------------------------------------

            //-- 患者情報、レポート一覧どちらかでも変更があれば、更新
            if ((modFlag) || (reportModFlag))
            {
                //-- ファイル更新
                xmlLoadDoc.Save(strPatientInfoXml);

            }
            return fn3Ret;
        }


        /// <summary>
        /// ノードリストの属性値ソート処理
        /// </summary>
        /// <param name="targNode"></param>
        /// <param name="strSortAttribute"></param>
        /// <param name="sortType"></param>
        private void attributeSortNodeList(ref XmlNode targNode, string strSortAttribute, NodeSortType sortType)
        {
            // ソートタイプの計算子
            int intAscDesc;
            if (sortType == NodeSortType.ASC)
            {
                intAscDesc = 1;
            }
            else
            {
                intAscDesc = -1;
            }

            // エレメントに変換
            XmlElement root = (XmlElement)targNode;

            // 子供達を配列に転写
            XmlElement[] children = new XmlElement[root.ChildNodes.Count];
            int i = 0;
            foreach (XmlNode child in root.ChildNodes)
            {
                children[i++] = (XmlElement)child;
            }

            // 属性値でソート
            Array.Sort(children,
                       delegate(XmlElement x, XmlElement y)
                       {
                           return x.Attributes[strSortAttribute].Value.CompareTo(y.Attributes[strSortAttribute].Value) * intAscDesc;
                       });

            // レポート一覧をソート済みのものと入れ替える
            targNode.RemoveAll();
            foreach (XmlElement child in children)
            {
                targNode.AppendChild(child);
            }
        }

        /// <summary>
        /// 誕生日からの年齢取得処理
        /// </summary>
        /// <param name="strBirthday">誕生日（YYYY/MM/DD）</param>
        /// <returns>年齢</returns>
        private string getAgeFromBirthday(string strBirthday)
        {
            string strAge = "";

            if (strBirthday.Length != 0)
            {
                DateTime dt1 = DateTime.Now; //基準日
                DateTime dt2 = DateTime.Parse(strBirthday); //誕生日
                long d1 = System.Convert.ToInt64(dt1.ToString("yyyyMMdd")); //基準日を数値に変換
                long d2 = System.Convert.ToInt64(dt2.ToString("yyyyMMdd")); //誕生日を数値に変換
                int age = (int)Math.Floor((double)((d1 - d2) / 10000));
                strAge = age.ToString();
            }

            return strAge;
        }


        /// <summary>
        /// ノード取得ラッパー
        /// </summary>
        /// <param name="strRet"></param>
        /// <param name="strXPath"></param>
        /// <param name="exeInfo"></param>
        /// <returns></returns>
        private Fn3ReturnCode getNodeString(out string strRet, string strXPath, Fn3ExecuteInfo exeInfo)
        {
            XmlNode xmlNode;
            Fn3ReturnCode fn3Ret = Fn3ReturnCode.Success;
            strRet = "";

            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(strXPath);

            if (xmlNode == null)
            {
                fn3Ret = ERR_PDFSERVERMAN_NODE_NULL;
                this.TraceOut(fn3Ret, strXPath);
            }
            else
            {
                strRet = xmlNode.InnerText.Trim();
            }

            return fn3Ret;
        }

        /// <summary>
        /// 患者属性XML作成処理
        /// </summary>
        /// <param name="xmlDoc"></param>
        private void createPatientXmlTemplate(ref XmlDocument xmlDoc)
        {
            //-- XML宣言およびルート
            XmlElement xmlRoot = createXmlDecAndRoot(ref xmlDoc);

            //-- 患者情報部
            XmlElement xmlPatient = xmlDoc.CreateElement("PATIENT");
            xmlPatient.Attributes.Append(xmlDoc.CreateAttribute("UPDATE_DATETIME"));
            xmlRoot.AppendChild(xmlPatient);

            xmlPatient.AppendChild(xmlDoc.CreateElement("DISP_PATID"));
            xmlPatient.AppendChild(xmlDoc.CreateElement("PATID"));
            xmlPatient.AppendChild(xmlDoc.CreateElement("NAME"));
            xmlPatient.AppendChild(xmlDoc.CreateElement("KANA"));
            xmlPatient.AppendChild(xmlDoc.CreateElement("BIRTHDAY"));
            xmlPatient.AppendChild(xmlDoc.CreateElement("AGE"));
            xmlPatient.AppendChild(xmlDoc.CreateElement("SEX"));
            xmlPatient.AppendChild(xmlDoc.CreateElement("INOUT"));

            //-- レポート一覧部
            xmlRoot.AppendChild(xmlDoc.CreateElement("REPORTS"));

        }

        /// <summary>
        /// 空XML作成処理
        /// </summary>
        /// <param name="xmlDoc"></param>
        /// <returns></returns>
        private XmlElement createXmlDecAndRoot(ref XmlDocument xmlDoc)
        {
            //-- XML宣言
            xmlDoc.AppendChild(xmlDoc.CreateXmlDeclaration("1.0", "shift_jis", null));

            //-- XMLルート
            XmlElement xmlRoot = xmlDoc.CreateElement("rootNode");
            xmlDoc.AppendChild(xmlRoot);

            return xmlRoot;
        }
        #endregion



    }
}
