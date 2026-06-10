package jp.co.nikkiso.ntss.api.service.utils;
// add 10550 患者別の検査結果一覧帳票を出力できるようにする gjn start
import java.util.Comparator;

public class CustomComparator implements Comparator<String> {

  @Override
  public int compare(String s1, String s2) {
    String date1 = getDatePart(s1);
    String date2 = getDatePart(s2);

    int dateComparison = date1.compareTo(date2);

    if (dateComparison == 0) {
      String suffix1 = getSuffix(s1);
      String suffix2 = getSuffix(s2);

      Integer numSuffix1 = tryParseInt(suffix1);
      Integer numSuffix2 = tryParseInt(suffix2);

      if (numSuffix1 != null && numSuffix2 != null) {
        return numSuffix1.compareTo(numSuffix2);
      } else if (numSuffix1 != null) {
        return -1; // 文字よりも数字を優先
      } else if (numSuffix2 != null) {
        return 1; // 文字よりも数字を優先
      }
      return suffix1.compareTo(suffix2);
    }
    return dateComparison;
  }

  private String getDatePart(String dateWithSuffix) {
    int commaIndex = dateWithSuffix.indexOf(',');
    if (commaIndex != -1) {
      return dateWithSuffix.substring(0, commaIndex);
    } else {
      return dateWithSuffix;
    }
  }

  private String getSuffix(String dateWithSuffix) {
    int commaIndex = dateWithSuffix.indexOf(',');
    if (commaIndex != -1 && commaIndex + 1 < dateWithSuffix.length()) {
      return dateWithSuffix.substring(commaIndex);
    }
    return "";
  }

  private Integer tryParseInt(String str) {
    try {
      return Integer.parseInt(str);
    } catch (NumberFormatException e) {
      return null;
    }
  }
}
// add 10550 患者別の検査結果一覧帳票を出力できるようにする gjn end
