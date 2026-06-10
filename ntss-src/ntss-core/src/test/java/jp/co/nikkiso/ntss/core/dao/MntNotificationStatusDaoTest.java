package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MntNotificationStatus;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Arrays;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * {@link MntNotificationStatusDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntNotificationStatusDaoTest.before.sql")
public class MntNotificationStatusDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MntNotificationStatusDao target;

  /**
   * updateIsRead()の検証.
   *
   * 条件：更新する通知メッセージ番号と既読フラグ（既読）を指定
   * 結果：更新できること
   */
  @Test
  public void test_updateIsRead_正常_既読に更新() {
    // 事前準備
    final List<Long> nos = Arrays.asList(1L, 2L, 4L);
    final Long userId = 11L;
    final String isRead = "1";
    final String isNotRead = "0";

    // 実行
    int result = target.updateIsRead(nos, userId, isRead);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(3);

    // 更新後検証
    MntNotificationStatus updated1 = target.selectById(1L, 11L);
    assertThat(updated1.getIsRead()).isEqualTo(isRead);
    MntNotificationStatus updated2 = target.selectById(1L, 12L);
    assertThat(updated2.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated3 = target.selectById(2L, 11L);
    assertThat(updated3.getIsRead()).isEqualTo(isRead);
    MntNotificationStatus updated4 = target.selectById(3L, 11L);
    assertThat(updated4.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated5 = target.selectById(4L, 11L);
    assertThat(updated5.getIsRead()).isEqualTo(isRead);
    MntNotificationStatus updated6 = target.selectById(5L, 11L);
    assertThat(updated6.getIsRead()).isEqualTo(isRead);
  }

  /**
   * updateIsRead()の検証.
   *
   * 条件：更新する通知メッセージ番号と既読フラグ（未読）を指定
   * 結果：更新できること
   */
  @Test
  public void test_updateIsRead_正常_未読に更新() {
    // 事前準備
    final List<Long> nos = Arrays.asList(1L, 2L, 4L);
    final Long userId = 11L;
    final String isRead = "1";
    final String isNotRead = "0";

    // 実行
    int result = target.updateIsRead(nos, userId, isNotRead);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(3);

    // 更新後検証
    MntNotificationStatus updated1 = target.selectById(1L, 11L);
    assertThat(updated1.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated2 = target.selectById(1L, 12L);
    assertThat(updated2.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated3 = target.selectById(2L, 11L);
    assertThat(updated3.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated4 = target.selectById(3L, 11L);
    assertThat(updated4.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated5 = target.selectById(4L, 11L);
    assertThat(updated5.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated6 = target.selectById(5L, 11L);
    assertThat(updated6.getIsRead()).isEqualTo(isRead);
  }

  /**
   * updateIsRead()の検証.
   *
   * 条件：該当データなし
   * 結果：更新結果が0となること
   */
  @Test
  public void test_updateIsRead_異常_更新データなし() {
    // 事前準備
    final List<Long> nos = Arrays.asList(1L, 2L, 4L);
    final Long userId = 999L;
    final String isRead = "1";
    final String isNotRead = "0";

    // 実行
    int result = target.updateIsRead(nos, userId, isRead);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(0);

    // 更新後検証
    MntNotificationStatus updated1 = target.selectById(1L, 11L);
    assertThat(updated1.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated2 = target.selectById(1L, 12L);
    assertThat(updated2.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated3 = target.selectById(2L, 11L);
    assertThat(updated3.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated4 = target.selectById(3L, 11L);
    assertThat(updated4.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated5 = target.selectById(4L, 11L);
    assertThat(updated5.getIsRead()).isEqualTo(isRead);
    MntNotificationStatus updated6 = target.selectById(5L, 11L);
    assertThat(updated6.getIsRead()).isEqualTo(isRead);
  }

  /**
   * updateIsNotified()の検証.
   *
   * 条件：更新する通知メッセージ番号と通知済フラグを指定
   * 結果：更新できること
   */
  @Test
  public void test_updateIsNotified_正常_通知済に更新() {
    // 事前準備
    final List<Long> nos = Arrays.asList(1L, 2L, 4L);
    final Long userId = 11L;

    // 実行
    int result = target.updateIsNotified(nos, userId, "1");

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(3);

    // 更新後検証
    MntNotificationStatus updated1 = target.selectById(1L, 11L);
    assertThat(updated1.getIsNotified()).isEqualTo("1");
    MntNotificationStatus updated2 = target.selectById(1L, 12L);
    assertThat(updated2.getIsNotified()).isEqualTo("0");
    MntNotificationStatus updated3 = target.selectById(2L, 11L);
    assertThat(updated3.getIsNotified()).isEqualTo("1");
    MntNotificationStatus updated4 = target.selectById(3L, 11L);
    assertThat(updated4.getIsNotified()).isEqualTo("0");
    MntNotificationStatus updated5 = target.selectById(4L, 11L);
    assertThat(updated5.getIsNotified()).isEqualTo("1");
    MntNotificationStatus updated6 = target.selectById(5L, 11L);
    assertThat(updated6.getIsNotified()).isEqualTo("0");
  }

  /**
   * updateIsNotified()の検証.
   *
   * 条件：該当データなし
   * 結果：更新結果が0となること
   */
  @Test
  public void test_updateIsNotified_異常_更新データなし() {
    // 事前準備
    final List<Long> nos = Arrays.asList(1L, 2L, 4L);
    final Long userId = 999L;

    // 実行
    int result = target.updateIsRead(nos, userId, "1");

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(0);

    // 更新後検証
    MntNotificationStatus updated1 = target.selectById(1L, 11L);
    assertThat(updated1.getIsNotified()).isEqualTo("0");
    MntNotificationStatus updated2 = target.selectById(1L, 12L);
    assertThat(updated2.getIsNotified()).isEqualTo("0");
    MntNotificationStatus updated3 = target.selectById(2L, 11L);
    assertThat(updated3.getIsNotified()).isEqualTo("0");
    MntNotificationStatus updated4 = target.selectById(3L, 11L);
    assertThat(updated4.getIsNotified()).isEqualTo("0");
    MntNotificationStatus updated5 = target.selectById(4L, 11L);
    assertThat(updated5.getIsNotified()).isEqualTo("0");
    MntNotificationStatus updated6 = target.selectById(5L, 11L);
    assertThat(updated6.getIsNotified()).isEqualTo("0");
  }

  /**
   * selectUnreadCountByUserId()の検証.
   *
   * 条件：未読件数が1件以上
   * 結果：未読件数（1件以上）が取得できること
   */
  @Test
  public void test_selectUnreadCountByUserId_正常未読件数が1件以上() {
    // 事前準備
    final Long userId = 11L;

    // 実行
    int result = target.selectUnreadCountByUserId(userId);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(3);
  }

  /**
   * selectUnreadCountByUserId()の検証.
   *
   * 条件：未読件数が0件
   * 結果：未読件数（0件）が取得できること
   */
  @Test
  public void test_selectUnreadCountByUserId_正常_未読件数が0件() {
    // 事前準備
    final Long userId = 13L;

    // 実行
    int result = target.selectUnreadCountByUserId(userId);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(0);
  }

  /**
   * insert()の検証.
   *
   * 条件：登録する通知状態管理情報を指定
   * 結果：登録できること
   */
  @Test
  public void test_insert_正常() {
    // 事前準備
    final Long notificationMessageNo = 1L;
    final List<Long> userIds = Arrays.asList(1L, 2L);
    final String facilityCd = "000001";
    final List<MntNotificationStatus> entities = userIds.stream()
      .map(u -> new MntNotificationStatus() {
        {
          setNotificationMessageNo(notificationMessageNo);
          setUserId(u);
          setFacilityCd(facilityCd);
        }
      })
      .collect(Collectors.toList());

    // 実行
    int[] result = target.insert(entities);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).hasSize(2);
    assertThat(result[0]).isEqualTo(1);
    assertThat(result[1]).isEqualTo(1);

    MntNotificationStatus inserted = target.selectById(notificationMessageNo, userIds.get(0));
    assertThat(inserted).isNotNull();
    assertThat(inserted.getIsNotified()).isEqualTo(MntNotificationStatus.IS_NOT_NOTIFIED);
    assertThat(inserted.getIsRead()).isEqualTo(MntNotificationStatus.IS_NOT_READ);
    assertThat(inserted.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(inserted.getRegDate()).isNotNull();
    assertThat(inserted.getUpDate()).isNotNull();

    inserted = target.selectById(notificationMessageNo, userIds.get(1));
    assertThat(inserted).isNotNull();
    assertThat(inserted.getIsNotified()).isEqualTo(MntNotificationStatus.IS_NOT_NOTIFIED);
    assertThat(inserted.getIsRead()).isEqualTo(MntNotificationStatus.IS_NOT_READ);
    assertThat(inserted.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(inserted.getRegDate()).isNotNull();
    assertThat(inserted.getUpDate()).isNotNull();
  }

}
