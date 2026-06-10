package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstAddressGroupDao;
import jp.co.nikkiso.ntss.core.entity.MstAddressGroup;

/**
 * 宛先グループマスタService.
 */
@Service
public class MstAddressGroupServiceImpl implements MstAddressGroupService {
  
  @Autowired
  private MstAddressGroupDao mstAddressGroupDao;
  
  @Override
  public List<MstAddressGroup> selectAll() {
    List<MstAddressGroup> mstAddressGroupList = mstAddressGroupDao.selectAll();
    return mstAddressGroupList;
  }
  
  @Override
  @Transactional
  public MstAddressGroup create(MstAddressGroup mstAddressGroup) {
    mstAddressGroupDao.insert(mstAddressGroup);
    return mstAddressGroup;
  }
  
  @Override
  public MstAddressGroup findByCd(String addressGroupCd) {
    return mstAddressGroupDao.selectByCd(addressGroupCd);
  }
  
  @Override
  @Transactional
  public void delete(String addressGroupCd) {
    MstAddressGroup mstAddressGroup = mstAddressGroupDao.selectByCd(addressGroupCd);
    if (mstAddressGroup != null) {
      mstAddressGroupDao.delete(mstAddressGroup);
    }
  }
  
  @Override
  @Transactional
  public MstAddressGroup update(MstAddressGroup mstAddressGroup) {
    mstAddressGroupDao.update(mstAddressGroup);
    return mstAddressGroup;
  }
  
}
