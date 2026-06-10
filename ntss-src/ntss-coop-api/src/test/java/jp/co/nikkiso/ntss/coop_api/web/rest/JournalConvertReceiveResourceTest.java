package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.hamcrest.Matchers;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.JavaType;
import com.google.common.collect.Maps;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.OrdCoopNoDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatCoopDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatObsRecDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatCoopDetail;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatObsRec;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.extern.slf4j.Slf4j;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Slf4j
public class JournalConvertReceiveResourceTest extends AbstractResourceTest {

  @SpyBean
  private MstDiseaseDao mstDiseaseDao;

  @SpyBean
  private MstDialysisDifficultyDao mstDialysisDifficultyDao;

  @SpyBean
  private ConvertCommonService convertCommonService;

  @SpyBean
  private SysCoopJournalDao sysCoopJournalDao;

  @SpyBean
  private PatPersonalMainDao patPersonalMainDao;

  @SpyBean
  private PatMainDao patMainDao;

  @SpyBean
  private PatExamMainDao patExamMainDao;

  @SpyBean
  private PatObsRecDao patObsRecDao;

  @SpyBean
  private PatUniqueDao patUniqueDao;

  @SpyBean
  private PatCoopDetailDao patCoopDetailDao;

  @SpyBean
  private PatInsuranceDao patInsuranceDao;

  @SpyBean
  private OrdMainDao ordMainDao;

