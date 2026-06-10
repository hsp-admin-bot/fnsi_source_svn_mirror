package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstAreaDao;
import jp.co.nikkiso.ntss.core.entity.MstArea;

/**
 * 地域マスタService.
 */
@Service
public class MstAreaServiceImpl implements MstAreaService {
  
  @Autowired
  private MstAreaDao mstAreaDao;
  
  @Override
  public List<MstArea> selectAll() {
    List<MstArea> mstAreaList = mstAreaDao.selectAll();
    return mstAreaList;
  }
  
  @Override
  @Transactional
  public MstArea create(MstArea mstArea) {
    mstAreaDao.insert(mstArea);
    return mstArea;
  }
  
  @Override
  public MstArea findByCd(String areaCd) {
    return mstAreaDao.selectByCd(areaCd);
  }
  
  @Override
  @Transactional
  public void delete(String areaCd) {
    MstArea mstArea = mstAreaDao.selectByCd(areaCd);
    if (mstArea != null) {
      mstAreaDao.delete(mstArea);
    }
  }
  
  @Override
  @Transactional
  public MstArea update(MstArea mstArea) {
    mstAreaDao.update(mstArea);
    return mstArea;
  }
  
}
