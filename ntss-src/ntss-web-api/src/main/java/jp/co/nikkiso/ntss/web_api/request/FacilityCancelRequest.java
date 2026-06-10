package jp.co.nikkiso.ntss.web_api.request;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * 施設解約のリクエストクラス。
 */
@Data
public class FacilityCancelRequest {
  /**
   * 施設コード
   * （解約登録）
   */
  @JsonProperty("facility_cd")
  private String facilityCd;

  /**
   * 解約基準日
   * （解約登録）
   */
  @JsonProperty("base_date")
  private String baseDate;

  /**
   * 処理区分
   * （解約登録）
   */
  @JsonProperty("proc_class")
  private String procClass;

  /**
   * 処理実行時間の上限値（単位: 分）
   * （解約実行）
   */
  private Long expiration;

  /**
   * レコード管理番号
   * （解約処理ステータス更新）
   */
  @JsonProperty("ctl_no")
  private Long ctlNo;
}
