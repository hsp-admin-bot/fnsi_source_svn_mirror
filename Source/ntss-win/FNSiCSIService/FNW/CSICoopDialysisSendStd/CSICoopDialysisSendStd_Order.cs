///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：シーエスアイ標準連携　透析実績送信機能
// ファイル名：CSICoopDialysisSendStd_Order.cs
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
//  2011/02/22  堀内英史            処置送信対応
//  2011/05/13  中村圭之介          指示医対応（新里ﾒﾃﾞｨｹｱ版よりマージ）
//  2012/02/01  中村圭之介          オーダ番号オーバーフロー対応
//  2015/07/29  石川俊介            特殊浄化対応,ログ強化
//  2015/09/03  中村圭之介          受入指摘対応(Redmine#4953)
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

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        /// <summary>
        /// 汎用オーダ送信モード
        /// </summary>
        private enum OrderSendMode
        {
            Dialisys,
            Oxygen,
            Ecg,
            Treatment
        }
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        #region 汎用オーダ・データクラス
        /// <summary>
        /// 汎用オーダ・ディテール作成用データクラス
        /// ※当初structだったが値の再代入が出来ないのでclassに変更する。
        /// </summary>
        private class OrderDetailData
        {
            /// <summary>
            /// 機能コード
            /// </summary>
            public string FunctionCode;
            /// <summary>
            /// 院内コード（薬剤マスタ・院内コード）
            /// </summary>
            public string InHospitalCode;
            /// <summary>
            /// 数量
            /// </summary>
            public string Amount;

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            /// <summary>
            /// 開始時間
            /// </summary>
            public string StartTime;
            /// <summary>
            /// 終了時間
            /// </summary>
            public string EndTime;
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            
            /// <summary>
            /// コンストラクタ
            /// </summary>
            /// <param name="strProcedureCode">機能コード</param>
            /// <param name="strInHospitalCode">院内コード</param>
            /// <param name="strAmount">数量(</param>
            public OrderDetailData(string strFunctionCode, string strInHospitalCode, string strAmount, string strStartTime, string strEndTime)
            {
                FunctionCode = strFunctionCode;
                InHospitalCode = strInHospitalCode;
                Amount = strAmount;
                StartTime = strStartTime;
                EndTime = strEndTime;
            }
        }
        #endregion

        #endregion


        #region メソッド定義・プライベート

        #region 汎用オーダ・メイン
        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        ///// <summary>
        ///// 汎用オーダ・データ設定送信マネージャ。
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <param name="strRetOrederNo">オーダ番号（戻り値）</param>
        ///// <param name="bolRetry">リトライ(true:リトライする/false:リトライしない)</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SendAllPurposeOrderMgr(Fn3ExecuteInfo exeInfo, out string strRetOrederNo, out bool bolRetry)
        
        /// <summary>
        /// 汎用オーダ・データ設定送信マネージャ。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="strRetOrederNo">オーダ番号（戻り値）</param>
        /// <param name="bolRetry">リトライ(true:リトライする/false:リトライしない)</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/その他処置）</param>
        /// <param name="actionCode">送信する行為コード（その他処置のみ使用）</param>
        /// <param name="medicineCode">送信対象の薬剤コード（その他処置のみ使用）</param>
        /// <returns>-1:異常/0:送信なし/1:正常</returns>
        // private int SendAllPurposeOrderMgr
        //     (Fn3ExecuteInfo exeInfo, out string strRetOrederNo, out bool bolRetry, OrderSendMode sendMode, ref string actionCode, string medicineCode, ArrayList oxygenArray)
        //private int SendAllPurposeOrderMgr
        //    (Fn3ExecuteInfo exeInfo, out string strRetOrederNo, out bool bolRetry, OrderSendMode sendMode, ArrayList treatArray, ArrayList oxygenArray)
        private int SendAllPurposeOrderMgr
            (Fn3ExecuteInfo exeInfo, out string strRetOrederNo, out bool bolRetry, OrderSendMode sendMode, TreatActInfo treatInfo, ArrayList oxygenArray, ArrayList ecgArray)
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            strRetOrederNo = string.Empty;

            int iRetVal = 1;

            // -----------------------------------------------
            // 初期化
            // -----------------------------------------------
            CSICommon.ClearAllParameter();
            bolRetry = false;
            // -----------------------------------------------
            // 領域確保
            // -----------------------------------------------
            // オーダ領域
            CSICommon.varORDER = new object[14];
            // オーダヘッダ領域
            CSICommon.varHEADER = new object[28];
            // オーダグループ領域
            CSICommon.varGROUP = new object[13];
            // オーダディテール領域
            CSICommon.varDETAIL = new object[6];
            // アウトパラメータ領域
            CSICommon.varOUTPARAM = new object[7];

            // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
            m_blnOxygenNotDataFlag = false;
            // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            // --------------------------------------------------------------------------------------------------
            // ※注意！！ 汎用オーダの種類によってはイベントが上がってきてもデータが無いことがあるのでデータ有無の判定が必要
            // -------------------------------------------------------------------------------------------------
            // 状態により汎用オーダデータの送信区分を変更する
            // string strChangeSendClass = ChangeSendClassGeneral(exeInfo, sendMode, actionCode, medicineCode, oxygenArray);
            // string strChangeSendClass = ChangeSendClassGeneral(exeInfo, sendMode, treatArray, oxygenArray);
            string strChangeSendClass = ChangeSendClassGeneral(exeInfo, sendMode, treatInfo, oxygenArray, ecgArray);

            if (strChangeSendClass != null)
            {
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                // +++++++++++++++++++++++++++++++++++++++++++++++
                // ▼汎用オーダデータを設定▼
                // +++++++++++++++++++++++++++++++++++++++++++++++
                // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                //bool bolSetData = SetAllPurposeOrder(exeInfo, sendMode);

// 2011/05/24 中村 
#if false
                // その他処置モードのとき
                if (sendMode == OrderSendMode.Treatment)
                {
                    // この時点で行為コード（院内コード）が空文字列のときは、
                    // 「今回データ無し、送信実績あり」が考えられるため
                    // 削除送信のために、保持管理番号情報から院内コードを取得しておく
                    // ★★★要チェック箇所
                    if (actionCode.Equals(string.Empty))
                    {
                        ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, medicineCode, oxygenArray);
                        actionCode = arr[0].ToString();
                    }
                }
#endif

                // bool bolSetData = SetAllPurposeOrder(exeInfo, sendMode, strChangeSendClass, actionCode, medicineCode, oxygenArray);
                // bool bolSetData = SetAllPurposeOrder(exeInfo, sendMode, strChangeSendClass, treatArray, oxygenArray);
                bool bolSetData = SetAllPurposeOrder(exeInfo, sendMode, strChangeSendClass, treatInfo, oxygenArray, ecgArray);
                // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                if (!bolSetData)
                {
                    // エラー（ログは下位で出力）
                    // return false;
                    return -1;
                }

