package jp.co.nikkiso.ntss.admin_web.response.details.graph.dab;

import lombok.AllArgsConstructor;

/**
 * DAB自己診断のグラフ4のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class DabGraph4 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * B液濃度.
   */
  public String concentrationB;

  /**
   * 透析液濃度.
   */
  public String concentrationDialysate;

}
