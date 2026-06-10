package jp.co.nikkiso.ntss.coop_api.utils;

import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * ctl_noの最大値を求めるユーティリティクラス。
 */
public class MaxCtlNoUtil {

  /**
   * ctl_noの最大値を取得する。
   *
   * @param valueStr
   * @return ctl_noの最大値
   */
  public static Long getCtlNoMax(String valueStr) {

    if (StringUtils.isEmpty(valueStr)) {
      return 1L;
    }

    try {
      List<Map<String, Object>> colValue = ObjectMapperUtil.readListOfMap(valueStr);
      return getCtlNoMax(colValue);
    } catch (IOException e) {
      throw new NtssException("ctl_no最大値の取得でエラーが発生しました。", e);
    }
  }

  /**
   * 配列形式JSONで、要素のうちctl_noキーに対する値の最大値を取得する。
   *
   * @param l 配列形式JSON
   * @return 最大値
   */
  public static Long getCtlNoMax(List<Map<String, Object>> l) {

    if (CollectionUtils.isEmpty(l)) {
      return 0L;
    }

    Optional<Long> m = l.stream().map(e -> longValue(e.get("ctl_no"))).max(Comparator.naturalOrder());
    return m.orElse(0L);
  }

  /**
   * IntegerないしLongの値をlongに変換する。
   *
   * @param obj IntegerないしLong（nullも可）
   * @return long値
   */
  public static long longValue(Object obj) {
    if (obj == null) {
      return 0L;
    }

    if (obj instanceof Long) {
      return (long) obj;
    }

    if (obj instanceof String) {
      return Long.parseLong((String) obj);
    }

    return Long.valueOf((Integer) obj);
  }
}
