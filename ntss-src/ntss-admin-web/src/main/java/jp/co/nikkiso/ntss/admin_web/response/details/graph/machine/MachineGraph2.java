package jp.co.nikkiso.ntss.admin_web.response.details.graph.machine;

import lombok.AllArgsConstructor;

/**
 * 透析装置自己診断のグラフ2のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class MachineGraph2 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * 除水.
   */
  public String removal;

  /**
   * バランス.
   */
  public String balance;

}
