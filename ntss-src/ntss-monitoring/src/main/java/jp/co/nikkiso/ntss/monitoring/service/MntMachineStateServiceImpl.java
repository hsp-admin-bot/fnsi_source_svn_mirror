package jp.co.nikkiso.ntss.monitoring.service;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;

import java.util.List;

@Service
public class MntMachineStateServiceImpl implements MntMachineStateService {

  @Autowired
  MntMachineStateDao mntMachineStateDao;
  
  @Override
  public List<ComsvMntMachineState> selectByFacility(String facilityCd) {
    return mntMachineStateDao.selectByFacilityCd(facilityCd);
  }

  @Override
  public MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial) {
    return mntMachineStateDao.selectByKey(facilityCd, machineTypeCd, machineSerial);
  }

  @Override
  public int updateAlarmList(String facilityCd, String machineTypeCd, String machineSerial, String alarmList) {
    return mntMachineStateDao.updateAlarmList(facilityCd, machineTypeCd, machineSerial, alarmList);
  }

}
