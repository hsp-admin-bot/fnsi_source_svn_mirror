using System;
using System.Collections.Generic;
using System.Text;

namespace NKK.BloodPurify
{
    /// <summary>
    /// プラソートiQ21用 受信データ処理機能クラス
    /// </summary>
    internal class IQ21Data
    {
        /// <summary>
        /// バイト配列をJISでStringに変換
        /// </summary>
        /// <param name="bytes">ESCシーケンスを除いたJIS</param>
        /// <param name="flgKanji">漢字:true 半角:false</param>
        /// <returns></returns>
        public String EncodingByteJIS(byte[] bytes, bool flgKanji)
        {
            byte[] data;
            if (flgKanji)
            {
                data = new byte[bytes.Length + 6];
                byte[] dataHead = new byte[] { 0x1B, 0x24, 0x42 };
                byte[] dataFoot = new byte[] { 0x1B, 0x28, 0x42 };

                Array.Copy(dataHead, data, 3);
                Array.Copy(bytes, 0, data, 3, bytes.Length);
                Array.Copy(dataFoot, 0, data, bytes.Length + 3, 3);
            }
            else
            {
                data = bytes;
            }
            return Encoding.GetEncoding("iso-2022-jp").GetString(data); // JIS
        }

        /// <summary>
        /// バイト配列をSJISでStringに変換
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        public String EncodingByteSJIS(byte[] bytes)
        {
            return Encoding.GetEncoding("Shift_JIS").GetString(bytes); // SJIS
        }

        /// <summary>
        /// バイトをそのまま文字列化 ハイフン除去
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        public String BytesToString(byte[] bytes)
        {
            return BitConverter.ToString(bytes).Replace("-", string.Empty);
        }
    }
}
