package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntMNoticeManageDao;
import jp.co.nikkiso.ntss.core.entity.MntMNoticeManage;

/**
 * 緊急発報管理マスタService.
 */
@Service
public class MntMNoticeManageServiceImpl implements MntMNoticeManageService {
  
  @Autowired
  private MntMNoticeManageDao mntMNoticeManageDao;
  
  @Override
  public List<MntMNoticeManage> selectAll() {
    List<MntMNoticeManage> mntMNoticeManage = mntMNoticeManageDao.selectAll();
    return mntMNoticeManage;
  }
  
  @Override
  @Transactional
  public MntMNoticeManage create(MntMNoticeManage mntMNoticeManage) {
    mntMNoticeManageDao.insert(mntMNoticeManage);
    return mntMNoticeManage;
  }
  
  @Override
  public MntMNoticeManage findByManageNo(Long mNoticeManageNo) {
    return mntMNoticeManageDao.selectByManageNo(mNoticeManageNo);
  }
  
  @Override
  @Transactional
  public void delete(Long mNoticeManageNo) {
    MntMNoticeManage mntMNoticeManage = mntMNoticeManageDao.selectByManageNo(mNoticeManageNo);
    if(mntMNoticeManage != null) {
      mntMNoticeManageDao.delete(mntMNoticeManage);
    }
  }
  
  @Override
  @Transactional
  public MntMNoticeManage update(MntMNoticeManage mntMNoticeManage) {
    mntMNoticeManageDao.update(mntMNoticeManage);
    return mntMNoticeManage;
  }
  
}
