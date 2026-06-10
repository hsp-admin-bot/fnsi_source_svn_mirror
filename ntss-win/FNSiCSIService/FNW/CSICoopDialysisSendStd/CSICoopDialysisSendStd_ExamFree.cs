///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：シーエスアイ標準連携　透析実績送信機能
// ファイル名：CSICoopDialysisSendStd_ExamFree.cs
// 説明      ：透析実績送信機能を提供する。※パーシャルクラス
//
//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2010/02/15	今井久雄   			新規作成
//  2011/01/07  中村圭之介          指示医を版確定者⇒患者基本情報.担当医に変更。
//  2011/01/11  中村圭之介          スタッフコード先頭0詰めなし対応
//  2011/05/13  中村圭之介          指示医対応（新里ﾒﾃﾞｨｹｱ版よりマージ）
//  2015/07/30  石川俊介            特殊浄化対応,ログ強化
//  2017/02/05  橋口雅典            5.02加算対応（透析困難コメントの複数出力）
//  2025/06/10  P.H.Thach           成田記念モード追加
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
        #region メソッド定義・プライベート

        #region 患者診療フリー・メイン
        /// <summary>
        /// 患者診療フリーデータを送信する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <param name="strRetOrederNo">オーダ番号（戻り値）</param>
        /// <returns>true:正常/false:異常</returns>
        private bool SendExamFreeMgr(Fn3ExecuteInfo exeInfo, out string strRetOrederNo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // -----------------------------------------------
            // 初期化
            // -----------------------------------------------
            CSICommon.ClearAllParameter();
            strRetOrederNo = string.Empty;
            // -----------------------------------------------
            // 領域確保
            // -----------------------------------------------
            // 患者診断フリーデータ領域
            CSICommon.varEXAMFREE = new object[13];
            // アウトパラメータ領域
            CSICommon.varOUTPARAM = new object[1];
            // +++++++++++++++++++++++++++++++++++++++++++++++
            // ▼患者診断フリーデータを設定▼
            // +++++++++++++++++++++++++++++++++++++++++++++++
            bool bolSetData = SetExamFreeData(exeInfo);
            if (!bolSetData)
            {
                // エラー（ログは下位で出力）
                return false;
            }

 #if !WITHOUT_INTERFACE
           // +++++++++++++++++++++++++++++++++++++++++++++++
            // ▼患者診断フリーデータを送信▼
            // +++++++++++++++++++++++++++++++++++++++++++++++
            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
            base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pExamFree() Start");
            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
            bool blnExec = CSICommonMethod.pExamFree(m_objCSIEXAMRREE,
                                                     CSICommon.varEXAMFREE,
                                                     ref CSICommon.varOUTPARAM,
                                                     ref CSICommon.colERR,
                                                     m_objMiraisDB);
            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
            base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pExamFree() End");
            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
#else
            bool blnExec = true;
#endif

            if (!blnExec)
            {
                // エラー
                this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_EXAMRREE, CSICommonMethod.GetLastErrorString());
                return false;
            }
            else
            {
                // -----------------------------------------------
                // オーダNo、オーダサブNoを設定する
                // -----------------------------------------------
                // 処理区分を確認
                if (exeInfo.SendClass == EVENT_TYPE_ADD)
                {
#if !WITHOUT_INTERFACE
                    // 新規登録の場合は診療番号を取得
                    string strMainNo = CSICommon.pGetOUTPARAMData(0).ToString();
#else
                    string strMainNo = "123456";
#endif
                    if (strMainNo.Equals(string.Empty))
                    {
                        // MIRAIｓ発行オーダNoが不正
                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_SEND_EXAMRREE, "MIRAIｓ発行オーダNoが不正です");
                        return false;
                    }
                    else
                    {
                        // 新規の場合は取得したオーダNo、オーダサブNoを設定
                        strRetOrederNo = strMainNo;
                    }
                }
                else
                {
                    // 新規以外は既存のオーダNoを再設定
                    string[] strBuf = exeInfo.SendHistMemo.Split(',');
                    strRetOrederNo = strBuf[4];
                }
            }
            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            // 正常終了
            return true;
        }
        #endregion


        #region 患者診療フリー・データ
        /// <summary>
        /// 患者診断フリーデータを設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <returns></returns>
        private bool SetExamFreeData(Fn3ExecuteInfo exeInfo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            string strNode = null;
            string strSetData = null;
            XmlNode xmlNode = null;

            // -----------------------------------------------
            // -- 患者診療フリー・処理区分・0 --
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                    strSetData = CSICommonConst.PROCDIV_INSERT;
                    break;
                case EVENT_TYPE_CHG:   // 修正 
                    strSetData = CSICommonConst.PROCDIV_MODIFY;
                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = CSICommonConst.PROCDIV_DELETE;
                    break;
                default:
                    // ありえないが一応確認（ここ以外ではexeInfo.SendClassの異常値は確認しない）
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "処理区分:" + exeInfo.SendClass.ToString());
                    return false;
            }
            CSICommon.pSetEXAMFREEData(0, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・診察番号・1 --           
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                    strSetData = null;
                    break;
                case EVENT_TYPE_CHG:   // 修正 
                case EVENT_TYPE_DEL:   // 削除 
                    // SendHistMemoの内容は「汎用オーダ番号,汎用オーダサブ番号,注射オーダ番号,注射オーダサブ番号,患者診療フリー診療番号」となる
                    string[] strBuf = exeInfo.SendHistMemo.Split(',');
                    strSetData = strBuf[4];
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診察番号"))
                    {
                        return false;
                    }
                    break;
            }
            CSICommon.pSetEXAMFREEData(1, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・患者番号・2 --
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    // 患者基本情報・表示用患者IDを取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DISP_PATID");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・患者番号"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・患者番号"))
                    {
                        return false;
                    }
                    // 取得した患者IDが設定桁数以下の場合に対応する為、設定桁数で0詰めする
                    strSetData = strSetData.PadLeft(m_iSendDispPatIdFigures, '0');
                    // 患者番号の下設定桁数を取得する
                    strSetData = strSetData.Substring(strSetData.Length - m_iSendDispPatIdFigures, m_iSendDispPatIdFigures);
                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetEXAMFREEData(2, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・診療科・3 --
            // -----------------------------------------------
            strSetData = null;
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                    // 2013/04/23 中村 科コード設定対応 Chg Start
#if false
                    // 患者基本情報・患者グループの院内コード
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_PAT_GROUP/IN_HOSPITAL_CD");
                    if (xmlNode == null || xmlNode.InnerText.Trim().Length != 5)
                    {
                        // 透析実績依頼科を設定（設定値）
                        strSetData = m_strDapartment;
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
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetEXAMFREEData(3, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・診察日・4 --
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正
                    // 透析実績・透析開始日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダ・診察日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダ・診察日"))
                    {
                        return false;
                    }
                    else
                    {
                        // 日時から日付のみを設定
                        strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_DAY);
                    }
                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetEXAMFREEData(4, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・診療時刻・5 --
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    // 透析実績・透析開始日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_ORDER, "オーダ・診療時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_ORDER, "オーダ・診療時刻"))
                    {
                        // 必須項目ではないので処理続行
                        strSetData = null;
                    }
                    else
                    {
                        // 日時から時刻のみを設定
                        strSetData = DateTime.Parse(strNode).ToString(OUTPUT_FROMAT_TIME);
                    }
                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetEXAMFREEData(5, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・指示医・6 --
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更
#if false
                    // 透析実績版番管理・版確定者を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・指示医"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・指示医"))
                    {
                        return false;
                    }
                    // 前0詰め5桁
                    strSetData = strSetData.Trim();
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
                        if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "患者基本情報・担当医1"))
                        {
                            strSetData = xmlNode.InnerText.Trim();
                        }
                        if (string.IsNullOrEmpty(strSetData))
                        {
                            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DOCTOR_CD2");
                            if (this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "患者基本情報・担当医2"))
                            {
                                strSetData = xmlNode.InnerText.Trim();
                            }
                        }
                        // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                        // ※デフォルト値をセットして続行しているので、警告が適切
                        //if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "患者基本情報・担当医"))
                        if (!this.CheckEmptyVal(strSetData, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "患者基本情報・担当医"))
                        // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                        {
                            strSetData = this.m_strDefaultStaffCd;
                        }
                    }
                    break;
