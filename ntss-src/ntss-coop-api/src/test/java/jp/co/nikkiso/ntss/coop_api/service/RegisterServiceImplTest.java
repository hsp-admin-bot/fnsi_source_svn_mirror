package jp.co.nikkiso.ntss.coop_api.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.commons.beanutils.BeanUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql(value = "classpath:resource.script/RegisterServiceImplTest/setUpMasters.db5.sql", config = @SqlConfig(dataSource = DataSourceName.DEFAULT, transactionManager = TransactionManagerName.DEFAULT))
@Sql(value = "classpath:resource.script/RegisterServiceImplTest/setUpJournal.db5.sql", config = @SqlConfig(dataSource = DataSourceName.DEFAULT, transactionManager = TransactionManagerName.DEFAULT))
@Sql(value = "classpath:resource.script/RegisterServiceImplTest/RegisterServiceImplTest.db4.before.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
@Sql(value = "classpath:resource.script/RegisterServiceImplTest/RegisterServiceImplTest.db5.before.sql", config = @SqlConfig(dataSource = DataSourceName.DEFAULT, transactionManager = TransactionManagerName.DEFAULT))
@Sql(value = "classpath:resource.script/RegisterServiceImplTest/RegisterServiceImplTest.db6.before.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
@Sql("classpath:resource.script/RegisterServiceImplTest/loopTestMaster.sql")
@Sql("classpath:resource.script/RegisterServiceImplTest/loopTestJournal.sql")
public class RegisterServiceImplTest extends BaseServiceTest {

  @MockitoSpyBean
  private RegisterServiceImpl registerServiceImpl;

  @MockitoSpyBean
  private PatMainDao patMainDao;

  @MockitoSpyBean
  private PatPersonalMainDao patPersonalMainDao;

  @Test
  public void 正常系_登録_db5_患者基本情報pat_mainが登録できる() throws IOException {

    insert_db5(1001L);

    PatMain result = patMainDao.selectById(1001L);
    PatMain expected = createExpectationPatMain(1001L);

    // 登録日、更新日が設定されていることをチェック
    assertThat(result.getReg_date()).isNotEmpty();
    assertThat(result.getUp_date()).isNotEmpty();
    // insert時にTimeStampが設定されるので値はチェックしない
    expected.setReg_date(result.getReg_date());
    expected.setUp_date(result.getUp_date());

    assertThat(result).isEqualToComparingFieldByField(expected);

  }

  // @Test
  public void 正常系_登録_db6_患者基本情報pat_personal_mainが登録できる() {

    insert_db6(1001L);

    PatPersonalMain result = patPersonalMainDao.selectById(1001L);
    PatPersonalMain expected = createExpectationPatPersonalMain(1001L);
    assertThat(result).isEqualToComparingFieldByField(expected);
  }

  // @Test
  public void 正常系_登録_db5_db6_複合_2つのDBに登録できる() throws IOException {

    insert_db5(1002L);
    insert_db6(1002L);

    PatMain resultPatMain = patMainDao.selectById(1002L);
    PatMain expectedPatMain = createExpectationPatMain(1002L);
    assertThat(resultPatMain).isEqualToComparingFieldByField(expectedPatMain);

    PatPersonalMain resultPatPersonalMain = patPersonalMainDao.selectById(1002L);
    PatPersonalMain expectedPatPersonalMain = createExpectationPatPersonalMain(1002L);
    assertThat(resultPatPersonalMain).isEqualToComparingFieldByField(expectedPatPersonalMain);
  }

  // @Test(expected = RuntimeException.class)
  public void 登録_複合_db6_ロールバック_1() {

    boolean flag = true;

    insert_db5(1003L);
    insert_db6(1003L);

    if (flag) {
      throw new RuntimeException("ロールバック");
    }

    // 例外は発生するが、insert_db5とinsert_db6は正常に終了している。
    // そのため、それぞれのテーブルで1003Lのレコードが作成される。
  }

  //  @Test(expected = RuntimeException.class)
  public void 登録_複合_db6_ロールバック_2() {

    boolean flag = true;

    insert_db5(1004L);

    if (flag) {
      throw new RuntimeException("ロールバック");
    }

    insert_db6(1004L);

    // pat_mainのみ1004Lのレコードが作成される。
    // TODO このメソッドは複数DBのロールバック試験として正しくない。
    // 後で修正ないし削除する。
  }

  /**
   * pat_mainのテストレコードを登録する。
   *
   * @param patId 患者ID
   */
  private void insert_db5(Long patId) {

    Map<String, Object> args = createPatMainMap(patId);
//    registerServiceImpl.insert("pat_main", args);
  }

  /**
   * pat_personal_mainのテストレコードを登録する。
   *
   * @param patId 患者ID
   */
  private void insert_db6(Long patId) {

    Map<String, Object> args = createPatPersonalMainMap(patId);
//    registerServiceImpl.insertPatPersonalMain(args);
  }

  /**
   * pat_mainの期待結果を作成する。
   *
   * @param patId 患者ID
   * @return 期待結果（PatMainエンティティ）
   * @throws IOException
   */
  private PatMain createExpectationPatMain(Long patId) throws IOException {

    try {
      PatMain pm = new PatMain();
      Map<String, Object> m = createPatMainExpected(patId);
      BeanUtils.populate(pm, m);
      return pm;

    } catch (IllegalAccessException | InvocationTargetException e) {
      throw new NtssException("createExpectationPatMainでエラーが発生しました。", e);
    }

  }

  /**
   * pat_personal_mainの期待結果を作成する。
   * @param patId 患者ID
   * @return 期待結果（PatPersonalMainエンティティ）
   */
  private PatPersonalMain createExpectationPatPersonalMain(Long patId) {

    try {
      PatPersonalMain ppm = new PatPersonalMain();
      Map<String, Object> m = createPatPersonalMainMap(patId);
      BeanUtils.populate(ppm, m);
      return ppm;
    } catch (IllegalAccessException | InvocationTargetException e) {
      throw new NtssException("createExpectationPatPersonalMainでエラーが発生しました。", e);
    }
  }

  /**
   * pat_mainのテストレコード（マップ）を作成する。
   *
   * @param patId 患者ID
   * @return テストレコード（マップ）
   */
  private Map<String, Object> createPatMainMap(Long patId) {

    Map<String, Object> m = new TreeMap<>();
    m.put("pat_id", patId);
    m.put("facility_cd", "TK2019");
    m.put("is_same", "P");
    m.put("is_implant", "Q");
    m.put("is_infect", "R");
    m.put("is_diabetes", "S");
    m.put("is_blood_suger_exam", "T");
    m.put("is_del", "0");

    Map<String, Object> tabooAllergyInfo = new TreeMap<>();
    tabooAllergyInfo.put("ctl_no", 101);
    tabooAllergyInfo.put("disp_order", 3);
    tabooAllergyInfo.put("content", "内容サンプル");
    tabooAllergyInfo.put("memo", "備考サンプル");
    tabooAllergyInfo.put("category_class", 0);
    tabooAllergyInfo.put("taboo_allergy_class", "1");
    tabooAllergyInfo.put("taboo_allergy_cd", "1113");
    List<Map<String, Object>> l1 = new ArrayList<>();
    l1.add(tabooAllergyInfo);
    m.put("taboo_allergy_info", l1);

    Map<String, Object> chargeStaffInfo = new TreeMap<>();
    chargeStaffInfo.put("ctl_no", 10001);
    chargeStaffInfo.put("disp_order", 21);
    chargeStaffInfo.put("staff_cd", "nkknkk2");
    chargeStaffInfo.put("is_main", "1");
    chargeStaffInfo.put("is_charge", "0");
    chargeStaffInfo.put("is_puncture", "0");
    List<Map<String, Object>> l2 = new ArrayList<>();
    l2.add(chargeStaffInfo);
    m.put("charge_staff_info", l2);

    Map<String, Object> infectInfo = new TreeMap<>();
    infectInfo.put("ctl_no", 1);
    infectInfo.put("infection_cd", "1112");
    infectInfo.put("infect", 0);
    infectInfo.put("exam_date", "2019-12-18 17:00:00");
    infectInfo.put("up_date", "2019-12-18 17:10:00");
    List<Map<String, Object>> l3 = new ArrayList<>();
    l3.add(infectInfo);
    m.put("infect_info", l3);

    Map<String, Object> implantInfo = new TreeMap<>();
    implantInfo.put("ctl_no", 2);
    implantInfo.put("disp_order", 2);
    implantInfo.put("implant_cd", "1111");
    implantInfo.put("start_date", "2001-01-01 00:00:00");
    List<Map<String, Object>> l4 = new ArrayList<>();
    l4.add(implantInfo);
    m.put("implant_info", l4);

    return m;
  }

  private Map<String, Object> createPatMainExpected(Long patId) throws IOException {

    Map<String, Object> m = createPatMainMap(patId);

    Map<String, Object> chargeStaffInfo = new LinkedHashMap<>();
    chargeStaffInfo.put("ctl_no", 1);
    chargeStaffInfo.put("is_main", "1");
    chargeStaffInfo.put("staff_cd", 8004);
    chargeStaffInfo.put("is_charge", "0");
    chargeStaffInfo.put("disp_order", 1);
    chargeStaffInfo.put("is_puncture", "0");

    List<Map<String, Object>> l = new ArrayList<>();
    l.add(chargeStaffInfo);
    m.put("charge_staff_info", toString(l));

    Map<String, Object> tabooAllergyInfo = new LinkedHashMap<>();
    tabooAllergyInfo.put("memo", "備考サンプル");
    tabooAllergyInfo.put("ctl_no", 101);
    tabooAllergyInfo.put("content", "内容サンプル");
    tabooAllergyInfo.put("disp_order", 3);
    tabooAllergyInfo.put("category_class", 0);
    tabooAllergyInfo.put("taboo_allergy_cd", 1003);
    tabooAllergyInfo.put("taboo_allergy_class", "1");

    List<Map<String, Object>> l4 = new ArrayList<>();
    l4.add(tabooAllergyInfo);
    m.put("taboo_allergy_info", toString(l4));

    Map<String, Object> infectInfo = new LinkedHashMap<>();
    infectInfo.put("ctl_no", 1);
    infectInfo.put("infect", 0);
    infectInfo.put("up_date", "2019-12-18 17:10:00");
    infectInfo.put("exam_date", "2019-12-18 17:00:00");
    infectInfo.put("infection_cd", 1002);

    List<Map<String, Object>> l2 = new ArrayList<>();
    l2.add(infectInfo);
    m.put("infect_info", toString(l2));

    Map<String, Object> implantInfo = new LinkedHashMap<>();
    implantInfo.put("ctl_no", 2);
    implantInfo.put("disp_order", 2);
    implantInfo.put("implant_cd", 1001);
    implantInfo.put("start_date", "2001-01-01 00:00:00");

    List<Map<String, Object>> l3 = new ArrayList<>();
    l3.add(implantInfo);
    m.put("implant_info", toString(l3));

    Map<String, Map<String, Object>> tareInfo = createTareInfo();
    m.put("tare_info", toString(tareInfo));

    Map<String, Map<String, Object>> offWaterInfo = createOffWaterInfo();
    m.put("off_water_info", toString(offWaterInfo));

    Map<String, Object> deviceSetInfo = createDeviceSetInfo();
    m.put("device_set_info", toString(deviceSetInfo));

    m.put("sch_ext_status", toString(0));

    return m;
  }

  private String toString(Object m) throws IOException {
    return ObjectMapperUtil.write(m).replaceAll("(\":|,)", "$1 ");
  }

  private Map<String, Map<String, Object>> createTareInfo() {

    Map<String, Object> elem = createTareInfoElem();

    Map<String, Map<String, Object>> m = new TreeMap<>();
    for (int i = 1; i <= 7; ++i) {
      m.put(String.valueOf(i), elem);
    }

    return m;
  }

  private Map<String, Object> createTareInfoElem() {

    Map<String, Object> m = new TreeMap<>();

    m.put("name_1", "項目1名称");
    m.put("name_2", "項目2名称");
    m.put("name_3", "項目3名称");
    m.put("name_4", "項目4名称");
    m.put("name_5", "項目5名称");

    m.put("weight_1", "500");
    m.put("weight_2", "400");
    m.put("weight_3", "300");
    m.put("weight_4", "200");
    m.put("weight_5", "100");

    return m;
  }

  private Map<String, Map<String, Object>> createOffWaterInfo() {

    Map<String, Object> elem = createOffWaterInfoElem();

    Map<String, Map<String, Object>> m = new TreeMap<>();
    for (int i = 1; i <= 7; ++i) {
      m.put(String.valueOf(i), elem);
    }

    return m;
  }

  private Map<String, Object> createOffWaterInfoElem() {

    Map<String, Object> m = new TreeMap<>();

    m.put("name_1", "項目1名称");
    m.put("name_2", "項目2名称");
    m.put("name_3", "項目3名称");
    m.put("name_4", "項目4名称");
    m.put("name_5", "項目5名称");

    m.put("weight_1", "90000");
    m.put("weight_2", "80000");
    m.put("weight_3", "70000");
    m.put("weight_4", "60000");
    m.put("weight_5", "50000");

    return m;
  }

  private Map<String, Object> createDeviceSetInfo() {

    Map<String, Object> m = new TreeMap<>();
    m.put("device", "setting");

    return m;
  }

  /**
   * pat_personal_mainのテストレコード（マップ）を作成する。
   *
   * @param patId テストレコード（マップ）
   * @return テストレコード（マップ）
   */
  private Map<String, Object> createPatPersonalMainMap(Long patId) {

    Map<String, Object> m = new TreeMap<>();
    m.put("pat_id", patId);
    m.put("hosp_pat_id", "1112");
    m.put("facility_cd", "TK2019");
    m.put("pat_last_name", "aaa");
    m.put("pat_first_name", "zzz");
    m.put("pat_last_name_alpha", "aaa");
    m.put("pat_first_name_alpha", "zzz");
    m.put("pat_birthday", "19900101");
    m.put("pat_sex", 1);
    m.put("nationality", "J");
    m.put("is_del", "0");

    m.put("die_cd", "1002");
    m.put("severity_cd", 1015);
    m.put("transport_cd", 1009);
    m.put("primary_disease_cd", 1002);

    return m;
  }

}
