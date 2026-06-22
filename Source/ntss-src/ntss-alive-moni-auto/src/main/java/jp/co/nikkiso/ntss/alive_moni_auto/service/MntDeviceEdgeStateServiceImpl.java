package jp.co.nikkiso.ntss.alive_moni_auto.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

@Service
public class MntDeviceEdgeStateServiceImpl implements MntDeviceEdgeStateService {
  @Autowired
  private MntDeviceEdgeStateDao mntDeviceEdgeStateDao;
  
  @Autowired
  private LogService logService;

  @Override
  public List<MntDeviceEdgeState> findById(String facilityCd, int deviceEdgeNo) {
    List<MntDeviceEdgeState> data;
    try {
      data = this.mntDeviceEdgeStateDao.selectByFacilityDeviceEdgeNo(facilityCd, deviceEdgeNo);
    } catch (Exception e) {
      data = null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ", device_edge_no = " + deviceEdgeNo + ")");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"MntDeviceEdgeStateDao/selectByFacilityDeviceEdgeNo");
    }

    return data;
  }
}
