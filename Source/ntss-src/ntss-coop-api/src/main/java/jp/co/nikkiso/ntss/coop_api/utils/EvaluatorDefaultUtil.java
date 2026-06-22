package jp.co.nikkiso.ntss.coop_api.utils;

/**
 * 変換レイアウトマスタのvalue（特殊値指定）のうち、default指定を評価するクラス。
 */
public class EvaluatorDefaultUtil {

  /**
   * default指定を評価する。
   *
   * @param itemValue 電文から切り出した項目値
   * @param value 特殊値指定（「default:」の後）
   * @param existedFlg 電文タグの有無
   * @return 評価結果
   */
  public static String eval(String itemValue, String value, boolean existedFlg) {

    // 電文タグがある(existedFlg=true)場合は電文から切り出した項目値を使用
    // 電文タグがない(existedFlg=false)場合は設定した"default:"の後の値を使用
    if(existedFlg) {
      return itemValue;
    } else {
      return value;
    }
  }
}
