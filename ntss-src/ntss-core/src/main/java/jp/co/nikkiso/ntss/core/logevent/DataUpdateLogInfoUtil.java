package jp.co.nikkiso.ntss.core.logevent;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import jp.co.nikkiso.ntss.core.entity.custom.CtlNoInfo;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.postgresql.util.PGobject;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.BeanUtils;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.core.entity.DataUpdateLogInfoEntity;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.JsonCompareInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.OrdMainHisInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.TableCommentInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.UpdateLogInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;

/**
 * データ更新ログ共通クラス
 * xiebzh
 */
public class DataUpdateLogInfoUtil {

  /** Jsonがないコラムのメッセージ */
  public final static String LOG_MESSAGE_NO_JSON = "[%s]の[%s]が[%s]→[%s]に変更されました。";

  /** Jsonがあるコラムのメッセージ */
  public final static String LOG_MESSAGE_FOR_JSON = "[%s]の[%s]の[%s]が[%s]→[%s]に変更されました。";

  // DB更新ログ出力ロジック xie Start
  public final static String LOG_MESSAGE_ORD_MAIN_HIS = "%s[%s]⇒[%s]";
  // DB更新ログ出力ロジック xie End
  /** すーべす */
  private final static String BLANK = "";

  /**
   * Key取得
   * @param key Jsonのキー
   * @return 変換したキー
   */
  public static String getKeyWithParent(String key) {
    String newKey = "";
    if (StringUtils.isEmpty(key)) {
      return key;
    }

    if (key.indexOf(".") >= 0) {
      String[] strArray = key.split("\\.");
      if (strArray != null && strArray.length > 0) {
        for (int i = 0; i < strArray.length; i++) {
          if (strArray[i].indexOf("[") >= 0) {
            continue;
          }
          newKey = newKey + strArray[i] + "-";
        }

        if (!StringUtils.isEmpty(newKey)) {
          return newKey.substring(0, newKey.length() - 1);
        }
      }
    } else {
      return key;
    }

    return newKey;
  }

  /**
   * Key取得
   * @param key Jsonのキー
   * @return 変換したキー
   */
  public static String getKeyWithStep(String key, int dotCnt) {
    int step = dotCnt;
    if (step <= 0) {
      step = 1;
    }
    if (key == null || key.equals(BLANK)) {
      return BLANK;
    }

    if (key.indexOf(".") >= 0) {
      String[] keyArray = key.split("\\.");
      if (keyArray != null) {
        if (keyArray.length >= step) {
          String result = "";
          for (int i = 0; i < keyArray.length; i++) {
            if (i >= step) {
              break;
            }
            result = result + keyArray[keyArray.length - step + i] + ".";
          }
          return result.substring(0, result.length() - 1);

        } else if (step > keyArray.length) {
          return key;
        } else {
          return keyArray[0];
        }
      }
    } else {
      return key;
    }

    return BLANK;
  }

  /**
   * Json判断
   * @param obj オブジェクト
   * @return true:json false:jsonがない
   */
  public static boolean isJson(Object obj) {

    if (obj == null) {
      return false;
    }

    if (obj instanceof PGobject) {
      if (((PGobject)obj).getType().equals("jsonb")) {
        return true;
      } else {
        return false;
      }
    }

    return false;
  }

  /**
   * Jsonオブジェクト変換
   * @param oldJsonStr 更新前データ
   * @param newJsonStr 更新後データ
   * @return 更新前後データのマージ結果
   * @throws JSONException
   */
  public static Map campareJsonObject(String oldJsonStr, String newJsonStr) throws JSONException {
    //add 6127 愁訴処置の場合、変更前後は""である場合がありますので、転換処理。 ljx start
    if("".equals(oldJsonStr)){
      oldJsonStr = "[]";
    }
    if("".equals(newJsonStr)){
      newJsonStr = "[]";
    }
    //add 6127 愁訴処置の場合、変更前後は""である場合がありますので、転換処理。 ljx end
    boolean isJsonArray = false;
    boolean isJson = false;
    Map<String, Object> oldMap = new LinkedHashMap<>();
    Map<String, Object> newMap = new LinkedHashMap<>();
    Map<String, Object> differenceMap = null;
    JSONArray oldJsonArray = null;
    JSONArray newJsonArray = null;
    JSONObject oldJson = null;
    JSONObject newJson = null;

    try {
      oldJsonArray = new JSONArray(oldJsonStr);
      newJsonArray = new JSONArray(newJsonStr);
      isJsonArray = true;
    } catch(Exception e) {
      isJsonArray = false;
    }

    try {
      oldJson = new JSONObject(oldJsonStr);
      newJson = new JSONObject(newJsonStr);
      isJson = true;
    } catch(Exception e) {
      isJson = false;
    }

    if (isJsonArray) {
      convertJsonToMap(oldJsonArray, BLANK, oldMap);
      convertJsonToMap(newJsonArray, BLANK, newMap);
      differenceMap = campareMap(oldMap, newMap);
    } else {
      if (isJson) {
        convertJsonToMap(oldJson, BLANK, oldMap);
        convertJsonToMap(newJson, BLANK, newMap);
        differenceMap = campareMap(oldMap, newMap);
      }
    }

    return differenceMap;
  }

  /**
   * JsonからMapに変換する
   * @param json jsonデータ
   * @param root ルートキー
   * @param resultMap 結果
   */
  private static void convertJsonToMap(Object json, String root, Map<String, Object> resultMap) {
    if (json instanceof JSONObject) {
      JSONObject jsonObject = ((JSONObject) json);
      Iterator iterator = jsonObject.keySet().iterator();
      while (iterator.hasNext()) {
        String key = convertString(iterator.next());
        Object value = jsonObject.get(key);
        String newRoot = BLANK.equals(root) ? key + BLANK : root + "." + key;
        if (value instanceof JSONObject || value instanceof JSONArray) {
          convertJsonToMap(value, newRoot, resultMap);
        } else {
          resultMap.put(newRoot, value);
        }
      }
    } else if (json instanceof JSONArray) {
      JSONArray jsonArray = (JSONArray) json;
      for (int i = 0; i < jsonArray.length(); i++) {
        Object vaule = jsonArray.get(i);
        String newRoot = BLANK.equals(root) ? "[" + i + "]" : root + ".[" + i + "]";
        if (vaule instanceof JSONObject || vaule instanceof JSONArray) {
          convertJsonToMap(vaule, newRoot, resultMap);
        } else {
          resultMap.put(newRoot, vaule);
        }
      }
    }
  }

