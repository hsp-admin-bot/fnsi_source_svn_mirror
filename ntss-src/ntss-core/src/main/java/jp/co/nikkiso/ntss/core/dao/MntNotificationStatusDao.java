package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MntNotificationStatus;
import org.seasar.doma.BatchInsert;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * 通知状態管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntNotificationStatusDao {

  /**
   * 通知状態管理を取得します.
   *
   * @param notificationMessageNo 通知メッセージ番号
   * @param userId ユーザーID
   * @return 通知状態管理情報
   */
  @Select
  MntNotificationStatus selectById(Long notificationMessageNo, Long userId);

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<MntNotificationStatus> selectByNotificationMessageNo(Long notificationMessageNo);
  // Add By HandsomeLin At 2023/02/16 End

  /**
   * 通知状態管理を登録します.
   *
   * @param entities 通知状態管理情報
   * @return 登録件数
   */
  @BatchInsert
  int[] insert(List<MntNotificationStatus> entities);

  /**
   * 既読フラグを更新します.
   *
   * @param notificationMessageNos 通知メッセージ番号のリスト
   * @param userId ユーザーID
   * @param isRead 既読フラグ
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateIsRead(List<Long> notificationMessageNos, Long userId, String isRead);

  // add FNSI-通知既読更新を修正 江 start
  /**
   * 既読フラグを更新します.
   *
   * @param userId ユーザーID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateAllIsRead(Long userId);
  // add FNSI-通知既読更新を修正 江 end

  /**
   * 通知済フラグを更新します.
   *
   * @param notificationMessageNos 通知メッセージ番号のリスト
   * @param userId ユーザーID
   * @param isNotified 通知済フラグ
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateIsNotified(List<Long> notificationMessageNos, Long userId, String isNotified);

  /**
   * 未読件数を取得します.
   * @param userId ユーザーID
   * @return 未読件数
   */
  @Select
  int selectUnreadCountByUserId(Long userId);

  /**
   * 件数を取得します.
   * @param userId ユーザーID
   * @return 未読件数
   */
  @Select
  int selectCountByUserIdAndFacilityCd(Long notificationMessageNo, Long userId, String facilityCd);

  //add FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 start
  /**
   * 未読件数を取得します.
   * @param userId ユーザーID
   * @return 未読件数
   */
  @Select
  int selectUnreadCountByUserIdAndFacilityCd(Long userId, String facilityCd);
  //add FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 end
}
