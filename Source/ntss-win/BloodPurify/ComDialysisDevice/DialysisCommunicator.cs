///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：透析装置からの受信データ処理クラス
// ファイル名 ：DialysisCommunicator.cs
// 説明       ：透析装置からの受信データ処理クラス
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved
//
// 更新履歴
//	日付		担当				理由
//	2008/10/08	伊東 昌洋			新規作成
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using NKK.FN3.Common.Library.TcpSocket;

namespace NKK.FN3.ComServer.Library
{

    /// <summary>
    /// 透析装置からの受信データ処理クラス
    /// </summary>
    public abstract class DialysisCommunicator
    {

        #region インスタンス変数

        /// <summary>
        /// 受信バッファ
        /// </summary>
        private ReceiveDataBuffer receiveBuffer = new ReceiveDataBuffer();

        //protected ReceiveDataBuffer ReceiveBuffer
        //{
        //    get { return receiveBuffer; }
        //    set { receiveBuffer = value; }
        //}

        /// <summary>
        /// 受信バッファ
        /// </summary>
        protected ReceiveDataBuffer ReceiveBuffer
        {
            get { return receiveBuffer; }
            set { receiveBuffer = value; }
        }

        #endregion

        /// <summary>
        /// ソケット受信データを処理するデリゲート
        /// </summary>
        /// <param name="sender">BaseSccketインスタンス</param>
        /// <param name="data">受信データ</param>
        /// <param name="size">受信データ長(バイト数)</param>
// <<<<< CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加
        //public delegate void DgtOnCommandRecv(BaseSocket sender, byte[] data, int size);
        public delegate void DgtOnCommandRecv(BaseSocket sender, byte[] data, int size,string strlogfile);
// <<<<< CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加

        /// <summary>
        /// 送信コマンドを作成する
        /// </summary>
        /// <param name="data">送信したいデータ</param>
        /// <param name="size">パラメータに指定したdata配列のバイト長</param>
        /// <returns>送信コマンド配列</returns>
        public abstract byte[] GetSendCommand(byte[] data, int size);
        //public abstract int SendData(BaseSocket sender, byte[] data, int size);

        /// <summary>
        /// ソケット受信が完了したことを通知するデリゲート
        /// </summary>
        /// <param name="sender">BaseSccketインスタンス</param>
        public delegate void DgtOnCompleteRecv(BaseSocket sender);

        /// <summary>
        /// ソケット受信データを処理するデリゲート
        /// </summary>
        /// <param name="data">受信データ</param>
        /// <param name="size">受信データ長(バイト数)</param>
        public delegate void DgtOnCommandRecvJmed(byte[] data, int size);

    }

}
