//----------------------------------------------------------------------------------------------------
//  NKKFalicaクラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Text;
using System.Reflection;
using System.Net;
using System.Linq;

#if DEBUG
using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKFelicaLib
//----------------------------------------------------------------------------------------------------
using NKKFelicaLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebAccessLib
//----------------------------------------------------------------------------------------------------
using NKKWebAccessLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebClientLib
//----------------------------------------------------------------------------------------------------
using NKKWebClientLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:ToGUILib
//----------------------------------------------------------------------------------------------------
using ToGUILib;
//add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
using System.Threading;
using System.Collections.Generic;
//add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
//----------------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------------
//  名前空間:NKKAccessCardLib
//----------------------------------------------------------------------------------------------------
namespace NKKAccessCardLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKFalicaクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKFalica : ToGUI
    {

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = "Felica";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// カード情報通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_CARD_VALUE_URI = "/api/card_state/card";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// カード情報通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_CARD_STATUS_URI = "/api/card_state/status";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// felicaカード読み書きオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly FelicaLibTdc m_Felica = new FelicaLibTdc();
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計管理番号
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strWeightCd = String.Empty;
        //----------------------------------------------------------------------------------------------------

        private const String BROWSER = "BROWSER";
        private const String CARD_CLIENT = "CARD_CLIENT";
        private const String CARD_READER_STATUS = "CARD_READER_STATUS";
        private const String CARD_STAFF_INFO = "CARD_STAFF_INFO";
        private const String CARD_PAT_INFO = "CARD_PAT_INFO";

        public static Boolean cardDeviceStatus = false;
        public static NKKFalica felica;
        public static ushort dataVer = 0;
        public static string card_idm = "";
        #region パブリックプロパティ

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
                    this.AddLogInfo( dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(this.SERVICE_NAME + " " + strlogdata);
#endif
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計管理番号参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String WeightCd
        {
            get { return (this.m_strWeightCd); }
            set { this.m_strWeightCd = value; }
        }
        //----------------------------------------------------------------------------------------------------

        #endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKFalica()
        {

            // 構築処理

            // フェリカカードシステムコード
            FelicaLibTdc.IcSystemCode = "88D5";
            // フェリカカードサービスコード１
            FelicaLibTdc.IcServiceCode1 = "0049";
            // フェリカカードサービスコード２
            FelicaLibTdc.IcServiceCode2 = "0089";

            // イベントハンドラ登録
            // エラー発生時イベントハンドラ
            FelicaLibTdc.FelicaErrorEvent += this.FelicaError;
            // 情報ログイベントハンドラ
            FelicaLibTdc.FelicaInfoEvent += this.FelicaInfo; 
            // カード接続情報変更イベントハンドラ
            FelicaLibTdc.FelicaConnectChangeEvent += this.FalicaConnectChanged;
            // カード読込情報変更イベントハンドラ
            FelicaLibTdc.FelicaChangeEvent += this.FelicaChanged;
        }

        public static NKKFalica GetInstance()
        {
            if (felica == null)
            {
                NKKFalica felica = new NKKFalica();
            }
            return felica;
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        ~NKKFalica()
        {
            //
            FelicaLibTdc.PollingThreadEnd();
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// カード読み込み開始
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Start()
        {
            DateTime dtnow = DateTime.Now;
            //
            FelicaLibTdc.PollingThreadStart();

            // ログ記録
            String strlog = "カード通信開始";
            this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

            // GUIへ通知
            this.SendMessageToGUI("切断中", dtnow, strlog);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// カード読み込み終了
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Stop()
        {
            DateTime dtnow = DateTime.Now;

            //
            FelicaLibTdc.PollingThreadEnd();

            // ログ記録
            String strlog = "カード通信終了";
            this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

            // GUIへ通知
            this.SendMessageToGUI("切断中", dtnow, strlog);
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
        //  フェリカカード書き込み
        /// </summary>
        /// <param name="data">書き込み情報</param>
        /// <returns>true：書き込み成功/false：書き込み失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public Boolean WritePatCard(String data)
        {
            Boolean bret = false;
            String strlog = String.Empty;

            lock (FelicaLibTdc.LockoObj)
            {
                try
                {

                    // オープン
                    if (FelicaLibTdc.Open() == true)
                    {
                        // システムコード
                        Byte[] syscode = new byte[2];
                        syscode[0] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(0, 2), 16);
                        syscode[1] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(2, 2), 16);
                        // サービスコード①  例：0049→{ 0x49, 0x00 }
                        Byte[] servicecode1 = new byte[2];
                        servicecode1[0] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(2, 2), 16);
                        servicecode1[1] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(0, 2), 16);

                        // 書き込み用のデータ作成(64byte：4ブロック * 16byte)
                        Byte[] writeData_ServiceCode1 = Enumerable.Repeat<Byte>(0x00, 64).ToArray();
                        if (0 < data.Length)
                        {
                            // 指定データを上書き(64byteまで)
                            Byte[] bbuff = ASCIIEncoding.ASCII.GetBytes(data);
                            if (bbuff.Length <= 64)
                            {
                                Array.Copy(bbuff, writeData_ServiceCode1, bbuff.Length);
                            }
                            else
                            {
                                return false;
                            }
                        }

                        NKKLogging.LOGGING_CLASS type = NKKLogging.LOGGING_CLASS.INFO;

                        // サービスコード①に書き込み
                        bret = FelicaLibTdc.Write(writeData_ServiceCode1, syscode, servicecode1, 4);
                        if (bret == true)
                        {
                            // サービスコード①に書き込み成功

                            // 
                            // ログ記録
                            strlog = String.Format("カード書き込み成功,data:{0}", data);
                        }
                        else
                        {
                            // サービスコード①に書き込み失敗

                            //String errMsg = FelicaLibTdc.FelicaError.ToString();
                            //errMsg += "\n\n";
                            //errMsg += FelicaLibTdc.RwError.ToString();

                            // ログ記録
                            strlog = String.Format("カード書き込み失敗,data:{0},{1}", data, FelicaLibTdc.RwError.ToString());

                            type = NKKLogging.LOGGING_CLASS.ERROR;
                        }

                        // ログ記録
                        this.AddLogInfo(DateTime.Now, type, strlog);

                        // GUIへ通知
                        this.SendMessageToGUI("カード書き込み", DateTime.Now, strlog);
                    }
                    else
                    {
                        // オープン失敗

                        String errMsg = FelicaLibTdc.FelicaError.ToString();
                        errMsg += "\n\n";
                        errMsg += FelicaLibTdc.RwError.ToString();

                        // ログ記録
                        strlog = String.Format("カード書き込み失敗,data:{0},{1}", data, errMsg);
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);
                    }
                }
                catch (Exception e)
                {
                    this.Error = e;
                }
                finally
                {
                    // フェリカカードクローズ
                    FelicaLibTdc.Close();
                }
            }

            return bret;
        }
        //----------------------------------------------------------------------------------------------------


        #region イベント定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// カードリーダー接続状態変更時イベント
        /// </summary>
        /// <param name="bStatus">接続状態(true：接続ON、false：接続OFF)</param>
        //----------------------------------------------------------------------------------------------------
        private void FalicaConnectChanged( Boolean? bStatus )
        {
            cardDeviceStatus = (Boolean)bStatus;

            DateTime dtnow = DateTime.Now;

            // 接続判定
            String strlog = "切断中";
            if( bStatus == true )
            {
                strlog = "接続中";
            }

            // ログ記録
            this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

            // GUIへ通知
            this.SendMessageToGUI(strlog, dtnow, String.Empty);

            // mod FNSI-4200ポートを使用している 孫 start
            //string strdata = String.Format("{0}\t{1}\t{2}", CARD_CLIENT, CARD_READER_STATUS, bStatus.ToString());
            string strdata = String.Format("{0}\t{1}\t{2}\t{3}", CARD_CLIENT, CARD_READER_STATUS, bStatus.ToString(), NKKWebAppSocketConfig.WS_PORT.ToString());
            // mod FNSI-4200ポートを使用している 孫 end
            NKKWebAppSocket.GetInstance()?.SendMessage(strdata);
#if DEBUG
            //
            Debug.WriteLine("{0}{1}", MethodBase.GetCurrentMethod().Name, strlog);
#endif
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// カード接続情報変更時イベント
        /// </summary>
        /// <param name="strIdm">カード番号(テキスト)</param>
        /// <param name="bIdm">カード番号(バイト配列)</param>
        //----------------------------------------------------------------------------------------------------
        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
        //private void FelicaChanged(String strIdm, Byte[] bIdm)
        private bool FelicaChanged(String strIdm, Byte[] bIdm)
        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
        {
            card_idm = TdcLib.TdcLib.GetByteToHexString(bIdm);
            DateTime dtnow = DateTime.Now;
            String strlog = String.Empty;
            dataVer = 0;
            try
            {
                if (strIdm == String.Empty)
                {
                    // ログ記録
                    // mod 2021-08-23 #5841:カードリーダサービスのカードを外した時のログがカートになっているの対応 孫 start
                    //this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "カートなし");
                    this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "カードなし");
                    // mod 2021-08-23 #5841:カードリーダサービスのカードを外した時のログがカートになっているの対応 孫 end

                    // GUIへ通知
                    this.SendMessageToGUI( "カードなし", dtnow, strlog);

                }
                else
                {
                    // カード情報読込
                    // システムコード
                    Byte[] syscode = new byte[2];
                    syscode[0] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(0, 2), 16);
                    syscode[1] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(2, 2), 16);
                    // サービスコード①  例：0049→{ 0x49, 0x00 }
                    Byte[] servicecode1 = new byte[2];
                    servicecode1[0] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(2, 2), 16);
                    servicecode1[1] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(0, 2), 16);

                    // サービスコード①の情報取得(64byte：4ブロック * 16byte)
                    Byte[] bcode1 = FelicaLibTdc.Read(syscode, servicecode1, 4);
                    if (null == bcode1)
                    {
                        //errMsg = FelicaLibTdc.FelicaError.ToString();
                        //errMsg += "\n\n";
                        //errMsg += FelicaLibTdc.RwError.ToString();

                        //// メッセージ表示・ログ書き込み
                        //Cmn.LogFrmMessg(64, "カード読込エラー", errMsg);
                        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
                        //return;
                        return false;
                        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
                    }
                    else
                    {
                        // サービスコード②の情報取得

                        // サービスコード② 例：0089→{ 0x89, 0x00 }
                        Byte[] servicecode2 = new byte[2];
                        servicecode2[0] = Convert.ToByte(FelicaLibTdc.IcServiceCode2.Substring(2, 2), 16);
                        servicecode2[1] = Convert.ToByte(FelicaLibTdc.IcServiceCode2.Substring(0, 2), 16);
                        // サービスコード②の情報を構造体にセット(320byte：20ブロック * 16byte)
                        Byte[] bcode2 = FelicaLibTdc.Read(syscode, servicecode2, 20);
                        if (null == bcode2)
                        {
                            // エラー
                            //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
                            //return;
                            return false;
                            //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
                        }
                        else
                        {
                            // カード番号/カード情報：Text→Hex
                            //strlog = String.Format("Idm:{0}, ServeCode1:{1}, ServiceCode2:{2}"
                            //            , TdcLib.TdcLib.GetByteToHexString(bIdm)
                            //            , TdcLib.TdcLib.GetByteToHexString(bcode1)
                            //            , TdcLib.TdcLib.GetByteToHexString(bcode2)
                            //);
                            strlog = String.Format("Idm:{0}, ServeCode1:{1}"
                                        , TdcLib.TdcLib.GetByteToHexString(bIdm)
                                        , TdcLib.TdcLib.GetByteToHexString(bcode1)
                            );

                            // 
                            // ログ記録
                            this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードあり:{0}", strlog));

                            // カード番号/カード情報：Text
                            //strlog = String.Format("Id:{0}, Name:{1}, ServiceCode2:{2}"
                            //            , Encoding.ASCII.GetString(bcode1, 0, 16).TrimEnd('\0')
                            //            , Encoding.Unicode.GetString(bcode1, 16, bcode1.Length - 16).TrimEnd('\0')
                            //            , Encoding.Unicode.GetString(bcode2)
                            //);
                            // コード1を文字列化
                            int nsize = bcode1.Length;
                            for( int intlop = 0; intlop < bcode1.Length; intlop++ )
                            {
                                if( bcode1[intlop] == 0x00 )
                                {
                                    nsize = intlop + 1;
                                    break;
                                }
                            }

                            String strbcodetype = Encoding.ASCII.GetString(bcode1, 0, 2).TrimEnd('\0');
                            strlog = String.Format("ServeCodeType:{0}"
                                        , strbcodetype
                            );

                            if (strbcodetype != null && strbcodetype.EndsWith("**"))
                            {
                                String strbcode1 = Encoding.ASCII.GetString(bcode1, 2, nsize).TrimEnd('\0');
                                strlog = String.Format("ServeCode1:{0}"
                                            , strbcode1
                                );

                                // ログ記録
                                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードあり:{0}", strlog));

                                // GUIへ通知
                                this.SendMessageToGUI("カードあり", dtnow, strlog);

                                //mod #9511 FNSiカードアプリが一方のブラウザとしかつながらない。 donghao start
                                //string strdata = String.Format("{0}\t{1}\t{2}", CARD_CLIENT, CARD_STAFF_INFO, strbcode1);
                                string strdata = String.Format("{0}\t{1}\t{2}\t{3}", CARD_CLIENT, CARD_STAFF_INFO, strbcode1, card_idm);
                                //mod #9511 FNSiカードアプリが一方のブラウザとしかつながらない。 donghao end

                                NKKWebAppSocket.GetInstance()?.SendMessage(strdata);
                            }
                            else
                            {
                                Byte[] bbuff = new Byte[NKKAccessCardInfo.DATA_VER_LENGTH];
                                bbuff = new Byte[NKKAccessCardInfo.DATA_VER_LENGTH];
                                Array.Copy(bcode2, 24, bbuff, 0, NKKAccessCardInfo.DATA_VER_LENGTH);
                                string data_ver;
                                if (Encoding.UTF8.GetString(bbuff).TrimEnd('\0') == string.Empty)
                                    data_ver = string.Empty;
                                else
                                {
                                    data_ver = BitConverter.ToUInt16(bbuff, 0).ToString();
                                    dataVer = ushort.Parse(data_ver);
                                }

                                // ログ記録
                                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードあり:{0}", strlog));

                                // GUIへ通知
                                this.SendMessageToGUI("カードあり", dtnow, strlog);
                            }
                        }
                    }
                }

