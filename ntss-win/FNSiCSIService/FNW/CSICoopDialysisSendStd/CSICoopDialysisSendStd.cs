///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：シーエスアイ標準連携　透析実績送信機能
// ファイル名：CSICoopDialysisSendStd.cs
// 説明      ：透析実績送信機能を提供する。※パーシャルクラス
//
//	Copyright(C) 2010 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2010/02/15	今井久雄			新規作成
//  2011/01/07  中村圭之介          指示医を版確定者⇒患者基本情報.担当医に変更。
//  2011/01/21  中村圭之介          小数点以下の有効桁数対応
//  2011/02/22  堀内英史            処置送信対応
//  2011/05/13  中村圭之介          指示医対応（新里ﾒﾃﾞｨｹｱ版よりマージ）
//  2015/07/29  石川俊介            特殊浄化対応,ログ強化
//  2015/09/03  中村圭之介          受入指摘対応(Redmine#4949)
//  2017/02/05  橋口雅典            5.02加算対応（透析困難コメントの複数出力）
//  2025/06/10  P.H.Thach           心電図送信対応
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
using System.IO;


namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    /// <summary>
    /// 処置行為情報
    /// </summary>
    public class TreatActInfo
    {
        private string m_strMstMedCode;
        /// <summary>薬剤コード</summary>
        /// <remarks>セット薬剤の場合、S + セット薬剤コード</remarks>
        public string MstMedCode
        {
            get { return m_strMstMedCode; }
            set { m_strMstMedCode = value; }
        }

        private string m_strTreatmenetAct;
        /// <summary>行為コード（院内コード１／院内コード２</summary>
        public string TreatmentAct
        {
            get { return m_strTreatmenetAct; }
            set { m_strTreatmenetAct = value; }
        }        

        private string m_strClassType;
        /// <summary>分類(M/T)</summary>
        public string ClassType
        {
            get { return m_strClassType; }
            set { m_strClassType = value; }
        }

        private string m_strCtlNo;
        /// <summary>項目コード</summary>
        public string CtlNo
        {
            get { return m_strCtlNo; }
            set { m_strCtlNo = value; }
        }

        private string m_strEffectDate;
        /// <summary>実施日時</summary>
        public string EffectDate
        {
            get { return m_strEffectDate; }
            set { m_strEffectDate = value; }
        }

        private string m_strOrderNo;
        /// <summary>オーダ番号</summary>
        public string OrderNo
        {
            get { return m_strOrderNo; }
            set { m_strOrderNo = value; }
        }

        private List<TreatItemInfo> m_TreatItemlist;
        /// <summary>
        /// 処置薬剤・材料リストの追加（1件）
        /// </summary>
        /// <param name="Function">機能コード</param>
        /// <param name="ItemCode">処置行為詳細コード</param>
        /// <param name="Amount">数量</param>
        public void SetTreatItem(string Function, string ItemCode, string Amount)
        {
            if (string.IsNullOrEmpty(Function) || string.IsNullOrEmpty(ItemCode))
            {
                return;
            }

            if (m_blnTreatmentActionUnitFlag)
            {
                // まとめる設定の場合
                int Index = -1;
                for (int i = 0; i < m_TreatItemlist.Count; i++)
                {
                    // 機能コード、行為詳細コードが一致するものを検索
                    if (m_TreatItemlist[i].Function.Equals(Function) &&
                        m_TreatItemlist[i].ItemCode.Equals(ItemCode))
                    {
                        Index = i;
                        break;
                    }
                }

                if (Index.Equals(-1))
                {
                    // 新規で、処置薬剤・材料情報を追加
                    TreatItemInfo itemInfo = new TreatItemInfo();
                    itemInfo.Function = Function;
                    itemInfo.ItemCode = ItemCode;
                    itemInfo.Amount = Amount;
                    m_TreatItemlist.Add(itemInfo);
                }
                else
                {
                    // 既存の処置薬剤・材料情報の数量に加算
                    string baseAmount = m_TreatItemlist[Index].Amount;
                    decimal dcBaseAmount;
                    if (!decimal.TryParse(baseAmount, out dcBaseAmount))
                    {
                        return;
                    }
                    decimal dcInAmount;
                    if (!decimal.TryParse(Amount, out dcInAmount))
                    {
                        return;
                    }

                    m_TreatItemlist[Index].Amount = decimal.Add(dcBaseAmount, dcInAmount).ToString();
                }
            }
            else
            {
                // まとめない設定の場合

                // 新規で、処置薬剤・材料情報を追加
                TreatItemInfo itemInfo = new TreatItemInfo();
                itemInfo.Function = Function;
                itemInfo.ItemCode = ItemCode;
                itemInfo.Amount = Amount;
                m_TreatItemlist.Add(itemInfo);
            }
        }

        /// <summary>
        /// 処置薬剤・材料リストの追加（一括）
        /// </summary>
        /// <param name="listTreatItem">処置薬剤・材料リスト</param>
        public void SetTreatItem(List<TreatItemInfo> listTreatItem)
        {
            if (m_blnTreatmentActionUnitFlag)
            {
                // まとめる設定の場合
                foreach (TreatItemInfo treatItem in listTreatItem)
                {
                    int Index = -1;
                    for (int i = 0; i < m_TreatItemlist.Count; i++)
                    {
                        // 機能コード、行為詳細コードが一致するものを検索
                        if (m_TreatItemlist[i].Function.Equals(treatItem.Function) &&
                            m_TreatItemlist[i].ItemCode.Equals(treatItem.ItemCode))
                        {
                            Index = i;
                            break;
                        }
                    }

                    if (Index.Equals(-1))
                    {
                        // 新規で、処置薬剤・材料情報を追加
                        TreatItemInfo itemInfo = new TreatItemInfo();
                        itemInfo.Function = treatItem.Function;
                        itemInfo.ItemCode = treatItem.ItemCode;
                        itemInfo.Amount = treatItem.Amount;
                        m_TreatItemlist.Add(itemInfo);
                    }
                    else
                    {
                        // 既存の処置薬剤・材料情報の数量に加算
                        string baseAmount = m_TreatItemlist[Index].Amount;
                        decimal dcBaseAmount;
                        if (!decimal.TryParse(baseAmount, out dcBaseAmount))
                        {
                            return;
                        }
                        decimal dcInAmount;
                        if (!decimal.TryParse(treatItem.Amount, out dcInAmount))
                        {
                            return;
                        }

                        m_TreatItemlist[Index].Amount = decimal.Add(dcBaseAmount, dcInAmount).ToString();
                    }
                }
            }
            else
            {
                // まとめない設定の場合
                foreach (TreatItemInfo treatItem in listTreatItem)
                {
                    m_TreatItemlist.Add(treatItem);
                }
            }
        }

        /// <summary>処置薬剤・材料リストの取得</summary>
        public List<TreatItemInfo> GetTreatItem
        {
            get { return m_TreatItemlist; }
        }
        bool m_blnTreatmentActionUnitFlag = false;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="blnTreatmentActionUnitFlag">処置行為まとめフラグ</param>
        public TreatActInfo(bool blnTreatmentActionUnitFlag)
        {
            m_blnTreatmentActionUnitFlag = blnTreatmentActionUnitFlag;
            m_TreatItemlist = new List<TreatItemInfo>();
        }
    }
    
    /// <summary>
    /// 処置薬剤・材料情報
    /// </summary>
    public class TreatItemInfo
    {
        private string m_strFunction;
        /// <summary>機能コード</summary>
        public string Function
        {
            get { return m_strFunction; }
            set { m_strFunction = value; }
        }

        private string m_strItemCode;
        /// <summary>行為詳細コード</summary>
        public string ItemCode
        {
            get { return m_strItemCode; }
            set { m_strItemCode = value; }
        }

        private string m_strAmount;
        /// <summary>数量</summary>
        public string Amount
        {
            get { return m_strAmount; }
            set { m_strAmount = value; }
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public TreatItemInfo()
        {
            m_strFunction = string.Empty;
            m_strItemCode = string.Empty;
            m_strAmount = string.Empty;
        }
    }
    

    public partial class Fn3CSICoopDialysisSendStd : Fn3ComPlugIn
    {

        #region 定数定義
        /// <summary>
        /// オーダNoなし
        /// </summary>
        const string NONE = "none";

        /// <summary>
        /// 入力・日付フォーマット
        /// </summary>
        const string INPUT_FROMAT_DAY = "yyyyMMdd";
        /// 入力・時間フォーマット（秒無し）
        /// </summary>
        const string INPUT_FROMAT_TIME = "HHmm";
        /// <summary>
        /// 入力・時間フォーマット（秒有り）
        /// </summary>
        const string INPUT_FROMAT_TIME_SS = "HHmmss";
        /// <summary>
        /// 出力・日付フォーマット
        /// </summary>
        const string OUTPUT_FROMAT_DAY = "yyyy/MM/dd";
        /// <summary>
        /// 出力・時間フォーマット（秒無し）
        /// </summary>
        const string OUTPUT_FROMAT_TIME = "HH:mm";
        /// <summary>
        /// 出力・時間フォーマット（秒有り）
        /// </summary>
        const string OUTPUT_FROMAT_TIME_SS = "HH:mm:ss";
        /// 出力・時間フォーマット（00秒）
        /// ※FMWEBのデータで秒が有ったり無かったりするデータがあるので、その対策として0秒で固定で出力為の定数
        /// </summary>
        const string OUTPUT_FROMAT_TIME_00 = "HH:mm:00";

        /// <summary>
        /// Fn3ExecuteInfo・処理区分：新規
        /// </summary>
        const string EVENT_TYPE_ADD = "0";
        /// <summary>
        /// Fn3ExecuteInfo・処理区分：変更
        /// </summary>
        const string EVENT_TYPE_CHG = "1";
        /// <summary>
        /// Fn3ExecuteInfo・処理区分：削除
        /// </summary>
        const string EVENT_TYPE_DEL = "2";
        /// <summary>
        /// Fn3ExecuteInfo・処理区分：XXX（未使用）
        /// </summary>
        const string EVENT_TYPE_XXX = "X";

        /// <summary>
        /// テーブル定義値・入外区分：外来
        /// </summary>
        const string DB_INOUT_FLG_OUT = "0";
        /// <summary>
        /// テーブル定義値・入外区分：入院
        /// </summary>
        const string DB_INOUT_FLG_IN = "1";
        /// <summary>
        /// テーブル定義値・透析実績投薬履歴・薬剤投与・未実施
        /// </summary>
        const string DB_EFFECT_FLG_OFF = "0";
        /// <summary>
        /// テーブル定義値・透析実績投薬履歴・薬剤投与・実施済み
        /// </summary>
        const string DB_EFFECT_FLG_ON = "1";

        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード（治療方法）
        /// </summary>
        const string TARGET_TREAT_NO = "006";

        /// <summary>
        /// 治療項目マスタ・治療方法名称
        /// </summary>
        const string TREATNAME_HEMODIALYSIS_4H_UNDER = "血液透析(4時間未満)";
        /// <summary>
        /// 治療項目マスタ・治療方法名称
        /// </summary>
        const string TREATNAME_HEMODIALYSIS_4H5H = "血液透析(4～5時間)";
        /// <summary>
        /// 治療項目マスタ・治療方法名称
        /// </summary>
        const string TREATNAME_HEMODIALYSIS_5H_OVER = "血液透析(5時間以上)";
        /// <summary>
        /// 治療項目マスタ・治療方法名称
        /// </summary>
        const string TREATNAME_HEMODIALYSIS_DIALYSIS = "血液透析濾過";
        /// <summary>
        /// 治療項目マスタ・治療方法名称
        /// </summary>
        const string TREATNAME_HEMOFILTRATION = "血液濾過";
        /// <summary>
        /// 治療項目マスタ・治療方法名称
        /// </summary>
        const string TREATNAME_ECUN = "ECUN";

        /// <summary>
        /// オーダディテール・機能コード・処置薬剤
        /// </summary>
        const string CODE_MEASURES_DRUG = "04";
        /// <summary>
        /// オーダディテール・機能コード・処置材料
        /// </summary>
        const string CODE_MEASURES_MATERIAL = "05";

        // >>>>>【Ver.5.0.0.104】2011.02.23 horiuchi 処置送信対応
        /// オーダディテール・機能コード・時間
        /// </summary>
        const string CODE_MEASURES_TIME = "06";
        // <<<<<【Ver.5.0.0.104】2011.02.23 horiuchi 処置送信対応

        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・透析時間
        /// </summary>
        const string CODE_DIALYSIS_ITEM_DIALYSIS_TIME = "002";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・DW
        /// </summary>
        const string CODE_DIALYSIS_ITEM_DW = "004";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・治療方法
        /// </summary>
        const string CODE_DIALYSIS_ITEM_TREAT = "006";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・ダイアライザー（血液浄化器）
        /// </summary>
        const string CODE_DIALYSIS_ITEM_DIALYZER = "008";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・吸着カラム
        /// </summary>
        const string CODE_DIALYSIS_ITEM_KYUTYAKU = "009";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・抗凝固剤
        /// </summary>
        const string CODE_DIALYSIS_ITEM_GYOKO = "011";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・抗凝固剤ワンショット量
        /// </summary>
        const string CODE_DIALYSIS_ITEM_GYOKO_ONE = "012";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・抗凝固剤持続速度
        /// </summary>
        const string CODE_DIALYSIS_ITEM_GYOKO_SPEED = "013";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・抗凝固剤持続総量
        /// </summary>
        const string CODE_DIALYSIS_ITEM_GYOKO_QUANTIY = "014";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・透析液
        /// </summary>
        const string CODE_DIALYSIS_ITEM_HEMODIALYSIS = "018";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・透析液量
        /// </summary>
        const string CODE_DIALYSIS_ITEM_HEMODIALYSIS_QUANTIY = "020";

        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・補液
        /// <value>022</value>
        /// </summary>
        const string CODE_DIALYSIS_ITEM_REPLENISH = "022";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・補液量
        /// <value>022</value>
        /// </summary>
        const string CODE_DIALYSIS_ITEM_REPLENISH_AMOUNT = "023";
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・補液使用数
        /// <value>030</value>
        /// </summary>
        const string CODE_DIALYSIS_ITEM_REPLENISH_QUANTIY = "030";

        // >>>>>【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応
        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・１次膜
        /// <value>039</value>
        /// </summary>
        const string CODE_DIALYSIS_ITEM_FIRST_FILM = "039";

        /// <summary>
        /// 透析条件項目マスタ・透析条件項目コード・２次膜
        /// <value>040</value>
        /// </summary>
        const string CODE_DIALYSIS_ITEM_SECOND_FILM = "040";
        // <<<<<【Ver.5.0.3.100】2015.07.29 石川 特殊浄化対応

        /// <summary>
        /// 薬剤マスタ・注射・無し
        /// </summary>
        const string CODE_MEDICINE_SHOT_OFF = "0";
        /// <summary>
        /// 薬剤マスタ・注射・有り
        /// </summary>
        const string CODE_MEDICINE_SHOT_ON = "1";
        /// <summary>
        /// 薬剤マスタ・薬剤・通常薬剤
        /// </summary>
        const string CODE_MEDICINE_NORMAL = "0";
        /// <summary>
        /// 薬剤マスタ・薬剤・セット薬剤
        /// </summary>
        const string CODE_MEDICINE_SET = "1";

        /// <summary>
        /// 透析実績愁訴処置_処置履歴・処置区分・処置薬剤
        /// </summary>
        const string CODE_DIALYSIS_TREATMEN_TREATDRUG = "0";
        /// <summary>
        /// 透析実績愁訴処置_処置履歴・処置区分・薬剤
        /// </summary>
        const string CODE_DIALYSIS_TREATMEN_DRUG = "1";
        /// <summary>
        /// 透析実績愁訴処置_処置履歴・処置区分・処置
        /// </summary>
        const string CODE_DIALYSIS_TREATMEN_TREAT = "2";
        /// <summary>
        /// 透析実績愁訴処置_処置履歴・処置区分・酸素吸入
        /// </summary>
        const string CODE_DIALYSIS_TREATMEN_OX = "3";
        /// <summary>
        /// 透析実績愁訴処置_処置履歴・処置区分・心電図
        /// </summary>
        const string CODE_DIALYSIS_TREATMEN_ECG = "4";

        /// <summary>
        /// 数量が空の場合に設定する値
        /// ※連携全体として数量が空の場合は0としているが、今後どうするかは不明
        /// </summary>
        const string EMPTY_VAL = "0";

        /// <summary>
        /// 酸素吸入最大送信数
        /// <value>10</value>
        /// </summary>
        const int OXYGEN_LIMIT_COUNT = 10;

        /// <summary>
        /// 心電図最大送信数
        /// <value>10</value>
        /// </summary>
        const int ECG_LIMIT_COUNT = 10;

        /// <summary>
        /// 処置最大送信数
        /// <value>20</value>
        /// </summary>
        const int TREATMENT_LIMIT_COUNT = 20;

        #endregion


        #region メンバ定義
        /// <summary>
        /// シーエスアイ外部I/F部品・MIRAIs-DBオブジェクト
        /// </summary>
        object m_objMiraisDB = null;
        /// <summary>
        /// シーエスアイ外部I/F部品・共通オブジェクト
        /// </summary>
        object m_objCSICOMMON = null;
        /// <summary>
        /// シーエスアイ外部I/F部品・汎用オーダ
        /// </summary>
        object m_objCSIORDER = null;
        /// <summary>
        /// シーエスアイ外部I/F部品・注射オーダ
        /// </summary>
        object m_objCSIORDERInjection = null;
        /// <summary>
        /// シーエスアイ外部I/F部品・患者診療フリー登録/変更
        /// </summary>
        object m_objCSIEXAMRREE = null;

        /// <summary>
        /// 設定値・透析実績依頼科
        /// </summary>
        private string m_strDapartment;
        /// <summary>
        /// 設定値・透析実績操作部署
        /// </summary>
        private string m_strOrderWard;
        /// <summary>
        /// 設定値・透析実績入力端末
        /// </summary>
        private string m_strUpdateErminal;
        /// <summary>
        /// 設定値・注射オーダ薬袋Ｉ／Ｆ使用フラグ
        /// </summary>
        private string m_strDrugBagFlg;
        /// <summary>
        /// 設定値・酸素吸入量コード
        /// </summary>
        private string m_strOxygenInhalationCode;
        /// <summary>
        /// 設定値・抗凝固剤・手技
        /// </summary>
        private string m_strAnticoagulantProcedureCode;
        /// <summary>
        /// 設定値・抗凝固剤・ルート項目コード
        /// </summary>
        private string m_strAnticoagulantRouteCode;
        /// <summary>
        /// 設定値・抗凝固剤・投与方法項目コード
        /// </summary>
        private string m_strAnticoagulantMethodCode;
        /// <summary>
        /// 設定値・透析液・手技
        /// </summary>
        private string m_strHemodialysisProcedureCode;
        /// <summary>
        /// 設定値・透析液・ルート項目コード
        /// </summary>
        private string m_strHemodialysisRouteCode;
        /// <summary>
        /// 設定値・透析液・投与方法項目コード
        /// </summary>
        private string m_strHemodialysisMethodCode;
        /// <summary>
        /// 設定値・患者ID送信桁数
        /// </summary>
        private int m_iSendDispPatIdFigures;
        /// <summary>
        /// 設定値・ 連携対象動作モード
        /// </summary>
        private string m_strConnectType;
        /// <summary>
        /// 設定値・ I/F部品使用モード
        /// </summary>
        private string m_strLibType;

        /// <summary>
        /// 患者ＩＤ（ログ・アラーム用）
        /// </summary>
        private string m_strPatID;
        /// <summary>
        /// 表示用患者ＩＤ（ログ・アラーム用）
        /// </summary>
        private string m_strPatDispID;
        /// <summary>
        /// 患者名（ログ・アラーム用）
        /// </summary>
        private string m_strPatName;
        /// <summary>
        /// 処理区分（ログ・アラーム用）
        /// </summary>
        private string m_strSendClass;
        /// <summary>
        /// 透析番号（ログ・アラーム用）
        /// </summary>
        private string m_strDialysisNo;
        /// <summary>
        /// 版番号（ログ・アラーム用）
        /// </summary>
        private string m_strEdition;
        /// <summary>
        /// アラーム出力抑制フラグ
        /// </summary>
        private bool m_bolAramChk = true;

        // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更
        /// <summary>
        /// デフォルト医師
        /// </summary>
        private string m_strDefaultStaffCd;

        // 2011/05/13 中村 指示医対応
        /// <summary>
        /// 指示医フラグ
        /// </summary>
        private string m_strIndicatorFlg;

        // >>>>>【Ver.5.0.0.104】2011.02.23 horiuchi 処置送信対応
        /// <summary>
        /// 酸素吸入行為送信フラグ
        /// </summary>
        private bool m_blnOxygenActionSendFlag;
        /// <summary>
        /// 酸素吸入行為コード
        /// </summary>
        private string m_strOxygenActionCode;

        /// <summary>
        /// 心電図行為送信フラグ
        /// </summary>
        private bool m_blnEcgActionSendFlag;
        /// <summary>
        /// 心電図行為コード
        /// </summary>
        private string m_strEcgActionCode;

        /// <summary>
        /// 処置行為送信フラグ
        /// </summary>
        private bool m_blnTreatmentActionSendFlag;
        /// <summary>
        /// 処置行為薬剤コード
        /// </summary>
        private ArrayList m_arrTreatmentActionMedicineCode = new ArrayList();

        // 2016/04/14 中村 その他処置行為送信仕様追加
        /// <summary>
        /// 処置行為送信方法の切り替え設定
        /// </summary>
        private string m_strTreatmentActionSendType;

        /// <summary>
        /// 処置材料として扱う分類
        /// </summary>
        private ArrayList m_strEquipClassCode = new ArrayList();

        /// <summary>
        /// 処置行為まとめフラグ
        /// <value>true:まとめる／false:まとめない</value>
        /// </summary>
        private bool m_blnTreatmentActionUnitFlag;

        /// <summary>
        /// 補液送信フラグ
        /// <value>true:送信する／false:送信しない</value>
        /// </summary>
        private bool m_blnReplenishSendFlg;
        /// <summary>
        /// 補液・手技
        /// </summary>
        private string m_strReplenishProcedureCode;
        /// <summary>
        /// 補液・ルート項目コード
        /// </summary>
        private string m_strReplenishRouteCode;
        /// <summary>
        /// 補液・投与方法項目コード
        /// </summary>
        private string m_strReplenishMethodCode;

        // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
        /// <summary>
        /// 酸素吸入データなしフラグ
        /// <value>true:データなし／false:データあり</value>
        /// </summary>
        private bool m_blnOxygenNotDataFlag = false;
        /// <summary>
        /// 心電図データなしフラグ
        /// <value>true:データなし／false:データあり</value>
        /// </summary>
        private bool m_blnEcgNotDataFlag = false;
        /// <summary>
        /// 注射オーダデータなしフラグ
        /// <value>true:データなし／false:データあり</value>
        /// </summary>
        private bool m_blnInjectionNotDataFlag = false;
        // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応

        // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加
        /// <summary>
        /// 診療フリーモード
        /// <value>0:標準／1:成田記念</value>
        /// </summary>
        private string m_ExamFreeMode = "0";
        // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加

        // /// <summary>
        // /// 送信対象処置行為薬剤コード
        // /// </summary>
        // //private ArrayList m_arrSendTreatmentActionMedisineCode = new ArrayList();
        // private Hashtable m_hasSendTreatmentActionMedisineCode = new Hashtable();
        /// <summary>
        /// その他の処置情報リスト
        /// ※以下備考
        /// ※ハッシュキーはOCCUR_DATE
        /// ※ItemはArrayListとし、以下を保持
        /// ※  [0]薬剤コード
        /// ※  [1]院内コード
        /// ※  [2]分類
        /// ※  [3]項目コード
        /// ※  [4]実施日時
        /// ※  [5]汎用オーダ番号
        /// </summary>
        // private Dictionary<string, ArrayList> m_dictSendTreatmentList = new Dictionary<string, ArrayList>();
        private Dictionary<string, TreatActInfo> m_dictSendTreatActList = new Dictionary<string, TreatActInfo>();


        ///// <summary>
        ///// 酸素吸入有無フラグ
        ///// </summary>
        //private bool m_isOxygenFound = false;

        /// <summary>
        /// 酸素吸入情報リスト
        /// 汎用オーダ（人工腎臓）の処理時に、愁訴処置_処置内の酸素吸入情報（TREAT_CLASS=3）を一旦溜める
        /// ※以下備考
        /// ※ハッシュキーはOCCUR_DATE
        /// ※ItemはArrayListとし、以下を保持
        /// ※  [0]RESULT_NO        （三桁切り捨て。オーダ番号と紐付ける）
        /// ※  [1]OCCUR_DATE       （開始レコードと終了レコードの値を時間Detailに渡す）
        /// ※  [2]OXYGEN_START     （仕様不備で時刻が持てないため使用しないが、念のため）
        /// ※  [3]OXYGEN_TIME      （バグによりセット値が異なり使用しないが、念のため）
        /// ※  [4]OXYGEN_AMOUNT
        /// ※  [5]開始レコードのOCCUR_DATE （※開始終了をワンセットにするときにセット）
        /// ※  [6]汎用オーダ番号           （※送信後にセット）
        /// ※DBIOはパフォーマンス優先のため愁訴処置_処置の取得時にクエリでORDERをかけないので、
        /// ※本ビジネスロジック側でOCCUR_DATEでソートし、開始－終了の整合を取る必要がある
        /// </summary>
        //        private Hashtable m_hasSendOxygenList = new Hashtable();
        private Dictionary<string, ArrayList> m_dictSendOxygenList = new Dictionary<string, ArrayList>();

        // <<<<<【Ver.5.0.0.104】2011.02.23 horiuchi 処置送信対応

        // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応
        /// <summary>
        /// 心電図情報リスト
        /// 汎用オーダ（人工腎臓）の処理時に、愁訴処置_処置内の心電図情報（TREAT_CLASS=4）を一旦溜める
        /// ※以下備考
        /// ※ハッシュキーはOCCUR_DATE
        /// ※ItemはArrayListとし、以下を保持
        /// ※  [0]RESULT_NO                 （三桁切り捨て。オーダ番号と紐付ける）
        /// ※  [1]OCCUR_DATE                （開始レコードと終了レコードの値を時間Detailに渡す）
        /// ※  [2]ELECTROCARDIOGRAM_TYPE    （前後のフラグ）
        /// ※  [3]開始レコードのOCCUR_DATE  （※開始終了をワンセットにするときにセット）
        /// ※  [4]汎用オーダ番号            （※送信後にセット）
        /// ※DBIOはパフォーマンス優先のため愁訴処置_処置の取得時にクエリでORDERをかけないので、
        /// ※本ビジネスロジック側でOCCUR_DATEでソートし、開始－終了の整合を取る必要がある
        /// </summary>
        private Dictionary<string, ArrayList> m_dictSendEcgList = new Dictionary<string, ArrayList>();
        // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応

        // 2013/04/23 中村 科コード設定対応 Add Start
        /// <summary>
        /// 科コード設定
        /// </summary>
        Hashtable hstGroupCd = new Hashtable();
        /// <summary>
        /// 所属グループコードの利用有無
        /// </summary>
        private string m_PatGroupFlg = "1";
        // 2013/04/23 中村 科コード設定対応 Add Start     

        // 2013/10/31 阿部(浩) 同手技送信方法対応 Add Start
        /// <summary>
        /// 注射オーダ同手技まとめフラグ
        /// <value>0:まとめて送信／1:まとめずに送信</value>
        /// </summary>
        private string m_SameProcedureFlag = "0";
        // 2013/10/31 阿部(浩) 同手技送信方法対応 Add End

        // 2016/04/13 中村 ポップアップ通知対応 Add Start
        /// <summary>ポップアップ通知設定</summary>
        private string m_strPopupNotice = "0";
        // 2016/04/13 中村 ポップアップ通知対応 Add End

        // hasi-5.02加算対応（透析困難コメントの複数出力）Add Start
        /// <summary>システム設定（ID=134：レセプトメモ表示切替）</summary>
        private string m_strId0134 = "0";
        // hasi-5.02加算対応（透析困難コメントの複数出力）Add End
        #endregion


        #region メソッド定義・プラグインハンドラ
        /// <summary>
        /// プラグイン開始処理。
        /// </summary>
        /// <returns>リターンコード</param>
        protected override Fn3ReturnCode Initialize()
        {
            hstGroupCd.Clear();
            try
            {
                // メソッド開始ログ
                this.MethodStartLogOut(MethodBase.GetCurrentMethod());

                // アラームログフラグ
                m_bolAramChk = true;

                // -----------------------------------------------
                // 設定値取得
                // -----------------------------------------------
                // 初期設定情報から透析実績依頼科を取得
                m_strDapartment = string.Empty;
                Fn3ReturnCode retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_DAPARTMENT, ref m_strDapartment);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_DAPARTMENT, m_strDapartment));
                    return retCode;
                }
                // 初期設定情報から透析実績操作部署を取得
                m_strOrderWard = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_ORDER_WARD, ref m_strOrderWard);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_ORDER_WARD, m_strOrderWard));
                    return retCode;
                }
                // 初期設定情報から透析実績入力端末を取得
                m_strUpdateErminal = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_UPDATE_TERMINAL, ref m_strUpdateErminal);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_UPDATE_TERMINAL, m_strUpdateErminal));
                    return retCode;
                }
                // 初期設定情報から注射オーダ薬袋Ｉ／Ｆ使用フラグを取得
                m_strDrugBagFlg = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_DRUGBAG_FLG, ref m_strDrugBagFlg);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_DRUGBAG_FLG, m_strDrugBagFlg));
                    return retCode;
                }
                // 酸素吸入量コードを取得
                m_strOxygenInhalationCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_OXYGEN_INHALATION, ref m_strOxygenInhalationCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_OXYGEN_INHALATION, m_strOxygenInhalationCode));
                    return retCode;
                }
                // 抗凝固剤・手技を取得
                m_strAnticoagulantProcedureCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRANTICOAGULANT_PROCEDURE_CODE, ref m_strAnticoagulantProcedureCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRANTICOAGULANT_PROCEDURE_CODE, m_strAnticoagulantProcedureCode));
                    return retCode;
                }
                // 抗凝固剤・ルート項目コードを取得
                m_strAnticoagulantRouteCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRANTICOAGULANT_ROUTE_CODE, ref m_strAnticoagulantRouteCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRANTICOAGULANT_ROUTE_CODE, m_strAnticoagulantRouteCode));
                    return retCode;
                }
                // 抗凝固剤・投与方法項目コードを取得
                m_strAnticoagulantMethodCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRANTICOAGULANT_METHOD_CODE, ref m_strAnticoagulantMethodCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRANTICOAGULANT_METHOD_CODE, m_strAnticoagulantMethodCode));
                    return retCode;
                }
                // 透析液・手技を取得
                m_strHemodialysisProcedureCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRHEMODIALYSIS_PROCEDURE_CODE, ref m_strHemodialysisProcedureCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRHEMODIALYSIS_PROCEDURE_CODE, m_strHemodialysisProcedureCode));
                    return retCode;
                }
                // 透析液・ルート項目コード
                m_strHemodialysisRouteCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRHEMODIALYSIS_ROUTE_CODE, ref m_strHemodialysisRouteCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRHEMODIALYSIS_ROUTE_CODE, m_strHemodialysisRouteCode));
                    return retCode;
                }
                // 透析液・投与方法項目コードを取得
                m_strHemodialysisMethodCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRHEMODIALYSIS_METHOD_CODE, ref m_strHemodialysisMethodCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRHEMODIALYSIS_METHOD_CODE, m_strHemodialysisMethodCode));
                    return retCode;
                }
                // 送信患者IDの桁数を取得
                string strBuf = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_SEND_PATID_FIGURES, ref strBuf);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_SEND_PATID_FIGURES, strBuf));
                    return retCode;
                }
                m_iSendDispPatIdFigures = int.Parse(strBuf);
                // 連携対象動作モードを取得
                m_strConnectType = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_CONNECT_TYPE, ref m_strConnectType);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_CONNECT_TYPE, m_strConnectType));
                    return retCode;
                }
                // I/F部品使用モードを取得
                m_strLibType = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_LIBRARY_TYPE, ref m_strLibType);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_LIBRARY_TYPE, m_strLibType));
                    return retCode;
                }

                // 2011/01/07 中村 依頼医師に患者基本情報.担当医を設定するよう変更
                // デフォルト医師
                m_strDefaultStaffCd = string.Empty;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_DEFAULT_STAFF_CODE, ref m_strDefaultStaffCd);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_DEFAULT_STAFF_CODE, m_strDefaultStaffCd));
                    return retCode;
                }

                // 2011/05/13 中村 指示医対応
                // 指示医フラグ
                m_strIndicatorFlg = string.Empty;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_INDICATOR_FLG, ref m_strIndicatorFlg);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_INDICATOR_FLG, m_strIndicatorFlg));
                    return retCode;
                }

                // >>>>>【Ver.5.0.0.104】2011.02.23 horiuchi 処置送信対応
                // 酸素吸入行為送信フラグ
                string strTemp = string.Empty;
                m_blnOxygenActionSendFlag = false;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_OXYGENACTION_SEND_FLAG, ref strTemp);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_OXYGENACTION_SEND_FLAG, strTemp));
                    return retCode;
                }
                if (strTemp.Equals("1"))
                {
                    m_blnOxygenActionSendFlag = true;
                }
                // 酸素吸入行為コード
                m_strOxygenActionCode = string.Empty;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_OXYGENACTION_CODE, ref m_strOxygenActionCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_OXYGENACTION_CODE, m_strOxygenActionCode));
                    return retCode;
                }
                // コード未設定ならフラグを落とす
                if (m_strOxygenActionCode.Equals(string.Empty))
                {
                    m_blnOxygenActionSendFlag = false;
                }
                // 処置行為送信フラグ
                strTemp = string.Empty;
                m_blnTreatmentActionSendFlag = false;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_SEND_FLAG, ref strTemp);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_SEND_FLAG, strTemp));
                    return retCode;
                }
                if (strTemp.Equals("1"))
                {
                    m_blnTreatmentActionSendFlag = true;
                }

                // 処置行為まとめフラグ
                strTemp = string.Empty;
                m_blnTreatmentActionUnitFlag = false;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_UNITE_FLAG, ref strTemp);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_UNITE_FLAG, strTemp));
                    return retCode;
                }
                if (strTemp.Equals("0"))
                {
                    m_blnTreatmentActionUnitFlag = true;
                }

                // 補液送信フラグを設定
                strTemp = string.Empty;
                m_blnReplenishSendFlg = false;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_REPLENISH_SEND_FLAG, ref strTemp);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_UNITE_FLAG, strTemp));
                    return retCode;
                }
                if (strTemp.Equals("1"))
                {
                    m_blnReplenishSendFlg = true;
                }

                // 補液・手技を取得
                m_strReplenishProcedureCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRREPLENISH_PROCEDURE_CODE, ref m_strReplenishProcedureCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRREPLENISH_PROCEDURE_CODE, m_strReplenishProcedureCode));
                    return retCode;
                }
                // 補液・ルート項目コード
                m_strReplenishRouteCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRREPLENISH_ROUTE_CODE, ref m_strReplenishRouteCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRREPLENISH_ROUTE_CODE, m_strReplenishRouteCode));
                    return retCode;
                }
                // 補液・投与方法項目コードを取得
                m_strReplenishMethodCode = string.Empty;
                retCode = GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRREPLENISH_METHOD_CODE, ref m_strReplenishMethodCode);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_STRREPLENISH_METHOD_CODE, m_strReplenishMethodCode));
                    return retCode;
                }

                // 処置行為薬剤コード
                string[] strArr;

                // >>>>> 20件版
                strTemp = string.Empty;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_MEDICINE_CODES, ref strTemp);
                if (retCode.IsError || retCode.IsException)
                {
                    // エラー(先にアラーム用トレース出力)
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_MEDICINE_CODES, strTemp));
                    return retCode;
                }
                // バラす
                strArr = strTemp.Split(',');
                for (int i = 0; i < strArr.Length; i++)
                {
                    // 20件を超過したら無視
                    if (20 <= i)
                    {
                        this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_INIT, "処置行為薬剤コードの定義数が20件を越えています。");
                        break;
                    }
                    if (!strArr[i].Trim().Equals(string.Empty))
                    {
                        // 重複していないときのみ
                        if (!m_arrTreatmentActionMedicineCode.Contains(strArr[i].Trim()))
                        {
                            m_arrTreatmentActionMedicineCode.Add(strArr[i].Trim());
                        }
                        else
                        {
                            this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_INIT, string.Format("処置行為薬剤コードの重複定義({0})", strArr[i].Trim()));
                        }
                    }
                }
                // <<<<< 20件版

                // 2013/04/23 中村 科コード設定対応 Add Start
                // 個別設定値を読み込む
                string strGroupFlg = string.Empty;
                Fn3ReturnCode retCodeGroupFlg = this.GetInitialValue("1", CSICommonConst.SYS_SECT_GROUPCD, CSICommonConst.SYS_KEY_PAT_GROUP_FLG, ref strGroupFlg);
                if (retCodeGroupFlg.IsError || retCodeGroupFlg.IsException || string.IsNullOrEmpty(strGroupFlg))
                {
                    retCode = CSIReturnCode.ERR_DIALYSIS_SND_GROUPCD_FAILED;

                    this.TraceOut(retCode,
                                  string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                CSICommonConst.SYS_SECT_GROUPCD,
                                                CSICommonConst.SYS_KEY_PAT_GROUP_FLG,
                                                ""));
                    return retCode;
                }
                else
                {
                    m_PatGroupFlg = strGroupFlg;
                }

                if (m_PatGroupFlg.Equals("0"))
                {
                    Fn3ReturnCode retCodeGroupCd = this.GetInitialValue("1", CSICommonConst.SYS_SECT_GROUPCD, ref hstGroupCd);
                    if (retCodeGroupCd.IsError || retCodeGroupCd.IsException)
                    {
                        retCode = CSIReturnCode.ERR_DIALYSIS_SND_GROUPCD_FAILED;

                        this.TraceOutWrap(retCode,
                                          string.Format(CSICommonConst.SYS_LOG_FORMAT,
                                                        CSICommonConst.SYS_SECT_GROUPCD,
                                                        "",
                                                        ""));
                        return retCode;
                    }

                    // 所属グループコードの利用設定をハッシュから取り除く
                    if (hstGroupCd.ContainsKey(CSICommonConst.SYS_KEY_PAT_GROUP_FLG))
                    {
                        hstGroupCd.Remove(CSICommonConst.SYS_KEY_PAT_GROUP_FLG);
                    }

                    // ベッド番号・科コード対応
                    string strOutXml = string.Empty;
                    Fn3ReturnCode retExecQuery = base.DBExecQuery("00002", "<rootNode />", ref strOutXml);
                    if (retExecQuery.IsError || retExecQuery.IsException)
                    {
                        retCode = CSIReturnCode.ERR_DIALYSIS_SND_MSTBED_FAILED;
                        this.TraceOutWrap(retCode);
                        return retCode;
                    }
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(strOutXml);

                    if (xmlDoc.SelectNodes("//rootNode/MST_BED/BED_NO").Count == 0)
                    {
                        retCode = CSIReturnCode.ERR_DIALYSIS_SND_MSTBED_FAILED;
                        this.TraceOutWrap(retCode);
                        return retCode;
                    }
                    string strNgBedNo = string.Empty;
                    foreach (XmlNode nodeBed in xmlDoc.SelectNodes("//rootNode/MST_BED/BED_NO"))
                    {
                        if (hstGroupCd.ContainsKey(nodeBed.InnerText) == false ||
                            hstGroupCd[nodeBed.InnerText].ToString().Length != 5)
                        {
                            retCode = CSIReturnCode.ERR_DIALYSIS_SND_MSTPATGROUP_FAILED;
                            if (!string.IsNullOrEmpty(strNgBedNo)) strNgBedNo += ",";
                            strNgBedNo += nodeBed.InnerText;
                        }
                    }
                    if (retCode == CSIReturnCode.ERR_DIALYSIS_SND_MSTPATGROUP_FAILED)
                    {
                        this.TraceOutWrap(retCode,
                                      string.Format("登録されていないベッド番号：{0}", strNgBedNo));
                        return retCode;
                    }
                }
                // 2013/04/23 中村 科コード設定対応 Add End

                // 2013/10/31 阿部(浩) 同手技送信方法対応 Add Start
                string strValue = string.Empty;
                Fn3ReturnCode ret = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_SAME_PROCEDURE_FLG, ref strValue);
                if (ret.IsError || ret.IsException || string.IsNullOrEmpty(strValue))
                {
                    // 取得失敗 or 未設定
                    retCode = CSIReturnCode.ERR_DIALYSIS_SND_SAME_PROCEDURE_FAILED;
                    this.TraceOut(retCode, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_SAME_PROCEDURE_FLG, ""));
                    
                    return retCode;
                }
                else
                {
                    this.m_SameProcedureFlag = strValue;
                }
                // 2013/10/31 阿部(浩) 同手技送信方法対応 Add End

                // 2016/04/14 中村 その他処置行為送信仕様追加 Add Start
                strValue = string.Empty;
                Fn3ReturnCode retTreatSendType = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_SEND_TYPE, ref strValue);
                if (retTreatSendType.IsError || retTreatSendType.IsException || string.IsNullOrEmpty(strValue))
                {
                    // 取得失敗 or 未設定
                    retTreatSendType = CSIReturnCode.WNG_DIALYSIS_SND_TREATACTION_SEND_TYPE;
                    this.TraceOut(retTreatSendType, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_TREATMENTACTION_SEND_TYPE, ""));
                    m_strTreatmentActionSendType = "0";
                }
                else
                {
                    this.m_strTreatmentActionSendType = strValue;
                }
                
                strValue = string.Empty;
                Fn3ReturnCode retEquipClassCodes = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_EQUIP_CLASS_CODES, ref strValue);
                if (retEquipClassCodes.IsError || retEquipClassCodes.IsException)
                {
                    // 取得失敗 or 未設定
                    retEquipClassCodes = CSIReturnCode.WNG_DIALYSIS_SND_EQUIP_CLASS_CODES;
                    this.TraceOut(retEquipClassCodes, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_EQUIP_CLASS_CODES, ""));
                }
                else
                {
                    string[] ClassCodes = strValue.Split(',');
                    foreach(string strClassCode in ClassCodes)
                    {
                        if (!string.IsNullOrEmpty(strClassCode))
                        {
                            m_strEquipClassCode.Add(strClassCode);
                        }
                    }
                }

                // 2016/04/14 中村 その他処置行為送信仕様追加 Add End

                // 2016/04/13 中村 ポップアップ通知対応 Add Start
                strValue = string.Empty;
                Fn3ReturnCode retPopup = base.GetInitialValue("1", CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_POPUP_NOTICE, ref strValue);
                if (retPopup.IsError || retPopup.IsException || string.IsNullOrEmpty(strValue))
                {
                    // 取得失敗 or 未設定
                    retPopup = CSIReturnCode.WNG_DIALYSIS_SND_POPUP_NOTICE;
                    this.TraceOut(retPopup, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_COMMON, CSICommonConst.SYS_KEY_POPUP_NOTICE, ""));
                }
                else
                {
                    this.m_strPopupNotice = strValue;
                }
                // 2016/04/13 中村 ポップアップ通知対応 Add End

                // コードがゼロ件ならフラグを落とす
                if (m_arrTreatmentActionMedicineCode.Count <= 0)
                {
                    m_blnTreatmentActionSendFlag = false;
                }
                // <<<<<【Ver.5.0.0.104】2011.02.23 horiuchi 処置送信対応

                // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応
                // 心電図行為送信フラグ
                strTemp = string.Empty;
                m_blnEcgActionSendFlag = false;
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_ECGACTION_SEND_FLAG, ref strTemp);
                if (retCode.IsError || retCode.IsException)
                {
                    // 取得失敗 or 未設定
                    retPopup = CSIReturnCode.WNG_DIALYSIS_SND_ECGACTION_FLAG;
                    this.TraceOut(retPopup, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_ECGACTION_SEND_FLAG, ""));
                }
                if (strTemp.Equals("1"))
                {
                    m_blnEcgActionSendFlag = true;

                    // 心電図行為コード
                    m_strEcgActionCode = string.Empty;
                    retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_ECGACTION_CODE, ref m_strEcgActionCode);
                    if (retCode.IsError || retCode.IsException)
                    {
                        // エラー(先にアラーム用トレース出力)
                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE);
                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_GETINITIALVALUE, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_ECGACTION_CODE, m_strEcgActionCode));
                        return retCode;
                    }
                    // コード未設定ならフラグを落とす
                    if (m_strEcgActionCode.Equals(string.Empty))
                    {
                        m_blnEcgActionSendFlag = false;
                    }
                }
                
                // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応

                // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加
                // 診療フリーモード
                strTemp = string.Empty;
                m_ExamFreeMode = "0";
                retCode = base.GetInitialValue("1", CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_CLINICAL_FREE_MODE, ref strTemp);
                if (retCode.IsError || retCode.IsException)
                {
                    // 取得失敗 or 未設定
                    retPopup = CSIReturnCode.WNG_DIALYSIS_SND_CLINICAL_FREE_MODE;
                    this.TraceOut(retPopup, string.Format(CSICommonConst.SYS_LOG_FORMAT, CSICommonConst.SYS_SECT_DIALYSISSND, CSICommonConst.SYS_KEY_CLINICAL_FREE_MODE, ""));
                }
                else
                {
                    m_ExamFreeMode = strTemp;
                }
                
                // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 成田記念モード追加

