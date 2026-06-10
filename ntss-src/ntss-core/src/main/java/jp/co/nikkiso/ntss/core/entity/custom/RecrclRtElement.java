package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * 再循環率測定
 */
@Data
public class RecrclRtElement {
  /**
   * 再循環率,ログデータから乗せた値
   */
  @JsonProperty("rate")
  public Double rate;
  /**
   * 血流量,mnt_machine_state.monitor_dataから「血流量」の値を取得
   */
  @JsonProperty("bld_vl")
  public Integer bld_vl;
  /**
   * 発生時間,ログデータに乗せた発生時間
   */
  @JsonProperty("datetime")
  public String datetime;
  /**
   * コメント,登録時に、空白で登録
   */
  @JsonProperty("comment")
  public String comment;
}
