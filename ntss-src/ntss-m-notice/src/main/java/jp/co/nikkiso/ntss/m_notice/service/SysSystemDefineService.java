package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

/**
 * システム設定マスタService.
 */
public interface SysSystemDefineService {

  List<SysSystemDefine> selectAll();

  SysSystemDefine selectByFacilityCd(String facilityCd);

  SysSystemDefine selectDefaultMail();

  String selectNoticeMailAddress();

  SysSystemDefine insert(SysSystemDefine sysSystemDefine);

  void delete(String facilityCd);

  SysSystemDefine update(SysSystemDefine sysSystemDefine);

  SysSystemDefine selectByCtlNoAndServiceCd(int ctlNo, String serviceCd);
}
