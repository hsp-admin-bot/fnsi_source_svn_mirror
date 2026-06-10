package jp.co.nikkiso.ntss.api.request;

import lombok.Getter;
import lombok.Setter;

/**
 * 受付番号採番サービスリクエスト
 *
 */
@Getter
@Setter
public class SysDailyNoRequest {

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 採番種別
   */
  private String numberingCd;

}
