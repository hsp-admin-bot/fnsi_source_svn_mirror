
using System.Collections.Generic;


namespace ConvertCommon.parts
{
    public class SimpleConvertValueDirectInfo : ConvertValueInfoBase
    {
        /// <summary>
        /// 列名と対象値と変換値のマップ
        /// </summary>
        protected Dictionary<string, Dictionary<string, string>> _simpleConvertValueDirectMap;

        public Dictionary<string, Dictionary<string, string>> SimpleConvertValueDirectMap
        {
          get { return _simpleConvertValueDirectMap; }
          set { _simpleConvertValueDirectMap = value; }
        }

        protected const string DEFAULT = "default";
        protected const string NULL = "null";

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public SimpleConvertValueDirectInfo()
        {
            this._simpleConvertValueDirectMap = new Dictionary<string, Dictionary<string, string>>();
        }

        /// <summary>
        /// 変換マップに指定したキーと対象値と変換値のマップを追加する
        /// </summary>
        /// <param name="key">キー（列名または列名＋JSON要素のキー名）</param>
        /// <param name="oldValue">対象値</param>
        /// <param name="newValue">変換値</param>
        public override void AddConvertValueMap(string key, string oldValue, string newValue)
        {
            if (!_simpleConvertValueDirectMap.ContainsKey(key))
            {
                // マップにキーが存在しない場合追加し、デフォルト値はnullの文字列を設定
                _simpleConvertValueDirectMap.Add(key, new Dictionary<string, string>() { { DEFAULT, NULL } });
            }

            if (string.IsNullOrEmpty(oldValue))
            {
                // 対象値が無い場合、デフォルト値として設定する
                _simpleConvertValueDirectMap[key][DEFAULT] = newValue;
            }else{
                _simpleConvertValueDirectMap[key].Add(oldValue, newValue);
            }
        }

        /// <summary>
        /// キーと対象値を指定して変換値を取得する
        /// </summary>
        /// <param name="key">キー（列名または列名＋JSON要素のキー名）</param>
        /// <param name="oldValue">対象値</param>
        /// <returns>変換値またはデフォルト値</returns>
        public override string GetConvertValue(string key, string oldValue)
        {

            if (_simpleConvertValueDirectMap.ContainsKey(key))
            {
                // 値変換のマップを取得
                Dictionary<string, string> oldValueToNewValueMap = _simpleConvertValueDirectMap[key];
                if (oldValueToNewValueMap.ContainsKey(oldValue))
                {
                    // 対象値が存在する場合、対応する変換値を返す
                    return oldValueToNewValueMap[oldValue];
                }
                else
                {
                    // 対象値が存在しない場合、デフォルト値を返す
                    return oldValueToNewValueMap[DEFAULT];
                }
                
            }else{
                // 列名が存在しない場合は対象値をそのまま返す
                return oldValue;
                /*
                throw new Exception("変換マップにキー=" + key + ",値:" + oldValue + " の情報が存在しません。" + Environment.NewLine +
                                "変換テーブルのデータを確認してください。");
                 */
            }
        }

        public override string GetConvertValue(string key, string oldValue,
            ConvertCommon.ConvertBase.NtssRecord record,
            List<ConvertCommon.ConvertBase.JsonElement> jsonElementList)
        {
            return GetConvertValue(key, oldValue);
        }

        public override bool ContainsKey(string key)
        {
            return this._simpleConvertValueDirectMap.ContainsKey(key);
        }
    }
}
