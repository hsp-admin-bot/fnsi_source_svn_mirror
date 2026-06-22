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
//----------------------------------------------------------------------------------------------------
using NKKWeightScaleDB.Services;
using NKKWeightScaleDB.Models;
using System.Threading.Tasks;
using System.Collections.Generic;


//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightLib
//----------------------------------------------------------------------------------------------------
namespace NKKWeightLib
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
        private readonly String PUT_CARD_VALUE_URI = "/api/weight_state/card";
        //----------------------------------------------------------------------------------------------------

        // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
        /// <summary>
        /// カードIDM取得URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String GET_CARD_IDM_URI = "/api/weight/card_idm/";
        //----------------------------------------------------------------------------------------------------
        // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end

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
        // #12738 add 2026.06.08 Ferica処理で処理中状態を返すプロパティを追加 TDC米沢 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Fericaスレッドの動作状態参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public bool IsRunning
        {
            get { return FelicaLibTdc.IsRunning; }
        }
        //----------------------------------------------------------------------------------------------------
        // #12738 add 2026.06.08 Ferica処理で処理中状態を返すプロパティを追加 TDC米沢 end

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
            // カード接続情報変更イベントハンドラ
            FelicaLibTdc.FelicaConnectChangeEvent += this.FalicaConnectCahanged;
            // カード読込情報変更イベントハンドラ
            FelicaLibTdc.FelicaChangeEvent += this.FelicaChanged;
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
            // #12738 mod 2026.06.11 状態表示を適正化 TDC米沢 start
            //this.SendMessageToGUI("切断中", dtnow, strlog);
            this.SendMessageToGUI("未使用", dtnow, strlog);
            // #12738 mod 2026.06.11 状態表示を適正化 TDC米沢 end
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
        private void FalicaConnectCahanged( Boolean? bStatus )
        {
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
        private bool FelicaChanged( String strIdm, Byte[] bIdm  )
        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
        {
            DateTime dtnow = DateTime.Now;
            String strlog = String.Empty;

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
                        Byte[] bcode2 = FelicaLibTdc.Read(syscode, servicecode2, 87);
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
                            strlog = String.Format("Idm:{0}, ServeCode1 Data:{1}"
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
                            String strbcode1 = Encoding.ASCII.GetString(bcode1, 0, nsize).TrimEnd('\0').Trim();
                            strlog = String.Format("ServeCode1 Data:{0}"
                                        , strbcode1
                            );

                            // ログ記録
                            this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードあり:{0}", strlog));

                            // GUIへ通知
                            this.SendMessageToGUI("カードあり", dtnow, strlog);

                            // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
                            // del 2021-02-25 FNSI-仕様変更 Idmのチェック処理削除 夏 start
                            //String strIdmUri = String.Empty;
                            //String strstate = String.Empty;
                            //string patientID = String.Empty;
                            // del 2021-02-25 FNSI-仕様変更 Idmのチェック処理削除 夏 end
                            // カードチェック結果 0:チェックOK 1:チェックNG
                            int nret = 0;

                            // del 2021-02-25 FNSI-仕様変更 Idmのチェック処理削除 夏 start
                            //String strbcode1type = Encoding.UTF8.GetString(bcode1, 0, 2).TrimEnd('\0');
                            //if (strbcode1type != null && !strbcode1type.EndsWith("**"))
                            //{
                            //    nret = 1;
                            //    patientID = ConvertByteToString(bcode1, new Byte[NKKFelicaInformation.ID_LENGTH], 0, NKKFelicaInformation.ID_LENGTH, 1);

                            //    // カードIDM取得取得
                            //    strIdmUri = String.Format("{0}{1}{2}{3}/{4}?_={5}"
                            //        , NKKWebAccess.BaseUri
                            //        , NKKWeightInformation.WEB_APP_URI
                            //        , this.GET_CARD_IDM_URI
                            //        , NKKWebAccess.FacilityCd
                            //        , patientID
                            //        , DateTime.Now.Ticks);
                            //    NKKWebAccessResponse idmRes = NKKWebAccess.Get("DBにカードIDM取得", strIdmUri).Result;
                            //    if (idmRes.response.IsSuccessStatusCode == true)
                            //    {
                            //        strstate = idmRes.strContent;
                            //    }
                            //    if (String.IsNullOrEmpty(strstate) == false)
                            //    {
                            //        // 処理成功

                            //        // ログ記録：状態値
                            //        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードIDM取得, 情報:{0}", strstate));

                            //        // JSON分解
                            //        Dictionary<String, String> json = NKKWebAccess.GetJsonData(strstate);

                            //        // カードIDM内容
                            //        if (json.ContainsKey("cardIdmValue") == true)
                            //        {
                            //            String cardidm = json["cardIdmValue"];

                            //            // カード有効無効なチェック
                            //            if (String.IsNullOrEmpty(cardidm) == false && cardidm.Equals(TdcLib.TdcLib.GetByteToHexString(bIdm)))
                            //            {
                            //                // チェックOK
                            //                nret = 0;

                            //                // ログ記録
                            //                strlog = "カード有効";
                            //                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                            //                // GUIへ通知
                            //                this.SendMessageToGUI("カード有効", dtnow, strlog);
                            //            }
                            //        }
                            //    }
                            //    if (nret == 1)
                            //    {
                            //        // エラーメッセージ
                            //        strlog = "カード無効";
                            //        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                            //        // GUIへ通知
                            //        this.SendMessageToGUI("カード無効", dtnow, strlog);
                            //    }
                            //}
                            // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
                            // del 2021-02-25 FNSI-仕様変更 Idmのチェック処理削除 夏 end

                            // #11165 2024.10.23 del カードの通知をスタッフカード以外とする TDC米沢 start
                            //// カード情報を通知
                            ////*@param request { scaleCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, cardReadValue: カード読み取り情報, cardCheckValue: カードチェック結果}
                            //Task.Run(() => {
                            //String strUri = String.Format("{0}{1}{2}?_={3}"
                            //    , NKKWebAccess.BaseUri
                            //    , NKKWeightInformation.WEB_APP_URI
                            //    , this.PUT_CARD_VALUE_URI
                            //    , DateTime.Now.Ticks );
                            //String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}, \"cardReadValue\":{3}}}"
                            //    , NKKWeightInformation.WeightCd
                            //    , NKKWebAccess.FacilityCd
                            //    , NKKWeightInformation.WeightNo
                            //    // UPD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
                            //    //, String.Format("{{\"idm\":\"{0}\", \"id\":\"{1}\"}}"
                            //    , String.Format("{{\"idm\":\"{0}\", \"id\":\"{1}\", \"cardCheckValue\":\"{2}\"}}"
                            //    // UPD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
                            //        , TdcLib.TdcLib.GetByteToHexString(NKKWeightInformation.Encoding.GetBytes(strIdm))
                            //        , strbcode1
                            //        // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
                            //        , nret
                            //        // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
                            //        )
                            //    );
                            //NKKWebAccessResponse res = NKKWebAccess.Put("カード情報通知", strUri, strbody).Result;
                            //if (res.response.IsSuccessStatusCode == true )
                            //{
                            //    // 処理成功

                            //    // ログ記録
                            //    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("カード情報通知完了,{0}", strbody));
                            //}
                            //});
                            // #11165 2024.10.23 del カードの通知をスタッフカード以外とする TDC米沢 end

                            // ADD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start                            
                            if (nret == 0)
                            {
                            // ADD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
                                String strbcodetype = Encoding.UTF8.GetString(bcode1, 0, 2).TrimEnd('\0');
                                strlog = String.Format("ServeCodeType:{0}", strbcodetype
                                );

                                // #11165 2024.10.23 add カード形式を表示/記録 TDC米沢 start
                                // ログ記録
                                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードあり:{0}", strlog));
                                // GUIへ通知
                                this.SendMessageToGUI("カードあり", dtnow, strlog);
                                // #11165 2024.10.23 add カード形式を表示/記録 TDC米沢 end

                                if (strbcodetype != null && !strbcodetype.EndsWith("**"))
                                {
                                    // スタッフカード以外

                                    // #11165 2024.10.23 add カードの通知をスタッフカード以外とする TDC米沢 start
                                    // カード情報を通知
                                    //*@param request { scaleCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, cardReadValue: カード読み取り情報, cardCheckValue: カードチェック結果}
                                    Task.Run(() => {
                                        String strUri = String.Format("{0}{1}{2}?_={3}"
                                            , NKKWebAccess.BaseUri
                                            , NKKWeightInformation.WEB_APP_URI
                                            , this.PUT_CARD_VALUE_URI
                                            , DateTime.Now.Ticks);
                                        String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}, \"cardReadValue\":{3}}}"
                                            , NKKWeightInformation.WeightCd
                                            , NKKWebAccess.FacilityCd
                                            , NKKWeightInformation.WeightNo
                                            // UPD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
                                            //, String.Format("{{\"idm\":\"{0}\", \"id\":\"{1}\"}}"
                                            , String.Format("{{\"idm\":\"{0}\", \"id\":\"{1}\", \"cardCheckValue\":\"{2}\"}}"
                                                // UPD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
                                                , TdcLib.TdcLib.GetByteToHexString(NKKWeightInformation.Encoding.GetBytes(strIdm))
                                                , strbcode1
                                                // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
                                                , nret
                                                // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
                                                )
                                            );
                                        NKKWebAccessResponse res = NKKWebAccess.Put("カード情報通知", strUri, strbody).Result;
                                        if (res.response.IsSuccessStatusCode == true)
                                        {
                                            // 処理成功

                                            // ログ記録
                                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("カード情報通知完了,{0}", strbody));
                                        }
                                    });
                                    // #11165 2024.10.23 add カードの通知をスタッフカード以外とする TDC米沢 end

                                    string id = ConvertByteToString(bcode1, new Byte[NKKFelicaInformation.ID_LENGTH], 0, NKKFelicaInformation.ID_LENGTH, 1);
                                    // mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン start
                                    //string fullname = ConvertByteToString(bcode1, new Byte[NKKFelicaInformation.FULL_NAME_LENGTH], 16, NKKFelicaInformation.FULL_NAME_LENGTH, 1);
                                    string fullname = ConvertByteToString(bcode1, new Byte[NKKFelicaInformation.FULL_NAME_LENGTH], 16, NKKFelicaInformation.FULL_NAME_LENGTH, 4);
                                    // mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン end
                                    string year = ConvertByteToString(bcode1, new Byte[NKKFelicaInformation.YEAR_LENGTH], 56, NKKFelicaInformation.YEAR_LENGTH, 2);
                                    string day_month = ConvertByteToString(bcode1, new Byte[NKKFelicaInformation.DAY_MONTH], 58, NKKFelicaInformation.DAY_MONTH, 2);
                                    string day = string.Empty;
                                    string month = string.Empty;
                                    if (!String.IsNullOrEmpty(day_month))
                                    {
                                        day = day_month.Substring(day_month.Length - 2, 2);
                                        month = day_month.Substring(0, (day_month.Length - day.Length));
                                    }
                                    string weight_checksum = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WEIGHT_CHECKSUM_LENGTH], 0, NKKFelicaInformation.WEIGHT_CHECKSUM_LENGTH, 3);
                                    string weight_before = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WEIGHT_BEFORE_LENGTH], 8, NKKFelicaInformation.WEIGHT_BEFORE_LENGTH, 2);
                                    string weight_mea = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WEIGHT_MEA_LENGTH], 10, NKKFelicaInformation.WEIGHT_MEA_LENGTH, 2);
                                    string weight_body_flag = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WEIGHT_BODY_FLAG_LENGTH], 12, NKKFelicaInformation.WEIGHT_BODY_FLAG_LENGTH, 2);
                                    string setting_checksum = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.SETTING_CHECKSUM_LENGTH], 16, NKKFelicaInformation.SETTING_CHECKSUM_LENGTH, 3);
                                    string data_ver = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.DATA_VER_LENGTH], 24, NKKFelicaInformation.DATA_VER_LENGTH, 2);
                                    string treat_mode = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_MODE_LENGTH], 26, NKKFelicaInformation.TREAT_MODE_LENGTH, 2);
                                    string dialysis_time = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.DIALYSIS_TIME_LENGTH], 28, NKKFelicaInformation.DIALYSIS_TIME_LENGTH, 2);
                                    string target_weight = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TARGET_WEIGHT_LENGTH], 30, NKKFelicaInformation.TARGET_WEIGHT_LENGTH, 2);
                                    // mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン start
                                    // string water_info_name_1 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_1_LENGTH], 32, NKKFelicaInformation.WATER_INFO_NAME_1_LENGTH, 1);
                                    // string water_info_name_2 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_2_LENGTH], 48, NKKFelicaInformation.WATER_INFO_NAME_2_LENGTH, 1);
                                    // string water_info_name_3 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_3_LENGTH], 64, NKKFelicaInformation.WATER_INFO_NAME_3_LENGTH, 1);
                                    // string water_info_name_4 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_4_LENGTH], 80, NKKFelicaInformation.WATER_INFO_NAME_4_LENGTH, 1);
                                    // string water_info_name_5 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_5_LENGTH], 96, NKKFelicaInformation.WATER_INFO_NAME_5_LENGTH, 1);
                                    string water_info_name_1 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_1_LENGTH], 32, NKKFelicaInformation.WATER_INFO_NAME_1_LENGTH, 4);
                                    string water_info_name_2 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_2_LENGTH], 48, NKKFelicaInformation.WATER_INFO_NAME_2_LENGTH, 4);
                                    string water_info_name_3 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_3_LENGTH], 64, NKKFelicaInformation.WATER_INFO_NAME_3_LENGTH, 4);
                                    string water_info_name_4 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_4_LENGTH], 80, NKKFelicaInformation.WATER_INFO_NAME_4_LENGTH, 4);
                                    string water_info_name_5 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_NAME_5_LENGTH], 96, NKKFelicaInformation.WATER_INFO_NAME_5_LENGTH, 4);
                                    // mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン end
                                    string water_info_weight_1 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_WEIGHT_1_LENGTH], 112, NKKFelicaInformation.WATER_INFO_WEIGHT_1_LENGTH, 2);
                                    string water_info_weight_2 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_WEIGHT_2_LENGTH], 114, NKKFelicaInformation.WATER_INFO_WEIGHT_2_LENGTH, 2);
                                    string water_info_weight_3 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_WEIGHT_3_LENGTH], 116, NKKFelicaInformation.WATER_INFO_WEIGHT_3_LENGTH, 2);
                                    string water_info_weight_4 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_WEIGHT_4_LENGTH], 118, NKKFelicaInformation.WATER_INFO_WEIGHT_4_LENGTH, 2);
                                    string water_info_weight_5 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.WATER_INFO_WEIGHT_5_LENGTH], 120, NKKFelicaInformation.WATER_INFO_WEIGHT_5_LENGTH, 2);
                                    // mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン start
                                    // string ind_tare_info_name_1 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_1_LENGTH], 128, NKKFelicaInformation.IND_TARE_INFO_NAME_1_LENGTH, 1);
                                    // string ind_tare_info_name_2 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_2_LENGTH], 144, NKKFelicaInformation.IND_TARE_INFO_NAME_2_LENGTH, 1);
                                    // string ind_tare_info_name_3 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_3_LENGTH], 160, NKKFelicaInformation.IND_TARE_INFO_NAME_3_LENGTH, 1);
                                    // string ind_tare_info_name_4 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_4_LENGTH], 176, NKKFelicaInformation.IND_TARE_INFO_NAME_4_LENGTH, 1);
                                    // string ind_tare_info_name_5 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_5_LENGTH], 192, NKKFelicaInformation.IND_TARE_INFO_NAME_5_LENGTH, 1);
                                    string ind_tare_info_name_1 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_1_LENGTH], 128, NKKFelicaInformation.IND_TARE_INFO_NAME_1_LENGTH, 4);
                                    string ind_tare_info_name_2 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_2_LENGTH], 144, NKKFelicaInformation.IND_TARE_INFO_NAME_2_LENGTH, 4);
                                    string ind_tare_info_name_3 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_3_LENGTH], 160, NKKFelicaInformation.IND_TARE_INFO_NAME_3_LENGTH, 4);
                                    string ind_tare_info_name_4 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_4_LENGTH], 176, NKKFelicaInformation.IND_TARE_INFO_NAME_4_LENGTH, 4);
                                    string ind_tare_info_name_5 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_NAME_5_LENGTH], 192, NKKFelicaInformation.IND_TARE_INFO_NAME_5_LENGTH, 4);
                                    // mod redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン end
                                    string ind_tare_info_weight_1 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_WEIGHT_1_LENGTH], 208, NKKFelicaInformation.IND_TARE_INFO_WEIGHT_1_LENGTH, 2);
                                    string ind_tare_info_weight_2 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_WEIGHT_2_LENGTH], 210, NKKFelicaInformation.IND_TARE_INFO_WEIGHT_2_LENGTH, 2);
                                    string ind_tare_info_weight_3 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_WEIGHT_3_LENGTH], 212, NKKFelicaInformation.IND_TARE_INFO_WEIGHT_3_LENGTH, 2);
                                    string ind_tare_info_weight_4 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_WEIGHT_4_LENGTH], 214, NKKFelicaInformation.IND_TARE_INFO_WEIGHT_4_LENGTH, 2);
                                    string ind_tare_info_weight_5 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TARE_INFO_WEIGHT_5_LENGTH], 216, NKKFelicaInformation.IND_TARE_INFO_WEIGHT_5_LENGTH, 2);
                                    string ind_cond_info_20 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_20_LENGTH], 224, NKKFelicaInformation.IND_COND_INFO_20_LENGTH, 2);
                                    string ind_cond_info_24 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_24_LENGTH], 224, NKKFelicaInformation.IND_COND_INFO_24_LENGTH, 2);
                                    string ind_cond_info_21 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_21_LENGTH], 228, NKKFelicaInformation.IND_COND_INFO_21_LENGTH, 2);
                                    string ind_cond_info_23 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_23_LENGTH], 230, NKKFelicaInformation.IND_COND_INFO_23_LENGTH, 2);
                                    string ind_cond_info_14 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_14_LENGTH], 232, NKKFelicaInformation.IND_COND_INFO_14_LENGTH, 2);
                                    string ind_cond_info_31 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_31_LENGTH], 234, NKKFelicaInformation.IND_COND_INFO_31_LENGTH, 2);
                                    string ind_cond_info_32 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_32_LENGTH], 236, NKKFelicaInformation.IND_COND_INFO_32_LENGTH, 2);
                                    string ind_cond_info_36 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_36_LENGTH], 238, NKKFelicaInformation.IND_COND_INFO_36_LENGTH, 2);
                                    string ind_cond_info_18 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_18_LENGTH], 240, NKKFelicaInformation.IND_COND_INFO_18_LENGTH, 2);
                                    string ind_cond_info_16 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_16_LENGTH], 242, NKKFelicaInformation.IND_COND_INFO_16_LENGTH, 2);
                                    string ind_device_set_info_203 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_DEVICE_SET_INFO_203_LENGTH], 244, NKKFelicaInformation.IND_DEVICE_SET_INFO_203_LENGTH, 2);
                                    string ind_device_set_info_200 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_DEVICE_SET_INFO_200_LENGTH], 246, NKKFelicaInformation.IND_DEVICE_SET_INFO_200_LENGTH, 2);
                                    string ind_device_set_info_202 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_DEVICE_SET_INFO_202_LENGTH], 248, NKKFelicaInformation.IND_DEVICE_SET_INFO_202_LENGTH, 2);
                                    string ind_device_set_info_201 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_DEVICE_SET_INFO_201_LENGTH], 250, NKKFelicaInformation.IND_DEVICE_SET_INFO_201_LENGTH, 2);
                                    string treat_condition_181 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_181_LENGTH], 252, NKKFelicaInformation.TREAT_CONDITION_181_LENGTH, 2);
                                    string treat_condition_179 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_179_LENGTH], 254, NKKFelicaInformation.TREAT_CONDITION_179_LENGTH, 2);
                                    string treat_condition_211 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_211_LENGTH], 256, NKKFelicaInformation.TREAT_CONDITION_211_LENGTH, 2);
                                    string treat_condition_212 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_212_LENGTH], 258, NKKFelicaInformation.TREAT_CONDITION_212_LENGTH, 2);
                                    string treat_condition_213 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_213_LENGTH], 260, NKKFelicaInformation.TREAT_CONDITION_213_LENGTH, 2);
                                    string treat_condition_214 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_214_LENGTH], 262, NKKFelicaInformation.TREAT_CONDITION_214_LENGTH, 2);
                                    string treat_condition_217 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_217_LENGTH], 264, NKKFelicaInformation.TREAT_CONDITION_217_LENGTH, 2);
                                    string treat_condition_218 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_218_LENGTH], 266, NKKFelicaInformation.TREAT_CONDITION_218_LENGTH, 2);
                                    string treat_condition_190 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.TREAT_CONDITION_190_LENGTH], 268, NKKFelicaInformation.TREAT_CONDITION_190_LENGTH, 2);
                                    string ind_cond_info_3 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_3_LENGTH], 272, NKKFelicaInformation.IND_COND_INFO_3_LENGTH, 2);
                                    string ind_cond_info_4 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_4_LENGTH], 274, NKKFelicaInformation.IND_COND_INFO_4_LENGTH, 2);
                                    string ind_kur_cd = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_KUR_CD_LENGTH], 276, NKKFelicaInformation.IND_KUR_CD_LENGTH, 3);
                                    string ind_treat_start_time = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_TREAT_START_TIME_LENGTH], 284, NKKFelicaInformation.IND_TREAT_START_TIME_LENGTH, 2);
                                    string ind_bed_cd = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_BED_CD_LENGTH], 288, NKKFelicaInformation.IND_BED_CD_LENGTH, 3);
                                    string ind_cond_info_2 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_2_LENGTH], 296, NKKFelicaInformation.IND_COND_INFO_2_LENGTH, 2);
                                    string ind_cond_info_5 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_5_LENGTH], 298, NKKFelicaInformation.IND_COND_INFO_5_LENGTH, 2);
                                    string ind_cond_info_6 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_6_LENGTH], 300, NKKFelicaInformation.IND_COND_INFO_6_LENGTH, 2);
                                    string ind_cond_info_7 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_7_LENGTH], 302, NKKFelicaInformation.IND_COND_INFO_7_LENGTH, 2);
                                    string ind_cond_info_8 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_8_LENGTH], 304, NKKFelicaInformation.IND_COND_INFO_8_LENGTH, 2);
                                    string ind_cond_info_9 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_9_LENGTH], 306, NKKFelicaInformation.IND_COND_INFO_9_LENGTH, 2);
                                    string ind_cond_info_10 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_10_LENGTH], 308, NKKFelicaInformation.IND_COND_INFO_10_LENGTH, 2);
                                    string ind_cond_info_11 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_11_LENGTH], 310, NKKFelicaInformation.IND_COND_INFO_11_LENGTH, 2);
                                    string ind_cond_info_12 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_12_LENGTH], 312, NKKFelicaInformation.IND_COND_INFO_12_LENGTH, 2);
                                    string ind_cond_info_13 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_13_LENGTH], 314, NKKFelicaInformation.IND_COND_INFO_13_LENGTH, 2);
                                    string ind_cond_info_15 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_15_LENGTH], 316, NKKFelicaInformation.IND_COND_INFO_15_LENGTH, 2);
                                    string ind_cond_info_17 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_16_LENGTH], 318, NKKFelicaInformation.IND_COND_INFO_16_LENGTH, 2);
                                    string ind_cond_info_19 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_19_LENGTH], 1360, NKKFelicaInformation.IND_COND_INFO_19_LENGTH, 2);
                                    string ind_cond_info_22 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_22_LENGTH], 1362, NKKFelicaInformation.IND_COND_INFO_22_LENGTH, 2);
                                    string ind_cond_info_25 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_25_LENGTH], 1364, NKKFelicaInformation.IND_COND_INFO_25_LENGTH, 2);
                                    string ind_cond_info_26 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_26_LENGTH], 1366, NKKFelicaInformation.IND_COND_INFO_26_LENGTH, 2);
                                    string ind_cond_info_27 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_27_LENGTH], 1368, NKKFelicaInformation.IND_COND_INFO_27_LENGTH, 2);
                                    string ind_cond_info_28 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_28_LENGTH], 1370, NKKFelicaInformation.IND_COND_INFO_28_LENGTH, 2);
                                    string ind_cond_info_29 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_29_LENGTH], 1372, NKKFelicaInformation.IND_COND_INFO_29_LENGTH, 2);
                                    string ind_cond_info_30 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_30_LENGTH], 1374, NKKFelicaInformation.IND_COND_INFO_30_LENGTH, 2);
                                    string ind_cond_info_33 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_33_LENGTH], 1376, NKKFelicaInformation.IND_COND_INFO_33_LENGTH, 2);
                                    string ind_cond_info_34 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_34_LENGTH], 1378, NKKFelicaInformation.IND_COND_INFO_34_LENGTH, 2);
                                    string ind_cond_info_37 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_37_LENGTH], 1380, NKKFelicaInformation.IND_COND_INFO_37_LENGTH, 2);
                                    string ind_cond_info_38 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_38_LENGTH], 1382, NKKFelicaInformation.IND_COND_INFO_38_LENGTH, 2);
                                    string ind_cond_info_35 = ConvertByteToString(bcode2, new Byte[NKKFelicaInformation.IND_COND_INFO_35_LENGTH], 1384, NKKFelicaInformation.IND_COND_INFO_35_LENGTH, 2);

                                    Patient patient = new Patient();
                                    patient.PatientID = id;
                                    patient.PatientName = fullname;

                                    Treatment_condition treatment_condition = new Treatment_condition();
                                    treatment_condition.patient_id = id;
                                    treatment_condition.method_of_treatment = treat_mode;
                                    treatment_condition.cool = ind_kur_cd;
                                    treatment_condition.dialysis_start_time = ind_treat_start_time;
                                    treatment_condition.treatment_time = dialysis_time;
                                    treatment_condition.va = ind_cond_info_2;
                                    treatment_condition.dialyzer = ind_cond_info_5;
                                    treatment_condition.adsorption_column = ind_cond_info_6;
                                    treatment_condition.primary_membrane = ind_cond_info_7;
                                    treatment_condition.secondary_membrane = ind_cond_info_8;
                                    treatment_condition.puncture_needle_a = ind_cond_info_9;
                                    treatment_condition.puncture_needle_v = ind_cond_info_10;
                                    treatment_condition.puncture_needle_sn = ind_cond_info_11;
                                    treatment_condition.use_single_needle = ind_cond_info_12;
                                    treatment_condition.blood_circuit = ind_cond_info_13;
                                    treatment_condition.volume_of_blood_flow = ind_cond_info_14;
                                    treatment_condition.dialysate = ind_cond_info_15;
                                    treatment_condition.dialysate_flow_rate = ind_cond_info_16;
                                    treatment_condition.fluid_replacement = ind_cond_info_19;
                                    treatment_condition.dialysate_volume = ind_cond_info_17;
                                    treatment_condition.dialysate_temperature = ind_cond_info_18;
                                    treatment_condition.replacement_fluidAmount = ind_cond_info_20;
                                    treatment_condition.replacement_fluid_selection = ind_cond_info_21;
                                    treatment_condition.number_of_replacement_fluids = ind_cond_info_22;
                                    treatment_condition.fluid_replacement_temperature = ind_cond_info_23;
                                    treatment_condition.fluid_replacement_speed = ind_cond_info_24;
                                    treatment_condition.anticoagulant_drug = ind_cond_info_25;
                                    treatment_condition.anticoagulant_one_shot_amount_drug = ind_cond_info_26;
                                    treatment_condition.anticoagulant_sustained_rate = ind_cond_info_27;
                                    treatment_condition.total_amount_of_anticoagulant_sustained = ind_cond_info_28;
                                    treatment_condition.select_ip = ind_cond_info_29;
                                    treatment_condition.ip_start = ind_cond_info_30;
                                    treatment_condition.ip_one_shot_amount = ind_cond_info_31;
                                    treatment_condition.ip_speed = ind_cond_info_32;
                                    treatment_condition.ip_speed_maximum_value = ind_cond_info_33;
                                    treatment_condition.automatic_one_shot = ind_cond_info_34;
                                    treatment_condition.ip_power_off_automatically = ind_cond_info_35;
                                    treatment_condition.ip_power_off_automatically_time = ind_cond_info_36;
                                    treatment_condition.turn_off_the_ip_power_supply_ok_monitor = ind_cond_info_37;
                                    treatment_condition.ip_power_ok_monitor_turn_off_time = ind_cond_info_38;

                                    bool result = false;
                                    //患者情報を保存
                                    PatientService patientService = new PatientService();
                                    result = patientService.AddOrUpdate(patient) != null;
                                    this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("result:{0}", result));

                                    //透析条件を保存
                                    TreatmentConditionService treatmentConditionService = new TreatmentConditionService();
                                    result = treatmentConditionService.AddOrUpdate(treatment_condition) != null;
                                    this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("result:{0}", result));

                                    // ログ記録
                                    strlog = String.Format("{0}\tid:{1}\tname:{2}", strlog, id, fullname);
                                    this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("カードあり:{0}", strlog));

                                    // GUIへ通知
                                    this.SendMessageToGUI("カードあり", dtnow, strlog);
                                }
                            // UPD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
                            }
                            // UPD 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
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
        /// バイトから文字列へ変換。
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private string ConvertByteToString(Byte[] bcode, Byte[] bbuff, int index, int lengthByte, int type)
        {
            try
            {
                Array.Copy(bcode, index, bbuff, 0, lengthByte);
                string value = string.Empty;
                if (Encoding.UTF8.GetString(bbuff).TrimEnd('\0') == string.Empty)
                    value = string.Empty;
                else if (type == 1)
                    value = Encoding.UTF8.GetString(bbuff).TrimEnd('\0');
                else if (type == 2)
                    value = BitConverter.ToUInt16(bbuff, 0).ToString();
                else if (type == 3)
                    value = BitConverter.ToUInt64(bbuff, 0).ToString();
                // add redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン start
                else if (type == 4)
                {
                    value = Encoding.GetEncoding("UNICODE").GetString(bbuff).TrimEnd('\0');
                }
                // add redmai #4820 「患者カードを作成しても透析装置でデータ異常と表示される」を修正する。 鄧シン end
                return value;
            }
            catch (Exception)
            {
                return string.Empty;
            }
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

#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
