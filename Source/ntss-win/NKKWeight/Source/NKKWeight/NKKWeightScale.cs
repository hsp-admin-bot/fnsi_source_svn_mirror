//----------------------------------------------------------------------------------------------------
//  NKKWeightScaleクラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Ports;
using System.Reflection;

#if DEBUG
    using System.Diagnostics;
#endif

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
using System.Threading;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightLib
//----------------------------------------------------------------------------------------------------
namespace NKKWeightLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKWeightScaleクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKWeightScale : ToGUI
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// シリアル通信用設定
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public struct SERIAL_INFO
        {
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// ポート名
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            public String strPortName;
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 通信速度
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            public int nBaudRate;
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// データ長
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            public int nDataBits;
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// ストップビット長
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            public StopBits StopBits;
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// パリティ制御
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            public Parity Parity;
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// フロー制御
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            public Handshake Handshake;
            //----------------------------------------------------------------------------------------------------
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = "WeightScale";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続状態通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_WEIGHT_CONNECT_URI = "/api/weight_state/weight_connect";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 測定値通知URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String PUT_WEIGHT_VALUE_URI = "/api/weight_state/scale_value";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// シリアル通信コンポーネント 
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private SerialPort m_SerialPort = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// シリアル通信パラメータ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private SERIAL_INFO m_SerialInformation = new SERIAL_INFO();
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計との接続状態[true：接続中/false：未接続]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Boolean m_bConnected = false;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計からの値を格納するバッファ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String m_strSerialBuffer = String.Empty;
        //----------------------------------------------------------------------------------------------------
        // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 start
        /// <summary>
        /// 測定重量リスト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static List<Decimal> listvalues = new List<Decimal>();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 現在の時刻
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime starttime = DateTime.Now;
        //----------------------------------------------------------------------------------------------------
        // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 end
        // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッド終了用シグナル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly System.Threading.ManualResetEvent m_evFinish = new ManualResetEvent(false);
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッドオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Thread m_Thread = null;
        //----------------------------------------------------------------------------------------------------
        // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 end
        // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
        /// <summary>
        /// 体重計との通信フォーマット
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String weightFormatData = String.Empty;
        //----------------------------------------------------------------------------------------------------

        /// <summary>
        /// 体重計とのUNIT
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String weightFormatUnit = String.Empty;
        //----------------------------------------------------------------------------------------------------
        // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end

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
                    this.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(this.SERVICE_NAME + " " + strlogdata);
#endif
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通信状態参照用プロパティ[true：通信中/false：未通信]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Boolean IsOpen
        {
            get
            {
                Boolean bret = false;
                if (this.m_SerialPort != null)
                {
                    bret = this.m_SerialPort.IsOpen;
                    if ( bret== false && this.IsConnected == true )
                    {
                        DateTime dtnow = DateTime.Now;
                        String strlog = "NKKWeightScaleの切断を検出";

                        // ログ記録
                        this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.ERROR, strlog);
                        // GUIへ通知
                        this.SendMessageToGUI("切断検出", dtnow, strlog);

                        // 接続状態を通知
                        this.SendWeightConnect(false);
                    }
                }

                return bret;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// シリアル通信情報参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public SERIAL_INFO SerialInfomation
        {
            get { return this.m_SerialInformation; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// シリアル通信情報文字列参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String SerialInfomationString
        {
            get 
             {
                StringBuilder sb = new StringBuilder();

                // ポート名
                sb.AppendFormat("PortName:{0}", this.m_SerialPort.PortName);
                // 通信速度
                sb.AppendFormat(", BaudRate:{0}", this.m_SerialPort.BaudRate);
                // データ長
                sb.AppendFormat(", DataBits:{0}", this.m_SerialPort.DataBits);
                // ストップビット長
                sb.AppendFormat(", StopBits:{0}", this.m_SerialPort.StopBits);
                // パリティ制御
                sb.AppendFormat(", Parity:{0}", this.m_SerialPort.Parity);
                // フロー制御
                sb.AppendFormat(", Handshake:{0}", this.m_SerialPort.Handshake);

                // 体重計機種
                sb.AppendFormat(", DeviceClass:{0}", NKKWeightInformation.DeviceClass);

                return (sb.ToString());
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計との接続状態参照用プロパティ[true：接続中/false：未接続]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Boolean IsConnected
        {
            get { return (this.m_bConnected); }
        }
        //----------------------------------------------------------------------------------------------------


#endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKWeightScale()
        {
            // 構築処理
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        ~NKKWeightScale()
        {
            // 通信終了
            this.Close();

            // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 start
            if ("1".Equals(NKKWeightInformation.DeviceClass))
            {
                if (this.m_Thread != null)
                {
                    // スレッド停止
                    this.m_evFinish.Set();
                }
            }
            // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 end            
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 初期化処理
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public Boolean Init(SERIAL_INFO info)
        {
            Boolean bret = false;

            try
            {
                //
                this.m_SerialPort = new SerialPort();

                // イベント登録
                //this.m_SerialPort.DataReceived -= this.DataReceived;
                this.m_SerialPort.DataReceived += this.DataReceived;
                //this.m_SerialPort.PinChanged -= this.PinChanged;
                this.m_SerialPort.PinChanged += this.PinChanged;
                //this.m_SerialPort.ErrorReceived -= this.ErrorReceived;
                this.m_SerialPort.ErrorReceived += this.ErrorReceived;


                // 体重計種類による個別設定
                if (NKKWeightInformation.DeviceClass == "2")
                {
                    // ヤマトハカリの場合

                    // データ長：8bit
                    info.nDataBits = 8;
                    // パリティ：なし
                    info.Parity = Parity.None;
                    // フロー制御：ハードウェア(RTS/CTS)
                    info.Handshake = Handshake.RequestToSend;
                }

                // 
                // 通信設定保持
                this.m_SerialInformation = info;

                // 通信設定
                this.m_SerialPort.PortName = info.strPortName;
                this.m_SerialPort.BaudRate = info.nBaudRate;
                this.m_SerialPort.DataBits = info.nDataBits;
                this.m_SerialPort.StopBits = info.StopBits;
                this.m_SerialPort.Parity = info.Parity;
                this.m_SerialPort.Handshake = info.Handshake;

                this.m_SerialPort.RtsEnable = true;
                this.m_SerialPort.DtrEnable = true;

                this.m_SerialPort.WriteTimeout = 200;
                this.m_SerialPort.ReadTimeout = 200;

                bret = true;
            }
            catch( Exception ex )
            {
                this.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ポートオープン
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public Boolean Open()
        {
            Boolean bret = false;

            DateTime dtnow = DateTime.Now;

            try
            {
                // ポートが開いている場合
                if (this.IsOpen == true)
                {
                    // ポートを閉じる
                    this.Close();
                }

                // ポート開く
                this.m_SerialPort.Open();

                bret = true;

                // ログ記録
                String strlog = String.Format("通信開始,{0}", this.SerialInfomationString);
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

                // GUIへ通知
                this.SendMessageToGUI("接続中", dtnow, strlog);

                // 接続状態を通知
                this.SendWeightConnect(bret);

                // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 start
                if ("1".Equals(NKKWeightInformation.DeviceClass))
                {
                    // スレッド構築
                    this.m_Thread = new Thread(this.DoWork);

                    if (this.m_Thread != null)
                    {
                        // 接続/WatchDoc用スレッド開始
                        this.m_Thread.Start();
                    }
                }
                // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 end
            }
            catch ( Exception ex )
            {
                this.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ポートクローズ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Close()
        {
            DateTime dtnow = DateTime.Now;

            try
            {
                // ポートが開いている場合
                if (this.IsOpen == true)
                {
                    // ポートを閉じる
                    this.m_SerialPort.Close();
                }

                // 接続状態を通知
                this.SendWeightConnect(false);

                // ログ記録
                String strlog = "通信終了";
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

                // GUIへ通知
                this.SendMessageToGUI("切断中", dtnow, strlog);

                // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 start
                if ("1".Equals(NKKWeightInformation.DeviceClass))
                {
                    // 接続/WatchDoc用スレッド停止
                    if (this.m_Thread != null)
                    {
                        // カウンタ値初期化
                        uint dwtickcount = (uint)System.Environment.TickCount;
                        // スレッドが終了するか10秒間待つ
                        while (!TdcLib.TdcLib.CheckTickCount(10 * 1000, dwtickcount, (uint)System.Environment.TickCount))
                        {
                            // スレッド停止
                            this.m_evFinish.Set();

                            // スレッドが終了した場合
                            if (this.m_Thread.IsAlive == false)
                            {
                                // 処理を抜ける
                                break;
                            }
                        };
                    }
                }
                // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 end
            }
            catch ( Exception ex )
            {
                this.Error = ex;
            }
        }
        //----------------------------------------------------------------------------------------------------


        #region プライベートメソッド定義
        // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッド実行処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void DoWork()
        {
            // スレッド開始
            this.m_evFinish.Reset();
            
            DateTime dtnow = DateTime.Now;
            // 電文解析
            String strweight = CheckWeightCommand(this.m_strSerialBuffer);

            while (true)
            {
                int interval = (DateTime.Now - starttime).Seconds;
                if (interval >= NKKWeightInformation.DataSendInterval && listvalues.Count > 0)
                {
                    // GUIへ通知
                    this.SendMessageToGUI(this.SERVICE_NAME, "測定", dtnow, strweight);

                    if ("2".Equals(NKKWeightInformation.DataSelectType))
                    {
                        listvalues.Sort((x, y) => -x.CompareTo(y));
                    }
                    else if ("1".Equals(NKKWeightInformation.DataSelectType))
                    {
                        listvalues.Sort((x, y) => x.CompareTo(y));
                    }

                    String strscalevaluelist = string.Join(",", listvalues.ToArray());
                    listvalues.Clear();

                    Task.Run(() =>
                    {
                        // 測定値を通知
                        //*@param request { weightCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, scaleValue: 測定値 }
                        String strUri = String.Format("{0}{1}{2}?_={3}"
                                , NKKWebAccess.BaseUri
                                , NKKWeightInformation.WEB_APP_URI
                                , this.PUT_WEIGHT_VALUE_URI
                                , DateTime.Now.Ticks);
                        String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}, \"scaleValueList\":\"{3}\"}}"
                            , NKKWeightInformation.WeightCd
                            , NKKWebAccess.FacilityCd
                            , NKKWeightInformation.WeightNo
                            , strscalevaluelist
                            );

                        NKKWebAccessResponse res = NKKWebAccess.Put("体重測定値通知", strUri, strbody).Result;
                        if (res.response.IsSuccessStatusCode == true)
                        {
                            // 処理成功

                            // ログ記録
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重測定値通知完了,{0}", strbody));
                        }
                    });
                }

                this.m_evFinish.WaitOne(500);
            }

        }
        // add 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 end
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
        private void SendMessageToGUI(String strStatus, DateTime dtOccurDate, String strMessage )
        {
            // GUIへ通知
            base.SendMessageToGUI(this.SERVICE_NAME, strStatus, dtOccurDate, strMessage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 受信電文解析
        /// </summary>
        /// <param name="strCommand">受信電文</param>
        /// <returns>Empty:解析失敗/else：測定値</returns>
        //----------------------------------------------------------------------------------------------------
        private String CheckWeightCommand( String strCommand )
        {
            // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
            if (String.IsNullOrEmpty(weightFormatData))
            {
                // GUIへ通知
                this.SendMessageToGUI(this.SERVICE_NAME, "測定", DateTime.Now, "通信フォーマット不正");
                return String.Empty;
            }
            // [CRLF]/[CR]/[LF]を分割
            String[] weightFormats = weightFormatData.Split(new String[] { "[CRLF]", "[CR]", "[LF]" }, StringSplitOptions.RemoveEmptyEntries);
            String weightFormat = weightFormats[0];

            int tempIndex = weightFormat.IndexOf("}");
            String tempBefor = weightFormat.Substring(0, tempIndex + 1);
            String tempAfter = weightFormat.Substring(tempIndex + 1, weightFormat.Length - tempIndex - 1);
            String tempReplace = String.Empty;
            bool replaceFlg = false;
            foreach (Char ch in tempAfter)
            {
                if ("}".Equals(ch.ToString()))
                {
                    replaceFlg = false;
                }
                if (replaceFlg == true)
                {
                    tempReplace = tempReplace + "*";
                }
                else
                {
                    tempReplace = tempReplace + ch;
                }
                if ("{".Equals(ch.ToString())) 
                {
                    replaceFlg = true;
                }
            }
            tempAfter = tempReplace.Replace("{**", "").Replace("}","");
            weightFormat = tempBefor + tempAfter;

            int formatLength = weightFormat.Length;


            // 「00000.00」を取得
            String valueFormat = GetFormatValue(weightFormat);
            int valueIndex = weightFormat.IndexOf(valueFormat);
            String beforFormat = weightFormat.Substring(0, valueIndex - 3);
            String afterFormat = weightFormat.Substring(valueIndex + valueFormat.Length + 1, formatLength - valueIndex - 1 - valueFormat.Length);
            String dataFormat = beforFormat + valueFormat + afterFormat;
            // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end
            String strret = String.Empty;

            try
            {
                // CRLF/CR/LFで電文を分割
                String[] strdatas = strCommand.Split(new String[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries);
                foreach( String strdata in strdatas )
                {
                    // mod 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
                    //// 機種判定
                    //switch (NKKWeightInformation.DeviceClass)
                    //{
                    //    case "0":   // A&D
                    //        if (strdata.StartsWith("ST,") == true && strdata.EndsWith("kg") == true)
                    //        {
                    //            // 旧フォーマット：ST,+00000.00 kg,+00000.00 kg\r\n
                    //            // 新フォーマット：ST,+00000.00 kg\r\n

                    //            // 測定値取得
                    //            strret = strdata.Substring(3, 9).Trim();
                    //        }
                    //        break;

                    //    case "1":   // 田中衡機
                    //        if (strdata.EndsWith("kg") == true)
                    //        {
                    //            // ヘッダ1
                    //            //  OL：オーバーロード
                    //            //　ST：安定
                    //            //  US：不安定

                    //            // ヘッダ2
                    //            //  NT：正味重量
                    //            //  GS：総重量

                    //            // 極性
                    //            //  +：＋データ
                    //            //  -：－データ

                    //            // フォーマット1：{ヘッダ1},{ヘッダ2},{極性},{データ}kg\r\n
                    //            if (strdata.StartsWith("ST") == true)
                    //            {
                    //                // 安定のみ

                    //                // 測定値取得
                    //                strret = strdata.Substring(6, 8);
                    //            }

                    //            // フォーマット2：@{アドレス[2桁]}{ヘッダ1},{ヘッダ2},{極性},{データ}kg\r\n
                    //            if (strdata.StartsWith("@") == true && strdata.Substring(3, 2).Equals("ST") == true)
                    //            {
                    //                // 安定のみ

                    //                // 測定値取得
                    //                strret = strdata.Substring(9, 8);
                    //            }

                    //        }
                    //        break;

                    //    case "2":   // ヤマトハカリ[DP5300互換モード]
                    //        int idx_etx = strdata.IndexOf((Char)0x03);
                    //        if (strdata.StartsWith(new String((Char)0x01, 2)) == true && 0 < idx_etx)
                    //        {
                    //            // 先頭SOH[0x01]×2出、末尾ETX[0x03]検出

                    //            // フォーマット
                    //            //  [SOH][SOH]{制御コード部：4桁}[STX]{テキスト部：11桁～}[ETX][BCC][CR]

                    //            // コントロールコード
                    //            //  SOH：0x01
                    //            //  STX：0x02
                    //            //  ETX：0x03
                    //            //  CR ：0x0d
                    //            //  SP ：0x20
                    //            //  BCC：0x00～0xFF

                    //            //  制御コード部：{送信順番：'0'～'2'}{小ブロック数：'1'～'8'}[SP][SP]
                    //            //  テキスト部  ：{ヘッダ文字：2桁}{データ：8桁(満たない場合は前方SP埋め)}{単位：2桁(重量データの場合のみ付加)}[,]
                    //            //    ※テキスト部は制御コードの小ブロック数分存在する
                    //            //  BCC算出方法 ：制御コードからETXまでのすべての値をxorした値

                    //            // ヘッダ文字
                    //            //  CD：コード
                    //            //  DT：日付
                    //            //  NW：正味重量
                    //            //  TW：風体重量
                    //            //  GW：総重量
                    //            //  LH：重量上限値
                    //            //  LL：重量下限値

                    //            // BCC算出
                    //            Char bcc = (Char)0x00;
                    //            for (int intlop = 2; intlop <= idx_etx; intlop++)
                    //            {
                    //                // 
                    //                bcc ^= (Char)strdata[intlop];
                    //            }
                    //            // BCCチェック
                    //            if (strdata[idx_etx + 1] == bcc)
                    //            {
                    //                // BCCチェックOK

                    //                // 必要情報切り出し
                    //                String strBlock = strdata.Substring(6, idx_etx - 1 - 6);
                    //                String[] strBlocks = strBlock.Split(new String[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                    //                foreach (String strText in strBlocks)
                    //                {
                    //                    // ヘッダ判定
                    //                    if (strText.StartsWith("NW") == true)
                    //                    {
                    //                        // 正味重量取得
                    //                        strret = strText.Substring(2, 8).Trim();
                    //                        break;
                    //                    }
                    //                }
                    //            }
                    //        }
                    //        break;
                    //}

                    // BCCチェック
                    bool bccFlg = false;
                    int idx_etx = GetBCCIndex(weightFormat);
                    if (idx_etx > 0)
                    {
                        // BCC算出
                        Char bcc = (Char)0x00;
                        for (int intlop = 0; intlop < idx_etx - 4; intlop++)
                        {
                            bcc ^= (Char)strdata[intlop];
                        }
                        // BCCチェック
                        if (strdata[idx_etx - 4] == bcc)
                        {
                            bccFlg = true;
                            weightFormat = weightFormat.Replace("[BCC]", bcc.ToString());
                            beforFormat = weightFormat.Substring(0, valueIndex - 3);
                            afterFormat = weightFormat.Substring(valueIndex + valueFormat.Length + 1, weightFormat.Length - valueIndex - 1 - valueFormat.Length);
                        }
                    }
                    String tempStrdata = strdata;
                    if ("0".Equals(NKKWeightInformation.DeviceClass))
                    {
                        int len = dataFormat.Length;
                        if (tempStrdata.Length > len)
                        {
                            tempStrdata = tempStrdata.Substring(0, len);
                        }
                        
                    }

                    if (idx_etx == -1 || bccFlg == true)
                    {
                        // 電文変換
                        String changeData = String.Empty;
                        foreach (Char ch in tempStrdata)
                        {
                            // 「0x01」⇒「[SOH]」
                            changeData = changeData + ConvertASCIICode(ch);
                        }

                        if (changeData.Length == weightFormat.Length - 4)
                        {
                            String beforData = changeData.Substring(0, valueIndex - 3);
                            String afterData = changeData.Substring(valueIndex - 3 + valueFormat.Length, changeData.Length - valueIndex + 3 - valueFormat.Length);
                            bool checkFlg = true;
                            List<string> beforDataList = GetStrList(beforData);
                            List<string> afterDataList = GetStrList(afterData);
                            List<string> beforFormatList = GetStrList(beforFormat);
                            List<string> afterFormatList = GetStrList(afterFormat);
                            if ((beforDataList.Count == beforFormatList.Count) && (afterDataList.Count == afterFormatList.Count))
                            {
                                for (int i = 0; i < beforFormatList.Count; i++)
                                {
                                    if ("*".Equals(beforFormatList[i]))
                                    {
                                        continue;
                                    }
                                    if (!beforFormatList[i].Equals(beforDataList[i]))
                                    {
                                        checkFlg = false;
                                        break;
                                    }
                                }
                                if (checkFlg == true)
                                {
                                    for (int i = 0; i < afterFormatList.Count; i++)
                                    {
                                        if ("*".Equals(afterFormatList[i]))
                                        {
                                            continue;
                                        }
                                        if (!afterFormatList[i].Equals(afterDataList[i]))
                                        {
                                            checkFlg = false;
                                            break;
                                        }
                                    }
                                }
                                if (checkFlg == true)
                                {
                                    // 測定値取得
                                    String changeDataValue = changeData.Substring(valueIndex - 3, valueFormat.Length).Trim();
                                    if (changeDataValue.IndexOf(".") == valueFormat.IndexOf("."))
                                    {
                                        // mod No.314:体重計との通信フォーマットの外部定義化 不具合修正 馮 start
                                        //strret = changeDataValue.Trim() + weightFormatUnit;
                                        strret = changeDataValue.Trim();
                                        // mod No.314:体重計との通信フォーマットの外部定義化 不具合修正 馮 end
                                        break;
                                    }
                                    else
                                    {
                                        // ログ記録：フォーマットエラー
                                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("通信フォーマット不正。「{0}」", weightFormats[0]));
                                    }
                                }
                                if (checkFlg == false)
                                {
                                    // ログ記録：フォーマットエラー
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("通信フォーマット不正。「{0}」", weightFormats[0]));
                                }

                            }
                            else
                            {
                                // ログ記録：フォーマットエラー
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("通信フォーマット不正。「{0}」", weightFormats[0]));
                            }
                        }
                        else
                        {
                            // ログ記録：フォーマットエラー
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("通信フォーマット不正。「{0}」", weightFormats[0]));
                        }
                    }
                    else 
                    {
                        // ログ記録：フォーマットエラー
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("通信フォーマット不正。「{0}」", weightFormats[0]));
                    }
                    // mod 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end


                    // ログ記録
                    String strlog = String.Format("測定値, {0}", strret);
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                    // 数値チェック
                    Decimal dec = Convert.ToDecimal(strret);

                }
            }
            catch( Exception ex )
            {
                this.Error = ex;
                strret = String.Empty;

            }

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------

        // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 体重計フォーマットの値を取得
        /// </summary>
        /// <param name="format">体重計フォーマット</param>
        /// <returns> 体重計フォーマットの値</returns>
        //----------------------------------------------------------------------------------------------------
        private String GetFormatValue(String format)
        {
            // 体重計フォーマット:{0:00000.00}
            int firstIndex = format.IndexOf("{");
            int secondIndex = format.IndexOf("}");
            // 「0:」を除く
            int valueLength = secondIndex - firstIndex - 3;
            // 00000.00
            String valueFormat = format.Substring(firstIndex + 3, valueLength);

            return valueFormat;
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// BCCのIndex取得
        /// </summary>
        /// <param name="format">体重計フォーマット</param>
        /// <returns>BCCのIndex</returns>
        //----------------------------------------------------------------------------------------------------
        private int GetBCCIndex(String format)
        {
            int index = -1;
            if (format.IndexOf("[BCC]") > 0)
            {
                format = format.Replace("[NUL]", "a");
                format = format.Replace("[SOH]", "a");
                format = format.Replace("[STX]", "a");
                format = format.Replace("[ETX]", "a");
                format = format.Replace("[EOT]", "a");
                format = format.Replace("[ENQ]", "a");
                format = format.Replace("[ACK]", "a");
                format = format.Replace("[BEL]", "a");
                format = format.Replace("[BS]", "a");
                format = format.Replace("[HT]", "a");
                format = format.Replace("[LF]", "a");
                format = format.Replace("[VT]", "a");
                format = format.Replace("[FF]", "a");
                format = format.Replace("[CR]", "a");
                format = format.Replace("[SO]", "a");
                format = format.Replace("[SI]", "a");
                format = format.Replace("[DLE]", "a");
                format = format.Replace("[DC1]", "a");
                format = format.Replace("[DC2]", "a");
                format = format.Replace("[DC3]", "a");
                format = format.Replace("[DC4]", "a");
                format = format.Replace("[NAK]", "a");
                format = format.Replace("[SYN]", "a");
                format = format.Replace("[ETB]", "a");
                format = format.Replace("[CAN]", "a");
                format = format.Replace("[EM]", "a");
                format = format.Replace("[SUB]", "a");
                format = format.Replace("[ESC]", "a");
                format = format.Replace("[FS]", "a");
                format = format.Replace("[GS]", "a");
                format = format.Replace("[RS]", "a");
                format = format.Replace("[US]", "a");
                format = format.Replace("[DEL]", "a");
                return format.IndexOf("[BCC]");
            }
            return index;
        }
        //----------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ASCIIコード変換
        /// </summary>
        /// <param name="strCommand">ASCIIコード</param>
        /// <returns>変換後の値</returns>
        //----------------------------------------------------------------------------------------------------
        private String ConvertASCIICode(Char ch)
        {
            String str = String.Empty;
            switch (ch)
            {
                case (Char)0x00: str = "[NUL]"; break;
                case (Char)0x01: str = "[SOH]"; break;
                case (Char)0x02: str = "[STX]"; break;
                case (Char)0x03: str = "[ETX]"; break;
                case (Char)0x04: str = "[EOT]"; break;
                case (Char)0x05: str = "[ENQ]"; break;
                case (Char)0x06: str = "[ACK]"; break;
                case (Char)0x07: str = "[BEL]"; break;
                case (Char)0x08: str = "[BS]"; break;
                case (Char)0x09: str = "[HT]"; break;
                case (Char)0x0A: str = "[LF]"; break;
                case (Char)0x0B: str = "[VT]"; break;
                case (Char)0x0C: str = "[FF]"; break;
                case (Char)0x0D: str = "[CR]"; break;
                case (Char)0x0E: str = "[SO]"; break;
                case (Char)0x0F: str = "[SI]"; break;
                case (Char)0x10: str = "[DLE]"; break;
                case (Char)0x11: str = "[DC1]"; break;
                case (Char)0x12: str = "[DC2]"; break;
                case (Char)0x13: str = "[DC3]"; break;
                case (Char)0x14: str = "[DC4]"; break;
                case (Char)0x15: str = "[NAK]"; break;
                case (Char)0x16: str = "[SYN]"; break;
                case (Char)0x17: str = "[ETB]"; break;
                case (Char)0x18: str = "[CAN]"; break;
                case (Char)0x19: str = "[EM]"; break;
                case (Char)0x1A: str = "[SUB]"; break;
                case (Char)0x1B: str = "[ESC]"; break;
                case (Char)0x1C: str = "[FS]"; break;
                case (Char)0x1D: str = "[GS]"; break;
                case (Char)0x1E: str = "[RS]"; break;
                case (Char)0x1F: str = "[US]"; break;
                case (Char)0x7F: str = "[DEL]"; break;
                default: str = ch.ToString(); break;
            }

            return str;
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GetStrList
        /// </summary>
        /// <param name="format">str</param>
        /// <returns> List</returns>
        //----------------------------------------------------------------------------------------------------
        private List<string> GetStrList(String str)
        {
            List<string> list = new List<string>();
            foreach (char c in str)
            {
                list.Add(c.ToString());
            }
            return list;
        }
        //----------------------------------------------------------------------------------------------------
        // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end

        /// <summary>
        /// 体重計との接続状態をサーバーへ通知
        /// </summary>
        /// <param name="bConnect">接続状態[true：接続中/false：未接続]</param>
        //----------------------------------------------------------------------------------------------------
        private void SendWeightConnect( Boolean bConnect )
        {
            Task.Run(() =>
        {
            // 接続状態変化
            if (this.IsConnected != bConnect)
            {
                // 接続状態変化

                // バッファクリア
                this.m_strSerialBuffer = string.Empty;

                // 接続状態を通知
                //*@param request { weightCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, isConnect: 接続状態 }
                String strUri = String.Format("{0}{1}{2}?_={3}"
                    , NKKWebAccess.BaseUri
                    , NKKWeightInformation.WEB_APP_URI
                    , this.PUT_WEIGHT_CONNECT_URI
                    , DateTime.Now.Ticks);
                String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}, \"isConnect\":\"{3}\"}}"
                    , NKKWeightInformation.WeightCd
                    , NKKWebAccess.FacilityCd
                    , NKKWeightInformation.WeightNo
                    , bConnect == true ? "1" : "0"
                    );
                NKKWebAccessResponse res = NKKWebAccess.Put("体重計接続状態通知", strUri, strbody).Result;
                if (res.response.IsSuccessStatusCode == true)
                {
                    // 処理成功

                    // 接続状態を保持
                    this.m_bConnected = bConnect;

                    // ログ記録
                    String strlog = "体重計接続状態通知完了,";
                    if( bConnect == true )
                    {
                        strlog += "接続";
                    }
                    else
                    {
                        strlog += "未接続";
                    }
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);
                }
            }
        }
            );
        }
        //----------------------------------------------------------------------------------------------------

#region イベント定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// データ受信時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void DataReceived( object sender, SerialDataReceivedEventArgs e )
        {
            DateTime dtnow = DateTime.Now;

            try
            {
                // データ受信
                int nsize = this.m_SerialPort.BytesToRead;
                Byte[] bdata = new Byte[nsize];
                int nreadcount = this.m_SerialPort.Read(bdata, 0, nsize);

                // データ変換
                String strdata = TdcLib.TdcLib.GetByteToString(bdata, "utf-8");

                // ログ記録
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("受信,{0}", strdata));

                // del 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
                // GUIへ通知
                //this.SendMessageToGUI(this.SERVICE_NAME, "受信", dtnow, strdata);
                // del 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end

                // データのバッファリング
                this.m_strSerialBuffer  += strdata;

                // データのサイズが特定サイズを超えた場合
                if ((NKKWeightInformation.DeviceClass != "2" && 30 < this.m_strSerialBuffer.Length)
                 || (NKKWeightInformation.DeviceClass == "2" && 100 < this.m_strSerialBuffer.Length))
                {
                    // バッファクリア
                    this.m_strSerialBuffer = string.Empty;
                }

                // データ末尾の{CR}{LF}/{CR}判定
                if (this.m_strSerialBuffer.EndsWith("\r\n") == true || this.m_strSerialBuffer.EndsWith("\r") == true)
                {
                    // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 start
                    // GUIへ通知
                    this.SendMessageToGUI(this.SERVICE_NAME, "受信", dtnow, this.m_strSerialBuffer);
                    // add 2020-12-23 No.314:体重計との通信フォーマットの外部定義化 商 end

                    // 接続状態を通知
                    this.SendWeightConnect(true);

                    // 電文解析
                    String strweight = CheckWeightCommand(this.m_strSerialBuffer);
                    // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 start
                    if ("1".Equals(NKKWeightInformation.DeviceClass))
                    {
                        if (listvalues.Count == 0)
                        {
                            starttime = DateTime.Now;
                        }

                        if (String.IsNullOrEmpty(strweight) == false && Convert.ToDecimal(strweight) > Decimal.Zero)
                        {
                            listvalues.Insert(0, Convert.ToDecimal(strweight));
                        }

                        // del 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 start
                        //int interval = (DateTime.Now - starttime).Seconds;
                        //if (interval >= NKKWeightInformation.DataSendInterval && listvalues.Count > 0)
                        //{
                        //    // GUIへ通知
                        //    this.SendMessageToGUI(this.SERVICE_NAME, "測定", dtnow, strweight);

                        //    if ("2".Equals(NKKWeightInformation.DataSelectType))
                        //    {
                        //        listvalues.Sort((x, y) => -x.CompareTo(y));
                        //    }
                        //    else if ("1".Equals(NKKWeightInformation.DataSelectType))
                        //    {
                        //        listvalues.Sort((x, y) => x.CompareTo(y));
                        //    }

                        //    String strscalevaluelist = string.Join(",", listvalues.ToArray());
                        //    listvalues.Clear();

                        //    Task.Run(() =>
                        //    {
                        //    // 測定値を通知
                        //    //*@param request { weightCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, scaleValue: 測定値 }
                        //    String strUri = String.Format("{0}{1}{2}?_={3}"
                        //            , NKKWebAccess.BaseUri
                        //            , NKKWeightInformation.WEB_APP_URI
                        //            , this.PUT_WEIGHT_VALUE_URI
                        //            , DateTime.Now.Ticks);
                        //        String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}, \"scaleValueList\":\"{3}\"}}"
                        //            , NKKWeightInformation.WeightCd
                        //            , NKKWebAccess.FacilityCd
                        //            , NKKWeightInformation.WeightNo
                        //            , strscalevaluelist
                        //            );

                        //        NKKWebAccessResponse res = NKKWebAccess.Put("体重測定値通知", strUri, strbody).Result;
                        //        if (res.response.IsSuccessStatusCode == true)
                        //        {
                        //        // 処理成功

                        //        // ログ記録
                        //        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重測定値通知完了,{0}", strbody));
                        //        }
                        //    });
                        //}
                        // del 外部結合テストの体重測定・条件送信No.6 田中衡機送信タイム対応 夏 end
                    }
                    else
                    {
                    // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 end
                        if (String.IsNullOrEmpty(strweight) == false)
                        {
                            // 測定値取得

                            //ログ記録
                            //this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, String.Format("測定値,{0}", strweight));
                            // mod 2021-03-26 FNSI-仕様追加 不具合修正 馮 start
                            // GUIへ通知
                            //this.SendMessageToGUI(this.SERVICE_NAME, "測定", dtnow, strweight);
                            this.SendMessageToGUI(this.SERVICE_NAME, "測定", dtnow, strweight + " "+ this.weightFormatUnit);
                            // mod 2021-03-26 FNSI-仕様追加 不具合修正 馮 end
                            Task.Run(() =>
                            {
                                // 測定値を通知
                                //*@param request { weightCd: 体重計管理コード, facilityCd: 施設コード, weightNo: 体重計番号, scaleValue: 測定値 }
                                String strUri = String.Format("{0}{1}{2}?_={3}"
                                    , NKKWebAccess.BaseUri
                                    , NKKWeightInformation.WEB_APP_URI
                                    , this.PUT_WEIGHT_VALUE_URI
                                    , DateTime.Now.Ticks);
                                String strbody = String.Format("{{\"weightCd\":{0}, \"facilityCd\":\"{1}\", \"weightNo\":{2}, \"scaleValue\":{3}}}"
                                    , NKKWeightInformation.WeightCd
                                    , NKKWebAccess.FacilityCd
                                    , NKKWeightInformation.WeightNo
                                    , Convert.ToDecimal(strweight)
                                    );
                                NKKWebAccessResponse res = NKKWebAccess.Put("体重測定値通知", strUri, strbody).Result;
                                if (res.response.IsSuccessStatusCode == true)
                                {
                                    // 処理成功

                                    // ログ記録
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("体重測定値通知完了,{0}", strbody));
                                }
                            });
                        }
                    // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 start
                    }
                    // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 end
                    // バッファクリア
                    this.m_strSerialBuffer = string.Empty;
                }



#if DEBUG
                //
                Debug.WriteLine("{0}{1}", MethodBase.GetCurrentMethod().Name, e.ToString());
#endif

            }
            catch ( Exception ex )
            {
                this.Error = ex;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ピン信号変更時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void PinChanged( object sender, SerialPinChangedEventArgs e )
        {
            DateTime dtnow = DateTime.Now;

            try
            {
                // 信号判定
                Boolean bflag = false;
                String strpin = e.EventType.ToString();
                strpin += ":";
                switch (e.EventType)
                {
                    case SerialPinChange.Break:
                        bflag = this.m_SerialPort.BreakState;
                        break;

                    case SerialPinChange.CDChanged:
                        bflag = this.m_SerialPort.CDHolding;
                        break;

                    case SerialPinChange.CtsChanged:
                        bflag = this.m_SerialPort.CDHolding;
                        break;

                    case SerialPinChange.DsrChanged:
                        bflag = this.m_SerialPort.DsrHolding;
                        break;

                    case SerialPinChange.Ring:
                        bflag = true;
                        break;
                }
                strpin += bflag.ToString();

                // ログ記録
                String strlog = String.Format("ピン信号変化,{0}", strpin);
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

                // GUIへ通知
                this.SendMessageToGUI("信号変化", dtnow, strlog);


                // 接続状態を通知
                this.SendWeightConnect(bflag);

#if DEBUG
                //
                Debug.WriteLine("{0}{1}", MethodBase.GetCurrentMethod().Name, e.ToString());
#endif
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// エラー発生時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ErrorReceived(object sender, SerialErrorReceivedEventArgs e)
        {
            DateTime dtnow = DateTime.Now;

            try
            {
                // ログ記録
                String strlog = String.Format("エラー発生:{0}", e.ToString());
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                // GUIへ通知
                this.SendMessageToGUI("エラー", dtnow, strlog);

#if DEBUG
                //
                Debug.WriteLine("{0}{1}", MethodBase.GetCurrentMethod().Name, e.ToString());
#endif
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
        }
        //----------------------------------------------------------------------------------------------------

#endregion

#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
