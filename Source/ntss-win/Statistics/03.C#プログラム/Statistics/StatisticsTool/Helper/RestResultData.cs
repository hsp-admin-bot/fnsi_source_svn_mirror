using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Helper
{
    /// <summary>
    /// REST-API 発行結果取得用データクラス
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class RestResultData<T>
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 取得結果の取得及び設定を行います。
        /// </summary>
        public Boolean IsSuccess { get; set; } = false;

        /// <summary>
        /// 取得データの取得及び設定を行います。
        /// </summary>
        public T Data { get; set; } = default(T);

        /// <summary>
        /// エラーメッセージの取得及び設定を行います。
        /// </summary>
        public String ErrorText { get; set; } = String.Empty;

        #endregion
    }
}
