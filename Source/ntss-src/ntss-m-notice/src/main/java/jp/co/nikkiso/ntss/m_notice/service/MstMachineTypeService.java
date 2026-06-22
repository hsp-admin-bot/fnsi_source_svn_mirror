package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachineType;

/**
 * 型式マスタService.
 */
public interface MstMachineTypeService {
  
  List<MstMachineType> selectAll();
  
  MstMachineType findByTypeCd(String machineTypeCd);
  
  MstMachineType create(MstMachineType mstMachineType);
  
  MstMachineType update(MstMachineType mstMachineType);
  
  void delete(String machineTypeCd);
  
}
