package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.HashMap;
import java.util.Map;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * カラムと値の対応を管理するクラス。
 */
public class ColumnValueManager {

  /**
   * カラムと値のマップ。
   * 第1キーはテーブル名、第2キーはカラム名、値は文字列（jsonb型以外）およびMap<String, String>（jsonb型）
   */
  private Map<String, Map<String, Object>> columnValueMap;

  /**
   * コンストラクタ。
   */
  public ColumnValueManager() {

    columnValueMap = new HashMap<>();
  }

  /**
   * カラムと値の対応を取得する。
   *
   * @return 対応マップ
   */
  public Map<String, Map<String, Object>> getColumnValueMap() {

    return columnValueMap;
  }

  /**
   * テーブルとカラムと値を対応付ける。
   *
   * @param tableName テーブル名
   * @param columnName テーブル名
   * @param value 値
   */
  public void add(String tableName, String columnName, Object value) {

    Map<String, Object> m = getColumnMap(tableName);
    m.put(columnName, value);
  }

  /**
   * JSON形式の値を蓄積する。
   *
   * @param tableName テーブル名
   * @param columnName カラム名
   * @param jsonKey JSONキー
   * @param jsonValue JSON値
   */
  public void add(String tableName, String columnName, String jsonKey, Object jsonValue) {
    Map<String, Object> m = getColumnMap(tableName);
    Map<String, Object> m2 = getJsonMap(m, columnName);
    m2.put(jsonKey, jsonValue);
  }

  /**
   * テーブルに対応するカラムのマップを取得する。
   *
   * @param tableName テーブル名
   * @return カラムのマップ
   */
  public Map<String, Object> getColumnMap(String tableName) {

    if (!columnValueMap.containsKey(tableName)) {
      Map<String, Object> m = new HashMap<>();
      columnValueMap.put(tableName, m);
      return m;
    }

    return columnValueMap.get(tableName);
  }

  /**
   * キーに対応するJSONマップを取得する。
   *
   * @param key キー
   * @return JSONマップ
   * @throws 該当するカラムの型がjsonbでない場合は
   */
  private Map<String, Object> getJsonMap(Map<String, Object> map, String key) {

    if (!map.containsKey(key)) {
      Map<String, Object> m = new HashMap<>();
      map.put(key, m);
      return m;
    }

    Object obj = map.get(key);
    if (obj instanceof Map) {
      Map<String, Object> mm = ObjectMapperUtil.castToStringObjectMap(obj);
      // ObjectMapper#convertValue()は引数の型を変換する前にディープコピーを作る。
      // そのため、同一キーで再登録しないと、返値にputされても元の構造に反映されない。
      map.put(key, mm);
      return mm;
    }

    String errMsg = String.format("jsonb型以外のカラムにjson値を指定しています。キー:[%s]", key);
    throw new NtssException(errMsg);
  }

  /**
   * 抽出した値のうち、テーブル名とカラム名に合致するものを取得する。
   *
   * @param tableName テーブル名
   * @param columnName カラム名
   * @return 抽出した値
   */
  public Object getValueByTableAndColumn(String tableName, String columnName) {

    if (!columnValueMap.containsKey(tableName)) {
      return null;
    }

    Map<String, Object> tableMap = columnValueMap.get(tableName);
    if (!tableMap.containsKey(columnName)) {
      return null;
    }

    return tableMap.get(columnName);
  }

}
