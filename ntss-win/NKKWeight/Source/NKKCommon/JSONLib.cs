//----------------------------------------------------------------------------------------------------
//  JSON文字列処理
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Text;

//----------------------------------------------------------------------------------------------------
// 名前空間:TdcLib
//----------------------------------------------------------------------------------------------------
namespace TdcLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// JSON文字列処理クラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class JSONLib
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// データ文字列をJSON形式文字列のエスケープシーケンス変換を行う
        /// </summary>
        /// <param name="strOrgText">変換前文字列</param>
        /// <returns>変換後文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String ConvertJSONString(String strOrgText)
        {
            String strret = strOrgText;

            // エスケープシーケンス変換
            strret = strret.Replace(@"\", "{\\\\}");    // 最初に値を変えておく
            strret = strret.Replace(@"/", "\\/");
            strret = strret.Replace("\r", "\\r");
            strret = strret.Replace("\n", "\\n");
            //strret = strret.Replace("'", "\\'");
            strret = strret.Replace(@"""", @"\""");
            strret = strret.Replace("\t", "\\t");
            strret = strret.Replace("\b", "\\b");
            strret = strret.Replace("\f", "\\f");
            strret = strret.Replace("{\\\\}", "\\\\");  // 最後に正しい値をセット
            
            return ( strret );
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// JSON形式文字列からデータ文字列へのエスケープシーケンス変換を行う
        /// </summary>
        /// <param name="strOrgText">変換前文字列</param>
        /// <returns>変換後文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String ConvertDataString(String strOrgText)
        {
            String strret = strOrgText;

            // エスケープシーケンス変換
            strret = strret.Replace("\\\\", @"{\\\\}" );    // 最初に値を変えておく
            strret = strret.Replace("\\/", @"/");
            strret = strret.Replace("\\r", "\r");
            strret = strret.Replace("\\n", "\n");
            //strret = strret.Replace("\\'", "'");
            strret = strret.Replace(@"\""", @"""");
            strret = strret.Replace("\\t", "\t");
            strret = strret.Replace("\\b", "\b");
            strret = strret.Replace("\\f", "\f");
            strret = strret.Replace(@"{\\\\}", @"\");       // 最後に正しい値をセット

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// JSON形式文字列判定
        /// </summary>
        /// <param name="strRecv"></param>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public static bool IsJSONData(String strRecv)
        {
            bool bret = false;

            try
            {
                bool bsep = false; // 先頭セパレータあり
                int ncount1 = 0;
                int ncount2 = 0;
                Char cseparator = (Char)0x00;   // 文字列セパレータ
                Char cwork;

                // JSON文字列チェック
                for (int intidx = 0; intidx < strRecv.Length; intidx++)
                {
                    cwork = (Char)strRecv[intidx];
                    switch (cwork)
                    {
                        case '{':   // 先頭セパレータ

                            if (cseparator == (Char)0x00)
                            {
                                ncount1++;

                                bsep = true;
                            }
                            break;

                        case '}':   // 末尾セパレータ

                            if (cseparator == (Char)0x00)
                            {
                                ncount1--;
                            }
                            break;

                        case '[':   // 配列開始セパレータ

                            
                            if (cseparator == (Char)0x00)
                            {
                                ncount2++;
                            }
                            break;

                        case ']':   // 配列終了セパレータ

                            if (cseparator == (Char)0x00)
                            {
                                ncount2--;
                            }
                            break;

                        case '\"':  // 文字列区切り
                        case '\'':  // 文字列区切り2

                            if (cseparator == (Char)0x00)
                            {
                                cseparator = cwork;
                            }
                            else if (cseparator == cwork )
                            {
                                cseparator = (Char)0x00;
                            }

                            break;

                        case '\\':  // 

                            // 文字列処理中
                            if (cseparator != (Char)0x00)
                            {
                                if (intidx + 1 < strRecv.Length)
                                {
                                    // エスケープシーケンス判定
                                    cwork = (Char)strRecv[intidx + 1];
                                    switch (cwork)
                                    {
                                        case '\\':
                                            intidx++;
                                            break;

                                        case '/':
                                            intidx++;
                                            break;

                                        case '"':
                                            intidx++;
                                            break;
                                    }
                                }
                            }

                            break;
                    }
                }

                // 
                if (ncount1 == 0 && ncount2 == 0 
                 && bsep == true && cseparator==(Char)0x00 )
                {
                    bret = true;
                }
            }
            catch
            {
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// JSON形式文字列をDirectory&lt;String,String&gt;で返す
        /// ※Key=名称、Value=データ
        /// </summary>
        /// <param name="strRecv">JSON形式文字列</param>
        /// <returns>変換値</returns>
        //----------------------------------------------------------------------------------------------------
        public static System.Collections.Generic.Dictionary<String, String> JSONtoData(String strRecv)
        {
            System.Collections.Generic.Dictionary<String, String> ret = new System.Collections.Generic.Dictionary<String, String>();

            try
            {
                int intst = 0;
                int inted = 0;
                int intidx = 0;
                String strname = String.Empty;
                String strvalue = String.Empty;
                String strwork = String.Empty;
                Char cseparator = (Char)0x00;
                Char cseparator2 = (Char)0x00;
                Object objvalue = System.DBNull.Value;

                // JSON形式確認
                intst = strRecv.IndexOf('{');
                inted = strRecv.LastIndexOf('}');
                if (intst != -1 && inted != -1)
                {
                    // 必要分のみ取得
                    String strdata = strRecv.Substring(intst + 1, inted - intst - 1).Trim();
                    intst = 0;
                    Boolean barray = false;
                    Boolean bjson = false;

                    while (intst <= strdata.Length)
                    {
                        barray = false;
                        bjson = false;

                        // 名称取得
                        cseparator = strdata[intst];

                        // 先頭の空白除去
                        if ( cseparator.Equals(' ') == true )
                        {
                            intst++;
                            continue;
                        }
                        // 切り出し文字検出
                        else if (cseparator.Equals('"') == true )
                        {
                            inted = strdata.IndexOf(cseparator, intst + 1);
                            if (intst < inted)
                            {
                                strname = strdata.Substring(intst + 1, inted - intst - 1);
                                intst = inted + 1;
                            }

                            // セパレータ検出
                            intidx = strdata.IndexOf( ':', intst);
                            if (intst <= intidx )
                            {
                                // データ取得

                                intst = intidx + 1;
                                while (intst <= strdata.Length)
                                {
                                    cseparator = strdata[intst];

                                    // 先頭の空白除去
                                    if (cseparator.Equals(' ') == true)
                                    {
                                        intst++;
                                        continue;
                                    }
                                    // 先頭の切り出し文字検出
                                    else if (cseparator.Equals('"') == true )
                                    {
                                        // 文字列等の場合

                                        inted = intst;
                                        while (inted <= strdata.Length)
                                        {
                                            inted++;

                                            // エスケープシーケンス判定
                                            if (strdata[inted].Equals('\\') == true )
                                            {
                                                switch (strdata[inted + 1])
                                                {
                                                    case '\\':
                                                        inted++;
                                                        continue;

                                                    case '/':
                                                        inted++;
                                                        continue;

                                                    case '"':
                                                        inted++;
                                                        continue;
                                                }
                                            }

                                            // 末尾の切り出し文字検出
                                            if (strdata[inted].Equals(cseparator) == true)
                                            {
                                                // 末尾の切り出し文字検出

                                                break;
                                            }
                                        }
                                    }
                                    // 配列
                                    else if (cseparator.Equals('[') == true)
                                    {
                                        barray = true;

                                        int ncount = 1;
                                        inted = intst + 1;

                                        // 配列件数検索
                                        cseparator2 = (Char)0x00;
                                        while (1 <= ncount && inted <= strdata.Length)
                                        {
                                            cseparator = strdata[inted];

                                            // 先頭の切り出し文字検出(文字列中の'['と']'を無視するため)
                                            if (cseparator2.Equals((Char)0x00) == true)
                                            {
                                                if (cseparator.Equals('"') == true)
                                                {
                                                    // 開始の切り出し文字検出
                                                    cseparator2 = cseparator;
                                                }

                                                // 配列開始文字列検出
                                                if (cseparator.Equals('[') == true)
                                                {
                                                    ncount++;
                                                }
                                                // 配列終了文字列検出
                                                else if (cseparator.Equals(']') == true)
                                                {
                                                    ncount--;
                                                }
                                            }
                                            else
                                            {
                                                // 文字列データ

                                                // エスケープシーケンス判定
                                                if (cseparator.Equals('\\') == true )
                                                {
                                                    // エスケープシーケンス判定
                                                    switch (strdata[inted + 1])
                                                    {
                                                        case '\\':
                                                            inted+=2;
                                                            continue;

                                                        case '/':
                                                            inted += 2;
                                                            continue;

                                                        case '"':
                                                            inted += 2;
                                                            continue;
                                                    }
                                                }

                                                // 末尾の切り出し文字検出
                                                if (cseparator.Equals(cseparator2) == true)
                                                {
                                                    // 末尾の切り出し文字検出

                                                    cseparator2 = (Char)0x00;
                                                }
                                            }
                                            inted++;
                                        }
                                        inted--;
                                    }
                                    // JSON
                                    else if (cseparator.Equals('{') == true)
                                    {
                                        bjson = true;

                                        int ncount = 1;
                                        inted = intst + 1;

                                        // 配列件数検索
                                        cseparator2 = (Char)0x00;
                                        while (1 <= ncount && inted <= strdata.Length)
                                        {
                                            cseparator = strdata[inted];

                                            // 先頭の切り出し文字検出(文字列中の'['と']'を無視するため)
                                            if (cseparator2.Equals((Char)0x00) == true)
                                            {
                                                if (cseparator.Equals('"') == true)
                                                {
                                                    // 開始の切り出し文字検出
                                                    cseparator2 = cseparator;
                                                }

                                                // 配列開始文字列検出
                                                if (cseparator.Equals('{') == true)
                                                {
                                                    ncount++;
                                                }
                                                // 配列終了文字列検出
                                                else if (cseparator.Equals('}') == true)
                                                {
                                                    ncount--;
                                                }
                                            }
                                            else
                                            {
                                                // 文字列データ

                                                // エスケープシーケンス判定
                                                if (cseparator.Equals('\\') == true)
                                                {
                                                    // エスケープシーケンス判定
                                                    switch (strdata[inted + 1])
                                                    {
                                                        case '\\':
                                                            inted += 2;
                                                            continue;

                                                        case '/':
                                                            inted += 2;
                                                            continue;

                                                        case '"':
                                                            inted += 2;
                                                            continue;
                                                    }
                                                }

                                                // 末尾の切り出し文字検出
                                                if (cseparator.Equals(cseparator2) == true)
                                                {
                                                    // 末尾の切り出し文字検出

                                                    cseparator2 = (Char)0x00;
                                                }
                                            }
                                            inted++;
                                        }
                                        inted--;
                                    }
                                    else
                                    {
                                        intst--;

                                        // 以外
                                        inted = strdata.IndexOf(',', intst + 1);
                                        if (inted < 0)
                                        {
                                            inted = strdata.Length;
                                        }
                                    }

                                    if (intst < inted)
                                    {
                                        // データ
                                        strvalue = strdata.Substring(intst + 1, inted - intst - 1);
                                        intst = inted;
                                    }

                                    // 格納方法判定
                                    if (barray == true)
                                    {
                                        // 配列

                                        // 配列の分割
                                        List<String> strlines = new List<String>();
                                        StringBuilder sbwork = new StringBuilder();
                                        intidx = 0;
                                        int ncount = 0;
                                        cseparator2 = (Char)0x00;
                                        for (int intlop = 0; intlop < strvalue.Length; intlop++)
                                        {
                                            cseparator = strvalue[intlop];

                                            // 切り出し文字検出(文字列中の'{'と'}'を無視するため)
                                            if (cseparator2.Equals((char)0x00) == true)
                                            {
                                                if (cseparator.Equals('"') == true)
                                                {
                                                    // 開始の切り出し文字検出
                                                    cseparator2 = cseparator;

                                                    continue;
                                                }

                                                // 配列開始文字列検出
                                                if (cseparator.Equals('{') == true)
                                                {
                                                    ncount++;
                                                }
                                                // 配列終了文字列検出
                                                else if (cseparator.Equals('}') == true)
                                                {
                                                    ncount--;

                                                    // "{"と"}"の対検出
                                                    if (ncount == 0)
                                                    {
                                                        strlines.Add(strvalue.Substring(intidx, intlop - intidx + 1));

                                                        // 区切り検出
                                                        if ((intlop + 1) < strvalue.Length && strvalue[intlop + 1].Equals(',') == true)
                                                        {
                                                            intidx = intlop + 2;
                                                        }
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                // 文字列データ

                                                // エスケープシーケンス判定
                                                if (cseparator.Equals('\\') == true)
                                                {
                                                    switch (cseparator)
                                                    {
                                                        case '\\':
                                                            intlop++;
                                                            continue;

                                                        case '/':
                                                            intlop++;
                                                            continue;

                                                        case '"':
                                                            intlop++;
                                                            continue;
                                                    }
                                                }

                                                // 末尾の切り出し文字検出
                                                if (cseparator.Equals(cseparator2) == true)
                                                {
                                                    // 末尾の切り出し文字検出

                                                    cseparator2 = (Char)0x00;
                                                }
                                            }
                                        }

                                        // 配列数記録
                                        ret.Add(strname, strlines.Count.ToString());

                                        // 配列分のJSON形式変換
                                        ncount = 1;
                                        System.Collections.Generic.Dictionary<String, String> ret2;
                                        foreach (String strline in strlines)
                                        {
                                            ret2 = JSONLib.JSONtoData(strline);
                                            foreach (System.Collections.Generic.KeyValuePair<String, String> info in ret2)
                                            {
                                                ret.Add(String.Format("{0}.{1}.{2}", strname, ncount, info.Key), info.Value);
                                            }

                                            ncount++;
                                        }
                                    }
                                    else if( bjson == true )
                                    {
                                        // JSON

                                        ret.Add(strname, "{" + strvalue + "}");
                                    }
                                    else
                                    {
                                        // 単一

                                        ret.Add(strname, ConvertDataString(strvalue));
                                    }

                                    break;
                                }
                            }
                        }

                        intst++;
                    }
                }
            }
            catch
            {
            }

            return (ret);
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
