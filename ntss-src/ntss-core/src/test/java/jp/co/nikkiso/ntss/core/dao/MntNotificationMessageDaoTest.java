package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MntNotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MntNotificationStatus;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * {@link MntNotificationMessageDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MntNotificationMessageDaoTest.before.sql")
public class MntNotificationMessageDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MntNotificationMessageDao target;

  /**
   * 通知状態管理Dao.
   */
  @Autowired
  private MntNotificationStatusDao mntNotificationStatusDao;

  /**
   * selectByUserId()の検証.
   *
   * 条件：ユーザーIDが "3" の通知メッセージ情報が登録されている(通知済フラグは "未通知"、並び替え順は "昇順")
   * 結果：条件に該当する通知メッセージ情報が取得できること
   */
  @Test
  public void test_selectByUserId_正常_未通知_昇順() {
    // 事前準備
    final Long userId = 3L;

    // 実行
    List<NotificationMessage> results = target.selectByUserId(userId, "0", false);

    // 検証
    assertThat(results).isNotNull();
    assertThat(results).hasSize(2);
    assertThat(results.get(0).getNotificationMessageNo()).isEqualTo(10);
    assertThat(results.get(0).getContent()).isEqualTo("テストメッセージ内容1");
    assertThat(results.get(0).getAdditionalInfo()).isEqualTo("{\"item01\": \"value01\", \"item02\": \"value02\"}");
    assertThat(results.get(0).getIsRead()).isEqualTo("0");
    assertThat(results.get(0).getRegDate()).isEqualTo(Timestamp.valueOf("2019-08-05 12:00:00"));
    assertThat(results.get(1).getNotificationMessageNo()).isEqualTo(30);
    assertThat(results.get(1).getContent()).isEqualTo("テストメッセージ内容3");
    assertThat(results.get(1).getAdditionalInfo()).isEqualTo("{\"item01\": \"value01\"}");
    assertThat(results.get(1).getIsRead()).isEqualTo("1");
    assertThat(results.get(1).getRegDate()).isEqualTo(Timestamp.valueOf("2019-08-05 12:00:02"));
  }

  /**
   * selectByUserId()の検証.
   *
   * 条件：ユーザーIDが "3" の通知メッセージ情報が登録されている(通知済フラグは 未指定、並び替え順は "降順")
   * 結果：条件に該当する通知メッセージ情報が取得できること
   */
  @Test
  public void test_selectByUserId_正常_未指定_降順() {
    // 事前準備
    final Long userId = 3L;

    // 実行
    List<NotificationMessage> results = target.selectByUserId(userId, null, true);

    // 検証
    assertThat(results).isNotNull();
    assertThat(results).hasSize(3);
    assertThat(results.get(0).getNotificationMessageNo()).isEqualTo(30);
    assertThat(results.get(0).getContent()).isEqualTo("テストメッセージ内容3");
    assertThat(results.get(0).getAdditionalInfo()).isEqualTo("{\"item01\": \"value01\"}");
    assertThat(results.get(0).getIsRead()).isEqualTo("1");
    assertThat(results.get(0).getRegDate()).isEqualTo(Timestamp.valueOf("2019-08-05 12:00:02"));
    assertThat(results.get(1).getNotificationMessageNo()).isEqualTo(20);
    assertThat(results.get(1).getContent()).isEqualTo("テストメッセージ内容2");
    assertThat(results.get(1).getAdditionalInfo()).isEqualTo("{\"item01\": \"value01\"}");
    assertThat(results.get(1).getIsRead()).isEqualTo("0");
    assertThat(results.get(1).getRegDate()).isEqualTo(Timestamp.valueOf("2019-08-05 12:00:01"));
    assertThat(results.get(2).getNotificationMessageNo()).isEqualTo(10);
    assertThat(results.get(2).getContent()).isEqualTo("テストメッセージ内容1");
    assertThat(results.get(2).getAdditionalInfo()).isEqualTo("{\"item01\": \"value01\", \"item02\": \"value02\"}");
    assertThat(results.get(2).getIsRead()).isEqualTo("0");
    assertThat(results.get(2).getRegDate()).isEqualTo(Timestamp.valueOf("2019-08-05 12:00:00"));
  }

  /**
   * selectByUserId()の検証.
   *
   * 条件：ユーザーIDが "4" の通知メッセージ情報が登録されていない
   * 結果：通知メッセージ情報が取得できないこと
   */
  @Test
  public void test_selectByUserId_正常_該当データなし() {
    // 事前準備
    final Long userId = 4L;

    // 実行
    List<NotificationMessage> results = target.selectByUserId(userId, null, false);

    // 検証
    assertThat(results).isNotNull();
    assertThat(results).hasSize(0);
  }

  /**
   * insert()の検証.
   *
   * 条件：登録する通知メッセージ情報を指定
   * 結果：登録できること
   */
  @Test
  public void test_insert_正常() {
    // 事前準備
    final String content = "テストメッセージ内容";
    final String additionalInfo = "{\"item01\": \"value01\", \"item02\": \"value02\"}";
    final String facilityCd = "000001";
    MntNotificationMessage mntNotificationMessage = new MntNotificationMessage() {
      {
        setContent(content);
        setAdditionalInfo(additionalInfo);
        setFacilityCd(facilityCd);
      }
    };

    // 実行
    int result = target.insert(mntNotificationMessage);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(1);
    assertThat(mntNotificationMessage.getNotificationMessageNo()).isNotNull();

    MntNotificationMessage inserted = target.selectById(mntNotificationMessage.getNotificationMessageNo());
    assertThat(inserted).isNotNull();
    assertThat(inserted.getContent()).isEqualTo(content);
    assertThat(inserted.getAdditionalInfo()).isEqualTo(additionalInfo);
    assertThat(inserted.getFacilityCd()).isEqualTo(facilityCd);
    assertThat(inserted.getRegDate()).isNotNull();
    assertThat(inserted.getUpDate()).isNotNull();
  }

  /**
   * delete()の検証.
   *
   * 条件：削除対象の通知メッセージ情報が登録されている
   * 結果：削除されること
   */
  @Test
  public void test_delete_正常() {
    // 事前準備
    Timestamp timestamp = Timestamp.valueOf("2019-08-05 12:00:01.000");

    // 実行
    int result = target.delete(timestamp);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).isEqualTo(2);

    MntNotificationMessage deleted = target.selectById(10L);
    assertThat(deleted).isNull();
    deleted = target.selectById(20L);
    assertThat(deleted).isNull();
    deleted = target.selectById(30L);
    assertThat(deleted).isNotNull();

    MntNotificationStatus deletedStatus = mntNotificationStatusDao.selectById(10L, 1L);
    assertThat(deletedStatus).isNull();
    deletedStatus = mntNotificationStatusDao.selectById(10L, 2L);
    assertThat(deletedStatus).isNull();
    deletedStatus = mntNotificationStatusDao.selectById(20L, 1L);
    assertThat(deletedStatus).isNull();
    deletedStatus = mntNotificationStatusDao.selectById(30L, 1L);
    assertThat(deletedStatus).isNotNull();
  }

}
