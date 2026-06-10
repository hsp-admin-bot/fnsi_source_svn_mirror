package jp.co.nikkiso.ntss.api.service.report;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
@Slf4j
public class ReportTotalService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407add yangxuewang end

  /*
   * 時間間隔単位
   */
  private static final String YEAR = "年";
  private static final String MONTH = "月";
  private static final String DAY = "日";
  private static final String DAY_OF_WEEK = "曜日";

  // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
  /*
   * 日付時刻の書式文字列
   */
  private enum Format_DateTime {
    FORMAT_1("yyyy\"年\"m\"月\"d\"日\"(aaa) h\"時\"mm\"分\"", "yyyy年M月d日(E) H時mm分"),
    FORMAT_2("yyyy\"年\"m\"月\"d\"日\" h\"時\"mm\"分\"", "yyyy年M月d日 H時mm分"),
    FORMAT_3("yyyy/m/d h:mm", "yyyy/M/d H:mm"),
    FORMAT_4("yyyy/mm/dd hh:mm", "yyyy/MM/dd HH:mm"),
    FORMAT_5("yyyy\"年\"m\"月\"", "yyyy年M月"),
    FORMAT_6("ge/m", "Gyyyy/M"),
    FORMAT_7("yyyy\"年\"m\"月\"d\"日\"(aaa)", "yyyy年M月d日(E)"),
    FORMAT_8("yyyy\"年\"m\"月\"d\"日\"", "yyyy年M月d日"),
    FORMAT_9("yyyy/m/d", "yyyy/M/d"),
    FORMAT_10("yyyy/mm/dd", "yyyy/MM/dd"),
    FORMAT_11("ggge\"年\"m\"月\"d\"日\"(aaa)", "GGGG年M月d日(E)"),
    FORMAT_12("ggge\"年\"m\"月\"d\"日\"", "GGGG年M月d日"),
    FORMAT_13("ge/m/d", "Gyyyy/M/d"),
    FORMAT_14("m\"月\"d\"日\"(aaa)", "M月d日(E)"),
    FORMAT_15("m\"月\"d\"日\"", "M月d日"),
    FORMAT_16("m/d(aaa)", "M/d(E)"),
    FORMAT_17("m/d", "M/d"),
    FORMAT_18("(aaa)", "(E)"),
    FORMAT_19("aaa\"曜日\"", "EEEE"),
    FORMAT_20("m/d h:mm", "M/d H:mm"),
    FORMAT_21("[h]:mm:ss", "[h]:mm:ss"),
    FORMAT_22("h:mm:ss", "H:mm:ss"),
    FORMAT_23("[h]\"時間\"mm\"分\"ss\"秒\"", "[h]時間mm分ss秒"),
    FORMAT_24( "h\"時\"mm\"分\"ss\"秒\"", "H時mm分ss秒"),
    FORMAT_25("[h]:mm", "[h]:mm"),
    FORMAT_26( "h:mm", "H:mm"),
    FORMAT_27( "hh:mm", "HH:mm"),
    FORMAT_28("[h]\"時間\"mm\"分\"", "[h]時間mm分"),
    FORMAT_29("h\"時\"mm\"分\"", "H時mm分"),
    FORMAT_30( "h:mm AM/PM", "H:mm a")
    ;

    private final String formatByExcel;
    private final String formatByJava;

    Format_DateTime(String formatByExcel, String formatByJava) {
      this.formatByExcel = formatByExcel;
      this.formatByJava = formatByJava;
    }

    public String getFormatByExcel() {
      return formatByExcel;
    }

    public String getFormatByJava() {
      return formatByJava;
    }
  }

  private static Map<String, String> getDateTimeFormatSet() {
    return new HashMap<String, String>() {
      {
        put("[h]:mm:ss", "yyyy-MM-dd HH:mm:ss");
        put("[h]時間mm分ss秒", "yyyy-MM-dd HH:mm:ss");

        put("yyyy年M月d日(E) H時mm分", "yyyy-MM-dd HH:mm");
        put("yyyy年M月d日 H時mm分", "yyyy-MM-dd HH:mm");
        put("yyyy/M/d H:mm", "yyyy-MM-dd HH:mm");
        put("yyyy/MM/dd HH:mm", "yyyy-MM-dd HH:mm");
        put("[h]:mm", "yyyy-MM-dd HH:mm");
        put("[h]時間mm分", "yyyy-MM-dd HH:mm");

        // mod #12444 複数集計の日付表示がおかしい limingzhe start
        //put("M/d H:mm", "MM-dd HH:mm");
        put("M/d H:mm", "yyyy-MM-dd HH:mm");
        // mod #12444 複数集計の日付表示がおかしい limingzhe end

        put("yyyy年M月d日(E)", "yyyy-MM-dd");
        put("yyyy年M月d日", "yyyy-MM-dd");
        put("yyyy/M/d", "yyyy-MM-dd");
        put("yyyy/MM/dd", "yyyy-MM-dd");
        put("GGGG年M月d日(E)", "yyyy-MM-dd");
        put("GGGG年M月d日", "yyyy-MM-dd");
        put("Gyyyy/M/d", "yyyy-MM-dd");

        put("(E)", "EEEE");
        put("EEEE", "EEEE");

        put("yyyy年M月", "yyyy-MM");
        put("GGGG年M月", "yyyy-MM");
        put("Gyyyy/M", "yyyy-MM");

        // mod #12444 複数集計の日付表示がおかしい limingzhe start
        //put("M月d日(E)", "M月d日");
        //put("M月d日", "M月d日");
        //put("M/d(E)", "M月d日");
        //put("M/d", "M月d日");
        put("M月d日(E)", "yyyy-MM-dd");
        put("M月d日", "yyyy-MM-dd");
        put("M/d(E)", "yyyy-MM-dd");
        put("M/d", "yyyy-MM-dd");
        // mod #12444 複数集計の日付表示がおかしい limingzhe end

        put("H時mm分ss秒", "HH:mm:ss");
        put("H:mm:ss", "HH:mm:ss");

        put("H:mm", "HH:mm");
        put("HH:mm", "HH:mm");
        put("H時mm分", "HH:mm");
        put("H:mm a", "HH:mm");

        put("yyyy年", "yyyy");
        put("yyyy", "yyyy");
        put("GGGG年", "yyyy");
        put("Gyyyy", "yyyy");
      }
    };
  }
  /**
   * 日付時刻の書式種類
   * flag （1：Excel、2：Java）
   */
  private static boolean isDispFormatInList(int flag, String dispFormat) {
    if(flag == 1) {
      for (Format_DateTime format : Format_DateTime.values()) {
        if (dispFormat.equals(format.getFormatByExcel())) {
          return true;
        }
      }
    }
    else if(flag == 2){
      for (Format_DateTime format : Format_DateTime.values()) {
        if (dispFormat.equals(format.getFormatByJava())) {
          return true;
        }
      }
    }
    return false;
  }

  private static String getDispFormatInListJavatoExcel(String dispFormat) {
    for (Format_DateTime format : Format_DateTime.values()){
      if(dispFormat.equals(format.getFormatByJava())){
        return format.getFormatByExcel();
      }
    }
    return dispFormat;
  }

  private static String getDispFormatInListExceltoJava(String dispFormat) {
    for (Format_DateTime format : Format_DateTime.values()){
      if(dispFormat.equals(format.getFormatByExcel())){
        return format.getFormatByJava();
      }
    }
    return dispFormat;
  }

  public static String getUnitDispFormatForExcel(String totalUnitDate, String dispFormat) {
    if(StringUtils.isEmpty(dispFormat)) return dispFormat;
    String format = "";
    boolean bExcel = isDispFormatInList(1, dispFormat);
    boolean bJava = isDispFormatInList(2, dispFormat);
    if(bExcel || bJava){
      if(bExcel){
        format = dispFormat;
      }
      else if(bJava){
        format = getDispFormatInListJavatoExcel(dispFormat);
      }
    }
    else {
      format = dispFormat;
    }

    switch (totalUnitDate) {
      case YEAR:
        if(format.contains("/m"))  format = format.split("/m")[0];
        else if(format.contains("-m"))  format = format.split("-m")[0];
        else if(format.contains("m"))  format = format.split("m")[0];
        break;
      case MONTH:
        if(format.contains("/d"))  format = format.split("/d")[0];
        else if(format.contains("-d"))  format = format.split("-d")[0];
        else if(format.contains("d"))  format = format.split("d")[0];
        break;
      case DAY:
        break;
      case DAY_OF_WEEK:
        return "aaa";
    }
    return format;
  }

  private static String getUnitDispFormatForJava(String totalUnitDate, String dispFormat) {
    if(StringUtils.isEmpty(dispFormat)) return dispFormat;
    String format = "";
    boolean bExcel = isDispFormatInList(1, dispFormat);
    boolean bJava = isDispFormatInList(2, dispFormat);
    if(bExcel || bJava){
      if(bExcel){
        format = getDispFormatInListExceltoJava(dispFormat);
      }
      else if(bJava){
        format = dispFormat;
      }
    }
    else {
      format = "yyyy-MM-dd HH:mm:ss";
    }

    switch (totalUnitDate) {
      case YEAR:
        if(format.contains("/M"))  format = format.split("/M")[0];
        else if(format.contains("-M"))  format = format.split("-M")[0];
        else if(format.contains("M"))  format = format.split("M")[0];
        break;
      case MONTH:
        if(format.contains("/d"))  format = format.split("/d")[0];
        else if(format.contains("-d"))  format = format.split("-d")[0];
        else if(format.contains("d"))  format = format.split("d")[0];
        break;
      case DAY:
        break;
      case DAY_OF_WEEK:
        return dispFormat;
    }
    Map<String, String> dtf = getDateTimeFormatSet();
    if(dtf.containsKey(format)){
      format = dtf.get(format);
    }
    return format;
  }
  // add #11985 定期点検一覧帳票が正常に出せない limingzhe end

  /**
   * 表示内容種類
   */
  private static final String CONTENTS_TYPE_FIRST = "先頭";
  private static final String CONTENTS_TYPE_LAST = "後尾";
  private static final String CONTENTS_TYPE_CONCAT = "全部";

  /**
   * 表示内容：（項目値（前）：first、項目値（後）：last、項目値（連結）：concat、合　計：total、平均値：avg、最大値：max、最小値：min）
   */
  private static final String FIRST = "first";
  private static final String LAST = "last";
  private static final String CONCAT = "concat";
  private static final String TOTAL = "total";
  private static final String AVG = "avg";
  private static final String MAX = "max";
  private static final String MIN = "min";

  /*
   * @param totalContents 集計内訳の表示内容
  */
  public static String getTotalContentsType(String totalContents, String totalContentsType){
    switch (totalContents) {
      case "項目値":
        switch (totalContentsType) {
          case CONTENTS_TYPE_FIRST:
            return FIRST;
          case CONTENTS_TYPE_LAST:
            return LAST;
          case CONTENTS_TYPE_CONCAT:
            return CONCAT;
          default:
            return FIRST;
        }
      case "合　計":
        return TOTAL;
      case "平均値":
        return AVG;
      case "最大値":
        return MAX;
      case "最小値":
        return MIN;
      default:
        return CONCAT;
    }
  }

  /**
   * 繰返方向：（N：0、Z：1）
   */
  private static final String DIRECTION_N = "N";
  private static final String DIRECTION_Z = "Z";

  /*
   * @param direction 集計内訳の繰返方向
   */
  public static String getTmplRepeatDirection(int direction){
    switch (direction) {
      case 0:
        return DIRECTION_N;
      case 1:
        return DIRECTION_Z;
      default:
        return DIRECTION_N;
    }
  }

  /**
   * 結果は方向を示します
   */
  private static final String ROW_FLAG = "row";
  private static final String COLUMN_FLAG = "column";
  private static final String TOTAL_FLAG = "total";

  /*
   * @param direction 集計の結果は方向を示します ：（row：1、column：2）
   */
  public static String getResultShowDirection(int direction){
    switch (direction) {
      case 1:
        return ROW_FLAG;
      case 2:
        return COLUMN_FLAG;
      default:
        return TOTAL_FLAG;
    }
  }

  /**
   * 合計のkey
   */
  private static final String ROW_TOTAL_KEY = "rowTotals";
  private static final String COLUMN_TOTAL_KEY = "columnTotals";
  private static final String TOTAL_KEY = "grandTotal";

  /**
   * 合計は方向を示します
   */
  private static final String ROW_TOTAL_FLAG = "横合計";
  private static final String COLUMN_TOTAL_FLAG = "縦合計";

  /*
   * 合計の名称
   */
  private static final String ROW_TOTAL_NAME = "合計";
  private static final String COLUMN_TOTAL_NAME = "合計";

  private static final String NAME_CONCAT_FLAG = ",";

  private static String toHalfWidth(String input) {
    if (input == null) return null;
    StringBuilder sb = new StringBuilder();
    for (char c : input.toCharArray()) {
      if (c >= '０' && c <= '９') {
        sb.append((char)(c - '０' + '0'));
      } else if (c == '．') {
        sb.append('.');
      } else if (c == '－') {
        sb.append('-');
      } else {
        sb.append(c);
      }
    }
    return sb.toString();
  }

  /**
   * 数字型の判定処理
   * @return true:数字型 false:非数字型
   */
  private static boolean isNumeric(Object value) {
    if (value == null) {
      return false;
    }
    String str = value.toString();
    return str.matches("[0-9]+") || str.matches("[０-９]+");  // Handling half-width and full-width digits
  }

  /**
   * 数字型の判定処理
   * @param str　文字列
   * @return true:数字型 false:非数字型
   */
  private static boolean isNumeric(String str) {
    if (str == null || str.trim().isEmpty()) return false;
    str = toHalfWidth(str); // full-width → half-width
    int decimalCount = 0;
    boolean hasNegativeSign = false;
    for (int i = 0; i < str.length(); i++) {
      char c = str.charAt(i);
      // Check for negative sign only at the beginning
      if (i == 0 && c == '-') {
        hasNegativeSign = true;
      } else if (c == '.') {
        decimalCount++;
        // Ensure decimal point occurs only once
        if (decimalCount > 1) {
          return false;
        }
      } else if (!Character.isDigit(c)) {
        return false;
      }
    }
    // If there is a negative sign, string length should be greater than 1
    if (hasNegativeSign && str.length() == 1) {
      return false;
    }
    return true;
  }

  private static Double parseNumeric(String valStr) {
    if (valStr == null || valStr.trim().isEmpty()) return null;
    valStr = toHalfWidth(valStr); // full-width → half-width
    try {
      return Double.parseDouble(valStr);
    } catch (NumberFormatException e) {
      return null;
    }
  }

  private static boolean isTimestamp(Object value){
    if (value == null) {
      return false;
    }
    if (value instanceof Timestamp) {
      return true;
    }
    else if (value instanceof Long) {
      Long lValue = (Long) value;
      if (lValue > 0 && lValue < System.currentTimeMillis() + 1000 * 60 * 60 * 24 * 365 * 10) {
        return true;
      } else {
        return false;
      }
    }
    else {
      return false;
    }
  }

  private static Date parseDate(String s) throws Exception {
    List<String> formats = Arrays.asList("yyyy-MM-dd HH:mm:ss", "yyyy/MM/dd HH:mm:ss", "yyyy-MM-dd", "yyyy/MM/dd", "yyyyMMdd");
    for (String fmt : formats) {
      try {
        return new SimpleDateFormat(fmt).parse(s);
      } catch (Exception ignored) {}
    }
    throw new Exception("日付形式を認識できません: " + s);
  }

  private static String getJapaneseWeekday(int dayOfWeek) {
    switch (dayOfWeek) {
      case Calendar.SUNDAY: return "日";
      case Calendar.MONDAY: return "月";
      case Calendar.TUESDAY: return "火";
      case Calendar.WEDNESDAY: return "水";
      case Calendar.THURSDAY: return "木";
      case Calendar.FRIDAY: return "金";
      case Calendar.SATURDAY: return "土";
    }
    return "";
  }

  static class CellValues {
    List<String> originalValues = new ArrayList<>();
    List<Double> numericValues = new ArrayList<>();
  }

  public static class AggregationResult {
    public List<Map<String, Object>> mainTable = new ArrayList<>(); // 主表
    public Set<String> rowName = new LinkedHashSet<>(); // 縦の単位
    public Set<String> columnName = new LinkedHashSet<>(); // 横の単位
    public List<Map<String, Object>> rowSummary = new ArrayList<>(); // 横計
    public List<Map<String, Object>> columnSummary = new ArrayList<>(); // 縦計
    public Map<String, Object> totalSummary = new HashMap<>(); // 全体合計
  }

  public AggregationResult aggregate(
    Map<String, Object> config,
    List<Map<String, Object>> data
  ) {
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> rowKeys = (List<Map<String, Object>>) config.getOrDefault("rowKeys", new ArrayList<>());
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> columnKeys = (List<Map<String, Object>>) config.getOrDefault("columnKeys", new ArrayList<>());

    @SuppressWarnings("unchecked")
    List<String> outputTypes = (List<String>) config.getOrDefault("outputTypes", new ArrayList<>());

    String direction = String.valueOf(config.get("direction"));
    String targetKey = String.valueOf(config.get("targetKey"));
    // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
    String dataType = String.valueOf(config.get("totalDataType"));
    String dispFormat = String.valueOf(config.get("totalDispFormat"));
    // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
    String conversion = String.valueOf(config.get("totalConversion"));

    @SuppressWarnings("unchecked")
    Map<String, String> ordKeys = (Map<String, String>) config.getOrDefault("ordKeys", new HashMap<>());

    // Step 1: Validate input
    if (data == null || data.isEmpty()) {
      throw new IllegalArgumentException("Input data cannot be null or empty.");
    }

    if (targetKey == null || targetKey.isEmpty()) {
      throw new IllegalArgumentException("Key item cannot be null or empty.");
    }

    AggregationResult result = new AggregationResult();

    Map<String, Map<String, CellValues>> matrix = new LinkedHashMap<>();

    Set<String> rowKeySet = new LinkedHashSet<>();
    Set<String> colKeySet = new LinkedHashSet<>();

    for (Map<String, Object> record : data) {
      String rowKey = buildKey(record, rowKeys);
      String colKey = buildKey(record, columnKeys);

      String valStr = record.get(targetKey).toString();
      Double valNum = parseNumeric(valStr);

      if(isEffectKey(rowKey)) rowKeySet.add(rowKey);
      if(isEffectKey(colKey)) colKeySet.add(colKey);

      matrix
        .computeIfAbsent(rowKey, k -> new LinkedHashMap<>())
        .computeIfAbsent(colKey, k -> new CellValues());

      CellValues cell = matrix.get(rowKey).get(colKey);
      if(valStr != null && !valStr.equals("")) {
        // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
        if("DateTime".equals(dataType)){
          valStr = transformDateForUnitSet(valStr, "日", dispFormat);
        }
        // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
        if(conversion != null && !conversion.equals("")) {
          valStr = conversion;
        }
        cell.originalValues.add(valStr);
      }
      if (valNum != null) {
        cell.numericValues.add(valNum);
      }
    }

    // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
    // 値のある行のみ出力
    if(rowKeys != null && rowKeys.size() > 0){
      if(rowKeys.get(0).get("effectDataFlag").equals("1")) {
        Map<String, Object> outSet = new LinkedHashMap<>();
        outSet.put("unitDir", rowKeys.get(0).get("unitDir"));
        outSet.put("outputTypes", outputTypes);
        outSet.put("dataType", dataType);
        outSet.put("dispFormat", dispFormat);
        List<String> rowList = new ArrayList<>(rowKeySet);
        rowKeySet = getEffectStrKeyRange(rowList, outSet, matrix);
      }
    }
    // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

    // Sort
    for(int i = 0; i < rowKeys.size(); i++){
      Map<String, Object> keyMap = rowKeys.get(i);
      if("DateTime".equals(keyMap.get("dataType"))){
        // 指定範囲の全日出力
        // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
        //if(keyMap.get("effectDateFlag").equals("0")) {
        //  List<String> dateKeys = generateDateKeyRange(
        //    String.valueOf(keyMap.get("fromDate")),
        //    String.valueOf(keyMap.get("toDate")),
        //    String.valueOf(keyMap.get("totalUnitDate")),
        //    String.valueOf(keyMap.get("dispFormat"))
        //  );
        //  rowKeySet.addAll(dateKeys);
        //}
        if(keyMap.get("effectDataFlag").equals("0")) {
          List<String> rowList = new ArrayList<>(rowKeySet);
          rowKeySet = getAllbuildKeyRange(rowList, i, rowKeys.size(), keyMap);
        }
        // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
        List<String> rowList = new ArrayList<>(rowKeySet);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        sortDateTypeKey(rowList, i, keyMap,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        rowKeySet = new LinkedHashSet<>(rowList);
      }
      else if("string".equals(keyMap.get("dataType"))){
        if(ordKeys.containsKey(keyMap.get("dataCode"))){
          List<String> rowList = new ArrayList<>(rowKeySet);
          sortStrTypeKey(rowList, i, String.valueOf(keyMap.get("dataCode")), ordKeys.get(keyMap.get("dataCode")), data);
          rowKeySet = new LinkedHashSet<>(rowList);
        }
      }
    }

    // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
    // 値のある列のみ出力
    if(columnKeys != null && columnKeys.size() > 0){
      if(columnKeys.get(0).get("effectDataFlag").equals("1")) {
        Map<String, Object> outSet = new LinkedHashMap<>();
        outSet.put("unitDir", columnKeys.get(0).get("unitDir"));
        outSet.put("outputTypes", outputTypes);
        outSet.put("dataType", dataType);
        outSet.put("dispFormat", dispFormat);
        List<String> colList = new ArrayList<>(colKeySet);
        colKeySet = getEffectStrKeyRange(colList, outSet, matrix);
      }
    }
    // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

    for(int i = 0; i < columnKeys.size(); i++){
      Map<String, Object> keyMap = columnKeys.get(i);
      if("DateTime".equals(keyMap.get("dataType"))){
        // 指定範囲の全日出力
        // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
        //if(keyMap.get("effectDateFlag").equals("0")) {
        //  List<String> dateKeys = generateDateKeyRange(
        //    String.valueOf(keyMap.get("fromDate")),
        //    String.valueOf(keyMap.get("toDate")),
        //    String.valueOf(keyMap.get("totalUnitDate")),
        //    String.valueOf(keyMap.get("dispFormat"))
        //  );
        //  colKeySet.addAll(dateKeys);
        //}
        if(keyMap.get("effectDataFlag").equals("0")) {
          List<String> colList = new ArrayList<>(colKeySet);
          colKeySet = getAllbuildKeyRange(colList, i, columnKeys.size(), keyMap);
        }
        // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
        List<String> colList = new ArrayList<>(colKeySet);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        sortDateTypeKey(colList, i, keyMap,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        colKeySet = new LinkedHashSet<>(colList);
      }
      else if("string".equals(keyMap.get("dataType"))){
        if(ordKeys.containsKey(keyMap.get("dataCode"))){
          List<String> colList = new ArrayList<>(colKeySet);
          sortStrTypeKey(colList, i, String.valueOf(keyMap.get("dataCode")), ordKeys.get(keyMap.get("dataCode")), data);
          colKeySet = new LinkedHashSet<>(colList);
        }
      }
    }

    result.rowName.addAll(rowKeySet);
    result.columnName.addAll(colKeySet);

    // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
    Map<String, Object> outSet = new LinkedHashMap<>();
    outSet.put("targetKey", targetKey);
    outSet.put("direction", direction);
    outSet.put("dataType", dataType);
    outSet.put("dispFormat", dispFormat);
    // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end

    Map<String, Map<String, List<Double>>> rowTotals = new LinkedHashMap<>();
    Map<String, Map<String, List<Double>>> columnTotals = new LinkedHashMap<>();
    Map<String, List<Double>> totalValues = new HashMap<>();
    // Main output with direction awareness
    if (DIRECTION_N.equalsIgnoreCase(direction)) {
      for (String col : colKeySet) {
        for (String row : rowKeySet) {
          // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          // generateOutput(matrix, row, col, targetKey, direction, outputTypes, result.mainTable);
          generateOutput(matrix, row, col, outSet, outputTypes, result.mainTable);
          // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
          getTotalsInfo(matrix, row, col, outputTypes, rowTotals, columnTotals, totalValues);
        }
      }
    } else {
      for (String row : rowKeySet) {
        for (String col : colKeySet) {
          // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          // generateOutput(matrix, row, col, targetKey, direction, outputTypes, result.mainTable);
          generateOutput(matrix, row, col, outSet, outputTypes, result.mainTable);
          // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
          getTotalsInfo(matrix, row, col, outputTypes, rowTotals, columnTotals, totalValues);
        }
      }
    }

    // Row total
    for (String row : rowTotals.keySet()) {
      Map<String, Object> out = new LinkedHashMap<>();
      out.put(ROW_FLAG, row);
      out.put(ROW_TOTAL_KEY, rowTotals.get(row).get(outputTypes.get(0)).stream().mapToDouble(Double::doubleValue).sum());
      result.rowSummary.add(out);
    }

    // Column total
    for (String col : columnTotals.keySet()) {
      Map<String, Object> out = new LinkedHashMap<>();
      out.put(COLUMN_FLAG, col);
      out.put(COLUMN_TOTAL_KEY, columnTotals.get(col).get(outputTypes.get(0)).stream().mapToDouble(Double::doubleValue).sum());
      result.columnSummary.add(out);
    }

    // Overall total
    if(totalValues != null && totalValues.size() > 0){
      result.totalSummary.put(TOTAL_KEY, Optional.ofNullable(totalValues.get(outputTypes.get(0))).orElse(Collections.emptyList()).stream().mapToDouble(Double::doubleValue).sum());
    }

    return result;
  }

  private static String buildKey(Map<String, Object> record, List<Map<String, Object>> keys) {
    List<String> res = new ArrayList<>();
    for(int i = 0; i < keys.size(); i++){
      Map<String, Object> keyMap = keys.get(i);
      String value = "";
      if(keyMap.get("reportInfo") == null) {
        if("DateTime".equals(keyMap.get("dataType"))){
          String valueStr = null;
          if(isTimestamp(record.getOrDefault(keyMap.get("dataCode"), null))){
            valueStr = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(record.getOrDefault(keyMap.get("dataCode"), null));
          }
          else {
            // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
            //valueStr = (String) record.getOrDefault(keyMap.get("dataCode"), "");
            valueStr = String.valueOf(record.getOrDefault(keyMap.get("dataCode"), ""));
            // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
          }
          value = transformDateForUnitSet(valueStr, String.valueOf(keyMap.get("totalUnitDate")), String.valueOf(keyMap.get("dispFormat")));
        }
        else if("decimal".equals(keyMap.get("dataType"))){
          Double valNum = parseNumeric(String.valueOf(record.getOrDefault(keyMap.get("dataCode"), "")));
          value = valNum == null ? "" : String.format(String.valueOf(keyMap.get("dispFormat")), valNum);
        }
        else {
          value = String.valueOf(record.getOrDefault(keyMap.get("dataCode"), ""));
        }
      }
      else {
        List<Map<String, Object>> infos = (List<Map<String, Object>>)keyMap.get("reportInfo");
        List<String> unitPreList = keys.stream()
          .limit(i)
          .filter(k -> k.get("reportInfo") == null)
          .map(m -> (String)m.get("dataCode"))
          .collect(Collectors.toList());
        List<Map<String, Object>> filterInfos = new ArrayList<>(infos);
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
        if(unitPreList != null && unitPreList.size() > 0){
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
          // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
          Set<String> tmpUnitKeys = new HashSet<>();
          if(record.keySet().contains("machine_no") && infos.size() > 0 && infos.get(0).containsKey("machine_no")){
            tmpUnitKeys.add("machine_no");
          }
          if(record.keySet().contains("mainte_no") && infos.size() > 0 && infos.get(0).containsKey("mainte_no")){
            tmpUnitKeys.add("mainte_no");
          }
          if(record.keySet().contains("mainte_layout_cd") && infos.size() > 0 && infos.get(0).containsKey("mainte_layout_cd")){
            tmpUnitKeys.add("mainte_layout_cd");
          }
          if(tmpUnitKeys.size() > 0){
            unitPreList = new ArrayList<>(tmpUnitKeys);
          }
          // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
          for(String unitPre : unitPreList){
            filterInfos = filterInfos.stream().
              filter(info -> info.containsKey(unitPre) && String.valueOf(record.get(unitPre)).equals(String.valueOf(info.get(unitPre)))).
              collect(Collectors.toList());
          }
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
        }
        else if(infos.size() > 0){
          Set<String> commonKeys = record.keySet().stream()
            .filter(infos.get(0)::containsKey)
            .collect(Collectors.toSet());
          // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe start
          Set<String> tmpKeys = new HashSet<>();
          if(commonKeys.contains("machine_no")){
            tmpKeys.add("machine_no");
          }
          if(commonKeys.contains("mainte_no")){
            tmpKeys.add("mainte_no");
          }
          if(commonKeys.contains("mainte_layout_cd")){
            tmpKeys.add("mainte_layout_cd");
          }
          if(tmpKeys.size() > 0) {
            commonKeys = tmpKeys;
          }
          // add #12529 機器保守カテゴリの装置情報項目が足りていない limingzhe end
          for(String key : commonKeys){
            filterInfos = filterInfos.stream().
              filter(info -> info.containsKey(key) && String.valueOf(record.get(key)).equals(String.valueOf(info.get(key)))).
              collect(Collectors.toList());
          }
        }
        else {
          filterInfos.clear();
        }
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
        if(filterInfos != null && filterInfos.size() > 0){
          if("DateTime".equals(keyMap.get("dataType"))){
            String valueStr = null;
            if(isTimestamp(filterInfos.get(0).getOrDefault(keyMap.get("dataCode"), null))){
              valueStr = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(filterInfos.get(0).getOrDefault(keyMap.get("dataCode"), null));
            }
            else {
              valueStr = (String) filterInfos.get(0).getOrDefault(keyMap.get("dataCode"), "");
            }
            value = transformDateForUnitSet(valueStr, String.valueOf(keyMap.get("totalUnitDate")), String.valueOf(keyMap.get("dispFormat")));
          }
          else if("decimal".equals(keyMap.get("dataType"))){
            Double sum = filterInfos.stream()
              .mapToDouble(map -> {
                Double d = parseNumeric(String.valueOf(map.getOrDefault(String.valueOf(keyMap.get("dataCode")), "")));
                if(d == null) d = 0.0;
                return d;
              })
              .sum();
            value = String.format(String.valueOf(keyMap.get("dispFormat")), sum);
          }
          else {
            value = String.valueOf(filterInfos.get(0).getOrDefault(keyMap.get("dataCode"), ""));
          }
        }
      }
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
      //if(value.equals("null")) value = "";
      if(value == null || value.equals("null")) value = "";
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
      res.add(value);
    }
    return res.stream().collect(Collectors.joining(NAME_CONCAT_FLAG));
  }

  private static boolean isEffectKey(String key) {
    boolean bEffect = false;
    if(key != null && !StringUtils.isEmpty(key)){
      String str = key.replaceAll(" ", "").replaceAll(NAME_CONCAT_FLAG, "");
      if(!StringUtils.isEmpty(str)) bEffect = true;
    }
    return bEffect;
  }

  // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
  private static Set<String> getAllbuildKeyRange(List<String> info, Integer index, Integer keyCount, Map<String, Object> keyMap){
    List<String> dateKeys = generateDateKeyRange(
      String.valueOf(keyMap.get("fromDate")),
      String.valueOf(keyMap.get("toDate")),
      String.valueOf(keyMap.get("totalUnitDate")),
      String.valueOf(keyMap.get("dispFormat"))
    );
    Set<String> colSet = new HashSet<>();
    for (String entry : info) {
      // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
      //String date = entry.split(NAME_CONCAT_FLAG)[index];
      String date = entry.split(NAME_CONCAT_FLAG, -1)[index];
      if(StringUtils.isEmpty(date)) continue;
      // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
      colSet.add(date);
    }
    for (String date : dateKeys){
      if(!colSet.contains(date)){
        StringBuffer strbuf = new StringBuffer();
        for(int j = 0; j < keyCount; j++){
          if(j == index) strbuf.append(date);
          if(j < keyCount - 1) strbuf.append(NAME_CONCAT_FLAG);
        }
        info.add(strbuf.toString());
      }
    }
    Set<String> effKeys = new LinkedHashSet<>(info);
    return effKeys;
  }

  private static Set<String> getEffectStrKeyRange(List<String> info, Map<String, Object> outSet, Map<String, Map<String, CellValues>> matrix){
    Set<String> effKeys = new LinkedHashSet<>();
    List<String> outputTypes = (List<String>) outSet.getOrDefault("outputTypes", new ArrayList<>());
    if(String.valueOf(outSet.get("unitDir")).equals(ROW_FLAG)){
      for (String row : info) {
        Map<String, CellValues> colInfo = matrix.getOrDefault(row, Collections.emptyMap());
        for(String col : colInfo.keySet()){
          CellValues cell = matrix.getOrDefault(row, Collections.emptyMap()).get(col);
          if (cell != null) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.putAll(outSet);
            addStatResults(out, cell, outputTypes);
            for (String type : outputTypes) {
              if(out.get(type) != null && !StringUtils.isEmpty(out.get(type))){
                effKeys.add(row);
              }
            }
          }
        }
      }
    }
    else if(String.valueOf(outSet.get("unitDir")).equals(COLUMN_FLAG)){
      for (String row : matrix.keySet()) {
        for(String col : info){
          CellValues cell = matrix.getOrDefault(row, Collections.emptyMap()).get(col);
          if (cell != null) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.putAll(outSet);
            addStatResults(out, cell, outputTypes);
            for (String type : outputTypes) {
              if(out.get(type) != null && !StringUtils.isEmpty(out.get(type))){
                effKeys.add(col);
              }
            }
          }
        }
      }
    }
    return effKeys;
  }
  // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
