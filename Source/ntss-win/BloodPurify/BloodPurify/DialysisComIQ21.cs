using System;
using System.Collections.Generic;
using NKK.FN3.ComServer.Library;
using NKK.FN3.Common.Library.TcpSocket;

namespace NKK.BloodPurify
{
    class DialysisComIQ21 : DialysisCommunicator
    {
        /// <summary>
        /// モニタデータ受信を処理するデリゲート宣言
        /// </summary>
        private event DgtOnCommandRecvJmed onCommandReceived;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="onCommandReceivedHandler">電文受信時イベントハンドラ</param>
        public DialysisComIQ21(DgtOnCommandRecvJmed onCommandReceivedHandler)
        {
            // 指定されたコールバック関数を内部変数に保持する
            onCommandReceived = onCommandReceivedHandler;
        }

        /// <summary>
        /// ソケット受信コールバック関数
        /// </summary>
        /// <param name="sender">BaseSocketのインスタンス</param>
        public void OnRecv(BaseSocket sender)
        {
            // ソケットデータ受信時の処理を実装する
            if (null == sender)
            {
                throw new ArgumentNullException("sender");
            }
            else
            {
                ReceiveStream rs;

                // 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
                rs = sender.GetReceiveData();
                while (null != rs)
                {
                    CallOnCommandReceived(sender, rs);
                    rs = sender.GetReceiveData();
                }
            }
        }

        /// <summary>
        /// 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
        /// </summary>
        /// <param name="rs">受信データ</param>
        public void CallOnCommandReceived(BaseSocket sender, ReceiveStream rs)
        {
            lock (ReceiveBuffer)
            {
                // 受信したデータをバッファに追加する
                ReceiveBuffer.Add(rs);
                int bufferSize = ReceiveBuffer.Size;

                // 受信データを解析する
                byte[] rcvBytes;

                // 受信データを取得する
                rcvBytes = ReceiveBuffer.GetBuffer();

                int count;
                byte[] data;
                int index = 0;

                List<byte> byteData = new List<byte>();

                while (index < bufferSize)
                {
                    switch (rcvBytes[index])
                    {
                        case 0x05:
                            // ENQ(0x05)が見つかる

                            // 返送
                            sender.SendData(new byte[] { 0x20 }, 1);
                            // ENQ以外に受信済みのデータが存在しないため、受信バッファを削除する
                            ReceiveBuffer.RemoveHead(bufferSize);
                            index = bufferSize;
                            break;
                        case 0x0A:
                            // LFきたらそこまでで１回確認

                            byteData.Add(rcvBytes[index]);
                            count = byteData.Count;

                            // 末尾ならばこれで１区画
                            if (count > 2 && byteData[count - 2] == 0x4A && byteData[count - 3] == 0x1B)
                            {
                                data = new byte[count + 256];
                                byteData.CopyTo(data);

                                // 受信イベントを生成
                                onCommandReceived(data, count);

                                // 受信バッファから削除する
                                ReceiveBuffer.RemoveHead(count);

                                byteData.Clear();
                            }
                            break;
                        default:
                            // 文節の途中ならば・・・
                            byteData.Add(rcvBytes[index]);
                            break;
                    }

                    index += 1;
                }
            }
        }

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
            Buffer.BlockCopy(AfterBuf, 0, SendCommand, 0, Size);

            return SendCommand;
        }
    }
}
