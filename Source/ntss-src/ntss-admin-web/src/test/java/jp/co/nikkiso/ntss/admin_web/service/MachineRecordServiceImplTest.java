package jp.co.nikkiso.ntss.admin_web.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.MachineRecordResponse;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;

/**
 * {@link MachineRecordServiceImpl}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class MachineRecordServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private MachineRecordService machineRecordService;

  /**
   * 装置記録のMockBean.
   */
  @MockitoBean
  private MstMachineRecordDao mstMachineRecordDao;

  // テスト用データ
  private List<MstMachineRecord> getMstMachineRecord() {
    MstMachineRecord mstMachineRecord1 = new MstMachineRecord(
      "0050",
      "投与",
      "1",
      "1",
      "1",
      now(),
      now(),
      ""
    );

    MstMachineRecord mstMachineRecord2 = new MstMachineRecord(
      "0060",
      "酸素吸入開始",
      "1",
      "2",
      "3",
      now(),
      now(),
      ""
    );

    MstMachineRecord mstMachineRecord3 = new MstMachineRecord(
      "0103",
      "ケア",
      "1",
      "4",
      "6",
      now(),
      now(),
      ""
    );

    MstMachineRecord mstMachineRecord4 = new MstMachineRecord(
      "0106",
      null,
      "0",
      "2",
      "4",
      now(),
      now(),
      ""
    );

    MstMachineRecord mstMachineRecord5 = new MstMachineRecord(
      "0109",
      "引き残し量",
      "0",
      "1",
      "1",
      now(),
      now(),
      ""
    );

    List<MstMachineRecord> machineRecords = Arrays
        .asList(mstMachineRecord1, mstMachineRecord2, mstMachineRecord3, mstMachineRecord4, mstMachineRecord5);

    return machineRecords;
  }

  /**
   * getMstMachineRecordの検証.
   *
   * 条件：装置記録にデータがある
   * 結果：装置記録が全件取得されること
   */
  @Test
  public void test_getAllMachineRecord_正常_データあり() {

    List<MstMachineRecord> machineRecords = getMstMachineRecord();

    // Mock化
    given(mstMachineRecordDao.selectAll()).willReturn(machineRecords);

    // 実行
    MachineRecordResponse result = machineRecordService.getAllMachineRecords(null);

    // 検証
    verify(mstMachineRecordDao, times(1)).selectAll();
    assertThat(result).isNotNull();
    assertThat(result.getMachineRecords()).isNotNull();

    assertThat(result.getMachineRecords()).hasSize(5);
    assertThat(result.getMachineRecords())
      .extracting(
        MachineRecordResponse.MachineRecord::getCode,
        MachineRecordResponse.MachineRecord::getMessage,
        MachineRecordResponse.MachineRecord::getIsDefault,
        MachineRecordResponse.MachineRecord::getLogClass,
        MachineRecordResponse.MachineRecord::getTargetModel
      )
      .containsExactly(
        tuple("0050", "投与", "1", "1", "1"),
        tuple("0060", "酸素吸入開始", "1", "2", "3"),
        tuple("0103", "ケア", "1", "4", "6"),
        tuple("0106", null, "0", "2", "4"),
        tuple("0109", "引き残し量", "0", "1", "1")
      )
    ;
  }

  /**
   * getMstMachineRecordの検証.
   *
   * 条件：装置記録にデータがない
   * 結果：空のリストが取得されること
   */
  @Test
  public void test_getAllMachineRecord_正常_データなし() {
    // Mock化
    given(mstMachineRecordDao.selectAll()).willReturn(Collections.emptyList());

    // 実行
    MachineRecordResponse result = machineRecordService.getAllMachineRecords(null);

    // 検証
    verify(mstMachineRecordDao, times(1)).selectAll();
    assertThat(result).isNotNull();
    assertThat(result.getMachineRecords()).isNotNull();
    assertThat(result.getMachineRecords()).hasSize(0);
  }

  private Timestamp now() {
    return Timestamp.valueOf(LocalDateTime.now());
  }
}
