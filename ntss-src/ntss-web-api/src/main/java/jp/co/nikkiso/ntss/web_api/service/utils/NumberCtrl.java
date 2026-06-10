package jp.co.nikkiso.ntss.web_api.service.utils;

import org.springframework.util.NumberUtils;

/**
 * 数値関連クラス
 * 
 */
public class NumberCtrl {
  
  /**
   * 文字列 → 数値変換
   * 
   * @param value 対象文字列
   * @param defaultValue 対象文字列変換失敗時のデフォルト値(必ず数値の文字列を設定すること)
   * @param targetClass 数値(戻り値)の型
   * @return
   */
  public static <T extends Number> T ParseNumber(String value, String defaultValue, Class<T> targetClass) {
    T ret = null;
    try {
      // 数値変換
      ret = NumberUtils.parseNumber(value, targetClass);
    } catch (Exception ex) {
      // 変換失敗時はデフォルト値を設定
      ret = NumberUtils.parseNumber(defaultValue, targetClass);
    }
    
    return ret;
  }
}
