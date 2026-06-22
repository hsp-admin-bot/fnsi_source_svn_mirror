package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

import java.util.List;

/**
 * 濃度自己診断結果のJSON格納クラス.
 */
@Data
public class ConcentrationTestDto {
  
  /**
   * 濃度自己診断結果.
   */
  @JsonProperty("65")
  private String result;
  
  /**
   * B原液.
   */
  @JsonProperty("63")
  private String dialysateB;
  
  /**
   * A原液.
   */
  @JsonProperty("64")
  private String dialysateA;


  /* add #9241 by zhangruixue 2023-08-01 --start */
  /**
   *自己診断判定 設定
   */
  @JsonProperty("999")
  private List<SelfMeasureResultDto> selfMeasureResultDto;
  /* add #9241 by zhangruixue 2023-08-01 --end */
}
