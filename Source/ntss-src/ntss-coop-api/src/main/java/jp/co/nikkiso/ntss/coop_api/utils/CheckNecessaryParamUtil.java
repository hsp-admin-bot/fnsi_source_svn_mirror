package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.Map;

import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * ジャーナル-トランザクションテーブル登録処理における、必須パラメータのチェックをまとめたユーティリティクラス。
 */
public class CheckNecessaryParamUtil {

  /**
   * 必須チェック。（項目値取得済バージョン）
   *
   * @param keyName 項目名
   * @param value 項目値
   * @throws NtssException 項目が存在しない、もしくはnullやブランクの場合
   */
  public static void checkRequired(String keyName, Object value) {
    if (value == null || (value instanceof String) && StringUtils.isEmpty((String) value)) {
      String errMsg = String.format("キー[%s]は必須です。", keyName);
      throw new NtssException(errMsg);
    }
  }

  /**
   * 必須チェック。（項目値未取得バージョン）
   *
   * @param keyName 項目名
   * @param map パラメータマップ
   * @throws NtssException 項目が存在しない、もしくはnullやブランクの場合
   */
  public static void checkRequired(String keyName, Map<String, Object> map) {
    if (!map.containsKey(keyName)) {
      String errMsg = String.format("キー[%s]は必須です。", keyName);
      throw new NtssException(errMsg);
    }

    checkRequired(keyName, map.get(keyName));
  }
}
