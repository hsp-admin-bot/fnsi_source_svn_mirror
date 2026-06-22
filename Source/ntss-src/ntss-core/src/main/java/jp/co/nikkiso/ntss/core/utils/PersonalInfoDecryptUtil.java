package jp.co.nikkiso.ntss.core.utils;
//add 10389 患者リストのソートが遅い gjn start
import java.nio.charset.StandardCharsets;

/**
 * 元のpostgre暗号解読関数（personal _ info _ decrypt，personal _ info _ encrypt）をjavaツールクラスに変換
 */
public class PersonalInfoDecryptUtil {

  /**
   * シフト復号 （personal_info_decrypt）
   *
   * @param hexStr
   * @return
   */
  public static String decrypt(String hexStr) {
    byte[] decryptedData = null;
    String bitStr;
    int loopCnt;
    int startIndex;

    if (hexStr != null && !hexStr.isEmpty()) {
      // 16進文字列をバイト配列に変換
      byte[] bytes = hexStringToByteArray(hexStr);
      // ビット文字列へのバイト配列の変換
      bitStr = bytesToBitString(bytes);
      // ビット文字列ループを1ビット右にシフト
      bitStr = bitStr.substring(bitStr.length() - 1) + bitStr.substring(0, bitStr.length() - 1);
      // サイクル数の計算
      loopCnt = bitStr.length() / 8;
      if (loopCnt < 1) {
        return null;
      }
      startIndex = 0;
      decryptedData = new byte[loopCnt];
      for (int i = 0; i < loopCnt; i++) {
        String substring = bitStr.substring(startIndex, startIndex + 8);
        int intValue = Integer.parseInt(substring, 2);
        decryptedData[i] = (byte) intValue;
        startIndex += 8;
      }
    }
    if (decryptedData != null) {
      String decryptedString = new String(decryptedData, StandardCharsets.UTF_8);
      return decryptedString;
    }
    return null;
  }

  /**
   * 16進文字列をバイト配列に変換
   *
   * @param hexStr
   * @return
   */
  private static byte[] hexStringToByteArray(String hexStr) {
    int len = hexStr.length();
    byte[] data = new byte[len / 2];
    for (int i = 0; i < len; i += 2) {
      data[i / 2] = (byte) ((Character.digit(hexStr.charAt(i), 16) << 4)
        + Character.digit(hexStr.charAt(i + 1), 16));
    }
    return data;
  }

  /**
   * シフト暗号化（personal_info_encrypt）
   *
   * @param indata
   * @return
   */
  public static String encrypt(String indata) {
    String hexStr = null;
    String bitStr;
    int loopCnt;
    int startIndex;

    if (indata != null && !indata.isEmpty()) {
      // 入力テキストをバイト配列に変換
      byte[] bytes = indata.getBytes();
      // ビット文字列へのバイト配列の変換
      bitStr = bytesToBitString(bytes);
      // ビット文字列のループを左に1ビットシフト
      bitStr = bitStr.substring(1) + bitStr.substring(0, 1);
      // サイクル数の計算
      loopCnt = bitStr.length() / 4;
      if (loopCnt < 1) {
        return null;
      }
      startIndex = 0;
      hexStr = "";
      for (int i = 0; i < loopCnt; i++) {
        String substring = bitStr.substring(startIndex, startIndex + 4);
        int intValue = Integer.parseInt(substring, 2);
        hexStr += Integer.toHexString(intValue);
        startIndex += 4;
      }
    }
    return hexStr;
  }

  /**
   * バイトによるビット文字の変換
   *
   * @param bytes
   * @return
   */
  private static String bytesToBitString(byte[] bytes) {
    StringBuilder bitString = new StringBuilder();
    for (byte b : bytes) {
      // 各バイトを8ビット文字列に変換
      String binaryString = String.format("%8s", Integer.toBinaryString(b & 0xFF)).replace(' ', '0');
      //分割ビット文字列
      bitString.append(binaryString);
    }
    return bitString.toString();
  }
}
//add 10389 患者リストのソートが遅い gjn end
