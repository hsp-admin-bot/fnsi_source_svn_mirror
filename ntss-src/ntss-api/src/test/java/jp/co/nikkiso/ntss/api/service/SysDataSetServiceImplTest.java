package jp.co.nikkiso.ntss.api.service;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.AUTH;
import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.DEFAULT;
import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.PERSONAL;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasEntry;
import static org.hamcrest.Matchers.is;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.service.SysDataSetServiceImpl.UseApplication;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.SysDataSetDao;
import jp.co.nikkiso.ntss.core.entity.SysDataSet.Detail;
import jp.co.nikkiso.ntss.core.exception.NtssException;


@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional(value=CoreConstant.TransactionManagerName.ALL)
@Sql(value = "classpath:resource.script/SysDataSetServiceTest.db5.before.sql", config = @SqlConfig(dataSource = DEFAULT, transactionManager = CoreConstant.TransactionManagerName.DEFAULT))
@Sql(value = "classpath:resource.script/SysDataSetServiceTest.db6.before.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
@Sql(value = "classpath:resource.script/SysDataSetServiceTest.db4.before.sql", config = @SqlConfig(dataSource = AUTH, transactionManager = CoreConstant.TransactionManagerName.AUTH))
public class SysDataSetServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private SysDataSetService target;

  /**
   * データセットのDaoインタフェース.
   */
  @Autowired
  private SysDataSetDao sysDataSetDao;

  /**
   * 例外の発生をテストするためのルール.
   */
  @Rule
  public ExpectedException expectedException = ExpectedException.none();

  /**
   * createSelectBuilder(privateメソッド)をinvokeする.
   *
   * @param config DB接続先情報
   * @param sql SQL
   * @param dataKey データキー
   * @return {@link SelectBuilder}
   * @throws Throwable
   */
  private SelectBuilder invokeCreateSelectBuilder(Config config, String sql, Map<String, Object> dataKey) throws Throwable {
    try {
      Method method = SysDataSetServiceImpl.class.getDeclaredMethod("createSelectBuilder", Config.class, String.class, Map.class);
      method.setAccessible(true);
      return (SelectBuilder) method.invoke(target, config, sql, dataKey);
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
   * replaceReportInfo(privateメソッド)をinvokeする.
   *
   * @param reportInfo 帳票出力情報
   * @param details データセットの詳細情報
   * @return 帳票出力情報
   * @throws Throwable
   */
  private List<Map<String, Object>> invokeReplaceReportInfo(List<Map<String, Object>> reportInfo, List<Detail> details) throws Throwable {
    try {
      Method method = SysDataSetServiceImpl.class.getDeclaredMethod("replaceReportInfo", List.class, List.class);
      method.setAccessible(true);
      return (List<Map<String, Object>>) method.invoke(target, reportInfo, details);
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
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が1つも設定されていないSQLが引数で渡される
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータなし() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where is_del = '1'";
    Map<String, Object> dataKey = new HashMap<>();

    String expected = sql;

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().toString(), is(expected));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が1つ設定されているSQLが引数で渡される（where @xxx and is_del）
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ1つ_パラメータ_固定() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx = @xxx and is_del = '1'";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", "value");

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx = ");
    expected.param(String.class, "value");
    expected.sql(" and is_del = '1'");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が1つ設定されているSQLが引数で渡される（where is_del and @xxx）
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ1つ_固定_パラメータ() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where is_del = '1' and xxx = @xxx";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", "value");

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where is_del = '1' and xxx = ");
    expected.param(String.class, "value");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が2つ設定されているSQLが引数で渡される
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ2つ() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx = @xxx and yyy = @yyy";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", "value_x");
    dataKey.put("yyy", "value_y");

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx = ");
    expected.param(String.class, "value_x");
    expected.sql(" and yyy = ");
    expected.param(String.class, "value_y");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：SQLのパラメータ（@xxx）とデータキーの内容が不一致な引数が渡される
   * 結果：SQLのパラメータ（@xxx）がそのままな SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ不一致() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx = @xxx";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@yyy", "value");

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx = @xxx");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）にそれぞれにデータ型が指定されているSQLが引数で渡される
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ_全データ型() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx = @xxx and yyy = @yyy and zzz = @zzz";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", String.valueOf(1));
    dataKey.put("@yyy", Long.valueOf(1));
    dataKey.put("@zzz", Integer.valueOf(1));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx = ");
    expected.param(String.class, "1");
    expected.sql(" and yyy = ");
    expected.param(Long.class, 1L);
    expected.sql(" and zzz = ");
    expected.param(Integer.class, 1);

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）に想定しないデータ型が指定されているSQLが引数で渡される
   * 結果：NtssExceptionがThrowされること
   */
  @Test
  public void test_createSelectBuilder_異常_SQLパラメータ_想定しないデータ型() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx = @xxx";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", new Date());

    // 実行
    // 検証
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("");
    invokeCreateSelectBuilder(config, sql, dataKey);
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（String）
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ1つ_配列パラメータ_String() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList("1","2","3"));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（Integer）
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ1つ_配列パラメータ_Integer() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList(1,2,3));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(Integer.class, 1);
    expected.sql(",");
    expected.param(Integer.class, 2);
    expected.sql(",");
    expected.param(Integer.class, 3);
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（Long）
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ1つ_配列パラメータ_Long() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList(1L,2L,3L));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（String）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_同一SQLパラメータ2つ_配列パラメータ_String() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and yyy in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList("1","2","3"));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(") and yyy in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（Integer）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_同一SQLパラメータ2つ_配列パラメータ_Integer() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and yyy in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList(1,2,3));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(Integer.class, 1);
    expected.sql(",");
    expected.param(Integer.class, 2);
    expected.sql(",");
    expected.param(Integer.class, 3);
    expected.sql(") and yyy in (");
    expected.param(Integer.class, 1);
    expected.sql(",");
    expected.param(Integer.class, 2);
    expected.sql(",");
    expected.param(Integer.class, 3);
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（Long）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_同一SQLパラメータ2つ_配列パラメータ_Long() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and yyy in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList(1L,2L,3L));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") and yyy in (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（String）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_同一SQLパラメータ3つ_配列パラメータ_String() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and yyy in (@xxx) and zzz in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList("1","2","3"));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(") and yyy in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(") and zzz in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（Integer）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_同一SQLパラメータ3つ_配列パラメータ_Integer() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and yyy in (@xxx) and zzz in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList(1,2,3));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(Integer.class, 1);
    expected.sql(",");
    expected.param(Integer.class, 2);
    expected.sql(",");
    expected.param(Integer.class, 3);
    expected.sql(") and yyy in (");
    expected.param(Integer.class, 1);
    expected.sql(",");
    expected.param(Integer.class, 2);
    expected.sql(",");
    expected.param(Integer.class, 3);
    expected.sql(") and zzz in (");
    expected.param(Integer.class, 1);
    expected.sql(",");
    expected.param(Integer.class, 2);
    expected.sql(",");
    expected.param(Integer.class, 3);
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（Long）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_同一SQLパラメータ3つ_配列パラメータ_Long() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and yyy in (@xxx) and zzz in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList(1L,2L,3L));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") and yyy in (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") and zzz in (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }


  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（Long）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_準備リストSQL() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);

    // SQL
    StringBuilder sb = new StringBuilder();
    sb.append("SELECT to_timestamp(treat_date,'YYYYMMDD') as treat_date,kind,Name,SUM(Amount) as amount,unit ")
      .append(System.getProperty("line.separator"))
      .append("FROM (")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 1 as disp_order,om.treat_date,'ダイアライザ' as kind,dz.model_number AS Name,1 AS Amount,COALESCE(om.ind_cond_info::json#>>'{5,unit}','') AS Unit FROM ord_main om LEFT OUTER JOIN mst_dialyzer dz ON TO_NUMBER(om.ind_cond_info::json#>>'{5,value}','99999999')=dz.dialyzer_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>'{5,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 2 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{6,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>'{6,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 3 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{7,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>'{7,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 4 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{8,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>'{8,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 5 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{9,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>'{9,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 5 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{10,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>'{10,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 6 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{11,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>'{11,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("SELECT 7 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{13,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>'{13,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 8 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>'{17,value}','99999999.99') AS Amount,COALESCE(md.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{15,value}','99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>'{15,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 9 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>'{22,value}','99999999.99') AS Amount,COALESCE(md.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{19,value}','99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>'{19,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 10 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name AS Name,(TO_NUMBER(om.ind_cond_info::json#>>'{26,value}','99999999.99')+TO_NUMBER(om.ind_cond_info::json#>>'{28,value}','99999999.99')) AS Amount,COALESCE(md.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{25,value}','99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>'{25,value}' IS NOT NULL")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 11 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name as Name,(TO_NUMBER(medi ->> 'amount' ,'99999999.99')) as Amount,COALESCE(md.unit,'') AS Unit FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_medi_info :: json) medi LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(medi ->> 'cd' ,'99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (@ordNos)  ")
      .append(System.getProperty("line.separator"))
      .append("\tUNION ALL")
      .append(System.getProperty("line.separator"))
      .append("\tSELECT 12 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name as Name,(TO_NUMBER(eqi ->> 'amount' ,'99999999.99')) as Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_equip_info :: json) eqi LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(eqi ->> 'cd' ,'99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (@ordNos)  ")
      .append(System.getProperty("line.separator"))
      .append(") AS EquipmentList ")
      .append(System.getProperty("line.separator"))
      .append("GROUP BY disp_order,treat_date,kind,Name,Unit ")
      .append(System.getProperty("line.separator"))
      .append("ORDER BY disp_order,kind ");

    String sql = sb.toString();
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@ordNos", Arrays.asList(1L,2L,3L));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("SELECT to_timestamp(treat_date,'YYYYMMDD') as treat_date,kind,Name,SUM(Amount) as amount,unit ");
    expected.sql("FROM (");
    expected.sql("\tSELECT 1 as disp_order,om.treat_date,'ダイアライザ' as kind,dz.model_number AS Name,1 AS Amount,COALESCE(om.ind_cond_info::json#>>'{5,unit}','') AS Unit FROM ord_main om LEFT OUTER JOIN mst_dialyzer dz ON TO_NUMBER(om.ind_cond_info::json#>>'{5,value}','99999999')=dz.dialyzer_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") AND om.ind_cond_info::json#>>'{5,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 2 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{6,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") AND om.ind_cond_info::json#>>'{6,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 3 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{7,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") AND om.ind_cond_info::json#>>'{7,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 4 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{8,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") AND om.ind_cond_info::json#>>'{8,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 5 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{9,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") AND om.ind_cond_info::json#>>'{9,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 5 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{10,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") AND om.ind_cond_info::json#>>'{10,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 6 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{11,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")  AND om.ind_cond_info::json#>>'{11,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("SELECT 7 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{13,value}','99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")  AND om.ind_cond_info::json#>>'{13,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 8 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>'{17,value}','99999999.99') AS Amount,COALESCE(md.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{15,value}','99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")  AND om.ind_cond_info::json#>>'{15,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 9 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>'{22,value}','99999999.99') AS Amount,COALESCE(md.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{19,value}','99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")  AND om.ind_cond_info::json#>>'{19,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 10 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name AS Name,(TO_NUMBER(om.ind_cond_info::json#>>'{26,value}','99999999.99')+TO_NUMBER(om.ind_cond_info::json#>>'{28,value}','99999999.99')) AS Amount,COALESCE(md.unit,'') AS Unit FROM ord_main om LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{25,value}','99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")  AND om.ind_cond_info::json#>>'{25,value}' IS NOT NULL");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 11 as disp_order,om.treat_date,COALESCE(mdc.class_name,'') as kind,md.medicine_name as Name,(TO_NUMBER(medi ->> 'amount' ,'99999999.99')) as Amount,COALESCE(md.unit,'') AS Unit FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_medi_info :: json) medi LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(medi ->> 'cd' ,'99999999')=md.medicine_cd LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")  ");
    expected.sql("\tUNION ALL");
    expected.sql("\tSELECT 12 as disp_order,om.treat_date,COALESCE(eqc.class_name,'') as kind,eq.equipment_name as Name,(TO_NUMBER(eqi ->> 'amount' ,'99999999.99')) as Amount,COALESCE(eq.unit,'') AS Unit FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_equip_info :: json) eqi LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(eqi ->> 'cd' ,'99999999')=eq.equipment_cd LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd WHERE om.ord_no IN (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(")  ");
    expected.sql(") AS EquipmentList ");
    expected.sql("GROUP BY disp_order,treat_date,kind,Name,Unit ");
    expected.sql("ORDER BY disp_order,kind ");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が配列（String）でかつ、SQL文内、複数回存在する
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ3つ_同一パラメータあり_配列パラメータ_String() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and zzz in (@yyy) and yyy in (@xxx)";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList("1","2","3"));
    dataKey.put("@yyy", Arrays.asList("9","8","7"));

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(") and zzz in (");
    expected.param(String.class, "9");
    expected.sql(",");
    expected.param(String.class, "8");
    expected.sql(",");
    expected.param(String.class, "7");
    expected.sql(") and yyy in (");
    expected.param(String.class, "1");
    expected.sql(",");
    expected.param(String.class, "2");
    expected.sql(",");
    expected.param(String.class, "3");
    expected.sql(")");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * createSelectBuilder()の検証.
   *
   * 条件：パラメータ（@xxx）が2つ設定されているSQLが引数で渡される
   * 結果：指定したSQLをもとに生成された SelectBuilder が返却されること
   */
  @Test
  public void test_createSelectBuilder_成功_SQLパラメータ2つ_配列パラメータを含む() throws Throwable {
    // 事前準備
    Config config = Config.get(sysDataSetDao);
    String sql = "select * from hoge where xxx in (@xxx) and yyy = @yyy";
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("@xxx", Arrays.asList(1L,2L,3L));
    dataKey.put("yyy", "value_y");

    SelectBuilder expected = SelectBuilder.newInstance(config);
    expected.sql("select * from hoge where xxx in (");
    expected.param(Long.class, 1L);
    expected.sql(",");
    expected.param(Long.class, 2L);
    expected.sql(",");
    expected.param(Long.class, 3L);
    expected.sql(") and yyy = ");
    expected.param(String.class, "value_y");

    // 実行
    SelectBuilder result = invokeCreateSelectBuilder(config, sql, dataKey);

    // 検証
    assertThat(result.getSql().getFormattedSql(), is(expected.getSql().getFormattedSql()));
  }

  /**
   * replaceReportInfo()の検証.
   *
   * 条件：SQL実行結果とデータセット詳細情報が一致していること
   * 結果：フィールド名からデータ項目コードに置き換えられた帳票出力情報が返却されること
   */
  @Test
  public void test_replaceReportInfo_成功_フィールド名_データ項目コード_一致() throws Throwable {
    // 事前準備
    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("field1", "value1_1");
          put("field2", "value1_2");
        }
      },
      new HashMap<String, Object>() {
        {
          put("field1", "value2_1");
          put("field2", "value2_2");
        }
      }
    );
    List<Detail> details = Arrays.asList(
      new Detail() {
        {
          setDataCode("data_code1");
          setFieldName("field1");
        }
      },
      new Detail() {
        {
          setDataCode("data_code2");
          setFieldName("field2");
        }
      }
    );

    Map<String, Object> expectedMap1 = new HashMap<String, Object>() {
      {
        put("data_code1", "value1_1");
        put("data_code2", "value1_2");
      }
    };
    Map<String, Object> expectedMap2 = new HashMap<String, Object>() {
      {
        put("data_code1", "value2_1");
        put("data_code2", "value2_2");
      }
    };
    List<Map<String, Object>> expected = Arrays.asList(
      expectedMap1,
      expectedMap2
    );

    // 実行
    List<Map<String, Object>> result = invokeReplaceReportInfo(reportInfo, details);

    // 検証
    assertThat(result.size(), is(expected.size()));
    Map<String, Object> resultMap = result.get(0);
    assertThat(resultMap.size(), is(expectedMap1.size()));
    assertThat(resultMap, hasEntry("data_code1", "value1_1"));
    assertThat(resultMap, hasEntry("data_code2", "value1_2"));
    resultMap = result.get(1);
    assertThat(resultMap.size(), is(expectedMap2.size()));
    assertThat(resultMap, hasEntry("data_code1", "value2_1"));
    assertThat(resultMap, hasEntry("data_code2", "value2_2"));
  }

  /**
   * replaceReportInfo()の検証.
   *
   * 条件：SQL実行結果とデータセット詳細情報に不一致な情報が含まれていること
   * 結果：データセット詳細情報に存在しないデータはフィールド名がそのままの帳票出力情報が返却されること
   */
  @Test
  public void test_replaceReportInfo_成功_フィールド名_データ項目コード_不一致() throws Throwable {
    // 事前準備
    List<Map<String, Object>> reportInfo = Arrays.asList(
      new HashMap<String, Object>() {
        {
          put("field1", "value1");
          put("field2", "value2");
        }
      }
    );
    List<Detail> details = Arrays.asList(
      new Detail() {
        {
          setDataCode("data_code1");
          setFieldName("field1");
        }
      },
      new Detail() {
        {
          setDataCode("data_code3");
          setFieldName("field3");
        }
      }
    );

    Map<String, Object> expectedMap = new HashMap<String, Object>() {
      {
        put("data_code1", "value1");
        put("field2", "value2");
      }
    };
    List<Map<String, Object>> expected = Arrays.asList(expectedMap);

    // 実行
    List<Map<String, Object>> result = invokeReplaceReportInfo(reportInfo, details);

    // 検証
    assertThat(result.size(), is(expected.size()));
    Map<String, Object> resultMap = result.get(0);
    assertThat(resultMap.size(), is(expectedMap.size()));
    assertThat(resultMap, hasEntry("data_code1", "value1"));
    assertThat(resultMap, hasEntry("field2", "value2"));
  }

  /**
   * getDataList()の検証.
   *
   * 条件：DB5から帳票出力情報を取得するSqlCodeが指定されていること
   * 結果：帳票出力情報が返却されること
   */
  @Test
  public void test_getReportInfo_正常_DB5() {
    // 事前準備
    Long sqlCd = 1L;
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@pat_id", 10L);
      }
    };

    // 実行
    List<Map<String, Object>> result = target.getDataList(sqlCd, dataKey);

    // 検証
    assertThat(result.size(), is(2));
    Map<String, Object> resultMap = result.get(0);
    assertThat(resultMap, hasEntry("ord_no", 1L));
    assertThat(resultMap, hasEntry("facility_cd", "009999"));
    resultMap = result.get(1);
    assertThat(resultMap, hasEntry("ord_no", 2L));
    assertThat(resultMap, hasEntry("facility_cd", "009999"));
  }

  /**
   * getDataList()の検証.
   *
   * 条件：DB6から帳票出力情報を取得するSqlCodeが指定されていること
   * 結果：帳票出力情報が返却されること
   */
  @Test
  public void test_getReportInfo_正常_DB6() {
    // 事前準備
    Long sqlCd = 2L;
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@pat_id", 10L);
      }
    };

    // 実行
    List<Map<String, Object>> result = target.getDataList(sqlCd, dataKey);

    // 検証
    assertThat(result.size(), is(1));
    Map<String, Object> resultMap = result.get(0);
    assertThat(resultMap, hasEntry("pat_id", 10L));
    assertThat(resultMap, hasEntry("facility_cd", "009999"));
  }

  /**
   * getDataList()の検証.
   *
   * 条件：想定外のデータベースから取得するSqlCodeが指定されていること
   * 結果：NtssExceptionがThrowされること
   */
  @Test
  @Ignore("例外が発生した場合でも後続処理を継続する様に対応した為、本テストは不要")
  public void test_getReportInfo_異常_DB() {
    // 事前準備
    Long sqlCd = 4L;
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@pat_id", 10L);
      }
    };

    // 実行
    // 検証
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("");
    target.getDataList(sqlCd, dataKey);
  }

  /**
   * getDataList()の検証.
   *
   * 条件：想定外のデータベースから取得するSqlCodeが指定されていること
   * 結果：例外が発生せず、空のリストが返却されること
   */
  @Test
  public void test_getReportInfo_異常_例外発生() {
    // 事前準備
    Long sqlCd = 6L;
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@pat_id", 10L);
      }
    };
    // 実行
    List<Map<String, Object>>  result = target.getDataList(sqlCd, dataKey);
    // 検証
    assertThat(result.size(), is(0));
  }

  /**
   * getDataList()の検証.

   *
   * 条件：DB4から帳票出力情報を取得するSqlCodeが指定されていること
   * 結果：NtssExceptionがThrowされること
   */
  @Test
  public void test_getReportInfo_正常_DB4() {
    // 事前準備
    Long sqlCd = 3L;
    // テスト用データキーマップ作成
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@user_id", 100);
      }
    };
    // 実行
    List<Map<String, Object>> result = target.getDataList(sqlCd, dataKey);
    // 検証
    assertThat(result.size(), is(1));
    // リストからマップを取得
    Map<String, Object> resultMap = result.get(0);
    assertThat(resultMap.get("user_id"), is(100L));
    assertThat(resultMap.get("facility_cd"), is("012345"));
    assertThat(resultMap.get("disp_user_id"), is("test01"));
    assertThat(resultMap.get("user_password"), is("test99"));
    assertThat(resultMap.get("failure_cnt"), is(new BigDecimal("0")));
    assertThat(resultMap.get("reg_date"), is(Timestamp.valueOf("2020-03-16 13:00:00")));
    assertThat(resultMap.get("up_date"), is(Timestamp.valueOf("2020-03-16 13:05:00")));
  }

  /**
   * {@link SysDataSetService#getDataList(Long, Map)}の検証.
   *
   * 条件:指定したsqlCdに該当するsqlが空である事
   * 結果:例外が発生せず、空のリストが返却される事
   */
  @Test
  public void test_getDataList_正常_sqlCodeのsqlが空() {
    // 事前準備
    Long sqlCd = 5L;
    // テスト用データキーマップ作成
    Map<String, Object> dataKey = new HashMap<String, Object>();
    // 実行
    List<Map<String, Object>> result = target.getDataList(sqlCd, dataKey);
    // 検証
    assertThat(result.size(), is(0));
  }

  /**
   * {@link SysDataSetService#getDataList(Long, Map)}の検証.
   *
   * 条件:指定したsqlCdに該当するsqlが<code>null</code>である事
   * 結果:例外が発生せず、空のリストが返却される事
   */
  @Test
  @Ignore("データベース上、sql列にNotNull制約である為、nullが格納される事はない.")
  public void test_getDataList_正常_sqlCodeのsqlがnull() {
    // 事前準備
    Long sqlCd = 6L;
    // テスト用データキーマップ作成
    Map<String, Object> dataKey = new HashMap<String, Object>();
    // 実行
    List<Map<String, Object>> result = target.getDataList(sqlCd, dataKey);
    // 検証
    assertThat(result.size(), is(0));
  }
  /**
   * getDataList()の検証.
   * ※use_applicationの指定ありの場合
   *
   * 条件 : sys_data_setのuse_applicationが未設定の場合に、呼び出し元の使用用途が設定されている場合
   * 結果 : NtssExceptionがThrowされること
   * */
  @Test
  public void test_checkUseApplication_use_applicationが未設定の場合エラー() {

    // 事前準備
    Long sqlCd = 3L;
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@pat_id", 10L);
      }
    };

    // 実行
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("sys_data_setにuse_applicationが設定されていません。");
    target.getDataList(sqlCd, dataKey, UseApplication.REPORT);
  }

  /**
   * getDataList()の検証.
   * ※use_applicationの指定ありの場合
   *
   * 条件 : sys_data_setのuse_applicationの形式が不正
   * 結果 : NtssExceptionがThrowされること
   * */
  @Test
  public void test_checkUseApplication_use_applicationの形式が想定以外の場合エラー() {

    // 事前準備
    Long sqlCd = 2L;
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@pat_id", 10L);
      }
    };

    // 実行
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("use_applicationの変換に失敗しました。");
    target.getDataList(sqlCd, dataKey, UseApplication.PATIENT_EVENT_TBL);
  }

  /**
   * getDataList()の検証.
   * ※use_applicationの指定ありの場合
   *
   * 条件 : sys_data_setのuse_applicationに、呼び出し元の使用用途が含まれない場合
   * 結果 : NtssExceptionがThrowされること
   * */
  @Test
  public void test_checkUseApplication_use_applicationに読み出し元の使用用途が含まれない場合エラー() {

    // 事前準備
    Long sqlCd = 1L;
    Map<String, Object> dataKey = new HashMap<String, Object>() {
      {
        put("@pat_id", 10L);
      }
    };

    // 実行
    expectedException.expect(NtssException.class);
    expectedException.expectMessage("対象のSqlCodeのデータセットは使用できません。");
    target.getDataList(sqlCd, dataKey, UseApplication.PATIENT_EVENT_TBL);
  }
}