  /**
   * 新旧比較
   * @param oldMap 更新前データ
   * @param newMap 更新後データ
   * @return 比較した結果
   */
  private static Map<String, Object> campareMap(Map<String, Object> oldMap, Map<String, Object> newMap) {
    campareNewToOld(oldMap, newMap);
    campareOldToNew(oldMap);
    return oldMap;
  }

  /**
   * 新旧比較
   * @param oldMap 更新前データ
   */
  private static void campareOldToNew(Map<String, Object> oldMap) {
    for (Iterator<Map.Entry<String, Object>> it = oldMap.entrySet().iterator(); it.hasNext(); ) {
      Map.Entry<String, Object> item = it.next();
      String key = item.getKey();
      Object value = item.getValue();
      if (!(value instanceof Map)) {
        Map<String, Object> differenceMap = new HashMap<>();
        differenceMap.put("oldValue", value);
        differenceMap.put("newValue", BLANK);
        oldMap.put(key, differenceMap);
      }
    }
  }

  /**
   * 新旧比較
   * @param oldMap 更新前データ
   * @param newMap 更新後データ
   */
  private static void campareNewToOld(Map<String, Object> oldMap, Map<String, Object> newMap) {
    for (Iterator<Map.Entry<String, Object>> it = newMap.entrySet().iterator(); it.hasNext(); ) {
      Map.Entry<String, Object> item = it.next();
      String key = item.getKey();
      Object newValue = item.getValue();
      Map<String, Object> differenceMap = new HashMap<>();
      if (oldMap.containsKey(key)) {
        Object oldValue = oldMap.get(key);
        if (newValue.equals(oldValue)) {
          oldMap.remove(key);
          continue;
        } else {
          differenceMap.put("oldValue", oldValue);
          differenceMap.put("newValue", newValue);
          oldMap.put(key, differenceMap);
        }
      } else {
        differenceMap.put("oldValue", BLANK);
        differenceMap.put("newValue", newValue);
        oldMap.put(key, differenceMap);
      }
    }
  }

  /**
   * 新旧比較
   * @param m オブジェクト
   * @param result データ
   * @return 比較結果
   */
  public static Map<Object,Object> viewJsonTree(Object m, Map<Object,Object> result) {
    if (null != m){
      try {
        Map mp = null;
        List ls = null;
        if (m instanceof Map || m instanceof LinkedHashMap) {
          mp = (Map)m;
          for (Iterator ite = mp.entrySet().iterator(); ite.hasNext();){
            Map.Entry e = (Map.Entry) ite.next();
            if (e.getValue() instanceof String) {
              result.put(e.getKey(), e.getValue());
            } else if(e.getValue() instanceof Map) {
              viewJsonTree((Map)e.getValue(),result);
            } else if(e.getValue() instanceof ArrayList) {
              viewJsonTree((ArrayList)e.getValue(),result);
            }
          }
        }
        if (m instanceof List || m instanceof ArrayList) {
          ls = (ArrayList)m;
          for (int i=0;i<ls.size();i++) {
            if (ls.get(i) instanceof Map) {
              viewJsonTree((Map)ls.get(i), result);
            }else if(ls.get(i) instanceof ArrayList){
              viewJsonTree((ArrayList)ls.get(i), result);
            }
          }
        }
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        throw e;
      }
    }

    return result;
  }

  /**
   * String変換
   * @param obj 変換用オブジェクト
   * @return 変換したデータ
   */
  public static String convertString(Object obj) {
    if (obj == null) {
      return BLANK;
    }

    try {
      if (obj instanceof Timestamp) {
        DateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
        return sdf.format(obj);
      }
    } catch (Exception e) {}

    if ("null".equals(obj.toString())) {
      return "";
    }

    return obj.toString();
  }

  /**
   * 二つオブジェクト比較
   * @param obj1 オブジェクト1
   * @param obj2 オブジェクト2
   * @return 比較した結果
   */
  public static boolean isEqual(Object obj1, Object obj2) {
    if (obj1 == null && obj2 == null) {
      return true;
    }

    if (obj1 == null && obj2 != null || obj1 != null && obj2 == null) {
      return false;
    }

    if (StringUtils.isEmpty(obj1) && StringUtils.isEmpty(obj2)) {
      return true;
    }

    if (obj1 instanceof String && obj2 instanceof String) {
      if ("null".equals(obj1) || obj1 == null) {
        obj1 = BLANK;
      }

      if ("null".equals(obj2) || obj1 == null) {
        obj2 = BLANK;
      }
    }

    if (obj1 instanceof BigDecimal || obj2 instanceof BigDecimal) {
      return isEqualByBigDecimal(obj1, obj2);
    }

    if (!obj1.getClass().toString().equals(obj2.getClass().toString())) {
      if (obj1 instanceof String) {
        return isEqualByTypeLang(obj1, obj2);
      } else if (obj2 instanceof String) {
        return isEqualByTypeLang(obj2, obj1);
      } else {
        return convertString(obj1).equals(convertString(obj2));
      }
    } else {
      return obj1.equals(obj2);
    }
  }