#if !WITHOUT_INTERFACE
                // +++++++++++++++++++++++++++++++++++++++++++++++
                // ▼汎用オーダデータを送信▼
                // +++++++++++++++++++++++++++++++++++++++++++++++
                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pOrder() Start");
                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                bool blnExec = CSICommonMethod.pOrder(m_objCSIORDER,
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
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDER, CSICommonMethod.GetLastErrorString());
                    // -----------------------------------------------
                    // エラーコードを判定
                    // -----------------------------------------------
                    if (CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR1) ||
                        CSICommonMethod.IsErrorCode(CSICommonConst.ERRCODE_RETRYERR2))
                    {
                        // 上記のエラーコードの場合はリトライフラグを立てる
                        bolRetry = true;
                    }
                    // return false;
                    return -1;
                }
                else
                {
                    // -----------------------------------------------
                    // 正常終了でもERRパラメータの中身を確認する
                    // -----------------------------------------------
                    if (CSICommon.pGetERRCollectionCount() > 0)
                    {
                        // ERRパラメータの中身がある場合はログ及びアラームを出力する
                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDER_SUCCESS_ERR, CSICommonMethod.GetLastErrorString());
                        // ※エラーログは出力するが処理続行
                    }

                    // -----------------------------------------------
                    // オーダNo、オーダサブNoを設定する
                    // -----------------------------------------------
                    // 処理区分を確認
                    if (strChangeSendClass == EVENT_TYPE_ADD)
                    {
#if !WITHOUT_INTERFACE
                        // 新規登録の場合はOutParamからオーダNo、オーダサブNoを取得
                        string strMainNo = CSICommon.pGetOUTPARAMData(0).ToString();
                        string strSubNo = CSICommon.pGetOUTPARAMData(1).ToString();
#else
                        string strMainNo = "123456";
                        string strSubNo = "7";
#endif
                        if (strMainNo.Equals(string.Empty) || strSubNo.Equals(string.Empty))
                        {
                            // MIRAIｓ発行オーダNoが不正
                            this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_ORDER, "MIRAIｓ発行オーダNoが不正です");
                            // return false;
                            return -1;
                        }
                        else
                        {
                            // 新規の場合は取得したオーダNo、オーダサブNoを設定
                            strRetOrederNo = strMainNo + "," + strSubNo;
                        }
                    }
                    // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    // 削除のときはオーダ番号を返さない
                    else if (strChangeSendClass == EVENT_TYPE_DEL)
                    {
                        strRetOrederNo = string.Empty;
                    }
                    // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    else
                    {
                        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                        //// 新規以外は既存のオーダNo、オーダサブNoを設定
                        //string[] strBuf = exeInfo.SendHistMemo.Split(',');
                        //strRetOrederNo = strBuf[0] + "," + strBuf[1];

                        if (!sendMode.Equals(OrderSendMode.Treatment))
                        {
                            // 新規以外は既存のオーダNo、オーダサブNoを設定
                            // ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, medicineCode, oxygenArray);
                            ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, oxygenArray, ecgArray);
                            if (arr != null)
                            {
                                string strSendedNo = arr[1].ToString();
                                strRetOrederNo = strSendedNo.Substring(0, 13) + "," + strSendedNo.Substring(13);
                            }
                        }
                        else
                        {
                            //string strSendedNo = treatArray[5].ToString();
                            string strSendedNo = treatInfo.OrderNo.ToString();
                            strRetOrederNo = strSendedNo.Substring(0, 13) + "," + strSendedNo.Substring(13);
                        }
                        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    }
                }
            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            }
            else
            {
                // 汎用オーダデータ無し
                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER_NODATE, CSICommonMethod.GetLastErrorString());

                iRetVal = 0;
            }
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            // 正常終了
            // return true;
            return iRetVal;
        }
        #endregion


        #region 汎用オーダ・オーダ
        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        ///// <summary>
        ///// 汎用オーダ・データを設定する。
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SetAllPurposeOrder(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode)
        
        /// <summary>
        /// 汎用オーダ・データを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/その他処置）</param>
        /// <param name="strChangeSendClass">判定後処理区分</param>
        /// <param name="actionCode">送信する行為コード（その他処置のみ使用）</param>
        /// <param name="medicineCode">送信対象の薬剤コード（その他処置のみ使用）</param>
        /// <returns>true:正常/false:異常</returns>
        // private bool SetAllPurposeOrder
        //     (Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, string actionCode, string medicineCode, ArrayList oxygenArray)
        //private bool SetAllPurposeOrder
        //    (Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, ArrayList treatArray, ArrayList oxygenArray)
        private bool SetAllPurposeOrder
            (Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, TreatActInfo treatInfo, ArrayList oxygenArray, ArrayList ecgArray)
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;

            // オーダ配列領域
            CSICommon.varORDER = new object[14];

            // -----------------------------------------------
            // -- オーダ・処理区分・0 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                    strSetData = CSICommonConst.PROCDIV_INSERT;
                    break;
                case EVENT_TYPE_CHG:   // 修正 
                    strSetData = CSICommonConst.PROCDIV_MODIFY;
                    break;
                case EVENT_TYPE_DEL:   // 削除
                    // ※注意！汎用オーダの削除要求は"中止"で送信する
                    strSetData = CSICommonConst.PROCDIV_MODSTATUS;
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                default:
                    // ありえないが一応確認（ここ以外ではstrChangeSendClassの異常値は確認しない）
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "処理区分:" + strChangeSendClass.ToString());
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
            // -- オーダ・オーダヘッダコレクション・4 --
            // -----------------------------------------------
            // オーダヘッダコレクションを作成する
            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //bool bolRet = SendOrderHeader(exeInfo, sendMode);
            //bool bolRet = SendOrderHeader(exeInfo, sendMode, strChangeSendClass, treatArray, oxygenArray);
            bool bolRet = SendOrderHeader(exeInfo, sendMode, strChangeSendClass, treatInfo, oxygenArray, ecgArray);
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
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
            // 「“0”：進捗マスタを参照しない」を設定（固定値）
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
                    // 「“Ｙ”：実施」を設定（固定値）
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
                    // 「“Ａ”：未会計」を設定（固定値）
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
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                case EVENT_TYPE_DEL:   // 削除
                    // 「“Ｎ”：帳票出力しない」を設定（固定値）
                    strSetData = "N";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetORDERData(9, strSetData);
            // -----------------------------------------------
            // -- オーダ・薬袋I/F・10 --
            // -----------------------------------------------
            // 「“N”：Ｉ／Ｆ出力しない」を設定（固定値）
            strSetData = "N";
            CSICommon.pSetORDERData(10, strSetData);
            // -----------------------------------------------
            // -- オーダ・検査I/F・11 --
            // -----------------------------------------------
            // 「“N”：Ｉ／Ｆ出力しない」を設定（固定値）
            strSetData = "N";
            CSICommon.pSetORDERData(11, strSetData);
            // -----------------------------------------------
            // -- オーダ・医事I/F・12 --
            // -----------------------------------------------
            // 「“Ｙ”：　Ｉ／Ｆ出力する」を設定（固定値）
            strSetData = "Y";
            CSICommon.pSetORDERData(12, strSetData);
            // -----------------------------------------------
            // -- オーダ・RISI/F・13 --
            // -----------------------------------------------
            // 「“N”：Ｉ／Ｆ出力しない」を設定（固定値）
            strSetData = "N";
            CSICommon.pSetORDERData(13, strSetData);

            // ++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダコレクションにオーダ配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(1, CSICommon.varORDER);

            return true;
        }
        #endregion

        #region 汎用オーダ・ヘッダ
        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        ///// <summary>
        ///// 汎用オーダ・ヘッダコレクションを設定する。
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SendOrderHeader(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode)
        
        /// <summary>
        /// 汎用オーダ・ヘッダコレクションを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/心電図/その他処置）</param>
        /// <param name="strChangeSendClass">判定後処理区分</param>
        /// <param name="actionCode">送信する行為コード（その他処置のみ使用）</param>
        /// <param name="medicineCode">送信対象の薬剤コード（その他処置のみ使用）</param>
        /// <returns>true:正常/false:異常</returns>
        // private bool SendOrderHeader
        //     (Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, string actionCode, string medicineCode, ArrayList oxygenArray)
        //private bool SendOrderHeader
        //    (Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, ArrayList treatArray, ArrayList oxygenArray)
        private bool SendOrderHeader
            (Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, TreatActInfo treatInfo, ArrayList oxygenArray, ArrayList ecgArray)
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
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
                    // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    //// SendHistMemoの内容は「汎用オーダ番号,汎用オーダサブ番号,注射オーダ番号,注射オーダサブ番号,患者診療フリー診療番号」となる
                    //string[] strBuf = exeInfo.SendHistMemo.Split(',');
                    //strSetData = strBuf[0];
                    //strSetData = strSetData.PadLeft(13, '0');
                    if (!sendMode.Equals(OrderSendMode.Treatment))
                    {
                        // ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, medicineCode, oxygenArray);
                        ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, oxygenArray, ecgArray);
                        if (arr != null)
                        {
                            strSetData = arr[1].ToString();
                            // 2015/09/03 中村 受入指摘対応(#4949) Chg Start
                            // strSetData = strSetData.Substring(0, 13);
                            if (strSetData.Length < 13)
                            {
                                if (sendMode.Equals(OrderSendMode.Oxygen) && string.IsNullOrEmpty(strSetData))
                                {
                                    // 酸素吸入(新規)を送信していない為、スキップ
                                    m_blnOxygenNotDataFlag = true;
                                    return false;
                                }
                                if (sendMode.Equals(OrderSendMode.Ecg) && string.IsNullOrEmpty(strSetData))
                                {
                                    // 心電図(新規)を送信していない為、スキップ
                                    m_blnEcgNotDataFlag = true;
                                    return false;
                                }
                                strSetData = null;
                            }
                            else
                            {
                                strSetData = strSetData.Substring(0, 13);
                            }
                            // 2015/09/03 中村 受入指摘対応(#4949) Chg End

                        }
                        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    }
                    else
                    {
                        //string[] strBuf = treatArray[5].ToString().Split(',');
                        string[] strBuf = treatInfo.OrderNo.ToString().Split(',');
                        strSetData = strBuf[0];
                    }
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ番号"))
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
                    // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    //// SendHistMemoの内容は「汎用オーダ番号,汎用オーダサブ番号,注射オーダ番号,注射オーダサブ番号,患者診療フリー診療番号」となる
                    //string[] strBuf = exeInfo.SendHistMemo.Split(',');
                    //strSetData = strBuf[1];
                    //strSetData = strSetData.PadLeft(3, '0');
                    if (!sendMode.Equals(OrderSendMode.Treatment))
                    {
                        // ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, medicineCode, oxygenArray);
                        ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, oxygenArray, ecgArray);
                        if (arr != null)
                        {
                            strSetData = arr[1].ToString();
                            strSetData = strSetData.Substring(13);
                        }
                    }
                    else
                    {
                        //string[] strBuf = treatArray[5].ToString().Split(',');
                        string[] strBuf = treatInfo.OrderNo.ToString().Split(',');
                        strSetData = strBuf[1];
                    }
                    // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダサブ番号"))
                    {
                        return false;
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・患者番号"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・患者番号"))
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
                    // 「“41”：汎用」を設定（固定値）
                    strSetData = "41";
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetHEADERData(3, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダ詳細・4 --
            // -----------------------------------------------
            strSetData = null;
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ開始日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ開始日"))
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ開始時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ開始時刻"))
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
                    // >>>>> 2021/12/00 Mod Thach #12564 汎用オーダの終了日・終了時刻には開始日・開始時刻と同じものをセットする
                    //xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/END_DATE");
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // <<<<< 2021/12/00 Mod Thach #12564 汎用オーダの終了日・終了時刻には開始日・開始時刻と同じものをセットする
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ終了日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ終了日"))
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
                    // >>>>> 2021/12/00 Mod Thach #12564 汎用オーダの終了日・終了時刻には開始日・開始時刻と同じものをセットする
                    //xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/END_DATE");
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // <<<<< 2021/12/00 Mod Thach #12564 汎用オーダの終了日・終了時刻には開始日・開始時刻と同じものをセットする
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ終了時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ終了時刻"))
                    {
                        // 必須項目ではないので処理続行
                        strSetData = null;
                    }
                    else
                    {
                        // 日時から時刻のみを設定 ※秒は0秒固定
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・病棟(入外区分)"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・病棟(入外区分)"))
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
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・病棟(病棟コード)"))
                        {
                            return false;
                        }
                        strSetData = xmlNode.InnerText;
                        // 値チェック
                        if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・病棟(病棟コード)"))
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・指示医"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・指示医"))
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
                        if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "患者基本情報・担当医1"))
                        {
                            strSetData = xmlNode.InnerText.Trim();
                        }
                        if (string.IsNullOrEmpty(strSetData))
                        {
                            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD2");
                            if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "患者基本情報・担当医2"))
                            {
                                strSetData = xmlNode.InnerText.Trim();
                            }
                        }

                        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                        // ※デフォルト値をセットして続行しているので、警告が適切
                        //if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "患者基本情報・担当医"))
                        if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "患者基本情報・担当医"))
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ日"))
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ時刻"))
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ入力者"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・オーダ入力者"))
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
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施病棟"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施病棟"))
                    {
                        // 必須ではないので続行
                        strSetData = null;
                        break;
                    }
                    // 透析実績履歴・病棟マスタ・院内コードを設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/MST_WARD/IN_HOSPITAL_CD");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施病棟"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施病棟"))
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
            // -- ヘッダ・実施日・19 --（※必須項目ではない）
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                case EVENT_TYPE_DEL:   // 削除
                    if (sendMode.Equals(OrderSendMode.Oxygen) && !oxygenArray[5].Equals(string.Empty))
                    {
                        strNode = oxygenArray[5].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Ecg) && !ecgArray[3].Equals(string.Empty))
                    {
                        strNode = ecgArray[3].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Treatment) && !treatInfo.EffectDate.Equals(string.Empty))
                    {
                        strNode = treatInfo.EffectDate.ToString();
                    }
                    else
                    {
                        // 透析実績履歴・透析開始日時を設定
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施日"))
                        {
                            return false;
                        }
                        strNode = xmlNode.InnerText;
                    }
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施日"))
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
            // -- ヘッダ・実施時刻・20 -- （※必須項目ではない）
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    if (sendMode.Equals(OrderSendMode.Oxygen) && !oxygenArray[5].Equals(string.Empty))
                    {
                        strNode = oxygenArray[5].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Ecg) && !ecgArray[3].Equals(string.Empty))
                    {
                        strNode = ecgArray[3].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Treatment) && !treatInfo.EffectDate.Equals(string.Empty))
                    {
                        strNode = treatInfo.EffectDate.ToString();
                    }
                    else
                    {
                        // 透析実績履歴・透析開始日時を設定
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施時刻"))
                        {
                            return false;
                        }
                        strNode = xmlNode.InnerText;
                    }

                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施時刻"))
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
            // -- ヘッダ・実施者・21 --（※必須項目ではない）
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績版番管理・版確定者を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施者"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・実施者"))
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
            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・更新者"))
            {
                return false;
            }
            strSetData = xmlNode.InnerText.Trim();
            // 値チェック
            if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダヘッダ・更新者"))
            {
                return false;
            }
            // 2011/01/11 中村 スタッフコード0詰めなし対応
            // // 前0詰め5桁
            // strSetData = strSetData.PadLeft(5, '0');
            CSICommon.pSetHEADERData(26, strSetData);
            // -----------------------------------------------
            // -- ヘッダ・オーダグループコレクション・27 --
            // -----------------------------------------------
            // オーダグループコレクションを作成する
            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //bool bolRet = SetOrderGroup(exeInfo, sendMode);
            //bool bolRet = SetOrderGroup(exeInfo, sendMode, strChangeSendClass, treatArray, oxygenArray);
            bool bolRet = SetOrderGroup(exeInfo, sendMode, strChangeSendClass, treatInfo, oxygenArray, ecgArray);
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            if (bolRet)
            {
                // オーダグループコレクションを設定する
                CSICommon.pSetHEADERData(27, (VBA.Collection)CSICommon.colGROUP);
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


        #region 汎用オーダ・グループ
        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        ///// <summary>
        ///// 汎用オーダ・グループコレクションを設定する。
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SetOrderGroup(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode)

        /// <summary>
        /// 汎用オーダ・グループコレクションを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/その他処置）</param>
        /// <param name="strChangeSendClass">判定後処理区分</param>
        /// <param name="actionCode">送信する行為コード（その他処置のみ使用）</param>
        /// <returns>true:正常/false:異常</returns>
        // private bool SetOrderGroup(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, string actionCode, ArrayList oxygenArray)
        // private bool SetOrderGroup(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, ArrayList treatArray, ArrayList oxygenArray)
        private bool SetOrderGroup(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, TreatActInfo treatInfo, ArrayList oxygenArray, ArrayList ecgArray)
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;
            XmlNode xmlNode = null;
            string strNode = null;

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
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績履歴・病棟コードの有無を確認　※必須項目でないので病院コードの有無を確認し院内コードを取得する
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/WARD_CD");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施病棟(病棟コード)"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施病棟(病棟コード)"))
                    {
                        // 必須ではないので続行
                        strSetData = null;
                        break;
                    }
                    // 透析実績履歴・病棟マスタ・院内コードを設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/MST_WARD/IN_HOSPITAL_CD");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施病棟(院内コード)"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施病棟(院内コード)"))
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
            CSICommon.pSetGROUPData(3, strSetData);
            // -----------------------------------------------
            // -- グループ・実施病室・4 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetGROUPData(4, strSetData);
            // -----------------------------------------------
            // -- グループ・実施日・5 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    if (sendMode.Equals(OrderSendMode.Oxygen) && !oxygenArray[5].Equals(string.Empty))
                    {
                            strNode = oxygenArray[5].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Ecg) && !ecgArray[3].Equals(string.Empty))
                    {
                        strNode = ecgArray[3].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Treatment) && !treatInfo.EffectDate.Equals(string.Empty))
                    {
                        strNode = treatInfo.EffectDate.ToString();
                    }
                    else
                    {
                        // 透析実績履歴・透析開始日時を設定
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施日"))
                        {
                            return false;
                        }
                        strNode = xmlNode.InnerText;
                    }
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施日"))
                    {
                        return false;
                    }
                    strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_DAY);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetGROUPData(5, strSetData);
            // -----------------------------------------------
            // -- グループ・実施時刻・6 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    if (sendMode.Equals(OrderSendMode.Oxygen) && !oxygenArray[5].Equals(string.Empty))
                    {
                            strNode = oxygenArray[5].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Ecg) && !ecgArray[3].Equals(string.Empty))
                    {
                        strNode = ecgArray[3].ToString();
                    }
                    else if (sendMode.Equals(OrderSendMode.Treatment) && !treatInfo.EffectDate.Equals(string.Empty))
                    {
                        strNode = treatInfo.EffectDate.ToString();
                    }
                    else
                    {
                        // 透析実績履歴・透析開始日時を設定
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施時刻"))
                        {
                            return false;
                        }
                        strNode = xmlNode.InnerText;
                    }

                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施時刻"))
                    {
                        return false;
                    }
                    strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_TIME_SS);
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetGROUPData(6, strSetData);
            // -----------------------------------------------
            // -- グループ・実施者・7 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // 透析実績版番管理・版確定者を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施者"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・実施者"))
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
            // -- グループ・行為コード・11 --
            // -----------------------------------------------
            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除
                    // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    // 人工腎臓モードのときのみ
                    if (sendMode == OrderSendMode.Dialisys)
                    {
                        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                        // 透析実績透析条件履歴を取得
                        foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                        {
                            // 透析実績透析条件履歴・透析条件項目コードを比較し治療方法のノードを取得する

                            // 透析条件項目コードを取得
                            xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード(透析条件項目コード)"))
                            {
                                return false;
                            }
                            string strCtlNo = xmlNode.InnerText.Trim();
                            if (strCtlNo == TARGET_TREAT_NO)
                            {
                                // 患者基本情報・入外を取得
                                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/INOUT_FLG");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード(入外区分)"))
                                {
                                    return false;
                                }
                                string strInOut = xmlNode.InnerText;
                                // 透析実績透析条件履歴・治療項目マスタ・院内コードを取得
                                // ※院内コードはカンマ区切りで「外来のコード,入の院コード」となっている
                                xmlNode = xmlNodes.SelectSingleNode("MST_TREAT_ITEM/IN_HOSPITAL_CD");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード(院内コード)"))
                                {
                                    return false;
                                }
                                string treatName = xmlNode.InnerText.Trim();
                                string[] strCode = treatName.Split(',');
                                // 入外を判定
                                if (strInOut == DB_INOUT_FLG_OUT)
                                {
                                    // 外来の場合・院内コードのカンマ区切りの前の値を設定
                                    strSetData = strCode[0];
                                }
                                else if (strInOut == DB_INOUT_FLG_IN)
                                {
                                    // 入院の場合　
                                    if (strCode.Length > 1)
                                    {
                                        // 入院の場合・院内コードのカンマ区切りの後ろの値を設定
                                        strSetData = strCode[1];
                                    }
                                    else
                                    {
                                        // カンマ区切りでない場合は入外共通となるのでstrCode[0]を設定
                                        strSetData = strCode[0];
                                    }
                                }
                                else
                                {
                                    // エラー
                                    this.CheckEmptyVal("", CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード(入外区分)");
                                    return false;
                                }
                            }
                        }
                        // 値チェック
                        if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード"))
                        {
                            return false;
                        }

                    // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    }
                    // 酸素吸入モードのときのみ
                    else if (sendMode == OrderSendMode.Oxygen)
                    {
                        // 設定値から取得済みの酸素吸入用行為コードをセット
                        strSetData = m_strOxygenActionCode;
                    }
                    // 心電図モードのときのみ
                    else if (sendMode == OrderSendMode.Ecg)
                    {
                        // 設定値から取得済みの心電図用行為コードをセット
                        strSetData = m_strEcgActionCode;
                    }
                    // その他の処置モードのときのみ
                    else if (sendMode == OrderSendMode.Treatment)
                    {
                        // 上位から渡された行為コードをそのままセット
                        //strSetData = treatArray[1].ToString();
                        strSetData = treatInfo.TreatmentAct.ToString();
                    }
                    // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                    //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    //// 前0詰め6桁
                    //strSetData = strSetData.PadLeft(6, '0');
                    //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                    break;
                case EVENT_TYPE_XXX:   // (未使用) 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetGROUPData(11, strSetData);


            // -----------------------------------------------
            // -- グループ・オーダディテールコレクション・12 --
            // -----------------------------------------------

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            // その他処置のときは空のディテールをセット
            // if (sendMode == OrderSendMode.Treatment)
            if (sendMode == OrderSendMode.Treatment && m_strTreatmentActionSendType.Equals("0"))
            {
                //SetOrderDetailOfEmpty();
                // オーダディテールコレクションを設定する
                CSICommon.pSetGROUPData(12, (VBA.Collection)CSICommon.colDETAIL);
            }
            else
            {
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                //bool bolRet = SetOrderDetail(exeInfo);
                // bool bolRet = SetOrderDetail(exeInfo, sendMode, strChangeSendClass, oxygenArray);
                bool bolRet = SetOrderDetail(exeInfo, sendMode, strChangeSendClass, oxygenArray, treatInfo, ecgArray);
                // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                if (bolRet)
                {
                    // オーダディテールコレクションを設定する
                    CSICommon.pSetGROUPData(12, (VBA.Collection)CSICommon.colDETAIL);
                }
                else
                {
                    // エラー
                    return false;
                }
            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            }
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダグループコレクションにオーダグループ配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(3, CSICommon.varGROUP);

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }
        #endregion


        #region 汎用オーダ・ディテール
        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        ///// <summary>
        ///// 汎用オーダ・ディテールコレクションを設定する。
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SetOrderDetail(Fn3ExecuteInfo exeInfo)
        
        /// <summary>
        /// 汎用オーダ・ディテールコレクションを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/その他処置）</param>
        /// <param name="strChangeSendClass">判定後処理区分</param>
        /// <returns>true:正常/false:異常</returns>
        // private bool SetOrderDetail(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, ArrayList oxygenArray)
        private bool SetOrderDetail(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string strChangeSendClass, ArrayList oxygenArray, TreatActInfo treatInfo, ArrayList ecgArray)
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            switch (strChangeSendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除

                    #region 酸素吸入複数化に伴い見直し
                    //// >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                    ////// ※仕様変更・酸素吸入時間は送信しない
                    //////// 汎用オーダ・ディテールコレクションを設定（酸素吸入時間）
                    //////bool bolDetailTypeOxygen = SetOrderDetailTypeOxygen(exeInfo);

                    //// 汎用オーダ・ディテールコレクションを設定（酸素吸入時間）
                    //// ※有無を判定するため、モードに関わらず常に実施
                    //// 　モードによる制御は最深部ディテールコレクションにセットするところで行う
                    
                    //// ★★★保留
                    ////  「酸素吸入時間」のセットが、機器側でバグっているので現状は保留
                    ////   また「酸素吸入開始日時」が現状”年月日”までしかセットされないため、
                    ////   その点は仕様の見直しが必要で、それによって以下のメソッド内でも改修が必要になる
                    ////bool bolDetailTypeOxygen = SetOrderDetailTypeOxygen(exeInfo, sendMode);
                    //bool bolDetailTypeOxygen = true;
                    //// ★★★保留
                                        
                    //// <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応


                    //// 汎用オーダ・ディテールコレクションを設定（酸素吸入時間以外）
                    //// >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    ////bool bolDetailTypeExceptForOxygen = SetOrderDetailTypeExceptForOxygen(exeInfo);
                    //bool bolDetailTypeExceptForOxygen = SetOrderDetailTypeExceptForOxygen(exeInfo, sendMode);
                    //// <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                    //// ディテールの作成確認
                    //// >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    //////if (!bolDetailTypeOxygen && !bolDetailTypeExceptForOxygen)
                    ////if (!bolDetailTypeExceptForOxygen)

                    //if (!bolDetailTypeOxygen && !bolDetailTypeExceptForOxygen)
                    //// <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    //{
                    //    // エラー・ディテールが未作成
                    //    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテールの作成が出来ません");
                    //    return false;
                    //}
                    #endregion

                    // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                    // 汎用オーダ・ディテールコレクションを設定
                    //if (!SetOrderDetailAll(exeInfo, sendMode, oxygenArray))
                    if (!SetOrderDetailAll(exeInfo, sendMode, oxygenArray, treatInfo, ecgArray))
                    {
                        // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                        // 酸素吸入モードの場合
                        if (m_blnOxygenNotDataFlag == false)
                        {
                        // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応

                            // エラー・ディテールが未作成
                            this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテールの作成が出来ません");

                        // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                        }
                        // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                        return false;
                    }
                    // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                    break;

                case EVENT_TYPE_XXX:   // (未使用) 
                    // 削除の場合の空のディテールを作成
                    SetOrderDetailOfEmpty();
                    break;
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }


        #region 酸素吸入オーダ複数化に伴い廃止
        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        ///// <summary>
        ///// 汎用オーダ・ディテールコレクションを設定する。
        ///// ※酸素吸入時間の登録時
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SetOrderDetailTypeOxygen(Fn3ExecuteInfo exeInfo)
        
        ///// <summary>
        ///// 汎用オーダ・ディテールコレクションを設定する。
        ///// ※酸素吸入時間の登録時
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/その他処置）</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SetOrderDetailTypeOxygen(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode)
        //// <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        //{
        //    // メソッド開始ログ
        //    this.MethodStartLogOut(MethodBase.GetCurrentMethod());

        //    string strSetData = null;
        //    bool bolCreatDetailDataChk = false;

        //    // 透析実績愁訴処置_処置履歴の取得
        //    foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_TREATMENT_HST"))
        //    {
        //        // 透析実績愁訴処置_処置履歴・処置区分を取得
        //        XmlNode xmlNode = xmlNodes.SelectSingleNode("TREAT_CLASS");
        //        // ノードチェック
        //        if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール(酸素吸入時間) //rootNode/RST_DIALYSIS_TREATMENT_HST"))
        //        {
        //            // ノードが無い場合は処理を抜ける
        //            break;
        //        }
        //        string strTreatClass = xmlNode.InnerText;
        //        // 処置区分が"酸素吸入"か判定する
        //        if (strTreatClass == CODE_DIALYSIS_TREATMEN_OX)
        //        {
        //            // 透析実績愁訴処置_処置履歴・酸素吸入時間を取得
        //            xmlNode = xmlNodes.SelectSingleNode("OXYGEN_TIME");
        //            // ノードチェック
        //            if (this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール(酸素吸入時間)・終了時間　//rootNode/RST_DIALYSIS_COND_HST/OXYGEN_TIME"))
        //            {
        //                string strOxygenTime = xmlNode.InnerText;
        //                // 値チェック ※処理区分が酸素吸入でも時間が設定されていな事があるのでその場合は無視する(時間が設定されていな場合は使用量が設定されている）
        //                if (strOxygenTime != string.Empty)
        //                {
        //                    // -----------------------------------------------
        //                    // -- ディテール・機能コード・0 --
        //                    // -----------------------------------------------
        //                    // 「“06”：時間」を設定（固定値）
        //                    strSetData = "06";
        //                    CSICommon.pSetDETAILData(0, strSetData);
        //                    // -----------------------------------------------
        //                    // -- ディテール・行為詳細項目コード・1 --
        //                    // -----------------------------------------------
        //                    strSetData = null;
        //                    CSICommon.pSetDETAILData(1, strSetData);
        //                    // -----------------------------------------------
        //                    // -- ディテール・使用量・2 --
        //                    // -----------------------------------------------
        //                    strSetData = null;
        //                    CSICommon.pSetDETAILData(2, strSetData);
        //                    // -----------------------------------------------
        //                    // -- ディテール・フリーテキスト・3 --
        //                    // -----------------------------------------------
        //                    strSetData = null;
        //                    CSICommon.pSetDETAILData(3, strSetData);
        //                    // -----------------------------------------------
        //                    // -- ディテール・開始時間・4 --
        //                    // -----------------------------------------------
        //                    // 酸素吸入時刻が取得出来ないので"00:00"を設定
        //                    strSetData = "00:00";
        //                    CSICommon.pSetDETAILData(4, strSetData);
        //                    // -----------------------------------------------
        //                    // -- ディテール・終了時間・5 --
        //                    // -----------------------------------------------
        //                    // 透析実績愁訴処置_処置履歴・酸素吸入時間を設定
        //                    // (単位：分)をHH:MMに変換 C#は0割チェックはなしでOK
        //                    strSetData = (int.Parse(strOxygenTime) / 60).ToString("00") + ":" + (int.Parse(strOxygenTime) % 60).ToString("00");
        //                    CSICommon.pSetDETAILData(5, strSetData);

        //                    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        //                    // ++ オーダディテールコレクションにオーダディテール配列を追加 ++
        //                    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        //                    // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        //                    //CSICommon.pSetCollection(4, CSICommon.varDETAIL);

        //                    // 酸素吸入モードのときのみ、酸素吸入時間をセットする
        //                    if (sendMode == OrderSendMode.Oxygen)
        //                    {
        //                        CSICommon.pSetCollection(4, CSICommon.varDETAIL);
        //                    }
        //                    // それ以外のモードのときは存在フラグのみ立てて抜ける
        //                    else
        //                    {
        //                        m_isOxygenFound = true;
        //                    }
        //                    // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        //                    // ディテール作成フラグを立てる
        //                    bolCreatDetailDataChk = true;
        //                }
        //            }
        //        }
        //    }

        //    // メソッド終了ログ
        //    this.MethodEndLogOut(MethodBase.GetCurrentMethod());

        //    //// ディテールが作成されたか確認する
        //    //if (!bolCreatDetailDataChk)
        //    //{
        //    //    // ディテールが未作成
        //    //    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール(酸素吸入時間)は作成されませんでした");
        //    //}

        //    return bolCreatDetailDataChk;
        //}
        #endregion

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        ///// <summary>
        ///// 汎用オーダ・ディテールコレクションを設定する。
        ///// ※酸素吸入時間以外の登録
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool SetOrderDetailTypeExceptForOxygen(Fn3ExecuteInfo exeInfo)
        
        /// <summary>
        /// 汎用オーダ・ディテールコレクションを設定する。
        /// ※酸素吸入時間以外の登録
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/心電図/その他処置）</param>
        /// <returns>true:正常/false:異常</returns>
        //private bool SetOrderDetailAll(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, ArrayList oxygenArray)
        private bool SetOrderDetailAll(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, ArrayList oxygenArray, TreatActInfo treatInfo, ArrayList ecgArray)
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strCtlNo = string.Empty;
            string strFunctionCode = string.Empty;
            string strInHospitalCode = string.Empty;
            string strAmount = string.Empty;
            string strAmountA = string.Empty;
            string strAmountB = string.Empty;
            string strValChk = string.Empty;
            XmlNode xmlNode = null;

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            string strOccurDate = string.Empty;
            string strResultNo = string.Empty;
            string strOxygenStart = string.Empty;
            string strOxygenTime = string.Empty;
            string strStartTime = string.Empty;
            string strEndTime = string.Empty;
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

            string strEcgType = string.Empty;

            List<OrderDetailData> orderDetailDataMgr = new List<OrderDetailData>();

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            // 人工腎臓モードのときのみ
            if (sendMode == OrderSendMode.Dialisys)
            {
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                // ------------------------------------------------------
                // ダイアライザ
                // ------------------------------------------------------
                #region
                // 透析実績透析条件履歴を取得
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                {
                    // 初期化
                    strInHospitalCode = string.Empty;
                    strAmount = string.Empty;
                    strFunctionCode = string.Empty;
                    // 透析条件項目コードを取得
                    xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・ダイアライザ(透析条件項目コード)"))
                    {
                        // データが無い場合は処理を抜ける
                        break;
                    }
                    strCtlNo = xmlNode.InnerText;
                    // 透析条件項目コードがダイアライザか判定する
                    if (strCtlNo == CODE_DIALYSIS_ITEM_DIALYZER)
                    {
                        // VALUE値を取得
                        xmlNode = xmlNodes.SelectSingleNode("VALUE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・ダイアライザ(VALUE値確認)"))
                        {
                            return false;
                        }
                        strValChk = xmlNode.InnerText;
                        // VALUE値確認
                        if (!this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・ダイアライザ(VALUE値確認)"))
                        {
                            // VALUE値空はデータなしと判断して処理続行 ※複数データを考慮してbreakはしない
                        }
                        else
                        {
                            // -----機能コードを設定-----
                            strFunctionCode = CODE_MEASURES_MATERIAL;
                            // -----院内コードを取得-----
                            xmlNode = xmlNodes.SelectSingleNode("MST_DIALYZER/IN_HOSPITAL_CD");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・ダイアライザ(院内コード)"))
                            {
                                return false;
                            }
                            strInHospitalCode = xmlNode.InnerText.Trim();
                            // 値チェック
                            if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・ダイアライザ(院内コード)"))
                            {
                                // 処理続行
                            }
                            //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                            //else
                            //{
                            //    // 前0詰め6桁
                            //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                            //}
                            //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                            // -----使用量を設定（「"1"」固定値）-----
                            strAmount = "1";
                            // 院内コードの有無を確認
                            if (strInHospitalCode != string.Empty)
                            {
                                // ▼オーダディテールリストに追加▼
                                AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                            }
                        }
                    }
                }
                #endregion

                // ------------------------------------------------------
                // 吸着カラム
                // ------------------------------------------------------
                #region
                // 透析実績透析条件履歴を取得
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                {
                    // 初期化
                    strInHospitalCode = string.Empty;
                    strAmount = string.Empty;
                    strFunctionCode = string.Empty;
                    // 透析条件項目コードを取得
                    xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・吸着カラム(透析条件項目コード)"))
                    {
                        // データが無い場合は処理を抜ける
                        break;
                    }
                    strCtlNo = xmlNode.InnerText;
                    // 透析条件項目コードが吸着カラムか判定する
                    if (strCtlNo == CODE_DIALYSIS_ITEM_KYUTYAKU)
                    {
                        // VALUE値を取得
                        xmlNode = xmlNodes.SelectSingleNode("VALUE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・吸着カラム(VALUE値確認)"))
                        {
                            return false;
                        }
                        strValChk = xmlNode.InnerText;
                        // VALUE値確認
                        if (!this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・吸着カラム(VALUE値確認)"))
                        {
                            // VALUE値空はデータなしと判断して処理続行 ※複数データを考慮してbreakはしない
                        }
                        else
                        {
                            // -----機能コードを設定-----
                            strFunctionCode = CODE_MEASURES_MATERIAL;
                            // -----院内コードを取得-----
                            xmlNode = xmlNodes.SelectSingleNode("MST_EQUIPMENT/IN_HOSPITAL_CD");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・吸着カラム(院内コード)"))
                            {
                                return false;
                            }
                            strInHospitalCode = xmlNode.InnerText.Trim();
                            // 値チェック
                            if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・吸着カラム(院内コード)"))
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
                            // -----使用量を設定（「"1"」固定値）-----
                            strAmount = "1";
                            // 院内コードの有無を確認
                            if (strInHospitalCode != string.Empty)
                            {
                                // ▼オーダディテールリストに追加▼
                                AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                            }
                        }
                    }
                }
                #endregion

                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                // ------------------------------------------------------
                // １次膜
                // ------------------------------------------------------
                #region
                strInHospitalCode = string.Empty;
                strAmount = string.Empty;
                strFunctionCode = string.Empty;

                XmlNode xmlFirstFilmNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_FIRST_FILM));
                if (xmlFirstFilmNode != null)
                {
                    xmlNode = xmlFirstFilmNode.SelectSingleNode("VALUE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・１次膜(VALUE値確認)"))
                    {
                        return false;
                    }
                    strValChk = xmlNode.InnerText;
                    if (this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・１次膜(VALUE値確認)"))
                    {
                        // -----機能コードを設定-----
                        strFunctionCode = CODE_MEASURES_MATERIAL;

                        // -----院内コードを取得-----
                        xmlNode = xmlFirstFilmNode.SelectSingleNode("MST_EQUIPMENT/IN_HOSPITAL_CD");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・１次膜(院内コード)"))
                        {
                            return false;
                        }
                        strInHospitalCode = xmlNode.InnerText.Trim();
                        // 値チェック
                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・１次膜(院内コード)"))
                        {
                            // 処理続行
                        }

                        // -----使用量を設定（「"1"」固定値）-----
                        strAmount = "1";
                        
                        // 院内コードの有無を確認
                        if (strInHospitalCode != string.Empty)
                        {
                            // ▼オーダディテールリストに追加▼
                            AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                        }
                    }
                }

                #endregion

                // ------------------------------------------------------
                // ２次膜
                // ------------------------------------------------------
                #region
                strInHospitalCode = string.Empty;
                strAmount = string.Empty;
                strFunctionCode = string.Empty;

                XmlNode xmlSecondFilmNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_SECOND_FILM));
                if (xmlSecondFilmNode != null)
                {
                    xmlNode = xmlSecondFilmNode.SelectSingleNode("VALUE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・２次膜(VALUE値確認)"))
                    {
                        return false;
                    }
                    strValChk = xmlNode.InnerText;
                    if (this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・２次膜(VALUE値確認)"))
                    {
                        // -----機能コードを設定-----
                        strFunctionCode = CODE_MEASURES_MATERIAL;

                        // -----院内コードを取得-----
                        xmlNode = xmlSecondFilmNode.SelectSingleNode("MST_EQUIPMENT/IN_HOSPITAL_CD");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・２次膜(院内コード)"))
                        {
                            return false;
                        }
                        strInHospitalCode = xmlNode.InnerText.Trim();
                        // 値チェック
                        if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・２次膜(院内コード)"))
                        {
                            // 処理続行
                        }

                        // -----使用量を設定（「"1"」固定値）-----
                        strAmount = "1";

                        // 院内コードの有無を確認
                        if (strInHospitalCode != string.Empty)
                        {
                            // ▼オーダディテールリストに追加▼
                            AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                        }
                    }
                }

                #endregion
                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                // ------------------------------------------------------
                // 抗凝固剤　※注射薬剤は除外
                // ------------------------------------------------------
                #region
                // 透析実績透析条件履歴を取得
