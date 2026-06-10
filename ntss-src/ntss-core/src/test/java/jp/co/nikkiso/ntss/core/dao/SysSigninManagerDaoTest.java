package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.SysSigninManager;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

/**
 * {@link SysSigninManagerDao}のテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional(CoreConstant.TransactionManagerName.AUTH)
@Sql(value = "classpath:dao.script/SysSigninManagerDaoTest.before.sql",
     config = @SqlConfig(dataSource = CoreConstant.DataSourceName.AUTH, transactionManager = CoreConstant.TransactionManagerName.AUTH))
public class SysSigninManagerDaoTest {

  /**
   * {@link SysSigninManagerDao#selectAll()}の検証
   *
   * <p>
   *   条件:データが存在する事
   *   結果:登録されている全データが取得出来る事.
   * </p>
   */
  @Test
  public void test_selectAll_正常() {
    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectAll();

    // 検証
    assertThat(result.size(), is(4));

    // 検証
    assertThat(result.get(0).getTerminalUniqueString(), is("term1"));
    assertThat(result.get(0).getFacilityCd(), is("009999"));
    assertThat(result.get(0).getUserId(), is(1L));
    assertThat(result.get(0).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:00:00")));
    assertThat(result.get(0).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:05:00")));

    assertThat(result.get(1).getTerminalUniqueString(), is("term2"));
    assertThat(result.get(1).getFacilityCd(), is("009999"));
    assertThat(result.get(1).getUserId(), is(2L));
    assertThat(result.get(1).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:10:00")));
    assertThat(result.get(1).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:15:00")));

    assertThat(result.get(2).getTerminalUniqueString(), is("term3"));
    assertThat(result.get(2).getFacilityCd(), is("009999"));
    assertThat(result.get(2).getUserId(), is(3L));
    assertThat(result.get(2).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:20:00")));
    assertThat(result.get(2).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:25:00")));

    assertThat(result.get(3).getTerminalUniqueString(), is("term5"));
    assertThat(result.get(3).getFacilityCd(), is("123456"));
    assertThat(result.get(3).getUserId(), is(2L));
    assertThat(result.get(3).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:30:00")));
    assertThat(result.get(3).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:35:00")));
  }

  /**
   * {@link SysSigninManagerDao}
   */
  @Autowired
  SysSigninManagerDao sysSigninManagerDao;

  /**
   * {@link SysSigninManagerDao#insert(SysSigninManager)}の検証.
   *
   * <p>
   *   条件：同じ端末固有文字列が存在しない事.
   *   結果:正常に登録される事.
   * </p>
   */
  @Test
  public void test_insert_正常_同一端末固有文字列が存在しない場合() {
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
    int result = sysSigninManagerDao.insert(sysSigninManager);
    assertThat(result, is(1));

    // 検証
    List<SysSigninManager> insertResult = sysSigninManagerDao.selectByParam(sysSigninManager);
    assertNotNull(insertResult);
    assertThat(insertResult.size(), is(1));
    assertThat(insertResult.get(0).getTerminalUniqueString(), is(terminalUniqueString));
    assertThat(insertResult.get(0).getFacilityCd(), is(facilityCd));
    assertThat(insertResult.get(0).getUserId(), is(userId));
    assertNotNull(insertResult.get(0).getRegDate());
    assertNotNull(insertResult.get(0).getUpDate());
  }

  /**
   * {@link SysSigninManagerDao#insert(SysSigninManager)}の検証.
   *
   * <p>
   *   条件：同じ端末固有文字列が存在する事.
   *   結果:例外が発生する事.
   * </p>
   */
  @Test(expected = DuplicateKeyException.class)
  public void test_insert_異常_同一端末固有文字列が存在する場合() {
    // 事前準備
    final String terminalUniqueString = "term1";
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
    int result = sysSigninManagerDao.insert(sysSigninManager);
  }

  /**
   * {@link SysSigninManagerDao#selectByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:該当データが存在する事.
   *   結果:該当データが取得出来る事.
   * </p>
   */
  @Test
  public void test_selectByParam_正常_端末固有文字列に該当するデータが存在する場合() {
    // 事前準備
    final String terminalUniqueString = "term1";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);

    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(1));
    assertThat(result.get(0).getTerminalUniqueString(), is(terminalUniqueString));
    assertThat(result.get(0).getFacilityCd(), is("009999"));
    assertThat(result.get(0).getUserId(), is(1L));
    assertThat(result.get(0).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:00:00")));
    assertThat(result.get(0).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:05:00")));
  }

  /**
   * {@link SysSigninManagerDao#selectByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:端末固有文字列に該当するデータが存在しない事.
   *   結果:nullが返却される事.
   * </p>
   */
  @Test
  public void test_selectByParam_正常_端末固有文字列に該当するデータが存在しない場合() {
    // 事前準備
    final String terminalUniqueString = "test";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);

    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    assertTrue(result.isEmpty());
  }

  /**
   * {@link SysSigninManagerDao#selectByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:該当データが存在する事.
   *   結果:該当データが取得出来る事.
   * </p>
   */
  @Test
  public void test_selectByParam_正常_利用者IDに該当するデータが存在する場合() {
    // 事前準備
    final Long userId = 2L;
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setUserId(userId);

    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(2));
    assertThat(result.get(0).getTerminalUniqueString(), is("term2"));
    assertThat(result.get(0).getFacilityCd(), is("009999"));
    assertThat(result.get(0).getUserId(), is(userId));
    assertThat(result.get(0).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:10:00")));
    assertThat(result.get(0).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:15:00")));

    // 2件目
    assertThat(result.get(1).getTerminalUniqueString(), is("term5"));
    assertThat(result.get(1).getFacilityCd(), is("123456"));
    assertThat(result.get(1).getUserId(), is(userId));
    assertThat(result.get(1).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:30:00")));
    assertThat(result.get(1).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:35:00")));
  }

  /**
   * {@link SysSigninManagerDao#selectByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:該当データが存在しない事.
   *   結果:空配列が返却される事.
   * </p>
   */
  @Test
  public void test_selectByParam_正常_利用者IDに該当するデータが存在しない場合() {
    // 事前準備
    final Long userId = 100L;
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setUserId(userId);

    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(0));
  }

  /**
   * {@link SysSigninManagerDao#selectByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:該当データが存在する事.
   *   結果:該当データが取得出来る事.
   * </p>
   */
  @Test
  public void test_selectByParam_正常_施設コードに該当するデータが存在する場合() {
    // 事前準備
    final String facilityCd = "009999";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setFacilityCd(facilityCd);

    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(3));
    assertThat(result.get(0).getTerminalUniqueString(), is("term1"));
    assertThat(result.get(0).getFacilityCd(), is("009999"));
    assertThat(result.get(0).getUserId(), is(1L));
    assertThat(result.get(0).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:00:00")));
    assertThat(result.get(0).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:05:00")));

    // 2件目
    assertThat(result.get(1).getTerminalUniqueString(), is("term2"));
    assertThat(result.get(1).getFacilityCd(), is("009999"));
    assertThat(result.get(1).getUserId(), is(2L));
    assertThat(result.get(1).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:10:00")));
    assertThat(result.get(1).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:15:00")));

    // 3件目
    assertThat(result.get(2).getTerminalUniqueString(), is("term3"));
    assertThat(result.get(2).getFacilityCd(), is("009999"));
    assertThat(result.get(2).getUserId(), is(3L));
    assertThat(result.get(2).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:20:00")));
    assertThat(result.get(2).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:25:00")));
  }

  /**
   * {@link SysSigninManagerDao#selectByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:該当データが存在しない事.
   *   結果:空配列が返却される事.
   * </p>
   */
  @Test
  public void test_selectByParam_正常_施設コードに該当するデータが存在しない場合() {
    // 事前準備
    final String facilityCd = "test";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setFacilityCd(facilityCd);

    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(0));
  }

  /**
   * {@link SysSigninManagerDao#selectByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:該当データが存在しない事.
   *   結果:空配列が返却される事.
   * </p>
   */
  @Test
  public void test_selectByParam_正常_複合キーに該当するデータが存在する場合() {
    // 事前準備
    final Long userId = 2L;
    final String facilityCd = "009999";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setUserId(userId);
    sysSigninManager.setFacilityCd(facilityCd);

    // 実行
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertNotNull(result);
    assertThat(result.size(), is(1));
    assertThat(result.get(0).getTerminalUniqueString(), is("term2"));
    assertThat(result.get(0).getFacilityCd(), is("009999"));
    assertThat(result.get(0).getUserId(), is(userId));
    assertThat(result.get(0).getRegDate(), is(Timestamp.valueOf("2020-05-27 15:10:00")));
    assertThat(result.get(0).getUpDate(), is(Timestamp.valueOf("2020-05-27 15:15:00")));
  }

  /**
   * {@link SysSigninManagerDao#deleteByParam(SysSigninManager)}の検証.
   *
   * <p>
   *   条件:対象データが存在する事.
   *   結果:対象データが削除される事.
   * </p>
   */
  @Test
  public void test_deleteByParam_正常_端末固有文字列に該当するデータが存在する場合() {
    // 事前準備
    final String terminalUniqueString = "term3";
    final String facilityCd = "009999";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);

    // 実行
    int selectCount = sysSigninManagerDao.deleteByParam(sysSigninManager);

    // データ取得
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);

    // 検証
    assertThat(selectCount, is(1));
    assertNotNull(result);
    assertThat(result.size(), is(0));
  }

  /**
   * {@link SysSigninManagerDao#deleteByParam(SysSigninManager)} の検証.
   *
   * <p>
   *   条件:対象データが存在しない事.
   *   結果:削除した結果が0件である事.
   * </p>
   */
  @Test
  public void test_deleteByParam_正常_端末固有文字列に該当するデータが存在しない場合() {
    // 事前準備
    final String terminalUniqueString = "del_test";
    final String facilityCd = "009999";
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setTerminalUniqueString(terminalUniqueString);
    sysSigninManager.setFacilityCd(facilityCd);

    // 実行
    int result = sysSigninManagerDao.deleteByParam(sysSigninManager);

    // 検証
    assertThat(result, is(0));
  }

  /**
   * {@link SysSigninManagerDao#deleteByParam(SysSigninManager)}の検証
   *
   * <p>
   *   条件:対象のデータが存在する事
   *   結果:対象データが削除される事.
   * </p>
   */
  @Test
  @Transactional(CoreConstant.TransactionManagerName.AUTH)
  @Sql(value = "classpath:dao.script/SysSigninManagerDaoTest.deleteByUserId.before.sql",
       config = @SqlConfig(dataSource = CoreConstant.DataSourceName.AUTH, transactionManager = CoreConstant.TransactionManagerName.AUTH))
  public void test_deleteByParam_正常_利用者IDに該当するデータが存在する場合() {
    // 事前準備
    Long userId = 1000L;
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setUserId(userId);

    // テスト前にデータが存在する事のチェック
    List<SysSigninManager> before = sysSigninManagerDao.selectByParam(sysSigninManager);
    assertThat(before.size(), is(3));

    // 実行
    int deleteCount = sysSigninManagerDao.deleteByParam(sysSigninManager);
    assertThat(deleteCount, is(3));

    // テスト後にデータが存在する事のチェック
    List<SysSigninManager> after = sysSigninManagerDao.selectByParam(sysSigninManager);
    assertThat(after.size(), is(0));
  }

  /**
   * {@link SysSigninManagerDao#deleteByParam(SysSigninManager)}の検証
   *
   * <p>
   *   条件:対象のデータが存在しない事
   *   結果:データが削除されない事.
   * </p>
   */
  @Test
  public void test_deleteByParam_正常_利用者IDに該当するデータが存在しない場合() {
    // 事前準備
    Long userId = 1001L;
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setUserId(userId);

    // テスト前にデータが存在する事のチェック
    List<SysSigninManager> before = sysSigninManagerDao.selectByParam(sysSigninManager);
    assertThat(before.size(), is(0));

    // 実行
    int deleteCount = sysSigninManagerDao.deleteByParam(sysSigninManager);
    assertThat(deleteCount, is(0));
  }
}
