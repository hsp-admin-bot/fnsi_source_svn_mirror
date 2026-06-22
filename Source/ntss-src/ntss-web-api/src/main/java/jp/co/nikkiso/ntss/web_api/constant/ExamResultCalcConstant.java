package jp.co.nikkiso.ntss.web_api.constant;

/**
 * 計算機能共通定数クラス.
 */
public class ExamResultCalcConstant {
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
// add #8144 【デグレ】検査計算結果が検査後にしか反映されない dou start
  /**
   * 透析工程フラグ
   */
  public static class DialysisProgressFlag {
    /**
     * 空
     */
    public static final String EMPTY = "0";

    /**
     * 透析前
     */
    public static final String BEFORE = "1";

    /**
     * 透析後
     */
    public static final String AFTER = "2";

    /**
     * すべて選択
     */
    public static final String ALL = "3";
  }

  /**
   * 登録時検査区分
   */
  public static class OrderClass {
    /**
     * 透析前
     */
    public static final String BEFORE_DIALYSIS = "1";

    /**
     * 透析後
     */
    public static final String AFTER_DIALYSIS = "2";

    /**
     * その他
     */
    public static final String OTHER_DIALYSIS = "0";
  }
// add #8144 【デグレ】検査計算結果が検査後にしか反映されない dou end
  /**
   * 検査使用区分
   */
  public static class ExamClass {
    /**
     * 検査項目
     */
    public static final String EXAM_ITEM = "0";

    /**
     * システム標準計算項目
     */
    public static final String SYSTEM_DEFAULT_CALC_ITEM = "1";

    /**
     * 検査計算項目
     */
    public static final String EXAM_CALC_ITEM = "2";
  }

  /**
   * システム標準計算ID
   */
  public static class ExamItemSystemDefaultCalcFormulaId {
    /**
     * KT/V
     */
    public static final String KT_V = "1";

    /**
     * KT/Ve
     */
    public static final String KT_VE = "2";

    /**
     * KT/Vsp
     */
    public static final String KT_VSP = "3";

    /**
     * Daugirdas Kt/V
     */
    public static final String DAUGIRDAS_KT_V = "4";

    /**
     * BUN除去率
     */
    public static final String EXCLUSION_RATE = "5";

    /**
     * TAC_BUN
     */
    public static final String TAC_BUN = "6";

    /**
     * 補正化 Ca
     */
    public static final String COR_CA = "7";

    /**
     * クリアスペース率
     */
    public static final String CLEAR_SPACE = "8";

    /**
     * PCR
     */
    public static final String PCR = "9";

    /**
     * CreatininIndex
     */
    public static final String CREATININ_INDEX = "10";

    /**
     * Kt/V(shinzato)
     */
    public static final String KT_V_SHINZATO = "11";

    /**
     * BMI
     */
    public static final String BMI = "12";

    /**
     * GNRI
     */
    public static final String GNRI = "13";

    /**
     * Cr除去率
     */
    public static final String CR_EXCLUSION_RATE = "14";

    /**
     * TSAT
     */
    public static final String T_SAT = "15";
  }

  /**
   * システム標準計算使用カラム.
   */
  public static class ExamResultCalcColumns {

    /**
     * BUN.
     */
    public static final String BUN = "1";

    /**
     * 血清Ca濃度.
     */
    public static final String SERUM_CA_CONCENTRATION = "2";

    /**
     * 血清アルブミン.
     */
    public static final String SERUM_ALBUMIN_CONCENTRATION = "3";

    /**
     * クレアチニン.
     */
    public static final String CREATININE = "4";

    /**
     * 血清鉄.
     */
    public static final String SERUM_FE = "5";

    /**
     * 総鉄結合能.
     */
    public static final String TIBC = "6";

    /**
     * ヘマトクリット.
     */
    public static final String HEMATOCRIT = "7";

    /**
     * その他検査計算使用項目.
     */
    public static final String OTHER = "8";

  }

  /**
   * 検査計算できなかった場合に設定する文字列
   */
  public static final String CALC_RESULT_NONE = "";
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
}
