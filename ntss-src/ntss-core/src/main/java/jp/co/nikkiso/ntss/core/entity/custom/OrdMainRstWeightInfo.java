package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * 体重実績のJSON格納クラス.
 */
@Data
public class OrdMainRstWeightInfo {

  /**
   * 前体重測定値
   */
  @JsonProperty("weight_measure_before")
  private BigDecimal weightMeasureBefore;
  /**
   * 前体重.
   */
  @JsonProperty("weight_before")
  private BigDecimal weightBefore;
  /**
   * 前体重測定日時
   */
  @JsonProperty("weight_before_date")
  private String weightBeforeDate;
  /**
   * 後体重測定値
   */
  @JsonProperty("weight_measure_after")
  private BigDecimal weightMeasureAfter;
  /**
   * 後体重
   */
  @JsonProperty("weight_after")
  private BigDecimal weightAfter;

  /**
   * 後体重測定日時
   */
  @JsonProperty("weight_after_date")
  private String weightAfterDate;
  /**
   * CTR
   */
  @JsonProperty("ctr")
  private BigDecimal ctr;
  /**
   * CTR測定日時,
   */
  @JsonProperty("ctr_measure_date")
  private String ctrMeasureDate;
  /**
   * CTR測定時体重
   */
  @JsonProperty("ctr_weight")
  private BigDecimal ctrWeight;
  /**
   * 目標除水量
   */
  @JsonProperty("water_removal_target")
  private BigDecimal waterRemovalTarget;
  /**
   * 実績除水量
   */
  @JsonProperty("water_removal_rst")
  private BigDecimal waterRemovalRst;
  /**
   * 除水積算値
   */
  @JsonProperty("add_total")
  private BigDecimal addTotal;
  /**
   * 補液積算値
   */
  @JsonProperty("add_water_total")
  private BigDecimal addWaterTotal;
  /**
   * Kt/V測定値
   */
  @JsonProperty("kt_v_measure")
  private BigDecimal ktVMeasure;
  /**
   * URR
   */
  @JsonProperty("urr")
  private BigDecimal urr;
  /**
   * 減少量
   */
  @JsonProperty("weight_decreased")
  private BigDecimal weightDecreased;
  /**
   * 治療記録で選択された再循環率の番号を格納(生体モニタリング管理番号[bio_moni_ctl_no]を想定)
   */
  @JsonProperty("re_loop_rate_main")
  private Long reLoopRateMain;

  @JsonProperty("reloop_info")
  private String reloopInfo;

  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 zhaoyunbin start
  /**
   * 再循環率測定
   */
  @JsonProperty("recrcl_rt")
  private RecrclRt recrcl_rt;
  /**
   * プログラム補液引き残し量
   */
  @JsonProperty("ihdf_pll")
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
  // private String ihdf_pll;
  private BigDecimal ihdf_pll;
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
  /**
   * 静的静脈圧
   */
  @JsonProperty("sttc_vns_prssr")
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
  // private String sttc_vns_prssr;
  private BigDecimal sttc_vns_prssr;
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
  /**
   * IAP ratio
   */
  @JsonProperty("iap_rt")
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
  // private String iap_rt;
  private BigDecimal iap_rt;
  // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 zhaoyunbin end
}
