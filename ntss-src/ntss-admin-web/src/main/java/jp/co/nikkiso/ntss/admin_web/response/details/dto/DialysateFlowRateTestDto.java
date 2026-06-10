package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

import java.util.List;

/**
 * 透析液流量自己診断結果のJSON格納クラス.
 */
@Data
public class DialysateFlowRateTestDto {

  /**
   * 透析液流量-測定値.
   */
  @JsonProperty("58")
  private String dialysateFlowRate;

  /* add #9241 by zhangruixue 2023-08-01 --start */
  /**
   *自己診断判定 設定
   */
  @JsonProperty("999")
  private List<SelfMeasureResultDto> selfMeasureResultDto;
  /* add #9241 by zhangruixue 2023-08-01 --end */
}
