package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstMNoticeDao;
import jp.co.nikkiso.ntss.core.entity.MstMNotice;

/**
 * 緊急発報マスタService.
 */
@Service
public class MstMNoticeServiceImpl implements MstMNoticeService{

  @Autowired
  private MstMNoticeDao mstMNoticeDao;
  
  @Override
  public List<MstMNotice> selectAll(){
    List<MstMNotice> mstMNoticeList = mstMNoticeDao.selectAll();
    return mstMNoticeList;
  }
  
  @Override
  @Transactional
  public MstMNotice create(MstMNotice mstMNotice) {
    mstMNoticeDao.insert(mstMNotice);
    return mstMNotice;
  }
  
  @Override
  public MstMNotice findByCd(String facilityCd, String machineRecordCd) {
    return mstMNoticeDao.selectByCd(facilityCd, machineRecordCd);
  }
  
  @Override
  @Transactional
  public void delete(String facilityCd, String machineRecordCd) {
    MstMNotice mstMNotice = mstMNoticeDao.selectByCd(facilityCd, machineRecordCd);
    if(mstMNotice != null) {
      mstMNoticeDao.delete(mstMNotice);
    }
  }
  
  @Override
  @Transactional
  public MstMNotice update(MstMNotice mstMNotice) {
    mstMNoticeDao.update(mstMNotice);
    return mstMNotice;
  }
  
}
