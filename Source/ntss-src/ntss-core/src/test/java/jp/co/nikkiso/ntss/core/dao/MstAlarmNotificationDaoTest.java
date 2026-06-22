package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification.TargetMachineRecord;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification.TargetMachineRecordCd;

/**
 * {@link SysMasterDefineDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MstAlarmNotificationDaoTest.before.sql")
public class MstAlarmNotificationDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MstAlarmNotificationDao target;

  /**
   * selectByFacilityCd()の検証.
   * <p>
   * 条件：データが1件存在する施設コードを指定 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectByFacilityCd_正常_データ1件あり() {
    // 実行
    List<MstAlarmNotification> result = target.selectByFacilityCd("00001");

    // 検証
    assertThat(result).hasSize(1);
    assertThat(result.get(0).getAlarmNotificationCd()).isEqualTo(1L);
    assertThat(result.get(0).getFacilityCd()).isEqualTo("00001");
    assertThat(result.get(0).getAlarmNotificationName()).isEqualTo("通知1");
    assertThat(result.get(0).getDestinationFacilityCd()).isEqualTo("00009");
    assertThat(result.get(0).getDestinationGroupCd()).isEqualTo(10L);
    assertThat(result.get(0).getIsDisp()).isEqualTo("1");
    assertThat(result.get(0).getIsDel()).isEqualTo("0");
    assertThat(result.get(0).getIsNoticeMon()).isEqualTo("0");
    assertThat(result.get(0).getStartTimeMon()).isEqualTo("12:00");
    assertThat(result.get(0).getEndTimeMon()).isEqualTo("18:00");
    assertThat(result.get(0).getIsNextDayMon()).isEqualTo("1");
    assertThat(result.get(0).getIsNoticeTue()).isEqualTo("1");
    assertThat(result.get(0).getStartTimeTue()).isNull();
    assertThat(result.get(0).getEndTimeTue()).isNull();
    assertThat(result.get(0).getIsNextDayTue()).isEqualTo("0");

    // 対象機器情報
    List<TargetMachineRecordCd> targetMachineRecordCd = result.get(0).getTargetMachineRecord().getCds();
    assertThat(targetMachineRecordCd.get(0).getMachineRecordCd()).isEqualTo("999");
  }

  /**
   * selectByFacilityCd()の検証.
   * <p>
   * 条件：データが複数存在する施設コードを指定 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectByFacilityCd_正常_データ複数あり() {
    // 実行
    List<MstAlarmNotification> result = target.selectByFacilityCd("00002");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result.get(0).getAlarmNotificationCd()).isEqualTo(2L);
    assertThat(result.get(0).getFacilityCd()).isEqualTo("00002");
    assertThat(result.get(0).getAlarmNotificationName()).isEqualTo("通知2-1");
    assertThat(result.get(0).getDestinationFacilityCd()).isEqualTo("00009");
    assertThat(result.get(0).getDestinationGroupCd()).isEqualTo(10L);
    assertThat(result.get(0).getIsDisp()).isEqualTo("1");
    assertThat(result.get(0).getIsDel()).isEqualTo("0");

    // 対象機器情報
    List<TargetMachineRecordCd> targetMachineRecordCd1 = result.get(0).getTargetMachineRecord().getCds();
    assertThat(targetMachineRecordCd1.get(0).getMachineRecordCd()).isEqualTo("999");

    assertThat(result.get(1).getAlarmNotificationCd()).isEqualTo(3L);
    assertThat(result.get(1).getFacilityCd()).isEqualTo("00002");
    assertThat(result.get(1).getAlarmNotificationName()).isEqualTo("通知2-2");
    assertThat(result.get(1).getDestinationFacilityCd()).isEqualTo("00009");
    assertThat(result.get(1).getDestinationGroupCd()).isEqualTo(10L);
    assertThat(result.get(1).getIsDisp()).isEqualTo("1");
    assertThat(result.get(1).getIsDel()).isEqualTo("0");
    // 対象機器情報
    List<TargetMachineRecordCd> targetMachineRecordCd2 = result.get(1).getTargetMachineRecord().getCds();
    assertThat(targetMachineRecordCd2.get(0).getMachineRecordCd()).isEqualTo("1000");

    assertThat(result.get(2).getAlarmNotificationCd()).isEqualTo(4L);
    assertThat(result.get(2).getFacilityCd()).isEqualTo("00002");
    assertThat(result.get(2).getAlarmNotificationName()).isEqualTo("通知2-3");
    assertThat(result.get(2).getDestinationFacilityCd()).isEqualTo("00009");
    assertThat(result.get(2).getDestinationGroupCd()).isEqualTo(10L);
    assertThat(result.get(2).getIsDisp()).isEqualTo("1");
    assertThat(result.get(2).getIsDel()).isEqualTo("0");
    // 対象機器情報
    TargetMachineRecord targetMachineRecordCd3 = result.get(2).getTargetMachineRecord();
    assertThat(targetMachineRecordCd3.getCds()).isEmpty();

    assertThat(result.get(3).getAlarmNotificationCd()).isEqualTo(5L);
    assertThat(result.get(3).getFacilityCd()).isEqualTo("00002");
    assertThat(result.get(3).getAlarmNotificationName()).isEqualTo("通知2-4");
    assertThat(result.get(3).getDestinationFacilityCd()).isEqualTo("00009");
    assertThat(result.get(3).getDestinationGroupCd()).isEqualTo(10L);
    assertThat(result.get(3).getIsDisp()).isEqualTo("1");
    assertThat(result.get(3).getIsDel()).isEqualTo("0");
    // 対象機器情報
    List<TargetMachineRecordCd> targetMachineRecordCd4 = result.get(3).getTargetMachineRecord().getCds();
    assertThat(targetMachineRecordCd4).isNotNull();
    assertThat(targetMachineRecordCd4).isEmpty();
  }

  /**
   * selectByFacilityCd()の検証.
   * <p>
   * 条件：データが存在しない施設コードを指定 結果：空のリストを取得できること
   * </p>
   */
  @Test
  public void test_selectByFacilityCd_正常_データなし() {
    // 実行
    List<MstAlarmNotification> result = target.selectByFacilityCd("90009");

    // 検証
    assertThat(result).hasSize(0);
  }

  /**
   * selectAll()の検証.
   * <p>
   * 条件：なし 結果：取得結果5件であること
   * </p>
   */
  @Test
  public void test_selectAll_正常() {
    // 実行
    List<MstAlarmNotification> result = target.selectAll();

    // 検証
    assertThat(result).hasSize(89);

    assertThat(result.get(0).getAlarmNotificationCd()).isEqualTo(1L);
    assertThat(result.get(0).getFacilityCd()).isEqualTo("00001");
    assertThat(result.get(0).getAlarmNotificationName()).isEqualTo("通知1");
    assertThat(result.get(0).getDestinationFacilityCd()).isEqualTo("00009");
    assertThat(result.get(0).getDestinationGroupCd()).isEqualTo(10L);
    assertThat(result.get(0).getIsDisp()).isEqualTo("1");
    assertThat(result.get(0).getIsDel()).isEqualTo("0");
    assertThat(result.get(0).getIsNoticeMon()).isEqualTo("0");
    assertThat(result.get(0).getStartTimeMon()).isEqualTo("12:00");
    assertThat(result.get(0).getEndTimeMon()).isEqualTo("18:00");
    assertThat(result.get(0).getIsNextDayMon()).isEqualTo("1");
    assertThat(result.get(0).getIsNoticeTue()).isEqualTo("1");
    assertThat(result.get(0).getStartTimeTue()).isNull();
    assertThat(result.get(0).getEndTimeTue()).isNull();
    assertThat(result.get(0).getIsNextDayTue()).isEqualTo("0");
    // 対象機器情報
    List<TargetMachineRecordCd> targetMachineRecordCd = result.get(0).getTargetMachineRecord().getCds();
    assertThat(targetMachineRecordCd.get(0).getMachineRecordCd()).isEqualTo("999");

    assertThat(result.get(1).getAlarmNotificationCd()).isEqualTo(2L);
    assertThat(result.get(2).getAlarmNotificationCd()).isEqualTo(3L);
    assertThat(result.get(3).getAlarmNotificationCd()).isEqualTo(4L);
    assertThat(result.get(4).getAlarmNotificationCd()).isEqualTo(5L);
  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：月曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   *
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_月曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/08 21:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(11L, "09999", "mon_on_all", "09999", 1L),
            tuple(12L, "09999", "mon_on_0023", "09999", 1L),
            tuple(14L, "09999", "mon_on_next_1802", "09999", 1L),
            tuple(15L, "09999", "mon_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：月曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果3件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時月曜_18時20時日曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/08 12:31:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(3);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(11L, "09999", "mon_on_all", "09999", 1L),
            tuple(12L, "09999", "mon_on_0023", "09999", 1L),
            tuple(51L, "09999", "sun_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：月曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」、
   *      前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果5件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_前1件_月曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/08 20:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(5);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(11L, "09999", "mon_on_all", "09999", 1L),
            tuple(12L, "09999", "mon_on_0023", "09999", 1L),
            tuple(14L, "09999", "mon_on_next_1802", "09999", 1L),
            tuple(15L, "09999", "mon_on_next_1820", "09999", 1L),
            tuple(51L, "09999", "sun_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：月曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_月曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/08 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(11L, "09999", "mon_on_all", "09999", 1L),
            tuple(12L, "09999", "mon_on_0023", "09999", 1L),
            tuple(50L, "09999", "sun_on_next_1802", "09999", 1L),
            tuple(51L, "09999", "sun_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：月曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）かつ複数グループが取得できることを検証
   * 結果：取得結果8件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_それぞれ2件_月曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/08 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957A");

    // 検証
    assertThat(result).hasSize(8);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(11L, "09999", "mon_on_all", "09999", 1L),
            tuple(12L, "09999", "mon_on_0023", "09999", 1L),
            tuple(50L, "09999", "sun_on_next_1802", "09999", 1L),
            tuple(51L, "09999", "sun_on_next_1820", "09999", 1L),
            tuple(53L, "09999", "mon_on_all", "09999", 2L),
            tuple(54L, "09999", "mon_on_0023", "09999", 2L),
            tuple(92L, "09999", "sun_on_next_1802", "09999", 2L),
            tuple(93L, "09999", "sun_on_next_1820", "09999", 2L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：火曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_火曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/09 21:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(17L, "09999", "tue_on_all", "09999", 1L),
            tuple(18L, "09999", "tue_on_0023", "09999", 1L),
            tuple(20L, "09999", "tue_on_next_1802", "09999", 1L),
            tuple(21L, "09999", "tue_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：火曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果3件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時火曜_18時20時月曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/09 12:31:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証

    assertThat(result).hasSize(3);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(15L, "09999", "mon_on_next_1820", "09999", 1L),
            tuple(17L, "09999", "tue_on_all", "09999", 1L),
            tuple(18L, "09999", "tue_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：火曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」、
   *      前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果5件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_前1件_火曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/09 20:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(5);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(15L, "09999", "mon_on_next_1820", "09999", 1L),
            tuple(17L, "09999", "tue_on_all", "09999", 1L),
            tuple(18L, "09999", "tue_on_0023", "09999", 1L),
            tuple(20L, "09999", "tue_on_next_1802", "09999", 1L),
            tuple(21L, "09999", "tue_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：火曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_火曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/09 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(14L, "09999", "mon_on_next_1802", "09999", 1L),
            tuple(15L, "09999", "mon_on_next_1820", "09999", 1L),
            tuple(17L, "09999", "tue_on_all", "09999", 1L),
            tuple(18L, "09999", "tue_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：火曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）かつ複数グループが取得できることを検証
   * 結果：取得結果8件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_それぞれ2件_火曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/09 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957A");

    // 検証
    assertThat(result).hasSize(8);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(14L, "09999", "mon_on_next_1802", "09999", 1L),
            tuple(15L, "09999", "mon_on_next_1820", "09999", 1L),
            tuple(17L, "09999", "tue_on_all", "09999", 1L),
            tuple(18L, "09999", "tue_on_0023", "09999", 1L),
            tuple(56L, "09999", "mon_on_next_1802", "09999", 2L),
            tuple(57L, "09999", "mon_on_next_1820", "09999", 2L),
            tuple(59L, "09999", "tue_on_all", "09999", 2L),
            tuple(60L, "09999", "tue_on_0023", "09999", 2L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：水曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_水曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/10 21:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(23L, "09999", "wed_on_all", "09999", 1L),
            tuple(24L, "09999", "wed_on_0023", "09999", 1L),
            tuple(26L, "09999", "wed_on_next_1802", "09999", 1L),
            tuple(27L, "09999", "wed_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：水曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果3件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時水曜_18時20時火曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/10 12:31:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証

    assertThat(result).hasSize(3);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(21L, "09999", "tue_on_next_1820", "09999", 1L),
            tuple(23L, "09999", "wed_on_all", "09999", 1L),
            tuple(24L, "09999", "wed_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：水曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」、
   *      前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果5件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_前1件_水曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/10 20:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(5);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(21L, "09999", "tue_on_next_1820", "09999", 1L),
            tuple(23L, "09999", "wed_on_all", "09999", 1L),
            tuple(24L, "09999", "wed_on_0023", "09999", 1L),
            tuple(26L, "09999", "wed_on_next_1802", "09999", 1L),
            tuple(27L, "09999", "wed_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：水曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_水曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/10 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(20L, "09999", "tue_on_next_1802", "09999", 1L),
            tuple(21L, "09999", "tue_on_next_1820", "09999", 1L),
            tuple(23L, "09999", "wed_on_all", "09999", 1L),
            tuple(24L, "09999", "wed_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：水曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）かつ複数グループが取得できることを検証
   * 結果：取得結果8件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_それぞれ2件_水曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/10 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957A");

    // 検証
    assertThat(result).hasSize(8);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(20L, "09999", "tue_on_next_1802", "09999", 1L),
            tuple(21L, "09999", "tue_on_next_1820", "09999", 1L),
            tuple(23L, "09999", "wed_on_all", "09999", 1L),
            tuple(24L, "09999", "wed_on_0023", "09999", 1L),
            tuple(62L, "09999", "tue_on_next_1802", "09999", 2L),
            tuple(63L, "09999", "tue_on_next_1820", "09999", 2L),
            tuple(65L, "09999", "wed_on_all", "09999", 2L),
            tuple(66L, "09999", "wed_on_0023", "09999", 2L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：木曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_木曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/11 21:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(29L, "09999", "thu_on_all", "09999", 1L),
            tuple(30L, "09999", "thu_on_0023", "09999", 1L),
            tuple(32L, "09999", "thu_on_next_1802", "09999", 1L),
            tuple(33L, "09999", "thu_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：木曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果3件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時木曜_18時20時水曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/11 12:31:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証

    assertThat(result).hasSize(3);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(27L, "09999", "wed_on_next_1820", "09999", 1L),
            tuple(29L, "09999", "thu_on_all", "09999", 1L),
            tuple(30L, "09999", "thu_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：木曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」、
   *      前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果5件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_前1件_木曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/11 20:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(5);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(27L, "09999", "wed_on_next_1820", "09999", 1L),
            tuple(29L, "09999", "thu_on_all", "09999", 1L),
            tuple(30L, "09999", "thu_on_0023", "09999", 1L),
            tuple(32L, "09999", "thu_on_next_1802", "09999", 1L),
            tuple(33L, "09999", "thu_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：木曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_木曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/11 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(26L, "09999", "wed_on_next_1802", "09999", 1L),
            tuple(27L, "09999", "wed_on_next_1820", "09999", 1L),
            tuple(29L, "09999", "thu_on_all", "09999", 1L),
            tuple(30L, "09999", "thu_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：木曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果8件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_それぞれ2件_木曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/11 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957A");

    // 検証
    assertThat(result).hasSize(8);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(26L, "09999", "wed_on_next_1802", "09999", 1L),
            tuple(27L, "09999", "wed_on_next_1820", "09999", 1L),
            tuple(29L, "09999", "thu_on_all", "09999", 1L),
            tuple(30L, "09999", "thu_on_0023", "09999", 1L),
            tuple(68L, "09999", "wed_on_next_1802", "09999", 2L),
            tuple(69L, "09999", "wed_on_next_1820", "09999", 2L),
            tuple(71L, "09999", "thu_on_all", "09999", 2L),
            tuple(72L, "09999", "thu_on_0023", "09999", 2L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：金曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_金曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/12 21:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(35L, "09999", "fri_on_all", "09999", 1L),
            tuple(36L, "09999", "fri_on_0023", "09999", 1L),
            tuple(38L, "09999", "fri_on_next_1802", "09999", 1L),
            tuple(39L, "09999", "fri_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：金曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果3件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時金曜_18時20時日曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/12 12:31:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(3);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(33L, "09999", "thu_on_next_1820", "09999", 1L),
            tuple(35L, "09999", "fri_on_all", "09999", 1L),
            tuple(36L, "09999", "fri_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：金曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」、
   *      前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果5件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_前1件_金曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/12 20:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(5);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(33L, "09999", "thu_on_next_1820", "09999", 1L),
            tuple(35L, "09999", "fri_on_all", "09999", 1L),
            tuple(36L, "09999", "fri_on_0023", "09999", 1L),
            tuple(38L, "09999", "fri_on_next_1802", "09999", 1L),
            tuple(39L, "09999", "fri_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：金曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_金曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/12 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(32L, "09999", "thu_on_next_1802", "09999", 1L),
            tuple(33L, "09999", "thu_on_next_1820", "09999", 1L),
            tuple(35L, "09999", "fri_on_all", "09999", 1L),
            tuple(36L, "09999", "fri_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：金曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）かつ複数グループが取得できることを検証
   * 結果：取得結果8件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_それぞれ2件_金曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/12 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957A");

    // 検証
    assertThat(result).hasSize(8);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(32L, "09999", "thu_on_next_1802", "09999", 1L),
            tuple(33L, "09999", "thu_on_next_1820", "09999", 1L),
            tuple(35L, "09999", "fri_on_all", "09999", 1L),
            tuple(36L, "09999", "fri_on_0023", "09999", 1L),
            tuple(74L, "09999", "thu_on_next_1802", "09999", 2L),
            tuple(75L, "09999", "thu_on_next_1820", "09999", 2L),
            tuple(77L, "09999", "fri_on_all", "09999", 2L),
            tuple(78L, "09999", "fri_on_0023", "09999", 2L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：土曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_土曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/13 21:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(41L, "09999", "sat_on_all", "09999", 1L),
            tuple(42L, "09999", "sat_on_0023", "09999", 1L),
            tuple(44L, "09999", "sat_on_next_1802", "09999", 1L),
            tuple(45L, "09999", "sat_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：土曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果3件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時土曜_18時20時日曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/13 12:31:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(3);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(39L, "09999", "fri_on_next_1820", "09999", 1L),
            tuple(41L, "09999", "sat_on_all", "09999", 1L),
            tuple(42L, "09999", "sat_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：土曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」、
   *      前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果5件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_前1件_土曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/13 20:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(5);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(39L, "09999", "fri_on_next_1820", "09999", 1L),
            tuple(41L, "09999", "sat_on_all", "09999", 1L),
            tuple(42L, "09999", "sat_on_0023", "09999", 1L),
            tuple(44L, "09999", "sat_on_next_1802", "09999", 1L),
            tuple(45L, "09999", "sat_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：土曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_土曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/13 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(38L, "09999", "fri_on_next_1802", "09999", 1L),
            tuple(39L, "09999", "fri_on_next_1820", "09999", 1L),
            tuple(41L, "09999", "sat_on_all", "09999", 1L),
            tuple(42L, "09999", "sat_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：土曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）かつ複数グループが取得できることを検証
   * 結果：取得結果8件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_それぞれ2件_土曜正常()
      throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/13 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957A");

    // 検証
    assertThat(result).hasSize(8);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(38L, "09999", "fri_on_next_1802", "09999", 1L),
            tuple(39L, "09999", "fri_on_next_1820", "09999", 1L),
            tuple(41L, "09999", "sat_on_all", "09999", 1L),
            tuple(42L, "09999", "sat_on_0023", "09999", 1L),
            tuple(80L, "09999", "fri_on_next_1802", "09999", 2L),
            tuple(81L, "09999", "fri_on_next_1820", "09999", 2L),
            tuple(83L, "09999", "sat_on_all", "09999", 2L),
            tuple(84L, "09999", "sat_on_0023", "09999", 2L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：日曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_日曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/14 21:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(47L, "09999", "sun_on_all", "09999", 1L),
            tuple(48L, "09999", "sun_on_0023", "09999", 1L),
            tuple(50L, "09999", "sun_on_next_1802", "09999", 1L),
            tuple(51L, "09999", "sun_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：日曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果3件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時日曜_18時20時土曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/14 12:31:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証

    assertThat(result).hasSize(3);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(45L, "09999", "sat_on_next_1820", "09999", 1L),
            tuple(47L, "09999", "sun_on_all", "09999", 1L),
            tuple(48L, "09999", "sun_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：日曜日で、当日の「時間指定なし」「0時〜23時」、翌日チェックありの「18時〜02時」「18時〜20時」、
   *      前日の「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果5件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_翌2件_前1件_日曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/14 20:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(5);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(45L, "09999", "sat_on_next_1820", "09999", 1L),
            tuple(47L, "09999", "sun_on_all", "09999", 1L),
            tuple(48L, "09999", "sun_on_0023", "09999", 1L),
            tuple(50L, "09999", "sun_on_next_1802", "09999", 1L),
            tuple(51L, "09999", "sun_on_next_1820", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：日曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）が取得できることを検証
   * 結果：取得結果4件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_日曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = new java.sql.Timestamp(
        new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse("2019/04/14 01:00:00").getTime());

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957B");

    // 検証
    assertThat(result).hasSize(4);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(44L, "09999", "sat_on_next_1802", "09999", 1L),
            tuple(45L, "09999", "sat_on_next_1820", "09999", 1L),
            tuple(47L, "09999", "sun_on_all", "09999", 1L),
            tuple(48L, "09999", "sun_on_0023", "09999", 1L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：日曜日で、当日の「時間指定なし」「0時〜23時」、前日の「18時〜02時」「18時〜20時」（全て通知ON）かつ複数グループが取得できることを検証
   * 結果：取得結果8件であること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_通知あり_ONのみ_0時23時_前2件_それぞれ2件_日曜正常() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/14 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "957A");

    // 検証
    assertThat(result).hasSize(8);
    assertThat(result)
        .extracting(
            MstAlarmNotification::getAlarmNotificationCd,
            MstAlarmNotification::getFacilityCd,
            MstAlarmNotification::getAlarmNotificationName,
            MstAlarmNotification::getDestinationFacilityCd,
            MstAlarmNotification::getDestinationGroupCd)
        .containsExactly(
            tuple(44L, "09999", "sat_on_next_1802", "09999", 1L),
            tuple(45L, "09999", "sat_on_next_1820", "09999", 1L),
            tuple(47L, "09999", "sun_on_all", "09999", 1L),
            tuple(48L, "09999", "sun_on_0023", "09999", 1L),
            tuple(86L, "09999", "sat_on_next_1802", "09999", 2L),
            tuple(87L, "09999", "sat_on_next_1820", "09999", 2L),
            tuple(89L, "09999", "sun_on_all", "09999", 2L),
            tuple(90L, "09999", "sun_on_0023", "09999", 2L));

  }

  /**
   * selectByMNoticeTelegram()の検証.
   * <p>
   * 条件：施設コードが'09999', 装置記録コードが'999A', イベント発生日時が'2019/04/08 01:00:00' (該当なし)
   * 結果：空のリストを取得できること
   * </p>
   * @throws ParseException
   */
  @Test
  public void test_selectByMNoticeTelegram_正常_データなし() throws ParseException {
    // 実行
    Timestamp eventRegDate = getTimestamp("2019/04/08 01:00:00");

    List<MstAlarmNotification> result = target.getAlarmNotificationByMNoticeTelegram(eventRegDate, "09999", "999A");

    // 検証
    assertThat(result).hasSize(0);
  }

  /**
   * 日付の文字列よりtimestampを取得.
   * @param str 日時（String）
   * @return 日時（TimeStamp）
   * @throws ParseException
   */
  private Timestamp getTimestamp(String str) throws ParseException {
    return new java.sql.Timestamp(
          new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(str).getTime()
    );
  }
}
