package jp.co.nikkiso.ntss.monitoring.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Utilities {
  /**
   * 数値チェック（整数のみ）
   * @param val
   * @return
   */
  public static boolean isNumber(String val) {
    String regex = "\\A[-]?[0-9]+\\z";
    Pattern p = Pattern.compile(regex);
    Matcher m1 = p.matcher(val);
    return m1.find();
  }
  
}
