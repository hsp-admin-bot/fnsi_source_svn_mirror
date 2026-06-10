///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：プラグイン機能
// ファイル名：Fn3CoopMediInfo.cs
// 説明      ：薬剤情報項目を取得します。
//             ※パナソニック処方薬剤連携から流用
//
//	Copyright(C) 2012-2015 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2012/01/16	會田正人			新規作成
//  2015/05/21  中村圭之介          Redmine#4666(オンライン治療の数量合算の不具合修正)
//
///////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.Xml;
using System.Collections;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
    #region enum定義
    /// <summary>
    /// セット薬剤情報源定義
    /// </summary>
    public enum MedicineClass
    {
        /// <summary>透析条件項目-抗凝固剤</summary>
        KouGyouko = 0,

        /// <summary>透析条件項目-透析液</summary>
        Tousekieki,

        /// <summary>透析条件項目-補液</summary>
        Hoeki,

        /// <summary>薬剤指示</summary>
        MedDirection,

        /// <summary>投与薬剤(実施)</summary>
        AdminMed,

        /// <summary>愁訴処置</summary>
        Treat
    }
    #endregion

    /// <summary>
    /// 薬剤情報項目取得クラス
    /// </summary>
    public class Fn3CoopMediInfo
    {
        #region メンバ

        private string m_strSetMedicineFlag = string.Empty;
        private string m_strMedicineCd = string.Empty;
        private string m_strMedicineName = string.Empty;
        private string m_strMediInHospitalCd = string.Empty;
        private string m_strMediInHospitalCd2 = string.Empty;
        private string m_strMedicineGroupCd = string.Empty;
        private string m_strMedicineGroupName = string.Empty;
        private string m_strProcedureCd = string.Empty;
        private string m_strProcedureName = string.Empty;
        private string m_strProcInHospitalCd1 = string.Empty;
        private string m_strProcInHospitalCd2 = string.Empty;
        private string m_strTimingCd = string.Empty;
        private string m_strTimeingName = string.Empty;
        private double m_dblAmount = 0;
        private string m_strUnit = string.Empty;
        private string m_strUpDate = string.Empty;
        private string m_strEffectDate = string.Empty;
        private string m_strPersonCd = string.Empty;
        private string m_strPersonName = string.Empty;

        #endregion

        #region プロパティ

        /// <summary>
        /// セット薬剤フラグ
        /// </summary>
        public string SetMedicineFlag
        {
            get { return m_strSetMedicineFlag; }
            internal set { m_strSetMedicineFlag = value; }
        }

        /// <summary>
        /// 薬剤コード
        /// </summary>
        public string MedicineCd
        {
            get { return m_strMedicineCd; }
            internal set { m_strMedicineCd = value; }
        }

        /// <summary>
        /// 薬剤名称
        /// </summary>
        public string MedicineName
        {
            get { return m_strMedicineName; }
            internal set { m_strMedicineName = value; }
        }

        /// <summary>
        /// 薬剤-院内コード
        /// </summary>
        public string MediInHospitalCd
        {
            get { return m_strMediInHospitalCd; }
            internal set { m_strMediInHospitalCd = value; }
        }

        /// <summary>
        /// 薬剤-院内コード2
        /// </summary>
        public string MediInHospitalCd2
        {
            get { return m_strMediInHospitalCd2; }
            internal set { m_strMediInHospitalCd2 = value; }
        }

        /// <summary>
        /// 薬剤分類コード
        /// </summary>
        public string MedicineGroupCd
        {
            get { return m_strMedicineGroupCd; }
            internal set { m_strMedicineGroupCd = value; }
        }

        /// <summary>
        /// 薬剤分類名称
        /// </summary>
        public string MedicineGroupName
        {
            get { return m_strMedicineGroupName; }
            internal set { m_strMedicineGroupName = value; }
        }

        /// <summary>
        /// 手技コード
        /// </summary>
        public string ProcedureCd
        {
            get { return m_strProcedureCd; }
            internal set { m_strProcedureCd = value; }
        }

        /// <summary>
        /// 手技名称
        /// </summary>
        public string ProcedureName
        {
            get { return m_strProcedureName; }
            internal set { m_strProcedureName = value; }
        }

        /// <summary>
        /// 手技-院内コード1
        /// </summary>
        public string ProcInHospitalCd1
        {
            get { return m_strProcInHospitalCd1; }
            internal set { m_strProcInHospitalCd1 = value; }
        }

        /// <summary>
        /// 手技-院内コード2
        /// </summary>
        public string ProcInHospitalCd2
        {
            get { return m_strProcInHospitalCd2; }
            internal set { m_strProcInHospitalCd2 = value; }
        }

        /// <summary>
        /// 投与時間帯コード
        /// </summary>
        public string TimingCd
        {
            get { return m_strTimingCd; }
            internal set { m_strTimingCd = value; }
        }

        /// <summary>
        /// 投与時間帯名称
        /// </summary>
        public string TimeingName
        {
            get { return m_strTimeingName; }
            internal set { m_strTimeingName = value; }
        }

        /// <summary>
        /// 数量
        /// </summary>
        public double Amount
        {
            get { return m_dblAmount; }
            internal set { m_dblAmount = value; }
        }

        /// <summary>
        /// 単位
        /// </summary>
        public string Unit
        {
            get { return m_strUnit; }
            internal set { m_strUnit = value; }
        }

        /// <summary>
        /// 更新日
        /// </summary>
        public string UpDate
        {
            get { return m_strUpDate; }
            internal set { m_strUpDate = value; }
        }

        /// <summary>
        /// 実施日
        /// </summary>
        public string EffectDate
        {
            get { return m_strEffectDate; }
            internal set { m_strEffectDate = value; }
        }

        /// <summary>
        /// 処置者コード
        /// </summary>
        public string PersonCd
        {
            get { return m_strPersonCd; }
            internal set { m_strPersonCd = value; }
        }

        /// <summary>
        /// 処置者名
        /// </summary>
        public string PersonName
        {
            get { return m_strPersonName; }
            internal set { m_strPersonName = value; }
        }

        #endregion

        #region パブリックメソッド

        #region 薬剤情報の取得
        /// <summary>
        /// 薬剤情報の取得
        /// </summary>
        /// <remarks>
        /// 透析実績投与薬剤、透析実績愁訴処置処置、透析実績透析条件から薬剤情報を取得する。<br/>
        /// セット薬剤の場合は、薬剤を分解し、薬剤単位にする。この際に数量の算出も行う。
        /// </remarks>
        /// <param name="mediclass">分解するセット薬剤の情報源</param>
        /// <param name="xmlCoopInfo">分解するセット薬剤情報（ExeInfo.CoopInfoXmlの内容）</param>
        /// <param name="lstMediInfo">分解した薬剤のリスト情報(処理失敗時はNULLを返す)</param>
        /// <param name="iSetMediFlg">セット薬剤参照フラグ<br/>
        /// (0：セット薬剤を分解する<br/>
        /// 1：セット薬剤のまま<br/>
        /// 2：セット薬剤の院内コードありの場合-セット薬剤のまま、セット薬剤の院内コードなしの場合-セット薬剤の分解)</param>
        /// <param name="iInHospitalCode">使用院内コード</param>
        /// <returns>Fn3ReturnCode</returns>
        public static Fn3ReturnCode GetMedicineInfo(
            MedicineClass mediclass, XmlNode xmlCoopInfo, out List<Fn3CoopMediInfo> lstMediInfo, int iSetMediFlg, int iInHospitalCode)
        {
            Fn3ReturnCode retCode = Fn3ReturnCode.Error;
            lstMediInfo = null;

            try
            {
                // パラメータチェック
                if (xmlCoopInfo == null)
                {
                    return retCode;
                }

                // 薬剤情報取得区分による処理分岐
                switch (mediclass)
                {
                    case MedicineClass.KouGyouko:
                    case MedicineClass.Tousekieki:
                    case MedicineClass.Hoeki:
                        {
                            #region "透析条件項目"
                            switch (mediclass)
                            {
                                case MedicineClass.KouGyouko:
                                    {
                                        // 抗凝固剤をセットする
                                        lstMediInfo = GetMedKouGyoukoInfo(xmlCoopInfo, iSetMediFlg, iInHospitalCode);
                                        break;
                                    }
                                case MedicineClass.Tousekieki:
                                    {
                                        // 透析液をセットする
                                        lstMediInfo = GetMedTousekiekiInfo(xmlCoopInfo, iSetMediFlg, iInHospitalCode);
                                        break;
                                    }
                                case MedicineClass.Hoeki:
                                    {
                                        // 補液をセットする
                                        lstMediInfo = GetMedHoekiInfo(xmlCoopInfo, iSetMediFlg, iInHospitalCode);
                                        break;
                                    }
                            }

                            retCode = Fn3ReturnCode.Success;
                            break;

                            #endregion
                        }
                    case MedicineClass.MedDirection:
                        {
                            #region "薬剤指示"

                            lstMediInfo = new List<Fn3CoopMediInfo>();
                            XmlNodeList xmlDialMedList = xmlCoopInfo.SelectNodes("rootNode/IND_DIALYSIS_MEDI");

                            foreach (XmlNode xmlDialMed in xmlDialMedList)
                            {
                                XmlNode xmlSetMedicineFlg = xmlDialMed.SelectSingleNode("SET_MEDICINE_FLG");
                                if (xmlSetMedicineFlg == null || xmlSetMedicineFlg.InnerText.Trim().Equals(""))
                                {
                                    continue;
                                }

                                //	手技取得
                                XmlNode xmlMstProcedureName = xmlDialMed.SelectSingleNode("MST_PROCEDURE");

                                //	更新日時取得
                                string strUpdate = "";
                                XmlNode xmlValue = xmlDialMed.SelectSingleNode("UP_DATE");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strUpdate = xmlValue.InnerText;
                                }

                                // 投与時間帯コード
                                string strTimingCd = "";
                                xmlValue = xmlDialMed.SelectSingleNode("TIMING_CD");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strTimingCd = xmlValue.InnerText;
                                }

                                // 投与時間名
                                string strTimingName = "";
                                xmlValue = xmlDialMed.SelectSingleNode("TIMING_NAME");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strTimingName = xmlValue.InnerText;
                                }

                                // 設定値
                                string strValue = "";
                                xmlValue = xmlDialMed.SelectSingleNode("VALUE");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strValue = xmlValue.InnerText;
                                }
                                else
                                {
                                    strValue = "0";
                                }

                                // 薬剤情報
                                if (xmlSetMedicineFlg.InnerText.Trim().Equals("0"))
                                {
                                    // ***********************
                                    //	通常薬剤
                                    // ***********************
                                    XmlNode xmlMstMedicine = xmlDialMed.SelectSingleNode("MST_MEDICINE");
                                    if (xmlMstMedicine == null)
                                    {
                                        lstMediInfo = null;
                                        return Fn3ReturnCode.Error;
                                    }

                                    Fn3CoopMediInfo info = GetMedicine(xmlMstMedicine, strValue, xmlMstProcedureName, strTimingCd,
                                        strTimingName, "", strUpdate, "", "");
                                    if (info != null) lstMediInfo.Add(info);
                                }
                                else if (xmlSetMedicineFlg.InnerText.Trim().Equals("1"))
                                {
                                    // ***********************
                                    //	セット薬剤
                                    // ***********************
                                    // セット薬剤分解フラグ(true:分解する、:分解しない)
                                    bool isDisassemblyflg;

                                    // セット薬剤分解フラグ取得
                                    retCode = GetDisassemblyflg(out isDisassemblyflg, iSetMediFlg, iInHospitalCode, xmlDialMed);

                                    if (retCode != Fn3ReturnCode.Success)
                                    {
                                        lstMediInfo = null;
                                        return Fn3ReturnCode.Error;
                                    }

                                    double dbValue;
                                    if (false == double.TryParse(strValue, out dbValue))
                                    {
                                        dbValue = 0.0;
                                    }

                                    if (isDisassemblyflg == true)
                                    {
                                        // -----セット薬剤を分解する場合----- //
                                        if (null == xmlDialMed.SelectSingleNode("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            lstMediInfo = null;
                                            return Fn3ReturnCode.Error;
                                        }
                                        XmlNodeList xmlMediList = xmlDialMed.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE");

                                        // 薬剤数分、セットする
                                        foreach (XmlNode item in xmlMediList)
                                        {
                                            // 薬剤マスタの取得
                                            XmlNode xmlMstMedicine = item.SelectSingleNode("MST_MEDICINE");
                                            if (xmlMstMedicine == null)
                                            {
                                                lstMediInfo = null;
                                                return Fn3ReturnCode.Error;
                                            }

                                            // 使用薬剤数の取得
                                            double dbUseNum;
                                            xmlValue = item.SelectSingleNode("MEDI_USE_NUM");
                                            if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                            {
                                                if (false == double.TryParse(xmlValue.InnerText.Trim(), out dbUseNum))
                                                {
                                                    dbUseNum = 0.0;
                                                }
                                            }
                                            else
                                            {
                                                dbUseNum = 0.0;
                                            }

                                            // 数量＝薬剤数量 * 使用薬剤数
                                            string strAmount = (dbValue * dbUseNum).ToString();

                                            Fn3CoopMediInfo info = GetMedicine(xmlMstMedicine, strAmount, xmlMstProcedureName,
                                                strTimingCd, strTimingName, "", strUpdate, "", "");

                                            if (info != null)
                                                lstMediInfo.Add(info);
                                        }
                                    }
                                    else
                                    {
                                        // -----セット薬剤のままの場合----- //
                                        XmlNode xmlSetMediName = xmlDialMed.SelectSingleNode("MST_SET_MEDI_NAME");
                                        if (xmlSetMediName == null)
                                        {
                                            lstMediInfo = null;
                                            return Fn3ReturnCode.Error;
                                        }

                                        Fn3CoopMediInfo info = GetSetMedicine(xmlSetMediName, dbValue.ToString(), xmlMstProcedureName,
                                            strTimingCd, strTimingName, "", strUpdate, "", "");

                                        if (info != null) lstMediInfo.Add(info);
                                    }
                                }
                            }

                            retCode = Fn3ReturnCode.Success;
                            break;

                            #endregion
                        }
                    case MedicineClass.AdminMed:
                        {
                            #region "投与薬剤"

                            lstMediInfo = new List<Fn3CoopMediInfo>();
                            XmlNodeList xmlDialMedList = xmlCoopInfo.SelectNodes("//rootNode/RST_DIALYSIS_MEDICATION_HST[EFFECT_FLG='1']");
                           
                            foreach (XmlNode xmlDialMed in xmlDialMedList)
                            {
                                XmlNode xmlSetMedicineFlg = xmlDialMed.SelectSingleNode("SET_MEDICINE_FLG");
                                if (xmlSetMedicineFlg == null || xmlSetMedicineFlg.InnerText.Trim().Equals(""))
                                {
                                    continue;
                                }

                                //	手技取得
                                XmlNode xmlMstProcedureName = xmlDialMed.SelectSingleNode("MST_PROCEDURE");

                                //	実施日時取得
                                string strEffectDate = "";
                                XmlNode xmlEffectDate = xmlDialMed.SelectSingleNode("EFFECT_DATE");
                                if (null != xmlEffectDate && false == xmlEffectDate.InnerText.Equals(""))
                                {
                                    strEffectDate = xmlEffectDate.InnerText;
                                }

                                //	更新日時取得
                                string strUpdate = "";
                                XmlNode xmlValue = xmlDialMed.SelectSingleNode("UP_DATE");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strUpdate = xmlValue.InnerText;
                                }

                                // 投与時間帯コード
                                string strTimingCd = "";
                                xmlValue = xmlDialMed.SelectSingleNode("TIMING_CD");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strTimingCd = xmlValue.InnerText;
                                }

                                // 投与時間名
                                string strTimingName = "";
                                xmlValue = xmlDialMed.SelectSingleNode("TIMING_NAME");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strTimingName = xmlValue.InnerText;
                                }

                                //	処置者CD
                                string strStaffCode = "";
                                xmlValue = xmlDialMed.SelectSingleNode("STAFF_CD");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strStaffCode = xmlValue.InnerText;
                                }

                                //	処置者名
                                string strStaffName = "";
                                xmlValue = xmlDialMed.SelectSingleNode("STAFF_NAME");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strStaffName = xmlValue.InnerText;
                                }

                                // 設定値
                                string strValue = "";
                                xmlValue = xmlDialMed.SelectSingleNode("AMOUNT");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strValue = xmlValue.InnerText;
                                }
                                else
                                {
                                    strValue = "0";
                                }

                                // 薬剤情報
                                if (xmlSetMedicineFlg.InnerText.Trim().Equals("0"))
                                {
                                    // ***********************
                                    //	通常薬剤
                                    // ***********************
                                    XmlNode xmlMstMedicine = xmlDialMed.SelectSingleNode("MST_MEDICINE");
                                    if (xmlMstMedicine == null)
                                    {
                                        lstMediInfo = null;
                                        return Fn3ReturnCode.Error;
                                    }

                                    Fn3CoopMediInfo info = GetMedicine(xmlMstMedicine, strValue, xmlMstProcedureName, strTimingCd, 
                                        strTimingName, strEffectDate, strUpdate, strStaffCode, strStaffName);
                                    if (info != null) lstMediInfo.Add(info);
                                }
                                else if (xmlSetMedicineFlg.InnerText.Trim().Equals("1"))
                                {
                                    // ***********************
                                    //	セット薬剤
                                    // ***********************

                                    // セット薬剤分解フラグ(true:分解する、:分解しない)
                                    bool isDisassemblyflg;

                                    // セット薬剤分解フラグ取得
                                    retCode = GetDisassemblyflg(out isDisassemblyflg, iSetMediFlg, iInHospitalCode, xmlDialMed);

                                    if (retCode != Fn3ReturnCode.Success)
                                    {
                                        lstMediInfo = null;
                                        return Fn3ReturnCode.Error;
                                    }

                                    double dbValue;
                                    if (false == double.TryParse(strValue, out dbValue))
                                    {
                                        dbValue = 0.0;
                                    }

                                    if (isDisassemblyflg == true)
                                    {
                                        // -----セット薬剤を分解する場合----- //
                                        if (null == xmlDialMed.SelectSingleNode("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            lstMediInfo = null;
                                            return Fn3ReturnCode.Error;
                                        }
                                        XmlNodeList xmlMediList = xmlDialMed.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE");

                                        // 薬剤数分、セットする
                                        foreach (XmlNode item in xmlMediList)
                                        {
                                            // 薬剤マスタの取得
                                            XmlNode xmlMstMedicine = item.SelectSingleNode("MST_MEDICINE");
                                            if (xmlMstMedicine == null)
                                            {
                                                lstMediInfo = null;
                                                return Fn3ReturnCode.Error;
                                            }

                                            // 使用薬剤数の取得
                                            double dbUseNum;
                                            xmlValue = item.SelectSingleNode("MEDI_USE_NUM");
                                            if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                            {
                                                if (false == double.TryParse(xmlValue.InnerText.Trim(), out dbUseNum))
                                                {
                                                    dbUseNum = 0.0;
                                                }
                                            }
                                            else
                                            {
                                                dbUseNum = 0.0;
                                            }

                                            // 数量＝薬剤数量 * 使用薬剤数
                                            string strAmount = (dbValue * dbUseNum).ToString();

                                            Fn3CoopMediInfo info = GetMedicine(xmlMstMedicine, strAmount, xmlMstProcedureName,
                                                strTimingCd, strTimingName, strEffectDate, strUpdate, strStaffCode, strStaffName);
                                            if (info != null) lstMediInfo.Add(info);
                                        }
                                    }
                                    else
                                    {
                                        // -----セット薬剤のままの場合----- //
                                        XmlNode xmlSetMediName = xmlDialMed.SelectSingleNode("MST_SET_MEDI_NAME");
                                        if (xmlSetMediName == null)
                                        {
                                            lstMediInfo = null;
                                            return Fn3ReturnCode.Error;
                                        }

                                        Fn3CoopMediInfo info = GetSetMedicine(xmlSetMediName, dbValue.ToString(), xmlMstProcedureName,
                                            strTimingCd, strTimingName, strEffectDate, strUpdate, strStaffCode, strStaffName);
                                        if (info != null) lstMediInfo.Add(info);
                                    }
                                }
                            }

                            retCode = Fn3ReturnCode.Success;
                            break;

                            #endregion
                        }
                    case MedicineClass.Treat:
                        {
                            #region "愁訴処置"

                            lstMediInfo = new List<Fn3CoopMediInfo>();
                            XmlNodeList xmlDialTreatList = xmlCoopInfo.SelectNodes("rootNode/RST_DIALYSIS_TREATMENT_HST");

                            foreach (XmlNode xmlDialTreat in xmlDialTreatList)
                            {
                                // 透析番号の取得
                                XmlNode xmlDialysisNo = xmlDialTreat.SelectSingleNode("DIALYSIS_NO");
                                if (xmlDialysisNo == null)
                                {
                                    //	透析番号が取得できない場合は空タグと判断
                                    continue;
                                }

                                //	実施日時取得
                                string strEffectDate = "";
                                XmlNode xmlEffectDate = xmlDialTreat.SelectSingleNode("OCCUR_DATE");
                                if (null != xmlEffectDate && false == xmlEffectDate.InnerText.Equals(""))
                                {
                                    strEffectDate = xmlEffectDate.InnerText;
                                }

                                // 版数の取得
                                XmlNode xmlEdition = xmlDialTreat.SelectSingleNode("EDITION");
                                if (xmlEdition == null)
                                {
                                    //	版数のが取得できない場合は空タグと判断
                                    continue;
                                }

                                // 実績番号
                                XmlNode xmlResult = xmlDialTreat.SelectSingleNode("RESULT_NO");
                                if (xmlResult == null)
                                {
                                    //	実績番号が取得できない場合は空タグと判断
                                    continue;
                                }

                                // 処置区分
                                XmlNode xmlTreatClass = xmlDialTreat.SelectSingleNode("TREAT_CLASS");
                                if (xmlTreatClass == null || xmlTreatClass.InnerText.Trim().Equals(""))
                                {
                                    continue;
                                }

                                //	手技取得
                                XmlNode xmlMstProcedureName = xmlDialTreat.SelectSingleNode("MST_PROCEDURE");

                                //	更新日時取得
                                string strUpdate = "";
                                XmlNode xmlValue = xmlDialTreat.SelectSingleNode("UP_DATE");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strUpdate = xmlValue.InnerText;
                                }

                                // 処置者情報を取得
                                string strStaffCode = "";
                                string strStaffName = "";

                                string strWhere = string.Format("rootNode/RST_DIALYSIS_TREAT_PERSON_HST[DIALYSIS_NO='{0}'][EDITION='{1}'][RESULT_NO='{2}']",
                                                                  xmlDialysisNo.InnerText.Trim(), xmlEdition.InnerText.Trim(), xmlResult.InnerText.Trim());

                                XmlNode xmlPerson = xmlCoopInfo.SelectSingleNode(strWhere);
                                if (null != xmlPerson)
                                {
                                    //	処置者CD
                                    xmlValue = xmlPerson.SelectSingleNode("TREAT_PERSON_CD");
                                    if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                    {
                                        strStaffCode = xmlValue.InnerText;
                                    }

                                    //	処置者名
                                    xmlValue = xmlPerson.SelectSingleNode("TREAT_PERSON_NAME");
                                    if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                    {
                                        strStaffName = xmlValue.InnerText;
                                    }
                                }

                                // 設定値
                                string strValue = "";
                                xmlValue = xmlDialTreat.SelectSingleNode("AMOUNT");
                                if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                {
                                    strValue = xmlValue.InnerText;
                                }
                                else
                                {
                                    strValue = "0";
                                }

                                // 薬剤情報
                                if (xmlTreatClass.InnerText.Trim().Equals("1"))
                                {
                                    // ***********************
                                    //	通常薬剤
                                    // ***********************
                                    XmlNode xmlMstMedicine = xmlDialTreat.SelectSingleNode("MST_MEDICINE");
                                    if (xmlMstMedicine == null)
                                    {
                                        lstMediInfo = null;
                                        return Fn3ReturnCode.Error;
                                    }

                                    Fn3CoopMediInfo info = GetMedicine(xmlMstMedicine, strValue, xmlMstProcedureName,
                                        "", "", strEffectDate, strUpdate, strStaffCode, strStaffName);
                                    if (info != null) lstMediInfo.Add(info);
                                }
                                else if (xmlTreatClass.InnerText.Trim().Equals("0"))
                                {
                                    // ***********************
                                    //	セット薬剤
                                    // ***********************

                                    // セット薬剤分解フラグ(true:分解する、:分解しない)
                                    bool isDisassemblyflg;

                                    // セット薬剤分解フラグ取得
                                    retCode = GetDisassemblyflg(out isDisassemblyflg, iSetMediFlg, iInHospitalCode, xmlDialTreat);

                                    if (retCode != Fn3ReturnCode.Success)
                                    {
                                        lstMediInfo = null;
                                        return Fn3ReturnCode.Error;
                                    }

                                    double dbValue;
                                    if (false == double.TryParse(strValue, out dbValue))
                                    {
                                        dbValue = 0.0;
                                    }

                                    if (isDisassemblyflg == true)
                                    {
                                        // -----セット薬剤を分解する場合----- //
                                        if (null == xmlDialTreat.SelectSingleNode("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                                        {
                                            lstMediInfo = null;
                                            return Fn3ReturnCode.Error;
                                        }
                                        XmlNodeList xmlMediList = xmlDialTreat.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE");

                                        // 薬剤数分、セットする
                                        foreach (XmlNode item in xmlMediList)
                                        {
                                            // 薬剤マスタの取得
                                            XmlNode xmlMstMedicine = item.SelectSingleNode("MST_MEDICINE");
                                            if (xmlMstMedicine == null)
                                            {
                                                lstMediInfo = null;
                                                return Fn3ReturnCode.Error;
                                            }

                                            // 使用薬剤数の取得
                                            double dbUseNum;
                                            xmlValue = item.SelectSingleNode("MEDI_USE_NUM");
                                            if (null != xmlValue && false == xmlValue.InnerText.Equals(""))
                                            {
                                                if (false == double.TryParse(xmlValue.InnerText.Trim(), out dbUseNum))
                                                {
                                                    dbUseNum = 0.0;
                                                }
                                            }
                                            else
                                            {
                                                dbUseNum = 0.0;
                                            }

                                            // 数量＝薬剤数量 * 使用薬剤数
                                            string strAmount = (dbValue * dbUseNum).ToString();

                                            Fn3CoopMediInfo info = GetMedicine(xmlMstMedicine, strAmount, xmlMstProcedureName,
                                                "", "", strEffectDate, strUpdate, strStaffCode, strStaffName);
                                            if (info != null) lstMediInfo.Add(info);
                                        }
                                    }
                                    else
                                    {
                                        // -----セット薬剤のままの場合----- //
                                        XmlNode xmlSetMediName = xmlDialTreat.SelectSingleNode("MST_SET_MEDI_NAME");
                                        if (xmlSetMediName == null)
                                        {
                                            lstMediInfo = null;
                                            return Fn3ReturnCode.Error;
                                        }

                                        Fn3CoopMediInfo info = GetSetMedicine(xmlSetMediName, dbValue.ToString(), xmlMstProcedureName,
                                            "", "", strEffectDate, strUpdate, strStaffCode, strStaffName);
                                        if (info != null) lstMediInfo.Add(info);
                                    }
                                }
                            }

                            retCode = Fn3ReturnCode.Success;
                            break;

                            #endregion
                        }
                }

                if (lstMediInfo == null)
                {
                    // リストが作成できなかった場合はエラー
                    retCode = Fn3ReturnCode.Error;
                }
            }
            catch (Exception)
            {
                retCode = Fn3ReturnCode.Exception;
                lstMediInfo = null;
            }

            return retCode;
        }
        #endregion

        #endregion

        #region プライベートメソッド

        #region 抗凝固剤情報を取得する

        /// <summary>
        /// 抗凝固剤情報を取得する
        /// </summary>
        /// <param name="xmlCoopInfo"></param>
        /// <param name="iInHospitalCode"></param>
        /// <param name="iSetMediiFlg"></param>
        /// <returns></returns>
        private static List<Fn3CoopMediInfo> GetMedKouGyoukoInfo(XmlNode xmlCoopInfo, int iSetMediiFlg, int iInHospitalCode)
        {
            List<Fn3CoopMediInfo> lstMedInfo = new List<Fn3CoopMediInfo>();

            // ====================================
            // 指示又は透析実績から抗凝固剤の透析条件を取得する
            // ====================================
            XmlNode xmlDialysisCond = null;
            string strSelectTable = "";

            if (xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='011']") != null)
            {
                xmlDialysisCond = xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='011']");
                strSelectTable = "IND_DIALYSIS_COND";
            }
            else if (xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='011']") != null)
            {
                xmlDialysisCond = xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='011']");
                strSelectTable = "RST_DIALYSIS_COND_HST";
            }
            else
            {
                // 抗凝固剤が設定されていない (0件)
                return lstMedInfo;
            }

            // ====================================
            //	更新日時取得
            // ====================================
            string strUpdate = "";
            XmlNode xmlUpdate = xmlDialysisCond.SelectSingleNode("UP_DATE");
            if (null != xmlUpdate && false == xmlUpdate.InnerText.Equals(""))
            {
                strUpdate = xmlUpdate.InnerText;
            }

            // ====================================
            // 設定値を取得する
            // ====================================
            XmlNode xmlValue = xmlDialysisCond.SelectSingleNode("VALUE");

            if (xmlValue == null || string.IsNullOrEmpty(xmlValue.InnerText.Trim()))
            {
                // 抗凝固剤が設定されていない (0件)
                return lstMedInfo;
            }

            // セット薬剤か、通常薬剤かをチェックする
            if (xmlValue.InnerText[0] == '0')
            {
                // ****************************
                //  通常薬剤の場合
                // ****************************
                // ワンショット量を取得
                double dbOneShot = 0.0;
                XmlNode xmlOneShot = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='012']/VALUE", strSelectTable));
                if (xmlOneShot != null && false == xmlOneShot.InnerText.Trim().Equals(""))
                {
                    // 文字列を数値に変換する
                    if (false == double.TryParse(xmlOneShot.InnerText.Trim(), out dbOneShot))
                    {
                        dbOneShot = 0.0;
                    }
                }

                // 持続総量を取得
                double dbTotal = 0.0;
                XmlNode xmlTotal = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='014']/VALUE", strSelectTable));
                if (xmlTotal != null && false == xmlTotal.InnerText.Trim().Equals(""))
                {
                    // 文字列を数値に変換する
                    if (false == double.TryParse(xmlTotal.InnerText.Trim(), out dbTotal))
                    {
                        dbTotal = 0.0;
                    }
                }

                XmlNode xmlMstMedicine = xmlDialysisCond.SelectSingleNode("MST_MEDICINE");
                if (xmlMstMedicine == null)
                {
                    return null;
                }
                //  数量算出
                string strAmount = (dbOneShot + dbTotal).ToString();

                //	薬剤情報をリストに追加
                Fn3CoopMediInfo mediInfo = GetMedicine(xmlMstMedicine, strAmount, strUpdate);

                if (mediInfo != null)
                    lstMedInfo.Add(mediInfo);
            }
            else if (xmlValue.InnerText[0] == '1')
            {
                // ****************************
                //  セット薬剤の場合
                // ****************************

                // セット薬剤分解フラグ(true:分解する、false:分解しない)
                bool isDisassemblyflg;

                // セット薬剤分解フラグ取得
                Fn3ReturnCode retCode = GetDisassemblyflg(out isDisassemblyflg, iSetMediiFlg, iInHospitalCode, xmlDialysisCond);

                if (retCode != Fn3ReturnCode.Success)
                {
                    return null;
                }

                if (isDisassemblyflg == true)
                {
                    // -----セット薬剤を分解する場合----- //
                    if (null == xmlDialysisCond.SelectSingleNode("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                    {
                        return null;
                    }
                    XmlNodeList xmlMediList = xmlDialysisCond.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE");

                    foreach (XmlNode item in xmlMediList)
                    {
                        string strAmount = "";
                        // 数量を取得する
                        XmlNode xmlUseMedi = item.SelectSingleNode("MEDI_USE_NUM");

                        if (xmlUseMedi == null || xmlUseMedi.InnerText.Trim().Equals(""))
                        {
                            strAmount = "0";
                        }
                        else
                        {
                            strAmount = xmlUseMedi.InnerText.Trim();
                        }

                        // 薬剤マスタを取得する
                        XmlNode xmlMstMedicine = item.SelectSingleNode("MST_MEDICINE");

                        if (xmlMstMedicine == null)
                        {
                            return null;
                        }

                        //	薬剤情報をリストに追加
                        Fn3CoopMediInfo mediInfo = GetMedicine(xmlMstMedicine, strAmount, strUpdate);
                        if (mediInfo != null)
                            lstMedInfo.Add(mediInfo);
                    }
                }
                else
                {
                    // -----セット薬剤のままの場合----- //
                    XmlNode xmlSetMediName = xmlDialysisCond.SelectSingleNode("MST_SET_MEDI_NAME");

                    if (xmlSetMediName == null)
                    {
                        return null;
                    }

                    // ワンショット量を取得
                    double dbOneShot = 0.0;
                    XmlNode xmlOneShot = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='012']/VALUE", strSelectTable));
                    if (xmlOneShot != null && false == xmlOneShot.InnerText.Trim().Equals(""))
                    {
                        // 文字列を数値に変換する
                        if (false == double.TryParse(xmlOneShot.InnerText.Trim(), out dbOneShot))
                        {
                            dbOneShot = 0.0;
                        }
                    }

                    // 持続総量を取得
                    double dbTotal = 0.0;
                    XmlNode xmlTotal = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='014']/VALUE", strSelectTable));
                    if (xmlTotal != null && false == xmlTotal.InnerText.Trim().Equals(""))
                    {
                        // 文字列を数値に変換する
                        if (false == double.TryParse(xmlTotal.InnerText.Trim(), out dbTotal))
                        {
                            dbTotal = 0.0;
                        }
                    }
                    //  数量算出
                    string strAmount = (dbOneShot + dbTotal).ToString();

                    //	薬剤情報をリストに追加
                    Fn3CoopMediInfo mediInfo = GetSetMedicine(xmlSetMediName, strAmount, strUpdate);

                    if (mediInfo != null)
                        lstMedInfo.Add(mediInfo);
                }

            }

            return lstMedInfo;
        }
        #endregion

        #region 透析液情報を取得する

        /// <summary>
        /// 透析液情報を取得する
        /// </summary>
        /// <param name="xmlCoopInfo"></param>
        /// <param name="iInHospitalCode"></param>
        /// <param name="iSetMediiFlg"></param>
        private static List<Fn3CoopMediInfo> GetMedTousekiekiInfo(XmlNode xmlCoopInfo, int iSetMediiFlg, int iInHospitalCode)
        {
            List<Fn3CoopMediInfo> lstMedInfo = new List<Fn3CoopMediInfo>();

            // ====================================
            // 指示又は透析実績から透析液の透析条件を取得する
            // ====================================
            XmlNode xmlDialysisCond = null;
            string strSelectTable = "";

            if (xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='018']") != null)
            {
                xmlDialysisCond = xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='018']");
                strSelectTable = "IND_DIALYSIS_COND";
            }
            else if (xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='018']") != null)
            {
                xmlDialysisCond = xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='018']");
                strSelectTable = "RST_DIALYSIS_COND_HST";
            }
            else
            {
                // 透析液が設定されていない (0件)
                return lstMedInfo;
            }

            // ====================================
            //	更新日時取得
            // ====================================
            string strUpdate = "";
            XmlNode xmlUpdate = xmlDialysisCond.SelectSingleNode("UP_DATE");
            if (null != xmlUpdate && false == xmlUpdate.InnerText.Equals(""))
            {
                strUpdate = xmlUpdate.InnerText;
            }

            // ====================================
            // 設定値を取得する
            // ====================================
            XmlNode xmlValue = xmlDialysisCond.SelectSingleNode("VALUE");

            if (null == xmlValue || xmlValue.InnerText.Trim().Equals(""))
            {
                // 透析液が設定されていない (0件)
                return lstMedInfo;
            }

            #region オンライン補液取得
            // オンライン透析の場合は、補液情報を取得する
            double dbHoeki = 0.0;

            // 2015/05/21 中村 Redmine#4666(オンライン治療の数量合算）
            Hashtable htHoeki = new Hashtable();

            if (CheckOnlineDialysis(xmlCoopInfo))
            {
                XmlNode xmlHoeki = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='022']", strSelectTable));
                if (null != xmlHoeki)
                {
                    XmlNode xmlHoekiValue = xmlHoeki.SelectSingleNode("VALUE");
                    if (null != xmlHoekiValue && false == xmlHoekiValue.InnerText.Trim().Equals(""))
                    {
                        // 補液使用数を取得
                        double dbValue = 0.0;
                        XmlNode xmlVal = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='030']/VALUE", strSelectTable));
                        if (null != xmlVal && false == xmlVal.InnerText.Trim().Equals(""))
                        {
                            // 文字列を数値に変換する
                            if (false == double.TryParse(xmlVal.InnerText.Trim(), out dbValue))
                            {
                                dbValue = 0.0;
                            }
                        }

                        // セット薬剤か否かを確認する
                        if ('0' == xmlHoekiValue.InnerText[0])
                        {
                            // ****************************
                            //  通常薬剤の場合
                            // ****************************
                            // 補液使用数を設定する
                            dbHoeki = dbValue;
                        }
                        else if ('1' == xmlHoekiValue.InnerText[0])
                        {
                            // ****************************
                            //  セット薬剤の場合
                            // ****************************

                            // セット薬剤分解フラグ(true:分解する、false:分解しない)
                            bool isDisassemblyflg;

                            // セット薬剤分解フラグ取得
                            Fn3ReturnCode retCode = GetDisassemblyflg(out isDisassemblyflg, iSetMediiFlg, iInHospitalCode, xmlDialysisCond);

                            if (retCode != Fn3ReturnCode.Success)
                            {
                                return null;
                            }

                            if (isDisassemblyflg == true)
                            {
                                // -----セット薬剤を分解する場合----- //
                                XmlNodeList xmlMediList = xmlDialysisCond.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE");

                                if (xmlMediList == null)
                                {
                                    dbHoeki = 0.0;
                                }

                                foreach (XmlNode item in xmlMediList)
                                {
                                    // 薬剤分類が透析液のレコードを取得する
                                    XmlNode xmlMstMedicine = item.SelectSingleNode("MST_MEDICINE[MEDICINE_GROUP_CD='302']");

                                    if (null == xmlMstMedicine)
                                    {
                                        continue;
                                    }

                                    // 使用薬剤数を取得する
                                    double dbUseNum = 0.0;
                                    XmlNode xmlUseMedi = item.SelectSingleNode("MEDI_USE_NUM");
                                    if (null != xmlUseMedi && false == xmlUseMedi.InnerText.Trim().Equals(""))
                                    {
                                        if (false == double.TryParse(xmlUseMedi.InnerText.Trim(), out dbUseNum))
                                        {
                                            dbUseNum = 0.0;
                                        }
                                    }

                                    // 補液量 = 補液使用数 * 薬剤使用数
                                    // 2015/05/21 中村 Redmine#4666(オンライン治療の数量合算） Chg Start
                                    // dbHoeki += dbValue * dbUseNum;
                                    XmlNode xmlMedicineCd = item.SelectSingleNode("MEDICINE_CD");
                                    if (null != xmlMedicineCd && !string.IsNullOrEmpty(xmlMedicineCd.InnerText.Trim()))
                                    {
                                        if (htHoeki.ContainsKey(xmlMedicineCd.InnerText.Trim()))
                                        {
                                            // ハッシュテーブルに薬剤コードが一致するものがある場合、
                                            // 値を更新
                                            htHoeki[xmlMedicineCd.InnerText.Trim()] =
                                                (double)htHoeki[xmlMedicineCd.InnerText.Trim()] + (dbValue * dbUseNum);
                                        }
                                        else
                                        {
                                            // ハッシュテーブルに薬剤コードが一致するものがない場合、
                                            // 新規に追加
                                            htHoeki.Add(xmlMedicineCd.InnerText.Trim(), (dbValue * dbUseNum));
                                        }
                                    }
                                    // 2015/05/21 中村 Redmine#4666(オンライン治療の数量合算） Chg End
                                }
                            }
                            else
                            {
                                // -----セット薬剤のままの場合----- //
                                // 補液使用数を設定する
                                dbHoeki = dbValue;
                            }
                        }
                    }
                }
            }
            #endregion

            // 透析液量を取得
            double dbDialysis = 0.0;
            XmlNode xmlDialysis = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='020']/VALUE", strSelectTable));
            if (null != xmlDialysis && false == xmlDialysis.InnerText.Trim().Equals(""))
            {
                // 文字列を数値に変換する
                if (false == double.TryParse(xmlDialysis.InnerText.Trim(), out dbDialysis))
                {
                    dbDialysis = 0.0;
                }
            }

            // セット薬剤か、通常薬剤かをチェックする
            if (xmlValue.InnerText[0] == '0')
            {
                // ****************************
                //  通常薬剤の場合
                // ****************************

                XmlNode xmlMstMedicine = xmlDialysisCond.SelectSingleNode("MST_MEDICINE");

                if (null == xmlMstMedicine)
                {
                    return null;
                }

                //  数量算出　透析液量＋補液使用数
                string strAmount = (dbDialysis + dbHoeki).ToString();

                //	薬剤情報をリストに追加
                Fn3CoopMediInfo mediInfo = GetMedicine(xmlMstMedicine, strAmount, strUpdate);

                if (null != mediInfo)
                    lstMedInfo.Add(mediInfo);
            }
            else if ('1' == xmlValue.InnerText[0])
            {
                // ****************************
                //  セット薬剤の場合
                // ****************************

                // セット薬剤分解フラグ(true:分解する、false:分解しない)
                bool isDisassemblyflg;

                // セット薬剤分解フラグ取得
                Fn3ReturnCode retCode = GetDisassemblyflg(out isDisassemblyflg, iSetMediiFlg, iInHospitalCode, xmlDialysisCond);

                if (retCode != Fn3ReturnCode.Success)
                {
                    return null;
                }

                if (isDisassemblyflg == true)
                {
                    // -----セット薬剤を分解する場合----- //
                    if (null == xmlDialysisCond.SelectSingleNode("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                    {
                        return null;
                    }
                    XmlNodeList xmlMediList = xmlDialysisCond.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE");

                    foreach (XmlNode item in xmlMediList)
                    {
                        // 薬剤マスタを取得する
                        XmlNode xmlMstMedicine = item.SelectSingleNode("MST_MEDICINE");

                        if (null == xmlMstMedicine)
                        {
                            return null;
                        }

                        // 使用薬剤数を取得する
                        double dbUseNum = 0.0;
                        XmlNode xmlUseMedi = item.SelectSingleNode("MEDI_USE_NUM");
                        if (null != xmlUseMedi && false == xmlUseMedi.InnerText.Trim().Equals(""))
                        {
                            if (false == double.TryParse(xmlUseMedi.InnerText.Trim(), out dbUseNum))
                            {
                                dbUseNum = 0.0;
                            }
                        }

                        //  数量算出　透析液量＋補液使用数
                        string strAmount = "";

                        // 透析液の場合は、補液の量を足す
                        if (null != item.SelectSingleNode("MST_MEDICINE[MEDICINE_GROUP_CD='302']"))
                        {
                            //数量は、透析液量 * 使用薬剤数に補液を足したもの
                            // 2015/05/21 中村 Redmine#4666(オンライン治療の数量合算） Chg Start
                            // strAmount = ((dbDialysis * dbUseNum) + dbHoeki).ToString();
                            double dbValue = 0.0;
                            XmlNode xmlMedicineCd = item.SelectSingleNode("MEDICINE_CD");
                            if (null != xmlMedicineCd && !string.IsNullOrEmpty(xmlMedicineCd.InnerText.Trim()))
                            {
                                if (htHoeki.ContainsKey(xmlMedicineCd.InnerText.Trim()))
                                {
                                    dbValue = (double)htHoeki[xmlMedicineCd.InnerText.Trim()];
                                }
                            }
                            strAmount = ((dbDialysis * dbUseNum) + dbValue).ToString();
                            // 2015/05/21 中村 Redmine#4666(オンライン治療の数量合算） Chg End
                        }
                        else
                        {
                            // 数量は、透析液量 * 使用薬剤数
                            strAmount = (dbDialysis * dbUseNum).ToString();
                        }

                        //	薬剤情報をリストに追加
                        Fn3CoopMediInfo mediInfo = GetMedicine(xmlMstMedicine, strAmount, strUpdate);
                        if (null != mediInfo)
                            lstMedInfo.Add(mediInfo);
                    }
                }
                else
                {
                    // -----セット薬剤のままの場合----- //
                    XmlNode xmlSetMediName = xmlDialysisCond.SelectSingleNode("MST_SET_MEDI_NAME");

                    if (xmlSetMediName == null)
                    {
                        return null;
                    }

                    //  数量算出　透析液量＋補液使用数
                    string strAmount = "";

                    // 透析液の場合は、補液の量を足す
                    if (null != xmlDialysisCond.SelectSingleNode("MST_SET_MEDI_NAME[MEDICINE_GROUP_CD='302']"))
                    {
                        //数量は、透析液量に補液を足したもの
                        strAmount = (dbDialysis + dbHoeki).ToString();
                    }
                    else
                    {
                        // 数量は、透析液量
                        strAmount = dbDialysis.ToString();
                    }

                    //	薬剤情報をリストに追加
                    Fn3CoopMediInfo mediInfo = GetSetMedicine(xmlSetMediName, strAmount, strUpdate);

                    if (mediInfo != null)
                        lstMedInfo.Add(mediInfo);
                }
            }

            return lstMedInfo;
        }

        #endregion

        #region 補液情報を取得する

        /// <summary>
        /// 補液情報を取得する
        /// </summary>
        /// <param name="xmlCoopInfo"></param>
        /// <param name="iInHospitalCode"></param>
        /// <param name="iSetMediiFlg"></param>
        /// <returns></returns>
        private static List<Fn3CoopMediInfo> GetMedHoekiInfo(XmlNode xmlCoopInfo, int iSetMediiFlg, int iInHospitalCode)
        {
            List<Fn3CoopMediInfo> lstMedInfo = new List<Fn3CoopMediInfo>();
            // ====================================
            // 指示又は透析実績から透析液の透析条件を取得する
            // ====================================
            XmlNode xmlDialysisCond = null;
            string strSelectTable = "";

            if (xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='022']") != null)
            {
                xmlDialysisCond = xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='022']");
                strSelectTable = "IND_DIALYSIS_COND";
            }
            else if (xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='022']") != null)
            {
                xmlDialysisCond = xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='022']");
                strSelectTable = "RST_DIALYSIS_COND_HST";
            }
            else
            {
                // 補液が設定されていない (0件)
                return lstMedInfo;
            }

            // ====================================
            //	更新日時取得
            // ====================================
            string strUpdate = "";
            XmlNode xmlUpdate = xmlDialysisCond.SelectSingleNode("UP_DATE");
            if (null != xmlUpdate && false == xmlUpdate.InnerText.Equals(""))
            {
                strUpdate = xmlUpdate.InnerText;
            }

            // ====================================
            // 設定値を取得する
            // ====================================
            XmlNode xmlValue = xmlDialysisCond.SelectSingleNode("VALUE");

            if (null == xmlValue || xmlValue.InnerText.Trim().Equals(""))
            {
                // 透析液が設定されていない (0件)
                return lstMedInfo;
            }

            // 補液使用数を取得
            double dbUseHoeki = 0.0;
            XmlNode xmlHoeki = xmlCoopInfo.SelectSingleNode(string.Format("rootNode/{0}[CTL_NO='030']/VALUE", strSelectTable));
            if (null != xmlHoeki && false == xmlHoeki.InnerText.Trim().Equals(""))
            {
                // 文字列を数値に変換する
                if (false == double.TryParse(xmlHoeki.InnerText.Trim(), out dbUseHoeki))
                {
                    dbUseHoeki = 0.0;
                }
            }

            // オンライン補液かどうかを取得する
            bool blOnline = CheckOnlineDialysis(xmlCoopInfo);

            // セット薬剤か、通常薬剤かをチェックする
            if (xmlValue.InnerText[0] == '0')
            {
                // ****************************
                //  通常薬剤の場合
                // ****************************

                // オンライン補液の場合は、セットしない
                if (blOnline) return lstMedInfo;    // 0件で返す

                XmlNode xmlMstMedicine = xmlDialysisCond.SelectSingleNode("MST_MEDICINE");
                if (null == xmlMstMedicine)
                {
                    return null;
                }
                //  数量算出　補液使用数
                string strAmount = dbUseHoeki.ToString();

                //	薬剤情報をリストに追加
                Fn3CoopMediInfo mediInfo = GetMedicine(xmlMstMedicine, strAmount, strUpdate);

                if (null != mediInfo)
                    lstMedInfo.Add(mediInfo);
            }
            else if ('1' == xmlValue.InnerText[0])
            {
                // ****************************
                //  セット薬剤の場合
                // ****************************

                // セット薬剤分解フラグ(true:分解する、false:分解しない)
                bool isDisassemblyflg;

                // セット薬剤分解フラグ取得
                Fn3ReturnCode retCode = GetDisassemblyflg(out isDisassemblyflg, iSetMediiFlg, iInHospitalCode, xmlDialysisCond);

                if (retCode != Fn3ReturnCode.Success)
                {
                    return null;
                }

                if (isDisassemblyflg == true)
                {
                    // -----セット薬剤を分解する場合----- //
                    if (null == xmlDialysisCond.SelectSingleNode("MST_SET_MEDI_NAME/MST_SET_MEDICINE"))
                    {
                        return null;
                    }
                    XmlNodeList xmlMediList = xmlDialysisCond.SelectNodes("MST_SET_MEDI_NAME/MST_SET_MEDICINE");

                    foreach (XmlNode item in xmlMediList)
                    {
                        // 薬剤マスタを取得する
                        XmlNode xmlMstMedicine = item.SelectSingleNode("MST_MEDICINE");

                        if (null == xmlMstMedicine)
                        {
                            return null;
                        }

                        // オンライン補液で且つ、薬剤分類が透析液の場合は、セットしない
                        if (blOnline && (null != item.SelectSingleNode("MST_MEDICINE[MEDICINE_GROUP_CD='302']")))
                        {
                            continue;
                        }

                        // 使用薬剤数を取得する
                        double dbUseNum = 0.0;
                        XmlNode xmlUseMedi = item.SelectSingleNode("MEDI_USE_NUM");
                        if (null != xmlUseMedi && false == xmlUseMedi.InnerText.Trim().Equals(""))
                        {
                            if (false == double.TryParse(xmlUseMedi.InnerText.Trim(), out dbUseNum))
                            {
                                dbUseNum = 0.0;
                            }
                        }

                        //  数量算出　補液使用数 * 使用薬剤数
                        string strAmount = (dbUseHoeki * dbUseNum).ToString();

                        //	薬剤情報をリストに追加
                        Fn3CoopMediInfo mediInfo = GetMedicine(xmlMstMedicine, strAmount, strUpdate);
                        if (null != mediInfo)
                            lstMedInfo.Add(mediInfo);
                    }
                }
                else
                {
                    // -----セット薬剤のままの場合----- //
                    XmlNode xmlMstMedicine = xmlDialysisCond.SelectSingleNode("MST_SET_MEDI_NAME");

                    if (null == xmlMstMedicine)
                    {
                        return null;
                    }

                    //  数量算出　補液使用数
                    string strAmount = dbUseHoeki.ToString();

                    //	薬剤情報をリストに追加
                    Fn3CoopMediInfo mediInfo = GetSetMedicine(xmlMstMedicine, strAmount, strUpdate);

                    if (null != mediInfo)
                        lstMedInfo.Add(mediInfo);
                }
            }
            return lstMedInfo;
        }

        #endregion

        #region 薬剤情報を取得する(透析条件項目用)
        /// <summary>
        /// 薬剤情報を取得する(透析条件項目用)
        /// </summary>
        /// <param name="xmlMstMedicine">マスタ</param>
        /// <param name="strAmount">数量</param>
        /// <param name="strUpdateDate">更新日</param>
        /// <returns></returns>
        private static Fn3CoopMediInfo GetMedicine(XmlNode xmlMstMedicine, string strAmount, string strUpdateDate)
        {
            return GetMedicine(xmlMstMedicine, strAmount, null, "", "", "", strUpdateDate, "", "");
        }
        #endregion

        #region 薬剤情報を取得する
        /// <summary>
        /// 薬剤情報を取得する
        /// </summary>
        /// <param name="xmlMstMedicine">薬剤マスタ</param>
        /// <param name="strAmount">数量</param>
        /// <param name="xmlMstProcedure">手技マスタ</param>
        /// <param name="strTimingCd">投与時間帯コード</param>
        /// <param name="strTimingName">投与時間帯名称</param>
        /// <param name="strEffectDate">実施日</param>
        /// <param name="strUpdateDate">更新日</param>
        /// <param name="strStaffCode">スタッフコード</param>
        /// <param name="strStaffName">スタッフ名称</param>
        /// <returns></returns>
        private static Fn3CoopMediInfo GetMedicine(
            XmlNode xmlMstMedicine, string strAmount, XmlNode xmlMstProcedure, string strTimingCd, string strTimingName,
            string strEffectDate, string strUpdateDate, string strStaffCode, string strStaffName)
        {
            Fn3CoopMediInfo info = new Fn3CoopMediInfo();

            // 薬剤コード
            XmlNode xmlValue = xmlMstMedicine.SelectSingleNode("MEDICINE_CD");
            if (xmlValue != null)
            {
                info.MedicineCd = xmlValue.InnerText.Trim();
            }

            // 薬剤名称
            xmlValue = xmlMstMedicine.SelectSingleNode("MEDICINE_NAME");
            if (xmlValue != null)
            {
                info.MedicineName = xmlValue.InnerText.Trim();
            }

            // 薬剤院内コード１
            xmlValue = xmlMstMedicine.SelectSingleNode("IN_HOSPITAL_CD");
            if (xmlValue != null)
            {
                info.MediInHospitalCd = xmlValue.InnerText.Trim();
            }

            // 薬剤院内コード２
            xmlValue = xmlMstMedicine.SelectSingleNode("IN_HOSPITAL_CD2");
            if (xmlValue != null)
            {
                info.MediInHospitalCd2 = xmlValue.InnerText.Trim();
            }

            // 薬剤分類コード
            xmlValue = xmlMstMedicine.SelectSingleNode("MEDICINE_GROUP_CD");
            if (xmlValue != null)
            {
                info.MedicineGroupCd = xmlValue.InnerText.Trim();
            }

            // 薬剤分類名称
            xmlValue = xmlMstMedicine.SelectSingleNode("MST_CLASS_NAME/CLASS_NAME");
            if (xmlValue != null)
            {
                info.MedicineGroupName = xmlValue.InnerText.Trim();
            }

            // 数量
            double dblAmount;
            if (double.TryParse(strAmount, out dblAmount) == false)
            {
                info.Amount = 0.0;
            }
            else
            {
                info.Amount = dblAmount;
            }

            // 単位
            xmlValue = xmlMstMedicine.SelectSingleNode("UNIT");
            if (xmlValue != null)
            {
                info.Unit = xmlValue.InnerText.Trim();
            }

            //  更新日
            DateTime dtUpdateDate;
            if (DateTime.TryParse(strUpdateDate, out dtUpdateDate) == true)
            {
                info.UpDate = dtUpdateDate.ToString("yyyyMMddHHmmss");
            }
            else
            {
                info.UpDate = "";
            }

            // 手技情報
            if (xmlMstProcedure != null)
            {
                // 手技コード
                xmlValue = xmlMstProcedure.SelectSingleNode("PROCEDURE_CD");
                if (xmlValue != null)
                {
                    info.ProcedureCd = xmlValue.InnerText.Trim();
                }

                // 手技名称
                xmlValue = xmlMstProcedure.SelectSingleNode("PROCEDURE_NAME");
                if (xmlValue != null)
                {
                    info.ProcedureName = xmlValue.InnerText.Trim();
                }

                // 手技院内コード１
                xmlValue = xmlMstProcedure.SelectSingleNode("IN_HOSPITAL_CD1");
                if (xmlValue != null)
                {
                    info.ProcInHospitalCd1 = xmlValue.InnerText.Trim();
                }

                // 手技院内コード１
                xmlValue = xmlMstProcedure.SelectSingleNode("IN_HOSPITAL_CD2");
                if (xmlValue != null)
                {
                    info.ProcInHospitalCd2 = xmlValue.InnerText.Trim();
                }

                // 投与時間帯コード
                info.TimingCd = strTimingCd;

                // 投与時間帯名称
                info.TimeingName = strTimingName;
            }

            //  実施日
            DateTime dtOccurDate;
            if (DateTime.TryParse(strEffectDate, out dtOccurDate) == true)
            {
                info.EffectDate = dtOccurDate.ToString("yyyyMMddHHmmss");
            }
            else
            {
                info.EffectDate = "";
            }

            // 処置者コード
            info.PersonCd = strStaffCode;
            //  処置者
            info.PersonName = strStaffName;
            // セット薬剤フラグを0にする
            info.SetMedicineFlag = "0";

            return info;
        }

        #endregion

        #region セット薬剤情報を取得する(透析条件項目用)
        /// <summary>
        /// セット薬剤情報を取得する(透析条件項目用)
        /// </summary>
        /// <param name="xmlMstMedicine">マスタ</param>
        /// <param name="strAmount">数量</param>
        /// <param name="strUpdateDate">更新日</param>
        /// <returns></returns>
        private static Fn3CoopMediInfo GetSetMedicine(XmlNode xmlMstMedicine, string strAmount, string strUpdateDate)
        {
            return GetSetMedicine(xmlMstMedicine, strAmount, null, "", "", "", strUpdateDate, "", "");
        }
        #endregion

        #region セット薬剤情報を取得する
        /// <param name="xmlMstMedicine">薬剤マスタ</param>
        /// <param name="strAmount">数量</param>
        /// <param name="xmlMstProcedure">手技マスタ</param>
        /// <param name="strTimingCd">投与時間帯コード</param>
        /// <param name="strTimingName">投与時間帯名称</param>
        /// <param name="strEffectDate">実施日</param>
        /// <param name="strUpdateDate">更新日</param>
        /// <param name="strStaffCode">スタッフコード</param>
        /// <param name="strStaffName">スタッフ名称</param>
        /// <returns></returns>
        private static Fn3CoopMediInfo GetSetMedicine(
            XmlNode xmlMstMedicine, string strAmount, XmlNode xmlMstProcedure, string strTimingCd, string strTimingName,
            string strEffectDate, string strUpdateDate, string strStaffCode, string strStaffName)
        {
            Fn3CoopMediInfo info = new Fn3CoopMediInfo();

            // 薬剤コード
            XmlNode xmlValue = xmlMstMedicine.SelectSingleNode("SET_MEDICINE_CD");
            if (xmlValue != null)
            {
                info.MedicineCd = xmlValue.InnerText.Trim();
            }

            // 薬剤名称
            xmlValue = xmlMstMedicine.SelectSingleNode("SET_MEDICINE_NAME");
            if (xmlValue != null)
            {
                info.MedicineName = xmlValue.InnerText.Trim();
            }

            // 薬剤院内コード１
            xmlValue = xmlMstMedicine.SelectSingleNode("IN_HOSPITAL_CD");
            if (xmlValue != null)
            {
                info.MediInHospitalCd = xmlValue.InnerText.Trim();
            }

            // 薬剤院内コード２
            xmlValue = xmlMstMedicine.SelectSingleNode("IN_HOSPITAL_CD2");
            if (xmlValue != null)
            {
                info.MediInHospitalCd2 = xmlValue.InnerText.Trim();
            }

            // 薬剤分類コード
            xmlValue = xmlMstMedicine.SelectSingleNode("MEDICINE_GROUP_CD");
            if (xmlValue != null)
            {
                info.MedicineGroupCd = xmlValue.InnerText.Trim();
            }

            // 薬剤分類名称
            xmlValue = xmlMstMedicine.SelectSingleNode("MST_CLASS_NAME/CLASS_NAME");
            if (xmlValue != null)
            {
                info.MedicineGroupName = xmlValue.InnerText.Trim();
            }

            // 数量
            double dblAmount;
            if (double.TryParse(strAmount, out dblAmount) == false)
            {
                info.Amount = 0.0;
            }
            else
            {
                info.Amount = dblAmount;
            }

            // 単位
            xmlValue = xmlMstMedicine.SelectSingleNode("IND_UNIT");
            if (xmlValue != null)
            {
                info.Unit = xmlValue.InnerText.Trim();
            }

            //  更新日
            DateTime dtUpdateDate;
            if (DateTime.TryParse(strUpdateDate, out dtUpdateDate) == true)
            {
                info.UpDate = dtUpdateDate.ToString("yyyyMMddHHmmss");
            }
            else
            {
                info.UpDate = "";
            }

            // 手技情報
            if (xmlMstProcedure != null)
            {
                // 手技コード
                xmlValue = xmlMstProcedure.SelectSingleNode("PROCEDURE_CD");
                if (xmlValue != null)
                {
                    info.ProcedureCd = xmlValue.InnerText.Trim();
                }

                // 手技名称
                xmlValue = xmlMstProcedure.SelectSingleNode("PROCEDURE_NAME");
                if (xmlValue != null)
                {
                    info.ProcedureName = xmlValue.InnerText.Trim();
                }

                // 手技院内コード１
                xmlValue = xmlMstProcedure.SelectSingleNode("IN_HOSPITAL_CD1");
                if (xmlValue != null)
                {
                    info.ProcInHospitalCd1 = xmlValue.InnerText.Trim();
                }

                // 手技院内コード１
                xmlValue = xmlMstProcedure.SelectSingleNode("IN_HOSPITAL_CD2");
                if (xmlValue != null)
                {
                    info.ProcInHospitalCd2 = xmlValue.InnerText.Trim();
                }

                // 投与時間帯コード
                info.TimingCd = strTimingCd;

                // 投与時間帯名称
                info.TimeingName = strTimingName;
            }

            //  実施日
            DateTime dtOccurDate;
            if (DateTime.TryParse(strEffectDate, out dtOccurDate) == true)
            {
                info.EffectDate = dtOccurDate.ToString("yyyyMMddHHmmss");
            }
            else
            {
                info.EffectDate = "";
            }

            // 処置者コード
            info.PersonCd = strStaffCode;
            //  処置者
            info.PersonName = strStaffName;
            // セット薬剤フラグを１にする
            info.SetMedicineFlag = "1";

            return info;
        }

        #endregion

        #region 透析条件項目から治療項目の装置モードがオンライン透析かチェックする

        /// <summary>
        /// 透析条件項目から治療項目の装置モードがオンライン透析かチェックする
        /// </summary>
        /// <param name="xmlCoopInfo">実行情報</param>
        /// <returns>True:オンライン透析 False：その他</returns>
        private static bool CheckOnlineDialysis(XmlNode xmlCoopInfo)
        {
            bool retVal = false;

            XmlNode xmlTreatItem = null;

            // 指示、又は実績テーブルより治療項目の透析条件を取得
            if (xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='006']") != null)
            {
                xmlTreatItem = xmlCoopInfo.SelectSingleNode("rootNode/IND_DIALYSIS_COND[CTL_NO='006']");
            }
            else if (xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='006']") != null)
            {
                xmlTreatItem = xmlCoopInfo.SelectSingleNode("rootNode/RST_DIALYSIS_COND_HST[CTL_NO='006']");
            }
            else
            {
                return retVal;
            }

            XmlNode xmlDevMode = xmlTreatItem.SelectSingleNode("MST_TREAT_ITEM/DEVICE_MODE");
            if (xmlDevMode != null)
            {
                switch (xmlDevMode.InnerText.Trim())
                {
                    case "4":   // HD + 補液
                    case "7":   // OHDF
                    case "8":   // OHF
                    case "10":  // プログラム補液
                        retVal = true;
                        break;
                    default:
                        break;
                }
            }

            return retVal;
        }

        #endregion

        #region セット薬剤分解フラグの取得
        /// <summary>
        /// セット薬剤分解フラグの取得
        /// </summary>
        /// <param name="isDisassemblyflg">セット薬剤分解フラグ(true:分解する、false:分解しない)</param>
        /// <param name="iSetMediiFlg">セット薬剤参照フラグ</param>
        /// <param name="iInHospitalCode">使用院内コード</param>
        /// <param name="xmlDialysis">透析条件</param>
        /// <returns>リターンコード</returns>
        private static Fn3ReturnCode GetDisassemblyflg(
            out bool isDisassemblyflg, int iSetMediiFlg, int iInHospitalCode, XmlNode xmlDialysis)
        {
            // セット薬剤分解フラグ(true:分解する、false:分解しない)
            XmlNode xmlValue = null;
            isDisassemblyflg = true;

            if (iSetMediiFlg == 0)
            {
                // セット薬剤を分解する場合
                isDisassemblyflg = true;
            }
            else if (iSetMediiFlg == 1)
            {
                // セット薬剤のままの場合
                isDisassemblyflg = false;
            }
            else
            {
                // MST_SET_MEDI_NAMEを取得
                XmlNode xmlSetMediName = xmlDialysis.SelectSingleNode("MST_SET_MEDI_NAME");

                if (xmlSetMediName == null)
                {
                    // MST_SET_MEDI_NAMEが取得できなかった場合、終了
                    return Fn3ReturnCode.Error;
                }

                if (iInHospitalCode == 1)
                {
                    // 院内コードを１取得
                    xmlValue = xmlSetMediName.SelectSingleNode("IN_HOSPITAL_CD");
                }
                else if (iInHospitalCode == 2)
                {
                    // 院内コード２を取得
                    xmlValue = xmlSetMediName.SelectSingleNode("IN_HOSPITAL_CD2");
                }

                if (xmlValue == null || xmlValue.InnerText.Trim().Equals(""))
                {
                    // 院内コードが未設定の場合、セット薬剤を分解
                    isDisassemblyflg = true;
                }
                else
                {
                    // 院内コードが設定されている場合、セット薬剤のまま
                    isDisassemblyflg = false;
                }
            }
            return Fn3ReturnCode.Success;
        }
        #endregion

        #endregion

    }
}
