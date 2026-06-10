using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace LayoutDesigner.Data
{
    /// <summary>
    /// 条件付き書式ルール
    /// </summary>
    public class FormatConditionRules : List<FormatConditionRule> {

        /// <summary>
        /// XmlElement を取得します
        /// </summary>
        /// <returns>XmlElement</returns>
        private XmlElement ToXmlElement()
        {
            if (this.Count <= 0)
            {
                return null;
            }

            System.Xml.XmlElement wRet = null;
            System.Xml.XmlDocument wDoc = null;

            try
            {
                wDoc = new System.Xml.XmlDocument();

                wRet = wDoc.CreateElement("rules");
                this.ForEach(ele => wRet.AppendChild(wDoc.ImportNode(ele.ToXmlElement(), true)));
            }
            catch
            {
                throw;
            }

            return wRet;
        }

        /// <summary>
        /// XmlElement を文字列で取得します。
        /// </summary>
        /// <returns>XmlElement を文字列</returns>
        public string ToXmlElementText()
        {
            return this.ToXmlElement()?.OuterXml;
        }

        /// <summary>
        /// 指定した XmlNode を対応する 変換リストに変換し、変換に成功したかどうかを示す値を返します。
        /// </summary>
        /// <param name="element"></param>
        /// <param name="result"></param>
        /// <returns></returns>
        public static bool TryParse(XmlElement element, out FormatConditionRules result)
        {

            bool wRet = false;

            // 戻り値生成
            result = new FormatConditionRules();

            try
            {

                foreach (XmlNode item in element.ChildNodes)
                {

                    // 条件付き書式ルールのインスタンスを生成
                    var rule = new FormatConditionRule(item.ChildNodes)
                    {
                        ComparisonOperator = item.Attributes["comparisonOperator"].Value,
                        Value = item.Attributes["value"].Value
                    };
                    result.Add(rule);

                }

                wRet = true;

            }
            catch
            {
            }

            return wRet;

        }
    }
}
