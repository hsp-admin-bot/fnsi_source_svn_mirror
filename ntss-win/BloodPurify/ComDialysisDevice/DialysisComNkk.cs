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

    /// <summary>
    /// 日機装透析装置からの受信データ処理クラス
    /// </summary>
    public class DialysisComNkk : DialysisCommunicator
    {

        /// <summary>
        /// コマンド受信を処理するデリゲート
        /// </summary>
        private event DgtOnCommandRecv OnCommandReceived;

        /// <summary>
        /// 
        /// </summary>
        private event DgtOnCompleteRecv onCompleteReceiveHandler;

        /// <summary>
        /// 医器工コマンド受信を処理するデリゲート宣言
        /// </summary>
        private event DgtOnCommandRecvJmed OnCommandReceivedJmed;

        #region コンストラクタ

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="onCommandReceivedHandler">電文受信時イベントハンドラ</param>
        /// <param name="onCompleteReceivedHandler">全データ受信完了イベントハンドラ</param>
        public DialysisComNkk(DgtOnCommandRecv onCommandReceivedHandler, DgtOnCompleteRecv onCompleteReceivedHandler)
        {

            // 指定されたコールバック関数を内部変数に保持する
            this.OnCommandReceived = onCommandReceivedHandler;
            this.onCompleteReceiveHandler = onCompleteReceivedHandler;

        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="onCommandReceivedHandler">電文受信時イベントハンドラ</param>
        /// <param name="onCompleteReceivedHandler">全データ受信完了イベントハンドラ</param>
        public DialysisComNkk(DgtOnCommandRecvJmed onCommandReceivedHandler, DgtOnCompleteRecv onCompleteReceivedHandler)
        {

            // 指定されたコールバック関数を内部変数に保持する
            this.OnCommandReceivedJmed = onCommandReceivedHandler;
            this.onCompleteReceiveHandler = onCompleteReceivedHandler;

        }

        #endregion

        /// <summary>
        /// ソケット受信コールバック関数
        /// </summary>
        /// <param name="sender">BaseSocketのインスタンス</param>
// <<<<< CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加
        //public void OnRecv(BaseSocket sender)
        public void OnRecv(BaseSocket sender,string strlogfile)
// >>>>> CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加
        {

            // ソケットデータ受信時の処理を実装する
            if (null == sender)
            {
                throw new ArgumentNullException("sender");
            }
            else
            {

                // 今回受信したデータを受信バッファに結合する
                //this.ReceiveBuffer.Add(sender.GetReceiveData());
                ReceiveStream rs;

                // 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
                rs = sender.GetReceiveData();
                while (null != rs)
                {
// <<<<< CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加
                    //CallOnCommandReceived(sender, rs);
                    CallOnCommandReceived(sender, rs,strlogfile);
// >>>>> CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加
                    rs = sender.GetReceiveData();
                }

            }

        }

        // <<<<< ADD Y.Takamura 2009/06/10 医器工対応に伴い新規追加
        /// <summary>
        /// ソケット受信コールバック関数（医器工）
        /// </summary>
        /// <param name="sender">BaseSocketのインスタンス</param>
        public void OnRecvJmed(BaseSocket sender)
        {
            FN3TSlib.TextWriter("JMED_RECV.txt", true, "OnRecvJMED");

            // ソケットデータ受信時の処理を実装する
            if (null == sender)
            {
                throw new ArgumentNullException("sender");
            }
            else
            {

                // 今回受信したデータを受信バッファに結合する
                //this.ReceiveBuffer.Add(sender.GetReceiveData());
                ReceiveStream rs;

                // 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
                rs = sender.GetReceiveData();
                while (null != rs)
                {
                    CallOnCommandReceivedJmed(rs);
                    rs = sender.GetReceiveData();
                }

            }

        }
        // >>>>> ADD Y.Takamura 2009/06/10 医器工対応に伴い新規追加

        /// <summary>
        /// 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
        /// </summary>
        /// <param name="sender">BaseSocketインスタンス</param>
        /// <param name="rs">受信データ</param>
        /// <param name="strlogfile">Stepログ用ファイル名</param>
        public void CallOnCommandReceived(BaseSocket sender, ReceiveStream rs, string strlogfile)
        {
            // <<<<< CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加
            //public void CallOnCommandReceived(BaseSocket sender, ReceiveStream rs)
            // >>>>> CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加

            const int STX = 0x02;
            const int ETX = 0x03;

            lock (ReceiveBuffer)
            {

                // 受信したデータをバッファに追加する
                this.ReceiveBuffer.Add(rs);
                int BufferSize = this.ReceiveBuffer.Size;

                // 受信データを解析する
                int i;
                byte rcvByte;
                int intSTXPos = -1;
                int intETXPos = -1;
                byte[] RcvBytes;
                int searchStartPos = 0;

                // 受信データを取得する
                RcvBytes = this.ReceiveBuffer.GetBuffer();

                for (i = 0; i < BufferSize; i++)
                {
                    rcvByte = RcvBytes[i];

                    if (STX == rcvByte)
                    {
                        intSTXPos = i;
                    }
                    else if (ETX == rcvByte)
                    {
                        intETXPos = i;

                        // 受信バッファから取り出したバイト数分を削除する
                        this.ReceiveBuffer.RemoveHead(intETXPos - searchStartPos + 1);
                        searchStartPos = i + 1;

                        if (0 <= intSTXPos)
                        {
                            // intSTXPos = ヘッダ
                            // (intSTXPos + 1) = 装置の型式(通信フォーマット)
                            // (intSTXPos + 2) ～ (intSTXPos + 8) = 装置の識別番号
                            // (intSTXPos + 9) = シーケンシャルNo
                            // (intSTXPos + 10) = コマンドコード
                            // (intSTXPos + 11) = 装置ステータス
                            // (intSTXPos + 12) = 終了コード
                            // (intSTXPos + 13) ～ (i - 2) = コマンドデータ
                            // (i - 1) = CRC
                            // i = ETX

                            // データがそろった時点で受信コマンド処理用のイベントを発生させる
                            //byte[] data = new byte[i - intSTXPos - 2];
                            //for (int j = 0; j < (i - intSTXPos - 2); j++)
                            //{
                            //    data[j] = RcvBytes[intSTXPos + j + 1];
                            //}

                            // BeforeBytes配列にコピーする
                            byte[] BeforeBytes = new byte[4096];
                            Buffer.BlockCopy(RcvBytes, intSTXPos, BeforeBytes, 0, i - intSTXPos + 1);

                            // 制御コードを除いた受信データをdata配列に格納する
                            byte[] Data = new byte[4048];
                            int Size = formatRem(BeforeBytes, Data, i - intSTXPos + 1);

                            // 受信イベントを生成する
                            //CommandRecvEventArgs e = new CommandRecvEventArgs();
                            //e.Data = data;
                            //e.Size = Size;
// <<<<< CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加
                            //this.OnCommandReceived(sender, Data, Size);
                            this.OnCommandReceived(sender, Data, Size, strlogfile);
// >>>>> CHG H.Yonezawa 2009/08/10 引数にStepログ用ファイル名追加

                        }

                        intSTXPos = -1;

                    }

                }

                if (ETX == RcvBytes[BufferSize - 1])
                {
                    // 受信データの最後がEXTならば全ての受信データを処理できた
                    this.ReceiveBuffer.Size = 0;

                    if (null != this.onCompleteReceiveHandler)
                    {
                        this.onCompleteReceiveHandler(sender);
                    }
                    
                }
                //else if (0 <= intETXPos)
                //{
                //    // 受信データの最後がEXTで終了していなく、かつ受信コマンドに伴う処理を行っていれば
                //    // 受信バッファ中の一部を処理できた。その分、シフトする。
                //    this.ReceiveBuffer.RemoveHead(intETXPos + 1);
                //}

            }
            
        }

        /// <summary>
        /// STX・ETX変換、STX・CRC・ETX除去
        /// </summary>
        /// <param name="BeforeBytes">変換元バッファ</param>
        /// <param name="Data">変換先バッファ</param>
        /// <param name="beforeLen">変換元バッファ長</param>
        /// <returns>変換データ長(バイト)。先頭がSTXでない場合 -1。末尾がETXでない場合 -2。CRCエラーの場合 -3。</returns>
        protected virtual int formatRem(byte[] BeforeBytes, byte[] Data, int beforeLen)
        {

            int Size = FN3TSlib.FormatRem(BeforeBytes, beforeLen, Data);
            return Size;
        }

        // <<<<< ADD Y.Takamura 2009/06/10 医器工対応に伴い新規追加
        /// <summary>
        /// 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す（医器工）
        /// </summary>
        /// 
        /// <param name="rs">受信データ</param>
        public virtual void CallOnCommandReceivedJmed(ReceiveStream rs)
        {
            const int STX1 = 0x4b;	// 'K'
            const int STX2 = 0x53;	// 'S'
            const int STX3 = 0x52;	// 'R'
            const int STX4 = 0x45;	// 'E'
            const int VER2 = 0x32;	// '2'
            const int VER3 = 0x33;	// '3'
            const int ETX1 = 0x0D;	// CR
            const int ETX2 = 0x0A;	// LF

            FN3TSlib.TextWriter("JMED_RECV.txt", true, "CallOnCommandReceivedJMED");

            lock (ReceiveBuffer)
            {

                // 受信したデータをバッファに追加する
                this.ReceiveBuffer.Add(rs);
                int BufferSize = this.ReceiveBuffer.Size;

                // 受信データを解析する
                int i;
                byte rcvByte;
                int intCMD = 0;
                int intSTXFlg = 0;
                int intETXFlg = 0;
                int intSTXPos = -1;
                int intETXPos = -1;
                byte[] RcvBytes;
                int searchStartPos = 0;

                // 受信データを取得する
                RcvBytes = this.ReceiveBuffer.GetBuffer();

                for (i = 0; i < BufferSize; i++)
                {
                    rcvByte = RcvBytes[i];

                    if (intSTXFlg == 1)
                    {
                        FN3TSlib.TextWriter("JMED_RECV.txt", true, "STX-2");

                        intSTXFlg = 0;
                        if (intCMD == STX1 && (VER2 == rcvByte || VER3 == rcvByte))
                        {
                            FN3TSlib.TextWriter("JMED_RECV.txt", true, "STX-K OK");

                            intSTXPos = i - 1;
                            continue;
                        }
                        else if ((intCMD == STX2 || intCMD == STX3 || intCMD == STX4) && VER3 == rcvByte)
                        {
                            FN3TSlib.TextWriter("JMED_RECV.txt", true, "STX-S OK");

                            intSTXPos = i - 1;
                            continue;
                        }
                        else
                        {
                            FN3TSlib.TextWriter("JMED_RECV.txt", true, "STX ERROR");

                            intCMD = 0;
                            intSTXPos = -1;
                        }
                    }
                    else if (intETXFlg == 1)
                    {
                        intETXPos = -1;
                        if (ETX2 == rcvByte)
                        {
                            FN3TSlib.TextWriter("JMED_RECV.txt", true, "ETX-2");

                            intETXPos = i - 1;

                            // 受信バッファから削除する
                            this.ReceiveBuffer.RemoveHead(intETXPos - searchStartPos + 1);
                            searchStartPos = i + 1;

                            if (0 <= intSTXPos)
                            {
                                // 受信データをdata配列に格納する
                                byte[] Data = new byte[4048];
                                int Size = i - intSTXPos + 1;
                                Buffer.BlockCopy(RcvBytes, intSTXPos, Data, 0, Size);

                                FN3TSlib.TextWriter("JMED_RECV.txt", true, "ETX OK");
                                // 受信イベントを生成する
                                // <<<<< CHG M.Ito 2011/04/11 デリゲート宣言変更
                                //this.OnCommandReceived(sender, Data, Size, "");
                                this.OnCommandReceivedJmed(Data, Size);
                                // >>>>> CHG M.Ito 2011/04/11 デリゲート宣言変更

                            }

                            intCMD = 0;
                            intSTXFlg = 0;
                            intETXFlg = 0;
                            intSTXPos = -1;
                            intETXPos = -1;
                            continue;
                        }
                        else
                        {
                            intETXFlg = 0;
                            intETXPos = -1;
                        }
                    }

                    if (intSTXFlg == 0 && intSTXPos < 0 && (STX1 == rcvByte || STX2 == rcvByte || STX3 == rcvByte || STX4 == rcvByte))
                    {
                        FN3TSlib.TextWriter("JMED_RECV.txt", true, "STX-1");

                        intCMD = rcvByte;
                        intSTXFlg = 1;
                        intSTXPos = -1;
                    }
                    else if (intETXFlg == 0 && ETX1 == rcvByte)
                    {
                        FN3TSlib.TextWriter("JMED_RECV.txt", true, "ETX-1");

                        intETXFlg = 1;
                        intETXPos = -1;
                    }
                }
            }

        }
        // >>>>> ADD Y.Takamura 2009/06/10 医器工対応に伴い新規追加

        //public override int SendData(BaseSocket sender, byte[] data, int size)
        //{
        //    byte[] AfterBuf = new byte[size];

        //    // STX、CRC、ETXを付加してデータを送信する
        //    int Size = FN3TSlib.FormatAdd(data, size, AfterBuf);
        //    return sender.SendData(data, Size);

        //}

        /// <summary>
        /// 送信コマンドを作成する
        /// </summary>
        /// <param name="data">コマンド</param>
        /// <param name="size">コマンド長</param>
        /// <returns>送信コマンド</returns>
        public override byte[] GetSendCommand(byte[] data, int size)
        {

            byte[] AfterBuf = new byte[4096];

            // STX、CRC、ETXを付加してデータを送信する
            int Size = FN3TSlib.FormatAdd(data, size, AfterBuf);

            // 作成した送信コマンドを戻り値用バッファにコピーする
            byte[] SendCommand = new byte[Size];
            System.Buffer.BlockCopy(AfterBuf, 0, SendCommand, 0, Size);

            return SendCommand;

        }

    }

}
