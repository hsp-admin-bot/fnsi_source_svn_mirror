package jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * V4共通通信の部品運転/交換時間のJSON格納モデル.
 */
public class V4PartsRunningDto extends PartsRunningDto {

  /**
   * ETRF1時間.
   */
  @JsonProperty("16")
  public String particleFiltration;

  /**
   * ETRF2時間.
   */
  @JsonProperty("31")
  public String particleFiltration2;

}
