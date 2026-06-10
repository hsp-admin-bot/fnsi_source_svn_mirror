package jp.co.nikkiso.ntss.admin_web.service.trendGraph;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.trendGraph.TrendGraphMasterResponse;
import jp.co.nikkiso.ntss.admin_web.response.trendGraph.TrendGraphResponse;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstTrendGraphMonitorSet;
import jp.co.nikkiso.ntss.core.entity.MstTrendGraphTemplate;

public interface TrendGraphService {

  /**
   * トレンドグラフ用データを取得する
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置種別
   * @param machineSerial 製造番号
   * @param startDate 開始日
   * @param endDate 終了日
   * @return
   */
  List<MniMonitor> selectMonitorOnMachine(String facilityCd, String machineTypeCd, String machineSerial,
      String startDate, String endDate);

  /**
   * トレンドグラフ：モニターデータ情報を取得する
   * @param facilityCd 施設コード
   * @param model 装置種別
   * @return
   */
  // mod FNSI-改修内容5702修正 xuty start
  // List<MstTrendGraphMonitorSet> selectTrendGraphOnMonitor(String facilityCd, String model);
  List<MstTrendGraphMonitorSet> selectTrendGraphOnMonitor(String facilityCd, String model, String comFormatCd);
  // mod FNSI-改修内容5702修正 xuty end

  /**
   * トレンドグラフ：グラフ系列情報を取得する
   * @param facilityCd 施設コード
   * @param model 装置種別
   * @return
   */
  // mod FNSI-改修内容5702修正 xuty start
  // List<MstTrendGraphTemplate> selectTrendGraphOnTemplate(String facilityCd, String model);
  List<MstTrendGraphTemplate> selectTrendGraphOnTemplate(String facilityCd, String model, String comFormatCd);
  // mod FNSI-改修内容5702修正 xuty end

  /**
   * トレンドグラフ用データを取得する
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置種別
   * @param machineSerial 製造番号
   * @param model 装置種別
   * @param startDate 開始日
   * @param endDate 終了日
   * @return
   */
  TrendGraphResponse findTrendGraphdata(String facilityCd, String machineTypeCd, String machineSerial, String model,
      String startDate, String endDate);

  /**
   * 特定施設の特定装置のマスターを取得して返す
   * @param facilityCd 施設コード
   * @param model 装置種別
   * @param comFormatCd 通信フォーマット
   * @return
   */
  // mod FNSI-改修内容5702修正 xuty start
  // TrendGraphMasterResponse findTrendGraphMaster(String facilityCd, String model);
  TrendGraphMasterResponse findTrendGraphMaster(String facilityCd, String model, String comFormatCd);
  // mod FNSI-改修内容5702修正 xuty end

}