  /**
   * 比較
   * @param obj1 データ１
   * @param obj2 データ２
   * @return 比較結果
   */
  private static boolean isEqualByTypeLang(Object obj1, Object obj2) {
    String str = "";
    if (obj1 instanceof String) {
      if (obj1 == null) {
        str = "0";
      } else {
        str = convertString(obj1);
      }

      if ("".equals(str.trim())) {
        str = "0";
      }
      switch (obj2.getClass().getTypeName()) {
        case "java.lang.Short":
          return obj2.equals(Short.parseShort(str));
        case "java.lang.Integer":
          return obj2.equals(Integer.parseInt(str));
        case "java.lang.Double":
          return obj2.equals(Double.valueOf(str));
        case "java.lang.Long":
          return obj2.equals(Long.parseLong(str));
        default:
          return convertString(obj1).equals(convertString(obj2));
      }
    }

    return convertString(obj1).equals(convertString(obj2));
  }

  /**
   * ByBigDecimal比較
   * @param obj1 オブジェクト1
   * @param obj2 オブジェクト2
   * @return 比較結果
   */
  private static boolean isEqualByBigDecimal(Object obj1, Object obj2) {
    BigDecimal b1 = null;
    BigDecimal b2 = null;
    if (obj1 instanceof BigDecimal) {
      b1 = (BigDecimal) obj1;
    } else {
      b1 = new BigDecimal(convertString(obj1).equals("")? "0" : convertString(obj1));
    }

    if (obj2 instanceof BigDecimal) {
      b2 = (BigDecimal) obj2;
    } else {
      b2 = new BigDecimal(convertString(obj2).equals("")? "0" : convertString(obj2));
    }

    if (b1.compareTo(b2) == 0) {
      return true;
    }

    return false;
  }

  /**
   * Json文字列取得
   * @param obj オブジェクト
   * @return 変換した文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static String getJsonValue(Object obj) throws NoSuchMethodException, InvocationTargetException, IllegalAccessException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    if (obj instanceof String) {
      return convertString(obj);
    }

    try {
      Class c = obj.getClass();
      Method m = c.getMethod("getValue");
      Object param = null;
      String value = convertString(m.invoke(obj, param));
      return value;
    } catch (NoSuchMethodException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    } catch (InvocationTargetException ex) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      ex.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      throw ex;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    } catch (IllegalAccessException ea) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      ea.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      throw ea;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    }
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//    return BLANK;
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
  }

  /**  56
   * 論理カラム名を取得する
   * @param tableName テーブル名
   * @return 論理カラム名
   */
  public static List<TableCommentInfo> getAllFieldComment(Config cfg, String tableName) {
    SelectBuilder selectBuilder = SelectBuilder.newInstance(cfg);
    selectBuilder.sql("SELECT ");
    selectBuilder.sql("   tbl_name, ");
    selectBuilder.sql("   tbl_comment, ");
    selectBuilder.sql("   col_name, ");
    selectBuilder.sql("   col_comment, ");
    selectBuilder.sql("   json_flg, ");
    selectBuilder.sql("   keystep, ");
    selectBuilder.sql(" ord_main_hst_ins_flg ");
    selectBuilder.sql("FROM ");
    selectBuilder.sql("   log_table_comment ");
    selectBuilder.sql("WHERE ");
    selectBuilder.sql("     tbl_name = '" + tableName + "' ");
    selectBuilder.sql(" AND (delete_flg != 1 or delete_flg is null)");

    // Select文の実行
    List<Map<String, Object>> results = selectBuilder.getMapResultList(MapKeyNamingType.NONE);
    // 結果がゼロ件の場合、楽観的排他エラーをスロー
    if (results.isEmpty()) {
      throw new NotExistException("log_table_comment no data");
    }

    List tableInfoList = new ArrayList();
    TableCommentInfo tableInfo = null;
    for (int i = 0; i < results.size(); i++) {
      tableInfo = new TableCommentInfo();
      Map map = results.get(i);
      tableInfo.setTblName(convertString(map.get("tbl_name")));
      tableInfo.setTblComment(convertString(map.get("tbl_comment")));
      tableInfo.setColName(convertString(map.get("col_name")));
      tableInfo.setColComment(convertString(map.get("col_comment")));
      tableInfo.setJsonFlg(convertString(map.get("json_flg")));
      if (StringUtils.isEmpty(convertString(map.get("keystep"))) ||
        "0".equals(convertString(map.get("keystep")))) {
        tableInfo.setKeyStep(1);
      } else {
        tableInfo.setKeyStep(Integer.parseInt(convertString(map.get("keystep"))));
      }
      tableInfo.setOrdMainHstInsFlg(map.get("ord_main_hst_ins_flg") == null ? 0 : Integer.parseInt(convertString(map.get("ord_main_hst_ins_flg"))));

      tableInfoList.add(tableInfo);
    }

    return tableInfoList;
  }

  /**
   * 論理テーブル名を取得する
   * @param fieldCommentList
   * @return テーブル論理名
   */
  public static String getTableComment(List<TableCommentInfo> fieldCommentList) {
    if (fieldCommentList != null && fieldCommentList.size() >0) {
      return fieldCommentList.get(0).getTblComment();
    }
    return BLANK;
  }

  /**
   * 論理テーブル名を取得する
   * @param fieldCommentList
   * @return テーブル論理名
   */
  public static int getOrdMainHistFlg(List<TableCommentInfo> fieldCommentList) {
    if (fieldCommentList != null && fieldCommentList.size() >0) {
      return fieldCommentList.get(0).getOrdMainHstInsFlg();
    }
    return 0;
  }

  /**
   * 論理カラム名を取得する
   * @param fieldName カラム名
   * @param fieldList カラムリスト
   * @return 論理カラム名
   */
  public static String getFieldComment(String fieldName, List<TableCommentInfo> fieldList) {
    String fieldKey = "";
    String fieldComment = "";

    for (int i = 0; i < fieldList.size(); i++) {
      TableCommentInfo info = fieldList.get(i);
      if (fieldName.equals(info.getColName())) {
        return info.getColComment();
      }
    }

    return BLANK;
  }

