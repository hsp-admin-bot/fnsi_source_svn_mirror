package jp.co.nikkiso.ntss.coop_api.utils;

// #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-02-11 卓 ---start
public class PatInfoConstant {
  // メッセージ
  public static class InOutVisitHistoryInfo {
    /**
     * 導入
     */
    public static final String INTRODUCTION = "1";

    /**
     * 転入
     */
    public static final String MOVE_IN = "2";

    /**
     * 転出
     */
    public static final String MOVING_OUT = "3";

    /**
     * 入院
     */
    public static final String HOSPITALIZATION = "4";

    /**
     * 退院
     */
    public static final String DISCHARGE = "5";

    /**
     * 外来
     */
    public static final String OUTPATIENT = "6";

    /**
     * 離脱
     */
    public static final String WITHDRAWAL = "7";

    /**
     * 移植
     */
    public static final String IMPLANTATION = "8";

    /**
     * 一時転出
     */
    public static final String TEMP_MOVING_OUT = "9";

    /**
     * 通院拒否・不明
     */
    public static final String UNKNOWN = "10";

    /**
     * 死亡
     */
    public static final String DEATH = "11";
  }
}
// #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-02-11 卓 ---end

