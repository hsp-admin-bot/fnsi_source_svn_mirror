///////////////////////////////////////////////////////////////////////////////
// 
// システム名 ： FutureNet Ⅲ
// 
// 機  能  名 ： 検査結果情報の受信機能
// 
// ファイル名 ： CSICoopExaminRcvStdSub.cs
// 
// 説      明 ： CSICoopExaminRcvStdのPartialクラスです。
//               サブルーチンとなるプライベートメソッドを定義します。
// 
// Copyright(C) 2008 NIKKISO CO., LTD. All Right Reserved
// 
// ＜更新履歴＞
// 
//   日付        担当        内容
//   ----------  ----------  ------------------------------------------------
//   2009/12/07  森山俊介    新規作成
//   2010/03/10  飛田隆太    大幅改修、取り込み仕様を大きく変更
// 
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Xml;
using System.IO;
using System.Collections;
using System.Data.OracleClient;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    partial class CSICoopExaminRcvStd
    {
        #region データクラス

        /// <summary>
        /// 検査結果情報クラス
        /// </summary>
        private class ExamInfo
        {
            #region メンバ定義

            private List<decimal> _lstSeqNumbers = new List<decimal>();
            private String _COLLECTDATE = "";
            private String _COLLECTTIME = "";
            private List<String> _lstSPECIMENCODE = new List<String>();
            private String _MIRAIsPatID = "";
            private String _PatID = "";
            private String _PatName = "";
            private DateTime _ExamDate = DateTime.MinValue;
            private String _OrderClass = "";

            #endregion

            #region プロパティ

            /// <summary>
            /// シーケンス番号
            /// </summary>
            public List<decimal> lstSeqNumbers
            {
                get { return this._lstSeqNumbers; }
            }

            /// <summary>
            /// 採取日(MIRAIs)
            /// </summary>
            public String COLLECTDATE
            {
                get { return this._COLLECTDATE; }
                set { this._COLLECTDATE = value; }
            }

            /// <summary>
            /// 採取時間(MIRAIs)
            /// </summary>
            public String COLLECTTIME
            {
                get { return this._COLLECTTIME; }
                set { this._COLLECTTIME = value; }
            }

            /// <summary>
            /// 検体番号(MIRAIs)
            /// </summary>
            public List<String> lstSPECIMENCODE
            {
                get { return this._lstSPECIMENCODE; }
            }

            /// <summary>
            /// MIRAIs患者ID
            /// </summary>
            public string MIRAIsPatID
            {
                get { return this._MIRAIsPatID; }
                set { this._MIRAIsPatID = value; }
            }

            /// <summary>
            /// 患者ID
            /// </summary>
            public string PatID
            {
                get { return this._PatID; }
                set { this._PatID = value; }
            }

            /// <summary>
            /// 表示用患者ID
            /// </summary>
            public string DispPatID
            {
                get { return this._MIRAIsPatID.PadLeft(12, '0'); }
            }

            /// <summary>
            /// 患者名
            /// </summary>
            public string PatName
            {
                get { return this._PatName; }
                set { this._PatName = value; }
            }

            /// <summary>
            /// 検査日時
            /// </summary>
            public DateTime ExamDate
            {
                get { return this._ExamDate; }
                set { this._ExamDate = value; }
            }

            /// <summary>
            /// 検査区分
            /// </summary>
            public string OrderClass
            {
                get { return this._OrderClass; }
                set { this._OrderClass = value; }
            }

            #endregion

            #region メソッド

            /// <summary>
            /// コンストラクタ
            /// </summary>
            public ExamInfo()
            {
            }

            #endregion
        }

        #endregion

        #region 共通メソッド

        // 2013/08/22 中村 １日複数回取込対応 Chg Start
        /// <summary>
        /// 指定された時刻までのトータルミリ秒数を取得します。
        /// </summary>
        /// <param name="listExecuteTime">実施時刻リスト。</param>
        /// <returns>指定時刻までのトータルミリ秒数。</returns>
        /// <remarks>
        /// パラメータ dt からは時刻情報のみを参照します。
        /// 現在時刻が指定された時刻を過ぎている場合は、翌日の指定時刻までのトータルミリ秒数を返します。
        /// </remarks>
        private double GetMSecOfUntilSpecifiedTime(List<DateTime> listExecuteTime)
        {

            DateTime time = listExecuteTime[0];
            DateTime dtNow = DateTime.Now;
            foreach (DateTime dtVal in listExecuteTime)
            {
                if (dtVal >= dtNow)
                {
                    time = dtVal;
                    break;
                }
            }

            // 目的時刻を作成
            DateTime dt = DateTime.Today + time.TimeOfDay;

            // 現在時刻が目的時刻を過ぎている場合は翌日の同時刻を目的時刻とする
            if (dt < DateTime.Now)
            {
                dt = dt.AddDays(1);
            }

            // 目的時刻までのトータルミリ秒数を算出
            TimeSpan ts = dt - DateTime.Now;

            return ts.TotalMilliseconds;
        }
        // 2013/08/22 中村 １日複数回取込対応 Add End

        #endregion


        #region MIRAIsデータベース関連

        /// <summary>
        /// MIRAIsデータベースより検査結果情報を取得します。
        /// </summary>
        /// <param name="oraConnection">Oracleコネクションオブジェクト。</param>
        /// <param name="dsExaminData">検査結果を格納するデータセットオブジェクト。</param>
        /// <returns><see cref="Fn3ReturnCode"/> 値の 1 つ。</returns>
        private Fn3ReturnCode GetExaminationData(OracleConnection oraConnection, out DataSet dsExaminData)
        {
            Fn3ReturnCode retCode;

            OracleCommand oraCommand = new OracleCommand();
            OracleDataAdapter oraAdapter = new OracleDataAdapter();

            dsExaminData = new DataSet();

            // -------------------------------------
            // SQL文字列の作成
            // ------------------------------------

            // 検査結果紹介サマリ＆検査結果紹介詳細
            // 患者、採取日、採取時間、検体番号毎にシーケンスが最大のレコードを抽出する
            // ※最新の検査結果が抽出されることになる。
            StringBuilder sbExamin = new StringBuilder();
            sbExamin.Append("SELECT");
            sbExamin.Append("  B.SEQNO,");
            sbExamin.Append("  B.PATIENTNO,");
            sbExamin.Append("  B.COLLECTDATE,");
            sbExamin.Append("  B.COLLECTTIME,");
            sbExamin.Append("  B.SPECIMENCODE,");
            sbExamin.Append("  B.ORDERCOMMENT1,");
            sbExamin.Append("  (SELECT COMMENTNAME FROM MIRAI.M_RESULTCOMMENT WHERE B.ORDERCOMMENT1 = COMMENTCODE) COMMENTNAME1,");
            sbExamin.Append("  B.ORDERCOMMENT2,");
            sbExamin.Append("  (SELECT COMMENTNAME FROM MIRAI.M_RESULTCOMMENT WHERE B.ORDERCOMMENT2 = COMMENTCODE) COMMENTNAME2,");
            sbExamin.Append("  B.ORDERCOMMENTFREE,");
            sbExamin.Append("  C.TESTITEMCODE,");
            sbExamin.Append("  C.EDITORIALRESULT ");
            sbExamin.Append("FROM");
            sbExamin.Append("  (SELECT PATIENTNO, COLLECTDATE, COLLECTTIME, SPECIMENCODE, MAX(SEQNO) SEQNO FROM MIRAI.B_DIARESSUMMARY GROUP BY PATIENTNO, COLLECTDATE, COLLECTTIME, SPECIMENCODE) A,");
            sbExamin.Append("  (SELECT PATIENTNO, COLLECTDATE, COLLECTTIME, SPECIMENCODE, SEQNO, ORDERCOMMENT1, ORDERCOMMENT2, ORDERCOMMENTFREE FROM MIRAI.B_DIARESSUMMARY) B,");
            sbExamin.Append("  (SELECT SEQNO, TESTITEMCODE, EDITORIALRESULT FROM MIRAI.B_DIARESDETAIL) C ");
            sbExamin.Append("WHERE");
            sbExamin.Append("  B.SEQNO = A.SEQNO");
            sbExamin.Append("  AND");
            sbExamin.Append("  C.SEQNO = A.SEQNO ");
            sbExamin.Append("ORDER BY");
            sbExamin.Append("  B.SEQNO");

            // -------------------------------------
            // SQLクエリの実行
            // -------------------------------------
            try
            {
                oraCommand.Connection = oraConnection;

                // 検査結果情報の取得
                oraCommand.CommandText = sbExamin.ToString();
                oraAdapter.SelectCommand = oraCommand;
                try
                {
                    // データアダプタによるSQLステートメントの実行
                    oraAdapter.Fill(dsExaminData, "ExaminData");
                }
                catch (Exception ex2)
                {
                    retCode = CSIReturnCode.FTL_EXAMIN_RCV_DBQUERY;
                    this.ErrorTraceOut(retCode, ex2, string.Format("SQL String : {0}", sbExamin.ToString()));

                    return retCode;
                }
            }
            finally
            {
                oraAdapter.Dispose();
                oraCommand.Dispose();
            }

            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// MIRAISデータベースから検査結果情報を削除します。
        /// 同一の患者、採取日、採取時間、検査区分単位で削除する
        /// </summary>
        /// <param name="oraConnection">Oracleコネクションオブジェクト。</param>
        /// <param name="eiExamInfo">検査結果情報</param>
        /// <returns><see cref="Fn3ReturnCode"/> 値の 1 つ。</returns>
        private Fn3ReturnCode DeleteExaminationData(OracleConnection oraConnection, ExamInfo eiExamInfo)
        {
            Fn3ReturnCode retCode;

            // -------------------------------------
            // SQL文字列の作成
            // -------------------------------------
            StringBuilder sbWhere = new StringBuilder();
            sbWhere.Append(string.Format("PATIENTNO='{0}'", eiExamInfo.MIRAIsPatID));
            sbWhere.Append(string.Format(" AND COLLECTDATE='{0}'", eiExamInfo.COLLECTDATE));
            sbWhere.Append(string.Format(" AND COLLECTTIME='{0}'", eiExamInfo.COLLECTTIME));
            string strTemp = "";
            foreach (string strSPECIMENCODE in eiExamInfo.lstSPECIMENCODE)
            {
// >>>>>【Ver.5.0.0.102】2010.07.08（R.Tobita）検体番号が文字列の場合、取り込み済みレコードを削除できない不具合修正
                //strTemp += strSPECIMENCODE + ",";
                strTemp += "'" + strSPECIMENCODE + "'" + ",";
// <<<<<【Ver.5.0.0.102】2010.07.08（R.Tobita）検体番号が文字列の場合、取り込み済みレコードを削除できない不具合修正
            }
            sbWhere.Append(string.Format(" AND SPECIMENCODE IN ({0})", strTemp.TrimEnd(',')));
            // 結果照会サマリ
            StringBuilder sbDeleteDiaresSummary = new StringBuilder();
            sbDeleteDiaresSummary.Append(string.Format("DELETE FROM MIRAI.B_DIARESSUMMARY WHERE {0}", sbWhere));
            // 結果照会詳細
            StringBuilder sbDeleteDiaresDetail = new StringBuilder();
            sbDeleteDiaresDetail.Append(string.Format("DELETE FROM MIRAI.B_DIARESDETAIL WHERE {0}", sbWhere));
            // 結果照会詳細コメント
            StringBuilder sbDeleteDiaresDetailComment = new StringBuilder();
            sbDeleteDiaresDetailComment.Append(string.Format("DELETE FROM MIRAI.B_DIARESDETAILCOMMENT WHERE {0}", sbWhere));

            // -------------------------------------
            // トランザクション開始
            // -------------------------------------
            OracleTransaction oraTransaction;
            try
            {
                oraTransaction = oraConnection.BeginTransaction();
            }
            catch (Exception ex1)
            {
                retCode = CSIReturnCode.FTL_EXAMIN_RCV_DBTRANSACTION;
                this.ErrorTraceOut(retCode, ex1);

                return retCode;
            }

            // -------------------------------------
            // ステートメント実行
            // -------------------------------------
            OracleCommand oraCommand = new OracleCommand();
            oraCommand.Connection = oraConnection;
            oraCommand.Transaction = oraTransaction;

            try
            {
                // 結果照会サマリテーブルからの削除
                try
                {
                    oraCommand.CommandText = sbDeleteDiaresSummary.ToString();

                    if (oraCommand.ExecuteNonQuery() <= 0)
                    {
                        // 削除されなかった(ログ出力して処理続行)
                        this.TraceOut(CSIReturnCode.WNG_EXAMIN_RCV_NOTREMOVED, string.Format("SQL String : {0}", oraCommand.CommandText));
                    }
                }
                catch (Exception ex2)
                {
                    // ログ出力
                    retCode = CSIReturnCode.FTL_EXAMIN_RCV_DBEXECUTE;
                    this.ErrorTraceOut(retCode, ex2, string.Format("SQL String : {0}", sbDeleteDiaresSummary.ToString()));

                    // ロールバック
                    try
                    {
                        oraTransaction.Rollback();
                    }
                    catch (Exception ex3)
                    {
                        // ロールバックに失敗(ログ出力して処理続行)
                        this.ErrorTraceOut(CSIReturnCode.FTL_EXAMIN_RCV_DBEXECUTE, ex3);
                    }

                    return retCode;
                }

                // 結果照会詳細テーブルからの削除
                try
                {
                    oraCommand.CommandText = sbDeleteDiaresDetail.ToString();

                    if (oraCommand.ExecuteNonQuery() <= 0)
                    {
                        // 削除されなかった(ログ出力して処理続行)
                        this.TraceOut(CSIReturnCode.WNG_EXAMIN_RCV_NOTREMOVED, string.Format("SQL String : {0}", oraCommand.CommandText));
                    }
                }
                catch (Exception ex4)
                {
                    // ログ出力
                    retCode = CSIReturnCode.FTL_EXAMIN_RCV_DBEXECUTE;
                    this.ErrorTraceOut(retCode, ex4, string.Format("SQL String : {0}", sbDeleteDiaresDetail.ToString()));

                    // ロールバック
                    try
                    {
                        oraTransaction.Rollback();
                    }
                    catch (Exception ex5)
                    {
                        // ロールバックに失敗(ログ出力して処理続行)
                        this.ErrorTraceOut(CSIReturnCode.FTL_EXAMIN_RCV_DBEXECUTE, ex5);
                    }

                    return retCode;
                }

                // 結果照会詳細コメントテーブルからの削除
                try
                {
                    oraCommand.CommandText = sbDeleteDiaresDetailComment.ToString();

                    if (oraCommand.ExecuteNonQuery() <= 0)
                    {
                        // 削除されなかった(データ無しのケースもあるためログ出力しない)
                    }
                }
                catch (Exception ex6)
                {
                    // ログ出力
                    retCode = CSIReturnCode.FTL_EXAMIN_RCV_DBEXECUTE;
                    this.ErrorTraceOut(retCode, ex6, string.Format("SQL String : {0}", sbDeleteDiaresDetailComment.ToString()));

                    // ロールバック
                    try
                    {
                        oraTransaction.Rollback();
                    }
                    catch (Exception ex7)
                    {
                        // ロールバックに失敗(ログ出力して処理続行)
                        this.ErrorTraceOut(CSIReturnCode.FTL_EXAMIN_RCV_DBEXECUTE, ex7);
                    }

                    return retCode;
                }

                // コミット
                try
                {
                    oraTransaction.Commit();
                }
                catch (Exception ex8)
                {
                    // コミットに失敗
                    retCode = CSIReturnCode.FTL_EXAMIN_RCV_DBEXECUTE;
                    this.ErrorTraceOut(retCode, ex8);

                    return retCode;
                }
            }
            finally
            {
                oraCommand.Dispose();
                oraTransaction.Dispose();
            }

            return Fn3ReturnCode.Success;
        }

        #endregion


        #region FNデータベース関連

        /// <summary>
        /// 検査結果情報リスト生成
        /// MRIAIsより取得した検査結果より、FNWに登録すべき検査結果の情報リストを生成する。
        /// ※FNWに存在しない患者はリストに登録しない
        /// </summary>
        /// <param name="dsExaminData">MIRAIsより取得した検査結果情報</param>
        /// <param name="lstExamInfos">検査結果情報リスト</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode CreateExamInfoList(DataSet dsExaminData, ref List<ExamInfo> lstExamInfos)
        {
            // 検査結果の件数分ループ
            foreach (DataRow drExamData in dsExaminData.Tables["ExaminData"].Rows)
            {
                // 検査情報の取り出し
                decimal decSeqNo = System.Convert.ToDecimal(drExamData["SEQNO"].ToString());
                String strMIRAIsPatID = drExamData["PATIENTNO"].ToString();
                String strCOLLECTDATE = drExamData["COLLECTDATE"].ToString();
                String strCOLLECTTIME = drExamData["COLLECTTIME"].ToString();
                String strSPECIMENCODE = drExamData["SPECIMENCODE"].ToString();
                String strOrderComment1 = !drExamData.IsNull("ORDERCOMMENT1") ? drExamData["ORDERCOMMENT1"].ToString() : "";
                String strOrderComment2 = !drExamData.IsNull("ORDERCOMMENT2") ? drExamData["ORDERCOMMENT2"].ToString() : "";

                #region 患者情報の取得
                String strDispPatID = string.Empty;
                String strPatID = string.Empty;
                String strPatName = string.Empty;

                // 表示用患者IDの取得(前ゼロ埋め12桁とする)
                strDispPatID = strMIRAIsPatID.PadLeft(12, '0');

                //// 既に患者情報を取得済みの場合
                //if (lstExamInfos.Exists(match => match.DispPatID.Equals(strDispPatID)))
                //{
                //    // 取得済み検査結果情報から患者ID、患者名を取得
                //    ExamInfo eiExamInfo = lstExamInfos.Find(match => match.DispPatID.Equals(strDispPatID));
                //    strPatID = eiExamInfo.PatID;
                //    strPatName = eiExamInfo.PatName;
                //}
                //// 患者情報取得
                //else
                //{
                //    // 入力XML生成
                //    StringBuilder sbInXml = new StringBuilder();
                //    XmlWriterSettings xmwSetting = new XmlWriterSettings();
                //    xmwSetting.OmitXmlDeclaration = true;
                //    XmlWriter xwInXmlWriter = XmlWriter.Create(sbInXml, xmwSetting);
                //    xwInXmlWriter.WriteStartElement("rootNode");
                //    xwInXmlWriter.WriteElementString("DISP_PATID", strDispPatID);
                //    xwInXmlWriter.WriteEndElement();
                //    xwInXmlWriter.Flush();
                //    xwInXmlWriter.Close();

                //    // 患者取得実施
                //    String strResultXml = "";
                //    Fn3ReturnCode retCodeGetPatient = base.DBSelectCoopInfo("患者情報受信", sbInXml.ToString(), ref strResultXml);
                //    if (retCodeGetPatient.IsError || retCodeGetPatient.IsException)
                //    {
                //        // [トレースログ]患者取得失敗
                //        base.TraceOut(CSIReturnCode.ERR_EXAMIN_RCV_GETPATIENTINFO, retCodeGetPatient.Message);

                //        // [アラーム]患者取得失敗
                //        base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, strDispPatID, "", CSIReturnCode.ERR_EXAMIN_RCV_GETPATIENTINFO);

                //        // [エラー]患者取得失敗
                //        return CSIReturnCode.ERR_EXAMIN_RCV_GETPATIENTINFO;
                //    }

                //    // 対象患者がFNWに存在しない場合
                //    XmlDocument xmlPatInfo = new XmlDocument();
                //    xmlPatInfo.LoadXml(strResultXml);
                //    if (xmlPatInfo.InnerText.Equals(""))
                //    {
                //        // [トレースログ]処理対象外
                //        base.TraceOut(CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR +
                //                      string.Format("該当患者がFNWに存在しないため、FNWへの取込み、及びMIRAIsデータの削除を行いませんでした。 表示用患者ID：{0}", strDispPatID));

                //        // 存在しない患者の検査結果は処理しない
                //        continue;
                //    }

                //    // 患者ID取得
                //    XmlNode nodePatID = xmlPatInfo.SelectSingleNode("//rootNode/PAT_BASIC_INFO/PATID");
                //    strPatID = (nodePatID != null) ? nodePatID.InnerText : "";
                //    // 患者名取得
                //    XmlNode nodePatName = xmlPatInfo.SelectSingleNode("//rootNode/PAT_BASIC_INFO/NAME");
                //    strPatName = (nodePatName != null) ? nodePatName.InnerText : "";
                //}
                #endregion

                #region 登録時検査日時の取得
                // 2013/04/23 中村 採取日・採取時間のNULL考慮 Chg Start
                if ((strCOLLECTDATE.Length != 8) || (strCOLLECTTIME.Length != 4))
                {
                    base.TraceOut(CSIReturnCode.WNG_EXAMIN_RCV_GETEXAMDATE, string.Format("採取日：{0}、採取時間：{1}", strCOLLECTDATE, strCOLLECTTIME));
                    continue;
                }

                DateTime dtmExamDate;
                try
                {
                    // 検査結果の採取日、採取時間を登録時検査日時とする
                    dtmExamDate = new DateTime(System.Convert.ToInt32(strCOLLECTDATE.Substring(0, 4)),
                                               System.Convert.ToInt32(strCOLLECTDATE.Substring(4, 2)),
                                               System.Convert.ToInt32(strCOLLECTDATE.Substring(6, 2)),
                                               System.Convert.ToInt32(strCOLLECTTIME.Substring(0, 2)),
                                               System.Convert.ToInt32(strCOLLECTTIME.Substring(2, 2)),
                                               0);
                }
                catch
                {
                    base.TraceOut(CSIReturnCode.WNG_EXAMIN_RCV_GETEXAMDATE, string.Format("採取日：{0}、採取時間：{1}", strCOLLECTDATE, strCOLLECTTIME));
                    continue;
                }
                // 2013/04/23 中村 採取日・採取時間のNULL考慮 Chg End
                #endregion

                #region 登録時検査区分の取得
                // サマリのオーダ依頼コメント1、2を検査区分の候補とする
                String strOrderClass;
                String strConvedOrderClass1 = "";
                String strConvedOrderClass2 = "";

                // 検査区分変換実施(0:透析前/1:透析後/2:その他)
                bool isOrderClass1 = this.IsExamOrderClass(strOrderComment1, ref strConvedOrderClass1);
                bool isOrderClass2 = this.IsExamOrderClass(strOrderComment2, ref strConvedOrderClass2);

                // オーダ依頼コメント1、2のいづれも検査区分に変換できなかった場合
                if (isOrderClass1.Equals(false) && isOrderClass2.Equals(false))
                {
                    // 想定外(未設定)のため"その他"
                    strOrderClass = "2";
                    this.TraceOut(CSICommonConst.MODULE_MNAME_ER + 
                                  CSICommonConst.LOGTYPE_ERR + 
                                  String.Format("対応する変換コードがないため、{0}を設定します。（Section={1} /key=\"{2},{3}\"）", "その他", ConvertItem.ExaminOrderClassToFNW.ToString(), strOrderComment1, strOrderComment2));
                }
                // オーダ依頼コメント1が検査区分に変換できた場合
                else if (isOrderClass1.Equals(true) && isOrderClass2.Equals(false))
                {
                    // 検査区分を設定
                    strOrderClass = strConvedOrderClass1;
                }
                // オーダ依頼コメント2が検査区分に変換できた場合
                else if (isOrderClass2.Equals(true) && isOrderClass1.Equals(false))
                {
                    // 検査区分を設定
                    strOrderClass = strConvedOrderClass2;
                }
                // オーダ依頼コメント1、2の双方を検査区分に変換できた場合
                else
                {
                    // 同じ検査区分の場合
                    if (strConvedOrderClass1.Equals(strConvedOrderClass2))
                    {
                        // 検査区分を設定
                        strOrderClass = strConvedOrderClass1;
                    }
                    // 違う検査区分の場合
                    else
                    {
                        // 想定外(両方存在)のため"その他"
                        strOrderClass = "2";
                    }
                }
                #endregion

                #region 検査結果情報リストへ取り込み情報を登録
                // リストの1要素は、FNW側検査結果1件を表す
                // FNW側1検査結果につき、MIRAIs側検査結果はN件となる(Nはシーケンス番号=検体番号)

                // 患者、登録時検査日時、登録時検査区分が同一の情報が既に登録されている場合
                if (lstExamInfos.Exists(match => match.DispPatID.Equals(strDispPatID) && match.ExamDate.Equals(dtmExamDate) && match.OrderClass.Equals(strOrderClass)))
                {
                    // 該当検査結果情報の取り込み対象としてシーケンス番号、検体番号を登録
                    ExamInfo eiExamInfo = lstExamInfos.Find(match => match.DispPatID.Equals(strDispPatID) && match.ExamDate.Equals(dtmExamDate) && match.OrderClass.Equals(strOrderClass));
                    if (!eiExamInfo.lstSeqNumbers.Exists(match => match.Equals(decSeqNo)))
                    {
                        eiExamInfo.lstSeqNumbers.Add(decSeqNo);
                    }
                    if (!eiExamInfo.lstSPECIMENCODE.Exists(match => match.Equals(strSPECIMENCODE)))
                    {
                        eiExamInfo.lstSPECIMENCODE.Add(strSPECIMENCODE);
                    }
                }
                // 未登録の場合
                else
                {
                    // 検査結果情報を登録
                    ExamInfo eiExamInfo = new ExamInfo();

                    // シーケンス番号
                    eiExamInfo.lstSeqNumbers.Add(decSeqNo);
                    // MIRAIs側採取日
                    eiExamInfo.COLLECTDATE = strCOLLECTDATE;
                    // MIRAIs側採取時間
                    eiExamInfo.COLLECTTIME = strCOLLECTTIME;
                    // MIRAIs側検体番号
                    eiExamInfo.lstSPECIMENCODE.Add(strSPECIMENCODE);
                    // MIRAIs側患者ID
                    eiExamInfo.MIRAIsPatID = strMIRAIsPatID;
                    // FNW側患者ID
                    eiExamInfo.PatID = strPatID;
                    // 患者氏名
                    eiExamInfo.PatName = strPatName;
                    // 登録時検査日時
                    eiExamInfo.ExamDate = dtmExamDate;
                    // 登録時検査区分
                    eiExamInfo.OrderClass = strOrderClass;

                    lstExamInfos.Add(eiExamInfo);
                }
                #endregion
            }

            // リスト生成成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// FNデータベースへ検査結果情報を登録します。
        /// </summary>
        /// <param name="dsExaminData">検査結果が格納されたデータセットオブジェクト。</param>
        /// <param name="eiExamInfo">検査結果情報</param>
        /// <returns><see cref="Fn3ReturnCode"/> 値の 1 つ。</returns>
        private Fn3ReturnCode UpdateExaminationData(DataSet dsExaminData, ExamInfo eiExamInfo)
        {
            Fn3ReturnCode retCode;

            // -------------------------------------
            // トランザクション開始
            // -------------------------------------
            retCode = this.DBTransaction();
            if (retCode.IsError || retCode.IsException)
            {
                // ログ出力
                this.TraceOut(CSIReturnCode.ERR_EXAMIN_RCV_TRANSACTION);
                this.TraceOut(retCode);
                return retCode;
            }

            // -------------------------------------
            // 検査結果情報更新
            // -------------------------------------
            int intUpdateCount = 0;

            // 検査結果情報更新用XML作成
            string xmlExaminInfo = this.CreateExaminInfoXML(dsExaminData, eiExamInfo);

            // DBの登録処理を実行する
            retCode = this.DBUpdateCoopInfo(this.FunctionName, xmlExaminInfo, ref intUpdateCount);
            if (retCode.IsError || retCode.IsException)
            {
                // ログ出力
                this.TraceOut(CSIReturnCode.ERR_EXAMIN_RCV_UPDATE);
                this.TraceOut(retCode, xmlExaminInfo);
                // ロールバック
                Fn3ReturnCode resCode = this.DBRollback();
                if (resCode.IsError || resCode.IsException)
                {
                    this.TraceOut(resCode);
                }

                return retCode;
            }

            // -------------------------------------
            // コミット
            // -------------------------------------
            retCode = this.DBCommit();
            if (retCode.IsError || retCode.IsException)
            {
                // ログ出力
                this.TraceOut(CSIReturnCode.ERR_EXAMIN_RCV_COMMIT);
                this.TraceOut(retCode);
                return retCode;
            }

            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 検査結果情報更新用のXML文字列を作成します。
        /// </summary>
        /// <param name="dsExaminData">検査結果が格納されたデータセットオブジェクト。</param>
        /// <param name="eiExamInfo">検査結果情報</param>
        /// <returns>検査情報更新用のXML文字列。</returns>
        private string CreateExaminInfoXML(DataSet dsExaminData, ExamInfo eiExamInfo)
        {
            // -------------------------------------
            // データ取得
            // -------------------------------------
            String strSelect = "";
            foreach (decimal decSeqNo in eiExamInfo.lstSeqNumbers)
            {
                strSelect += strSelect.Equals("") ? "" : " OR ";
                strSelect += String.Format("SEQNO = {0}", decSeqNo.ToString("0"));
            }
            DataRow[] drExamDatas = dsExaminData.Tables["ExaminData"].Select(strSelect);

            // -------------------------------------
            // XML作成
            // -------------------------------------

// >>>>>【Ver.5.0.0.101】2010.05.21（h.horiuchi）結果値に制御文字が含まれていると致命的エラー

            //StringBuilder sbXml = new StringBuilder();

            //sbXml.Append("<?xml version='1.0' encoding='SHIFT_JIS' ?>");
            //sbXml.Append("<rootNode>");

            ////＜検査結果＞
            //sbXml.Append("<RST_EXAMIN_HST>");

            //// 患者ID
            //sbXml.AppendFormat("<DISP_PATID>{0}</DISP_PATID>", eiExamInfo.DispPatID);
            //// 登録時検査日時
            //sbXml.AppendFormat("<REG_EXAM_DATE>{0}</REG_EXAM_DATE>", eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"));
            //// 登録時検査区分
            //sbXml.AppendFormat("<REG_ORDER_CLASS>{0}</REG_ORDER_CLASS>", eiExamInfo.OrderClass);

            //sbXml.Append("</RST_EXAMIN_HST>");

            ////＜検査結果詳細＞
            //for (int i = 0; i < drExamDatas.Length; i++)
            //{
            //    sbXml.AppendFormat("<RST_EXAMIN_HST_DETAIL ID=\"{0}\">", (i + 1).ToString());

            //    // 患者ID
            //    sbXml.AppendFormat("<DISP_PATID>{0}</DISP_PATID>", eiExamInfo.DispPatID);
            //    // 登録時検査日時
            //    sbXml.AppendFormat("<REG_EXAM_DATE>{0}</REG_EXAM_DATE>", eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"));
            //    // 登録時検査区分
            //    sbXml.AppendFormat("<REG_ORDER_CLASS>{0}</REG_ORDER_CLASS>", eiExamInfo.OrderClass);
            //    // 検査項目コード(取込み用標準院内コード)
            //    sbXml.AppendFormat("<IN_HOSPITAL_CD>{0}</IN_HOSPITAL_CD>", drExamDatas[i]["TESTITEMCODE"].ToString());
            //    // 検査結果
            //    sbXml.AppendFormat("<EXAM_RST>{0}</EXAM_RST>", drExamDatas[i]["EDITORIALRESULT"].ToString());
            //    // コメント(検査区分ではないオーダ依頼コメントとフリーを設定)
            //    String strOrderComment1 = !drExamDatas[i].IsNull("ORDERCOMMENT1") ? drExamDatas[i]["ORDERCOMMENT1"].ToString() : "";
            //    String strCommentName1 = !drExamDatas[i].IsNull("COMMENTNAME1") ? drExamDatas[i]["COMMENTNAME1"].ToString() : "";
            //    String strOrderComment2 = !drExamDatas[i].IsNull("ORDERCOMMENT2") ? drExamDatas[i]["ORDERCOMMENT2"].ToString() : "";
            //    String strCommentName2 = !drExamDatas[i].IsNull("COMMENTNAME2") ? drExamDatas[i]["COMMENTNAME2"].ToString() : "";
            //    String strOrderCommentFree = !drExamDatas[i].IsNull("ORDERCOMMENTFREE") ? drExamDatas[i]["ORDERCOMMENTFREE"].ToString() : "";
            //    String strTmpValue = "";
            //    String strBuff = "";
            //    if (!this.IsExamOrderClass(strOrderComment1, ref strBuff) && !strCommentName1.Equals(""))
            //    {
            //        strTmpValue = strCommentName1;
            //    }
            //    if (!this.IsExamOrderClass(strOrderComment2, ref strBuff) && !strCommentName2.Equals(""))
            //    {
            //        strTmpValue += strTmpValue.Equals("") ? strCommentName2 : this.strCommentSeparate + strCommentName2;
            //    }
            //    if (!strOrderCommentFree.Equals(""))
            //    {
            //        strTmpValue += strTmpValue.Equals("") ? strOrderCommentFree : this.strCommentSeparate + strOrderCommentFree;
            //    }
            //    sbXml.AppendFormat("<COMMENTS>{0}</COMMENTS>", strTmpValue);

            //    sbXml.Append("</RST_EXAMIN_HST_DETAIL>");
            //}

            //sbXml.Append("</rootNode>");

            //return sbXml.ToString();


			string strXml;

			using(StringWriter sw = new StringWriter())
            using (XmlTextWriter xml = new XmlTextWriter(sw))
            {

                xml.WriteStartElement("rootNode");

                //＜検査結果＞
                xml.WriteStartElement("RST_EXAMIN_HST");
                // 患者ID
                xml.WriteElementString("DISP_PATID", eiExamInfo.DispPatID);
                // 登録時検査日時
                xml.WriteElementString("REG_EXAM_DATE", eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"));
                // 登録時検査区分
                xml.WriteElementString("REG_ORDER_CLASS", eiExamInfo.OrderClass);

                xml.WriteEndElement();//"</RST_EXAMIN_HST>"

                //＜検査結果詳細＞
                for (int i = 0; i < drExamDatas.Length; i++)
                {
                    xml.WriteStartElement("RST_EXAMIN_HST_DETAIL");
                    xml.WriteAttributeString("ID", (i + 1).ToString());

                    // 患者ID
                    xml.WriteElementString("DISP_PATID", eiExamInfo.DispPatID);
                    // 登録時検査日時
                    xml.WriteElementString("REG_EXAM_DATE", eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"));
                    // 登録時検査区分
                    xml.WriteElementString("REG_ORDER_CLASS", eiExamInfo.OrderClass);
                    // 検査項目コード(取込み用標準院内コード)
                    xml.WriteElementString("IN_HOSPITAL_CD", drExamDatas[i]["TESTITEMCODE"].ToString());
                    // 検査結果
                    xml.WriteElementString("EXAM_RST", drExamDatas[i]["EDITORIALRESULT"].ToString());
                    // コメント(検査区分ではないオーダ依頼コメントとフリーを設定)
                    String strOrderComment1 = !drExamDatas[i].IsNull("ORDERCOMMENT1") ? drExamDatas[i]["ORDERCOMMENT1"].ToString() : "";
                    String strCommentName1 = !drExamDatas[i].IsNull("COMMENTNAME1") ? drExamDatas[i]["COMMENTNAME1"].ToString() : "";
                    String strOrderComment2 = !drExamDatas[i].IsNull("ORDERCOMMENT2") ? drExamDatas[i]["ORDERCOMMENT2"].ToString() : "";
                    String strCommentName2 = !drExamDatas[i].IsNull("COMMENTNAME2") ? drExamDatas[i]["COMMENTNAME2"].ToString() : "";
                    String strOrderCommentFree = !drExamDatas[i].IsNull("ORDERCOMMENTFREE") ? drExamDatas[i]["ORDERCOMMENTFREE"].ToString() : "";
                    String strTmpValue = "";
                    String strBuff = "";
                    if (!this.IsExamOrderClass(strOrderComment1, ref strBuff) && !strCommentName1.Equals(""))
                    {
                        strTmpValue = strCommentName1;
                    }
                    if (!this.IsExamOrderClass(strOrderComment2, ref strBuff) && !strCommentName2.Equals(""))
                    {
                        strTmpValue += strTmpValue.Equals("") ? strCommentName2 : this.strCommentSeparate + strCommentName2;
                    }
                    if (!strOrderCommentFree.Equals(""))
                    {
                        strTmpValue += strTmpValue.Equals("") ? strOrderCommentFree : this.strCommentSeparate + strOrderCommentFree;
                    }
                    xml.WriteElementString("COMMENTS", strTmpValue);

                    xml.WriteEndElement();	//	RST_EXAMIN_HST_DETAIL
                }

                xml.WriteEndElement();	//	rootNode

                strXml = sw.ToString();
            }
            return strXml;
// <<<<<【Ver.5.0.0.101】2010.05.21（h.horiuchi）結果値に制御文字が含まれていると致命的エラー

        }

        /// <summary>
        /// 検査区分チェック
        /// 対象コードが検査区分かどうか判定する
        /// ※検査区分の場合、変換後コードも返す
        /// </summary>
        /// <param name="strMIRAIsCode">MIRAIs側コード</param>
        /// <param name="strOrderClass">FNW側コード</param>
        /// <returns>検査区分である/検査区分ではない</returns>
        private bool IsExamOrderClass(String strMIRAIsCode, ref String strOrderClass)
        {
            Fn3ReturnCode retCodeConvert = this.Convert(ConvertItem.ExaminOrderClassToFNW, strMIRAIsCode, ref strOrderClass);
            if (retCodeConvert.IsSuccess)
            {
                // 検査区分である
                return true;
            }
            else
            {
                // 検索分ではない
                return false;
            }
        }

        #endregion

    }
}