  /**
   * キーステップを取得する
   * @param fieldCommentList
   * @return キーステップ
   */
  public static int getKeyStep(List<TableCommentInfo> fieldCommentList, String fieldName) {
    if (fieldCommentList != null && fieldCommentList.size() > 0) {
      for (int i = 0; i <fieldCommentList.size(); i++) {
        if (isEqual(fieldName, fieldCommentList.get(i).getColName())) {
          return fieldCommentList.get(i).getKeyStep();
        }
      }
    }

    return 0;
  }

  /**
   * 変更前データを取得する
   * @param data データ
   * @param infoMap 情報
   */
  public static void setBeforeFieldValue(List<Map<String, Object>> data, Map<String, UpdateLogInfo> infoMap) {
    for (Map dataMap : data) {
      Iterator<String> iter = dataMap.keySet().iterator();
      while(iter.hasNext()) {
        String key = iter.next();
        if (infoMap.containsKey(key)) {
          UpdateLogInfo outputInfo = infoMap.get(key);
          outputInfo.setBeforeUpdateValue(dataMap.get(key));
        }
      }
    }
  }

  /**
   * データ更新済みフラグ設定する
   * @param infoMap
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static void setUpdated(Config cfg, Map<String, UpdateLogInfo> infoMap) throws InvocationTargetException, NoSuchMethodException, IllegalAccessException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    Object beforeData = null;
    Object afterData = null;
    Iterator<String> iter = infoMap.keySet().iterator();
    while(iter.hasNext()) {
      String key = iter.next();
      UpdateLogInfo outputInfo = infoMap.get(key);
      beforeData = outputInfo.getBeforeUpdateValue();
      afterData = outputInfo.getAfterUpdateValue();
      outputInfo.setUpdated(!isEqual(beforeData, afterData));
      outputInfo.setJson((isJson(beforeData)));
      if (outputInfo.isJson()) {
        try {
          Map map = campareJsonObject(convertString(getJsonValue(beforeData)), getJsonValue(afterData));
          if (map != null && map.size() > 0) {
            List<JsonCompareInfo> list = getJsonCompareObject(cfg, map, outputInfo);
            outputInfo.setJsonUpdatedlist(list);
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        } catch (JSONException | IllegalAccessException e) {
          throw e;
        } catch (InvocationTargetException e) {
          throw e;
        } catch (NoSuchMethodException e) {
          throw e;
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      }
    }
  }

  /**
   * Jsonデータを比較する
   * @param cfg
   * @param map
   * @param outputInfo
   * @return
   */
  private static List<JsonCompareInfo> getJsonCompareObject(Config cfg, Map map, UpdateLogInfo outputInfo) {
    List<JsonCompareInfo> list = new ArrayList<JsonCompareInfo>();
    JsonCompareInfo jsonCompareInfo = null;
    Iterator<String> iter = map.keySet().iterator();
    while(iter.hasNext()) {
      String key = iter.next();
      Map value = (Map)map.get(key);
      jsonCompareInfo = new JsonCompareInfo();
      if (outputInfo.getKeyStep() == 1) {
        jsonCompareInfo.setKey(getKeyWithStep(key, 0));
      } else {
        jsonCompareInfo.setKey(getKeyWithParent(key));
      }

      jsonCompareInfo.setOldValue(convertString(value.get("oldValue")));
      jsonCompareInfo.setNewValue(convertString(value.get("newValue")));
      jsonCompareInfo.setTableName(outputInfo.getTableName());
      jsonCompareInfo.setColName(outputInfo.getFieldName());
      jsonCompareInfo.setKeyComment(getKeyComment(cfg, jsonCompareInfo));
      if (!isEqual(jsonCompareInfo.getOldValue(), jsonCompareInfo.getNewValue())) {
        list.add(jsonCompareInfo);
      }
    }

    return list;
  }

  /**
   * Jsonキーのコメントを取得する
   * @param cfg DB接続情報
   * @param jsonCompareInfo Json情報
   * @return Jsonキーのコメント
   */
  private static String getKeyComment(Config cfg, JsonCompareInfo jsonCompareInfo) {
    SelectBuilder selectBuilder = SelectBuilder.newInstance(cfg);
    selectBuilder.sql("SELECT ");
    selectBuilder.sql("     tbl_name, ");
    selectBuilder.sql("     col_name, ");
    selectBuilder.sql("     json_key_name, ");
    selectBuilder.sql("     json_key_comment ");
    selectBuilder.sql("FROM ");
    selectBuilder.sql("     log_json_comment ");
    selectBuilder.sql("WHERE ");
    selectBuilder.sql("     tbl_name = '" + jsonCompareInfo.getTableName() + "' ");
    selectBuilder.sql(" AND col_name = '" + jsonCompareInfo.getColName() + "' ");
    selectBuilder.sql(" AND json_key_name = '" + jsonCompareInfo.getKey() + "' ");

    // Select文の実行
    List<Map<String, Object>> results = executeSql(selectBuilder);
    // 結果がゼロ件の場合、楽観的排他エラーをスロー
    if (results.isEmpty()) {
      return BLANK;
    }

    Map map = results.get(0);
    return convertString(map.get("json_key_comment"));
  }

  /**
   * SQL実行する
   * @param selectBuilder SQL
   * @return 取得した検索結果
   */
  public static List<Map<String, Object>> executeSql(SelectBuilder selectBuilder) {
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }

