package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.monitor.MonitorGraphDefineResponse;
import jp.co.nikkiso.ntss.core.dao.MstAddMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstMonitorGraphDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import jp.co.nikkiso.ntss.core.entity.MstMonitorGraph;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import static java.util.Collections.emptyList;

/**
 * モニタグラフ用のService実装クラス.
 */
@Service
public class MonitorGraphServiceImpl implements MonitorGraphService {

  /**
   * モニタグラフのDaoインターフェース.
   */
  @Autowired
  private MstMonitorGraphDao mstMonitorGraphDao;

  /**
   * 並び順管理マスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
  @Autowired
  private jp.co.nikkiso.ntss.core.dao.SysMonitorItemDao sysMonitorItemDao;
  @Autowired
  private MstAddMonitorDao mstAddMonitorDao;
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * モニタグラフ情報を取得
   * {@inheritDoc}
   */
  @Override
  public List<MonitorGraphDefineResponse> createMonitorGraphDefineResponse(String facilityCd) {
    final List<MstMonitorGraph> monitorGraphs = mstMonitorGraphDao
        .selectByFacilityCd(facilityCd);

    if (monitorGraphs.isEmpty()) {
      return emptyList();
    }

    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_monitor_graph");
    if(Objects.isNull(mstSelector)) {
      return emptyList();
    }

    final List<MstSelector.Item> orderSettingItems = mstSelector.getOrderSettings().getItems();
    if(orderSettingItems.isEmpty()) {
      return emptyList();
    }

    final List<MonitorGraphDefineResponse> result = new ArrayList<>();
    orderSettingItems.stream()
      .map(MstSelector.Item::getCode)
      .forEach(code -> {
        MstMonitorGraph mstMonitorGraph = monitorGraphs.stream()
          .filter(value -> value.getMonitorGraphCd().equals(Integer.parseInt(code.toString())))
          .findFirst()
          .get();

        String leftName = "左項目なし";
        String rightName = "右項目なし";
        final Integer INDEX_OFFSET = 10000;
        String leftDataIndex = mstMonitorGraph.getLeftDataIndex();
        String rightDataIndex = mstMonitorGraph.getRightDataIndex();
        SysMonitorItem sysMonitorItem = null;
        MstAddMonitor addMonitorItem = null;

        // 左項目コードあり
        if (StringUtils.hasText(leftDataIndex)) {
          // 左項目元
          Integer isMstMonitor = mstMonitorGraph.getLeftIsMstMonitor();
          // モニタ項目マスタ
          if (isMstMonitor == 0) {
            // left_data_indexに格納されている値をキーとして使用する
            // ※格納されている値に数値以外の文字列も含まれる
            sysMonitorItem = sysMonitorItemDao.selectByMoniDataNo(leftDataIndex);
            if (sysMonitorItem != null) {
              leftName = sysMonitorItem.getMoniDataName();
            }
          } // バイタル・モニタ項目追加マスタ
          else if (isMstMonitor == 1) {
            try {
              addMonitorItem = mstAddMonitorDao.selectByCd(Long.valueOf(leftDataIndex));
              if (addMonitorItem != null) {
                leftName = addMonitorItem.getVitalMonitorItemName();
              }
              // left_data_index +10000 をキーの値として使用する
              leftDataIndex = String.valueOf(Integer.valueOf(leftDataIndex) + INDEX_OFFSET);
            } catch (NumberFormatException e) {
              // 値は数値ではありません
              EventLogMessage eventLogMessage = new EventLogMessage();
              StringBuilder sb = new StringBuilder();
              sb.append("モニタグラフ情報を取得 leftDataIndex:" + leftDataIndex + " は数値ではありません")
              .append(System.getProperty("line.separator"))
              .append("施設コード: " + facilityCd);
              eventLogMessage.setLogMessage(sb.toString());
              logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            }
          }
        }
        // 右項目コードあり
        if (StringUtils.hasText(rightDataIndex)) {
          // 右項目元
          Integer isMstMonitor = mstMonitorGraph.getRightIsMstMonitor();
          // モニタ項目マスタ
          if (isMstMonitor == 0) {
            // right_data_indexに格納されている値をキーとして使用する
            // ※格納されている値に数値以外の文字列も含まれる
            sysMonitorItem = sysMonitorItemDao.selectByMoniDataNo(rightDataIndex);
            if (sysMonitorItem != null) {
              rightName = sysMonitorItem.getMoniDataName();
            }
          } // バイタル・モニタ項目追加マスタ
          else if (isMstMonitor == 1) {
            try {
              addMonitorItem = mstAddMonitorDao.selectByCd(Long.valueOf(rightDataIndex));
              if (addMonitorItem != null) {
                rightName = addMonitorItem.getVitalMonitorItemName();
              }
              // right_data_index +10000 をキーの値として使用する
              rightDataIndex = String.valueOf(Integer.valueOf(rightDataIndex) + INDEX_OFFSET);
            } catch (NumberFormatException e) {
              // 値は数値ではありません
              EventLogMessage eventLogMessage = new EventLogMessage();
              StringBuilder sb = new StringBuilder();
              sb.append("モニタグラフ情報を取得 rightDataIndex:" + rightDataIndex + " は数値ではありません")
              .append(System.getProperty("line.separator"))
              .append("施設コード: " + facilityCd);
              eventLogMessage.setLogMessage(sb.toString());
              logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
            }
          }
        }
        //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
        //mod FNSI-改修内容 グラフ様式修正 房 start
        MonitorGraphDefineResponse response = new MonitorGraphDefineResponse(
          mstMonitorGraph.getMonitorGraphCd(),
          mstMonitorGraph.getMonitorGraphName(),
          leftDataIndex,
          mstMonitorGraph.getLeftColor(),
          mstMonitorGraph.getLeftLineSize(),
          mstMonitorGraph.getLeftLineTypeValue(),
          mstMonitorGraph.getLeftPointColor(),
          mstMonitorGraph.getLeftPointSize(),
          mstMonitorGraph.getLeftPointTypeValue(),
          rightDataIndex,
          mstMonitorGraph.getRightColor(),
          mstMonitorGraph.getRightLineSize(),
          mstMonitorGraph.getRightLineTypeValue(),
          mstMonitorGraph.getRightPointColor(),
          mstMonitorGraph.getRightPointSize(),
          mstMonitorGraph.getRightPointTypeValue(),
          //mod FNSI-改修内容 グラフ様式追加最大値と最小値 杜天成 start
          mstMonitorGraph.getRightGraphLowerLimit(),
          mstMonitorGraph.getRightGraphUpperLimit(),
          mstMonitorGraph.getLeftGraphLowerLimit(),
          mstMonitorGraph.getLeftGraphUpperLimit()
          //mod FNSI-改修内容 グラフ様式追加最大値と最小値 杜天成 end
          //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
          ,leftName
          ,rightName
          //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
        );
        //mod FNSI-改修内容 グラフ様式修正 房 end
        result.add(response);
      });

    return result;
  }

}
