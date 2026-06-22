package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstAddressGroup;

/**
 * 宛先グループマスタService.
 */
public interface MstAddressGroupService {
  
  List<MstAddressGroup> selectAll();
  
  MstAddressGroup findByCd(String addressGroupCd);
  
  MstAddressGroup create(MstAddressGroup mstAddressGroup);
  
  MstAddressGroup update(MstAddressGroup mstAddressGroup);
  
  void delete(String addressGroupCd);
  
}
