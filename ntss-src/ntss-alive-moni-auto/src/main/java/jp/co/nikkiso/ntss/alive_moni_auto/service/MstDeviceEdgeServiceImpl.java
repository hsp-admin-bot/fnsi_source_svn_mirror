package jp.co.nikkiso.ntss.alive_moni_auto.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

@Service
public class MstDeviceEdgeServiceImpl implements MstDeviceEdgeService {
  @Autowired
  private MstDeviceEdgeDao mstDeviceEdgeDao;

  @Autowired
  private LogService logService;
  
  @Override
  public List<MstDeviceEdge> findById(String facilityCd) {
    List<MstDeviceEdge> data;
    try {
      data = this.mstDeviceEdgeDao.selectByFacilityCd(facilityCd);
    } catch (Exception e) {
      data = null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ")");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"MstDeviceEdgeDao/selectByFacilityCd");
    }

    return data;
  }
}
