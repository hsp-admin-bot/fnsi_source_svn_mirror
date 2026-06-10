
using System.Collections.Generic;

namespace ConvertCommon.parts
{
    public class SimpleConvertValueCaseSqlInfo : ConvertValueInfoBase
    {
        /// <summary>
        /// 列名と対象値と変換値のマップ
        /// </summary>
        private Dictionary<string, string> _simpleConvertValueCaseSqlMap;

        public Dictionary<string, string> SimpleConvertValueCaseSqlMap
        {
            get { return _simpleConvertValueCaseSqlMap; }
            set { _simpleConvertValueCaseSqlMap = value; }
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public SimpleConvertValueCaseSqlInfo()
        {
            this._simpleConvertValueCaseSqlMap = new Dictionary<string, string>();
        }

        /// <summary>
        /// 変換マップに指定したキーと変換のためのCASE文のSQLのマップを追加する
        /// </summary>
        /// <param name="key">キー（列名または列名＋JSON要素のキー名）</param>
        /// <param name="noUseValue">使用しない</param>
        /// <param name="caseSql">CASE文のSQL</param>
        public override void AddConvertValueMap(string key, string noUseValue, string caseSql)
        {
            this.AddConvertValueMap(key, caseSql);
        }

        /// <summary>
        /// 変換マップに指定したキーと変換のためのCASE文のSQLのマップを追加する
        /// </summary>
        /// <param name="key">キー（列名または列名＋JSON要素のキー名）</param>
        /// <param name="caseSql">CASE文のSQL</param>
        private void AddConvertValueMap(string key, string caseSql)
        {
            this._simpleConvertValueCaseSqlMap.Add(key, caseSql);
        }

        /// <summary>
        /// キーを指定してCASE文のSQLを取得する。取得時に置換変数をoldValueに置き換える。
        /// </summary>
        /// <param name="key">キー（列名または列名＋JSON要素のキー名）</param>
        /// <param name="oldValue">置換変数を置き換える値</param>
        /// <returns>CASE文のSQL</returns>
        public override string GetConvertValue(string key, string oldValue)
        {
            return string.Format(this._simpleConvertValueCaseSqlMap[key], oldValue);
        }

        public override string GetConvertValue(string key, string oldValue,
            ConvertCommon.ConvertBase.NtssRecord record,
            List<ConvertCommon.ConvertBase.JsonElement> jsonElementList)
        {
            return string.Format(this._simpleConvertValueCaseSqlMap[key], oldValue);
        }

        public override bool ContainsKey(string key)
        {
            return this._simpleConvertValueCaseSqlMap.ContainsKey(key);
        }

    }
}