  /**
   * データ変更ログを出力する(JSON以外)
   * @param outputInfo
   * @param tableName
   */
  public static void outputDataAccessLogNoJson(EventLogMessage eventLogMessage, LogServiceCore logServiceCore, UpdateLogInfo outputInfo, String tableName) {
    if (isContainPassword(outputInfo.getFieldName())) {
      outputInfo.setBeforeUpdateValue(passwordConvert(convertString(outputInfo.getBeforeUpdateValue())));
      outputInfo.setAfterUpdateValue(passwordConvert(convertString(outputInfo.getAfterUpdateValue())));
    }

    String logMessage = "";
    logMessage = String.format(LOG_MESSAGE_NO_JSON, tableName,
      outputInfo.getFieldComment(),
      convertString(outputInfo.getBeforeUpdateValue()),
      convertString(outputInfo.getAfterUpdateValue()));

    eventLogMessage.setLogMessage(logMessage);
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setFunctionName(outputInfo.getTableComment());
    logServiceCore.log(LogLevel.INFO, eventLogMessage, "", "", "",null);

    // DB更新ログ出力ロジック xie Start
    if (outputInfo.getOrdMainHstInsFlg() == 1) {
      String ordMainHisMessage = String.format(LOG_MESSAGE_ORD_MAIN_HIS, outputInfo.getFieldComment(),
        convertString(outputInfo.getBeforeUpdateValue()),
        convertString(outputInfo.getAfterUpdateValue()));
      OrdMainHisMongo ordMainHisMongo = new OrdMainHisMongo();
      ordMainHisMongo.setMessage(ordMainHisMessage);
      OrdMainHisInfo ordMainHisInfo = outputInfo.getOrdMainInfo();
      if (ordMainHisInfo != null) {
        ordMainHisMongo.setOrdNo(ordMainHisInfo.getOrdNo());
        ordMainHisMongo.setRstEdition(ordMainHisInfo.getRstEdition());
        ordMainHisMongo.setUpDate(ordMainHisInfo.getUpDate());
        ordMainHisMongo.setUpUserId(ordMainHisInfo.getUpUserId());
      }
      logServiceCore.createOrdMainHis(ordMainHisMongo);
    }
    // DB更新ログ出力ロジック xie End
  }

  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --start */
  /**
   * データ変更ログを出力する(JSON以外)
   * @param outputInfo
   * @param tableName
   */
  // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//  // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
//  // public static void outputDataAccessLogNoJsonToBatch(List<DataUpdateLogInfoEntity> entityList, LogServiceCore logServiceCore) {
//  public static void outputDataAccessLogNoJsonToBatch(List<DataUpdateLogInfoEntity> entityList, LogServiceCore logServiceCore, boolean isConfirm) {
//    // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
    public static void outputDataAccessLogNoJsonToBatch(List<DataUpdateLogInfoEntity> entityList, LogServiceCore logServiceCore) {
    // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
    List<EventLogMessage> eventLogMessageList = new ArrayList<>();
    for (DataUpdateLogInfoEntity entity : entityList) {
      if (isContainPassword(entity.getOutputInfo().getFieldName())) {
        entity.getOutputInfo().setBeforeUpdateValue(passwordConvert(convertString(entity.getOutputInfo().getBeforeUpdateValue())));
        entity.getOutputInfo().setAfterUpdateValue(passwordConvert(convertString(entity.getOutputInfo().getAfterUpdateValue())));
      }
      // add #6775 ログの抽出が正しく行われない 鄭爽 start
      if ("mnt_device_edge_state".equals(entity.getOutputInfo().getTableName()) &&
        "last_moni_time".equals(entity.getOutputInfo().getFieldName())) {
        continue;
      }
      // add #6775 ログの抽出が正しく行われない 鄭爽 end
      String logMessage = "";
      logMessage = String.format(LOG_MESSAGE_NO_JSON, entity.getTableName(),
        entity.getOutputInfo().getFieldComment(),
        convertString(entity.getOutputInfo().getBeforeUpdateValue()),
        convertString(entity.getOutputInfo().getAfterUpdateValue()));

      entity.getEventLogMessage().setLogMessage(logMessage);
      entity.getEventLogMessage().setEc2Identification(LogObjectUtils.getHostAddress());
      entity.getEventLogMessage().setFunctionName(entity.getOutputInfo().getTableComment());
//      logServiceCore.log(LogLevel.INFO, entity.getEventLogMessage(), "", "", "",null);
      eventLogMessageList.add(entity.getEventLogMessage());

      // DB更新ログ出力ロジック xie Start
      if (entity.getOutputInfo().getOrdMainHstInsFlg() == 1) {
        String ordMainHisMessage = String.format(LOG_MESSAGE_ORD_MAIN_HIS, entity.getOutputInfo().getFieldComment(),
          convertString(entity.getOutputInfo().getBeforeUpdateValue()),
          convertString(entity.getOutputInfo().getAfterUpdateValue()));
        OrdMainHisMongo ordMainHisMongo = new OrdMainHisMongo();
        ordMainHisMongo.setMessage(ordMainHisMessage);
        OrdMainHisInfo ordMainHisInfo = entity.getOutputInfo().getOrdMainInfo();
        if (ordMainHisInfo != null) {
          ordMainHisMongo.setOrdNo(ordMainHisInfo.getOrdNo());
          // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//          // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
//          // ordMainHisMongo.setRstEdition(ordMainHisInfo.getRstEdition());
//          String rstEdition = ordMainHisInfo.getRstEdition();
//          if (ordMainHisInfo.getRstEdition() != null && isConfirm == true) {
//            if (Integer.parseInt(ordMainHisInfo.getRstEdition()) >= 1) {
//              rstEdition = String.valueOf(Integer.parseInt(ordMainHisInfo.getRstEdition()) - 1);
//            }
//          }
//          ordMainHisMongo.setRstEdition(rstEdition);
//          // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
          ordMainHisMongo.setRstEdition(ordMainHisInfo.getRstEdition());
          // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
          ordMainHisMongo.setUpDate(ordMainHisInfo.getUpDate());
          ordMainHisMongo.setUpUserId(ordMainHisInfo.getUpUserId());
        }
        logServiceCore.createOrdMainHis(ordMainHisMongo);
      }
      // DB更新ログ出力ロジック xie End
    }

    if (!eventLogMessageList.isEmpty()) {
      logServiceCore.logToBatch(LogLevel.INFO, eventLogMessageList, "", "", "",null);
    }
  }
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --end */

