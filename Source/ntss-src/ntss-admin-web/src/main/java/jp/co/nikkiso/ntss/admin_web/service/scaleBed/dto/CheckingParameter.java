package jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto;

import jp.co.nikkiso.ntss.admin_web.service.scaleBed.constant.CheckingParameterCode;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class CheckingParameter {

  /**
   * 患者身長
   */
  private BigDecimal patHeight;

  /**
   * DW
   */
  private BigDecimal dw;

  /**
   * 目標体重
   */
  private BigDecimal targetWeight;

  /**
   * 測定値
   */
  private BigDecimal measureValue;
  /**
   * 前体重
   */
  private BigDecimal beforeWeight;
  /**
   * 後体重
   */
  private BigDecimal afterWeight;
  /**
   * 前回後体重
   */
  private BigDecimal lastAfterWeight;

  /**
   * 目標除水量
   */
  private BigDecimal targetOffWater;
  /**
   * 除水制限値
   */
  private BigDecimal limitOffWater;
  /**
   * 風袋
   */
  private BigDecimal tare;
  /**
   * 風袋JSON文字列
   */
  private String tareJsonStr;

  /**
   * 除水補正
   */
  private BigDecimal offWater;

  /**
   * 除水補正JSON文字列
   */
  private String offWaterJsonStr;
  /**
   * 除水実績
   */
  private BigDecimal resultOffWater;

  /**
   * 次回透析予定１
   */
  private String nextDate1;
  /**
   * 次回透析予定２
   */
  private String nextDate2;
  /**
   * BMI
   */
  private String bmi;
  /**
   * I-HDF引き残し量
   */
  private String pg;
  /**
   * 車いす
   */
  private BigDecimal wheelChair;
  /**
   * 前体重許容上限
   */
  private BigDecimal beforeWeightMax;
  /**
   * 前体重許容下限
   */
  private BigDecimal beforeWeightMin;

  /**
   * コードから値を取得（文字列 or null）
   * @param checkingParameterCode 置換コード
   * @return 文字列に変換した値、もしくはnull
   */
  public String getByCode(String checkingParameterCode) {
    if (checkingParameterCode == null) {
      return null;
    } else if (checkingParameterCode.equals(CheckingParameterCode.DW)) {
      return dw == null ? null : String.valueOf(dw);
    } else if (checkingParameterCode.equals(CheckingParameterCode.TARGET_WEIGHT)) {
      return targetWeight == null ? null : String.valueOf(targetWeight);
    } else if (checkingParameterCode.equals(CheckingParameterCode.MEASURE_VALUE)) {
      return measureValue == null ? null : String.valueOf(measureValue);
    } else if (checkingParameterCode.equals(CheckingParameterCode.BEFORE_WEIGHT)) {
      return beforeWeight == null ? null : String.valueOf(beforeWeight);
    } else if (checkingParameterCode.equals(CheckingParameterCode.AFTER_WEIGHT)) {
      return afterWeight == null ? null : String.valueOf(afterWeight);
    } else if (checkingParameterCode.equals(CheckingParameterCode.LAST_AFTER_WEIGHT)) {
      return lastAfterWeight == null ? null : String.valueOf(lastAfterWeight);
    } else if (checkingParameterCode.equals(CheckingParameterCode.TARGET_OFF_WATER)) {
      return targetOffWater == null ? null : String.valueOf(targetOffWater);
    } else if (checkingParameterCode.equals(CheckingParameterCode.LIMIT_OFF_WATER)) {
      return limitOffWater == null ? null : String.valueOf(limitOffWater);
    } else if (checkingParameterCode.equals(CheckingParameterCode.TARE)) {
      return tare == null ? null : String.valueOf(tare);
    } else if (checkingParameterCode.equals(CheckingParameterCode.OFF_WATER)) {
      return offWater == null ? null : String.valueOf(offWater);
    } else if (checkingParameterCode.equals(CheckingParameterCode.RESULT_OFF_WATER)) {
      return resultOffWater == null ? null : String.valueOf(resultOffWater);
    } else if (checkingParameterCode.equals(CheckingParameterCode.NEXT_DATE_1)) {
      return nextDate1;
    } else if (checkingParameterCode.equals(CheckingParameterCode.NEXT_DATE_2)) {
      return nextDate2;
    } else if (checkingParameterCode.equals(CheckingParameterCode.BMI)) {
      return bmi;
    } else if (checkingParameterCode.equals(CheckingParameterCode.PG)) {
      return pg;
    } else if (checkingParameterCode.equals(CheckingParameterCode.WHEEL_CHAIR)) {
      return wheelChair == null ? null : String.valueOf(wheelChair);
    } else if (checkingParameterCode.equals(CheckingParameterCode.BEFORE_WEIGHT_MAX)) {
      return beforeWeightMax == null ? null : String.valueOf(beforeWeightMax);
    } else if (checkingParameterCode.equals(CheckingParameterCode.BEFORE_WEIGHT_MIN)) {
      return beforeWeightMin == null ? null : String.valueOf(beforeWeightMin);
    }
    return null;
  }

  private PrintParameter printParameter;

  @Getter
  @Setter
  public static class PrintParameter {
    private String bedName;
    private String hospPatId;
    private String patName;
    private String facilityName;
    private String dialysisTime;
    private Timestamp rstStartDate;
    private Timestamp rstEndDate;
    private Timestamp nextSchedule;
  }
}
