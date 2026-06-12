package jp.co.nikkiso.ntss.coop_api.utils;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections4.MapUtils;

import tools.jackson.databind.JavaType;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * JSON形式Map（多段Map）の値を変換するユーティリティクラス。
 */
public class EntityJsonUtil {

  /**
   * マップの値がJSON値（マップ、配列）の時、文字列に変換する。
   *
   * @param m JSON形式マップ
   * @return 変換済みマップ
   */
  public static Map<String, String> flatten(Map<String, Object> m) {

    Map<String, String> result = new HashMap<>();
    if (MapUtils.isEmpty(m)) {
      return result;
    }

    Set<Map.Entry<String, Object>> sme = m.entrySet();
    for (Map.Entry<String, Object> me : sme) {
      result.put(me.getKey(), createJsonStr(me.getValue()));
    }

    return result;
  }

  /**
   * オブジェクト（マップ、配列、文字列、整数）をJSON形式文字列に変換する。
   *
   * @param obj オブジェクト
   * @return JSON形式文字列
   */
  private static String createJsonStr(Object obj) {

    // ObjectMapper#writeValue()は、obj引数がStringの時にダブルクォートで括った値を返す。
    // JSONの仕様としては正しいが、varchar型カラムに登録する値としては不正であるので
    // 引数がStringの場合は変換せずに返す。
    if (obj instanceof String) {
      return (String) obj;
    }

    if (obj instanceof Timestamp) {
      return String.valueOf(obj);
    }

    try {
      return ObjectMapperUtil.write(obj);
    } catch (IOException e) {
      throw new NtssException("JSON文字列変換でエラーが発生しました。", e);
    }
  }

  /**
   * マップの値がJSON文字列の時、マップに変換する。
   *
   * @param m マップ
   * @return 変換済みマップ
   */
  public static Map<String, Object> sharpen(Map<String, String> m) {

    Map<String, Object> result = new HashMap<>();
    if (MapUtils.isEmpty(m)) {
      return result;
    }

    Set<Map.Entry<String, String>> me = m.entrySet();
    for (Map.Entry<String, String> e : me) {
      result.put(e.getKey(), createJsonObj(e.getValue()));
    }

    return result;
  }

  /**
   * JSON形式文字列をオブジェクト（マップ、配列、文字列、整数）に変換する。
   *
   * @param s JSON形式文字列
   * @return オブジェクト
   */
  private static Object createJsonObj(String s) {

    try {
      switch (s.charAt(0)) {
      case JournalConvertConstants.JSON_START_ARRAY:
        JavaType listType = ObjectMapperUtil.constructListType(Object.class);
        return ObjectMapperUtil.read(s, listType);

      case JournalConvertConstants.JSON_START_OBJECT:
        JavaType mapType = ObjectMapperUtil.constructMapType(String.class, Object.class);
        return ObjectMapperUtil.read(s, mapType);

      default:
        // jsonb型カラムにはリストないしマップが登録されているはず。
        throw new NtssException("jsonb型カラムに不正な値が登録されています。");
      }
    } catch (IOException e) {
      throw new NtssException("DBに登録されたJSON文字列の解析でエラーが発生しました。", e);
    }
  }

  /**
   * JSON形式マップをマージする。
   *
   * @param m1 DBから取得した内容
   * @param m2 受信電文から抽出した内容
   * @param appendFlagMap カラムごとの追記/上書きフラグ
   * @return マージ結果
   */
  public static Map<String, Object> merge(Map<String, Object> m1, Map<String, Object> m2,
      Map<String, Boolean> appendFlagMap) {

    Map<String, Object> result = new HashMap<>(m1);
    if (MapUtils.isEmpty(m2)) {
      return result;
    }

    Set<Map.Entry<String, Object>> sme = m2.entrySet();
    for (Map.Entry<String, Object> me : sme) {
      String key = me.getKey();
      Boolean flagValue = appendFlagMap.get(key);

      // 未指定の場合（jsonb以外の型を想定）
      // 上書き
      if (flagValue == null) {
        result.put(key, me.getValue());
        continue;
      }

      // 明示的にfalseが指定された場合
      if (!flagValue) {
        Object resultValue = result.get(key);

        if (resultValue instanceof List) {
          // jsonb型のカラムにリストが登録されている場合
          List<Object> listValue = ObjectMapperUtil.castToObjectList(resultValue);
          result.put(key, listValue);
          listValue.clear();
          listValue.add(me.getValue());
        } else if (resultValue instanceof Map) {
          // jsonb型のカラムにマップが登録されている場合
          Map<String, Object> mapValue = ObjectMapperUtil.castToStringObjectMap(resultValue);
          result.put(key, mapValue);
          mapValue.clear();
          mapValue.putAll(ObjectMapperUtil.castToStringObjectMap(me.getValue()));
        } else {
          // 明示的にfalseが指定されているが、JSONの配列でもマップでもない場合
          result.put(key, me.getValue());
        }

        continue;
      }

      // 明示的にtrueが指定された場合
      Object resultValue = result.get(key);
      if (resultValue instanceof List) {
        List<Object> listValue = ObjectMapperUtil.castToObjectList(result.get(key));
        listValue.add(me.getValue());
      } else {
        // 配列以外の場合は追記不可とする。
        String errMsg = String.format("連携時の追記指定に誤りがあります。カラムの型がjsonbでないか、もしくは、マップ型JSONが登録されているため、追記できません。"
            + "追記元:[%s], 追記内容:[%s]", String.valueOf(resultValue), String.valueOf(me.getValue()));
        throw new NtssException(errMsg);
      }
    }

    return result;
  }

}