// #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  private static void sortDateTypeKey(List<String> info, Integer index, Map<String, Object> keyMap, LogService logService){
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    String totalUnitDate = String.valueOf(keyMap.get("totalUnitDate"));
    String dispFormat = String.valueOf(keyMap.get("dispFormat"));

    info.sort((s1, s2) -> {
      try {
        // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
        //String[] arr1 = s1.split(NAME_CONCAT_FLAG);
        //String[] arr2 = s2.split(NAME_CONCAT_FLAG);
        String[] arr1 = s1.split(NAME_CONCAT_FLAG, -1);
        String[] arr2 = s2.split(NAME_CONCAT_FLAG, -1);
        // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
        String dateStr1 = arr1[index].trim();
        String dateStr2 = arr2[index].trim();

        if (dateStr1 == null || dateStr2 == null) return -1;

        for(int i = 0; i < index; i++){
          if (!arr1[i].equals(arr2[i])) return -1;
        }

        String format = "";
        switch (totalUnitDate) {
          case YEAR:
            // del #11985 定期点検一覧帳票が正常に出せない limingzhe start
//            if(dispFormat.contains("/M"))  format = dispFormat.split("/M")[0];
//            else if(dispFormat.contains("M"))  format = dispFormat.split("M")[0];
//            else format = dispFormat;
//            break;
            // del #11985 定期点検一覧帳票が正常に出せない limingzhe end
          case MONTH:
            // del #11985 定期点検一覧帳票が正常に出せない limingzhe start
//            if(dispFormat.contains("/d"))  format = dispFormat.split("/d")[0];
//            else if(dispFormat.contains("d"))  format = dispFormat.split("d")[0];
//            else format = dispFormat;
//            break;
            // del #11985 定期点検一覧帳票が正常に出せない limingzhe end
          case DAY:
            // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
            //format = dispFormat;
            format = getUnitDispFormatForJava(totalUnitDate, dispFormat);
            if(!format.equals("E"))
            // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
              break;
          case DAY_OF_WEEK:
            String[] weekDays = {"月", "火", "水", "木", "金", "土", "日"};
            int index1 = 0, index2 = 0;
            for (int i = 0; i < weekDays.length; i++){
              if(dateStr1.equals(weekDays[i])) index1 = i;
              if(dateStr2.equals(weekDays[i])) index2 = i;
            }
            return Integer.compare(index1, index2);
        }

        SimpleDateFormat dateFormat = new SimpleDateFormat(format);

        // Parse the dates
        Date date1 = dateFormat.parse(dateStr1);
        Date date2 = dateFormat.parse(dateStr2);

        // Compare the dates
        return date1.compareTo(date2);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        if (logService != null) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      }
      return 0;
    });
  }

  private static void sortStrTypeKey(List<String> info, Integer index, String dataCode, String ordKey, List<Map<String, Object>> data){
    Map<String, Integer> uMap = data.stream()
      .collect(Collectors.toMap(
        map -> String.valueOf(map.get(dataCode)),
        map -> Integer.parseInt(String.valueOf(map.get(ordKey))),
        (existing, replacement) -> existing
      ));

    Map<String, List<Map<String, String>>> map = new LinkedHashMap<>();
    for (String value : info) {
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
      // String[] parts = value.split(NAME_CONCAT_FLAG);
      String[] parts = value.split(NAME_CONCAT_FLAG, -1);
      // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
      String unitPre = String.join(NAME_CONCAT_FLAG, Arrays.copyOfRange(parts, 0, Math.min(parts.length, index)));
      String unitNext = String.join(NAME_CONCAT_FLAG, Arrays.copyOfRange(parts, index, Math.max(parts.length, index)));
      Map<String, String> m = new HashMap<>();
      m.put(dataCode, unitNext);
      m.put(ordKey, String.valueOf(uMap.get(parts[index])));
      map.computeIfAbsent(unitPre, k -> new ArrayList<>()).add(m);
    }

    info.clear();
    for (Map.Entry<String, List<Map<String, String>>> entry : map.entrySet()) {
      String unitPre = entry.getKey();
      List<Map<String, String>> numList = entry.getValue();

      Collections.sort(numList, new Comparator<Map<String, String>>() {
        @Override
        public int compare(Map<String, String> m1, Map<String, String> m2) {
          return Integer.compare(Integer.parseInt(m1.get(ordKey)), Integer.parseInt(m2.get(ordKey)));
        }
      });

      for (Map<String, String> num : numList) {
        info.add(unitPre + "," + num.get(dataCode));
      }
    }
  }

  // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
  // private static void generateOutput(Map<String, Map<String, CellValues>> matrix, String row, String col, String targetKey, String direction,
  //                                    List<String> outputTypes,
  private static void generateOutput(Map<String, Map<String, CellValues>> matrix, String row, String col, Map<String, Object> outSet, List<String> outputTypes,
  // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
                                     List<Map<String, Object>> outputList
  ) {
    Map<String, Object> out = new LinkedHashMap<>();
    out.put(ROW_FLAG, row);
    out.put(COLUMN_FLAG, col);
    // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
    // out.put("targetKey", targetKey);
    // out.put("direction", direction);
    out.putAll(outSet);
    // mod #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
    CellValues cell = matrix.getOrDefault(row, Collections.emptyMap()).get(col);
    if (cell == null) {
      addNullResults(out, outputTypes);
    } else {
      addStatResults(out, cell, outputTypes);
    }
    outputList.add(out);
  }

  private static void addNullResults(Map<String, Object> map, List<String> outputTypes) {
    for (String type : outputTypes) {
      map.put(type, null);
    }
  }

  private static void addStatResults(Map<String, Object> map, CellValues cell, List<String> outputTypes) {
    List<Double> values = cell.numericValues;
    List<String> originals = cell.originalValues;
    // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
//    List<String> temp = new ArrayList<>();
//    for(String vStr : originals){
//      if (isNumeric(vStr) && parseNumeric(vStr) == 0.0) continue;
//      temp.add(vStr);
//    }
//    originals = temp;
    // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
    for (String type : outputTypes) {
      Double vDou;
      switch (type) {
        case MAX:
          vDou = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).max().orElse(0);
          // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          // if((vDou != null && vDou == 0.0)) vDou = null;
          // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
          map.put(MAX, vDou);
          break;
        case MIN:
          vDou = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).min().orElse(0);
          // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          // if((vDou != null && vDou == 0.0)) vDou = null;
          // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
          map.put(MIN, vDou);
          break;
        case AVG:
          vDou = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).average().orElse(0);
          // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          // if((vDou != null && vDou == 0.0)) vDou = null;
          // del #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
          map.put(AVG, vDou);
          break;
        case TOTAL:
          vDou = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).sum();
          // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          if("decimal".equals(map.get("dataType"))) {
          // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
            if ((vDou != null && vDou == 0.0)) vDou = null;
          // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          }
          // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
          map.put(TOTAL, vDou);
          break;
        case FIRST:
          map.put(FIRST, originals.isEmpty() ? null : originals.get(0));
          break;
        case LAST:
          map.put(LAST, originals.isEmpty() ? null : originals.get(originals.size() - 1));
          break;
        case CONCAT:
          // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe start
          if("decimal".equals(map.get("dataType"))) {
            List<String> temp = new ArrayList<>();
            for(String vStr : originals){
              String formatValue = null;
              if (String.valueOf(map.get("dispFormat")).matches("^%\\.\\d+f$")) {
                formatValue = String.format(String.valueOf(map.get("dispFormat")), new BigDecimal(vStr));
              }else {
                formatValue = vStr;
              }
              temp.add(formatValue);
            }
            originals = temp;
          }
          // add #11123 複数集計で平均、最大値、最小値のとき値のないセルにも0が出るのはNG limingzhe end
          map.put(CONCAT, originals.isEmpty() ? null : String.join(",", originals));
          break;
        default:
          map.put(CONCAT, originals.isEmpty() ? null : String.join(",", originals));
          break;
      }
    }
  }

  private static void getTotalsInfo(Map<String, Map<String, CellValues>> matrix, String row, String col, List<String> outputTypes,
                                    Map<String, Map<String, List<Double>>> rowTotals,
                                    Map<String, Map<String, List<Double>>> columnTotals,
                                    Map<String, List<Double>> totalValues
  ) {
    CellValues cell = matrix.getOrDefault(row, Collections.emptyMap()).get(col);
    if (cell != null) {
      List<Double> values = cell.numericValues;
      List<String> originals = cell.originalValues;

      for (String type : outputTypes) {
        Double valNum = null;
        switch (type) {
          case MAX:
            valNum = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).max().orElse(0);
            break;
          case MIN:
            valNum = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).min().orElse(0);
            break;
          case AVG:
            valNum = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).average().orElse(0);
            break;
          case TOTAL:
            valNum = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).sum();
            break;
          case FIRST:
            valNum = originals.isEmpty() ? null : parseNumeric(originals.get(0));
            break;
          case LAST:
            valNum = originals.isEmpty() ? null : parseNumeric(originals.get(originals.size() - 1));
            break;
          case CONCAT:
            valNum = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).sum();
            break;
          default:
            valNum = values.isEmpty() ? null : values.stream().mapToDouble(Double::doubleValue).sum();
            break;
        }
        if(valNum == null) continue;
        rowTotals
          .computeIfAbsent(row, k -> new LinkedHashMap<>())
          .computeIfAbsent(type, k -> new ArrayList<>()).add(valNum);
        columnTotals
          .computeIfAbsent(col, k -> new LinkedHashMap<>())
          .computeIfAbsent(type, k -> new ArrayList<>()).add(valNum);
        totalValues.computeIfAbsent(type, k -> new ArrayList<>()).add(valNum);
      }
    }
  }

  public static class ExcelCellOutput {
    public int page;
    public String cell; // e.g. "A1" or merged like "A1:B2"
    public String value;
    public Map<String, String> reference; // {"横列":"...", "縦列":"..."}

    public ExcelCellOutput(int page, String cell, String value, Map<String, String> reference) {
      this.page = page;
      this.cell = cell;
      this.value = value;
      this.reference = reference;
    }
  }

  // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
  public static class ExcelCellOutputForTotal {
    public List<ExcelCellOutput> output = new ArrayList<>(); // 集計内容
    public List<ExcelCellOutput> outputUnit = new ArrayList<>(); // 集計の単位
    public List<ExcelCellOutput> outputTotal = new ArrayList<>(); // 集計の合計

    public ExcelCellOutputForTotal(List<ExcelCellOutput> output, List<ExcelCellOutput> outputUnit, List<ExcelCellOutput> outputTotal) {
      this.output = output;
      this.outputUnit = outputUnit;
      this.outputTotal = outputTotal;
    }
  }
  // add #11985 定期点検一覧帳票が正常に出せない limingzhe end

  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
  //public static List<ExcelCellOutput> calcExcelAddressFromData(
  public static ExcelCellOutputForTotal calcExcelAddressFromData(
  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
    Map<String, Object> config,
    AggregationResult totalResult
  ) {
    String startCell = (String) config.get("tmplId");
    String direction = (String) config.get("direction");
    int horRepeat = (int) config.get("repeatCountH");
    int verRepeat = (int) config.get("repeatCountV");
    String cellByteLimitStr = (String) config.get("dispLength");
    int byteLimit = cellByteLimitStr.equals("0") ? Integer.MAX_VALUE : Integer.parseInt(cellByteLimitStr);
    boolean multipage = config.get("isNewPage").equals("1");
    String displayKey = (String) config.get("totalContents");
    String totalFormat = (String) config.get("totalFormat");
    String totalDataType = (String) config.get("totalDataType");
    boolean outColSum = config.get("totalCountH").equals("1");
    boolean outRowSum = config.get("totalCountV").equals("1");
    boolean outTotal = config.get("tableCount").equals("1");

    int page = (int) config.get("pageStart") + 1;

    @SuppressWarnings("unchecked")
    List<Map<String, String>> dateRanges = (List<Map<String, String>>) config.getOrDefault("dateRanges", new ArrayList<>());

    List<Map<String, String>> rowSet = dateRanges.stream().filter(r -> r.get("unitDir").equals(COLUMN_FLAG)).collect(Collectors.toList());
    List<String[]> rowsAddr = new ArrayList<>();
    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
    //List<String> rowsDataType = new ArrayList<>();
    List<Map<String, String>> rowsSetInfo = new ArrayList<>();
    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
    for (Map<String, String> dr : rowSet) {
      String[] addrs = dr.get("repeatAddress").split(",");
      rowsAddr.add(addrs);
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
      //rowsDataType.add(dr.get("dataType"));
      Map<String, String> set = new HashMap<>();
      set.put("dataType", dr.get("dataType"));
      set.put("dispFormat", dr.get("dispFormat"));
      rowsSetInfo.add(set);
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
    }

    List<Map<String, String>> colSet = dateRanges.stream().filter(r -> r.get("unitDir").equals(ROW_FLAG)).collect(Collectors.toList());
    List<String[]> colsAddr = new ArrayList<>();
    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
    //List<String> colsDataType = new ArrayList<>();
    List<Map<String, String>> colsSetInfo = new ArrayList<>();
    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
    for (Map<String, String> dr : colSet) {
      String[] addrs = dr.get("repeatAddress").split(",");
      colsAddr.add(addrs);
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
      //colsDataType.add(dr.get("dataType"));
      Map<String, String> set = new HashMap<>();
      set.put("dataType", dr.get("dataType"));
      set.put("dispFormat", dr.get("dispFormat"));
      colsSetInfo.add(set);
      // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
    }

    @SuppressWarnings("unchecked")
    List<Map<String, String>> totalValueRanges = (List<Map<String, String>>) config.getOrDefault("totalValueRanges", new ArrayList<>());

    List<Map<String, String>> rowTotalSet = totalValueRanges.stream().filter(r -> r.get("unitDir").equals(ROW_FLAG)).collect(Collectors.toList());

    List<Map<String, String>> colTotalSet = totalValueRanges.stream().filter(r -> r.get("unitDir").equals(COLUMN_FLAG)).collect(Collectors.toList());

    List<Map<String, String>> totalSet = totalValueRanges.stream().filter(r -> r.get("unitDir").equals(TOTAL_FLAG)).collect(Collectors.toList());

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> otherTotalRanges = (List<Map<String, Object>>) config.getOrDefault("otherTotalRanges", new ArrayList<>());

    List<Map<String, Object>> mainData = totalResult.mainTable;
    LinkedHashSet<String> rows = new LinkedHashSet<>(totalResult.columnName);
    LinkedHashSet<String> cols = new LinkedHashSet<>(totalResult.rowName);
    Map<String, String> rowSum = new HashMap<>();
    if(outRowSum && totalResult.rowSummary != null) {
      for (Map<String, Object> s : totalResult.rowSummary) {
        String key = (String) s.get(ROW_FLAG);
        String value = String.valueOf(s.get(ROW_TOTAL_KEY));
        rowSum.put(key, value);
      }
    }
    Map<String, String> colSum = new HashMap<>();
    if(outColSum && totalResult.columnSummary != null) {
      for (Map<String, Object> s : totalResult.columnSummary) {
        String key = (String) s.get(COLUMN_FLAG);
        String value = String.valueOf(s.get(COLUMN_TOTAL_KEY));
        colSum.put(key, value);
      }
    }
    Map<String, Object> totalSum = totalResult.totalSummary;

    List<String> rowList = new ArrayList<>(rows);
    List<String> colList = new ArrayList<>(cols);


    if (outRowSum && rowTotalSet.size() == 0) rowList.add(ROW_TOTAL_FLAG);
    if (outColSum && colTotalSet.size() == 0) colList.add(COLUMN_TOTAL_FLAG);

    int rowSize = rowList.size();
    int colSize = colList.size();

    // 集計内容
    List<ExcelCellOutput> output = new ArrayList<>();
    // 集計の単位
    List<ExcelCellOutput> outputUnit = new ArrayList<>();
    // 集計の合計
    List<ExcelCellOutput> outputTotal = new ArrayList<>();

    if(direction.equals(DIRECTION_N)){
      int rStart = 0;
      while (rStart < rowSize) {
        int cStart = 0;
        while (cStart < colSize) {
          for (int rOffset = 0; rOffset < horRepeat && rStart + rOffset < rowSize; rOffset++) {
            for (int cOffset = 0; cOffset < verRepeat && cStart + cOffset < colSize; cOffset++) {
              String rowKey = rowList.get(rStart + rOffset);
              String colKey = colList.get(cStart + cOffset);

              // 縦の単位
              if(rOffset == 0){
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
                //String[] parts = colKey.split(NAME_CONCAT_FLAG);
                String[] parts = colKey.split(NAME_CONCAT_FLAG, -1);
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
                for (int j = 0; j < parts.length; j++) {
                  if(j >= colsAddr.size()) continue;
                  if(parts[j] == null || parts[j].equals("")) continue;
                  if(parts[j].equals(COLUMN_TOTAL_FLAG)) parts[j] = COLUMN_TOTAL_NAME;
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put(ROW_FLAG, colKey);
                  reference.put(COLUMN_FLAG, rowKey);
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
                  //reference.put("dataType", colsDataType.get(j));
                  Map<String, String> set = colsSetInfo.get(j);
                  reference.put("dataType", set.get("dataType"));
                  reference.put("dispFormat", set.get("dispFormat"));
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
                  outputUnit.add(new ExcelCellOutput(page, colsAddr.get(j)[cOffset], parts[j], reference));
                }
              }

              // 横の単位
              if(cOffset == 0){
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
                //String[] parts = rowKey.split(NAME_CONCAT_FLAG);
                String[] parts = rowKey.split(NAME_CONCAT_FLAG, -1);
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
                for (int j = 0; j < parts.length; j++) {
                  if (j >= rowsAddr.size()) continue;
                  if(parts[j] == null || parts[j].equals("")) continue;
                  if(parts[j].equals(ROW_TOTAL_FLAG)) parts[j] = ROW_TOTAL_NAME;
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put(ROW_FLAG, colKey);
                  reference.put(COLUMN_FLAG, rowKey);
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
                  //reference.put("dataType", rowsDataType.get(j));
                  Map<String, String> set = rowsSetInfo.get(j);
                  reference.put("dataType", set.get("dataType"));
                  reference.put("dispFormat", set.get("dispFormat"));
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
                  outputUnit.add(new ExcelCellOutput(page, rowsAddr.get(j)[rOffset], parts[j], reference));
                }
              }

              String content = null;
              Map<String, Object> matched = mainData.stream().filter(d ->
                Objects.equals(d.get(ROW_FLAG), colKey) &&
                  Objects.equals(d.get(COLUMN_FLAG), rowKey)
              ).findFirst().orElse(null);

              if (matched != null && matched.containsKey(displayKey) && matched.get(displayKey) != null) {
                content = matched.get(displayKey).toString();
                // del #11985 定期点検一覧帳票が正常に出せない limingzhe start
//                if(content != null){
//                  if("DateTime".equals(totalDataType)){
//                    content = transformDateForUnitSet(content, "日", totalFormat);
//                  }
//                }
                // del #11985 定期点検一覧帳票が正常に出せない limingzhe end
              }
              else if (rowKey.equals(ROW_TOTAL_FLAG) && colKey.equals(COLUMN_TOTAL_FLAG)) {
                content = String.valueOf(totalSum.getOrDefault(TOTAL_KEY, "0"));
              }
              else if (rowKey.equals(ROW_TOTAL_FLAG)) {
                content = rowSum.getOrDefault(colKey, "0");
              }
              else if (colKey.equals(COLUMN_TOTAL_FLAG)) {
                content = colSum.getOrDefault(rowKey, "0");
              }

              if (content == null) continue;

              int[] cellCount = calculateMergeDimensions(startCell);

              int cellW = cellCount[0];
              int cellH = cellCount[1];

              int colOffset = rOffset * cellW;
              int rowOffset = cOffset * cellH;

              String cellAddr = calcNextMergeCellAddress(startCell, cellW, cellH, colOffset, rowOffset);

              Map<String, String> reference = new LinkedHashMap<>();
              reference.put(ROW_FLAG, colKey);
              reference.put(COLUMN_FLAG, rowKey);
              reference.put("dataType", totalDataType);
              output.add(new ExcelCellOutput(page, cellAddr, content, reference));
            }
          }
          cStart += verRepeat;
          if (!multipage) break;
          page++;
        }
        rStart += horRepeat;
        if (!multipage) break;
      }

      // 横の合計
      if(outRowSum && rowTotalSet.size() > 0){
        List<String[]> rowsTotalAddr = new ArrayList<>(rowTotalSet.size());
        List<String> rowsTotalDataType = new ArrayList<>(rowTotalSet.size());
        for (Map<String, String> dr : rowTotalSet) {
          String[] addrs = dr.get("repeatAddress").split(",");
          rowsTotalAddr.add(addrs);
          rowsTotalDataType.add(dr.get("dataType"));
        }
        int pageRow = colSize / verRepeat + (colSize % verRepeat > 0 ? 1 : 0);
        int pColStart = page - pageRow;
        if((pColStart >= 1 && multipage) || (pColStart == 1 && !multipage)) {
          int cSumStart = 0;
          while (cSumStart < colSize) {
            for (int cOffset = 0; cOffset < verRepeat && cSumStart + cOffset < colSize; cOffset++) {
              String colKey = colList.get(cSumStart + cOffset);
              String totalStr = rowSum.getOrDefault(colKey, "0");
              Double total = Double.parseDouble(totalStr);
              Map<String, String> reference = new LinkedHashMap<>();
              reference.put("page", String.valueOf(pColStart));
              reference.put(ROW_FLAG, colKey);
              for (int j = 0; j < rowsTotalAddr.size(); j++) {
                reference.put("dataType", String.valueOf(rowsTotalDataType.get(j)));
                String dispFormat = rowTotalSet.get(j).get("dispFormat");
                outputTotal.add(new ExcelCellOutput(pColStart, rowsTotalAddr.get(j)[cOffset], String.format(dispFormat, total), reference));
              }
            }
            cSumStart += verRepeat;
            if (!multipage) break;
            pColStart++;
          }
        }
      }

      // 縦の合計
      if(outColSum && colTotalSet.size() > 0){
        List<String[]> colsTotalAddr = new ArrayList<>(colTotalSet.size());
        List<String> colsTotalDataType = new ArrayList<>(colTotalSet.size());
        for (Map<String, String> dr : colTotalSet) {
          String[] addrs = dr.get("repeatAddress").split(",");
          colsTotalAddr.add(addrs);
          colsTotalDataType.add(dr.get("dataType"));
        }
        int pageRow = colSize / verRepeat + (colSize % verRepeat > 0 ? 1 : 0);
        int pRowStart = pageRow;
        if((pRowStart >= 1 && multipage) || (pRowStart == 1 && !multipage)){
          int rSumStart = 0;
          while (rSumStart < rowSize) {
            for (int rOffset = 0; rOffset < horRepeat && rSumStart + rOffset < rowSize; rOffset++) {
              String rowKey = rowList.get(rSumStart + rOffset);
              String totalStr = colSum.getOrDefault(rowKey, "0");
              Double total = Double.parseDouble(totalStr);
              Map<String, String> reference = new LinkedHashMap<>();
              reference.put("page", String.valueOf(pRowStart));
              reference.put(COLUMN_FLAG, rowKey);
              for (int j = 0; j < colsTotalAddr.size(); j++) {
                reference.put("dataType", String.valueOf(colsTotalDataType.get(j)));
                String dispFormat = colTotalSet.get(j).get("dispFormat");
                outputTotal.add(new ExcelCellOutput(pRowStart, colsTotalAddr.get(j)[rOffset], String.format(dispFormat, total), reference));
              }
            }
            rSumStart += horRepeat;
            if (!multipage) break;
            pRowStart+=pageRow;
          }
        }
      }

      if(otherTotalRanges.size() > 0){
        for(Map<String, Object> map : otherTotalRanges){
          List<Map<String, Object>> infoList = (List<Map<String, Object>>) map.get("reportInfo");
          if(infoList == null) continue;
          String[] addrs = map.get("repeatAddress").toString().split(",");
          if(map.get("unitDir").toString().equals(ROW_FLAG)){
            int pageRow = colSize / verRepeat + (colSize % verRepeat > 0 ? 1 : 0);
            int pColStart = page - pageRow;
            if((pColStart >= 1 && multipage) || (pColStart == 1 && !multipage)) {
              int cSumStart = 0;
              while (cSumStart < colSize) {
                for (int cOffset = 0; cOffset < verRepeat && cSumStart + cOffset < colSize; cOffset++) {
                  if (outRowSum && rowTotalSet.size() == 0 && cSumStart + cOffset == colSize - 1) break;
                  if(infoList.size() <= cSumStart + cOffset) break;
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                  //Double total = Double.parseDouble(String.valueOf(infoList.get(cSumStart + cOffset).get(map.get("dataCode"))));
                  String colKey = colList.get(cSumStart + cOffset);
                  String totalStr = infoList.stream().filter(s -> Objects.equals(s.get(map.get("dateName")), colKey))
                    .map(s -> s.get(map.get("dataCode"))).findFirst().map(Object::toString).orElse("0");
                  Double total = Double.parseDouble(totalStr);
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                  if(total == null) total = 0.0;
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put("page", String.valueOf(pColStart));
                  reference.put(TOTAL_FLAG, String.format(String.valueOf(map.get("dispFormat")), total));
                  reference.put("dataType", String.valueOf(map.get("dataType")));
                  outputTotal.add(new ExcelCellOutput(pColStart, addrs[cOffset], String.format(String.valueOf(map.get("dispFormat")), total), reference));
                }
                cSumStart += verRepeat;
                if (!multipage) break;
                pColStart++;
              }
            }
          }
          else if(map.get("unitDir").toString().equals(COLUMN_FLAG)) {
            int pageRow = colSize / verRepeat + (colSize % verRepeat > 0 ? 1 : 0);
            int pRowStart = pageRow;
            if ((pRowStart >= 1 && multipage) || (pRowStart == 1 && !multipage)) {
              int rSumStart = 0;
              while (rSumStart < rowSize) {
                for (int rOffset = 0; rOffset < horRepeat && rSumStart + rOffset < rowSize; rOffset++) {
                  if (outColSum && colTotalSet.size() == 0 && rSumStart + rOffset == rowSize - 1) break;
                  if(infoList.size() <= rSumStart + rOffset) break;
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                  //Double total = Double.parseDouble(String.valueOf(infoList.get(rSumStart + rOffset).get(map.get("dataCode"))));
                  String rowKey = rowList.get(rSumStart + rOffset);
                  String totalStr = infoList.stream().filter(s -> Objects.equals(s.get(map.get("dateName")), rowKey))
                    .map(s -> s.get(map.get("dataCode"))).findFirst().map(Object::toString).orElse("0");
                  Double total = Double.parseDouble(totalStr);
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put("page", String.valueOf(pRowStart));
                  reference.put(TOTAL_FLAG, String.format(String.valueOf(map.get("dispFormat")), total));
                  reference.put("dataType", String.valueOf(map.get("dataType")));
                  outputTotal.add(new ExcelCellOutput(pRowStart, addrs[rOffset], String.format(String.valueOf(map.get("dispFormat")), total), reference));
                }
                rSumStart += horRepeat;
                if (!multipage) break;
                pRowStart += pageRow;
              }
            }
          }
        }
      }
    }
    else {
      int cStart = 0;
      while (cStart < colSize) {
        int rStart = 0;
        while (rStart < rowSize) {
          for (int cOffset = 0; cOffset < verRepeat && cStart + cOffset < colSize; cOffset++) {
            for (int rOffset = 0; rOffset < horRepeat && rStart + rOffset < rowSize; rOffset++) {
              String rowKey = rowList.get(rStart + rOffset);
              String colKey = colList.get(cStart + cOffset);

              // 縦の単位
              if(rOffset == 0){
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
                //String[] parts = colKey.split(NAME_CONCAT_FLAG);
                String[] parts = colKey.split(NAME_CONCAT_FLAG, -1);
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
                for (int j = 0; j < parts.length; j++) {
                  if(j >= colsAddr.size()) continue;
                  if(parts[j] == null || parts[j].equals("")) continue;
                  if(parts[j].equals(COLUMN_TOTAL_FLAG)) parts[j] = COLUMN_TOTAL_NAME;
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put(ROW_FLAG, colKey);
                  reference.put(COLUMN_FLAG, rowKey);
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
                  //reference.put("dataType", colsDataType.get(j));
                  Map<String, String> set = colsSetInfo.get(j);
                  reference.put("dataType", set.get("dataType"));
                  reference.put("dispFormat", set.get("dispFormat"));
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
                  outputUnit.add(new ExcelCellOutput(page, colsAddr.get(j)[cOffset], parts[j], reference));
                }
              }

              // 横の単位
              if(cOffset == 0){
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe start
                //String[] parts = rowKey.split(NAME_CONCAT_FLAG);
                String[] parts = rowKey.split(NAME_CONCAT_FLAG, -1);
                // mod #12536 機器保守.日常点検(詳細無し).点検日を集計単位に含んでいるとシステムエラー limingzhe end
                for (int j = 0; j < parts.length; j++) {
                  if(j >= rowsAddr.size()) continue;
                  if(parts[j] == null || parts[j].equals("")) continue;
                  if(parts[j].equals(ROW_TOTAL_FLAG)) parts[j] = ROW_TOTAL_NAME;
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put(ROW_FLAG, colKey);
                  reference.put(COLUMN_FLAG, rowKey);
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
                  //reference.put("dataType", rowsDataType.get(j));
                  Map<String, String> set = rowsSetInfo.get(j);
                  reference.put("dataType", set.get("dataType"));
                  reference.put("dispFormat", set.get("dispFormat"));
                  // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
                  outputUnit.add(new ExcelCellOutput(page, rowsAddr.get(j)[rOffset], parts[j], reference));
                }
              }

              String content = null;
              Map<String, Object> matched = mainData.stream().filter(d ->
                Objects.equals(d.get(ROW_FLAG), colKey) &&
                  Objects.equals(d.get(COLUMN_FLAG), rowKey)
              ).findFirst().orElse(null);

              if (matched != null && matched.containsKey(displayKey) && matched.get(displayKey) != null) {
                content = matched.get(displayKey).toString();
                // del #11985 定期点検一覧帳票が正常に出せない limingzhe start
//                if(content != null){
//                  if("DateTime".equals(totalDataType)){
//                    content = transformDateForUnitSet(content, "日", totalFormat);
//                  }
//                }
                // del #11985 定期点検一覧帳票が正常に出せない limingzhe end
              }
              else if (rowKey.equals(ROW_TOTAL_FLAG) && colKey.equals(COLUMN_TOTAL_FLAG)) {
                content = String.valueOf(totalSum.getOrDefault(TOTAL_KEY, "0"));
              }
              else if (rowKey.equals(ROW_TOTAL_FLAG)) {
                content = rowSum.getOrDefault(colKey, "0");
              }
              else if (colKey.equals(COLUMN_TOTAL_FLAG)) {
                content = colSum.getOrDefault(rowKey, "0");
              }

              if (content == null) continue;

              int[] cellCount = calculateMergeDimensions(startCell);

              int cellW = cellCount[0];
              int cellH = cellCount[1];

              int colOffset = rOffset * cellW;
              int rowOffset = cOffset * cellH;

              String cellAddr = calcNextMergeCellAddress(startCell, cellW, cellH, colOffset, rowOffset);

              Map<String, String> reference = new LinkedHashMap<>();
              reference.put(ROW_FLAG, colKey);
              reference.put(COLUMN_FLAG, rowKey);
              reference.put("dataType", totalDataType);
              output.add(new ExcelCellOutput(page, cellAddr, content, reference));
            }
          }
          rStart += horRepeat;
          if (!multipage) break;
          page++;
        }
        cStart += verRepeat;
        if (!multipage) break;
      }

      // 横の合計
      if(outRowSum && rowTotalSet.size() > 0){
        List<String[]> rowsTotalAddr = new ArrayList<>(rowTotalSet.size());
        List<String> rowsTotalDataType = new ArrayList<>(rowTotalSet.size());
        for (Map<String, String> dr : rowTotalSet) {
          String[] addrs = dr.get("repeatAddress").split(",");
          rowsTotalAddr.add(addrs);
          rowsTotalDataType.add(dr.get("dataType"));
        }
        int pageCol = rowSize / horRepeat + (rowSize % horRepeat > 0 ? 1 : 0);
        int pColStart = pageCol;
        if((pColStart >= 1 && multipage) || (pColStart == 1 && !multipage)) {
          int cSumStart = 0;
          while (cSumStart < colSize) {
            for (int cOffset = 0; cOffset < verRepeat && cSumStart + cOffset < colSize; cOffset++) {
              String colKey = colList.get(cSumStart + cOffset);
              String totalStr = rowSum.getOrDefault(colKey, "0");
              Double total = Double.parseDouble(totalStr);
              Map<String, String> reference = new LinkedHashMap<>();
              reference.put("page", String.valueOf(pColStart));
              reference.put(ROW_FLAG, colKey);
              for (int j = 0; j < rowsTotalAddr.size(); j++) {
                reference.put("dataType", String.valueOf(rowsTotalDataType.get(j)));
                String dispFormat = rowTotalSet.get(j).get("dispFormat");
                outputTotal.add(new ExcelCellOutput(pColStart, rowsTotalAddr.get(j)[cOffset], String.format(dispFormat, total), reference));
              }
            }
            cSumStart += verRepeat;
            if (!multipage) break;
            pColStart+=pageCol;
          }
        }
      }

      // 縦の合計
      if(outColSum && colTotalSet.size() > 0){
        List<String[]> colsTotalAddr = new ArrayList<>(colTotalSet.size());
        List<String> colsTotalDataType = new ArrayList<>(colTotalSet.size());
        for (Map<String, String> dr : colTotalSet) {
          String[] addrs = dr.get("repeatAddress").split(",");
          colsTotalAddr.add(addrs);
          colsTotalDataType.add(dr.get("dataType"));
        }
        int pageCol = rowSize / horRepeat + (rowSize % horRepeat > 0 ? 1 : 0);
        int pRowStart = page - pageCol;
        if((pRowStart >= 1 && multipage) || (pRowStart == 1 && !multipage)){
          int rSumStart = 0;
          while (rSumStart < rowSize) {
            for (int rOffset = 0; rOffset < horRepeat && rSumStart + rOffset < rowSize; rOffset++) {
              String rowKey = rowList.get(rSumStart + rOffset);
              String totalStr = colSum.getOrDefault(rowKey, "0");
              Double total = Double.parseDouble(totalStr);
              Map<String, String> reference = new LinkedHashMap<>();
              reference.put("page", String.valueOf(pRowStart));
              reference.put(COLUMN_FLAG, rowKey);
              for (int j = 0; j < colsTotalAddr.size(); j++) {
                reference.put("dataType", String.valueOf(colsTotalDataType.get(j)));
                String dispFormat = colTotalSet.get(j).get("dispFormat");
                outputTotal.add(new ExcelCellOutput(pRowStart, colsTotalAddr.get(j)[rOffset], String.format(dispFormat, total), reference));
              }
            }
            rSumStart += horRepeat;
            if (!multipage) break;
            pRowStart++;
          }
        }
      }

      if(otherTotalRanges.size() > 0){
        for(Map<String, Object> map : otherTotalRanges){
          List<Map<String, Object>> infoList = (List<Map<String, Object>>) map.get("reportInfo");
          if(infoList == null) continue;
          String[] addrs = map.get("repeatAddress").toString().split(",");
          if(map.get("unitDir").toString().equals(ROW_FLAG)){
            int pageCol = rowSize / horRepeat + (rowSize % horRepeat > 0 ? 1 : 0);
            int pColStart = pageCol;
            if((pColStart >= 1 && multipage) || (pColStart == 1 && !multipage)) {
              int cSumStart = 0;
              while (cSumStart < colSize) {
                for (int cOffset = 0; cOffset < verRepeat && cSumStart + cOffset < colSize; cOffset++) {
                  if (outRowSum && rowTotalSet.size() == 0 && cSumStart + cOffset == colSize - 1) break;
                  if(infoList.size() <= cSumStart + cOffset) break;
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                  //Double total = Double.parseDouble(String.valueOf(infoList.get(cSumStart + cOffset).get(map.get("dataCode"))));
                  String colKey = colList.get(cSumStart + cOffset);
                  String totalStr = infoList.stream().filter(s -> Objects.equals(s.get(map.get("dateName")), colKey))
                    .map(s -> s.get(map.get("dataCode"))).findFirst().map(Object::toString).orElse("0");
                  Double total = Double.parseDouble(totalStr);
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                  if(total == null) total = 0.0;
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put("page", String.valueOf(pColStart));
                  reference.put(TOTAL_FLAG, String.format(String.valueOf(map.get("dispFormat")), total));
                  reference.put("dataType", String.valueOf(map.get("dataType")));
                  outputTotal.add(new ExcelCellOutput(pColStart, addrs[cOffset], String.format(String.valueOf(map.get("dispFormat")), total), reference));
                }
                cSumStart += verRepeat;
                if (!multipage) break;
                pColStart+=pageCol;
              }
            }
          }
          else if(map.get("unitDir").toString().equals(COLUMN_FLAG)){
            int pageCol = rowSize / horRepeat + (rowSize % horRepeat > 0 ? 1 : 0);
            int pRowStart = page - pageCol;
            if((pRowStart >= 1 && multipage) || (pRowStart == 1 && !multipage)){
              int rSumStart = 0;
              while (rSumStart < rowSize) {
                for (int rOffset = 0; rOffset < horRepeat && rSumStart + rOffset < rowSize; rOffset++) {
                  if (outColSum && colTotalSet.size() == 0 && rSumStart + rOffset == rowSize - 1) break;
                  if(infoList.size() <= rSumStart + rOffset) break;
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                  //Double total = Double.parseDouble(String.valueOf(infoList.get(rSumStart + rOffset).get(map.get("dataCode"))));
                  String rowKey = rowList.get(rSumStart + rOffset);
                  String totalStr = infoList.stream().filter(s -> Objects.equals(s.get(map.get("dateName")), rowKey))
                    .map(s -> s.get(map.get("dataCode"))).findFirst().map(Object::toString).orElse("0");
                  Double total = Double.parseDouble(totalStr);
                  // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                  Map<String, String> reference = new LinkedHashMap<>();
                  reference.put("page", String.valueOf(pRowStart));
                  reference.put(TOTAL_FLAG, String.format(String.valueOf(map.get("dispFormat")), total));
                  reference.put("dataType", String.valueOf(map.get("dataType")));
                  outputTotal.add(new ExcelCellOutput(pRowStart, addrs[rOffset], String.format(String.valueOf(map.get("dispFormat")), total), reference));
                }
                rSumStart += horRepeat;
                if (!multipage) break;
                pRowStart++;
              }
            }
          }
        }
      }
    }

    // 総の合計
    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
    //if (outTotal && totalSet.size() > 0) {
    if (outTotal && totalSet.size() > 0 && outputTotal.size() > 0) {
    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
      List<String[]> totalAddr = new ArrayList<>(totalSet.size());
      List<String> totalDataTypeList = new ArrayList<>(totalSet.size());
      for (Map<String, String> dr : totalSet) {
        String[] addrs = dr.get("repeatAddress").split(",");
        totalAddr.add(addrs);
        totalDataTypeList.add(dr.get("dataType"));
      }
      Double total = totalSum != null && totalSum.size() > 0 ? Double.parseDouble(totalSum.get(TOTAL_KEY).toString()) : 0.0;

      if(total != null) {
        Map<String, String> reference = new LinkedHashMap<>();
        reference.put("page", String.valueOf(page - 1));
        for (int j = 0; j < totalAddr.size(); j++) {
          reference.put("dataType", String.valueOf(totalDataTypeList.get(j)));
          String dispFormat = totalSet.get(j).get("dispFormat");
          outputTotal.add(new ExcelCellOutput(page - 1, totalAddr.get(j)[0], String.format(dispFormat, total), reference));
        }
      }
    }

    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
//    output.addAll(outputUnit);
//    output.addAll(outputTotal);
//    return output;
    return new ExcelCellOutputForTotal(output, outputUnit, outputTotal);
    // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
  }

  public static String transformDateForUnitSet(String original, String totalUnitDate, String dispFormat) {
    if (original == null) return null;
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
    if (StringUtils.isEmpty(dispFormat)) return null;
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
    try {
      Date date = parseDate(original);
      // del #11985 定期点検一覧帳票が正常に出せない limingzhe start
      //String format = "";
      // del #11985 定期点検一覧帳票が正常に出せない limingzhe end
      switch (totalUnitDate) {
        case YEAR:
          // del #11985 定期点検一覧帳票が正常に出せない limingzhe start
//          if(dispFormat.contains("/M"))  format = dispFormat.split("/M")[0];
//          else if(dispFormat.contains("M"))  format = dispFormat.split("M")[0];
//          else format = dispFormat;
//          return new SimpleDateFormat(format).format(date);
          // del #11985 定期点検一覧帳票が正常に出せない limingzhe end
        case MONTH:
          // del #11985 定期点検一覧帳票が正常に出せない limingzhe start
//          if(dispFormat.contains("/d"))  format = dispFormat.split("/d")[0];
//          else if(dispFormat.contains("d"))  format = dispFormat.split("d")[0];
//          else format = dispFormat;
//          return new SimpleDateFormat(format).format(date);
          // del #11985 定期点検一覧帳票が正常に出せない limingzhe end
        case DAY:
          // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
          //return new SimpleDateFormat(dispFormat).format(date);
          String format = getUnitDispFormatForJava(totalUnitDate, dispFormat);
          if (StringUtils.isEmpty(format)) return null;
          return new SimpleDateFormat(format).format(date);
          // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
        case DAY_OF_WEEK:
          Calendar cal = Calendar.getInstance();
          cal.setTime(date);
          return getJapaneseWeekday(cal.get(Calendar.DAY_OF_WEEK));
      }
    } catch (Exception ignored) {}
    return original;
  }

  /**
   * 集計単位日付属性により、配列の縦列サイズを計算する
   *
   * @param start fromDate
   * @param end toDate
   * @param totalUnitDate 集計単位日付属性
   * @param dispFormat 集計単位書式
   * @return Map<key, value>
   */
  private static List<String> generateDateKeyRange(String start, String end, String totalUnitDate, String dispFormat) {
    List<String> result = new ArrayList<>();
    try {
      Date startDate = parseDate(start);
      Date endDate = parseDate(end);
      Calendar cal = Calendar.getInstance();
      cal.setTime(startDate);
      while (!cal.getTime().after(endDate)) {
        result.add(transformDateForUnitSet(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(cal.getTime()), totalUnitDate, dispFormat));
        cal.add(Calendar.DATE, 1);
      }
    } catch (Exception ignored) {}
    return result;
  }

  /**
   * 集計単位日付属性により、配列の縦列サイズを計算する
   * 指定された方法で並べ替えます
   * @param start fromDate
   * @param end toDate
   * @param totalUnitDate 集計単位日付属性
   * @param dispFormat 集計単位書式
   * @return Map<key, value>
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  public static Set<String> getAllDateKeyRange(String start, String end, String totalUnitDate, String dispFormat, LogService logService){
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    List<String> dateKeys = generateDateKeyRange(
      start,
      end,
      totalUnitDate,
      dispFormat
    );
    Map<String, Object> keyMap = new HashMap<>();
    keyMap.put("totalUnitDate", totalUnitDate);
    keyMap.put("dispFormat", dispFormat);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    sortDateTypeKey(dateKeys, 0, keyMap,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    Set<String> result = new LinkedHashSet<>(dateKeys);
    return result;
  }

  /**
   * 集計単位日付属性により、配列の縦列サイズを計算する
   * 指定された方法で並べ替えます
   * @param data
   * @param totalUnitDate 集計単位日付属性
   * @param dispFormat 集計単位書式
   * @return Map<key, value>
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  public static Set<String> getEffectDateKeyRange(List<String> data, String totalUnitDate, String dispFormat, LogService logService){
    Map<String, Object> keyMap = new HashMap<>();
    keyMap.put("totalUnitDate", totalUnitDate);
    keyMap.put("dispFormat", dispFormat);
    sortDateTypeKey(data, 0, keyMap,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    Set<String> result = new LinkedHashSet<>(data);
    return result;
  }

  private static int[] calculateMergeDimensions(String cellRange) {
    String[] startEnd = cellRange.split(":");
    if (startEnd.length != 2) {
      return new int[]{1, 1};
    }
    String startCell = startEnd[0];
    String endCell = startEnd[1];

    int startRow = Integer.parseInt(startCell.replaceAll("[^0-9]", ""));
    int startCol = columnToNumber(startCell.replaceAll("[^A-Z]", ""));

    int endRow = Integer.parseInt(endCell.replaceAll("[^0-9]", ""));
    int endCol = columnToNumber(endCell.replaceAll("[^A-Z]", ""));

    int rows = endRow - startRow + 1;
    int columns = endCol - startCol + 1;

    return new int[]{columns, rows};
  }

  /*
   * Cell Address
   */
  private static String calcNextCellAddress(String start, int dx, int dy) {
    int col = columnToNumber(start.replaceAll("[0-9]", "")) + dx;
    int row = Integer.parseInt(start.replaceAll("[A-Z]", "")) + dy;
    return numberToColumn(col) + row;
  }

  /*
  * MergeCell Address
  */
  private static String calcNextMergeCellAddress(String start, int cellW, int cellH, int colOffset, int rowOffset){
    String startCell = start.contains(":") ? start.split(":")[0] : start;

    String baseColStr = startCell.replaceAll("[0-9]", "");
    String baseRowStr = startCell.replaceAll("[A-Z]", "");
    int baseCol = columnToNumber(baseColStr);
    int baseRow = Integer.parseInt(baseRowStr);

    int startCol = baseCol + colOffset;
    int startRow = baseRow + rowOffset;
    int endCol = startCol + cellW - 1;
    int endRow = startRow + cellH - 1;

    String cellAddr;
    if (cellW == 1 && cellH == 1) {
      cellAddr = numberToColumn(startCol) + startRow;
    } else {
      cellAddr = numberToColumn(startCol) + startRow + ":" + numberToColumn(endCol) + endRow;
    }

    return cellAddr;
  }

  private static int columnToNumber(String col) {
    int num = 0;
    for (int i = 0; i < col.length(); i++) {
      num *= 26;
      num += col.charAt(i) - 'A' + 1;
    }
    return num;
  }

  private static String numberToColumn(int number) {
    StringBuilder sb = new StringBuilder();
    while (number > 0) {
      number--;
      sb.insert(0, (char) ('A' + (number % 26)));
      number /= 26;
    }
    return sb.toString();
  }
}
