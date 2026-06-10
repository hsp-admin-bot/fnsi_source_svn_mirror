package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.Arrays;

public class ByteUtil {

  /**
   * 文字列の先頭から2バイト分に相当する文字列を取得する。
   *
   * @param s 文字列（半角英数記号）
   * @return 先頭2バイト分の文字列。
   */
  public static String getUpper2Bytes(String s) {
    if (s == null) return "";
    byte[] insNoBytes = s.getBytes();
    byte[] insNoBytes2 = Arrays.copyOfRange(insNoBytes, 0, 2);
    return new String(insNoBytes2);
  }
}