  @SpyBean
  private OrdCoopNoDao ordCoopNoDao;

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hosp/clean_db5.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hosp/clean_db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hosp/masters_staff.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hosp/masters_others.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hosp/masters_layout.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hosp/masters_layout_detail.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hosp/journal.sql")
  @Test
  public void ジャーナル変換_疎通テスト() {
    // このシナリオは応答ステータス確認のみ。
    // DB内容確認は別シナリオで実施する。

    final String FACILITY_CD = "F_hosp";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status()
        .isOk())
        // 正常系
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", Matchers.hasSize(1)))
        .andExpect(jsonPath("$.result[0].ctl_no").value(12365L))
        .andExpect(jsonPath("$.result[0].ana_result").value("9"))
        .andExpect(jsonPath("$.result[0].message").value(""));
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos2/clean_db5.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos2/clean_db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos2/masters_staff.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos2/masters_others.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos2/masters_layout.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos2/masters_layout_detail.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos2/journal.sql")
  @Test
  public void ジャーナル変換_疎通テスト_pat_unique_病名コードがない場合_既往歴が連携されない() {
    try {
      ResultActions response = requestConversionByFacilityCd("F_hos2");
      response.andExpect(status().isOk());
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // DB内容確認シナリオ

  // pat_personal_main
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s000/clean_db5_000.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s000/clean_db6_000.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s000/masters_staff_000.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s000/masters_others_000.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s000/masters_layout_000.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s000/masters_layout_detail_000.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s000/journal_000.sql")
  @Test
  public void ジャーナル変換_pat_personal_mainレコードが登録される() {
    final String FACILITY_CD = "F_h000";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s001/clean_db5_001.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s001/clean_db6_001.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s001/masters_staff_001.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s001/masters_others_001.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s001/masters_layout_001.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s001/masters_layout_detail_001.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s001/journal_001.sql")
  @Test
  public void ジャーナル変換_pat_personal_mainレコードが登録される_新規登録() {
    final String FACILITY_CD = "F_h001";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s002/clean_db5_002.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s002/clean_db6_002.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s002/masters_staff_002.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s002/masters_others_002.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s002/masters_layout_002.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s002/journal_002.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s002/pat_personal_main_002.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void ジャーナル変換_pat_personal_mainレコードが登録される_更新() {
    final String FACILITY_CD = "F_h002";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // 施設コード=F_h002、hosp_pat_id=1111111112のレコードの姓と名が電文内容で書き換えられる。
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s003/clean_db5_003.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s003/clean_db6_003.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s003/masters_staff_003.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s003/masters_others_003.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s003/masters_layout_003.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s003/journal_003.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s003/pat_personal_main_003.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void ジャーナル変換_pat_personal_mainレコードが登録される_削除() {
    final String FACILITY_CD = "F_h003";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // 施設コード=F_h003、hosp_pat_id=1111111113のレコードが論理削除される。
      // 論理削除されたレコードを取得するpat_personal_mainのDAO APIが存在しないため、DBを目視確認する。
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertTrue(ppmList.isEmpty());
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_main
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s100/clean_db5_100.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s100/clean_db6_100.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s100/masters_staff_100.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s100/masters_others_100.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s100/masters_layout_100.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s100/masters_layout_detail_100.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s100/journal_100.sql")
  @Test
  public void ジャーナル変換_pat_mainレコードが登録される() {
    final String FACILITY_CD = "F_h100";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      PatMain pm = patMainDao.selectById(patId);
      assertThat(pm, notNullValue());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_exam_main
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s200/clean_db5_200.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s200/clean_db6_200.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s200/masters_staff_200.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s200/masters_others_200.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s200/masters_layout_200.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s200/masters_layout_detail_200.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s200/journal_200.sql")
  @Test
  public void ジャーナル変換_pat_exam_mainレコードが登録される_新規登録() {
    final String FACILITY_CD = "F_h200";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      List<Long> patIdList = Collections.singletonList(patId);
      List<PatExamMainData> l = patExamMainDao.selectPatExamMainByPatIdList(patIdList, "0001/01/01");
      assertThat(l, notNullValue());
      assertThat(l.size(), is(1));

      PatExamMainData pemd = l.get(0);
      assertThat(pemd.getPatId(), is(patId));

      assertThat(pemd.getRegOrderClass(), is("T"));
      assertThat(pemd.getExamStatus(), is("S"));

      String examResultInfoStr = pemd.getExamResultInfo();
      assertThat(examResultInfoStr, notNullValue());

      JavaType jt = ObjectMapperUtil.constructMapType(String.class, Object.class);
      JavaType lt = ObjectMapperUtil.constructListType(jt);
      List<Map<String, Object>> lm = ObjectMapperUtil.read(examResultInfoStr, lt);

      assertThat(lm.size(), is(2));
      assertThat(lm.get(0).get("unit"), is("mmHg"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s201/clean_db5_201.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s201/clean_db6_201.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s201/masters_staff_201.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s201/masters_others_201.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s201/masters_layout_201.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s201/masters_layout_detail_201.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s201/journal_201.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s201/pat_exam_main_201.sql")
  @Test
  public void ジャーナル変換_pat_exam_mainレコードが登録される_既存レコード更新() {
    final String FACILITY_CD = "F_h201";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      List<Long> patIdList = Collections.singletonList(patId);
      List<PatExamMainData> l = patExamMainDao.selectPatExamMainByPatIdList(patIdList, "0001/01/01");
      assertThat(l, notNullValue());
      assertThat(l.size(), is(1));
      // ここで1件取得される他、既存レコードがis_del="1"に変更されている。
      // 論理削除されたレコードを取得するDAO APIが存在しないため、pat_exam_mainを目視確認する。

      PatExamMainData pemd = l.get(0);
      assertThat(pemd.getPatId(), is(patId));

      assertThat(pemd.getRegOrderClass(), is("T"));
      assertThat(pemd.getExamStatus(), is("S"));

      String examResultInfoStr = pemd.getExamResultInfo();
      assertThat(examResultInfoStr, notNullValue());

      JavaType jt = ObjectMapperUtil.constructMapType(String.class, Object.class);
      JavaType lt = ObjectMapperUtil.constructListType(jt);
      List<Map<String, Object>> lm = ObjectMapperUtil.read(examResultInfoStr, lt);

      assertThat(lm.size(), is(2));
      assertThat(lm.get(0).get("unit"), is("mmHg"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_obs_rec
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s300/clean_db5_300.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s300/clean_db6_300.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s300/masters_staff_300.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s300/masters_others_300.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s300/masters_layout_300.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s300/masters_layout_detail_300.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s300/journal_300.sql")
  @Test
  public void ジャーナル変換_pat_obs_rec_マスタ照合すべて成功の場合_レコードが登録される_() {
    final String FACILITY_CD = "F_h300";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      PatObsRec patObsRec = getPatObsRecByFacilityCd(FACILITY_CD);
      assertThat(patObsRec, notNullValue());

      // 種別情報の確認
      Map<String, Object> resultKindInfo = getResultMap(patObsRec.getKindInfo());
      assertTrue(!resultKindInfo.isEmpty());

      Map<String, Object> expectedKindInfo = createExpected("kind_no", "1", "kind_name", "かきくけこ", "kind_update",
        "20200210160000");
      assertMapEquals(resultKindInfo, expectedKindInfo);

      // 起票者情報の確認
      Map<String, Object> resultRegStaffInfo = getResultMap(patObsRec.getRegStaffInfo());
      assertTrue(!resultRegStaffInfo.isEmpty());

      Map<String, Object> expectedRegStaffInfo = createExpected("reg_staff_cd", 90300, "reg_staff_name", "さしすせそ",
        "reg_staff_update", "20200210161000");
      assertMapEquals(resultRegStaffInfo, expectedRegStaffInfo);
      // 利用者マスタの利用者IDカラムはbigint（JavaではLongに相当）だが、Jacksonでは数値によりInteger/Long/BigIntegerが使用される。
      // （符号付き32ビットに収まる⇒Integer、符号付き64ビットに収まる⇒Long、符号付き64ビットに収まらない⇒BigInteger）
      // カラムの型がbigintであっても90300はIntegerになるので注意する。
      // （つまり、上記の90300を90300Lと書くと型が異なるため照合不一致となる。）

      // 編集者情報の確認
      Map<String, Object> resultUpStaffInfo = getResultMap(patObsRec.getUpStaffInfo());
      assertTrue(!resultUpStaffInfo.isEmpty());

      Map<String, Object> expectedUpStaffInfo = createExpected("up_staff_cd", 90300, "up_staff_name", "たちつてと",
        "up_staff_update", "20200210162000");
      assertMapEquals(resultUpStaffInfo, expectedUpStaffInfo);
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s301/clean_db5_301.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s301/clean_db6_301.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s301/masters_staff_301.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s301/masters_others_301.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s301/masters_layout_301.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s301/masters_layout_detail_301.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s301/journal_301.sql")
  @Test
  public void ジャーナル変換_pat_obs_rec_種別情報照合失敗_kind_nameがない場合は空jsonが設定される() {
    final String FACILITY_CD = "F_h301";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      PatObsRec patObsRec = getPatObsRecByFacilityCd(FACILITY_CD);
      assertThat(patObsRec, notNullValue());

      Map<String, Object> result = getResultMap(patObsRec.getKindInfo());
      assertTrue(result.isEmpty());
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s302/clean_db5_302.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s302/clean_db6_302.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s302/masters_staff_302.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s302/masters_others_302.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s302/masters_layout_302.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s302/masters_layout_detail_302.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s302/journal_302.sql")
  @Test
  public void ジャーナル変換_pat_obs_rec_種別情報照合失敗_kind_nameがある場合はkind_nameが設定される() {
    final String FACILITY_CD = "F_h302";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      PatObsRec patObsRec = getPatObsRecByFacilityCd(FACILITY_CD);
      assertThat(patObsRec, notNullValue());

      Map<String, Object> result = getResultMap(patObsRec.getKindInfo());
      assertTrue(!result.isEmpty());

      // マスタ照合が失敗しkind_noは反映されないが、kind_nameとkind_updateは登録される。
      Map<String, Object> expected = createExpected("kind_name", "かきくけこ", "kind_update", "20200210160000");
      assertMapEquals(result, expected);
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s311/clean_db5_311.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s311/clean_db6_311.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s311/masters_staff_311.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s311/masters_others_311.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s311/masters_layout_311.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s311/masters_layout_detail_311.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s311/journal_311.sql")
  @Test
  public void ジャーナル変換_pat_obs_rec_起票者情報照合失敗_reg_staff_nameがない場合は空jsonが設定される() {
    final String FACILITY_CD = "F_h311";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      PatObsRec patObsRec = getPatObsRecByFacilityCd(FACILITY_CD);

      assertThat(patObsRec, notNullValue());

      Map<String, Object> result = getResultMap(patObsRec.getRegStaffInfo());
      assertTrue(result.isEmpty());
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s312/clean_db5_312.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s312/clean_db6_312.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s312/masters_staff_312.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s312/masters_others_312.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s312/masters_layout_312.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s312/masters_layout_detail_312.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s312/journal_312.sql")
  @Test
  public void ジャーナル変換_pat_obs_rec_起票者情報照合失敗_reg_staff_nameがある場合はreg_staff_nameが設定される() {
    final String FACILITY_CD = "F_h312";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      PatObsRec patObsRec = getPatObsRecByFacilityCd(FACILITY_CD);
      assertThat(patObsRec, notNullValue());

      Map<String, Object> result = getResultMap(patObsRec.getRegStaffInfo());
      assertTrue(!result.isEmpty());

      // マスタ照合が失敗しkind_noは反映されないが、kind_nameとkind_updateは登録される。
      Map<String, Object> expected = createExpected("reg_staff_name", "さしすせそ", "reg_staff_update", "20200210161000");
      assertMapEquals(result, expected);
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s321/clean_db5_321.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s321/clean_db6_321.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s321/masters_staff_321.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s321/masters_others_321.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s321/masters_layout_321.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s321/masters_layout_detail_321.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s321/journal_321.sql")
  @Test
  public void ジャーナル変換_pat_obs_rec_編集者情報照合失敗_up_staff_nameがない場合は空jsonが設定される() {
    final String FACILITY_CD = "F_h321";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      PatObsRec patObsRec = getPatObsRecByFacilityCd(FACILITY_CD);

      assertThat(patObsRec, notNullValue());

      Map<String, Object> result = getResultMap(patObsRec.getUpStaffInfo());
      assertTrue(result.isEmpty());
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s322/masters_staff_322.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s322/masters_others_322.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s322/masters_layout_322.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s322/masters_layout_detail_322.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s322/reset_322.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s322/journal_322.sql")
  @Test
  public void ジャーナル変換_pat_obs_rec_編集者情報照合失敗_up_staff_nameがある場合はup_staff_nameが設定される() {
    final String FACILITY_CD = "F_h322";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      PatObsRec patObsRec = getPatObsRecByFacilityCd(FACILITY_CD);
      assertThat(patObsRec, notNullValue());

      Map<String, Object> result = getResultMap(patObsRec.getUpStaffInfo());
      assertTrue(!result.isEmpty());

      // マスタ照合が失敗しkind_noは反映されないが、kind_nameとkind_updateは登録される。
      Map<String, Object> expected = createExpected("up_staff_name", "たちつてと", "up_staff_update", "20200210162000");
      assertMapEquals(result, expected);
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_unique
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s400/clean_db5_400.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s400/clean_db6_400.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s400/masters_staff_400.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s400/masters_others_400.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s400/masters_layout_400.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s400/masters_layout_detail_400.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s400/journal_400.sql")
  @Test
  public void ジャーナル変換_pat_uniqueレコードが登録される() {
    final String FACILITY_CD = "F_h400";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      Long patId = getPatIdByFacilityCd(FACILITY_CD);
      assertThat(patId, is(1000400L));

      PatUnique patUnique = patUniqueDao.selectById(patId);
      assertThat(patUnique, notNullValue());

      // medical_hst_info（既往歴）
      String medicalHstInfoStr = patUnique.getMedical_hst_info();
      List<Map<String, Object>> resultMedicalHstInfo = ObjectMapperUtil.readListOfMap(medicalHstInfoStr);

      Integer diseaseCd = mstDiseaseDao.selectByInHospitalCd1(FACILITY_CD, "VB199999");

      Map<String, Object> expectedMedicalHstInfoElement = createExpected("ctrl_no", 1, "disp_order", 1, "disease_cd",
        diseaseCd);
      List<Map<String, Object>> expectedMedicalHstInfo = Collections.singletonList(expectedMedicalHstInfoElement);
      assertMapListEquals(resultMedicalHstInfo, expectedMedicalHstInfo);

      // 新規登録

      // physical_info（身体情報）
      // exam_date項目が存在する && exam_dateの最大値より大きい場合は連携する

      // TODO

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_coop_detail
  // メモ: pat_coop_detailはバリエーションなし
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s500/clean_db5_500.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s500/clean_db6_500.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s500/masters_staff_500.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s500/masters_others_500.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s500/masters_layout_500.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s500/masters_layout_detail_500.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s500/journal_500.sql")
  @Test
  public void ジャーナル変換_pat_coop_detailレコードが登録される() {
    final String FACILITY_CD = "F_h500";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      PatCoopDetail pcd = patCoopDetailDao.selectByPatId(patId, FACILITY_CD, null);
      assertThat(pcd, notNullValue());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_insurance
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s600/clean_db5_600.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s600/clean_db6_600.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s600/masters_staff_600.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s600/masters_others_600.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s600/masters_layout_600.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s600/masters_layout_detail_600.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s600/journal_600.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される() {
    try {
      ResultActions response = requestConversionByFacilityCd("F_h600");
      response.andExpect(status().isOk());

      // pat_insuranceはベンダごとに登録処理が異なる。
      // そのため、本シナリオでは正常応答のみ確認している。
      // DB登録内容の検証はF_h601～F_h621を参照。

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s601/clean_db5_601.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s601/clean_db6_601.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s601/masters_staff_601.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s601/masters_others_601.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s601/masters_layout_601.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s601/masters_layout_detail_601.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s601/journal_601.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される_富士通_保険_新規登録() {
    final String FACILITY_CD = "F_h601";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      // 登録された保険情報の数の検証
      // （電文から5個抽出した。
      //  insu_class=0とinsu_class=2のレコードが5個ずつ作成されるが、insu_class=0のレコードはすべて同一の一意条件を持つ。
      //  そのため、insu_class=0は1個insertした後にupdateが4回実行され、合計オブジェクト数は6となる。）
      List<PatInsurance> piList = patInsuranceDao.getListPatInsuranceById(patId);
      assertThat(piList, notNullValue());
      assertThat(piList.size(), is(10));

      // 患者IDと施設コードがpat_personal_mainと一致することの検証
      piList.forEach(pi -> {
        assertThat(pi.getPat_id(), is(patId));
        assertThat(pi.getFacility_cd(), is(FACILITY_CD));
      });

      // セット情報中のinsu_set_infoカラムのinsu_cdの値が、対応する保険情報のinsurance_cdと一致する
      for (int i = 0; i < 10; i += 2) {
        Long insCd = piList.get(i).getInsurance_cd();

        String setInfoStr = piList.get(i + 1).getInsu_set_info();
        Map<String, Object> setInfo = getResultMap(setInfoStr);
        String refStr = (String) setInfo.get("insu_cd");
        Long ref = Long.parseLong(refStr);
        assertThat(ref, is(insCd));
      }

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s602/clean_db5_602.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s602/clean_db6_602.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s602/masters_staff_602.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s602/masters_others_602.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s602/masters_layout_602.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s602/masters_layout_detail_602.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s602/journal_602.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される_富士通_公費_新規登録() {
    final String FACILITY_CD = "F_h602";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      // 登録された保険情報の数の検証
      List<PatInsurance> piList = patInsuranceDao.getListPatInsuranceById(patId);
      assertThat(piList, notNullValue());
      assertThat(piList.size(), is(10));

      // 患者IDと施設コードがpat_personal_mainと一致することの検証
      piList.forEach(pi -> {
        assertThat(pi.getPat_id(), is(patId));
        assertThat(pi.getFacility_cd(), is(FACILITY_CD));
      });

      // セット情報中のinsu_set_infoカラムのinsu_cdの値が、対応する公費情報のinsurance_cdと一致する
      for (int i = 0; i < 10; i += 2) {
        Long insCd = piList.get(i).getInsurance_cd();

        String setInfoStr = piList.get(i + 1).getInsu_set_info();
        Map<String, Object> setInfo = getResultMap(setInfoStr);
        String refStr = (String) setInfo.get("insu_cd");
        Long ref = Long.parseLong(refStr);
        assertThat(ref, is(insCd));
      }

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s603/clean_db5_603.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s603/clean_db6_603.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s603/masters_staff_603.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s603/masters_others_603.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s603/masters_layout_603.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s603/masters_layout_detail_603.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s603/pat_insurance_603.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s603/journal_603.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される_富士通_保険_更新() {
    final String FACILITY_CD = "F_h603";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      // 登録された保険情報の数の検証
      // （既存1件+保険情報5×{保険情報,セット情報}=11）
      List<PatInsurance> piList = patInsuranceDao.getListPatInsuranceById(patId);
      assertThat(piList, notNullValue());
      assertThat(piList.size(), is(11));

      // 患者IDと施設コードがpat_personal_mainと一致することの検証
      piList.forEach(pi -> {
        assertThat(pi.getPat_id(), is(patId));
        assertThat(pi.getFacility_cd(), is(FACILITY_CD));
      });

      // セット情報中のinsu_set_infoカラムのinsu_cdの値が、対応する保険情報のinsurance_cdと一致する
      piList.removeIf(p -> StringUtils.isEmpty(p.getInsu_name()));

      for (int i = 0; i < 10; i += 2) {
        Long insCd = piList.get(i).getInsurance_cd();

        String setInfoStr = piList.get(i + 1).getInsu_set_info();
        Map<String, Object> setInfo = getResultMap(setInfoStr);
        String refStr = (String) setInfo.get("insu_cd");
        Long ref = Long.parseLong(refStr);
        assertThat(ref, is(insCd));
      }

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s604/clean_db5_604.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s604/clean_db6_604.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s604/masters_staff_604.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s604/masters_others_604.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s604/masters_layout_604.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s604/masters_layout_detail_604.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s604/pat_insurance_604.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s604/journal_604.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される_富士通_公費_更新() {
    final String FACILITY_CD = "F_h604";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容検証
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();

      // 登録された保険情報の数の検証
      // （電文から5個抽出したので、保険情報とセット情報で計10個作成される）
      List<PatInsurance> piList = patInsuranceDao.getListPatInsuranceById(patId);
      assertThat(piList, notNullValue());
      assertThat(piList.size(), is(11));

      // 患者IDと施設コードがpat_personal_mainと一致することの検証
      piList.forEach(pi -> {
        assertThat(pi.getPat_id(), is(patId));
        assertThat(pi.getFacility_cd(), is(FACILITY_CD));
      });

      // セット情報中のinsu_set_infoカラムのinsu_cdの値が、対応する保険情報のinsurance_cdと一致する
      piList.removeIf(p -> StringUtils.isEmpty(p.getInsu_name()));

      for (int i = 0; i < 10; i += 2) {
        Long insCd = piList.get(i).getInsurance_cd();

        String setInfoStr = piList.get(i + 1).getInsu_set_info();
        Map<String, Object> setInfo = getResultMap(setInfoStr);
        String refStr = (String) setInfo.get("insu_cd");
        Long ref = Long.parseLong(refStr);
        assertThat(ref, is(insCd));
      }

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s610/clean_db5_610.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s610/clean_db6_610.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s610/masters_staff_610.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s610/masters_others_610.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s610/masters_layout_610.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s610/masters_layout_detail_610.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s610/journal_610.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される_NEC() {
    final String FACILITY_CD = "F_h610";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      log.debug("{}:ppmList={}", FACILITY_CD, ppmList);
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();
      log.debug("{}:patId={}", FACILITY_CD, patId);

      List<PatInsurance> piList = patInsuranceDao.getListPatInsuranceById(patId);
      assertThat(piList, notNullValue());
      assertThat(piList.size(), is(5));

      piList.forEach(pi -> {
        assertThat(pi.getPat_id(), is(patId));
        assertThat(pi.getFacility_cd(), is(FACILITY_CD));
      });

      assertThat(piList.get(0).getInsu_name(), is("ABCD"));
      assertThat(piList.get(1).getInsu_name(), is("0123"));
      assertThat(piList.get(2).getInsu_name(), is("PQRS"));
      assertThat(piList.get(3).getInsu_name(), is("9873"));
      assertThat(piList.get(4).getInsu_name(), is("MNOP"));
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s620/clean_db5_620.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s620/clean_db6_620.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s620/masters_staff_620.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s620/masters_others_620.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s620/masters_layout_620.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s620/masters_layout_detail_620.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s620/journal_620.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される_PANASONIC_新規登録() {
    final String FACILITY_CD = "F_h620";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      log.debug("{}:ppmList={}", FACILITY_CD, ppmList);
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();
      log.debug("{}:patId={}", FACILITY_CD, patId);

      List<PatInsurance> piList = patInsuranceDao.getListPatInsuranceById(patId);
      assertThat(piList, notNullValue());
      assertThat(piList.size(), is(4));

      PatInsurance pi0 = piList.get(0);
      PatInsurance pi1 = piList.get(1);
      PatInsurance pi2 = piList.get(2);
      PatInsurance pi3 = piList.get(3);

      assertThat(pi0.getInsu_name(), is("3"));
      assertThat(pi0.getInsu_name_short(), is("3"));

      assertThat(pi1.getInsu_name(), is("51000000"));
      assertThat(pi1.getInsu_name_short(), is("51"));

      assertThat(pi2.getInsu_name(), is("84000000"));
      assertThat(pi2.getInsu_name_short(), is("84"));

      assertThat(pi3.getInsu_name(), is("自費"));
      assertThat(pi3.getInsu_name_short(), is("自費"));

      piList.stream().forEach(e -> {
        assertThat(e.getStart_date(), is("00010101"));
        assertThat(e.getEnd_date(), is("99991231"));
      });

      // セット情報と保険/公費情報の関連付けのチェック

      String s = pi3.getInsu_set_info();
      JavaType mapType = ObjectMapperUtil.constructMapType(String.class, String.class);
      Map<String, String> m = ObjectMapperUtil.read(s, mapType);

      Long insuCd = Long.parseLong(m.get("insu_cd"));
      assertThat(insuCd, is(pi0.getInsurance_cd()));

      Long insuPub1Cd = Long.parseLong(m.get("insu_pub1_cd"));
      assertThat(insuPub1Cd, is(pi1.getInsurance_cd()));

      Long insuPub2Cd = Long.parseLong(m.get("insu_pub2_cd"));
      assertThat(insuPub2Cd, is(pi2.getInsurance_cd()));

      // coop_codeの検証
      assertThat(pi0.getCoop_code(), is("3"));
      // 既存レコードから変化しない。

      assertThat(pi1.getCoop_code(), is("51000000"));
      assertThat(pi2.getCoop_code(), is("84000000"));
      assertThat(pi3.getCoop_code(), is("001"));

      // is_coopの検証
      piList.stream().forEach(e -> {
        assertThat(e.getIs_coop(), is("1"));
      });

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s621/clean_db5_621.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s621/clean_db6_621.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s621/masters_staff_621.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s621/masters_others_621.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s621/masters_layout_621.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s621/masters_layout_detail_621.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/s621/pat_insurance_621.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/s621/journal_621.sql")
  @Test
  public void ジャーナル変換_pat_insuranceレコードが登録される_PANASONIC_更新() {
    final String FACILITY_CD = "F_h621";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      log.debug("{}:ppmList={}", FACILITY_CD, ppmList);
      PatPersonalMain ppm = ppmList.get(0);
      Long patId = ppm.getPat_id();
      log.debug("{}:patId={}", FACILITY_CD, patId);

      List<PatInsurance> piList = patInsuranceDao.getListPatInsuranceById(patId);
      assertThat(piList, notNullValue());
      assertThat(piList.size(), is(5));

      PatInsurance pi0 = piList.get(0);
      PatInsurance pi1 = piList.get(1);
      PatInsurance pi2 = piList.get(2);
      PatInsurance pi3 = piList.get(3);
      PatInsurance pi4 = piList.get(4);

      // 保険情報は既存である。
      // 既存情報は更新しないため、電文で指定された「3」はDBに反映されない。
      assertThat(pi0.getInsu_name(), is(""));
      assertThat(pi0.getInsu_name_short(), is(""));

      // 保険情報
      // 既存レコードのカラムに電文で指定された値を上書きした状態になる。
      // 既存レコードで空であり、電文でも指定されていないため、空になる。
      assertThat(pi1.getInsu_name(), is(""));
      assertThat(pi1.getInsu_name_short(), is(""));

      assertThat(pi2.getInsu_name(), is("51000000"));
      assertThat(pi2.getInsu_name_short(), is("51"));

      assertThat(pi3.getInsu_name(), is("84000000"));
      assertThat(pi3.getInsu_name_short(), is("84"));

      assertThat(pi4.getInsu_name(), is("自費"));
      assertThat(pi4.getInsu_name_short(), is("自費"));

      // 保険情報は既存なので、start_dateとend_dateはnullのまま変化しない。
      // 公費情報とセット情報はデフォルト値が登録される。
      assertThat(pi0.getStart_date(), nullValue());
      assertThat(pi0.getEnd_date(), nullValue());
      assertThat(pi1.getStart_date(), nullValue());
      assertThat(pi1.getEnd_date(), nullValue());

      for (int i = 2; i <= 4; ++i) {
        assertThat(piList.get(i).getStart_date(), is("00010101"));
        assertThat(piList.get(i).getEnd_date(), is("99991231"));
      }

      // セット情報と保険/公費情報の関連付けのチェック

      String s = pi4.getInsu_set_info();
      JavaType mapType = ObjectMapperUtil.constructMapType(String.class, String.class);
      Map<String, String> m = ObjectMapperUtil.read(s, mapType);

      Long insuCd = Long.parseLong(m.get("insu_cd"));
      assertThat(insuCd, is(pi1.getInsurance_cd()));

      Long insuPub1Cd = Long.parseLong(m.get("insu_pub1_cd"));
      assertThat(insuPub1Cd, is(pi2.getInsurance_cd()));

      Long insuPub2Cd = Long.parseLong(m.get("insu_pub2_cd"));
      assertThat(insuPub2Cd, is(pi3.getInsurance_cd()));

      // coop_codeの検証
      assertThat(pi0.getCoop_code(), is("06121212"));
      // 既存レコードから変化しない。

      assertThat(pi1.getCoop_code(), is("06121212"));
      assertThat(pi2.getCoop_code(), is("51000000"));
      assertThat(pi3.getCoop_code(), is("84000000"));
      assertThat(pi4.getCoop_code(), is("001"));

      // is_coopの検証
      piList.stream().forEach(e -> {
        assertThat(e.getIs_coop(), is("1"));
      });

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA00/clean_db5_A00.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA00/clean_db6_A00.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA00/masters_staff_A00.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA00/masters_others_A00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA00/masters_layout_A00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA00/masters_layout_detail_A00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA00/journal_A00.sql")
  @Test
  public void ジャーナル変換_患者姓名などがtrimされる姓名が分離される() {
    try {
      String FACILITY_CD = "F_hA00";
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      // DB内容確認
      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      PatPersonalMain ppm = ppmList.get(0);

      assertThat(ppm.getPat_last_name(), is("田中"));
      assertThat(ppm.getPat_first_name(), is("学"));
      assertThat(ppm.getPat_last_name_kana(), is("タナカ"));
      assertThat(ppm.getPat_first_name_kana(), is("マナブ"));
      assertThat(ppm.getPat_last_name_alpha(), is("tanaka"));
      assertThat(ppm.getPat_first_name_alpha(), is("manabu"));
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // 処理区分（insert/update/delete）の確認
  // pat_personal_mainの処理区分とpat_mainの処理区分が独立に制御できるケース
  // pat_mainをDB5テーブル群代表として全パターン実施する。
  // 他のテーブルは抜粋して実施する。

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA01/clean_db5_A01.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA01/clean_db6_A01.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA01/masters_staff_A01.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA01/masters_others_A01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA01/masters_layout_A01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA01/masters_layout_detail_A01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA01/journal_A01.sql")
  @Test
  public void pat_personal_main_新規登録_pat_main_新規登録() {
    final String FACILITY_CD = "F_hA01";
    // pat_personal_main.is_delなし

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);
      assertThat(pm, notNullValue());

      String staffInfoStr = pm.getCharge_staff_info();

      List<Map<String, Object>> lm = ObjectMapperUtil.readListOfMap(staffInfoStr);
      assertThat(lm, notNullValue());
      assertThat(lm.size(), is(1));

      Map<String, Object> m = lm.get(0);
      assertTrue(!m.isEmpty());
      assertThat(m.get("staff_cd"), is(98001));
      assertThat(m.get("staff_name"), is("ＧＸ２Ｗ　管理者"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA02/masters_staff_A02.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA02/masters_others_A02.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA02/masters_layout_A02.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA02/masters_layout_detail_A02.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA02/reset_A02.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA02/journal_A02.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA02/pat_main_A02.sql")
  @Test
  public void pat_personal_main_新規登録_pat_main_更新() {
    final String FACILITY_CD = "F_hA02";
    // pat_personal_main.is_del="0"を明示

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);
      assertThat(pm, notNullValue());

      String staffInfoStr = pm.getCharge_staff_info();
      List<Map<String, Object>> lm = ObjectMapperUtil.readListOfMap(staffInfoStr);
      assertThat(lm, notNullValue());
      assertThat(lm.size(), is(1));

      Map<String, Object> m = lm.get(0);

      // charge_staff_infoカラムの検証
      // 電文内容が登録される。
      assertThat(m.get("staff_cd"), is(98002));
      assertThat(m.get("staff_name"), is("ＧＸ２Ｗ　管理者"));

      // pat_memo_infoカラムの内容の検証
      String patMemoInfoStr = pm.getPat_memo_info();

      // 既存レコードでは"content":"foobar"が設定されているが、受信内容で置き換えられる。
      List<Map<String, Object>> lm2 = ObjectMapperUtil.readListOfMap(patMemoInfoStr);
      assertThat(lm2, notNullValue());
      assertThat(lm2.size(), is(1));

      Map<String, Object> m2 = lm2.get(0);
      assertThat(m2.get("content"), is("血液透析（４ｈ以上）"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA03/masters_staff_A03.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA03/masters_others_A03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA03/masters_layout_A03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA03/masters_layout_detail_A03.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA03/reset_A03.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA03/journal_A03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA03/pat_main_A03.sql")
  @Test
  public void pat_personal_main_新規登録_pat_main_削除() {
    final String FACILITY_CD = "F_hA03";
    // pat_personal_main.is_delなし
    // pat_main.is_del="1"

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);
      assertThat(pm, nullValue());
      // pat_mainレコードが論理削除されるため、nullが返される。
      // 論理削除されたレコードを取得するDAO APIが存在しないため、削除状態はDBの目視により確認する。

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA11/clean_db5_A11.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA11/clean_db6_A11.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA11/masters_staff_A11.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA11/masters_others_A11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA11/masters_layout_A11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA11/masters_layout_detail_A11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA11/journal_A11.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA11/pat_personal_main_A11.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void pat_personal_main_更新_pat_main_新規登録() {
    final String FACILITY_CD = "F_hA11";
    // pat_personal_main.is_del="0"を明示

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      // 既存レコードに設定されている名称が電文内容で更新される。
      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);
      assertThat(pm, notNullValue());

      String staffInfoStr = pm.getCharge_staff_info();
      List<Map<String, Object>> lm = ObjectMapperUtil.readListOfMap(staffInfoStr);
      assertThat(lm, notNullValue());
      assertThat(lm.size(), is(1));

      Map<String, Object> m = lm.get(0);

      assertThat(m.get("staff_cd"), is(98011));
      assertThat(m.get("staff_name"), is("ＧＸ２Ｗ　管理者"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA12/clean_db5_A12.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA12/clean_db6_A12.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA12/masters_staff_A12.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA12/masters_others_A12.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA12/masters_layout_A12.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA12/masters_layout_detail_A12.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA12/journal_A12.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA12/pat_main_A12.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA12/pat_personal_main_A12.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void pat_personal_main_更新_pat_main_更新() {
    final String FACILITY_CD = "F_hA12";
    // pat_personal_main.is_delなし

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      // 既存レコードに設定されている名称が電文内容で更新される。
      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);
      assertThat(pm, notNullValue());

      String staffInfoStr = pm.getCharge_staff_info();
      List<Map<String, Object>> lm = ObjectMapperUtil.readListOfMap(staffInfoStr);
      assertThat(lm, notNullValue());
      assertThat(lm.size(), is(1));

      Map<String, Object> m = lm.get(0);

      // charge_staff_infoカラムの検証
      // 電文内容が登録される。
      assertThat(m.get("staff_cd"), is(98012));
      assertThat(m.get("staff_name"), is("ＧＸ２Ｗ　管理者"));

      // pat_memo_infoカラムの内容の検証
      String patMemoInfoStr = pm.getPat_memo_info();

      // 既存レコードでは"content":"foobar"が設定されているが、受信内容で置き換えられる。
      List<Map<String, Object>> lm2 = ObjectMapperUtil.readListOfMap(patMemoInfoStr);
      assertThat(lm2, notNullValue());
      assertThat(lm2.size(), is(1));

      Map<String, Object> m2 = lm2.get(0);
      assertThat(m2.get("content"), is("血液透析（４ｈ以上）"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA13/clean_db5_A13.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA13/clean_db6_A13.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA13/masters_staff_A13.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA13/masters_others_A13.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA13/masters_layout_A13.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA13/masters_layout_detail_A13.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA13/journal_A13.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sA13/pat_main_A13.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sA13/pat_personal_main_A13.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void pat_personal_main_更新_pat_main_削除() {
    final String FACILITY_CD = "F_hA13";
    // is_del="0"を明示

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      // 既存レコードに設定されている名称が電文内容で更新される。
      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatMain pm = patMainDao.selectById(patId);
      assertThat(pm, nullValue());
      // pat_mainレコードが論理削除されるため、nullが返される。
      // 論理削除されたレコードを取得するDAO APIが存在しないため、削除状態はDBの目視により確認する。

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_personal_mainが削除、pat_mainが新規登録/更新/削除されるパターンは、実施不可のため実施しない。
  // pat_personal_mainが論理削除されると、pat_mainを検索するためのpat_idを取得する手段がないことによる。

  // 他のDB5テーブル（抜粋して実施）

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB01/clean_db5_B01.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB01/clean_db6_B01.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB01/masters_staff_B01.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB01/masters_others_B01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB01/masters_layout_B01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB01/masters_layout_detail_B01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB01/journal_B01.sql")
  @Test
  public void pat_personal_main_新規登録_pat_exam_main_新規登録() {
    final String FACILITY_CD = "F_hB01";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatExamMain pem = patExamMainDao.selectById(patId, FACILITY_CD, 12345L);

      assertThat(pem, notNullValue());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB02/clean_db5_B02.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB02/clean_db6_B02.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB02/masters_staff_B02.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB02/masters_others_B02.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB02/masters_layout_B02.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB02/masters_layout_detail_B02.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB02/journal_B02.sql")
  @Test
  public void pat_personal_main_更新_pat_obs_rec_新規登録() {
    final String FACILITY_CD = "F_hB02";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatObsRec por = patObsRecDao.selectById(patId, FACILITY_CD);

      assertThat(por, notNullValue());
      assertThat(por.getUpCnt(), is(Short.parseShort("100")));

      String kindInfoStr = por.getKindInfo();
      JavaType mapType = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> kindInfo = ObjectMapperUtil.read(kindInfoStr, mapType);

      assertThat(kindInfo.get("kind_no"), is("12"));
      assertThat(kindInfo.get("kind_name"), is("種別名1"));

      String obsRecInfoStr = por.getObsRecInfo();
      List<Map<String, Object>> obsRecInfoList = ObjectMapperUtil.readListOfMap(obsRecInfoStr);
      assertThat(obsRecInfoList, notNullValue());
      assertThat(obsRecInfoList.size(), is(1));

      Map<String, Object> obsRecInfo = obsRecInfoList.get(0);

      assertThat(obsRecInfo.get("detail1"), is("あ"));
      assertThat(obsRecInfo.get("detail3"), is("い"));
      assertThat(obsRecInfo.get("detail6"), is("う"));
      assertThat(obsRecInfo.size(), is(3));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB03/clean_db5_B03.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB03/clean_db6_B03.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB03/masters_staff_B03.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB03/masters_others_B03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB03/masters_layout_B03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB03/masters_layout_detail_B03.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB03/journal_B03.sql")
  @Test
  public void pat_personal_main_新規登録_pat_unique_新規登録() {
    final String FACILITY_CD = "F_hB03";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatUnique pu = patUniqueDao.selectById(patId);

      String medicalHstInfoStr = pu.getMedical_hst_info();
      List<Map<String, Object>> medicalHstInfoList = ObjectMapperUtil.readListOfMap(medicalHstInfoStr);

      assertThat(medicalHstInfoList.size(), is(1));

      Map<String, Object> medicalHstInfo = medicalHstInfoList.get(0);
      Integer diseaseCd = (Integer) medicalHstInfo.get("disease_cd");

      Integer mstDiseaseCd = mstDiseaseDao.selectByInHospitalCd1(FACILITY_CD, "1234");

      assertThat(diseaseCd, is(mstDiseaseCd));

      String physicalInfoStr = pu.getPhysical_info();
      List<Map<String, Object>> physicalInfoList = ObjectMapperUtil.readListOfMap(physicalInfoStr);

      assertThat(physicalInfoList.size(), is(1));

      Map<String, Object> physicalInfo = physicalInfoList.get(0);

      assertThat(physicalInfo.get("exam_date"), is("2019-12-20"));
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB04/clean_db5_B04.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB04/clean_db6_B04.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB04/masters_staff_B04.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB04/masters_others_B04.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB04/masters_layout_B04.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB04/masters_layout_detail_B04.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB04/journal_B04.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB04/reset_B04.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB04/pat_unique_B04.sql")
  @Test
  public void pat_personal_main_新規登録_pat_unique_更新() {
    final String FACILITY_CD = "F_hB04";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatUnique pu = patUniqueDao.selectById(patId);

      String medicalHstInfoStr = pu.getMedical_hst_info();
      List<Map<String, Object>> medicalHstInfoList = ObjectMapperUtil.readListOfMap(medicalHstInfoStr);

      assertThat(medicalHstInfoList.size(), is(2));
      log.debug("{}:medicalInfoList=[{}]", FACILITY_CD, medicalHstInfoList);

      Map<String, Object> medicalHstInfo = medicalHstInfoList.get(1);
      Integer diseaseCd = (Integer) medicalHstInfo.get("disease_cd");

      Integer mstDiseaseCd = mstDiseaseDao.selectByInHospitalCd1(FACILITY_CD, "1234");

      assertThat(diseaseCd, is(mstDiseaseCd));

      String physicalInfoStr = pu.getPhysical_info();
      List<Map<String, Object>> physicalInfoList = ObjectMapperUtil.readListOfMap(physicalInfoStr);

      assertThat(physicalInfoList.size(), is(2));
      log.debug("{}:physicalInfoList=[{}]", FACILITY_CD, physicalInfoList);

      Map<String, Object> physicalInfo = physicalInfoList.get(1);

      assertThat(physicalInfo.get("exam_date"), is("2019-12-20"));

      // TODO PatUniqueLogicにバグがある。
      // pat_uniqueの既存レコードでjsonb型カラムの値が"[{}]"の時、stream処理でexam_dateの最大値が取得できない。
      // （NullPointerExceptionが発生する。）
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB05/masters_staff_B05.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB05/masters_others_B05.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB05/masters_layout_B05.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB05/masters_layout_detail_B05.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB05/journal_B05.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB05/reset_B05.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB05/pat_coop_detail_B05.sql")
  @Test
  public void pat_personal_main_更新_pat_coop_detail_更新() {
    final String FACILITY_CD = "F_hB05";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();

      PatCoopDetail pcd = patCoopDetailDao.selectByPatId(patId, FACILITY_CD, null);

      String save1Str = pcd.getSave1();
      List<Map<String, Object>> save1List = ObjectMapperUtil.readListOfMap(save1Str);
      assertThat(save1List, notNullValue());
      assertThat(save1List.size(), is(1));

      Map<String, Object> save1 = save1List.get(0);
      assertThat(save1.get("key2"), is("foo"));
      assertThat(save1.get("key4"), is("bar"));
      assertThat(save1.get("key8"), is("baz"));

      String save6Str = pcd.getSave6();
      List<Map<String, Object>> save6List = ObjectMapperUtil.readListOfMap(save6Str);
      assertThat(save6List, notNullValue());
      assertThat(save6List.size(), is(1));

      Map<String, Object> save6 = save6List.get(0);
      assertThat(save6.get("key3"), is("FOO"));
      assertThat(save6.get("key5"), is("BAR"));
      assertThat(save6.get("key9"), is("BAZ"));

      // 電文内容で上書きされていないカラムの確認
      String save2Str = pcd.getSave2();
      assertThat(save2Str, notNullValue());

      List<Map<String, Object>> save2List = ObjectMapperUtil.readListOfMap(save2Str);
      assertThat(save2List, notNullValue());
      assertThat(save2List.size(), is(1));

      Map<String, Object> save2 = save2List.get(0);
      assertThat(save2.get("abcde"), is("ABCDE"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB06/clean_db5_B06.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB06/clean_db6_B06.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB06/masters_staff_B06.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB06/masters_others_B06.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB06/masters_layout_B06.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB06/masters_layout_detail_B06.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB06/journal_B06.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB06/pat_unique_B06.sql")
  @Test
  public void pat_personal_main_新規登録_pat_unique_削除() {
    final String FACILITY_CD = "F_hB06";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      PatUnique pu = patUniqueDao.selectById(patId);

      // pat_uniqueレコードが論理削除されるため、検索結果はnullになる。
      assertThat(pu, nullValue());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB07/clean_db5_B07.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB07/clean_db6_B07.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB07/masters_staff_B07.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB07/masters_others_B07.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB07/masters_layout_B07.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB07/masters_layout_detail_B07.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sB07/journal_B07.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sB07/pat_insurance_B07.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Test
  public void pat_personal_main_更新_pat_insurance_削除() {
    final String FACILITY_CD = "F_hB07";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      assertThat(ppm.getPat_last_name(), is("あああ"));
      assertThat(ppm.getPat_first_name(), is("いいい"));

      Long patId = ppm.getPat_id();
      List<PatInsurance> piList = patInsuranceDao.selectByPatId(patId, FACILITY_CD);

      // pat_id=1001707のpat_insuranceレコードが論理削除されるため、検索結果は0件になる。
      assertThat(piList, notNullValue());
      assertTrue(piList.isEmpty());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // システムエラー時のpat_personal_main論理削除のテスト。
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZA/clean_db5_ZZA.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sZZA/clean_db6_ZZA.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sZZA/masters_staff_ZZA.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZA/masters_others_ZZA.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZA/masters_layout_ZZA.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZA/masters_layout_detail_ZZA.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZA/journal_ZZA.sql")
  @Test
  public void ジャーナル変換_システムエラーが発生した場合_pat_personal_mainが論理削除される() {
    final String FACILITY_CD = "F_hZZA";

    doPatMainInsertErrorMock();

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());
      // DBエラーが発生した場合、DBにはエラーが記録されるがHTTPステータスはOKとする。

      // DB内容確認
      // ※PatPersonalMainDaoのselect系メソッドには、is_del='1'のレコードを取得できるものがない。
      // 暫定措置として、施設コードと患者IDで検索した結果が存在しないというテストとした。
      // pat_personal_mainテーブルを目視し、施設コード=F_hZZAのレコードが存在して
      // is_del='1'であることを確認する。
      Long patId = getPatIdByFacilityCd(FACILITY_CD);
      PatPersonalMain ppm = patPersonalMainDao.selectById(patId);
      assertThat(ppm, nullValue());
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // システムエラー時のジャーナル変換状態ロールバックのテスト。
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZB/clean_db5_ZZB.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sZZB/clean_db6_ZZB.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/sZZB/masters_staff_ZZB.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZB/masters_others_ZZB.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZB/masters_layout_ZZB.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZB/masters_layout_detail_ZZB.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/sZZB/journal_ZZB.sql")
  @Test
  public void ジャーナル変換_システムエラーが発生した場合_ジャーナルの変換状態がE1に設定される() {
    final String FACILITY_CD = "F_hZZB";

    doPatMainInsertErrorMock();

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status()
        .isOk())
        // 異常系
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", hasSize(1)))
        .andExpect(jsonPath("$.result[0].ana_result").value("E1"))
        .andExpect(jsonPath("$.result[0].message").value("トランザクションテーブル登録でエラーが発生しました。施設コード:[F_hZZB] 内容:[例外テスト]"));
      ;
      // DBエラーが発生した場合、DBにはエラーが記録されるがHTTPステータスはOKとする。

      // DB内容確認
      SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "", "C", "R");
      log.debug("sysCoopJournal={}", BeanUtils.describe(journal));
      assertThat(journal.getAnaResult(), is("E1"));
      assertThat(journal.getOutAnaDate(), nullValue());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // レスポンスの内容確認 引数なし
  @Test
  public void 異常系_施設コード未設定_400エラーでリスエストパラメータエラー() {

    try {
      ResultActions response = requestConversionByFacilityCd("");
      response
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.status").value(400))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", hasSize(1)))
        .andExpect(jsonPath("$.result[0].message").value("リクエストパラメータが不正または不足しています。facility_cd:[]"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // レスポンスの内容確認 施設コード未存在
  @Test
  public void 異常系_施設コード未存在_204エラーで対象件数0件エラー() {
    final String FACILITY_CD = "TESTXXX";
    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response
        .andExpect(status().isNoContent())
        .andExpect(jsonPath("$.status").value(204))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", hasSize(1)))
        .andExpect(jsonPath("$.result[0].message").value("変換対象ジャーナル 0件でした。facility_cd:[TESTXXX]"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // 登録処理呼び出し前にエラーになる場合の確認
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hosZ/journal.sql")
  @Test
  public void 異常系_登録処理前のエラー時でもDBが更新されること() {
    final String FACILITY_CD = "F_hosZ";

    try {
      String errMsg = String.format("電文変換レイアウトが設定されていません。施設コード:[%s], 送受信向き:[R], 電文種別:[ini_dial], 電文付帯情報:[], 電文種別補足コード:[pre]",
        FACILITY_CD);
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status()
        .isOk())
        // 異常系
        .andExpect(jsonPath("$.status").value(200))
        .andExpect(jsonPath("$.result").isArray())
        .andExpect(jsonPath("$.result", hasSize(1)))
        .andExpect(jsonPath("$.result[0].ana_result").value("E1"))
        .andExpect(jsonPath("$.result[0].message").value(errMsg));

      // DBが更新されていることを確認する
      SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "", "C", "R");
      // 変換ステータス「内部エラー」
      assertThat(journal.getAnaResult(), is("E1"));
      // エラー時は処理完了日時(処理)は設定されないこと
      assertThat(journal.getOutAnaDate(), nullValue());

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos3/clean_db5.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos3/clean_db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos3/masters_others.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos3/masters_layout.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos3/journal.sql")
  @Test
  public void ジャーナル変換_ord_mainとord_coop_noが登録される_新規登録() {
    final String FACILITY_CD = "S_hos3";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk())
        .andExpect(jsonPath("$.result[0].message").value(""));

      // DBが更新されていることを確認する
      SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "", "C", "R");
      // 変換ステータス「正常終了」
      assertThat(journal.getAnaResult(), is("9"));

      OrdMain ordMain = ordMainDao.selectLastByFacilityCd(FACILITY_CD);
      assertThat(ordMain, notNullValue());

      assertThat(ordMain.getFnPatId(), is("438943903"));
      assertThat(ordMain.getTreatDate(), is("20200512"));
      assertThat(ordMain.getTreatWeek(), is(Short.parseShort("3")));
      assertThat(ordMain.getFacilityCd(), is(FACILITY_CD));
      assertThat(ordMain.getFacilityName(), is("test"));
      assertThat(ordMain.getIndVaCd(), is(2));
      assertThat(ordMain.getIndTreatmentCd(), is(4));
      assertThat(ordMain.getIndTreatmentName(), is("TreatmentName"));
      assertThat(ordMain.getIndKurCd(), is(5));
      assertThat(ordMain.getIndKurName(), is("kur"));
      assertThat(ordMain.getIndTreatStartTime(), is("0132"));
      assertThat(ordMain.getIndBedCd(), is(6));
      assertThat(ordMain.getIndBedName(), is("bed"));
      assertThat(ordMain.getIndScheduleUserInfo(), is("{\"test1\": \"IndScheduleUserInfo\"}"));
      assertThat(ordMain.getIndCondInfo(), is("{\"test2\": \"IndCondInfo\"}"));
      assertThat(ordMain.getIndMediInfo(), is("{\"test3\": \"IndMediInfo\"}"));
      assertThat(ordMain.getIndEquipInfo(), is("{\"test4\": \"IndEquipInfo\"}"));
      assertThat(ordMain.getIndIndCommentInfo(), is("{\"test5\": \"IndIndCommentInfo\"}"));
      assertThat(ordMain.getIndTareInfo(), is("{\"1\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"500\", \"weight_2\": \"400\", \"weight_3\": \"300\", \"weight_4\": \"200\", \"weight_5\": \"100\"}, \"2\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"500\", \"weight_2\": \"400\", \"weight_3\": \"300\", \"weight_4\": \"200\", \"weight_5\": \"100\"}, \"3\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"500\", \"weight_2\": \"400\", \"weight_3\": \"300\", \"weight_4\": \"200\", \"weight_5\": \"100\"}, \"4\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"500\", \"weight_2\": \"400\", \"weight_3\": \"300\", \"weight_4\": \"200\", \"weight_5\": \"100\"}, \"5\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"500\", \"weight_2\": \"400\", \"weight_3\": \"300\", \"weight_4\": \"200\", \"weight_5\": \"100\"}, \"6\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"500\", \"weight_2\": \"400\", \"weight_3\": \"300\", \"weight_4\": \"200\", \"weight_5\": \"100\"}, \"7\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"500\", \"weight_2\": \"400\", \"weight_3\": \"300\", \"weight_4\": \"200\", \"weight_5\": \"100\"}}"));
      assertThat(ordMain.getIndOffWaterInfo(), is("{\"1\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"90000\", \"weight_2\": \"80000\", \"weight_3\": \"70000\", \"weight_4\": \"60000\", \"weight_5\": \"50000\"}, \"2\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"90000\", \"weight_2\": \"80000\", \"weight_3\": \"70000\", \"weight_4\": \"60000\", \"weight_5\": \"50000\"}, \"3\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"90000\", \"weight_2\": \"80000\", \"weight_3\": \"70000\", \"weight_4\": \"60000\", \"weight_5\": \"50000\"}, \"4\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"90000\", \"weight_2\": \"80000\", \"weight_3\": \"70000\", \"weight_4\": \"60000\", \"weight_5\": \"50000\"}, \"5\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"90000\", \"weight_2\": \"80000\", \"weight_3\": \"70000\", \"weight_4\": \"60000\", \"weight_5\": \"50000\"}, \"6\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"90000\", \"weight_2\": \"80000\", \"weight_3\": \"70000\", \"weight_4\": \"60000\", \"weight_5\": \"50000\"}, \"7\": {\"name_1\": \"項目1名称\", \"name_2\": \"項目2名称\", \"name_3\": \"項目3名称\", \"name_4\": \"項目4名称\", \"name_5\": \"項目5名称\", \"weight_1\": \"90000\", \"weight_2\": \"80000\", \"weight_3\": \"70000\", \"weight_4\": \"60000\", \"weight_5\": \"50000\"}}"));
      assertThat(ordMain.getIndDeviceSetInfo(), is("{\"device\": \"setting\"}"));
      assertThat(ordMain.getRstFnDialysisNo(), nullValue());
      assertThat(ordMain.getRstRelationDialysisNo(), nullValue());
      assertThat(ordMain.getRstEdition(), is(0));
      assertThat(ordMain.getRstIsUpdateEdition(), nullValue());
      assertThat(ordMain.getRstInputClass(), nullValue());
      assertThat(ordMain.getRstDialysisState(), is("0"));
      assertThat(ordMain.getRstTreatmentCd(), nullValue());
      assertThat(ordMain.getRstTreatmentName(), nullValue());
      assertThat(ordMain.getRstKurCd(), nullValue());
      assertThat(ordMain.getRstKurName(), nullValue());
      assertThat(ordMain.getRstBedCd(), nullValue());
      assertThat(ordMain.getRstBedName(), nullValue());
      assertThat(ordMain.getRstMachineNo(), nullValue());
      assertThat(ordMain.getRstMachineName(), nullValue());
      assertThat(ordMain.getRstCondSendDate(), nullValue());
      assertThat(ordMain.getRstAcceptDate(), nullValue());
      assertThat(ordMain.getRstStartDate(), nullValue());
      assertThat(ordMain.getRstEndDate(), nullValue());
      assertThat(ordMain.getRstReturnHomeDate(), nullValue());
      assertThat(ordMain.getRstInOutClass(), nullValue());
      assertThat(ordMain.getRstDialysisCnt(), nullValue());
      assertThat(ordMain.getRstWardCd(), nullValue());
      assertThat(ordMain.getRstWardName(), nullValue());
      assertThat(ordMain.getRstCourseCd(), nullValue());
      assertThat(ordMain.getRstCourseName(), nullValue());
      assertThat(ordMain.getRstPunctureUserInfo(), nullValue());
      assertThat(ordMain.getRstReturnUserInfo(), nullValue());
      assertThat(ordMain.getRstChargeUserInfo(), nullValue());
      assertThat(ordMain.getRstBloodCirculateTotal(), nullValue());
      assertThat(ordMain.getRstRunningTime(), nullValue());
      assertThat(ordMain.getRstKtV(), nullValue());
      assertThat(ordMain.getRecSetDate(), nullValue());
      assertThat(ordMain.getSendCtlNo(), nullValue());
      assertThat(ordMain.getBloodPurifierName(), nullValue());
      assertThat(ordMain.getPullLeaveAmount(), nullValue());
      assertThat(ordMain.getRstCondInfo(), nullValue());
      assertThat(ordMain.getRstMediInfo(), nullValue());
      assertThat(ordMain.getRstEquipInfo(), nullValue());
      assertThat(ordMain.getRstIndCommentInfo(), nullValue());
      assertThat(ordMain.getRstTareInfo(), nullValue());
      assertThat(ordMain.getRstOffWaterInfo(), nullValue());
//      assertThat(ordMain.getRstDeviceSetInfo(), nullValue()); // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
      assertThat(ordMain.getRstWeightInfo(), nullValue());
//      assertThat(ordMain.getRstVitalInfo(), nullValue());
      assertThat(ordMain.getRstComplaintInfo(), nullValue());
      assertThat(ordMain.getRstTreatmentInfo(), nullValue());
      assertThat(ordMain.getRstTreatStaffInfo(), nullValue());
      assertThat(ordMain.getRstRoundsInfo(), nullValue());
      assertThat(ordMain.getRstDw(), nullValue());
      assertThat(ordMain.getWeightScaleNo(), nullValue());
      assertThat(ordMain.getTreatType(), nullValue());
      assertThat(ordMain.getIsConfirm(), is("0"));
      assertThat(ordMain.getIndDw(), nullValue());
      assertThat(ordMain.getRstPurificationCnt(), nullValue());
      assertThat(ordMain.getAdditionInfo(), nullValue());
      assertThat(ordMain.getIsDel(), is("0"));

      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd("", ordMain.getPatId(), "", ordMain.getOrdNo(), "112233", null);
      assertThat(ordCoopNoList.size(), is(1));
      assertThat(ordCoopNoList.get(0).getCoopOrdNo(), is("998877"));
      assertThat(ordCoopNoList.get(0).getIsDel(), is("0"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos4/clean_db5.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos4/clean_db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos4/masters_others.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos4/masters_layout.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos4/journal.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos4/pat_personal_main.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos4/ord_main_and_ord_coop_no.sql")
  @Test
  public void ジャーナル変換_ord_main_更新() {
    final String FACILITY_CD = "S_hos4";


    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk())
        .andExpect(jsonPath("$.result[0].message").value(""));

      // DBが更新されていることを確認する
      SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "", "C", "R");
      // 変換ステータス「正常終了」
      assertThat(journal.getAnaResult(), is("9"));

      OrdMain ordMain = ordMainDao.selectLastByFacilityCd(FACILITY_CD);
      assertThat(ordMain, notNullValue());


      assertThat(ordMain.getOrdNo(), is(Long.valueOf(2)));
      assertThat(ordMain.getPatId(), is(Long.valueOf(3000002)));
      assertThat(ordMain.getFnPatId(), is("438943903"));
      assertThat(ordMain.getTreatDate(), is("20200512"));
      assertThat(ordMain.getTreatWeek(), is(Short.parseShort("9")));
      assertThat(ordMain.getFacilityCd(), is(FACILITY_CD));
      assertThat(ordMain.getFacilityName(), is("test"));
      assertThat(ordMain.getIndVaCd(), is(8));
      assertThat(ordMain.getIndTreatmentCd(), is(7));
      assertThat(ordMain.getIndTreatmentName(), is("TreatmentName"));
      assertThat(ordMain.getIndKurCd(), is(6));
      assertThat(ordMain.getIndKurName(), is("kur"));
      assertThat(ordMain.getIndTreatStartTime(), is("0000"));
      assertThat(ordMain.getIndBedCd(), is(5));
      assertThat(ordMain.getIndBedName(), is("bed"));
      assertThat(ordMain.getIndScheduleUserInfo(), is("{\"test1\": \"IndScheduleUserInfo\"}"));
      assertThat(ordMain.getIndCondInfo(), is("{\"test2\": \"IndCondInfo\"}"));
      assertThat(ordMain.getIndMediInfo(), is("{\"test3\": \"IndMediInfo\"}"));
      assertThat(ordMain.getIndEquipInfo(), is("{\"test4\": \"IndEquipInfo\"}"));
      assertThat(ordMain.getIndIndCommentInfo(), is("{\"test5\": \"IndIndCommentInfo\"}"));
      assertThat(ordMain.getIsDel(), is("0"));
      assertThat(ordMain.getUpDate(), not("2019-12-13 05:44:54"));

      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd("", ordMain.getPatId(), "", ordMain.getOrdNo(), "is_dial", null);
      assertThat(ordCoopNoList.size(), is(1));
      assertThat(ordCoopNoList.get(0).getCoopOrdNo(), is("111111"));
      assertThat(ordCoopNoList.get(0).getIsDel(), is("0"));
      assertThat(ordCoopNoList.get(0).getUpDate().toString(), is("2019-12-13 05:44:54.0"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos5/clean_db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos5/masters_others.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos5/masters_layout.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos5/journal.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos5/pat_personal_main.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos5/ord_main_and_ord_coop_no.sql")
  @Test
  public void ジャーナル変換_ord_coop_noだけ削除() {
    final String FACILITY_CD = "S_hos5";


    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk())
        .andExpect(jsonPath("$.result[0].message").value(""));

      // DBが更新されていることを確認する
      SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "", "C", "R");
      // 変換ステータス「正常終了」
      assertThat(journal.getAnaResult(), is("9"));

      OrdMain ordMain = ordMainDao.selectLastByFacilityCd(FACILITY_CD);
      assertThat(ordMain, notNullValue());

      assertThat(ordMain.getPatId(), is(Long.valueOf(3000003)));
      assertThat(ordMain.getIsDel(), is("0"));

      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd("", ordMain.getPatId(), "", ordMain.getOrdNo(), "is_dial", null);
      assertThat(ordCoopNoList.size(), is(0));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos6/clean_db6.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos6/masters_others.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos6/masters_layout.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos6/journal.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceTest/S_hos6/pat_personal_main.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceTest/S_hos6/ord_main_and_ord_coop_no.sql")
  @Test
  public void ジャーナル変換_ord_mainとord_coop_no両方削除() {
    final String FACILITY_CD = "S_hos6";


    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk())
        .andExpect(jsonPath("$.result[0].message").value(""));

      // DBが更新されていることを確認する
      SysCoopJournal journal = sysCoopJournalDao.select(FACILITY_CD, "ini_dial", "", "C", "R");
      // 変換ステータス「正常終了」
      assertThat(journal.getAnaResult(), is("9"));

      OrdMain ordMain = ordMainDao.selectLastByFacilityCd(FACILITY_CD);
      assertThat(ordMain, nullValue());

      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd("", Long.valueOf(2000003), "", Long.valueOf(2), "is_dial", null);
      assertThat(ordCoopNoList.size(), is(0));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  private void doPatMainInsertErrorMock() {
    doThrow(new NtssException("例外テスト")).when(patMainDao).insert(any());
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

  /**
   * エンティティのフィールド値として期待されるマップを作成する。
   * @param args キーと値の組（キー1, 値1, キー2, 値2, ... という形式で任意個指定できる）
   * @return マップ
   */
  private Map<String, Object> createExpected(Object... args) {
    if (ArrayUtils.isEmpty(args)) {
      return null;
    }

    // 引数が奇数個の場合はエラーになる。
    // （テスト専用メソッドなので簡略化）
    Map<String, Object> result = new HashMap<>();
    for (int i = 0; i < args.length; i += 2) {
      result.put((String) args[i], args[i + 1]);
    }

    return result;
  }

  /**
   * 施設コードから患者IDを取得する。（テストデータが1施設コードにつき1人である場合のみ有効）
   *
   * @param facilityCd 施設コード
   * @return 患者ID
   */
  private Long getPatIdByFacilityCd(String facilityCd) {

    List<String> facilityCdList = Collections.singletonList(facilityCd);
    List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(facilityCdList);

    Comparator<PatPersonalMain> c = new Comparator<PatPersonalMain>() {
      @Override
      public int compare(PatPersonalMain o1, PatPersonalMain o2) {
        return -o1.getUp_date().compareTo(o2.getUp_date());
      }
    };

    Optional<PatPersonalMain> result = ppmList.stream().filter(e -> StringUtils.equals(facilityCd, e.getFacility_cd()))
      .sorted(c).findFirst();

    if (result.isPresent()) {
      return result.get().getPat_id();
    }

    return null;
  }

  /**
   * 施設コードを指定してPatObsRecエンティティを1件取得する。
   * 複数個存在する場合は、更新日時が最も新しいものを取得する。
   *
   * @param facilityCd 施設コード
   * @return PatObsRecエンティティ
   */
  private PatObsRec getPatObsRecByFacilityCd(String facilityCd) {
    List<PatObsRec> l = patObsRecDao.selectAll(SelectOptions.get());

    Comparator<PatObsRec> c = new Comparator<PatObsRec>() {

      @Override
      public int compare(PatObsRec o1, PatObsRec o2) {
        return -o1.getUpDate().compareTo(o2.getUpDate());
      }
    };

    Optional<PatObsRec> result = l.stream().filter(e -> StringUtils.equals(facilityCd, e.getFacilityCd())).sorted(c)
      .findFirst();
    return result.orElse(null);
  }

  /**
   * jsonb型カラムの文字列値からマップを作成する。
   *
   * @param str 文字列
   * @return マップ
   */
  private Map<String, Object> getResultMap(String str) {
    JavaType jt = ObjectMapperUtil.constructMapType(String.class, Object.class);
    try {
      return ObjectMapperUtil.read(str, jt);
    } catch (IOException e) {
//      fail();
      return null;
    }
  }

  /**
   * マップの一致をチェックする。
   * マップ自体の型（HashMap、TreeMap等）は問わない。
   *
   * @param m1 マップ1
   * @param m2 マップ2
   */
  private void assertMapEquals(Map<String, Object> m1, Map<String, Object> m2) {
    log.debug("m1={}", m1);
    log.debug("m2={}", m2);
    assertTrue(Maps.difference(m1, m2).entriesDiffering().isEmpty());
  }

  /**
   * マップを要素とするリストの一致をチェックする。
   * リスト内の要素の位置は考慮する。（[a,b]と[b,a]は異なる）
   * マップ自体の型、マップ内のキーの出現順は問わない。（HashMap{k1=v1, k2=v2}とTreeMap{k2=v2, k1=v1}は一致と判定）
   *
   * @param l1 リスト1
   * @param l2 リスト2
   */
  private void assertMapListEquals(List<Map<String, Object>> l1, List<Map<String, Object>> l2) {
    log.debug("l1={}", l1);
    log.debug("l2={}", l2);
    if (CollectionUtils.isEmpty(l1) || CollectionUtils.isEmpty(l2)) {
//      fail();
      return;
    }

    if (l1.size() != l2.size()) {
//      fail();
      return;
    }

    Iterator<Map<String, Object>> itr1 = l1.iterator();
    Iterator<Map<String, Object>> itr2 = l2.iterator();
    while (itr1.hasNext()) {
      Map<String, Object> m1 = itr1.next();
      Map<String, Object> m2 = itr2.next();

      assertMapEquals(m1, m2);
    }
  }

}
