package jp.co.nikkiso.ntss.core.dao;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.SysDataSet.Detail;

/**
 * {@link SysDataSetDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:dao.script/SysDataSetDaoTest.before.sql")
public class SysDataSetDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private SysDataSetDao target;

  /**
   * selectByCd()の検証.
   * <p>
   * 条件：データが存在する帳票番号を指定 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_selectByCd_正常_データあり() {
    // 実行
    SysDataSet result = target.selectByCd(1L);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result.getSql()).isEqualTo("select * from hoge");
    assertThat(result.getDbClass()).isEqualTo(2);
    assertThat(result.getDetailInfo().getDetails()).hasSize(2);

    List<Detail> details = result.getDetailInfo().getDetails();
    Detail detail = details.get(0);
    assertThat(detail.getDataCategory()).isEqualTo("data_category");
    assertThat(detail.getDataClass()).isEqualTo("data_class");
    assertThat(detail.getDataCode()).isEqualTo("data_code");
    assertThat(detail.getDataName()).isEqualTo("data_name");
    assertThat(detail.getFieldName()).isEqualTo("field_name");
    assertThat(detail.getConvTable().size()).isEqualTo(1);
    assertThat(detail.getConvTable().get(0).getCode()).isEqualTo("code");
    assertThat(detail.getConvTable().get(0).getItem()).isEqualTo("item");
    assertThat(detail.getConvTable().get(0).getDisp()).isEqualTo("disp");
    assertThat(detail.getDataType()).isEqualTo("data_type");
    assertThat(detail.getPreview()).isEqualTo("preview");
    assertThat(detail.getDispFormat()).isEqualTo("disp_format");
    assertThat(detail.getCanCalc()).isEqualTo("can_calc");
    assertThat(detail.getFacilityFilterType()).isEqualTo("facility_filter_type");
    assertThat(detail.getFacilityTable()).isEqualTo("facility_table");
    detail = details.get(1);
    assertThat(detail.getDataCode()).isEqualTo("pat_name_code");
    assertThat(detail.getFieldName()).isEqualTo("pat_name_name");
    assertThat(result.getCanRepeat()).isEqualTo("3");
    assertThat(result.getUseApplication()).isEqualTo("{\"test1\": \"value1\"}");
    assertThat(result.getReportClass().getClasses().get(0)).isEqualTo(4);
    assertThat(result.getReportClass().getClasses().get(1)).isEqualTo(5);
    assertThat(result.getMemo()).isEqualTo("memo");
    assertThat(result.getRegDate()).isEqualTo(Timestamp.valueOf("2019-05-29 17:24:00.000"));
    assertThat(result.getUpDate()).isEqualTo(Timestamp.valueOf("2019-05-29 17:25:00.000"));
  }

  /**
   * selectByCd()の検証.
   * <p>
   * 条件：データが存在しないSQLコードを指定
   * 結果：EmptyResultDataAccessException例外が投げられること
   * </p>
   */
  @Test(expected = EmptyResultDataAccessException.class)
  public void test_selectByCd_正常_データなし_帳票番号不一致() {
    // 実行
    // 検証
    target.selectByCd(2L);
  }

  /**
   * executeSql()の検証.
   * <p>
   * 条件：DB5に存在するテーブルのSQLを指定
   * 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_executeSql_正常() {
    // 事前準備
    SelectBuilder builder = SelectBuilder.newInstance(Config.get(target));
    builder.sql(" SELECT * FROM sys_data_set ");

    // 実行
    List<Map<String, Object>> result = target.executeSql(builder);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).hasSize(2);

    Optional<Map<String, Object>> map = result.stream().filter(r -> Long.valueOf(r.get("sql_cd").toString()) == 1).findFirst();
    // 値を取得できることの検証のため、全項目の確認は行わない
    assertThat(map.get().get("sql")).isEqualTo("select * from hoge");
    assertThat(map.get().get("db_class")).isEqualTo(2);

    map = result.stream().filter(r -> Long.valueOf(r.get("sql_cd").toString()) == 10).findFirst();
    assertThat(map.get().get("sql")).isEqualTo("select");
    assertThat(map.get().get("db_class")).isEqualTo(9);
  }

  /**
   * executeSql()の検証.
   * <p>
   * 条件：DB5に存在しないテーブルのSQLを指定
   * 結果：例外が投げられること
   * </p>
   */
  @Test(expected = Exception.class)
  public void test_executeSql_異常() {
    // 事前準備
    SelectBuilder builder = SelectBuilder.newInstance(Config.get(target));
    builder.sql(" SELECT * FROM hoge ");

    // 実行
    // 検証
    target.executeSql(builder);
  }

}
