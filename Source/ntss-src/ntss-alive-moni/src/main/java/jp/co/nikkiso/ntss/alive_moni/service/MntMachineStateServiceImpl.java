package jp.co.nikkiso.ntss.alive_moni.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;


/**
 * 装置状態管理マスタのService実装クラス.
 */
@Service
public class MntMachineStateServiceImpl implements MntMachineStateService {

  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  private LogService logService;

  @Override
  public List<MntMachineState> findById(String facilityCd) {
    List<MntMachineState> data;
    try {
      data = this.mntMachineStateDao.selectAllByFacilityCd(facilityCd);
    } catch (Exception e) {
      data = null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ")");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"MntMachineStateDao/selectAllByFacilityCd");
    }

    return data;
  }

  @Override
  public int update(MntMachineState machineState) {
    int ret;
    try {
      ret = this.mntMachineStateDao.updateAliveMoni(machineState);
    } catch (Exception e) {
      ret = -1;

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setMachineTypeCd(machineState.getMachineTypeCd());
      eventLogMessage.setSqlIdentification("(facility_cd = " + machineState.getFacilityCd() + ", machine_type_cd" + machineState.getMachineTypeCd() +
      ", machine_serial = " + machineState.getMachineSerial() + ", process_state = " + machineState.getProcessState() + ", is_preventive_mainte = " +
      machineState.getIsPreventiveMainte() + ", up_date = " + machineState.getUpDate() + ")");
      eventLogMessage.setFacilityCd(machineState.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"MntMachineStateDao/updateAliveMoni");
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateAllOnlineMachine(MntMachineState machineState, Integer deviceEdgeNo) {
    int ret;
    try {
      ret = this.mntMachineStateDao.updateProcessStateByEdge(machineState, deviceEdgeNo, true);
    } catch (Exception e) {
      ret = -1;

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setSqlIdentification("(facility_cd = " + machineState.getFacilityCd() + ", device_edge_no" + deviceEdgeNo +
      ", process_state = " + machineState.getProcessState() + ", is_preventive_mainte = " +
      machineState.getIsPreventiveMainte() + ", up_date = " + machineState.getUpDate() + ")");
      eventLogMessage.setFacilityCd(machineState.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"MntMachineStateDao/updateProcessStateByEdge");
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateAllMachine(MntMachineState machineState, Integer deviceEdgeNo) {
    int ret;
    try {
      ret = this.mntMachineStateDao.updateProcessStateByEdge(machineState, deviceEdgeNo, false);
    } catch (Exception e) {
      ret = -1;

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setSqlIdentification("(facility_cd = " + machineState.getFacilityCd() + ", device_edge_no" + deviceEdgeNo +
      ", process_state = " + machineState.getProcessState() + ", is_preventive_mainte = " +
      machineState.getIsPreventiveMainte() + ", up_date = " + machineState.getUpDate() + ")");
      eventLogMessage.setFacilityCd(machineState.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS,"MntMachineStateDao/updateProcessStateByEdge");
    }

    return ret;
  }
}
