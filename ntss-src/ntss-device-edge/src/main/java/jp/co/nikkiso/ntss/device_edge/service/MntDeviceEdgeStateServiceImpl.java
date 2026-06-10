package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;

import java.util.List;

@Service
public class MntDeviceEdgeStateServiceImpl implements MntDeviceEdgeStateService {

  @Autowired
  MntDeviceEdgeStateDao mntDeviceEdgeStateDao;

  @Autowired
  private LogService logService;

  @Override
  @Transactional
  public int updateAliveMoni(MntDeviceEdgeState param) {
    return mntDeviceEdgeStateDao.updateAliveMoni(param);
  }

  // add FNSI-バグ #7480 通信サーバ 高 start
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
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
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS,
        "MntDeviceEdgeStateDao/selectByFacilityDeviceEdgeNo");
    }

    return data;
  }
  // add FNSI-バグ #7480 通信サーバ 高 end

}
