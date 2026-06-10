using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace LayoutDesigner.Data
{

    [Serializable()]
    public class FormatConditionRule
    {

        /// <summary>
        /// 比較演算子 タグ名
        /// </summary>
        private const string FORMAT_COND_COMPARISON_OPE = "comparisonOperator";

        /// <summary>
        /// 比較演算式右辺 タグ名
        /// </summary>
        private const string FORMAT_COND_VALUE = "value";

        /// <summary>
        /// 文字色
        /// </summary>
        private const string enForeColor = "foreColor";

        /// <summary>
        /// 背景色
        /// </summary>
        private const string enBackColor = "backColor";

        /// <summary>
        /// フォント名
        /// </summary>
        private const string enFontName = "fontName";

        /// <summary>
        /// フォントサイズ
        /// </summary>
        private const string enFontSize = "fontSize";

        /// <summary>
        /// フォントスタイル
        /// </summary>
        private const string enFontStyle = "fontStyle";

        /// <summary>
        /// 比較演算子
        /// </summary>
        public string ComparisonOperator;

        /// <summary>
        /// 比較演算 右辺
        /// </summary>
        public string Value;

        /// <summary>
        /// 条件を満たした時に適用するフォント
        /// </summary>
        public System.Drawing.Font Font;

        /// <summary>
        /// CSSクラス名
        /// </summary>
        public string CssClass;

        /// <summary>
        /// 文字色
        /// </summary>
        public Color Color = System.Drawing.Color.Black;

        /// <summary>
        /// 背景色
        /// </summary>
        public Color BackColor = Color.White;

        #region コンストラクタ

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FormatConditionRule() { }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="list">XML文字列</param>
        public FormatConditionRule(XmlNodeList list)
        {
            string fontName = string.Empty;
            float fontSize = 0;
            int style = 0;
            foreach (XmlNode item in list)
            {

                int argb;
                switch (item.Name)
                {
                    case enFontName:
                        fontName = item.InnerText;
                        break;
                    case enFontSize:
                        fontSize = float.Parse(item.InnerText);
                        break;
                    case enFontStyle:
                        int result = 0;
                        if (int.TryParse(item.InnerText, out result))
                        {
                            style = result;
                        }
                        break;
                    case enForeColor:
                        if (int.TryParse(item.InnerText, out argb))
                        {
                            Color = Color.FromArgb(argb);
                        }
                        break;
                    case enBackColor:
                        if (int.TryParse(item.InnerText, out argb))
                        {
                            BackColor = Color.FromArgb(argb);
                        }
                        break;
                    default:
                        break;
                }

            }
            Font = new System.Drawing.Font(fontName, fontSize, (System.Drawing.FontStyle)style);

        }

        #endregion

        /// <summary>
        /// XmlNode を生成します
        /// </summary>
        /// <returns></returns>
        internal XmlNode ToXmlElement()
        {
            XmlElement wRet;
            try
            {
                wRet = new System.Xml.XmlDocument().CreateElement("formatCondition");
                wRet.SetAttribute(FORMAT_COND_COMPARISON_OPE, this.ComparisonOperator);
                wRet.SetAttribute(FORMAT_COND_VALUE, this.Value);

                // 子要素を追加するローカル関数
                void appendChild(string elementName, string innerText)
                {
                    var wChildElement = wRet.OwnerDocument.CreateElement(elementName);
                    wChildElement.InnerText = innerText;
                    wRet.AppendChild(wChildElement);
                }

                appendChild(FormatConditionRule.enFontName, this.Font.Name);
                appendChild(FormatConditionRule.enFontSize, this.Font.Size.ToString());
                appendChild(FormatConditionRule.enFontStyle, ((int)this.Font.Style).ToString());
                appendChild(FormatConditionRule.enForeColor, this.Color.ToArgb().ToString());
                appendChild(FormatConditionRule.enBackColor, this.BackColor.ToArgb().ToString());

            }
            catch
            {
                throw;
            }

            return wRet;
        }

    }
}
