package jp.co.nikkiso.ntss.admin_web.request.bloodPurify.dto;

public final class MntMotionRecordStaticValues {

  /**
   * 1：装置記録
   * 2：緊急発報記録
   * 3：予防保全/故障予知記録
   * 4：自己診断結果
   * 5：溶解記録
   * 6：データ収集記録
   */
  public static class DataType {

    /**
     * 1：装置記録
     */
    public static final int LOG = 1;
    /**
     * 2：緊急発報記録
     */
    public static final int M_NOTICE = 2;
    /**
     * 3：予防保全/故障予知記録
     */
    public static final int PREVENTION = 3;
    /**
     * 4：自己診断結果
     */
    public static final int SELF_DIAGNOSIS = 4;
    /**
     * 5：溶解記録
     */
    public static final int DISSOLUTION = 5;
    /**
     * 6：データ収集記録
     */
    public static final int DATA_COLLECT = 6;
  }

  /**
   * 1：配管（UFRC）自己診断
   * 2：漏血自己診断
   * 3：透析液流量自己診断
   * 4：濃度自己診断
   * 5：配管テスト
   * 6：希釈テスト
   * 7：自己診断結果(通信共通)
   */
  public static class TestType {

    /**
     * 1：配管（UFRC）自己診断
     */
    public static final int UFRC = 1;
    /**
     * 2：漏血自己診断
     */
    public static final int BLEEDING = 2;
    /**
     * 3：透析液流量自己診断
     */
    public static final int DIALYSIS_FLOW = 3;
    /**
     * 4：濃度自己診断
     */
    public static final int CONCENTRATION = 4;
    /**
     * 5：配管テスト
     */
    public static final int PIPE_TEST = 5;
    /**
     * 6：希釈テスト
     */
    public static final int DILUTION_TEST = 6;
    /**
     * 7：自己診断結果(通信共通V4)
     */
    public static final int COMMON_COMM_V4 = 7;
  }

  public static class MachineRecordMessage {

    /**
     * 配管（UFRC）自己診断
     */
    public static final String UFRC = "配管自己診断";
    /**
     * 漏血自己診断
     */
    public static final String BLEEDING = "漏血自己診断結果";
    /**
     * 透析液流量自己診断
     */
    public static final String DIALYSIS_FLOW = "透析液流量自己診断結果";
    /**
     * 濃度自己診断
     */
    public static final String CONCENTRATION = "濃度自己診断結果";
    /**
     * 配管テスト
     */
    public static final String PIPE_TEST = "配管テスト結果";
    /**
     * 希釈テスト
     */
    public static final String DILUTION_TEST = "希釈テスト結果";

    /**
     * 溶解記録
     */
    public static final String DISSOLUTION = "溶解記録";

    /**
     * 自己診断結果(通信共通V4)
     */
    public static final String COMMON_COMM_V4 = "自己診断結果";

    public static String getTestTypeMessage(int testType) {
      switch (testType) {
      case TestType.UFRC:
        return UFRC;
      case TestType.BLEEDING:
        return BLEEDING;
      case TestType.DIALYSIS_FLOW:
        return DIALYSIS_FLOW;
      case TestType.CONCENTRATION:
        return CONCENTRATION;
      case TestType.PIPE_TEST:
        return PIPE_TEST;
      case TestType.DILUTION_TEST:
        return DILUTION_TEST;
      case TestType.COMMON_COMM_V4:
        return COMMON_COMM_V4;
      }
      return "";
    }
  }

}
