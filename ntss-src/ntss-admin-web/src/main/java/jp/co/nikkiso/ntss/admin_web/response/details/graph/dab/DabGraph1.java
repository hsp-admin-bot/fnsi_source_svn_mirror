package jp.co.nikkiso.ntss.admin_web.response.details.graph.dab;

import lombok.AllArgsConstructor;

/**
 * DAB自己診断のグラフ1のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class DabGraph1 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * 給水圧.
   */
  public String supplyPressure;

  /**
   * 送液圧低.
   */
  public String dialysateFlowPressureLow;

  /**
   * 送液圧高.
   */
  public String dialysateFlowPressureHigh;

}
