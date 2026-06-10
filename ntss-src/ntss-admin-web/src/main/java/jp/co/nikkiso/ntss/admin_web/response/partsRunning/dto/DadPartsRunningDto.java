package jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * DAD部品運転/交換時間のJSON格納モデル.
 */
public class DadPartsRunningDto extends PartsRunningDto {

  /**
   * 装置運転時間.
   */
  @JsonProperty("1")
  public String useTime;

  //NOTE: 通信仕様書は [2] -> 消耗品グループ１（時間）, [3] -> 消耗品グループ１（回数）だが、実機は逆になっている。実機に合わせる。

  /**
   * 消耗品グループ1(回数).
   */
  @JsonProperty("2")
  public String expendablesGroup1Count;

  /**
   * 消耗品グループ1(時間).
   */
  @JsonProperty("3")
  public String expendablesGroup1Time;

  /**
   * 消耗品グループ2.
   */
  @JsonProperty("4")
  public String expendablesGroup2;

  /**
   * 消耗品グループ3.
   */
  @JsonProperty("5")
  public String expendablesGroup3;

  /**
   * 減容カッター.
   */
  @JsonProperty("6")
  public String reductionCutter;

  /**
   * 微粒子除去フィルタ.
   */
  @JsonProperty("7")
  public String particulateRemovalFilter;

  /**
   * 電源装置ファン用フィルタ.
   */
  @JsonProperty("8")
  public String powerSupplyFanFilter;

  /**
   * HEPAフィルタ用フィルタ.
   */
  @JsonProperty("9")
  public String HepaFilter;

}
