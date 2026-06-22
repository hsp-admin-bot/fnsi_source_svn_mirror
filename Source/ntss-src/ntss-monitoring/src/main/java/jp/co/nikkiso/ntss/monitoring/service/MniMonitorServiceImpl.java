package jp.co.nikkiso.ntss.monitoring.service;

import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.custom.MniMonitorSelected;
import jp.co.nikkiso.ntss.monitoring.web.dto.MonitorParameterDto;
import jp.co.nikkiso.ntss.monitoring.web.dto.MonitorParameterDtoEx;

/**
 * モニタリングサービス
 * @author Y.Kataguchi
 *
 */
@Service
public class MniMonitorServiceImpl implements MniMonitorService{
  
  @Autowired
  private MniMonitorDao mniMonitorDao;
  
  @Override
  public List<MniMonitor> selectAll() {
    return mniMonitorDao.selectAll();
  }

  @Override
  public List<MniMonitorSelected> selectPickupByMachine(MonitorParameterDto dto, List<String> keys) {
    return mniMonitorDao.selectPickupByMachine(
        dto.getFacilityCd(),
        dto.getMachineTypeCd(),
        dto.getMachineSerial(),
        dto.getBioMoniCtlNo(),
        dto.getNumOrdNo(),
        dto.getOccurDate(),
        keys);
  }

  @Override
  public List<MniMonitorSelected> selectPickupByMachineEx(MonitorParameterDtoEx dto, List<String> keys) {
    return mniMonitorDao.selectPickupByMachineEx(
        dto.getFacilityCd(),
        dto.getMachineTypeCd(),
        dto.getMachineSerial(),
        dto.getBioMoniCtlNo(),
        dto.getLastBioMoniCtlNo(),
        dto.getOccurDate(),
        dto.getLastOccurDate(),
        keys);
  }

  @Override
  public List<MniMonitorSelected> selectPickupByMachineExDiff(MonitorParameterDto dto, List<String> keys) {
    return mniMonitorDao.selectPickupByMachineExDiff(
        dto.getFacilityCd(),
        dto.getMachineTypeCd(),
        dto.getMachineSerial(),
        dto.getBioMoniCtlNo(),
        dto.getOccurDate(),
        keys);
  }

}