#if false
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                {
                    // 透析条件項目コードを取得
                    xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(透析条件項目コード)"))
                    {
                        // データが無い場合は処理を抜ける(※透析実績透析条件履歴は必ず下位ノードが存在するとのことなのでここに来ることはない）
                        break;
                    }
                    strCtlNo = xmlNode.InnerText;
                    switch (strCtlNo)
                    {
                        case CODE_DIALYSIS_ITEM_GYOKO:          // 抗凝固剤       
                            // -----院内コードを取得-----         
                            // VALUE値を取得
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(VALUE値確認)"))
                            {
                                return false;
                            }
                            strValChk = xmlNode.InnerText;
                            // VALUEを値確認
                            if (!this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(VALUE値確認)"))
                            {
                                // VALUE値空は抗凝固剤データなしと判断して処理続行
                                break;
                            }
                            // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                            if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                            {
                                // ＜＜通常薬剤の場合＞＞

                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(注射フラグ)"))
                                {
                                    return false;
                                }
                                string strShot = xmlNode.InnerText;
                                // 薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                                if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                                {
                                    // 院内コードを取得
                                    xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
                                    {
                                        return false;
                                    }
                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                    // 値チェック
                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
                                    {
                                        // 処理続行
                                        break;
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
                                // ＜＜セット薬剤の場合＞＞
                                // ※抗凝固剤のセット薬剤は展開しない
                                // ※抗凝固剤のセット薬剤の注射薬剤には対応しない(抗凝固剤のセット薬剤の注射薬剤は汎用オーダで送る)

                                // セット薬剤名称マスタ・院内コードを取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
                                {
                                    return false;
                                }
                                strInHospitalCode = xmlNode.InnerText.Trim();
                                // 値チェック
                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
                                {
                                    // 処理続行
                                }
                                else
                                {
                                    // 前0詰め6桁
                                    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                }
                            }
                            else
                            {
                                // エラー
                                this.CheckEmptyVal("", CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(VALUE値)・セット薬剤判定");
                                return false;
                            }
                            break;
                        case CODE_DIALYSIS_ITEM_GYOKO_ONE:      // 抗凝固剤ワンショット量
                            // -----使用量を取得-----
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・凝固剤ワンショット量)"))
                            {
                                return false;
                            }
                            strAmountA = xmlNode.InnerText;
                            break;
                        case CODE_DIALYSIS_ITEM_GYOKO_QUANTIY:   // 抗凝固剤持続総量
                            // -----使用量を取得-----
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
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
                    //// 使用量の値チェック
                    //if (!this.CheckEmptyVal(strAmountA, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤ワンショット量)") ||
                    //    !this.CheckEmptyVal(strAmountB, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                    //{
                    //    return false;
                    //}
                    // 使用量の値チェック
                    if (!this.CheckEmptyVal(strAmountA, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・凝固剤ワンショット量)"))
                    {
                        // 値が空の場合は規定値を設定
                        strAmountA = EMPTY_VAL;
                    }
                    if (!this.CheckEmptyVal(strAmountB, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                    {
                        // 値が空の場合は規定値を設定
                        strAmountB = EMPTY_VAL;
                    }
                    // 使用量を設定
                    strAmount = (double.Parse(strAmountA) + double.Parse(strAmountB)).ToString();
                    // 機能コードを設定
                    strFunctionCode = CODE_MEASURES_DRUG;
                    // ▼オーダディテールリストに追加▼
                    AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                }
#else
                strInHospitalCode = string.Empty;
                strAmount = string.Empty;
                strFunctionCode = string.Empty;

                XmlNode xmlGyokoNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_GYOKO));
                if (xmlGyokoNode != null)
                {
                    xmlNode = xmlGyokoNode.SelectSingleNode("VALUE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(VALUE値確認)"))
                    {
                        return false;
                    }
                    strValChk = xmlNode.InnerText;
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
                            // 薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                            if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                            {
                                // -----行為詳細項目コードを設定-----
                                #region 抗凝固剤(院内コード)
                                // 院内コードを取得
                                xmlNode = xmlGyokoNode.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
                                {
                                    return false;
                                }
                                strInHospitalCode = xmlNode.InnerText.Trim();
                                // 値チェック
                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
                                {
                                    // 処理継続
                                }
                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                //else
                                //{
                                //    // 前0詰め6桁
                                //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                //}
                                //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                #endregion

                                // -----機能コードを設定-----
                                strFunctionCode = CODE_MEASURES_DRUG;

                                // -----使用量(ワンショット量 + 持続総量)を設定-----
                                #region 使用量の算出
                                
                                #region 抗凝固剤(ワンショット量)
                                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_GYOKO_ONE));
                                // ノードチェック
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・凝固剤ワンショット量)"))
                                //{
                                //    return false;
                                //}
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                                // if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・凝固剤ワンショット量)") == true)
                                if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤ワンショット量)") == true)
                                // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    strAmountA = xmlNode.InnerText;
                                    // 使用量の値チェック
                                    // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                                    // if (!this.CheckEmptyVal(strAmountA, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・凝固剤ワンショット量)"))
                                    if (!this.CheckEmptyVal(strAmountA, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤ワンショット量)"))
                                    // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                                    {
                                        // 値が空の場合は規定値を設定
                                        strAmountA = EMPTY_VAL;
                                    }
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                else
                                {
                                    // NULLの場合は規定値を設定
                                    strAmountA = EMPTY_VAL;
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                #endregion

                                #region 抗凝固剤(持続総量)
                                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_GYOKO_QUANTIY));
                                // ノードチェック
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                                //{
                                //    return false;
                                //}
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)") == true)
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    strAmountB = xmlNode.InnerText;
                                    if (!this.CheckEmptyVal(strAmountB, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)"))
                                    {
                                        // 値が空の場合は規定値を設定
                                        strAmountB = EMPTY_VAL;
                                    }
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                else
                                {
                                    // NULLの場合は規定値を設定
                                    strAmountB = EMPTY_VAL;
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                #endregion

                                strAmount = (double.Parse(strAmountA) + double.Parse(strAmountB)).ToString();
                                #endregion

                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                // 使用量が0の場合
                                if (double.Parse(strAmount) == 0)
                                {
                                    // ワーニングログ出力
                                    // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                                    // this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・抗凝固剤(使用量・抗凝固剤持続総量)");
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・抗凝固剤(使用量・抗凝固剤総量)");
                                    // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                                    // 送信データを出力対象から除外
                                }
                                else
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                
                                    // 院内コードの有無を確認
                                    if (strInHospitalCode != string.Empty)
                                    {
                                        // ▼オーダディテールリストに追加▼
                                        AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                    }
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            }
                            #endregion
                        }
                        else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                        {
                            #region ＜＜セット薬剤の場合＞＞
                            foreach (XmlNode xmlNodeSets in xmlGyokoNode.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                            {
                                // 初期化
                                strInHospitalCode = string.Empty;
                                strAmount = string.Empty;
                                strFunctionCode = string.Empty;
                                
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(注射フラグ)"))
                                {
                                    // エラー
                                    return false;
                                }
                                string strShot = xmlNode.InnerText;
                                // ●薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                                if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                                {
                                    // -----行為詳細項目コードを設定-----
                                    #region 院内コード
                                    // 院内コードを取得
                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
                                    {
                                        return false;
                                    }
                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                    // 値チェック
                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(院内コード)"))
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

                                    // -----機能コードを設定-----
                                    strFunctionCode = CODE_MEASURES_DRUG;

                                    // -----使用量を設定-----
                                    #region 使用薬剤数
                                    xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                    // ノードチェック
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用薬剤数)"))
                                    //{
                                    //    return false;
                                    //}
                                    if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用薬剤数)") == true)
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・抗凝固剤(使用薬剤数)"))
                                        {
                                            // 値が空の場合は規定値を設定
                                            strAmount = double.Parse(EMPTY_VAL).ToString();
                                        }
                                        else
                                        {
                                            // セット薬剤マスタ.使用薬剤数を設定
                                            strAmount = double.Parse(xmlNode.InnerText).ToString();
                                        }

                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                    else
                                    {
                                        strAmount = double.Parse(EMPTY_VAL).ToString();
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    #endregion

                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    // 使用量が0の場合
                                    if (double.Parse(strAmount) == 0)
                                    {
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・抗凝固剤(VALUE値)・セット薬剤判定");
                                        // 送信データを出力対象から除外
                                    }
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        // 院内コードの有無を確認
                                        if (strInHospitalCode != string.Empty)
                                        {
                                            // ▼オーダディテールリストに追加▼
                                            AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                        }

                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
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
                #endregion

                // ------------------------------------------------------
                // 透析液　※注射薬剤は除外
                // ------------------------------------------------------
                #region
#if false
                strInHospitalCode = string.Empty;
                strAmount = string.Empty;
                strFunctionCode = string.Empty;
                // 透析実績透析条件履歴を取得
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                {
                    // 透析条件項目コードを取得
                    xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(透析条件項目コード)"))
                    {
                        // データが無い場合は処理を抜ける
                        break;
                    }
                    strCtlNo = xmlNode.InnerText;
                    switch (strCtlNo)
                    {
                        case CODE_DIALYSIS_ITEM_HEMODIALYSIS:       // 透析液 
                            // -----院内コードを取得-----              
                            // VALUE値を取得
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(VALUE値確認)"))
                            {
                                return false;
                            }
                            strValChk = xmlNode.InnerText;
                            // VALUE値確認
                            if (!this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(VALUE値確認)"))
                            {
                                // VALUE値空はデータなしと判断して処理続行
                                break;
                            }
                            // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                            if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                            {
                                // ＜＜通常薬剤の場合＞＞

                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(注射フラグ)"))
                                {
                                    return false;
                                }
                                string strShot = xmlNode.InnerText;
                                // 薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                                if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                                {
                                    // 院内コードを取得
                                    xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
                                    {
                                        return false;
                                    }
                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                    // 値チェック
                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
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
                                // ＜＜セット薬剤の場合＞＞
                                // ※透析液のセット薬剤は展開しない
                                // ※透析液のセット薬剤の注射薬剤には対応しない(透析液のセット薬剤の注射薬剤は汎用オーダで送る)

                                xmlNode = xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
                                {
                                    return false;
                                }
                                strInHospitalCode = xmlNode.InnerText.Trim();
                                // 値チェック
                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
                                {
                                    // 処理続行
                                    break;
                                }
                                else
                                {
                                    // 前0詰め6桁
                                    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                }
                            }
                            else
                            {
                                // エラー
                                this.CheckEmptyVal("", CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)・セット薬剤判定");
                                return false;
                            }
                            break;
                        case CODE_DIALYSIS_ITEM_HEMODIALYSIS_QUANTIY:   // 透析液量
                            // -----使用量を取得-----
                            xmlNode = xmlNodes.SelectSingleNode("VALUE");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用量)"))
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
                    // 使用量の値チェック
                    //if (!this.CheckEmptyVal(strAmount, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用量)"))
                    //{
                    //    return false;
                    //}
                    if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用量)"))
                    {
                        // 値が空の場合は規定値を設定
                        strAmount = EMPTY_VAL;
                    }
                    // -----機能コードを設定-----
                    strFunctionCode = CODE_MEASURES_DRUG;
                    // ▼オーダディテールリストに追加▼
                    AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                }
#else
                strInHospitalCode = string.Empty;
                strAmount = string.Empty;
                strFunctionCode = string.Empty;

                XmlNode xmlHemodialysisNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_HEMODIALYSIS));
                if (xmlHemodialysisNode != null)
                {
                    xmlNode = xmlHemodialysisNode.SelectSingleNode("VALUE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(VALUE値確認)"))
                    {
                        return false;
                    }
                    strValChk = xmlNode.InnerText;
                    if (this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(VALUE値確認)"))
                    {
                        // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                        if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                        {
                            #region ＜＜通常薬剤の場合＞＞
                            // 薬剤マスタ・注射フラグを取得
                            xmlNode = xmlHemodialysisNode.SelectSingleNode("MST_MEDICINE/SHOT");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(注射フラグ)"))
                            {
                                return false;
                            }
                            string strShot = xmlNode.InnerText;
                            // 薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                            if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                            {
                                // -----行為詳細項目コードを設定-----
                                #region 透析液(院内コード)
                                // 院内コードを取得
                                xmlNode = xmlHemodialysisNode.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
                                {
                                    return false;
                                }
                                strInHospitalCode = xmlNode.InnerText.Trim();
                                // 値チェック
                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
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

                                // -----機能コードを設定-----
                                strFunctionCode = CODE_MEASURES_DRUG;

                                // -----使用量を設定-----
                                #region 透析液量
                                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_HEMODIALYSIS_QUANTIY));
                                // ノードチェック
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用量)"))
                                //{
                                //    return false;
                                //}
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用量)") == true)
                                {
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    strAmount = xmlNode.InnerText;
                                    if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用量)"))
                                    {
                                        // 値が空の場合は規定値を設定
                                        strAmount = EMPTY_VAL;
                                    }
                                #endregion


                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    // 使用量が0の場合
                                    if (double.Parse(strAmount) == 0)
                                    {
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・透析液(使用量)");
                                        // 送信データを出力対象から除外
                                    }
                                    else
                                    {
                                     // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        // 院内コードの有無を確認
                                        if (strInHospitalCode != string.Empty)
                                        {
                                            // ▼オーダディテールリストに追加▼
                                            AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                        }

                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                }
                                else
                                {
                                    // ワーニングログ出力
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・透析液(使用量)");
                                    // 送信データを出力対象から除外
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            }
                            #endregion
                        }
                        else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                        {
                            #region ＜＜セット薬剤の場合＞＞

                            #region 透析液量
                            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_HEMODIALYSIS_QUANTIY));
                            // ノードチェック
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液量"))
                            //{
                            //    return false;
                            //}
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液量") == true)
                            {
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                double dblSetCnt;
                                if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液量"))
                                {
                                    //// 値が空の場合は規定値を設定
                                    //dblSetCnt = double.Parse(EMPTY_VAL);
                                    // ワーニングログ出力
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・透析液量");
                                    // 送信データを出力対象から除外
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                else
                                {
                                    // 透析液量を設定
                                    dblSetCnt = double.Parse(xmlNode.InnerText);
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //}
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                            #endregion

                                    foreach (XmlNode xmlNodeSets in xmlHemodialysisNode.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                    {
                                        // 初期化
                                        strInHospitalCode = string.Empty;
                                        strAmount = string.Empty;
                                        strFunctionCode = string.Empty;

                                        // 薬剤マスタ・注射フラグを取得
                                        xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                        // ノードチェック
                                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(注射フラグ)"))
                                        {
                                            // エラー
                                            return false;
                                        }
                                        string strShot = xmlNode.InnerText;
                                        // ●薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                                        if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                                        {
                                            // -----行為詳細項目コードを設定-----
                                            #region 院内コード
                                            // 院内コードを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                            // ノードチェック
                                            if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
                                            {
                                                return false;
                                            }
                                            strInHospitalCode = xmlNode.InnerText.Trim();
                                            // 値チェック
                                            if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)"))
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

                                            // -----機能コードを設定-----
                                            strFunctionCode = CODE_MEASURES_DRUG;

                                            // -----使用量を算出し設定（透析液量 × セット薬剤マスタ・薬剤使用量）-----
                                            #region 使用量の算出
                                            // セット薬剤マスタ.使用薬剤数を取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                            // ノードチェック
                                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                            //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用薬剤数)"))
                                            //{
                                            //    return false;
                                            //}
                                            if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用薬剤数)") == true)
                                            {
                                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                double dblValuet;
                                                if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(使用薬剤数)"))
                                                {
                                                    // 値が空の場合は規定値を設定
                                                    dblValuet = double.Parse(EMPTY_VAL);
                                                }
                                                else
                                                {
                                                    // 使用薬剤数を設定
                                                    dblValuet = double.Parse(xmlNode.InnerText);
                                                }

                                                strAmount = (dblValuet * dblSetCnt).ToString();
                                                #endregion

                                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                if (double.Parse(strAmount) == 0)
                                                {
                                                    // ワーニングログ出力
                                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・透析液(使用薬剤数)");
                                                    // 送信データを出力対象から除外
                                                }
                                                else
                                                {
                                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                    // 院内コードの有無を確認
                                                    if (strInHospitalCode != string.Empty)
                                                    {
                                                        // ▼オーダディテールリストに追加▼
                                                        AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                                    }

                                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                }
                                            }
                                            else
                                            {
                                                // ワーニングログ出力
                                                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・透析液(使用薬剤数)");
                                                // 送信データを出力対象から除外
                                            }
                                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        }
                                    }
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                            }
                            else
                            {
                                // ワーニングログ出力
                                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・透析液量");
                                // 送信データを出力対象から除外
                            }
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            #endregion
                        }
                        else
                        {
                            // エラー
                            this.CheckEmptyVal("", CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・透析液(院内コード)・セット薬剤判定");
                            return false;
                        }
                    }
                }
