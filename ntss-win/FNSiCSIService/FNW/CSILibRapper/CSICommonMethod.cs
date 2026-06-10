using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.VisualBasic;
//using System.Windows.Forms;
using System.Reflection;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    class CSICommonMethod
    {
        #region 共通メソッド

        /// <summary>
        /// object型配列の内容を文字列に変換公開用(COLLECTION版)　※DUMP利用を想定
        /// </summary>
        /// <param name="objVarArray">object型配列</param>
        /// <returns>変換結果文字列</returns>
        public static string ConvertStringFromVarArray(VBA.Collection colParam)
        {
            object[] objVarArray = new object[1];
            objVarArray[0] = colParam;
            return convertStringFromVarArray(objVarArray, string.Empty);
        }

        /// <summary>
        /// object型配列の内容を文字列に変換公開用　※DUMP利用を想定
        /// </summary>
        /// <param name="objVarArray">object型配列</param>
        /// <returns>変換結果文字列</returns>
        public static string ConvertStringFromVarArray(object[] objVarArray)
        {
            return convertStringFromVarArray(objVarArray, string.Empty);
        }

        /// <summary>
        /// object型配列の内容を文字列に変換内部用
        /// </summary>
        /// <param name="objVarArray">object型配列</param>
        /// <param name="strIndent">再帰時のインデント文字列引継ぎ</param>
        /// <returns>変換結果文字列</returns>
        private static string convertStringFromVarArray(object[] objVarArray, string strIndent)
        {
            try
            {
                const string strLabelNull = "<NULL>";
                const string strLabelCollections = "<COLLECTION>";
                const string strLabelCollection = "<COLLECTION_ITEM>";
                const string strLabelArray = "<ARRAY>";
                const string strRetCode = "\r\n";
                const string strIndentChar = "    ";
                const string strNumberingFormat = "{0:D2}: ";

                string strResult = "";
                VBA.Collection colElement;

                object[] objChildArray;
                Array arrChild;

                object objColIndex;
                int iLineIndex = 0;

                foreach (object objElement in objVarArray)
                {
                    // インデント（再帰時）
                    strResult += strIndent;

                    // ナンバリング
                    strResult += string.Format(strNumberingFormat, iLineIndex);
                    iLineIndex++;

                    if (objElement == null)
                    {
                        // 値がNULLのときはNULLラベルを出力
                        strResult += strLabelNull + strRetCode;
                    }
                    else
                    {
                        switch (Information.VarType(objElement))
                        {
                            case VariantType.Object:
                                //// collectionオブジェクトの入れ子に対応

                                // コレクションラベルを出力
                                strResult += strLabelCollections + strRetCode;

                                // collectionオブジェクトの入れ子に対応
                                colElement = (VBA.Collection)objElement;

                                // object配列に展開
                                for (int i = 1; i <= colElement.Count(); i++)
                                {
                                    objColIndex = (object)i;

                                    // コレクションItemの中のArrayを取得
                                    arrChild = (Array)colElement.Item(ref objColIndex);

                                    // ArrayをObject配列に展開
                                    objChildArray = new object[arrChild.Length];
                                    for (int j = 0; j < arrChild.Length; j++)
                                    {
                                        objChildArray[j] = arrChild.GetValue(j);
                                    }
                                    // コレクションアイテムナンバリング
                                    strResult += strIndent + strIndentChar + string.Format(strNumberingFormat, i);
                                    // コレクションアイテムラベルを出力
                                    strResult += strLabelCollection + strRetCode;
                                    // インデントして再帰処理
                                    strResult += convertStringFromVarArray(objChildArray, strIndent + strIndentChar + strIndentChar);

                                }
                                break;

                            case (VariantType)8201: //Object[]に対応
                                // アレイラベルを出力
                                strResult += strLabelArray + strRetCode;
                                // インデントして再帰処理
                                strResult += convertStringFromVarArray((object[])objElement, strIndent + strIndentChar + strIndentChar);
                                break;

                            case VariantType.Null:
                            case VariantType.Empty:
                                // 値がNULLのときはNULLラベルを出力
                                strResult += strLabelNull + strRetCode;
                                break;
                            default:
                                // そのまま出力
                                strResult += objElement.ToString() + strRetCode;
                                break;
                        }
                    }
                }
                return strResult;
            }
            catch
            {
                return string.Empty;
            }
        }
        //private static string convertStringFromVarArray(object[] objVarArray, string strIndent)
        //{
        //    try
        //    {
        //        const string strLabelNull = "<NULL>";
        //        const string strLabelCollection = "<COLLECTION>";
        //        const string strRetCode = "\r\n";
        //        const string strIndentChar = "    ";
        //        const string strNumberingFormat = "{0:D2}: ";

        //        string strResult = "";
        //        VBA.Collection colElement;
        //        object[] objChildArray;
        //        object objColIndex;
        //        int iLineIndex = 0;

        //        foreach (object objElement in objVarArray)
        //        {
        //            // インデント（再帰時）
        //            strResult += strIndent;

        //            // ナンバリング
        //            strResult += string.Format(strNumberingFormat, iLineIndex);
        //            iLineIndex++;

        //            if (objElement == null)
        //            {
        //                // 値がNULLのときはNULLラベルを出力
        //                strResult += strLabelNull + strRetCode;
        //            }
        //            else
        //            {
        //                switch (Information.VarType(objElement))
        //                {
        //                    case VariantType.Object:
        //                        // collectionオブジェクトの入れ子に対応
        //                        colElement = (VBA.Collection)objElement;
        //                        // object配列に展開
        //                        objChildArray = new object[colElement.Count()];
        //                        for (int i = 1; i <= colElement.Count(); i++)
        //                        {
        //                            objColIndex = (object)i;
        //                            objChildArray[i - 1] = colElement.Item(ref objColIndex);
        //                        }
        //                        // コレクションラベルを出力
        //                        strResult += strLabelCollection + strRetCode;
        //                        // インデントして再帰処理
        //                        strResult += convertStringFromVarArray(objChildArray, strIndent + strIndentChar);
        //                        break;
        //                    case VariantType.Null:
        //                    case VariantType.Empty:
        //                        // 値がNULLのときはNULLラベルを出力
        //                        strResult += strLabelNull + strRetCode;
        //                        break;
        //                    default:
        //                        // そのまま出力
        //                        strResult += objElement.ToString() + strRetCode;
        //                        break;
        //                }
        //            }
        //        }
        //        return strResult;
        //    }
        //    catch
        //    {
        //        return string.Empty;
        //    }
        //}

        /// <summary>
        /// ゼロパディングメソッド
        /// </summary>
        /// <param name="formatText">書式化指定</param>
        /// <param name="strValue">対象の値</param>
        /// <returns>処理結果文字列</returns>
        public static string formatString(string formatText, string strValue)
        {
            Int64 intValue;
            if (!Int64.TryParse(strValue, out intValue))
            {
                // 整数変換できなければ受け取ったまま返す
                return strValue;
            }
            else
            {
                // 指定桁数でゼロパディングして返す
                return string.Format(formatText, intValue);
            }
        }

        /// <summary>
        /// 泣き別れ防止Substring
        /// 対象文字列を先頭から指定バイト数分だけ切り出す
        /// この際、末尾文字の泣き別れを防ぐ
        /// </summary>
        /// <param name="strValue">対象文字列</param>
        /// <param name="intMaxByte">切り出しバイト数</param>
        /// <returns>切り出した文字列</returns>
        public static String SubstringSafe(String strValue, Int32 intMaxByte)
        {
            while (System.Text.Encoding.GetEncoding("Shift_JIS").GetByteCount(strValue) > intMaxByte)
            {
                strValue = strValue.Substring(0, strValue.Length - 1);
            }
            return strValue;
        }

        /// <summary>
        /// ダンプデータ生成
        /// </summary>
        /// <param name="strPatID">患者ID</param>
        /// <param name="dumpParam">ダンプパラメタクラス</param>
        /// <returns>ダンプ用のログフォーマットに文字した文字配列</returns>
        public static byte[] CreateDumpData(String strPatID, DumpParameter[] dumpParam)
        {
            // - 現在日時 -
            String strDumpData = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss\r\n");

            // - 患者ID -
            strDumpData += String.Format("【PATID】{0}\r\n", strPatID);

            // - ダンプの主要データ部生成
            strDumpData += CreateDumpMain(dumpParam);

            // DumpOutメソッド用なのでbyte配列で返す
            return Encoding.Default.GetBytes(strDumpData);
        }

        /// <summary>
        /// ダンプデータ生成
        /// </summary>
        /// <param name="strPatID">患者ID</param>
        /// <param name="strDialysisNo">透析番号</param>
        /// <param name="strEdition">版番</param>
        /// <param name="dumpParam">ダンプパラメタクラス</param>
        /// <returns>ダンプ用のログフォーマットに文字した文字配列</returns>
        public static byte[] CreateDumpData(String strPatID, String strDialysisNo, String strEdition, DumpParameter[] dumpParam)
        {
            // - 現在日時 -
            String strDumpData = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss\r\n");

            // - 患者ID -
            strDumpData += String.Format("【PATID】{0}\r\n", strPatID);

            // - 透析番号 -
            strDumpData += String.Format("【DIALYSIS_NO】{0}\r\n", strDialysisNo);

            // - 版番 -
            strDumpData += String.Format("【EDITION】{0}\r\n", strEdition);

            // ダンプの主要データ部生成
            strDumpData += CreateDumpMain(dumpParam);

            // DumpOutメソッド用なのでbyte配列で返す
            return Encoding.Default.GetBytes(strDumpData);
        }

        /// <summary>
        /// ダンプ主要データ生成
        /// </summary>
        /// <param name="dumpParam">ダンプパラメタクラス</param>
        /// <returns>主要データを成型した文字列</returns>
        private static String CreateDumpMain(DumpParameter[] dumpParam)
        {
            String strDumpData = "";

            // ダンプパラメータ配列を成型
            foreach (DumpParameter dumpParameter in dumpParam)
            {
                // - 処理タイトル -
                strDumpData += String.Format("【{0}】\r\n", dumpParameter.DataTitle);

                // - 送信データ -
                if (dumpParameter.SendData != null)
                {
                    strDumpData += "「送信データ」\r\n";
                    strDumpData += ConvertStringFromVarArray(dumpParameter.SendData);
                }

                // - 受信データ -
                if (dumpParameter.ReceiveData != null)
                {
                    strDumpData += "「受信データ」\r\n";
                    strDumpData += ConvertStringFromVarArray(dumpParameter.ReceiveData);
                }

                // - エラーコレクション -
                if (dumpParameter.ErrorData != null)
                {
                    strDumpData += "「エラーデータ」\r\n";
                    strDumpData += ConvertStringFromVarArray(dumpParameter.ErrorData);
                }

                // - 送受信結果 -
                if (dumpParameter.Result == true)
                {
                    strDumpData += "-- 処理成功 --\r\n";
                }
                else if (dumpParameter.Result == false)
                {
                    strDumpData += "-- 処理失敗 --\r\n";
                }
                else if (dumpParameter.Result == null)
                {
                    strDumpData += "-- 未処理 --\r\n";
                }

                strDumpData += "\r\n";
            }

            return strDumpData;
        }

        /// <summary>
        /// ライブラリ名(CSI提供ライブラリ)を設定値によって変える
        /// </summary>
        /// <param name="strLibType">基本となるライブラリ名</param>
        /// <returns>変更後のライブラリ名</returns>
        public static String GetLibName(string strLibName, string strLibType)
        {
            const string SETTING_VAL_PARTS  = "0";
            const string SETTING_VAL_JMS    = "1";
            const string PREFIX_PARTS       = "PARTS";
            const string PREFIX_JMS         = "JMS";

            string strRet = string.Empty;

            switch (strLibType)
            {
                case SETTING_VAL_PARTS:
                    strRet = PREFIX_PARTS + strLibName;
                    break;
                case SETTING_VAL_JMS:
                    strRet = PREFIX_JMS + strLibName;                    
                    break;
                default:
                    // ここに来る場合はエラー
                    strRet = "error";
                    break;
            }

            return strRet;
        }
        #endregion


        #region 部品関係メソッド

        /// <summary>
        /// COMオブジェクトへの参照を作成および取得する
        /// </summary>
        /// <param name="progId">作成するオブジェクトのプログラムID</param>
        /// <param name="serverName">
        /// オブジェクトが作成されるネットワーク サーバーの名前
        /// </param>
        /// <returns>作成されたCOMオブジェクト</returns>
        public static object CreateObject(string progId, string serverName)
        {
            Type t;
            if (serverName == null || serverName.Length == 0)
            {
                t = Type.GetTypeFromProgID(progId);
            }
            else
            {
                t = Type.GetTypeFromProgID(progId, serverName, true);
            }

            if (t == null)
            {
                //MessageBox.Show("プログラムIDからTypeオブジェクトが取得できません\nCOMが登録されていない可能性があります",
                //                "Rapper Class Error",
                //                MessageBoxButtons.OK,
                //                MessageBoxIcon.Error);
            }

            return Activator.CreateInstance(t);
        }

        /// <summary>
        /// COMオブジェクトへの参照を作成および取得する
        /// </summary>
        /// <param name="progId">作成するオブジェクトのプログラムID</param>
        /// <returns>作成されたCOMオブジェクト</returns>
        public static object CreateObject(string progId)
        {
            return CreateObject(progId, null);
        }

        /// <summary>
        /// 外部I/F部品の最後のエラー情報を取得
        /// </summary>
        /// <returns>書式化されたエラー文字列</returns>
        public static string GetLastErrorString()
        {
            int iCount = CSICommon.pGetERRCollectionCount();
            string strResult = "";

            if (0 < iCount)
            {
                object oColKey = string.Empty;
                string sErrLevel = string.Empty;
                string sErrCode = string.Empty;
                string sErrText = string.Empty;

                strResult = "";

                // ※複数エラーは区切り文字で連結して返す
                for (int i = 1; i <= iCount; i++)
                {
                    if (1 < i)
                    {
                        strResult += " / ";
                    }

                    CSICommon.pGetERRCollectionItem(i, ref sErrLevel, ref sErrCode, ref sErrText);
                    strResult += sErrCode + "(" + sErrLevel + ")" + sErrText;
                }
            }

            // [暫定対応] 2010/01/05 アラーム通知を考慮し、エラー情報からカンマを除去
            //return strResult;
            return strResult.Replace(",", "");
        }

        /// <summary>
        /// 外部I/F部品の最後のエラー情報を取得
        /// </summary>
        /// <returns>書式化されたエラー文字列</returns>
        public static string GetLastErrorString(ref string sErrLevel, ref string sErrCode, ref string sErrText)
        {
            int iCount = CSICommon.pGetERRCollectionCount();
            string strResult = "";

            if (0 < iCount)
            {
                object oColKey = string.Empty;
                sErrLevel = string.Empty;
                sErrCode = string.Empty;
                sErrText = string.Empty;

                strResult = "";

                // ※複数エラーは区切り文字で連結して返す
                for (int i = 1; i <= iCount; i++)
                {
                    if (1 < i)
                    {
                        strResult += " / ";
                    }

                    CSICommon.pGetERRCollectionItem(i, ref sErrLevel, ref sErrCode, ref sErrText);
                    strResult += sErrCode + "(" + sErrLevel + ")" + sErrText;
                }
            }

            // [暫定対応] 2010/01/05 アラーム通知を考慮し、エラー情報からカンマを除去
            //return strResult;
            return strResult.Replace(",", "");
        }


        /// <summary>
        /// パラメータで指定したエラーコードがエラーリスト内にあるか検索する
        /// </summary>
        /// <param name="strErrCode">エラーコード</param>
        /// <returns>true:有り/false:無し</returns>
        public static bool IsErrorCode(string strErrCode)
        {
            if (0 < CSICommon.pGetERRCollectionCount())
            {
                object oColKey = string.Empty;
                string sErrLevel = string.Empty;
                string sErrCode = string.Empty;
                string sErrText = string.Empty;

                for (int i = 1; i <= CSICommon.pGetERRCollectionCount(); i++)
                {
                    CSICommon.pGetERRCollectionItem(i, ref sErrLevel, ref sErrCode, ref sErrText);
                    // 指定されたエラーコードと比較する
                    if (sErrCode.Trim() == strErrCode)
                    {
                        // 一致するエラーコードを有り
                        return true;
                    }
                }
            }
            // 一致するエラーコードは無い
            return false;
        }

        /// <summary>
        /// データベースOPENメソッド
        /// </summary>
        /// <param name="objJMSCOMMON">ActiveXオブジェクト</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pDbOpen(object objCOMMON, ref object objDbObject, ref VBA.Collection colErr)
        {
            Type typCOMMON;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // object型インスタンス生成
            // ※DB接続オブジェクトを取得するためには、object型のインスタンスを渡す必要があるため
            // ※DB接続オブジェクトが取得できると、System.Object型→System.__ComObject型となる
            if (objDbObject == null)
            {
                objDbObject = new object();
            }

            // ライブラリのTypeを取得
            typCOMMON = objCOMMON.GetType();

            // パラメータをセット
            objs = new object[] { objDbObject, colErr };

            // パラメータバインディングを設定
            p = new ParameterModifier(2);
            p[0] = true;
            p[1] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typCOMMON.InvokeMember("pDbOpen",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objCOMMON,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);
            // 出力パラメータに値をセット
            objDbObject = objs[0];
            colErr = (VBA.Collection)objs[1];

            return blnResult;
        }

        /// <summary>
        /// データベースCLOSEメソッド
        /// </summary>
        /// <param name="objJMSCOMMON">ActiveXオブジェクト</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pDbClose(object objCOMMON, object objDbObject, ref VBA.Collection colErr)
        {
            return callMethodCommon("pDbClose", objCOMMON, objDbObject, ref colErr);
        }

        /// <summary>
        /// トランザクション開始メソッド
        /// </summary>
        /// <param name="objJMSCOMMON">ActiveXオブジェクト</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pDbBeginTrn(object objCOMMON, object objDbObject, ref VBA.Collection colErr)
        {
            return callMethodCommon("pDbBeginTrn", objCOMMON, objDbObject, ref colErr);
        }

        /// <summary>
        /// トランザクション終了メソッド
        /// </summary>
        /// <param name="objJMSCOMMON">ActiveXオブジェクト</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pDbCommitTrn(object objCOMMON, object objDbObject, ref VBA.Collection colErr)
        {
            return callMethodCommon("pDbCommitTrn", objCOMMON, objDbObject, ref colErr);
        }

        /// <summary>
        /// ロールバック処理メソッド
        /// </summary>
        /// <param name="objJMSCOMMON">ActiveXオブジェクト</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pDbRollBack(object objCOMMON, object objDbObject, ref VBA.Collection colErr)
        {
            return callMethodCommon("pDbRollBack", objCOMMON, objDbObject, ref colErr);
        }

        /// <summary>
        /// COMMONライブラリのメソッド呼び出し共通処理
        /// </summary>
        /// <param name="strMethodName">呼び出しメソッド名称</param>
        /// <param name="objJMSCOMMON">ActiveXオブジェクト</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <returns>正常終了／異常終了</returns>
        private static bool callMethodCommon(string strMethodName, object objCOMMON, object objDbObject, ref VBA.Collection colErr)
        {
            Type typCOMMON;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typCOMMON = objCOMMON.GetType();

            // パラメータをセット
            objs = new object[] { objDbObject, colErr };

            // パラメータバインディングを設定
            p = new ParameterModifier(2);
            p[1] = true;
            mods = new ParameterModifier[] { p };

            //bInRet = oJMSCOMMON.pDbClose(oDbObject, colERR);
            blnResult = (bool)typCOMMON.InvokeMember(strMethodName,
                                                     BindingFlags.InvokeMethod,
                                                     null,
                                                     objCOMMON,
                                                     objs,
                                                     mods,
                                                     null,
                                                     null);
            // 出力パラメータに値をセット
            colErr = (VBA.Collection)objs[1];

            return blnResult;
        }

        /// <summary>
        /// 患者属性情報検索メソッド
        /// </summary>
        /// <param name="objJMSPATSCH">ActiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="objPatsch">出力パラメータ</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pPatSch(object objPATSCH, object[] objInparam, ref object[] objPatsch, ref VBA.Collection colErr, object objDbObject)
        {
            Type typPATSCH;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typPATSCH = objPATSCH.GetType();

            // パラメータをセット
            objs = new object[] { objInparam, objPatsch, colErr, objDbObject };

            // パラメータバインディングを設定
            p = new ParameterModifier(4);
            p[1] = true;
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typPATSCH.InvokeMember("pPatSch",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objPATSCH,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値をセット
            objPatsch = (object[])objs[1];
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }

        /// <summary>
        /// 患者血液型検索メソッド
        /// </summary>
        /// <param name="objBLOODTYPE">AxtiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="objBloodtype">出力パラメータ</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了/異常終了</returns>
        public static bool pBloodType(object objBLOODTYPE, object[] objInparam, ref object[] objBloodtype, ref VBA.Collection colErr, object objDbObject)
        {
            Type typBLOODTYPE;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typBLOODTYPE = objBLOODTYPE.GetType();

            // パラメータを設定
            objs = new object[] { objInparam, objBloodtype, colErr, objDbObject };

            // パラメータバインディングを指定
            p = new ParameterModifier(4);
            p[1] = true;
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typBLOODTYPE.InvokeMember("pBloodType",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objBLOODTYPE,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値を設定
            objBloodtype = (object[])objs[1];
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }

        /// <summary>
        /// 患者感染症検索メソッド
        /// </summary>
        /// <param name="objINFECTION">ActiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="colInfection">出力パラメータ</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了/異常終了</returns>
        public static bool pInfection(object objINFECTION, object[] objInparam, ref VBA.Collection colInfection, ref VBA.Collection colErr, object objDbObject)
        {
            Type typINFECTION;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typINFECTION = objINFECTION.GetType();

            // パラメータを指定
            objs = new object[] { objInparam, colInfection, colErr, objDbObject };

            // パラメータバインディングを指定
            p = new ParameterModifier(4);
            p[1] = true;
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typINFECTION.InvokeMember("pInfection",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objINFECTION,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値を設定
            colInfection = (VBA.Collection)objs[1];
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }

        /// <summary>
        /// 患者在院情報検索メソッド
        /// </summary>
        /// <param name="objADMSCH">ActiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="objAdmsch">出力パラメータ</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了/異常終了</returns>
        public static bool pAdmSch(object objADMSCH, object[] objInparam, ref object[] objAdmsch, ref VBA.Collection colErr, object objDbObject)
        {
            Type typADMSCH;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typADMSCH = objADMSCH.GetType();

            // パラメータを指定
            objs = new object[] { objInparam, objAdmsch, colErr, objDbObject };

            // パラメータバインディングを指定
            p = new ParameterModifier(4);
            p[1] = true;
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typADMSCH.InvokeMember("pAdmSch",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objADMSCH,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値を設定
            objAdmsch = (object[])objs[1];
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }

        /// <summary>
        /// 患者識別情報出力メソッド
        /// </summary>
        /// <param name="objDIALYSIS">ActiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="colErr">エラー情報出力コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了/異常終了</returns>
        public static bool pDialysis(object objDIALYSIS, object[] objInparam, ref VBA.Collection colErr, object objDbObject)
        {
            Type typDIALYSIS;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typDIALYSIS = objDIALYSIS.GetType();

            // パラメータを指定
            objs = new object[] { objInparam, "", colErr, objDbObject };

            // パラメータバインディングを指定
            p = new ParameterModifier(4);
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typDIALYSIS.InvokeMember("pDialysis",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objDIALYSIS,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値を設定
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }

        /// <summary>
        /// 患者予約情報登録／変更メソッド
        /// </summary>
        /// <param name="objAPPPATIENT">ActiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="objOutparam">出力パラメータ</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pAppPatient(object objAPPPATIENT, object[] objInparam, ref object[] objOutparam, ref VBA.Collection colErr, object objDbObject)
        {
            Type typAPPPATIENT;          // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typAPPPATIENT = objAPPPATIENT.GetType();

            // パラメータをセット
            objs = new object[] { objInparam, objOutparam, colErr, objDbObject };

            // パラメータバインディングを設定
            p = new ParameterModifier(4);
            p[1] = true;
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typAPPPATIENT.InvokeMember("pAppPatient",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objAPPPATIENT,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値をセット
            objOutparam = (object[])objs[1];
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }

        /// <summary>
        /// 患者オーダ登録／変更メソッド
        /// </summary>
        /// <param name="objORDER">ActiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="objOutparam">出力パラメータ</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pOrder(object colORDER, VBA.Collection colInparam, ref object[] objOutparam, ref VBA.Collection colErr, object objDbObject)
        {
            Type typORDER;              // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typORDER = colORDER.GetType();

            // パラメータをセット
            objs = new object[] { colInparam, objOutparam, colErr, objDbObject };

            // パラメータバインディングを設定
            p = new ParameterModifier(4);
            p[1] = true;
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typORDER.InvokeMember("pOrder",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        colORDER,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値をセット
            objOutparam = (object[])objs[1];
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }

        /// <summary>
        /// 患者診療フリー登録／変更メソッド
        /// </summary>
        /// <param name="objEXAMFREE">ActiveXオブジェクト</param>
        /// <param name="objInparam">入力パラメータ</param>
        /// <param name="objOutparam">出力パラメータ</param>
        /// <param name="colErr">エラー情報コレクション</param>
        /// <param name="objDbObject">DB接続クラスオブジェクト</param>
        /// <returns>正常終了／異常終了</returns>
        public static bool pExamFree(object objEXAMFREE, object[] objInparam, ref object[] objOutparam, ref VBA.Collection colErr, object objDbObject)
        {
            Type typEXAMFREE;           // JMSCOMMONのTypeクラス
            object[] objs;              // パラメータ配列
            ParameterModifier p;        // パラメータバインディング指定
            ParameterModifier[] mods;   // パラメータバインディング配列
            bool blnResult;             // 戻り値

            // ライブラリのTypeを取得
            typEXAMFREE = objEXAMFREE.GetType();

            // パラメータをセット
            objs = new object[] { objInparam, objOutparam, colErr, objDbObject };

            // パラメータバインディングを設定
            p = new ParameterModifier(4);
            p[1] = true;
            p[2] = true;
            mods = new ParameterModifier[] { p };

            // メソッド呼び出し
            blnResult = (bool)typEXAMFREE.InvokeMember("pExamFree",
                                                        BindingFlags.InvokeMethod,
                                                        null,
                                                        objEXAMFREE,
                                                        objs,
                                                        mods,
                                                        null,
                                                        null);

            // 出力パラメータに値をセット
            objOutparam = (object[])objs[1];
            colErr = (VBA.Collection)objs[2];

            return blnResult;
        }
        #endregion
    }

    #region ダンプログデータクラス　※別ファイルにするのもなんなんでここに置く
    /// <summary>
    /// ダンプ出力メソッド用・送受信結果格納クラス　
    /// <para>MIRAIsとの受信結果をダンプする際に使用</para>
    /// </summary>
    public class DumpParameter
    {
        #region 変数定義
        /// <summary>
        /// 送受信データのタイトル
        /// </summary>
        private String _DataTitle = string.Empty;
        /// <summary>
        /// 入力パラメータ
        /// </summary>
        private Object[] _SendData = null;
        /// <summary>
        /// 出力パラメータ
        /// </summary>
        private Object[] _ReceiveData = null;
        /// <summary>
        /// エラーコレクション
        /// </summary>
        private VBA.Collection _ErrorData = null;
        /// <summary>
        /// 送受信の結果
        /// </summary>
        private Nullable<bool> _bolResult = null;
        #endregion

        #region プロパティ
        /// <summary>
        /// 送受信データのタイトル
        /// </summary>
        public String DataTitle
        {
            get { return _DataTitle; }
            set { this._DataTitle = value; }
        }
        /// <summary>
        /// 入力パラメータ
        /// </summary>
        public Object[] SendData
        {
            get { return _SendData; }
            set { this._SendData = value; }
        }
        /// <summary>
        /// 出力パラメータ
        /// </summary>
        public Object[] ReceiveData
        {
            get { return _ReceiveData; }
            set { this._ReceiveData = value; }
        }
        /// <summary>
        /// エラーコレクション
        /// </summary>
        public VBA.Collection ErrorData
        {
            get { return _ErrorData; }
            set { this._ErrorData = value; }
        }
        /// <summary>
        /// 送受信の結果
        /// </summary>
        public Nullable<bool> Result
        {
            get { return _bolResult; }
            set { this._bolResult = value; }
        }
        #endregion

        #region コンストラクタ
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public DumpParameter() { }
        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="dataTitle">ダンプデータのタイトル</param>
        /// <param name="SendData">送信データ(未処理の場合はnull)</param>
        /// <param name="outParam">受信データ(未処理の場合はnull)</param>
        /// <param name="errorData">エラーコレクション(未処理の場合はnull)</param>
        /// <param name="isSuccess">処理結果 true:成功/false:失敗/null:未処理</param>
        public DumpParameter(String dataTitle, Object[] sendData, Object[] receiveData, VBA.Collection errorData, Nullable<bool> bolResult)
        {
            this.DataTitle = dataTitle;
            this.SendData = sendData;
            this.ReceiveData = receiveData;
            this.ErrorData = errorData;
            this.Result = bolResult;
        }
        #endregion
    }
    #endregion 
}
