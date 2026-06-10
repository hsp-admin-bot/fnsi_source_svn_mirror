package jp.co.nikkiso.ntss.coop_api.utils;

import java.util.List;

public class JournalConvertUtil {

  public static String ctlNoListToString(List<Long> ctlNoList) {
    String result = "";
    StringBuilder tempSB = new StringBuilder("");

    try {
      for(Long ctlNo : ctlNoList) {
        tempSB = tempSB.append(ctlNo.toString() + ",");
      }
      result = tempSB.toString().substring(0, tempSB.lastIndexOf(","));
    } catch (Exception ex) {
//      e.printStackTrace();
      throw ex;
    }

    return result;
  }
}
