package jp.co.nikkiso.ntss.admin_web.service.sysCoopNo;


import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysCoopNo;

/**
 * 通知一覧のServiceインタフェース.
 */
public interface SysCoopNoService {

  /* FacilityCdによってSysCoopNoを選択します */
  List<SysCoopNo> selectSysCoopNoByFacilityCd(String facilityCd) throws Exception;

  /* 保存 */
	Boolean submit(SysCoopNo sysCoopNo, final Long userId) throws Exception;

}