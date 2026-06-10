package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * 配管テスト結果のJSON格納クラス.
 */
@Data
public class PipingDto {

  /**
   * 配管テスト結果.
   */
  @JsonProperty("6")
  private String result;
  
  /**
   * 給水圧.
   */
  @JsonProperty("7")
  private String supplyPressure;
  
  /**
   * 送液圧低.
   */
  @JsonProperty("8")
  private String dialysateFlowPressureLow;
  
  /**
   * 送液圧高.
   */
  @JsonProperty("9")
  private String dialysateFlowPressureHigh;
  
  /**
   * 濃度 セル3.
   */
  @JsonProperty("10")
  private String concentrationCell3;
  
  /**
   * 濃度 セル4.
   */
  @JsonProperty("11")
  private String concentrationCell4;
  
  /**
   * 注水判定時間.
   */
  @JsonProperty("1")
  private String judgementTermInjection;
  
  /**
   * 排液判定時間.
   */
  @JsonProperty("5")
  private String judgementTermDrainage;
  
}
