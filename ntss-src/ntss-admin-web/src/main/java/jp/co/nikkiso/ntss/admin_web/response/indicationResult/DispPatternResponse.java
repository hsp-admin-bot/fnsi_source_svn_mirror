package jp.co.nikkiso.ntss.admin_web.response.indicationResult;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;

/**
 * 表示形式パターン取得APIのResponseクラス.
 */
@AllArgsConstructor
public class DispPatternResponse {

  /**
   * 表示形式パターン.
   */
  @JsonProperty("disp_pattern")
  private Integer dispPattern;

}
