package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Objects;

import org.apache.commons.collections4.CollectionUtils;

/**
 * マップのリストの要素のうち、指定された条件を満たすものを別のマップで置換するユーティリティクラス。
 */
public class ListReplacerUtil {

  /**
   * マップのリストの要素のうち、指定されたキーが一致するものを別のマップで置換する。
   *
   * @param list マップのリスト
   * @param item 置換要素（マップ）
   * @param keyName 判定キー
   */
  public static void replaceOrAdd(List<Map<String, Object>> list, Map<String, Object> item, String keyName) {

    if (CollectionUtils.isEmpty(list)) {
      list.add(item);
      return;
    }

    ListIterator<Map<String, Object>> itr = list.listIterator();
    while (itr.hasNext()) {
      Map<String, Object> m = itr.next();
      if (hasSame(m, item, keyName)) {
        itr.set(item);
        return;
      }
    }

    list.add(item);
  }

  /**
   * 2つのマップの指定されたキーに対応する値が一致するか判定する。
   *
   * @param m1 マップ1
   * @param m2 マップ2
   * @param keyName キー名
   * @return 値が一致すればtrue、一致しなければfalse
   */
  private static boolean hasSame(Map<String, Object> m1, Map<String, Object> m2, String keyName) {

    Object v1 = m1.get(keyName);
    Object v2 = m2.get(keyName);
    return v1 != null && v2 != null && Objects.equals(v1, v2);
  }

}
