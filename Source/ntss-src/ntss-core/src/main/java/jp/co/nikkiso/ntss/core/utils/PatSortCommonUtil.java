package jp.co.nikkiso.ntss.core.utils;
//add 10389 バックエンド患者リスト順序付け機能処理 gjn start
import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurBed;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.util.CollectionUtils;

import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/**
 * 患者の複雑な順序付けツール類
 */
public class PatSortCommonUtil {

  // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
  private static final String number_regex = "-?\\d+(\\.\\d+)?";
  // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end

  /**
   *  ソート用比較関数
   *
   * @param a
   * @param b
   * @param isAsc
   * @param zeroSort 0が不明の意味がある場合: true、以外: false
   * @return
   */
  // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//  public static int compareFunc(Object a, Object b, boolean isAsc) {
  public static int compareFunc(Object a, Object b, boolean isAsc, boolean zeroSort) {
  // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
    if (a instanceof Integer && b instanceof Integer) {
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
      if (((Integer) a).compareTo(0) < 0 || ((Integer) b).compareTo(0) < 0) {
        isAsc = !isAsc;
      } else if (zeroSort && (a.equals(0) || b.equals(0))) {
        isAsc = !isAsc;
      }
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      if (isAsc) {
        return Integer.compare((Integer) a, (Integer) b);
      } else {
        return Integer.compare((Integer) b, (Integer) a);
      }
    } else if (a instanceof String && b instanceof String) {
      String str1 = (String) a;
      String str2 = (String) b;
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
      if (StringUtils.equalsAny("-1", str1, str2)) {
        isAsc = !isAsc;
      } else if (zeroSort && StringUtils.equalsAny("0", str1, str2)) {
        isAsc = !isAsc;
      }
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      int result;
      if (isAsc) {
        result = str1.compareTo(str2);
      } else {
        result = str2.compareTo(str1);
      }
      return result;
    } else if (a instanceof Character && b instanceof Character) {
      Character char1 = (Character) a;
      Character char2 = (Character) b;
      int result;
      if (isAsc) {
        result = char1.compareTo(char2);
      } else {
        result = char2.compareTo(char1);
      }
      return result;
    } else {
      return 0;
    }
  }

  /**
   * 患者IDソート用比較関数
   *
   * @param a
   * @param b
   * @param isAsc
   * @return
   */
  public static int compareHospPatIdFunc(Object a, Object b, boolean isAsc) {
    String aa = String.valueOf(a);
    String bb = String.valueOf(b);

  // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//    // 12位未満の。12ビットを補足して比較
//    String aByZero = String.format("%012d", parseIntOrDefault(aa, isAsc));
//    String bByZero = String.format("%012d", parseIntOrDefault(bb, isAsc));
//
//    if (isAsc) {
//      return aByZero.compareTo(bByZero);
//    } else {
//      return bByZero.compareTo(aByZero);
//    }
    if (a != null && b != null) {
      if (aa.matches(number_regex)) {
        if (bb.matches(number_regex)) {
          long numA = Long.parseLong(aa);
          long numB = Long.parseLong(bb);
          int cmp = Long.compare(numA, numB);
          if (cmp == 0) {
            // 数値が等しい場合、桁数順で比較
            cmp = Integer.compare(aa.length(), bb.length());
          }
          return isAsc ? cmp : -cmp;
        } else {
          return isAsc ? -1 : 1;
        }
      } else if (bb.matches(number_regex)) {
        return isAsc ? 1 : -1;
      }
    }

    if (isAsc) {
      return aa.compareTo(bb);
    } else {
      return bb.compareTo(aa);
    }
  // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
  }

  /**
   * タイプ変換処理
   * 非数値クラスIDが昇順であれ降順であれ最後になることを保証する
   *
   * @param str
   * @param isAsc
   * @return
   */
  public static Long parseIntOrDefault(String str, boolean isAsc) {
    try {
      return Long.parseLong(str);
    } catch (NumberFormatException e) {
      Long maxTop = 999999999999999L;
      Long mixTop = -999999999999999L;
      int index = findFirstAlphabetPosition(str);
      Long max = maxTop-(100-index);
      Long mix = mixTop-index;
      if (!isAsc) {
        //降順
        return mix;
      } else {
        //昇順
        return max;
      }
    }
  }