#if !WITHOUT_INTERFACE
                // -----------------------------------------------
                // 部品オブジェクト作成
                // -----------------------------------------------
                // シーエスアイ外部I/F部品のオブジェクト作成（共通）
                m_objCSICOMMON = this.CreateObjectWrap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_COMMON, m_strLibType));
                if (m_objCSICOMMON == null)
                {
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_COMMON, CSICommonMethod.GetLastErrorString());
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_COMMON,
                        string.Format("LibName=\"{0}\", エラー内容=\"{1}\"", CSICommonConst.CSIPROGRAMID_COMMON, CSICommonMethod.GetLastErrorString()));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    return Fn3ReturnCode.Error;
                }
                // シーエスアイ外部I/F部品のオブジェクト作成（汎用オーダ登録／変更）
                m_objCSIORDER = this.CreateObjectWrap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_ORDER, m_strLibType));
                if (m_objCSIORDER == null)
                {
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_ORDER, CSICommonMethod.GetLastErrorString());
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_ORDER,
                        string.Format("LibName=\"{0}\", エラー内容=\"{1}\"", CSICommonConst.CSIPROGRAMID_ORDER, CSICommonMethod.GetLastErrorString()));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    return Fn3ReturnCode.Error;
                }
                // シーエスアイ外部I/F部品のオブジェクト作成（注射オーダ登録／変更）
                m_objCSIORDERInjection = this.CreateObjectWrap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_ORDER, m_strLibType));
                if (m_objCSIORDERInjection == null)
                {
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_ORDERINJECTION, CSICommonMethod.GetLastErrorString());
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_ORDERINJECTION,
                        string.Format("LibName=\"{0}\", エラー内容=\"{1}\"", CSICommonConst.CSIPROGRAMID_ORDER, CSICommonMethod.GetLastErrorString()));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    return Fn3ReturnCode.Error;
                }
                // シーエスアイ外部I/F部品のオブジェクト作成（患者診療フリー登録／変更）
                m_objCSIEXAMRREE = this.CreateObjectWrap(CSICommonMethod.GetLibName(CSICommonConst.CSIPROGRAMID_EXAMFREE, m_strLibType));
                if (m_objCSIEXAMRREE == null)
                {
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_EXAMFREE, CSICommonMethod.GetLastErrorString());
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_CREATEOBJECT_EXAMFREE,
                        string.Format("LibName=\"{0}\", エラー内容=\"{1}\"", CSICommonConst.CSIPROGRAMID_EXAMFREE, CSICommonMethod.GetLastErrorString()));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    return Fn3ReturnCode.Error;
                }

                // hasi-5.02加算対応（透析困難コメントの複数出力）Add Start
                // システム設定(ID=134)取得
                string strInXml = string.Empty;
                int id = 134;
                using (StringWriter sw = new StringWriter())
                using (XmlTextWriter TxmlW = new XmlTextWriter(sw))
                {
                    TxmlW.WriteStartElement("rootNode");
                    TxmlW.WriteElementString("ID", id.ToString());
                    TxmlW.WriteEndElement();
                    strInXml = sw.ToString();
                }
                string strOutXmlVal = string.Empty;
                string strGetValue = string.Empty;
                retCode = base.DBExecQuery("20001", strInXml, ref strOutXmlVal);
                if (retCode.IsError || retCode.IsException)
                {
                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_MAKEDATA_EXAMRREE, string.Format("オーダ・診療フリー内容・システム設定(ID={0})：値が空または異常です。", id.ToString()));
                }
                else
                {
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(strOutXmlVal);
                    // レセプトメモ表示切替を取得
                    strGetValue = Fn3ComTool.GetXmlValue(xmlDoc.LastChild, "//rootNode/SYS_SYSTEM_DEFINE/VALUE");
                }
                this.m_strId0134 = "0";
                if (true == "1".Equals(strGetValue))
                {
                    // DBの値を取得する
                    this.m_strId0134 = strGetValue;
                }
                // hasi-5.02加算対応（透析困難コメントの複数出力）Add End
