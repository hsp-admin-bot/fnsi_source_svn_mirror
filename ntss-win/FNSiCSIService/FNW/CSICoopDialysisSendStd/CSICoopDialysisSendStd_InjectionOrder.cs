///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：シーエスアイ標準連携　透析実績送信機能
// ファイル名：CSICoopDialysisSendStd_InjectionOrder.cs
// 説明      ：透析実績送信機能を提供する。※パーシャルクラス
//
//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2010/02/15	今井久雄   			新規作成
//  2011/01/07  中村圭之介          指示医を版確定者⇒患者基本情報.担当医に変更。
//  2011/01/11  中村圭之介          スタッフコード先頭0詰めなし対応
//  2011/01/21  中村圭之介          小数点以下の有効桁数対応
//  2011/05/13  中村圭之介          指示医対応（新里ﾒﾃﾞｨｹｱ版よりマージ）
//  2015/07/30  石川俊介            特殊浄化対応,ログ強化
//  2015/09/03  中村圭之介          受入指摘対応(Redmine#4953)
//  2020/07/31  Phan Hai Thach      Redmine#11191 透析終了日時は透析開始日時と同じようにする
//
///////////////////////////////////////////////////////////////////////////////
//#define WITHOUT_INTERFACE

using System;
using System.Collections.Generic;
using System.Xml;
using System.Collections;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using CSILib;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    public partial class Fn3CSICoopDialysisSendStd : Fn3ComPlugIn
    {
        #region メンバ定義・プライベート

        #region 注射オーダ・データクラス
        /// <summary>
        /// 汎用オーダ・ディテール作成用データクラス
        /// ※当初structだったが値の再代入が出来ないのでclassに変更する。
        /// </summary>
        private class InjectionDetailData
        {
            /// <summary>
            /// 手技コード
            /// </summary>
            public string ProcedureCode;
            /// <summary>
            /// ルート項目コード（手技マスタ・院内コード1）
            /// </summary>
            public string RouteCode;
            /// <summary>
            /// 投与方法項目コード（手技マスタ・院内コード2）
            /// </summary>
            public string MethodCode;
            /// <summary>
            /// 薬剤コード（薬剤マスタ・院内コード）
            /// </summary>
            public string InHospitalCode;
            /// <summary>
            /// 入力数量(数量）
            /// </summary>
            public string Amount;
            /// <summary>
            /// コンストラクタ
            /// </summary>
            /// <param name="strProcedureCode">手技コード</param>
            /// <param name="strRouteCode">ルート項目コード</param>
            /// <param name="strMethodCode">投与方法項目コード</param>
            /// <param name="strInHospitalCode">薬剤コード</param>
            /// <param name="strAmount">入力数量(</param>
            public InjectionDetailData(string strProcedureCode, string strRouteCode, string strMethodCode, string strInHospitalCode, string strAmount)
            {
                ProcedureCode = strProcedureCode;
                RouteCode = strRouteCode;
                MethodCode = strMethodCode;
                InHospitalCode = strInHospitalCode;
                Amount = strAmount;
            }
        }
        #endregion

        #endregion


        #region メソッド定義・プライベート

        #region 注射オーダ・メイン
        /// <summary>
        /// 注射オーダ・設定送信マネージャ
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="strRetOrederNo">オーダ番号（戻り値）</param>
        /// <returns>true:正常/false:異常</returns>
        private bool SendInjectionOrderMgr(Fn3ExecuteInfo exeInfo, out string strRetOrederNo, out bool bolRetry)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // -----------------------------------------------
            // 初期化
            // -----------------------------------------------
            CSICommon.ClearAllParameter();
            strRetOrederNo = NONE + "," + NONE;
            bolRetry = false;
            // -----------------------------------------------
            // 領域確保
            // -----------------------------------------------
            // オーダ領域
            CSICommon.varORDER = new object[14];
            // オーダヘッダ領域
            CSICommon.varHEADER = new object[31];
            // オーダグループ領域
            CSICommon.varGROUP = new object[40];
            // オーダディテール領域
            CSICommon.varDETAIL = new object[6];
            // アウトパラメータ領域
            CSICommon.varOUTPARAM = new object[8];

            // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
            m_blnInjectionNotDataFlag = false;
            // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応

            // --------------------------------------------------------------------------------------------------
            // ※注意！！ 注射オーダはイベントが上がってきてもデータが無いことがあるのでデータ有無の判定が必要
            // -------------------------------------------------------------------------------------------------
            // 状態により注射オーダデータの送信区分を変更する
            string strChangeSendClass = ChangeSendClass(exeInfo);
            if (strChangeSendClass != null)
            {
                // +++++++++++++++++++++++++++++++++++++++++++++++
                // ▼注射オーダデータを設定▼
                // +++++++++++++++++++++++++++++++++++++++++++++++
                bool bolSetData = SetInjectionOrder(exeInfo,
                                                    strChangeSendClass,
                                                    null);
                if (!bolSetData)
                {
                    // エラー（ログは下位で出力）
                    return false;
                }

#if !WITHOUT_INTERFACE
                // +++++++++++++++++++++++++++++++++++++++++++++++
                // ▼注射オーダデータを送信▼
                // +++++++++++++++++++++++++++++++++++++++++++++++
                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pOrder() Start");
                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                bool blnExec = CSICommonMethod.pOrder(m_objCSIORDERInjection,
                                                      CSICommon.colORDER,
                                                      ref CSICommon.varOUTPARAM,
                                                      ref CSICommon.colERR,
                                                      m_objMiraisDB);
                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pOrder() End");
                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
#else
                bool blnExec = true;
#endif

                if (!blnExec)
                {
                    // エラー
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDERINJECTION, CSICommonMethod.GetLastErrorString());
                    // エラーコードを判定
                    if (CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR1) ||
                        CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR2))
                    {
                        // 上記のエラーコードの場合はリトライフラグを立てる
                        bolRetry = true;
                    }
                    return false;
                }
                else
                {
                    // -----------------------------------------------
                    // 正常終了でもERRパラメータの中身を確認する
                    // -----------------------------------------------
                    if (CSICommon.pGetERRCollectionCount() > 0)
                    {
                        // ERRパラメータの中身がある場合はログ及びアラームを出力する
                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDERINJECTION_SUCCESS_ERR, CSICommonMethod.GetLastErrorString());
                        // ※エラーログは出力するが処理続行
                    }
                    // -----------------------------------------------
                    // オーダNo、オーダサブNoを設定する
                    // -----------------------------------------------
#if !WITHOUT_INTERFACE
                    string strMainNo = CSICommon.pGetOUTPARAMData(0).ToString();
                    string strSubNo = CSICommon.pGetOUTPARAMData(1).ToString();
#else
                    string strMainNo = "123456";
                    string strSubNo = "1";
