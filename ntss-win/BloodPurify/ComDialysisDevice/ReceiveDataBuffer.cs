///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：通信サーバー新装置通信
// ファイル名 ：ComDiaSv.cs
// 説明       ：通信サーバーで透析装置と接続する
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

    //public abstract class ComDialysisDevice : IComDialysisDevice
    //{

    //    #region インスタンス変数

    //    private ComSocket m_sock;

    //    private bool isWaitingResponse = false;

    //    protected bool IsWaitingResponse
    //    {
    //        get { return isWaitingResponse; }
    //        set { isWaitingResponse = value; }
    //    }

    //    private string deviceModelCode;

    //    protected string DeviceModelCode
    //    {
    //        get { return this.deviceModelCode; }
    //        set { this.deviceModelCode = value; }
    //    }

    //    private string deviceSerial;

    //    protected string DeviceSerial
    //    {
    //        get { return this.deviceSerial; }
    //        set { this.deviceSerial = value; }
    //    }

    //    private int sta_bak = 0;

    //    protected int StatusBak
    //    {
    //        get { return this.sta_bak; }
    //        set { this.sta_bak = value; }
    //    }

    //    #endregion

    //    #region IComDialysisDevice メンバ

    //    public abstract void OnRecv(BaseSocket sender);

    //    public ComSocket Socket
    //    {
    //        get { return this.m_sock; }
    //        set { this.m_sock = (ComSocket)value; }
    //    }

    //    public abstract int SendDialysisCond();

    //    #endregion

    //}

    /// <summary>
    /// 受信データバッファ保持クラス
    /// </summary>
    public class ReceiveDataBuffer
    {

        #region インスタンス変数

        /// <summary>
        /// 受信データバッファ(Byte配列)
        /// </summary>
        private byte[] buffer;

        //public byte[] Buffer
        //{
        //    get { return (byte[])buffer.Clone(); }
        //    set { buffer = value; }
        //}

        /// <summary>
        /// 受信バッファ長
        /// </summary>
        private int size;

        public int Size
        {
            get { return size; }
            set { size = value; }
        }

        #endregion

        /// <summary>
        /// 受信バッファに受信データを追加する
        /// </summary>
        /// <param name="rs">受信データ</param>
        public void Add(ReceiveStream rs)
        {
            // 受信データをBuffer配列に追加する

            // 受信データ長を取得する
            int rcvSize = rs.rcvSize;

            int i;
            //byte rcvByte;
            byte[] DataBuffers = new byte[this.size + rcvSize];

            // 既に保持しているデータを新規領域にコピーする
            for (i = 0; i < this.size; i++)
            {
                DataBuffers[i] = this.buffer[i];
            }

            // 今回受信したデータを受信バッファに結合する
            for (i = 0; i < rcvSize; i++)
            {
                DataBuffers[this.size + i] = rs.rcvData[i];
            }

            // 今回の追加を反映させたBYTE配列をセットする
            this.buffer = DataBuffers;
            this.Size += rcvSize;

        }

        /// <summary>
        /// 保持しているByte配列を返す
        /// </summary>
        /// <returns></returns>
        public byte[] GetBuffer()
        {
            // バッファを返す
            return this.buffer;
        }

        /// <summary>
        /// 指定されたバイト数を内部保持バッファの先頭から除去する
        /// </summary>
        /// <param name="removeLength">先頭から除去するバイト数</param>
        public void RemoveHead(int removeLength)
        {

            // 指定されたバイト数を内部保持バッファの先頭から除去する
            int Length = this.Size - removeLength;
            byte[] LeaveBuffer = new byte[Length];
            for (int i = 0; i < Length; i++)
            {
                LeaveBuffer[i] = this.buffer[removeLength + i];
            }

            // 新しく生成したByte配列をセットする
            this.size = Length;
            this.buffer = LeaveBuffer;

        }

    }

}