#endif

                // メソッド終了ログ
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
                return Fn3ReturnCode.Success;
            }
            catch (Exception ex)
            {
                // エラー
                this.ErrorTraceOutWrap(CSIReturnCode.FTL_DIALYSIS_SND_EX_INIT, ex);
                return Fn3ReturnCode.Error;
            }
        }

        /// <summary>
        /// プラグイン送信実行処理
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        /// <returns>リターンコード</param>
        protected override Fn3ReturnCode Execute(Fn3ExecuteInfo exeInfo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // -------------------------------------------------
            // 初期化
            // -------------------------------------------------
            // アラーム出力フラグ
            // ※１イベントでアラームは一回のみとする
            m_bolAramChk = true;
            // ロールバックフラグ
            bool bolRollBack = false;
            // リトライフラグ
            bool bolReTry = false;
            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
            // 戻り値
            bool bResult = true;
            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化

            // 2016/04/14 中村 ポップアップ通知
            bool IsSuccess = true;

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //// オーダNo・汎用オーダ
            //string strAllPurposeOrderRetNo = string.Empty;
            // オーダNo・汎用オーダ（人工腎臓）
            string strAllPurposeOrderRetNo = string.Empty;
            // オーダNo・汎用オーダ（酸素吸入）
            string strAllPurposeOxygenOrderRetNo = string.Empty;
            // オーダNo・汎用オーダ（心電図）
            string strAllPurposeEcgOrderRetNo = string.Empty;
            // オーダNo・汎用オーダ（その他の処置）
            string strAllPurposeTreatmentOrderRetNo = string.Empty;
            //// 酸素吸入有無フラグOFF
            //m_isOxygenFound = false;
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

            // オーダNo・注射オーダ
            string strInjectionOrderRetNo = string.Empty;
            // オーダNo・診療フリー
            string strExamRetNo = string.Empty;

            // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
            //// ダンプログデータ・汎用オーダ送信
            //DumpParameter objOrderExecData = new DumpParameter("汎用オーダ送信", null, null, null, null);
            // ダンプログデータ・汎用オーダ（人工腎臓）送信
            DumpParameter objOrderExecData = new DumpParameter("汎用オーダ（人工腎臓）送信", null, null, null, null);
            // ダンプログデータ・汎用オーダ（酸素吸入）送信
            ArrayList oxygenDumpParamList = new ArrayList();
            DumpParameter objOxygenOrderExecData = new DumpParameter("汎用オーダ（酸素吸入）送信", null, null, null, null);
            // ダンプログデータ・汎用オーダ（心電図）送信
            ArrayList ecgDumpParamList = new ArrayList();
            DumpParameter objEcgOrderExecData = new DumpParameter("汎用オーダ（心電図）送信", null, null, null, null);
            // ダンプログデータ・汎用オーダ（その他の処置）送信
            ArrayList treatDumpParamList = new ArrayList();
            DumpParameter objTreatmentOrderExecData = new DumpParameter("汎用オーダ（その他の処置）送信", null, null, null, null);
            // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

            // ダンプログデータ・注射オーダ送信
            DumpParameter objInjectionExecOrderData = new DumpParameter("注射オーダ送信", null, null, null, null);
            // ダンプログデータ・患者診療フリー送信
            DumpParameter objExamFreeExecData = new DumpParameter("患者診療フリー送信", null, null, null, null);
            try
            {
#if DEBUG
                // ファイルにexeInfoを書き出す
                using (System.IO.StreamWriter streamWriter = new System.IO.StreamWriter(@"D:\" + exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/PATID").InnerText + "_CSICoopDialysisSendStd_exeInfo.xml"))
                {
                    streamWriter.WriteLine(exeInfo.CoopInfoXML.InnerXml);
                }
                this.TraceOut("■透析実績送信・Debug版■ ＜読み込み＞");
                this.TraceOut("■透析実績送信・Debug版■ exeInfo.SendClass＝" + exeInfo.SendClass.ToString());
                this.TraceOut("■透析実績送信・Debug版■ exeInfo.SendHistMemo＝" + exeInfo.SendHistMemo.ToString());
                this.TraceOut("■透析実績送信・Debug版■ this.SendHistMemo＝" + this.SendHistMemo);
                this.TraceOut("■透析実績送信・Debug版■ PatID＝" + exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/PATID").InnerText + "   PatDispID＝" + exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DISP_PATID").InnerText);