#endif
                    // オーダNo、オーダサブNoを確認
                    if (strMainNo.Equals(string.Empty) || strSubNo.Equals(string.Empty))
                    {
                        // エラー・MIRAIｓ発行オーダNoが取得出来ていない
                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDERINJECTION, "MIRAIｓ発行オーダNoが不正です");
                        return false;
                    }
                    else
                    {
                        // オーダNo、オーダサブNoを設定
                        switch (strChangeSendClass)
                        {
                            case EVENT_TYPE_ADD:   // 新規
                                // 新規の場合は戻り値であるオーダNo、オーダサブNoを設定する
                                strRetOrederNo = strMainNo + "," + strSubNo;
                                break;
                            case EVENT_TYPE_CHG:   // 修正
                                // 修正の場合は既存のオーダNo,オーダサブNoを設定する
                                string[] strBuf = exeInfo.SendHistMemo.Split(',');
                                strRetOrederNo = strBuf[2] + "," + strBuf[3];
                                break;
                            case EVENT_TYPE_DEL:   // 削除
                                // 削除の場合はNONEを設定する。
                                strRetOrederNo = NONE + "," + NONE;
                                break;
                        }
                    }
                    // ------------------------------------------------------
                    // ※※再送信処理※※
                    // "変更"、"削除"の場合のみ更新送信を前処理として行って
                    // そこで取得したオーダサブNoを再設定して送信する
                    // ------------------------------------------------------
                    if (strChangeSendClass == EVENT_TYPE_CHG || strChangeSendClass == EVENT_TYPE_DEL)
                    {
                        // -----------------------------------------------
                        // 初期化
                        // -----------------------------------------------
                        CSICommon.ClearAllParameter();
                        // -----------------------------------------------
                        // 領域確保
                        // -----------------------------------------------
                        // オーダ領域
                        CSICommon.varORDER = new object[14];
                        // オーダヘッダ領域
                        CSICommon.varHEADER = new object[31];
                        // オーダグループ領域
                        CSICommon.varGROUP = new object[40];
                        // オーダディテール領域
                        CSICommon.varDETAIL = new object[6];
                        // アウトパラメータ領域
                        CSICommon.varOUTPARAM = new object[8];
                        // +++++++++++++++++++++++++++++++++++++++++++++++
                        // ▼注射オーダデータを“再設定”▼
                        // +++++++++++++++++++++++++++++++++++++++++++++++
                        // ※VBA.Collectionにデータを再設定出来ないのでを作り直す
                        bolSetData = SetInjectionOrder(exeInfo,
                                                       strChangeSendClass,
                                                       strSubNo);
                        if (!bolSetData)
                        {
                            // エラー（ログは下位で出力）
                            return false;
                        }

#if !WITHOUT_INTERFACE
                        // ++++++++++++++++++++++++++++++++++++++++++
                        // ▼注射オーダデータを“再送信”▼
                        // ++++++++++++++++++++++++++++++++++++++++++
                        blnExec = CSICommonMethod.pOrder(m_objCSIORDERInjection,
                                                         CSICommon.colORDER,
                                                         ref CSICommon.varOUTPARAM,
                                                         ref CSICommon.colERR,
                                                         m_objMiraisDB);
#else
                        blnExec = true;
#endif

                        if (!blnExec)
                        {
                            // エラー
                            this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDERINJECTION, CSICommonMethod.GetLastErrorString());
                            // -----------------------------------------------
                            // エラーコードを判定
                            // -----------------------------------------------
                            if (CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR1) ||
                                CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR2))
                            {
                                // 上記のエラーコードの場合はリトライフラグを立てる
                                bolRetry = true;
                            }
                            return false;
                        }
                        else
                        {
                            // -----------------------------------------------
                            // 正常終了でもERRパラメータの中身を確認する
                            // -----------------------------------------------
                            if (CSICommon.pGetERRCollectionCount() > 0)
                            {
                                // ERRパラメータの中身がある場合はログ及びアラームを出力する
                                this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDERINJECTION_SUCCESS_ERR, CSICommonMethod.GetLastErrorString());
                                // ※エラーログは出力するが処理続行
                            }
                        }
                    }
                }
            }
            else
            {
                // 注射オーダデータ無し
                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION_NODATE, CSICommonMethod.GetLastErrorString());
            }
            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            // 正常終了
            return true;
        }
        #endregion


        #region 注射オーダ・オーダ
        /// <summary>
        /// 注射オーダ・オーダを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>        
        /// <param name="strSendClass">処理区分</param>
        /// <param name="strOrderSubNo">オーダサブNo（新規及び修正初回、削除初回はnullを設定する）</param>
        /// <returns>true:正常/false:異常</returns>
        private bool SetInjectionOrder(Fn3ExecuteInfo exeInfo, string strChangeSendClass, string strOrderSubNo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;

            // -----------------------------------------------
            // -- オーダ・処理区分・0 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                    strSetData = CSICommonConst.PROCDIV_INSERT;
                    break;
                case EVENT_TYPE_CHG:   // 修正 
                    // ※注意！！　注射オーダの修正要求は始めに"更新"で送信する
                    // strOrderSubNoがnullの場合は初回とみなす
                    if (strOrderSubNo == null)
                    {
                        // 更新を設定
                        strSetData = CSICommonConst.PROCDIV_RENEWINFO;
                    }
                    else
                    {
                        // 修正を設定
                        strSetData = CSICommonConst.PROCDIV_MODIFY;
                    }
                    break;
                case EVENT_TYPE_DEL:   // 削除
                    // ※注意！！　注射オーダの削除要求は始めに"更新"で送信する
                    // strOrderSubNoがnullの場合は初回とみなす
                    if (strOrderSubNo == null)
                    {
                        // 更新を設定
                        strSetData = CSICommonConst.PROCDIV_RENEWINFO;
                    }
                    else
                    {
                        // ※注意！注射オーダの削除要求は"中止"で送信する
                        strSetData = CSICommonConst.PROCDIV_MODSTATUS;
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                default:
                    // ありえないが一応確認（ここ以外ではstrChangeSendClassの異常値は確認しない）
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "処理区分:" + strChangeSendClass);
                    return false;
            }
            CSICommon.pSetORDERData(0, strSetData);
            // -----------------------------------------------
            // -- オーダ・動作区分・1 --
            // -----------------------------------------------
            //// 「“2”：正常登録」を設定（固定値）
            //strSetData = "2";
            // 「“3”：警告登録」を設定（固定値）
            strSetData = "3";
            CSICommon.pSetORDERData(1, strSetData);
            // -----------------------------------------------
            // -- オーダ・進捗変更区分・2 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    strSetData = null;
                    break;
                case EVENT_TYPE_DEL:   // 削除
                    strSetData = "STP";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetORDERData(2, strSetData);
            // -----------------------------------------------
            // -- オーダ・帳票区分・3 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetORDERData(3, strSetData);
            // -----------------------------------------------
            // -- オーダ・オーダヘッダコレクション・ 4--
            // -----------------------------------------------
            // オーダヘッダコレクションを作成する
            bool bolRet = SetInjectionOrderHeader(exeInfo, strChangeSendClass, strOrderSubNo);
            if (bolRet)
            {
                // オーダヘッダコレクションを設定する
                CSICommon.pSetORDERData(4, (VBA.Collection)CSICommon.colHEADER);
            }
            else
            {
                // エラー
                return false;
            }
            // -----------------------------------------------
            // -- オーダ・進捗マスタ参照フラグ・5 --
            // -----------------------------------------------
            // 「0：参照しない」を設定（固定値）
            strSetData = "0";
            CSICommon.pSetORDERData(5, strSetData);
            // -----------------------------------------------
            // -- オーダ・新オーダ日・6 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 「“N”：変更なし」を設定（固定値）
                    strSetData = "N";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetORDERData(6, strSetData);
            // -----------------------------------------------
            // -- オーダ・新オーダ進捗・7 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    // 「“Y”：実施」を設定（固定値）
                    strSetData = "Y";
                    break;
                case EVENT_TYPE_DEL:   // 削除
                    // 「“Z”：中止」を設定（固定値）
                    strSetData = "Z";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetORDERData(7, strSetData);
            // -----------------------------------------------
            // -- オーダ・新会計進捗・8 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 「“A”：未会計」を設定（固定値）
                    strSetData = "A";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetORDERData(8, strSetData);
            // -----------------------------------------------
            // -- オーダ・帳票発行・9 --
            // -----------------------------------------------
            // 「“N”：帳票出力しない」を設定（固定値）
            strSetData = "N";
            CSICommon.pSetORDERData(9, strSetData);
            // -----------------------------------------------
            // -- オーダ・薬袋Ｉ／Ｆ・10 --
            // -----------------------------------------------
            // 注射オーダ薬袋Ｉ／Ｆ使用フラグ（設定値）を判定
            if (m_strDrugBagFlg == CSICommonConst.FALSE_CODE)
            {
                // 「“N”：Ｉ／Ｆ出力しない  」を設定（固定値）
                strSetData = "N";
            }
            else if (m_strDrugBagFlg == CSICommonConst.TRUE_CODE)
            {
                // 「“Y”：Ｉ／Ｆ出力する  」を設定（固定値）
                strSetData = "Y";
            }
            CSICommon.pSetORDERData(10, strSetData);
            // -----------------------------------------------
            // -- オーダ・検査Ｉ／Ｆ・11 --
            // -----------------------------------------------
            // 「“N”：Ｉ／Ｆ出力しない」を設定（固定値）
            strSetData = "N";
            CSICommon.pSetORDERData(11, strSetData);
            // -----------------------------------------------
            // -- オーダ・医事Ｉ／Ｆ・12 --
            // -----------------------------------------------
            // 「“Y”：Ｉ／Ｆ出力する」を設定（固定値）
            strSetData = "Y";
            CSICommon.pSetORDERData(12, strSetData);
            // -----------------------------------------------
            // -- オーダ・ＲＩＳ Ｉ／Ｆ・13 --
            // -----------------------------------------------
            // 「“N”：Ｉ／Ｆ出力しない」を設定（固定値）
            strSetData = "N";
            CSICommon.pSetORDERData(13, strSetData);

            // ++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダコレクションにオーダ配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(1, CSICommon.varORDER);

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }
        #endregion


        #region 注射オーダ・ヘッダ
        /// <summary>
        /// 注射オーダ・ヘッダコレクションを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="strSendClass">処理区分</param>
        /// <param name="strOrderSubNo">オーダサブNo（新規及び修正初回、削除初回はnullを設定する）</param>
        /// <returns>true:正常/false:異常</returns>
        private bool SetInjectionOrderHeader(Fn3ExecuteInfo exeInfo, string strChangeSendClass, string strOrderSubNo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;
            XmlNode xmlNode = null;
            string strNode = null;

            // -----------------------------------------------
            // -- ヘッダ・オーダ番号・0 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                    strSetData = null;
                    break;
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // SendHistMemoの内容は「注射オーダ番号,注射オーダサブ番号,注射オーダ番号,注射オーダサブ番号,患者診療フリー診療番号」となる
                    string[] strBuf = exeInfo.SendHistMemo.Split(',');
                    strSetData = strBuf[2];
                    strSetData = strSetData.PadLeft(13, '0');
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ番号"))
                    {
                        return false;
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    break;
            }
            CSICommon.pSetHEADERData(0, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダサブ番号・1 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                    strSetData = null;
                    break;
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // strOrderSubNoがnullの場合は初回とみなす
                    if (strOrderSubNo == null)
                    {
                        // SendHistMemoの内容は「注射オーダ番号,注射オーダサブ番号,注射オーダ番号,注射オーダサブ番号,患者診療フリー診療番号」となる
                        string[] strBuf = exeInfo.SendHistMemo.Split(',');
                        strSetData = strBuf[3];
                        strSetData = strSetData.PadLeft(3, '0');
                        // 値チェック
                        if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダサブ番号"))
                        {
                            return false;
                        }
                    }
                    else
                    {
                        // 修正、削除は始めに更新で送信、サブオーダNoを取得して再送信する
                        strSetData = strOrderSubNo;
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    break;
            }
            CSICommon.pSetHEADERData(1, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・患者番号・2 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 患者基本情報・表示用患者IDを取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DISP_PATID");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・患者番号"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・患者番号"))
                    {
                        return false;
                    }
                    // 取得した患者IDが設定桁数以下の場合に対応する為、設定桁数で0詰めする
                    strSetData = strSetData.PadLeft(m_iSendDispPatIdFigures, '0');
                    // 患者番号の下設定桁数を取得する
                    strSetData = strSetData.Substring(strSetData.Length - m_iSendDispPatIdFigures, m_iSendDispPatIdFigures);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(2, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ種・3 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 「“30”：注射」を設定（固定値）
                    strSetData = "30";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(3, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ詳細・4 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 入外を判定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/INOUT_FLG");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ詳細"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ詳細"))
                    {
                        return false;
                    }
                    if (strNode == DB_INOUT_FLG_OUT)
                    {
                        // 外来の場合「“80”：外来事後」を設定（固定値）
                        strSetData = "80";

                    }
                    else
                    {
                        // 入院の場合「“40”：入院事後」を設定（固定値）
                        strSetData = "40";
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(4, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ開始日・5 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績・透析開始日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ開始日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ開始日"))
                    {
                        return false;
                    }
                    // 日時から日付のみを設定
                    strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_DAY);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(5, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ開始時刻・6 --（※必須項目ではない）
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績・透析開始日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ開始時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ開始時刻"))
                    {
                        // 必須項目ではないので処理続行
                        strSetData = null;
                    }
                    else
                    {
                        // 日時から時刻のみを設定　※秒は0秒固定
                        strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_TIME_00);
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(6, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ終了日・7 --（※必須項目ではない）
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績・透析終了日時を取得
                    // >>>>> 2020/07/30 Mod Thach #11191 透析終了日時は透析開始日時と同じようにする
                    //xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/END_DATE");
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // <<<<< 2020/07/30 Mod Thach #11191
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ終了日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ終了日"))
                    {
                        // 必須項目ではないので処理続行
                        strSetData = null;
                    }
                    else
                    {
                        // 日時から日付のみを設定
                        strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_DAY);
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(7, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ終了時刻・8 --（※必須項目ではない）
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績・透析終了日時を取得
                    // >>>>> 2020/07/30 Mod Thach #11191 透析終了日時は透析開始日時と同じようにする
                    //xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/END_DATE");
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // <<<<< 2020/07/30 Mod Thach #11191
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ終了時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ終了時刻"))
                    {
                        // 必須項目ではないので処理続行
                        strSetData = null;
                    }
                    else
                    {
                        // 日時から時刻のみを設定　※秒は0秒固定
                        strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_TIME_00);
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(8, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・実施進捗・9 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetHEADERData(9, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・科・10 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 2013/04/23 中村 科コード設定対応 Chg Start
#if false                    
                    // 患者基本情報・患者グループの院内コード
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
                    if (xmlNode == null || xmlNode.InnerText.Trim().Length != 5)
                    {
                        // 透析実績依頼科を設定（設定値）
                        strSetData = m_strDapartment;
                        // 前0詰め2桁
                        strSetData = strSetData.PadLeft(2, '0');
                    }
                    else
                    {
                        // 患者グループ
                        strSetData = xmlNode.InnerText.Trim().Substring(0, 2);
                    }
#else
                    if (m_PatGroupFlg.Equals("0"))
                    {
                        XmlNode nodeBedNo = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/BED_NO");
                        if (nodeBedNo != null)
                        {
                            if (hstGroupCd.ContainsKey(nodeBedNo.InnerText))
                            {
                                strSetData = hstGroupCd[nodeBedNo.InnerText].ToString().Substring(0, 2);
                            }
                        }
                    }
                    if (string.IsNullOrEmpty(strSetData))
                    {
                        // 患者基本情報・患者グループの院内コード
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
                        if (xmlNode == null || xmlNode.InnerText.Trim().Length != 5)
                        {
                            // 透析実績依頼科を設定（設定値）
                            strSetData = m_strDapartment;
                            // 前0詰め2桁
                            strSetData = strSetData.PadLeft(2, '0');
                        }
                        else
                        {
                            // 患者グループ
                            strSetData = xmlNode.InnerText.Trim().Substring(0, 2);
                        }
                    }
#endif
                    // 2013/04/23 中村 科コード設定対応 Chg End
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(10, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・病棟・11 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 入外を判定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/INOUT_FLG");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・病棟(入外区分)"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・病棟(入外区分)"))
                    {
                        return false;
                    }
                    if (strNode == DB_INOUT_FLG_OUT)
                    {
                        // 外来の場合
                        // 透析実績操作部署を設定（設定値）
                        strSetData = m_strOrderWard;
                    }
                    else
                    {
                        // 入院の場合
                        // 患者情報基本情報・病棟コードを設定
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_WARD/IN_HOSPITAL_CD");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・病棟(病棟コード)"))
                        {
                            return false;
                        }
                        strSetData = xmlNode.InnerText.Trim();
                        // 値チェック
                        if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・病棟(病棟コード)"))
                        {
                            return false;
                        }
                    }
                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    //// 前0詰め2桁
                    //strSetData = strSetData.PadLeft(2, '0');
                    //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(11, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・指示医・12 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更
#if false
                    // 透析実績版番管理・版確定者を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・指示医"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・指示医"))
                    {
                        return false;
                    }
                    // 前0詰め5桁
                    strSetData = strSetData.PadLeft(5, '0');
                    break;
#else
                    // 患者基本情報・担当医を設定
                    strSetData = string.Empty;

                    // 2011/05/13 中村 指示医対応
                    if (m_strIndicatorFlg.Equals("1"))
                    {
                        strSetData = getDeciderCd(exeInfo.CoopInfoXML);
                    }
                    if (string.IsNullOrEmpty(strSetData))
                    {
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD1");
                        // ノードチェック
                        if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "患者基本情報・担当医1"))
                        {
                            strSetData = xmlNode.InnerText.Trim();
                        }
                        if (string.IsNullOrEmpty(strSetData))
                        {
                            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD2");
                            if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "患者基本情報・担当医2"))
                            {
                                strSetData = xmlNode.InnerText.Trim();
                            }
                        }
                        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                        // ※デフォルト値をセットして続行しているので、警告が適切
                        //if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "患者基本情報・担当医"))
                        if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "患者基本情報・担当医"))
                        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                        {
                            strSetData = this.m_strDefaultStaffCd;
                        }
                    }
                    break;
#endif
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(12, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ日・13 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績・透析開始日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ日"))
                    {
                        return false;
                    }
                    strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_DAY);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(13, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ時刻・14 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績・透析開始日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ時刻"))
                    {
                        return false;
                    }
                    strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_TIME_00);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(14, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ入力端末・15 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績入力端末を設定（設定値）
                    strSetData = m_strUpdateErminal;
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(15, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ入力者・16 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績版番管理・版確定者を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ入力者"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・オーダ入力者"))
                    {
                        return false;
                    }
                    // 2011/01/11 中村 スタッフコード0詰めなし対応
                    // // 前0詰め5桁
                    // strSetData = strSetData.PadLeft(5, '0');
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(16, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・実施病棟・17 --（※必須項目ではない）
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績履歴・病棟コードの有無を確認　※必須項目でないので病院コードの有無を確認し院内コードを取得する
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/WARD_CD");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施病棟(病棟コード)"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施病棟(病棟コード)"))
                    {
                        // 必須ではないので続行
                        strSetData = null;
                        break;
                    }
                    // 透析実績履歴・病棟マスタ・院内コードを設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/MST_WARD/IN_HOSPITAL_CD");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施病棟(院内コード)"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施病棟(院内コード)"))
                    {
                        // 必須ではないので続行
                        strSetData = null;
                        break;
                    }
                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    //// 前0詰め2桁
                    //strSetData = strSetData.PadLeft(2, '0');
                    //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(17, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・実施病室・18 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetHEADERData(18, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・実施日・19 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績履歴・透析開始日時を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施日"))
                    {
                        return false;
                    }
                    strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_DAY);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(19, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・実施時刻・20 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績履歴・透析開始日時を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施時刻"))
                    {
                        return false;
                    }
                    strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_TIME_SS);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(20, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・実施者・21 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績版番管理・版確定者を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施者"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・実施者"))
                    {
                        return false;
                    }
                    // 2011/01/11 中村 スタッフコード0詰めなし対応
                    // // 前0詰め5桁
                    // strSetData = strSetData.PadLeft(5, '0');
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(21, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・実施番号・22 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetHEADERData(22, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・発行日・23 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetHEADERData(23, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・発行者・24 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetHEADERData(24, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・更新端末・25 --
            // -----------------------------------------------
            // 透析実績入力端末を設定（設定値）
            strSetData = m_strUpdateErminal;
            CSICommon.pSetHEADERData(25, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・更新者・26 --
            // -----------------------------------------------
            // 透析実績版番管理・版確定者を設定
            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
            // ノードチェック
            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・更新者"))
            {
                return false;
            }
            strSetData = xmlNode.InnerText.Trim();
            // 値チェック
            if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダヘッダ・更新者"))
            {
                return false;
            }
            // 2011/01/11 中村 スタッフコード0詰めなし対応
            // // 前0詰め5桁
            // strSetData = strSetData.PadLeft(5, '0');
            CSICommon.pSetHEADERData(26, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・注射箋通番・27 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetHEADERData(27, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・事後／予定区分・28 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                case EVENT_TYPE_DEL:   // 削除
                    // 「“０”：事後」を設定（固定値）
                    strSetData = "0";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(28, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・外来実施部署・29 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetHEADERData(29, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダグループコレクション ・30 --
            // -----------------------------------------------
            // オーダグループコレクション(新規・修正用)を作成する
            bool bolRet = SetInjectionOrderGroup(exeInfo, strChangeSendClass);
            if (bolRet)
            {
                // オーダグループコレクションを設定する
                CSICommon.pSetHEADERData(30, (VBA.Collection)CSICommon.colGROUP);
            }
            else
            {
                // エラー
                return false;
            }
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダヘッダコレクションにオーダヘッダ配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(2, CSICommon.varHEADER);

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }
        #endregion


        #region 注射オーダ・グループ
        /// <summary>
        /// 注射オーダ・グループコレクションを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="strSendClass">処理区分</param>
        /// <returns>true:正常/false:異常</returns>
        private bool SetInjectionOrderGroup(Fn3ExecuteInfo exeInfo, string strChangeSendClass)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                case EVENT_TYPE_DEL:   // 削除
                    string strAmountA = string.Empty;
                    string strAmountB = string.Empty;
                    string strInHospitalCode = string.Empty;
                    string strAmount = string.Empty;

                    // 注射データリスト
                    List<List<InjectionDetailData>> InjectionDetailDataMgr = new List<List<InjectionDetailData>>();
                    // --------------------------------------------------------------------------------------
                    // 透析実績投薬履歴を参照・手技コード毎の注射データのジャグ配列(コレクション)を作成する
                    // -------------------------------------------------------------------------------------- 
                    foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_MEDICATION_HST"))
                    {
                        // 指示実施フラグを取得
                        XmlNode xmlNode = xmlNodes.SelectSingleNode("EFFECT_FLG");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(指示実施フラグ)"))
                        {
                            // データが無い場合は処理を抜ける
                            break;
                        }
                        string strEffectFlg = xmlNode.InnerText;
                        // 指示実施済みか判断する
                        if (strEffectFlg == DB_EFFECT_FLG_ON)
                        {
                            // セット薬剤使用フラグを取得
                            xmlNode = xmlNodes.SelectSingleNode("SET_MEDICINE_FLG");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(セット薬剤使用フラグ)"))
                            {
                                // データが無い場合は処理を抜ける
                                break;
                            }
                            // ●セット薬剤か判断する(0：通常、1：セット薬剤)
                            if (xmlNode.InnerText == CODE_MEDICINE_NORMAL)
                            {
                                // -------------------------------------
                                // ＜＜通常薬剤の場合＞＞
                                // -------------------------------------
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック・データ無しは続行
                                if (this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(注射フラグ)"))
                                {
                                    // ●注射薬剤か判定する
                                    string strShot = xmlNode.InnerText;
                                    if (strShot == CODE_MEDICINE_SHOT_ON)
                                    {
                                        // -------------------------------------
                                        // 注射薬剤なら注射データを取得設定する
                                        // -------------------------------------
                                        // -----手技コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("PROCEDURE_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード)"))
                                        {
                                            return false;
                                        }
                                        string strProcedureCode = xmlNode.InnerText;
                                        //  -----ルート項目コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD1");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        string strRouteCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strRouteCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strRouteCode = strRouteCode.PadLeft(3, '0');
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----投与方法項目コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD2");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        string strMethodCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strMethodCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strMethodCode = strMethodCode.PadLeft(3, '0');
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----院内コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        strInHospitalCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                        {
                                            // 処理続行
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //else
                                        //{
                                        //    // 前0詰め6桁
                                        //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                        //}
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----入力数量を取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数量"))
                                        {
                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            //return false;
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・入力数量");
                                            // 送信データを出力対象から除外 
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        }
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        else
                                        {
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            strAmount = xmlNode.InnerText;
                                            // 値チェック
                                            //if (!this.CheckEmptyVal(strAmount, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数量"))
                                            //{
                                            //    return false;
                                            //}
                                            if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数量"))
                                            {
                                                // 値が空の場合は規定値を設定
                                                strAmount = EMPTY_VAL;
                                            }

                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            if (double.Parse(strAmount) == 0)
                                            {
                                                // ワーニングログ出力
                                                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・入力数量");
                                                // 送信データを出力対象から除外 
                                            }
                                            else
                                            {
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                                // -----上記で取得したデータを注射データクラスリストに格納-----
                                                // 院内コードの有無を確認
                                                if (strInHospitalCode != string.Empty)
                                                {
                                                    // 空チェック・手技が設定されていな場合は無視
                                                    if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード)"))
                                                    {
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                        if ("0".Equals(this.m_SameProcedureFlag))
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめて送信」する場合
                                                            // ---------------------------------------------------
                                                            bool bolNewAddflg = false;
                                                            foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                            {
                                                                // 同じ手技コードが既に格納されているか確認
                                                                if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                {
                                                                    // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                    AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                    // 追加フラグ
                                                                    bolNewAddflg = true;
                                                                }
                                                            }
                                                            // 既存リストに追加したか判定
                                                            if (!bolNewAddflg)
                                                            {
                                                                // 既存リストに追加していない場合は新規追加
                                                                List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                InjectionDetailDataMgr.Add(newList);
                                                            }
                                                        }
                                                        else
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめず送信」する場合
                                                            // ---------------------------------------------------
                                                            // すべて新規追加
                                                            List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                            newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                            InjectionDetailDataMgr.Add(newList);
                                                        }
                                                        //bool bolNewAddflg = false;
                                                        //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                        //{
                                                        //    // 同じ手技コードが既に格納されているか確認
                                                        //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                        //    {
                                                        //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                        //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                        //        //injectionDetailDataList.Add(InjectionDetailDataBuf);
                                                        //        // 追加フラグ
                                                        //        bolNewAddflg = true;
                                                        //    }
                                                        //}
                                                        //// 既存リストに追加したか判定
                                                        //if (!bolNewAddflg)
                                                        //{
                                                        //    // 既存リストに追加していない場合は新規追加
                                                        //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                        //    // 2011/01/21 中村 小数点以下の有効桁数対応
                                                        //    // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                                        //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                        //    InjectionDetailDataMgr.Add(newList);
                                                        //}
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                    }
                                                }
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            }
                                        }
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                    }
                                }
                            }
                            else if (xmlNode.InnerText == CODE_MEDICINE_SET)
                            {
                                // -------------------------------------
                                // ＜＜セット薬剤の場合＞＞
                                // -------------------------------------
                                // -----使用量(＝セット数)を取得-----
                                xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・使用量"))
                                {
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    //return false;
                                    // ワーニングログ出力
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・入力数量");
                                    // 送信データを出力対象から除外 
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                }
                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                else
                                {
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    // 値チェック
                                    //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・使用量"))
                                    //{
                                    //    return false;
                                    //}
                                    //// セット薬剤の数を設定
                                    //double dblSetCnt = double.Parse(xmlNode.InnerText);
                                    double dblSetCnt;
                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・使用量"))
                                    {
                                        // 値が空の場合は規定値を設定
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //dblSetCnt = double.Parse(EMPTY_VAL);
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・使用量");
                                        // 送信データを出力対象から除外 
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    else
                                    {
                                        // セット薬剤の数を設定
                                        dblSetCnt = double.Parse(xmlNode.InnerText);
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //}
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                        // 2014/09/29 中村 障害対応(Redmine#3800) Del Start
                                        //// -----手技コードを取得-----
                                        //xmlNode = xmlNodes.SelectSingleNode("PROCEDURE_CD");
                                        //// ノードチェック
                                        //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        //string strProcedureCode = xmlNode.InnerText;
                                        //// -----ルート項目コードを取得-----
                                        //xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD1");
                                        //// ノードチェック
                                        //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        //string strRouteCode = xmlNode.InnerText.Trim();
                                        //// 値チェック
                                        //if (!this.CheckEmptyVal(strRouteCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        ////>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        ////// 前0詰め3桁
                                        ////strRouteCode = strRouteCode.PadLeft(3, '0');
                                        ////<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// -----投与方法項目コードを取得-----
                                        //xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD2");
                                        //// ノードチェック
                                        //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        //string strMethodCode = xmlNode.InnerText.Trim();
                                        //// 値チェック
                                        //if (!this.CheckEmptyVal(strMethodCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        // 2014/09/29 中村 障害対応(Redmine#3800) Del End

                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strMethodCode = strMethodCode.PadLeft(3, '0');
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----セット薬剤マスタを取得-----
                                        string strProcedureCode = string.Empty;
                                        string strRouteCode = string.Empty;
                                        string strMethodCode = string.Empty;
                                        foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            // 薬剤マスタ・注射フラグを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                            // ノードチェック
                                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(注射フラグ)"))
                                            {
                                                // エラー
                                                return false;
                                            }
                                            string strShot = xmlNode.InnerText;
                                            // ●薬剤マスタ・注射フラグが「"1"：注射」か判定する
                                            if (strShot == CODE_MEDICINE_SHOT_ON)
                                            {
                                                // 2014/09/29 中村 障害対応(Redmine#3800) Add Start
                                                // -----手技コードを取得-----
                                                if (string.IsNullOrEmpty(strProcedureCode))
                                                {
                                                    xmlNode = xmlNodes.SelectSingleNode("PROCEDURE_CD");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード)"))
                                                    {
                                                        return false;
                                                    }
                                                    strProcedureCode = xmlNode.InnerText;
                                                }
                                                // -----ルート項目コードを取得-----
                                                if (string.IsNullOrEmpty(strRouteCode))
                                                {
                                                    xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD1");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                    strRouteCode = xmlNode.InnerText.Trim();
                                                    // 値チェック
                                                    if (!this.CheckEmptyVal(strRouteCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                }
                                                // -----投与方法項目コードを取得-----
                                                if (string.IsNullOrEmpty(strMethodCode))
                                                {
                                                    xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD2");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                    strMethodCode = xmlNode.InnerText.Trim();
                                                    // 値チェック
                                                    if (!this.CheckEmptyVal(strMethodCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                }
                                                // 2014/09/29 中村 障害対応(Redmine#3800) Add End

                                                // -----院内コードを取得-----
                                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                                {
                                                    return false;
                                                }
                                                strInHospitalCode = xmlNode.InnerText.Trim();
                                                // 値チェック
                                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                                {
                                                    // 処理続行
                                                }
                                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                //else
                                                //{
                                                //    // 前0詰め6桁
                                                //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                                //}
                                                //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                // >>>>>【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                                //// -----入力数量を取得-----
                                                //xmlNode = xmlNodeSets.SelectSingleNode("VALUE");
                                                //// ノードチェック
                                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                                //{
                                                //    return false;
                                                //}

                                                // -----入力数量（使用薬剤数）を取得-----
                                                xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・使用薬剤数"))
                                                {
                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    //return false;
                                                    // ワーニングログ出力
                                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・使用薬剤数");
                                                    // 送信データを出力対象から除外 
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                }
                                                // <<<<<【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                else
                                                {
                                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    // 値チェック
                                                    //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                                    //{
                                                    //    return false;
                                                    //}
                                                    //// 使用量(セット薬剤)を設定
                                                    //double dblValuet = double.Parse(xmlNode.InnerText);
                                                    double dblValuet;
                                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                                    {
                                                        // 値が空の場合は規定値を設定
                                                        dblValuet = double.Parse(EMPTY_VAL);
                                                    }
                                                    else
                                                    {
                                                        // 使用量(セット薬剤)を設定
                                                        dblValuet = double.Parse(xmlNode.InnerText);
                                                    }
                                                    // 入力数量を算出し設定（透析実績投薬履歴・使用量 × セット薬剤マスタ・薬剤使用量）
                                                    strAmount = (dblValuet * dblSetCnt).ToString();

                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    if (double.Parse(strAmount) == 0)
                                                    {
                                                        // ワーニングログ出力
                                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・使用薬剤数");
                                                        // 送信データを出力対象から除外 
                                                    }
                                                    else
                                                    {
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                                        // -----上記で取得したデータを注射データクラスリストに格納-----
                                                        // 院内コードの有無を確認
                                                        if (strInHospitalCode != string.Empty)
                                                        {
                                                            // 空チェック・手技が設定されていな場合は無視
                                                            if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード)"))
                                                            {
                                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                                if ("0".Equals(this.m_SameProcedureFlag))
                                                                {
                                                                    // ---------------------------------------------------
                                                                    // 同手技で「まとめて送信」する場合
                                                                    // ---------------------------------------------------
                                                                    bool bolNewAddflg = false;
                                                                    // 既存の注射データリストを参照
                                                                    foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                    {
                                                                        // 同じ手技コードが既に格納されているか確認
                                                                        if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                        {
                                                                            // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                            AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                            bolNewAddflg = true;
                                                                        }
                                                                    }
                                                                    // 既存リストに追加したか判定
                                                                    if (!bolNewAddflg)
                                                                    {
                                                                        // 既存リストに追加していない場合は新規追加
                                                                        List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                        newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                        InjectionDetailDataMgr.Add(newList);
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    // ---------------------------------------------------
                                                                    // 同手技で「まとめず送信」する場合
                                                                    // ---------------------------------------------------
                                                                    // 既存の注射データリストを参照
                                                                    // すべて新規追加
                                                                    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                    InjectionDetailDataMgr.Add(newList);
                                                                }
                                                                //bool bolNewAddflg = false;
                                                                //// 既存の注射データリストを参照
                                                                //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                //{
                                                                //    // 同じ手技コードが既に格納されているか確認
                                                                //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                //    {
                                                                //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                //        bolNewAddflg = true;
                                                                //    }
                                                                //}
                                                                //// 既存リストに追加したか判定
                                                                //if (!bolNewAddflg)
                                                                //{
                                                                //    // 既存リストに追加していない場合は新規追加
                                                                //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                //    // 2011/01/21 中村 小数点以下の有効桁数対応
                                                                //    // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                                                //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                //    InjectionDetailDataMgr.Add(newList);
                                                                //}
                                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                            }
                                                        }
                                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    }
                                                }
                                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            }
                                        }
                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                            }
                        }
                    }
                    // ------------------------------------------------------------------------------------------------
                    /// 透析実績愁訴処置_処置履歴を参照・手技コード毎の注射データのジャグ配列(コレクション)を作成する
                    // ------------------------------------------------------------------------------------------------
                    strInHospitalCode = string.Empty;
                    strAmount = string.Empty;
                    foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_TREATMENT_HST"))
                    {
                        // 透析実績愁訴処置_処置履歴・処置区分を取得・データ無しは続行
                        XmlNode xmlNode = xmlNodes.SelectSingleNode("TREAT_CLASS");
                        if (this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(処置区分)"))
                        {
                            // ●処理区分が薬剤か判定する
                            string strTreatClass = xmlNode.InnerText;
                            if (strTreatClass == CODE_DIALYSIS_TREATMEN_DRUG)
                            {
                                // -------------------------------------
                                // ＜＜薬剤は通常薬剤となる＞＞
                                // -------------------------------------
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック・データ無しは続行
                                if (this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(注射フラグ)"))
                                {
                                    // ●注射薬剤か判定する
                                    string strShot = xmlNode.InnerText;
                                    if (strShot == CODE_MEDICINE_SHOT_ON)
                                    {
                                        // -------------------------------------
                                        // 注射薬剤なら注射データを取得設定する
                                        // -------------------------------------
                                        // -----手技コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("PROCEDURE_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                        {
                                            return false;
                                        }
                                        string strProcedureCode = xmlNode.InnerText.Trim();
                                        //  -----ルート項目コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD1");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        string strRouteCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strRouteCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strRouteCode = strRouteCode.PadLeft(3, '0');
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----投与方法項目コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD2");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        string strMethodCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strMethodCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strMethodCode = strMethodCode.PadLeft(3, '0');
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----院内コードを取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                        {
                                            return false;
                                        }
                                        strInHospitalCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                        {
                                            // 処理続行
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //else
                                        //{
                                        //    // 前0詰め6桁
                                        //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                        //}
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----入力数量を取得-----
                                        xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                        {
                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            //return false;
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・入力数");
                                            // 送信データを出力対象から除外 
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        }
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        else
                                        {
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            strAmount = xmlNode.InnerText;
                                            // 値チェック
                                            //if (!this.CheckEmptyVal(strAmount, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                            //{
                                            //    return false;
                                            //}
                                            if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                            {
                                                // 値が空の場合は規定値を設定
                                                strAmount = EMPTY_VAL;
                                            }

                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            if (double.Parse(strAmount) == 0)
                                            {
                                                // ワーニングログ出力
                                                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・入力数");
                                                // 送信データを出力対象から除外 
                                            }
                                            else
                                            {
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                // -----上記で取得したデータを注射データクラスリストに格納-----
                                                // 院内コードの有無を確認
                                                if (strInHospitalCode != string.Empty)
                                                {
                                                    // 空チェック・手技が設定されていな場合は無視
                                                    if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                    {
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                        if ("0".Equals(this.m_SameProcedureFlag))
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめて送信」する場合
                                                            // ---------------------------------------------------
                                                            bool bolNewAddflg = false;
                                                            // 既存の注射データリストを参照
                                                            foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                            {
                                                                // 同じ手技コードが既に格納されているか確認
                                                                if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                {
                                                                    // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                    AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                    // 追加フラグ
                                                                    bolNewAddflg = true;
                                                                }
                                                            }
                                                            // 既存リストに追加したか判定
                                                            if (!bolNewAddflg)
                                                            {
                                                                // 既存リストに追加していない場合は新規追加
                                                                List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                InjectionDetailDataMgr.Add(newList);
                                                            }
                                                        }
                                                        else
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめず送信」する場合
                                                            // ---------------------------------------------------
                                                            // 既存の注射データリストを参照
                                                            // すべて新規追加
                                                            List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                            newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                            InjectionDetailDataMgr.Add(newList);
                                                        }
                                                        //bool bolNewAddflg = false;
                                                        //// 既存の注射データリストを参照
                                                        //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                        //{
                                                        //    // 同じ手技コードが既に格納されているか確認
                                                        //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                        //    {
                                                        //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                        //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                        //        // 追加フラグ
                                                        //        bolNewAddflg = true;
                                                        //    }
                                                        //}
                                                        //// 既存リストに追加したか判定
                                                        //if (!bolNewAddflg)
                                                        //{
                                                        //    // 既存リストに追加していない場合は新規追加
                                                        //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                        //    // 2011/01/21 中村 小数点以下の有効桁数対応
                                                        //    // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                                        //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                        //    InjectionDetailDataMgr.Add(newList);
                                                        //}
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                    }
                                                }
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            }
                                        }
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                }
                            }
                            else if (strTreatClass == CODE_DIALYSIS_TREATMEN_TREATDRUG)
                            {
                                // -------------------------------------
                                // ＜＜処置薬剤はセット薬剤となる＞＞
                                // -------------------------------------
                                // 2014/09/29 中村 障害対応(Redmine#3800) Del Start
                                //// -----手技コードを取得-----
                                //xmlNode = xmlNodes.SelectSingleNode("PROCEDURE_CD");
                                //// ノードチェック
                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                //{
                                //    return false;
                                //}
                                //string strProcedureCode = xmlNode.InnerText.Trim();
                                // 2014/09/29 中村 障害対応(Redmine#3800) Del End

                                // -----使用量(＝セット数)を取得-----
                                xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数量(セット数)"))
                                {
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    //return false;
                                    // ワーニングログ出力
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・入力数量(セット数)");
                                    // 送信データを出力対象から除外 
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                }
                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                else
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    // 値チェック
                                    //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数量(セット数)"))
                                    //{
                                    //    return false;
                                    //}
                                    //double dblSetCnt = double.Parse(xmlNode.InnerText);
                                    double dblSetCnt;
                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数量(セット数)"))
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //// 値が空の場合は規定値を設定
                                        //dblSetCnt = double.Parse(EMPTY_VAL);
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・入力数量(セット数)");
                                        // 送信データを出力対象から除外 
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    else
                                    {
                                        dblSetCnt = double.Parse(xmlNode.InnerText);
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //}
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                        // 2014/09/29 中村 障害対応(Redmine#3800) Del Start
                                        //// -----ルート項目コードを取得-----
                                        //xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD1");
                                        //// ノードチェック
                                        //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        //string strRouteCode = xmlNode.InnerText.Trim();
                                        //// 値チェック
                                        //if (!this.CheckEmptyVal(strRouteCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        ////>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        ////// 前0詰め3桁
                                        ////strRouteCode = strRouteCode.PadLeft(3, '0');
                                        ////<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// -----投与方法項目コードを取得-----   
                                        //xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD2");
                                        //// ノードチェック
                                        //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        //string strMethodCode = xmlNode.InnerText.Trim();
                                        //// 値チェック
                                        //if (!this.CheckEmptyVal(strMethodCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                        //{
                                        //    return false;
                                        //}
                                        // 2014/09/29 中村 障害対応(Redmine#3800) Del End

                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strMethodCode = strMethodCode.PadLeft(3, '0');
                                        //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // 透析実績愁訴処置_処置履歴・セット薬剤名称マスタ・セット薬剤マスタ
                                        string strProcedureCode = string.Empty;
                                        string strRouteCode = string.Empty;
                                        string strMethodCode = string.Empty;
                                        foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            // 薬剤マスタ・注射フラグを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                            // ノードチェック
                                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(注射フラグ)"))
                                            {
                                                // エラー
                                                return false;
                                            }
                                            // ●薬剤マスタ・注射フラグが「"1"：注射」か判定する●
                                            if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                            {
                                                // 2014/09/29 中村 障害対応(Redmine#3800) Add Start
                                                // -----手技コードを取得-----
                                                if (string.IsNullOrEmpty(strProcedureCode))
                                                {
                                                    xmlNode = xmlNodes.SelectSingleNode("PROCEDURE_CD");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                    {
                                                        return false;
                                                    }
                                                    strProcedureCode = xmlNode.InnerText.Trim();
                                                }
                                                // -----ルート項目コードを取得-----
                                                if (string.IsNullOrEmpty(strRouteCode))
                                                {
                                                    xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD1");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                    strRouteCode = xmlNode.InnerText.Trim();
                                                    // 値チェック
                                                    if (!this.CheckEmptyVal(strRouteCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・ルート項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                }
                                                // -----投与方法項目コードを取得-----
                                                if (string.IsNullOrEmpty(strMethodCode))
                                                {
                                                    xmlNode = xmlNodes.SelectSingleNode("MST_PROCEDURE/IN_HOSPITAL_CD2");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                    strMethodCode = xmlNode.InnerText.Trim();
                                                    // 値チェック
                                                    if (!this.CheckEmptyVal(strMethodCode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・投与方法項目コード(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                }
                                                // 2014/09/29 中村 障害対応(Redmine#3800) Add End

                                                // -------------------------------------
                                                // 注射薬剤なら注射データを取得設定する
                                                // -------------------------------------
                                                // -----院内コードを取得-----
                                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                                {
                                                    return false;
                                                }
                                                strInHospitalCode = xmlNode.InnerText.Trim();
                                                // 値チェック
                                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・薬剤コード(院内コード)"))
                                                {
                                                    // 処理続行
                                                }
                                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                //else
                                                //{
                                                //    // 前0詰め6桁
                                                //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                                //}
                                                //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                // >>>>>【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                                //// -----入力数量を取得-----
                                                //xmlNode = xmlNodeSets.SelectSingleNode("VALUE");
                                                //// ノードチェック
                                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                                //{
                                                //    return false;
                                                //}

                                                // -----入力数量（使用薬剤数）を取得-----
                                                xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・使用薬剤数"))
                                                {
                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    //return false;
                                                    // ワーニングログ出力
                                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・使用薬剤数");
                                                    // 送信データを出力対象から除外 
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                }
                                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                else
                                                {
                                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    // <<<<<【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                                    // 値チェック
                                                    //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                                    //{
                                                    //    return false;
                                                    //}
                                                    //// 使用量(セット薬剤)を設定
                                                    //double dblValuet = double.Parse(xmlNode.InnerText);
                                                    double dblValuet;
                                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・入力数"))
                                                    {
                                                        // 値が空の場合は規定値を設定
                                                        dblValuet = double.Parse(EMPTY_VAL);
                                                    }
                                                    else
                                                    {
                                                        // 使用量(セット薬剤)を設定
                                                        dblValuet = double.Parse(xmlNode.InnerText);
                                                    }
                                                    // 入力数量を算出し設定（透析実績愁訴処置_処置・数量 × セット薬剤マスタ・薬剤使用量）
                                                    strAmount = (dblValuet * dblSetCnt).ToString();

                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    if (double.Parse(strAmount) == 0)
                                                    {
                                                        // ワーニングログ出力
                                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・使用薬剤数");
                                                        // 送信データを出力対象から除外 
                                                    }
                                                    else
                                                    {
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                                        // -----上記で取得したデータを注射データクラスリストに格納-----
                                                        // 院内コードの有無を確認
                                                        if (strInHospitalCode != string.Empty)
                                                        {
                                                            // 空チェック・手技が設定されていな場合は無視
                                                            if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                            {
                                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                                if ("0".Equals(this.m_SameProcedureFlag))
                                                                {
                                                                    // ---------------------------------------------------
                                                                    // 同手技で「まとめて送信」する場合
                                                                    // ---------------------------------------------------
                                                                    bool bolNewAddflg = false;
                                                                    // 既存の注射データリストを参照
                                                                    foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                    {
                                                                        // 同じ手技コードが既に格納されているか確認
                                                                        if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                        {
                                                                            // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                            AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                            // 追加フラグ
                                                                            bolNewAddflg = true;
                                                                        }
                                                                    }
                                                                    // 既存リストに追加したか判定
                                                                    if (!bolNewAddflg)
                                                                    {
                                                                        // 既存リストに追加していない場合は新規追加
                                                                        List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                        newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                        InjectionDetailDataMgr.Add(newList);
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    // ---------------------------------------------------
                                                                    // 同手技で「まとめず送信」する場合
                                                                    // ---------------------------------------------------
                                                                    // 既存の注射データリストを参照
                                                                    // すべて新規追加
                                                                    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                    InjectionDetailDataMgr.Add(newList);
                                                                }
                                                                //bool bolNewAddflg = false;
                                                                //// 既存の注射データリストを参照
                                                                //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                //{
                                                                //    // 同じ手技コードが既に格納されているか確認
                                                                //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                //    {
                                                                //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                //        // 追加フラグ
                                                                //        bolNewAddflg = true;
                                                                //    }
                                                                //}
                                                                //// 既存リストに追加したか判定
                                                                //if (!bolNewAddflg)
                                                                //{
                                                                //    // 既存リストに追加していない場合は新規追加
                                                                //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                //    // 2011/01/21 中村 小数点以下の有効桁数対応
                                                                //    // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                                                //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                //    InjectionDetailDataMgr.Add(newList);
                                                                //}
                                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                            }
                                                        }
                                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    }
                                                }
                                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            }
                                        }
                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                            }
                        }
                    }
                    // ---------------------------------------------------------------------------------------------------------
                    /// 透析実績透析条件履歴を参照・手技コード毎の注射データのジャグ配列(コレクション)を作成する 　＜抗凝固剤＞
                    // ---------------------------------------------------------------------------------------------------------
                    strInHospitalCode = string.Empty;
                    strAmountA = string.Empty;
                    strAmountB = string.Empty;
                    strAmount = string.Empty;
                    // 透析実績透析条件履歴を取得
#if false
                    foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                    {
                        // 透析条件項目コードを取得
                        XmlNode xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(透析条件項目コード)"))
                        {
                            // データが無い場合は処理を抜ける(※透析実績透析条件履歴は必ず下位ノードが存在するとのことなのでここに来ることはない）
                            break;
                        }
                        string strCtlNo = xmlNode.InnerText;
                        switch (strCtlNo)
                        {
                            case CODE_DIALYSIS_ITEM_GYOKO:          // 抗凝固剤       
                                // -----院内コードを取得-----  
                                // VALUE値を取得
                                xmlNode = xmlNodes.SelectSingleNode("VALUE");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(VALUE値確認)"))
                                {
                                    return false;
                                }
                                string strValChk = xmlNode.InnerText;
                                // VALUE値を確認
                                if (!this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(VALUE値確認)"))
                                {
                                    // VALUE値空はデータなしと判断して処理続行
                                    break;
                                }
                                // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                                if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                                {
                                    // -------------------------------------
                                    // ＜＜通常薬剤の場合＞＞
                                    // -------------------------------------
                                    // 薬剤マスタ・注射フラグを取得
                                    xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(注射フラグ)"))
                                    {
                                        return false;
                                    }
                                    string strShot = xmlNode.InnerText;
                                    // 薬剤マスタ・注射フラグを判定
                                    if (strShot == CODE_MEDICINE_SHOT_ON)
                                    {
                                        // 院内コードを取得
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(院内コード)"))
                                        {
                                            return false;
                                        }
                                        strInHospitalCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(院内コード)"))
                                        {
                                            // 処理続行
                                        }
                                        else
                                        {
                                            // 前0詰め6桁
                                            strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                        }
                                    }
                                }
                                else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                                {
                                    // -------------------------------------
                                    // ＜＜セット薬剤の場合＞＞
                                    // -------------------------------------
                                    // ※抗凝固剤のセット薬剤は展開しない
                                    // ※抗凝固剤のセット薬剤の注射薬剤には対応しない(抗凝固剤のセット薬剤の注射薬剤は汎用オーダで送る)
                                }
                                else
                                {
                                    // エラー
                                    this.CheckEmptyVal("", CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(VALUE値)・セット薬剤判定");
                                    return false;
                                }
                                break;
                            case CODE_DIALYSIS_ITEM_GYOKO_ONE:      // 抗凝固剤ワンショット量
                                // -----使用量を取得-----
                                xmlNode = xmlNodes.SelectSingleNode("VALUE");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(使用量・凝固剤ワンショット量)"))
                                {
                                    return false;
                                }
                                strAmountA = xmlNode.InnerText;
                                break;
                            case CODE_DIALYSIS_ITEM_GYOKO_QUANTIY:   // 抗凝固剤持続総量
                                // -----使用量を取得-----
                                xmlNode = xmlNodes.SelectSingleNode("VALUE");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                                {
                                    return false;
                                }
                                strAmountB = xmlNode.InnerText;
                                break;
                        }
                    }
                    // 院内コードの有無を確認
                    if (strInHospitalCode != string.Empty)
                    {
                        // 使用量の値チェック
                        //if (!this.CheckEmptyVal(strAmountA, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤ワンショット量)") ||
                        //    !this.CheckEmptyVal(strAmountB, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                        //{
                        //    return false;
                        //}
                        if (!this.CheckEmptyVal(strAmountA, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤ワンショット量"))
                        {
                            // 値が空の場合は規定値を設定
                            strAmountA = EMPTY_VAL;
                        }
                        if (!this.CheckEmptyVal(strAmountB, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                        {
                            // 値が空の場合は規定値を設定
                            strAmountB = EMPTY_VAL;
                        }
                        // -----手技コードを取得-----
                        string strProcedureCode = m_strAnticoagulantProcedureCode.Trim();
                        // -----ルート項目コードを取得-----
                        string strRouteCode = m_strAnticoagulantRouteCode.Trim();
                        // 前0詰め3桁
                        strRouteCode = strRouteCode.PadLeft(3, '0');
                        // -----投与方法項目コードを取得-----   
                        string strMethodCode = m_strAnticoagulantMethodCode.Trim();
                        // 前0詰め3桁
                        strMethodCode = strMethodCode.PadLeft(3, '0');
                        // -----使用量を設定（抗凝固剤ワンショット量+抗凝固剤持続総量）-----   
                        strAmount = (double.Parse(strAmountA) + double.Parse(strAmountB)).ToString();
                        // -----上記で取得したデータを注射データクラスリストに格納-----
                        // 空チェック・手技が設定されていな場合は無視
                        if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                        {
                            bool bolNewAddflg = false;
                            // 既存の注射データリストを参照
                            foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                            {
                                // 同じ手技コードが既に格納されているか確認
                                if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                {
                                    // 同じ手技コードが既に存在する場合はそのリストに追加
                                    AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                    // 追加フラグ
                                    bolNewAddflg = true;
                                }
                            }
                            // 既存リストに追加したか判定
                            if (!bolNewAddflg)
                            {
                                // 既存リストに追加していない場合は新規追加
                                List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                // 2011/01/21 中村 小数点以下の有効桁数対応
                                // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                InjectionDetailDataMgr.Add(newList);
                            }
                        }
                    }
#else
                    XmlNode xmlGyokoNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_GYOKO));
                    if (xmlGyokoNode != null)
                    {
                        XmlNode xmlNode = xmlGyokoNode.SelectSingleNode("VALUE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(VALUE値確認)"))
                        {
                            return false;
                        }
                        string strValChk = xmlNode.InnerText;
                        if (this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(VALUE値確認)"))
                        {
                            // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                            if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                            {
                                #region ＜＜通常薬剤の場合＞＞
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlGyokoNode.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(注射フラグ)"))
                                {
                                    return false;
                                }
                                string strShot = xmlNode.InnerText;
                                if (strShot == CODE_MEDICINE_SHOT_ON)
                                {
                                    // -------------------------------------
                                    // 注射薬剤なら注射データを取得設定する
                                    // -------------------------------------
                                    // -----行為詳細項目コードを取得-----
                                    #region 院内コード
                                    // 院内コードを取得
                                    xmlNode = xmlGyokoNode.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(院内コード)"))
                                    {
                                        return false;
                                    }
                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                    // 値チェック
                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(院内コード)"))
                                    {
                                        // 処理続行
                                    }
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    //else
                                    //{
                                    //    // 前0詰め6桁
                                    //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                    //}
                                    //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    #endregion

                                    // -----手技コードを取得-----
                                    string strProcedureCode = m_strAnticoagulantProcedureCode.Trim();
                                    // -----ルート項目コードを取得-----
                                    string strRouteCode = m_strAnticoagulantRouteCode.Trim();
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    //// 前0詰め3桁
                                    //strRouteCode = strRouteCode.PadLeft(3, '0');
                                    //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    // -----投与方法項目コードを取得-----   
                                    string strMethodCode = m_strAnticoagulantMethodCode.Trim();
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    //// 前0詰め3桁
                                    //strMethodCode = strMethodCode.PadLeft(3, '0');
                                    //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更

                                    // -----使用量を設定(抗凝固剤ワンショット量+抗凝固剤持続総量)-----   
                                    #region 使用量の算出

                                    #region 抗凝固剤ワンショット量
                                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_GYOKO_ONE));
                                    // ノードチェック
                                    // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                                    // if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(使用量・凝固剤ワンショット量)"))
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(使用量・抗凝固剤ワンショット量)"))
                                    // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //return false;
                                        strAmountA = EMPTY_VAL;
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        strAmountA = xmlNode.InnerText;
                                        if (!this.CheckEmptyVal(strAmountA, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤ワンショット量"))
                                        {
                                            // 値が空の場合は規定値を設定
                                            strAmountA = EMPTY_VAL;
                                        }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    #endregion

                                    #region 抗凝固剤持続総量
                                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_GYOKO_QUANTIY));
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //return false;
                                        strAmountB = EMPTY_VAL;
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        strAmountB = xmlNode.InnerText;
                                        if (!this.CheckEmptyVal(strAmountB, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                                        {
                                            // 値が空の場合は規定値を設定
                                            strAmountB = EMPTY_VAL;
                                        }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    #endregion

                                    // ワンショット量 + 持続総量
                                    strAmount = (double.Parse(strAmountA) + double.Parse(strAmountB)).ToString();

                                    #endregion

                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    if (double.Parse(strAmount) == 0)
                                    {
                                        // ワーニングログ出力
                                        // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                                        // this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)");
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・抗凝固剤(使用量・抗凝固剤総量)");
                                        // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                                        // 送信データを出力対象から除外 
                                    }
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        // -----上記で取得したデータを注射データクラスリストに格納-----
                                        // 院内コードの有無を確認
                                        if (strInHospitalCode != string.Empty)
                                        {
                                            // 空チェック・手技が設定されていな場合は無視
                                            if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                            {
                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                if ("0".Equals(this.m_SameProcedureFlag))
                                                {
                                                    // ---------------------------------------------------
                                                    // 同手技で「まとめて送信」する場合
                                                    // ---------------------------------------------------
                                                    bool bolNewAddflg = false;
                                                    // 既存の注射データリストを参照
                                                    foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                    {
                                                        // 同じ手技コードが既に格納されているか確認
                                                        if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                        {
                                                            // 同じ手技コードが既に存在する場合はそのリストに追加
                                                            AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                            // 追加フラグ
                                                            bolNewAddflg = true;
                                                        }
                                                    }
                                                    // 既存リストに追加したか判定
                                                    if (!bolNewAddflg)
                                                    {
                                                        // 既存リストに追加していない場合は新規追加
                                                        List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                        newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                        InjectionDetailDataMgr.Add(newList);
                                                    }
                                                }
                                                else
                                                {
                                                    // ---------------------------------------------------
                                                    // 同手技で「まとめず送信」する場合
                                                    // ---------------------------------------------------
                                                    // 既存の注射データリストを参照
                                                    // すべて新規追加
                                                    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                    InjectionDetailDataMgr.Add(newList);
                                                }
                                                //bool bolNewAddflg = false;
                                                //// 既存の注射データリストを参照
                                                //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                //{
                                                //    // 同じ手技コードが既に格納されているか確認
                                                //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                //    {
                                                //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                //        // 追加フラグ
                                                //        bolNewAddflg = true;
                                                //    }
                                                //}
                                                //// 既存リストに追加したか判定
                                                //if (!bolNewAddflg)
                                                //{
                                                //    // 既存リストに追加していない場合は新規追加
                                                //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                //    // 2011/01/21 中村 小数点以下の有効桁数対応
                                                //    // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                                //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                //    InjectionDetailDataMgr.Add(newList);
                                                //}
                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                            }
                                        }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                }
                                #endregion
                            }
                            else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                            {
                                #region ＜＜セット薬剤の場合＞＞

                                // -----手技コードを取得-----
                                string strProcedureCode = m_strAnticoagulantProcedureCode.Trim();
                                // -----ルート項目コードを取得-----
                                string strRouteCode = m_strAnticoagulantRouteCode.Trim();
                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                //// 前0詰め3桁
                                //strRouteCode = strRouteCode.PadLeft(3, '0');
                                //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                // -----投与方法項目コードを取得-----   
                                string strMethodCode = m_strAnticoagulantMethodCode.Trim();
                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                //// 前0詰め3桁
                                //strMethodCode = strMethodCode.PadLeft(3, '0');
                                //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更

                                foreach (XmlNode xmlNodeSets in xmlGyokoNode.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                {
                                    // 初期化
                                    strInHospitalCode = string.Empty;
                                    strAmount = string.Empty;

                                    // 薬剤マスタ・注射フラグを取得
                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(注射フラグ)"))
                                    {
                                        // エラー
                                        return false;
                                    }
                                    string strShot = xmlNode.InnerText;
                                    if (strShot == CODE_MEDICINE_SHOT_ON)
                                    {
                                        // -------------------------------------
                                        // 注射薬剤なら注射データを取得設定する
                                        // -------------------------------------
                                        // -----行為詳細項目コードを設定-----
                                        #region 院内コード
                                        // 院内コードを取得
                                        xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(院内コード)"))
                                        {
                                            return false;
                                        }
                                        strInHospitalCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・抗凝固剤(院内コード)"))
                                        {
                                            // 処理続行
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //else
                                        //{
                                        //    // 前0詰め6桁
                                        //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                        //}
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        #endregion

                                        // -----使用量を設定-----
                                        #region 使用薬剤数
                                        xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用薬剤数)"))
                                        {
                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            //return false;
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)");
                                            // 送信データを出力対象から除外 
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        }
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        else
                                        {
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            strAmount = xmlNode.InnerText;
                                            if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用薬剤数"))
                                            {
                                                // 値が空の場合は規定値を設定
                                                strAmount = EMPTY_VAL;
                                            }

                                        #endregion

                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            if (double.Parse(strAmount) == 0)
                                            {
                                                // ワーニングログ出力
                                                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・抗凝固剤(使用薬剤数");
                                                // 送信データを出力対象から除外 
                                            }
                                            else
                                            {
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                // -----上記で取得したデータを注射データクラスリストに格納-----
                                                // 院内コードの有無を確認
                                                if (strInHospitalCode != string.Empty)
                                                {
                                                    // 空チェック・手技が設定されていな場合は無視
                                                    if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                    {
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                        if ("0".Equals(this.m_SameProcedureFlag))
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめて送信」する場合
                                                            // ---------------------------------------------------
                                                            bool bolNewAddflg = false;
                                                            // 既存の注射データリストを参照
                                                            foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                            {
                                                                // 同じ手技コードが既に格納されているか確認
                                                                if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                {
                                                                    // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                    AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                    // 追加フラグ
                                                                    bolNewAddflg = true;
                                                                }
                                                            }
                                                            // 既存リストに追加したか判定
                                                            if (!bolNewAddflg)
                                                            {
                                                                // 既存リストに追加していない場合は新規追加
                                                                List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                InjectionDetailDataMgr.Add(newList);
                                                            }
                                                        }
                                                        else
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめず送信」する場合
                                                            // ---------------------------------------------------
                                                            // 既存の注射データリストを参照
                                                            // すべて新規追加
                                                            List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                            newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                            InjectionDetailDataMgr.Add(newList);
                                                        }
                                                        //bool bolNewAddflg = false;
                                                        //// 既存の注射データリストを参照
                                                        //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                        //{
                                                        //    // 同じ手技コードが既に格納されているか確認
                                                        //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                        //    {
                                                        //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                        //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                        //        // 追加フラグ
                                                        //        bolNewAddflg = true;
                                                        //    }
                                                        //}
                                                        //// 既存リストに追加したか判定
                                                        //if (!bolNewAddflg)
                                                        //{
                                                        //    // 既存リストに追加していない場合は新規追加
                                                        //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                        //    // 2011/01/21 中村 小数点以下の有効桁数対応
                                                        //    // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                                        //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                        //    InjectionDetailDataMgr.Add(newList);
                                                        //}
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                    } 
                                                }
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            }
                                        }
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                    }
                                }
                                #endregion
                            }
                            else
                            {
                                // エラー
                                this.CheckEmptyVal("", CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(VALUE値)・セット薬剤判定");
                                return false;
                            }
                        }
                    }
#endif
                    // ---------------------------------------------------------------------------------------------------------
                    /// 透析実績透析条件履歴を参照・手技コード毎の注射データのジャグ配列(コレクション)を作成する　　＜透析液＞
                    // ---------------------------------------------------------------------------------------------------------
                    strInHospitalCode = string.Empty;
                    strAmount = string.Empty;
                    // 透析実績透析条件履歴を取得
#if false
                    foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                    {
                        // 透析条件項目コードを取得
                        XmlNode xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(透析条件項目コード)"))
                        {
                            // データが無い場合は処理を抜ける
                            break;
                        }
                        string strCtlNo = xmlNode.InnerText;
                        switch (strCtlNo)
                        {
                            case CODE_DIALYSIS_ITEM_HEMODIALYSIS:       // 透析液 
                                // -----院内コードを取得-----    
                                // VALUE値を取得
                                xmlNode = xmlNodes.SelectSingleNode("VALUE");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(VALUE値確認)"))
                                {
                                    return false;
                                }
                                string strValChk = xmlNode.InnerText;
                                // VALUE値確認
                                if (!this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(VALUE値確認)"))
                                {
                                    // VALUE値空はデータなしと判断して処理続行
                                    break;
                                }
                                // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                                if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                                {
                                    // -------------------------------------
                                    // ＜＜通常薬剤の場合＞＞
                                    // -------------------------------------
                                    // 薬剤マスタ・注射フラグを取得
                                    xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(注射フラグ)"))
                                    {
                                        return false;
                                    }
                                    string strShot = xmlNode.InnerText;
                                    // 薬剤マスタ・注射フラグを判定
                                    if (strShot == CODE_MEDICINE_SHOT_ON)
                                    {
                                        // 院内コードを取得
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)"))
                                        {
                                            return false;
                                        }
                                        strInHospitalCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)"))
                                        {
                                            // 処理続行
                                        }
                                        else
                                        {
                                            // 前0詰め6桁
                                            strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                        }
                                    }
                                }
                                else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                                {
                                    // -------------------------------------
                                    // ＜＜セット薬剤の場合＞＞
                                    // -------------------------------------
                                    // ※透析液のセット薬剤は展開しない
                                    // ※透析液のセット薬剤の注射薬剤には対応しない(透析液のセット薬剤の注射薬剤は汎用オーダで送る)
                                }
                                else
                                {
                                    // エラー
                                    this.CheckEmptyVal("", CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)・セット薬剤判定");
                                    return false;
                                }
                                break;
                            case CODE_DIALYSIS_ITEM_HEMODIALYSIS_QUANTIY:   // 透析液量
                                // -----使用量を取得-----
                                xmlNode = xmlNodes.SelectSingleNode("VALUE");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(使用量)"))
                                {
                                    return false;
                                }
                                strAmount = xmlNode.InnerText;   
                                break;
                        }
                    }
                    // 院内コードの有無を確認
                    if (strInHospitalCode != string.Empty)
                    {
                        //// 使用量の値チェック
                        //if (!this.CheckEmptyVal(strAmount, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用量)"))
                        //{
                        //    return false;
                        //}
                        if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(使用量)"))
                        {
                            // 値が空の場合は規定値を設定
                            strAmount = EMPTY_VAL;
                        }
                        // -----手技コードを取得-----
                        string strProcedureCode = m_strHemodialysisProcedureCode.Trim();
                        // -----ルート項目コードを取得-----
                        string strRouteCode = m_strHemodialysisRouteCode.Trim();
                        // 前0詰め3桁
                        strRouteCode = strRouteCode.PadLeft(3, '0');
                        // -----投与方法項目コードを取得-----
                        string strMethodCode = m_strHemodialysisMethodCode.Trim();
                        // 前0詰め3桁
                        strMethodCode = strMethodCode.PadLeft(3, '0');
                        // -----上記で取得したデータを注射データクラスリストに格納-----
                        // 空チェック・手技が設定されていな場合は無視
                        if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                        {
                            bool bolNewAddflg = false;
                            // 既存の注射データリストを参照
                            foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                            {
                                // 同じ手技コードが既に格納されているか確認
                                if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                {
                                    // 同じ手技コードが既に存在する場合はそのリストに追加
                                    AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                    // 追加フラグ
                                    bolNewAddflg = true;
                                }
                            }
                            // 既存リストに追加したか判定
                            if (!bolNewAddflg)
                            {
                                // 既存リストに追加していない場合は新規追加
                                List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                // 2011/01/21 中村 小数点以下の有効桁数対応
                                // newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount));
                                newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                InjectionDetailDataMgr.Add(newList);
                            }
                        }
                    }
#else
                    XmlNode xmlHemodialysisNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_HEMODIALYSIS));
                    if (xmlHemodialysisNode != null)
                    {
                        XmlNode xmlNode = xmlHemodialysisNode.SelectSingleNode("VALUE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(VALUE値確認)"))
                        {
                            return false;
                        }
                        string strValChk = xmlNode.InnerText;
                        // VALUE値確認
                        if (this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(VALUE値確認)"))
                        {
                            // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                            if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                            {
                                #region ＜＜通常薬剤の場合＞＞
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlHemodialysisNode.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(注射フラグ)"))
                                {
                                    return false;
                                }
                                string strShot = xmlNode.InnerText;
                                // 薬剤マスタ・注射フラグを判定
                                if (strShot == CODE_MEDICINE_SHOT_ON)
                                {
                                    // -----行為詳細項目コードを設定-----
                                    #region 院内コード
                                    // 院内コードを取得
                                    xmlNode = xmlHemodialysisNode.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)"))
                                    {
                                        return false;
                                    }
                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                    // 値チェック
                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)"))
                                    {
                                        // 処理続行
                                    }
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    //else
                                    //{
                                    //    // 前0詰め6桁
                                    //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                    //}
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    #endregion

                                    // -----手技コードを取得-----
                                    string strProcedureCode = m_strHemodialysisProcedureCode.Trim();
                                    // -----ルート項目コードを取得-----
                                    string strRouteCode = m_strHemodialysisRouteCode.Trim();
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    //// 前0詰め3桁
                                    //strRouteCode = strRouteCode.PadLeft(3, '0');
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    // -----投与方法項目コードを取得-----
                                    string strMethodCode = m_strHemodialysisMethodCode.Trim();
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                    //// 前0詰め3桁
                                    //strMethodCode = strMethodCode.PadLeft(3, '0');
                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更

                                    // -----使用量を設定-----
                                    #region 透析液量
                                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_HEMODIALYSIS_QUANTIY));
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液量"))
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //return false;
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・透析液量");
                                        // 送信データを出力対象から除外 
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        strAmount = xmlNode.InnerText;
                                        if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液量"))
                                        {
                                            // 値が空の場合は規定値を設定
                                            strAmount = EMPTY_VAL;
                                        }
                                    #endregion

                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        if (double.Parse(strAmount) == 0)
                                        {
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・透析液量");
                                            // 送信データを出力対象から除外 
                                        }
                                        else
                                        {
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                            // -----上記で取得したデータを注射データクラスリストに格納-----
                                            // 院内コードの有無を確認
                                            if (strInHospitalCode != string.Empty)
                                            {
                                                // 空チェック・手技が設定されていな場合は無視
                                                if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                {
                                                    // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                    if ("0".Equals(this.m_SameProcedureFlag))
                                                    {
                                                        // ---------------------------------------------------
                                                        // 同手技で「まとめて送信」する場合
                                                        // ---------------------------------------------------
                                                        bool bolNewAddflg = false;
                                                        // 既存の注射データリストを参照
                                                        foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                        {
                                                            // 同じ手技コードが既に格納されているか確認
                                                            if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                            {
                                                                // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                // 追加フラグ
                                                                bolNewAddflg = true;
                                                            }
                                                        }
                                                        // 既存リストに追加したか判定
                                                        if (!bolNewAddflg)
                                                        {
                                                            // 既存リストに追加していない場合は新規追加
                                                            List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                            newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                            InjectionDetailDataMgr.Add(newList);
                                                        }
                                                    }
                                                    else
                                                    {
                                                        // ---------------------------------------------------
                                                        // 同手技で「まとめず送信」する場合
                                                        // ---------------------------------------------------
                                                        // 既存の注射データリストを参照
                                                        // すべて新規追加
                                                        List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                        newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                        InjectionDetailDataMgr.Add(newList);
                                                    }
                                                    //bool bolNewAddflg = false;
                                                    //// 既存の注射データリストを参照
                                                    //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                    //{
                                                    //    // 同じ手技コードが既に格納されているか確認
                                                    //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                    //    {
                                                    //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                    //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                    //        // 追加フラグ
                                                    //        bolNewAddflg = true;
                                                    //    }
                                                    //}
                                                    //// 既存リストに追加したか判定
                                                    //if (!bolNewAddflg)
                                                    //{
                                                    //    // 既存リストに追加していない場合は新規追加
                                                    //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                    //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                    //    InjectionDetailDataMgr.Add(newList);
                                                    //}
                                                    // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                }
                                            }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        }
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                }
                                #endregion
                            }
                            else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                            {
                                #region ＜＜セット薬剤の場合＞＞
                                #region 透析液量
                                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_HEMODIALYSIS_QUANTIY));
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液量"))
                                {
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    //return false;
                                    // ワーニングログ出力
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・透析液量");
                                    // 送信データを出力対象から除外 
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                }
                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                else
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    double dblSetCnt;
                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液量"))
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //// 値が空の場合は規定値を設定
                                        //dblSetCnt = double.Parse(EMPTY_VAL);
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・透析液量");
                                        // 送信データを出力対象から除外 
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    else
                                    {
                                        // 透析液量を設定
                                        dblSetCnt = double.Parse(xmlNode.InnerText);
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //}
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                #endregion

                                        // -----手技コードを取得-----
                                        string strProcedureCode = m_strHemodialysisProcedureCode.Trim();
                                        // -----ルート項目コードを取得-----
                                        string strRouteCode = m_strHemodialysisRouteCode.Trim();
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strRouteCode = strRouteCode.PadLeft(3, '0');
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----投与方法項目コードを取得-----
                                        string strMethodCode = m_strHemodialysisMethodCode.Trim();
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strMethodCode = strMethodCode.PadLeft(3, '0');
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更

                                        foreach (XmlNode xmlNodeSets in xmlHemodialysisNode.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            // 初期化
                                            strInHospitalCode = string.Empty;
                                            strAmount = string.Empty;

                                            // 薬剤マスタ・注射フラグを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                            // ノードチェック
                                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(注射フラグ)"))
                                            {
                                                return false;
                                            }
                                            string strShot = xmlNode.InnerText;
                                            // 薬剤マスタ・注射フラグを判定
                                            if (strShot == CODE_MEDICINE_SHOT_ON)
                                            {
                                                // -----行為詳細項目コードを設定-----
                                                #region 院内コード
                                                // 院内コードを取得
                                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)"))
                                                {
                                                    return false;
                                                }
                                                strInHospitalCode = xmlNode.InnerText.Trim();
                                                // 値チェック
                                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)"))
                                                {
                                                    // 処理続行
                                                }
                                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                //else
                                                //{
                                                //    // 前0詰め6桁
                                                //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                                //}
                                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                #endregion

                                                // -----使用量を設定-----
                                                #region 使用量を算出
                                                xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用薬剤数)"))
                                                {
                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    //return false;
                                                    // ワーニングログ出力
                                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・透析液(使用薬剤数)");
                                                    // 送信データを出力対象から除外 
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                }
                                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                else
                                                {
                                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    double dblValue;
                                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用薬剤数)"))
                                                    {
                                                        // 値が空の場合は規定値を設定
                                                        dblValue = double.Parse(EMPTY_VAL);
                                                    }
                                                    else
                                                    {
                                                        dblValue = double.Parse(xmlNode.InnerText);
                                                    }
                                                    // 使用量を算出し設定（透析液量 × セット薬剤マスタ・薬剤使用量）
                                                    strAmount = (dblSetCnt * dblValue).ToString();

                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    if (double.Parse(strAmount) == 0)
                                                    {
                                                        // ワーニングログ出力
                                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・透析液量");
                                                        // 送信データを出力対象から除外 
                                                    }
                                                    else
                                                    {
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                                #endregion

                                                        // -----上記で取得したデータを注射データクラスリストに格納-----
                                                        // 院内コードの有無を確認
                                                        if (strInHospitalCode != string.Empty)
                                                        {
                                                            // 空チェック・手技が設定されていな場合は無視
                                                            if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                            {
                                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                                if ("0".Equals(this.m_SameProcedureFlag))
                                                                {
                                                                    // ---------------------------------------------------
                                                                    // 同手技で「まとめて送信」する場合
                                                                    // ---------------------------------------------------
                                                                    bool bolNewAddflg = false;
                                                                    // 既存の注射データリストを参照
                                                                    foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                    {
                                                                        // 同じ手技コードが既に格納されているか確認
                                                                        if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                        {
                                                                            // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                            AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                            // 追加フラグ
                                                                            bolNewAddflg = true;
                                                                        }
                                                                    }
                                                                    // 既存リストに追加したか判定
                                                                    if (!bolNewAddflg)
                                                                    {
                                                                        // 既存リストに追加していない場合は新規追加
                                                                        List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                        newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                        InjectionDetailDataMgr.Add(newList);
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    // ---------------------------------------------------
                                                                    // 同手技で「まとめず送信」する場合
                                                                    // ---------------------------------------------------
                                                                    // 既存の注射データリストを参照
                                                                    // すべて新規追加
                                                                    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                    InjectionDetailDataMgr.Add(newList);
                                                                }
                                                                //bool bolNewAddflg = false;
                                                                //// 既存の注射データリストを参照
                                                                //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                //{
                                                                //    // 同じ手技コードが既に格納されているか確認
                                                                //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                //    {
                                                                //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                //        // 追加フラグ
                                                                //        bolNewAddflg = true;
                                                                //    }
                                                                //}
                                                                //// 既存リストに追加したか判定
                                                                //if (!bolNewAddflg)
                                                                //{
                                                                //    // 既存リストに追加していない場合は新規追加
                                                                //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                //    InjectionDetailDataMgr.Add(newList);
                                                                //}
                                                                // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                            }
                                                        }
                                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    }
                                                }
                                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            }
                                        }
                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                #endregion
                            }
                            else
                            {
                                // エラー
                                this.CheckEmptyVal("", CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・透析液(院内コード)・セット薬剤判定");
                                return false;
                            }
                        }
                    }
#endif

                    // ---------------------------------------------------------------------------------------------------------
                    // 透析実績透析条件履歴を参照・手技コード毎の注射データのジャグ配列(コレクション)を作成する　　＜補液＞
                    // ---------------------------------------------------------------------------------------------------------
                    strInHospitalCode = string.Empty;
                    strAmount = string.Empty;

                    // 補液送信フラグチェック
                    if (m_blnReplenishSendFlg)
                    {
                        // 透析実績透析条件履歴を取得
                        XmlNode xmlReplenishNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_REPLENISH));
                        if (xmlReplenishNode != null)
                        {
                            XmlNode xmlNode = xmlReplenishNode.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(VALUE値確認)"))
                            {
                                return false;
                            }
                            string strValChk = xmlNode.InnerText;
                            // VALUE値確認
                            if (this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(VALUE値確認)"))
                            {
                                // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                                if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                                {
                                    #region ＜＜通常薬剤の場合＞＞
                                    // 薬剤マスタ・注射フラグを取得
                                    xmlNode = xmlReplenishNode.SelectSingleNode("MST_MEDICINE/SHOT");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(注射フラグ)"))
                                    {
                                        return false;
                                    }
                                    string strShot = xmlNode.InnerText;
                                    // 薬剤マスタ・注射フラグを判定
                                    if (strShot == CODE_MEDICINE_SHOT_ON)
                                    {
                                        // -----行為詳細項目コードを設定-----
                                        #region 院内コード
                                        // 院内コードを取得
                                        xmlNode = xmlReplenishNode.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(院内コード)"))
                                        {
                                            return false;
                                        }
                                        strInHospitalCode = xmlNode.InnerText.Trim();
                                        // 値チェック
                                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(院内コード)"))
                                        {
                                            // 処理続行
                                        }
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //else
                                        //{
                                        //    // 前0詰め6桁
                                        //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                        //}
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        #endregion

                                        // -----手技コードを取得-----
                                        string strProcedureCode = m_strReplenishProcedureCode.Trim();
                                        // -----ルート項目コードを取得-----
                                        string strRouteCode = m_strReplenishRouteCode.Trim();
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strRouteCode = strRouteCode.PadLeft(3, '0');
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        // -----投与方法項目コードを取得-----
                                        string strMethodCode = m_strReplenishMethodCode.Trim();
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                        //// 前0詰め3桁
                                        //strMethodCode = strMethodCode.PadLeft(3, '0');
                                        //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更

                                        // -----使用量を設定-----
                                        #region 補液使用数
                                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_REPLENISH_QUANTIY));
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(使用数)"))
                                        {
                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            //return false;
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・補液(使用数)");
                                            // 送信データを出力対象から除外 
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        }
                                        else
                                        {
                                            strAmount = xmlNode.InnerText;
                                            if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(使用数)"))
                                            {
                                                // 値が空の場合は規定値を設定
                                                strAmount = EMPTY_VAL;
                                            }
                                        #endregion

                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            if (double.Parse(strAmount) == 0)
                                            {
                                                // ワーニングログ出力
                                                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・補液(使用数)");
                                                // 送信データを出力対象から除外 
                                            }
                                            else
                                            {
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                                // -----上記で取得したデータを注射データクラスリストに格納-----
                                                // 院内コードの有無を確認
                                                if (strInHospitalCode != string.Empty)
                                                {
                                                    // 空チェック・手技が設定されていな場合は無視
                                                    if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                    {
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                        if ("0".Equals(this.m_SameProcedureFlag))
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめて送信」する場合
                                                            // ---------------------------------------------------
                                                            bool bolNewAddflg = false;
                                                            // 既存の注射データリストを参照
                                                            foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                            {
                                                                // 同じ手技コードが既に格納されているか確認
                                                                if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                {
                                                                    // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                    AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                    // 追加フラグ
                                                                    bolNewAddflg = true;
                                                                }
                                                            }
                                                            // 既存リストに追加したか判定
                                                            if (!bolNewAddflg)
                                                            {
                                                                // 既存リストに追加していない場合は新規追加
                                                                List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                InjectionDetailDataMgr.Add(newList);
                                                            }
                                                        }
                                                        else
                                                        {
                                                            // ---------------------------------------------------
                                                            // 同手技で「まとめず送信」する場合
                                                            // ---------------------------------------------------
                                                            // 既存の注射データリストを参照
                                                            // すべて新規追加
                                                            List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                            newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                            InjectionDetailDataMgr.Add(newList);
                                                        }
                                                        //bool bolNewAddflg = false;
                                                        //// 既存の注射データリストを参照
                                                        //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                        //{
                                                        //    // 同じ手技コードが既に格納されているか確認
                                                        //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                        //    {
                                                        //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                        //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                        //        // 追加フラグ
                                                        //        bolNewAddflg = true;
                                                        //    }
                                                        //}
                                                        //// 既存リストに追加したか判定
                                                        //if (!bolNewAddflg)
                                                        //{
                                                        //    // 既存リストに追加していない場合は新規追加
                                                        //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                        //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                        //    InjectionDetailDataMgr.Add(newList);
                                                        //}
                                                        // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                    }
                                                }
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            }
                                        }
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    #endregion
                                }
                                else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                                {
                                    #region ＜＜セット薬剤の場合＞＞
                                    #region 補液使用数
                                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_REPLENISH_QUANTIY));
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(使用数)"))
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        //return false;
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・補液(使用数)");
                                        // 送信データを出力対象から除外 
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        double dblSetCnt;
                                        if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(使用数)"))
                                        {
                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            //// 値が空の場合は規定値を設定
                                            //dblSetCnt = double.Parse(EMPTY_VAL);
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・補液(使用数)");
                                            // 送信データを出力対象から除外 
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        }
                                        else
                                        {
                                            // 補液使用数を設定
                                            dblSetCnt = double.Parse(xmlNode.InnerText);
                                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                            //}
                                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    #endregion

                                            // -----手技コードを取得-----
                                            string strProcedureCode = m_strReplenishProcedureCode.Trim();
                                            // -----ルート項目コードを取得-----
                                            string strRouteCode = m_strReplenishRouteCode.Trim();
                                            //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                            //// 前0詰め3桁
                                            //strRouteCode = strRouteCode.PadLeft(3, '0');
                                            //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                            // -----投与方法項目コードを取得-----
                                            string strMethodCode = m_strReplenishMethodCode.Trim();
                                            //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                            //// 前0詰め3桁
                                            //strMethodCode = strMethodCode.PadLeft(3, '0');
                                            //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更

                                            foreach (XmlNode xmlNodeSets in xmlReplenishNode.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                            {
                                                // 初期化
                                                strInHospitalCode = string.Empty;
                                                strAmount = string.Empty;

                                                // 薬剤マスタ・注射フラグを取得
                                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(注射フラグ)"))
                                                {
                                                    return false;
                                                }
                                                string strShot = xmlNode.InnerText;
                                                // 薬剤マスタ・注射フラグを判定
                                                if (strShot == CODE_MEDICINE_SHOT_ON)
                                                {
                                                    // -----行為詳細項目コードを設定-----
                                                    #region 院内コード
                                                    // 院内コードを取得
                                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(院内コード)"))
                                                    {
                                                        return false;
                                                    }
                                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                                    // 値チェック
                                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(院内コード)"))
                                                    {
                                                        // 処理続行
                                                    }
                                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                    //else
                                                    //{
                                                    //    // 前0詰め6桁
                                                    //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                                    //}
                                                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                                    #endregion

                                                    // -----使用量を設定-----
                                                    #region 使用量を算出
                                                    xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                                    // ノードチェック
                                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用薬剤数)"))
                                                    {
                                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                        //return false;
                                                        // ワーニングログ出力
                                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・補液(使用薬剤数)");
                                                        // 送信データを出力対象から除外 
                                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    }
                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                    else
                                                    {
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                        double dblValue;
                                                        if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用薬剤数)"))
                                                        {
                                                            // 値が空の場合は規定値を設定
                                                            dblValue = double.Parse(EMPTY_VAL);
                                                        }
                                                        else
                                                        {
                                                            dblValue = double.Parse(xmlNode.InnerText);
                                                        }
                                                        // 使用量を算出し設定（補液使用数 × セット薬剤マスタ・薬剤使用量）
                                                        strAmount = (dblSetCnt * dblValue).ToString();
                                                    #endregion

                                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                        if (double.Parse(strAmount) == 0)
                                                        {
                                                            // ワーニングログ出力
                                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・補液(使用薬剤数)");
                                                            // 送信データを出力対象から除外 
                                                        }
                                                        else
                                                        {
                                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                                            // -----上記で取得したデータを注射データクラスリストに格納-----
                                                            // 院内コードの有無を確認
                                                            if (strInHospitalCode != string.Empty)
                                                            {
                                                                // 空チェック・手技が設定されていな場合は無視
                                                                if (this.CheckEmptyVal(strProcedureCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクション準備(手技コード取得)"))
                                                                {
                                                                    // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG Start
                                                                    if ("0".Equals(this.m_SameProcedureFlag))
                                                                    {
                                                                        // ---------------------------------------------------
                                                                        // 同手技で「まとめて送信」する場合
                                                                        // ---------------------------------------------------
                                                                        bool bolNewAddflg = false;
                                                                        // 既存の注射データリストを参照
                                                                        foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                        {
                                                                            // 同じ手技コードが既に格納されているか確認
                                                                            if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                            {
                                                                                // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                                AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                                // 追加フラグ
                                                                                bolNewAddflg = true;
                                                                            }
                                                                        }
                                                                        // 既存リストに追加したか判定
                                                                        if (!bolNewAddflg)
                                                                        {
                                                                            // 既存リストに追加していない場合は新規追加
                                                                            List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                            newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                            InjectionDetailDataMgr.Add(newList);
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        // ---------------------------------------------------
                                                                        // 同手技で「まとめず送信」する場合
                                                                        // ---------------------------------------------------
                                                                        // 既存の注射データリストを参照
                                                                        // すべて新規追加
                                                                        List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                        newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                        InjectionDetailDataMgr.Add(newList);
                                                                    }
                                                                    //bool bolNewAddflg = false;
                                                                    //// 既存の注射データリストを参照
                                                                    //foreach (List<InjectionDetailData> injectionDetailDataList in InjectionDetailDataMgr)
                                                                    //{
                                                                    //    // 同じ手技コードが既に格納されているか確認
                                                                    //    if (injectionDetailDataList[0].ProcedureCode == strProcedureCode)
                                                                    //    {
                                                                    //        // 同じ手技コードが既に存在する場合はそのリストに追加
                                                                    //        AddInjectionDetailData(injectionDetailDataList, strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, strAmount);
                                                                    //        // 追加フラグ
                                                                    //        bolNewAddflg = true;
                                                                    //    }
                                                                    //}
                                                                    //// 既存リストに追加したか判定
                                                                    //if (!bolNewAddflg)
                                                                    //{
                                                                    //    // 既存リストに追加していない場合は新規追加
                                                                    //    List<InjectionDetailData> newList = new List<InjectionDetailData>();
                                                                    //    newList.Add(new InjectionDetailData(strProcedureCode, strRouteCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount)));
                                                                    //    InjectionDetailDataMgr.Add(newList);
                                                                    //}
                                                                    // 2013/10/31 阿部(浩) 同手技送信方法対応 CHG End
                                                                }
                                                            }
                                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                        }
                                                    }
                                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                                }
                                            }
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        }
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                    #endregion
                                }
                                else
                                {
                                    // エラー
                                    this.CheckEmptyVal("", CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダディテール・補液(院内コード)・セット薬剤判定");
                                    return false;
                                }
                            }
                        }
                    }

                    // ----------------------------------------------------------------------------------- 
                    // 上記で作成した手技コード毎のジャグ配列を元に注射オーダ・グループコレクションを作成する
                    // ----------------------------------------------------------------------------------- 
                    // 件数チェック
                    if (InjectionDetailDataMgr.Count == 0)
                    {
                        // 削除区分か判定
                        if (strChangeSendClass == EVENT_TYPE_DEL)
                        {
                            // 削除の場合はデータが無いので空のコレクションを作成する
                            // ▼注射オーダ・グループコレクションを作成▼
                            if (!SetInjectionOrderGroupData(exeInfo, InjectionDetailDataMgr))
                            {
                                // エラー
                                return false;
                            }
                        }
                        else
                        {   
                            // エラー　※上位で注射オーダデータの有無確認を行っているので、ここに入ってくることは院内コードが未設定の場合、、、、←院内コードのないパターンには現在未対応
                            // >>>>>【Ver.5.0.2.100】2015.08.04 石川 特殊浄化対応
                            //this.CheckEmptyVal("", CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "グループコレクションを作成する為のデータがありません");
                            this.CheckEmptyVal("", CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION_NODATE, "グループコレクションを作成する為のデータがありません");
                            m_blnInjectionNotDataFlag = true;
                            // <<<<<【Ver.5.0.2.100】2015.08.04 石川 特殊浄化対応                       
                            return false;
                        }
                    }
                    else
                    {
                        // ▼注射オーダ・グループコレクションを作成▼
                        if (!SetInjectionOrderGroupData(exeInfo, InjectionDetailDataMgr))
                        {
                            // エラー
                            return false;
                        }
                    }
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    // 注射オーダ・グループコレクション(削除用)を作成
                    SetInjectionOrderGroupDataDell();
                    break;
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }

        /// <summary>
        /// 注射オーダ・グループコレクション(新規・修正用)を設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="xmlData"></param>
        /// <returns>true:正常/false:異常</returns>
        private bool SetInjectionOrderGroupData(Fn3ExecuteInfo exeInfo, List<List<InjectionDetailData>> InjectionDetailDataMgr)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;
            XmlNode xmlNode = null;
            string strNode = null;

            foreach (List<InjectionDetailData> InjectionDetailDataRoot in InjectionDetailDataMgr)
            {
                // -----------------------------------------------
                // -- グループ・開始日付・0 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(0, strSetData);
                // -----------------------------------------------
                // -- グループ・開始時刻・1 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(1, strSetData);
                // -----------------------------------------------
                // -- グループ・実施進捗・2 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(2, strSetData);
                // -----------------------------------------------
                // -- グループ・実施病棟・3 --（※必須項目ではない）
                // -----------------------------------------------
                // 透析実績履歴・病棟コードの有無を確認　※必須項目でないので病院コードの有無を確認し院内コードを取得する
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/WARD_CD");
                // ノードチェック
                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施病棟(病棟コード)"))
                {
                    return false;
                }
                strSetData = xmlNode.InnerText;
                // 値チェック
                if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施病棟(病棟コード)"))
                {
                    // 必須ではないので続行
                    strSetData = null;
                }
                else
                {
                    // 透析実績履歴・病棟マスタ・院内コードを設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/MST_WARD/IN_HOSPITAL_CD");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施病棟(院内コード)"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施病棟(院内コード)"))
                    {
                        // 必須ではないので続行
                        strSetData = null;
                    }
                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    //else
                    //{
                    //    // 前0詰め2桁
                    //    strSetData = strSetData.PadLeft(2, '0');
                    //}
                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                }
                CSICommon.pSetGROUPData(3, strSetData);
                // -----------------------------------------------
                // -- グループ・実施病室・4 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(4, strSetData);
                // -----------------------------------------------
                // -- グループ・実施日・5 --
                // -----------------------------------------------
                // 透析実績履歴・透析開始日時を設定
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                // ノードチェック
                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施日"))
                {
                    return false;
                }
                strNode = xmlNode.InnerText;
                // 値チェック
                if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施日"))
                {
                    return false;
                }
                strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_DAY);
                CSICommon.pSetGROUPData(5, strSetData);
                // -----------------------------------------------
                // -- グループ・実施時刻・6 --
                // -----------------------------------------------
                // 透析実績履歴・透析開始日時を設定
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                // ノードチェック
                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施時刻"))
                {
                    return false;
                }
                strNode = xmlNode.InnerText;
                // 値チェック
                if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施時刻"))
                {
                    return false;
                }
                strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_TIME_SS);
                CSICommon.pSetGROUPData(6, strSetData);
                // -----------------------------------------------
                // -- グループ・実施者・7 --
                // -----------------------------------------------
                // 透析実績版番管理・版確定者を設定
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                // ノードチェック
                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施者"))
                {
                    return false;
                }
                strSetData = xmlNode.InnerText.Trim();
                // 値チェック
                if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDERINJECTION, "オーダグループ・実施者"))
                {
                    return false;
                }
                // 2011/01/11 中村 スタッフコード0詰めなし対応
                // // 前0詰め5桁
                // strSetData = strSetData.PadLeft(5, '0');
                CSICommon.pSetGROUPData(7, strSetData);
                // -----------------------------------------------
                // -- グループ・実施番号・8 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(8, strSetData);
                // -----------------------------------------------
                // -- グループ・期間・9 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(9, strSetData);
                // -----------------------------------------------
                // -- グループ・グループ種・10 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(10, strSetData);
                // -----------------------------------------------
                // -- グループ・ルート項目コード・11 --
                // -----------------------------------------------
                strSetData = InjectionDetailDataRoot[0].RouteCode;
                CSICommon.pSetGROUPData(11, strSetData);
                // -----------------------------------------------
                // -- グループ・回数・12 --
                // -----------------------------------------------
                // 「“1”：オーダの回数」を設定（固定値）
                strSetData = "1";
                CSICommon.pSetGROUPData(12, strSetData);
                // -----------------------------------------------
                // -- グループ・投与方法項目コード・13 --
                // -----------------------------------------------
                strSetData = InjectionDetailDataRoot[0].MethodCode;
                CSICommon.pSetGROUPData(13, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメントコード・14 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(14, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメント入力区分・15 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(15, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメント名称・16 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(16, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメントコード２・17 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(17, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメント入力区分２・18 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(18, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメント名称２・19 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(19, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメントコード３・20 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(20, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメント入力区分３・21 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(21, strSetData);
                // -----------------------------------------------
                // -- グループ・ルートコメント名称３・22 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(22, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメントコード・23 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(23, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメント入力区分・24 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(24, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメント名称・25 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(25, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメントコード２・26 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(26, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメント入力区分２・27 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(27, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメント名称２・28 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(28, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメントコード３・29 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(29, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメント入力区分３・30 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(30, strSetData);
                // -----------------------------------------------
                // -- グループ・Ｒｐコメント名称３・31 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(31, strSetData);
                // -----------------------------------------------
                // -- グループ・開始時刻一回目・32 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(32, strSetData);
                // -----------------------------------------------
                // -- グループ・開始時刻二回目・33 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(33, strSetData);
                // -----------------------------------------------
                // -- グループ・開始時刻三回目・34 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(34, strSetData);
                // -----------------------------------------------
                // -- グループ・開始時刻四回目・35 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(35, strSetData);
                // -----------------------------------------------
                // -- グループ・開始時刻五回目・36 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(36, strSetData);
                // -----------------------------------------------
                // -- グループ・開始時刻六回目・37 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(37, strSetData);
                // -----------------------------------------------
                // -- グループ・指定速度・38 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetGROUPData(38, strSetData);
                // -----------------------------------------------
                // -- グループ・オーダディテールコレクション・39 --
                // -----------------------------------------------
                // オーダディテールコレクションをクリアする
                // ※ディテールコレクションを使いまわすのでクリアは必須 
                CSICommon.ClearColParameter(ref CSICommon.colDETAIL);
                // オーダディテールコレクション(新規・修正用)を作成する
                bool bolRet = SetInjectionOrderDetail(InjectionDetailDataRoot);
                if (bolRet)
                {
                    // オーダディテールコレクションを設定する
                    CSICommon.pSetGROUPData(39, (VBA.Collection)CSICommon.colDETAIL);
                }
                else
                {
                    // エラー
                    return false;
                }

                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                // ++ オーダグループコレクションにオーダグループ配列を追加 ++
                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                CSICommon.pSetCollection(3, CSICommon.varGROUP);
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }

        /// <summary>
        /// 注射オーダ・グループコレクション(削除用)を設定する。
        /// </summary>
        private void SetInjectionOrderGroupDataDell()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;
            // -----------------------------------------------
            // -- グループ・開始日付・0 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(0, strSetData);
            // -----------------------------------------------
            // -- グループ・開始時刻・1 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(1, strSetData);
            // -----------------------------------------------
            // -- グループ・実施進捗・2 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(2, strSetData);
            // -----------------------------------------------
            // -- グループ・実施病棟・3 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(3, strSetData);
            // -----------------------------------------------
            // -- グループ・実施病室・4 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(4, strSetData);
            // -----------------------------------------------
            // -- グループ・実施日・5 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(5, strSetData);
            // -----------------------------------------------
            // -- グループ・実施時刻・6 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(6, strSetData);
            // -----------------------------------------------
            // -- グループ・実施者・7 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(7, strSetData);
            // -----------------------------------------------
            // -- グループ・実施番号・8 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(8, strSetData);
            // -----------------------------------------------
            // -- グループ・期間・9 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(9, strSetData);
            // -----------------------------------------------
            // -- グループ・グループ種・10 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(10, strSetData);
            // -----------------------------------------------
            // -- グループ・ルート項目コード・11 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(11, strSetData);
            // -----------------------------------------------
            // -- グループ・回数・12 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(12, strSetData);
            // -----------------------------------------------
            // -- グループ・投与方法項目コード・13 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(13, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメントコード・14 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(14, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメント入力区分・15 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(15, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメント名称・16 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(16, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメントコード２・17 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(17, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメント入力区分２・18 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(18, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメント名称２・19 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(19, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメントコード３・20 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(20, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメント入力区分３・21 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(21, strSetData);
            // -----------------------------------------------
            // -- グループ・ルートコメント名称３・22 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(22, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメントコード・23 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(23, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメント入力区分・24 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(24, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメント名称・25 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(25, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメントコード２・26 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(26, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメント入力区分２・27 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(27, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメント名称２・28 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(28, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメントコード３・29 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(29, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメント入力区分３・30 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(30, strSetData);
            // -----------------------------------------------
            // -- グループ・Ｒｐコメント名称３・31 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(31, strSetData);
            // -----------------------------------------------
            // -- グループ・開始時刻一回目・32 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(32, strSetData);
            // -----------------------------------------------
            // -- グループ・開始時刻二回目・33 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(33, strSetData);
            // -----------------------------------------------
            // -- グループ・開始時刻三回目・34 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(34, strSetData);
            // -----------------------------------------------
            // -- グループ・開始時刻四回目・35 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(35, strSetData);
            // -----------------------------------------------
            // -- グループ・開始時刻五回目・36 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(36, strSetData);
            // -----------------------------------------------
            // -- グループ・開始時刻六回目・37 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(37, strSetData);
            // -----------------------------------------------
            // -- グループ・指定速度・38 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(38, strSetData);
            // -----------------------------------------------
            // -- グループ・オーダディテールコレクション・39 --
            // -----------------------------------------------
            // オーダディテールコレクション(削除用)を作成する
            SetInjectionOrderDetailDell();

            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダグループコレクションにオーダグループ配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(3, CSICommon.varGROUP);

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }
        #endregion


        #region 注射オーダ・ディテール
        /// <summary>
        /// 注射オーダ・ディテールコレクション(新規・修正用)を設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <returns>true:正常/false:異常</returns>
        private bool SetInjectionOrderDetail(List<InjectionDetailData> InjectionDetailDataChildList)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;

            foreach (InjectionDetailData InjectionDetailDataChild in InjectionDetailDataChildList)
            {
                // -----------------------------------------------
                // -- ディテール・薬剤コード・0 --
                // -----------------------------------------------
                strSetData = InjectionDetailDataChild.InHospitalCode;
                CSICommon.pSetDETAILData(0, strSetData);
                // -----------------------------------------------
                // -- ディテール・入力数量・1 --
                // -----------------------------------------------
                strSetData = InjectionDetailDataChild.Amount;
                CSICommon.pSetDETAILData(1, strSetData);
                // -----------------------------------------------
                // -- ディテール・入力単位・2 --
                // -----------------------------------------------
                // 「“1”：単位1をセット」を設定（固定値）
                strSetData = "1";
                CSICommon.pSetDETAILData(2, strSetData);
                // -----------------------------------------------
                // -- ディテール・薬剤コメントコード・3 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetDETAILData(3, strSetData);
                // -----------------------------------------------
                // -- ディテール・コメント入力方法・4 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetDETAILData(4, strSetData);
                // -----------------------------------------------
                // -- ディテール・コメント名称・5 --
                // -----------------------------------------------
                strSetData = null;
                CSICommon.pSetDETAILData(5, strSetData);

                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                // ++ オーダディテールコレクションにオーダディテール配列を追加 ++
                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                CSICommon.pSetCollection(4, CSICommon.varDETAIL);
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }

        /// <summary>
        /// 注射オーダ・ディテールコレクション(削除用)を設定する。
        /// </summary>
        private void SetInjectionOrderDetailDell()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;
            // -----------------------------------------------
            // -- ディテール・薬剤コード・0 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(0, strSetData);
            // -----------------------------------------------
            // -- ディテール・入力数量・1 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(1, strSetData);
            // -----------------------------------------------
            // -- ディテール・入力単位・2 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(2, strSetData);
            // -----------------------------------------------
            // -- ディテール・薬剤コメントコード・3 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(3, strSetData);
            // -----------------------------------------------
            // -- ディテール・コメント入力方法・4 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(4, strSetData);
            // -----------------------------------------------
            // -- ディテール・コメント名称・5 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(5, strSetData);

            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダディテールコレクションにオーダディテール配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(4, CSICommon.varDETAIL);

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }
        #endregion


        #region 注射オーダ・その他
        /// <summary>
        /// 「イベントの送信区分」と「実際の送信データ(注射オーダ)」の有無から実際の送信区分を決定する
        /// ※例：「イベントの送信区分が修正」で「データが無い」場合 ⇒ 処理区分が削除になる
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="strSendClass">処理区分</param>
        /// <returns>送信区分(nullの場合は送信データがない)</returns>
        private string ChangeSendClass(Fn3ExecuteInfo exeInfo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strChangeSendClass = null;
            string[] strBuf;
            string strOrderNo;

            // 注射データの有無を判定する
            bool bolChackInjectionDetailData = ChackInjectionDetailData(exeInfo);

            // 送信区分(exeInfo.SendClass)を判断する
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                    // 注射データの有無の確認
                    if (bolChackInjectionDetailData)
                    {
                        // 注射データ有り ⇒ 新規区分
                        strChangeSendClass = EVENT_TYPE_ADD;
                    }
                    else
                    {
                        // 注射データ無し ⇒ 送信しない
                        strChangeSendClass = null;
                    }

                    break;
                case EVENT_TYPE_CHG:   // 修正 
                    // オーダ番号を取得する(オーダ番号の有無で送信実績を判断する）
                    strBuf = exeInfo.SendHistMemo.Split(',');
                    strOrderNo = strBuf[2];
                    // 注射データの有無の確認
                    if (bolChackInjectionDetailData)
                    {
                        // 送信実績の有無の確認
                        if (strOrderNo == NONE)
                        {
                            // 注射データ有り・送信実績の無し ⇒ 新規区分
                            strChangeSendClass = EVENT_TYPE_ADD;
                        }
                        else
                        {
                            // 注射データ有り・送信実績の有り ⇒ 修正区分
                            strChangeSendClass = EVENT_TYPE_CHG;
                        }
                    }
                    else
                    {
                        // 送信実績の有無の確認
                        if (strOrderNo == NONE)
                        {
                            // 注射データ無し・送信実績の無し ⇒ 送信しない
                            strChangeSendClass = null;
                        }
                        else
                        {
                            // 注射データ無し・送信実績の有り ⇒ 削除区分
                            strChangeSendClass = EVENT_TYPE_DEL;
                        }
                    }
                    break;
                case EVENT_TYPE_DEL:   // 削除
                    // オーダ番号を取得する(オーダ番号の有無で送信実績を判断する）
                    strBuf = exeInfo.SendHistMemo.Split(',');
                    strOrderNo = strBuf[2];

                    // 注射データの有無の確認
                    if (bolChackInjectionDetailData)
                    {
                        // 送信実績の有無の確認
                        if (strOrderNo == NONE)
                        {
                            // 注射データ有り・送信実績の無し ⇒ 送信しない
                            strChangeSendClass = null;
                        }
                        else
                        {
                            // 注射データ有り・送信実績の有り ⇒ 削除区分
                            strChangeSendClass = EVENT_TYPE_DEL;
                        }
                    }
                    else
                    {
                        // 送信実績の有無の確認
                        if (strOrderNo == NONE)
                        {
                            // 注射データ無し・送信実績の無し ⇒ 送信しない（ここに来る場合はバグ）
                            strChangeSendClass = null;
                        }
                        else
                        {
                            // 注射データ無し・送信実績の有り ⇒ 送信しない
                            strChangeSendClass = null;
                        }
                    }
                    break;
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            // 処理区分を返す
            return strChangeSendClass;
        }

        /// <summary>
        /// 注射オーダのデータの有無を判定する
        /// ※データの有無以外は確認しない
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="strSendClass">処理区分</param>
        /// <returns>true:注射オーダ有り/false:注射オーダ無し</returns>
        private bool ChackInjectionDetailData(Fn3ExecuteInfo exeInfo)
        {
            // --------------------------------------------------------------------------------------
            // 透析実績投薬履歴を参照
            // --------------------------------------------------------------------------------------
            foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_MEDICATION_HST"))
            {
                // 指示実施フラグを取得
                XmlNode xmlNode = xmlNodes.SelectSingleNode("EFFECT_FLG");
                // ノードチェック
                if (xmlNode != null)
                {
                    // 指示実施済みか判断する
                    if (xmlNode.InnerText == DB_EFFECT_FLG_ON)
                    {
                        // セット薬剤使用フラグを取得
                        xmlNode = xmlNodes.SelectSingleNode("SET_MEDICINE_FLG");
                        // ノードチェック
                        if (xmlNode != null)
                        {
                            // 通常薬剤かセット薬剤か判断する(0：通常、1：セット薬剤)
                            if (xmlNode.InnerText == CODE_MEDICINE_NORMAL)
                            {
                                // ○通常薬剤の場合○
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (xmlNode != null)
                                {
                                    // 注射薬剤か判定する
                                    if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                    {
                                        // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        // 院内コードの有無を確認
                                        if (xmlNode.InnerText.Trim() != string.Empty)
                                        {
                                            // 注射オーダ有り
                                            return true;
                                        }
                                    }
                                }
                            }
                            else if (xmlNode.InnerText == CODE_MEDICINE_SET)
                            {
                                // ○セット薬剤の場合○
                                // セット薬剤マスタを取得
                                foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                {
                                    // 薬剤マスタ・注射フラグを取得
                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                    // ノードチェック
                                    if (xmlNode != null)
                                    {
                                        // 注射薬剤か判定する
                                        if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                        {
                                            // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                            // 院内コードの有無を確認
                                            if (xmlNode.InnerText.Trim() != string.Empty)
                                            {
                                                // 注射オーダ有り
                                                return true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // ------------------------------------------------------------------------------------------------
            // 透析実績愁訴処置_処置履歴を参照
            // ------------------------------------------------------------------------------------------------
            foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_TREATMENT_HST"))
            {
                // 透析実績愁訴処置_処置履歴・処置区分を取得・データ無しは続行
                XmlNode xmlNode = xmlNodes.SelectSingleNode("TREAT_CLASS");
                if (xmlNode != null)
                {
                    // 処理区分を判定する
                    string strTreatClass = xmlNode.InnerText;
                    if (strTreatClass == CODE_DIALYSIS_TREATMEN_DRUG)
                    {
                        // ○処理区分が薬剤の場合は通常薬剤となる○
                        // 薬剤マスタ・注射フラグを取得
                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                        // ノードチェック
                        if (xmlNode != null)
                        {
                            // 注射薬剤か判定する
                            if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                            {
                                // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                // 院内コードの有無を確認
                                if (xmlNode.InnerText.Trim() != string.Empty)
                                {
                                    // 注射オーダ有り
                                    return true;
                                }
                            }
                        }
                    }
                    else if (strTreatClass == CODE_DIALYSIS_TREATMEN_TREATDRUG)
                    {
                        // ○処理区分が処置薬剤の場合はセット薬剤となる○
                        // 透析実績愁訴処置_処置履歴・セット薬剤名称マスタ・セット薬剤マスタ
                        foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                        {
                            // 薬剤マスタ・注射フラグを取得
                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                            // ノードチェック
                            if (xmlNode != null)
                            {
                                // 注射薬剤か判定する
                                if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                {
                                    // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // 院内コードの有無を確認
                                    if (xmlNode.InnerText.Trim() != string.Empty)
                                    {
                                        // 注射オーダ有り
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // --------------------------------------------------------------------------------------
            // 透析実績透析条件履歴を参照
            // --------------------------------------------------------------------------------------
            foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
            {
                // 透析条件項目コードを取得
                XmlNode xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                // ノードチェック
                if (xmlNode != null)
                {
                    switch (xmlNode.InnerText)
                    {
                        case CODE_DIALYSIS_ITEM_GYOKO: // 抗凝固剤
                            // VALUE値を取得
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (xmlNode != null)
                            {
                                // VALUE値確認
                                if (xmlNode.InnerText != string.Empty)
                                {
                                    // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                                    if (xmlNode.InnerText.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                                    {
                                        #region ＜＜通常薬剤の場合＞＞
                                        // 薬剤マスタ・注射フラグを取得
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                        // ノードチェック
                                        if (xmlNode != null)
                                        {
                                            // 注射薬剤か判定する
                                            if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                            {
                                                // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                // 院内コードの有無を確認
                                                if (xmlNode.InnerText.Trim() != string.Empty)
                                                {
                                                    // 注射オーダ有り
                                                    return true;
                                                }
                                            }
                                        }
                                        #endregion
                                    }
                                    else
                                    {
                                        #region ＜＜セット薬剤の場合＞＞
                                        // 透析実績透析条件履歴(抗凝固剤)・セット薬剤名称マスタ・セット薬剤マスタ
                                        foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            // 薬剤マスタ・注射フラグを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                            // ノードチェック
                                            if (xmlNode != null)
                                            {
                                                // 注射薬剤か判定する
                                                if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                                {
                                                    // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                    // 院内コードの有無を確認
                                                    if (xmlNode.InnerText.Trim() != string.Empty)
                                                    {
                                                        // 注射オーダ有り
                                                        return true;
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                    }
                                }
                            }
                            break;
                        case CODE_DIALYSIS_ITEM_HEMODIALYSIS: // 透析液
                            // VALUE値を取得
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (xmlNode != null)
                            {
                                // VALUE値確認
                                if (xmlNode.InnerText != string.Empty)
                                {
                                    // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                                    if (xmlNode.InnerText.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                                    {
                                        #region ＜＜通常薬剤の場合＞＞
                                        // 薬剤マスタ・注射フラグを取得
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                        // ノードチェック
                                        if (xmlNode != null)
                                        {
                                            // 注射薬剤か判定する
                                            if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                            {
                                                // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                // 院内コードの有無を確認
                                                if (xmlNode.InnerText.Trim() != string.Empty)
                                                {
                                                    // 注射オーダ有り
                                                    return true;
                                                }
                                            }
                                        }
                                        #endregion
                                    }
                                    else
                                    {
                                        #region ＜＜セット薬剤の場合＞＞
                                        // 透析実績透析条件履歴(透析液)・セット薬剤名称マスタ・セット薬剤マスタ
                                        foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            // 薬剤マスタ・注射フラグを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                            // ノードチェック
                                            if (xmlNode != null)
                                            {
                                                // 注射薬剤か判定する
                                                if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                                {
                                                    // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                    // 院内コードの有無を確認
                                                    if (xmlNode.InnerText.Trim() != string.Empty)
                                                    {
                                                        // 注射オーダ有り
                                                        return true;
                                                    }
                                                }
                                            }
                                        }
                                        #endregion                                    }
                                    }
                                }
                            }
                            break;
                        case CODE_DIALYSIS_ITEM_REPLENISH:  // 補液
                            // VALUE値を取得
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (xmlNode != null)
                            {
                                // VALUE値確認
                                if (xmlNode.InnerText != string.Empty)
                                {
                                    // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                                    if (xmlNode.InnerText.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                                    {
                                        #region ＜＜通常薬剤の場合＞＞
                                        // 薬剤マスタ・注射フラグを取得
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                        // ノードチェック
                                        if (xmlNode != null)
                                        {
                                            // 注射薬剤か判定する
                                            if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                            {
                                                // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                // 院内コードの有無を確認
                                                if (xmlNode.InnerText.Trim() != string.Empty)
                                                {
                                                    // 注射オーダ有り
                                                    return true;
                                                }
                                            }
                                        }
                                        #endregion
                                    }
                                    else
                                    {
                                        #region ＜＜セット薬剤の場合＞＞
                                        // 透析実績透析条件履歴(補液)・セット薬剤名称マスタ・セット薬剤マスタ
                                        foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            // 薬剤マスタ・注射フラグを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                            // ノードチェック
                                            if (xmlNode != null)
                                            {
                                                // 注射薬剤か判定する
                                                if (xmlNode.InnerText == CODE_MEDICINE_SHOT_ON)
                                                {
                                                    // 院内コードを取得（ノードチェックは上記で行っているので省略）
                                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                    // 院内コードの有無を確認
                                                    if (xmlNode.InnerText.Trim() != string.Empty)
                                                    {
                                                        // 注射オーダ有り
                                                        return true;
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                    }
                                }
                            }
                            break;
                    }
                }
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            // 注射オーダ無し
            return false;
        }

        /// <summary>
        /// ディテールリストにディテールデータを追加する(同一薬剤の場合は数量を纏める)
        /// </summary>
        /// <param name="injectionDetailDataList">オーダティテールデータリスト※ref渡しではないので注意！</param>
        /// <param name="ProcedureCode">手技コード</param>
        /// <param name="RouteCode">ルート項目コード</param>
        /// <param name="MethodCode">投与方法項目コード</param>
        /// <param name="InHospitalCode">薬剤コード（院内コード）</param>
        /// <param name="Amount">入力数量(数量)</param>
        private void AddInjectionDetailData(List<InjectionDetailData> injectionDetailDataList, string strProcedureCode, string strRouteCode, string strMethodCode, string strInHospitalCode, string strAmount)
        {
            bool bolAddFlg = true;

            // オーダディテールデータリストを参照
            foreach (InjectionDetailData detailData in injectionDetailDataList)
            {
                //院内コード及び機能コードを比較
                if (detailData.InHospitalCode == strInHospitalCode)
                {
                    // 院内コードと機能コードともに一致するデータ存在する場合はその項目に数量を足す
                    // 2011/01/21 中村 小数点以下の有効桁数対応
                    // detailData.Amount = (double.Parse(detailData.Amount) + double.Parse(strAmount)).ToString();
                    detailData.Amount = this.RoundDecimal((double.Parse(detailData.Amount) + double.Parse(strAmount)).ToString());
                    bolAddFlg = false;
                }
            }
            // 同一のデータの存在確認
            if (bolAddFlg)
            {
                // 同一のデータが存在しない場合はリストに新規追加する
                // 2011/01/21 中村 小数点以下の有効桁数対応
                // InjectionDetailData detailNewData = new InjectionDetailData(strProcedureCode, strMethodCode, strMethodCode, strInHospitalCode, strAmount);
                InjectionDetailData detailNewData = new InjectionDetailData(strProcedureCode, strMethodCode, strMethodCode, strInHospitalCode, this.RoundDecimal(strAmount));
                injectionDetailDataList.Add(detailNewData);
            }
        }
        #endregion

        #endregion
    }
}
