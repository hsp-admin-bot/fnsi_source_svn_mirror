
using System.Collections.Generic;
using System.Linq;

namespace ConvertCommon.parts
{
    public class SimpleConvertValueHasDecisionItem : SimpleConvertValueDirectInfo
    {

        /// <summary>
        /// 変換処理対象列と判定対象列のマップ
        /// </summary>
        protected Dictionary<string, string> _itemNameToColumnNameMap;

        public Dictionary<string, string> ItemNameToColumnNameMap
        {
            get { return _itemNameToColumnNameMap; }
            set { _itemNameToColumnNameMap = value; }
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public SimpleConvertValueHasDecisionItem(Dictionary<string, string> itemNameToColumnNameMap)
        {
            this._simpleConvertValueDirectMap = new Dictionary<string, Dictionary<string, string>>();
            this._itemNameToColumnNameMap = itemNameToColumnNameMap;
        }

        /// <summary>
        /// キーを指定して変換値を取得する
        /// </summary>
        /// <param name="key"></param>
        /// <param name="record"></param>
        /// <param name="jsonElementList"></param>
        /// <returns></returns>
        public override string GetConvertValue(string key,string oldValue,
            ConvertCommon.ConvertBase.NtssRecord record,
            List<ConvertCommon.ConvertBase.JsonElement> jsonElementList)
        {
            // 移行元の値がNullの場合、値変換をせずNullを返すように処理する
            if (("null".Equals(oldValue) || "".Equals(oldValue)) && !key.Equals("ind_cond_infovalue_name_1"))
            {
                return "null";
            }

            // 判定対象の列を取得する
            string convertedValue;
            if (this._itemNameToColumnNameMap.ContainsKey(key))
            {
                string decisionTargetColumnName = this._itemNameToColumnNameMap[key].ToString();

                // 項目名（列名またはJSON要素名）で１レコード＋JSONリストを検索し、値を取得する
                string decisionTargetValue = this.SearchValueFromRecordByItemName(decisionTargetColumnName,
                    record,
                    jsonElementList);

                // 判断値がNullの場合、値変換をせずNullを返すように処理する
                if ("null".Equals(decisionTargetValue) || "".Equals(decisionTargetValue))
                {
                    return "null";
                }

                // キーと対象値を指定して変換値を取得する
                convertedValue = this.GetConvertValue(key, decisionTargetValue);
            }
            else
            {
                // 判定対象の列が存在しない場合、処理対象列を判定対象列とみなす
                convertedValue = this.GetConvertValue(key, oldValue);
            }

            return convertedValue;
        }

        /// <summary>
        /// 項目名（列名またはJSON要素名）で１レコード＋JSONリストを検索し、
        /// 値を取得する
        /// </summary>
        /// <param name="itemName">列名またはJSON項目名</param>
        /// <param name="ntssRecord">１レコード</param>
        /// <param name="jsonElementList">JSONリスト</param>
        /// <returns></returns>
        private string SearchValueFromRecordByItemName(string itemName,
            ConvertCommon.ConvertBase.NtssRecord ntssRecord,
            List<ConvertCommon.ConvertBase.JsonElement> jsonElementList)
        {
            string decisionTargetValue;

            // １レコードまたはJSONリストの中から変換対象の値を取得する
            if (jsonElementList == null)
            {
                decisionTargetValue = ntssRecord.columns.Where(col => col.name.Equals(itemName)).First().value.ToString();
            }
            else
            {
                decisionTargetValue = jsonElementList.Where(je => je.getKeyNameDeleteEscape().ToString().Equals(itemName)).First().value.ToString();
            }

            return decisionTargetValue;
        }

    }
}
