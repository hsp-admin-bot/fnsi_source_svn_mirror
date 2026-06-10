using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 変換リストデータクラス
    /// </summary>
    public class DesignConvertList : System.Collections.Generic.List<DesignConvertListData>
    {
        #region メンバプロパティ定義

        public String ClassName { get; set; } = String.Empty;

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// XmlElement を取得します。
        /// </summary>
        /// <returns></returns>
        public System.Xml.XmlElement ToXmlElement()
        {
            if( this.Count <= 0 ) return null;

            System.Xml.XmlElement wRet = null;
            System.Xml.XmlDocument wDoc = null;

            try {
                wDoc = new System.Xml.XmlDocument();

                wRet = wDoc.CreateElement(RldConst.ItemList.TAG_CONVTABLE);
                wRet.SetAttribute(RldConst.ItemList.ATT_CONVTABLE_CLS, this.ClassName);

                this.ForEach(ele => wRet.AppendChild(wDoc.ImportNode(ele.ToXmlElement(), true)));
            }
            catch {
                throw;
            }

            return wRet;
        }

        /// <summary>
        /// XmlElement を文字列で取得します。
        /// </summary>
        /// <returns></returns>
        public string ToXmlElementText()
        {
            return this.ToXmlElement()?.OuterXml;
        }

        /// <summary>
        /// 指定した XmlNode を対応する 変換リストに変換し、変換に成功したかどうかを示す値を返します。
        /// </summary>
        /// <param name="aNode"></param>
        /// <param name="Result"></param>
        public static Boolean TryParse(System.Xml.XmlNode aNode, out DesignConvertList Result)
        {
            Boolean wRet = false;

            // 戻り値生成
            Result = new DesignConvertList();

            try {
                foreach( System.Xml.XmlAttribute wAttribute in aNode.Attributes ) {
                    if( LFunc_IsEquals(wAttribute.Name, RldConst.ItemList.ATT_CONVTABLE_CLS) )
                        Result.ClassName = wAttribute.Value;
                }

                // @"conv"
                String wXPathConv = String.Format(@"{0}", RldConst.ItemList.TAG_CONV);

                foreach( System.Xml.XmlNode wXmlConvNode in aNode.SelectNodes(wXPathConv) ) {

                    if( !DesignConvertListData.TryParse(wXmlConvNode, out DesignConvertListData wConvData) )
                        throw new System.ApplicationException("変換リストデータの取得に失敗しました。");
                    Result.Add(wConvData);
                }

                wRet = true;

                /// <summary>
                /// (ローカル関数) 指定された文字列が等しいか確認します。
                /// </summary>
                /// <param name="strA"></param>
                /// <param name="strB"></param>
                /// <returns></returns>
                Boolean LFunc_IsEquals(String strA, String strB)
                {
                    return (String.CompareOrdinal(strA.ToUpper(), strB.ToUpper()) == 0);
                }
            }
            catch {
            }

            return wRet;
        }

        #endregion
    }
}
