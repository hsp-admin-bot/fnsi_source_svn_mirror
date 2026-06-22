///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：ソケットクラス
// ファイル名 ：ComSocket.cs
// 説明       ：通信サーバシステムで使用するソケットクラス
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved
//
// 更新履歴
//	日付		担当				理由
//	2008/10/07	伊東 昌洋			新規作成
//
///////////////////////////////////////////////////////////////////////////////
using System.Net.Sockets;
using NKK.FN3.Common.Library.TcpSocket;

namespace NKK.FN3.ComServer.Library
{
    /// <summary>
    /// 通信サーバシステムで使用するソケットクラス。BaseSocketクラスから派生しています。
    /// </summary>
    public class ComSocket : BaseSocket
    {
        /// <summary>
        /// ComSocketクラスのコンストラクタ
        /// </summary>
        /// <param name="sock">TcpClient型のソケットオブジェクト。ソケットは接続が確立している事（※必須）。</param>
        /// <param name="mngHandler">例外発生時に接続処理を行う、BaseConnectクラス（又はその継承クラス）のインスタンス</param>
        /// <param name="devInfo">ソケットの接続先の装置情報</param>
        public ComSocket(TcpClient sock, dgtOnException_Mng mngHandler, DeviceInformation devInfo) : base(sock, mngHandler, devInfo)
        { 
        }

        /// <summary>
        /// ComSocketクラスのコンストラクタ
        /// </summary>
        /// <param name="sock">TcpClient型のソケットオブジェクト。ソケットは接続が確立している事（※必須）。</param>
        public ComSocket(TcpClient sock) : base(sock)
        {
        }

        // データ受信時に呼び出すコールバック関数を指定します
        //protected new BaseSocket.dgtOnReceived ReceiveHandler
        //{
        //    set { base.ReceiveHandler = value; }
        //}
    
    }
}
