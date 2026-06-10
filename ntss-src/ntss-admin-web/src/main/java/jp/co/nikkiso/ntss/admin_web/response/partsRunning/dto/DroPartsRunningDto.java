package jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * DRO部品運転/交換時間のJSON格納モデル.
 */
public class DroPartsRunningDto extends PartsRunningDto {

  /**
   * 10μフィルタ.
   */
  @JsonProperty("1")
  public String tenMcroFilter;

  /**
   * カーボンフィルタ.
   */
  @JsonProperty("2")
  public String carbonFilter;

  /**
   * LRO膜.
   */
  @JsonProperty("3")
  public String lroFilm;

  /**
   * RO膜.
   */
  @JsonProperty("4")
  public String roFilm;

  /**
   * エアフィルタ.
   */
  @JsonProperty("5")
  public String airFilter;

  /**
   * RO水タンクUVランプ.
   */
  @JsonProperty("6")
  public String roWaterTunkUvLamp;

  /**
   * 濃縮水タンクUVランプ.
   */
  @JsonProperty("7")
  public String condenseWaterTunkUvLamp;

  /**
   * 排水回収RO膜.
   */
  @JsonProperty("8")
  public String drainageRecoveryRoFilm;

}
