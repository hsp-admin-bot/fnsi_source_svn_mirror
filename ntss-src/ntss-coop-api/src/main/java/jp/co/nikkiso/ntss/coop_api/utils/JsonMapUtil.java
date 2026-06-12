package jp.co.nikkiso.ntss.coop_api.utils;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_TMP_COLUMN;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.TABLE_PAT_INSURANCE;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections4.MapUtils;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;

public class JsonMapUtil {

  /** 英数字および空白文字の並びを判別する正規表現 */
  private static final String REGEXP_ALPHA_NUM_SPACE = "^[A-Z0-9_\\s]+$";

  /**
   * 抽出したデータをカラム単位でまとめる。
   * （{table1.column1.key1=abcde, table1.column1.key2=あいう} -> table.column1={key1=abcde, key2=あいう}
   *
   * @param rm 抽出したデータ
   * @return カラム単位でまとめたマップ
   */
  public static ResultMap collectJsonMapByKey(ResultMap rm) {
    if (MapUtils.isEmpty(rm)) {
      return rm;
    }

    Set<String> keySet = rm.keySet();
    ResultMap collected = new ResultMap();

    for (String key : keySet) {
      String[] keyArr = key.split("\\.");

      // col属性の値により判別する。
      switch (keyArr.length) {

        // テーブル名のみの場合（「%%shori_kbn」等の特例のみ該当）
        case 1:
          add1(collected, key, rm.get(key));
          break;

        // 「テーブル名.カラム名」の場合
        case 2:
          add2(collected, key, rm.get(key));
          break;

        // 「テーブル名.カラム名.JSONキー名」の場合
        case 3:
          String keyColumn = String.join(".", keyArr[0], keyArr[1]);
          add3(collected, keyColumn, keyArr[2], rm.get(key));
          break;
        // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
        case 4:
          String keyColumns = String.join(".", keyArr[0], keyArr[1], keyArr[2]);
          add4(collected, keyColumns, keyArr[3], rm.get(key));
          break;
        // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end

        default:
          break;
      }
    }

    return collected;
  }

  /**
   * キーがテーブル名のみの場合の処理。
   *
   * @param rm 電文データ
   * @param key キー
   * @param obj キーに対応する値
   */
  private static void add1(ResultMap rm, String key, Object obj) {
    Object target = rm.get(key);
    if (target == null) {
      rm.put(key, obj);
    }
  }

  /**
   * キーが「テーブル名.カラム名」の場合の処理。
   *
   * @param rm 電文データ
   * @param key キー
   * @param obj キーに対応する値
   */
  private static void add2(ResultMap rm, String key, Object obj) {
    Object target = rm.get(key);
    if (target == null) {
      rm.put(key, obj);
      return;
    }

    if (target instanceof Map) {
      Map<String, Object> t = ObjectMapperUtil.castToStringObjectMap(target);
      rm.put(key, t);

      if (obj instanceof Map) {
        Map<String, Object> m = ObjectMapperUtil.castToStringObjectMap(obj);
        t.putAll(m);
      }

      return;
    }

    if (target instanceof List) {
      List<Object> t = ObjectMapperUtil.castToObjectList(target);
      rm.put(key, t);
      t.add(obj);
    }
  }

