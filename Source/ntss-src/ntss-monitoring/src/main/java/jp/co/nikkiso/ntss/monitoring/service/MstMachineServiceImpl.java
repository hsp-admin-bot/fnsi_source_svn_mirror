package jp.co.nikkiso.ntss.monitoring.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.custom.MstMachineWithState;

/**
 * 装置マスタサービス
 */
@Service
public class MstMachineServiceImpl implements MstMachineService{

  @Autowired
  private MstMachineDao mstMachineDao;

  @Override
  public List<MstMachine> selectAll() {
    List<MstMachine> mstMachineList = mstMachineDao.selectAll();
    return mstMachineList;
  }

  @Override
  @Transactional
  public MstMachine create(MstMachine mstMachine) {
    mstMachineDao.insert(mstMachine);
    return mstMachine;
  }

  @Override
  public MstMachine findByCd(String machineTypeCd, String machineSerial, String facilityCd) {
    return mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);
  }

  @Override
  @Transactional
  public void delete(String machineTypeCd, String machineSerial, String facilityCd) {
    MstMachine mstMachine = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);
    if(mstMachine != null) {
      mstMachineDao.delete(mstMachine);
    }
  }

  @Override
  @Transactional
  public MstMachine update(MstMachine mstMachine) {
    mstMachineDao.update(mstMachine);
    return mstMachine;
  }

  @Override
  public List<MstMachineWithState> findByFacilitywithState(String facilityCd, String machineTypeCd, String machineSerial) {
    List<MstMachineWithState> mstMachineList = mstMachineDao.selectWithState(facilityCd, machineTypeCd, machineSerial);
    return mstMachineList;
  }
}
