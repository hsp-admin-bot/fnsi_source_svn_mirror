package jp.co.nikkiso.ntss.admin_web.service.scaleBed.constant;


public class CheckingParameterCode {
  /**
   * DW
   */
  public static final String DW = "[dw]";

  /**
   * 目標体重
   */
  public static final String TARGET_WEIGHT = "[tw]";

  /**
   * 測定値
   */
  public static final String MEASURE_VALUE = "[mv]";

  /**
   * 前体重
   */
  public static final String BEFORE_WEIGHT = "[bw]";

  /**
   * 後体重
   */
  public static final String AFTER_WEIGHT = "[aw]";

  /**
   * 前回後体重
   */
  public static final String LAST_AFTER_WEIGHT = "[lw]";

  /**
   * 目標除水量
   */
  public static final String TARGET_OFF_WATER = "[twat]";

  /**
   * 除水制限値
   */
  public static final String LIMIT_OFF_WATER = "[lwat]";

  /**
   * 風袋
   */
  public static final String TARE = "[tare]";

  /**
   * 除水補正
   */
  public static final String OFF_WATER = "[wat]";

  /**
   * 除水実績
   */
  public static final String RESULT_OFF_WATER = "[rwat]";

  /**
   * 次回透析予定１
   */
  public static final String NEXT_DATE_1 = "[nd1]";

  /**
   * 次回透析予定2
   */
  public static final String NEXT_DATE_2 = "[nd2]";

  /**
   * BMI
   */
  public static final String BMI = "[bmi]";

  /**
   * I-HDF引き残し量
   */
  public static final String PG = "[pg]";

  /**
   * 車椅子
   */
  public static final String WHEEL_CHAIR = "[wc]";

  /**
   * 前体重許容上限
   */
  public static final String BEFORE_WEIGHT_MAX = "[bwmx]";

  /**
   * 前体重許容下限
   */
  public static final String BEFORE_WEIGHT_MIN = "[bwmn]";

  public static final String[] ALL_CODE = new String[]{
    DW,
    TARGET_WEIGHT,
    MEASURE_VALUE,
    BEFORE_WEIGHT,
    AFTER_WEIGHT,
    LAST_AFTER_WEIGHT,
    TARGET_OFF_WATER,
    LIMIT_OFF_WATER,
    TARE,
    OFF_WATER,
    RESULT_OFF_WATER,
    NEXT_DATE_1,
    NEXT_DATE_2,
    BMI,
    PG,
    WHEEL_CHAIR,
    BEFORE_WEIGHT_MAX,
    BEFORE_WEIGHT_MIN
  };
}
