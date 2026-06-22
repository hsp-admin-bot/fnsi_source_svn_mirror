package jp.co.nikkiso.ntss.admin_web.service.sysReportClass;

import jp.co.nikkiso.ntss.core.dao.SysReportClassDao;
import jp.co.nikkiso.ntss.core.entity.SysReportClass;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 機能帳票設定のサービスクラス.
 */
@Service
public class sysReportClassServiceImpl implements sysReportClassService {

  /**
   * {@link SysReportClassDao}インタフェース.
   */
  @Autowired
  private SysReportClassDao sysReportClassDao;

  /**
   * 機能帳票設定データ収集
   */
  @Override
  public List<SysReportClass> getAllSysReportClass(int classCd) {
    return sysReportClassDao.selectAll(classCd);
  }
}
