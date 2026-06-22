using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Xml;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用 XML 関連クラス拡張メソッド
    /// </summary>
    public static class RldXmlExtentions
    {
        /// <summary>
        /// 指定した名前を使用して要素を作成し、このノードの子ノードのリストの末尾に追加します。
        /// </summary>
        /// <param name="aDocument"></param>
        /// <param name="aName">要素の限定名</param>
        /// <returns>追加されたノード。</returns>
        public static XmlElement AddNewElement(this XmlDocument aDocument, String aName)
        {
            var wElement = aDocument.CreateElement(aName);
            aDocument.AppendChild(wElement);
            return wElement;
        }
    }
}
