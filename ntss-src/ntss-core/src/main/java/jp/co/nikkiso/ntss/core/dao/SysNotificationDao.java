package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysNotification;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 通知メッセージのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysNotificationDao {

  /**
   * 通知定義情報を取得します.
   *
   * @return 通知定義情報
   */
  @Select
  List<SysNotification> selectAll();

  /**
   * 通知定義情報を個別取得します.
   *
   * @return 通知定義情報
   */
  @Select
  SysNotification selectByCd(Long notificationNo);



  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<SysNotification> selectByCdList(List<Long> notificationNoList);
  // Add By HandsomeLin At 2023/02/16 End


}
