package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Collections;
import java.util.List;
import java.util.Map;

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

import com.fasterxml.jackson.databind.JavaType;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertReceiveRequest;
import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.PatCoopDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatObsRecDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.PatCoopDetail;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatObsRec;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import lombok.extern.slf4j.Slf4j;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Slf4j
public class JournalConvertReceiveResourceJsonTest extends AbstractResourceTest {

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

  // JSON型カラムの内容の確認

  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC00/clean_db5_C00.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC00/clean_db6_C00.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC00/masters_staff_C00.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC00/masters_others_C00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC00/masters_layout_C00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC00/masters_layout_detail_C00.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC00/journal_C00.sql")
  @Test
  public void JSONカラム内容確認_pat_personal_main_新規登録_1件ずつ() {
    final String FACILITY_CD = "F_hC00";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      // dial_diff_com_info（透析困難情報）
      String dialDiffComInfoStr = ppm.getDial_diff_com_info();
      assertThat(dialDiffComInfoStr, notNullValue());

      List<Map<String, Object>> dialDiffComInfo = ObjectMapperUtil.readListOfMap(dialDiffComInfoStr);
      assertThat(dialDiffComInfo, notNullValue());
      assertThat(dialDiffComInfo.size(), is(1));

      Map<String, Object> d = dialDiffComInfo.get(0);
      log.debug("{}:dial_diff_com_info={}", FACILITY_CD, d);
      assertThat(d, notNullValue());
      assertThat(d.size(), is(5));
      // データ中で指定したエントリはctl_no、dial_diff_com_info、is_mainの3個だが、
      // マスタ照合で取得したdial_diff_cd、reg_dateが追加されるため5となる。
      // TODO dial_diff_com_infoはdial_diff_cdの誤り。最終的には4が正しい。

      assertThat(d.get("ctl_no"), is(1));
      assertThat(d.get("is_main"), is("1"));

      Integer dialDiffCd = (Integer) d.get("dial_diff_cd");

      Integer dialDiffCdMst = mstDialysisDifficultyDao.selectByInHospitalCd1(FACILITY_CD, "VAB004");
      assertThat(dialDiffCd, is(dialDiffCdMst));

      // pat_contact_info（本人連絡先情報）
      // このカラムには単一のマップが登録される。
      String patContactInfoStr = ppm.getPat_contact_info();
      assertThat(patContactInfoStr, notNullValue());

      JavaType mapType = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> patContactInfo = ObjectMapperUtil.read(patContactInfoStr, mapType);
      assertThat(patContactInfo, notNullValue());
      assertThat(patContactInfo.size(), is(10));

      assertThat(patContactInfo.get("zip_cd"), is("001-0001"));
      assertThat(patContactInfo.get("address"), is("東京都千代田区"));
      assertThat(patContactInfo.get("tel1"), is("03-0000-0000"));
      assertThat(patContactInfo.get("tel2"), is("03-1111-1111"));
      assertThat(patContactInfo.get("fax"), is("03-5555-5555"));
      assertThat(patContactInfo.get("email"), is("test@example.com"));
      assertThat(patContactInfo.get("work_name"), is("国防省"));
      assertThat(patContactInfo.get("work_tel"), is("03-9999-9999"));
      assertThat(patContactInfo.get("memo1"), is("メモその1"));
      assertThat(patContactInfo.get("memo2"), is("メモその2"));

      // other_contact_info（連絡先情報）
      String otherContactInfoStr = ppm.getOther_contact_info();
      assertThat(otherContactInfoStr, notNullValue());

      List<Map<String, Object>> otherContactInfoList = ObjectMapperUtil.readListOfMap(otherContactInfoStr);
      assertThat(otherContactInfoList, notNullValue());
      assertThat(otherContactInfoList.size(), is(1));

      Map<String, Object> otherContactInfo = otherContactInfoList.get(0);
      assertThat(otherContactInfo.size(), is(20));

      // ctl_no, disp_orderは電文中で明示されていても既存レコードから算出する。
      // そのため、電文中の3ではなく1が設定される。
      assertThat(otherContactInfo.get("ctl_no"), is("1"));
      assertThat(otherContactInfo.get("disp_order"), is("1"));

      assertThat(otherContactInfo.get("is_key_person"), is("0"));
      assertThat(otherContactInfo.get("pat_id"), is("132435"));
      assertThat(otherContactInfo.get("last_name"), is("へのへの"));
      assertThat(otherContactInfo.get("first_name"), is("もへじ"));
      assertThat(otherContactInfo.get("last_name_kana"), is("ﾍﾉﾍﾉ"));
      assertThat(otherContactInfo.get("first_name_kana"), is("ﾓﾍｼﾞ"));

      // relation_cdはmst_relationルックアップによって変換される。
      assertThat(otherContactInfo.get("relation_cd"), is("15"));

      assertThat(otherContactInfo.get("relation_name"), is("兄弟姉妹"));
      assertThat(otherContactInfo.get("zip_cd"), is("987-9876"));
      assertThat(otherContactInfo.get("address"), is("鹿児島県"));
      assertThat(otherContactInfo.get("tel1"), is("099-9876-4321"));
      assertThat(otherContactInfo.get("tel2"), is("099-8642-1357"));
      assertThat(otherContactInfo.get("fax"), is("099-7766-2211"));
      assertThat(otherContactInfo.get("e_mail"), is("test999@example.com"));
      assertThat(otherContactInfo.get("work_name"), is("第拾伍東京市農水省"));
      assertThat(otherContactInfo.get("work_tel"), is("099-9898-7676"));
      assertThat(otherContactInfo.get("memo1"), is("メモメモメモ1"));
      assertThat(otherContactInfo.get("memo2"), is("メモメモメモ2"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC01/clean_db5_C01.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC01/clean_db6_C01.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC01/masters_staff_C01.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC01/masters_others_C01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC01/masters_layout_C01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC01/masters_layout_detail_C01.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC01/journal_C01.sql")
  @Test
  public void JSONカラム内容確認_pat_personal_main_新規登録_5件ずつ() {
    final String FACILITY_CD = "F_hC01";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      // dial_diff_com_info（透析困難情報）
      String dialDiffComInfoStr = ppm.getDial_diff_com_info();
      assertThat(dialDiffComInfoStr, notNullValue());

      List<Map<String, Object>> dialDiffComInfoList = ObjectMapperUtil.readListOfMap(dialDiffComInfoStr);
      assertThat(dialDiffComInfoList, notNullValue());

      // 本シナリオでは透析困難情報が10件抽出されるが、dial_diff_cdがすべて一致する。
      // そのため、登録される透析困難情報は1件である。
      assertThat(dialDiffComInfoList.size(), is(1));

      Map<String, Object> dialDiffComInfo = dialDiffComInfoList.get(0);
      Integer dialDiffCdMst = mstDialysisDifficultyDao.selectByInHospitalCd1(FACILITY_CD, "VAB004");

      log.debug("{}:dial_diff_com_info={}", FACILITY_CD, dialDiffComInfo);
      assertThat(dialDiffComInfo, notNullValue());
      assertThat(dialDiffComInfo.size(), is(5));
      // データ中で指定したエントリはctl_no、dial_diff_com_info、is_mainの3個だが、
      // マスタ照合で取得したdial_diff_cd、reg_dateが追加されるため5となる。
      // TODO dial_diff_com_infoはdial_diff_cdの誤り。最終的には4が正しい。

      // ctl_noは採番された値となる。
      assertThat(dialDiffComInfo.get("ctl_no"), is(10));

      assertThat(dialDiffComInfo.get("is_main"), is("1"));

      Integer dialDiffCd = (Integer) dialDiffComInfo.get("dial_diff_cd");
      assertThat(dialDiffCd, is(dialDiffCdMst));

      // pat_contact_info（本人連絡先情報）
      // このカラムには単一のマップが登録される。
      // （マップ1個しか存在しない。）
      String patContactInfoStr = ppm.getPat_contact_info();
      assertThat(patContactInfoStr, notNullValue());

      JavaType mapType = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> patContactInfo = ObjectMapperUtil.read(patContactInfoStr, mapType);
      assertThat(patContactInfo, notNullValue());
      assertThat(patContactInfo.size(), is(10));

      assertThat(patContactInfo.get("zip_cd"), is("001-0001"));
      assertThat(patContactInfo.get("address"), is("東京都千代田区"));
      assertThat(patContactInfo.get("tel1"), is("03-0000-0000"));
      assertThat(patContactInfo.get("tel2"), is("03-1111-1111"));
      assertThat(patContactInfo.get("fax"), is("03-5555-5555"));
      assertThat(patContactInfo.get("email"), is("test@example.com"));
      assertThat(patContactInfo.get("work_name"), is("国防省"));
      assertThat(patContactInfo.get("work_tel"), is("03-9999-9999"));
      assertThat(patContactInfo.get("memo1"), is("メモその1"));
      assertThat(patContactInfo.get("memo2"), is("メモその2"));

      // other_contact_info（連絡先情報）
      String otherContactInfoStr = ppm.getOther_contact_info();
      assertThat(otherContactInfoStr, notNullValue());

      List<Map<String, Object>> otherContactInfoList = ObjectMapperUtil.readListOfMap(otherContactInfoStr);
      assertThat(otherContactInfoList, notNullValue());
      assertThat(otherContactInfoList.size(), is(10));

      for (int i = 0; i < 10; ++i) {
        Map<String, Object> otherContactInfo = otherContactInfoList.get(i);
        assertThat(otherContactInfo.size(), is(20));

        // ctl_no, disp_orderは電文中で明示されていても既存レコードから算出する。
        String is = String.valueOf(i + 1);
        assertThat(otherContactInfo.get("ctl_no"), is(is));
        assertThat(otherContactInfo.get("disp_order"), is(is));

        assertThat(otherContactInfo.get("is_key_person"), is("0"));
        assertThat(otherContactInfo.get("pat_id"), is("132435"));
        assertThat(otherContactInfo.get("last_name"), is("へのへの"));
        assertThat(otherContactInfo.get("first_name"), is("もへじ"));
        assertThat(otherContactInfo.get("last_name_kana"), is("ﾍﾉﾍﾉ"));
        assertThat(otherContactInfo.get("first_name_kana"), is("ﾓﾍｼﾞ"));

        // relation_cdはmst_relationルックアップによって変換される。
        assertThat(otherContactInfo.get("relation_cd"), is("25"));

        assertThat(otherContactInfo.get("relation_name"), is("兄弟姉妹"));
        assertThat(otherContactInfo.get("zip_cd"), is("987-9876"));
        assertThat(otherContactInfo.get("address"), is("鹿児島県"));
        assertThat(otherContactInfo.get("tel1"), is("099-9876-4321"));
        assertThat(otherContactInfo.get("tel2"), is("099-8642-1357"));
        assertThat(otherContactInfo.get("fax"), is("099-7766-2211"));
        assertThat(otherContactInfo.get("e_mail"), is("test999@example.com"));
        assertThat(otherContactInfo.get("work_name"), is("第拾伍東京市農水省"));
        assertThat(otherContactInfo.get("work_tel"), is("099-9898-7676"));
        assertThat(otherContactInfo.get("memo1"), is("メモメモメモ1"));
        assertThat(otherContactInfo.get("memo2"), is("メモメモメモ2"));
      }

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC10/clean_db5_C10.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC10/clean_db6_C10.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC10/masters_staff_C10.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC10/masters_others_C10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC10/masters_layout_C10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC10/masters_layout_detail_C10.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC10/journal_C10.sql")
  @Test
  public void JSONカラム内容確認_pat_main_新規登録_1件ずつ() {
    final String FACILITY_CD = "F_hC10";

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

      // pat_memo_info →複数個
      String patMemoInfoStr = pm.getPat_memo_info();
      assertThat(patMemoInfoStr, notNullValue());

      List<Map<String, Object>> patMemoInfoList = ObjectMapperUtil.readListOfMap(patMemoInfoStr);
      assertThat(patMemoInfoList, notNullValue());
      assertThat(patMemoInfoList.size(), is(1));

      Map<String, Object> patMemoInfo = patMemoInfoList.get(0);
      assertThat(patMemoInfo, notNullValue());
      assertThat(patMemoInfo.size(), is(2));

      // addition_info →非対応

      // charge_staff_info →複数個
      String chargeStaffInfoStr = pm.getCharge_staff_info();
      assertThat(chargeStaffInfoStr, notNullValue());

      List<Map<String, Object>> chargeStaffInfoList = ObjectMapperUtil.readListOfMap(chargeStaffInfoStr);
      assertThat(chargeStaffInfoList, notNullValue());
      assertThat(chargeStaffInfoList.size(), is(1));

      Map<String, Object> chargeStaffInfo = chargeStaffInfoList.get(0);
      assertThat(chargeStaffInfo.size(), is(6));

      // ctl_no、disp_orderは自動採番される。
      assertThat(chargeStaffInfo.get("ctl_no"), is(1));
      assertThat(chargeStaffInfo.get("disp_order"), is(1));

      // staff_cdはマスタルックアップ（mst_user_authentication）の結果で置き換えられる。
      assertThat(chargeStaffInfo.get("staff_cd"), is(92800));

      assertThat(chargeStaffInfo.get("is_main"), is("1"));
      assertThat(chargeStaffInfo.get("is_charge"), is("0"));
      assertThat(chargeStaffInfo.get("is_puncture"), is("1"));

      // pat_group_info →対象外

      // taboo_allergy_info →複数個
      String tabooAllergyInfoStr = pm.getTaboo_allergy_info();
      assertThat(tabooAllergyInfoStr, notNullValue());

      List<Map<String, Object>> tabooAllergyInfoList = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr);
      assertThat(tabooAllergyInfoList, notNullValue());
      assertThat(tabooAllergyInfoList.size(), is(1));

      Map<String, Object> tabooAllergyInfo = tabooAllergyInfoList.get(0);
      assertThat(tabooAllergyInfo.size(), is(7));

      // taboo_allergy_infoのctl_no、disp_orderには正規化仕様がない。
      assertThat(tabooAllergyInfo.get("ctl_no"), is("101"));
      assertThat(tabooAllergyInfo.get("disp_order"), is("102"));

      assertThat(tabooAllergyInfo.get("content"), is("アレルギー"));
      assertThat(tabooAllergyInfo.get("memo"), is("バラ科果実全般禁忌"));
      assertThat(tabooAllergyInfo.get("category_class"), is("0"));
      assertThat(tabooAllergyInfo.get("taboo_allergy_class"), is("1"));
      assertThat(tabooAllergyInfo.get("taboo_allergy_cd"), is(11800));

      // infect_info →複数個
      String infectInfoStr = pm.getInfect_info();
      assertThat(infectInfoStr, notNullValue());

      List<Map<String, Object>> infectInfoList = ObjectMapperUtil.readListOfMap(infectInfoStr);
      assertThat(infectInfoList, notNullValue());
      assertThat(infectInfoList.size(), is(1));

      Map<String, Object> infectInfo = infectInfoList.get(0);
      assertThat(infectInfo.size(), is(5));

      assertThat(infectInfo.get("ctl_no"), is("111"));
      assertThat(infectInfo.get("infection_cd"), is(1180));
      assertThat(infectInfo.get("infect"), is("1"));
      assertThat(infectInfo.get("exam_date"), is("2020-04-09"));
      assertThat(infectInfo.get("up_date"), is("2020-04-09"));

      // implant_info →複数個
      String implantInfoStr = pm.getImplant_info();
      assertThat(implantInfoStr, notNullValue());

      List<Map<String, Object>> implantInfoList = ObjectMapperUtil.readListOfMap(implantInfoStr);
      assertThat(implantInfoList, notNullValue());
      assertThat(implantInfoList.size(), is(1));

      Map<String, Object> implantInfo = implantInfoList.get(0);
      assertThat(implantInfo.size(), is(5));

      assertThat(implantInfo.get("ctl_no"), is("121"));
      assertThat(implantInfo.get("disp_order"), is("122"));
      assertThat(implantInfo.get("implant_cd"), is(118000));
      assertThat(implantInfo.get("reg_date"), is("2020-01-10"));
      assertThat(implantInfo.get("remove_date"), is("9999-12-31"));

      // tare_info, off_water_info, device_set_info →他シナリオで確認済

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC11/clean_db5_C11.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC11/clean_db6_C11.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC11/masters_staff_C11.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC11/masters_others_C11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC11/masters_layout_C11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC11/masters_layout_detail_C11.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC11/journal_C11.sql")
  @Test
  public void JSONカラム内容確認_pat_main_新規登録_3件ずつ() {
    final String FACILITY_CD = "F_hC11";

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

      // pat_memo_info →複数個
      String patMemoInfoStr = pm.getPat_memo_info();
      assertThat(patMemoInfoStr, notNullValue());

      List<Map<String, Object>> patMemoInfoList = ObjectMapperUtil.readListOfMap(patMemoInfoStr);
      assertThat(patMemoInfoList, notNullValue());
      assertThat(patMemoInfoList.size(), is(3));

      Map<String, Object> patMemoInfo = patMemoInfoList.get(0);
      assertThat(patMemoInfo, notNullValue());
      assertThat(patMemoInfo.size(), is(2));

      // addition_info →非対応

      // charge_staff_info →複数個
      String chargeStaffInfoStr = pm.getCharge_staff_info();
      assertThat(chargeStaffInfoStr, notNullValue());

      List<Map<String, Object>> chargeStaffInfoList = ObjectMapperUtil.readListOfMap(chargeStaffInfoStr);
      assertThat(chargeStaffInfoList, notNullValue());
      // 3件抽出したがすべてstaff_cdが同一のため1件となる。
      assertThat(chargeStaffInfoList.size(), is(1));

      Map<String, Object> chargeStaffInfo = chargeStaffInfoList.get(0);
      assertThat(chargeStaffInfo.size(), is(6));

      // ctl_no、disp_orderは自動採番される。
      assertThat(chargeStaffInfo.get("ctl_no"), is(1));
      assertThat(chargeStaffInfo.get("disp_order"), is(1));

      // staff_cdはマスタルックアップ（mst_user_authentication）の結果で置き換えられる。
      assertThat(chargeStaffInfo.get("staff_cd"), is(92801));

      assertThat(chargeStaffInfo.get("is_main"), is("1"));
      assertThat(chargeStaffInfo.get("is_charge"), is("0"));
      assertThat(chargeStaffInfo.get("is_puncture"), is("1"));

      // pat_group_info →対象外

      // taboo_allergy_info →複数個
      String tabooAllergyInfoStr = pm.getTaboo_allergy_info();
      assertThat(tabooAllergyInfoStr, notNullValue());

      List<Map<String, Object>> tabooAllergyInfoList = ObjectMapperUtil.readListOfMap(tabooAllergyInfoStr);
      assertThat(tabooAllergyInfoList, notNullValue());
      // 3件抽出したがすべてtaboo_allergy_cdが同一のため1件となる。
      assertThat(tabooAllergyInfoList.size(), is(1));

      Map<String, Object> tabooAllergyInfo = tabooAllergyInfoList.get(0);
      assertThat(tabooAllergyInfo.size(), is(7));

      // taboo_allergy_infoのctl_no、disp_orderには正規化仕様がない。
      assertThat(tabooAllergyInfo.get("ctl_no"), is("101"));
      assertThat(tabooAllergyInfo.get("disp_order"), is("102"));

      assertThat(tabooAllergyInfo.get("content"), is("アレルギー"));
      assertThat(tabooAllergyInfo.get("memo"), is("バラ科果実全般禁忌"));
      assertThat(tabooAllergyInfo.get("category_class"), is("0"));
      assertThat(tabooAllergyInfo.get("taboo_allergy_class"), is("1"));
      assertThat(tabooAllergyInfo.get("taboo_allergy_cd"), is(11801));

      // infect_info →複数個
      String infectInfoStr = pm.getInfect_info();
      assertThat(infectInfoStr, notNullValue());

      List<Map<String, Object>> infectInfoList = ObjectMapperUtil.readListOfMap(infectInfoStr);
      assertThat(infectInfoList, notNullValue());
      // 3件抽出したがすべてinfection_cdが同一のため1件となる。
      assertThat(infectInfoList.size(), is(1));

      Map<String, Object> infectInfo = infectInfoList.get(0);
      assertThat(infectInfo.size(), is(5));

      assertThat(infectInfo.get("ctl_no"), is("111"));
      assertThat(infectInfo.get("infection_cd"), is(1181));
      assertThat(infectInfo.get("infect"), is("1"));
      assertThat(infectInfo.get("exam_date"), is("2020-04-09"));
      assertThat(infectInfo.get("up_date"), is("2020-04-09"));

      // implant_info →複数個
      String implantInfoStr = pm.getImplant_info();
      assertThat(implantInfoStr, notNullValue());

      List<Map<String, Object>> implantInfoList = ObjectMapperUtil.readListOfMap(implantInfoStr);
      assertThat(implantInfoList, notNullValue());
      // 3件抽出したがすべてimplant_cdが同一のため1件となる。
      assertThat(implantInfoList.size(), is(1));

      Map<String, Object> implantInfo = implantInfoList.get(0);
      assertThat(implantInfo.size(), is(5));

      assertThat(implantInfo.get("ctl_no"), is("121"));
      assertThat(implantInfo.get("disp_order"), is("122"));
      assertThat(implantInfo.get("implant_cd"), is(118001));
      assertThat(implantInfo.get("reg_date"), is("2020-01-10"));
      assertThat(implantInfo.get("remove_date"), is("9999-12-31"));

      // tare_info, off_water_info, device_set_info →他シナリオで確認済

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_exam_main
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC20/clean_db5_C20.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC20/clean_db6_C20.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC20/masters_staff_C20.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC20/masters_others_C20.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC20/masters_layout_C20.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC20/masters_layout_detail_C20.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC20/journal_C20.sql")
  @Test
  public void JSONカラム内容確認_pat_exam_main_新規登録_1件ずつ() {
    final String FACILITY_CD = "F_hC20";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();

      List<Long> patIdList = Collections.singletonList(patId);
      List<PatExamMainData> patExamMainDataList = patExamMainDao.selectPatExamMainByPatIdList(patIdList, "0001/01/01");
      assertThat(patExamMainDataList, notNullValue());
      assertThat(patExamMainDataList.size(), is(1));

      PatExamMainData patExamMainData = patExamMainDataList.get(0);
      String examResultInfoStr = patExamMainData.getExamResultInfo();
      List<Map<String, Object>> examResultInfoList = ObjectMapperUtil.readListOfMap(examResultInfoStr);
      assertThat(examResultInfoList, notNullValue());
      assertThat(examResultInfoList.size(), is(1));

      Map<String, Object> examResultInfo = examResultInfoList.get(0);
      assertThat(examResultInfo.size(), is(13));

      assertThat(examResultInfo.get("disp_order"), is("100"));
      assertThat(examResultInfo.get("exam_item_cd"), is("11"));
      assertThat(examResultInfo.get("exam_result"), is("120"));
      assertThat(examResultInfo.get("exam_check"), is("N"));
      assertThat(examResultInfo.get("exam_comment"), is("001"));
      assertThat(examResultInfo.get("exam_free_comment"), is("正常"));

      // exam_result_dateは抽出した値によらずシステム日付を設定する。
      // UT実行日時により値が変わるため、型のみ検証する。
      Object examResultDateObj = examResultInfo.get("exam_result_date");
      assertTrue(examResultDateObj instanceof Long);

      assertThat(examResultInfo.get("exam_item_name"), is("最高血圧"));
      assertThat(examResultInfo.get("data_type"), is("01"));
      assertThat(examResultInfo.get("unit"), is("mmHg"));
      assertThat(examResultInfo.get("normal_value_upper"), is("140"));
      assertThat(examResultInfo.get("normal_value_lower"), is("80"));
      assertThat(examResultInfo.get("exam_class"), is("111"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC21/clean_db5_C21.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC21/clean_db6_C21.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC21/masters_staff_C21.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC21/masters_others_C21.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC21/masters_layout_C21.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC21/masters_layout_detail_C21.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC21/journal_C21.sql")
  @Test
  public void JSONカラム内容確認_pat_exam_main_新規登録_10件ずつ() {
    final String FACILITY_CD = "F_hC21";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();

      List<Long> patIdList = Collections.singletonList(patId);
      List<PatExamMainData> patExamMainDataList = patExamMainDao.selectPatExamMainByPatIdList(patIdList, "0001/01/01");
      assertThat(patExamMainDataList, notNullValue());
      assertThat(patExamMainDataList.size(), is(1));

      PatExamMainData patExamMainData = patExamMainDataList.get(0);
      String examResultInfoStr = patExamMainData.getExamResultInfo();
      List<Map<String, Object>> examResultInfoList = ObjectMapperUtil.readListOfMap(examResultInfoStr);
      assertThat(examResultInfoList, notNullValue());
      assertThat(examResultInfoList.size(), is(10));

      examResultInfoList.forEach(e -> {
        assertThat(e.size(), is(13));

        assertThat(e.get("disp_order"), is("100"));
        assertThat(e.get("exam_item_cd"), is("11"));
        assertThat(e.get("exam_result"), is("120"));
        assertThat(e.get("exam_check"), is("N"));
        assertThat(e.get("exam_comment"), is("001"));
        assertThat(e.get("exam_free_comment"), is("正常"));

        // exam_result_dateは抽出した値によらずシステム日付を設定する。
        // UT実行日時により値が変わるため、型のみ検証する。
        Object examResultDateObj = e.get("exam_result_date");
        assertTrue(examResultDateObj instanceof Long);

        assertThat(e.get("exam_item_name"), is("最高血圧"));
        assertThat(e.get("data_type"), is("01"));
        assertThat(e.get("unit"), is("mmHg"));
        assertThat(e.get("normal_value_upper"), is("140"));
        assertThat(e.get("normal_value_lower"), is("80"));
        assertThat(e.get("exam_class"), is("111"));
      });
    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_coop_detail
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC30/clean_db5_C30.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC30/clean_db6_C30.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC30/masters_staff_C30.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC30/masters_others_C30.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC30/masters_layout_C30.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC30/masters_layout_detail_C30.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC30/journal_C30.sql")
  @Test
  public void JSONカラム内容確認_pat_coop_detail_登録件数混合() {
    // pat_coop_detailの連携対象カラムsave_1～save_10はすべて均質であるため、
    // 1シナリオで登録件数を混在させる方法とした。
    final String FACILITY_CD = "F_hC30";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();

      PatCoopDetail pcd = patCoopDetailDao.selectByPatId(patId, FACILITY_CD, null);
      assertThat(pcd, notNullValue());

      String save1Str = pcd.getSave1();
      List<Map<String, Object>> save1List = ObjectMapperUtil.readListOfMap(save1Str);
      assertThat(save1List, notNullValue());
      assertThat(save1List.size(), is(1));
      Map<String, Object> save1 = save1List.get(0);
      assertThat(save1.get("key_1"), is("1"));

      String save2Str = pcd.getSave2();
      List<Map<String, Object>> save2List = ObjectMapperUtil.readListOfMap(save2Str);
      assertThat(save2List, notNullValue());
      assertThat(save2List.size(), is(1));
      Map<String, Object> save2 = save2List.get(0);
      assertThat(save2.get("key_1"), is("2"));

      String save3Str = pcd.getSave3();
      List<Map<String, Object>> save3List = ObjectMapperUtil.readListOfMap(save3Str);
      assertThat(save3List, notNullValue());
      assertThat(save3List.size(), is(2));
      save3List.forEach(e -> {
        assertThat(e.get("key_2"), is("3"));
      });

      String save8Str = pcd.getSave8();
      List<Map<String, Object>> save8List = ObjectMapperUtil.readListOfMap(save8Str);
      assertThat(save8List, notNullValue());
      assertThat(save8List.size(), is(3));
      save8List.forEach(e -> {
        assertThat(e.get("key_2"), is("8"));
      });

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_obs_rec
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC40/clean_db5_C40.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC40/clean_db6_C40.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC40/masters_staff_C40.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC40/masters_others_C40.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC40/masters_layout_C40.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC40/masters_layout_detail_C40.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC40/journal_C40.sql")
  @Test
  public void JSONカラム内容確認_pat_obs_rec_新規登録_1件ずつ() {
    final String FACILITY_CD = "F_hC40";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();

      PatObsRec por = patObsRecDao.selectById(patId, FACILITY_CD);
      assertThat(por, notNullValue());

      // kind_info
      // 複数件抽出しても先頭の1件を単一マップとして登録する。
      String kindInfoStr = por.getKindInfo();
      assertThat(kindInfoStr, notNullValue());
      JavaType mapType = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> kindInfo = ObjectMapperUtil.read(kindInfoStr, mapType);
      assertThat(kindInfo, notNullValue());
      assertThat(kindInfo.size(), is(3));

      // kind_noでマスタ照合（mst_obs_kind）する。
      // （ただし、照合が成功しても電文から抽出した値を設定する。）
      assertThat(kindInfo.get("kind_no"), is("40"));
      assertThat(kindInfo.get("kind_update"), is("2020-04-01"));
      assertThat(kindInfo.get("kind_name"), is("kubun1"));

      // reg_staff_info
      // kind_infoに同じ
      String regStaffInfoStr = por.getRegStaffInfo();
      assertThat(regStaffInfoStr, notNullValue());
      Map<String, Object> regStaffInfo = ObjectMapperUtil.read(regStaffInfoStr, mapType);
      assertThat(regStaffInfo, notNullValue());
      assertThat(regStaffInfo.size(), is(3));

      assertThat(regStaffInfo.get("reg_staff_cd"), is(94000));
      assertThat(regStaffInfo.get("reg_staff_update"), is("2020-04-10"));
      assertThat(regStaffInfo.get("reg_staff_name"), is("医師00"));

      // up_staff_info
      // kind_infoに同じ
      String upStaffInfoStr = por.getUpStaffInfo();
      assertThat(upStaffInfoStr, notNullValue());
      Map<String, Object> upStaffInfo = ObjectMapperUtil.read(upStaffInfoStr, mapType);
      assertThat(upStaffInfo, notNullValue());
      assertThat(upStaffInfo.size(), is(3));

      assertThat(upStaffInfo.get("up_staff_cd"), is(94010));
      assertThat(upStaffInfo.get("up_staff_update"), is("2020-04-10"));
      assertThat(upStaffInfo.get("up_staff_name"), is("放射線技師01"));

      // obs_rec_info
      // 他のテーブルのjsonb型カラムと同様、マップのリストが設定される。
      String obsRecInfoStr = por.getObsRecInfo();
      assertThat(obsRecInfoStr, notNullValue());

      List<Map<String, Object>> obsRecInfoList = ObjectMapperUtil.readListOfMap(obsRecInfoStr);
      assertThat(obsRecInfoList, notNullValue());
      assertThat(obsRecInfoList.size(), is(1));

      Map<String, Object> obsRecInfo = obsRecInfoList.get(0);

      assertThat(obsRecInfo.size(), is(4));
      assertThat(obsRecInfo.get("detail1"), is("S"));
      assertThat(obsRecInfo.get("detail2"), is("O"));
      assertThat(obsRecInfo.get("detail3"), is("A"));
      assertThat(obsRecInfo.get("detail4"), is("P"));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC41/clean_db5_C41.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC41/clean_db6_C41.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC41/masters_staff_C41.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC41/masters_others_C41.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC41/masters_layout_C41.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC41/masters_layout_detail_C41.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC41/journal_C41.sql")
  @Test
  public void JSONカラム内容確認_pat_obs_rec_新規登録_6件ずつ() {
    final String FACILITY_CD = "F_hC41";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();

      PatObsRec por = patObsRecDao.selectById(patId, FACILITY_CD);
      assertThat(por, notNullValue());

      // kind_info
      // 複数件抽出しても先頭の1件を単一マップとして登録する。
      String kindInfoStr = por.getKindInfo();
      assertThat(kindInfoStr, notNullValue());
      JavaType mapType = ObjectMapperUtil.constructMapType(String.class, Object.class);
      Map<String, Object> kindInfo = ObjectMapperUtil.read(kindInfoStr, mapType);
      assertThat(kindInfo, notNullValue());
      assertThat(kindInfo.size(), is(3));

      // kind_noでマスタ照合（mst_obs_kind）する。
      // （ただし、照合が成功しても電文から抽出した値を設定する。）
      assertThat(kindInfo.get("kind_no"), is("41"));
      assertThat(kindInfo.get("kind_update"), is("2020-04-01"));
      assertThat(kindInfo.get("kind_name"), is("kubun1"));

      // reg_staff_info
      // kind_infoに同じ
      String regStaffInfoStr = por.getRegStaffInfo();
      assertThat(regStaffInfoStr, notNullValue());
      Map<String, Object> regStaffInfo = ObjectMapperUtil.read(regStaffInfoStr, mapType);
      assertThat(regStaffInfo, notNullValue());
      assertThat(regStaffInfo.size(), is(3));

      assertThat(regStaffInfo.get("reg_staff_cd"), is(94001));
      assertThat(regStaffInfo.get("reg_staff_update"), is("2020-04-10"));
      assertThat(regStaffInfo.get("reg_staff_name"), is("医師00"));

      // up_staff_info
      // kind_infoに同じ
      String upStaffInfoStr = por.getUpStaffInfo();
      assertThat(upStaffInfoStr, notNullValue());
      Map<String, Object> upStaffInfo = ObjectMapperUtil.read(upStaffInfoStr, mapType);
      assertThat(upStaffInfo, notNullValue());
      assertThat(upStaffInfo.size(), is(3));

      assertThat(upStaffInfo.get("up_staff_cd"), is(94011));
      assertThat(upStaffInfo.get("up_staff_update"), is("2020-04-10"));
      assertThat(upStaffInfo.get("up_staff_name"), is("放射線技師01"));

      // obs_rec_info
      // 他のテーブルのjsonb型カラムと同様、マップのリストが設定される。
      String obsRecInfoStr = por.getObsRecInfo();
      assertThat(obsRecInfoStr, notNullValue());

      List<Map<String, Object>> obsRecInfoList = ObjectMapperUtil.readListOfMap(obsRecInfoStr);
      assertThat(obsRecInfoList, notNullValue());
      assertThat(obsRecInfoList.size(), is(6));

      obsRecInfoList.forEach(e -> {
        assertThat(e.size(), is(4));
        assertThat(e.get("detail1"), is("S"));
        assertThat(e.get("detail2"), is("O"));
        assertThat(e.get("detail3"), is("A"));
        assertThat(e.get("detail4"), is("P"));
      });

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_unique
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC50/clean_db5_C50.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC50/clean_db6_C50.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC50/masters_staff_C50.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC50/masters_others_C50.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC50/masters_layout_C50.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC50/masters_layout_detail_C50.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC50/journal_C50.sql")
  @Test
  public void JSONカラム内容確認_pat_unique_新規登録_1件ずつ() {
    final String FACILITY_CD = "F_hC50";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();
      PatUnique patUnique = patUniqueDao.selectById(patId);
      assertThat(patUnique, notNullValue());

      // medical_hst_info
      String medicalHstInfoStr = patUnique.getMedical_hst_info();
      assertThat(medicalHstInfoStr, notNullValue());

      List<Map<String, Object>> medicalHstInfoList = ObjectMapperUtil.readListOfMap(medicalHstInfoStr);
      assertThat(medicalHstInfoList, notNullValue());
      assertThat(medicalHstInfoList.size(), is(1));

      Map<String, Object> medicalHstInfo = medicalHstInfoList.get(0);
      assertThat(medicalHstInfo.size(), is(3));

      // ctl_no, disp_orderは自動採番される
      assertThat(medicalHstInfo.get("ctl_no"), is(1));
      assertThat(medicalHstInfo.get("disp_order"), is(1));

      // disease_cdはマスタ照合（mst_disease）
      assertThat(medicalHstInfo.get("disease_cd"), is(30503));

      // physical_info
      String physicalInfoStr = patUnique.getPhysical_info();
      assertThat(physicalInfoStr, notNullValue());

      List<Map<String, Object>> physicalInfoList = ObjectMapperUtil.readListOfMap(physicalInfoStr);
      assertThat(physicalInfoList, notNullValue());
      assertThat(physicalInfoList.size(), is(1));

      Map<String, Object> physicalInfo = physicalInfoList.get(0);
      assertThat(physicalInfo.size(), is(15));

      // ctl_noは自動採番される
      assertThat(medicalHstInfo.get("ctl_no"), is(1));

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC51/clean_db5_C51.sql")
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC51/clean_db6_C51.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
  @Sql(value = "classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC51/masters_staff_C51.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC51/masters_others_C51.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC51/masters_layout_C51.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC51/masters_layout_detail_C51.sql")
  @Sql("classpath:resource.script/JournalConvertReceiveResourceJsonTest/sC51/journal_C51.sql")
  @Test
  public void JSONカラム内容確認_pat_unique_新規登録_8件ずつ() {
    final String FACILITY_CD = "F_hC51";

    try {
      ResultActions response = requestConversionByFacilityCd(FACILITY_CD);
      response.andExpect(status().isOk());

      List<PatPersonalMain> ppmList = patPersonalMainDao.selectAll(Collections.singletonList(FACILITY_CD));
      assertThat(ppmList, notNullValue());
      assertThat(ppmList.size(), is(1));

      PatPersonalMain ppm = ppmList.get(0);
      assertThat(ppm, notNullValue());

      Long patId = ppm.getPat_id();
      PatUnique patUnique = patUniqueDao.selectById(patId);
      assertThat(patUnique, notNullValue());

      // medical_hst_info
      String medicalHstInfoStr = patUnique.getMedical_hst_info();
      assertThat(medicalHstInfoStr, notNullValue());

      List<Map<String, Object>> medicalHstInfoList = ObjectMapperUtil.readListOfMap(medicalHstInfoStr);
      assertThat(medicalHstInfoList, notNullValue());
      // 電文から8件抽出したがすべてdisease_cdが一致する。
      // そのため、登録件数は1件となる。
      assertThat(medicalHstInfoList.size(), is(1));

      Map<String, Object> medicalHstInfo = medicalHstInfoList.get(0);
      assertThat(medicalHstInfo.size(), is(3));

      // ctl_no, disp_orderは自動採番される
      assertThat(medicalHstInfo.get("ctl_no"), is(1));
      assertThat(medicalHstInfo.get("disp_order"), is(1));

      // disease_cdはマスタ照合（mst_disease）
      assertThat(medicalHstInfo.get("disease_cd"), is(30513));

      // physical_info
      String physicalInfoStr = patUnique.getPhysical_info();
      assertThat(physicalInfoStr, notNullValue());

      List<Map<String, Object>> physicalInfoList = ObjectMapperUtil.readListOfMap(physicalInfoStr);
      assertThat(physicalInfoList, notNullValue());
      assertThat(physicalInfoList.size(), is(8));

      for (int i = 0; i < 8; ++i) {
        Map<String, Object> physicalInfo = physicalInfoList.get(i);
        assertThat(physicalInfo.size(), is(15));

        // ctl_noは自動採番される
        assertThat(physicalInfo.get("ctl_no"), is(i + 1));
      }

    } catch (Exception e) {
      fail("ジャーナル変換に失敗しました", e);
    }
  }

  // pat_insuranceは入力（電文）と出力（カラム）の対応が1対1でないため対象外とする。

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
