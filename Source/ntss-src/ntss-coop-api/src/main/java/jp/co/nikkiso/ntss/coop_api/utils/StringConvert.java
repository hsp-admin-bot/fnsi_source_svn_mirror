package jp.co.nikkiso.ntss.coop_api.utils;

public class StringConvert {

  /**
   * 半角英数を全角に変換する
   * @param input String.
   * @return 全角文字列
   */
  public static String ToSBC(String input) {
    char c[] = input.toCharArray();
    for (int i = 0; i < c.length; i++) {
      if (c[i] == ' ') {
        c[i] = '\u3000';
      } else if (c[i] < '\177') {
        c[i] = (char) (c[i] + 65248);
      }
    }
    return new String(c);
  }

  /**
   * 全角英数を半角に変換する
   * @param input String.
   * @return 半角文字列
   */
  public static String ToDBC(String input) {
    char c[] = input.toCharArray();
    for (int i = 0; i < c.length; i++) {
      if (c[i] == '\u3000') {
        c[i] = ' ';
      } else if (c[i] > '\uFF00' && c[i] < '\uFF5F') {
        c[i] = (char) (c[i] - 65248);
      }
    }
    String returnString = new String(c);
    return returnString;
  }
}
