package jp.co.nikkiso.ntss.device_edge.constant;

public final class HostNotifyConstant {

  /**
   * ホスト報知設定JSONのキー
   *
   */
  public static class HostNotificationInfoKey {
    /**
     * 設定項目ごとの設定値
     *
     */
    public static class value {
      /**
       * 設定値 最大値
       * （血圧測定間隔、ケア報知間隔には存在しない）
       */
      public static final String UPPER = "upper";
      /**
       * 設定値 最小値
       * （血圧測定間隔、ケア報知間隔には存在しない）
       */
      public static final String LOWER = "lower";
      /**
       * 設定値 有効フラグ
       */
      public static final String JUDGE = "judge";
      /**
       * 設定値 間隔（分）
       * （血圧測定間隔、ケア報知間隔にのみ存在する）
       */
      public static final String INTERVAL = "interval";
    }
    /**
     * 最高血圧
     */
    public static final String BP_MAX = "bp_max";
    /**
     * 最低血圧
     */
    public static final String BP_MIN = "bp_min";
    /**
     * 平均血圧
     */
    public static final String BP_AVE = "bp_ave";
    /**
     * 脈拍
     */
    public static final String PULSE = "pulse";
    /**
     * 血流量
     */
    public static final String BLOOD_FLOW = "blood_flow";
    /**
     * IP速度
     */
    public static final String IP_SPEED = "ip_speed";
    /**
     * 除水速度
     */
    public static final String UFR = "ufr";
    /**
     * 静脈圧
     */
    public static final String VP = "vp";
    /**
     * 動脈圧
     */
    public static final String AP = "ap";
    /**
     * Na濃度
     */
    public static final String NA_CONC = "na_conc";
    /**
     * 透析液温度
     */
    public static final String DIALYS_TEMP = "dialys_temp";
    /**
     * ΔBV変化率
     */
    public static final String D_BV_ROC = "d_bv_roc";
    /**
     * LDQb
     */
    public static final String LDQP = "ldqb";
    /**
     * 血圧測定間隔
     */
    public static final String BPMI = "bpmi";
    /**
     * ケア報知間隔
     */
    public static final String CARE_I = "care_i";
  }

  /**
   * 項目と対応するモニタデータのキーコード
   *
   */
  public static class SysMonitorItemKey{
    /**
     * 最高血圧
     */
    public static final String BP_MAX = "90";
    /**
     * 最低血圧
     */
    public static final String BP_MIN = "91";
    /**
     * 平均血圧
     */
    public static final String BP_AVE = "92";
    /**
     * 脈拍
     */
    public static final String PULSE = "93";
    /**
     * 血流量
     */
    public static final String BLOOD_FLOW = "8";
    /**
     * IP速度
     */
    public static final String IP_SPEED = "10";
    /**
     * 除水速度
     */
    public static final String UFR = "6";
    /**
     * 静脈圧
     */
    public static final String VP = "11";
    /**
     * 動脈圧(ダイアライザー入口圧)
     */
    public static final String AP = "14";
    /**
     * Na濃度
     */
    public static final String NA_CONC = "20";
    /**
     * 透析液温度
     */
    public static final String DIALYS_TEMP = "21";
    /**
     * ΔBV変化率
     */
    public static final String D_BV_ROC = "80";
    /**
     * LDQb
     */
    public static final String LDQP = "102";
  }

  /**
   * モニタデータキーからホスト報知用の項目名文字列を取得する
   * @param key SysMonitorItemKey
   * @return
   */
  public static String getHostNotifyItemName(String key) {
    switch (key) {
    case SysMonitorItemKey.BP_MAX:
      return "最高血圧";
    case SysMonitorItemKey.BP_MIN:
      return "最低血圧";
    case SysMonitorItemKey.BP_AVE:
      return "平均血圧";
    case SysMonitorItemKey.PULSE:
      return "脈拍";
    case SysMonitorItemKey.BLOOD_FLOW:
      return "血流量";
    case SysMonitorItemKey.IP_SPEED:
      return "IP速度";
    case SysMonitorItemKey.UFR:
      return "除水速度";
    case SysMonitorItemKey.VP:
      return "静脈圧";
    case SysMonitorItemKey.AP:
      return "動脈圧";
    case SysMonitorItemKey.NA_CONC:
      return "Na濃度";
    case SysMonitorItemKey.DIALYS_TEMP:
      return "透析液温度";
    case SysMonitorItemKey.D_BV_ROC:
      return "ΔBV変化率";
    case SysMonitorItemKey.LDQP:
      return "LDQb";
    default:
      return "";
    }
  }

}
