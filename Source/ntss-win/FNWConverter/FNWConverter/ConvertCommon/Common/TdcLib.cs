//----------------------------------------------------------------------------------------------------
//  共通ライブラリ
//----------------------------------------------------------------------------------------------------
using System;
using System.Text;
using System.Xml;
using System.IO;
using System.Globalization;
using System.Collections.Generic;
using ConvertCommon;

#if DEBUG
    using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  TdcLib名前空間
//----------------------------------------------------------------------------------------------------
namespace TdcLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 共通ライブラリクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public static partial class TdcLib
    {

#region プライベート定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デバッグログ使用許可フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static bool m_bUseLog = false;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------

#endregion


#region パブリックプロパティ

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static Exception Error
        {
            get
            {
                return (m_Exception);
            }

            set
            {
                m_Exception = value;

#if DEBUG
                Trace.WriteLine(String.Format("TdcLib Error:{0}", value.ToString()));
#endif
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デバッグログ使用許可フラグプロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static bool UseLog
        {
            get
            {
                return (m_bUseLog);
            }

            set
            {
                m_bUseLog = value;
            }
        }
        //----------------------------------------------------------------------------------------------------

#endregion

#region パブリックメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Short値でエンディアン変換
        /// ※BigEndian型Short値→LittleEndian型Short値
        ///   LittleEndian型Short値→BigEndian型Short値
        /// </summary>
        /// <param name="sintSrc">変換元</param>
        /// <returns>変換後</returns>
        //----------------------------------------------------------------------------------------------------
        public static short ConvEndian(short sintSrc)
        {
            Byte[] bbuff = BitConverter.GetBytes(sintSrc);
            Array.Reverse(bbuff);
            return( BitConverter.ToInt16(bbuff, 0));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Int32値でエンディアン変換
        /// ※BigEndian型Int32値→LittleEndian型Int32値
        ///   LittleEndian型Int32値→BigEndian型Int32値
        /// </summary>
        /// <param name="int32Src">変換元</param>
        /// <returns>変換後</returns>
        //----------------------------------------------------------------------------------------------------
        public static Int32 ConvEndian(Int32 int32Src)
        {
            Byte[] bbuff = BitConverter.GetBytes(int32Src);
            Array.Reverse(bbuff);
            return( BitConverter.ToInt32(bbuff, 0));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Long値でエンディアン変換
        /// ※BigEndian型long値→LittleEndian型Long値
        ///   LittleEndian型long値→BigEndian型Long値
        /// </summary>
        /// <param name="lngSrc">変換元</param>
        /// <returns>変換後</returns>
        //----------------------------------------------------------------------------------------------------
        public static long ConvEndian(long lngSrc)
        {
            Byte[] bbuff = BitConverter.GetBytes(lngSrc);
            Array.Reverse(bbuff);
            return( BitConverter.ToInt64(bbuff, 0));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Byte値でエンディアン変換
        /// ※BigEndian型Byte配列→LittleEndian型Byte配列
        ///   LittleEndian型Byte配列→BigEndian型Byte配列
        ///   ex.UTF-16はintConvSize=2
        /// </summary>
        /// <param name="cBase">変換元</param>
        /// <param name="intIndex">変換開始位置[0～]</param>
        /// <param name="intConvSize">変換対象要素数</param>
        /// <returns>変換後</returns>
        //----------------------------------------------------------------------------------------------------
        public static Byte[] ConvEndian(Byte[] cBase, int intIndex, int intConvSize)
        {
            Byte[] cret = null;

            try
            {
                // 配列長分
                for (int intlop = intIndex; intlop < cBase.Length; intlop += intConvSize)
                {
                    // エンディアン変換を行う
                    Array.Reverse(cBase, intlop, intConvSize);
                }

                cret = cBase;
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (cBase);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// BYTE配列を16進文字列に変換
        /// </summary>
        /// <param name="bBuff">BYTE配列</param>
        /// <param name="intIndex">取得開始位置[0～]</param>
        /// <param name="intSize">取得byte数</param>
        /// <returns>変換した16進文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetByteToHexString(Byte[] bBuff, int intIndex, int intSize)
        {
            //StringBuilder sbret = new StringBuilder();

            //try
            //{
            //    //
            //    for (int intlop = intIndex; intlop < (intIndex + intSize); intlop++)
            //        sbret.AppendFormat("{0:X2}", bBuff[intlop]);

            //}
            //catch (Exception ex)
            //{
            //    TdcLib.Error = ex;
            //}

            //return (sbret.ToString());

            String strret = String.Empty;

            try
            {
                // 対象データのコピー
                byte[] bbuf = new byte[intSize];
                Buffer.BlockCopy(bBuff, intIndex, bbuf, 0, intSize);

                // BIN→HEX
                strret = BitConverter.ToString(bbuf).Replace("-", String.Empty);
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// BYTE配列を16進文字列に変換
        /// </summary>
        /// <param name="bBuff">BYTE配列</param>
        /// <returns>変換した16進文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetByteToHexString(Byte[] bBuff)
        {
            return (TdcLib.GetByteToHexString(bBuff, 0, bBuff.Length));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// BYTE配列から文字列を取得
        /// </summary>
        /// <param name="bBuff">BYTE配列</param>
        /// <param name="intIndex">取得開始位置[0～]</param>
        /// <param name="intSize">取得byte数</param>
        /// <param name="strCodePageName">変換元コードページ</param>
        /// <returns>取得した文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetByteToString(Byte[] bBuff, int intIndex, int intSize, String strCodePageName)
        {
            String strret = String.Empty;

            try
            {
                if (bBuff != null)
                {
                    strret = Encoding.GetEncoding(strCodePageName).GetString(bBuff, intIndex, intSize);

                    // null以降を除去
                    strret = strret.TrimEnd( '\0' );
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// BYTE配列から文字列を取得
        /// </summary>
        /// <param name="bBuff">BYTE配列</param>
        /// <param name="strCodePageName">変換元コードページ</param>
        /// <returns>取得した文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetByteToString(Byte[] bBuff, String strCodePageName)
        {
            return (TdcLib.GetByteToString(bBuff, 0, bBuff.Length, strCodePageName));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 日付時刻文字列をDateTime型へ変換
        /// </summary>
        /// <param name="strDateTime">日付時刻文字列</param>
        /// <param name="dtDateTime">変換したDateTime値</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool GetStringToDateTime(String strDateTime, out DateTime dtDateTime)
        {
            return (DateTime.TryParse(strDateTime, out dtDateTime));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 日付時刻文字列をDateTime型へ変換
        /// ※日付時刻文字列の書式指定版
        /// </summary>
        /// <param name="strDateTimeFormat">日付時刻文字列書式</param>
        /// <param name="strDateTime">日付時刻文字列</param>
        /// <param name="dtDateTime">変換したDateTime値</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool GetStringToDateTime(String strDateTimeFormat, String strDateTime, out DateTime dtDateTime)
        {
            return (DateTime.TryParseExact(strDateTime, strDateTimeFormat, null, DateTimeStyles.AllowLeadingWhite | DateTimeStyles.AllowTrailingWhite, out dtDateTime));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 日付、時刻をあらわすInt32値をDateTime値へ変換
        /// </summary>
        /// <param name="int32Date">日付[YYYYMMDD形式]</param>
        /// <param name="int32Time">時刻[HHMMSS形式]</param>
        /// <param name="dtData">変換したDateTime値</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool GetInt32ToDateTime(Int32 int32Date, Int32 int32Time, out DateTime dtData)
        {
            String strwork = String.Format( "{0:0000\\/00\\/00} {1:00\\:00\\:00}", int32Date, int32Time );
            return ( TdcLib.GetStringToDateTime(strwork, out dtData));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 小数点付き数値文字列をDouble値へ変換
        /// </summary>
        /// <param name="strData">数値文字列</param>
        /// <param name="dblData">変換したDouble値</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool GetStringToDouble(String strData, out double dblData)
        {
            return (double.TryParse(strData, out dblData));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 小数点付き数値文字列をDecimal値へ変換
        /// </summary>
        /// <param name="strData">数値文字列</param>
        /// <param name="decData">変換したDecimal値</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool GetStringToDecimal(String strData, out decimal decData)
        {
            return (decimal.TryParse(strData, out decData));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 小数点付き数値文字列を数値化、倍数をかけた後のInt値を取得する
        /// </summary>
        /// <param name="strData">数値文字列</param>
        /// <param name="nDecilamFuigure">倍数</param>
        /// <param name="intData">変換したInt値</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool GetDblStringToInt(String strData, int nDecilamFuigure, ref int intData)
        {
            bool bret = false;

            try
            {
                decimal decdata;

                // 文字列を変換
                if (TdcLib.GetStringToDecimal(strData, out decdata) == true)
                {
                    // 倍数をかけて整数取得
                    decdata *= nDecilamFuigure;
                    intData = (int)decdata;

                    bret = true;
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定した整数値と小数点以下桁数から小数点付数値文字列へ変換
        /// </summary>
        /// <param name="sintData">short値</param>
        /// <param name="nDecimalFigure">小数点以下桁数</param>
        /// <param name="nSize">文字列桁数(不要な場合は0)</param>
        /// <returns>変換した小数点付数値文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetNumberToDoubleString(short sintData, int nDecimalFigure, int nSize)
        {
            return (TdcLib.GetNumberToDoubleString((int)sintData, nDecimalFigure, nSize ));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定した整数値と小数点以下桁数から小数点付数値文字列へ変換
        /// </summary>
        /// <param name="int32Data">Int値</param>
        /// <param name="nDecimalFigure">小数点以下桁数</param>
        /// <param name="nSize">文字列桁数(不要な場合は0)</param>
        /// <returns>変換した小数点付数値文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetNumberToDoubleString(Int32 int32Data, int nDecimalFigure, int nSize)
        {
            String strret = String.Empty;

            try
            {
                // 表示形式作成
                String strfmt = "{0";

                // 有効桁数指定あり
                if (0 < nSize)
                {
                    strfmt += "," + nSize.ToString();
                }

                strfmt += ":0";

                // 小数点以下桁数指定あり
                if (0 < nDecimalFigure)
                {
                    strfmt += "\\.";
                    strfmt += new string('0', nDecimalFigure);
                }
                strfmt += "}";

                // 数値→小数点付文字列化
                strret = String.Format(strfmt, int32Data);
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定したノード文字列から指定タグを検索、該当するノードオブジェクトを取得する
        /// </summary>
        /// <param name="XmlDoc">Xmlドキュメントオブジェクト</param>
        /// <param name="strNodeName">XmlNode文字列</param>
        /// <returns>null：該当なし/else：該当XmlNodeオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static XmlNode GetXmlNode(XmlDocument XmlDoc, String strNodeName)
        {
            XmlNode noderet = null;

            try
            {
                // ノード分割
                String[] strsep = { "\\" };
                String[] strnodes = strNodeName.Split(strsep, StringSplitOptions.None);
                foreach( String strnode in strnodes )
                {
                    XmlNode node = null;
                    if (noderet == null)
                    {
                        // ルートノード
                        node = XmlDoc[strnode];
                    }
                    else
                    {
                        node = noderet[strnode];
                    }
                    noderet = node;
                    if (noderet == null)
                    {
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (noderet);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定したXmlNodeオブジェクトの子ノードから指定タグを検索、該当子ノードオブジェクトを取得する
        /// </summary>
        /// <param name="XmlNode">XmlNodeオブジェクト</param>
        /// <param name="strTag">タグ</param>
        /// <returns>null：該当なし/else：該当XmlNodeオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static XmlNode GetXmlNode(XmlNode XmlNode, String strTag)
        {
            XmlNode noderet = null;

            try
            {
                //// 指定ノードの子ノード列挙
                //foreach (XmlNode node in XmlNode.ChildNodes)
                //{
                //    // タグ名判定
                //    if (node.Name.Equals(strTag) == true)
                //    {
                //        // ノード取得
                //        noderet = node;

                //        break;
                //    }
                //}
                // 指定した子ノードを検索
                XmlElement element = (XmlElement)XmlNode;
                if( element != null )
                {
                    XmlNodeList nodelist = element.GetElementsByTagName(strTag);
                    if (nodelist != null && 0 < nodelist.Count)
                    {
                        // 該当ノードを返す
                        noderet = nodelist.Item(0);
                    }
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (noderet);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定したXmlNodeオブジェクトの子ノードから指定タグを検索、文字列を取得する
        /// </summary>
        /// <param name="XmlNode">XmlNodeオブジェクト</param>
        /// <param name="strTag">タグ</param>
        /// <param name="strDefaultValue">データがない場合の既定文字列</param>
        /// <returns>取得した文字列</returns>
        /// <remarks>(NULL)等の値は既定値に置き換わる</remarks>
        //----------------------------------------------------------------------------------------------------
        public static string GetXmlTagData(XmlNode XmlNode, String strTag, String strDefaultValue)
        {
            // 既定値の代入
            String strret = strDefaultValue;

            try
            {
                // 指定ノードの指定子ノード取得
                XmlNode node = TdcLib.GetXmlNode(XmlNode,strTag);
                if( node != null )
                {
                    // データ取得
                    strret = node.InnerText;
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定したXmlNodeオブジェクトの子ノードから指定タグを検索、文字列を取得する
        /// </summary>
        /// <param name="XmlNode">XmlNodeオブジェクト</param>
        /// <param name="strTag">タグ</param>
        /// <returns>空：データなし/else：取得した文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static string GetXmlTagData(XmlNode XmlNode, string strTag)
        {
            return (GetXmlTagData(XmlNode, strTag, string.Empty));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定したノード文字列から指定タグを検索、該当するノードオブジェクトを取得する
        /// ※該当ノードがない場合は作成する
        /// </summary>
        /// <param name="XmlDoc">Xmlドキュメントオブジェクト</param>
        /// <param name="strNodeName">XmlNode文字列</param>
        /// <returns>null：該当なし/else：該当XmlNodeオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        public static XmlNode SetXmlNode(XmlDocument XmlDoc, String strNodeName)
        {
            XmlNode noderet = null;

            try
            {
                // ノード分割
                String[] strsep = { "\\" };
                String[] strnodes = strNodeName.Split(strsep, StringSplitOptions.None);
                foreach (String strnode in strnodes)
                {
                    XmlNode node = null;
                    if (noderet == null)
                    {
                        // ルートノード取得
                        node = XmlDoc[strnode];

                        // ルートノードがない場合
                        if (node == null)
                        {
                            // XML宣言ノード作成
                            XmlDoc.AppendChild(XmlDoc.CreateXmlDeclaration("1.0", "utf-8", String.Empty));

                            // XMLルートノード作成
                            node = XmlDoc.AppendChild(XmlDoc.CreateElement(strnode));
                        }
                    }
                    else
                    {
                        // 子ノード取得
                        node = noderet[strnode];

                        // 子ノードがない場合
                        if (node == null)
                        {
                            // 指定したタグ名のノードを構築し子ノードの末尾に追加
                            node = noderet.AppendChild(XmlDoc.CreateElement(strnode));
                        }
                    }

                    noderet = node;
                    if (noderet == null)
                    {
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (noderet);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 文字列をXMLドキュメントに追加/変更する
        /// </summary>
        /// <param name="XmlNode">XMLNodeオブジェクト</param>
        /// <param name="strTag">タグ</param>
        /// <param name="strValue">記録する文字列</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool SetXmlTagData(XmlNode XmlNode, String strTag, String strValue)
        {
            bool bret = false;

            try
            {
                // XMLNodeオブジェクトの有無チェック

                // 指定ノードの指定子ノード取得
                XmlNode node = TdcLib.GetXmlNode(XmlNode, strTag);
                if (node != null)
                {
                    // データ設定
                    node.InnerText = strValue;
                }
                else
                {
                    // 指定されたXMLタグがない場合

                    // 指定したタグ名のノード構築
                    XmlElement element = XmlNode.OwnerDocument.CreateElement(strTag);

                    // データ設定
                    element.InnerText = strValue;

                    // 子ノードの末尾に追加
                    XmlNode.AppendChild(element);
                }

                bret = true;
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (bret);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// XMLノードを変更、また追加する
        /// </summary>
        /// <param name="rootNode"></param>
        /// <param name="pathNodes"></param>
        /// <param name="value"></param>
        //----------------------------------------------------------------------------------------------------
        public static bool SetXmlTagWithPath(ref XmlNode rootNode, Queue<string> pathNodes, string value)
        {
            bool bret = false;

            try
            {
                string strPreNodeName = string.Empty;
                int fullQueueCount = pathNodes.Count;
                string path = "";
                for (int i = 0; i < fullQueueCount; i++)
                {
                    string strNode = pathNodes.Dequeue();
                    string path2;
                    if (i == 0)
                    {
                        path2 = path + strNode;
                    }
                    else
                    {
                        path2 = path + "/" + strNode;
                    }

                    if (rootNode.SelectSingleNode(path2) == null)
                    {
                        XmlNode node = rootNode.OwnerDocument.CreateNode(XmlNodeType.Element, strNode, "");
                        if (!string.IsNullOrEmpty(strPreNodeName))
                        {
                            rootNode.SelectSingleNode(path).AppendChild(node);
                        }
                        else
                        {
                            rootNode.AppendChild(node);
                        }

                    }
                    path = path2;
                    strPreNodeName = strNode;
                }

                XmlNode xmlNode = rootNode.SelectSingleNode(path);
                xmlNode.InnerText = value;
                bret = true;
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (bret);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定したXmlNodeオブジェクトの子ノードのタグの前にコメントを追加する
        /// </summary>
        /// <param name="XmlNode">XMLNodeオブジェクト</param>
        /// <param name="strTag">タグ</param>
        /// <param name="strComment">記録するコメント</param>
        /// <returns>true：処理成功/false：処理失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool SetXmlTagComment(XmlNode XmlNode, String strTag, String strComment)
        {
            bool bret = false;

            try
            {
                // XMLNodeオブジェクトの有無チェック

                // 指定ノードの指定子ノード取得
                XmlNode node = TdcLib.GetXmlNode(XmlNode, strTag);
                if (node != null)
                {
                    // コメント作成
                    XmlComment cmt = XmlNode.OwnerDocument.CreateComment(strComment);

                    // 指定子ノードの前に追加
                    XmlNode.InsertBefore(cmt, node);

                    bret = true;
                }
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("SetXmlTagComment:{0}", ex.Message);
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 2つのTickCount値の差を返す関数
        /// ※[TickCount値:(UInt32)System.Environment.TickCount]
        /// </summary>
        /// <param name="nTickCount1">前回TickCount値</param>
        /// <param name="nTickCount2">今回TickCount値</param>
        /// <returns>差</returns>
        //----------------------------------------------------------------------------------------------------
        public static UInt32 GetTickCountDiff(UInt32 nTickCount1, UInt32 nTickCount2)
        {
            UInt32 ntickcount;

            // それぞれのTickCount値比較
            if (nTickCount1 <= nTickCount2)
            {
                // TickCount値1よりTickCount値2が大きい場合
                ntickcount = nTickCount2 - nTickCount1;
            }
            else
            {
                // TickCount値2よりTickCount値1が大きい場合
                //ntickcount = (0xffffffff - nTickCount1) + nTickCount2;
                ntickcount = (UInt32.MaxValue - nTickCount1) + nTickCount2;
            }

            return (ntickcount);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 2つのTickCount値の差が指定ミリ秒を超えているかどうかを返す関数
        /// ※[TickCount値:(UInt32)System.Environment.TickCount]
        /// </summary>
        /// <param name="nSpanTickCount">２つの差[ミリ秒]</param>
        /// <param name="nTickCount1">前回TickCount値</param>
        /// <param name="nTickCount2">今回TickCount値</param>
        /// <returns>true：超えている/false：超えていない</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CheckTickCount(UInt32 nSpanTickCount, UInt32 nTickCount1, UInt32 nTickCount2)
        {
            bool bret = false;

            // それぞれのTickCount値の差取得
            UInt32 ntickcount = TdcLib.GetTickCountDiff( nTickCount1, nTickCount2);

            // 指定した差との比較
            if (nSpanTickCount <= ntickcount)
            {
                bret = true;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 年齢算出
        /// </summary>
        /// <param name="dtBirthday">誕生日</param>
        /// <param name="dtNow">年齢計算日付</param>
        /// <returns>-1:算出不能/else：算出年齢</returns>
        //----------------------------------------------------------------------------------------------------
        public static int GetAge(DateTime dtBirthday, DateTime dtNow)
        {
            int intret = -1;

            // 誕生日≦年齢計算日付の場合のみ算出を行う
            if (dtBirthday <= dtNow)
            {
                // 年齢計算日付-誕生日にて年齢を算出する
                intret = dtNow.Year - dtBirthday.Year;

                // 補正(誕生日を迎えていない場合の処理)
                DateTime dtwork = new DateTime(dtBirthday.Year, 1, 1);
                dtwork = dtwork.AddDays(dtNow.DayOfYear - 1);
                if (dtwork < dtBirthday)
                    intret -= 1;
            }

            return (intret);
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Unocode文字列をShift-JISバイト配列へ変換する
        /// </summary>
        /// <param name="strUnicodeText"></param>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public static Byte[] GetUni2SJISBytes(String strUnicodeText)

        {
            Byte[] bret = { };
            try
            {
                bret = System.Text.Encoding.GetEncoding("Shift_JIS").GetBytes(strUnicodeText);
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("GetUni2SJISBytes:{0}", ex.Message);
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定した文字列[UNICODE]の指定位置[文字桁数]から指定カウント分取得する関数
        /// ※半角は連続2文字を1カウント、以外は1文字を1カウントとして算出する
        /// </summary>
        /// <param name="strText">取得元文字列[Unicode]</param>
        /// <param name="nStart">取得開始桁数[0～]</param>
        /// <param name="nSize">取得カウント数</param>
        /// <returns>取得文字列[Unicode]</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetSelUnicodeText(String strText, int nStart, int nSize)
        {
            StringBuilder sbret = new StringBuilder();
            int nindex = nStart;
            String strwork  = String.Empty;
            String strwork2 = String.Empty;
            int ncount = 0;
            int nbyte = 0;

            try
            {
                while (nindex < strText.Length)
                {
                    // 指定位置の文字取得
                    strwork = strText.Substring(nindex, 1);

                    // Unicode→SJIS変換後のByte数取得
                    nbyte = TdcLib.GetUni2SJISBytes(strwork).Length;
                    if (nbyte == 1)
                    {
                        // 1byte文字である場合
                        
                        // 次の文字存在チェック
                        if(( nindex + 1 ) < strText.Length)
                        {
                            // 次の文字取得
                            strwork2 = strText.Substring(nindex + 1, 1);

                            // Unicode→SJIS変換後のByte数取得
                            nbyte = TdcLib.GetUni2SJISBytes(strwork2).Length;
                            if (nbyte == 1)
                            {
                                // 1byte文字である場合

                                // 文字列連結
                                strwork += strwork2;

                                // 
                                nindex++;
                            }
                        }
                    }
                    else
                    {
                        // 以外
                    }

                    if (ncount < nSize)
                    {
                        // 文字列追加
                        sbret.Append(strwork);

                        //
                        ncount++;
                        nindex++;
                    }
                    else
                    {
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("GetSelUnicodeText:{0}", ex.Message);
            }

            return (sbret.ToString());
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// テキストファイルに記録する
        /// </summary>
        /// <param name="strLogMessage">ログメッセージ</param>
        //----------------------------------------------------------------------------------------------------
        public static void WriteLog(String strLogMessage)
        {
            // ログ記録
            TdcLib.WriteLog(strLogMessage, "DebugLog.TXT");
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// テキストファイルに記録する
        /// ※キャラクタコードはShift-JIS形式
        /// </summary>
        /// <param name="strLogMessage">メッセージ</param>
        /// <param name="strLogFileName">ログ出力ファイル名</param>
        //----------------------------------------------------------------------------------------------------
        public static void WriteLog(String strLogMessage, String strLogFileName)
        {
            TdcLib.WriteLog(System.Text.Encoding.GetEncoding("Shift_JIS"), strLogMessage, strLogFileName);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// テキストファイルに記録する
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strLogMessage">メッセージ</param>
        /// <param name="strLogFileName">ログ出力ファイル名</param>
        //----------------------------------------------------------------------------------------------------
        public static void WriteLog( System.Text.Encoding Enc,String strLogMessage, String strLogFileName)
        {
            // ログ使用許可フラグ
            if (TdcLib.UseLog == true)
            {
                try
                {
                    // フルパスファイル名作成
                    String strfilename = AppDomain.CurrentDomain.BaseDirectory;
                    // 末尾の\付加
                    if (strfilename.EndsWith("\\") == false)
                        strfilename += "\\";
                    strfilename += strLogFileName;

                    // ファイルに追記
                    byte[] bbuff = Enc.GetBytes(strLogMessage + System.Environment.NewLine);
                    System.IO.FileStream fs = new System.IO.FileStream(strfilename, System.IO.FileMode.Append, System.IO.FileAccess.Write, System.IO.FileShare.ReadWrite);
                    fs.Write(bbuff, 0, bbuff.Length);
                    fs.Close();
                }
                catch (Exception ex)
                {
                    TdcLib.Error = ex;
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルを指定バイト数で分割する
        /// ※分割したファイル名の拡張子末尾に0000書式で分割順が入る
        /// </summary>
        /// <param name="strFileName">分割元ファイル名</param>
        /// <param name="nMaxSize">分割バイトサイズ</param>
        /// <returns>分割したファイル名一覧</returns>
        //----------------------------------------------------------------------------------------------------
        public static List<String> SeparateFile(String strFileName, long nMaxSize)
        {
            List<String> ret = new List<String>();

            try 
            {
                // 分割元ファイルを開く
                using (FileStream rf = new FileStream(strFileName, FileMode.Open, FileAccess.Read))
                {
                    int read = 0;
                    int count = 0;
                    long remain = rf.Length;
                    byte[] buf = new byte[1024 * 1024];

                    // 分割バイト数リストを作成
                    List<long> listsize = new List<long>();
                    for (int intlop = 0; intlop < remain / nMaxSize; intlop++)
                    {
                        listsize.Add(nMaxSize);
                    }
                    // 分割バイト数の残り
                    if (remain % nMaxSize > 0)
                    {
                        listsize.Add(remain % nMaxSize);
                    }

                    // 分割バイト数リスト分
                    foreach (int size in listsize)
                    {
                        // 分割先ファイル名を作成
                        String filename = strFileName + String.Format("{0:0000}", ++count);
                        ret.Add(filename);

                        // 分割先ファイルを開く
                        using (FileStream wf = new FileStream(filename, FileMode.Create, FileAccess.Write))
                        {
                            // バッファ分
                            for( int intlop = size; 0 < intlop; intlop -= buf.Length)
                            {
                                // 分割元ファイルから読み込む
                                read = rf.Read(buf, 0, buf.Length);

                                // 分割先ファイルに書きこむ
                                wf.Write(buf, 0, read);
                            }
                        }
                    }
                }
            }
            catch( Exception ex)
            {
                TdcLib.Error = ex;
            }
            return ret;
        }
        //----------------------------------------------------------------------------------------------------

#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
