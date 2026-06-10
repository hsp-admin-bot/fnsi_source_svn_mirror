package jp.co.nikkiso.ntss.admin_web.service.sysReportClass;

import jp.co.nikkiso.ntss.core.entity.SysReportClass;

import java.util.List;

/**
 * 帳票種別定義のServiceインタフェース.
 */
public interface sysReportClassService {

  /**
   * 帳票種別定義を取得します.
   */
  List<SysReportClass> getAllSysReportClass(int classCd);
}
