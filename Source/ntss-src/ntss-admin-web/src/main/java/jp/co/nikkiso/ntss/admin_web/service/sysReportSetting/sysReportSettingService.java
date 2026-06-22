package jp.co.nikkiso.ntss.admin_web.service.sysReportSetting;

import jp.co.nikkiso.ntss.core.entity.SysReportSetting;

import java.util.List;

/**
 * 機能帳票設定のServiceインタフェース.
 */
public interface sysReportSettingService {

  /**
   * 機能帳票設定を取得します.
   */
  //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 start
  //List<SysReportSetting> getAllSysReportSetting();
  List<SysReportSetting> getAllSysReportSetting(String facilityCd);
  //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 end
}
