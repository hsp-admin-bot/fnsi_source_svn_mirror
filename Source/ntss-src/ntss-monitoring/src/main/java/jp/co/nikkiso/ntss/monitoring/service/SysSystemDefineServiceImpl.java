package jp.co.nikkiso.ntss.monitoring.service;

import java.math.BigDecimal;
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
  public SysSystemDefine selectByPrimaryKey(String facilityCd, BigDecimal ctlNo) {
    SysSystemDefine sysSystemDefine = sysSystemDefineDao.selectByPrimaryKey(facilityCd, ctlNo);
    return sysSystemDefine;
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
  @Transactional
  public int insertOrUpdate(SysSystemDefine sysSystemDefine) {
    SysSystemDefine sysSystemDefineBase = sysSystemDefineDao.selectByPrimaryKey(sysSystemDefine.getFacilityCd(), sysSystemDefine.getCtlNo());
    if(sysSystemDefineBase == null) {
      // 新規登録
      sysSystemDefineDao.insertDefine(sysSystemDefine);
      return 1;
    }
    if(sysSystemDefine.getUpDate() == null || 
        sysSystemDefineBase.getUpDate().after(sysSystemDefine.getUpDate())) {
      // DBのデータのほうが新しい
      return -1;
    }
    sysSystemDefineDao.updateDefine(sysSystemDefine);
    return 1;
  }
  
}
