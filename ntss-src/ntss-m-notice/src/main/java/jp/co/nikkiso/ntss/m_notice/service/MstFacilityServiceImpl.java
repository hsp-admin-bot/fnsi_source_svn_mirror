package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;

/**
 * 施設マスタService.
 */
@Service
public class MstFacilityServiceImpl implements MstFacilityService{
  
  @Autowired
  private MstFacilityDao mstFacilityDao;
  
  @Override
  public List<MstFacility> selectAll(){
    List<MstFacility> mstMNoticeList = mstFacilityDao.selectAll();
    return mstMNoticeList;
  }
  
  @Override
  @Transactional
  public MstFacility create(MstFacility mstFacility) {
    mstFacilityDao.insert(mstFacility);
    return mstFacility;
  }
  
  @Override
  public MstFacility findByCd(String facilityCd) {
    return mstFacilityDao.selectByCd(facilityCd);
  }
  
  @Override
  @Transactional
  public void delete(String facilityCd) {
    MstFacility mstFacility = mstFacilityDao.selectByCd(facilityCd);
    if(mstFacility != null) {
      mstFacilityDao.delete(mstFacility);
    }
  }
  
  @Override
  @Transactional
  public MstFacility update(MstFacility mstFacility) {
    mstFacilityDao.update(mstFacility);
    return mstFacility;
  }

}
