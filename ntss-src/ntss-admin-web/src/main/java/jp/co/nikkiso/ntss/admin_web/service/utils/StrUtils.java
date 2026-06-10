package jp.co.nikkiso.ntss.admin_web.service.utils;

import org.json.JSONObject;
import org.springframework.util.StringUtils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class StrUtils {
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

  public static String getStrFromJSONObject(JSONObject jsonObject,String key){
    Object obj = jsonObject.get(key);
    if(obj == null){
      return "";
    }
    String str = String.valueOf(obj);
    if(StringUtils.isEmpty(str)){
      return "";
    }
    return str;
  }

  /* add by chamaojia 2024-04-08 [10473] half angle full angle conversion method added --start */
  /**
   * to half width (numbers, letters, punctuation marks)
   */
  public static String toHalfWidth(String input) {
    if (input == null) {
      return null;
    }
    char[] c = input.toCharArray();
    for (int i = 0; i < c.length; i++) {
      if (c[i] >= 65281 && c[i] <= 65374) {
        c[i] = (char)(c[i] - 65248);
      } else if (c[i] == 12288) {
        c[i] = (char)32;
      }
    }
    return new String(c);
  }

  /**
   * to full width (numbers, letters, punctuation marks)
   */
  public static String toFullWidth(String input) {
    StringBuilder output = new StringBuilder();
    for (char c : input.toCharArray()) {
      if (c >= 0 && c <= 127) {
        // convert half width ASCII code to corresponding full width characters
        output.append((char) (c + 0xFEE0));
      } else {
        // non ASCII characters remain unchanged
        output.append(c);
      }
    }
    return output.toString();
  }
  /* add by chamaojia 2024-04-08 [10473] half angle full angle conversion method added --end */
}
