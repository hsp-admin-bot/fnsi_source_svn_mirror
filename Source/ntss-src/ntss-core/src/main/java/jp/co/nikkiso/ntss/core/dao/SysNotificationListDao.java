package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.SysNotificationList;

@ConfigAutowireable
@Dao
public interface SysNotificationListDao {

  /**
   * 通知先リスト登録(端末固有文字列が同じ場合はupdateを行う)
   */
  @Insert(sqlFile = true)
  int upsert(SysNotificationList notification);

  /**
   * 通知先リストを取得.
   * @param facilityCd 施設コード
   * @param userId ユーザID
   * @return 通知先リスト
   */
  @Select
  List<SysNotificationList> selectByFacilityAnduserId(String facilityCd, Long userId);

  /**
   * 通知先リストを取得.
   * @param terminalUniqueString 端末固有文字列
   * @return 通知先リスト
   */
  @Select
  // mod FNSI-外結バッグを修正する 江 start
  //List<SysNotificationList> selectByterminalUniqueString(String terminalUniqueString);
  List<SysNotificationList> selectByterminalUniqueString(String terminalUniqueString,String facilityCd, String userId);
  // mod FNSI-外結バッグを修正する 江 end

  /**
   * 通知先リスト削除
   * @param terminalUniqueString 端末固有文字列
   */
  @Delete(sqlFile = true)
  int deleteByTerminalUniqueString(String terminalUniqueString);

}
