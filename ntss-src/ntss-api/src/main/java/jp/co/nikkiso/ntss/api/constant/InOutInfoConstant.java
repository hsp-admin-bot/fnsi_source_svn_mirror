package jp.co.nikkiso.ntss.api.constant;

/**
 * 入外区分・転入出情報更新処理 共通定数クラス.
 */
public class InOutInfoConstant {

  /**
   * 患者情報-入外・転入出カード-区分値(画面入力値)
   */
  public static class InOutVisitHistoryInfoMoveInOut {
    /**
     * 導入
     */
    public static final String MOVE_IN_OUT_CLASS_INTRODUCTION = "1";

    /**
     * 転入
     */
    public static final String MOVE_IN_OUT_CLASS_MOVE_IN = "2";

    /**
     * 転出
     */
    public static final String MOVE_IN_OUT_CLASS_MOVING_OUT = "3";

    /**
     * 入院
     */
    public static final String MOVE_IN_OUT_CLASS_HOSPITALIZATION = "4";

    /**
     * 退院
     */
    public static final String MOVE_IN_OUT_CLASS_DISCHARGE = "5";

    /**
     * 外来
     */
    public static final String MOVE_IN_OUT_CLASS_OUTPATIENT = "6";

    /**
     * 離脱
     */
    public static final String MOVE_IN_OUT_CLASS_WITHDRAWAL = "7";

    /**
     * 移植
     */
    public static final String MOVE_IN_OUT_CLASS_IMPLANTATION = "8";

    /**
     * 一時転出
     */
    public static final String MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT = "9";

    /**
     * 通院拒否・不明
     */
    public static final String MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN = "10";

    /**
     * 死亡
     */
    public static final String MOVE_IN_OUT_CLASS_DEATH = "11";

  }

  /**
   * 転入出状態(DB保存値)
   */
  public static class PatInfoMoveInOut {
    /**
     * 在院
     */
    public static final String MOVE_IN_OUT_HOSPITALIZATION = "0";

    /**
     * 導入予定
     */
    public static final String MOVE_IN_OUT_INTRODUCTION_PLAN = "1";

    /**
     * 転入予定
     */
    public static final String MOVE_IN_OUT_MOVE_IN_PLAN = "2";

    /**
     * 転出
     */
    public static final String MOVE_IN_OUT_MOVING_OUT = "3";

    /**
     * 離脱
     */
    public static final String MOVE_IN_OUT_WITHDRAWAL = "7";

    /**
     * 移植
     */
    public static final String MOVE_IN_OUT_IMPLANTATION = "8";

    /**
     * 一時転出
     */
    public static final String MOVE_IN_OUT_TEMPORARILY_MOVING_OUT = "9";

    /**
     * 不明
     */
    public static final String MOVE_IN_OUT_UNKNOWN = "10";

    /**
     * 死亡
     */
    public static final String MOVE_IN_OUT_DEATH = "11";

  }

  /**
   * 入外区分値(画面入力値/DB保存値 共通)
   */
  public static class PatInfoInOutClass {
    /**
     * 外来
     */
    public static final String IN_OUT_CLASS_OUTPATIENT = "0";

    /**
     * 入院
     */
    public static final String IN_OUT_CLASS_HOSPITALIZATION = "1";

    /**
     * 死亡
     */
    public static final String IN_OUT_CLASS_DEATH = "2";

    /**
     * － (不在)
     */
    public static final String IN_OUT_CLASS_ABSRENCE = "3";

  }

}
