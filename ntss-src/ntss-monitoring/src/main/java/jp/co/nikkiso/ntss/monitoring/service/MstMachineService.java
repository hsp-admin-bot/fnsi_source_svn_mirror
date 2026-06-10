package jp.co.nikkiso.ntss.monitoring.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.custom.MstMachineWithState;

/**
 * 装置マスタサービス
 */
public interface MstMachineService {

  List<MstMachine> selectAll();

  MstMachine findByCd(String machineTypeCd, String machineSerial, String facilityCd);
  
  List<MstMachineWithState> findByFacilitywithState(String facility_cd, String machineTypeCd, String machineSerial);

  MstMachine create(MstMachine mstMachine);

  MstMachine update(MstMachine mstMachine);

  void delete(String machineTypeCd, String machineSerial, String facilityCd);
}
