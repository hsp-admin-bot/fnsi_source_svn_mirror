package jp.co.nikkiso.ntss.admin_web.service.sysNotification;


import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysNotification;

/**
 * 通知一覧のServiceインタフェース.
 */
public interface SysNotificationService {

  /**
   * 通知定義情報を取得します.
   */
  List<SysNotification> getSysNotificationAll();

}
