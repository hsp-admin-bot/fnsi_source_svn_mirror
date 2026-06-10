package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.dao.TmpCommFailureRecoveryDao;
import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class TmpCommFailureRecoverySeviceImpl implements TmpCommFailureRecoverySevice{

  @Autowired
  TmpCommFailureRecoveryDao tmpCommFailureRecoveryDao;

  public TmpCommFailureRecovery selectMachineKeyCommFail(String facilityCd, String machineTypeCd, String machineSerial){
    return tmpCommFailureRecoveryDao.selectByKey(facilityCd, machineTypeCd, machineSerial);
  }
  @Override
  public int updateTmpCommFailureRecoveryCommFail(TmpCommFailureRecovery param) {
    return tmpCommFailureRecoveryDao.updateTmpCommFailureRecoveryCommFail(param);
  }

  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 start
  @Override
  public int deleteTmpCommFailureRecoveryByKey(String facilityCd, String machineTypeCd, String machineSerial) {
    return tmpCommFailureRecoveryDao.deleteByKey(facilityCd, machineTypeCd, machineSerial);
  }
  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 end
}
