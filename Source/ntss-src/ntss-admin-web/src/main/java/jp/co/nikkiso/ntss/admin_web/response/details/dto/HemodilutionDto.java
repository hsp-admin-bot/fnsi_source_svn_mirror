package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * 希釈テスト結果のJSON格納クラス.
 */
@Data
public class HemodilutionDto {
  
  /**
   * 希釈テスト結果.
   */
  @JsonProperty("6")
  private String result;
  
  /**
   * B液濃度.
   */
  @JsonProperty("4")
  private String concentrationB;
  
  /**
   * 透析液濃度.
   */
  @JsonProperty("5")
  private String concentrationDialysate;

}