#endif
                // -------------------------------------------------
                // 暫定対策　
                // -------------------------------------------------
                // this.SendHistMemoに変な値が入ってくる。フレームワークのバグと思われるがバグ対応を待つ時間はないのでexeInfo.SendHistMemoで上書する。
                this.SendHistMemo = exeInfo.SendHistMemo;

                // -------------------------------------------------
                // ログ・アラーム用出力値を取得する(基本的な値なのでエラーチェックはしない)
                // -------------------------------------------------
                // 処理区分を取得
                m_strSendClass = exeInfo.SendClass;
                // 患者基本情報・表示用患者IDを取得・0詰め12桁
                XmlNode xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/PATID");
                m_strPatID = xmlNode.InnerText;
                m_strPatID = m_strPatID.PadLeft(12, '0');
                // 患者基本情報・表示用患者IDを取得・0詰め12桁
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/DISP_PATID");
                m_strPatDispID = xmlNode.InnerText;
                m_strPatDispID = m_strPatDispID.PadLeft(12, '0');
                // 患者基本情報・患者名を取得
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/PAT_BASIC_INFO/NAME");
                m_strPatName = xmlNode.InnerText;
                // 透析実績履歴・透析番号を取得
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/DIALYSIS_NO");
                m_strDialysisNo = xmlNode.InnerText;
                // 透析実績履歴・版番号を取得
                xmlNode = exeInfo.CoopInfoXML.SelectSingleNode("//rootNode/RST_DIALYSIS_HST/EDITION");
                m_strEdition = xmlNode.InnerText;

#if !WITHOUT_INTERFACE
                // -------------------------------------------------
                // MIRAIs-DBへの接続する
                // -------------------------------------------------
                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                //if (!CSICommonMethod.pDbOpen(m_objCSICOMMON, ref m_objMiraisDB, ref CSICommon.colERR))
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbOpen() Start");
                bResult = CSICommonMethod.pDbOpen(m_objCSICOMMON, ref m_objMiraisDB, ref CSICommon.colERR);
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbOpen() End");
                if (bResult == false)
                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                {
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_DBOPEN, CSICommonMethod.GetLastErrorString());
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_DBOPEN,
                        string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", m_strPatDispID, CSICommonMethod.GetLastErrorString()));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化

                    // 2016/04/14 中村 ポップアップ通知
                    IsSuccess = false;
                    return Fn3ReturnCode.Error;
                }

                // -------------------------------------------------
                // トランザクション開始する
                // -------------------------------------------------
                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                //if (!CSICommonMethod.pDbBeginTrn(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR))
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbBeginTrn() Start");
                bResult = CSICommonMethod.pDbBeginTrn(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR);
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbBeginTrn() End");
                if (bResult == false)
                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                {
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_DBTRANSACTION, CSICommonMethod.GetLastErrorString());
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_DBTRANSACTION,
                        string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", m_strPatDispID, CSICommonMethod.GetLastErrorString()));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化

                    // 2016/04/14 中村 ポップアップ通知
                    IsSuccess = false;
                    return Fn3ReturnCode.Error;
                }
