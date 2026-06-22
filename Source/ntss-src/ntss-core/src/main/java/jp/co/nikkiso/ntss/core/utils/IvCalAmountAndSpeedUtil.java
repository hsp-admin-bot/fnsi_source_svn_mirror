package jp.co.nikkiso.ntss.core.utils;

import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.AFBF;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.ECUM;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.HD;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.HDF;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.HF;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.IHDF;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.OHDF;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.OHF;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.不明;
import static jp.co.nikkiso.ntss.core.constant.CondIvEnum.特殊浄化;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_BLOOD_FLOW;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_IV_AMOUNT;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_IV_COUNT;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_IV_FLOW_RATE;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_IV_SELECTION;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_IV_TEMPERATURE;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.T_I_START_DATE;

/**
 * @className: IvCalAmountAndSpeedUtil
 * @author: kangjie
 * @date: 2024/09/05 13:59
 * @Version: 1.0
 * @description: 10150_9664
 */
public class IvCalAmountAndSpeedUtil {

  public static final List<Integer> SPECIAL_DEVICE = Arrays.asList(不明.getDeviceMode(), 特殊浄化.getDeviceMode());
  public static final List<Integer> OFF_LINE_DEVICE = Arrays.asList(HDF.getDeviceMode(),
    HF.getDeviceMode(),AFBF.getDeviceMode());
  public static final List<Integer> ON_LINE_DEVICE = Arrays.asList(OHDF.getDeviceMode(),
    OHF.getDeviceMode(),IHDF.getDeviceMode());
  public static final List<Integer> NO_IV = Arrays.asList(HD.getDeviceMode(),ECUM.getDeviceMode());
  public static final List<String> EDIT_KEY_CAL_REPEAT = Arrays.asList(
    T_I_START_DATE.getItemCode(),
    T_I_BLOOD_FLOW.getItemCode(),
    T_I_IV_AMOUNT.getItemCode(),
    T_I_IV_SELECTION.getItemCode(),
    T_I_IV_COUNT.getItemCode(),
    T_I_IV_TEMPERATURE.getItemCode(),
    T_I_IV_FLOW_RATE.getItemCode()
  );

  public static final List<String> OFF_LINE_EDIT_KEY = Arrays.asList(
    T_I_START_DATE.getItemCode(),
    T_I_IV_AMOUNT.getItemCode(),
    T_I_IV_SELECTION.getItemCode(),
    T_I_IV_COUNT.getItemCode(),
    T_I_IV_TEMPERATURE.getItemCode(),
    T_I_IV_FLOW_RATE.getItemCode()
  );

  //  前補液
  public static final String BEFORE_IV = "1";

  /**
  * @Author kangjie
  * @Description
  * @Date 2024/09/05 14:06
  * @Param
   * [indCond（治療時間、血の流れです、補液量です、補液速度です）,
   * patDeviceSetInfo (補液速度算出、補液量算出、補液比率算出、濾過率算出を個人設定します),
   * deviceMode (OHF/OHDF/I-HDF/HDF/HF/AFBF/不明/特殊净化),
   * ordDeviceSetInfo(トラフィックテーブルに保存されたデバイスデータです),
   * bodyDataIndCond(ページ編集項目です)]
  * @return java.util.Map<java.lang.String,java.math.BigDecimal>
  **/
  public static Map<String, String> calIvAmountAndIvSpeed(JSONObject indCond,
                                                          String patDeviceSetInfo, Integer deviceMode) {
    // offLineタイプです，治療時間を編集し,補液速度を算出します
    if (OFF_LINE_DEVICE.contains(deviceMode)) {
      return calByIvSpeedSetting(indCond,patDeviceSetInfo);
    }

    JSONObject patDeviceSetInfoJSON = new JSONObject(patDeviceSetInfo);
    String liquidCalPriority = patDeviceSetInfoJSON.getJSONObject("ope").getJSONObject("dev")
      .getJSONObject("A").get("389").toString();
    return switch (liquidCalPriority) {
      //補液速度を算出します
      case "0" -> calByIvSpeedSetting(indCond, patDeviceSetInfo);
      // 補液量算出します
      case "1" -> calByIVAmountSetting(indCond, patDeviceSetInfo);
      // 補液率を算出します
      case "2" -> calByIvRateSetting(indCond, patDeviceSetInfo);
      // フィルター率を算出しました
      case "3" -> calByIvFlowSetting();
      default -> null;
    };

  }

