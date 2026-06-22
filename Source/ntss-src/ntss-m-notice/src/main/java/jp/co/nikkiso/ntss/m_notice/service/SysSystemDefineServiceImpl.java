package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

/**
 * システム設定マスタService.
 */
@Service
public class SysSystemDefineServiceImpl implements SysSystemDefineService {

  @Autowired
  SysSystemDefineDao sysSystemDefineDao;

  @Override
  public List<SysSystemDefine> selectAll() {
   List<SysSystemDefine> sysSystemDefineList = sysSystemDefineDao.selectAll();
   return sysSystemDefineList;
  }

  @Override
  public SysSystemDefine selectByFacilityCd(String facilityCd) {
    SysSystemDefine sysSystemDefine = sysSystemDefineDao.selectByFacilityCd(facilityCd);
    return sysSystemDefine;
  }

  @Override
  public SysSystemDefine selectDefaultMail() {
    SysSystemDefine sysSystemDefine = sysSystemDefineDao.selectDefaultMail();
    return sysSystemDefine;
  }

  @Override
  public String selectNoticeMailAddress() {
    String noticeMailAddress = sysSystemDefineDao.selectNoticeMailAddress();
    return noticeMailAddress;
  }

  @Override
  @Transactional
  public SysSystemDefine insert(SysSystemDefine sysSystemDefine) {
    sysSystemDefineDao.insert(sysSystemDefine);
    return sysSystemDefine;
  }

  @Override
  @Transactional
  public void delete(String facilityCd) {
    SysSystemDefine sysSystemDefine = sysSystemDefineDao.selectByFacilityCd(facilityCd);
    if(sysSystemDefine != null) {
      sysSystemDefineDao.delete(sysSystemDefine);
    }
  }

  @Override
  @Transactional
  public SysSystemDefine update(SysSystemDefine sysSystemDefine) {
    sysSystemDefineDao.update(sysSystemDefine);
    return sysSystemDefine;
  }

  @Override
  public SysSystemDefine selectByCtlNoAndServiceCd(int ctlNo, String serviceCd) {
	  SysSystemDefine systemDefine = sysSystemDefineDao.selectByCtlNoAndServiceCd(ctlNo, serviceCd);
	return systemDefine;
  }

}
