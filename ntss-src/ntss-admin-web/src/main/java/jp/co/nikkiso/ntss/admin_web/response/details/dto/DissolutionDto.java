package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * 溶解記録結果のJSON格納クラス.
 */
@Data
public class DissolutionDto {
  
  /**
   * 曜日.
   */
  @JsonProperty("3")
  private String dayOfWeek;
  
  /**
   * 溶解回数.
   */
  @JsonProperty("5")
  private String dissolutionCnt;
  
  /**
   * B原液溶解時間.
   */
  @JsonProperty("6")
  private String dissolutionTimeB;
  
  /**
   * A原液溶解時間.
   */
  @JsonProperty("7")
  private String dissolutionTimeA;
  
  /**
   * B原液濃度.
   */
  @JsonProperty("8")
  private String concentrationB;
  
  /**
   * A原液濃度.
   */
  @JsonProperty("9")
  private String concentrationA;
  
  /**
   * B原液温度.
   */
  @JsonProperty("10")
  private String temperatureB;
  
  /**
   * A原液温度.
   */
  @JsonProperty("11")
  private String temperatureA;
  
  /**
   * B原液溶解判定.
   */
  @JsonProperty("12")
  private String resultB;
  
  /**
   * A原液溶解判定.
   */
  @JsonProperty("13")
  private String resultA;

}
