package jp.co.nikkiso.ntss.admin_web.service.sysNotification;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.SysNotificationDao;
import jp.co.nikkiso.ntss.core.entity.SysNotification;

@Service
public class SysNotificationServiceImpl implements SysNotificationService {
  
  /**
   * 通知定義のDaoインタフェース.
   */
  @Autowired
  SysNotificationDao sysNotificationDao;

  @Override
  public List<SysNotification> getSysNotificationAll() {
    return sysNotificationDao.selectAll();
  }

}
