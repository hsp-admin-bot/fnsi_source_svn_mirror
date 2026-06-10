package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

import java.util.List;

/**
 * 配管(UFRC)自己診断結果のJSON格納クラス.
 */
@Data
public class UfrcTestDto {
  
  /**
   * 配管自己診断結果.
   */
  @JsonProperty("47")
  private String result;

  /**
   * 配管漏れ(陰圧).
   */
  @JsonProperty("43")
  private String negativePipeLeakage;
  
  /**
   * 配管漏れ(陽圧).
   */
  @JsonProperty("44")
  private String positivePipeLeakage;
  
  /**
   * CF漏れ.
   */
  @JsonProperty("45")
  private String cfLeakage;
  
  /**
   * CF2漏れ.
   */
  @JsonProperty("49")
  private String cf2Leakage;
  
  /**
   * 除水.
   */
  @JsonProperty("48")
  private String removal;
  
  /**
   * バランス.
   */
  @JsonProperty("46")
  private String balance;

  /* add #9241 by zhangruixue 2023-08-01 --start */
  /**
   *自己診断判定 設定
   */
  @JsonProperty("999")
  private List<SelfMeasureResultDto> selfMeasureResultDto;
  /* add #9241 by zhangruixue 2023-08-01 --end */
}
