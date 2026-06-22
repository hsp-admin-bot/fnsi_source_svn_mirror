using System;
using System.Collections.Generic;
using System.Text;

namespace NKK.BloodPurify
{
    /// <summary>
    /// KM9000用 モニタデータ処理機能クラス
    /// </summary>
    internal class KM9000Data : IKM
    {
        /// <summary>
        /// モニタデータを表示用文字列に変換して返します
        /// </summary>
        /// <param name="col">列番号(0～)</param>
        /// <param name="value">装置から取得したモニタ値</param>
        /// <returns>表示用メッセージ</returns>
        public string ExchangeDispString(int col, string value)
        {
            string sValue = value;
            switch (col)
            {
                case 35: // その他情報用途
                    switch (sValue)
                    {
                        case "1": sValue = "CRRT"; break;
                        case "2": sValue = "ECUM"; break;
                        case "3": sValue = "DF"; break;
                        case "4": sValue = "DFT"; break;
                        case "5": sValue = "PP"; break;
                        case "6": sValue = "PE"; break;
                        case "7": sValue = "DHP"; break;
                        case "8": sValue = "ASCT"; break;
                        case "9": sValue = "TEST"; break;
                    }
                    break;
                case 36: // その他情報工程
                    switch (sValue)
                    {
                        case "1": sValue = "装着"; break;
                        case "2": sValue = "確認"; break;
                        case "3": sValue = "洗浄"; break;
                        case "4": sValue = "臨床"; break;
                        case "5": sValue = "回収"; break;
                    }
                    break;
            }

            return sValue;
        }
    }
}
