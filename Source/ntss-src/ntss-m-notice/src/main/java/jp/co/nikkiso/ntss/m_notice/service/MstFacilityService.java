package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstFacility;

/**
 * 施設マスタService.
 */
public interface MstFacilityService {
  
  List<MstFacility> selectAll();
  
  MstFacility findByCd(String facilityCd);
  
  MstFacility create(MstFacility mstFacility);
  
  MstFacility update(MstFacility mstFacility);
  
  void delete(String facilityCd);

}
