package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.beanutils.BeanUtils;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.JavaType;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class JournalConvertReceiveResourceXMLTest extends AbstractResourceTest {

  @MockitoSpyBean
  private SysCoopJournalDao sysCoopJournalDao;

  @MockitoSpyBean
  private PatPersonalMainDao patPersonalMainDao;

  @MockitoSpyBean
  private PatMainDao patMainDao;

  @MockitoSpyBean
  private MstDiseaseDao mstDiseaseDao;

  @MockitoSpyBean
  private MstInfectionDao mstInfectionDao;

  @MockitoSpyBean
  private MstTabooAllergyDao mstTabooAllergyDao;

  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD00/clean_db5_D00.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD00/clean_db6_D00.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD00/masters_staff_D00.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD00/masters_others_D00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD00/masters_layout_D00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD00/journal_D00.sql")
  @Test
  public void 患者属性連携_1_繰返しなし_分岐なし() {
    final String FACILITY_CD = "F_hD00";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // pat_personal_main登録内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      Map<String, Object> ppmResult = new TreeMap<>();
      ppmResult.putAll(BeanUtils.describe(ppm));

      Map<String, Object> ppmExpected = createExpected_D00_pat_personal_main(FACILITY_CD);

      assertTrue(containsAll(ppmResult, ppmExpected));

      // pat_main登録内容検証
      PatMain pm = patMainDao.selectById(ppm.getPat_id());
      assertThat(pm, notNullValue());

      Map<String, Object> pmResult = new TreeMap<>();
      pmResult.putAll(BeanUtils.describe(pm));

      Map<String, Object> pmExpected = createExpected_D00_pat_main(FACILITY_CD);

      assertTrue(containsAll(pmResult, pmExpected));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  private Map<String, Object> createExpected_D00_pat_personal_main(String facilityCd) {
    Map<String, Object> m = new TreeMap<>();

    Integer dieCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, "1");
    m.put("die_cd", String.valueOf(dieCd));

    m.put("hosp_pat_id", "99990507");
    m.put("pat_birthday", "19900801");
    m.put("pat_blood_type_abo", "4");
    m.put("pat_blood_type_rh", "1");

    m.put("pat_first_name", "テスト");
    m.put("pat_last_name", "SSI");

    m.put("pat_first_name_kana", "テスト");
    m.put("pat_last_name_kana", "エスエスアイ");

    m.put("pat_sex", "0");

    Integer primaryDiseaseCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, "1991");
    m.put("primary_disease_cd", String.valueOf(primaryDiseaseCd));

    Map<String, Object> contactInfoMap = new TreeMap<>();
    m.put("pat_contact_info", contactInfoMap);
    contactInfoMap.put("address", "東京都千代田区霞が関");
    contactInfoMap.put("tel1", "999-9999");
    contactInfoMap.put("zip_cd", "001-0002");

    return m;
  }

  private Map<String, Object> createExpected_D00_pat_main(String facilityCd) {
    Map<String, Object> m = new TreeMap<>();

    Map<String, Object> chargeStaffInfoMap = new TreeMap<>();
    List<Map<String, Object>> chargeStaffInfoMapList = Collections.singletonList(chargeStaffInfoMap);
    m.put("charge_staff_info", chargeStaffInfoMapList);
    // staff_cdのみマスタルックアップ。他は受信内容を登録。
    chargeStaffInfoMap.put("ctl_no", 1);
    chargeStaffInfoMap.put("disp_order", 1);
    chargeStaffInfoMap.put("staff_cd", 91900);
    chargeStaffInfoMap.put("dial_doctor_cd", "12341234");
    chargeStaffInfoMap.put("dial_nurse_cd", "53106812");

    Map<String, Object> memoInfoMap = new TreeMap<>();
    List<Map<String, Object>> memoInfoMapList = Collections.singletonList(memoInfoMap);
    m.put("pat_memo_info", memoInfoMapList);
    memoInfoMap.put("content", "患者情報コメント");

    Map<String, Object> infectInfoMap = new TreeMap<>();
    List<Map<String, Object>> infectInfoMapList = Collections.singletonList(infectInfoMap);
    m.put("infect_info", infectInfoMapList);
    Integer infectionCd = mstInfectionDao.selectByInHospitalCd1(facilityCd, "C2019");
    infectInfoMap.put("infection_cd", infectionCd);
    infectInfoMap.put("exam_date", "20200410");
    infectInfoMap.put("infect", "1");

    Map<String, Object> tabooAllergyInfoMap = new TreeMap<>();
    List<Map<String, Object>> tabooAllergyInfoMapList = Collections.singletonList(tabooAllergyInfoMap);
    m.put("taboo_allergy_info", tabooAllergyInfoMapList);

    Integer tabooAllergyCd = mstTabooAllergyDao.selectByInHospitalCd1(facilityCd, "872");
    tabooAllergyInfoMap.put("taboo_allergy_cd", tabooAllergyCd);
    tabooAllergyInfoMap.put("taboo_allergy_class", "1");
    tabooAllergyInfoMap.put("comment", "アレルギー情報コメント");
    tabooAllergyInfoMap.put("drug_allergy_cd", "10021");
    tabooAllergyInfoMap.put("drug_allergy_comment", "薬剤アレルギー情報コメント");
    tabooAllergyInfoMap.put("drug_allergy_status", "3");

    return m;
  }

  private boolean containsAll(Map<String, Object> result, Map<String, Object> expected) throws IOException {

    Set<Map.Entry<String, Object>> entrySet = expected.entrySet();
    for (Map.Entry<String, Object> entry : entrySet) {
      String key = entry.getKey();
      Object expectedValue = entry.getValue();

      if (!expected.containsKey(key)) {
        return false;
      }

      Object resultValue = result.get(key);

      resultValue = conform(expectedValue, resultValue);

      if (!resultValue.equals(expectedValue)) {
        return false;
      }
    }

    return true;
  }

  private Object conform(Object expected, Object result) throws IOException {
    if (!(result instanceof String)) {
      return result;
    }

    String s = (String) result;

    if (expected instanceof Map) {
      JavaType jt = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> m = ObjectMapperUtil.read(s, jt);
      Map<String, Object> r = new TreeMap<>();
      r.putAll(m);
      return r;
    }

    if (expected instanceof List) {
      List<Map<String, Object>> dst = new ArrayList<>();
      List<Map<String, Object>> src = ObjectMapperUtil.readListOfMap(s);
      for (Map<String, Object> a : src) {
        Map<String, Object> b = new TreeMap<>();
        b.putAll(a);
        dst.add(b);
      }
      return dst;
    }

    return result;
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD01/clean_db5_D01.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD01/clean_db6_D01.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD01/masters_staff_D01.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD01/masters_others_D01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD01/masters_layout_D01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD01/journal_D01.sql")
  @Test
  public void 患者属性連携_2_繰返しあり_分岐なし() {
    final String FACILITY_CD = "F_hD01";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // pat_personal_main登録内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      Map<String, Object> ppmResult = new TreeMap<>();
      ppmResult.putAll(BeanUtils.describe(ppm));

      Map<String, Object> ppmExpected = createExpected_D01_pat_personal_main(FACILITY_CD);

      assertTrue(containsAll(ppmResult, ppmExpected));

      // pat_main登録内容検証
      PatMain pm = patMainDao.selectById(ppm.getPat_id());
      assertThat(pm, notNullValue());

      Map<String, Object> pmResult = new TreeMap<>();
      pmResult.putAll(BeanUtils.describe(pm));

      Map<String, Object> pmExpected = createExpected_D01_pat_main(FACILITY_CD);

      assertTrue(containsAll(pmResult, pmExpected));

    } catch (Exception e) {
      fail("", e);
    }
  }

  private Map<String, Object> createExpected_D01_pat_personal_main(String facilityCd) {
    Map<String, Object> m = new TreeMap<>();

    Integer dieCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, "1");
    m.put("die_cd", String.valueOf(dieCd));

    m.put("hosp_pat_id", "99990507");
    m.put("pat_birthday", "19900801");
    m.put("pat_blood_type_abo", "4");
    m.put("pat_blood_type_rh", "1");

    m.put("pat_first_name", "テスト");
    m.put("pat_last_name", "SSI");

    m.put("pat_first_name_kana", "テスト");
    m.put("pat_last_name_kana", "エスエスアイ");

    m.put("pat_sex", "0");

    Integer primaryDiseaseCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, "1991");
    m.put("primary_disease_cd", String.valueOf(primaryDiseaseCd));

    Map<String, Object> contactInfoMap = new TreeMap<>();
    m.put("pat_contact_info", contactInfoMap);
    contactInfoMap.put("address", "東京都千代田区霞が関");
    contactInfoMap.put("tel1", "999-9999");
    contactInfoMap.put("zip_cd", "001-0002");

    return m;
  }

  private Map<String, Object> createExpected_D01_pat_main(String facilityCd) {
    Map<String, Object> m = new TreeMap<>();

    Map<String, Object> chargeStaffInfoMap = new TreeMap<>();
    List<Map<String, Object>> chargeStaffInfoMapList = Collections.singletonList(chargeStaffInfoMap);
    m.put("charge_staff_info", chargeStaffInfoMapList);
    // staff_cdのみマスタルックアップ。他は受信内容を登録。
    chargeStaffInfoMap.put("ctl_no", 1);
    chargeStaffInfoMap.put("disp_order", 1);
    chargeStaffInfoMap.put("staff_cd", 91910);
    chargeStaffInfoMap.put("dial_doctor_cd", "12341234");
    chargeStaffInfoMap.put("dial_nurse_cd", "53106812");

    Map<String, Object> memoInfoMap = new TreeMap<>();
    List<Map<String, Object>> memoInfoMapList = Collections.singletonList(memoInfoMap);
    m.put("pat_memo_info", memoInfoMapList);
    memoInfoMap.put("content", "患者情報コメント");

    List<Map<String, Object>> infectInfoMapList = new ArrayList<>();
    m.put("infect_info", infectInfoMapList);

    Map<String, Object> infectInfoMap1 = new TreeMap<>();
    Integer infectionCd1 = mstInfectionDao.selectByInHospitalCd1(facilityCd, "C2019");
    infectInfoMapList.add(infectInfoMap1);
    infectInfoMap1.put("infection_cd", infectionCd1);
    infectInfoMap1.put("exam_date", "20200410");
    infectInfoMap1.put("infect", "1");

    Map<String, Object> infectInfoMap2 = new TreeMap<>();
    infectInfoMapList.add(infectInfoMap2);
    Integer infectionCd2 = mstInfectionDao.selectByInHospitalCd1(facilityCd, "1001");
    infectInfoMap2.put("infection_cd", infectionCd2);
    infectInfoMap2.put("exam_date", "20200510");
    infectInfoMap2.put("infect", "0");

    Map<String, Object> infectInfoMap3 = new TreeMap<>();
    infectInfoMapList.add(infectInfoMap3);
    Integer infectionCd3 = mstInfectionDao.selectByInHospitalCd1(facilityCd, "9912");
    infectInfoMap3.put("infection_cd", infectionCd3);
    infectInfoMap3.put("exam_date", "20200510");
    infectInfoMap3.put("infect", "0");

    List<Map<String, Object>> tabooAllergyInfoMapList = new ArrayList<>();
    m.put("taboo_allergy_info", tabooAllergyInfoMapList);

    Map<String, Object> tabooAllergyInfoMap1 = new TreeMap<>();
    tabooAllergyInfoMapList.add(tabooAllergyInfoMap1);
    Integer tabooAllergyCd1 = mstTabooAllergyDao.selectByInHospitalCd1(facilityCd, "872");
    tabooAllergyInfoMap1.put("taboo_allergy_cd", tabooAllergyCd1);
    tabooAllergyInfoMap1.put("taboo_allergy_class", "1");
    tabooAllergyInfoMap1.put("comment", "鶏卵アレルギー");

    Map<String, Object> tabooAllergyInfoMap2 = new TreeMap<>();
    tabooAllergyInfoMapList.add(tabooAllergyInfoMap2);
    Integer tabooAllergyCd2 = mstTabooAllergyDao.selectByInHospitalCd1(facilityCd, "882");
    tabooAllergyInfoMap2.put("taboo_allergy_cd", tabooAllergyCd2);
    tabooAllergyInfoMap2.put("taboo_allergy_class", "1");
    tabooAllergyInfoMap2.put("comment", "小麦アレルギー");

    return m;
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD10/clean_db5_D10.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD10/clean_db6_D10.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD10/masters_staff_D10.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD10/masters_others_D10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD10/masters_layout_D10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceXMLTest/sD10/journal_D10.sql")
  @Test
  public void 患者属性連携_3_繰返しなし_分岐なし_JSONルックアップ() {
    final String FACILITY_CD = "F_hD10";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // pat_personal_main登録内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      Map<String, Object> ppmResult = new TreeMap<>();
      ppmResult.putAll(BeanUtils.describe(ppm));

      Map<String, Object> ppmExpected = createExpected_D10_pat_personal_main(FACILITY_CD);

      assertTrue(containsAll(ppmResult, ppmExpected));

      // pat_main登録内容検証
      PatMain pm = patMainDao.selectById(ppm.getPat_id());
      assertThat(pm, notNullValue());

      Map<String, Object> pmResult = new TreeMap<>();
      pmResult.putAll(BeanUtils.describe(pm));

      Map<String, Object> pmExpected = createExpected_D10_pat_main(FACILITY_CD);

      assertTrue(containsAll(pmResult, pmExpected));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  private Map<String, Object> createExpected_D10_pat_personal_main(String facilityCd) {
    Map<String, Object> m = new TreeMap<>();

    Integer dieCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, "1");
    m.put("die_cd", String.valueOf(dieCd));

    m.put("hosp_pat_id", "99990507");
    m.put("pat_birthday", "19900801");

    // 電文中は"3"（O型）が指定されているが、JSONルックアップにより4に置換する。
    // （NTSSでは0=不明である）
    m.put("pat_blood_type_abo", "4");

    // 同様に"1"（Rh-）を2に置換する。
    m.put("pat_blood_type_rh", "2");

    m.put("pat_first_name", "テスト");
    m.put("pat_last_name", "SSI");

    m.put("pat_first_name_kana", "テスト");
    m.put("pat_last_name_kana", "エスエスアイ");

    // 電文中は"M"が指定されているが、JSONルックアップにより1に置換する。
    m.put("pat_sex", "1");

    Integer primaryDiseaseCd = mstDiseaseDao.selectByInHospitalCd1(facilityCd, "1991");
    m.put("primary_disease_cd", String.valueOf(primaryDiseaseCd));

    Map<String, Object> contactInfoMap = new TreeMap<>();
    m.put("pat_contact_info", contactInfoMap);
    contactInfoMap.put("address", "東京都千代田区霞が関");

    // 電話番号はconst指定でXXX-XXXXに置換している。
    contactInfoMap.put("tel1", "XXX-XXX-XXXX");

    contactInfoMap.put("zip_cd", "001-0002");

    return m;
  }

  private Map<String, Object> createExpected_D10_pat_main(String facilityCd) {
    Map<String, Object> m = new TreeMap<>();

    Map<String, Object> chargeStaffInfoMap = new TreeMap<>();
    List<Map<String, Object>> chargeStaffInfoMapList = Collections.singletonList(chargeStaffInfoMap);
    m.put("charge_staff_info", chargeStaffInfoMapList);
    // staff_cdのみマスタルックアップ。他は受信内容を登録。
    chargeStaffInfoMap.put("ctl_no", 1);
    chargeStaffInfoMap.put("disp_order", 1);
    chargeStaffInfoMap.put("staff_cd", 92900);
    chargeStaffInfoMap.put("dial_doctor_cd", "12341234");
    chargeStaffInfoMap.put("dial_nurse_cd", "53106812");

    Map<String, Object> memoInfoMap = new TreeMap<>();
    List<Map<String, Object>> memoInfoMapList = Collections.singletonList(memoInfoMap);
    m.put("pat_memo_info", memoInfoMapList);
    memoInfoMap.put("content", "患者情報コメント");

    Map<String, Object> infectInfoMap = new TreeMap<>();
    List<Map<String, Object>> infectInfoMapList = Collections.singletonList(infectInfoMap);
    m.put("infect_info", infectInfoMapList);
    Integer infectionCd = mstInfectionDao.selectByInHospitalCd1(facilityCd, "C2019");
    infectInfoMap.put("infection_cd", infectionCd);
    infectInfoMap.put("exam_date", "20200410");
    infectInfoMap.put("infect", "1");

    Map<String, Object> tabooAllergyInfoMap = new TreeMap<>();
    List<Map<String, Object>> tabooAllergyInfoMapList = Collections.singletonList(tabooAllergyInfoMap);
    m.put("taboo_allergy_info", tabooAllergyInfoMapList);

    Integer tabooAllergyCd = mstTabooAllergyDao.selectByInHospitalCd1(facilityCd, "872");
    tabooAllergyInfoMap.put("taboo_allergy_cd", tabooAllergyCd);
    tabooAllergyInfoMap.put("taboo_allergy_class", "1");
    tabooAllergyInfoMap.put("comment", "アレルギー情報コメント");
    tabooAllergyInfoMap.put("drug_allergy_cd", "10021");
    tabooAllergyInfoMap.put("drug_allergy_comment", "薬剤アレルギー情報コメント");
    tabooAllergyInfoMap.put("drug_allergy_status", "3");

    return m;
  }

  @Test
  @Ignore("電文項目とカラムの対応が明確になるまで")
  public void 透析予約連携() {

  }

  @Test
  @Ignore("電文項目とカラムの対応が明確になるまで")
  public void カルテ記載連携() {

  }

  @Test
  @Ignore("電文項目とカラムの対応が明確になるまで")
  public void 透析実績連携() {

  }

  /**
   * リクエストを発行する。
   *
   * @param facilityCd 施設コード
   * @return
   * @throws Exception
   */
  private ResultActions requestConversionByFacilityCd(String facilityCd) throws Exception {
    JournalConvertReceiveRequest req = new JournalConvertReceiveRequest();
    req.setFacilityCd(facilityCd);
    return mockMvc.perform(post("/journal/convert/receive")
        .content(ObjectMapperUtil.write(req)).contentType(MediaType.APPLICATION_JSON));
  }
}
