using System;
using System.Collections.Generic;
using System.Text;

namespace NKK.BloodPurify
{
    /// <summary>
    /// KM8900、KM9000 モニタデータ処理機能インタフェース
    /// </summary>
    public interface IKM
    {
        /// <summary>
        /// モニタデータを表示用文字列に変換して返します
        /// </summary>
        /// <param name="col">列番号(0～)</param>
        /// <param name="value">装置から取得したモニタ値</param>
        /// <returns>表示用メッセージ</returns>
        string ExchangeDispString(int col, string value);
    }
}
