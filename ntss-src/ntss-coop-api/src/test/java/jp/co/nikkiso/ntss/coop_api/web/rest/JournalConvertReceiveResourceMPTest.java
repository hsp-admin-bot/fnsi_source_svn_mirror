package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.http.MediaType;
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
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class JournalConvertReceiveResourceMPTest extends AbstractResourceTest {

  @SpyBean
  private PatPersonalMainDao patPersonalMainDao;

  @SpyBean
  private PatMainDao patMainDao;

  @SpyBean
  private PatUniqueDao patUniqueDao;

  @SpyBean
  private MstDiseaseDao mstDiseaseDao;

  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM00/clean_db5_M00.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceMPTest/sM00/clean_db6_M00.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceMPTest/sM00/masters_staff_M00.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM00/masters_others_M00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM00/masters_layout_M00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM00/masters_layout_detail_M00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM00/journal_M00.sql")
  @Test
  public void 電文に複数患者が含まれる_1_電文構造一致() {
    final String FACILITY_CD = "F_hM00";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容の検証
      // 詳細な内容検証は他のシナリオで実施しているため、ここではpat_personal_mainレコード数と識別情報のみチェックする。
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(2));

      assertThat(ppmList.get(0).getPat_id(), is(51001800L));
      assertThat(ppmList.get(0).getFacility_cd(), is(FACILITY_CD));
      assertThat(ppmList.get(1).getPat_id(), is(51001801L));
      assertThat(ppmList.get(1).getFacility_cd(), is(FACILITY_CD));

      List<Long> patIdList = ppmList.stream().map(ppm -> ppm.getPat_id()).collect(Collectors.toList());
      List<PatMain> pmLIst = patMainDao.selectByIdList(patIdList);
      assertThat(pmLIst, notNullValue());
      assertThat(pmLIst.size(), is(2));

      assertThat(pmLIst.get(0).getPat_id(), is(51001800L));
      assertThat(pmLIst.get(0).getFacility_cd(), is(FACILITY_CD));
      assertThat(pmLIst.get(1).getPat_id(), is(51001801L));
      assertThat(pmLIst.get(1).getFacility_cd(), is(FACILITY_CD));

    } catch (Exception e) {
      fail("", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM01/clean_db5_M01.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceMPTest/sM01/clean_db6_M01.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceMPTest/sM01/masters_staff_M01.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM01/masters_others_M01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM01/masters_layout_M01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM01/masters_layout_detail_M01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceMPTest/sM01/journal_M01.sql")
  @Test
  public void 電文に複数患者が含まれる_2_電文構造相違() {
    final String FACILITY_CD = "F_hM01";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB登録内容の検証
      // 詳細な内容検証は他のシナリオで実施しているため、ここではpat_personal_mainレコード数と識別情報のみチェックする。
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(2));

      // 患者情報1と2の相違点
      // 患者情報1（pat_id=51001810）ではVB1（原疾患）である情報が、患者情報2（pat_id=51001811）ではXXX（コメント）になっている。
      // 結果として、患者情報1ではpat_unique.medical_hst_info、患者情報2ではpat_main.pat_memo_infoが登録される。

      // pat_personal_main
      PatPersonalMain ppm1 = ppmList.get(0);
      assertThat(ppm1.getPat_id(), is(51001810L));
      assertThat(ppm1.getFacility_cd(), is(FACILITY_CD));

      PatPersonalMain ppm2 = ppmList.get(1);
      assertThat(ppm2.getPat_id(), is(51001811L));
      assertThat(ppm2.getFacility_cd(), is(FACILITY_CD));

      // pat_main
      List<Long> patIdList = ppmList.stream().map(ppm -> ppm.getPat_id()).collect(Collectors.toList());
      List<PatMain> pmList = patMainDao.selectByIdList(patIdList);
      assertThat(pmList, notNullValue());
      assertThat(pmList.size(), is(2));

      PatMain pm1 = pmList.get(0);
      assertThat(pm1.getPat_id(), is(51001810L));
      assertThat(pm1.getFacility_cd(), is(FACILITY_CD));

      String memo1 = pm1.getPat_memo_info();
      // 患者情報1にはpat_main.pat_memo_infoを抽出する指定がない。
      // そのため、値はnullになる。
      assertThat(memo1, nullValue());

      PatMain pm2 = pmList.get(1);
      assertThat(pm2.getPat_id(), is(51001811L));
      assertThat(pm2.getFacility_cd(), is(FACILITY_CD));

      String memo2 = pm2.getPat_memo_info();
      // 患者情報1で抽出した原疾患の名称が、患者情報2ではコメントとして抽出される。
      assertThat(memo2, notNullValue());
      assertThat(memo2, is("[{\"content\": \"もやもや病\"}]"));

      // pat_unique
      PatUnique pu1 = patUniqueDao.selectById(ppm1.getPat_id());
      // 患者情報1では原疾患でmedical_hst_infoにdisease_cdが設定されている。
      assertThat(pu1, notNullValue());
      String medicalHstInfo1Str = pu1.getMedical_hst_info();
      List<Map<String, Object>> result = ObjectMapperUtil.readListOfMap(medicalHstInfo1Str);

      Map<String, Object> m1 = new TreeMap<>();
      List<Map<String, Object>> expected = Collections.singletonList(m1);

      m1.put("ctl_no", 1);
      m1.put("disp_order", 1);
      Integer diseaseCd = mstDiseaseDao.selectByInHospitalCd1(FACILITY_CD, "VB199999");
      m1.put("disease_cd", diseaseCd);

      assertThat(result, is(expected));

      PatUnique pu2 = patUniqueDao.selectById(ppm2.getPat_id());
      // 患者情報2ではpat_uniqueのカラムを抽出する指定が存在しないが、pat_personal_main、pat_main、pat_uniqueは必ず組で登録される。
      assertThat(pu2, notNullValue());
      // medical_hst_infoカラムを抽出する指定が存在しないため、nullが設定されている。
      String medicalHstInfo2 = pu2.getMedical_hst_info();
      assertThat(medicalHstInfo2, nullValue());

    } catch (Exception e) {
      fail("", e);
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
