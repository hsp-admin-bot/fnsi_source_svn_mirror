//----------------------------------------------------------------------------------------------------
//  NKKPrinterクラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Printing;
using System.Runtime.InteropServices;
using System.ComponentModel;
#if DEBUG
    using System.Diagnostics;
#endif
using AdvanceSoftware;

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcLib
//----------------------------------------------------------------------------------------------------
using TdcLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebAccessLib
//----------------------------------------------------------------------------------------------------
using NKKWebAccessLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:ToGUILib
//----------------------------------------------------------------------------------------------------
using ToGUILib;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightLib
//----------------------------------------------------------------------------------------------------
namespace NKKWeightLib
{

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 印刷情報
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKPrinterInformation
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 印刷項目ID
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int nId = 0;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フォントサイズ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int nFontSize = 1;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// パラメータ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String strParams = String.Empty;
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKPrinterクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKPrinter : ToGUI
    {

#region プリンタ状態取得用API定義
        //----------------------------------------------------------------------------------------------------
        [DllImport("winspool.drv", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool OpenPrinter(string pPrinterName,
            out IntPtr hPrinter, IntPtr pDefault);
        //----------------------------------------------------------------------------------------------------
        [DllImport("winspool.drv", SetLastError = true)]
        private static extern bool ClosePrinter(IntPtr hPrinter);
        //----------------------------------------------------------------------------------------------------
        [DllImport("winspool.drv", SetLastError = true)]
        private static extern bool GetPrinter(IntPtr hPrinter,
            int dwLevel, IntPtr pPrinter, int cbBuf, out int pcbNeeded);
        //----------------------------------------------------------------------------------------------------
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct PRINTER_INFO_2
        {
            public string pServerName;
            public string pPrinterName;
            public string pShareName;
            public string pPortName;
            public string pDriverName;
            public string pComment;
            public string pLocation;
            public IntPtr pDevMode;
            public string pSepFile;
            public string pPrintProcessor;
            public string pDatatype;
            public string pParameters;
            public IntPtr pSecurityDescriptor;
            public uint Attributes;
            public uint Priority;
            public uint DefaultPriority;
            public uint StartTime;
            public uint UntilTime;
            public uint Status;
            public uint cJobs;
            public uint AveragePPM;
        }
        //----------------------------------------------------------------------------------------------------
#endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// レシートプリンタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static readonly string PRINTER_NAME = "ScalesPrinter";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// KIOSKレシートプリンタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static readonly string PRINTER_NAME_KIOSK = "NII Printer_D-Raster USB HW";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// バーコード印刷時の改行高さ
        /// フォント小
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly int m_nSmallBarcodeHeigh = 35;
        //private static readonly int m_nSmallBarcodeHeigh = 15;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// バーコード印刷時の改行高さ
        /// フォント中
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        //private static readonly int m_nMiddleBarcodeHeigh = 25;
        private static readonly int m_nMiddleBarcodeHeigh = 60;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// バーコード印刷時の改行高さ
        /// フォント大
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly int m_nLargeBarcodeHeigh = 100;
        //private static readonly int m_nLargeBarcodeHeigh = 50;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 各行間高さ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly int m_nLineGap = 4;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = "Printer";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 印刷開始行番号
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nPrintLineCount = 0;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 行印刷情報
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Dictionary<int, NKKPrinterInformation> m_listPrintInfomation;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 行データ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Dictionary<int, String> m_listPrintData;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Exception Error
        {
            get { return (this.m_Exception); }
            set
            {
                m_Exception = value;

                if (value != null)
                {
                    // ログ記録クラス取得
                    NKKLogging log = NKKLogging.GetInstance();

                    // 履歴作成
                    DateTime dtlog = DateTime.Now;
                    String strlogdata = String.Format("{0}, {1}", this.GetType().Name, value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    log.AddLogInfo(dtlog, this.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(this.SERVICE_NAME + " " + strlogdata);
#endif
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 行フォントサイズ設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Dictionary<int, NKKPrinterInformation> PrintInfomation
        {
            set { this.m_listPrintInfomation = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 行データ設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Dictionary<int, String> PrintData
        {
            set { this.m_listPrintData = value; }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKPrinter()
        {

        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        ~NKKPrinter()
        {

        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定プリンタ名の登録チェック
        /// </summary>
        /// <param name="strPrinterName">チェックを行うプリンタ名</param>
        /// <returns>登録状態(true:登録あり/false：登録なし)</returns>
        //----------------------------------------------------------------------------------------------------
        public static Boolean IsPrinterExist(String strPrinterName)
        {
            Boolean bret = false;

            // 登録一覧
            foreach (string strname in PrinterSettings.InstalledPrinters)
            {
                // 指定プリンター名と比較
                if (strname.Equals(strPrinterName))
                {
                    bret = true;

                    break;
                }
            }

            return bret;
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 印刷処理
        /// </summary>
        /// <returns>印刷結果(false:失敗/true:成功)</returns>
        //----------------------------------------------------------------------------------------------------
        public Boolean PrintOut(String PrinterName)
        {
            Boolean bret = false;
            String strlog = String.Empty;
            PRINTER_INFO_2 prtinfo;
            String strPrintStatusHex = String.Empty;
            const String HEX_FORMAT= "X8";

            try
            {
                // 印刷開始行初期化
                this.m_nPrintLineCount = 0;

                // プリンタの状態を取得する
                prtinfo = GetPrinterInfo(PrinterName);
                strPrintStatusHex = prtinfo.Status.ToString(HEX_FORMAT);

                // #12708 2026.05.19 mod プリンタが使用可能状態であれば印刷を行うようにする TDC米沢 start
                //// 状態判定
                //if (prtinfo.Status.Equals(0))
                //{
                ////　印刷準備
                //PrintDocument pdPrint = new PrintDocument();

                //// プリンタ設定
                //pdPrint.PrinterSettings.PrinterName = PrinterName;
                //pdPrint.DocumentName = "体重計システム";

                //// 印刷用イベント登録
                //pdPrint.PrintPage += new PrintPageEventHandler(this.Printer_PrintPage);

                //// PrintControllerプロパティをStandardPrintControllerにして印刷中ダイアログを非表示にする
                //pdPrint.PrintController =
                //    new System.Drawing.Printing.StandardPrintController();

                //　印刷準備
                PrintDocument pdPrint = new PrintDocument();

                // プリンタ設定
                pdPrint.PrinterSettings.PrinterName = PrinterName;
                pdPrint.DocumentName = "体重計システム";

                // 印刷用イベント登録
                pdPrint.PrintPage += new PrintPageEventHandler(this.Printer_PrintPage);

                // PrintControllerプロパティをStandardPrintControllerにして印刷中ダイアログを非表示にする
                pdPrint.PrintController =
                    new System.Drawing.Printing.StandardPrintController();

                // プリンタの使用可能判定
                if (pdPrint.PrinterSettings.IsValid)
                {
                    // プリンタ使用可能
                    // #12708 2026.05.19 mod プリンタが使用可能状態であれば印刷を行うようにする TDC米沢 end
                    strlog = "印刷開始";

                    // 履歴
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);
                    // GUIへ通知
                    this.SendMessageToGUI("接続中", DateTime.Now, strlog);

                    while (this.m_nPrintLineCount < this.m_listPrintInfomation.Count)
                    {
                        // 印刷開始
                        pdPrint.Print();
                    }

                    // #12708 2026.05.19 mod 印刷終了後にプリンタ状態にて印刷終了を判断しない TDC米沢 start
                    //// プリンタの状態を取得する
                    //prtinfo = GetPrinterInfo(PrinterName);
                    //strPrintStatusHex = prtinfo.Status.ToString(HEX_FORMAT);

                    //// 状態判定
                    //if ( prtinfo.Status.Equals(0))
                    //{

                    //    // 印刷成功

                    //    strlog = "印刷成功";

                    //    // ログ記録
                    //    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                    //    // GUIへ通知
                    //    this.SendMessageToGUI("接続中", DateTime.Now, strlog);

                    //    bret = true;
                    //}
                    //else
                    //{
                    //    // プリンタ印刷失敗
                    //    throw new Exception("プリンタエラー:" + strPrintStatusHex);
                    //}

                    // 印刷成功

                    strlog = "印刷成功";

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                    // GUIへ通知
                    this.SendMessageToGUI("接続中", DateTime.Now, strlog);

                    bret = true;
                    // #12708 2026.05.19 mod 印刷終了後にプリンタ状態にて印刷終了を判断しない TDC米沢 end
                }
                else
                {
                    // プリンタ印刷不可状態
                    throw new Exception("プリンタエラー:" + strPrintStatusHex);
                }
            }
            catch (Exception ex )
            {
                // 印刷失敗

                this.Error = ex;

                // GUIへ通知
                this.SendMessageToGUI("接続中", DateTime.Now, "印刷失敗:" + strPrintStatusHex);
            }

            return bret;
        }
        //----------------------------------------------------------------------------------------------------


#region プライベートメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// プリンタの情報をPRINTER_INFO_2で取得する
        /// </summary>
        /// <param name="printerName">プリンタ名</param>
        /// <returns>プリンタの情報</returns>
        //----------------------------------------------------------------------------------------------------
        public static PRINTER_INFO_2 GetPrinterInfo(string printerName)
        {
            IntPtr hPrinter = IntPtr.Zero;
            IntPtr pPrinterInfo = IntPtr.Zero;

            // プリンタハンドルを取得
            if (!OpenPrinter(printerName, out hPrinter, IntPtr.Zero))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }

            // プリンタ情報取得
            try
            {
                // 必要なバイト数を取得
                int needed;
                GetPrinter(hPrinter, 2, IntPtr.Zero, 0, out needed);
                if (needed <= 0)
                    throw new Exception("失敗しました。");

                // Globalメモリを割り当て
                pPrinterInfo = Marshal.AllocHGlobal(needed);

                // プリンタ情報を取得
                int temp;
                if (!GetPrinter(hPrinter, 2, pPrinterInfo, needed, out temp))
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                }

                // PRINTER_INFO_2型にマーシャリング
                PRINTER_INFO_2 printerInfo =
                    (PRINTER_INFO_2)Marshal.PtrToStructure(pPrinterInfo,
                    typeof(PRINTER_INFO_2));

                // プリンタ情報を返す
                return printerInfo;
            }
            finally
            {
                // プリンタハンドルをクローズしてメモリを解放
                if (hPrinter != IntPtr.Zero)
                {
                    ClosePrinter(hPrinter);
                }
                if (pPrinterInfo != IntPtr.Zero) 
                {
                    Marshal.FreeHGlobal(pPrinterInfo);
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, this.SERVICE_NAME, LoggingClass, strMesssage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI通知
        /// </summary>
        /// <param name="strStatus">状態</param>
        /// <param name="dtOccurDate">発生日時</param>
        /// <param name="strMessage">内容</param>
        //----------------------------------------------------------------------------------------------------
        private void SendMessageToGUI(String strStatus, DateTime dtOccurDate, String strMessage)
        {
            // GUIへ通知
            base.SendMessageToGUI(this.SERVICE_NAME, strStatus, dtOccurDate, strMessage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 印刷実行
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void Printer_PrintPage(object sender, PrintPageEventArgs e)
        {
            ArrayList text = new ArrayList();
            int yPos = 0;
            int Pos = 10;
            string sDat = "";

            ////----------------------------------------------------------------------------------------------------
            ///// <summary>
            ///// 通常フォント
            ///// </summary>
            ////----------------------------------------------------------------------------------------------------
            //Font printFont = new Font("ＭＳ ゴシック", 10);
            ////----------------------------------------------------------------------------------------------------
            ///// <summary>
            ///// Japanese11 フォント置換用 
            ///// </summary>
            ////----------------------------------------------------------------------------------------------------
            //Font printBoldFont = new Font("ＭＳ ゴシック", 14, FontStyle.Bold);
            ////----------------------------------------------------------------------------------------------------
            ///// <summary>
            ///// Control フォント置換用 
            ///// </summary>
            ////----------------------------------------------------------------------------------------------------
            //Font controlFont = new Font("Arial", 1);
            ////----------------------------------------------------------------------------------------------------

            ////----------------------------------------------------------------------------------------------------
            ///// <summary>
            ///// バーコード(NW-7(Codabar))
            ///// </summary>
            ////----------------------------------------------------------------------------------------------------
            //Font BarcodeFont1 = new Font("Courier New", 21.0F);
            ////----------------------------------------------------------------------------------------------------
            ///// <summary>
            ///// バーコード(JAN13) 
            ///// </summary>
            ////----------------------------------------------------------------------------------------------------
            //Font BarcodeFont2 = new Font("Times New Roman", 14.0F);
            ////----------------------------------------------------------------------------------------------------

            // 次ページなし
            e.HasMorePages = false;

            int iID = 0;
            int iIDFont = 1;
            
            //
            for (; this.m_nPrintLineCount < this.m_listPrintInfomation.Count; this.m_nPrintLineCount++)
            {
                // 
                NKKPrinterInformation info = this.m_listPrintInfomation[this.m_nPrintLineCount];

                // 設定の有無を判断する
                if ( true )
                {
                    iID = info.nId;
                    iIDFont = info.nFontSize;
                    sDat = this.m_listPrintData[this.m_nPrintLineCount];

                    Font printFont = new Font("ＭＳ ゴシック", NKKPrinter.GetFontSize(iIDFont));
                    // debug
                    //e.Graphics.DrawString(this.m_nPrintLineCount.ToString(), printFont, Brushes.Black, 0.0f, (float)(yPos));

                    //
                    if (iID == 4)
                    {
                        // 用紙カット

                        this.m_nPrintLineCount++;

                        break;
                    }
                    //else if (iID == 57 ||    // 改行（１行）
                    //         iID == 58 ||    // 改行（２行）
                    //         iID == 59 ||    // 改行（３行）
                    //         iID == 60 ||    // 改行（４行）
                    //         iID == 61       // 改行（５行）
                    //        )
                    //{
                    //    //実数のフォントサイズで改行
                    //    yPos += (int)(NKKPrinter.GetFontSize(iIDFont) * (iID - 56) + NKKPrinter.m_nLineGap);        
                    //}
                    else
                    {
                        // バーコード判定
                        if (iID == 2
                         || iID == 3)
                        {
                            //String strBarcodeName = String.Empty;
                            //if ( iID == 2 )
                            //{
                            //    // Codabar = NW-7
                            //    // Codabar（NW-7）バーコードで任意のスタート／ストップキャラクタを指定するには、
                            //    // 半角大文字の"A"～"D"を、データの前後に付加してセットしてください。
                            //    strBarcodeName = "Courier New";
                            //    sDat = "A" + sDat + "A";
                            //}
                            //else
                            //{
                            //    // JAN-13
                            //    strBarcodeName = "Times New Roman";
                            //    if( 12 <= sDat.Length )
                            //    {
                            //        // モジュラス01/ウエイト3算出

                            //        sDat = sDat.PadLeft(12, '0');

                            //        int x = 0;
                            //        for (int i = 0; i < sDat.Length; i++)
                            //        {
                            //            x += int.Parse(sDat[sDat.Length - 1 - i].ToString()) * ((i % 2 == 0) ? 3 : 1);
                            //        }

                            //        x = (10 - (x % 10)) % 10;

                            //        sDat += x;
                            //    }
                            //}

                            // バーコードフォントのサイズに合わせて改行高さを変更する
                            // TODO：バーコードの高さが変えられない
                            // ※フォントのサイズとバーコードフォントのサイズは連動しない
                            // サイズ変更はプリンタ側の「バーコード設定」にて変更が可能
                            float xflg = 0;
                            if (iIDFont == 0)
                            {
                                // フォントサイズ小
                                xflg = m_nSmallBarcodeHeigh;
                            }
                            else if (iIDFont == 1)
                            {
                                // フォントサイズ中
                                xflg = m_nMiddleBarcodeHeigh;
                            }
                            else
                            {
                                // フォントサイズ大
                                xflg = m_nLargeBarcodeHeigh;
                            }
                            //// バーコード印刷(フォント指定)
                            //Font barcodeFont = new Font(strBarcodeName, xflg);
                            //e.Graphics.DrawString(sDat, barcodeFont, Brushes.Black, (float)10, (float)(yPos));
                            // バーコード印刷(VB-Barcode)
                            System.Drawing.Image img = MakeBarcode(iID - 2, sDat, (int)xflg);
                            // #12652 2026.05.19 mod バーコードが不正な場合は描画せずにログを記録して次の印刷処理を行うようにする TDC米沢 start
                            //e.Graphics.DrawImage(img, (float)10, (float)yPos, 270, xflg);

                            //// バーコードフォントのサイズに合わせて次の印字開始行を調整する
                            ////Pos = (int)barcodeFont.GetHeight(e.Graphics);
                            ////Pos = 110;
                            ////yPos += Pos + NKKPrinter.m_nLineGap;
                            ////Debug.Print(String.Format("name:{0},size:{1}", strBarcodeName, Pos));
                            //yPos += (int)xflg + NKKPrinter.m_nLineGap;
                            if (img != null)
                            {
                                // 有効なバーコードの場合

                                // バーコード描画
                                e.Graphics.DrawImage(img, (float)10, (float)yPos, 270, xflg);

                                // バーコードフォントのサイズに合わせて次の印字開始行を調整する
                                yPos += (int)xflg + NKKPrinter.m_nLineGap;
                            }
                            else
                            {
                                // 無効なバーコードの場合

                                // ログ記録
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("バーコード生成失敗, 値: [{0}]", sDat));
                            }
                            // #12652 2026.05.19 mod バーコードが不正な場合は描画せずにログを記録して次の印刷処理を行うようにする TDC米沢 end

                        }
                        else
                        {
                            //大フォントの場合再調整を行う。
                            if (iIDFont == 2)
                            {
                                //シート最大を360と仮定する
                                Encoding sjisEnc = Encoding.GetEncoding("Shift_JIS");

                                //int num = sjisEnc.GetByteCount(sDat);
                                int num = 0;

                                //sDatに改行コードがあれば改行コードで二つに割って、文字列が多いほうを基準に計算する
                                if (sDat.IndexOf("\r\n") > 0)
                                {
                                    //改行コードで半分にし長いほうの文字列を返す
                                    //num = CrlfSplitLength(sDat, sjisEnc, num);
                                }
                                else
                                {
                                    num = sjisEnc.GetByteCount(sDat);
                                }

                                if (num > 18)
                                {
                                    double dFont = 360 / num;
                                    int iFong = int.Parse(dFont.ToString());
                                    printFont = new Font("ＭＳ ゴシック", NKKPrinter.GetFontSize(iFong));
                                }
                            }
                            else if (iIDFont == 1)
                            {
                                Encoding sjisEnc = Encoding.GetEncoding("Shift_JIS");

                                int num = 0;
                                //sDatに改行コードがあれば改行コードで二つに割って、文字列が多いほうを基準に計算する
                                if (sDat.IndexOf("\r\n") > 0)
                                {
                                    //改行コードで半分にし長いほうの文字列を返す
                                    //num = CrlfSplitLength(sDat, sjisEnc, num);
                                }
                                else
                                {
                                    num = sjisEnc.GetByteCount(sDat);
                                }
                                //sDatに改行コードがあれば改行コードで二つに割って、文字列が多いほうを基準に計算する
                                //<<<< CHG A.Watanabe 2013/09/19 次回予定日印刷が必ず小さいフォントで印刷される #2729 #600

                                if (num > 24)
                                {
                                    double dFont = 360 / num;
                                    int iFong = int.Parse(dFont.ToString());
                                    printFont = new Font("ＭＳ ゴシック", NKKPrinter.GetFontSize(iFong));
                                }

                            }

                            // 印刷
                            e.Graphics.DrawString(sDat, printFont, Brushes.Black, (float)10, (float)(yPos));
                            Pos = (int)(printFont.GetHeight(e.Graphics));

                            // 次の印刷開始行
                            yPos += (int)(Pos + NKKPrinter.m_nLineGap);

                            //sDatに改行コードがあれば改行して次の印字にまわす。
                            if (sDat.IndexOf("\r\n") > 0)
                            {
                                //実数のフォントサイズで改行
                                yPos += (int)(NKKPrinter.GetFontSize(iIDFont) * (1) + NKKPrinter.m_nLineGap);
                            }
                        }
                    }
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フォントサイズを返す
        /// </summary>
        /// <param name="iNo">
        /// フォント番号</param>
        /// <returns>
        /// フォントサイズ</returns>
        //----------------------------------------------------------------------------------------------------
        private static float GetFontSize(int iNo)
        {
            float Siz = 5.0F;
            switch (iNo)
            {
                case 0: Siz = 10.0F; break;
                case 1: Siz = 15.0F; break;
                case 2: Siz = 20.0F; break;
                default:
                    Siz = float.Parse(iNo.ToString());
                    break;
            }
            return Siz;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// メタ画像形式バーコード作成
        /// </summary>
        /// <param name="barcodetype">0:Codabar(NW-7)/1:JAN13</param>
        /// <param name="data">バーコードメッセージ内容</param>
        /// <returns>作成したバーコードのメタ画像</returns>
        //----------------------------------------------------------------------------------------------------
        private System.Drawing.Image MakeBarcode(int barcodetype, String data, int height)
        {
            AdvanceSoftware.VBBarCode4.BarCodeControl bc = new AdvanceSoftware.VBBarCode4.BarCodeControl();

            try
            {

                // バーコード種別
                if (barcodetype == 1)
                {
                    // JAN13
                    bc.Type = AdvanceSoftware.VBBarCode4.BarCodeType.JAN13;
                }
                else
                {
                    // NW-7
                    bc.Type = AdvanceSoftware.VBBarCode4.BarCodeType.CodaBar;
                }

                // サイズ単位 (省略可)
                bc.Unit = AdvanceSoftware.VBBarCode4.Unit.Pixel;
                // x , y 方向の解像度 (省略可)
                //bc1.DpiX = 96;
                //bc1.DpiY = 96;
                // チェックデジットの付加 (省略可)
                if (barcodetype == 0)
                {
                    bc.CheckCharMode = false;
                }
                else if (barcodetype == 1)
                {
                    bc.CheckCharMode = true;
                }
                else
                {
                    bc.CheckCharMode = true;
                }

                // バーコードの高さ (省略可)
                //bc.BarHeight = 100;    // [0] で "自動設定" となります。
                bc.BarHeight = height;
                // バーコードの幅 (省略可)
                //bc.BarWidth = 270;     // [0] で "自動設定" となります。
                bc.BarWidth = 0;

                // バーコードメッセージ内容
                bc.Value = data;

                // バーコードメッセージの付加 (省略可)
                bc.ShowMessage = false;

            }
            catch (Exception ex)
            {
                this.Error = ex;

                // GUIへ通知
                this.SendMessageToGUI("接続中", DateTime.Now, "バーコード生成失敗");
            }

            return (bc.GetBarCodeImage( System.Drawing.Imaging.ImageFormat.Bmp, true));
        }
        //----------------------------------------------------------------------------------------------------

        #endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
