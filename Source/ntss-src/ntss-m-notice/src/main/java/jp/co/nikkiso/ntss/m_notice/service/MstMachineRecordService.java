package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;

/**
 * 装置記録マスタService.
 */
public interface MstMachineRecordService {
  
  List<MstMachineRecord> selectAll();
  
  MstMachineRecord findByCd(String machineRecordCd);
  
  String selectMachineMessage(String machineRecordCd);
  
  MstMachineRecord create (MstMachineRecord mstMachineRecord);
  
  MstMachineRecord update(MstMachineRecord mstMachineRecord);
  
  void delete(String machineRecordCd);
  
}
