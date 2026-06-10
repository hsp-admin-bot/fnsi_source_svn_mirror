using System;
using System.Collections.Generic;
using System.Text;

namespace NKK.BloodPurify
{
    /// <summary>
    /// KM8900用 モニタデータ処理機能クラス
    /// </summary>
    internal class KM8900Data : IKM
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
                case 20: // その他情報アラーム番号
                    switch (sValue)
                    {
                        case "0": sValue = "異常なし"; break;
                        case "2": sValue = "一般アラーム発生中"; break;
                        case "3": sValue = "補液切れアラーム発生中"; break;
                        case "4": sValue = "生食切れアラーム発生中"; break;
                    }
                    break;
                case 22: // その他情報モード(用途)
                    switch (sValue)
                    {
                        case "0": sValue = "情報なし"; break;
                        case "1": sValue = "CHDF"; break;
                        case "2": sValue = "CHD"; break;
                        case "3": sValue = "CHF"; break;
                        case "4": sValue = "PE"; break;
                        case "5": sValue = "PP"; break;
                        case "6": sValue = "DF"; break;
                        case "7": sValue = "手動"; break;
                    }
                    break;
                case 23: // その他情報工程情報
                    switch (sValue)
                    {
                        case "0": sValue = "情報なし"; break;
                        case "1": sValue = "洗浄工程"; break;
                        case "2": sValue = "臨床工程"; break;
                        case "3": sValue = "回収工程"; break;
                        case "4": sValue = "手動工程"; break;
                    }
                    break;
            }

            return sValue;
        }
    }
}
