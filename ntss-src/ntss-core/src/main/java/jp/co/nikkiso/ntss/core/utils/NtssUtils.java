package jp.co.nikkiso.ntss.core.utils;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;

/**
 * FutureNetWeb+ Si の共通関数
 */
public class NtssUtils {

  /**
   * システムが稼働している端末のOSがWindowsか否かを判断する.
   *
   * @return true : Windows
   *         false  : Windows以外
   */
  public static boolean isWindows() {
    return System.getProperty("os.name").indexOf("Windows") >= 0;
  }

  /**
   * 入力した文字列を、DB6と同様の暗号化を行い返す.
   * @param input 暗号化する文字列
   * @return 暗号化された文字列
   */
  public static String Encrypt(String input) {
    String output = "";
    String strBits = TextToBits(input);
    strBits = strBits.substring(1) + strBits.substring(0,1);
    output = BitsToHexs(strBits);
    return output;
  }

  /**
   * 入力した暗号文字列を、DB6と同様の複合化を行い返す.
   * @param input 複合化する文字列
   * @return 複合化された文字列
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static String Decrypt(String input) throws UnsupportedEncodingException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    String output = "";
    String strBits = HexsToBits(input);
    strBits = strBits.substring(strBits.length() - 1, strBits.length()) + strBits.substring(0, strBits.length() - 1);
    output = BitsToText(strBits);
    return output;
  }

  private static String TextToBits(String input) {
    String output = "";
    byte[] bytes = input.getBytes();
    StringBuilder binary = new StringBuilder();

    for (byte b : bytes) {
      int val = b;
      for (int i = 0; i < 8; i++) {
        binary.append((val & 128) == 0 ? 0 : 1);
        val <<= 1;
      }
    }
    output = binary.toString();
    return output;
  }

  private static String BitsToHexs(String input) {
    String output = "";
    int loopCnt = input.length()/4;
    int startIndex = 0;

    for(int i = 1; i <= loopCnt; i++) {
      String strBit = input.substring(startIndex, startIndex + 4);
      int decimal  = Integer.parseInt(strBit,2);
      output = output + Integer.toString(decimal,16);
      startIndex += 4;
    }
    return output;
  }

  private static Map<String, String> digiMap = new HashMap<>();
  static {
    digiMap.put("0", "0000");
    digiMap.put("1", "0001");
    digiMap.put("2", "0010");
    digiMap.put("3", "0011");
    digiMap.put("4", "0100");
    digiMap.put("5", "0101");
    digiMap.put("6", "0110");
    digiMap.put("7", "0111");
    digiMap.put("8", "1000");
    digiMap.put("9", "1001");
    digiMap.put("a", "1010");
    digiMap.put("b", "1011");
    digiMap.put("c", "1100");
    digiMap.put("d", "1101");
    digiMap.put("e", "1110");
    digiMap.put("f", "1111");
  }

  private static String HexsToBits(String input) {
    char[] hex = input.toCharArray();
    String binaryString = "";
    for (char h : hex) {
      binaryString = binaryString + digiMap.get(String.valueOf(h));
    }
    return binaryString;
  }
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  private static String BitsToText(String input) throws UnsupportedEncodingException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    String output = "";
    String[] ss =  input.split("(?<=\\G.{8})");

    byte[] bytes = new byte[ input.length()/8];
    for ( int i = 0; i < ss.length; i++ ) {
      int a =  Integer.parseInt(ss[i], 2);
      byte[] ba = ByteBuffer.allocate(4).putInt(a).array();
      bytes[i] = ba[3];
    }

    try {
      output = new String(bytes, 0, bytes.length, "UTF-8");
    } catch (UnsupportedEncodingException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      throw e;
    }
    return output;
  }
 // add #6775 ログの抽出が正しく行われない 鄭爽 start
  /**
   * 入力した文字列を、DB6と同様の暗号化を行い返す.
   * @param input 暗号化する文字列
   * @param lastBit last bit
   * @return 暗号化された文字列
   */
  public static String EncryptKeySearch(String input, String lastBit) {
    String output = "";
    String strBits = TextToBits(input);
    strBits = strBits.substring(1) + lastBit;
    output = BitsToHexs(strBits);
    return output;
  }
  // add #6775 ログの抽出が正しく行われない 鄭爽 end

  /**
   * 詳細な例外スタック情報を出力
   * @param e
   * @return
   */
  public static String ExcetionStackTraceToString(Exception e) {
    StringBuilder strbuff = new StringBuilder();
    for (StackTraceElement stet : e.getStackTrace()) {
      strbuff.append(stet + "\n");
    }
    return e.getClass().getName() + ":" + e.getMessage() + ":" + strbuff.toString();
  }
}