  /**
   * キーが「テーブル名.カラム名.JSONキー名」の場合の処理。
   *
   * @param rm 電文データ
   * @param key12 キーのうち「テーブル名.カラム名」の部分
   * @param key3 キーのうち「JSONキー名」の部分
   * @param obj キーに対応する値
   */
  private static void add3(ResultMap rm, String key12, String key3, Object obj) {
    Object target = rm.get(key12);
    if (target == null) {
      Map<String, Object> m = new HashMap<>();
      rm.put(key12, m);
      m.put(key3, obj);
      return;
    }

    if (target instanceof Map) {
      Map<String, Object> m = ObjectMapperUtil.castToStringObjectMap(target);
      rm.put(key12, m);

      if (obj instanceof Map) {
        Map<String, Object> m2 = ObjectMapperUtil.castToStringObjectMap(obj);
        m.putAll(m2);
        return;
      }

      m.put(key3, obj);
      return;
    }

    if (target instanceof List) {
      List<Object> t = ObjectMapperUtil.castToObjectList(target);
      rm.put(key12, t);

      if (obj instanceof List) {
        List<Object> o = ObjectMapperUtil.castToObjectList(obj);
        t.addAll(o);
        return;
      }

      Map<String, Object> m = new HashMap<>();
      t.add(m);
      m.put(key3, obj);
    }
  }

  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
  /**
   * キーが「テーブル名.カラム名.JSONキー名」の場合の処理。
   *
   * @param rm 電文データ
   * @param key123 キーのうち「テーブル名.カラム名」の部分
   * @param key4 キーのうち「JSONキー名」の部分
   * @param obj キーに対応する値
   */
  private static void add4(ResultMap rm, String key123, String key4, Object obj) {
    Object target = rm.get(key123);
    if (target == null) {
      Map<String, Object> m = new HashMap<>();
      rm.put(key123, m);
      m.put(key4, obj);
      return;
    }

    if (target instanceof Map) {
      Map<String, Object> m = ObjectMapperUtil.castToStringObjectMap(target);
      rm.put(key123, m);

      if (obj instanceof Map) {
        Map<String, Object> m2 = ObjectMapperUtil.castToStringObjectMap(obj);
        m.putAll(m2);
        return;
      }

      m.put(key4, obj);
      return;
    }

    if (target instanceof List) {
      List<Object> t = ObjectMapperUtil.castToObjectList(target);
      rm.put(key123, t);

      if (obj instanceof List) {
        List<Object> o = ObjectMapperUtil.castToObjectList(obj);
        t.addAll(o);
        return;
      }

      Map<String, Object> m = new HashMap<>();
      t.add(m);
      m.put(key4, obj);
    }
  }
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end

  /**
   * col属性の値が「pat_insurance.<英大文字、数字、"_"、スペース>」の場合、ダミーのカラム名を追加して正規化する。
   *
   * @param key col属性の値
   * @return 正規化結果
   */
  public static String normalizeKey(String key) {
    if (StringUtils.isEmpty(key)) {
      return key;
    }

    String[] keyArr = key.split("\\.");
    if (keyArr.length == 2 && isSpecial(keyArr)) {
      return String.join(".", keyArr[0], PAT_INSURANCE_TMP_COLUMN, keyArr[1]);
    }

    return key;
  }

  /**
   * テーブル名がpat_insurance、JSONキーが特殊値か判別する。
   *
   * @param keyArr col属性を"."で区切った配列
   * @return 特殊値であればtrue
   */
  private static boolean isSpecial(String[] keyArr) {
    return keyArr[0].equals(TABLE_PAT_INSURANCE) &&
        keyArr[1].matches(REGEXP_ALPHA_NUM_SPACE);
  }

  /**
   * テーブル.カラムに対する値が単一のマップの時、マップのリストに変換する。
   * @param rm マップ
   */
  public static void makeListOnSingleMap(ResultMap rm) {
    if (MapUtils.isEmpty(rm)) {
      return;
    }

    Set<Map.Entry<String, Object>> entrySet = rm.entrySet();
    for (Map.Entry<String, Object> entry : entrySet) {
      Object obj = entry.getValue();
      // del FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 start
//      add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 張 start
//      if (obj instanceof List) {
//        List<Object> arrayList = (List) obj;
//        List<Object> array = new ArrayList<>();
//        Object list;
//        arrayList.forEach(item ->
//          array.add(item.toString().replace("&amp;","&").replace("\"", "@#@").replace("&quot;", "@#@"))
//        );
//        list = array;
//        String key = entry.getKey();
//        rm.put(key, list);
//      }
//      add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 張 end
      // del FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 end
      if (!(obj instanceof Map)) {
        continue;
      }

      List<Object> l = new ArrayList<>();
      l.add(obj);
      String key = entry.getKey();
      rm.put(key, l);
    }
  }
}
