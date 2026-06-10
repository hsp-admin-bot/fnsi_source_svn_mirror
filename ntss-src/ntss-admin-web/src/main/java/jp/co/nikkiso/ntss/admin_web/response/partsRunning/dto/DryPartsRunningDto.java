package jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * DRY-50A、DRY-50B部品運転/交換時間のJSON格納モデル.
 */
public class DryPartsRunningDto extends PartsRunningDto {

  /**
   * 微粒子ろ過フィルタ.
   */
  @JsonProperty("1")
  public String particulateRemovalFilter;

  /**
   * 消耗品グループ.
   */
  @JsonProperty("2")
  public String expendablesGroup;

}