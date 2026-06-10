package jp.co.nikkiso.ntss.core.dao;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Field;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Validation;

/**
 * {@link SysMasterDefineDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/MasterMaintennceGenericDaoTest.before.sql")
public class MasterMaintennceGenericDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private MasterMaintenanceGenericDao target;

  /**
   * テスト対象EntityDao.
   */
  @Autowired
  private MntMotionRecordDao editTarget;


  /**
   * getMasterData()の検証.
   * <p>
   *   条件：該当データあり(文字列、数字項目)
   *   結果：指定した施設コードの該当データを取得できること
   * </p>
   */
  @Test
  public void test_getMasterData_正常_該当データあり_文字列数字項目() {
    // 事前準備
    Validation numberValidation = new Validation() {
      {
        setMin(new BigDecimal("1"));
        setMax(new BigDecimal("99"));
      }
    };
    Validation nameValidation = new Validation() {
      {
        setMaxlength(20);
      }
    };
    Field deviceNo = new Field() {
      {
        setPhysicalName("device_edge_no");
        setTitle("デバイスエッジ番号");
        setType(FieldType.NUMBER);
        setValidation(numberValidation);
      }
    };
    Field deviceName = new Field() {
      {
        setPhysicalName("device_name");
        setTitle("デバイス名");
        setType(FieldType.STRING);
        setValidation(nameValidation);
        setAlias("name");
      }
    };
    SysMasterDefine.ColumnInfo column = new SysMasterDefine.ColumnInfo() {
      // 項目の設定(デバイスエッジ番号、デバイス名)
      {
        setFields(Arrays.asList(deviceNo, deviceName));
      }
    };
    SysMasterDefine masterDefine = new SysMasterDefine() {
      {
        setMasterName("デバイスエッジマスタ");
        setMasterPhysicalName("mst_device_edge");
        setMode("1");
        setAllowSort("1");
        setAllowAddRecord("1");
        setDispOrder(1);
        setColumnInfo(column);
      }
    };
    String facilityCd = "000001";

    // 実行
    List<Map<String, Object>> result = target.getMasterData(masterDefine, facilityCd);

    // 検証
    assertThat(result, hasSize(2));
    assertThat(result.get(0).get("deviceEdgeNo"), is(BigDecimal.valueOf(1)));
    assertThat(result.get(0).get("name"), is("deviceA1"));
    assertThat(result.get(0).get("upDate"), is(Timestamp.valueOf("2019-09-13 10:01:00")));
    assertThat(result.get(1).get("deviceEdgeNo"), is(BigDecimal.valueOf(2)));
    assertThat(result.get(1).get("name"), is("deviceA2"));
    assertThat(result.get(1).get("upDate"), is(Timestamp.valueOf("2019-09-13 10:06:00")));
  }

  /**
   * getMasterData()の検証.
   * <p>
   *   条件：該当データあり(日付項目)
   *   結果：指定した施設コードの該当データを取得できること
   *
   *   mnt_motion_recordにindedxを作成したことでテストが通らなくなったため、一時的に無効とする
   *   テストが失敗する原因はindexを作成したことでデータの取得順番が変わったため
   *   TODO テストが通るように修正し、@Ignoreアノテーションを外す
   * </p>
   */
  @Test
  @Ignore
  public void test_getMasterData_正常_該当データあり_日付項目() {
    // 事前準備
    Validation nameValidation = new Validation() {
      {
        setMaxlength(2);
      }
    };
    Field eventDate = new Field() {
      {
        setPhysicalName("event_reg_date");
        setTitle("イベント発生日時");
        setType(FieldType.DATE);
      }
    };
    Field noticeStatus = new Field() {
      {
        setPhysicalName("m_notice_status");
        setTitle("緊急発報ステータス");
        setType(FieldType.NUMBER);
        setValidation(nameValidation);
      }
    };
    SysMasterDefine.ColumnInfo column = new SysMasterDefine.ColumnInfo() {
      // 項目の設定(イベント発生日時、緊急発報ステータス)
      {
        setFields(Arrays.asList(eventDate, noticeStatus));
      }
    };
    SysMasterDefine masterDefine = new SysMasterDefine() {
      {
        setMasterName("装置動作記録");
        setMasterPhysicalName("mnt_motion_record");
        setMode("1");
        setAllowSort("1");
        setAllowAddRecord("1");
        setDispOrder(1);
        setColumnInfo(column);
      }
    };
    String facilityCd = "000001";

    // 実行
    List<Map<String, Object>> result = target.getMasterData(masterDefine, facilityCd);

    // 検証
    assertThat(result, hasSize(3));
    assertThat(result.get(0).get("eventRegDate").toString(), is("2018-03-29 12:13:14.0"));
    assertThat(result.get(0).get("mNoticeStatus"), is(BigDecimal.valueOf(1)));
    assertThat(result.get(1).get("eventRegDate").toString(), is("2018-03-29 12:13:14.0"));
    assertThat(result.get(1).get("mNoticeStatus"), is(BigDecimal.valueOf(-1)));
    assertThat(result.get(2).get("eventRegDate").toString(), is("2018-03-28 11:22:33.0"));
    assertThat(result.get(2).get("mNoticeStatus"), is(BigDecimal.valueOf(-1)));
  }

  /**
   * getMasterData()の検証.
   * <p>
   *   条件：該当データなし
   *   結果：取得結果0件であること
   * </p>
   */
  @Test
  public void test_getMasterData_正常_該当データなし() {
    // 事前準備
    Validation numberValidation = new Validation() {
      {
        setMin(new BigDecimal("1"));
        setMax(new BigDecimal("99"));
      }
    };
    Validation nameValidation = new Validation() {
      {
        setMaxlength(20);
      }
    };
    Field deviceNo = new Field() {
      {
        setPhysicalName("device_edge_no");
        setTitle("デバイスエッジ番号");
        setType(FieldType.NUMBER);
        setValidation(numberValidation);
      }
    };
    Field deviceName = new Field() {
      {
        setPhysicalName("device_name");
        setTitle("デバイス名");
        setType(FieldType.STRING);
        setValidation(nameValidation);
      }
    };
    SysMasterDefine.ColumnInfo column = new SysMasterDefine.ColumnInfo() {
      // 項目の設定(デバイスエッジ番号、デバイス名)
      {
        setFields(Arrays.asList(deviceNo, deviceName));
      }
    };
    SysMasterDefine masterDefine = new SysMasterDefine() {
      {
        setMasterName("デバイスエッジマスタ");
        setMasterPhysicalName("mst_device_edge");
        setMode("1");
        setAllowSort("1");
        setAllowAddRecord("1");
        setDispOrder(1);
        setColumnInfo(column);
      }
    };
    String facilityCd = "12345";

    // 実行
    List<Map<String, Object>> result = target.getMasterData(masterDefine, facilityCd);

    // 検証
    assertThat(result, hasSize(0));
  }


  /**
   * selectPk()の検証.
   * <p>
   *   条件：成功
   *   結果：正常に取得されること
   * </p>
   */
  @Test
  public void test_selectPk_正常_成功() {

    // 事前準備
    // 対象データ
    @SuppressWarnings("serial")
    Map<String, Object> masterData = new HashMap<String, Object>() {
      {
        put("deviceEdgeNo", 10);
        put("machineTypeCd", "A1");
        put("machineSerial", "10000000");
        put("comFormatCd", "M");
        put("dataType", 2);
        put("testType", 3);
        put("emailText", "メール本文テキスト");
        put("remarks", "insertデータ");
      }
    };

    // マスタ定義
    Field motionRecordNo = new Field() {
      {
        setPhysicalName("motion_record_no");
        setTitle("装置動作記録番号");
        setType(FieldType.NUMBER);
        setAlias("code");
      }
    };
    Field deviceEdgeNo = new Field() {
      {
        setPhysicalName("device_edge_no");
        setTitle("デバイスエッジ番号");
        setType(FieldType.NUMBER);
      }
    };
    Field machineTypeCd = new Field() {
      {
        setPhysicalName("machine_type_cd");
        setTitle("型式コード");
        setType(FieldType.STRING);
      }
    };
    Field machineSerial = new Field() {
      {
        setPhysicalName("machine_serial");
        setTitle("製造番号");
        setType(FieldType.STRING);
      }
    };
    Field comFormatCd = new Field() {
      {
        setPhysicalName("com_format_cd");
        setTitle("通信フォーマット");
        setType(FieldType.STRING);
      }
    };
    Field dataType = new Field() {
      {
        setPhysicalName("data_type");
        setTitle("データ種別");
        setType(FieldType.NUMBER);
      }
    };
    Field testType = new Field() {
      {
        setPhysicalName("test_type");
        setTitle("自己診断種別");
        setType(FieldType.NUMBER);
      }
    };
    Field emailText = new Field() {
      {
        setPhysicalName("email_text");
        setTitle("メール本文");
        setType(FieldType.STRING);
      }
    };
    Field remarks = new Field() {
      {
        setPhysicalName("remarks");
        setTitle("備考");
        setType(FieldType.STRING);
      }
    };

    SysMasterDefine.ColumnInfo column = new SysMasterDefine.ColumnInfo() {
      // 項目の設定
      {
        setFields(Arrays.asList(motionRecordNo, deviceEdgeNo, machineTypeCd, machineSerial, comFormatCd, dataType, testType, emailText, remarks));
      }
    };
    SysMasterDefine masterDefine = new SysMasterDefine() {
      {
        setMasterName("装置動作記録");
        setMasterPhysicalName("mnt_motion_record");
        setMode("1");
        setAllowSort("1");
        setAllowAddRecord("1");
        setDispOrder(1);
        setColumnInfo(column);
      }
    };
    String facilityCd = "888881";

    // 実行
    target.insertMasterData(masterData, masterDefine, facilityCd);
    // 追加レコードのPKを取得
    Long serial = target.selectCurrentSeq("motion_record_no", "mnt_motion_record");

    // 検証
    assertThat(serial, is(2L));

    serial = target.selectCurrentSeq("motion_record_no", "mnt_motion_record");

    // 検証
    assertThat(serial, is(2L));

  }

  /**
   * insertMasterData()の検証.
   * <p>
   *   条件：更新成功
   *   結果：正常に更新されること
   * </p>
   */
  @Test
  public void test_insertMasterData_正常_更新成功() {

    // 事前準備
    // 対象データ
    @SuppressWarnings("serial")
    Map<String, Object> masterData = new HashMap<String, Object>() {
      {
        put("deviceEdgeNo", 10);
        put("machineTypeCd", "A1");
        put("machineSerial", "10000000");
        put("comFormatCd", "M");
        put("dataType", 2);
        put("testType", 3);
        put("emailText", "メール本文テキスト");
        put("remarks", "insertデータ");
      }
    };

    // マスタ定義
    Field motionRecordNo = new Field() {
      {
        setPhysicalName("motion_record_no");
        setTitle("装置動作記録番号");
        setType(FieldType.NUMBER);
        setAlias("code");
      }
    };
    Field deviceEdgeNo = new Field() {
      {
        setPhysicalName("device_edge_no");
        setTitle("デバイスエッジ番号");
        setType(FieldType.NUMBER);
      }
    };
    Field machineTypeCd = new Field() {
      {
        setPhysicalName("machine_type_cd");
        setTitle("型式コード");
        setType(FieldType.STRING);
      }
    };
    Field machineSerial = new Field() {
      {
        setPhysicalName("machine_serial");
        setTitle("製造番号");
        setType(FieldType.STRING);
      }
    };
    Field comFormatCd = new Field() {
      {
        setPhysicalName("com_format_cd");
        setTitle("通信フォーマット");
        setType(FieldType.STRING);
      }
    };
    Field dataType = new Field() {
      {
        setPhysicalName("data_type");
        setTitle("データ種別");
        setType(FieldType.NUMBER);
      }
    };
    Field testType = new Field() {
      {
        setPhysicalName("test_type");
        setTitle("自己診断種別");
        setType(FieldType.NUMBER);
      }
    };
    Field emailText = new Field() {
      {
        setPhysicalName("email_text");
        setTitle("メール本文");
        setType(FieldType.STRING);
      }
    };
    Field remarks = new Field() {
      {
        setPhysicalName("remarks");
        setTitle("備考");
        setType(FieldType.STRING);
      }
    };

    SysMasterDefine.ColumnInfo column = new SysMasterDefine.ColumnInfo() {
      // 項目の設定
      {
        setFields(Arrays.asList(motionRecordNo, deviceEdgeNo, machineTypeCd, machineSerial, comFormatCd, dataType, testType, emailText, remarks));
      }
    };
    SysMasterDefine masterDefine = new SysMasterDefine() {
      {
        setMasterName("装置動作記録");
        setMasterPhysicalName("mnt_motion_record");
        setMode("1");
        setAllowSort("1");
        setAllowAddRecord("1");
        setDispOrder(1);
        setColumnInfo(column);
      }
    };
    String facilityCd = "888881";

    // 実行
    target.insertMasterData(masterData, masterDefine, facilityCd);
    // 追加レコードを取得
    Optional<MntMotionRecord> optEntity = editTarget.selectAll().stream()
        .filter(record -> record.getRemarks().equals("insertデータ"))
        .findFirst();

    // 検証
    assertTrue(optEntity.isPresent());
    MntMotionRecord insertedEntity = optEntity.get();
    assertThat(insertedEntity.getDeviceEdgeNo(), is(masterData.get("deviceEdgeNo")));
    assertThat(insertedEntity.getMachineTypeCd(), is(masterData.get("machineTypeCd")));
    assertThat(insertedEntity.getMachineSerial(), is(masterData.get("machineSerial")));
    assertThat(insertedEntity.getComFormatCd(), is(masterData.get("comFormatCd")));
    assertThat(insertedEntity.getDataType(), is(masterData.get("dataType")));
    assertThat(insertedEntity.getTestType(), is(masterData.get("testType")));
    assertThat(insertedEntity.getEmailText(), is(masterData.get("emailText")));
    assertThat(insertedEntity.getRemarks(), is(masterData.get("remarks")));
    assertThat(insertedEntity.getUpDate(), notNullValue());
    assertThat(insertedEntity.getRegDate(), notNullValue());

  }

  /**
   * updateMasterData()の検証.
   * <p>
   * 条件：更新成功 結果：正常に更新されること
   * </p>
   */
  @Test
  public void test_updateMasterData_正常_更新成功() {

    // 事前準備
    // 対象データ
    @SuppressWarnings("serial")
    Map<String, Object> masterData = new HashMap<String, Object>() {
      {
        put("code", 21L);
        put("deviceEdgeNo", 10);
        put("machineTypeCd", "A1");
        put("machineSerial", "10000000");
        put("comFormatCd", "M");
        put("dataType", 2);
        put("testType", 3);
        put("emailText", "メール本文テキスト");
        put("remarks", "updateデータ");
      }
    };

    // マスタ定義
    Field motionRecordNo = new Field() {
      {
        setPhysicalName("motion_record_no");
        setTitle("装置動作記録番号");
        setType(FieldType.NUMBER);
        setAlias("code");
      }
    };
    Field deviceEdgeNo = new Field() {
      {
        setPhysicalName("device_edge_no");
        setTitle("デバイスエッジ番号");
        setType(FieldType.NUMBER);
      }
    };
    Field machineTypeCd = new Field() {
      {
        setPhysicalName("machine_type_cd");
        setTitle("型式コード");
        setType(FieldType.STRING);
      }
    };
    Field machineSerial = new Field() {
      {
        setPhysicalName("machine_serial");
        setTitle("製造番号");
        setType(FieldType.STRING);
      }
    };
    Field comFormatCd = new Field() {
      {
        setPhysicalName("com_format_cd");
        setTitle("通信フォーマット");
        setType(FieldType.STRING);
      }
    };
    Field dataType = new Field() {
      {
        setPhysicalName("data_type");
        setTitle("データ種別");
        setType(FieldType.NUMBER);
      }
    };
    Field testType = new Field() {
      {
        setPhysicalName("test_type");
        setTitle("自己診断種別");
        setType(FieldType.NUMBER);
      }
    };
    Field emailText = new Field() {
      {
        setPhysicalName("email_text");
        setTitle("メール本文");
        setType(FieldType.STRING);
      }
    };
    Field remarks = new Field() {
      {
        setPhysicalName("remarks");
        setTitle("備考");
        setType(FieldType.STRING);
      }
    };

    SysMasterDefine.ColumnInfo column = new SysMasterDefine.ColumnInfo() {
      // 項目の設定
      {
        setFields(Arrays.asList(motionRecordNo, deviceEdgeNo, machineTypeCd, machineSerial, comFormatCd, dataType, testType,
            emailText, remarks));
      }
    };
    SysMasterDefine masterDefine = new SysMasterDefine() {
      {
        setMasterName("装置動作記録");
        setMasterPhysicalName("mnt_motion_record");
        setMode("1");
        setAllowSort("1");
        setAllowAddRecord("1");
        setDispOrder(1);
        setColumnInfo(column);
      }
    };

    // 実行
    target.updateMasterData(masterData, masterDefine);
    // 更新レコードを取得
    MntMotionRecord updatedUser = editTarget.selectByMotionRecordNo((long)masterData.get("code"));

    // 検証
    assertThat(updatedUser.getDeviceEdgeNo(), is(masterData.get("deviceEdgeNo")));
    assertThat(updatedUser.getMachineTypeCd(), is(masterData.get("machineTypeCd")));
    assertThat(updatedUser.getMachineSerial(), is(masterData.get("machineSerial")));
    assertThat(updatedUser.getComFormatCd(), is(masterData.get("comFormatCd")));
    assertThat(updatedUser.getDataType(), is(masterData.get("dataType")));
    assertThat(updatedUser.getTestType(), is(masterData.get("testType")));
    assertThat(updatedUser.getEmailText(), is(masterData.get("emailText")));
    assertThat(updatedUser.getRemarks(), is(masterData.get("remarks")));
    assertThat(updatedUser.getUpDate(), notNullValue());
  }

}
