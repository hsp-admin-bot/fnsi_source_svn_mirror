package jp.co.nikkiso.ntss.admin_web.service.sysSystemDefine;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

public interface SysSystemDefineService {

  /**
   * システム設定を取得します.
   *
   * @param ctlNo 管理番号
   */
  List<SysSystemDefine> getSysSystemDefine(int ctlNo);

}
