using FNSiViewSyncLogicLib.Models;
using FNSiViewSyncLogicLib.Services;
using FNSiViewSyncLogicLib.Common.Utilities;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using TdcLib;

namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// FNSiSocketClientクラス
    /// </summary>
    class FNSiSocketClient
    {
        #region プライベート定義

        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        private Exception m_Exception = null;

        /// <summary>
        /// 出力先テーブル情報配列
        /// </summary>
        private List<ViewTableInfo> m_viewTableInfoList = new List<ViewTableInfo>();

        /// <summary>
        /// IFエッジサービスのIP
        /// </summary>
        private String m_strIFEdgeIPAddress = String.Empty;

        /// <summary>
        /// IFエッジサービスのポートNo
        /// </summary>
        private int m_nIFEdgePortNo = 0;

        /// <summary>
        /// ローカルサービスのIP
        /// </summary>
        private String m_strLocalIPAddress = String.Empty;

        /// <summary>
        /// ローカルサービスのポートNo
        /// </summary>
        private int m_nLocalPortNo = 0;

        /// <summary>
        /// 同期モード(1:起動、2:固定同期頻度1、3:固定同期頻度2、4:間隔同期)
        /// </summary>
        private int m_nSyncMode = -1;

        public string JobKeyName = String.Empty;

        #endregion

        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="viewTableInfoList">出力先テーブル情報配列</param>
        public FNSiSocketClient(List<ViewTableInfo> viewTableInfoList)
        {
            m_viewTableInfoList = viewTableInfoList;
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~FNSiSocketClient()
        {
        }

        /// <summary>
        /// IFエッジサービスのIP 参照/設定用プロパティ
        /// </summary>
        public String IFEdgeIPAddress
        {
            get { return this.m_strIFEdgeIPAddress; }
            set { this.m_strIFEdgeIPAddress = value; }
        }

        /// <summary>
        /// IFエッジサービスのポートNo 参照/設定用プロパティ
        /// </summary>
        public int IFEdgePortNo
        {
            get { return this.m_nIFEdgePortNo; }
            set { this.m_nIFEdgePortNo = value; }
        }

        /// <summary>
        ///ローカルサービスのIP 参照/設定用プロパティ
        /// </summary>
        public String LocalIPAddress
        {
            get { return this.m_strLocalIPAddress; }
            set { this.m_strLocalIPAddress = value; }
        }

        /// <summary>
        /// ローカルサービスのポートNo 参照/設定用プロパティ
        /// </summary>
        public int LocalPortNo
        {
            get { return this.m_nLocalPortNo; }
            set { this.m_nLocalPortNo = value; }
        }

        /// <summary>
        /// 同期モード(1:起動、2:固定同期頻度1、3:固定同期頻度2、4:間隔同期) 参照/設定用プロパティ
        /// </summary>
        public int SyncMode
        {
            get { return this.m_nSyncMode; }
            set { this.m_nSyncMode = value; }
        }

        public void DoWork()
        {
            ViewTableInfo viewTableInfo = m_viewTableInfoList[0];
            String sendData = "";
            try
            {
                // ソケット構築
                Socket clientSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                // 接続
                clientSocket.Connect(new IPEndPoint(IPAddress.Parse(this.m_strIFEdgeIPAddress), this.m_nIFEdgePortNo));

                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"接続先情報:{viewTableInfo.JobKeyName},IP:" + this.m_strIFEdgeIPAddress + ",ポートNo:" + this.m_nIFEdgePortNo.ToString());


                // 送信データを作成する
                sendData = DataService.GetSendData(m_viewTableInfoList, m_strLocalIPAddress, m_nLocalPortNo, m_nSyncMode, JobKeyName);

                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"Send Data:{viewTableInfo.JobKeyName}:[" + sendData  + "]");

                // 文字列をバイト シーケンスにエンコードする
                byte[] bdata = Encoding.UTF8.GetBytes(sendData);

                // 送信
                clientSocket.Send(bdata);


                // 受信データ
                byte[] cRecvData = new byte[1024];

                // 受信
                int len = clientSocket.Receive(cRecvData);

                // 受信データの文字列化
                string strdata = Encoding.UTF8.GetString(cRecvData, 0, len);
                string errorCode = "";
                string errorMessage = "";
                try
                {
                    var json = JObject.Parse(strdata);
                    errorCode = json["ErrorCode"].ToString();
                    errorMessage = json["ErrorMessage"].ToString();
                }
                catch(Exception)
                {
                    errorCode = "-";
                    errorMessage = "レスポンス解析失敗";
                }


                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"Recv Data:{viewTableInfo.JobKeyName}:[" + strdata + "]");
                if (errorCode != "0000")
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status={errorCode}, message={errorMessage}, result={m_viewTableInfoList[0].KeyName}");
                }

                GetReceivedData(strdata);

                // 切断
                clientSocket.Close();

            }
            catch (Exception ex)
            {
                try
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"{ex.Message}:{ex.StackTrace}");
                    FNSiViewSyncSetting.JobStatusList[viewTableInfo.JobKeyName].ErrorFlag = true;
                    CommonUtil.EndProcessing(viewTableInfo.KeyName, viewTableInfo.JobKeyName);

                    // 通信エラー
                    if (viewTableInfo.Mode == "1")
                    {
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=404, message=\"VIEWアプリ経路エラー\", result={viewTableInfo.KeyName}:{viewTableInfo.FromDate}~{viewTableInfo.ToDate}");
                        return;
                    }
                    SendData sendDataObj = JsonConvert.DeserializeObject<SendData>(sendData);
                    List<string> ids = new List<string>();
                    if (sendData != "")
                    {
                        foreach (ViewTable tbl in sendDataObj.tables)
                        {
                            if (tbl.dataKey.paramList1 != null)
                            {
                                ids.AddRange(tbl.dataKey.paramList1.Split(','));
                            }
                        }
                    }

                    if (ids.Count == 0)
                    {
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=404, message=\"VIEWアプリ経路エラー\", result={viewTableInfo.KeyName}");
                    }
                    else
                    {
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=404, message=\"VIEWアプリ経路エラー\", result={viewTableInfo.KeyName}:{ string.Join(",", ids)}");
                    }
                }
                catch(Exception ex2)
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"{ex2.Message}:{ex2.StackTrace}");
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=500, message=\"VIEWアプリ経路エラー\", result=\"\"");
                }
            }
        }

        #endregion

        #region プライベートメソッド

        /// <summary>
        /// 受信データを解析する
        /// </summary>
        ///// <param name="strdata">受信データ</param>
        private void GetReceivedData(String strdata)
        {
            Dictionary<string, string> tbl = new Dictionary<string, string>();
            string errorCode = "";
            string errorMessage = "";

            // 受信データがJSONか
            if (JSONLib.IsJSONData(strdata))
            {
                // JSON分解
                tbl = JsonConvert.DeserializeObject<Dictionary<string, string>>(strdata);
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
            else
            {
                errorCode = "9999";
                errorMessage = "Incorrect data format.";
            }

            // 異常場合
            if (!"0000".Equals(errorCode))
            {
                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"データ同期:{m_viewTableInfoList[0].JobKeyName}:送信に失敗しました:{errorMessage}:[" + strdata + "]");
            }
        }
        #endregion
    }
}
