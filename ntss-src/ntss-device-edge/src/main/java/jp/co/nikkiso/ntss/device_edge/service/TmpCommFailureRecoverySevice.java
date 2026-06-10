package jp.co.nikkiso.ntss.device_edge.service;


import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;

public interface TmpCommFailureRecoverySevice {
  TmpCommFailureRecovery selectMachineKeyCommFail(String facilityCd, String machineTypeCd, String machineSerial);
  int updateTmpCommFailureRecoveryCommFail(TmpCommFailureRecovery param);
  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 start
  int deleteTmpCommFailureRecoveryByKey(String facilityCd, String machineTypeCd, String machineSerial);
  //add 装置状態管理の削除方法を追加します(AWSとDEの通信断からの復旧) 劉 end
}