#endif
                // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                //// -------------------------------------------------
                //// 汎用オーダデータを送信する
                //// -------------------------------------------------
                //object[] sendOrderDataWrap = new object[1];
                //if (!SendAllPurposeOrderMgr(exeInfo, out strAllPurposeOrderRetNo, out bolReTry))
                //{
                //    //// ダンプログを格納
                //    sendOrderDataWrap[0] = CSICommon.colORDER;
                //    objOrderExecData = new DumpParameter("汎用オーダ送信", sendOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false);
                //    // エラー
                //    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_ORDER);
                //    // ロールバックフラグを立てる
                //    bolRollBack = true;
                //    return Fn3ReturnCode.Error;
                //}
                //// ダンプログを格納
                //sendOrderDataWrap[0] = CSICommon.colORDER;
                //objOrderExecData = new DumpParameter("汎用オーダ送信", sendOrderDataWrap, CSICommon.varOUTPARAM, null, true);

                //// 酸素吸入有無フラグをリセット
                //m_isOxygenFound = false;

                // 酸素吸入送信リストをクリア
                m_dictSendOxygenList.Clear();

                // 心電図送信リストをクリア
                m_dictSendEcgList.Clear();

                // その他処置行為リストをクリア
                // m_dictSendTreatmentList.Clear();
                m_dictSendTreatActList.Clear();

                // -------------------------------------------------
                // 汎用オーダ（人工腎臓）を送信する
                // -------------------------------------------------
                #region 汎用オーダ（人工腎臓）
                string actionCodeEmpty = string.Empty;
                object[] sendOrderDataWrap = new object[1];
                // if (0 > SendAllPurposeOrderMgr(exeInfo, out strAllPurposeOrderRetNo, out bolReTry, OrderSendMode.Dialisys, ref actionCodeEmpty, string.Empty, null))
                if (0 > SendAllPurposeOrderMgr(exeInfo, out strAllPurposeOrderRetNo, out bolReTry, OrderSendMode.Dialisys, null, null, null))
                {
                    //// ダンプログを格納
                    sendOrderDataWrap[0] = CSICommon.colORDER;
                    objOrderExecData = new DumpParameter("汎用オーダ（人工腎臓）送信", sendOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false);
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_ORDER);
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_ORDER, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    // ロールバックフラグを立てる
                    bolRollBack = true;
                    
                    // 2016/04/14 中村 ポップアップ通知
                    IsSuccess = false;
                    return Fn3ReturnCode.Error;
                }
                // ダンプログを格納
                sendOrderDataWrap[0] = CSICommon.colORDER;
                objOrderExecData = new DumpParameter("汎用オーダ（人工腎臓）送信", sendOrderDataWrap, CSICommon.varOUTPARAM, null, true);
                #endregion

                // -------------------------------------------------
                // 汎用オーダ（酸素吸入）を送信する
                // -------------------------------------------------
                #region 汎用オーダ（酸素吸入）
                actionCodeEmpty = string.Empty;

                // 酸素吸入送信数
                int intOxygenCnt = 0;

                // 酸素吸入送信リスト（オーダ番号保持でも参照するのでここで定義）
                // Hashtable hasOxygenList = new Hashtable();

                ArrayList arrOxygenKey = new ArrayList();
                ArrayList arrOxygenList = new ArrayList();

                if (m_blnOxygenActionSendFlag)
                {
                    #region 酸素吸入オーダ複数化に伴い見直し
                    //object[] sendOxygenOrderDataWrap = new object[1];
                    //int iRetVal = SendAllPurposeOrderMgr(exeInfo, out strAllPurposeOxygenOrderRetNo, out bolReTry, OrderSendMode.Oxygen, ref actionCodeEmpty, string.Empty, null);
                    //if (0 > iRetVal)
                    //{
                    //    //// ダンプログを格納
                    //    sendOxygenOrderDataWrap[0] = CSICommon.colORDER;
                    //    objOxygenOrderExecData = new DumpParameter("汎用オーダ（酸素吸入）送信", sendOxygenOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false);
                    //    // エラー
                    //    this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_OXYGEN_ORDER);
                    //    // ロールバックフラグを立てる
                    //    bolRollBack = true;
                    //    return Fn3ReturnCode.Error;
                    //}

                    //// 送信したときのみDUMPを出す
                    //if (iRetVal == 1)
                    //{
                    //    // ダンプログを格納
                    //    sendOxygenOrderDataWrap[0] = CSICommon.colORDER;
                    //    objOxygenOrderExecData = new DumpParameter("汎用オーダ（酸素吸入）送信", sendOxygenOrderDataWrap, CSICommon.varOUTPARAM, null, true);
                    //}
                    #endregion

                    // 1.取得済みの今回酸素吸入データをキー（発生日時）でソート
                    SortedDictionary<string, ArrayList> sortedOxygenList = new SortedDictionary<string, ArrayList>(m_dictSendOxygenList);

                    // 2.開始と終了の整合判定をしつつ送信用リストを作成
                    bool isStarted = false;
                    string strStartOccurDate = string.Empty;
                    foreach (KeyValuePair<string, ArrayList> kvpOxygen in sortedOxygenList)
                    {
                        // 酸素吸入開始していない
                        if (!isStarted)
                        {
                            // レコードの使用量が空値
                            if (kvpOxygen.Value[4].ToString() == string.Empty)
                            {
                                // 開始レコードが来た（正しい順序）
                                // 酸素吸入開始
                                isStarted = true;
                                // 開始レコードの発生日時を保持
                                strStartOccurDate = kvpOxygen.Value[1].ToString();
                            }
                            // 空値でない
                            else
                            {
                                // 開始していないのに終了レコードが来た
                                // ※無視する
                            }
                        }
                        // 開始している
                        else
                        {
                            // レコードの使用量が空値
                            if (kvpOxygen.Value[4].ToString() == string.Empty)
                            {
                                // 開始しているのにまた開始レコードが来た
                                // ※開始のまま続行（前回の開始を無視）

                                // 開始レコードの発生日時を保持
                                strStartOccurDate = kvpOxygen.Value[1].ToString();
                            }
                            // 空値でない
                            else
                            {
                                // 酸素吸入数チェック
                                if (OXYGEN_LIMIT_COUNT <= intOxygenCnt)
                                {
                                    // エラー
                                    // 酸素吸入の最大送信数10件を超えた
                                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_OXYGEN_ORVER);
                                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_OXYGEN_ORVER, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                                    break;
                                }

                                // 終了レコードが来た（正しい順序）
                                // 酸素吸入終了
                                isStarted = false;
                                // 終了レコードに、開始レコードの発生日時をセット
                                kvpOxygen.Value.Add(strStartOccurDate);
                                // 終了レコードを送信用リストに蓄積
                                // ※このときハッシュキーを実績番号にする
                                // hasOxygenList.Add(kvpOxygen.Value[0], kvpOxygen.Value);
                                arrOxygenKey.Add(kvpOxygen.Value[0]);
                                arrOxygenList.Add(kvpOxygen.Value);

                                // 酸素吸入数をインクリメント
                                intOxygenCnt++;
                            }
                        }
                    }

                    // 3.送信履歴に含まれる酸素吸入実績番号を抜き出して、2のリストとマージ
                    ArrayList arrSendedOxygenList = GetSendedOxygenResultNoList(exeInfo);
                    if (arrSendedOxygenList != null)
                    {
                        foreach (ArrayList arr in arrSendedOxygenList)
                        {
                            // 送信用リストのキーに、送信済みの実績番号がなければ
                            // if (!hasOxygenList.ContainsKey(arr[0].ToString()))
                            if (!arrOxygenKey.Contains(arr[0].ToString()))
                            {
                                ArrayList arrAdd = new ArrayList();
                                // ※  [0]RESULT_NO
                                arrAdd.Add(arr[0]);
                                // ※  [1]OCCUR_DATE
                                arrAdd.Add(string.Empty);
                                // ※  [2]OXYGEN_START
                                arrAdd.Add(string.Empty);
                                // ※  [3]OXYGEN_TIME
                                arrAdd.Add(string.Empty);
                                // ※  [4]OXYGEN_AMOUNT
                                arrAdd.Add(string.Empty);
                                // ※  [5]開始レコードのOCCUR_DATE
                                arrAdd.Add(string.Empty);
                                // ※  [6]汎用オーダ番号 
                                arrAdd.Add(arr[1]);
                                // 削除用のアイテムを追加
                                // hasOxygenList.Add(arr[0], arrAdd);
                                arrOxygenList.Add(arrAdd);
                            }
                            // あったら
                            else
                            {
                                int index = 0;
                                for (int i = 0; i < arrOxygenKey.Count; i++)
                                {
                                    if (arr[0].ToString() == arrOxygenKey[i].ToString())
                                    {
                                        index = i;
                                        break;
                                    }
                                }

                                // ここでオーダ番号を渡しておく
                                // ArrayList arrSend = (ArrayList)hasOxygenList[arr[0].ToString()];
                                ArrayList arrSend = (ArrayList)arrOxygenList[index];

                                // 「親番子番カンマ区切り」の形式に変換
                                string fullOrderNo = arr[1].ToString();
                                string sepaOrderNo = fullOrderNo.Substring(0, 13) + "," + fullOrderNo.Substring(13);

                                // アイテムの末尾に追加
                                arrSend.Add(sepaOrderNo);
                            }
                        }
                    }

                    // 2015/09/03 中村 受入指摘対応(#4949) Add
                    ArrayList arrRemoveList = new ArrayList();

                    // 4.上記3のリストを回して1オーダずつ送信
                    // foreach (ArrayList arrOxygen in hasOxygenList.Values)
                    foreach (ArrayList arrOxygen in arrOxygenList)
                    {
                        object[] sendOxygenOrderDataWrap = new object[1];

                        // int iRetVal = SendAllPurposeOrderMgr(exeInfo, out strAllPurposeOxygenOrderRetNo, out bolReTry, OrderSendMode.Oxygen, ref actionCodeEmpty, string.Empty, arrOxygen);
                        int iRetVal = SendAllPurposeOrderMgr(exeInfo, out strAllPurposeOxygenOrderRetNo, out bolReTry, OrderSendMode.Oxygen, null, arrOxygen, null);
                        if (0 > iRetVal)
                        {
                            // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                            // オーダディテール0件以外のエラーの場合
                            if (m_blnOxygenNotDataFlag == false)
                            {
                            // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                                //// ダンプログを格納
                                sendOxygenOrderDataWrap[0] = CSICommon.colORDER;
                                objOxygenOrderExecData = new DumpParameter("汎用オーダ（酸素吸入）送信", sendOxygenOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false);
                                // エラー
                                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                                //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_OXYGEN_ORDER);
                                base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_OXYGEN_ORDER, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                                // ロールバックフラグを立てる
                                bolRollBack = true;

                                // 2016/04/14 中村 ポップアップ通知
                                IsSuccess = false;
                                return Fn3ReturnCode.Error;

                            // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                            }
                            else
                            {
                                // ワーニングログを出力して処理を継続
                                base.TraceOut(CSIReturnCode.WNG_DIALYSIS_SND_OXYGEN_NOT_DATA, string.Format("患者ID=\"{0}\"", m_strPatDispID));

                                // 2015/09/03 中村 受入指摘対応(#4949) Add Start
                                arrRemoveList.Add(arrOxygen);
                                // 2015/09/03 中村 受入指摘対応(#4949) Add End
                                continue;
                            }
                            // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                        }
                        // オーダ番号を個別に保持
                        if (arrOxygen.Count < 7)
                        {
                            // ※送信リストに保持
                            arrOxygen.Add(strAllPurposeOxygenOrderRetNo);
                        }

                        // 送信したときのみDUMPを出す
                        if (iRetVal == 1)
                        {
                            // ダンプログを格納
                            sendOxygenOrderDataWrap[0] = CSICommon.colORDER;
                            // 複数ありえるのでリストに溜める
                            oxygenDumpParamList.Add(new DumpParameter("汎用オーダ（酸素吸入）送信", sendOxygenOrderDataWrap, CSICommon.varOUTPARAM, null, true));
                        }
                    }

                    // 2015/09/03 中村 受入指摘対応(#4949) Add Start
                    foreach (ArrayList arrOxygen in arrRemoveList)
                    {
                        // arrOxygenListベースで送信履歴メモへの登録情報を作成する為、
                        // 送信していない不要な酸素情報はarrOxygenListから削除
                        arrOxygenList.Remove(arrOxygen);
                    }
                    // 2015/09/03 中村 受入指摘対応(#4949) Add End
                }
                else
                {
                    // 汎用オーダ（酸素吸入）送信フラグOFF
                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_OXYGENORDER_FLAGOFF, CSICommonMethod.GetLastErrorString());
                }
                #endregion

                // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応
                #region 汎用オーダ（心電図）
                actionCodeEmpty = string.Empty;

                // 心電図送信数
                int intEcgCnt = 0;

                ArrayList arrEcgKey = new ArrayList();
                ArrayList arrEcgList = new ArrayList();

                if (m_blnEcgActionSendFlag)
                {
                    // 1.取得済みの今回心電図データをキー（発生日時）でソート
                    SortedDictionary<string, ArrayList> sortedEcgList = new SortedDictionary<string, ArrayList>(m_dictSendEcgList);

                    // 2.開始と終了の整合判定をしつつ送信用リストを作成
                    bool isStarted = false;
                    string strStartOccurDate = string.Empty;
                    foreach (KeyValuePair<string, ArrayList> kvpEcg in sortedEcgList)
                    {
                        // 心電図開始していない
                        if (!isStarted)
                        {
                            // レコードの使用量が空値
                            if (kvpEcg.Value[2].ToString() == "0")
                            {
                                // 開始レコードが来た（正しい順序）
                                // 心電図開始
                                isStarted = true;
                                // 開始レコードの発生日時を保持
                                strStartOccurDate = kvpEcg.Value[1].ToString();
                            }
                            // 空値でない
                            else
                            {
                                // 開始していないのに終了レコードが来た
                                // ※無視する
                            }
                        }
                        // 開始している
                        else
                        {
                            // レコードの使用量が空値
                            if (kvpEcg.Value[2].ToString() == "0")
                            {
                                // 開始しているのにまた開始レコードが来た
                                // ※開始のまま続行（前回の開始を無視）

                                // 開始レコードの発生日時を保持
                                strStartOccurDate = kvpEcg.Value[1].ToString();
                            }
                            // 終了
                            else
                            {
                                // 心電図数チェック
                                if (ECG_LIMIT_COUNT <= intEcgCnt)
                                {
                                    // エラー
                                    // 心電図の最大送信数10件を超えた
                                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_ECG_ORVER, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                                    break;
                                }

                                // 終了レコードが来た（正しい順序）
                                // 心電図終了
                                isStarted = false;
                                // 終了レコードに、開始レコードの発生日時をセット
                                kvpEcg.Value.Add(strStartOccurDate);
                                // 終了レコードを送信用リストに蓄積
                                // ※このときハッシュキーを実績番号にする
                                arrEcgKey.Add(kvpEcg.Value[0]);
                                arrEcgList.Add(kvpEcg.Value);

                                // 心電図数をインクリメント
                                intEcgCnt++;
                            }
                        }
                    }

                    // 3.送信履歴に含まれる心電図実績番号を抜き出して、2のリストとマージ
                    ArrayList arrSendedEcgList = GetSendedEcgResultNoList(exeInfo);
                    if (arrSendedEcgList != null)
                    {
                        foreach (ArrayList arr in arrSendedEcgList)
                        {
                            // 送信用リストのキーに、送信済みの実績番号がなければ
                            if (!arrEcgKey.Contains(arr[0].ToString()))
                            {
                                ArrayList arrAdd = new ArrayList();
                                // ※  [0]RESULT_NO
                                arrAdd.Add(arr[0]);
                                // ※  [1]OCCUR_DATE
                                arrAdd.Add(string.Empty);
                                // ※  [2]ELECTROCARDIOGRAM_TYPE
                                arrAdd.Add(string.Empty);
                                // ※  [3]開始レコードのOCCUR_DATE
                                arrAdd.Add(string.Empty);
                                // ※  [4]汎用オーダ番号 
                                arrAdd.Add(arr[1]);
                                // 削除用のアイテムを追加
                                arrEcgList.Add(arrAdd);
                            }
                            // あったら
                            else
                            {
                                int index = 0;
                                for (int i = 0; i < arrEcgKey.Count; i++)
                                {
                                    if (arr[0].ToString() == arrEcgKey[i].ToString())
                                    {
                                        index = i;
                                        break;
                                    }
                                }

                                // ここでオーダ番号を渡しておく
                                ArrayList arrSend = (ArrayList)arrEcgList[index];

                                // 「親番子番カンマ区切り」の形式に変換
                                string fullOrderNo = arr[1].ToString();
                                string sepaOrderNo = fullOrderNo.Substring(0, 13) + "," + fullOrderNo.Substring(13);

                                // アイテムの末尾に追加
                                arrSend.Add(sepaOrderNo);
                            }
                        }
                    }

                    ArrayList arrRemoveList = new ArrayList();

                    // 4.上記3のリストを回して1オーダずつ送信
                    foreach (ArrayList arrEcg in arrEcgList)
                    {
                        object[] sendEcgOrderDataWrap = new object[1];
                        int iRetVal = SendAllPurposeOrderMgr(exeInfo, out strAllPurposeEcgOrderRetNo, out bolReTry, OrderSendMode.Ecg, null, null, arrEcg);

                        if (0 > iRetVal)
                        {
                            // オーダディテール0件以外のエラーの場合
                            if (m_blnEcgNotDataFlag == false)
                            {
                                //// ダンプログを格納
                                sendEcgOrderDataWrap[0] = CSICommon.colORDER;
                                objEcgOrderExecData = new DumpParameter("汎用オーダ（心電図）送信", sendEcgOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false);
                                // エラー
                                base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_ECG_ORDER, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                                // ロールバックフラグを立てる
                                bolRollBack = true;

                                // ポップアップ通知
                                IsSuccess = false;
                                return Fn3ReturnCode.Error;
                            }
                            else
                            {
                                // ワーニングログを出力して処理を継続
                                base.TraceOut(CSIReturnCode.WNG_DIALYSIS_SND_ECG_NOT_DATA, string.Format("患者ID=\"{0}\"", m_strPatDispID));

                                arrRemoveList.Add(arrEcg);
                                continue;
                            }
                        }
                        // オーダ番号を個別に保持
                        if (arrEcg.Count < 5)
                        {
                            // ※送信リストに保持
                            arrEcg.Add(strAllPurposeEcgOrderRetNo);
                        }

                        // 送信したときのみDUMPを出す
                        if (iRetVal == 1)
                        {
                            // ダンプログを格納
                            sendEcgOrderDataWrap[0] = CSICommon.colORDER;
                            // 複数ありえるのでリストに溜める
                            ecgDumpParamList.Add(new DumpParameter("汎用オーダ（心電図）送信", sendEcgOrderDataWrap, CSICommon.varOUTPARAM, null, true));
                        }
                    }

                    foreach (ArrayList arrEcg in arrRemoveList)
                    {
                        // arrEcgListベースで送信履歴メモへの登録情報を作成する為、
                        // 送信していない不要な心電図情報はarrEcgListから削除
                        arrEcgList.Remove(arrEcg);
                    }
                }
                else
                {
                    // 汎用オーダ（心電図）送信フラグOFF
                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_ECGORDER_FLAGOFF, CSICommonMethod.GetLastErrorString());
                }
                #endregion
                // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応

                // -------------------------------------------------
                // 汎用オーダ（その他の処置）を送信する
                // -------------------------------------------------
                #region 汎用オーダ（その他の処置）

                // Hashtable hasTreatmentList = new Hashtable();
                ArrayList arrTreatmentAction = new ArrayList();

                ArrayList arrTreatmentKey = new ArrayList();
                // ArrayList arrTreatmentList = new ArrayList();
                List<TreatActInfo> lstTreatAct = new List<TreatActInfo>();

                // その他の処置送信数
                int intTreatCnt = 0;

                if (m_blnTreatmentActionSendFlag)
                {
#if false
                    // arrTreatment は次のような内容を期待
                    // { 0:FNW薬剤コード 1:院内コード 2:オーダ番号(この時点では空) }
                    ArrayList arrTreatment;

                    // 処置行為薬剤コードを全てループ
                    foreach (string actMedCode in m_arrTreatmentActionMedicineCode)
                    {
                        // 今回データを取得
                        if (m_hasSendTreatmentActionMedisineCode.ContainsKey(actMedCode))
                        {
                            arrTreatment = (ArrayList)m_hasSendTreatmentActionMedisineCode[actMedCode];
                        }
                        else
                        {
                            // 今回存在しなければダミーを作成
                            arrTreatment = new ArrayList();
                            arrTreatment.Add(actMedCode);
                            arrTreatment.Add(string.Empty); //*****
                            arrTreatment.Add(string.Empty);
                        }
                        // 院内コードを取り出す
                        //（今回送信するデータのコードならば、院内コードはすでに渡されている）
                        string inHospitalCode = arrTreatment[1].ToString();

                        object[] sendTreatmentOrderDataWrap = new object[1];
                        int iRetVal = SendAllPurposeOrderMgr(exeInfo, out strAllPurposeTreatmentOrderRetNo, out bolReTry, OrderSendMode.Treatment, ref inHospitalCode, actMedCode, null);
                        if (0 > iRetVal)
                        {
                            //// ダンプログを格納
                            sendTreatmentOrderDataWrap[0] = CSICommon.colORDER;
                            // 複数ありえるのでリストに溜める
                            treatDumpParamList.Add(new DumpParameter("汎用オーダ（その他の処置）送信", sendTreatmentOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false));
                            // エラー
                            this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_TREATMENT_ORDER);
                            // ロールバックフラグを立てる
                            bolRollBack = true;
                            return Fn3ReturnCode.Error;
                        }
                        // オーダ番号を個別に保持
                        arrTreatment[2] = strAllPurposeTreatmentOrderRetNo;

                        // ※※※
                        // arrTreatmentのダミーは、削除送信のときのみ作られ、
                        // オーダ番号保存処理までもちまわす必要がないため、
                        // このまま消失させる

                        // 送信したときのみDUMPを出す
                        if (iRetVal == 1)
                        {
                            // ダンプログを格納
                            sendTreatmentOrderDataWrap[0] = CSICommon.colORDER;
                            // 複数ありえるのでリストに溜める
                            treatDumpParamList.Add(new DumpParameter("汎用オーダ（その他の処置）送信", sendTreatmentOrderDataWrap, CSICommon.varOUTPARAM, null, true));
                        }
                    }
