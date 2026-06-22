package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.PERSONAL;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * {@link SysDataSetPersonalDao} のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql(value = "classpath:dao.script/SysDataSetPersonalDaoTest.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
public class SysDataSetPersonalDaoTest {

  /**
   * テスト対象Dao.
   */
  @Autowired
  private SysDataSetPersonalDao target;

  /**
   * executeSql()の検証.
   * <p>
   * 条件：DB6に存在するテーブルのSQLを指定
   * 結果：結果が取得できること
   * </p>
   */
  @Test
  public void test_executeSql_正常() {
    // 事前準備
    SelectBuilder builder = SelectBuilder.newInstance(Config.get(target));
    builder.sql(" SELECT * FROM pat_personal_main ");

    // 実行
    List<Map<String, Object>> result = target.executeSql(builder);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).hasSize(2);

    Optional<Map<String, Object>> map = result.stream().filter(r -> Long.valueOf(r.get("pat_id").toString()) == 1).findFirst();
    // 値を取得できることの検証のため、全項目の確認は行わない
    assertThat(map.get().get("hosp_pat_id")).isEqualTo("000000000001");
    assertThat(map.get().get("facility_cd")).isEqualTo("009991");

    map = result.stream().filter(r -> Long.valueOf(r.get("pat_id").toString()) == 2).findFirst();
    assertThat(map.get().get("hosp_pat_id")).isEqualTo("000000000002");
    assertThat(map.get().get("facility_cd")).isEqualTo("009992");
  }

  /**
   * executeSql()の検証.
   * <p>
   * 条件：DB6に存在しないテーブルのSQLを指定
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
