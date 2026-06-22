package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * DRY-50A溶解記録結果のJSON格納クラス.
 */
@Data
public class Dry50ADissolutionDto {

  /**
   * 濃度.
   */
  @JsonProperty("7")
  private String concentration;

  /**
   * 温度.
   */
  @JsonProperty("8")
  private String temperature;


}