#else
                    // 取得済みの処置データをキー（実施日時）でソート
                    
                    // 2016/04/15 中村 その他処置行為送信仕様追加
                    //SortedDictionary<string, ArrayList> sortedTreatList = new SortedDictionary<string, ArrayList>(m_dictSendTreatmentList);
                    //foreach (KeyValuePair<string, ArrayList> kvpTreat in sortedTreatList)
                    SortedDictionary<string, TreatActInfo> sortedTreatList = new SortedDictionary<string, TreatActInfo>(m_dictSendTreatActList);
                    foreach (KeyValuePair<string, TreatActInfo> kvpTreat in sortedTreatList)
                    {
                        // その他の処置数チェック
                        if (TREATMENT_LIMIT_COUNT <= intTreatCnt)
                        {
                            // エラー
                            // その他処置の最大送信数20件を超えた
                            // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                            //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_TREAT_ORVER);
                            base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_TREAT_ORVER, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                            // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                            break;
                        }

                        if (m_blnTreatmentActionUnitFlag)
                        {
                            // 2016/04/15 中村 その他処置行為送信仕様追加
                            // if (arrTreatmentAction.Contains(kvpTreat.Value[0]))
                            // {
                            //     continue;
                            // }
                            if (arrTreatmentAction.Contains(kvpTreat.Value.TreatmentAct))
                            {
                                int index = -1;
                                for (int i = 0; i < lstTreatAct.Count; i++)
                                {
                                    if (lstTreatAct[i].TreatmentAct.Equals(kvpTreat.Value.TreatmentAct))
                                    {
                                        index = i;
                                        break;
                                    }
                                }
                                if (!index.Equals(-1))
                                {
                                    lstTreatAct[index].SetTreatItem(kvpTreat.Value.GetTreatItem);
                                    continue;
                                }
                            }
                        }

                        // ※このときハッシュキーを実績番号にする
                        // string strHashkey = kvpTreat.Value[0].ToString() + kvpTreat.Value[2].ToString() + kvpTreat.Value[3].ToString();
                        string strHashkey = kvpTreat.Value.MstMedCode.ToString() + kvpTreat.Value.ClassType.ToString() + kvpTreat.Value.CtlNo.ToString();

                        // hasTreatmentList.Add(strHashkey, kvpTreat.Value);
                        arrTreatmentKey.Add(strHashkey);
                        //arrTreatmentList.Add(kvpTreat.Value);
                        lstTreatAct.Add(kvpTreat.Value);

                        // arrTreatmentAction.Add(kvpTreat.Value[0]);
                        arrTreatmentAction.Add(kvpTreat.Value.TreatmentAct);

                        // その他の処置数をインクリメント
                        intTreatCnt++;
                    }

                    // 送信履歴よりオーダ番号を取得
                    ArrayList arrSendedTreatList = GetSendedTreatResultNoList(exeInfo);
                    if (arrSendedTreatList != null)
                    {
                        foreach (ArrayList arr in arrSendedTreatList)
                        {
                            string strHashKey = arr[0].ToString() + arr[1].ToString() + arr[2].ToString();

                            // 送信用リストのキーに、送信済みのキーがない場合
                            // if (!hasTreatmentList.ContainsKey(strHashKey))
                            if (!arrTreatmentKey.Contains(strHashKey))
                            {
                                //ArrayList arrAdd = new ArrayList();
                                //// ※  [0]薬剤コード
                                //arrAdd.Add(string.Empty);
                                //// ※  [1]院内コード
                                //arrAdd.Add(string.Empty);
                                //// ※  [2]分類(M:投薬/T:処置薬剤)
                                //arrAdd.Add(string.Empty);
                                //// ※  [3]項目コード(CTL_NO/RESULT_NO)
                                //arrAdd.Add(string.Empty);
                                //// ※  [4]実施日時(OCCUR_DATE/EFFECT_DATE)
                                //arrAdd.Add(string.Empty);
                                //// ※  [5]オーダ番号
                                //// 「親番子番カンマ区切り」の形式に変換
                                //string fullOrderNo = arr[3].ToString();
                                //string sepaOrderNo = fullOrderNo.Substring(0, 13) + "," + fullOrderNo.Substring(13);
                                // // 削除用のアイテムを追加
                                // arrTreatmentList.Add(arrAdd);

                                TreatActInfo treatInfo = new TreatActInfo(m_blnTreatmentActionUnitFlag);
                                // ※  [0]薬剤コード
                                treatInfo.MstMedCode = string.Empty;
                                // ※  [1]院内コード
                                treatInfo.TreatmentAct = string.Empty;
                                // ※  [2]分類(M:投薬/T:処置薬剤)
                                treatInfo.ClassType = string.Empty;
                                // ※  [3]項目コード(CTL_NO/RESULT_NO)
                                treatInfo.CtlNo = string.Empty;
                                // ※  [4]実施日時(OCCUR_DATE/EFFECT_DATE)
                                treatInfo.EffectDate = string.Empty;
                                // ※  [5]オーダ番号
                                // 「親番子番カンマ区切り」の形式に変換
                                string fullOrderNo = arr[3].ToString();
                                string sepaOrderNo = fullOrderNo.Substring(0, 13) + "," + fullOrderNo.Substring(13);
                                treatInfo.OrderNo = sepaOrderNo;
                                // 削除用のアイテムを追加
                                lstTreatAct.Add(treatInfo);
                            }
                            // ある場合
                            else
                            {
                                int index = 0;
                                for (int i = 0; i < arrTreatmentKey.Count; i++)
                                {
                                    if (strHashKey == arrTreatmentKey[i].ToString())
                                    {
                                        index = i;
                                        break;
                                    }
                                }

                                // // ここでオーダ番号を渡しておく
                                // ArrayList arrSend = (ArrayList)hasTreatmentList[strHashKey];
                                // ArrayList arrSend = (ArrayList)arrTreatmentList[index];
                                TreatActInfo treatInfo = (TreatActInfo)lstTreatAct[index];

                                // 「親番子番カンマ区切り」の形式に変換
                                string fullOrderNo = arr[3].ToString();
                                string sepaOrderNo = fullOrderNo.Substring(0, 13) + "," + fullOrderNo.Substring(13);

                                // アイテムの末尾に追加
                                // arrSend.Add(sepaOrderNo);
                                treatInfo.OrderNo = sepaOrderNo;
                            }
                        }
                    }

                    // foreach (ArrayList arrTreatment in hasTreatmentList.Values)
                    // foreach (ArrayList arrTreatment in arrTreatmentList)
                    foreach (TreatActInfo treatInfo in lstTreatAct)
                    {
                        object[] sendTreatmentOrderDataWrap = new object[1];
                        int iRetVal = SendAllPurposeOrderMgr(exeInfo, out strAllPurposeTreatmentOrderRetNo, out bolReTry, OrderSendMode.Treatment, treatInfo, null, null);
                        if (0 > iRetVal)
                        {
                            //// ダンプログを格納
                            sendTreatmentOrderDataWrap[0] = CSICommon.colORDER;
                            // 複数ありえるのでリストに溜める
                            treatDumpParamList.Add(new DumpParameter("汎用オーダ（その他の処置）送信", sendTreatmentOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false));
                            // エラー
                            this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_TREATMENT_ORDER);
                            // ロールバックフラグを立てる
                            bolRollBack = true;

                            // 2016/04/14 中村 ポップアップ通知
                            IsSuccess = false;
                            return Fn3ReturnCode.Error;
                        }
                        //// オーダ番号を個別に保持
                        //if (arrTreatment.Count < 6)
                        //{
                        //    arrTreatment.Add(strAllPurposeTreatmentOrderRetNo);
                        //}
                        // オーダ番号を個別に保持
                        if (string.IsNullOrEmpty(treatInfo.OrderNo))
                        {
                            treatInfo.OrderNo = strAllPurposeTreatmentOrderRetNo;
                        }

                        // ※※※
                        // arrTreatmentのダミーは、削除送信のときのみ作られ、
                        // オーダ番号保存処理までもちまわす必要がないため、
                        // このまま消失させる

                        // 送信したときのみDUMPを出す
                        if (iRetVal == 1)
                        {
                            // ダンプログを格納
                            sendTreatmentOrderDataWrap[0] = CSICommon.colORDER;
                            // 複数ありえるのでリストに溜める
                            treatDumpParamList.Add(new DumpParameter("汎用オーダ（その他の処置）送信", sendTreatmentOrderDataWrap, CSICommon.varOUTPARAM, null, true));
                        }
