package jp.co.nikkiso.ntss.admin_web.service.sysReportSetting;

import jp.co.nikkiso.ntss.core.dao.SysReportSettingDao;
import jp.co.nikkiso.ntss.core.entity.SysReportSetting;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 機能帳票設定のサービスクラス.
 */
@Service
public class sysReportSettingServiceImpl implements sysReportSettingService {

  /**
   * {@link SysReportSettingDao}インタフェース.
   */
  @Autowired
  private SysReportSettingDao sysReportSettingDao;

  /**
   * 機能帳票設定データ収集
   */
  @Override
  //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 start
//  public List<SysReportSetting> getAllSysReportSetting() {
//    return sysReportSettingDao.selectAll();
//  }
  public List<SysReportSetting> getAllSysReportSetting(String facilityCd) {
    return sysReportSettingDao.selectAll(facilityCd);
  }
  //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 end
}
