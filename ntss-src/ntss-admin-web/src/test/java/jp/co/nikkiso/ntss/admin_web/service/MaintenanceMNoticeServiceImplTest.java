package jp.co.nikkiso.ntss.admin_web.service;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.PERSONAL;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.core.IsNull.notNullValue;
import static org.junit.Assert.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstMNoticeDao;
import jp.co.nikkiso.ntss.core.entity.MstMNotice;

import java.util.Arrays;
import java.util.List;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class MaintenanceMNoticeServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private MaintenanceMNoticeService target;

  /**
   * 緊急発報マスタのDaoインターフェイス.
   */
  @Autowired
  private MstMNoticeDao mstMNoticeDao;

  /**
   * createMstMNotice()の検証. 条件：一般ユーザ1グループのみ対象 結果：緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case1.sql")
  public void test_createMstMNotice_case1_一般ユーザ1グループのみ() {

    String facilityCd = "009999";
    List<String> targetFacilities = Arrays.asList(facilityCd) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    assertThat(insertEntity.getRegDate(),notNullValue());
    assertThat(insertEntity.getUpDate(),notNullValue());

  }

  /**
   * createMstMNotice()の検証. 条件：一般ユーザ2グループ混在 結果：緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case2.sql")
  public void test_createMstMNotice_case2_一般ユーザ2グループ混在() {

    String facilityCd = "009999";
    List<String> targetFacilities = Arrays.asList(facilityCd) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "AC09");
    assertThat(insertEntity.getMachineRecordMessage(), is("給水流量下限報知"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));
  }

  /**
   * createMstMNotice()の検証. 条件：_一般ユーザ2グループとNKKユーザ1グループのみ対象 （一般ユーザで起動）
   * 結果：緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case3.sql")
  public void test_createMstMNotice_case3_1_一般ユーザ2グループとNKKユーザ1グループ_一般起動() {

    String facilityCd = "009999";
    List<String> targetFacilities = Arrays.asList(facilityCd) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    facilityCd = "009999";

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "AC09");
    assertThat(insertEntity.getMachineRecordMessage(), is("給水流量下限報知"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "A500");
    assertThat(insertEntity.getMachineRecordMessage(), is("バイパス警報"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));
  }

  /**
   * createMstMNotice()の検証. 条件：_一般ユーザ2グループとNKKユーザ1グループのみ対象 （NKKで起動）
   * 結果：緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case3.sql")
  public void test_createMstMNotice_case3_2_一般ユーザ2グループとNKKユーザ1グループ_NKK起動() {

    String facilityCd = "009999";
    List<String> targetFacilities = Arrays.asList(facilityCd) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    facilityCd = "009999";

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "AC09");
    assertThat(insertEntity.getMachineRecordMessage(), is("給水流量下限報知"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "A500");
    assertThat(insertEntity.getMachineRecordMessage(), is("バイパス警報"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));
  }

  /**
   * createMstMNotice()の検証. 条件：_一般ユーザ2グループとNKKユーザ2グループ対象 （一般ユーザで起動）
   * 結果：緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case4.sql")
  public void test_createMstMNotice_case4_1_一般ユーザ2グループとNKKユーザ2グループ_一般起動() {

    String facilityCd = "009999";
    List<String> targetFacilities = Arrays.asList(facilityCd) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    facilityCd = "009999";

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "AC09");
    assertThat(insertEntity.getMachineRecordMessage(), is("給水流量下限報知"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "A500");
    assertThat(insertEntity.getMachineRecordMessage(), is("バイパス警報"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "F464");
    assertThat(insertEntity.getMachineRecordMessage(), is("補液速度変更"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));
  }

  /**
   * createMstMNotice()の検証. 条件：_一般ユーザ2グループとNKKユーザ2グループ対象 （NKKユーザで起動）
   * 結果：緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case4.sql")
  public void test_createMstMNotice_case4_1_一般ユーザ2グループとNKKユーザ2グループ_NKK起動() {

    String facilityCd = "009999";
    List<String> targetFacilities = Arrays.asList(facilityCd) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    facilityCd = "009999";

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "AC09");
    assertThat(insertEntity.getMachineRecordMessage(), is("給水流量下限報知"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "A500");
    assertThat(insertEntity.getMachineRecordMessage(), is("バイパス警報"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "F464");
    assertThat(insertEntity.getMachineRecordMessage(), is("補液速度変更"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));
  }

  /**
   * createMstMNotice()の検証. 条件：_NKKユーザで複数施設を作成 （NKKユーザで起動） 結果：緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case5.sql")
  public void test_createMstMNotice_case5_NKKユーザで複数施設作成_NKK起動() {

    String facilityCd1 = "009999";
    String facilityCd2 = "009998";
    List<String> targetFacilities = Arrays.asList(facilityCd1, facilityCd2) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "AC09");
    assertThat(insertEntity.getMachineRecordMessage(), is("給水流量下限報知"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "A500");
    assertThat(insertEntity.getMachineRecordMessage(), is("バイパス警報"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd1, "F464");
    assertThat(insertEntity.getMachineRecordMessage(), is("補液速度変更"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    // 作成されたデータの確認
    insertEntity = mstMNoticeDao.selectByCd(facilityCd2, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd2, "FFFF");
    assertThat(insertEntity.getMachineRecordMessage(), is("緊急停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));
  }

  /**
   * createMstMNotice()の検証. 条件：_警報通知マスタの担当施設と送信先グループが未設定
   * 結果：設定済みの情報で緊急発報マスタが作成されること
   */
  @Test
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.before.sql")
  @Sql(value = "classpath:resource.service/MstMNoticeServiceImplTest.beforePersonal.sql", config = @SqlConfig(dataSource = PERSONAL, transactionManager = CoreConstant.TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.service/MstMNoticeServiceImplTest.case6.sql")
  public void test_createMstMNotice_case6_警報通知マスタの担当施設と送信先グループが未設定() {

    String facilityCd = "009999";
    List<String> targetFacilities = Arrays.asList(facilityCd) ;
    // 実行
    target.createMstMNotice(targetFacilities);

    facilityCd = "009999";

    // 作成されたデータの確認
    MstMNotice insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4505");
    assertThat(insertEntity.getMachineRecordMessage(), is("背圧弁ダイアフラム交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4829");
    assertThat(insertEntity.getMachineRecordMessage(), is("複式ベアリング交換時期"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4501");
    assertThat(insertEntity.getMachineRecordMessage(), is("血液ポンプ電源「切」"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "4923");
    assertThat(insertEntity.getMachineRecordMessage(), is("ＴＭＰゼロ補正完了"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "7842");
    assertThat(insertEntity.getMachineRecordMessage(), is("薬液消毒キャンセル：装置停止"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "AC09");
    assertThat(insertEntity.getMachineRecordMessage(), is("給水流量下限報知"));
    assertThat(insertEntity.getEmailAddress(), is(""));
    assertThat(insertEntity.getEmailName(), is(""));

    insertEntity = mstMNoticeDao.selectByCd(facilityCd, "A500");
    assertThat(insertEntity, nullValue());
  }

}
