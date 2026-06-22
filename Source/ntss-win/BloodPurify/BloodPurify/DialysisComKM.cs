using System;
using NKK.FN3.ComServer.Library;

namespace NKK.BloodPurify
{
    public class DialysisComKM : DialysisComNkk
    {
        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="onCommandReceivedHandler">電文受信時イベントハンドラ</param>
        public DialysisComKM(DgtOnCommandRecv onCommandReceivedHandler) : base(onCommandReceivedHandler, null)
        {
            ; // 何もしない
        }

        /// <summary>
        /// 先頭と終端の1バイトを除去する(STX・ETX除去)
        /// </summary>
        /// <param name="BeforeBytes">変換元バッファ</param>
        /// <param name="Data">変換先バッファ</param>
        /// <param name="beforeLen">変換元バッファ長</param>
        /// <returns>変換後バイト数</returns>
        protected override int formatRem(byte[] BeforeBytes, byte[] Data, int beforeLen)
        {
            int count = beforeLen - 2;

            // コピーバイト数が0以下になった場合を考慮
            if (0 < count)
            {
                // 2バイト目から終端の直前までをコピーする
                Buffer.BlockCopy(BeforeBytes, 1, Data, 0, count);
            }
            else
            {
                count = 0;
            }

            return count;
        }
    }
}
