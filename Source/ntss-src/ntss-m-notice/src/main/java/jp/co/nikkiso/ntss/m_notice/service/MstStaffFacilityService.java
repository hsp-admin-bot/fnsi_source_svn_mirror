package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;

/**
 * 担当者施設マスタService.
 */
public interface MstStaffFacilityService {

  List<MstStaffFacility> selectAll();

  List<MstStaffFacility> selectByUserCd(Long userId);

  MstStaffFacility findByKey(Long userId, String facilityCd);

  MstStaffFacility create(MstStaffFacility mstStaffFacility);

  MstStaffFacility update(MstStaffFacility mstStaffFacility);

  void delete(Long userId, String facilityCd);

}
