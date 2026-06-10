package jp.co.nikkiso.ntss.core.utils;

import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import org.json.JSONException;
import org.json.JSONObject;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Map;

public class LiquidCalculateUtils {

  // IHDF 補液量 補液速度 計算
  public static Map<String, String> getIhdfCalculateLiquidAmoutAndSpeed(JSONObject deviceSetInfoObject, String treatTimeStr) {

    Map<String, String> resultMap = new HashMap<>();
    // I-HDF 補液量
    String ihdfLiquidAmoutStr = deviceSetInfoObject.getJSONObject("ihdf").getJSONObject("dev")
      .getJSONObject("A").get("200").toString();

    // I-HDFプログラム使用選択:[使用しない:0,使用する:1]
    String ihdfLiquid = deviceSetInfoObject.getJSONObject("ihdf").getJSONObject("dev")
      .getJSONObject("A").get("432").toString();

    // I-HDF 補液開始時間
    String ihdfLiquidStartTimeStr = deviceSetInfoObject.getJSONObject("ihdf").getJSONObject("dev")
      .getJSONObject("A").get("203").toString();

    // I-HDF 補液周期
    String ihdfLiquidCycleStr = deviceSetInfoObject.getJSONObject("ihdf").getJSONObject("dev")
      .getJSONObject("A").get("202").toString();

    // I-HDF 総補液量上限
    String ihdfLiquidMaxStr = deviceSetInfoObject.getJSONObject("ihdf").getJSONObject("dev")
      .getJSONObject("A").get("205").toString();

    // I-HDF 補液速度
    String ihdfLiquidSpeedStr = deviceSetInfoObject.getJSONObject("ihdf").getJSONObject("dev")
      .getJSONObject("A").get("201").toString();

    BigDecimal ihdfLiquidAmout = org.apache.commons.lang3.StringUtils.isNotEmpty(ihdfLiquidAmoutStr)
      && (TreatmentItemsDef.isInteger(ihdfLiquidAmoutStr) || TreatmentItemsDef.isFloat(ihdfLiquidAmoutStr))
      ? new BigDecimal(ihdfLiquidAmoutStr) : BigDecimal.ZERO;

    BigDecimal ihdfLiquidStartTime = org.apache.commons.lang3.StringUtils.isNotEmpty(ihdfLiquidStartTimeStr)
      && (TreatmentItemsDef.isInteger(ihdfLiquidStartTimeStr) || TreatmentItemsDef.isFloat(ihdfLiquidStartTimeStr))
      ? new BigDecimal(ihdfLiquidStartTimeStr) : BigDecimal.ZERO;

    BigDecimal ihdfLiquidCycle = org.apache.commons.lang3.StringUtils.isNotEmpty(ihdfLiquidCycleStr)
      && (TreatmentItemsDef.isInteger(ihdfLiquidCycleStr) || TreatmentItemsDef.isFloat(ihdfLiquidCycleStr))
      ? new BigDecimal(ihdfLiquidCycleStr) : BigDecimal.ZERO;

    BigDecimal ihdfLiquidMax = org.apache.commons.lang3.StringUtils.isNotEmpty(ihdfLiquidMaxStr)
      && (TreatmentItemsDef.isInteger(ihdfLiquidMaxStr) || TreatmentItemsDef.isFloat(ihdfLiquidMaxStr))
      ? new BigDecimal(ihdfLiquidMaxStr) : BigDecimal.ZERO;

    BigDecimal ihdfLiquidSpeed = org.apache.commons.lang3.StringUtils.isNotEmpty(ihdfLiquidSpeedStr)
      && (TreatmentItemsDef.isFloat(ihdfLiquidSpeedStr) || TreatmentItemsDef.isInteger(ihdfLiquidSpeedStr))
      ? new BigDecimal(ihdfLiquidSpeedStr) : BigDecimal.ZERO;

    BigDecimal ihdfLiquidTotal = new BigDecimal("0");
    BigDecimal frameIhdfLiquidCntMax = new BigDecimal("16");
    BigDecimal sixtyConst = new BigDecimal("60");
    BigDecimal thousandConst = new BigDecimal("1000");

    if (treatTimeStr != null) {
      BigDecimal treatTime = org.apache.commons.lang3.StringUtils.isNotEmpty(treatTimeStr)
        && (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
        ? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;

      // (((予定毎の治療時間-補液開始時間)/補液周期)小数点以下切り捨て)=補液回数
      BigDecimal ihdfLiquidCnt = treatTime.subtract(ihdfLiquidStartTime).divide(ihdfLiquidCycle, BigDecimal.ROUND_DOWN);

      // 使用しない:0,使用する:1
      if ("0".equals(ihdfLiquid)) {
        // 辅液量 * 辅液回数
        ihdfLiquidTotal = ihdfLiquidAmout.multiply(ihdfLiquidCnt);
      }else {
        // 画面上に補液量最大回数は16
        // 補液回数が画面上に補液量の最大回数より小さいか ? 16 : 辅液回数
        ihdfLiquidCnt = ihdfLiquidCnt.compareTo(frameIhdfLiquidCntMax) > 0 ? frameIhdfLiquidCntMax : ihdfLiquidCnt;
        int cnt = ihdfLiquidCnt.intValue() + 435;
        JSONObject dev = deviceSetInfoObject.getJSONObject("ihdf").getJSONObject("dev");
        JSONObject a = dev.getJSONObject("A");

        for (int key = 435; key < cnt; key++) {
          String keyStr = String.valueOf(key); // キーを文字列に変換
          Object value = a.get(keyStr);

          BigDecimal bigDecimalValue;

          if (value instanceof Number) {
            // 値がNumberタイプの場合は、直接変換
            bigDecimalValue = new BigDecimal(((Number) value).toString());
          } else if (value instanceof String) {
            // 値がStringタイプの場合は、BigDecimalに変換
            bigDecimalValue = new BigDecimal((String) value);
          } else {
            throw new JSONException("Unsupported type for conversion to BigDecimal");
          }
          ihdfLiquidTotal = ihdfLiquidTotal.add(bigDecimalValue);
        }
      }
      ihdfLiquidTotal = ihdfLiquidTotal.divide(thousandConst);
      ihdfLiquidTotal = ihdfLiquidTotal.compareTo(ihdfLiquidMax) > 0 ? ihdfLiquidMax : ihdfLiquidTotal;
    }
    ihdfLiquidSpeed = ihdfLiquidSpeed.divide(thousandConst).multiply(sixtyConst);

    resultMap.put("20", ihdfLiquidTotal.setScale(1, RoundingMode.DOWN).toString());
    resultMap.put("24", ihdfLiquidSpeed.setScale(2, RoundingMode.CEILING).toString());
    return resultMap;
  }
}
