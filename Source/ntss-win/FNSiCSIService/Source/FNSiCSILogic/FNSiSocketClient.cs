using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using TdcLib;

namespace FNSiCSILogicLib
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
        /// IFエッジサービスのIP
        /// </summary>
        private String m_strIFEdgeIPAddress = String.Empty;

        /// <summary>
        /// IFエッジサービスのポートNo
        /// </summary>
        private int m_nIFEdgePortNo = 0;

        /// <summary>
        /// UpdateXml
        /// </summary>
        private String m_strUpdateXml = String.Empty;

        #endregion

        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FNSiSocketClient()
        {
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
        public String ToUpdateXml
        {
            get { return this.m_strUpdateXml; }
            set { this.m_strUpdateXml = value; }
        }

        /// <summary>
        /// 実行モード
        /// </summary>
        public enum START_MODE
        {
            INIT = 0,
            START,
            MODE1,
            MODE2
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
                clientSocket.Connect(new IPEndPoint(IPAddress.Parse(this.m_strIFEdgeIPAddress), this.m_nIFEdgePortNo));

                // 送信データを作成する
                String sendData = GetSendData();

                String head = String.Format("{0:D6}OK", Encoding.Default.GetBytes(sendData).Length + 8);

                // 文字列をバイト シーケンスにエンコードする
                byte[] bdata = Encoding.Default.GetBytes(head + sendData);

                // 送信
                clientSocket.Send(bdata);

                //// 受信データ
                //byte[] cRecvData = new byte[1024];

                //// 受信
                //int len = clientSocket.Receive(cRecvData);

                //// 受信データの文字列化
                //string strdata = Encoding.Default.GetString(cRecvData, 0, len);

                //GetReceivedData(strdata);

                // 切断
                clientSocket.Close();
            }
            catch(Exception ex)
            {
                if (clientSocket != null && clientSocket.Connected)
                {
                    clientSocket.Close();
                }

                this.Error = ex;
            }
        }

        #endregion

        #region プライベートメソッド

        /// <summary>
        /// 送信データを作成する
        /// </summary>
        private String GetSendData()
        {
            // 送信データ
            StringBuilder sendData = new StringBuilder();

            sendData.Append("{");

            // 条件
            String updateXml = String.Format("\"Dump\":\"{0}\"}}"
                    , JSONLib.ConvertJSONString(this.m_strUpdateXml)
                    );
            sendData.Append(updateXml);

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
                tbl = JSONLib.JSONtoData(strdata);

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
            }
        }

        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
        private Exception Error
        {
            get { return (this.m_Exception); }
            set
            {
                m_Exception = value;

                if (value != null)
                {
                    // 履歴作成
                    DateTime dtlog = DateTime.Now;
                    String strlogdata = String.Format("{0}, {1}", this.GetType().Name, value.ToString().Replace("\r\n", "{CRLF}"));
                }
            }
        }
        #endregion
    }
}