  public static int findFirstAlphabetPosition(String str) {
    str = str.toLowerCase(); // 文字列を小文字に変換
    for (int i = 0; i < str.length(); i++) {
      char ch = str.charAt(i);
      if (ch >= 'a' && ch <= 'z') {
        return ch - 'a' + 1; // a-zシーケンス内のアルファベットの位置を返します
      }
    }
    return 0; // 文字列にa-z文字がない場合は0を返します
  }

  /**
   * ソート・スコアリング
   *
   * @param a
   * @param b
   * @param sortCondition
   * @param patInfoJson
   * @return
   */
  public static int sortFunc(Map<String, Object> a, Map<String, Object> b, Map<String, Object> sortCondition, Map<String, String> patInfoJson) {
    String sortKey = (String) sortCondition.get("key");
    boolean isAsc = "1".equals(!Objects.isNull(sortCondition.get("isAsc")) ? String.valueOf(sortCondition.get("isAsc")) : "0");
    Object valueA = Objects.isNull(a.get(sortKey)) ? "" : a.get(sortKey);
    Object valueB = Objects.isNull(b.get(sortKey)) ? "" : b.get(sortKey);

    // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
    if (sortKey.equals("pat_name")) {
      Object patNameSortA = Objects.isNull(a.get("pat_name_sort")) ? "" : a.get("pat_name_sort");
      Object patNameSortB = Objects.isNull(b.get("pat_name_sort")) ? "" : b.get("pat_name_sort");
      return compareFunc(patNameSortA, patNameSortB, isAsc, true);
    }

    if (sortKey.equals("is_wheel_chair")) {
      if (valueA.equals(valueB) && valueA.equals("1")) {
        Object wheelChairCdA = Objects.isNull(a.get("wheel_chair_cd")) ? "" : a.get("wheel_chair_cd");
        Object wheelChairCdB = Objects.isNull(b.get("wheel_chair_cd")) ? "" : b.get("wheel_chair_cd");
        // Compare using mst_wheel_chair list
        return compareGetIndex(patInfoJson, "mst_wheel_chair", wheelChairCdA, wheelChairCdB, isAsc);
      }
      return compareFunc(valueA, valueB, isAsc, true);
    }

    if (sortKey.equals("pat_blood_type_abo")) {
      int aboSortResult = compareFunc(valueA, valueB, isAsc, true);
      if (aboSortResult != 0) {
        return aboSortResult;
      }
      Object rhA = Objects.isNull(a.get("pat_blood_type_rh")) ? "" : a.get("pat_blood_type_rh");
      Object rhB = Objects.isNull(b.get("pat_blood_type_rh")) ? "" : b.get("pat_blood_type_rh");
      int rhSortResult = compareFunc(rhA, rhB, isAsc, true);
      if (rhSortResult != 0) {
        return rhSortResult;
      }
      Object serovarA = Objects.isNull(a.get("pat_blood_type_serovar")) ? "" : a.get("pat_blood_type_serovar");
      Object serovarB = Objects.isNull(b.get("pat_blood_type_serovar")) ? "" : b.get("pat_blood_type_serovar");
      return compareFunc(serovarA, serovarB, isAsc, true);
    }
    // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end

    if (!valueA.equals(valueB)) {
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//      if (sortKey.equals("pat_birthday") || sortKey.equals("dialysis_start_date")) {
      if (sortKey.equals("pat_birthday")) {
//        Object dateA = !"".equals(valueA) ? valueA : "99991231";
//        Object dateB = !"".equals(valueB) ? valueB : "99991231";
        Object dateA = !"".equals(valueA) ? valueA : "17000101";
        Object dateB = !"".equals(valueB) ? valueB : "17000101";
//        return compareFunc(dateA, dateB, !isAsc);
        return compareFunc(dateA, dateB, !isAsc, true);
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      }
      if (sortKey.equals("pat_birthday_age")) {
        Object dateA = !"".equals(valueA) ? valueA : "99991231";
        Object dateB = !"".equals(valueB) ? valueB : "99991231";
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//        return compareFunc(dateA, dateB, isAsc);
        return compareFunc(dateA, dateB, isAsc, true);
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      }
      if (sortKey.equals("main_course_cd") || sortKey.equals("dialysis_course_cd")) {
        // Compare using mst_course list
        return compareGetIndex(patInfoJson, "mst_course", valueA, valueB, isAsc);
      }
      if (sortKey.equals("ward_cd")) {
        // Compare using mst_ward list
        return compareGetIndex(patInfoJson, "mst_ward", valueA, valueB, isAsc);
      }
      if (sortKey.equals("mst_severity")) {
        // Compare using mst_severity list
        return compareGetIndex(patInfoJson, "mst_severity", valueA, valueB, isAsc);
      }
      if (sortKey.equals("mst_transport")) {
        // Compare using mst_transport list
        return compareGetIndex(patInfoJson, "mst_transport", valueA, valueB, isAsc);
      }
      if (sortKey.equals("dial_diff_com_info")) {
        // Compare using mst_dialysis_difficulty list
        return compareGetIndex(patInfoJson, "mst_dialysis_difficulty", valueA, valueB, isAsc);
      }
      if (sortKey.equals("is_dia_under_dis") || sortKey.equals("is_main_disease")) {
        // Compare using mst_disease list
        return compareGetIndex(patInfoJson, "mst_disease", valueA, valueB, isAsc);
      }
      if (sortKey.equals("ind_tr_cd")) {
        // Compare using mst_treatment list
        return compareGetIndex(patInfoJson, "mst_treatment", valueA, valueB, isAsc);
      }
      if (sortKey.equals("hosp_pat_id")) {
        return compareHospPatIdFunc(valueA, valueB, isAsc);
      }
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
      if (sortKey.equals("severity_cd")) {
        // Compare using mst_severity list
        return compareGetIndex(patInfoJson, "mst_severity", valueA, valueB, isAsc);
      }
      if (sortKey.equals("transport_cd")) {
        // Compare using mst_transport list
        return compareGetIndex(patInfoJson, "mst_transport", valueA, valueB, isAsc);
      }
      if (sortKey.equals("pat_bed_name")) {
        if (StringUtils.equalsAny("0", valueA.toString(), valueB.toString())
          && StringUtils.equalsAny("-1", valueA.toString(), valueB.toString())) {
          return compareFunc(valueA, valueB, isAsc, true);
        }
        // Compare using mst_bed list
        return compareGetIndex(patInfoJson, "mst_bed", valueA, valueB, isAsc);
      }
      if (StringUtils.equalsAny(sortKey, "in_out_class", "in_out_current_state", "dialysis_start_date")) {
        return compareFunc(valueA, valueB, isAsc, false);
      }
//      return compareFunc(valueA, valueB, isAsc);
      return compareFunc(valueA, valueB, isAsc, true);
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
    }
    return 0;
  }

