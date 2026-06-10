package jp.co.nikkiso.ntss.admin_web.service.trendGraph;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.trendGraph.TrendGraphMasterResponse;
import jp.co.nikkiso.ntss.admin_web.response.trendGraph.TrendGraphResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstTrendGraphMonitorSetDao;
import jp.co.nikkiso.ntss.core.dao.MstTrendGraphTemplateDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstTrendGraphMonitorSet;
import jp.co.nikkiso.ntss.core.entity.MstTrendGraphTemplate;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class TrendGraphServiceImpl implements TrendGraphService {

  //add FNSI redmine 5759 劉祥霖　start
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  //add FNSI redmine 5759 劉祥霖　end

  @Autowired
  MstTrendGraphTemplateDao mstTrendGraphTemplateDao;
  @Autowired
  MstTrendGraphMonitorSetDao mstTrendGraphMonitorDao;
  @Autowired
  MstSelectorDao mstSelectorDao;
  @Autowired
  MniMonitorDao mniMonitorDao;
  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MniMonitor> selectMonitorOnMachine(String facilityCd, String machineTypeCd, String machineSerial,
      String startDate, String endDate) {
    return mniMonitorDao.selectMonitorOnMachine(facilityCd, machineTypeCd, machineSerial, startDate, endDate);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod FNSI-改修内容5702修正 xuty start
  // public List<MstTrendGraphMonitorSet> selectTrendGraphOnMonitor(String facilityCd, String model) {
  //   List<MstTrendGraphMonitorSet> monitorSets = mstTrendGraphMonitorDao.selectByModel(facilityCd, model);
  public List<MstTrendGraphMonitorSet> selectTrendGraphOnMonitor(String facilityCd, String model, String comFormatCd) {
    List<MstTrendGraphMonitorSet> monitorSets = mstTrendGraphMonitorDao.selectByModel(facilityCd, model, comFormatCd);
  // mod FNSI-改修内容5702修正 xuty end
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_trend_graph_monitor_set");

    if (mstSelector != null) {
      // ソート後データ
      List<MstTrendGraphMonitorSet> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstTrendGraphMonitorSet item : monitorSets) {
          if (sortedCode.equals(item.getMonitorSetCd())) {
            // add FNSI-改修内容5702修正 xuty start
            JSONArray jsonArray = new JSONArray(item.getSeriesInfo());
            for(int i0 = 0; i0 < jsonArray.length(); i0++) {
              // add FNSI redmine 5702再修正 劉祥霖 start
              if(jsonArray.getJSONObject(i0).has("checked")){
              // add FNSI redmine 5702再修正 劉祥霖 end
                if ("false".equals(jsonArray.getJSONObject(i0).get("checked").toString())) {
                  jsonArray.remove(i0);
                  i0--;
                }
              // add FNSI redmine 5702再修正 劉祥霖 start
              }
              // add FNSI redmine 5702再修正 劉祥霖 end
            }
            item.setSeriesInfo(jsonArray.toString());
            // add FNSI-改修内容5702修正 xuty end
            sortedData.add(item);
          }
        }
      }

      monitorSets = sortedData;
    }
    return monitorSets;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod FNSI-改修内容5702修正 xuty start
  // public List<MstTrendGraphTemplate> selectTrendGraphOnTemplate(String facilityCd, String model) {
  //  List<MstTrendGraphTemplate> templates = mstTrendGraphTemplateDao.selectByModel(facilityCd, model);
  public List<MstTrendGraphTemplate> selectTrendGraphOnTemplate(String facilityCd, String model, String comFormatCd) {
    List<MstTrendGraphTemplate> templates = mstTrendGraphTemplateDao.selectByModel(facilityCd, model, comFormatCd);
  // mod FNSI-改修内容5702修正 xuty end
    // mod バグ改修251 付 start
    // mstSelectorから並び順を取得
    // MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_trend_graph_monitor_set");
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_trend_graph_template");
    // mod バグ改修251 付 end

    if (mstSelector != null) {
      // ソート後データ
      List<MstTrendGraphTemplate> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstTrendGraphTemplate item : templates) {
          if (sortedCode.equals(item.getTemplateCd())) {
            sortedData.add(item);
          }
        }
      }

      templates = sortedData;
    }
    return templates;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod FNSI-改修内容5702修正 xuty start
  // public TrendGraphMasterResponse findTrendGraphMaster(String facilityCd, String model) {
  public TrendGraphMasterResponse findTrendGraphMaster(String facilityCd, String model, String comFormatCd) {
  // mod FNSI-改修内容5702修正 xuty end
    TrendGraphMasterResponse res = new TrendGraphMasterResponse();
    // mod FNSI-改修内容5702修正 xuty start
    // res.monitorSet = selectTrendGraphOnMonitor(facilityCd, model);
    // res.template = selectTrendGraphOnTemplate(facilityCd, model);
    res.monitorSet = selectTrendGraphOnMonitor(facilityCd, model, comFormatCd);
    res.template = selectTrendGraphOnTemplate(facilityCd, model, comFormatCd);
    // mod FNSI-改修内容5702修正 xuty end
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TrendGraphResponse findTrendGraphdata(String facilityCd,
      String machineTypeCd,
      String machineSerial,
      String model,
      String startDate,
      String endDate) {
    // 戻り値作成（レスポンス作成）
    TrendGraphResponse response = new TrendGraphResponse();
    try {
      // モニタデータ取得
      List<MniMonitor> trendGraphData = this.selectMonitorOnMachine(facilityCd, machineTypeCd, machineSerial,
          convertTTTTMMDD2DateStr(startDate, 0L),
          convertTTTTMMDD2DateStr(endDate, 1L));
      //add FNSI redmine 5759 劉祥霖　start
      //最新データの発生時間は表示期間内の場合、モニタデータのリストに加える
      MntMachineState mntMachineStateTrendGraphData = mntMachineStateDao.selectByKey(facilityCd,machineTypeCd,machineSerial);
      String upTimeString=mntMachineStateTrendGraphData.getUpDate().toString();
      upTimeString=upTimeString.substring(0,10);
      upTimeString=upTimeString.replaceAll("-","");
      if(upTimeString.compareTo(startDate)>=0&&upTimeString.compareTo(endDate)<=0){
        MniMonitor MniMonitorTrendGraphData=new MniMonitor();
//      MniMonitorTrendGraphData.setBioMoniCtlNo(trendGraphData.get(0).getBioMoniCtlNo());
        MniMonitorTrendGraphData.setFacilityCd(facilityCd);
        MniMonitorTrendGraphData.setMachineTypeCd(machineTypeCd);
        MniMonitorTrendGraphData.setMachineSerial(machineSerial);
        MniMonitorTrendGraphData.setOrdNo(mntMachineStateTrendGraphData.getOrdNo());
        MniMonitorTrendGraphData.setPatId(mntMachineStateTrendGraphData.getPatId());
//      MniMonitorTrendGraphData.setDataType(trendGraphData.get(0).getDataType());
        MniMonitorTrendGraphData.setIsDel("0");
        MniMonitorTrendGraphData.setOccurDate(mntMachineStateTrendGraphData.getUpDate());
        MniMonitorTrendGraphData.setMonitorData(mntMachineStateTrendGraphData.getMonitorData());
        trendGraphData.add(MniMonitorTrendGraphData);
      }
      //add FNSI redmine 5759 劉祥霖　end
      response.isSuccess = true;
      response.monitorInfo = trendGraphData;

      return response;

    } catch (Exception e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getTrendGraphdata : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,null,SERVICE_NAME.REMS, null);
      return null;
    }
  }

  /**
   * YYYYMMDD文字列からYYYY/MM/DD文字列に変換
   * @param baseDateStr
   * @return
   */
  private String convertTTTTMMDD2DateStr(String baseDateStr, long addDate) {
    String formatYYYYMMDD = "uuuuMMdd";
    if (Objects.isNull(baseDateStr) || baseDateStr.length() != 8) {
      // 指定文字列形式ではない
      return null;
    }

    try {
      LocalDate pastDate = LocalDate.parse(baseDateStr, DateTimeFormatter.ofPattern(formatYYYYMMDD));
      pastDate = pastDate.plusDays(addDate);
      return pastDate.format(DateTimeFormatter.ofPattern("uuuu/MM/dd")).toString();
    } catch (Exception e) {
      return null;
    }
  }

}
