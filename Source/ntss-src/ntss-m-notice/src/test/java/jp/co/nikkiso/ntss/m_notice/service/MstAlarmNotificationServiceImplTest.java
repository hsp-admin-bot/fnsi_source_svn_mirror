package jp.co.nikkiso.ntss.m_notice.service;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.PERSONAL;
import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import org.assertj.core.api.Assertions;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.m_notice.service.MstAlarmNotificationService.EmailAddressAndName;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class MstAlarmNotificationServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private MstAlarmNotificationService target;

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ1グループのみ対象 結果：メールアドレスとグループ名が取得できること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case1.sql")
  public void test_getEmailAddressAndName_case1_一般ユーザ1グループのみ() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "4505";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String emailsExpected = "test1@esm.co.jp,test1@example.co.jp,test3@esm.co.jp,test4@example.co.jp,test7@esm.co.jp,test8@esm.co.jp";
    assertThat(result.getEmailAddress().length(), is(emailsExpected.length()));
    Assertions.assertThat(result.getEmailAddress()).contains(emailsExpected.split(","));
    assertThat(result.getEmailName(), is("group1"));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ2グループが対象で2グループが取得 結果：メールアドレスとグループ名が取得できること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case2.sql")
  public void test_getEmailAddressAndName_case2_一般ユーザ2グループ_2グループ取得() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "4505";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String emailsExpected = "test1@example.co.jp,test7@esm.co.jp,test8@esm.co.jp,test25@esm.co.jp,test25@example.co.jp,test12@esm.co.jp,test3@esm.co.jp,test7@example.co.jp";
    assertThat(result.getEmailAddress().length(), is(emailsExpected.length()));
    Assertions.assertThat(result.getEmailAddress()).contains(emailsExpected.split(","));
    assertThat(result.getEmailName(), is("group1、group2"));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ2グループが対象でgroup1のみが取得 結果：メールアドレスとグループ名が取得できること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case2.sql")
  public void test_getEmailAddressAndName_case2_一般ユーザ2グループ_group1のみ取得() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "4829";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String emailsExpected = "test1@example.co.jp,test7@esm.co.jp,test8@esm.co.jp,test25@esm.co.jp,test25@example.co.jp";
    assertThat(result.getEmailAddress().length(), is(emailsExpected.length()));
    Assertions.assertThat(result.getEmailAddress()).contains(emailsExpected.split(","));
    assertThat(result.getEmailName(), is("group1"));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ2グループが対象でgroup2のみが取得 結果：メールアドレスとグループ名が取得できること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case2.sql")
  public void test_getEmailAddressAndName_case2_一般ユーザ2グループ_group2のみ取得() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "AC09";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String emailsExpected = "test12@esm.co.jp,test3@esm.co.jp,test7@esm.co.jp,test7@example.co.jp";
    assertThat(result.getEmailAddress().length(), is(emailsExpected.length()));
    Assertions.assertThat(result.getEmailAddress()).contains(emailsExpected.split(","));
    assertThat(result.getEmailName(), is("group2"));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ2グループとNKKユーザ2グループが対象ですべて取得 結果：メールアドレスと一般ユーザのグループ名が取得できること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case3.sql")
  public void test_getEmailAddressAndName_case3_一般ユーザ2グループとNKKユーザ2グループ取得() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "4505";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String emailsExpected = "test1@example.co.jp,test7@esm.co.jp,test8@esm.co.jp,test25@esm.co.jp,test25@example.co.jp,test12@esm.co.jp,test3@esm.co.jp,test7@example.co.jp,ntest1@esm.co.jp,ntest1@example.co.jp,ntest3@esm.co.jp,ntest4@example.co.jp,ntest7@esm.co.jp,ntest8@esm.co.jp,ntest22@esm.co.jp,ntest13@example.co.jp,ntest17@esm.co.jp,ntest17@example.co.jp";
    assertThat(result.getEmailAddress().length(), is(emailsExpected.length()));
    Assertions.assertThat(result.getEmailAddress()).contains(emailsExpected.split(","));
    assertThat(result.getEmailName(), is("group1、group2"));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ2とNKKユーザ2グループが対象で一般ユーザだけ取得 結果：メールアドレスと一般ユーザのグループ名が取得できること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case3.sql")
  public void test_getEmailAddressAndName_case3_一般ユーザ2グループとNKKユーザ2グループで一般ユーザだけ取得() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "4501";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String emailsExpected = "test1@example.co.jp,test7@esm.co.jp,test8@esm.co.jp,test25@esm.co.jp,test25@example.co.jp,test12@esm.co.jp,test3@esm.co.jp,test7@example.co.jp";
    assertThat(result.getEmailAddress().length(), is(emailsExpected.length()));
    Assertions.assertThat(result.getEmailAddress()).contains(emailsExpected.split(","));
    assertThat(result.getEmailName(), is("group1、group2"));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ2とNKKユーザ2グループが対象でNKKユーザだけ取得 結果：メールアドレスが取得できグループ名が空文字であること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case3.sql")
  public void test_getEmailAddressAndName_case3_一般ユーザ2グループとNKKユーザ2グループでNKKユーザだけ取得() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "A500";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String expectedMailAddresses = "ntest1@esm.co.jp,ntest1@example.co.jp,ntest3@esm.co.jp,ntest4@example.co.jp,ntest7@esm.co.jp,ntest8@esm.co.jp,ntest22@esm.co.jp,ntest13@example.co.jp,ntest17@esm.co.jp,ntest17@example.co.jp";
    assertThat(result.getEmailAddress().length(), is(expectedMailAddresses.length()));
    Assertions.assertThat(result.getEmailAddress())
      .contains(expectedMailAddresses.split(","));
    assertThat(result.getEmailName(), is(""));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：警報通知マスタから取得するレコードがない 結果：メールアドレスとグループ名が空文字であること
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case3.sql")
  public void test_getEmailAddressAndName_警報通知マスタから取得するレコードがない() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "9999";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    assertThat(result.getEmailAddress(), is(""));
    assertThat(result.getEmailName(), is(""));

  }

  /**
   * getEmailAddressAndName()の検証.
   * 条件：一般ユーザ1グループのみ対象かつ記入不備メールアドレス有 結果：記入不備があるメールアドレス以外のアドレス情報が取得
   * @throws ParseException
   */
  @Test
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstAlarmNotificationServiceImplTest.beforePersonal2.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstAlarmNotificationServiceImplTest.case1.sql")
  public void test_getEmailAddressAndName_case4_一般ユーザ1グループのみ_メールアドレス一部不備() throws ParseException {

    Timestamp eventRegDate = getTimestamp("2019/04/08 12:30:00");
    String facilityCd = "09999";
    String mahcineRecordCd = "4505";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    mntMotionRecord.setEventRegDate(eventRegDate);
    mntMotionRecord.setFacilityCd(facilityCd);
    mntMotionRecord.setMachineRecordCd(mahcineRecordCd);

    // 実行
    EmailAddressAndName result = target.getEmailAddressAndName(mntMotionRecord);

    // 作成されたデータの確認
    final String emailsExpected = "test1@esm.co.jp,test4+test@example.co.jp,1test7@esm.co.jp,te.st8@esm.co.jp";
    assertThat(result.getEmailAddress().length(), is(emailsExpected.length()));
    Assertions.assertThat(result.getEmailAddress()).contains(emailsExpected.split(","));
    assertThat(result.getEmailName(), is("group1"));

  }


  /**
   * 日付の文字列よりtimestampを取得.
   * @param str 日時（String）
   * @return 日時（TimeStamp）
   * @throws ParseException
   */
  private Timestamp getTimestamp(String str) throws ParseException {
    return new java.sql.Timestamp(
        new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(str).getTime());
  }

}
