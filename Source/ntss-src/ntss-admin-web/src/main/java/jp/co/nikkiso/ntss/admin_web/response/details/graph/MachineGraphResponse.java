package jp.co.nikkiso.ntss.admin_web.response.details.graph;

import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph1;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph2;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph3;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph4;
import jp.co.nikkiso.ntss.admin_web.response.details.graph.machine.MachineGraph5;
import jp.co.nikkiso.ntss.core.entity.custom.TestResultDetail;
import lombok.AllArgsConstructor;

/**
 * 透析装置自己診断グラフのResponse.
 */
@AllArgsConstructor
public class MachineGraphResponse {
  
  /**
   * 基準日.
   */
  public String baseDate;
  
  /**
   * グラフ1のデータのリスト.
   */
  public List<MachineGraph1> graph1s;
  
  /**
   * グラフ2のデータリスト.
   */
  public List<MachineGraph2> graph2s;
  
  /**
   * グラフ3のデータリスト.
   */
  public List<MachineGraph3> graph3s;
  
  /**
   * グラフ4のデータリスト.
   */
  public List<MachineGraph4> graph4s;
  
  /**
   * グラフ5のデータリスト.
   */
  public List<MachineGraph5> graph5s;
  
  /**
   * 空の基準日とリストを返すコンストラクタ.
   * 取得結果0件時に使用する
   */
  public MachineGraphResponse() {
    this.baseDate = "";
    this.graph1s = Collections.emptyList();
    this.graph2s = Collections.emptyList();
    this.graph3s = Collections.emptyList();
    this.graph4s = Collections.emptyList();
    this.graph5s = Collections.emptyList();
  }

//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
  /**
   * 自己診断情報.
   */
  public List<TestResultDetail> selftList;
//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
}