#endif
                    }
                }
                else
                {
                    // 汎用オーダ（その他の処置）送信フラグOFF
                    this.TraceOutWrap(CSIReturnCode.WNG_DIALYSIS_SND_TREATMENTORDER_FLAGOFF, CSICommonMethod.GetLastErrorString());
                }
                // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                #endregion

                // -------------------------------------------------
                // 注射オーダデータを送信する
                // -------------------------------------------------
                object[] sendExecOrderDataWrap = new object[1];
                if (!SendInjectionOrderMgr(exeInfo, out strInjectionOrderRetNo, out bolReTry))
                {
                    // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                    if (m_blnInjectionNotDataFlag == false)
                    {
                        // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応

                        // ダンプログを格納
                        sendExecOrderDataWrap[0] = CSICommon.colORDER;
                        objInjectionExecOrderData = new DumpParameter("注射オーダ送信", sendExecOrderDataWrap, CSICommon.varOUTPARAM, CSICommon.colERR, false);
                        // エラー
                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                        //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_ORDERINJECTION);
                        base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_ORDERINJECTION, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                        // ロールバックフラグを立てる
                        bolRollBack = true;
                        
                        // 2016/04/14 中村 ポップアップ通知
                        IsSuccess = false;
                        return Fn3ReturnCode.Error;
                    // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                    }
                    else
                    {
                        // ワーニングログを出力して処理を継続
                        base.TraceOut(CSIReturnCode.WNG_DIALYSIS_SND_INJECTION_NOT_DATA, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                    }
                    // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                }
                // ダンプログを格納(注射オーダの場合はデータが無い場合があるが、その場合は処理結果は正常なので送信データを中身確認する）
                // >>>>>【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                //if (CSICommon.colORDER.Count() != 0)
                if (CSICommon.colORDER.Count() != 0 && m_blnInjectionNotDataFlag == false)
                // <<<<<【Ver.5.0.3.100】2015.08.04 石川 特殊浄化対応
                {
                    sendExecOrderDataWrap[0] = CSICommon.colORDER;
                    objInjectionExecOrderData = new DumpParameter("注射オーダ送信", sendExecOrderDataWrap, CSICommon.varOUTPARAM, null, true);
                }
                // -------------------------------------------------
                // 患者診療フリーデータを送信する
                // -------------------------------------------------
                // 連携対象動作モードを確認（0：電子カルテ　1：オーダリング）
                if (m_strConnectType == "0")
                {
                    //　0：電子カルテの場合は患者診療フリーデータを送信する
                    // 送信する設定の場合
                    if (!SendExamFreeMgr(exeInfo, out strExamRetNo))
                    {
                        // ダンプログを格納
                        objExamFreeExecData = new DumpParameter("患者診療フリー送信", CSICommon.varEXAMFREE, CSICommon.varOUTPARAM, CSICommon.colERR, false);
                        // エラー
                        // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                        //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_EXAMRREE);
                        base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_EXAMRREE, string.Format("患者ID=\"{0}\"", m_strPatDispID));
                        // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                        // ロールバックフラグを立てる
                        bolRollBack = true;
                        
                        // 2016/04/14 中村 ポップアップ通知
                        IsSuccess = false;
                        return Fn3ReturnCode.Error;
                    }
                    // ダンプログを格納
                    objExamFreeExecData = new DumpParameter("患者診療フリー送信", CSICommon.varEXAMFREE, CSICommon.varOUTPARAM, null, true);
                }
                else
                {
                    // ダンプログを格納
                    objExamFreeExecData = new DumpParameter("患者診療フリー送信", null, null, null, null);
                    // 患者診療フリー送信しない設定の場合はオーダ番号を一応noneに設定しておく
                    strExamRetNo = NONE;
                }


                // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                //// -------------------------------------------------
                //// MIRAISへの送信処理で発行されるオーダ番号(及びサブオーダ番号)を保持する
                //// 記録場所及び記録フォーマットは下記とする
                //// [記録場所]：連携送信履歴テーブル・コメント
                //// [記録フォーマット]：汎用オーダ番号,汎用オーダサブ番号,注射オーダ番号,注射オーダサブ番号,患者診療フリー診療番号（※カンマ区切りで正常系未送信の場合はnoneを設定する）
                //// -------------------------------------------------
                //this.SendHistMemo = strAllPurposeOrderRetNo + "," + strInjectionOrderRetNo + "," + strExamRetNo;
                // 先に旧方式で構成
                this.SendHistMemo = strAllPurposeOrderRetNo + ","
                                  + strInjectionOrderRetNo + ","
                                  + strExamRetNo;

                // 人工腎臓オーダ番号
                string[] strArr;
                strArr = strAllPurposeOrderRetNo.Split(',');
                if (strArr.Length < 2)
                {
                    strAllPurposeOrderRetNo = string.Empty;
                }
                else
                {
                    // 2012/02/01 中村 オーダ番号オーバーフロー対応
                    //strAllPurposeOrderRetNo = string.Format("{0:D13}", System.Convert.ToInt32(strArr[0]))
                    //                        + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                    strAllPurposeOrderRetNo = string.Format("{0:D13}", System.Convert.ToInt64(strArr[0]))
                                            + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                }
                this.SendHistMemo += ","
                                   + CSICommonConst.ORDERNO_KEY_DIALYSIS    // キー
                                   + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                   + "0"                                    // 院内コード／このモードではダミー値
                                   + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                   + strAllPurposeOrderRetNo;               // オーダ番号16桁

                // 酸素吸入オーダ番号
                if (m_blnOxygenActionSendFlag)
                {
                    #region 酸素吸入オーダ複数化に伴い見直し
                    //strArr = strAllPurposeOxygenOrderRetNo.Split(',');
                    //if (strArr.Length < 2)
                    //{
                    //    strAllPurposeOxygenOrderRetNo = string.Empty;
                    //}
                    //else
                    //{
                    //    strAllPurposeOxygenOrderRetNo = string.Format("{0:D13}", System.Convert.ToInt32(strArr[0]))
                    //                                  + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                    //}
                    //this.SendHistMemo += CSICommonConst.ORDERNO_PAIR_SEPARATER
                    //                   + CSICommonConst.ORDERNO_KEY_OXYGEN      // キー
                    //                   + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                    //                   + "0"                                    // 院内コード／このモードではダミー値
                    //                   + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                    //                   + strAllPurposeOxygenOrderRetNo;         // オーダ番号16桁
                    #endregion

                    //foreach (ArrayList arrOxygen in m_dictSendOxygenList.Values)
                    foreach (ArrayList arrOxygen in arrOxygenList)
                    {
                        // >>>>>【Ver.5.0.2.100】2015.08.04 石川 特殊浄化対応
                        // 2015/09/03 中村 受入指摘対応(#4949) Chg Start
                        // if (arrOxygen == null || string.IsNullOrEmpty(arrOxygen[6].ToString()) == true)
                        // arrOxygen[6]は汎用オーダ番号が格納される。送信した場合にリストに追加される。
                        if (arrOxygen == null || arrOxygen.Count < 7 || string.IsNullOrEmpty(arrOxygen[6].ToString()) == true)
                        // 2015/09/03 中村 受入指摘対応(#4949) Chg End
                        {
                            continue;
                        }
                        // <<<<<【Ver.5.0.2.100】2015.08.04 石川 特殊浄化対応

                        strArr = arrOxygen[6].ToString().Split(',');
                        if (strArr.Length < 2)
                        {
                            arrOxygen[6] = string.Empty;
                        }
                        else
                        {
                            // 2012/02/01 中村 オーダ番号オーバーフロー対応
                            //arrOxygen[6] = string.Format("{0:D13}", System.Convert.ToInt32(strArr[0]))
                            //                + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                            arrOxygen[6] = string.Format("{0:D13}", System.Convert.ToInt64(strArr[0]))
                                            + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                        }
                        this.SendHistMemo += CSICommonConst.ORDERNO_PAIR_SEPARATER
                                           + CSICommonConst.ORDERNO_KEY_OXYGEN   // キー
                                           + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                           + arrOxygen[0]                        // 実績番号3桁
                                           + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                           + arrOxygen[6];                       // オーダ番号16桁
                    }
                }

                // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応
                // 心電図オーダ番号
                if (m_blnEcgActionSendFlag)
                {
                    foreach (ArrayList arrEcg in arrEcgList)
                    {
                        // arrEcg[4]は汎用オーダ番号が格納される。送信した場合にリストに追加される。
                        if (arrEcg == null || arrEcg.Count < 5 || string.IsNullOrEmpty(arrEcg[4].ToString()) == true)
                        {
                            continue;
                        }

                        strArr = arrEcg[4].ToString().Split(',');
                        if (strArr.Length < 2)
                        {
                            arrEcg[4] = string.Empty;
                        }
                        else
                        {
                            arrEcg[4] = string.Format("{0:D13}", System.Convert.ToInt64(strArr[0]))
                                            + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                        }
                        this.SendHistMemo += CSICommonConst.ORDERNO_PAIR_SEPARATER
                                           + CSICommonConst.ORDERNO_KEY_ECG   // キー
                                           + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                           + arrEcg[0]                        // 実績番号3桁
                                           + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                           + arrEcg[4];                       // オーダ番号16桁
                    }
                }
                // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応

                // その他の処置オーダ番号
                if (m_blnTreatmentActionSendFlag)
                {
                    //// foreach (ArrayList arrTreatment in hasTreatmentList.Values)
                    //foreach (ArrayList arrTreatment in arrTreatmentList)
                    //{
                    //    if (arrTreatment[0].Equals(string.Empty)) break;

                    //    strArr = arrTreatment[5].ToString().Split(',');
                    //    if (strArr.Length < 2)
                    //    {
                    //        arrTreatment[5] = string.Empty;
                    //    }
                    //    else
                    //    {
                    //        // 2012/02/01 中村 オーダ番号オーバーフロー対応
                    //        //arrTreatment[5] = string.Format("{0:D13}", System.Convert.ToInt32(strArr[0]))
                    //        //                + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                    //        arrTreatment[5] = string.Format("{0:D13}", System.Convert.ToInt64(strArr[0]))
                    //                        + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                    //    }
                    //    this.SendHistMemo += CSICommonConst.ORDERNO_PAIR_SEPARATER
                    //                       + arrTreatment[0]                        // 薬剤コード
                    //                       + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                    //                       + arrTreatment[2]                        // 分類区分(M:投薬/T:処置)
                    //                       + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                    //                       + arrTreatment[3]                        // 項目コード(項目番号/実施番号)
                    //                       + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                    //                       + arrTreatment[5];                       // オーダ番号16桁
                    //}
                    foreach (TreatActInfo treatInfo in lstTreatAct)
                    {
                        if (treatInfo.MstMedCode.Equals(string.Empty)) break;

                        strArr = treatInfo.OrderNo.ToString().Split(',');
                        if (strArr.Length < 2)
                        {
                            treatInfo.OrderNo = string.Empty;
                        }
                        else
                        {
                            // 2012/02/01 中村 オーダ番号オーバーフロー対応
                            //arrTreatment[5] = string.Format("{0:D13}", System.Convert.ToInt32(strArr[0]))
                            //                + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                            treatInfo.OrderNo = string.Format("{0:D13}", System.Convert.ToInt64(strArr[0]))
                                              + string.Format("{0:D3}", System.Convert.ToInt32(strArr[1]));
                        }
                        this.SendHistMemo += CSICommonConst.ORDERNO_PAIR_SEPARATER
                                           + treatInfo.MstMedCode                   // 薬剤コード
                                           + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                           + treatInfo.ClassType                    // 分類区分(M:投薬/T:処置)
                                           + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                           + treatInfo.CtlNo                        // 項目コード(項目番号/実施番号)
                                           + CSICommonConst.ORDERNO_KEY_SEPARATER   // :
                                           + treatInfo.OrderNo;                       // オーダ番号16桁
                    }
                }
                // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

#if DEBUG
                this.TraceOut("■透析実績送信・Debug版■ ＜書き込み＞");
                this.TraceOut("■透析実績送信・Debug版■ this.SendHistMemo＝" + this.SendHistMemo);
#endif

#if !WITHOUT_INTERFACE
                // -------------------------------------------------
                // トランザクション終了する
                // -------------------------------------------------
                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                //if (!CSICommonMethod.pDbCommitTrn(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR))
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbCommitTrn() Start");
                bResult = CSICommonMethod.pDbCommitTrn(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR);
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbCommitTrn() End");
                if (bResult == false)
                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                {
                    // エラー
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_DBCOMMIT, CSICommonMethod.GetLastErrorString());
                    base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_DBCOMMIT,
                        string.Format("患者ID=\"{0}\", エラー内容=\"{1}\"", m_strPatDispID, CSICommonMethod.GetLastErrorString()));
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    // ロールバックフラグを立てる
                    bolRollBack = true;
                    
                    // 2016/04/14 中村 ポップアップ通知
                    IsSuccess = false;
                    return Fn3ReturnCode.Error;
                }
#endif
                // 成功ログ
                this.DebugTraceOut(CSICommonConst.MODULE_MNAME_DS + CSICommonConst.LOGTYPE_DBG + CSICommonConst.DEBUGTRACE_PRE_SUCCESS_MSG +
                                   "PATID=" + m_strPatID + " DISP_PATID=" + m_strPatDispID + " DIALYSIS_NO" + m_strDialysisNo + " EDITION" + m_strEdition);

                // メソッド終了ログ
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
                return new Fn3ReturnCode(Fn3ReturnCode.Success.ProcKind, Fn3ReturnCode.Success.Code, base.SendHistMemo, ReturnCodeType.Success);
            }
            catch (Exception ex)
            {
                // エラー
                this.ErrorTraceOutWrap(CSIReturnCode.FTL_DIALYSIS_SND_EX_EXECUTE, ex);

                // 2016/04/14 中村 ポップアップ通知
                IsSuccess = false;
                return Fn3ReturnCode.Error;
            }
            finally
            {
                // -------------------------------------------------
                // 送信データのダンプを出す
                // -------------------------------------------------

                // >>>>>【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応
                //DumpParameter[] dumpParameter = { objOrderExecData, objInjectionExecOrderData, objExamFreeExecData };

                // 酸素吸入行為の送信がなかった場合は「未処理」DUMPをリストにセット
                if (oxygenDumpParamList.Count == 0)
                {
                    oxygenDumpParamList.Add(objOxygenOrderExecData);
                }

                // >>>>>【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応
                // 心電図行為の送信がなかった場合は「未処理」DUMPをリストにセット
                if (ecgDumpParamList.Count == 0)
                {
                    ecgDumpParamList.Add(objEcgOrderExecData);
                }

                // その他処置行為の送信がなかった場合は「未処理」DUMPをリストにセット
                if (treatDumpParamList.Count == 0)
                {
                    treatDumpParamList.Add(objTreatmentOrderExecData);
                }

                // DUMPの総数で配列を作成
                // 2011/03/24
                // int cnt = 4 + treatDumpParamList.Count;
                int cnt = 3 + oxygenDumpParamList.Count + ecgDumpParamList.Count + treatDumpParamList.Count;

                DumpParameter[] dumpParameter = new DumpParameter[cnt];
                int idx = 0;
                // 汎用オーダ（人工腎臓）のDUMP
                dumpParameter[idx++] = objOrderExecData;
                // 汎用オーダ（酸素吸入）のDUMP　※ｎ件
                foreach (DumpParameter dp in oxygenDumpParamList)
                {
                    dumpParameter[idx++] = dp;
                }
                // 汎用オーダ（心電図）のDUMP　※ｎ件
                foreach (DumpParameter dp in ecgDumpParamList)
                {
                    dumpParameter[idx++] = dp;
                }
                // <<<<<【Ver.5.0.8.100】2025.06.10 Thach 心電図送信対応
                
                // 汎用オーダ（その他の処置）のDUMP　※ｎ件
                foreach (DumpParameter dp in treatDumpParamList)
                {
                    dumpParameter[idx++] = dp;
                }
                // 注射オーダのDUMP　※0or1件
                dumpParameter[idx++] = objInjectionExecOrderData;
                // 患者診療フリーのDUMP　※0or1件
                dumpParameter[idx++] = objExamFreeExecData;
                // <<<<<【Ver.5.0.0.104】2011.02.22 horiuchi 処置送信対応

                this.DumpOut(exeInfo.SpecificKey, CSICommonMethod.CreateDumpData(m_strPatID, m_strDialysisNo, m_strEdition, dumpParameter));

#if !WITHOUT_INTERFACE
                // -------------------------------------------------
                // ロールバックする
                // -------------------------------------------------
                //  ロールバックの必要判定
                if (bolRollBack)
                {
                    // ロールバックを行う
                    // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    //if (!CSICommonMethod.pDbRollBack(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR))
                    base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbRollBack() Start");
                    bResult = CSICommonMethod.pDbRollBack(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR);
                    base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbRollBack() End");
                    if (bResult == false)
                    // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                    {
                        // エラー
                        this.TraceOutWrap(CSIReturnCode.ERR_DIALYSIS_SND_DBROLLBACK, CSICommonMethod.GetLastErrorString());
                    }
                }
                // -------------------------------------------------
                // MIRAIs-DB切断する
                // -------------------------------------------------
                // >>>>>【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                //if (!CSICommonMethod.pDbClose(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR))
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbClose() Start");
                bResult = CSICommonMethod.pDbClose(m_objCSICOMMON, m_objMiraisDB, ref CSICommon.colERR);
                base.TraceOut("【透析実施送信】他部門I/F：CSICommonMethod.pDbClose() End");
                if (bResult == false)
                // <<<<<【Ver.5.0.3.100】2015.07.30 石川 ログ強化
                {
                    // エラー
                    this.TraceOutWrap(CSIReturnCode.ERR_DIALYLSIS_SND_DBCLOSE, CSICommonMethod.GetLastErrorString());
                }
