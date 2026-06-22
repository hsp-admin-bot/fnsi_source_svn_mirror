package web.constant;

import io.micrometer.core.instrument.util.StringUtils;
import org.springframework.util.ObjectUtils;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

/**
 * 治療条件IV設定項目定義Enum
 *
 */
public enum TreatmentItemsDef {

  /**
   * 治療時間
   */
  T_I_START_DATE("1", "分", "240"
          , "", "", getItemValueFormatPatten("0", "0"), 5,
          Arrays.asList(
                  "value",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable")),
  /** 目標体重 */
  T_I_WEIGHT("3", "Kg", "-1"
          , "300.00", "0.00", getItemValueFormatPatten("2"), 5,
          Arrays.asList(
                  "value",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable")),
  /** 除水量制限 */
  T_I_FILTER_LIMIT("4", "L", "5.00"
          , "39.99", "0.00", getItemValueFormatPatten("2"), 4,
          Arrays.asList(
                  "value",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable")),
  /**
   * 血流量
   */
  T_I_BLOOD_FLOW("14", "mL/min", "200"
          , "600", "0", getItemValueFormatPatten("3", "0"), 3,
          Arrays.asList(
                  "value",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable")),
  /** 補液 */
  T_I_IV("19", "", null
          , "", "", "", -1,
          Arrays.asList(
                  "value",
                  "medicine_type",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable")),
  /**
   * 補液量
   */
  T_I_IV_AMOUNT("20", "L", "0.0"
          , "999.0", "0.0", getItemValueFormatPatten("4", "1"), 4,
          Arrays.asList(
                  "value",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable")),
  /**
   * 補液選択
   */
  T_I_IV_SELECTION("21", "", "1"
          , "1", "0", "", 1,
          Arrays.asList(
                  "value",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable")),
  /**
   * 補液速度
   */
  T_I_IV_FLOW_RATE("24", "L/h", "0.00"
          , "999.00", "0.00", getItemValueFormatPatten("5", "2"), 7,
          Arrays.asList(
                  "value",
                  "ind_user_id",
                  "ind_user_last_name",
                  "ind_user_first_name",
                  "upd_user_id",
                  "upd_user_last_name",
                  "upd_user_first_name",
                  "input_class",
                  "cop_order_no",
                  "is_editable"));


  /**
   * 治療条件項目番号
   */
  @Getter
  private final String itemCode;


  /**
   * 治療条件項目デフォルト設定値：初期値
   */
  @Getter
  private final String defaultValue;

  /**
   * 設定値デフォルトフォーマットパータン
   */
  private final String valueFormatPatten;

  /**
   * 設定値の最大値
   */
  private final String maxValue;

  /**
   * 設定値の最小値
   */
  private final String minValue;

  /**
   * 設定値桁数 -1:制限しない
   */
  @Getter
  private final int maxLength;

  /**
   * 治療条件情報の初期化設定
   *
   * @param itemCode          項目番号
   * @param defaultUnit       デフォルトの単位値は、不要な場合は空の文字列に設定されます
   * @param defaultValue      デフォルト値。nullに設定されている場合は、そのデフォルト値をnullに設定でき、JSONのnullに再変換する必要があります
   * @param maxValue          最大値（空の文字列またはnullに設定されている場合）は、制限されていないことを示します
   * @param minValue          最小値（空の文字列またはnullに設定されている場合）は、制限されていないことを示します
   * @param valueFormatPatten 設定値のフォーマットされたパターンは、NULLに設定されている場合、取得時に最大長制限を判断して戻り値を決定します。
   *                          1、最大長さが制限されていない場合は、整数パターン:%dを返します。
   *                          2、最大長さが制限されている場合は、純小数パターン:%を返します。[maxLength]f
   * @param maxLength         最大长度限制
   * @param defaultJSONKey    item对应的value包含的json key
   */
  TreatmentItemsDef(String itemCode
          , String defaultUnit
          , String defaultValue
          , String maxValue
          , String minValue
          , String valueFormatPatten
          , int maxLength, List<String> defaultJSONKey
  ) {
    this.itemCode = itemCode;
    this.defaultValue = defaultValue;
    this.maxValue = maxValue;
    this.minValue = minValue;
    this.valueFormatPatten = valueFormatPatten;
    this.maxLength = maxLength;
  }

  /**
   * フォーマットパータンの開始
   */
  private static final String DEFAULT_FORMAT_START = "%";
  /**
   * デフォルト精度
   */
  private static final String DEFAULT_ACC_LENGTH = "1";
  /**
   *
   */
  private static final String POINT = ".";
  /**
   *
   */
  private static final String FLOAT_PATTEN = "f";

  private static final String NUM_PATTEN = "d";

  /**
   * デフォルトのフォーマットパータンを取得
   *
   * @return デフォルトのフォーマットパータン
   */
  public static String getItemValueDefaultFormatPatten() {
    return getItemValueFormatPatten(DEFAULT_ACC_LENGTH);
  }

  /**
   * 設定精度のフォーマットパータン構成メソッド
   * e.g.
   * ・整数部長さは「2」、小数部長さは「2」 -> %2.2f
   * ・整数部長さは「0」、小数部長さは「2」 -> %.2f
   * ・小数部長さは「0」、整数部長さは「2」 -> %2d
   * ・整数部と小数部のパラメータは非正整数　-> %d
   *
   * @param intLength 整数部長さ属性
   * @param accLength 小数部長さ属性
   * @return フォーマットパータン
   */
  private static String getItemValueFormatPatten(String intLength, String accLength) {
    intLength = ObjectUtils.isEmpty(intLength) ? "" : intLength;
    accLength = ObjectUtils.isEmpty(accLength) ? "" : accLength;

    if (isInteger(intLength) && Integer.parseInt(intLength) > 0) {
      if (isInteger(accLength) && Integer.parseInt(accLength) > 0) {
        return DEFAULT_FORMAT_START + intLength + POINT + accLength + FLOAT_PATTEN;
      } else {
        return DEFAULT_FORMAT_START + intLength + NUM_PATTEN;
      }
    } else {
      if (isInteger(accLength) && Integer.parseInt(accLength) > 0) {
        return DEFAULT_FORMAT_START + POINT + accLength + FLOAT_PATTEN;
      } else {
        return DEFAULT_FORMAT_START + NUM_PATTEN;
      }
    }
  }

  public static String getItemValueFormatPatten(String accLength) {
    return DEFAULT_FORMAT_START + POINT + accLength + FLOAT_PATTEN;
  }

  /**
   * パラメータが非負整数かどうかを判断する
   *
   * @param str パラメータ
   * @return 非負整数はtrue
   */
  public static boolean isInteger(String str) {
    if (ObjectUtils.isEmpty(str)) return false;
    Pattern pattern = Pattern.compile("^\\d*$");
    return pattern.matcher(str).matches();
  }

  /**
   * パラメータが非負フロートかどうかを判断する。
   * フロート数に正常に変換できるの場所、trueを戻り。
   * e.g.   "12.345" -> true
   * "12"  -> true
   * "12." -> false
   * ".1234" -> false
   * "12.0" -> true
   * "00.00" -> true
   * "010.02030" -> true
   * null -> false
   * "" -> false
   */
  public static boolean isFloat(String str) {
    if (ObjectUtils.isEmpty(str)) return false;
    Pattern pattern = Pattern.compile("^\\d+(\\.\\d+)?$");
    return pattern.matcher(str).matches();
  }

  public String getValueFormatPatten() {
    if (ObjectUtils.isEmpty(valueFormatPatten)) {
      if (maxLength == -1) {
        return getItemValueFormatPatten("0", "0");
      } else if (maxLength > 0) {
        return getItemValueFormatPatten(String.valueOf(getMaxLength()));
      } else {
        return getItemValueDefaultFormatPatten();
      }
    }
    return valueFormatPatten;
  }


  /**
   * According to the formatting format set in this project, format the specified setting value into a string.
   *
   * @param valueForFormat 設定値
   * @return 書式設定後の設定値
   */
  public String getFormattedValue(BigDecimal valueForFormat) {
    // 書式設定
    return getFormattedValueWithDecPoint(getValueFormatPatten(), valueForFormat);
  }

  public String getFormattedValueWithDecPoint(String formatPatten, BigDecimal valueForFormat) {
    if (valueForFormat == null)
      return getDefaultValue();

    formatPatten = ObjectUtils.isEmpty(formatPatten) ? getValueFormatPatten() : formatPatten;
    String valueStr = String.format(formatPatten, valueForFormat).trim();

    // Min Value
    if (StringUtils.isNotEmpty(minValue)) {
      if (compareWithMinValue(valueStr) < 0)
        return minValue;
    }
    // Max Value
    if (StringUtils.isNotEmpty(maxValue)) {
      if (compareWithMaxValue(valueStr) > 0)
        return maxValue;
    }
    return valueStr;
  }

  /**
   * パラメータと定義された最大値の比較
   *
   * @param cmpValue 比較する数値
   * @return 1 -> パラメータが最大値より大きい
   * 0 -> パラメータは最大値と等しい（通常）
   * -1 -> パラメータが最大値未満（通常）
   */
  public int compareWithMaxValue(String cmpValue) {
    if (!isFloat(cmpValue)) return 1;
    return new BigDecimal(cmpValue).compareTo(new BigDecimal(maxValue));
  }

  /**
   * パラメータと定義された最小値の比較
   *
   * @param cmpValue 比較する数値
   * @return 1 -> パラメータが最小値より大きい（通常）
   * 0 -> パラメータは最小値と等しい（通常）
   * -1 -> パラメータが最小値未満
   */
  public int compareWithMinValue(String cmpValue) {
    if (!isFloat(cmpValue)) return -1;
    return new BigDecimal(cmpValue).compareTo(new BigDecimal(minValue));
  }
}
