package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstStaffFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;

/**
 * 担当者施設マスタService.
 */
@Service
public class MstStaffFacilityServiceImpl implements MstStaffFacilityService {

  @Autowired
  private MstStaffFacilityDao mstStaffFacilityDao;

  @Override
  public List<MstStaffFacility> selectAll() {
    List<MstStaffFacility> mstStaffFacilityList = mstStaffFacilityDao.selectAll();
    return mstStaffFacilityList;
  }

  @Override
  public List<MstStaffFacility> selectByUserCd(Long userId) {
    List<MstStaffFacility> mstStaffFacilityList = mstStaffFacilityDao.selectByUserId(userId);
    return mstStaffFacilityList;
  }

  @Override
  @Transactional
  public MstStaffFacility create(MstStaffFacility mstStaffFacility) {
    mstStaffFacilityDao.insert(mstStaffFacility);
    return mstStaffFacility;
  }

  @Override
  public MstStaffFacility findByKey(Long userId, String facilityCd) {
    return mstStaffFacilityDao.selectByKey(userId, facilityCd);
  }

  @Override
  @Transactional
  public void delete(Long userId, String facilityCd) {
    MstStaffFacility mstStaffFacility = mstStaffFacilityDao.selectByKey(userId, facilityCd);
    if (mstStaffFacility != null) {
      mstStaffFacilityDao.delete(mstStaffFacility);
    }
  }

  @Override
  @Transactional
  public MstStaffFacility update(MstStaffFacility mstStaffFacility) {
    mstStaffFacilityDao.update(mstStaffFacility);
    return mstStaffFacility;
  }

}