#endif
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetEXAMFREEData(6, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・登録者・7 --
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    // 透析実績版番管理・版確定者を設定
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・登録者"))
                    {
                        return false;
                    }
                    strSetData = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・登録者"))
                    {
                        return false;
                    }
                    // 前0詰め5桁
                    strSetData = strSetData.Trim();
                    
                    // 2011/01/11 中村 スタッフコード0詰めなし対応
                    // strSetData = strSetData.PadLeft(5, '0');
                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }
            CSICommon.pSetEXAMFREEData(7, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・更新端末・8 --
            // -----------------------------------------------
            // 透析実績入力端末を設定（設定値）
            strSetData = m_strUpdateErminal;
            CSICommon.pSetEXAMFREEData(8, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・更新者・9 --
            // -----------------------------------------------
            // 透析実績版番管理・版確定者を設定
            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_EDITION/DECIDER");
            // ノードチェック
            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・更新者"))
            {
                return false;
            }
            strSetData = xmlNode.InnerText;
            // 値チェック
            if (!this.CheckEmptyVal(strSetData, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・更新者"))
            {
                return false;
            }
            // 前0詰め5桁
            strSetData = strSetData.Trim();
            // 2011/01/11 中村 スタッフコード0詰めなし対応
            // strSetData = strSetData.PadLeft(5, '0');
            CSICommon.pSetEXAMFREEData(9, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・ＰＯＳ番号・10 --
            // -----------------------------------------------
            strSetData = null;
            CSICommon.pSetEXAMFREEData(10, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・診療フリータイトル・11 --
            // -----------------------------------------------
            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    // 透析実績履歴・透析開始時刻を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリータイトル・透析開始時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリータイトル・透析開始時刻"))
                    {
                        return false;
                    }
                    strSetData = DateTime.Parse(strNode).ToString("透析実績（yyyy年MM月dd日");
                    // 透析実績履歴・クールマスタ・クール名
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/MST_KUR/KUR_NAME");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリータイトル・クール名"))
                    {
                        // 処理続行　※クールは設定されていないと取得出来ない。
                        strSetData = string.Empty;
                    }
                    else
                    {
                        strNode = " " + xmlNode.InnerText;

                    }
                    strSetData = strSetData + strNode + "）";
                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }
            // ※診療フリータイトルは漢字32文字以内
            CSICommon.pSetEXAMFREEData(11, strSetData);
            // -----------------------------------------------
            // -- 患者診療フリー・診療フリー内容・12 --
            // -----------------------------------------------
            // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加
            if (this.m_ExamFreeMode == "1")
            {
                if (!SetExamFreeDataDetailNrt(exeInfo, out strSetData))
                {
                    return false;
                }
            }
            else
            {
                if (!SetExamFreeDataDetail(exeInfo, out strSetData))
                {
                    return false;
                }
            }

            // ※診療フリー内容は漢字2000文字以内
            strSetData = TruncateByByte(strSetData, 4000, Encoding.GetEncoding("shift_jis"));
            
            // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加

            CSICommon.pSetEXAMFREEData(12, strSetData);
            
            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            return true;
        }

        // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加

        /// <summary>
        /// 指定された最大バイト数以内で文字列を切り取ります。
        /// マルチバイト文字が途中で切れる場合、その文字は除外されます。
        /// </summary>
        /// <param name="input">切り取る対象の文字列</param>
        /// <param name="maxBytes">最大バイト数</param>
        /// <param name="encoding">使用するエンコーディング（nullの場合はUTF-8）</param>
        /// <returns>指定バイト数以内で切り取られた文字列</returns>
        private string TruncateByByte(string input, int maxBytes, Encoding encoding)
        {
            if (string.IsNullOrEmpty(input) || maxBytes <= 0)
                return string.Empty;

            if (encoding == null)
                encoding = Encoding.UTF8;

            int byteCount = 0;
            int charIndex = 0;

            while (charIndex < input.Length)
            {
                int charByteCount = encoding.GetByteCount(new char[] { input[charIndex] });

                if (byteCount + charByteCount > maxBytes)
                    break;

                byteCount += charByteCount;
                charIndex++;
            }

            return input.Substring(0, charIndex);
        }

        /// <summary>
        /// 患者診断フリーデータ詳細を設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <returns></returns>
        private bool SetExamFreeDataDetail(Fn3ExecuteInfo exeInfo, out string strSetData)
        {
            string strNode = null;
            strSetData = null;
            XmlNode xmlNode = null;

            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 
                    // -----------------------------------------------
                    // 診療フリー内容（見出し・治療方法）
                    // -----------------------------------------------
                    strNode = string.Empty;
                    // 透析実績透析条件履歴を取得
                    foreach (XmlNode xmlNodes in exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_DIALYSIS_COND_HST"))
                    {
                        // 透析実績透析条件履歴・透析条件項目コードを取得
                        xmlNode = xmlNodes.SelectSingleNode("CTL_NO");
                        // ノードチェック
                        if (xmlNode != null)
                        {
                            // 透析条件項目コードが治療方法か判定する
                            if (xmlNode.InnerText == CODE_DIALYSIS_ITEM_TREAT)
                            {
                                // 透析条件項目コードが治療方法なら治療方法名称を取得
                                xmlNode = xmlNodes.SelectSingleNode("MST_TREAT_ITEM/TREAT_ITEM_NAME");
                                // ノードチェック
                                if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・治療方法"))
                                {
                                    return false;
                                }
                                strNode = xmlNode.InnerText;
                            }
                        }
                    }
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・治療方法"))
                    {
                        return false;
                    }
                    strSetData = "治療方法:" + strNode + "\r\n";
                    // -----------------------------------------------
                    // 診療フリー内容（見出し・透析治療時間）
                    // -----------------------------------------------
                    // 透析実績履歴・透析時間を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/DIALYSIS_TIME");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析治療時間"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析治療時間"))
                    {
                        return false;
                    }
                    strSetData = strSetData + "透析治療時間: " + int.Parse(strNode).ToString() + "分\r\n";
                    //strSetData = strSetData + "透析治療時間: " + (int.Parse(strNode) / 60).ToString("00時") + (int.Parse(strNode) % 60).ToString("00分") + "\r\n";
                    // -----------------------------------------------
                    // 診療フリー内容（見出し・透析開始時刻）
                    // -----------------------------------------------
                    // 透析実績履歴・透析開始日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析開始時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析開始時刻"))
                    {
                        return false;
                    }
                    strSetData = strSetData + "透析開始時刻:" + DateTime.Parse(strNode).ToString("HH時mm分") + "\r\n";
                    //strSetData = strSetData + "透析開始時刻:" + DateTime.Parse(strNode).ToString("yyyy年MM月dd日HH時mm分") + "\r\n";
                    // -----------------------------------------------
                    // 診療フリー内容（見出し・透析終了時刻）
                    // -----------------------------------------------
                    // 透析実績履歴・透析終了日時を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/END_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析終了時刻"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析終了時刻"))
                    {
                        return false;
                    }
                    strSetData = strSetData + "透析終了時刻:" + DateTime.Parse(strNode).ToString("HH時mm分") + "\r\n";
                    //strSetData = strSetData + "透析終了時刻:" + DateTime.Parse(strNode).ToString("yyyy年MM月dd日HH時mm分") + "\r\n";
                    // -----------------------------------------------
                    // 診療フリー内容（見出し・透析導入日）
                    // -----------------------------------------------
                    // 患者基本情報・透析導入日を取得 
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DIAL_START_DATE");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析導入日"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析導入日"))
                    {
                        // 値有り
                        strSetData = strSetData + "透析導入日:" + DateTime.ParseExact(strNode, INPUT_FROMAT_DAY,
                            System.Globalization.DateTimeFormatInfo.InvariantInfo, System.Globalization.DateTimeStyles.None).ToString("yyyy年MM月dd日") + "\r\n";

                    }
                    else
                    {
                        // 値無し（処理続行）
                        strSetData = strSetData + "透析導入日:未登録\r\n";
                    }
                    // -----------------------------------------------
                    // 診療フリー内容（見出し・透析困難）
                    // -----------------------------------------------
                    // 透析実績履歴・透析困難有無を取得 
                    // hasi-5.02加算対応（透析困難コメントの複数出力）Add Start
                    // システム設定（ID=134：レセプトメモ表示切替）の値が「1：レセプトメモ」の場合は「透析実績レセプトメモ履歴」からデータ取得
                    if (true == "1".Equals(this.m_strId0134))
                    {
                        // 透析困難コメント(レセプトメモ)取得
                        if (false == this.GetReceDiffComment(exeInfo, out strNode))
                        {
                            // エラーログは下位関数で出力済み
                            return false;
                        }
                        strSetData = strSetData + strNode;
                    }
                    // システム設定（ID=134：レセプトメモ表示切替）の値が「0：透析困難理由」の場合は「患者基本情報」からデータ取得
                    // hasi-5.02加算対応（透析困難コメントの複数出力）Add End
                    else
                    {
                        xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DIAL_DIFF");
                        // ノードチェック
                        if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析困難有無"))
                        {
                            return false;
                        }
                        strNode = xmlNode.InnerText;
                        // 値チェック
                        if (!this.CheckEmptyVal(strNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析困難有無"))
                        {
                            // 処理続行
                        }
                        if (strNode == "1")
                        {
                            // 透析困難・有り 
                            strSetData = strSetData + "透析困難:有り/";

                            // 透析実績履歴・マスタ透析困難コメント・透析困難コメントを取得 
                            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/MST_DIAL_DIFF_COMENT/DIAL_DIFF_COMMENT");
                            // ノードチェック
                            if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析困難コメント"))
                            {
                                return false;
                            }
                            strNode = xmlNode.InnerText;
                            // 値チェック
                            if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析困難コメント"))
                            {
                                return false;
                            }
                            strSetData = strSetData + strNode;
                        }
                        else
                        {
                            // ※DIAL_DIFF_COMMENTは設定されていない事があるので「1：透析困難有り 」以外は「透析困難無し」とする
                            // 透析困難・無し 
                            strSetData = strSetData + "透析困難:無し";
                        }
                    }
                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }

            return true;
        }

        /// <summary>
        /// 患者診断フリーデータ詳細を設定する。
        /// </summary>
        /// <param name="exeInfo">Fn3ExecuteInfoオブジェクト</param>
        /// <returns></returns>
        private bool SetExamFreeDataDetailNrt(Fn3ExecuteInfo exeInfo, out string strSetData)
        {
            string strNode = string.Empty;
            string strNode2 = string.Empty;
            strSetData = string.Empty;
            XmlNode xmlNode = null;

            switch (exeInfo.SendClass)
            {
                case EVENT_TYPE_ADD:   // 新規
                case EVENT_TYPE_CHG:   // 修正 

                    // -----------------------------------------------
                    // 診療フリー内容
                    // -----------------------------------------------
                    // 診療フリー内容を取得
                    xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/EXAM_FREE_DATA_DETAIL");
                    // ノードチェック
                    if (!this.CheckNullNode(xmlNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容"))
                    {
                        return false;
                    }
                    strNode = xmlNode.InnerText;
                    // 値チェック
                    if (!this.CheckEmptyVal(strNode, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容"))
                    {
                        return false;
                    }
                    strSetData = strNode + "\r\n";

                    break;
                case EVENT_TYPE_DEL:   // 削除 
                    strSetData = null;
                    break;
            }

            return true;
        }

        /// <summary>
        /// 連携情報より前回後体重を取得する
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        /// <param name="strNode">[out]前回後体重を返す</param>
        /// <returns>正常終了:true、異常終了:false</returns>
        private bool GetPreAfterWeight(Fn3ExecuteInfo exeInfo, out string strNode)
        {
            strNode = string.Empty;
            string strSeriesCd = string.Empty;
            string strDialysisNo = string.Empty;
            string strInXml;
            string strOutXml = string.Empty;
            XmlNode xmlNode = null;

            // 施設コードの取得
            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/SERIES_CD");
            // ノードチェック
            if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・施設コード"))
            {
                return false;
            }
            strSeriesCd = xmlNode.InnerText.Trim();

            // 値チェック
            if (!this.CheckEmptyVal(strSeriesCd, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・施設コード"))
            {
                return false;
            }

            // 透析番号の取得
            xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/DIALYSIS_NO");
            // ノードチェック
            if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析番号"))
            {
                return false;
            }
            strDialysisNo = xmlNode.InnerText.Trim();

            // 値チェック
            if (!this.CheckEmptyVal(strDialysisNo, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析番号"))
            {
                return false;
            }

            // 前回後体重の取得
            strInXml = string.Format("<rootNode><DIALYSIS_NO>{0}</DIALYSIS_NO><SERIES_CD>{1}</SERIES_CD></rootNode>", strDialysisNo, strSeriesCd);
            if (this.DBExecQuery("00003", strInXml, ref strOutXml).IsSuccess)
            {
                XmlDataDocument xmlDoc = new XmlDataDocument();
                xmlDoc.LoadXml(strOutXml);
                xmlNode = xmlDoc.LastChild.SelectSingleNode("./RST_DIALYSIS_WEIGHT/PRE_AFTER_WEIGHT");

                // ノードチェック
                if (!this.CheckNullNode(xmlNode, CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・前回後体重"))
                {
                    return false;
                }

                strNode = xmlNode.InnerText.Trim();
            }

            return true;
        }

        // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加

        // hasi-5.02加算対応（透析困難コメントの複数出力）Add Start
        /// <summary>
        /// 連携情報より透析実績レセプトメモ履歴(レセプトメモ区分が「0：透析困難理由」、加算有無が「1：加算あり」)の項目を取得する。
        /// ※取得順は以下。
        /// ①透析困難コメント（主たる透析困難）
        /// ②透析困難コメント（主たる透析困難以外）※レセプトメモコードの昇順（連携FW側で「①加算有無、②コード」の順でソート済み）
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        /// <param name="strNode">[out]透析困難コメントの項目名称リスト(該当データ無しの場合は「透析困難:無し」を返す)</param>
        /// <returns>正常終了:true、異常終了:false</returns>
        private bool GetReceDiffComment(Fn3ExecuteInfo exeInfo, out string strNode)
        {
            // 初期値設定
            strNode = string.Empty;

            // 透析困難コメント（主たる透析困難）格納
            XmlNodeList xmlRstReceiptMemoHstLst = exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_RECEIPT_MEMO_HST[DIVISION='0'][ADD_FLG='1'][MAIN_DIAL_DIFF='1']");
            // ノードチェック
            if (null == xmlRstReceiptMemoHstLst)
            {
                // エラーログ出力
                this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析困難コメント(主たる透析困難)：ノードが取得出来ません。");
                return false;
            }
            if (false == this.GetReceDiffCommentDetail(xmlRstReceiptMemoHstLst, ref strNode))
            {
                // エラーログは下位関数で出力済み
                return false;
            }

            // 透析困難コメント（主たる透析困難以外）格納
            xmlRstReceiptMemoHstLst = exeInfo.CoopInfoXML.SelectNodes("//rootNode/RST_RECEIPT_MEMO_HST[DIVISION='0'][ADD_FLG='1'][MAIN_DIAL_DIFF!='1']");
            // ノードチェック
            if (null == xmlRstReceiptMemoHstLst)
            {
                // エラーログ出力
                this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析困難コメント(主たる透析困難以外)：ノードが取得出来ません。");
                return false;
            }
            if (false == this.GetReceDiffCommentDetail(xmlRstReceiptMemoHstLst, ref strNode))
            {
                // エラーログは下位関数で出力済み
                return false;
            }

            // 透析困難コメントの項目名称リストチェック(該当データ無しの場合は「透析困難:無し」を返す)
            // 【Ver.5.0.8.100】2025.06.10 Thach 成田記念モードで透析困難なしの場合は、「透析困難：無し」を送らないようにする
            if (this.m_ExamFreeMode == "0")
            {
                if (true == string.IsNullOrEmpty(strNode)) strNode = "透析困難:無し";
            }

            return true;
        }

        /// <summary>
        /// 透析実績レセプトメモ履歴より、透析実績レセプトメモ履歴の項目名称を取得する。
        /// </summary>
        /// <param name="xmlRstReceiptMemoHstLst">透析実績レセプトメモ履歴(レセプトメモ区分が「0：透析困難理由」、加算有無が「1：加算あり」)</param>
        /// <param name="xmlOrders">[ref]透析困難コメントの項目名称リスト</param>
        /// <returns>正常終了:true、異常終了:false</returns>
        private bool GetReceDiffCommentDetail(XmlNodeList xmlRstReceiptMemoHstLst, ref string strNode)
        {
            // 透析困難コメント格納
            foreach (XmlNode xmlRstReceiptMemoHst in xmlRstReceiptMemoHstLst)
            {
                // 透析実績レセプトメモ履歴から項目名称取得
                string strName = Fn3ComTool.GetXmlValue(xmlRstReceiptMemoHst, "ITEM_NAME").Trim();
                // 値チェック
                if (false == this.CheckEmptyVal(strName, CSIReturnCode.ERR_DIALYSIS_SND_MAKEDATA_EXAMRREE, "オーダ・診療フリー内容・透析実績レセプトメモ履歴の項目名称"))
                {
                    // エラーログは下位関数で出力済み
                    return false;
                }
                else
                {
                    // 既にデータが存在する場合は改行コードを付与
                    if (false == string.IsNullOrEmpty(strNode)) strNode += "\r\n";
                    strNode += "透析困難:" + strName;
                }
            }

            return true;
        }
        // hasi-5.02加算対応（透析困難コメントの複数出力）Add End
        #endregion

        #endregion
    }
}
