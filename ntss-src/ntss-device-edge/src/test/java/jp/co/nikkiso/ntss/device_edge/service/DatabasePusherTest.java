package jp.co.nikkiso.ntss.device_edge.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.ParseException;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.ExternalAlarmCode;


/**
 * {@link DatabasePusher}のテストケースです。
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.service/DatabasePusherTest.before.sql")
public class DatabasePusherTest {

  /**
   * 以下、#3018 外部警報メッセージ変換 のテスト
   * 実際のモジュールを動作させる環境が無かったため自動テストにて実施
   */
  @Autowired
  private DatabasePusher databasePusher;

  /**
   * convertExternalAlarmMessage(privateメソッド)をinvokeする.
   *
   * @param machineRecordCd, facilityCd, message
   * @return
   * @throws Throwable
   */
  private String invokeConvertExternalAlarmMessage(String machineRecordCd, String facilityCd, String message) throws Throwable {
    try {
      Method method = DatabasePusher.class.getDeclaredMethod("convertExternalAlarmMessage", String.class, String.class, String.class);
      method.setAccessible(true);
      return (String) method.invoke(databasePusher, machineRecordCd, facilityCd, message);
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

  /**
   * 装置記録コードなし時の検証.
   * 条件：装置記録なし(null) 結果：元のメッセージがそのまま返ること、装置記録コードがnullのままであること
   * @throws ParseException
   */
  @Test
  public void 装置記録コードなし時の検証() throws ParseException {

    String facilityCd = "09999";
    String machineRecordCd = null;
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
    assertThat(mntMotionRecord.getMachineRecordCd(), is(nullValue()));
    assertThat(mntMotionRecord.getMachineRecordMessage(), is(messageExpected));
  }

}
