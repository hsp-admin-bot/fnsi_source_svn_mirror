package jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 透析装置の部品運転/交換時間のJSON格納モデル.
 */
public class MachinePartsRunningDto extends PartsRunningDto {

  /**
   * 装置運転時間.
   */
  @JsonProperty("0")
  public String useTime;

  /**
   * 消耗品グループ1.
   */
  @JsonProperty("1")
  public String expendablesGroup1;

  /**
   * 消耗品グループ2.
   */
  @JsonProperty("2")
  public String expendablesGroup2;

  /**
   * 消耗品グループ3.
   */
  @JsonProperty("3")
  public String expendablesGroup3;

  /**
   * 複式ポンプポペット運転時間.
   */
  @JsonProperty("4")
  public String duplexPumpPoppet;

  /**
   * 複式ポンプキャップシール運転時間
   */
  @JsonProperty("5")
  public String duplexPumpCapSeal;

  /**
   * 複式ポンプスライダー運転時間.
   */
  @JsonProperty("6")
  public String duplexPumpSlider;

  /**
   * 背圧弁ダイアフラム運転時間.
   */
  @JsonProperty("7")
  public String buckpressureValveDiaphragm;

  /**
   * 除水ポンプポペット運転時間.
   */
  @JsonProperty("8")
  public String removalPumpPoppet;

  /**
   * 除水ポンプキャップシール運転時間.
   */
  @JsonProperty("9")
  public String removalPumpCapSeal;

  /**
   * 脱気ポンプメカシ運転時間.
   */
  @JsonProperty("10")
  public String deaerationPumpMechanicalSeal;

  /**
   * 加圧ポンプメカシ運転時間.
   */
  @JsonProperty("11")
  public String pressurizationPumpMechanicalSeal;

  /**
   * 原液ポンプポペット運転時間.
   */
  @JsonProperty("12")
  public String undilutedPumpPoppet;

  /**
   * 原液ポンプキャップシール運転時間.
   */
  @JsonProperty("13")
  public String undilutedPumpCapSeal;

  /**
   * 原液ポンプ背圧ダイアフラム運転時間.
   */
  @JsonProperty("14")
  public String undilutedPumpBuckpressureValveDiaphragm;

  /**
   * 原液フィルタ運転時間.
   */
  @JsonProperty("15")
  public String undilutedFilter;

  /**
   * 微粒子ろ過フィルタ運転時間.
   */
  @JsonProperty("16")
  public String particleFiltration;

  /**
   * エアフィルタ運転時間.
   */
  @JsonProperty("17")
  public String airFilter;

  /**
   * 薬液フィルタ運転時間.
   */
  @JsonProperty("18")
  public String chemicalsFilter;

  /**
   * 透析液戻り口フィルタ.
   */
  @JsonProperty("19")
  public String dialysateReturnPortFilter;

  /**
   * 装置背面ファン用フィルタ.
   */
  @JsonProperty("20")
  public String backFanFilter;

  /**
   * 原液ノズルOリング.
   */
  @JsonProperty("21")
  public String undilutedNozzleORing;

  /**
   * バイパスコネクタOリング.
   */
  @JsonProperty("22")
  public String bypassConnectorORing;

  /**
   * ダイアライザーカップリングOリング.
   */
  @JsonProperty("23")
  public String dialyzerCupRingORing;

  /**
   * 電磁弁.
   */
  @JsonProperty("24")
  public String solenoidValve;

  /**
   * 薬液電磁弁.
   */
  @JsonProperty("25")
  public String chemicalsSolenoidValve;

  /**
   * 脱気ポンプインペラ.
   */
  @JsonProperty("26")
  public String deaerationPumpImpeller;

  /**
   * 加圧ポンプインペラ.
   */
  @JsonProperty("27")
  public String pressurizationPumpImpeller;

  /**
   * 複式ポンプテープベアリング.
   */
  @JsonProperty("28")
  public String duplexPumpTapeBearing;

  /**
   * 逆止弁.
   */
  @JsonProperty("29")
  public String checkValve;

  /**
   * 脱気ポンプフィルタ.
   */
  @JsonProperty("30")
  public String deaerationPumpFilter;

  /**
   * 微粒子ろ過フィルタ2運転時間.
   */
  @JsonProperty("31")
  public String particleFiltration2;

  /**
   * レベル調整ポンプしごき部.
   */
  @JsonProperty("32")
  public String levelAdjustingPumpIroning;

  /**
   * サンプルポートガスケット.
   */
  @JsonProperty("33")
  public String samplePortGasket;

  /**
   * ダイアライザーカップリング.
   */
  @JsonProperty("34")
  public String dialyzerCupRing;

  /**
   * サンプルポート逆止弁.
   */
  @JsonProperty("35")
  public String samplePortCheckValve;

}