  /**
   * 標準 配列インデックスによる比較
   *
   * @param array
   * @param value
   * @return
   */
  public static int getIndex(String[] array, Object value) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].equals(String.valueOf(value))) {
        return i;
      }
    }
    return -1;
  }


  /**
   * 高性能マッチング
   *
   * @param patInfoJson
   * @param mst
   * @param valueA
   * @param valueB
   * @param isAsc
   * @return
   */
  public static int compareGetIndex(Map<String, String> patInfoJson, String mst, Object valueA, Object valueB, boolean isAsc) {
    int va, vb;
    String mst_disease_array = !Objects.isNull(patInfoJson.get(mst)) ? String.valueOf(patInfoJson.get(mst)) : "";
    // 配列をMapに変換する（key=オカレンス、value=インデックスの下付き）
    Map<String, Integer> map = new HashMap<>();
    String[] array = strConvertArray(mst_disease_array);
    for (int i = 0; i < array.length; i++) {
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//      map.put(array[i], i);
      map.put(array[i], i+1);
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
    }
    // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//    va = map.getOrDefault(valueA, -1);
//    vb = map.getOrDefault(valueB, -1);
//    return compareFunc(va, vb, isAsc);
    va = map.getOrDefault(String.valueOf(valueA), -1);
    vb = map.getOrDefault(String.valueOf(valueB), -1);
    return compareFunc(va, vb, isAsc, true);
    // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
  }

  /**
   * 文字列変換配列
   *
   * @param jsonString
   * @return
   */
  public static String[] strConvertArray(String jsonString) {
    try {
      JSONArray jsonArray = new JSONArray(jsonString);
      String[] stringArray = new String[jsonArray.length()];
      for (int i = 0; i < jsonArray.length(); i++) {
        stringArray[i] = jsonArray.getString(i);
      }
      return stringArray;
    } catch (JSONException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      return new String[0];
    }
  }

  /**
   * ソート条件の作成
   * AND
   * 3つのドロップダウン・リストで選択したフィールドに基づいて昇順または降順にソート
   *
   * @param tmpPatList
   * @param sortConditions
   * @param patInfoJson
   * @param ordList
   * @param chairs
   */
  // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//  public static void sortList(List<Map<String, Object>> tmpPatList, List<Map<String, Object>> sortConditions,
