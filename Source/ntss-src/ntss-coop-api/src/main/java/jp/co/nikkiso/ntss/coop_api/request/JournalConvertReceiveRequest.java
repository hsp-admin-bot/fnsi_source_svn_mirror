package jp.co.nikkiso.ntss.coop_api.request;

import org.springframework.util.StringUtils;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

import java.util.List;

/**
 * ジャーナル受信変換処理のリクエスト。
 */
@Data
public class JournalConvertReceiveRequest {

  /**
   * 施設コード
   */
  @JsonProperty("facility_cd")
  private String facilityCd;

  /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加  --start */
  /**
   * 管理番号リスト
   */
  @JsonProperty("ctl_no_list")
  private List<Long> ctlNoList;
  /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加  --end */

  /**
   * パラメータが正しいか検証する。
   *
   * @return 正しい場合はtrue、不正な場合はfalse
   */
  public boolean validate() {
    return !StringUtils.isEmpty(facilityCd);
  }
}
