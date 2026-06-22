using System;
using System.Collections.Generic;
using System.Text;

namespace ComScaleBed
{
    class DefineParameters
    {
        /// <summary>
        /// 接続確認用の送信データ
        /// </summary>
        public static byte[] SEND_DATA = new byte[] { 0x40 };    // '@'
        /// <summary>
        /// 接続確認用の送信データ桁数
        /// </summary>
        public static int SEND_DATA_LENGTH = 1;
        /// <summary>
        /// 接続確認の送信間隔(ミリ秒)
        /// </summary>
        public static int SEND_DATA_INTERVAL = 30000;
    }
}
