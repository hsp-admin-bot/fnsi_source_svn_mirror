using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 変換リストアイテムデータ
    /// </summary>
    public class DesignConvertListData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// コードの取得及び設定を行います。
        /// </summary>
        public String Code { get; set; } = String.Empty;

        /// <summary>
        /// 値の取得及び設定を行います。
        /// </summary>
        public String ItemValue { get; set; } = String.Empty;

        /// <summary>
        /// 表示値の取得及び設定を行います。
        /// </summary>
        public String DisplayValue { get; set; } = String.Empty;

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// XmlNode を生成します。
        /// </summary>
        /// <returns></returns>
        public System.Xml.XmlElement ToXmlElement()
        {
            System.Xml.XmlElement wRet = null;

            try {
                wRet = (new System.Xml.XmlDocument()).CreateElement(RldConst.ItemList.TAG_CONV);
                wRet.SetAttribute(RldConst.ItemList.ATT_CONV_CODE, this.Code);
                wRet.SetAttribute(RldConst.ItemList.ATT_CONV_ITEM, this.ItemValue);
                wRet.SetAttribute(RldConst.ItemList.ATT_CONV_DISP, this.DisplayValue);
            }
            catch {
                throw;
            }

            return wRet;
        }

        /// <summary>
        /// 指定した XmlNode を対応する 変換リストデータに変換し、変換に成功したかどうかを示す値を返します。
        /// </summary>
        /// <param name="aNode"></param>
        /// <param name="Result"></param>
        /// <returns></returns>
        public static Boolean TryParse(System.Xml.XmlNode aNode, out DesignConvertListData Result)
        {
            Boolean wRet = false;

            Result = new DesignConvertListData();

            try {
                // 属性を列挙してプロパティをセット
                foreach( System.Xml.XmlAttribute wAttribute in aNode.Attributes ) {
                    if( RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_CONV_CODE) )
                        Result.Code = wAttribute.Value;
                    else if( RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_CONV_ITEM) )
                        Result.ItemValue = wAttribute.Value;
                    else if( RldLib.IsEqualXmlAttName(wAttribute.Name, RldConst.ItemList.ATT_CONV_DISP) )
                        Result.DisplayValue = wAttribute.Value;
                }

                wRet = true;
            }
            catch {
            }

            return wRet;
        }

        #endregion
    }
}