//                              Map<String, String> patInfoJson, List<OrdMainKurBed> ordList) {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static void sortList(List<Map<String, Object>> tmpPatList, List<Map<String, Object>> sortConditions,
                              Map<String, String> patInfoJson, List<OrdMainKurBed> ordList, List<MstWheelChair> chairs) throws JacksonException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
  // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
    // patInfoJsonクエリから返された結果に基づいて、次のソートに使用するtmpPatListデータを追加します。
    List<Map<String, Object>> patPersonalMain = null;
    List<Map<String, Object>> patMain = null;
    List<Map<String, Object>> patUnique = null;
    ObjectMapper mapper = new ObjectMapper();
    try {
      if (!patInfoJson.isEmpty()) {
        patPersonalMain = mapper.readValue(patInfoJson.get("pat_personal_main"), new TypeReference<List<Map<String, Object>>>() {
        });
        patMain = mapper.readValue(patInfoJson.get("pat_main"), new TypeReference<List<Map<String, Object>>>() {
        });
        patUnique = mapper.readValue(patInfoJson.get("pat_unique"), new TypeReference<List<Map<String, Object>>>() {
        });
      }
    } catch (JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      throwable.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      throw e;
    }

    for(Map<String, Object> pat : tmpPatList) {
      Map<String, Object> personalInfo = patPersonalMain.stream()
        .filter(el -> el.get("pat_id").equals(pat.get("pat_id")))
        .findFirst().orElse(new HashMap<>());

      Map<String, Object> mainInfo = patMain.stream()
        .filter(el -> el.get("pat_id").equals(pat.get("pat_id")))
        .findFirst().orElse(new HashMap<>());

      Map<String, Object> patUniqueInfo = patUnique.stream()
        .filter(el -> el.get("pat_id").equals(pat.get("pat_id")))
        .findFirst().orElse(new HashMap<>());

      pat.put("pat_id", personalInfo.get("pat_id"));
      pat.put("facility_cd", mainInfo.get("facility_cd"));
      pat.put("pat_birthday", personalInfo.get("pat_birthday"));
      pat.put("pat_birthday_age", personalInfo.get("pat_birthday"));
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//      pat.put("in_out_class", personalInfo.get("in_out_class"));
      if (null == personalInfo.get("in_out_class")) {
        pat.put("in_out_class", 3);
      } else if (2 == Integer.parseInt(personalInfo.get("in_out_class").toString())) {
        pat.put("in_out_class", -1);
      } else {
        pat.put("in_out_class", personalInfo.get("in_out_class"));
      }

//      String dialysis_start_date = "";
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      String medical_care_info = Objects.isNull(mainInfo.get("medical_care_info")) ? "" : mainInfo.get("medical_care_info").toString();
      if ("".equals(medical_care_info)) {
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//        pat.put("dialysis_start_date", dialysis_start_date);
        pat.put("dialysis_start_date", -1);
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      } else {
        JSONObject jsonObject = new JSONObject(medical_care_info);
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//        dialysis_start_date = String.valueOf(Objects.isNull(jsonObject.get("dialysis_start_date")) ? "" : jsonObject.get("dialysis_start_date"));
//        pat.put("dialysis_start_date", dialysis_start_date);
        if (Objects.isNull(jsonObject.get("dialysis_start_date")) || JSONObject.NULL.equals(jsonObject.get("dialysis_start_date"))) {
          pat.put("dialysis_start_date", -1);
        } else {
          String dialysisStartDateStr = String.valueOf(jsonObject.get("dialysis_start_date"));
          YearMonth now = YearMonth.now();
          DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
          try {
            YearMonth dialysisStartDate = YearMonth.parse(dialysisStartDateStr, formatter);
            int between = (int) ChronoUnit.MONTHS.between(dialysisStartDate, now);
            pat.put("dialysis_start_date", between);
          } catch (DateTimeParseException e) {
            pat.put("dialysis_start_date", 0);
          }
        }
        // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      }

      pat.put("hosp_pat_id", personalInfo.get("hosp_pat_id"));

      String pat_last_name = Objects.isNull(personalInfo.getOrDefault("pat_last_name", "")) ? "" : String.valueOf(personalInfo.getOrDefault("pat_last_name", ""));
      String pat_first_name = Objects.isNull(personalInfo.getOrDefault("pat_first_name", "")) ? "" : String.valueOf(personalInfo.getOrDefault("pat_first_name", ""));
      pat.put("pat_name", (pat_last_name + " " + pat_first_name).trim());

      String pat_last_name_kana = Objects.isNull(personalInfo.getOrDefault("pat_last_name_kana", "")) ? "" : String.valueOf(personalInfo.getOrDefault("pat_last_name_kana", ""));
      String pat_first_name_kana = Objects.isNull(personalInfo.getOrDefault("pat_first_name_kana", "")) ? "" : String.valueOf(personalInfo.getOrDefault("pat_first_name_kana", ""));
      pat.put("pat_name_kana", (pat_last_name_kana + " " + pat_first_name_kana).trim());

      String pat_last_name_alpha = Objects.isNull(personalInfo.getOrDefault("pat_last_name_alpha", "")) ? "" : String.valueOf(personalInfo.getOrDefault("pat_last_name_alpha", ""));
      String pat_first_name_alpha = Objects.isNull(personalInfo.getOrDefault("pat_first_name_alpha", "")) ? "" : String.valueOf(personalInfo.getOrDefault("pat_first_name_alpha", ""));
      pat.put("pat_name_alpha", (pat_last_name_alpha + " " + pat_first_name_alpha).trim());

      // システム共通患者名ソート用(フリガナ優先文字列)
      String lastName = !pat_last_name_kana.trim().isEmpty() ? pat_last_name_kana.trim() : pat_last_name.trim();
      String firstName = !pat_first_name_kana.trim().isEmpty() ? pat_first_name_kana.trim() : pat_first_name.trim();
      String pat_name_sort = String.join(" ", lastName, firstName);
      pat.put("pat_name_sort", pat_name_sort);

      pat.put("in_out_current_state", !Objects.isNull(mainInfo.get("in_out_current_state")) ? Integer.parseInt(mainInfo.get("in_out_current_state").toString()) : 10);
      pat.put("pat_blood_type_abo", !Objects.isNull(personalInfo.get("pat_blood_type_abo")) ? personalInfo.get("pat_blood_type_abo") : -1);
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
      pat.put("pat_blood_type_rh", !Objects.isNull(personalInfo.get("pat_blood_type_rh")) ? personalInfo.get("pat_blood_type_rh") : -1);
      pat.put("pat_blood_type_serovar", !Objects.isNull(personalInfo.get("pat_blood_type_serovar")) ? personalInfo.get("pat_blood_type_serovar") : -1);
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      pat.put("pat_sex", personalInfo.get("pat_sex"));
      // pat_kur,pat_bed_name,ind_tr_cdを空の文字列にする
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//      pat.put("pat_kur", "");
//      pat.put("pat_bed_name", "");
//      pat.put("ind_tr_cd", "");
//      if (!ordList.isEmpty()) {
//        List<OrdMainKurBed> ordListNew = ordList.stream().filter(f -> (pat.get("pat_id").equals(f.getPatId()))).distinct().collect(Collectors.toList());
//        for (OrdMainKurBed ord : ordListNew) {
//          if (ord.getPatId().equals(pat.get("pat_id"))) {
//            pat.put("pat_kur", ord.getKurStartTime());
//            pat.put("pat_bed_name", ord.getBedName());
//            pat.put("ind_tr_cd", ord.getIndTreatmentCd());
//          }
//        }
//      }
      pat.put("pat_kur", "-1");
      pat.put("pat_bed_name", -1);
      pat.put("ind_tr_cd", "-1");
      if (!CollectionUtils.isEmpty(ordList)) {
        Optional<OrdMainKurBed> ordMainKurBed = ordList.stream().filter(f -> (pat.get("pat_id").equals(Integer.valueOf(f.getPatId().toString())))).findFirst();
        if (ordMainKurBed.isPresent()) {
          OrdMainKurBed ord = ordMainKurBed.get();
          pat.put("pat_kur", StringUtils.isEmpty(ord.getKurStartTime()) ? "0" : ord.getKurStartTime());
          pat.put("pat_bed_name", Objects.nonNull(ord.getBedCd()) && 0 == ord.getBedCd() ? 0 : ord.getBedCd());
          pat.put("ind_tr_cd", ord.getIndTreatmentCd());
        }
      }
      // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
      if (!Objects.isNull(mainInfo.get("medical_care_info"))) {
        JSONObject medicalCareInfo = new JSONObject(mainInfo.get("medical_care_info").toString());
        pat.put("main_course_cd", medicalCareInfo.optString("main_course_cd", "-1"));
        pat.put("dialysis_course_cd", medicalCareInfo.optString("dialysis_course_cd", "-1"));
        pat.put("ward_cd", medicalCareInfo.optString("ward_cd", "-1"));
      } else {
        pat.put("main_course_cd", -1);
        pat.put("dialysis_course_cd", -1);
        pat.put("ward_cd", -1);
      }

      pat.put("severity_cd", Optional.ofNullable(personalInfo.get("severity_cd")).orElse(-1));
      pat.put("transport_cd", Optional.ofNullable(personalInfo.get("transport_cd")).orElse(-1));
      //禁忌
      if (Objects.isNull(mainInfo.get("taboo_allergy_info"))) {
        pat.put("taboo_allergy_info", -1);
      } else {
        JSONArray taboo_allergy_info_Array = new JSONArray(mainInfo.get("taboo_allergy_info").toString());
        JSONObject taboo_allergy_info = taboo_allergy_info_Array.length() > 0 ? (JSONObject) taboo_allergy_info_Array.get(0) : new JSONObject();
        pat.put("taboo_allergy_info", taboo_allergy_info.optString("taboo_allergy_class", "-1"));
      }
      pat.put("is_infect", Optional.ofNullable(mainInfo.get("is_infect")).orElse(-1));
      pat.put("is_implant", Optional.ofNullable(mainInfo.get("is_implant")).orElse(-1));
      pat.put("is_diabetes", Optional.ofNullable(mainInfo.get("is_diabetes")).orElse(-1));
      pat.put("is_blood_suger_exam", Optional.ofNullable(mainInfo.get("is_blood_suger_exam")).orElse(-1));
      pat.put("is_wheel_chair", Optional.ofNullable(mainInfo.get("is_wheel_chair")).orElse(-1));
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
      // 車いす利用マスタに患者個人所有の車情報をフィルターする
      Optional<MstWheelChair> wheelChair = chairs.stream()
        .filter(c -> "1".equals(c.getIsPersonal()) && c.getPatId().equals(Long.valueOf(String.valueOf(personalInfo.get("pat_id")))))
        .findAny();
      if (wheelChair.isPresent()) {
        // 個人所有車いす
        pat.put("wheel_chair_cd", String.valueOf(wheelChair.get().getWheelChairCd()));
        pat.put("is_wheel_chair", "1");
      } else if(!Objects.isNull(mainInfo.get("wheel_chair_cd"))) {
        // 共用所有車いす
        pat.put("wheel_chair_cd", String.valueOf(mainInfo.get("wheel_chair_cd")));
        pat.put("is_wheel_chair", "1");
      } else {
        pat.put("wheel_chair_cd", "");
      }
      // add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end

      if(personalInfo.get("dial_diff_com_info") != null) {
        JSONArray personalJSONArray = new JSONArray(personalInfo.get("dial_diff_com_info").toString());
        boolean flag = false;
        for (int i = 0; i < personalJSONArray.length(); i++) {
          JSONObject obj = personalJSONArray.getJSONObject(i);
          if (obj.get("is_main").equals("1")) {
            pat.put("dial_diff_com_info", Objects.isNull(obj.get("dial_diff_cd")) ? -1 : obj.get("dial_diff_cd"));
            flag = true;
            break;
          }
        }
        if (!flag) {
          pat.put("dial_diff_com_info", -1);
        }
      } else {
        pat.put("dial_diff_com_info", -1);
      }

      if(patUniqueInfo != null && patUniqueInfo.get("medical_hst_info") != null) {
        JSONArray uniqueJSONArray = new JSONArray(patUniqueInfo.get("medical_hst_info").toString());
        boolean flag1 = false, flag2 = false;
        for (int k = 0; k < uniqueJSONArray.length(); k++) {
          JSONObject uniqueObj = uniqueJSONArray.getJSONObject(k);
          if (uniqueObj.get("is_dialysis_underlying_disease").equals("1")) {
            // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//            pat.put("is_dia_under_dis", Objects.isNull(uniqueObj.get("disease_cd")) ? "-1" : String.valueOf(uniqueObj.get("disease_cd")));
            pat.put("is_dia_under_dis", !uniqueObj.has("disease_cd") || Objects.isNull(uniqueObj.get("disease_cd")) ? "-1" : String.valueOf(uniqueObj.get("disease_cd")));
            // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
            flag1 = true;
          }
          if (uniqueObj.get("is_main_disease").equals("1")) {
            // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
//            pat.put("is_main_disease", Objects.isNull(uniqueObj.get("disease_cd")) ? "-1" : String.valueOf(uniqueObj.get("disease_cd")));
            pat.put("is_main_disease", !uniqueObj.has("disease_cd") || Objects.isNull(uniqueObj.get("disease_cd")) ? "-1" : String.valueOf(uniqueObj.get("disease_cd")));
            // mod #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
            flag2 = true;
          }
        }
        if (!flag1) pat.put("is_dia_under_dis", "-1");
        if (!flag2) pat.put("is_main_disease", "-1");
      } else {
        pat.put("is_main_disease", "-1");
        pat.put("is_dia_under_dis", "-1");
      }
    }
    // 3つのドロップダウン・リストで選択したフィールドに基づいて昇順または降順にソート
    tmpPatList.sort(new Comparator<>() {
      @Override
      public int compare(Map<String, Object> a, Map<String, Object> b) {
        // 第1ソート条件
        if (sortConditions.size() > 0
          && !Objects.isNull(sortConditions.get(0))
          && !Objects.isNull(sortConditions.get(0).get("key"))) {
          int sortResult1 = sortFunc(a, b, sortConditions.get(0), patInfoJson);
          if (sortResult1 != 0) {
            return sortResult1;
          }
        }
        // 同値は下位のソート条件で続行
        // 第2ソート条件
        if (sortConditions.size() > 1
          && !Objects.isNull(sortConditions.get(1))
          && !Objects.isNull(sortConditions.get(1).get("key"))) {
          int sortResult2 = sortFunc(a, b, sortConditions.get(1), patInfoJson);
          if (sortResult2 != 0) {
            return sortResult2;
          }
        }
        // 第3ソート条件
        if (sortConditions.size() > 2
          && !Objects.isNull(sortConditions.get(2))
          && !Objects.isNull(sortConditions.get(2).get("key"))) {
          return sortFunc(a, b, sortConditions.get(2), patInfoJson);
        }
        return 0;
      }
    });
  }
}
//mod 10389 バックエンド患者リスト順序付け機能処理 gjn end
