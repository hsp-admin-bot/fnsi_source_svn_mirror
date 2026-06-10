package jp.co.nikkiso.ntss.admin_web.service;


import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.SysSigninManager;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;

import java.sql.Timestamp;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertNotNull;

@RunWith(SpringRunner.class)
@SpringBootTest
@Sql(value = "classpath:resource.service/SysSigninManagerServiceImplTest.before.sql",
     config = @SqlConfig(dataSource = CoreConstant.DataSourceName.AUTH, transactionManager = CoreConstant.TransactionManagerName.AUTH))
@Sql(value = "classpath:resource.service/SysSigninManagerServiceImplTest_db4.before.sql",
     config = @SqlConfig(dataSource = CoreConstant.DataSourceName.AUTH, transactionManager = CoreConstant.TransactionManagerName.AUTH))
public class SysSigninManagerServiceImplTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private SysSigninManagerService sysSigninManagerService;

  /**
   * {@link SysSigninManagerService#getAll()} の検証
   *
   * <p>
   *   条件:データが存在する事
   *   結果:全データが取得出来る事
   * </p>
   */
  @Test
  public void test_getAll_正常_データが存在する場合() {
    // 実行
    List<SysSigninManager> result = sysSigninManagerService.getAll();

    // 検証
    assertThat(result).hasSize(4);

    // 検証
    Assert.assertThat(result.get(0).getTerminalUniqueString(), is("term1"));
    Assert.assertThat(result.get(0).getFacilityCd(), is("009999"));
    Assert.assertThat(result.get(0).getUserId(), is(1L));
    Assert.assertThat(result.get(0).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:00:00")));
    Assert.assertThat(result.get(0).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:05:00")));

    Assert.assertThat(result.get(1).getTerminalUniqueString(), is("term2"));
    Assert.assertThat(result.get(1).getFacilityCd(), is("009999"));
    Assert.assertThat(result.get(1).getUserId(), is(2L));
    Assert.assertThat(result.get(1).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:10:00")));
    Assert.assertThat(result.get(1).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:15:00")));

    Assert.assertThat(result.get(2).getTerminalUniqueString(), is("term3"));
    Assert.assertThat(result.get(2).getFacilityCd(), is("009999"));
    Assert.assertThat(result.get(2).getUserId(), is(3L));
    Assert.assertThat(result.get(2).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:20:00")));
    Assert.assertThat(result.get(2).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:25:00")));

    Assert.assertThat(result.get(3).getTerminalUniqueString(), is("term5"));
    Assert.assertThat(result.get(3).getFacilityCd(), is("123456"));
    Assert.assertThat(result.get(3).getUserId(), is(2L));
    Assert.assertThat(result.get(3).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:30:00")));
    Assert.assertThat(result.get(3).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:35:00")));
  }

  /**
   * {@link SysSigninManagerService#getByParam(SysSigninManager)}の検証
   *
   * <p>
   *   条件:該当データが存在しない事
   *   結果:空のリストが返却される事
   * </p>
   */
  @Test
  public void test_getByParam_正常_条件に該当するデータが存在しない場合() {
    // 事前準備
    final String terminalUniqueString = "test";
    final String facilityCd = "009999";
    final Long userId = 1L;
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);
    sysSigninManager.setUserId(userId);

    // 実行
    List<SysSigninManager> result = sysSigninManagerService.getByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    Assert.assertThat(result.size(), is(0));
  }

  /**
   * {@link SysSigninManagerService#getByParam(SysSigninManager)}の検証
   *
   * <p>
   *   条件:該当データが存在する事
   *   結果:該当するデータのリストが返却される事
   * </p>
   */
  @Test
  public void test_getByParam_正常_条件に該当するデータが存在する場合() {
    // 事前準備
    final String terminalUniqueString = "term1";
    final String facilityCd = "009999";
    final Long userId = 1L;
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);
    sysSigninManager.setUserId(userId);

    // 実行
    List<SysSigninManager> result = sysSigninManagerService.getByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    // 検証
    assertNotNull(result);
    Assert.assertThat(result.size(), is(1));
    Assert.assertThat(result.get(0).getTerminalUniqueString(), is(terminalUniqueString));
    Assert.assertThat(result.get(0).getFacilityCd(), is("009999"));
    Assert.assertThat(result.get(0).getUserId(), is(1L));
    Assert.assertThat(result.get(0).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:00:00")));
    Assert.assertThat(result.get(0).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:05:00")));
  }

  /**
   * {@link SysSigninManagerService#deleteByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:削除対象のデータが存在する事
   *   結果:削除した件数が返却される事
   * </p>
   */
  @Test
  public void test_deleteByParam_正常_条件に該当するデータが存在する場合() {
    // 事前準備
    final String terminalUniqueString = "term3";
    final String facilityCd = "009999";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);

    // 実行
    int selectCount = sysSigninManagerService.deleteByParam(sysSigninManager);

    // データ取得
    List<SysSigninManager> result = sysSigninManagerService.getByParam(sysSigninManager);

    // 検証
    Assert.assertThat(selectCount, is(1));
    assertNotNull(result);
    Assert.assertThat(result.size(), is(0));
  }

  /**
   * {@link SysSigninManagerService#deleteByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:削除対象のデータが存在しない事
   *   結果:0 が返却される事
   * </p>
   */
  @Test
  public void test_deleteByParam_正常_条件に該当するデータが存在しない場合() {
    // 事前準備
    final String terminalUniqueString = "term999";
    final String facilityCd = "009999";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);

    // 実行
    int selectCount = sysSigninManagerService.deleteByParam(sysSigninManager);

    // データ取得
    List<SysSigninManager> result = sysSigninManagerService.getByParam(sysSigninManager);

    // 検証
    Assert.assertThat(selectCount, is(0));
    assertNotNull(result);
    Assert.assertThat(result.size(), is(0));
  }

  /**
   * {@link SysSigninManagerService#insertSysSigninManager(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:端末固有文字列に該当するデータが存在しない事
   *   結果:正常に登録出来る事
   * </p>
   */
  @Test
  public void test_insertSysSigninManager_正常_端末固有文字列に該当するデータが存在しない場合() {
    // 事前準備
    final String terminalUniqueString = "term4";
    final String facilityCd = "123456";
    final Long userId = 5L;
    final Long millis  = System.currentTimeMillis();
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);
    sysSigninManager.setUserId(userId);
    sysSigninManager.setRegDate(new Timestamp(millis));
    sysSigninManager.setUpDate(new Timestamp(millis));

    // 実行
    int result = sysSigninManagerService.insertSysSigninManager(sysSigninManager);
    Assert.assertThat(result, is(1));

    // 検証
    List<SysSigninManager> insertResult = sysSigninManagerService.getByParam(sysSigninManager);
    assertNotNull(insertResult);
    Assert.assertThat(insertResult.size(), is(1));
    Assert.assertThat(insertResult.get(0).getTerminalUniqueString(), is(terminalUniqueString));
    Assert.assertThat(insertResult.get(0).getFacilityCd(), is(facilityCd));
    Assert.assertThat(insertResult.get(0).getUserId(), is(userId));
    assertNotNull(insertResult.get(0).getRegDate());
    assertNotNull(insertResult.get(0).getUpDate());
  }

  /**
   * {@link SysSigninManagerService#insertSysSigninManager(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:端末固有文字列に該当するデータが存在しない事
   *   結果:正常に登録出来る事
   * </p>
   */
  @Test
  public void test_insertSysSigninManager_正常_端末固有文字列に該当するデータが存在する場合() {
    // 事前準備
    final String terminalUniqueString = "term1";
    final String facilityCd = "009999";
    final Long userId = 1L;
    final Long millis  = System.currentTimeMillis();
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);
    sysSigninManager.setUserId(userId);
    sysSigninManager.setRegDate(new Timestamp(millis));
    sysSigninManager.setUpDate(new Timestamp(millis));

    // 既に登録されているデータを取得
    List<SysSigninManager> before = sysSigninManagerService.getByParam(sysSigninManager);
    Assert.assertThat(before.size(), is(1));

    // 実行
    int result = sysSigninManagerService.insertSysSigninManager(sysSigninManager);
    Assert.assertThat(result, is(0));

    // 検証(更新されていない事)
    List<SysSigninManager> insertResult = sysSigninManagerService.getByParam(sysSigninManager);
    assertNotNull(insertResult);
    Assert.assertThat(insertResult.size(), is(1));
    Assert.assertThat(insertResult.get(0).getTerminalUniqueString(), is(before.get(0).getTerminalUniqueString()));
    Assert.assertThat(insertResult.get(0).getFacilityCd(), is(before.get(0).getFacilityCd()));
    Assert.assertThat(insertResult.get(0).getUserId(), is(before.get(0).getUserId()));
    assertNotNull(insertResult.get(0).getRegDate());
    assertNotNull(insertResult.get(0).getUpDate());
  }
}
