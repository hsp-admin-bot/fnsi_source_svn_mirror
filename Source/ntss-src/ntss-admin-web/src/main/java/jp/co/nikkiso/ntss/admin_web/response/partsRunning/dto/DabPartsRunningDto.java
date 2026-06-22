package jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * DAB部品運転/交換時間のJSON格納モデル.
 */
public class DabPartsRunningDto extends PartsRunningDto {

  /**
   * 装置運転時間.
   */
  @JsonProperty("1")
  public String useTime;

  /**
   * 消耗品グループ1.
   */
  @JsonProperty("2")
  public String expendablesGroup1;

  /**
   * 消耗品グループ2.
   */
  @JsonProperty("3")
  public String expendablesGroup2;

  /**
   * 消耗品グループ3.
   */
  @JsonProperty("4")
  public String expendablesGroup3;

  /**
   * 水計量シリンダ(往復動運転).
   */
  @JsonProperty("5")
  public String cylinderReciprocating;

  /**
   * 水計量シリンダ(バイパス運転).
   */
  @JsonProperty("6")
  public String cylinderBypass;

  /**
   * B原液注入ポンプP1運転時間.
   */
  @JsonProperty("7")
  public String pumpP1;

  /**
   * A原液注入ポンプP2運転時間.
   */
  @JsonProperty("8")
  public String pumpP2;

  /**
   * NaCl原液注入ポンプP3運転時間.
   */
  @JsonProperty("9")
  public String pumpP3;

  /**
   * 送液ポンプP4運転時間.
   */
  @JsonProperty("10")
  public String pumpP4;

  /**
   * 薬液注入ポンプP5運転時間.
   */
  @JsonProperty("11")
  public String pumpP5;

  /**
   * 脱気ポンプP6運転時間.
   */
  @JsonProperty("12")
  public String pumpP6;

  /**
   * 脱気ポンプP7運転時間.
   */
  @JsonProperty("13")
  public String pumpP7;

  /**
   * パワーユニットファンフィルタ.
   */
  @JsonProperty("14")
  public String powerUnitFanFilter;

  /**
   * 水計量シリンダ電磁弁動作回数.
   */
  @JsonProperty("15")
  public String cylinderSoleoidValve;

  /**
   * 給水電磁弁動作回数.
   */
  @JsonProperty("16")
  public String supplySolenoidValve;

}