  /**
   * データ変更ログを出力する(JSON対象)
   * @param outputInfo
   * @param tableName
   */
  public static void outputDataAccessLogForJson(EventLogMessage eventLogMessage, LogServiceCore logServiceCore, UpdateLogInfo outputInfo, String tableName) {
    String logMessage = "";
    List<JsonCompareInfo> list = outputInfo.getJsonUpdatedlist();
    if (list == null) {
      return;
    }
    for (int i = 0; i < list.size(); i++) {
      JsonCompareInfo jsonCompareInfo = list.get(i);
      // add #6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 鄭爽 start
      if ("pat_main".equals(list.get(i).getTableName()) &&
        "infect_info".equals(list.get(i).getColName()) &&
        ("infection_cd".equals(list.get(i).getKey()) ||
        "infect".equals(list.get(i).getKey())) &&
        "".equals(list.get(i).getNewValue())) {
        continue;
      }
      // add #6931 【デグレ】患者情報を編集した際ログに編集していない感染症を編集した記録が残る 鄭爽 end
      //FNSI-修正 4109対応 xiebzh add start
      if (convertString(jsonCompareInfo.getKey()).indexOf("up_date") >= 0 ||
        convertString(jsonCompareInfo.getKey()).indexOf("reg_date") >= 0 ||
        convertString(jsonCompareInfo.getKey()).indexOf("flg") >= 0 ||
        convertString(jsonCompareInfo.getKeyComment()).indexOf("フラグ") >= 0 ||
        convertString(jsonCompareInfo.getKeyComment()).indexOf("更新日時") >= 0) {
        continue;
      }

      if (isContainPassword(jsonCompareInfo.getKey())) {
        jsonCompareInfo.setOldValue(passwordConvert(convertString(jsonCompareInfo.getOldValue())));
        jsonCompareInfo.setNewValue(passwordConvert(convertString(jsonCompareInfo.getNewValue())));
      }

      // 保険情報
      setPatInsuranceDecryptJsonValue(jsonCompareInfo);
      // 患者基本情報
      setPatPersonalMainDecryptJsonValue(jsonCompareInfo);

      logMessage = String.format(
        LOG_MESSAGE_FOR_JSON,
        tableName,
        outputInfo.getFieldComment(),
        StringUtils.isEmpty(jsonCompareInfo.getKeyComment())? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
        convertString(jsonCompareInfo.getOldValue()),
        convertString(jsonCompareInfo.getNewValue()));

      eventLogMessage.setLogMessage(logMessage);
      eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
      eventLogMessage.setFunctionName(outputInfo.getTableComment());
      logServiceCore.log(LogLevel.INFO, eventLogMessage, "", "", "",null);

      // DB更新ログ出力ロジック xie Start
      if (outputInfo.getOrdMainHstInsFlg() == 1) {
        String ordMainHisMessage = String.format(LOG_MESSAGE_ORD_MAIN_HIS, outputInfo.getFieldComment() + "の" + jsonCompareInfo.getKeyComment(),
          convertString(jsonCompareInfo.getOldValue()),
          convertString(jsonCompareInfo.getNewValue()));
        OrdMainHisMongo ordMainHisMongo = new OrdMainHisMongo();
        ordMainHisMongo.setMessage(ordMainHisMessage);
        OrdMainHisInfo ordMainHisInfo = outputInfo.getOrdMainInfo();
        if (ordMainHisInfo != null) {
          ordMainHisMongo.setOrdNo(ordMainHisInfo.getOrdNo());
          ordMainHisMongo.setRstEdition(ordMainHisInfo.getRstEdition());
          ordMainHisMongo.setUpDate(ordMainHisInfo.getUpDate());
          ordMainHisMongo.setUpUserId(ordMainHisInfo.getUpUserId());
        }
        logServiceCore.createOrdMainHis(ordMainHisMongo);
      }
      // DB更新ログ出力ロジック xie End
    }
  }

  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --start */
  /**
   * データ変更ログを出力する(JSON対象)
   * @param outputInfo
   * @param tableName
   */

  // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//  // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
//  // public static void outputDataAccessLogForJsonToBatch(List<DataUpdateLogInfoEntity> entityList, LogServiceCore logServiceCore) {
//  public static void outputDataAccessLogForJsonToBatch(List<DataUpdateLogInfoEntity> entityList, LogServiceCore logServiceCore, boolean isConfirm) {
//    // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
    public static void outputDataAccessLogForJsonToBatch(List<DataUpdateLogInfoEntity> entityList, LogServiceCore logServiceCore) {
    // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
    List<EventLogMessage> eventLogMessageList = new ArrayList<>();
    for (DataUpdateLogInfoEntity entity : entityList) {
      String logMessage = "";
      List<JsonCompareInfo> list = entity.getOutputInfo().getJsonUpdatedlist();
      if (list == null) {
        continue;
      }
      for (int i = 0; i < list.size(); i++) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        BeanUtils.copyProperties(entity.getEventLogMessage(), eventLogMessage);
        JsonCompareInfo jsonCompareInfo = list.get(i);

        //FNSI-修正 4109対応 xiebzh add start
        if (convertString(jsonCompareInfo.getKey()).indexOf("up_date") >= 0 ||
          convertString(jsonCompareInfo.getKey()).indexOf("reg_date") >= 0 ||
          convertString(jsonCompareInfo.getKey()).indexOf("flg") >= 0 ||
          convertString(jsonCompareInfo.getKeyComment()).indexOf("フラグ") >= 0 ||
          convertString(jsonCompareInfo.getKeyComment()).indexOf("更新日時") >= 0) {
          continue;
        }

        if (isContainPassword(jsonCompareInfo.getKey())) {
          jsonCompareInfo.setOldValue(passwordConvert(convertString(jsonCompareInfo.getOldValue())));
          jsonCompareInfo.setNewValue(passwordConvert(convertString(jsonCompareInfo.getNewValue())));
        }

        // 保険情報
        setPatInsuranceDecryptJsonValue(jsonCompareInfo);
        // 患者基本情報
        setPatPersonalMainDecryptJsonValue(jsonCompareInfo);

        if (jsonCompareInfo.getKeyComment() == null ){
          continue;
        }

        logMessage = String.format(
          LOG_MESSAGE_FOR_JSON,
          entity.getTableName(),
          entity.getOutputInfo().getFieldComment(),
          StringUtils.isEmpty(jsonCompareInfo.getKeyComment())? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
          convertString(jsonCompareInfo.getOldValue()),
          convertString(jsonCompareInfo.getNewValue()));

        eventLogMessage.setLogMessage(logMessage);
        eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
        eventLogMessage.setFunctionName(entity.getOutputInfo().getTableComment());
//        logServiceCore.log(LogLevel.INFO, entity.getEventLogMessage(), "", "", "",null);
        eventLogMessageList.add(eventLogMessage);

        // DB更新ログ出力ロジック xie Start
        if (entity.getOutputInfo().getOrdMainHstInsFlg() == 1) {
          String ordMainHisMessage = String.format(LOG_MESSAGE_ORD_MAIN_HIS, entity.getOutputInfo().getFieldComment() + "の" + jsonCompareInfo.getKeyComment(),
            convertString(jsonCompareInfo.getOldValue()),
            convertString(jsonCompareInfo.getNewValue()));
          OrdMainHisMongo ordMainHisMongo = new OrdMainHisMongo();
          ordMainHisMongo.setMessage(ordMainHisMessage);
          OrdMainHisInfo ordMainHisInfo = entity.getOutputInfo().getOrdMainInfo();
          if (ordMainHisInfo != null) {
            ordMainHisMongo.setOrdNo(ordMainHisInfo.getOrdNo());
            // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//            // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
//            // ordMainHisMongo.setRstEdition(ordMainHisInfo.getRstEdition());
//            String rstEdition = ordMainHisInfo.getRstEdition();
//            if (ordMainHisInfo.getRstEdition() != null && isConfirm == true) {
//              if (Integer.parseInt(ordMainHisInfo.getRstEdition()) >= 1) {
//                rstEdition = String.valueOf(Integer.parseInt(ordMainHisInfo.getRstEdition()) - 1);
//              }
//            }
//            ordMainHisMongo.setRstEdition(rstEdition);
//            // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
            ordMainHisMongo.setRstEdition(ordMainHisInfo.getRstEdition());
            // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
            ordMainHisMongo.setUpDate(ordMainHisInfo.getUpDate());
            ordMainHisMongo.setUpUserId(ordMainHisInfo.getUpUserId());
          }
          logServiceCore.createOrdMainHis(ordMainHisMongo);
        }
        // DB更新ログ出力ロジック xie End
      }
    }