#endif
                #endregion

                // ------------------------------------------------------
                // 補液　※注射薬剤は除外
                // ------------------------------------------------------
                #region
                strInHospitalCode = string.Empty;
                strAmount = string.Empty;
                strFunctionCode = string.Empty;

                // 補液送信フラグチェック
                if (m_blnReplenishSendFlg)
                {
                    XmlNode xmlReplenishNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']", CODE_DIALYSIS_ITEM_REPLENISH));
                    if (xmlReplenishNode != null)
                    {
                        xmlNode = xmlReplenishNode.SelectSingleNode("VALUE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(VALUE値確認)"))
                        {
                            return false;
                        }
                        strValChk = xmlNode.InnerText;
                        if (this.CheckEmptyVal(strValChk, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(VALUE値確認)"))
                        {
                            // 薬剤の種類を判定する（VALUE値の１文字目がセット薬剤フラグとなっている）
                            if (strValChk.Substring(0, 1) == CODE_MEDICINE_NORMAL)
                            {
                                #region ＜＜通常薬剤の場合＞＞
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlReplenishNode.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(注射フラグ)"))
                                {
                                    return false;
                                }
                                string strShot = xmlNode.InnerText;
                                // 薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                                if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                                {
                                    // -----行為詳細項目コードを設定-----
                                    #region 補液(院内コード)
                                    // 院内コードを取得
                                    xmlNode = xmlReplenishNode.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(院内コード)"))
                                    {
                                        return false;
                                    }
                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                    // 値チェック
                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(院内コード)"))
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

                                    // -----機能コードを設定-----
                                    strFunctionCode = CODE_MEASURES_DRUG;

                                    // -----使用量を設定-----
                                    #region 補液使用数
                                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_REPLENISH_QUANTIY));
                                    // ノードチェック
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用数)"))
                                    //{
                                    //    return false;
                                    //}
                                    if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用数)") == true)
                                    {
                                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        strAmount = xmlNode.InnerText;
                                        if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用数)"))
                                        {
                                            // 値が空の場合は規定値を設定
                                            strAmount = EMPTY_VAL;
                                        }
                                    #endregion
                                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                                        if (double.Parse(strAmount) == 0)
                                        {
                                            // ワーニングログ出力
                                            // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                                            // this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・補液(使用数)");
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・補液(使用数)");
                                            // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                                            // 送信データを出力対象から除外 
                                        }
                                        else
                                        {
                                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                                            // 院内コードの有無を確認
                                            if (strInHospitalCode != string.Empty)
                                            {
                                                // ▼オーダディテールリストに追加▼
                                                AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                            }
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        }
                                    }
                                    else
                                    {
                                        // ワーニングログ出力
                                        // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                                        // this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・補液(使用数)");
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダ・オーダディテール・補液(使用数)");
                                        // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                                        // 送信データを出力対象から除外 
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                #endregion
                            }
                            else if (strValChk.Substring(0, 1) == CODE_MEDICINE_SET)
                            {
                                #region ＜＜セット薬剤の場合＞＞

                                #region 補液使用数
                                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode(string.Format("//rootNode/RST_DIALYSIS_COND_HST[CTL_NO='{0}']/VALUE", CODE_DIALYSIS_ITEM_REPLENISH_QUANTIY));
                                // ノードチェック
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用数)"))
                                //{
                                //    return false;
                                //}
                                if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用数)") == true)
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    double dblSetCnt;
                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用数)"))
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        //// 値が空の場合は規定値を設定
                                        //dblSetCnt = double.Parse(EMPTY_VAL);
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・補液(使用数)");
                                        // 送信データを出力対象から除外
                                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                    else
                                    {
                                        // 補液使用数を設定
                                        dblSetCnt = double.Parse(xmlNode.InnerText);
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    //}
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                
                                #endregion

                                        foreach (XmlNode xmlNodeSets in xmlReplenishNode.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            // 初期化
                                            strInHospitalCode = string.Empty;
                                            strAmount = string.Empty;
                                            strFunctionCode = string.Empty;

                                            // 薬剤マスタ・注射フラグを取得
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                            // ノードチェック
                                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(注射フラグ)"))
                                            {
                                                // エラー
                                                return false;
                                            }
                                            string strShot = xmlNode.InnerText;
                                            // ●薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                                            if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                                            {
                                                // -----行為詳細項目コードを設定-----
                                                #region 院内コード
                                                // 院内コードを取得
                                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                                // ノードチェック
                                                if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(院内コード)"))
                                                {
                                                    return false;
                                                }
                                                strInHospitalCode = xmlNode.InnerText.Trim();
                                                // 値チェック
                                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(院内コード)"))
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

                                                // -----機能コードを設定-----
                                                strFunctionCode = CODE_MEASURES_DRUG;

                                                // -----使用量を算出し設定（補液使用数 × セット薬剤マスタ・薬剤使用量）-----
                                                #region 使用量の算出
                                                // セット薬剤マスタ.使用薬剤数を取得
                                                xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                                // ノードチェック
                                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                //if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用薬剤数)"))
                                                //{
                                                //    return false;
                                                //}
                                                if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用薬剤数)") == true)
                                                {
                                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                                                    double dblValuet;
                                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(使用薬剤数)"))
                                                    {
                                                        // 値が空の場合は規定値を設定
                                                        dblValuet = double.Parse(EMPTY_VAL);
                                                    }
                                                    else
                                                    {
                                                        // 使用薬剤数を設定
                                                        dblValuet = double.Parse(xmlNode.InnerText);
                                                    }

                                                    strAmount = (dblValuet * dblSetCnt).ToString();
                                                    #endregion

                                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                    // 使用薬剤数が0の場合
                                                    if (double.Parse(strAmount) == 0)
                                                    {
                                                        // ワーニングログ出力
                                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・補液(使用薬剤数)");
                                                        // 送信データを出力対象から除外
                                                    }
                                                    else
                                                    {
                                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                        // 院内コードの有無を確認
                                                        if (strInHospitalCode != string.Empty)
                                                        {
                                                            // ▼オーダディテールリストに追加▼
                                                            AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                                        }
                                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                    }
                                                }
                                                else
                                                {
                                                    // ワーニングログ出力
                                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・補液(使用薬剤数)");
                                                    // 送信データを出力対象から除外
                                                }
                                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                            }
                                        }
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                }
                                else
                                {
                                    // ワーニングログ出力
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・補液(使用数)");
                                    // 送信データを出力対象から除外
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                #endregion
                            }
                            else
                            {
                                // エラー
                                this.CheckEmptyVal("", CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・補液(院内コード)・セット薬剤判定");
                                return false;
                            }
                        }
                    }
                }
                #endregion

                // ------------------------------------------------------
                // その他薬剤　※注射薬剤は除外　※セット薬剤に対応　
                // ------------------------------------------------------
                // ------------------------------------------------------
                // ■透析実績投薬履歴から"その他薬剤"を取得
                // ------------------------------------------------------
                #region
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_MEDICATION_HST"))
                {
                    // 初期化
                    strInHospitalCode = string.Empty;
                    string strInHospitalCode2 = string.Empty;

                    strAmount = string.Empty;
                    strFunctionCode = string.Empty;
                    // 指示実施フラグを取得
                    xmlNode = xmlNodes.SelectSingleNode("EFFECT_FLG");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(指示実施フラグ)"))
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
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(セット薬剤)"))
                        {
                            // データが無い場合は処理を抜ける
                            break;
                        }
                        // ●セット薬剤か判断する(0：通常、1：セット薬剤)
                        if (xmlNode.InnerText == CODE_MEDICINE_NORMAL)
                        {
                            // ＜＜通常の場合＞＞
                            #region
                            // 薬剤マスタ・注射フラグを取得
                            xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(注射フラグ)"))
                            {
                                // エラー
                                return false;
                            }
                            string strShot = xmlNode.InnerText;
                            // ●薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                            if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                            {
                                // -----院内コードを設定-----
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
                                {
                                    return false;
                                }
                                strInHospitalCode = xmlNode.InnerText.Trim();
                                // 値チェック
                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
                                {
                                    // 処理続行
                                }

                                // -----院内コード2を設定-----
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD2");
                                if (xmlNode != null && !string.IsNullOrEmpty(xmlNode.InnerText.Trim()))
                                {
                                    strInHospitalCode2 = xmlNode.InnerText.Trim();
                                }

                                //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                //else
                                //{
                                //    // 前0詰め6桁
                                //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                                //}
                                //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                                // -----機能コードを設定-----
                                strFunctionCode = CODE_MEASURES_DRUG;
                                // -----使用量を取得-----
                                xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                {
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    //return false;
                                    strAmount = EMPTY_VAL;
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                else
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    strAmount = xmlNode.InnerText;
                                    // 値チェック
                                    //if (!this.CheckEmptyVal(strAmount, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                    //{
                                    //    return false;
                                    //}
                                    if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                    {
                                        // 値が空の場合は規定値を設定
                                        strAmount = EMPTY_VAL;
                                    }
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                // 院内コードの有無を確認

                                // 2016/04/15 中村 その他処置行為送信仕様追加
                                // if (strInHospitalCode != string.Empty)
                                if (strInHospitalCode2 != string.Empty && m_strTreatmentActionSendType.Equals("1"))
                                {
                                    xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/MEDICINE_CD");
                                    string strMstMedCode = xmlNode.InnerText.Trim();
                                    XmlNode CtlNoNode = xmlNodes.SelectSingleNode("CTL_NO");
                                    string CtlNo = string.Empty;
                                    if (CtlNoNode != null)
                                    {
                                        CtlNo = CtlNoNode.InnerText.Trim();
                                    }
                                    XmlNode EffectDateNode = xmlNodes.SelectSingleNode("EFFECT_DATE");
                                    string EffectDate = string.Empty;
                                    if (EffectDateNode != null)
                                    {
                                        EffectDate = EffectDateNode.InnerText.Trim();
                                    }

                                    // その他処置行為リストに追加
                                    TreatActInfo treatAct = new TreatActInfo(m_blnTreatmentActionUnitFlag);
                                    treatAct.MstMedCode = strMstMedCode;
                                    treatAct.TreatmentAct = strInHospitalCode2;
                                    treatAct.ClassType = "M";
                                    treatAct.CtlNo = CtlNo;
                                    treatAct.EffectDate = EffectDate;
                                    if (!string.IsNullOrEmpty(strInHospitalCode))
                                    {
                                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/MEDICINE_GROUP_CD");
                                        string strClassCode = string.Empty;
                                        if (xmlNode != null)
                                        {
                                            strClassCode = xmlNode.InnerText.Trim();
                                        }
                                        if (m_strEquipClassCode.Contains(strClassCode))
                                        {
                                            // 設定に一致する分類がある為、処置材料とする
                                            strFunctionCode = CODE_MEASURES_MATERIAL;
                                        }
                                        treatAct.SetTreatItem(strFunctionCode, strInHospitalCode, strAmount);
                                    }
                                    string strdictKey = EffectDate + "M" + CtlNo;
                                    m_dictSendTreatActList.Add(strdictKey, treatAct);
                                }
                                else if (strInHospitalCode != string.Empty)
                                {
                                    // >>>>>【Ver.5.0.0.104】2011.03.24 中村 処置送信対応
                                    // // ▼オーダディテールリストに追加▼
                                    // AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                    bool actionFlag = false;
                                    // 薬剤コードを取得
                                    xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/MEDICINE_CD");
                                    string strMstMedCode = xmlNode.InnerText.Trim();
                                    // 処置行為薬剤コードかどうか判別
                                    foreach (string actMedCode in m_arrTreatmentActionMedicineCode)
                                    {
                                        if (strMstMedCode.Equals(actMedCode))
                                        {
                                            // 処置行為である
                                            actionFlag = true;

// 2011/05/24 中村 受入試験結果反映
#if false

                                            // 重複チェック
                                            // ※同一院内コードは1回しか送らない
                                            bool blnDuplication = false;
                                            foreach (ArrayList arrAdded in m_hasSendTreatmentActionMedisineCode.Values)
                                            {
                                                if (arrAdded[1].ToString().Equals(strInHospitalCode))
                                                {
                                                    blnDuplication = true;
                                                    break;
                                                }
                                            }

                                            // 重複していないときのみリストに溜める
                                            if (!blnDuplication)
                                            {
                                                // 上位との示し合わせによって以下のようなデータを作成
                                                // { 0:FNW薬剤コード 1:院内コード 2:オーダ番号(この時点では空) }
                                                ArrayList arrTreatment = new ArrayList();
                                                arrTreatment.Add(strMstMedCode);
                                                arrTreatment.Add(strInHospitalCode);
                                                arrTreatment.Add(string.Empty);
                                                // リストに溜める
                                                m_hasSendTreatmentActionMedisineCode.Add(strMstMedCode, arrTreatment);
                                            }
#else
                                            XmlNode InHospitalCdNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                            string InHospitalCd = string.Empty;
                                            if (InHospitalCdNode != null)
                                            {
                                                InHospitalCd = InHospitalCdNode.InnerText.Trim();
                                            }

                                            XmlNode CtlNoNode = xmlNodes.SelectSingleNode("CTL_NO");
                                            string CtlNo = string.Empty;
                                            if (CtlNoNode != null)
                                            {
                                                CtlNo = CtlNoNode.InnerText.Trim();
                                            }

                                            XmlNode EffectDateNode = xmlNodes.SelectSingleNode("EFFECT_DATE");
                                            string EffectDate = string.Empty;
                                            if (EffectDateNode != null)
                                            {
                                                EffectDate = EffectDateNode.InnerText.Trim();
                                            }

                                            // 上位との示し合わせによって以下のようなデータを作成
                                            //// { 0:FNW薬剤コード 1:M 2:項目番号 3:実施時間 }
                                            //ArrayList arrTreatment = new ArrayList();
                                            //arrTreatment.Add(strMstMedCode);    // [0]薬剤コード
                                            //arrTreatment.Add(InHospitalCd);     // [1]院内コード
                                            //arrTreatment.Add("M");              // [2]分類（M)
                                            //arrTreatment.Add(CtlNo);            // [3]項目コード
                                            //arrTreatment.Add(EffectDate);       // [4]実施日時
                                            //// arrTreatment.Add(string.Empty);
                                            //// リストに溜める
                                            //string strdictKey = EffectDate + "M" + CtlNo;
                                            //m_dictSendTreatmentList.Add(strdictKey, arrTreatment);
                                            // その他処置行為リストに追加
                                            TreatActInfo treatAct = new TreatActInfo(m_blnTreatmentActionUnitFlag);
                                            treatAct.MstMedCode = strMstMedCode;
                                            treatAct.TreatmentAct = InHospitalCd;
                                            treatAct.ClassType = "M";
                                            treatAct.CtlNo = CtlNo;
                                            treatAct.EffectDate = EffectDate;
                                            string strdictKey = EffectDate + "M" + CtlNo;
                                            m_dictSendTreatActList.Add(strdictKey, treatAct);
#endif
                                            break;
                                        }
                                    }
                                    // 処置行為でないときのみ、ディテールとしてセット
                                    if (!actionFlag)
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        if (double.Parse(strAmount) == 0)
                                        {
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・その他薬剤(使用量)");
                                            // 送信データを出力対象から除外
                                        }
                                        else
                                        {
                                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                            // ▼オーダディテールリストに追加▼
                                            AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        }
                                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                    // <<<<<【Ver.5.0.0.104】2011.03.24 中村 処置送信対応
                                }
                            }
                            #endregion
                        }
                        else if (xmlNode.InnerText == CODE_MEDICINE_SET)
                        {
                            // ＜＜セット薬剤の場合＞＞
                            #region
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            double dblSetCnt;
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                            // 透析実績投薬履歴・使用量(＝セット数)を取得
                            xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                            {
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //return false;
                                dblSetCnt = double.Parse(EMPTY_VAL);
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            }
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            else
                            {
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                // 値チェック
                                //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                //{
                                //    return false;
                                //}
                                //// セット薬剤の数を設定
                                //double dblSetCnt = double.Parse(xmlNode.InnerText);
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //double dblSetCnt;
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                {
                                    // 値が空の場合は規定値を設定
                                    dblSetCnt = double.Parse(EMPTY_VAL);
                                }
                                else
                                {
                                    // セット薬剤の数を設定
                                    dblSetCnt = double.Parse(xmlNode.InnerText);
                                }
                            }

                            // 2016/04/15 中村 その他処置行為送信仕様追加
                            // 院内コード２を取得
                            strInHospitalCode2 = string.Empty;
                            if (xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD2") != null &&
                                !string.IsNullOrEmpty(xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD2").InnerText.Trim()))
                            {
                                strInHospitalCode2 = xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD2").InnerText.Trim();
                            }

                            TreatActInfo treatAct = null;
                            string strdictKey = string.Empty;
                            if (!string.IsNullOrEmpty(strInHospitalCode2) && m_strTreatmentActionSendType.Equals("1"))
                            {
                                // 薬剤コード
                                string MstMedCode = string.Empty;
                                XmlNode MstMedNode = xmlNodes.SelectSingleNode("SET_MEDICINE_CD");
                                if (MstMedNode != null)
                                {
                                    MstMedCode = MstMedNode.InnerText.Trim();
                                }
                                // 項目コード取得
                                string CtlNo = string.Empty;
                                XmlNode CtlNoNode = xmlNodes.SelectSingleNode("CTL_NO");
                                if (CtlNoNode != null)
                                {
                                    CtlNo = CtlNoNode.InnerText.Trim();
                                }
                                // 実施日
                                XmlNode EffectDateNode = xmlNodes.SelectSingleNode("EFFECT_DATE");
                                string EffectDate = string.Empty;
                                if (EffectDateNode != null)
                                {
                                    EffectDate = EffectDateNode.InnerText.Trim();
                                }

                                treatAct = new TreatActInfo(m_blnTreatmentActionUnitFlag);
                                treatAct.MstMedCode = "S" + MstMedCode;
                                treatAct.TreatmentAct = strInHospitalCode2;
                                treatAct.ClassType = "M";
                                treatAct.CtlNo = CtlNo;
                                treatAct.EffectDate = EffectDate;
                                strdictKey = EffectDate + "M" + CtlNo;
                            }

                            // セット薬剤マスタを取得
                            foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                            {
                                // 初期化
                                strInHospitalCode = string.Empty;
                                strAmount = string.Empty;
                                strFunctionCode = string.Empty;
                                // 薬剤マスタ・注射フラグを取得
                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(注射フラグ)"))
                                {
                                    // エラー
                                    return false;
                                }
                                string strShot = xmlNode.InnerText;
                                // ●薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                                if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                                {
                                    // -----院内コードを設定-----
                                    xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
                                    {
                                        return false;
                                    }
                                    strInHospitalCode = xmlNode.InnerText.Trim();
                                    // 値チェック
                                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
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
                                    // -----機能コードを設定-----
                                    strFunctionCode = CODE_MEASURES_DRUG;
                                    // >>>>>【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                    //// -----使用量を取得-----
                                    //// セット薬剤マスタ・薬剤使用量を取得
                                    //xmlNode = xmlNodeSets.SelectSingleNode("VALUE");
                                    //// ノードチェック
                                    //if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                    //{
                                    //    return false;
                                    //}

                                    // -----使用薬剤数を取得-----
                                    // セット薬剤マスタ・使用薬剤数を取得
                                    xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                    // ノードチェック
                                    if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用薬剤数)"))
                                    {
                                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        //return false;
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・その他薬剤(使用薬剤数)");
                                        // 送信データを出力対象から除外
                                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        // <<<<<【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                        // 値チェック
                                        //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                        //{
                                        //    return false;
                                        //}
                                        //// 使用量(セット薬剤)を設定
                                        //double dblValuet = double.Parse(xmlNode.InnerText);
                                        double dblValuet;
                                        if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                        {
                                            // 値が空の場合は規定値を設定
                                            dblValuet = double.Parse(EMPTY_VAL);
                                        }
                                        else
                                        {
                                            // 使用量(セット薬剤)を設定
                                            dblValuet = double.Parse(xmlNode.InnerText);
                                        }
                                        // -----使用量を算出し設定（透析実績投薬履歴・使用量 × セット薬剤マスタ・薬剤使用量）-----
                                        strAmount = (dblValuet * dblSetCnt).ToString();

                                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        if (double.Parse(strAmount) == 0)
                                        {
                                            // ワーニングログ出力
                                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・その他薬剤(使用量)");
                                            // 送信データを出力対象から除外
                                        }
                                        else
                                        {
                                            // 2016/04/15 中村 その他処置行為送信仕様追加
                                            if (treatAct != null)
                                            {
                                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/MEDICINE_GROUP_CD");
                                                string strClassCode = string.Empty;
                                                if (xmlNode != null)
                                                {
                                                    strClassCode = xmlNode.InnerText.Trim();
                                                }
                                                if (m_strEquipClassCode.Contains(strClassCode))
                                                {
                                                    // 設定に一致する分類がある為、処置材料とする
                                                    strFunctionCode = CODE_MEASURES_MATERIAL;
                                                }
                                                treatAct.SetTreatItem(strFunctionCode, strInHospitalCode, strAmount);
                                            }
                                            else
                                            {
                                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                                // 院内コードの有無を確認
                                                if (strInHospitalCode != string.Empty)
                                                {
                                                    // ▼オーダディテールリストに追加▼
                                                    AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                                }
                                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                            }
                                        }
                                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                }
                            }

                            // 2016/04/15 中村 その他処置行為送信仕様追加
                            if (treatAct != null && !string.IsNullOrEmpty(strdictKey))
                            {
                                m_dictSendTreatActList.Add(strdictKey, treatAct);
                            }

                            #endregion
                        }
                    }
                }
                #endregion
                // ------------------------------------------------------
                // ■透析実績愁訴処置_処置履歴から"その他薬剤"を取得 ■
                // ------------------------------------------------------
                #region
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_TREATMENT_HST"))
                {
                    // 初期化
                    strInHospitalCode = string.Empty;
                    string strInHospitalCode2 = string.Empty;
                    strAmount = string.Empty;
                    strFunctionCode = string.Empty;
                    // 透析実績投薬履歴・処置区分を取得
                    xmlNode = xmlNodes.SelectSingleNode("TREAT_CLASS");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(処置区分)"))
                    {
                        // ノードが無い場合は処理を抜ける
                        break;
                    }
                    strCtlNo = xmlNode.InnerText;
                    // ●透析実績愁訴処置_処置履歴・処置区分を判定する
                    if (strCtlNo == CODE_DIALYSIS_TREATMEN_DRUG)
                    {
                        // ＜＜通常薬剤・処置区分が「"1"：薬剤」＞＞
                        #region
                        // 薬剤マスタ・注射フラグを取得
                        xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/SHOT");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(注射フラグ)"))
                        {
                            return false;
                        }
                        string strShot = xmlNode.InnerText;
                        // ●薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                        if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                        {
                            // -----機能コードを設定-----
                            strFunctionCode = CODE_MEASURES_DRUG;
                            // -----院内コードを取得-----
                            xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
                            {
                                return false;
                            }
                            strInHospitalCode = xmlNode.InnerText.Trim();
                            // 値チェック
                            if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
                            {
                                // 処理続行
                            }

                            xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD2");
                            if (xmlNode != null && !string.IsNullOrEmpty(xmlNode.InnerText.Trim()))
                            {
                                strInHospitalCode2 = xmlNode.InnerText.Trim();
                            }

                            //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                            //else
                            //{
                            //    // 前0詰め6桁
                            //    strInHospitalCode = strInHospitalCode.PadLeft(6, '0');
                            //}
                            //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
                            // -----使用量を取得-----
                            xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                            {
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                //return false;
                                strAmount = EMPTY_VAL;
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            }
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            else
                            {
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                strAmount = xmlNode.InnerText;
                                // 値チェック
                                //if (!this.CheckEmptyVal(strAmount, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                //{
                                //    return false;
                                //}
                                if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                {
                                    // 値が空の場合は規定値を設定
                                    strAmount = EMPTY_VAL;
                                }
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            }
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            // 院内コードの有無を確認

                            // 2016/04/15 中村 その他処置行為送信仕様追加
                            // if (strInHospitalCode != string.Empty)
                            if (strInHospitalCode2 != string.Empty && m_strTreatmentActionSendType.Equals("1"))
                            {
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/MEDICINE_CD");
                                string strMstMedCode = xmlNode.InnerText.Trim();
                                XmlNode ResultNoNode = xmlNodes.SelectSingleNode("RESULT_NO");
                                string ResultNo = string.Empty;
                                if (ResultNoNode != null)
                                {
                                    ResultNo = ResultNoNode.InnerText.Trim();
                                }
                                XmlNode OccurDateNode = xmlNodes.SelectSingleNode("OCCUR_DATE");
                                string OccurDate = string.Empty;
                                if (OccurDateNode != null)
                                {
                                    OccurDate = OccurDateNode.InnerText.Trim();
                                }

                                // その他処置行為リストに追加
                                TreatActInfo treatAct = new TreatActInfo(m_blnTreatmentActionUnitFlag);
                                treatAct.MstMedCode = strMstMedCode;
                                treatAct.TreatmentAct = strInHospitalCode2;
                                treatAct.ClassType = "T";
                                treatAct.CtlNo = ResultNo;
                                treatAct.EffectDate = OccurDate;
                                if (!string.IsNullOrEmpty(strInHospitalCode))
                                {
                                    xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/MEDICINE_GROUP_CD");
                                    string strClassCode = string.Empty;
                                    if (xmlNode != null)
                                    {
                                        strClassCode = xmlNode.InnerText.Trim();
                                    }
                                    if (m_strEquipClassCode.Contains(strClassCode))
                                    {
                                        // 設定に一致する分類がある為、処置材料とする
                                        strFunctionCode = CODE_MEASURES_MATERIAL;
                                    }
                                    treatAct.SetTreatItem(strFunctionCode, strInHospitalCode, strAmount);
                                }
                                string strdictKey = OccurDate + "T" + ResultNo;
                                m_dictSendTreatActList.Add(strdictKey, treatAct);
                            }
                            else if (strInHospitalCode != string.Empty)
                            {
                                // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                                //// ▼オーダディテールリストに追加▼
                                //AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount);

                                bool actionFlag = false;
                                // 薬剤コードを取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_MEDICINE/MEDICINE_CD");
                                string strMstMedCode = xmlNode.InnerText.Trim();
                                // 処置行為薬剤コードかどうか判別
                                foreach (string actMedCode in m_arrTreatmentActionMedicineCode)
                                {
                                    if (strMstMedCode.Equals(actMedCode))
                                    {
                                        // 処置行為である
                                        actionFlag = true;

// 2011/05/24 中村 受入試験結果反映
#if false
                                        // 重複チェック
                                        // ※同一院内コードは1回しか送らない
                                        bool blnDuplication = false;
                                        foreach (ArrayList arrAdded in m_hasSendTreatmentActionMedisineCode.Values)
                                        {
                                            if (arrAdded[1].ToString().Equals(strInHospitalCode))
                                            {
                                                blnDuplication = true;
                                                break;
                                            }
                                        }

                                        // 重複していないときのみリストに溜める
                                        if (!blnDuplication)
                                        {
                                            // 上位との示し合わせによって以下のようなデータを作成
                                            // { 0:FNW薬剤コード 1:院内コード 2:オーダ番号(この時点では空) }
                                            ArrayList arrTreatment = new ArrayList();
                                            arrTreatment.Add(strMstMedCode);
                                            arrTreatment.Add(strInHospitalCode);
                                            arrTreatment.Add(string.Empty);
                                            // リストに溜める
                                            m_hasSendTreatmentActionMedisineCode.Add(strMstMedCode, arrTreatment);
                                        }
#else
                                        XmlNode InHospitalCdNode = xmlNodes.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                        string InHospitalCd = string.Empty;
                                        if (InHospitalCdNode != null)
                                        {
                                            InHospitalCd = InHospitalCdNode.InnerText.Trim();
                                        }

                                        XmlNode ResultNoNode = xmlNodes.SelectSingleNode("RESULT_NO");
                                        string ResulNo = string.Empty;
                                        if (ResultNoNode != null)
                                        {
                                            ResulNo = ResultNoNode.InnerText.Trim();
                                        }

                                        XmlNode OccurDateNode = xmlNodes.SelectSingleNode("OCCUR_DATE");
                                        string OccurDate = string.Empty;
                                        if (OccurDateNode != null)
                                        {
                                            OccurDate = OccurDateNode.InnerText.Trim();
                                        }

                                        // 上位との示し合わせによって以下のようなデータを作成
                                        //ArrayList arrTreatment = new ArrayList();
                                        //arrTreatment.Add(strMstMedCode);    // [0]薬剤コード
                                        //arrTreatment.Add(InHospitalCd);     // [1]院内コード
                                        //arrTreatment.Add("T");              // [2]分類（T)
                                        //arrTreatment.Add(ResulNo);          // [3]項目コード
                                        //arrTreatment.Add(OccurDate);        // [4]実施日時
                                        //// arrTreatment.Add(string.Empty);
                                        //// リストに溜める
                                        //string strdictKey = OccurDate + "T" + ResulNo;
                                        //m_dictSendTreatmentList.Add(strdictKey, arrTreatment);

                                        TreatActInfo treatAct = new TreatActInfo(m_blnTreatmentActionUnitFlag);
                                        treatAct.MstMedCode = strMstMedCode;
                                        treatAct.TreatmentAct = InHospitalCd;
                                        treatAct.ClassType = "T";
                                        treatAct.CtlNo = ResulNo;
                                        treatAct.EffectDate = OccurDate;
                                        string strdictKey = OccurDate + "T" + ResulNo;
                                        m_dictSendTreatActList.Add(strdictKey, treatAct);
#endif
                                        break;
                                    }
                                }
                                // 処置行為でないときのみ、ディテールとしてセット
                                if (!actionFlag)
                                {
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    if (double.Parse(strAmount) == 0)
                                    {
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・その他薬剤(使用量)");
                                        // 送信データを出力対象から除外 
                                    }
                                    else
                                    {
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        // ▼オーダディテールリストに追加▼
                                        AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    }
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                            }
                        }
                        #endregion
                    }
                    else if (strCtlNo == CODE_DIALYSIS_TREATMEN_TREATDRUG)
                    {
                        // ＜＜セット薬剤・処置区分が「"0"：処置薬剤」＞＞
                        #region
                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                        double dblSetCnt;
                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                        // 透析実績愁訴処置_処置履歴・使用量(＝セット数)を取得
                        xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                        {
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            //return false;
                            dblSetCnt = double.Parse(EMPTY_VAL);
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                        }
                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                        else
                        {
                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            // 値チェック
                            //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                            //{
                            //    return false;
                            //}
                            //// セット薬剤の数を設定
                            //double dblSetCnt = double.Parse(xmlNode.InnerText);
                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            //double dblSetCnt;
                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                            {
                                // セット薬剤の数を設定
                                dblSetCnt = double.Parse(EMPTY_VAL);
                            }
                            else
                            {
                                // セット薬剤の数を設定
                                dblSetCnt = double.Parse(xmlNode.InnerText);
                            }
                        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                        }
                        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応


                        // 2016/04/15 中村 その他処置行為送信仕様追加 Add Start
                        // 院内コード２を取得
                        strInHospitalCode2 = string.Empty;
                        if (xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD2") != null &&
                            !string.IsNullOrEmpty(xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD2").InnerText.Trim()))
                        {
                            strInHospitalCode2 = xmlNodes.SelectSingleNode("MST_SET_MEDI_NAME/IN_HOSPITAL_CD2").InnerText.Trim();
                        }

                        TreatActInfo treatAct = null;
                        string strdictKey = string.Empty;
                        if (!string.IsNullOrEmpty(strInHospitalCode2) && m_strTreatmentActionSendType.Equals("1"))
                        {
                            // 薬剤コード
                            string MstMedCode = string.Empty;
                            XmlNode MstMedNode = xmlNodes.SelectSingleNode("TREAT_MEDICINE_CD");
                            if (MstMedNode != null)
                            {
                                MstMedCode = MstMedNode.InnerText.Trim();
                            }
                            // 項目コード取得
                            string ResultNo = string.Empty;
                            XmlNode ResultNoNode = xmlNodes.SelectSingleNode("RESULT_NO");
                            if (ResultNoNode != null)
                            {
                                ResultNo = ResultNoNode.InnerText.Trim();
                            }
                            // 実施日
                            XmlNode OccurDateNode = xmlNodes.SelectSingleNode("OCCUR_DATE");
                            string OccurDate = string.Empty;
                            if (OccurDateNode != null)
                            {
                                OccurDate = OccurDateNode.InnerText.Trim();
                            }

                            treatAct = new TreatActInfo(m_blnTreatmentActionUnitFlag);
                            treatAct.MstMedCode = "S" + MstMedCode;
                            treatAct.TreatmentAct = strInHospitalCode2;
                            treatAct.ClassType = "T";
                            treatAct.CtlNo = ResultNo;
                            treatAct.EffectDate = OccurDate;
                            strdictKey = OccurDate + "T" + ResultNo;
                        }
                        // 2016/04/15 中村 その他処置行為送信仕様追加 Add End

                        // セット薬剤マスタを取得
                        foreach (XmlNode xmlNodeSets in xmlNodes.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                        {
                            // 初期化
                            strInHospitalCode = string.Empty;
                            strAmount = string.Empty;
                            strFunctionCode = string.Empty;
                            // 薬剤マスタ・注射フラグを取得
                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/SHOT");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(注射フラグ)"))
                            {
                                // エラー
                                return false;
                            }
                            string strShot = xmlNode.InnerText;
                            // ●薬剤マスタ・注射フラグが「"0"：注射以外」か判定する　※Emptyも注射外と判断する
                            if (strShot == CODE_MEDICINE_SHOT_OFF || strShot == string.Empty)
                            {
                                // -----院内コードを設定-----
                                xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/IN_HOSPITAL_CD");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
                                {
                                    return false;
                                }
                                strInHospitalCode = xmlNode.InnerText.Trim();
                                // 値チェック
                                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(院内コード)"))
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
                                // -----機能コードを設定-----
                                strFunctionCode = CODE_MEASURES_DRUG;
                                // >>>>>【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                //// -----使用量を取得-----
                                //// セット薬剤マスタ・薬剤使用量を取得
                                //xmlNode = xmlNodeSets.SelectSingleNode("VALUE");
                                //// ノードチェック
                                //if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                //{
                                //    return false;
                                //}

                                // -----使用薬剤数を取得-----
                                // セット薬剤マスタ・使用薬剤数を取得
                                xmlNode = xmlNodeSets.SelectSingleNode("MEDI_USE_NUM");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNodeSets, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用薬剤数)"))
                                {
                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    //return false;
                                    // ワーニングログ出力
                                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・その他薬剤(使用薬剤数)");
                                    // 送信データを出力対象から除外 
                                    // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                }
                                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                else
                                {
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    // <<<<<【Ver.5.0.0.101】2010.07.08（R.Tobita）セット薬剤の数量に利用する値を、薬剤使用量から使用薬剤数へ修正
                                    // 値チェック
                                    //if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                    //{
                                    //    return false;
                                    //}
                                    //// 使用量(セット薬剤)を設定
                                    //double dblValuet = double.Parse(xmlNode.InnerText);
                                    double dblValuet;
                                    if (!this.CheckEmptyVal(xmlNode.InnerText, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・その他薬剤(使用量)"))
                                    {
                                        // 値が空の場合は規定値を設定
                                        dblValuet = double.Parse(EMPTY_VAL);
                                    }
                                    else
                                    {
                                        // 使用量(セット薬剤)を設定
                                        dblValuet = double.Parse(xmlNode.InnerText);
                                    }
                                    // -----使用量を算出し設定（透析実績愁訴処置_処置履歴・数量 × セット薬剤マスタ・薬剤使用量）-----
                                    strAmount = (dblValuet * dblSetCnt).ToString();

                                    // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                    if (double.Parse(strAmount) == 0)
                                    {
                                        // ワーニングログ出力
                                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・その他薬剤(使用薬剤数)");
                                        // 送信データを出力対象から除外 
                                    }
                                    else
                                    {
                                        // 2016/04/15 中村 その他処置行為送信仕様追加
                                        if (treatAct != null)
                                        {
                                            xmlNode = xmlNodeSets.SelectSingleNode("MST_MEDICINE/MEDICINE_GROUP_CD");
                                            string strClassCode = string.Empty;
                                            if (xmlNode != null)
                                            {
                                                strClassCode = xmlNode.InnerText.Trim();
                                            }
                                            if (m_strEquipClassCode.Contains(strClassCode))
                                            {
                                                // 設定に一致する分類がある為、処置材料とする
                                                strFunctionCode = CODE_MEASURES_MATERIAL;
                                            }
                                            treatAct.SetTreatItem(strFunctionCode, strInHospitalCode, strAmount);
                                        }
                                        else
                                        {
                                            // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                            // 院内コードの有無を確認
                                            if (strInHospitalCode != string.Empty)
                                            {
                                                // ▼オーダディテールリストに追加▼
                                                AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                                            }
                                            // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                                        }
                                    }
                                }
                                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                            }
                        }

                        // 2016/04/15 中村 その他処置行為送信仕様追加
                        if (treatAct != null && !string.IsNullOrEmpty(strdictKey))
                        {
                            m_dictSendTreatActList.Add(strdictKey, treatAct);
                        }

                        #endregion
                    }

                }
                #endregion

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            }
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

            // ------------------------------------------------------
            // 酸素吸入（量、時間）
            // ------------------------------------------------------
            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            #region

            // 酸素吸入モードのときのみ送信処理
            if (sendMode == OrderSendMode.Oxygen)
            {
                ////////////////////
                // 酸素吸入量
                ////////////////////

                // -----機能コードを設定-----
                strFunctionCode = CODE_MEASURES_MATERIAL;
           
                // -----院内コードを設定-----
                strInHospitalCode = m_strOxygenInhalationCode;
                strInHospitalCode = strInHospitalCode.Trim();

                // 値チェック(設定値だが一応チェック)
                if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(院内コード)"))
                {
                    // 処理続行
                }

                // -----使用量を取得-----
                strAmount = oxygenArray[4].ToString();

                // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
                if (double.Parse(strAmount) == 0)
                {
                    // ワーニングログ出力
                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・酸素吸入量(使用量)");
                    // 送信データを出力対象から除外 
                }
                else
                {
                // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

                    // ▼オーダディテールリストに追加▼
                    AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");

                    ////////////////////
                    // 酸素吸入時間
                    ////////////////////

                    // -----機能コードを設定-----
                    strFunctionCode = CODE_MEASURES_TIME;

                    // -----院内コードを設定-----
                    strInHospitalCode = m_strOxygenInhalationCode;
                    strInHospitalCode = strInHospitalCode.Trim();

                    // -----開始時間-----
                    strStartTime = oxygenArray[5].ToString().Substring(11, 5);

                    // -----終了時間-----
                    strEndTime = oxygenArray[1].ToString().Substring(11, 5);

                    // ▼オーダディテールリストに追加▼
                    AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, EMPTY_VAL, strStartTime, strEndTime);
                // >>>>>【Ver.5.0.3.100】2015.07.31 石川 特殊浄化対応
                }
                // <<<<<【Ver.5.0.3.100】2015.07.31 石川 特殊浄化対応
            }
            else if (sendMode == OrderSendMode.Ecg) // 心電図モードのときのみ送信処理
            {
                ////////////////////
                // 心電図 時間
                ////////////////////

                // -----機能コードを設定-----
                strFunctionCode = CODE_MEASURES_TIME;

                // -----院内コードを設定-----
                strInHospitalCode = string.Empty;

                // -----開始時間-----
                strStartTime = ecgArray[3].ToString().Substring(11, 5);

                // -----終了時間-----
                strEndTime = ecgArray[1].ToString().Substring(11, 5);

                // ▼オーダディテールリストに追加▼
                AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, EMPTY_VAL, strStartTime, strEndTime);
                
            }
            // それ以外のときは、酸素吸入情報の有無判定とリスト蓄積のみ行う
            else
            {
                // 透析実績愁訴処置_処置履歴からその他薬剤を取得 
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_TREATMENT_HST"))
                {
                    // 初期化
                    strInHospitalCode = string.Empty;
                    strAmount = string.Empty;
                    strFunctionCode = string.Empty;
                    // 透析実績投薬履歴・処置区分を取得
                    xmlNode = xmlNodes.SelectSingleNode("TREAT_CLASS");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(処置区分)"))
                    {
                        // データが無い場合は処理を抜ける
                        break;
                    }
                    strCtlNo = xmlNode.InnerText;
                    // 透析実績投薬履歴・処置区分が「"3"：酸素吸入」か判定する
                    if (strCtlNo == CODE_DIALYSIS_TREATMEN_OX)
                    {
                        //// -----機能コードを設定-----
                        //strFunctionCode = CODE_MEASURES_MATERIAL;
                        //// -----院内コードを設定-----
                        //strInHospitalCode = m_strOxygenInhalationCode;
                        //strInHospitalCode = strInHospitalCode.Trim();
                        //// 値チェック(設定値だが一応チェック)
                        //if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(院内コード)"))
                        //{
                        //    // 処理続行
                        //}
                        
                        // -----使用量を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("OXYGEN_AMOUNT");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(使用量)"))
                        {
                            // >>>>>【Ver.5.0.3.100】2015.07.31 石川 特殊浄化対応
                            //return false;
                            // ワーニングログ出力
                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダディテール・酸素吸入量(使用量)");
                            // 送信データを出力対象から除外 
                            continue;
                            // <<<<<【Ver.5.0.3.100】2015.07.31 石川 特殊浄化対応
                        }
                        strAmount = xmlNode.InnerText;

                        // -----発生日時を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("OCCUR_DATE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(発生日時)"))
                        {
                            return false;
                        }
                        strOccurDate = xmlNode.InnerText;

                        // -----実績番号を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("RESULT_NO");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(実績番号)"))
                        {
                            return false;
                        }
                        strResultNo = xmlNode.InnerText;
                        // 3桁前ゼロ詰めに成形（4桁目より上は切り捨て。有り得ないものとして想定から外す）
                        strResultNo = String.Format("{0:D3}", int.Parse(strResultNo));
                        if (strResultNo.Length > 3)
                        {
                            strResultNo = strResultNo.Substring(strResultNo.Length - 3);
                        }

                        // -----酸素吸入開始日時を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("OXYGEN_START");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(酸素吸入開始日時)"))
                        {
                            return false;
                        }
                        strOxygenStart = xmlNode.InnerText;

                        // -----酸素吸入時間を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("OXYGEN_TIME");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(酸素吸入時間)"))
                        {
                            return false;
                        }
                        strOxygenTime = xmlNode.InnerText;

                        if (m_dictSendOxygenList.ContainsKey(strOccurDate + strResultNo))
                        {
                            continue;
                        }

                        // 酸素吸入情報リストに蓄積
                        ArrayList arrItem = new ArrayList();
                        // ※  [0]RESULT_NO
                        arrItem.Add(strResultNo);
                        // ※  [1]OCCUR_DATE
                        arrItem.Add(strOccurDate);
                        // ※  [2]OXYGEN_START
                        arrItem.Add(strOxygenStart);
                        // ※  [3]OXYGEN_TIME
                        arrItem.Add(strOxygenTime);
                        // ※  [4]OXYGEN_AMOUNT
                        arrItem.Add(strAmount);
                        // ※  [5]開始レコードのOCCUR_DATE
                        // この時点では未設定
                        // ※  [6]汎用オーダ番号 
                        // この時点では未設定

                        // 発生日時をキーにしてハッシュに追加（後でキーでソートするため）
                        m_dictSendOxygenList.Add(strOccurDate + strResultNo, arrItem);

                        //// 酸素吸入情報有無判定
                        //if (this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(使用量)"))
                        //{
                        //    // 値がある場合は終了レコード
                        //    // 有無フラグを立てる
                        //    // ※開始のみで透析が終わっている場合がありえるので、終了レコード登場時のみフラグ立て
                        //    m_isOxygenFound = true;
                        //}
                    }

                    if (strCtlNo == CODE_DIALYSIS_TREATMEN_ECG)
                    {
                        // -----発生日時を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("OCCUR_DATE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・心電図(発生日時)"))
                        {
                            return false;
                        }
                        strOccurDate = xmlNode.InnerText;

                        // -----実績番号を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("RESULT_NO");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・心電図(実績番号)"))
                        {
                            return false;
                        }
                        strResultNo = xmlNode.InnerText;
                        // 3桁前ゼロ詰めに成形（4桁目より上は切り捨て。有り得ないものとして想定から外す）
                        strResultNo = String.Format("{0:D3}", int.Parse(strResultNo));
                        if (strResultNo.Length > 3)
                        {
                            strResultNo = strResultNo.Substring(strResultNo.Length - 3);
                        }

                        // -----心電図区分を取得-----
                        xmlNode = xmlNodes.SelectSingleNode("ELECTROCARDIOGRAM_TYPE");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・心電図(心電図区分)"))
                        {
                            return false;
                        }
                        strEcgType = xmlNode.InnerText;


                        if (m_dictSendEcgList.ContainsKey(strOccurDate + strResultNo))
                        {
                            continue;
                        }

                        // 酸素吸入情報リストに蓄積
                        ArrayList arrItem = new ArrayList();
                        // ※  [0]RESULT_NO
                        arrItem.Add(strResultNo);
                        // ※  [1]OCCUR_DATE
                        arrItem.Add(strOccurDate);
                        // ※  [2]ELECTROCARDIOGRAM_TYPE
                        arrItem.Add(strEcgType);
                        // ※  [3]開始レコードのOCCUR_DATE
                        // この時点では未設定
                        // ※  [4]汎用オーダ番号 
                        // この時点では未設定

                        // 発生日時をキーにしてハッシュに追加（後でキーでソートするため）
                        m_dictSendEcgList.Add(strOccurDate + strResultNo, arrItem);
                    }
                }
            }


            #region 2011.03.17仕様変更前丸ごと退避
            //// ------------------------------------------------------
            //// 酸素吸入量
            //// ------------------------------------------------------
            //// >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //// ※有無を判定するため、モードに関わらず常に実施
            //// 　モードによる制御は最深部ディテールコレクションにセットするところで行う
            //// <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //#region
            //// 透析実績愁訴処置_処置履歴からその他薬剤を取得 
            //foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_TREATMENT_HST"))
            //{
            //    // 初期化
            //    strInHospitalCode = string.Empty;
            //    strAmount = string.Empty;
            //    strFunctionCode = string.Empty;
            //    // 透析実績投薬履歴・処置区分を取得
            //    xmlNode = xmlNodes.SelectSingleNode("TREAT_CLASS");
            //    // ノードチェック
            //    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(処置区分)"))
            //    {
            //        // データが無い場合は処理を抜ける
            //        break;
            //    }
            //    strCtlNo = xmlNode.InnerText;
            //    // 透析実績投薬履歴・処置区分が「"3"：酸素吸入」か判定する
            //    if (strCtlNo == CODE_DIALYSIS_TREATMEN_OX)
            //    {
            //        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //        // 酸素吸入モードのときのみ送信処理
            //        if (sendMode == OrderSendMode.Oxygen)
            //        {
            //            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //            // -----機能コードを設定-----
            //            strFunctionCode = CODE_MEASURES_MATERIAL;
            //            // -----院内コードを設定-----
            //            strInHospitalCode = m_strOxygenInhalationCode;
            //            strInHospitalCode = strInHospitalCode.Trim();
            //            // 値チェック(設定値だが一応チェック)
            //            if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(院内コード)"))
            //            {
            //                // 処理続行
            //            }
            //            // -----使用量を取得-----
            //            xmlNode = xmlNodes.SelectSingleNode("OXYGEN_AMOUNT");
            //            // ノードチェック
            //            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(使用量)"))
            //            {
            //                return false;
            //            }
            //            strAmount = xmlNode.InnerText;
            //            //// 使用量の値チェックでのエラーメッセージ出さない
            //            //// 院内コード及び使用量の有無を確認 ※酸素吸入で"時間が設定されている"レコードには"使用量が設定されていない"のでその場合は無視する(※使用量が設定されていないものは酸素吸入時間で設定)←仕様変更・酸素使用量は送らない
            //            //if (strAmount != string.Empty && strInHospitalCode != string.Empty)
            //            //{
            //            //    // ▼オーダディテールリストに追加▼
            //            //    AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount);
            //            //}
            //            // 使用量が空でも規定の値を設定する為、時間が設定されていないことでこのレコードが使用量と判断する＆院内コードの有無確認
            //            if (xmlNodes.SelectSingleNode("OXYGEN_TIME").InnerText.Trim() == string.Empty && strInHospitalCode != string.Empty)
            //            {
            //                // 値チェック
            //                if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・酸素吸入量(使用量)"))
            //                {
            //                    // 値が空の場合は規定値を設定
            //                    strAmount = EMPTY_VAL;
            //                }
            //                // ▼オーダディテールリストに追加▼
            //                AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount);
            //            }
            //            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //        }
            //        // それ以外のモードのときは存在フラグのみ立てて抜ける
            //        else
            //        {
            //            m_isOxygenFound = true;
            //        }
            //        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //    }
            //}
            #endregion
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            #endregion



            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            // 人工腎臓モードのときのみ
            if (sendMode == OrderSendMode.Dialisys)
            {
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                // ------------------------------------------------------
                // 医療材料            
                // ------------------------------------------------------
                #region
                // 透析実績透析条件履歴を取得
                foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_EQUIP_HST"))
                {
                    // 初期化
                    strInHospitalCode = string.Empty;
                    strAmount = string.Empty;
                    strFunctionCode = string.Empty;
                    // -----機能コードを設定-----
                    strFunctionCode = CODE_MEASURES_MATERIAL;
                    // -----院内コードを取得-----
                    xmlNode = xmlNodes.SelectSingleNode("MST_EQUIPMENT/IN_HOSPITAL_CD");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・医療材料(院内コード)"))
                    {
                        // データが無い場合は処理を抜ける
                        break;
                    }
                    strInHospitalCode = xmlNode.InnerText.Trim();
                    // 値チェック
                    if (!this.CheckEmptyVal(strInHospitalCode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・医療材料(院内コード)"))
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
                    // -----使用量を取得-----
                    xmlNode = xmlNodes.SelectSingleNode("AMOUNT");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・医療材料(使用量)"))
                    {
                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                        //return false;
                        // ワーニングログ出力
                        // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                        // this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "注射オーダ・オーダディテール・医療材料(使用量)");
                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_NULL, "オーダ・オーダディテール・医療材料(使用量)");
                        // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                        // 送信データを出力対象から除外 
                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                    }
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                    else
                    {
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                        strAmount = xmlNode.InnerText;
                        //// 値チェック
                        //if (!this.CheckEmptyVal(strAmount, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・医療材料(使用量)"))
                        //{
                        //    return false;
                        //}
                        // 値チェック
                        if (!this.CheckEmptyVal(strAmount, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・医療材料(使用量)"))
                        {
                            // 値が空の場合は規定値を設定
                            strAmount = EMPTY_VAL;
                        }

                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                        if (double.Parse(strAmount) == 0)
                        {
                            // ワーニングログ出力
                            // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg Start
                            // this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "注射オーダ・オーダディテール・医療材料(使用量)");
                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_DATA_ZERO, "オーダディテール・医療材料(使用量)");
                            // 2015/09/03 中村 受入指摘対応(Redmine#4953) Chg End
                            // 送信データを出力対象から除外 
                        }
                        else
                        {
                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応

                            // 院内コードの有無を確認
                            if (strInHospitalCode != string.Empty)
                            {
                                // ▼オーダディテールリストに追加▼
                                AddOrderDetailData(ref orderDetailDataMgr, strFunctionCode, strInHospitalCode, strAmount, "", "");
                            }
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                        }
                    }
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 特殊浄化対応
                }
                #endregion

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            }
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

            // 2016/04/15 中村 その他処置送信仕様変更 Add Start
            if (sendMode == OrderSendMode.Treatment)
            {
                foreach (TreatItemInfo item in treatInfo.GetTreatItem)
                {
                    // ▼オーダディテールリストに追加▼
                    AddOrderDetailData(ref orderDetailDataMgr, item.Function, item.ItemCode, item.Amount, "", "");
                }
            }
            // 2016/04/15 中村 その他処置送信仕様変更 Add End

            // ----------------------------------------------
            // ディテールデータが存在するか確認する
            // ----------------------------------------------
            if (orderDetailDataMgr.Count == 0)
            {
                // ディテール未作成
                this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテールは作成されませんでした。");

                // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                // 酸素吸入モードの場合
                if (sendMode == OrderSendMode.Oxygen)
                {
                    // 酸素吸入データなしフラグを有効
                    m_blnOxygenNotDataFlag = true;
                }
                // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応

                // 心電図モードの場合
                if (sendMode == OrderSendMode.Ecg)
                {
                    // 心電図データなしフラグを有効
                    m_blnEcgNotDataFlag = true;
                }

                if (sendMode != OrderSendMode.Treatment)
                {
                    return false;
                }
            }
            // ----------------------------------------------
            // オーダディテールを作成する
            // ----------------------------------------------
            foreach (OrderDetailData detailData in orderDetailDataMgr)
            {
                // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                // 機能コードが「06:時間」のとき
                if (detailData.FunctionCode == CODE_MEASURES_TIME)
                {
                    // オーダディテールを作成する
                    if (!SetOrderDetailTypeOxygen(detailData.InHospitalCode, detailData.StartTime, detailData.EndTime))
                    {
                        // エラー
                        return false;
                    }
                }
                // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                // それ以外
                else
                {
                    // オーダディテールを作成する
                    if (!SetOrderDetailType(detailData.FunctionCode, detailData.InHospitalCode, detailData.Amount))
                    {
                        // エラー
                        return false;
                    }
                }
            }

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }




        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        /// <summary>
        /// 汎用オーダ・ディテールコレクションを設定する。
        /// ※酸素吸入時間
        /// </summary>
        /// <param name="strInHospitalCode"></param>
        /// <param name="strStartTime"></param>
        /// <param name="strEndTime"></param>
        /// <returns>true:正常/false:異常</returns>
        private bool SetOrderDetailTypeOxygen(string strInHospitalCode, string strStartTime, string strEndTime)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;

            // -----------------------------------------------
            // -- ディテール・機能コード・0 --
            // -----------------------------------------------
            // 「“06”：時間」を設定（固定値）
            strSetData = CODE_MEASURES_TIME;
            CSICommon.pSetDETAILData(0, strSetData);
            // -----------------------------------------------
            // -- ディテール・行為詳細項目コード・1 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(1, strSetData);
            // -----------------------------------------------
            // -- ディテール・使用量・2 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(2, strSetData);
            // -----------------------------------------------
            // -- ディテール・フリーテキスト・3 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(3, strSetData);
            // -----------------------------------------------
            // -- ディテール・開始時間・4 --
            // -----------------------------------------------
            // [HH:MM]
            strSetData = strStartTime;
            CSICommon.pSetDETAILData(4, strSetData);
            // -----------------------------------------------
            // -- ディテール・終了時間・5 --
            // -----------------------------------------------
            // [HH:MM]
            strSetData = strEndTime;
            CSICommon.pSetDETAILData(5, strSetData);

            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダディテールコレクションにオーダディテール配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(4, CSICommon.varDETAIL);

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        

        /// <summary>
        /// 汎用オーダ・オーダディテール配列に値を設定する
        /// </summary>
        /// <param name="strFunctionCode">機能コード</param>
        /// <param name="strInHospitalCode">院内コード</param>
        /// <param name="strAmount">使用量</param>
        /// <returns>true:正常/false:異常</returns>
        private bool SetOrderDetailType(string strFunctionCode, string strInHospitalCode, string strAmount)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;

            // -----------------------------------------------
            // -- ディテール・機能コード・0 --
            // -----------------------------------------------
            strSetData = strFunctionCode;
            // 値チェック
            if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・機能コード"))
            {
                return false;
            }
            CSICommon.pSetDETAILData(0, strSetData);
            // -----------------------------------------------
            // -- ディテール・行為詳細項目コード・1 --
            // -----------------------------------------------
            strSetData = strInHospitalCode;
            // 値チェック
            if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・行為詳細項目コード"))
            {
                return false;
            }
            //>>>>> T.Kurita DEL 2011/12/16 院内コード送信仕様変更
            //// 前0詰め6桁
            //strSetData = strSetData.PadLeft(6, '0');
            //<<<<< T.Kurita DEL 2011/12/16 院内コード送信仕様変更
            CSICommon.pSetDETAILData(1, strSetData);
            // -----------------------------------------------
            // -- ディテール・使用量・2 --
            // -----------------------------------------------
            strSetData = strAmount;
            // 値チェック
            if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダディテール・使用量"))
            {
                return false;
            }
            CSICommon.pSetDETAILData(2, strSetData);
            // -----------------------------------------------
            // -- ディテール・フリーテキスト・3 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(3, strSetData);
            // -----------------------------------------------
            // -- ディテール・開始時間・4 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(4, strSetData);
            // -----------------------------------------------
            // -- ディテール・終了時間・5 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(5, strSetData);

            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // ++ オーダディテールコレクションにオーダディテール配列を追加 ++
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            CSICommon.pSetCollection(4, CSICommon.varDETAIL);

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }

        /// <summary>
        /// 汎用オーダ・ディテールコレクションを設定する
        /// ※処理区分が削除時
        /// </summary>
        private void SetOrderDetailOfEmpty()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strSetData = null;

            // -----------------------------------------------
            // -- ディテール・機能コード・0 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(0, strSetData);
            // -----------------------------------------------
            // -- ディテール・行為詳細項目コード・1 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(1, strSetData);
            // -----------------------------------------------
            // -- ディテール・使用量・2 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(2, strSetData);
            // -----------------------------------------------
            // -- ディテール・フリーテキスト・3 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(3, strSetData);
            // -----------------------------------------------
            // -- ディテール・開始時間・4 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetDETAILData(4, strSetData);
            // -----------------------------------------------
            // -- ディテール・終了時間・5 --
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


        #region 汎用オーダ・その他

        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

        /// <summary>
        /// 「イベントの送信区分」と「実際の送信データ(汎用オーダ)」の有無から実際の送信区分を決定する
        /// ※例：「イベントの送信区分が修正」で「データが無い」場合 ⇒ 処理区分が削除になる
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/その他処置）</param>
        /// <param name="actionCode">行為コード（その他処置のみ使用）</param>
        /// <param name="medicineCode">送信対象の薬剤コード（その他処置のみ使用）</param>
        /// <param name="oxygenArray">酸素吸入の送信情報（酸素吸入のみ使用）</param>
        /// <returns>送信区分(nullの場合は送信データがない)</returns>
        // private string ChangeSendClassGeneral(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string actionCode, string medicineCode, ArrayList oxygenArray)
        // private string ChangeSendClassGeneral(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, ArrayList treatArray, ArrayList oxygenArray)
        private string ChangeSendClassGeneral(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, TreatActInfo treatInfo, ArrayList oxygenArray, ArrayList ecgArray)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());
            
            string strRet = null;

            // 人工腎臓モード
            if (sendMode == OrderSendMode.Dialisys)
            {
                // 必ずあるのでイベントから上がったままでよい
                strRet = exeInfo.SendClass;
            }
            // 他のモードでは判定が必要
            else
            {
                string strOrderNo;
                bool blnDataFound;

                // 酸素吸入モード
                if (sendMode == OrderSendMode.Oxygen)
                {
                    #region 酸素吸入複数化に伴う見直し
                    //// オーダ番号を取得する(オーダ番号の有無で送信実績を判断する）
                    //ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, string.Empty);
                    //strOrderNo = arr[1].ToString();

                    //// 今回イベント内にデータが存在するかの判定結果
                    //blnDataFound = m_isOxygenFound;
                    #endregion

                    // 送信実績があるかの判定
                    // ※オーダ番号の有無で送信実績を判断する
                    if (oxygenArray.Count < 7)
                    {
                        strOrderNo = string.Empty;
                    }
                    else
                    {
                        strOrderNo = oxygenArray[6].ToString();
                    }

                    // 今回イベント内にデータが存在するかの判定
                    // ※発生日時がセットされているかで判断
                    blnDataFound = !(oxygenArray[1].ToString().Equals(string.Empty));
                
                }
                // 心電図モード
                else if (sendMode == OrderSendMode.Ecg)
                {

                    // 送信実績があるかの判定
                    // ※オーダ番号の有無で送信実績を判断する
                    if (ecgArray.Count < 5)
                    {
                        strOrderNo = string.Empty;
                    }
                    else
                    {
                        strOrderNo = ecgArray[4].ToString();
                    }

                    // 今回イベント内にデータが存在するかの判定
                    // ※発生日時がセットされているかで判断
                    blnDataFound = !(ecgArray[1].ToString().Equals(string.Empty));

                }
                // その他処置モード
                else
                {
#if false
                    // オーダ番号を取得する(オーダ番号の有無で送信実績を判断する）
                    ArrayList arr = GetSendedOrderNo(exeInfo, sendMode, medicineCode, oxygenArray);
                    strOrderNo = arr[1].ToString();

                    // 今回イベント内にデータが存在するかの判定結果
                    blnDataFound = true;
                    if (actionCode.Equals(string.Empty))
                    {
                        blnDataFound = false;
                    }
#else
                    blnDataFound = true;

                    // 送信実績があるかの判定
                    // ※オーダ番号の有無で送信実績を判断
                    //if (treatArray.Count < 6)
                    //{
                    //    strOrderNo = string.Empty;
                    //}
                    //else
                    //{
                    //    strOrderNo = treatArray[5].ToString();
                    //    if (string.IsNullOrEmpty(treatArray[0].ToString()))
                    //    {
                    //        blnDataFound = false;
                    //    }
                    //}
                    if (string.IsNullOrEmpty(treatInfo.OrderNo))
                    {
                        strOrderNo = string.Empty;
                    }
                    else
                    {
                        strOrderNo = treatInfo.OrderNo.ToString();
                        if (string.IsNullOrEmpty(treatInfo.MstMedCode.ToString()))
                        {
                            blnDataFound = false;
                        }
                    }
#endif
                }

                // 送信区分(exeInfo.SendClass)を判断する
                switch (exeInfo.SendClass)
                {
                    case EVENT_TYPE_ADD:   // 新規
                        // データの有無の確認
                        if (blnDataFound)
                        {
                            // データ有り ⇒ 新規区分
                            strRet = EVENT_TYPE_ADD;
                        }
                        else
                        {
                            // データ無し ⇒ 送信しない
                            strRet = null;
                        }
                        break;
                    case EVENT_TYPE_CHG:   // 修正 
                        // データの有無の確認
                        if (blnDataFound)
                        {
                            // 送信実績の有無の確認
                            if (strOrderNo == string.Empty)
                            {
                                // データ有り・送信実績の無し ⇒ 新規区分
                                strRet = EVENT_TYPE_ADD;
                            }
                            else
                            {
                                // データ有り・送信実績の有り ⇒ 修正区分
                                strRet = EVENT_TYPE_CHG;
                            }
                        }
                        else
                        {
                            // 送信実績の有無の確認
                            if (strOrderNo == string.Empty)
                            {
                                // データ無し・送信実績の無し ⇒ 送信しない
                                strRet = null;
                            }
                            else
                            {
                                // データ無し・送信実績の有り ⇒ 削除区分
                                strRet = EVENT_TYPE_DEL;
                            }
                        }
                        break;
                    case EVENT_TYPE_DEL:   // 削除
                        // データの有無の確認
                        if (blnDataFound)
                        {
                            // 送信実績の有無の確認
                            if (strOrderNo == string.Empty)
                            {
                                // データ有り・送信実績の無し ⇒ 削除区分
                                strRet = EVENT_TYPE_DEL;
                            }
                            else
                            {
                                // データ有り・送信実績の有り ⇒ 削除区分
                                strRet = EVENT_TYPE_DEL;
                            }
                        }
                        else
                        {
                            // 送信実績の有無の確認
                            if (strOrderNo == string.Empty)
                            {
                                // データ無し・送信実績の無し ⇒ 送信しない
                                strRet = null;
                            }
                            else
                            {
                                // データ無し・送信実績の有り ⇒ 送信しない
                                strRet = null;
                            }
                        }
                        break;
                }
            }
            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            // 処理区分を返す
            return strRet;
        }


        /// <summary>
        /// 送信履歴から送信済み酸素吸入の”実績番号”を全て抽出し、リストを返す
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <returns></returns>
        private ArrayList GetSendedOxygenResultNoList(Fn3ExecuteInfo exeInfo)
        {
            // 管理番号毎に分割
            string[] manageEle = exeInfo.SendHistMemo.Split(',');
            ArrayList arrResult;
          
            // 新式管理番号はない
            if (manageEle.Length < 6)
            {
                return null;
            }
            // 新式管理番号ありのとき
            else
            {
                arrResult = new ArrayList();

                // 汎用オーダ毎に分割
                string[] orderEle = manageEle[5].Split(CSICommonConst.ORDERNO_PAIR_SEPARATER[0]);

                // 酸素吸入オーダのみ抽出する
                foreach (string ele in orderEle)
                {
                    // トークン分割
                    string[] keyEle = ele.Split(CSICommonConst.ORDERNO_KEY_SEPARATER[0]);
                    // 最初のトークンが酸素吸入のキーのもののみ
                    if (keyEle[0] == CSICommonConst.ORDERNO_KEY_OXYGEN)
                    {
                        ArrayList arrElement = new ArrayList();
                        arrElement.Add(keyEle[1]); // 実績番号
                        arrElement.Add(keyEle[2]); // オーダ番号
                        // 結果リストに追加
                        arrResult.Add(arrElement);
                    }
                }

                // 結果のあるときのみリストを返す
                if (arrResult.Count == 0)
                {
                    return null;
                }
                else
                {
                    return arrResult;
                }
            }
        }

        /// <summary>
        /// 送信履歴から送信済み心電図の”実績番号”を全て抽出し、リストを返す
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <returns></returns>
        private ArrayList GetSendedEcgResultNoList(Fn3ExecuteInfo exeInfo)
        {
            // 管理番号毎に分割
            string[] manageEle = exeInfo.SendHistMemo.Split(',');
            ArrayList arrResult;

            // 新式管理番号はない
            if (manageEle.Length < 6)
            {
                return null;
            }
            // 新式管理番号ありのとき
            else
            {
                arrResult = new ArrayList();

                // 汎用オーダ毎に分割
                string[] orderEle = manageEle[5].Split(CSICommonConst.ORDERNO_PAIR_SEPARATER[0]);

                // 心電図オーダのみ抽出する
                foreach (string ele in orderEle)
                {
                    // トークン分割
                    string[] keyEle = ele.Split(CSICommonConst.ORDERNO_KEY_SEPARATER[0]);
                    // 最初のトークンが心電図のキーのもののみ
                    if (keyEle[0] == CSICommonConst.ORDERNO_KEY_ECG)
                    {
                        ArrayList arrElement = new ArrayList();
                        arrElement.Add(keyEle[1]); // 実績番号
                        arrElement.Add(keyEle[2]); // オーダ番号
                        // 結果リストに追加
                        arrResult.Add(arrElement);
                    }
                }

                // 結果のあるときのみリストを返す
                if (arrResult.Count == 0)
                {
                    return null;
                }
                else
                {
                    return arrResult;
                }
            }
        }

        private ArrayList GetSendedTreatResultNoList(Fn3ExecuteInfo exeInfo)
        {
            // 管理番号毎に分割
            string[] manageEle = exeInfo.SendHistMemo.Split(',');
            ArrayList arrResult;

            // 新式管理番号はない
            if (manageEle.Length < 6)
            {
                return null;
            }
            // 新式管理番号ありのとき
            else
            {
                arrResult = new ArrayList();

                // 汎用オーダ毎に分割
                string[] orderEle = manageEle[5].Split(CSICommonConst.ORDERNO_PAIR_SEPARATER[0]);

                // その他処置オーダのみ抽出する
                foreach (string ele in orderEle)
                {
                    // トークン分割
                    string[] keyEle = ele.Split(CSICommonConst.ORDERNO_KEY_SEPARATER[0]);
                    if (keyEle[0] != CSICommonConst.ORDERNO_KEY_DIALYSIS &&
                        keyEle[0] != CSICommonConst.ORDERNO_KEY_OXYGEN &&
                        keyEle[0] != CSICommonConst.ORDERNO_KEY_ECG)
                    {
                        ArrayList arrElement = new ArrayList();
                        arrElement.Add(keyEle[0]); // 薬剤コード
                        arrElement.Add(keyEle[1]); // 分類
                        arrElement.Add(keyEle[2]); // 項目コード
                        arrElement.Add(keyEle[3]); // オーダ番号
                        // 結果リストに追加
                        arrResult.Add(arrElement);
                    }
                }

                // 結果のあるときのみリストを返す
                if (arrResult.Count == 0)
                {
                    return null;
                }
                else
                {
                    return arrResult;
                }
            }
        }

        /// <summary>
        /// 送信済みオーダ番号取得処理
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="sendMode">汎用オーダ送信モード（人工腎臓/酸素吸入/心電図/その他処置）</param>
        /// <param name="medicineCode">送信対象の薬剤コード（その他処置のみ使用）</param>
        /// <returns>配列（[0]院内コード [1]オーダ番号（16桁））</returns>
        // private ArrayList GetSendedOrderNo(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, string medicineCode, ArrayList oxygenArray)
        private ArrayList GetSendedOrderNo(Fn3ExecuteInfo exeInfo, OrderSendMode sendMode, ArrayList oxygenArray, ArrayList ecgArray)
        {
            // 登録済みオーダ番号取得時のキーを選択する
            string orderNumberKey = string.Empty;
            // 人工腎臓モード
            if (sendMode == OrderSendMode.Dialisys)
            {
                orderNumberKey = CSICommonConst.ORDERNO_KEY_DIALYSIS;
            }
            // 酸素吸入モード
            else if (sendMode == OrderSendMode.Oxygen)
            {
                orderNumberKey = CSICommonConst.ORDERNO_KEY_OXYGEN;
            }
            // 心電図モード
            else if (sendMode == OrderSendMode.Ecg)
            {
                orderNumberKey = CSICommonConst.ORDERNO_KEY_ECG;
            }
            // // その他処置モード
            // else
            // {
            //     orderNumberKey = medicineCode;
            // }
            
            // 管理番号毎に分割
            string[] manageEle = exeInfo.SendHistMemo.Split(',');
            ArrayList arr = null;
          
            // 新式管理番号はない
            if (manageEle.Length < 6)
            {
                // 人工腎臓モード
                if (sendMode == OrderSendMode.Dialisys)
                {
                    if (manageEle.Length < 2)
                    {
                        // 送信実績はない
                        arr = new ArrayList();
                        arr.Add(string.Empty);  // 院内コード
                        arr.Add(string.Empty);  // オーダ番号
                    }
                    else
                    {
                        // 旧式で保持されていた番号を新式に成形して返す
                        arr = new ArrayList();
                        arr.Add(string.Empty);                  // 院内コード
                        // 2012/02/01 中村 オーダ番号オーバーフロー対応
                        //arr.Add(string.Format("{0:D13}", System.Convert.ToInt32(manageEle[0]))
                        //      + string.Format("{0:D3}", System.Convert.ToInt32(manageEle[1]))); // オーダ番号
                        arr.Add(string.Format("{0:D13}", System.Convert.ToInt64(manageEle[0]))
                              + string.Format("{0:D3}", System.Convert.ToInt32(manageEle[1]))); // オーダ番号

                    }
                }
                // 酸素吸入、心電図、その他の処置
                else
                {
                    // 送信実績はない
                    arr = new ArrayList();
                    arr.Add(string.Empty);  // 院内コード
                    arr.Add(string.Empty);  // オーダ番号
                }
            }
            // 新式管理番号ありのとき
            else
            {
                // 汎用オーダ番号毎に分割
                string[] orderEle = manageEle[5].Split(CSICommonConst.ORDERNO_PAIR_SEPARATER[0]);

                // 汎用オーダ番号をハッシュテーブルに変換
                Hashtable localHash = new Hashtable();
                foreach (string ele in orderEle)
                {
                    string[] keyEle = ele.Split(CSICommonConst.ORDERNO_KEY_SEPARATER[0]);
                    arr = new ArrayList();
                    arr.Add(keyEle[1]); // 院内コード
                    arr.Add(keyEle[2]); // オーダ番号

                    // 酸素吸入の場合は一次キーが同一
                    if (keyEle[0] == CSICommonConst.ORDERNO_KEY_DIALYSIS)
                    {
                        localHash.Add(keyEle[0], arr);
                    }
                    else if (keyEle[0] == CSICommonConst.ORDERNO_KEY_OXYGEN || keyEle[0] == CSICommonConst.ORDERNO_KEY_ECG)
                    {
                        // 実績番号も付加してハッシュキーとする
                        localHash.Add(keyEle[0] + keyEle[1], arr);
                    }
                }

                // 引数のキーに該当するものを返す
                if (localHash.ContainsKey(orderNumberKey))
                {
                    arr = (ArrayList)localHash[orderNumberKey];
                }
                else
                {
                    // 透析モード
                    if (sendMode == OrderSendMode.Dialisys)
                    {
                        arr = new ArrayList();
                        arr.Add(string.Empty);  // 院内コード
                        arr.Add(string.Empty);  // オーダ番号
                    }
                    // 酸素吸入モード
                    else if (sendMode == OrderSendMode.Oxygen)
                    {
                        // 酸素吸入のキーにヒットするか？
                        if (localHash.ContainsKey(orderNumberKey + oxygenArray[0].ToString()))
                        {
                            arr = (ArrayList)localHash[orderNumberKey + oxygenArray[0].ToString()];
                        }
                        else
                        {
                            arr = new ArrayList();
                            arr.Add(string.Empty);  // 院内コード
                            arr.Add(string.Empty);  // オーダ番号
                        }
                    }
                    // 心電図モード
                    else if (sendMode == OrderSendMode.Ecg)
                    {
                        // 心電図のキーにヒットするか？
                        if (localHash.ContainsKey(orderNumberKey + ecgArray[0].ToString()))
                        {
                            arr = (ArrayList)localHash[orderNumberKey + ecgArray[0].ToString()];
                        }
                        else
                        {
                            arr = new ArrayList();
                            arr.Add(string.Empty);  // 院内コード
                            arr.Add(string.Empty);  // オーダ番号
                        }
                    }
                }
            }
            return arr;
        }
        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
        
        /// <summary>
        /// ディテールリストにディテールデータを追加する(同一薬剤の場合は数量を纏める)
        /// </summary>
        /// <param name="orderDetailDataList">オーダディテールデータリスト</param>
        /// <param name="strFunctionCode">機能コード</param>
        /// <param name="strInHospitalCode">院内コード(行為項目詳細コード)</param>
        /// <param name="strAmount">数量</param>
        private void AddOrderDetailData
            (ref List<OrderDetailData> orderDetailDataList, string strFunctionCode, string strInHospitalCode, string strAmount, string strStartTime, string strEndTime)
        {
            bool bolAddFlg = true;

            // オーダディテールデータリストを参照
            foreach (OrderDetailData detailData in orderDetailDataList)
            {
                //院内コード及び機能コードを比較
                if (detailData.InHospitalCode == strInHospitalCode && detailData.FunctionCode == strFunctionCode)
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
                // OrderDetailData detailNewData = new OrderDetailData(strFunctionCode, strInHospitalCode, strAmount);
                OrderDetailData detailNewData = new OrderDetailData
                    (strFunctionCode, strInHospitalCode, this.RoundDecimal(strAmount), strStartTime, strEndTime);
                orderDetailDataList.Add(detailNewData);
            }
        }

        ///// <summary>
        ///// 汎用オーダ・透析実績透析条件履歴から血液浄化法医事コードを導き出す。
        ///// </summary>
        ///// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        ///// <param name="strRet">血液浄化法医事コード</param>
        ///// <returns>true:正常/false:異常</returns>
        //private bool GetActCode(Fn3ExecuteInfo exeInfo, out string strRet)
        //{
        //    // メソッド開始ログ
        //    this.MethodStartLogOut(MethodBase.GetCurrentMethod());                        
        //    // 初期化
        //    strRet = string.Empty;
        //    // 透析実績透析条件履歴を取得
        //    foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
        //    {
        //        // 透析実績透析条件履歴・透析条件項目コードを比較し治療方法のノードを取得する
        //        // 透析条件項目コードを取得
        //        XmlNode xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
        //        // ノードチェック
        //        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード　//rootNode/RST_DIALYSIS_COND_HST/CTL_NO"))
        //        {
        //            return false;
        //        }
        //        string strCtlNo = xmlNode.InnerText;
        //        if (strCtlNo == TARGET_TREAT_NO)
        //        {
        //            // 患者基本情報・入外を取得
        //            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/INOUT_FLG");
        //            // ノードチェック
        //            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード　//rootNode/PAT_BASIC_INFO/INOUT_FLG"))
        //            {
        //                return false;
        //            }
        //            string strInOut = xmlNode.InnerText;
        //            // 透析実績透析条件履歴・治療項目マスタ・院内コード
        //            xmlNode = xmlNodes.SelectSingleNode("MST_TREAT_ITEM/IN_HOSPITAL_CD");
        //            // ノードチェック
        //            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード　//rootNode/RST_DIALYSIS_COND_HST/MST_TREAT_ITEM/IN_HOSPITAL_CD"))
        //            {
        //                return false;
        //            }
        //            string treatName = xmlNode.InnerText;
        //            // 入外を判定
        //            if (strInOut == DB_INOUT_FLG_OUT)
        //            {
        //                // ---------------------------
        //                // 外来の場合
        //                // ---------------------------
        //                // 治療方法名称を比較
        //                switch (treatName)
        //                {
        //                    case TREATNAME_HEMODIALYSIS_4H_UNDER:   // 血液透析(4時間未満)                                
        //                        // 血液浄化法医事コード・人工腎臓１（イ）
        //                        strRet = m_strArtificialKidney1_I;
        //                        break;
        //                    case TREATNAME_HEMODIALYSIS_4H5H:       // 血液透析(4～5時間)                                
        //                        // 血液浄化法医事コード・人工腎臓１（ロ）
        //                        strRet = m_strArtificialKidney1_Ro;
        //                        break;
        //                    case TREATNAME_HEMODIALYSIS_5H_OVER:    // 血液透析(5時間以上)
        //                        // 血液浄化法医事コード・人工腎臓１（ハ）
        //                        strRet = m_strArtificialKidney1_Ha;
        //                        break;
        //                    case TREATNAME_HEMODIALYSIS_DIALYSIS:   // 血液透析濾過
        //                    case TREATNAME_HEMOFILTRATION:          // 血液濾過
        //                    case TREATNAME_ECUN:                    // ECUM
        //                        // 血液浄化法医事コード・人工腎臓２
        //                        strRet = m_strArtificialKidney2;
        //                        break;
        //                    default:                                // 異常
        //                        // エラー
        //                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード　治療方法名称が異常の為、血液浄化法医事コードに変換できません。：" + treatName);
        //                        return false;
        //                }
        //            }
        //            else if (strInOut == DB_INOUT_FLG_IN)
        //            {
        //                // ---------------------------
        //                // 入院の場合
        //                // ---------------------------
        //                // 治療方法名称を比較
        //                switch (treatName)
        //                {
        //                    case TREATNAME_HEMODIALYSIS_4H_UNDER:   // 血液透析(4時間未満)                                
        //                    case TREATNAME_HEMODIALYSIS_4H5H:       // 血液透析(4～5時間)                                
        //                    case TREATNAME_HEMODIALYSIS_5H_OVER:    // 血液透析(5時間以上)
        //                    case TREATNAME_HEMODIALYSIS_DIALYSIS:   // 血液透析濾過
        //                    case TREATNAME_HEMOFILTRATION:          // 血液濾過
        //                    case TREATNAME_ECUN:                    // ECUM
        //                        // 血液浄化法医事コード・人工腎臓２
        //                        strRet = m_strArtificialKidney2;
        //                        break;
        //                    default:                                // 異常
        //                        // エラー
        //                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード　治療方法名称が異常の為、血液浄化法医事コードに変換できません。：" + treatName);
        //                        return false;
        //                }
        //            }
        //            else
        //            {
        //                // エラー
        //                this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダグループ・行為コード　入外区分が異常の為、血液浄化法医事コードに変換できません。：" + strInOut);
        //                return false;
        //            }
        //        }
        //    }
        //    // メソッド終了ログ
        //    this.MethodEndLogOut(MethodBase.GetCurrentMethod());
        //    // 戻り（血液浄化法医事コード）
        //    return true;
        //}
        #endregion

        #endregion
    }
}
