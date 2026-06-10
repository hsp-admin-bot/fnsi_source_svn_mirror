package jp.co.nikkiso.ntss.core.utils;

public class NumberFormatUtils {

  /* modify by chamaojia 2024-05-20 [10196] 小数点を処理するための共通メソッドの追加 --start */
  /**
   * 小数点以下の処理
   * @param targetValue  数量
   * @param decPoint  指定された小数点桁数
   * @return  数量(小数点桁数制御後)
   */
  public static String getValueToDecimalProcessed(String targetValue, Integer decPoint) {
    if (targetValue == null || "".equals(targetValue) || decPoint == null) {
      return targetValue;
    }

    // 小数点の位置
    int decimalPointPos = targetValue.indexOf(".");
    // 小数点以下の長さ
    int decimalLength = decimalPointPos == -1 ? 0 : targetValue.substring(decimalPointPos + 1).length();

    // 小数点長の判定
    if (decimalLength == decPoint) {
      // 小数点以下の桁数と設定値が等しい場合は、そのまま元の値に戻ります
      return targetValue;
    } else if (decimalLength > decPoint) {
      // 最小の長さ
      int minLength = targetValue.substring(0, decimalPointPos + 1 + decPoint).length();
      // 一番後ろから、連続して0の個数
      int zeroCount = 0;
      // 0以外の場所、または設定された小数点以下の桁数の場所で停止するには、後から前へ検索
      for (int i = targetValue.length() - 1; i >= minLength; i--) {
        if ("0".equals(targetValue.substring(i, i + 1))) {
          zeroCount++;
        } else {
          break;
        }
      }

      if (decPoint == 0 && decimalLength == zeroCount) {
        // 小数点がない場合は小数点を削除する必要があります
        return targetValue.substring(0, targetValue.length() - zeroCount - 1);
      } else {
        return targetValue.substring(0, targetValue.length() - zeroCount);
      }
    } else {
      // 小数点以下の桁数が設定値より小さい場合は、桁数を補う必要があります
      StringBuilder value = new StringBuilder(targetValue);
      for(int i = decimalLength; i < decPoint; i++) {
        if (i == 0) {
          // 補足する必要がある小数点はありません
          value.append(".");
        }
        value.append("0");
      }
      return value.toString();
    }
  }
  /* modify by chamaojia 2024-05-20 [10196] 小数点を処理するための共通メソッドの追加 --end */
}
