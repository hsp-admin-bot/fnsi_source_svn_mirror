package jp.co.nikkiso.ntss.alive_moni.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

@Service
public class MntDeviceEdgeStateServiceImpl implements MntDeviceEdgeStateService {
  @Autowired
  MntDeviceEdgeStateDao mntDeviceEdgeStateDao;

  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntDeviceEdgeState> findById(String facilityCd, Integer deviceEdgeNo) {
    List<MntDeviceEdgeState> data;
    try {
      int edgeNo = deviceEdgeNo.intValue();
      data = mntDeviceEdgeStateDao.selectByFacilityDeviceEdgeNo(facilityCd, edgeNo);
    } catch (Exception e) {
      data = null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ", device_edge_no = " + deviceEdgeNo + ")");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,
          "MntDeviceEdgeStateDao/selectByFacilityDeviceEdgeNo");
    }

    return data;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int insert(MntDeviceEdgeState deviceEdgeState) {
    int ret;
    try {
      ret = mntDeviceEdgeStateDao.insertAliveMoni(deviceEdgeState);
    } catch (Exception e) {
      ret = -1;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeState.getDeviceEdgeNo()));
      eventLogMessage.setSqlIdentification("(facility_cd = " + deviceEdgeState.getFacilityCd() + ", device_edge_no = "
          + deviceEdgeState.getDeviceEdgeNo() +
          ", alive_moni_status = " + deviceEdgeState.getAliveMoniStatus() + ", version_information = "
          + deviceEdgeState.getVersionInformation() +
          ", last_moni_time = " + deviceEdgeState.getLastMoniTime() + ", reg_date = " + deviceEdgeState.getRegDate()
          + ", up_date = " + deviceEdgeState.getUpDate() + ")");
      eventLogMessage.setFacilityCd(deviceEdgeState.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "MntDeviceEdgeStateDao/insertAliveMoni");
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int update(MntDeviceEdgeState deviceEdgeState) {
    int ret;
    try {
      ret = mntDeviceEdgeStateDao.updateAliveMoniStatus(deviceEdgeState);
    } catch (Exception e) {
      ret = -1;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeState.getDeviceEdgeNo()));
      eventLogMessage.setSqlIdentification("(facility_cd = " + deviceEdgeState.getFacilityCd() + ", device_edge_no = "
          + deviceEdgeState.getDeviceEdgeNo() +
          ", alive_moni_status = " + deviceEdgeState.getAliveMoniStatus() + ", last_moni_time = "
          + deviceEdgeState.getLastMoniTime() + ", up_date = " + deviceEdgeState.getUpDate() + ")");
      eventLogMessage.setFacilityCd(deviceEdgeState.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,
          "MntDeviceEdgeStateDao/updateAliveMoniStatus");
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateSendMailStatus(MntDeviceEdgeState deviceEdgeState) {
    int ret;
    try {
      ret = mntDeviceEdgeStateDao.updateSendMailStatus(deviceEdgeState);
    } catch (Exception e) {
      ret = -1;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeState.getDeviceEdgeNo()));
      eventLogMessage.setSqlIdentification("(facility_cd = " + deviceEdgeState.getFacilityCd() + ", device_edge_no = "
          + deviceEdgeState.getDeviceEdgeNo() +
          ", alive_moni_status = " + deviceEdgeState.getAliveMoniStatus() + ", last_moni_time = "
          + deviceEdgeState.getLastMoniTime() + ", up_date = " + deviceEdgeState.getUpDate() + ")");
      eventLogMessage.setFacilityCd(deviceEdgeState.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,
          "MntDeviceEdgeStateDao/updateSendMailStatus");
    }

    return ret;
  }
}