  /**
  * @Author kangjie
  * @Description  補液速度を算出します
  * @Date 2024/09/05 15:20
  * @Param [indCond]
  * @return java.util.Map<java.lang.String,java.math.BigDecimal>
  **/
  private static Map<String,String> calByIvSpeedSetting(JSONObject indCond,String patDeviceSetInfo) {

    if (indCond.isNull(T_I_START_DATE.getItemCode())
    || JSONObject.NULL.equals(indCond.getJSONObject(T_I_START_DATE.getItemCode()).get("value"))) return null;

    String amountStr = indCond.getJSONObject(T_I_IV_AMOUNT.getItemCode()).get("value").toString();

    if ("-1".equals(amountStr)) {
      return new HashMap<String, String>() {{
        put(T_I_IV_AMOUNT.getItemCode(),
          T_I_IV_AMOUNT.getFormattedValue(new BigDecimal("0")));
        put(T_I_IV_FLOW_RATE.getItemCode(),
          T_I_IV_FLOW_RATE.getFormattedValue(new BigDecimal("0")));
      }};
    }

    JSONObject patDeviceInfoJSON = new JSONObject(patDeviceSetInfo);

    String delayTimeStr = String.valueOf(patDeviceInfoJSON.getJSONObject("ope").getJSONObject("dev")
      .getJSONObject("A").get("398"));

    String treatTimeStr = indCond.getJSONObject(T_I_START_DATE.getItemCode()).get("value").toString();

    BigDecimal ivAmount = StringUtils.isNotEmpty(amountStr) &&
      (TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
      ? new BigDecimal(amountStr) : BigDecimal.ZERO;

    BigDecimal treatTime = StringUtils.isNotEmpty(treatTimeStr) &&
      (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
      ? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;

    BigDecimal delayTime = StringUtils.isNotEmpty(delayTimeStr) &&
      (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
      ? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;
    Map<String,String> resultMap = new HashMap<>();
    resultMap.put(T_I_IV_AMOUNT.getItemCode(),ivAmount.toString());
    if (treatTime.compareTo(delayTime) > 0) {
      BigDecimal speed = ivAmount.multiply(new BigDecimal("60"))
        .divide(treatTime.subtract(delayTime)
          , 2, RoundingMode.CEILING);
      resultMap.put(T_I_IV_FLOW_RATE.getItemCode(),speed.toString());
      return resultMap;
    }
    return resultMap;
  }

  /**
  * @Author kangjie
  * @Description 補液量算出します
  * @Date 2024/09/05 15:58
  * @Param [indCond, patDeviceSetInfo]
  * @return java.util.Map<java.lang.String,java.math.BigDecimal>
  **/
  private static Map<String,String> calByIVAmountSetting(JSONObject indCond,String patDeviceSetInfo) {
    if (indCond.isNull(T_I_IV_FLOW_RATE.getItemCode())
      || JSONObject.NULL.equals(
        indCond.getJSONObject(T_I_IV_FLOW_RATE.getItemCode()).get("value"))
      || indCond.isNull(T_I_START_DATE.getItemCode())
      || JSONObject.NULL.equals(indCond.getJSONObject(T_I_START_DATE.getItemCode()).get("value"))) return null;

    String speedStr = indCond.getJSONObject("24").get("value").toString();
    if ("-1".equals(speedStr)) {
      return new HashMap<String,String>(){{
        put(T_I_IV_AMOUNT.getItemCode(),
          T_I_IV_AMOUNT.getFormattedValue(new BigDecimal("0")));
        put(T_I_IV_FLOW_RATE.getItemCode(),
          T_I_IV_FLOW_RATE.getFormattedValue(new BigDecimal("0")));
      }};
    }
    JSONObject patDeviceSetJSON = new JSONObject(patDeviceSetInfo);

    String delayTimeStr = String.valueOf(patDeviceSetJSON.getJSONObject("ope").getJSONObject("dev")
      .getJSONObject("A").get("398"));

    String treatTimeStr = indCond.getJSONObject(T_I_START_DATE.getItemCode()).get("value").toString();

    BigDecimal speed = StringUtils.isNotEmpty(speedStr)
      && (TreatmentItemsDef.isFloat(speedStr) || TreatmentItemsDef.isInteger(speedStr))
      ? new BigDecimal(speedStr) : BigDecimal.ZERO;

    BigDecimal treatTime = StringUtils.isNotEmpty(treatTimeStr)
      && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
      ? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;

    BigDecimal delayTime = StringUtils.isNotEmpty(delayTimeStr)
      && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
      ? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;
    Map<String,String> resultMap = new HashMap<>();
    resultMap.put(T_I_IV_FLOW_RATE.getItemCode(),speed.toString());
    if (treatTime.compareTo(delayTime)>0) {
      BigDecimal amount = speed.multiply(
        treatTime.subtract(delayTime)).divide(new BigDecimal("60"), 1, RoundingMode.DOWN);

      resultMap.put(T_I_IV_AMOUNT.getItemCode(),amount.toString());
      return resultMap;
    }
    return resultMap;
  }

  /**
  * @Author kangjie
  * @Description 補液率を算出します
  * @Date 2024/09/05 16:44
  * @Param [indCond, patDeviceSetInfo]
  * @return java.util.Map<java.lang.String,java.lang.String>
  **/
  private static Map<String,String> calByIvRateSetting(JSONObject indCond,String patDeviceSetInfo) {

    String beforeIv = indCond.getJSONObject(T_I_IV_SELECTION.getItemCode()).get("value").toString();
    JSONObject patDeviceSetJSON = new JSONObject(patDeviceSetInfo);
    String rateStr = null;
    if (BEFORE_IV.equals(beforeIv)) {
      rateStr = patDeviceSetJSON.getJSONObject("ope").getJSONObject("dev").getJSONObject("A").get("379").toString();
    }else {
      rateStr = patDeviceSetJSON.getJSONObject("ope").getJSONObject("dev").getJSONObject("B").get("39").toString();
    }
    rateStr = StringUtils.isNotEmpty(rateStr)
      && (TreatmentItemsDef.isFloat(rateStr) || TreatmentItemsDef.isInteger(rateStr))
      ? rateStr : "0";
    BigDecimal rate = new BigDecimal(rateStr);
    BigDecimal bloodFlowValue =
      JSONObject.NULL.equals(indCond.getJSONObject(T_I_BLOOD_FLOW.getItemCode()).get("value")) ?BigDecimal.ZERO :
      new BigDecimal(String.valueOf(indCond.getJSONObject(T_I_BLOOD_FLOW.getItemCode()).get("value")));

    BigDecimal speed =  bloodFlowValue.multiply(rate)
      .multiply(new BigDecimal("60")).divide(new BigDecimal("100000"), 2,RoundingMode.CEILING);

    String delayTimeStr = patDeviceSetJSON.getJSONObject("ope").getJSONObject("dev").getJSONObject("A").get("398").toString();

    String treatTimeStr = indCond.getJSONObject(T_I_START_DATE.getItemCode()).get("value").toString();

    BigDecimal delayTime = StringUtils.isNotEmpty(delayTimeStr)
      && (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
      ? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;

    BigDecimal treatTime = StringUtils.isNotEmpty(treatTimeStr)
      && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
      ? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;
    Map<String,String> resultMap = new HashMap<>();
    resultMap.put(T_I_IV_FLOW_RATE.getItemCode(),speed.toString());
    if (treatTime.compareTo(delayTime) > 0) {
      BigDecimal amount = speed.multiply(treatTime.subtract(delayTime))
        .divide(new BigDecimal("60"), 1, RoundingMode.DOWN);
      resultMap.put(T_I_IV_AMOUNT.getItemCode(),amount.toString());
    }
    return resultMap;
  }

  /**
  * @Author kangjie
  * @Description フィルター率を算出しました
  * @Date 2024/09/05 16:45
  * @return java.util.Map<java.lang.String,java.lang.String>
  **/
  private static Map<String,String> calByIvFlowSetting() {
    return new HashMap<>(){{
      put(T_I_IV_AMOUNT.getItemCode(),"-1");
      put(T_I_IV_FLOW_RATE.getItemCode(),"-1");
    }
    };
  }

  /**
  * @Author kangjie
  * @Description
  * @Date 2024/09/06 12:14
  * @Param [json1, json2, params]
  * @return org.json.JSONObject
  **/
  public static JSONObject getCalParam(JSONObject json1, JSONObject json2, String... params) {
    JSONObject result = new JSONObject();
    for (String param : params) {
      if (json1.has(param)) {
        result.put(param, json1.getJSONObject(param));
      } else if (json2.has(param)) {
        result.put(param, json2.getJSONObject(param));
      }
    }
    return result;
  }

  /**
  * @Author kangjie
  * @Description
  * @Date 2024/09/06 12:34
  * @Param [map]
  * @return org.json.JSONObject
  **/
  public static JSONObject getUpdateObject(Map<String,String> map, Long indUserId,
                                           String indUserLastName,String indUserFirstName) {
    JSONObject result = new JSONObject();
    if (map.containsKey(T_I_IV_AMOUNT.getItemCode())){
      JSONObject value = new JSONObject();
      value.put("value",map.get(T_I_IV_AMOUNT.getItemCode()));
      value.put("ind_user_id",indUserId);
      value.put("ind_user_last_name",indUserLastName);
      value.put("ind_user_first_name",indUserFirstName);
      result.put(T_I_IV_AMOUNT.getItemCode(),value);

    }
    if (map.containsKey(T_I_IV_FLOW_RATE.getItemCode())){
      JSONObject value = new JSONObject();
      value.put("value",map.get(T_I_IV_FLOW_RATE.getItemCode()));
      value.put("ind_user_id",indUserId);
      value.put("ind_user_last_name",indUserLastName);
      value.put("ind_user_first_name",indUserFirstName);
      result.put(T_I_IV_FLOW_RATE.getItemCode(),value);
    }
    return result;
  }
}