#if DEBUG
                //
                Debug.WriteLine("{0}{1}", MethodBase.GetCurrentMethod().Name, strlog);
#endif
            }
            catch(Exception ex)
            {
                this.Error = ex;
            }
            //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
            return true;
            //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// エラー発生時イベント
        /// </summary>
        /// <param name="strErrorMessage1">エラーメッセージ1</param>
        /// <param name="strErrorMessage2">エラーメッセージ2</param>
        //----------------------------------------------------------------------------------------------------
        private void FelicaError(String strErrorMessage1, String strErrorMessage2 )
        {
            DateTime dtnow = DateTime.Now;
            String strlog = String.Format("{0},{1}", strErrorMessage1, strErrorMessage2);

            //
            this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.ERROR, strlog);
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 情報イベント
        /// </summary>
        /// <param name="strMessage1">メッセージ1</param>
        //----------------------------------------------------------------------------------------------------
        private void FelicaInfo(String strMessage1)
        {
            DateTime dtnow = DateTime.Now;

            //
            this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strMessage1);
        }
        //----------------------------------------------------------------------------------------------------

        /// <summary>
        /// スタッフ情報をカードに書き込む
        /// </summary>
        /// <param name="id">スタッフ番号</param>
        /// <param name="name">スタッフ名</param>
        /// <returns>成功・失敗</returns>
        public static Boolean WriteStaffCard(string id, string name = "")
        {
            Boolean bret = false;
            String strlog = String.Empty;

            AddDebugLogInfo("スタッフカード書き込む Start");

            try
            {
                // システムコード
                Byte[] syscode = new byte[2];
                syscode[0] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(0, 2), 16);
                syscode[1] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(2, 2), 16);
                // サービスコード①  例：0049→{ 0x49, 0x00 }
                Byte[] servicecode1 = new byte[2];
                servicecode1[0] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(2, 2), 16);
                servicecode1[1] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(0, 2), 16);

                // 書き込み用のデータ作成(64byte：4ブロック * 16byte)
                Byte[] writeData_ServiceCode1 = Enumerable.Repeat<Byte>(0x00, 64).ToArray();
                if (0 < id.Length)
                {
                    // 指定データを上書き(64byteまで)
                    Byte[] bbuff = ASCIIEncoding.ASCII.GetBytes(id);
                    if (bbuff.Length <= 64)
                    {
                        Array.Copy(bbuff, writeData_ServiceCode1, bbuff.Length);
                    }
                    else
                    {
                        // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
                        strlog = String.Format("カード書き込み失敗(64byteまで),data:{0},[{1} < 64]", id, bbuff.Length.ToString());
                        AddDebugLogInfo(strlog);
                        // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
                        return false;
                    }
                }

                // Add By HandsomeLin Begin
                // Write fullname to the seconds block, using 40 bytes.
                if (!string.IsNullOrWhiteSpace(name))
                {
                    var nameBytes = Encoding.Unicode.GetBytes(name);
                    if (nameBytes.Length <= 40)
                    {
                        Array.Copy(
                            sourceArray: nameBytes,
                            sourceIndex: 0,
                            destinationArray: writeData_ServiceCode1,
                            destinationIndex: 16,
                            length: nameBytes.Length
                        );
                    }
                    else
                    {
                        AddDebugLogInfo($"カード書き込み失敗(40byteまで),data:{id},[{nameBytes.Length.ToString()} < 64]");
                        return false;
                    }
                }
                // Add By HandsomeLin End

                // add #11386 H5体重測定時にカードが読めなくなる 高 start
                bool isTimeout = false;
                Mutex wMutex = null;
                // add #11386 H5体重測定時にカードが読めなくなる 高 end

                while (FelicaLibTdc.running)
                {
                    // mod #11386 H5体重測定時にカードが読めなくなる 高 start
                    // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 start
                    //lock (FelicaLibTdc.LockoObj)
                    //{
                    try
                    {
                        isTimeout = false;
                        wMutex = null;

                        try
                        {
                            wMutex = new Mutex(false, FelicaLibTdc.wMutexName);
                        }
                        catch (Exception ex)
                        {
                            strlog = String.Format("new Mutex エラー:{0},{1}", id, ex.Message);
                            AddDebugLogInfo(strlog);
                        }

                        if (wMutex != null)
                        {
                            if (FelicaLibTdc.Lock(ref isTimeout, wMutex))
                            {
                                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
                                lock (FelicaLibTdc.LockoObj)
                                {
                                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
                                    try
                                    {
                                        if (FelicaLibTdc.Open())
                                        {
                                            NKKLogging.LOGGING_CLASS type = NKKLogging.LOGGING_CLASS.INFO;

                                            // サービスコード①に書き込み
                                            bret = FelicaLibTdc.Write(writeData_ServiceCode1, syscode, servicecode1, 0, 4);
                                            if (bret == true)
                                            {
                                                // サービスコード①に書き込み成功

                                                // 
                                                // ログ記録
                                                strlog = String.Format("カード書き込み成功,data:{0}", id);
                                                AddDebugLogInfo(strlog);
                                            }
                                            else
                                            {
                                                // サービスコード①に書き込み失敗

                                                //String errMsg = FelicaLibTdc.FelicaError.ToString();
                                                //errMsg += "\n\n";
                                                //errMsg += FelicaLibTdc.RwError.ToString();

                                                // ログ記録
                                                strlog = String.Format("カード書き込み失敗,data:{0},{1}", id, FelicaLibTdc.RwError.ToString());

                                                type = NKKLogging.LOGGING_CLASS.ERROR;

                                                // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
                                                AddDebugLogInfo(strlog);
                                                // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
                                            }
                                        }
                                        else
                                        {
                                            strlog = String.Format("カード書き込み失敗,data:{0}", id);
                                            AddDebugLogInfo(strlog);
                                            bret = false;
                                        }

                                        return bret;
                                    }
                                    finally
                                    {
                                        // フェリカカードクローズ
                                        FelicaLibTdc.Close();
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        strlog = String.Format("WriteStaffCard() エラー:{0},{1}", id, ex.Message);
                        AddDebugLogInfo(strlog);
                    }
                    finally
                    {
                        if (wMutex != null)
                        {
                            FelicaLibTdc.Unlock(wMutex);
                            try
                            {
                                wMutex.Close();
                                wMutex = null;
                            }
                            catch (Exception ex)
                            {
                                strlog = String.Format("wMutex Close エラー:{0},{1}", id, ex.Message);
                                AddDebugLogInfo(strlog);
                            }
                        }
                    }
                    //}
                    // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 end
                    // mod #11386 H5体重測定時にカードが読めなくなる 高 end
                    Thread.Sleep(100);
                }

            }
            //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
            catch (Exception e)
            {
                // this.Error = e;
                // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
                AddDebugLogInfo(e.Message);
                // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
            }
            finally
            {
                AddDebugLogInfo("スタッフカード書き込む End");
            }

            return bret;
        }

        /// <summary>
        /// 患者情報をカードに書き込む
        /// </summary>
        /// <param name="data">患者情報</param>
        /// <param name="lstErrorMessage">エラーメッセージ</param>
        /// <returns>成功・失敗</returns>
        public static Boolean WritePatCard(Byte[][] data, out List<string> lstErrorMessage)
        {
            Boolean bret = false;
            lstErrorMessage = new List<string>();

            AddDebugLogInfo("患者カード書き込む Start");

            // add #11386 H5体重測定時にカードが読めなくなる 高 start
            bool isTimeout = false;
            Mutex wMutex = null;
            string strlog;
            // add #11386 H5体重測定時にカードが読めなくなる 高 end

            try
            {
                while (FelicaLibTdc.running)
                {
                    // mod #11386 H5体重測定時にカードが読めなくなる 高 start
                    // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 start
                    //lock (FelicaLibTdc.LockoObj)
                    //{
                    try
                    {
                        isTimeout = false;
                    wMutex = null;

                    try
                    {
                        wMutex = new Mutex(false, FelicaLibTdc.wMutexName);
                    }
                    catch (Exception ex)
                    {
                        strlog = String.Format("new Mutex エラー:{0}", ex.Message);
                        lstErrorMessage.Add(strlog);
                    }

                        if (wMutex != null)
                        {
                            if (FelicaLibTdc.Lock(ref isTimeout, wMutex))
                            {
                                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
                                lock (FelicaLibTdc.LockoObj)
                                {
                                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
                                    try
                                    {
                                        if (FelicaLibTdc.Open())
                                        {
                                            FelicaLibTdc.SetLockTimeout(0);

                                            // サービスコード①に書き込み
                                            bret = WritePatCard(data[0], 0, 4, 1);
                                            if (bret == false)
                                            {
                                                lstErrorMessage.Add("--->WriteCard NG：Service1");
                                            }
                                            bret = WritePatCard(data[1], 0, 144, 2);
                                            if (bret == false)
                                            {
                                                lstErrorMessage.Add("--->WriteCard NG：Service2");
                                            }
                                        }
                                        else
                                        {
                                            lstErrorMessage.Add("--->WriteCard NG");
                                            bret = false;
                                        }
                                        return bret;
                                    }
                                    finally
                                    {
                                        FelicaLibTdc.Close();
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        strlog = String.Format("WritePatCard() エラー:{0}",  ex.Message);
                        lstErrorMessage.Add(strlog);
                    }
                    finally
                    {
                        if (wMutex != null)
                        {
                            FelicaLibTdc.Unlock(wMutex);
                            try
                            {
                                wMutex.Close();
                                wMutex = null;
                            }
                            catch (Exception ex)
                            {
                                strlog = String.Format("wMutex Close エラー:{0}", ex.Message);
                                lstErrorMessage.Add(strlog);
                            }
                        }
                    }
                    // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 end
                    // mod #11386 H5体重測定時にカードが読めなくなる 高 end
                    Thread.Sleep(100);
                }
            }
            catch (Exception e)
            {
                AddDebugLogInfo(e.Message);
            }
            finally
            {
                AddDebugLogInfo("患者カード書き込む End");
            }
            return bret;
        }

        private static Boolean WritePatCard(Byte[] data, ushort startBlock, int numberOfBlocks, int serviceCode)
        {
            Boolean bret = false;
            String strlog = String.Empty;

            // システムコード
            Byte[] syscode = new byte[2];
            syscode[0] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(0, 2), 16);
            syscode[1] = Convert.ToByte(FelicaLibTdc.IcSystemCode.Substring(2, 2), 16);
            Byte[] servicecode = new byte[2];
            if (serviceCode == 1)
            {
                // サービスコード①  例：0049→{ 0x49, 0x00 }
                servicecode[0] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(2, 2), 16);
                servicecode[1] = Convert.ToByte(FelicaLibTdc.IcServiceCode1.Substring(0, 2), 16);
            }
            else if (serviceCode == 2)
            {
                // サービスコード②  例：0089→{ 0x89, 0x00 }
                servicecode[0] = Convert.ToByte(FelicaLibTdc.IcServiceCode2.Substring(2, 2), 16);
                servicecode[1] = Convert.ToByte(FelicaLibTdc.IcServiceCode2.Substring(0, 2), 16);
            }


            // 書き込み用のデータ作成(N byte：numberOfBlocksブロック * 16byte)
            Byte[] writeData_ServiceCode1 = Enumerable.Repeat<Byte>(0x00, 16 * numberOfBlocks).ToArray();
            if (0 < data.Length)
            {
                // 指定データを上書き(16* numberOfBlocks byteまで)
                // Byte[] bbuff = ASCIIEncoding.ASCII.GetBytes(data);
                Byte[] bbuff = data;
                if (bbuff.Length <= 16 * numberOfBlocks)
                {
                    Array.Copy(bbuff, writeData_ServiceCode1, bbuff.Length);
                }
                else
                {
                    // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
                    strlog = String.Format("カード書き込み失敗(16* numberOfBlocks byteまで),data:{0},[{1} <= 16 * {2}]", data, bbuff.Length.ToString(), numberOfBlocks.ToString());
                    AddDebugLogInfo(String.Format("{0}:[{1}]", strlog, Encoding.UTF8.GetString(data)));
                    // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
                    return false;
                }
            }

            FelicaLibTdc.SetLockTimeout(0);

            // サービスコード①に書き込み
            bret = FelicaLibTdc.Write(writeData_ServiceCode1, syscode, servicecode, startBlock, numberOfBlocks);
            if (bret == true)
            {
                // サービスコード①に書き込み成功
                // ログ記録
                strlog = String.Format("カード書き込み成功,data:{0}", data);
                AddDebugLogInfo(String.Format("{0}:[{1}]", strlog, Encoding.UTF8.GetString(data)));
            }
            else
            {
                // サービスコード①に書き込み失敗

                // ログ記録
                strlog = String.Format("カード書き込み失敗,data:{0},{1}", data, FelicaLibTdc.RwError.ToString());

                // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
                AddDebugLogInfo(String.Format("{0}:[{1}]", strlog, Encoding.UTF8.GetString(data)));
                // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
            }

            return bret;
        }

        // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 start
        private static void AddDebugLogInfo(String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(DateTime.Now, "Felica", NKKLogging.LOGGING_CLASS.DEBUG, strMesssage);
        }
        // add 2021-08-12 #5835:患者カードの作成ができないの対応 孫 end
        #endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