    if (!eventLogMessageList.isEmpty()) {
      logServiceCore.logToBatch(LogLevel.INFO, eventLogMessageList, "", "", "",null);
    }

  }
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --end */

  /**
   * 保険情報Decrypt value 設定
   * @param jsonCompareInfo
   */
  private static void setPatInsuranceDecryptJsonValue(JsonCompareInfo jsonCompareInfo) {
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_info", "insu_pat_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_info", "insu_pat_mark");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_pub_info", "insu_pub_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_pub_info", "insu_pub_no");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_pub_info", "insu_pub_pat_no");
  }

  /**
   * 患者基本情報Decrypt value 設定
   * @param jsonCompareInfo
   */
  private static void setPatPersonalMainDecryptJsonValue(JsonCompareInfo jsonCompareInfo) {
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "fax");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "tel1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "tel2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "memo1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "memo2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "e_mail");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "pat_id");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "zip_cd");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "work_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "last_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "work_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "first_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "work_address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "is_key_person");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "relation_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "last_name_kana");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "first_name_kana");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "fax");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "tel1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "tel2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "memo1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "memo2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "e_mail");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "zip_cd");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "work_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "work_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "work_address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "fax");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "memo1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "memo2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "zip_cd");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "company_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "company_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_e_mail");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_last_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_first_name");
  }

  private static void isDecryptJsonValue(
    JsonCompareInfo jsonCompareInfo, String tableName, String colName, String keyName) {
    if (jsonCompareInfo == null) {
      return;
    }

    if (jsonCompareInfo.getTableName().toLowerCase().equals(tableName) &&
      jsonCompareInfo.getColName().toLowerCase().equals(colName) &&
      jsonCompareInfo.getKey().toLowerCase().indexOf(keyName) >= 0) {
      String decryptOldValue = DataUpdateLogCommonNew.CUT_STR + jsonCompareInfo.getOldValue() + DataUpdateLogCommonNew.CUT_STR;
      String decryptNewValue = DataUpdateLogCommonNew.CUT_STR + jsonCompareInfo.getNewValue() + DataUpdateLogCommonNew.CUT_STR;
      jsonCompareInfo.setOldValue(decryptOldValue);
      // mod 6471 患者グループの編集した記録がログに残らない 周安寧 start
      //jsonCompareInfo.setOldValue(decryptNewValue);
      jsonCompareInfo.setNewValue(decryptNewValue);
      // mod 6471 患者グループの編集した記録がログに残らない 周安寧 end
    }
  }

  /**
   * パスワード含むかどうか
   * @param str コラム名
   * @return true: 含む false: 含まない
   */
  private static boolean isContainPassword(String str) {
    if (StringUtils.isEmpty(str)) {
      return false;
    }

    if (str.indexOf("user_password") >= 0) {
      return true;
    }

    return false;
  }

  /**
   * パスワードから[*]に変換する
   * @param pass パスワード
   * @return 変換後パスワード
   */
  private static String passwordConvert(String pass) {
    if (StringUtils.isEmpty(pass)) {
      return "";
    }
    String newPass = "";
    for (int i = 0; i < pass.length(); i++) {
      newPass += "*";
    }
    return newPass;
  }

  /**
   * 施設コード取得する
   * @param data
   * @return 取得した施設コード
   */
  public static String getFacilityCd(List<Map<String, Object>> data) {
    if (data == null || data.isEmpty()) {
      return BLANK;
    }

    for (Map map : data) {
      if (map.containsKey("facility_cd")) {
        return convertString(map.get("facility_cd"));
      }
      // add 10601 eventLog gjn start
      if (map.containsKey("facilityCd")) {
        return convertString(map.get("facilityCd"));
      }
      // add 10601 eventLog gjn end
    }

    return BLANK;
  }

  /**
   * UserID取得する
   * @param data
   * @return 取得したUserID
   */
  public static String getUserId(List<Map<String, Object>> data) {
    if (data == null || data.isEmpty()) {
      return BLANK;
    }

    for (Map map : data) {
      if (map.containsKey("up_user_id")) {
        return convertString(map.get("up_user_id"));
      }

      //add 利用者がない場合、テーブルから取得するの対応 xie start
      if (map.containsKey("up_ind_user_id")) {
        return convertString(map.get("up_ind_user_id"));
      }

      if (map.containsKey("user_id")) {
        return convertString(map.get("user_id"));
      }
      //add 利用者がない場合、テーブルから取得するの対応 xie start
      // add 10601 eventLog gjn start
      if (map.containsKey("upUserId")) {
        return convertString(map.get("upUserId"));
      }
      // add 10601 eventLog gjn end
    }

    return BLANK;
  }

  /**
   * 患者ID取得する
   * @param data データ
   * @return 取得した患者ID
   */
  public static String getPatId(List<Map<String, Object>> data) {
    if (data == null || data.isEmpty()) {
      return BLANK;
    }

    for (Map map : data) {
      if (map.containsKey("pat_id")) {
        return convertString(map.get("pat_id"));
      }
      // add 10601 eventLog gjn start
      if (map.containsKey("patId")) {
        return convertString(map.get("patId"));
      }
      // add 10601 eventLog gjn end
    }

    return BLANK;
  }

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  private static Map<String, Object> editCtlNoDifferenceMap(CtlNoInfo ctlNoInfo, Map<String, Object> oldMap, Map<String, Object> newMap) {
    List<JSONObject> oldJSONList = new ArrayList<>();
    List<JSONObject> newJSONList = new ArrayList<>();
    for(String ctlNo : ctlNoInfo.getCtlNoList()) {
      Optional<JSONObject> oldJsonObject = ctlNoInfo.getOldJSONList().stream().filter(el -> el.get("ctl_no") != null
        && el.get("ctl_no").toString().equals(ctlNo)).findFirst();
      if(oldJsonObject.isPresent()) {
        oldJSONList.add(oldJsonObject.get());
      } else {
        oldJSONList.add(new JSONObject());
      }
      Optional<JSONObject> newJsonObject = ctlNoInfo.getNewJSONList().stream().filter(el -> el.get("ctl_no") != null
        && el.get("ctl_no").toString().equals(ctlNo)).findFirst();
      if(newJsonObject.isPresent()) {
        newJSONList.add(newJsonObject.get());
      } else {
        newJSONList.add(new JSONObject());
      }
    }
    JSONArray oldJsonArray = new JSONArray(oldJSONList);
    JSONArray newJsonArray = new JSONArray(newJSONList);
    convertJsonToMap(oldJsonArray, BLANK, oldMap);
    convertJsonToMap(newJsonArray, BLANK, newMap);
    return campareMap(oldMap, newMap);
  }

  private static CtlNoInfo checkCtlNoIsExists(JSONArray oldJsonArray, JSONArray newJsonArray) {
    CtlNoInfo ctlNoInfo = new CtlNoInfo();
    List<String> ctlNoList = new ArrayList<>();
    List<JSONObject> oldJSONList = new ArrayList<>();
    List<JSONObject> newJSONList = new ArrayList<>();
    int maxSize = oldJsonArray.length() > newJsonArray.length() ? oldJsonArray.length() : newJsonArray.length();
    for(int i = 0; i < maxSize; i++) {
      if(i < oldJsonArray.length()) {
        oldJSONList.add(oldJsonArray.getJSONObject(i));
        if(!"null".equals(oldJsonArray.getJSONObject(i).get("ctl_no").toString())
          && !ctlNoList.contains(oldJsonArray.getJSONObject(i).get("ctl_no").toString())) {
          ctlNoList.add(oldJsonArray.getJSONObject(i).get("ctl_no").toString());
        }
      }
      if(i < newJsonArray.length()) {
        newJSONList.add(newJsonArray.getJSONObject(i));
        if(!"null".equals(newJsonArray.getJSONObject(i).get("ctl_no").toString())
          && !ctlNoList.contains(newJsonArray.getJSONObject(i).get("ctl_no").toString())) {
          ctlNoList.add(newJsonArray.getJSONObject(i).get("ctl_no").toString());
        }
      }
    }
    ctlNoInfo.setCtlNoList(ctlNoList);
    ctlNoInfo.setOldJSONList(oldJSONList);
    ctlNoInfo.setNewJSONList(newJSONList);
    return ctlNoInfo;
  }

  public static Map comparePatUniqueJsonObject(String oldJsonStr, String newJsonStr) throws JSONException {
    Map<String, Object> oldMap = new LinkedHashMap<>();
    Map<String, Object> newMap = new LinkedHashMap<>();
    JSONArray oldJsonArray = new JSONArray(oldJsonStr);
    JSONArray newJsonArray = new JSONArray(newJsonStr);
    CtlNoInfo ctlNoInfo = checkCtlNoIsExists(oldJsonArray, newJsonArray);
    return editCtlNoDifferenceMap(ctlNoInfo, oldMap, newMap);
  }
  // add 10626 データリストのCTR・DW一括登録修正 房 end
}
