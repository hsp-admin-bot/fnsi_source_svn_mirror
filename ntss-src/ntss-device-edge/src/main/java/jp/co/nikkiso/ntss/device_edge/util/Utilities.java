package jp.co.nikkiso.ntss.device_edge.util;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import org.springframework.util.StringUtils;

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
  /**
   * 年齢を求める(時刻基準)
   * @param birthDay
   * @param now
   * @return
   */
  public static int calcAge(Date birthDay, Date now) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    return (Integer.parseInt(sdf.format(now)) - Integer.parseInt(sdf.format(birthDay))) / 10000;
  }

  /**
   * 年齢を求める(時刻基準)
   * @param birthDay 誕生日を表す日付文字列(YYYYMMDD)
   * @param now
   * @return 日付文字列のパースに失敗した際は0を返す。
   */
  public static int calcAge(String birthDay, Date now) {
    if (birthDay == null) return 0;

    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    // 日付文字列のパース
    int rtn;
    try {
      Date birthDay_Date = sdf.parse(birthDay);
      rtn = (Integer.parseInt(sdf.format(now)) - Integer.parseInt(sdf.format(birthDay_Date))) / 10000;
    } catch (ParseException e) {
      rtn = 0;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
    }

    return rtn;
  }

  /**
   * 左詰め0埋め固定長文字列を返す
   * @param 文字列
   * @param 戻り文字列の長さ
   */
  public static String getZeroRightPaddingString(String string, int length) {
    for (int looper = 0; looper < length; looper++) {
      string = "0" + string;
    }
    String rtn = string.substring(string.length() - length, string.length());
    return rtn;
  }

  /**
   * (ord_mainの穿刺者・返血者・担当者用)JSON文字列からユーザーのコードを取得する。
   * コード1を優先的に返し、コード1に値がない場合コード2の値を返します。
   * @param jsonString
   * @return
   */
  public static Long getUserIdFromJsonString(String jsonString) {
    Long userId;
    if (StringUtils.hasText(jsonString)) {
      //      userId = 0L;

      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode = mapper.readTree(jsonString);

        userId = jsonNode.hasNonNull("user_id_1") ? jsonNode.get("user_id_1").asLong() : 0L;

        if (userId == 0L) {
          userId = jsonNode.hasNonNull("user_id_2") ? jsonNode.get("user_id_2").asLong() : 0L;
        }

      } catch (Exception e) {
        userId = null;
      }
    } else {
      userId = null;
    }
    return userId;
  }

  /**
   * 血液型(ABO)の値を血液型名称に変換する。
   * 0：不明、1：A型、2：B型、3：O型、4：AB型
   * 引数が0～4以外の場合、空文字列を返す。
   * @param typeValue
   * @return
   */
  public static String bloodTypeValueToName_ABO(Integer typeValue) {
    String rtn = "";

    if (Objects.isNull(typeValue) || typeValue == 0) {
      rtn = "不明";
    } else if (typeValue == 1) {
      rtn = "A型";
    } else if (typeValue == 2) {
      rtn = "B型";
    } else if (typeValue == 3) {
      rtn = "O型";
    } else if (typeValue == 4) {
      rtn = "AB型";
    }

    return rtn;
  }

  /**
   * 血液型(RH)の値を血液型名称に変換する。
   * 0：不明、1：Rh＋、2：Rh－
   * 引数が0～2以外の場合、空文字列を返す。
   * @param typeValue
   * @return
   */
  public static String bloodTypeValueToName_RH(Integer typeValue) {
    String rtn = "";

    if (Objects.isNull(typeValue) || typeValue == 0) {
      rtn = "不明";
    } else if (typeValue == 1) {
      rtn = "Rh＋";
    } else if (typeValue == 2) {
      rtn = "Rh－";
    }

    return rtn;
  }

  /**
   * ISO8601形式の日付文字列からDateを取得する。
   * @param dateString ISO8601形式の日付文字列
   * @return Date
   */
  public static Date dateStringToDate_iso8601(String dateString) {
    Date date;
    if (dateString != null && !Objects.equals(dateString, "null")) {
      // ISO8601形式のフォーマット
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
      try {
        date = sdf.parse(dateString);
      } catch (ParseException e) {
        // タイムゾーンにコロンがないフォーマットでリトライ
        SimpleDateFormat sdf_noColonInTimeZone = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        try {
          date = sdf_noColonInTimeZone.parse(dateString);
        } catch (ParseException e2) {
          // ミリ秒なしフォーマットでリトライ
          SimpleDateFormat sdf_noMiliSec = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX");
          try {
            date = sdf_noMiliSec.parse(dateString);
          } catch (ParseException e1) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//            e1.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
            date = null;
          }
        }
      }
    } else {
      // 引数がnullのときnullを返す
      date = null;
    }

    return date;
  }

  /**
   * DateからISO8601形式の日付文字列を取得する。
   * @param date
   * @return ISO8601形式の日付文字列
   */
  public static String getDateString_iso8601(Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String dateString = sdf.format(date);
    return dateString;
  }

  /**
   * 治療モードコードからモード名称を取得する。
   * @param treatModeCd
   * @return 治療モード名称
   */
  public static String treatCdToName(Integer treatModeCd) {
    String treatModeName = "";
    if (Objects.isNull(treatModeCd)) {
      return treatModeName;
    }
    switch (treatModeCd) {
    case -1:
      treatModeName = "不明";
      break;
    case 0:
      treatModeName = "HD";
      break;
    case 1:
      treatModeName = "ECUM";
      break;
    case 2:
      treatModeName = "HDF";
      break;
    case 3:
      treatModeName = "HF";
      break;
    case 4:
      treatModeName = "HD+補液";
      break;
    case 5:
      treatModeName = "ECUM+補液";
      break;
    case 6:
      treatModeName = "AFBF";
      break;
    case 7:
      treatModeName = "OHDF";
      break;
    case 8:
      treatModeName = "OHF";
      break;
    case 9:
      treatModeName = "特殊浄化";
      break;
    case 10:
      treatModeName = "I-HDF";
      break;
    default:
      treatModeName = "";
    }
    return treatModeName;
  }

  /**
   * 性別コードから性別名称を取得します。
   * 性別コード：0：不明、1：男性、2：女性
   * @param sexCd 性別コード
   * @return 性別名称
   */
  public static String sexCdToName(Integer sexCd) {
    String sexName = "";
    // 性別
    if (Objects.isNull(sexCd) || sexCd == 0) {
      sexName = "不明";
    } else if (sexCd == 1) {
      sexName = "男性";
    } else if (sexCd == 2) {
      sexName = "女性";
    }
    return sexName;
  }

  /**
   * 入外区分コードから入外区分名称を取得します。
   * 入外区分コード：0'：外来、'1'：入院、'2'：死亡、'3'：-(不在)
   * @param inOutCd 入外区分コード
   * @return 入外区分名称
   */
  public static String inOutCdToName(Integer inOutCd) {
    String inOutName = "";
    if (Objects.equals(inOutCd, 0)) {
      inOutName = "外来";
    }
    if (Objects.equals(inOutCd, 1)) {
      inOutName = "入院";
    }
    if (Objects.equals(inOutCd, 2)) {
      inOutName = "死亡";
    }
    if (Objects.equals(inOutCd, 3)) {
      // #9147 2024.01.10 chg 次患者整形 「3:-(不在)」は全角ハイフン TDC山崎 start
      //inOutName = "-(不在)";
      inOutName = "－";
      // #9147 2024.01.10 chg 次患者整形 「3:-(不在)」は全角ハイフン TDC山崎 end
    }
    return inOutName;
  }

  /**
   * JSONノード内の発生日が最新であるノードのIndexを返す
   * @param nodeList
   * @return
   * @throws ParseException
   */
  public static int getLatestOccurDateIndex(List<JsonNode> nodeList) {
    //    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
    int maxDateIdx = 0;
    Date maxOccurDate = Utilities.dateStringToDate_iso8601("1970-01-01T00:00:00+09:00");
    //    try {
    //      maxOccurDate = sdf.parse("19700101000000");
    // 発生日が最新のノードを取り出す
    for (int intlop = 0; intlop < nodeList.size(); intlop++) {
      JsonNode bufNode = nodeList.get(intlop);
      JsonNode occurDate_node = bufNode.get("occur_date");
      String occurDate_str = occurDate_node.asText();
      Date occurDate = Utilities.dateStringToDate_iso8601(occurDate_str);

      if (occurDate.after(maxOccurDate)) {
        maxOccurDate = occurDate;
        maxDateIdx = intlop;
      }
    }
    //    } catch (ParseException e) {
    //      e.printStackTrace();
    //    }

    return maxDateIdx;
  }

  /**
   * JSONノード内の管理番号が最大であるノードのIndexを返す
   * @param nodeList
   * @return
   * @throws ParseException
   */
  public static int getLatestCtlNoIndex(JsonNode nodeList) {
    int maxCtlNoIdx = 0;
    int maxCtlNo = 0;
    // 発生日が最新のノードを取り出す
    for (int intlop = 0; intlop < nodeList.size(); intlop++) {
      JsonNode bufNode = nodeList.get(intlop);
      JsonNode ctlNo_node = bufNode.get("ctl_no");
      int ctlNo = ctlNo_node.asInt();

      if (ctlNo > maxCtlNo) {
        maxCtlNo = ctlNo;
        maxCtlNoIdx = intlop;
      }
    }

    return maxCtlNoIdx;
  }


  /**
   * BigDecimal型変換
   * @param val
   * @return null：変換失敗/else：BigDecimal型値
   */
  public static BigDecimal toBigDecimal(String val) {
    BigDecimal ret = null;
    try {
      ret = new BigDecimal(val);
    } catch ( Exception e) {
    }
    return ret;
  }
  /**
   * 指定書式で数字を整形する
   * @param val 整形前文字(数字)
   * @param decimalPoint 小数点以下桁数
   * @return 整形された文字列
   */
  public static String getFormattedNumber( String val, Integer decimalPoint) {
    String ret = val;

    // 表示形式整形
    BigDecimal dec = Utilities.toBigDecimal(val);
    if( dec != null && decimalPoint != null ) {
      if( 0 < decimalPoint ) {
        NumberFormat nf = NumberFormat.getNumberInstance();
        // 少数桁数を設定
        nf.setMaximumFractionDigits(decimalPoint);
        nf.setMinimumFractionDigits(decimalPoint);
        // 指定桁数以下切り捨て
        ret = nf.format(dec.setScale(decimalPoint, BigDecimal.ROUND_DOWN));
      }
    }

    return ret;
  }
  /**
   * 積算分をHH:MM形式文字列に変換する
   * @param Time 経過分
   * @return
   */
  public static String AccumulatedMinutesToHHMM( Long time ) {
    String ret = "";
    try {
      if( time != null ) {
        Long absTime = Math.abs(time);
        ret = String.format("%d:%02d", absTime / 60,  absTime % 60 );
        if ( time < 0 ) {
          ret = "-" + ret;
        }
      }
    } catch ( Exception e) {
    }
    return ret;
  }

  /**
   * jsonNodeからint値を取得
   * @param obj node
   * @param nullValue null時の値
   * @return
   */
  public static Integer getIntJsonNode(JsonNode obj, Integer defaultValue) {
    if (Objects.isNull(obj)) {
      return defaultValue;
    }
    try {
      return obj.asInt();
    } catch (Exception e) {
      return defaultValue;
    }
  }

  /**
   * jsonNodeからString値を取得
   * @param obj node
   * @param nullValue null時の値
   * @return
   */
  public static String getTextJsonNode(JsonNode obj, String defaultValue) {
    if (Objects.isNull(obj)) {
      return defaultValue;
    }
    try {
      return obj.asText(defaultValue);
    } catch (Exception e) {
      return defaultValue;
    }
  }
}

