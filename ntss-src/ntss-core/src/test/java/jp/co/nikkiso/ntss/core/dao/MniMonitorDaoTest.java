package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;


/**
 * {@link MniMonitorDao}のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MniMonitorDaoTest.before.sql")
public class MniMonitorDaoTest {

  /**
   * {@link MniMonitorDao} のインスタンス
   */
  @Autowired
  private MniMonitorDao mniMonitorDao;

  /**
   * {@link MniMonitorDao#updateMonitorData(Long, Short, String, String, Timestamp, Timestamp, Long)} (Long, Short, String, String, Timestamp, Long)} の検証
   * <p>
   *   条件：更新対象の装置モニタデータレコードが存在する事
   *   結果：該当する装置モニタデータレコードが更新される事
   * </p>
   */
  @Test
  public void test_updateMonitorData_正常() {
    // 事前準備
    // 更新対象のオーダ番号
    Long ordNo = 1L;
    // 更新データ取得
    List<MniMonitor> updateBeforeDataList = mniMonitorDao.selectByOrdNo(ordNo);

    // 検証(取得更新件数)
    assertThat(updateBeforeDataList.size(), is(1));

    // 発生日時
    Timestamp occurDate = Timestamp.valueOf("2019-11-21 12:00:00.000");
    // 更新日時
    Timestamp upDate = new Timestamp(System.currentTimeMillis());

    // 実行
    int updateCount = mniMonitorDao.updateMonitorData(
      1L,
      (short)3,
      "{\"0\": \"test1\", \"1\": \"data1\", \"2\": \"data2\"}",
      "1",
      occurDate,
      upDate,
      100L
      );

    // 検証(更新件数)
    assertThat(updateCount, is(1));

    // 更新したデータ取得
    List<MniMonitor> updateAfterDataList = mniMonitorDao.selectByOrdNo(ordNo);

    // 検証(取得更新件数)
    assertThat(updateAfterDataList.size(), is(1));

    // 検証（データ種別）
    assertThat(updateAfterDataList.get(0).getDataType(), is((short)3));
    // 検証（モニタデータ）
    assertThat(updateAfterDataList.get(0).getMonitorData(), is("{\"0\": \"test1\", \"1\": \"data1\", \"2\": \"data2\"}"));
    // 検証（削除フラグ）
    assertThat(updateAfterDataList.get(0).getIsDel(), is("1"));
    // 検証（発生日時）
    assertThat(updateAfterDataList.get(0).getOccurDate(), is(occurDate));
    // 検証（更新日時）
    assertThat(updateAfterDataList.get(0).getUpDate(), is(upDate));
    // 検証（更新者ID）
    assertThat(updateAfterDataList.get(0).getUpdStaffId(), is(100L));
  }

  /**
   * {@link MniMonitorDao#updateMonitorData(Long, Short, String, String, Timestamp, Timestamp, Long)} (Long, Short, String, String, Timestamp, Long)} の検証
   * <p>
   *   条件：更新対象の装置モニタデータレコードが存在しない事
   *   結果：更新データ数がゼロ件である事
   * </p>
   */
  @Test
  public void test_updateMonitorData_異常_存在しないレコード更新() {
    // 発生日時
    Timestamp occurDate = Timestamp.valueOf("2019-11-21 12:00:00.000");
    // 更新日時
    Timestamp upDate = new Timestamp(System.currentTimeMillis());

    // 実行
    int updateCount = mniMonitorDao.updateMonitorData(
      2L,
      (short)4,
      "{\"0\": \"test1\", \"1\": \"data1\", \"2\": \"data2\", \"3\": \"data3\"}",
      "1",
      occurDate,
      upDate,
      200L
    );

    // 検証(更新件数)
    assertThat(updateCount, is(0));
  }

  /**
   * {@link MniMonitorDao#updateVitalDataByResultMerge(Long, Long, Long, Timestamp, Long)} の検証
   * <p>
   *   条件：更新対象の装置モニタデータレコードが存在する事
   *   結果：該当するデータのオーダ番号と患者ID、更新日時、更新者IDが更新される事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.updateVitalDataByOrdNo.before.sql")
  public void test_updateVitalDataByResultMerge_正常() {
    // テストするオーダ番号
    Long targetOrdNo = 2L;
    // 更新後のオーダ番号
    Long ordNo = 100L;
    // 更新後の患者ID
    Long patId = 1001L;
    // 更新前にこれから更新するデータを取得
    List<MniMonitor> beforeUpdateList = mniMonitorDao.selectByOrdNo(targetOrdNo);

    // 更新日時
    Timestamp update = new Timestamp(System.currentTimeMillis());
    // 更新者ID
    Long updStaffId = 10L;

    // 実行
    int updateCount = mniMonitorDao.updateVitalDataByResultMerge(targetOrdNo, ordNo, patId, update, updStaffId);

    // 検証（更新件数）
    assertThat(updateCount, is(4));

    // 検証する為、更新後のデータ取得
    List<MniMonitor> afterUpdateList = mniMonitorDao.selectByOrdNo(ordNo);
    // 検証（更新内容）
    afterUpdateList.forEach(s -> {
      // 更新前のデータから生体モニタリング管理番号をキーに退避したリストからデータを取得
      List<MniMonitor> extractionBoforeMniMonitorList =  beforeUpdateList.stream()
        .filter(before -> before.getBioMoniCtlNo().equals(s.getBioMoniCtlNo()))
        .collect(Collectors.toList());
      // 生体モニタリング番号での検索結果が1件である事.
      assertThat(extractionBoforeMniMonitorList.size(), is(1));

      // 検証
      // データ種別：0,1,3
      // 　更新前と値が変わっていない事
      // データ種別：2,4,5,6
      // 　期待する更新結果となっている事
      switch (extractionBoforeMniMonitorList.get(0).getDataType()) {

        case 0:
        case 1:
        case 3:
          assertThat(s.getOrdNo(), is(extractionBoforeMniMonitorList.get(0).getOrdNo()));
          assertThat(s.getPatId(), is(extractionBoforeMniMonitorList.get(0).getPatId()));
          assertThat(s.getUpDate(), is(extractionBoforeMniMonitorList.get(0).getUpDate()));
          assertThat(s.getUpdStaffId(), is(extractionBoforeMniMonitorList.get(0).getUpdStaffId()));
        case 2:
        case 4:
        case 5:
        case 6:
          assertThat(s.getOrdNo(), is(ordNo));
          assertThat(s.getPatId(), is(patId));
          assertThat(s.getUpDate(), is(update));
          assertThat(s.getUpdStaffId(), is(updStaffId));
        default:
      }
    });
  }

  /**
   * {@link MniMonitorDao#updateVitalDataByResultMerge(Long, Long, Long, Timestamp, Long)} の検証
   * <p>
   *   条件：更新対象の装置モニタデータレコードが存在しない事
   *   結果：更新件数がゼロ件である事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.updateVitalDataByOrdNo.before.sql")
  public void test_updateVitalDataByResultMerge_異常_更新データがない場合() {
    // テストするオーダ番号
    Long targetOrdNo = 4L;
    // 更新後のオーダ番号
    Long ordNo = 100L;
    // 更新後の患者ID
    Long patId = 1001L;
    // 更新前にこれから更新するデータを取得
    List<MniMonitor> beforeUpdateList = mniMonitorDao.selectByOrdNo(targetOrdNo);

    // 更新日時
    Timestamp update = new Timestamp(System.currentTimeMillis());
    // 更新者ID
    Long updStaffId = 10L;

    // 実行
    int updateCount = mniMonitorDao.updateVitalDataByResultMerge(targetOrdNo, ordNo, patId, update, updStaffId);

    // 検証（更新件数）
    assertThat(updateCount, is(0));
  }

  /**
   * {@link MniMonitorDao#updateMonitorDataByResultMerge(Long, Long, Long, Timestamp, Long)} の検証
   * <p>
   *   条件：更新対象の装置モニタデータレコードが存在する事
   *   結果：該当するデータのオーダ番号と患者ID、更新日時、更新者IDが更新される事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.updateMonitorDataByOrdNo.before.sql")
  public void test_updateMonitorDataByResultMerge_正常() {
    // テストするオーダ番号
    Long targetOrdNo = 3L;
    // 更新後のオーダ番号
    Long ordNo = 101L;
    // 更新後の患者ID
    Long patId = 1001L;
    // 更新前にこれから更新するデータを取得
    List<MniMonitor> beforeUpdateList = mniMonitorDao.selectByOrdNo(targetOrdNo);

    // 更新日時
    Timestamp update = new Timestamp(System.currentTimeMillis());
    // 更新者ID
    Long updStaffId = 10L;

    // 実行
    int updateCount = mniMonitorDao.updateMonitorDataByResultMerge(targetOrdNo, ordNo, patId, update, updStaffId);

    // 検証（更新件数）
    assertThat(updateCount, is(1));

    // 検証する為、更新後のデータ取得
    List<MniMonitor> afterUpdateList = mniMonitorDao.selectByOrdNo(ordNo);
    assertThat(afterUpdateList.get(0).getOrdNo(), is(ordNo));
    assertThat(afterUpdateList.get(0).getPatId(), is(patId));
    assertThat(afterUpdateList.get(0).getUpDate(), is(update));
    assertThat(afterUpdateList.get(0).getUpdStaffId(), is(updStaffId));
  }

  /**
   * {@link MniMonitorDao#updateMonitorDataByResultMerge(Long, Long, Long, Timestamp, Long)} の検証
   * <p>
   *   条件：更新対象の装置モニタデータレコードが存在する事
   *   結果：更新件数がゼロ件である事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.updateMonitorDataByOrdNo.before.sql")
  public void test_updateMonitorDataByResultMerge_異常_更新データがない場合() {
    // テストするオーダ番号
    Long targetOrdNo = 5L;
    // 更新後のオーダ番号
    Long ordNo = 101L;
    // 更新後の患者ID
    Long patId = 1001L;
    // 更新前にこれから更新するデータを取得
    List<MniMonitor> beforeUpdateList = mniMonitorDao.selectByOrdNo(targetOrdNo);

    // 更新日時
    Timestamp update = new Timestamp(System.currentTimeMillis());
    // 更新者ID
    Long updStaffId = 10L;

    // 実行
    int updateCount = mniMonitorDao.updateMonitorDataByResultMerge(targetOrdNo, ordNo, patId, update, updStaffId);

    // 検証（更新件数）
    assertThat(updateCount, is(0));
  }

  /**
   * {@link MniMonitorDao#updateDataTypeByKey(Long, Short)}の検証.
   * <p>
   *   条件：更新対象の装置モニタデータレコードが存在する事
   *   結果：該当する装置モニタデータのデータ種別が更新される事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.updateDataTypeByKey.before.sql")
  public void test_updateDataTypeByKey_正常() {
    // テストするオーダ番号
    Long ordNo = 6L;
    // 更新対象の生体モニタリング番号
    Long bioMniCtlNo = 25L;
    // 更新前にこれから更新するデータを取得
    List<MniMonitor> beforeUpdateList = mniMonitorDao.selectByOrdNo(ordNo).stream()
      .filter(e -> e.getBioMoniCtlNo().equals(bioMniCtlNo)).collect(Collectors.toList());
    // 実行
    int updateCount = mniMonitorDao.updateDataTypeByKey(bioMniCtlNo, CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP);

    // 検証（更新件数）
    assertThat(updateCount, is(1));

    // 検証する為、更新後のデータ取得
    List<MniMonitor> afterUpdateList = mniMonitorDao.selectByOrdNo(ordNo).stream()
      .filter(e -> e.getBioMoniCtlNo().equals(bioMniCtlNo))
      .collect(Collectors.toList());

    // データ種別以外が更新されていない事を確認
    assertThat(afterUpdateList.get(0).getFacilityCd(), is(beforeUpdateList.get(0).getFacilityCd()));
    assertThat(afterUpdateList.get(0).getMachineTypeCd(), is(beforeUpdateList.get(0).getMachineTypeCd()));
    assertThat(afterUpdateList.get(0).getMachineSerial(), is(beforeUpdateList.get(0).getMachineSerial()));
    assertThat(afterUpdateList.get(0).getOrdNo(), is(beforeUpdateList.get(0).getOrdNo()));
    assertThat(afterUpdateList.get(0).getPatId(), is(beforeUpdateList.get(0).getPatId()));
    assertThat(afterUpdateList.get(0).getDataType(), is(CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP));
    assertThat(afterUpdateList.get(0).getMonitorData(), is(beforeUpdateList.get(0).getMonitorData()));
    assertThat(afterUpdateList.get(0).getIsDel(), is(beforeUpdateList.get(0).getIsDel()));
    assertThat(afterUpdateList.get(0).getOccurDate(), is(beforeUpdateList.get(0).getOccurDate()));
    assertThat(afterUpdateList.get(0).getRegDate(), is(beforeUpdateList.get(0).getRegDate()));
    assertThat(afterUpdateList.get(0).getUpDate(), is(beforeUpdateList.get(0).getUpDate()));
    assertThat(afterUpdateList.get(0).getUpdStaffId(), is(beforeUpdateList.get(0).getUpdStaffId()));
  }

  /**
   * {@link MniMonitorDao#updateDataTypeByKey(Long, Short)}の検証.
   * <p>
   *   条件：更新対象の装置モニタデータが存在しない事
   *   結果：更新件数がゼロ件である事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.updateDataTypeByKey.before.sql")
  public void test_updateDataTypeByKey_異常_更新データがない場合() {
    // テストするオーダ番号
    Long ordNo = 6L;
    // 更新対象の生体モニタリング番号
    Long bioMniCtlNo = 27L;
    // 更新前にこれから更新するデータを取得
    List<MniMonitor> beforeUpdateList = mniMonitorDao.selectByOrdNo(ordNo).stream()
      .filter(e -> e.getBioMoniCtlNo().equals(bioMniCtlNo)).collect(Collectors.toList());
    // 実行
    int updateCount = mniMonitorDao.updateDataTypeByKey(bioMniCtlNo, CoreConstant.MniMonitorDataType.MONITOR_DATA_TYPE_DIALYSIS_BP);

    // 検証（更新件数）
    assertThat(updateCount, is(0));
  }

  /**
   * {@link MniMonitorDao#selectMonitorDataByMoniDataNo(Long, List, List)} の検証.
   * <p>
   *   条件:取得対象の装置モニタデータが存在する事
   *   結果:装置モニタデータが取得出来る事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.selectMonitorDataByMoniDataNo.before.sql")
  public void test_selectMonitorDataByMoniDataNo_正常_該当データあり() {
    // テスト用データ作成
    Long ordNo = 6L;
    List<SysMonitorItem> sysMonitorItemList = new ArrayList<>();
    for (int index = 0; index < 3; index++) {
      SysMonitorItem sysMonitorItem = new SysMonitorItem();
      sysMonitorItem.setMoniDataNo(String.valueOf(index));
      sysMonitorItemList.add(sysMonitorItem);
    }

    // 実行
    List<MniMonitor> result = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList, Collections.EMPTY_LIST);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(6));

    // 1件目
    assertThat(result.get(0).getBioMoniCtlNo(), is(20L));
    assertThat(result.get(0).getOccurDate(), is(Timestamp.valueOf("2019-03-22 09:33:00.000")));
    assertThat(result.get(0).getOrdNo(), is(ordNo));
    assertThat(result.get(0).getMonitorData(), is("{\"0\": \"-7.0\", \"1\": \"-38.0\"}"));

    assertThat(result.get(1).getBioMoniCtlNo(), is(21L));
    assertThat(result.get(1).getOccurDate(), is(Timestamp.valueOf("2019-03-22 09:45:00.000")));
    assertThat(result.get(1).getOrdNo(), is(ordNo));
    assertThat(result.get(1).getMonitorData(), is("{\"0\": \"-20.0\", \"1\": \"-75.0\"}"));

    assertThat(result.get(2).getBioMoniCtlNo(), is(22L));
    assertThat(result.get(2).getOccurDate(), is(Timestamp.valueOf("2019-03-22 10:04:00.000")));
    assertThat(result.get(2).getOrdNo(), is(ordNo));
    assertThat(result.get(2).getMonitorData(), is("{\"0\": \"-34.0\", \"1\": \"-103.0\", \"2\": \"01:14\"}"));

    assertThat(result.get(3).getBioMoniCtlNo(), is(23L));
    assertThat(result.get(3).getOccurDate(), is(Timestamp.valueOf("2019-03-22 14:34:00.000")));
    assertThat(result.get(3).getOrdNo(), is(ordNo));
    assertThat(result.get(3).getMonitorData(), is("{\"0\": \"-61.0\", \"1\": \"-129.0\", \"2\": \"01:44\", \"3\": \"36.1\"}"));

    assertThat(result.get(4).getBioMoniCtlNo(), is(24L));
    assertThat(result.get(4).getOccurDate(), is(Timestamp.valueOf("2019-03-22 14:35:00.000")));
    assertThat(result.get(4).getOrdNo(), is(ordNo));
    assertThat(result.get(4).getMonitorData(), is("{\"0\": \"-75.0\", \"1\": \"-153.0\", \"10\": \"3.0\"}"));

    assertThat(result.get(5).getBioMoniCtlNo(), is(26L));
    assertThat(result.get(5).getOccurDate(), is(Timestamp.valueOf("2019-03-22 14:37:00.000")));
    assertThat(result.get(5).getOrdNo(), is(ordNo));
    assertThat(result.get(5).getMonitorData(), is("{\"0\": \"-102.0\", \"1\": \"-199.0\"}"));
  }

  /**
   * {@link MniMonitorDao#selectMonitorDataByMoniDataNo(Long, List, List)} の検証.
   * <p>
   *   条件:取得対象の装置モニタデータが存在しない事
   *   結果:空のリストが取得される事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.selectMonitorDataByMoniDataNo.before.sql")
  public void test_selectMonitorDataByMoniDataNo_正常_オーダ番号に該当するモニタデータがない場合() {
    // テスト用データ作成
    Long ordNo = 7L;
    List<SysMonitorItem> sysMonitorItemList = new ArrayList<>();
    for (int index = 0; index < 3; index++) {
      SysMonitorItem sysMonitorItem = new SysMonitorItem();
      sysMonitorItem.setMoniDataNo(String.valueOf(index));
      sysMonitorItemList.add(sysMonitorItem);
    }

    // 実行
    List<MniMonitor> result = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList, Collections.EMPTY_LIST);

    // 検証
    assertNotNull(result);
    assertTrue(result.isEmpty());
  }

  /**
   * {@link MniMonitorDao#selectMonitorDataByMoniDataNo(Long, List, List)} の検証.
   * <p>
   *   条件:取得対象の装置モニタデータが存在する事
   *   結果:取得対象のモニタ項目番号が存在するデータのみ取得出来る事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.selectMonitorDataByMoniDataNo.before.sql")
  public void test_selectMonitorDataByMoniDataNo_正常_取得するモニタ項目番号が存在するモニタデータのみの場合() {
    // テスト用データ作成
    Long ordNo = 6L;
    List<SysMonitorItem> sysMonitorItemList = new ArrayList<>();
    SysMonitorItem sysMonitorItem = new SysMonitorItem();
    sysMonitorItem.setMoniDataNo("10");
    sysMonitorItemList.add(sysMonitorItem);

    // 実行
    List<MniMonitor> result = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList,Collections.EMPTY_LIST);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(1));
    assertThat(result.get(0).getBioMoniCtlNo(), is(24L));
    assertThat(result.get(0).getOccurDate(), is(Timestamp.valueOf("2019-03-22 14:35:00.000")));
    assertThat(result.get(0).getOrdNo(), is(ordNo));
    assertThat(result.get(0).getMonitorData(), is("{\"0\": \"-75.0\", \"1\": \"-153.0\", \"10\": \"3.0\"}"));
  }

  /**
   * {@link MniMonitorDao#selectMonitorDataByMoniDataNo(Long, List, List)} の検証.
   * <p>
   *   条件:取得対象の装置モニタデータが存在する事
   *   結果:取得対象のモニタ項目番号が存在するデータのみ取得出来る事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.selectMonitorDataByMoniDataNo.before.sql")
  public void test_selectMonitorDataByMoniDataNo_正常_取得するモニタ項目番号が存在しない場合() {
    // テスト用データ作成
    Long ordNo = 6L;
    List<SysMonitorItem> sysMonitorItemList = new ArrayList<>();
    SysMonitorItem sysMonitorItem = new SysMonitorItem();
    sysMonitorItem.setMoniDataNo("11");
    sysMonitorItemList.add(sysMonitorItem);

    // 実行
    List<MniMonitor> result = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList,Collections.EMPTY_LIST);

    // 検証
    assertNotNull(result);
    assertTrue(result.isEmpty());
  }

  /**
   * {@link MniMonitorDao#selectMonitorDataByMoniDataNo(Long, List, List)} の検証.
   * <p>
   *   条件:取得対象の装置モニタデータのキーは存在するが値がnullの場合
   *   結果:取得出来ない事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.selectMonitorDataByMoniDataNo.before.sql")
  public void test_selectMonitorDataByMoniDataNo_正常_取得するモニタ項目番号は存在するが値がnullの場合() {
    // テスト用データ作成
    Long ordNo = 8L;
    List<SysMonitorItem> sysMonitorItemList = new ArrayList<>();
    SysMonitorItem sysMonitorItem = new SysMonitorItem();
    sysMonitorItem.setMoniDataNo("0");
    sysMonitorItemList.add(sysMonitorItem);

    // 実行
    List<MniMonitor> result = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList,Collections.EMPTY_LIST);

    // 検証
    assertNotNull(result);
    assertTrue(result.isEmpty());
  }

  /**
   * {@link MniMonitorDao#selectMonitorDataByMoniDataNo(Long, List, List)} の検証.
   * <p>
   *   条件:取得対象の装置モニタデータのキーは存在するが値が空文字の場合
   *   結果:取得出来る事
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.selectMonitorDataByMoniDataNo.before.sql")
  public void test_selectMonitorDataByMoniDataNo_正常_取得するモニタ項目番号は存在するが値が空文字の場合() {
    // テスト用データ作成
    Long ordNo = 9L;
    List<SysMonitorItem> sysMonitorItemList = new ArrayList<>();
    SysMonitorItem sysMonitorItem = new SysMonitorItem();
    sysMonitorItem.setMoniDataNo("0");
    sysMonitorItemList.add(sysMonitorItem);

    // 実行
    List<MniMonitor> result = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList,Collections.EMPTY_LIST);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(1));
    assertThat(result.get(0).getBioMoniCtlNo(), is(28L));
    assertThat(result.get(0).getOccurDate(), is(Timestamp.valueOf("2019-03-22 14:37:00.000")));
    assertThat(result.get(0).getOrdNo(), is(ordNo));
    assertThat(result.get(0).getMonitorData(), is("{\"0\": \"\", \"1\": \"-199.0\"}"));
  }

  /**
   * {@link MniMonitorDao#selectMonitorDataByMoniDataNo(Long, List, List)} の検証.
   * <p>
   *   条件:取得対象のデータタイプが指定されている事.
   *   結果:取得出来る事.
   * </p>
   */
  @Test
  @Sql("classpath:dao.script/MniMonitorDaoTest.selectMonitorDataByMoniDataNo.before.sql")
  public void test_selectMonitorDataByMoniDataNo_正常_データタイプを指定した場合() {
    // テスト用データ作成
    Long ordNo = 10L;
    List<SysMonitorItem> sysMonitorItemList = new ArrayList<>();
    SysMonitorItem sysMonitorItem = new SysMonitorItem();
    sysMonitorItem.setMoniDataNo("0");
    sysMonitorItemList.add(sysMonitorItem);

    List<Short> dataTypeArray = new ArrayList<>();
    dataTypeArray.add((short)2);
    dataTypeArray.add((short)5);

    // 実行
    List<MniMonitor> result = mniMonitorDao.selectMonitorDataByMoniDataNo(ordNo, sysMonitorItemList, dataTypeArray);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(2));
    assertThat(result.get(0).getBioMoniCtlNo(), is(29L));
    assertThat(result.get(0).getOccurDate(), is(Timestamp.valueOf("2020-06-24 13:50:00.000")));
    assertThat(result.get(0).getOrdNo(), is(ordNo));
    assertThat(result.get(0).getMonitorData(), is("{\"0\": \"\", \"2\": \"-50.0\"}"));
    assertThat(result.get(1).getBioMoniCtlNo(), is(30L));
    assertThat(result.get(1).getOccurDate(), is(Timestamp.valueOf("2020-06-24 14:05:00.000")));
    assertThat(result.get(1).getOrdNo(), is(ordNo));
    assertThat(result.get(1).getMonitorData(), is("{\"0\": \"\", \"3\": \"-60.0\"}"));
  }
}
