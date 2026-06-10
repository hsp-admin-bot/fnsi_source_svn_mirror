package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MntNotificationMessage;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.sql.Timestamp;
import java.util.List;

/**
 * 通知メッセージのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntNotificationMessageDao {

  /**
   * 通知メッセージを取得します.
   *
   * @param notificationMessageNo 通知メッセージ番号
   * @return 通知メッセージ情報
   */
  @Select
  MntNotificationMessage selectById(Long notificationMessageNo);

  /**
   * ユーザーIDをもとに通知メッセージを取得します.
   *
   * @param userId ユーザーID
   * @param isNotified 通知済フラグ
   * @param isDesc 登録日時の降順で取得するかどうか(<code>true</code>の場合、降順、それ以外の場合、昇順)
   * @return 通知メッセージ情報のリスト
   */
  @Select
  List<NotificationMessage> selectByUserId(Long userId, String isNotified, boolean isDesc);

  // add FNSI-重要通知設定の追加 江 start
  /**
   * ユーザーIDをもとに通知メッセージを取得します.
   *
   * @param userId ユーザーID
   * @param isNotified 通知済フラグ
   * @param isDesc 登録日時の降順で取得するかどうか(<code>true</code>の場合、降順、それ以外の場合、昇順)
   * @return 通知メッセージ情報のリスト
   */
  @Select
  // mod FNSI-通知表示が遅いを修正 江 start
  //List<NotificationMessage> selectNotificationMessageByUserId(Long userId, String isNotified, boolean isDesc, List<Integer> notificationNoList);
  List<NotificationMessage> selectNotificationMessageByUserId(Long userId, String isNotified, boolean isDesc, List<Integer> notificationNoList, Integer offset, String facilityCd);
  // mod FNSI-通知表示が遅いを修正 江 end
  // add FNSI-重要通知設定の追加 江 end

  // del #10110 通知一覧から既読にした通知以外も消える dengshen start
  // // add FNSI redmine 4893 修正 鄧シン start
  // /**
  //  * ユーザーIDをもとに通知メッセージを取得します.
  //  *
  //  * @param userId ユーザーID
  //  * @param isNotified 通知済フラグ
  //  * @param isDesc 登録日時の降順で取得するかどうか(<code>true</code>の場合、降順、それ以外の場合、昇順)
  //  * @return 通知メッセージ情報のリスト
  //  */
  // @Select
  // List<NotificationMessage> selectNotificationMessageAfterChangeByUserId(Long userId, String isNotified, boolean isDesc, List<Integer> notificationNoList, Integer offset, String facilityCd);
  // // add FNSI redmine 4893 修正 鄧シン end
  // del #10110 通知一覧から既読にした通知以外も消える dengshen end

  //add FNSi6531通知が重複して行われる 周 start
  /**
   * 通知メッセージを取得します.
   *
   * @param facilityCd 施設コード
   * @param notificationNo 通知番号
   * @return 登録した通知メッセージ数
   */
  @Select
  List<MntNotificationMessage> selectMntNotificationMessageByNotificationNo(String facilityCd, Long notificationNo);
  //add FNSi6531通知が重複して行われる 周 end

  /**
   * 通知メッセージを登録します.
   *
   * @param entity 通知メッセージ情報
   * @return 登録件数
   */
  @Insert
  int insert(MntNotificationMessage entity);

  // add bug 6522 修正 chen start
  /**
   * 通知メッセージを取得します.
   *
   * @param entity 通知メッセージ情報
   * @return メッセージ情報
   */
  // @Select
  // List<MntNotificationMessage> selectMntNotificationMessageForFly(MntNotificationMessage entity);
  // add bug 6522 修正 chen start

  /**
   * 通知メッセージを削除します.
   *
   * @param deleteDate 削除対象日時
   * @return 削除件数
   */
  @Delete(sqlFile = true)
  int delete(Timestamp deleteDate);

}