#endif
                // -------------------------------------------------
                // リトライ判定する
                // -------------------------------------------------
                if (bolReTry)
                {
                    // リトライする
                    this.EventRetry = true;
                }

                // 2016/04/14 中村 ポップアップ通知対応 Add Start
                // -------------------------------------------------
                // ポップアップ通知
                // -------------------------------------------------
                this.RegistPopupNotice(exeInfo, IsSuccess);
                // 2016/04/14 中村 ポップアップ通知対応 Add End
            }
        }
        #endregion


        #region メソッド定義・プライベート（クラス内共通）
        /// <summary>
        /// 設定データ値の空文字チェック
        /// </summary>
        /// <param name="val">設定値</param>
        /// <param name="fn3ReturnCode">ログ用Fn3ReturnCode</param>
        /// <param name="addErrMsg">ログに追加する文字</param>
        /// <returns>true:正常 false:異常</returns>
        private bool CheckEmptyVal(string val, Fn3ReturnCode fn3ReturnCode, string addErrMsg)
        {
            // 値の空チェック
            if (val == string.Empty)
            {
                // エラー
                this.TraceOutWrap(fn3ReturnCode, addErrMsg + "：値が空または異常です。");
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// 取得ノードのnullチェック
        /// </summary>
        /// <param name="XmlNode">ノード</param>
        /// <param name="fn3ReturnCode">ログ用Fn3ReturnCode</param>
        /// <param name="addErrMsg">ログに追加する文字</param>
        /// <returns>true:正常 false:異常</returns>
        private bool CheckNullNode(XmlNode xmlNode, Fn3ReturnCode fn3ReturnCode, string addErrMsg)
        {
            // ノードのnullチェック
            if (xmlNode == null)
            {
                // エラー
                this.TraceOutWrap(fn3ReturnCode, addErrMsg + "：ノードが取得出来ません。");
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// TraceOutのラップメソッド
        /// </summary>
        /// <param name="cSIReturnCode">Fn3ReturnCode</param>
        private void TraceOutWrap(Fn3ReturnCode cSIReturnCode)
        {
            // トレースログを出力する
            this.TraceOut(cSIReturnCode);

            // アラームフラグを確認
            if (m_bolAramChk)
            {
                // エラー、例外はアラームを出力する
                if (cSIReturnCode.IsError || cSIReturnCode.IsException)
                {
                    // アラームフラグを落とす(アラームは１イベント一回とする）
                    m_bolAramChk = false;

                    // 処理区分が取得出来ているか確認
                    if (m_strSendClass == null)
                    {
                        // アラームを出力する
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, this.m_strPatDispID, this.m_strPatName, "", string.Format("{0}", cSIReturnCode.Message));
                    }
                    else
                    {
                        // 処理区分を追加してアラームを出力する
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, this.m_strPatDispID, this.m_strPatName, "", string.Format("{0}処理区分:{1}", cSIReturnCode.Message, m_strSendClass));
                    }
                }
            }
        }

        /// <summary>
        /// TraceOutのラップメソッド
        /// </summary>
        /// <param name="cSIReturnCode">Fn3ReturnCode</param>
        /// <param name="strMsg">追加メッセージ</param>
        private void TraceOutWrap(Fn3ReturnCode cSIReturnCode, string strMsg)
        {
            // トレースログを出力する
            this.TraceOut(cSIReturnCode, strMsg);

            // アラームフラグを確認
            if (m_bolAramChk)
            {
                // エラー、例外はアラームを出力する
                if (cSIReturnCode.IsError || cSIReturnCode.IsException)
                {
                    // アラームフラグを落とす(アラームは１イベント一回とする）
                    m_bolAramChk = false;

                    // 処理区分が取得出来ているか確認
                    if (m_strSendClass == null)
                    {
                        // アラームを出力する
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, this.m_strPatDispID, this.m_strPatName, "", string.Format("{0}（{1}）", cSIReturnCode.Message, strMsg));
                    }
                    else
                    {
                        // 処理区分を追加してアラームを出力する
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, this.m_strPatDispID, this.m_strPatName, "", string.Format("{0}（{1}）処理区分:{2}", cSIReturnCode.Message, strMsg, m_strSendClass));
                    }
                }
            }
        }

        /// <summary>
        /// ErrorTraceOutのラップメソッド
        /// </summary>
        /// <param name="cSIReturnCode">Fn3ReturnCode</param>
        /// <param name="ex">Exception</param>
        private void ErrorTraceOutWrap(Fn3ReturnCode cSIReturnCode, Exception ex)
        {
            // エラーログを出力する
            this.ErrorTraceOut(cSIReturnCode, ex);

            // アラームフラグを確認
            if (m_bolAramChk)
            {
                // エラー、例外はアラームを出力する
                if (cSIReturnCode.IsError || cSIReturnCode.IsException)
                {
                    // アラームフラグを落とす(アラームは１イベント一回とする）
                    m_bolAramChk = false;

                    // 処理区分が取得出来ているか確認
                    if (m_strSendClass == null)
                    {
                        // アラームを出力する
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, this.m_strPatDispID, this.m_strPatName, "", string.Format("{0}（{1}）", cSIReturnCode.Message, ex.Message));
                    }
                    else
                    {
                        // 処理区分を追加してアラームを出力する
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, this.m_strPatDispID, this.m_strPatName, "", string.Format("{0}（{1}）処理区分:{2}", cSIReturnCode.Message, ex.Message, m_strSendClass));
                    }
                }
            }
        }

        /// <summary>
        /// インスタンスを生成する
        /// </summary>
        /// <param name="strLibName">インスタンス名</param>
        /// <returns>インスタンス</returns>
        private object CreateObjectWrap(string strLibName)
        {
            try
            {
                // インスタンス生成
                return CSICommonMethod.CreateObject(strLibName);
            }
            catch (Exception ex)
            {
                // エラー
                this.ErrorTraceOutWrap(CSIReturnCode.FTL_DIALYSIS_SND_EX_CREATEOBJ, ex);
                return null;
            }
        }

        // 2011/01/21 中村 小数点以下の有効桁数対応
        ///// <summary>
        ///// 小数点表示桁下げを行う
        ///// </summary>
        ///// <param name="strValue">入力値</param>
        ///// <returns>変換結果</returns>
        //private string RoundDecimal(string strValue)
        //{
        //    double dBuf;
        //    if (!double.TryParse(strValue, out dBuf))
        //    {
        //        // Double型に変換できない場合、何もしない
        //        return strValue;
        //    }

        //    string strOutValue = strValue;

        //    if (strOutValue.Contains("."))
        //    {
        //        strOutValue = strOutValue.TrimEnd('0');
        //        if (strOutValue.Substring(strOutValue.Length - 1).Equals("."))
        //        {
        //            strOutValue = strOutValue.TrimEnd('.');
        //        }
        //    }
        //    return strOutValue;
        //}
        /// <summary>
        /// 小数点表示桁下げを行う
        /// </summary>
        /// <param name="strValue">入力値</param>
        /// <returns>変換結果</returns>
        private string RoundDecimal(string strValue)
        {
            decimal decBuf;
            if (!decimal.TryParse(strValue, out decBuf))
            {
                // Double型に変換できない場合、何もしない
                return strValue;
            }
            string strOutValue = decimal.Divide(Math.Truncate(decimal.Multiply(decBuf, 100m)), 100m).ToString();

            if (strOutValue.Contains("."))
            {

                strOutValue = strOutValue.TrimEnd('0');
                if (strOutValue.Substring(strOutValue.Length - 1).Equals("."))
                {
                    strOutValue = strOutValue.TrimEnd('.');
                }
            }
            return strOutValue;
        }

        // 2011/05/13 中村 指示医対応
        /// <summary>
        /// 透析実績.版確定者取得処理
        /// </summary>
        /// <param name="xmlCoopInfo">連携情報</param>
        /// <returns>版確定者コード</returns>
        private string getDeciderCd(XmlNode xmlCoopInfo)
        {
            string strStaffCd = string.Empty;
            string strLabel = string.Empty;

            // 指示者取得
            XmlNode xmlIndicator = xmlCoopInfo.SelectSingleNode("//RST_DIALYSIS_EDITION/DECIDER");
            if (xmlIndicator == null || string.IsNullOrEmpty(xmlIndicator.InnerText))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_DIALYSIS_SND_DECIDER, "透析実績.版確定者");

                return strStaffCd;
            }

            // 職種コード取得
            string strIndicator = xmlIndicator.InnerText;
            XmlNode xmlJobClass = xmlCoopInfo.SelectSingleNode(string.Format("//RST_DIALYSIS_EDITION/MST_STAFF[STAFF_CD='{0}']/JOB_CLASS_CD", strIndicator));
            if (xmlJobClass == null || string.IsNullOrEmpty(xmlJobClass.InnerText))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_DIALYSIS_SND_DECIDER, "スタッフマスタ.職種コード");

                return strStaffCd;
            }
            if (!xmlJobClass.InnerText.Equals("1"))
            {
                return strStaffCd;
            }

            string strOutXml = "";
            Fn3ReturnCode fn3Ret = this.DBExecQuery("00001", string.Format("<rootNode><VALUE>{0}</VALUE></rootNode>", strIndicator), ref strOutXml);
            if (fn3Ret.IsError || fn3Ret.IsException)
            {
                //	取得失敗
                this.TraceOut(fn3Ret, "スタッフ権限取得用個別クエリが失敗しました。");

                return strStaffCd;
            }

            XmlDocument doc = new XmlDocument();
            try
            {
                doc.LoadXml(strOutXml);
            }
            catch (Exception ex)
            {
                base.ErrorTraceOut(CSIReturnCode.FTL_DIALYSIS_SND_DECIDER, ex);
                return strStaffCd;
            }

            XmlNode xmlAcl = doc.SelectSingleNode("//rootNode/SYS_STAFF_AUTH/ACL");
            if (xmlAcl == null || string.IsNullOrEmpty(xmlAcl.InnerText))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_DIALYSIS_SND_DECIDER, "スタッフ権限.ACL区分");

                return strStaffCd;
            }

            int intAcl;
            if (!int.TryParse(xmlAcl.InnerText, out intAcl))
            {
                //	取得失敗
                this.TraceOut(CSIReturnCode.WNG_DIALYSIS_SND_DECIDER, "スタッフ権限.ACL区分");

                return strStaffCd;
            }
            if (intAcl >= 3)
            {
                strStaffCd = strIndicator;
            }

            return strStaffCd;
        }

        // 2016/04/13 中村 ポップアップ通知対応 Add Start
        #region
        /// <summary>
        /// ポップアップ通知情報登録
        /// </summary>
        private void RegistPopupNotice(Fn3ExecuteInfo exeInfo, bool IsSuccess)
        {
            if ("0" == m_strPopupNotice)
            {
                // 通知しない設定の場合は何もせずに終了
                return;
            }

            // 表示用患者ID
            string strDispPatId = string.Empty;
            if (string.IsNullOrEmpty(this.m_strPatDispID))
            {
                // 患者未指定の場合は何もせずに終了
                return;
            }
            strDispPatId = this.m_strPatDispID.PadLeft(12, '0');

            // 患者名チェック
            string strPatName = "-";
            if (!string.IsNullOrEmpty(this.m_strPatName))
            {
                strPatName = m_strPatName;
            }

            string strSendClass = string.Empty;
            switch (exeInfo.SendClass)
            {
                case "0": strSendClass = "新規"; break;	//	新規
                case "1": strSendClass = "修正"; break;	//	修正
                case "2": strSendClass = "削除"; break;	//	削除
                default: return;
            }

            // 透析日
            string strDialysisDate = string.Empty;
            DateTime dtDialysisDate;
            string strBuf = Fn3ComTool.GetXmlValue(exeInfo.CoopInfoXML, "//rootNode/RST_DIALYSIS_HST/START_DATE");
            if (DateTime.TryParseExact(strBuf, "yyyy/MM/dd HH:mm:ss", null, 0, out dtDialysisDate))
            {
                strDialysisDate = dtDialysisDate.ToString("yyyy/MM/dd");
            }
            else
            {
                return;
            }

            // メッセージ作成
            string strPopUpMsg = string.Empty;
            string strEventCd = string.Empty;
            if (IsSuccess)
            {
                // 成功メッセージ作成
                strPopUpMsg = string.Format("透析実施({0})の送信に成功しました。\n　患者ID：[{1}]\n　患者名：[{2}]\n　透析日：[{3}]",
                              strSendClass, strDispPatId, strPatName, strDialysisDate);
                strEventCd = "4200000001";
            }
            else
            {
                // 失敗メッセージ作成
                strPopUpMsg = string.Format("透析実施({0})の送信に失敗しました。\n　患者ID：[{1}]\n　患者名：[{2}]\n　透析日：[{3}]",
                              strSendClass, strDispPatId, strPatName, strDialysisDate);
                strEventCd = "4200000002";
            }

            // 連携イベントログテーブル存在チェック
            string strSQL = @"<rootNode></rootNode>";
            string strOutXml = string.Empty;
            Fn3ReturnCode retCode = base.DBExecQuery("10002", strSQL, ref strOutXml);
            if (retCode.IsError || retCode.IsException)
            {
                // エラー
                base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_REGIST_POPUP);
                return;
            }
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(strOutXml);
            XmlNode xmlNode = doc.SelectSingleNode("//rootNode/USER_TABLES/TABLE_NAME");
            if (null == xmlNode || !xmlNode.InnerText.Equals("IF_EVENT_LOG"))
            {
                // テーブルがないので処理終了
                TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_NOT_EXIST_IF_EVENT_LOG);
                return;
            }

            // 連携イベントログテーブル登録SQL
            strSQL = string.Format(@"<rootNode><EVENT_CLASS>{0}</EVENT_CLASS><DISP_PATID>{1}</DISP_PATID><NAME>{2}</NAME><EVENT_CD>{3}</EVENT_CD><EVENT_DETAIL>{4}</EVENT_DETAIL></rootNode>",
                                                "透析実施送信", strDispPatId, strPatName, strEventCd, strPopUpMsg);
            // SQL実行
            strOutXml = string.Empty;
            retCode = base.DBExecQuery("10001", strSQL, ref strOutXml);
            if (retCode.IsError || retCode.IsException)
            {
                // トレースログのみ出力
                base.TraceOut(CSIReturnCode.ERR_DIALYSIS_SND_REGIST_POPUP);
            }
        }
        #endregion
        // 2016/04/13 中村 ポップアップ通知対応 Add End

        #endregion
    }
}
