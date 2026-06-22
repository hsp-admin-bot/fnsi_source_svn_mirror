package jp.co.nikkiso.ntss.admin_web.response.details.graph.machine;

import lombok.AllArgsConstructor;

/**
 * 透析装置自己診断のグラフ3のデータ1件を表すクラス.
 */
@AllArgsConstructor
public class MachineGraph3 {

  /**
   * イベント発生日付(yyyy/MM/dd).
   */
  public String evenetRegDate;

  /**
   * イベント発生時刻(HH24:MI:SS).
   */
  public String evenetRegTime;

  /**
   * 赤電圧.
   */
  public String voltageRed;

  /**
   * 緑電圧.
   */
  public String voltageGreen;

}
