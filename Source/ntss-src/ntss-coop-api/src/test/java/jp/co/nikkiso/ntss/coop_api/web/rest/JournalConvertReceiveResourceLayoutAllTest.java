package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class JournalConvertReceiveResourceLayoutAllTest extends AbstractResourceTest {

  @MockitoSpyBean
  private SysCoopJournalDao sysCoopJournalDao;

  @MockitoSpyBean
  private PatPersonalMainDao patPersonalMainDao;

  @MockitoSpyBean
  private PatMainDao patMainDao;

  @MockitoSpyBean
  private PatUniqueDao patUniqueDao;

  @MockitoSpyBean
  private MstDiseaseDao mstDiseaseDao;

  @MockitoSpyBean
  private MstTabooAllergyDao mstTabooAllergyDao;

  @MockitoSpyBean
  private MstInfectionDao mstInfectionDao;

  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN00/clean_db5_N00.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN00/clean_db6_N00.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN00/masters_staff_N00.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN00/masters_others_N00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN00/masters_layout_N00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN00/masters_layout_detail_N00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN00/journal_N00.sql")
  @Test
  @Ignore
  public void レイアウト統合_1_layout() {
    final String FACILITY_CD = "F_hN00";

    try {
      // 正常応答検証
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容検証

      // pat_personal_main
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();

      // pat_unique
      PatUnique pu = patUniqueDao.selectById(patId);
      String medicalHstInfoStr = pu.getMedical_hst_info();

      // medical_hst_infoカラム
      // マスタ（mst_disease）ルックアップに成功した3件が登録される。
      List<Map<String, Object>> result = ObjectMapperUtil.readListOfMap(medicalHstInfoStr);

      List<Map<String, Object>> expected = new ArrayList<>();

      int ctl_no = 0;
      Map<String, Object> m1 = new HashMap<>();
      expected.add(m1);
      m1.put("ctl_no", ++ctl_no);
      m1.put("disp_order", ctl_no);
      Integer dcd1 = mstDiseaseDao.selectByInHospitalCd1(FACILITY_CD, "VB199999");
      m1.put("disease_cd", dcd1);

      Map<String, Object> m2 = new HashMap<>();
      expected.add(m2);
      m2.put("ctl_no", ++ctl_no);
      m2.put("disp_order", ctl_no);
      Integer dcd2 = mstDiseaseDao.selectByInHospitalCd1(FACILITY_CD, "VAB004");
      m2.put("disease_cd", dcd2);

      Map<String, Object> m3 = new HashMap<>();
      expected.add(m3);
      m3.put("ctl_no", ++ctl_no);
      m3.put("disp_order", ctl_no);
      Integer dcd3 = mstDiseaseDao.selectByInHospitalCd1(FACILITY_CD, "0001100011");
      m3.put("disease_cd", dcd3);

      assertThat(result, is(expected));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN10/clean_db5_N10.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN10/clean_db6_N10.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN10/masters_staff_N10.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN10/masters_others_N10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN10/masters_layout_N10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN10/masters_layout_detail_N10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN10/journal_N10.sql")
  @Test
  @Ignore
  public void レイアウト統合_2_ベンダ別アレルギー解析() {
    final String FACILITY_CD = "F_hN10";

    try {
      // 正常応答検証
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容検証

      // pat_personal_main
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(3));

      ppmList.stream().forEach(ppm -> {
        assertThat(ppm, notNullValue());
      });

      // pat_main（アレルギー情報）
      Long patId1 = ppmList.get(0).getPat_id();
      PatMain pm1 = patMainDao.selectById(patId1);
      assertThat(pm1, notNullValue());

      String tabooAllergyInfoStr1 = pm1.getTaboo_allergy_info();
      List<Map<String, Object>> result1 = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr1);
      Integer tabooAllergyCd1 = mstTabooAllergyDao.selectByInHospitalCd1(FACILITY_CD, "11111111");
      Map<String, Object> m1 = new TreeMap<>();
      List<Map<String, Object>> expected1 = Collections.singletonList(m1);
      m1.put("taboo_allergy_cd", tabooAllergyCd1);
      m1.put("taboo_allergy_class", "00");
      m1.put("taboo_allergy_aux_Fujitsu", "51");

      assertThat(result1, is(expected1));

      Long patId2 = ppmList.get(1).getPat_id();
      PatMain pm2 = patMainDao.selectById(patId2);
      assertThat(pm2, notNullValue());

      String tabooAllergyInfoStr2 = pm2.getTaboo_allergy_info();
      List<Map<String, Object>> result2 = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr2);
      Integer tabooAllergyCd2 = mstTabooAllergyDao.selectByInHospitalCd1(FACILITY_CD, "55555555");
      Map<String, Object> m2 = new TreeMap<>();
      List<Map<String, Object>> expected2 = Collections.singletonList(m2);
      m2.put("taboo_allergy_cd", tabooAllergyCd2);
      m2.put("taboo_allergy_class", "01");
      // taboo_allergy_cd, taboo_allergy_classはベンダ共通。
      // ベンダごとにtaboo_allergy_aux_*が異なる想定とした。
      m2.put("taboo_allergy_aux_NEC", "52");

      assertThat(result2, is(expected2));

      Long patId3 = ppmList.get(2).getPat_id();
      PatMain pm3 = patMainDao.selectById(patId3);
      assertThat(pm3, notNullValue());

      String tabooAllergyInfoStr3 = pm3.getTaboo_allergy_info();
      List<Map<String, Object>> result3 = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr3);
      Integer tabooAllergyCd3 = mstTabooAllergyDao.selectByInHospitalCd1(FACILITY_CD, "66666666");
      Map<String, Object> m3 = new TreeMap<>();
      List<Map<String, Object>> expected3 = Collections.singletonList(m3);
      m3.put("taboo_allergy_cd", tabooAllergyCd3);
      m3.put("taboo_allergy_class", "02");
      m3.put("taboo_allergy_aux_Panasonic", "53");

      assertThat(result3, is(expected3));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN11/clean_db5_N11.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN11/clean_db6_N11.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN11/masters_others_N11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN11/masters_layout_N11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN11/masters_layout_detail_N11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN11/journal_N11.sql")
  @Test
  @Rollback(false)
  public void レイアウト統合_3_アレルギー_感染症_すべて指定() {
    final String FACILITY_CD = "F_hN11";

    try {
      // 正常応答検証
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容検証

      // pat_personal_main
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      // pat_main
      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);

      assertThat(pm, notNullValue());

      // 禁忌・アレルギー情報
      String tabooAllergyInfoStr = pm.getTaboo_allergy_info();
      List<Map<String, Object>> resultTabooAllergyInfo = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr);
      assertThat(resultTabooAllergyInfo, notNullValue());
      assertThat(resultTabooAllergyInfo.size(), is(2));

      List<Map<String, Object>> expectedTabooAllergyInfo = new ArrayList<>();

      Map<String, Object> ta1 = new TreeMap<>();
      expectedTabooAllergyInfo.add(ta1);

      Integer tabooAllergyCd1 = mstTabooAllergyDao.selectByInHospitalCd1(FACILITY_CD, "LID");
      ta1.put("taboo_allergy_cd", tabooAllergyCd1);
      ta1.put("taboo_allergy_class", "2");
      ta1.put("category_class", "0");

      Map<String, Object> ta2 = new TreeMap<>();
      expectedTabooAllergyInfo.add(ta2);

      Integer tabooAllergyCd2 = mstTabooAllergyDao.selectByInHospitalCd1(FACILITY_CD, "IOD");
      ta2.put("taboo_allergy_cd", tabooAllergyCd2);
      ta2.put("taboo_allergy_class", "2");
      ta2.put("category_class", "1");

      assertThat(resultTabooAllergyInfo, is(expectedTabooAllergyInfo));

      // 感染症情報
      String infectInfoStr = pm.getInfect_info();
      List<Map<String, Object>> resultInfectInfo = ObjectMapperUtil.readListOfMap(infectInfoStr);
      assertThat(resultInfectInfo, notNullValue());
      assertThat(resultInfectInfo.size(), is(2));

      List<Map<String, Object>> expectedTInfectInfo = new ArrayList<>();

      Map<String, Object> in1 = new TreeMap<>();
      expectedTInfectInfo.add(in1);

      Integer infectCd1 = mstInfectionDao.selectByInHospitalCd1(FACILITY_CD, "311");
      in1.put("infect", "1");
      in1.put("infection_cd", infectCd1);

      Map<String, Object> in2 = new TreeMap<>();
      expectedTInfectInfo.add(in2);

      Integer infectCd2 = mstInfectionDao.selectByInHospitalCd1(FACILITY_CD, "312");
      in2.put("infect", "2");
      in2.put("infection_cd", infectCd2);

      assertThat(resultInfectInfo, is(expectedTInfectInfo));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN12/clean_db5_N12.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN12/clean_db6_N12.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN12/masters_others_N12.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN12/masters_layout_N12.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN12/masters_layout_detail_N12.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceLayoutAllTest/sN12/journal_N12.sql")
  @Test
  @Rollback(false)
  public void レイアウト統合_4_アレルギー_感染症_未指定あり() {
    final String FACILITY_CD = "F_hN12";

    try {
      // 正常応答検証
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容検証

      // pat_personal_main
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      // pat_main
      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);

      assertThat(pm, notNullValue());

      // 禁忌・アレルギー情報
      String tabooAllergyInfoStr = pm.getTaboo_allergy_info();
      List<Map<String, Object>> resultTabooAllergyInfo = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr);
      assertThat(resultTabooAllergyInfo, notNullValue());
      assertThat(resultTabooAllergyInfo.size(), is(1));

      // ヨードアレルギー="0"が指定されているため、対応するエントリは作成されない。

      List<Map<String, Object>> expectedTabooAllergyInfo = new ArrayList<>();

      Map<String, Object> ta1 = new TreeMap<>();
      expectedTabooAllergyInfo.add(ta1);

      Integer tabooAllergyCd1 = mstTabooAllergyDao.selectByInHospitalCd1(FACILITY_CD, "LID");
      ta1.put("taboo_allergy_cd", tabooAllergyCd1);
      ta1.put("taboo_allergy_class", "2");
      ta1.put("category_class", "0");

      // 感染症情報
      String infectInfoStr = pm.getInfect_info();
      List<Map<String, Object>> resultInfectInfo = ObjectMapperUtil.readListOfMap(infectInfoStr);
      assertThat(resultInfectInfo, notNullValue());
      assertThat(resultInfectInfo.size(), is(1));

      // HBs="0"が指定されているため、対応するエントリは作成されない。
      // （感染症情報のinfectキーは「"?"/"+"/"-"」しか認めないところに"0"を指定しているので無視される）

      List<Map<String, Object>> expectedTInfectInfo = new ArrayList<>();

      Map<String, Object> in1 = new TreeMap<>();
      expectedTInfectInfo.add(in1);

      Integer infectCd1 = mstInfectionDao.selectByInHospitalCd1(FACILITY_CD, "312");
      in1.put("infect", "1");
      in1.put("infection_cd", infectCd1);

      assertThat(resultInfectInfo, is(expectedTInfectInfo));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
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
