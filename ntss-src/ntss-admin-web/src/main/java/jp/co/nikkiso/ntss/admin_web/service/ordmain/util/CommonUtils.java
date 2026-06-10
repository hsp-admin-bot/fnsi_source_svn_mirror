package jp.co.nikkiso.ntss.admin_web.service.ordmain.util;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

public class CommonUtils {

  /***
   * JSON配列データから値を取得し、Integer配列データを返す
   * @param stringList JSON配列データ
   * @return List
   */
  public static List<Integer> getValueList(String stringList) throws JSONException {
    JSONArray json;
    List<Integer> valueArray = new ArrayList<>();
    if (null == stringList) return valueArray;
    json = new JSONArray(stringList);
    // 選択された値を配列に格納
    for (int i = 0; i < json.length(); i++) {
      valueArray.add((int) (json.get(i)));
    }
    return valueArray;
  }

  /**
   * JSON配列データをLong配列に変換して返す
   *
   * @param stringList JSON配列データ
   * @return List
   */
  public static List<Long> getLongList(String stringList) throws JSONException {
    List<Long> longList = new ArrayList<>();
    // 値が入っていなければ、処理を終了して空の配列を返す
    if (null == stringList) return longList;
    JSONArray json = new JSONArray(stringList);
    // 選択された値を配列に格納
    for (int i = 0; i < json.length(); i++) {
      long l = json.getInt(i);
      longList.add(l);
    }
    return longList;
  }

  public static boolean jsonHasKey(JSONObject json, String key) {
    return json.has(key) && !json.isNull(key);
  }

  public static boolean jsonNodeIsNull(Object obj) {
    return Objects.isNull(obj) || "null".equals(obj.toString()) || StringUtils.EMPTY.equals(obj.toString());
  }

  public static Object changeToJSONObjectNull(Object object) {
    return object != null ? object : JSONObject.NULL;
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public static <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuilder inStr = new StringBuilder();
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (T obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }

  public static void addToMapList(Map<String, List<Object>> map, String key, Object value) {
    // Map内存在しない場合は新規で入れる
    if (!map.containsKey(key)) {
      List<Object> list = new ArrayList<>((List<?>) value);
      map.put(key, list);
    } else {
      // Map内既に存在するのであれば、既存リストへデータマージ
      List<Object> list = map.get(key);
      list.addAll((List<?>) value);
      list.stream().distinct().collect(Collectors.toList());
    }
  }
}
