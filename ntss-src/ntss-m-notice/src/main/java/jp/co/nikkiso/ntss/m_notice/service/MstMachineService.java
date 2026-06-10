package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachine;

/**
 * 装置マスタService.
 */
public interface MstMachineService {
  
  List<MstMachine> selectAll();
  
  MstMachine findByCd(String machineTypeCd, String machineSerial, String facilityCd);
  
  MstMachine create(MstMachine mstMachine);
  
  MstMachine update(MstMachine mstMachine);
  
  void delete(String machineTypeCd, String machineSerial, String facilityCd);
  
}
