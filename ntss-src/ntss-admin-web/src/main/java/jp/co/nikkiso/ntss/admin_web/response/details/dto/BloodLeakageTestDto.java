package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

import java.util.List;

/**
 * 漏血自己診断結果のJSON格納クラス.
 */
@Data
public class BloodLeakageTestDto {
  
  /**
   * 赤電圧.
   */
  @JsonProperty("53")
  private String voltageRed;
  
  /**
   * 緑電圧.
   */
  @JsonProperty("54")
  private String voltageGreen;

  /* add #9241 by zhangruixue 2023-08-01 --start */
  /**
   *自己診断判定 設定
   */
  @JsonProperty("999")
  private List<SelfMeasureResultDto> selfMeasureResultDto;
  /* add #9241 by zhangruixue 2023-08-01 --end */

}
