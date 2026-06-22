package jp.co.nikkiso.ntss.coop_api.utils;

/**
 * 変換レイアウトマスタのvalue（特殊値指定）のうち、const指定を評価するクラス。
 */
public class EvaluatorConstUtil {

  /**
   * const指定を評価する。
   *
   * @param value 特殊値指定（「const:」の後）
   * @return 評価結果
   */
  public static String eval(String value) {

    // ";"の後の値が引数として渡されるので、そのまま返すだけで良い。
    // 電文から切り出した項目値は無視し、使用しない。
    return value;
  }
}
