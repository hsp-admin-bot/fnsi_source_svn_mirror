package jp.co.nikkiso.ntss.m_notice.service;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.fail;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.io.IOException;
import java.text.ParseException;

import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;
import jp.co.nikkiso.ntss.core.entity.MntMNoticeManage;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ExternalAlarmCode;
import jp.co.nikkiso.ntss.m_notice.packet.InvalidAlertFormatException;

/**
 * {@link MNotice}のテストケースです。
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.service/MNoticeTest.before.sql")
public class MNoticeTest {

  /**
   * テスト対象クラス.
   */
  MNotice service = new MNotice();

  @Ignore
  @Test
  public void 長さが不正な緊急発報の場合にHexStringがMNoticeManageのremarksに設定されてIllegalArgumentExceptionがthrowされること() throws IOException {
    //final byte[] buffer = StreamUtils.copyToByteArray(getClass().getResourceAsStream("invalid_length.dat"));
    final MntMNoticeManage mNoticeManage = new MntMNoticeManage();
    try {
      //service.createMntMotionRecordTelegram(mNoticeManage, buffer);
      fail();
    } catch (IllegalArgumentException e) {
      assertThat(mNoticeManage.getRemarks(), is("3030304e303030303041315444432017102015594030323033000700080009000a17"));
    }
  }

  @Ignore
  @Test
  public void チェックサムが不正な日機装新装置の緊急発報の場合にHexStringがMNoticeManageのremarksに設定されてInvalidAlertFormatExceptionがthrowされること() throws IOException {
    //final byte[] buffer = StreamUtils.copyToByteArray(getClass().getResourceAsStream("invalid_checksum_nkk.dat"));
    final MntMNoticeManage mNoticeManage = new MntMNoticeManage();
    try {
      //service.createMntMotionRecordTelegram(mNoticeManage, buffer);
      fail();
    } catch (InvalidAlertFormatException e) {
      assertThat(mNoticeManage.getRemarks(), is("3030304e303030303041315444435444432017102015594030323033000700080009000a17"));
    }
  }

  @Ignore
  @Test
  public void チェックサムが不正な医機工共通の緊急発報の場合にHexStringがMNoticeManageのremarksに設定されてInvalidAlertFormatExceptionがthrowされること() throws IOException {
    //final byte[] buffer = StreamUtils.copyToByteArray(getClass().getResourceAsStream("invalid_checksum_ikiko.dat"));
    final MntMNoticeManage mNoticeManage = new MntMNoticeManage();
    try {
      //service.createMntMotionRecordTelegram(mNoticeManage, buffer);
      fail();
    } catch (InvalidAlertFormatException e) {
      assertThat(mNoticeManage.getRemarks(), is("3030304e303030303041315444435444432017102015594030323033202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202017"));
    }
  }


  /**
   * 以下、#3018 外部警報メッセージ変換 のテスト
   * 実際のモジュールを動作させる環境が無かったため自動テストにて実施
   */
  @Autowired
  private MNotice mNotice;

  /**
   * convertExternalAlarmMessage(privateメソッド)をinvokeする.
   *
   * @param machineRecordCd, facilityCd, message
   * @return
   * @throws Throwable
   */
  private String invokeConvertExternalAlarmMessage(String machineRecordCd, String facilityCd, String message) throws Throwable {
    try {
      Method method = MNotice.class.getDeclaredMethod("convertExternalAlarmMessage", String.class, String.class, String.class);
      method.setAccessible(true);
      return (String) method.invoke(mNotice, machineRecordCd, facilityCd, message);
    } catch (InvocationTargetException e) {
      throw e.getCause();
    } catch (NoSuchMethodException | IllegalAccessException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    }
    return null;
  }

  /**
   * 外部警報1ONメッセージ変換の検証.
   * 条件：外部警報1ONのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報1ONメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_1_ON;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報1ONのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報2ONメッセージ変換の検証.
   * 条件：外部警報2ONのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報2ONメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_2_ON;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報2ONのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報3ONメッセージ変換の検証.
   * 条件：外部警報3ONのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報3ONメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_3_ON;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報3ONのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報4ONメッセージ変換の検証.
   * 条件：外部警報4ONのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報4ONメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_4_ON;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報4ONのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報1OFFメッセージ変換の検証.
   * 条件：外部警報1OFFのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報1OFFメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_1_OFF;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報1OFFのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報2OFFメッセージ変換の検証.
   * 条件：外部警報2OFFのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報2OFFメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_2_OFF;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報2OFFのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報3OFFメッセージ変換の検証.
   * 条件：外部警報3OFFのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報3OFFメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_3_OFF;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報3OFFのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報4OFFメッセージ変換の検証.
   * 条件：外部警報4OFFのメッセージを入力 結果：施設設定マスタで指定された値に変換できること
   * @throws ParseException
   */
  @Test
  public void 外部警報4OFFメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = ExternalAlarmCode.EXTERNAL_ALARM_4_OFF;
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "外部警報4OFFのメッセージです";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

  /**
   * 外部警報以外のメッセージ変換の検証.
   * 条件：外部警報ではないメッセージを入力 結果：元のメッセージがそのまま返ること
   * @throws ParseException
   */
  @Test
  public void 外部警報以外のメッセージ変換の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = "0000";
    String message = "変換前のメッセージです。";

    MntMotionRecord mntMotionRecord = new MntMotionRecord();

    // 実行
    try {
      mntMotionRecord.setMachineRecordMessage(invokeConvertExternalAlarmMessage(machineRecordCd, facilityCd, message));
    } catch (Throwable e1) {
//      e1.printStackTrace();
    }

    // 作成されたデータの確認
    final String messageExpected = "変換前のメッセージです。";
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }
}
