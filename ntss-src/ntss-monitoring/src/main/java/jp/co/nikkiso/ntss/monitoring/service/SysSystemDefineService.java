package jp.co.nikkiso.ntss.monitoring.service;

import java.math.BigDecimal;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

/**
 * システム設定マスタService.
 */
public interface SysSystemDefineService {

  List<SysSystemDefine> selectAll();

  SysSystemDefine selectByFacilityCd(String facilityCd);
  
  SysSystemDefine selectDefaultMail();

  SysSystemDefine insert(SysSystemDefine sysSystemDefine);

  void delete(String facilityCd);

  SysSystemDefine update(SysSystemDefine sysSystemDefine);
  
  SysSystemDefine selectByPrimaryKey(String facilityCd, BigDecimal ctlNo);
  
  int insertOrUpdate(SysSystemDefine sysSystemDefine);
  
}
