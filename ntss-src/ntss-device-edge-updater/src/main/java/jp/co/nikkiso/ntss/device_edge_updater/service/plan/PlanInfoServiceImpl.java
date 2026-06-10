package jp.co.nikkiso.ntss.device_edge_updater.service.plan;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge_updater.service.LogService;
import jp.co.nikkiso.ntss.device_edge_updater.util.Utilities;

@Service
public class PlanInfoServiceImpl implements PlanInfoService {

  @Autowired
  LogService logService;
  @Autowired
  MntDeviceEdgeStateDao mntDeviceEdgeStateDao;
  /**
   * {@inheritDoc}
   */
  @Override
  public int savePlanInfo(String facilityCd, Integer deviceEdgeNo, String strSeqNo, String planDate) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(deviceEdgeNo == null ? null : deviceEdgeNo.toString());
    eventLogMessage.setFacilityCd(facilityCd);

    List<MntDeviceEdgeState> deviceEdgeStates = mntDeviceEdgeStateDao.selectByFacilityDeviceEdgeNo(facilityCd, deviceEdgeNo);
    if (deviceEdgeStates.isEmpty()) {
      eventLogMessage.setLogMessage("mnt_device_edge_state に該当する項目がありません。");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return 0;
    }
    MntDeviceEdgeState deviceEdgeState = deviceEdgeStates.get(0);

    Long seqNo = null;
    if (strSeqNo != null && Utilities.isNumber(strSeqNo)) {
      seqNo = Long.parseLong(strSeqNo);
    }
    if (seqNo != null && seqNo.compareTo(0L) > 0) {
      // 予約確定
      eventLogMessage.setLogMessage("予約情報を登録します。");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
      LocalDateTime dtPlanDate = LocalDateTime.parse(planDate, dateFormat);
      Timestamp tsPlanDate = Timestamp.valueOf(dtPlanDate);
      deviceEdgeState.setManageNo(seqNo);
      deviceEdgeState.setManagePlanDate(tsPlanDate);
      return mntDeviceEdgeStateDao.updatePlan(deviceEdgeState);
    } else {
      // 予約削除(予約処理完了含む)
      eventLogMessage.setLogMessage("予約情報を削除します。");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

      deviceEdgeState.setManageNo(null);
      deviceEdgeState.setManagePlanDate(null);
      return mntDeviceEdgeStateDao.updatePlan(deviceEdgeState);
    }
  }

}
