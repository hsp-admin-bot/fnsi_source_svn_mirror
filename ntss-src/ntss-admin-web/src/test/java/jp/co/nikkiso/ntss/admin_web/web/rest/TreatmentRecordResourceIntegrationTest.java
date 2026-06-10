package jp.co.nikkiso.ntss.admin_web.web.rest;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName.PERSONAL;
import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.requestFields;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseBody;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.VitalMonitorData;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;

/**
 * TreatmentRecordResourceの結合テストクラス
 * <pre>
 * Spring Security の 認可 のテストを実施する場合は、以下を変更する.
 *   (test) jp.co.nikkiso.ntss.admin_web.security.SecurityConfig
 *     <code>@EnableGlobalMethodSecurity(prePostEnabled = false) -> @EnableGlobalMethodSecurity(prePostEnabled = true)</code>
 * </pre>
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.before.sql")
public class TreatmentRecordResourceIntegrationTest extends AbstractResourceIntegrationTest {

  @Autowired
  private TreatmentRecordDao treatmentRecordDao;

  /**
   * {@link MniMonitorDao}
   */
  @Autowired
  private MniMonitorDao mniMonitorDao;

  @Autowired
  private ObjectMapper objectMapper;

  /**
   * getTreatmentRecordResult()の検証.
   * 条件: オーダ番号に該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordResult_成功() throws Exception {
    // arrange
    final Long ordNo = 10L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$.rst_dialysis_state", is("1")))
      .andExpect(jsonPath("$.rst_kur_cd", is(11)))
      .andExpect(jsonPath("$.rst_kur_name", is("クール1")))
      .andExpect(jsonPath("$.rst_bed_cd", is(12)))
      .andExpect(jsonPath("$.rst_bed_name", is("ベッド1")))
      .andExpect(jsonPath("$.rst_start_date", is("2019-02-13T12:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_end_date", is("2019-02-13T18:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_in_out_class", is(1)))
      .andExpect(jsonPath("$.rst_dialysis_cnt", is(2)))
      .andExpect(jsonPath("$.rst_ward_cd", is(13)))
      .andExpect(jsonPath("$.rst_ward_name", is("病棟名1")))
      .andExpect(jsonPath("$.rst_course_cd", is(14)))
      .andExpect(jsonPath("$.rst_course_name", is("診療科名1")))
      .andExpect(jsonPath("$.rst_treatment_cd", is(101)))
      .andExpect(jsonPath("$.rst_treatment_name", is("テスト治療方法２")))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_id_1", is(101)))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_last_name_1", is("穿刺1")))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_first_name_1", is("太郎")))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_id_2", is(102)))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_last_name_2", is("穿刺2")))
      .andExpect(jsonPath("$.rst_puncture_user_info.user_first_name_2", is("次郎")))
      .andExpect(jsonPath("$.rst_puncture_user_info.date", is("2019-02-13T13:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_puncture_user_info.date_1", is("2019-02-13T13:01:00.000+09:00")))
      .andExpect(jsonPath("$.rst_puncture_user_info.date_2", is("2019-02-13T13:02:00.000+09:00")))
      .andExpect(jsonPath("$.rst_return_user_info.user_id_1", is(103)))
      .andExpect(jsonPath("$.rst_return_user_info.user_last_name_1", is("返血1")))
      .andExpect(jsonPath("$.rst_return_user_info.user_first_name_1", is("太郎")))
      .andExpect(jsonPath("$.rst_return_user_info.user_id_2", is(104)))
      .andExpect(jsonPath("$.rst_return_user_info.user_last_name_2", is("返血2")))
      .andExpect(jsonPath("$.rst_return_user_info.user_first_name_2", is("次郎")))
      .andExpect(jsonPath("$.rst_return_user_info.date", is("2019-02-13T13:30:00.000+09:00")))
      .andExpect(jsonPath("$.rst_return_user_info.date_1", is("2019-02-13T13:31:00.000+09:00")))
      .andExpect(jsonPath("$.rst_return_user_info.date_2", is("2019-02-13T13:32:00.000+09:00")))
      .andExpect(jsonPath("$.rst_charge_user_info.user_id_1", is(105)))
      .andExpect(jsonPath("$.rst_charge_user_info.user_last_name_1", is("担当1")))
      .andExpect(jsonPath("$.rst_charge_user_info.user_first_name_1", is("太郎")))
      .andExpect(jsonPath("$.rst_charge_user_info.user_id_2", is(106)))
      .andExpect(jsonPath("$.rst_charge_user_info.user_last_name_2", is("担当2")))
      .andExpect(jsonPath("$.rst_charge_user_info.user_first_name_2", is("次郎")))
      .andExpect(jsonPath("$.rst_charge_user_info.date_1", is("2019-02-13T14:31:00.000+09:00")))
      .andExpect(jsonPath("$.rst_charge_user_info.date_2", is("2019-02-13T14:32:00.000+09:00")))
      .andExpect(jsonPath("$.up_date", is("2019-02-13T14:30:00.000+09:00")))
      .andExpect(jsonPath("$.rst_purification_cnt", is(2)))
      .andExpect(jsonPath("$.treat_date", is("20190213")))
      .andExpect(jsonPath("$.operator_id", nullValue()))
      .andExpect(jsonPath("$.target_facility_cd", nullValue()))


      .andDo(document("treatment_record/result/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の実績を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("rst_dialysis_state").description("実績：治療状況"),
          fieldWithPath("rst_kur_cd").description("実績：クールコード"),
          fieldWithPath("rst_kur_name").description("実績：クール名"),
          fieldWithPath("rst_bed_cd").description("実績：ベッドコード"),
          fieldWithPath("rst_bed_name").description("実績：ベッド名"),
          fieldWithPath("rst_start_date").description("実績：治療開始日時"),
          fieldWithPath("rst_end_date").description("実績：治療終了日時"),
          fieldWithPath("rst_in_out_class").description("実績：入外区分"),
          fieldWithPath("rst_dialysis_cnt").description("実績：透析回数"),
          fieldWithPath("rst_ward_cd").description("実績：病棟コード"),
          fieldWithPath("rst_ward_name").description("実績：病棟名"),
          fieldWithPath("rst_course_cd").description("実績：診療科コード"),
          fieldWithPath("rst_course_name").description("実績：診療科名"),
          fieldWithPath("rst_treatment_cd").description("実績：治療方法コード"),
          fieldWithPath("rst_treatment_name").description("実績：治療方法名"),
          fieldWithPath("rst_puncture_user_info.user_id_1").description("実績：穿刺者情報.穿刺者コード1"),
          fieldWithPath("rst_puncture_user_info.user_last_name_1").description("実績：穿刺者情報.穿刺者名_姓1"),
          fieldWithPath("rst_puncture_user_info.user_first_name_1").description("実績：穿刺者情報.穿刺者名_名1"),
          fieldWithPath("rst_puncture_user_info.user_id_2").description("実績：穿刺者情報.穿刺者コード2"),
          fieldWithPath("rst_puncture_user_info.user_last_name_2").description("実績：穿刺者情報.穿刺者名_姓2"),
          fieldWithPath("rst_puncture_user_info.user_first_name_2").description("実績：穿刺者情報.穿刺者名_名2"),
          fieldWithPath("rst_puncture_user_info.date").description("実績：穿刺者情報.穿刺日時"),
          fieldWithPath("rst_puncture_user_info.date_1").description("実績：穿刺者情報.担当者1登録日時"),
          fieldWithPath("rst_puncture_user_info.date_2").description("実績：穿刺者情報.担当者2登録日時"),
          fieldWithPath("rst_return_user_info.user_id_1").description("実績：返血者情報.返血者コード1"),
          fieldWithPath("rst_return_user_info.user_last_name_1").description("実績：返血者情報.返血者名_姓1"),
          fieldWithPath("rst_return_user_info.user_first_name_1").description("実績：返血者情報.返血者名_名1"),
          fieldWithPath("rst_return_user_info.user_id_2").description("実績：返血者情報.返血者コード2"),
          fieldWithPath("rst_return_user_info.user_last_name_2").description("実績：返血者情報.返血者名_姓2"),
          fieldWithPath("rst_return_user_info.user_first_name_2").description("実績：返血者情報.返血者名_名2"),
          fieldWithPath("rst_return_user_info.date").description("実績：返血者情報.返血日時"),
          fieldWithPath("rst_return_user_info.date_1").description("実績：返血者情報.担当者1登録日時"),
          fieldWithPath("rst_return_user_info.date_2").description("実績：返血者情報.担当者2登録日時"),
          fieldWithPath("rst_charge_user_info.user_id_1").description("実績：担当者情報.担当者コード1"),
          fieldWithPath("rst_charge_user_info.user_last_name_1").description("実績：担当者情報.担当者名_姓1"),
          fieldWithPath("rst_charge_user_info.user_first_name_1").description("実績：担当者情報.担当者名_名1"),
          fieldWithPath("rst_charge_user_info.user_id_2").description("実績：担当者情報.担当者コード2"),
          fieldWithPath("rst_charge_user_info.user_last_name_2").description("実績：担当者情報.担当者名_姓2"),
          fieldWithPath("rst_charge_user_info.user_first_name_2").description("実績：担当者情報.担当者名_名2"),
          fieldWithPath("rst_charge_user_info.date_1").description("実績：担当者情報.担当者1登録日時"),
          fieldWithPath("rst_charge_user_info.date_2").description("実績：担当者情報.担当者2登録日時"),
          fieldWithPath("up_date").description("更新日時(排他制御用)"),
          fieldWithPath("is_confirm").description("確定フラグ"),
          fieldWithPath("rst_purification_cnt").description("実績：特殊浄化回数"),
          fieldWithPath("treat_date").description("治療日"),
          fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )))
    ;
  }

  /**
   * getTreatmentRecordResult()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていない
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordList_失敗_該当実績なし() throws Exception {
    // arrange
    final Long ordNo = 9L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/result/get/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )))
    ;
  }

  /**
   * getTreatmentRecordResult()の検証.
   * 条件: オーダ番号に該当するレコードが削除済み
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordList_失敗_該当実績削除済み() throws Exception {
    // arrange
    final Long ordNo = 12L;

    // action
    ResultActions result
      = mockMvc.perform(get("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
    ;
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功_治療記録のうち実績情報を更新できること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final TreatmentRecordResult beUpdatedTreatmentRecordResult = treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo);
    beUpdatedTreatmentRecordResult.setRstKurCd(110L);
    beUpdatedTreatmentRecordResult.setRstKurName("クール名更新");
    beUpdatedTreatmentRecordResult.setRstBedCd(120L);
    beUpdatedTreatmentRecordResult.setRstBedName("ベッド名更新");
    beUpdatedTreatmentRecordResult.setRstStartDate(Timestamp.valueOf("2019-02-15 06:00:00"));
    beUpdatedTreatmentRecordResult.setRstEndDate(Timestamp.valueOf("2019-02-15 11:30:00"));
    beUpdatedTreatmentRecordResult.setRstDialysisCnt(30);
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setUserId1(101L);
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setUserLastName1("穿刺者1 姓変更");
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setUserFirstName1("穿刺者1 名変更");
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setUserId2(102L);
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setUserLastName2("穿刺2");
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setUserFirstName2("次郎");
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setDate("2019-02-15 21:00:00");
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setDate1(Timestamp.valueOf("2019-02-15 22:00:00"));
    beUpdatedTreatmentRecordResult.getRstPunctureUserInfo().setDate2(Timestamp.valueOf("2019-02-15 23:00:00"));
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setUserId1(103L);
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setUserLastName1("返血1");
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setUserFirstName1("太郎");
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setUserId2(104L);
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setUserLastName2("返血者2 姓変更");
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setUserFirstName2("返血者2 名変更");
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setDate("2019-02-13 23:30:00");
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setDate1(Timestamp.valueOf("2019-02-13 14:30:00"));
    beUpdatedTreatmentRecordResult.getRstReturnUserInfo().setDate2(Timestamp.valueOf("2019-02-13 15:30:00"));
    // 治療方法コード
    beUpdatedTreatmentRecordResult.setRstTreatmentCd(999);
    // 治療方法名
    beUpdatedTreatmentRecordResult.setRstTreatmentName("テスト治療方法（更新）");
    // 治療日
    beUpdatedTreatmentRecordResult.setTreatDate("20190213");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordResult);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/result/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の実績を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("rst_dialysis_state").ignored()
          , fieldWithPath("rst_kur_cd").description("[必須]実績：クールコード")
          , fieldWithPath("rst_kur_name").description("[必須]実績：クール名")
          , fieldWithPath("rst_bed_cd").description("[必須]実績：ベッドコード")
          , fieldWithPath("rst_bed_name").description("[必須]実績：ベッド名")
          , fieldWithPath("rst_start_date").description("[必須]実績：治療開始日時")
          , fieldWithPath("rst_end_date").description("[必須]実績：治療終了日時")
          , fieldWithPath("rst_in_out_class").description("[必須]実績：入外区分")
          , fieldWithPath("rst_dialysis_cnt").description("実績：透析回数")
          , fieldWithPath("rst_ward_cd").description("実績：病棟コード")
          , fieldWithPath("rst_ward_name").description("実績：病棟名")
          , fieldWithPath("rst_course_cd").description("実績：診療科コード")
          , fieldWithPath("rst_course_name").description("実績：診療科名")
          , fieldWithPath("rst_treatment_cd").description("実績：治療方法コード")
          , fieldWithPath("rst_treatment_name").description("実績：治療方法名")
          , fieldWithPath("rst_puncture_user_info").description("実績：穿刺者情報")
          , fieldWithPath("rst_puncture_user_info.user_id_1").description("実績：穿刺者情報.穿刺者コード1")
          , fieldWithPath("rst_puncture_user_info.user_last_name_1").description("実績：穿刺者情報.穿刺者名_姓1")
          , fieldWithPath("rst_puncture_user_info.user_first_name_1").description("実績：穿刺者情報.穿刺者名_名1")
          , fieldWithPath("rst_puncture_user_info.user_id_2").description("実績：穿刺者情報.穿刺者コード2")
          , fieldWithPath("rst_puncture_user_info.user_last_name_2").description("実績：穿刺者情報.穿刺者名_姓2")
          , fieldWithPath("rst_puncture_user_info.user_first_name_2").description("実績：穿刺者情報.穿刺者名_名2")
          , fieldWithPath("rst_puncture_user_info.date").description("実績：穿刺者情報.穿刺日時")
          , fieldWithPath("rst_puncture_user_info.date_1").description("実績：穿刺者情報.担当者1登録日時")
          , fieldWithPath("rst_puncture_user_info.date_2").description("実績：穿刺者情報.担当者2登録日時")
          , fieldWithPath("rst_return_user_info").description("実績：返血者情報")
          , fieldWithPath("rst_return_user_info.user_id_1").description("実績：返血者情報.返血者コード1")
          , fieldWithPath("rst_return_user_info.user_last_name_1").description("実績：返血者情報.返血者名_姓1")
          , fieldWithPath("rst_return_user_info.user_first_name_1").description("実績：返血者情報.返血者名_名1")
          , fieldWithPath("rst_return_user_info.user_id_2").description("実績：返血者情報.返血者コード2")
          , fieldWithPath("rst_return_user_info.user_last_name_2").description("実績：返血者情報.返血者名_姓2")
          , fieldWithPath("rst_return_user_info.user_first_name_2").description("実績：返血者情報.返血者名_名2")
          , fieldWithPath("rst_return_user_info.date").description("実績：返血者情報.返血日時")
          , fieldWithPath("rst_return_user_info.date_1").description("実績：返血者情報.担当者1登録日時")
          , fieldWithPath("rst_return_user_info.date_2").description("実績：返血者情報.担当者2登録日時")
          , fieldWithPath("rst_charge_user_info").description("実績：担当者情報")
          , fieldWithPath("rst_charge_user_info.user_id_1").description("実績：担当者情報.担当者コード1")
          , fieldWithPath("rst_charge_user_info.user_last_name_1").description("実績：担当者情報.担当者名_姓1")
          , fieldWithPath("rst_charge_user_info.user_first_name_1").description("実績：担当者情報.担当者名_名1")
          , fieldWithPath("rst_charge_user_info.user_id_2").description("実績：担当者情報.担当者コード2")
          , fieldWithPath("rst_charge_user_info.user_last_name_2").description("実績：担当者情報.担当者名_姓2")
          , fieldWithPath("rst_charge_user_info.user_first_name_2").description("実績：担当者情報.担当者名_名2")
          , fieldWithPath("rst_charge_user_info.date_1").description("実績：担当者情報.担当者1登録日時")
          , fieldWithPath("rst_charge_user_info.date_2").description("実績：担当者情報.担当者2登録日時")
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("is_confirm").description("確定フラグ")
          , fieldWithPath("rst_purification_cnt").description("実績：特殊浄化回数")
          , fieldWithPath("treat_date").description("治療日")
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の実績情報を検証
    final TreatmentRecordResult updatedTreatmentRecordResult = treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo);
    assertThat(updatedTreatmentRecordResult.getOrdNo()).isEqualTo(1L);
    assertThat(updatedTreatmentRecordResult.getPatId()).isEqualTo(2L);
    assertThat(updatedTreatmentRecordResult.getFnPatId()).isEqualTo("00003");
    assertThat(updatedTreatmentRecordResult.getTreatDate()).isEqualTo("20190213");
    assertThat(updatedTreatmentRecordResult.getTreatWeek()).isEqualTo((short)1);
    assertThat(updatedTreatmentRecordResult.getFacilityCd()).isEqualTo("009999");
    assertThat(updatedTreatmentRecordResult.getFacilityName()).isEqualTo("テスト施設名");
    assertThat(updatedTreatmentRecordResult.getRstKurCd()).isEqualTo(110L);
    assertThat(updatedTreatmentRecordResult.getRstKurName()).isEqualTo("クール名更新");
    assertThat(updatedTreatmentRecordResult.getRstBedCd()).isEqualTo(120L);
    assertThat(updatedTreatmentRecordResult.getRstBedName()).isEqualTo("ベッド名更新");
    assertThat(updatedTreatmentRecordResult.getRstStartDate()).isEqualTo(Timestamp.valueOf("2019-02-15 06:00:00"));
    assertThat(updatedTreatmentRecordResult.getRstEndDate()).isEqualTo(Timestamp.valueOf("2019-02-15 11:30:00"));
    assertThat(updatedTreatmentRecordResult.getRstInOutClass()).isEqualTo((short)1);
    assertThat(updatedTreatmentRecordResult.getRstDialysisCnt()).isEqualTo(30);
    assertThat(updatedTreatmentRecordResult.getRstWardCd()).isEqualTo(13);
    assertThat(updatedTreatmentRecordResult.getRstWardName()).isEqualTo("病棟名1");
    assertThat(updatedTreatmentRecordResult.getRstCourseCd()).isEqualTo(14);
    assertThat(updatedTreatmentRecordResult.getRstCourseName()).isEqualTo("診療科名1");
    assertThat(updatedTreatmentRecordResult.getRstTreatmentCd()).isEqualTo(999);
    assertThat(updatedTreatmentRecordResult.getRstTreatmentName()).isEqualTo("テスト治療方法（更新）");
    assertThat(updatedTreatmentRecordResult.getRegDate()).isEqualTo(beUpdatedTreatmentRecordResult.getRegDate());
    assertThat(updatedTreatmentRecordResult.getUpDate()).isAfter(beUpdatedTreatmentRecordResult.getUpDate());

    final TreatmentRecordResult.RstUserInfo rstPunctureUserInfo = updatedTreatmentRecordResult.getRstPunctureUserInfo();
    assertThat(rstPunctureUserInfo.getUserId1()).isEqualTo(101L);
    assertThat(rstPunctureUserInfo.getUserLastName1()).isEqualTo("穿刺者1 姓変更");
    assertThat(rstPunctureUserInfo.getUserFirstName1()).isEqualTo("穿刺者1 名変更");
    assertThat(rstPunctureUserInfo.getUserId2()).isEqualTo(102L);
    assertThat(rstPunctureUserInfo.getUserLastName2()).isEqualTo("穿刺2");
    assertThat(rstPunctureUserInfo.getUserFirstName2()).isEqualTo("次郎");
    assertThat(rstPunctureUserInfo.getDate()).isEqualTo(Timestamp.valueOf("2019-02-15 21:00:00"));
    assertThat(rstPunctureUserInfo.getDate1()).isEqualTo(Timestamp.valueOf("2019-02-15 22:00:00"));
    assertThat(rstPunctureUserInfo.getDate2()).isEqualTo(Timestamp.valueOf("2019-02-15 23:00:00"));

    final TreatmentRecordResult.RstUserInfo rstReturnUserInfo = updatedTreatmentRecordResult.getRstReturnUserInfo();
    assertThat(rstReturnUserInfo.getUserId1()).isEqualTo(103L);
    assertThat(rstReturnUserInfo.getUserLastName1()).isEqualTo("返血1");
    assertThat(rstReturnUserInfo.getUserFirstName1()).isEqualTo("太郎");
    assertThat(rstReturnUserInfo.getUserId2()).isEqualTo(104L);
    assertThat(rstReturnUserInfo.getUserLastName2()).isEqualTo("返血者2 姓変更");
    assertThat(rstReturnUserInfo.getUserFirstName2()).isEqualTo("返血者2 名変更");
    assertThat(rstReturnUserInfo.getDate()).isEqualTo(Timestamp.valueOf("2019-02-13 23:30:00"));
    assertThat(rstReturnUserInfo.getDate1()).isEqualTo(Timestamp.valueOf("2019-02-13 14:30:00"));
    assertThat(rstReturnUserInfo.getDate2()).isEqualTo(Timestamp.valueOf("2019-02-13 15:30:00"));

    final TreatmentRecordResult.RstUserInfo rstChargeUserInfo = updatedTreatmentRecordResult.getRstChargeUserInfo();
    assertThat(rstChargeUserInfo.getUserId1()).isEqualTo(105L);
    assertThat(rstChargeUserInfo.getUserLastName1()).isEqualTo("担当1");
    assertThat(rstChargeUserInfo.getUserFirstName1()).isEqualTo("太郎");
    assertThat(rstChargeUserInfo.getUserId2()).isEqualTo(106L);
    assertThat(rstChargeUserInfo.getUserLastName2()).isEqualTo("担当2");
    assertThat(rstChargeUserInfo.getUserFirstName2()).isEqualTo("次郎");
    assertThat(rstChargeUserInfo.getDate1()).isEqualTo(Timestamp.valueOf("2019-02-14 14:30:00"));
    assertThat(rstChargeUserInfo.getDate2()).isEqualTo(Timestamp.valueOf("2019-02-14 15:30:00"));
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_失敗_治療情報に存在しないOrdNoを指定した場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long notExistOrdNo = 100L; // 存在しないオーダ番号
    final TreatmentRecordResult beUpdatedTreatmentRecordResult = treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordResult);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isConflict())
      .andDo(document("treatment_record/result/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * 条件: オーダ番号に該当するレコードが削除済みレコード（is_del='1'）であること
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_失敗_治療記録が削除済みの場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long deletedOrdNo = 12L;
    final TreatmentRecordResult beUpdatedTreatmentRecordResult = treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo);
    beUpdatedTreatmentRecordResult.setOrdNo(deletedOrdNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordResult);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result", deletedOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isConflict());
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * 条件: リクエストに入外区分が入力されていないこと
   * 結果: HTTPステータス400が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Ignore
  public void test_updateTreatmentRecordResult_失敗_入外区分が入力されていない場合_400が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final TreatmentRecordResult beUpdatedTreatmentRecordResult = treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo);
    beUpdatedTreatmentRecordResult.setRstInOutClass(null);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordResult);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isBadRequest())
      .andDo(document("treatment_record/result/put/required-be-empty",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )));
  }

  /**
   * updateTreatmentRecordResult()の検証.
   * 条件: リクエストに入外区分が入力されていないこと
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordResult_成功_入外区分が入力されていない場合_200が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final TreatmentRecordResult beUpdatedTreatmentRecordResult = treatmentRecordDao.selectTreatmentRecordResultByOrdNo(ordNo);
    beUpdatedTreatmentRecordResult.setRstInOutClass(null);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordResult);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/result/put/required-be-empty",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )));
  }

  /**
   * getTreatmentRecordMediInfo()の検証
   * 条件: 治療情報に存在するOrdNoを指定する
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMediInfo.before.sql")
  public void test_getTreatmentRecordMediInfo_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/medi_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.treat_date", is("20190201")))
      .andExpect(jsonPath("$.rst_dialysis_state", is("0")))
      .andExpect(jsonPath("$.rst_start_date", is("2019-03-01T12:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_medi_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.up_date", is("2019-03-01T13:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_end_date", nullValue()))
      .andExpect(jsonPath("$.operator_id", nullValue()))
      .andExpect(jsonPath("$.target_facility_cd", nullValue()))
      .andDo(
        document("treatment_record/medi_info/get/ok",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定されたオーダ番号に該当する治療記録の実績: 投与薬剤情報を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
            ),
            fieldWithPath("treat_date").description("治療日")
            , fieldWithPath("rst_dialysis_state").description("実績：治療状況")
            , fieldWithPath("rst_start_date").description("実績：透析開始日時")
            , fieldWithPath("rst_end_date").description("実績：透析終了日時")
            , fieldWithPath("rst_medi_info").description("実績：投与薬剤情報（JSON項目を文字列で返す。クライアント側でparseする。）")
            , fieldWithPath("up_date").description("更新日時(排他制御用)")
            , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordCondition()の検証.
   * 条件: オーダ番号に該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordCondition_成功() throws Exception {
    // arrange
    final Long ordNo = 21L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/condition", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$.ind_treat_start_time", is("1423")))
      .andExpect(jsonPath("$.rst_cond_info", is("{\"1\": {\"value\": \"0400\", \"value_name_1\": null}}")))
      .andExpect(jsonPath("$.rst_dw", is(66.3)))
      .andExpect(jsonPath("$.up_date", is("2019-02-13T14:30:00.000+09:00")))
      .andExpect(jsonPath("$.operator_id", nullValue()))
      .andExpect(jsonPath("$.target_facility_cd", nullValue()))

      .andDo(document("treatment_record/condition/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の条件情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("ind_treat_start_time").description("指示：治療開始時刻"),
          fieldWithPath("rst_cond_info").description("実績：治療条件情報"),
          fieldWithPath("rst_dw").description("実績：DW"),
          fieldWithPath("up_date").description("更新日時(排他制御用)"),
          fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )))
    ;
  }

  /**
   * getTreatmentRecordEquipInfo()の検証
   * 条件: 治療情報に存在するOrdNoを指定する
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordEquipInfo.before.sql")
  public void test_getTreatmentRecordEquipInfo_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/equip_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_dialysis_state", is("0")))
      .andExpect(jsonPath("$.rst_equip_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.up_date", is("2019-03-01T13:00:00.000+09:00")))
      .andDo(
        document("treatment_record/equip_info/get/ok",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定されたオーダ番号に該当する治療記録の実績: 医療材料情報を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
            ),
            fieldWithPath("rst_dialysis_state").description("実績：治療状況")
            , fieldWithPath("rst_equip_info").description("実績：医療材料情報（JSON項目を文字列で返す。クライアント側でparseする。）")
            , fieldWithPath("up_date").description("更新日時(排他制御用)")
            , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordMediInfo()の検証
   * 条件: 治療情報に存在しないオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMediInfo.before.sql")
  public void test_getTreatmentRecordMediInfo_失敗_マスタに存在しないオーダ番号を指定する() throws Exception {
    // arrange
    final Long ordNo = 9999L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/medi_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/medi_info/get/not-found",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordCondition()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていない
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordCondition_失敗_該当データなし() throws Exception {
    // arrange
    final Long ordNo = 9L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/condition", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/condition/get/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )))
    ;
  }

  /**
   * getTreatmentRecordEquipInfo()の検証
   * 条件: 治療情報に存在しないオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordEquipInfo.before.sql")
  public void test_getTreatmentRecordEquipInfo_失敗_マスタに存在しないオーダ番号を指定する() throws Exception {
    // arrange
    final Long ordNo = 9999L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/equip_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/equip_info/get/not-found",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordMediInfo()の検証
   * 条件: 治療情報に存在し、削除（is_del='1'）に設定されているオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMediInfo.before.sql")
  public void test_getTreatmentRecordMediInfo_失敗_削除に設定されているレコードを指定する() throws Exception {
    // arrange
    final Long ordNo = 2L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/medi_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/medi_info/get/set-deleted",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordCondition()の検証.
   * 条件: オーダ番号に該当するレコードが削除済み
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordCondition_失敗_該当データ削除済み() throws Exception {
    // arrange
    final Long ordNo = 12L;

    // action
    ResultActions result
      = mockMvc.perform(get("/api/treatment-record/{ord_no}/condition", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
    ;
  }

  /**
   * getTreatmentRecordEquipInfo()の検証
   * 条件: 治療情報に存在し、削除（is_del='1'）に設定されているオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordEquipInfo.before.sql")
  public void test_getTreatmentRecordEquipInfo_失敗_削除に設定されているレコードを指定する() throws Exception {
    // arrange
    final Long ordNo = 2L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/equip_info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/equip_info/get/set-deleted",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * updateTreatmentRecordCondition()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordCondition_成功_治療記録のうち治療条件を更新できること() throws Exception {
    // arrange
    final Long ordNo = 21L;
    final TreatmentRecordCondition beUpdatedTreatmentRecordCondition = treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo);
    beUpdatedTreatmentRecordCondition.setIndTreatStartTime("1508");
    beUpdatedTreatmentRecordCondition.setRstCondInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordCondition);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/condition", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/condition/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の条件情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("ind_treat_start_time").description("指示：治療開始時刻")
          , fieldWithPath("rst_cond_info").description("実績：治療条件情報")
          , fieldWithPath("rst_dw").description("実績：DW ※更新対象外項目")
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の治療条件を検証
    final TreatmentRecordCondition updatedTreatmentRecordCondition = treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo);
    assertThat(updatedTreatmentRecordCondition.getRstCondInfo()).isEqualTo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    assertThat(updatedTreatmentRecordCondition.getRstDw().toString()).isEqualTo("66.30");
  }

  /**
   * updateTreatmentRecordCondition()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordCondition_失敗_治療情報に存在しないOrdNoを指定した場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 21L;
    final Long notExistOrdNo = 100L; // 存在しないオーダ番号
    final TreatmentRecordCondition beUpdatedTreatmentRecordCondition = treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordCondition);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/condition", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isConflict())
      .andDo(document("treatment_record/condition/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * updateTreatmentRecordCondition()の検証.
   * 条件: オーダ番号に該当するレコードが削除済みレコード（is_del='1'）であること
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordCondition_失敗_治療記録が削除済みの場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 21L;
    final Long deletedOrdNo = 12L;
    final TreatmentRecordCondition beUpdatedTreatmentRecordCondition = treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordCondition);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/condition", deletedOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isConflict());
  }

  /**
   * updateTreatmentRecordCondition()の検証.
   * 条件: リクエストに治療方法が入力されていないこと
   * 結果: HTTPステータス400が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Ignore
  public void test_updateTreatmentRecordCondition_失敗_治療方法が入力されていない場合_400が返ること() throws Exception {
    // arrange
    final Long ordNo = 21L;
    final TreatmentRecordCondition beUpdatedTreatmentRecordCondition = treatmentRecordDao.selectTreatmentRecordConditionByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordCondition);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/condition", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isBadRequest())
      .andDo(document("treatment_record/condition/put/required-be-empty",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )));
  }

  /**
   * updateTreatmentRecordMediInfo()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMediInfo.before.sql")
  public void test_updateTreatmentRecordMediInfo_成功_治療記録のうち投与薬剤情報を更新できること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final TreatmentRecordMediInfo beforeUpdatedTreatmentRecordMediInfo = treatmentRecordDao.selectTreatmentRecordMediInfoByOrdNo(ordNo);
    beforeUpdatedTreatmentRecordMediInfo.setRstMediInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");

    final String requestBody = objectMapper.writeValueAsString(beforeUpdatedTreatmentRecordMediInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/medi_info", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/medi_info/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の投与薬剤情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("treat_date").ignored()
          , fieldWithPath("rst_dialysis_state").ignored()
          , fieldWithPath("rst_start_date").ignored()
          , fieldWithPath("rst_end_date").ignored()
          , fieldWithPath("rst_medi_info").description("実績：投与薬剤情報")
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の投与薬剤情報を検証
    final TreatmentRecordMediInfo updatedTreatmentRecordMediInfo = treatmentRecordDao.selectTreatmentRecordMediInfoByOrdNo(ordNo);
    assertThat(updatedTreatmentRecordMediInfo.getRstMediInfo()).isEqualTo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
  }

  /**
   * updateTreatmentRecordMediInfo()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMediInfo.before.sql")
  public void test_updateTreatmentRecordMediInfo_失敗_治療記録マスタに存在しないOrdNoを指定した場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long notExistOrdNo = 9999L; // 存在しないオーダ番号
    final TreatmentRecordMediInfo beUpdatedTreatmentRecordMediInfo = treatmentRecordDao.selectTreatmentRecordMediInfoByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordMediInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/medi_info", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isConflict())
      .andDo(document("treatment_record/medi_info/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * updateTreatmentRecordMediInfo()の検証.
   * 条件: オーダ番号に該当するレコードが削除済みレコード（is_del='1'）であること
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMediInfo.before.sql")
  public void test_updateTreatmentRecordMediInfo_失敗_治療記録が削除済みの場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long deletedOrdNo = 2L;
    final TreatmentRecordMediInfo beUpdatedTreatmentRecordMediInfo = treatmentRecordDao.selectTreatmentRecordMediInfoByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordMediInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/medi_info", deletedOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isConflict());
  }

  /**
   * updateTreatmentRecordEquipInfo()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordEquipInfo.before.sql")
  public void test_updateTreatmentRecordEquipInfo_成功_治療記録のうち医療材料情報を更新できること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final TreatmentRecordEquipInfo beforeUpdatedTreatmentRecordEquipInfo = treatmentRecordDao.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
    beforeUpdatedTreatmentRecordEquipInfo.setRstEquipInfo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
    beforeUpdatedTreatmentRecordEquipInfo.setUpDate(Timestamp.valueOf("2019-03-01 13:00:00"));

    final String requestBody = objectMapper.writeValueAsString(beforeUpdatedTreatmentRecordEquipInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/equip_info", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/equip_info/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の医療材料情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("rst_dialysis_state").ignored()
          , fieldWithPath("rst_equip_info").description("実績：医療材料情報")
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の医療材料情報を検証
    final TreatmentRecordEquipInfo updatedTreatmentRecordEquipInfo = treatmentRecordDao.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
    assertThat(updatedTreatmentRecordEquipInfo.getRstEquipInfo()).isEqualTo("{\"1\": {\"unit\": null, \"value\": \"0400\"}, \"2\": {\"unit\": null, \"value\": 3}}");
  }

  /**
   * updateTreatmentRecordEquipInfo()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordEquipInfo.before.sql")
  public void test_updateTreatmentRecordEquipInfo_失敗_治療記録マスタに存在しないOrdNoを指定した場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long notExistOrdNo = 9999L; // 存在しないオーダ番号
    final TreatmentRecordEquipInfo beUpdatedTreatmentRecordEquipInfo = treatmentRecordDao.selectTreatmentRecordEquipInfoByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordEquipInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/equip_info", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isConflict())
      .andDo(document("treatment_record/equip_info/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * updateTreatmentRecordEquipInfo()の検証.
   * 条件: オーダ番号に該当するレコードが削除済みレコード（is_del='1'）であること
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordEquipInfo.before.sql")
  public void test_updateTreatmentRecordEquipInfo_失敗_治療記録が削除済みの場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long deletedOrdNo = 2L;
    final TreatmentRecordEquipInfo beUpdatedTreatmentRecordEquipInfo = treatmentRecordDao.selectTreatmentRecordEquipInfoByOrdNo(ordNo);

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordEquipInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/equip_info", deletedOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isConflict());
  }

  /**
   * getRecirculationRate()の検証.
   * 条件: オーダ番号に該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getRecirculationRate_正常_該当データあり() throws Exception{
    // arrange
    final Long ordNo = 10L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/recirculation-rate", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$[0].bio_moni_ctl_no", is(1)))
      .andExpect(jsonPath("$[0].date", is("2019-03-22T12:00:00+09:00")))
      .andExpect(jsonPath("$[0].recirculation_rate", is(70)))
      .andExpect(jsonPath("$[0].blood_flow", is(100)))
      .andExpect(jsonPath("$[1].bio_moni_ctl_no", is(2)))
      .andExpect(jsonPath("$[1].date", is("2019-03-22T13:00:00+09:00")))
      .andExpect(jsonPath("$[1].recirculation_rate", is(75)))
      .andExpect(jsonPath("$[1].blood_flow", is(100)))
      .andExpect(jsonPath("$[2].bio_moni_ctl_no", is(3)))
      .andExpect(jsonPath("$[2].date", is("2019-03-22T13:30:00+09:00")))
      .andExpect(jsonPath("$[2].recirculation_rate", is(80)))
      .andExpect(jsonPath("$[2].blood_flow", is(100)))
      .andExpect(jsonPath("$[3].bio_moni_ctl_no", is(4)))
      .andExpect(jsonPath("$[3].date", is("2019-03-22T14:00:00+09:00")))
      .andExpect(jsonPath("$[3].recirculation_rate", is(85)))
      .andExpect(jsonPath("$[3].blood_flow", is(110)))
      .andExpect(jsonPath("$[4].bio_moni_ctl_no", is(5)))
      .andExpect(jsonPath("$[4].date", is("2019-03-22T15:00:00+09:00")))
      .andExpect(jsonPath("$[4].recirculation_rate", is(90)))
      .andExpect(jsonPath("$[4].blood_flow", is(120)))

      .andDo(document("treatment_record/recirculation-rate/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する再循環率データリストを取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：装置モニタデータ (mni_monitor)")
          ),
          fieldWithPath("[]").description("再循環率リスト"),
          fieldWithPath("[].bio_moni_ctl_no").description("生体モニタリング管理番号"),
          fieldWithPath("[].date").description("測定日時"),
          fieldWithPath("[].recirculation_rate").description("再循環率(%)"),
          fieldWithPath("[].blood_flow").description("血流量(ml/min)")
        )))
    ;
  }

  /**
   * getRecirculationRate()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていない
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getRecirculationRate_正常_該当データなし() throws Exception{
    // arrange
    final Long ordNo = 20L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/recirculation-rate", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }

  /**
   * getTreatmentRecordWeight()の検証.
   * 条件: オーダ番号に該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordWeight_成功() throws Exception {
    // arrange
    final Long ordNo = 32L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$.last_weight", is(55.4)))
      .andExpect(jsonPath("$.rst_weight_info", is("{\"weight_after\": 58.4, \"weight_before\": 56.9}")))
      .andExpect(jsonPath("$.rst_dw", is(66.5)))
      .andExpect(jsonPath("$.rst_tare_info", is("{\"after\": {\"name_1\": \"服\", \"weight_1\": 500}, \"before\": {\"name_1\": \"スリッパ\", \"weight_1\": 100}}")))
      .andExpect(jsonPath("$.target_weight", is(56.3)))
      .andExpect(jsonPath("$.water_removal_amount_limit", is(5)))
      .andExpect(jsonPath("$.rst_off_water_info", is("{\"name_1\": \"除水補正1\", \"weight_1\": 120}")))
      .andExpect(jsonPath("$.up_date", is("2019-03-13T15:30:00.000+09:00")))
      .andExpect(jsonPath("$.operator_id", nullValue()))
      .andExpect(jsonPath("$.target_facility_cd", nullValue()))

      .andDo(document("treatment_record/weight/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の体重情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("last_weight").description("前回体重"),
          fieldWithPath("rst_weight_info").description("実績：体重情報"),
          fieldWithPath("rst_dw").description("実績：DW"),
          fieldWithPath("rst_tare_info").description("実績：風袋補正"),
          fieldWithPath("target_weight").description("目標体重"),
          fieldWithPath("water_removal_amount_limit").description("除水量制限"),
          fieldWithPath("rst_off_water_info").description("実績：除水補正"),
          fieldWithPath("up_date").description("更新日時(排他制御用)"),
          fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )))
    ;
  }

  /**
   * getTreatmentRecordWeight()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていない
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordWeight_失敗_該当データなし() throws Exception {
    // arrange
    final Long ordNo = 9L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/weight/get/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )))
    ;
  }

  /**
   * getTreatmentRecordWeight()の検証.
   * 条件: オーダ番号に該当するレコードが削除済み
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordWeight_失敗_該当データ削除済み() throws Exception {
    // arrange
    final Long ordNo = 12L;

    // action
    ResultActions result
      = mockMvc.perform(get("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
    ;
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_成功_治療記録のうち体重情報を更新できること() throws Exception {
    // arrange
    final Long ordNo = 32L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo);
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-04-01T11:00:00.000+09:00\", \"weight_before_date\": \"2019-04-01T09:00:00.000+09:00\"}");
    beUpdatedTreatmentRecordWeight.setRstTareInfo("{\"11\": {\"unit\": null, \"value\": \"0400\"}, \"12\": {\"unit\": null, \"value\": 3}}");
    beUpdatedTreatmentRecordWeight.setRstOffWaterInfo("{\"21\": {\"unit\": null, \"value\": \"0400\"}, \"22\": {\"unit\": null, \"value\": 3}}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordWeight);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/weight/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の体重情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("rst_weight_info").description("実績：体重情報")
          , fieldWithPath("rst_tare_info").description("実績：風袋補正")
          , fieldWithPath("rst_off_water_info").description("実績：除水補正")
          , fieldWithPath("last_weight").ignored()
          , fieldWithPath("rst_dw").ignored()
          , fieldWithPath("target_weight").ignored()
          , fieldWithPath("water_removal_amount_limit").ignored()
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の治療条件を検証
    final TreatmentRecordWeight updatedTreatmentRecordWeight = treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo);
    assertThat(updatedTreatmentRecordWeight.getRstWeightInfo()).isEqualTo("{\"weight_after_date\": \"2019-04-01T11:00:00.000+09:00\", \"weight_before_date\": \"2019-04-01T09:00:00.000+09:00\"}");
    assertThat(updatedTreatmentRecordWeight.getRstTareInfo()).isEqualTo("{\"11\": {\"unit\": null, \"value\": \"0400\"}, \"12\": {\"unit\": null, \"value\": 3}}");
    assertThat(updatedTreatmentRecordWeight.getRstOffWaterInfo()).isEqualTo("{\"21\": {\"unit\": null, \"value\": \"0400\"}, \"22\": {\"unit\": null, \"value\": 3}}");
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_失敗_治療記録マスタに存在しないOrdNoを指定した場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 32L;
    final Long notExistOrdNo = 100L; // 存在しないオーダ番号
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo);
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-04-01T11:00:00.000+09:00\", \"weight_before_date\": \"2019-04-01T09:00:00.000+09:00\"}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordWeight);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/weight", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isConflict())
      .andDo(document("treatment_record/weight/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * 条件: オーダ番号に該当するレコードが削除済みレコード（is_del='1'）であること
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_失敗_治療記録が削除済みの場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 32L;
    final Long deletedOrdNo = 12L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo);
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-04-01T11:00:00.000+09:00\", \"weight_before_date\": \"2019-04-01T09:00:00.000+09:00\"}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordWeight);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/weight", deletedOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isConflict());
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * 条件: リクエストに測定日時が入力されていないこと
   * 結果: HTTPステータス400が返ってくること
   */
  @Test
  @Ignore
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_失敗_測定日時が入力されていない場合_400が返ること() throws Exception {
    // arrange
    final Long ordNo = 21L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo);
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-04-01T11:00:00.000+09:00\"}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordWeight);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isBadRequest())
      .andDo(document("treatment_record/weight/put/required-be-empty",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )));
  }

  /**
   * updateTreatmentRecordWeight()の検証.
   * 条件: リクエストに測定日時が入力されていないこと
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordWeight_成功_測定日時が入力されていない場合_200が返ること() throws Exception {
    // arrange
    final Long ordNo = 21L;
    final TreatmentRecordWeight beUpdatedTreatmentRecordWeight = treatmentRecordDao.selectTreatmentRecordWeightByOrdNo(ordNo);
    beUpdatedTreatmentRecordWeight.setRstWeightInfo("{\"weight_after_date\": \"2019-04-01T11:00:00.000+09:00\"}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordWeight);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/weight", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/weight/put/required-be-empty",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )));
  }

  /**
   * getLatestOrdNo()の検証.
   * 条件: 患者ID、施設コードに該当する最新のレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getLatestOrdNo_成功_データあり() throws Exception {
    // arrange
    final Long patId = 101L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{pat_id}/latest-ord-no", patId)
      .contentType(MediaType.TEXT_PLAIN));

    result
      .andExpect(status().isOk())
      .andExpect(content().string("113"))

      .andDo(document("treatment_record/latest-ord-no/get/ok",
        pathParameters(
          parameterWithName("pat_id").description("[必須]患者ID")
        ),
        responseBody(
          attributes(
            key("description").value("概要：指定された患者IDとサインイン済みの施設コードに該当する最新の治療記録のオーダ番号を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)"),
            key("value-type").value("Long"),
            key("value-description").value("指定された患者IDに紐付く最新のオーダ番号（レスポンスはJSON形式でなく（値を表すパス名が存在しない）、値が直接設定されている）")
          )
        )))
    ;
  }

  /**
   * getLatestOrdNo()の検証.
   * 条件: 患者ID、施設コードに該当する最新のレコードが登録されていない
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getLatestOrdNo_成功_データなし() throws Exception {
    // arrange
    final Long patId = 901L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{pat_id}/latest-ord-no", patId)
      .contentType(MediaType.TEXT_PLAIN));

    result
      .andExpect(status().isOk())
      .andExpect(content().string(""))

      .andDo(document("treatment_record/latest-ord-no/get/ok-nodata"))
    ;
  }

  /**
   * getTreatmentRecordSummary()の検証.
   * 条件: オーダ番号に該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordSummary_成功() throws Exception {
    // arrange
    final Long ordNo = 201L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/summary", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$.treatment_date", is("2019/04/12(金)")))
      .andExpect(jsonPath("$.bed_name", is("ベッド１")))
      .andExpect(jsonPath("$.kur_name", is("クール１")))
      .andExpect(jsonPath("$.treatment_name", is("治療方法１")))

      .andDo(document("treatment_record/summary/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療概要を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main), 選択肢マスタ (mst_selector)")
          ),
          fieldWithPath("treatment_date").description("治療日"),
          fieldWithPath("bed_name").description("ベッド名"),
          fieldWithPath("kur_name").description("クール名"),
          fieldWithPath("treatment_name").description("治療方法名")
        )))
    ;
  }

  /**
   * getTreatmentRecordSummary()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていない
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordSummary_失敗_該当実績なし() throws Exception {
    // arrange
    final Long ordNo = 203L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/summary", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/summary/get/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )))
    ;
  }

  /**
   * getTreatmentRecordSummary()の検証.
   * 条件: オーダ番号に該当するレコードが削除済み
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordSummary_失敗_該当実績削除済み() throws Exception {
    // arrange
    final Long ordNo = 202L;

    // action
    ResultActions result
      = mockMvc.perform(get("/api/treatment-record/{ord_no}/summary", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
    ;
  }

  /**
   * getTreatmentRecordAddition()の検証
   * 条件: 治療情報に存在するOrdNoを指定する
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordAddition.before.sql")
  public void test_getTreatmentRecordAddition_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/addition", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.pat_id", is(10)))
      .andExpect(jsonPath("$.facility_cd", is("009999")))
      .andExpect(jsonPath("$.treat_date", is("20190415")))
      .andExpect(jsonPath("$.rst_kur_cd", is(20)))
      .andExpect(jsonPath("$.rst_treatment_cd", is(30)))
      .andExpect(jsonPath("$.rst_ind_comment_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.up_date", is("2019-03-01T13:00:00.000+09:00")))
      .andExpect(jsonPath("$.operator_id", nullValue()))
      .andExpect(jsonPath("$.target_facility_cd", nullValue()))
      .andExpect(jsonPath("$.ind_kur_cd", nullValue()))
      .andExpect(jsonPath("$.ind_treatment_cd", nullValue()))
      .andDo(
        document("treatment_record/addition/get/ok",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定されたオーダ番号に該当する治療記録の実績: 指示コメント情報を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
            ),
            fieldWithPath("pat_id").description("患者ID")
            , fieldWithPath("facility_cd").description("施設コード")
            , fieldWithPath("treat_date").description("治療日")
            , fieldWithPath("rst_kur_cd").description("実績：クールコード")
            , fieldWithPath("rst_treatment_cd").description("実績：治療方法コード")
            , fieldWithPath("rst_ind_comment_info").description("実績：指示コメント")
            , fieldWithPath("up_date").description("更新日時(排他制御用)")
            , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
            , fieldWithPath("ind_kur_cd").description("指示：クールコード").optional()
            , fieldWithPath("ind_treatment_cd").description("指示：治療方法コード").optional()
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordAddition()の検証
   * 条件: 治療情報に存在しないオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordAddition.before.sql")
  public void test_getTreatmentRecordAddition_失敗_マスタに存在しないオーダ番号を指定する() throws Exception {
    // arrange
    final Long ordNo = 9999L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/addition", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/addition/get/not-found",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordAddition()の検証
   * 条件: 治療情報に存在し、削除（is_del='1'）に設定されているオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordAddition.before.sql")
  public void test_getTreatmentRecordAddition_失敗_削除に設定されているレコードを指定する() throws Exception {
    // arrange
    final Long ordNo = 2L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/addition", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/addition/get/set-deleted",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }


  /**
   * updateTreatmentRecordAddition()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordAddition_成功_治療記録のうち指示コメント情報を更新できること() throws Exception {
    // arrange
    final Long ordNo = 32L;
    final TreatmentRecordAddition beUpdatedTreatmentRecordAddition = new TreatmentRecordAddition();
    beUpdatedTreatmentRecordAddition.setRstIndCommentInfo("{\"11\": {\"unit\": null, \"value\": \"0400\"}, \"12\": {\"unit\": null, \"value\": 3}}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordAddition);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/addition", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/addition/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の指示コメント情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("rst_ind_comment_info").description("実績：指示コメント")
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("pat_id").ignored()
          , fieldWithPath("facility_cd").ignored()
          , fieldWithPath("treat_date").ignored()
          , fieldWithPath("rst_kur_cd").ignored()
          , fieldWithPath("rst_treatment_cd").ignored()
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
          , fieldWithPath("ind_kur_cd").description("指示:クールコード").optional()
          , fieldWithPath("ind_treatment_cd").description("指示:治療方法コード").optional()
        )
      ))
    ;

    // 更新後の指示コメント情報を検証
    final TreatmentRecordAddition updatedTreatmentRecordAddition = treatmentRecordDao.selectTreatmentRecordAdditionByOrdNo(ordNo);
    assertThat(updatedTreatmentRecordAddition.getRstIndCommentInfo()).isEqualTo("{\"11\": {\"unit\": null, \"value\": \"0400\"}, \"12\": {\"unit\": null, \"value\": 3}}");
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordAddition_失敗_治療記録テーブルに存在しないOrdNoを指定した場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 32L;
    final Long notExistOrdNo = 100L; // 存在しないオーダ番号
    final TreatmentRecordAddition beUpdatedTreatmentRecordAddition = treatmentRecordDao.selectTreatmentRecordAdditionByOrdNo(ordNo);
    beUpdatedTreatmentRecordAddition.setRstIndCommentInfo("{\"weight_after_date\": \"2019-04-01T11:00:00.000+09:00\", \"weight_before_date\": \"2019-04-01T09:00:00.000+09:00\"}");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordAddition);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/addition", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isConflict())
      .andDo(document("treatment_record/addition/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * updateTreatmentRecordAddition()の検証.
   * 条件: リクエストに指示コメント情報が入力されていないこと
   * 結果: HTTPステータス400が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordAddition_失敗_指示コメントが入力されていない場合_400が返ること() throws Exception {
    // arrange
    final Long ordNo = 21L;
    final TreatmentRecordAddition beUpdatedTreatmentRecordAddition = treatmentRecordDao.selectTreatmentRecordAdditionByOrdNo(ordNo);
    beUpdatedTreatmentRecordAddition.setRstIndCommentInfo("");

    final String requestBody = objectMapper.writeValueAsString(beUpdatedTreatmentRecordAddition);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/addition", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isBadRequest())
      .andDo(document("treatment_record/addition/put/required-be-empty",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )));
  }

  /**
   * getTreatmentRecordVitalMonitor()の検証.
   * 条件: オーダ番号に該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordVitalMonitor_正常_該当データあり() throws Exception{
    // arrange
    final Long ordNo = 11L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/vital-monitor", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$[0].bio_moni_ctl_no", is(23)))
      .andExpect(jsonPath("$[0].data_type", is(2)))
      .andExpect(jsonPath("$[0].monitor_data", is("{\"89\": 80}")))
      .andExpect(jsonPath("$[0].occur_date", is("2019-03-22T13:30:00.000+09:00")))
      .andExpect(jsonPath("$[0].upd_staff_id", is(3)))
      .andExpect(jsonPath("$[1].bio_moni_ctl_no", is(25)))
      .andExpect(jsonPath("$[1].data_type", is(4)))
      .andExpect(jsonPath("$[1].monitor_data", is("{\"89\": 90}")))
      .andExpect(jsonPath("$[1].occur_date", is("2019-03-22T15:00:00.000+09:00")))
      .andExpect(jsonPath("$[1].upd_staff_id", is(5)))
      .andExpect(jsonPath("$[2].bio_moni_ctl_no", is(26)))
      .andExpect(jsonPath("$[2].data_type", is(5)))
      .andExpect(jsonPath("$[2].monitor_data", is("{\"89\": 95}")))
      .andExpect(jsonPath("$[2].occur_date", is("2019-03-22T16:00:00.000+09:00")))
      .andExpect(jsonPath("$[2].upd_staff_id", is(6)))
      .andExpect(jsonPath("$[3].bio_moni_ctl_no", is(27)))
      .andExpect(jsonPath("$[3].data_type", is(6)))
      .andExpect(jsonPath("$[3].monitor_data", is("{\"89\": 100}")))
      .andExpect(jsonPath("$[3].occur_date", is("2019-03-22T17:00:00.000+09:00")))
      .andDo(document("treatment_record/vital-monitor/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する装置モニタデータ(バイタル)情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：装置モニタデータ (mni_monitor)")
          ),
          fieldWithPath("[]").description("装置モニタデータ(バイタル)情報"),
          fieldWithPath("[].bio_moni_ctl_no").description("生体モニタリング管理番号"),
          fieldWithPath("[].occur_date").description("発生日時"),
          fieldWithPath("[].monitor_data").description("モニタデータ"),
          fieldWithPath("[].data_type").description("データ種別"),
          fieldWithPath("[].upd_staff_id").description("更新者ID").optional(),
          fieldWithPath("[].user_last_name").description("更新者名（姓）").optional(),
          fieldWithPath("[].user_first_name").description("更新者名（名）").optional(),
          fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )))
    ;
  }

  /**
   * getTreatmentRecordMonitor()の検証.
   * 条件: オーダ番号に該当する治療記録レコード(透析開始日時設定あり)、装置モニタデータ共に登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMonitor.before.sql")
  public void test_getTreatmentRecordMonitor_正常_該当データあり() throws Exception{
    // arrange
    final Long ordNo = 90001L;

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/monitor", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())

      .andExpect(jsonPath("$[0].bio_moni_ctl_no", is(9000105)))
      .andExpect(jsonPath("$[0].monitor_data", is("{\"4\": \"004\"}")))
      .andExpect(jsonPath("$[0].occur_date", is("2019-05-24T12:15:00.000+09:00")))
      .andExpect(jsonPath("$[0].is_del", is("0")))

      .andExpect(jsonPath("$[1].bio_moni_ctl_no", is(9000107)))
      .andExpect(jsonPath("$[1].monitor_data", is("{\"6\": \"006\"}")))
      .andExpect(jsonPath("$[1].occur_date", is("2019-05-24T12:20:59.000+09:00")))
      .andExpect(jsonPath("$[1].is_del", is("0")))

      .andExpect(jsonPath("$[2].bio_moni_ctl_no", is(9000110)))
      .andExpect(jsonPath("$[2].monitor_data", is("{\"9\": \"009\"}")))
      .andExpect(jsonPath("$[2].occur_date", is("2019-05-24T12:40:00.000+09:00")))
      .andExpect(jsonPath("$[2].is_del", is("0")))

      .andExpect(jsonPath("$[3].bio_moni_ctl_no", is(9000111)))
      .andExpect(jsonPath("$[3].monitor_data", is("{\"10\": \"010\"}")))
      .andExpect(jsonPath("$[3].occur_date", is("2019-05-24T13:05:00.000+09:00")))
      .andExpect(jsonPath("$[3].is_del", is("0")))

      .andExpect(jsonPath("$[4].bio_moni_ctl_no", is(9000113)))
      .andExpect(jsonPath("$[4].monitor_data", is("{\"12\": \"012\"}")))
      .andExpect(jsonPath("$[4].occur_date", is("2019-05-24T13:26:00.000+09:00")))
      .andExpect(jsonPath("$[4].is_del", is("0")))

      .andDo(document("treatment_record/monitor/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する装置モニタデータ(モニタ)情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)、装置モニタデータ (mni_monitor)")
          ),
          fieldWithPath("[]").description("装置モニタデータ(モニタ)情報"),
          fieldWithPath("[].bio_moni_ctl_no").description("生体モニタリング管理番号"),
          fieldWithPath("[].occur_date").description("発生日時"),
          fieldWithPath("[].monitor_data").description("モニタデータ"),
          fieldWithPath("[].is_del").description("削除フラグ"),
          fieldWithPath("[].upd_staff_id").description("更新者ID").optional(),
          fieldWithPath("[].user_last_name").description("更新者名（姓）").optional(),
          fieldWithPath("[].user_first_name").description("更新者名（名）").optional(),
          fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )))
    ;
  }

  /**
   * getTreatmentRecordMonitor()の検証.
   * 条件: 該当データなしパターンを確認する
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordMonitor.before.sql")
  public void test_getTreatmentRecordMonitor_正常_該当データなし() throws Exception{

    // 治療記録レコード（透析開始日時設定）あり、装置モニタデータ該当なし
    {
      // arrange
      final Long ordNo = 90002L;

      // action
      validateNotFoundMonitor(ordNo);
    }

    // 治療記録レコード（透析開始日時設定）あり、装置モニタデータ全削除
    {
      // arrange
      final Long ordNo = 90003L;

      // action
      validateNotFoundMonitor(ordNo);
    }

    // 治療記録レコード（透析開始日時未設定）あり、装置モニタデータあり
    {
      // arrange
      final Long ordNo = 90004L;

      // action
      validateFoundMonitor(ordNo);
    }

    // 治療記録レコード削除済み
    {
      // arrange
      final Long ordNo = 90005L;

      // action
      validateNotFoundMonitor(ordNo);
    }

    // 治療記録レコード該当なし
    {
      // arrange
      final Long ordNo = 90006L;

      // action
      validateNotFoundMonitor(ordNo);
    }
  }

  /**
   * getTreatmentRecordMonitor()の該当データなしパターンを検証.
   * @param ordNo オーダ番号
   */
  private void validateNotFoundMonitor(final Long ordNo) throws Exception {
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/monitor", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }

  /**
   * getTreatmentRecordMonitor()の該当データなしパターンを検証.
   * @param ordNo オーダ番号
   */
  private void validateFoundMonitor(final Long ordNo) throws Exception {
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/monitor", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(1)))
    ;
  }

  /**
   * getTreatmentRecordSetting()の検証
   * 条件: なし
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordSetting.before.sql")
  public void test_getTreatmentRecordSetting_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/setting", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0].receive_date", is("2019-03-21T18:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].treat_condition", is("{\"a\": \"aaa\", \"b\": \"bbb\"}")))
      .andExpect(jsonPath("$[0].treat_class", is(2)))
      .andExpect(jsonPath("$[1].receive_date", is("2019-03-22T14:35:00.000+09:00")))
      .andExpect(jsonPath("$[1].treat_condition", is("{\"a\": \"aaa\", \"b\": \"bbb\"}")))
      .andExpect(jsonPath("$[1].treat_class", is(0)))
      .andExpect(jsonPath("$[2].receive_date", is("2019-03-23T21:35:00.000+09:00")))
      .andExpect(jsonPath("$[2].treat_condition", is("{\"a\": \"aaa\", \"b\": \"bbb\"}")))
      .andExpect(jsonPath("$[2].treat_class", is(1)))
      .andDo(
        document("treatment_record/setting/get/ok",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定されたオーダ番号に該当する設定値読み込み履歴情報を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：設定値読み込み履歴 (ord_treat_condition)")
            ),
            fieldWithPath("[]").description("設定値読み込み履歴")
            , fieldWithPath("[].receive_date").description("条件取得日時")
            , fieldWithPath("[].treat_condition").description("治療条件")
            , fieldWithPath("[].treat_class").description("区分")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordDeviceSetInfo()の検証
   * 条件: 治療情報に存在するOrdNoを指定する
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordDeviceSetInfo.before.sql")
  public void test_getTreatmentRecordDeviceSetInfo_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/rst-device-set-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_device_set_info", is("{\"cd\": 11, \"name\": \"name11\"}")))
      .andExpect(jsonPath("$.pat_id", is(11)))
      .andExpect(jsonPath("$.facility_cd", is("009999")))
      .andDo(
        document("treatment_record/rst-device-set-info/get/ok",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定されたオーダ番号に該当する治療記録の装置設定情報を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
            ),
            fieldWithPath("rst_device_set_info").description("実績：装置設定情報")
            , fieldWithPath("pat_id").description("システムで管理する一意な患者ID")
            , fieldWithPath("facility_cd").description("施設コード")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordDeviceSetInfo()の検証
   * 条件: 治療情報に存在しないオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordDeviceSetInfo.before.sql")
  public void test_getTreatmentRecordDeviceSetInfo_失敗_マスタに存在しないオーダ番号を指定する() throws Exception {
    // arrange
    final Long ordNo = 9999L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/rst-device-set-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/rst-device-set-info/get/not-found",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordDeviceSetInfo()の検証
   * 条件: 治療情報に存在し、削除（is_del='1'）に設定されているオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordDeviceSetInfo.before.sql")
  public void test_getTreatmentRecordDeviceSetInfo_失敗_削除に設定されているレコードを指定する() throws Exception {
    // arrange
    final Long ordNo = 2L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/rst-device-set-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/rst-device-set-info/get/set-deleted",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordRoundsInfo()の検証
   * 条件: 治療情報に存在するOrdNoを指定する
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordRoundsInfo.before.sql")
  public void test_getTreatmentRecordRoundsInfo_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/rst-rounds-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_rounds_info", is("{\"cd\": 11, \"name\": \"name11\"}")))
      .andExpect(jsonPath("$.up_date", is("2019-04-05T16:18:01.000+09:00")))
      .andDo(
        document("treatment_record/rst-rounds-info/get/ok",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定されたオーダ番号に該当する治療記録の回診記録情報を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
            ),
            fieldWithPath("rst_rounds_info").description("実績：回診記録情報")
            , fieldWithPath("up_date").description("更新日時(排他制御用)")
            , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordRoundsInfo()の検証
   * 条件: 治療情報に存在しないオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordRoundsInfo.before.sql")
  public void test_getTreatmentRecordRoundsInfo_失敗_マスタに存在しないオーダ番号を指定する() throws Exception {
    // arrange
    final Long ordNo = 9999L;

    // action
    mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/rst-rounds-info", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/rst-rounds-info/get/not-found",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * updateTreatmentRecordRoundsInfo()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordRoundsInfo_成功_治療記録のうち回診記録情報を更新できること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    TreatmentRecordRoundsInfo beforeUpdateTreatmentRecordRoundsInfo = new TreatmentRecordRoundsInfo();
    beforeUpdateTreatmentRecordRoundsInfo.setRstRoundsInfo("{\"cd\": 1, \"name\": \"name1\"}");

    final String requestBody = objectMapper.writeValueAsString(beforeUpdateTreatmentRecordRoundsInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/rst-rounds-info", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/rst-rounds-info/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の回診記録情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("rst_rounds_info").description("実績：回診記録情報")
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の回診記録情報を検証
    final TreatmentRecordRoundsInfo updatedTreatmentRecordRoundsInfo = treatmentRecordDao.selectTreatmentRecordRoundsInfoByOrdNo(ordNo);
    assertThat(updatedTreatmentRecordRoundsInfo.getRstRoundsInfo()).isEqualTo("{\"cd\": 1, \"name\": \"name1\"}");
  }

  /**
   * updateTreatmentRecordRoundsInfo()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス500が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordRoundsInfo_失敗_治療記録テーブルに存在しないOrdNoを指定した場合_500が返ること() throws Exception {
    // arrange
    final Long notExistOrdNo = 100L; // 存在しないオーダ番号
    TreatmentRecordRoundsInfo beforeUpdateTreatmentRecordRoundsInfo = new TreatmentRecordRoundsInfo();
    beforeUpdateTreatmentRecordRoundsInfo.setRstRoundsInfo("{\"cd\": 1, \"name\": \"name1\"}");

    final String requestBody = objectMapper.writeValueAsString(beforeUpdateTreatmentRecordRoundsInfo);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/rst-rounds-info", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/rst-rounds-info/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * getResultMergeList()の検証.
   * 条件: オーダ番号に該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.before.sql")
  @Sql(
    value = "classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.personal.before.sql",
    config = @SqlConfig(dataSource = PERSONAL,transactionManager = CoreConstant.TransactionManagerName.PERSONAL)
  )
  public void test_getResultMergeList_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/result-merge", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$[0].ord_no", is(1)))
      .andExpect(jsonPath("$[0].pat_id", is(2)))
      .andExpect(jsonPath("$[0].hosp_pat_id", is("000000000002")))
      .andExpect(jsonPath("$[0].pat_name", is("山田 花子")))
      .andExpect(jsonPath("$[0].rst_input_class", is(1)))
      .andExpect(jsonPath("$[0].rst_dialysis_state", is("3")))
      .andExpect(jsonPath("$[0].rst_treatment_cd", is("1")))
      .andExpect(jsonPath("$[0].rst_treatment_name", is("テスト治療方法")))
      .andExpect(jsonPath("$[0].rst_kur_cd", is(1)))
      .andExpect(jsonPath("$[0].rst_kur_name", is("テストクール名")))
      .andExpect(jsonPath("$[0].rst_bed_cd", is(2)))
      .andExpect(jsonPath("$[0].rst_bed_name", is("テストベッド名")))
      .andExpect(jsonPath("$[0].rst_machine_name", is("テスト装置名")))
      .andExpect(jsonPath("$[0].rst_cond_send_date", is("2019-06-26T09:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].rst_accept_date", is("2019-06-26T09:30:00.000+09:00")))
      .andExpect(jsonPath("$[0].rst_start_date", is("2019-06-26T10:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].rst_end_date", is("2019-06-26T13:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].rst_return_home_date", is("2019-06-26T14:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].rst_in_out_class", is(0)))
      .andExpect(jsonPath("$[0].rst_dialysis_cnt", is(2)))
      .andExpect(jsonPath("$[0].rst_ward_cd", is(3)))
      .andExpect(jsonPath("$[0].rst_ward_name", is("テスト病棟名")))
      .andExpect(jsonPath("$[0].rst_course_cd", is(4)))
      .andExpect(jsonPath("$[0].rst_course_name", is("テスト診療科名")))
      .andExpect(jsonPath("$[0].rst_dw", is(55.3)))
      .andExpect(jsonPath("$[0].rst_puncture_user_info", is("{\"date\": \"2019-02-13T13:00:00.000+09:00\", \"date_1\": \"2019-02-13T14:00:00.000+09:00\", \"date_2\": \"2019-02-13T15:00:00.000+09:00\", \"user_id_1\": 101, \"user_id_2\": 102, \"user_last_name_1\": \"穿刺1\", \"user_last_name_2\": \"穿刺2\", \"user_first_name_1\": \"太郎\", \"user_first_name_2\": \"次郎\"}")))
      .andExpect(jsonPath("$[0].rst_return_user_info", is("{\"date\": \"2019-02-13T13:30:00.000+09:00\", \"date_1\": \"2019-02-13T14:30:00.000+09:00\", \"date_2\": \"2019-02-13T15:30:00.000+09:00\", \"user_id_1\": 103, \"user_id_2\": 104, \"user_last_name_1\": \"返血1\", \"user_last_name_2\": \"返血2\", \"user_first_name_1\": \"太郎\", \"user_first_name_2\": \"次郎\"}")))
      .andExpect(jsonPath("$[0].rst_charge_user_info", is("{\"date_1\": \"2019-02-14T14:30:00.000+09:00\", \"date_2\": \"2019-02-14T15:30:00.000+09:00\", \"user_id_1\": 105, \"user_id_2\": 106, \"user_last_name_1\": \"担当1\", \"user_last_name_2\": \"担当2\", \"user_first_name_1\": \"太郎\", \"user_first_name_2\": \"次郎\"}")))
      .andExpect(jsonPath("$[0].rst_blood_circulate_total", is(200.24)))
      .andExpect(jsonPath("$[0].rst_running_time", is(180)))
      .andExpect(jsonPath("$[0].rst_kt_v", is(7.5)))
      .andExpect(jsonPath("$[0].rec_set_date", is("2019-06-26T15:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].send_ctl_no", is(5)))
      .andExpect(jsonPath("$[0].blood_purifier_name", is("テスト浄化装置")))
      .andExpect(jsonPath("$[0].pull_leave_amount", is(8.3)))
      .andExpect(jsonPath("$[0].rst_cond_info", is("{\"1\": {\"unit\": null, \"value\": \"0400\", \"ind_user_id\": 101, \"input_class\": 1, \"is_editable\": 1, \"upd_user_id\": 201, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"value_name_3\": null, \"value_name_4\": null, \"value_name_5\": null, \"value_name_6\": null, \"value_name_7\": null, \"value_name_8\": null, \"value_name_9\": null, \"medicine_type\": null, \"value_name_10\": null, \"ind_user_last_name\": \"yamada\", \"upd_user_last_name\": \"tanaka\", \"ind_user_first_name\": \"taro1\", \"upd_user_first_name\": \"hanako1\"}}")))
      .andExpect(jsonPath("$[0].rst_medi_info", is("[{\"cd\": 1, \"no\": 1, \"name\": \"テスト抗凝固剤１\", \"unit\": \"抗\", \"amount\": 2, \"comment\": \"コメント\", \"class_cd\": 1, \"timing_cd\": 2, \"class_name\": \"抗凝固剤\", \"class_type\": 1, \"effect_flg\": 0, \"short_name\": \"\", \"effect_date\": \"\", \"ind_user_id\": 101, \"input_class\": 1, \"is_editable\": 1, \"timing_name\": \"透析中\", \"upd_user_id\": 102, \"cop_order_no\": 1, \"procedure_cd\": 3, \"medicine_type\": 1, \"effect_user_id\": 103, \"procedure_name\": \"静脈側回路内注射\", \"ind_user_last_name\": \"指示者1\", \"upd_user_last_name\": \"更新者1\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"次郎\", \"effect_user_last_name\": \"実施者1\", \"effect_user_first_name\": \"三郎\"}]")))
      .andExpect(jsonPath("$[0].rst_equip_info", is("[{\"cd\": 2, \"name\": \"テスト吸着カラム\", \"unit\": \"本\", \"amount\": 5, \"class_cd\": 3, \"class_name\": \"吸着カラム\", \"class_type\": 4, \"short_name\": \"\", \"ind_user_id\": 101, \"input_class\": 1, \"is_editable\": 1, \"needle_type\": 0, \"upd_user_id\": 102, \"cop_order_no\": 1, \"ind_user_last_name\": \"指示者1\", \"upd_user_last_name\": \"更新者1\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"次郎\"}]")))
      .andExpect(jsonPath("$[0].rst_ind_comment_info", is("[{\"no\": 1, \"content\": \"指示コメント１\", \"ind_user_id\": 1, \"input_class\": 1, \"is_editable\": \"1\", \"upd_user_id\": 1, \"cop_order_no\": \"1\", \"ind_user_last_name\": \"山田\", \"upd_user_last_name\": \"山田\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"太郎\"}]")))
      .andExpect(jsonPath("$[0].rst_tare_info", is("{\"after\": {\"name_1\": \"[後]スリッパ\", \"name_2\": \"[後]服\", \"name_3\": \"[後]義足\", \"name_4\": \"[後]その他風袋１\", \"name_5\": \"[後]その他風袋２\", \"weight_1\": 310, \"weight_2\": 1210, \"weight_3\": 410, \"weight_4\": 410, \"weight_5\": 12910, \"wheel_chair_cd\": \"1\", \"wheel_chair_name\": \"[後]車いす\", \"wheel_chair_weight\": 3510}, \"before\": {\"name_1\": \"[前]スリッパ\", \"name_2\": \"[前]服\", \"name_3\": \"[前]義足\", \"name_4\": \"[前]その他風袋１\", \"name_5\": \"[前]その他風袋２\", \"weight_1\": 300, \"weight_2\": 1200, \"weight_3\": 400, \"weight_4\": 400, \"weight_5\": 12900, \"wheel_chair_cd\": \"1\", \"wheel_chair_name\": \"[前]車いす\", \"wheel_chair_weight\": 3500}}")))
      .andExpect(jsonPath("$[0].rst_off_water_info", is("{\"name_1\": \"除水補正１\", \"name_2\": \"除水補正２\", \"name_3\": \"除水補正３\", \"name_4\": \"除水補正４\", \"name_5\": \"除水補正５\", \"weight_1\": 300, \"weight_2\": 1200, \"weight_3\": 600, \"weight_4\": 1200, \"weight_5\": 1500}")))
      .andExpect(jsonPath("$[0].rst_device_set_info", is("{\"bp\": {\"dev\": {\"A\": {\"190\": 30, \"191\": \"0\", \"192\": 180, \"193\": \"1\", \"194\": \"0\", \"195\": \"1\", \"211\": 200, \"212\": 80, \"213\": 160, \"214\": 50, \"215\": 180, \"216\": 60, \"217\": 170, \"218\": 50, \"219\": \"1\", \"220\": \"1\", \"221\": \"1\", \"222\": \"1\", \"223\": \"1\", \"224\": \"1\", \"225\": \"1\", \"226\": \"1\", \"227\": 40, \"228\": 40, \"229\": 0, \"230\": 0, \"231\": 0, \"232\": 0, \"233\": 0, \"234\": 0, \"235\": 0, \"236\": 0, \"237\": \"0\", \"238\": \"0\", \"239\": \"1\"}}}}")))
      .andExpect(jsonPath("$[0].weight_scale_no", is(302)))
      .andExpect(jsonPath("$[0].rst_weight_info", is("{\"ctr\": 11, \"urr\": 17, \"add_total\": 14, \"ctr_weight\": 72, \"kt_v_measure\": 16, \"weight_after\": 59.2, \"weight_before\": 60, \"re_loop_rate_1\": {\"date\": \"2019-03-20T09:00:00+09:00\", \"value\": 50}, \"re_loop_rate_2\": {\"date\": \"2019-03-20T09:10:00+09:00\", \"value\": 55}, \"re_loop_rate_3\": {\"date\": \"2019-03-20T09:20:00+09:00\", \"value\": 60}, \"re_loop_rate_4\": {\"date\": \"2019-03-20T09:30:00+09:00\", \"value\": 65}, \"re_loop_rate_5\": {\"date\": \"2019-03-20T09:40:00+09:00\", \"value\": 70}, \"add_water_total\": 15, \"ctr_measure_date\": \"2019-03-20T12:10:05.055+09:00\", \"weight_decreased\": 18, \"re_loop_rate_main\": 11, \"water_removal_rst\": 13, \"weight_after_date\": \"2019-03-20T15:30:00.000+09:00\", \"weight_before_date\": \"2018-04-04T00:00:00.000+09:00\", \"water_removal_target\": 12, \"weight_measure_after\": 58.9, \"weight_measure_before\": 60.28}")))
      .andExpect(jsonPath("$[0].rst_vital_info", is("[{\"pulse\": 60, \"bp_ave\": 125, \"bp_max\": 150, \"bp_min\": 90, \"is_del\": \"0\", \"bp_class\": \"1\", \"occur_date\": \"2019-05-10T13:02:00.000+09:00\", \"temperature\": 36.3, \"bio_moni_ctl_no\": 39, \"blood_sugar_level\": 120}]")))
      .andExpect(jsonPath("$[0].rst_complaint_info", is("[{\"ctl_no\": 1, \"comp_cd\": 1, \"complaint\": \"筋肉のつれ\", \"occur_date\": \"2019-03-27T13:50:00.000+09:00\", \"input_class\": 0}]")))
      .andExpect(jsonPath("$[0].rst_treatment_info", is("[{\"unit\": null, \"amount\": null, \"ctl_no\": 1, \"row_no\": 1, \"treat_cd\": 1, \"occur_date\": \"2019-03-27T13:50:00.000+09:00\", \"treat_name\": \"下肢拳上\", \"input_class\": 0, \"is_editable\": \"1\", \"medicine_cd\": null, \"oxygen_time\": null, \"treat_class\": 1, \"cop_order_no\": 1, \"oxygen_speed\": null, \"oxygen_start\": null, \"procedure_cd\": null, \"medicine_name\": null, \"oxygen_amount\": null, \"procedure_name\": null, \"treat_medicine_cd\": null, \"treat_medicine_name\": null, \"electrocardiogram_type\": null}]")))
      .andExpect(jsonPath("$[0].rst_treat_staff_info", is("[{\"ctl_no\": 1, \"row_no\": 1, \"occur_date\": \"2019-03-27T13:50:00.000+09:00\", \"input_class\": 0, \"is_editable\": \"1\", \"cop_order_no\": 1, \"treat_staff_cd\": 1, \"treat_staff_name\": \"スタッフ００１\"}]")))
      .andExpect(jsonPath("$[0].rst_rounds_info", is("[{\"ctl_no\": 1, \"content\": \"内容1\"}]")))
      .andExpect(jsonPath("$[0].up_date", is("2019-06-26T19:00:00.000+09:00")))
      .andExpect(jsonPath("$[0].rst_purification_cnt", is(2)))
      .andExpect(jsonPath("$[0].operator_id", nullValue()))
      .andExpect(jsonPath("$[0].target_facility_cd", nullValue()))

      .andDo(document("treatment_record/result-merge/get/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の実績マージ情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("[]").description("実績マージ情報リスト"),
          fieldWithPath("[].ord_no").description("オーダ番号"),
          fieldWithPath("[].pat_id").description("患者ID"),
          fieldWithPath("[].hosp_pat_id").description("院内表示用の患者ID"),
          fieldWithPath("[].pat_name").description("患者名"),
          fieldWithPath("[].rst_input_class").description("登録区分"),
          fieldWithPath("[].rst_dialysis_state").description("治療状況"),
          fieldWithPath("[].rst_treatment_cd").description("治療方法コード"),
          fieldWithPath("[].rst_treatment_name").description("治療方法名"),
          fieldWithPath("[].rst_kur_cd").description("クールコード"),
          fieldWithPath("[].rst_kur_name").description("クール名"),
          fieldWithPath("[].rst_bed_cd").description("ベッドコード"),
          fieldWithPath("[].rst_bed_name").description("ベッド名"),
          fieldWithPath("[].rst_machine_name").description("装置名"),
          fieldWithPath("[].rst_cond_send_date").description("条件送信日時(ISO8601形式文字列)"),
          fieldWithPath("[].rst_accept_date").description("受付日時(ISO8601形式文字列)"),
          fieldWithPath("[].rst_start_date").description("治療開始日時(ISO8601形式文字列)"),
          fieldWithPath("[].rst_end_date").description("治療終了日時(ISO8601形式文字列)"),
          fieldWithPath("[].rst_return_home_date").description("帰宅日時(ISO8601形式文字列)"),
          fieldWithPath("[].rst_in_out_class").description("入外区分"),
          fieldWithPath("[].rst_dialysis_cnt").description("透析回数").optional(),
          fieldWithPath("[].rst_ward_cd").description("病棟コード"),
          fieldWithPath("[].rst_ward_name").description("病棟名"),
          fieldWithPath("[].rst_course_cd").description("診療科コード"),
          fieldWithPath("[].rst_course_name").description("診療科名"),
          fieldWithPath("[].rst_dw").description("DW"),
          fieldWithPath("[].rst_puncture_user_info").description("穿刺者情報"),
          fieldWithPath("[].rst_return_user_info").description("返血者情報"),
          fieldWithPath("[].rst_charge_user_info").description("担当者情報"),
          fieldWithPath("[].rst_blood_circulate_total").description("血液循環積算値"),
          fieldWithPath("[].rst_running_time").description("透析運転時間"),
          fieldWithPath("[].rst_kt_v").description("Kt/V"),
          fieldWithPath("[].rec_set_date").description("透析記録確認日時(ISO8601形式文字列)"),
          fieldWithPath("[].send_ctl_no").description("送信管理番号"),
          fieldWithPath("[].blood_purifier_name").description("血液浄化装置名称"),
          fieldWithPath("[].pull_leave_amount").description("プログラム補液引き残し量"),
          fieldWithPath("[].rst_cond_info").description("治療条件情報"),
          fieldWithPath("[].rst_medi_info").description("投与薬剤情報"),
          fieldWithPath("[].rst_equip_info").description("医療材料情報"),
          fieldWithPath("[].rst_ind_comment_info").description("指示コメント情報"),
          fieldWithPath("[].rst_tare_info").description("風袋補正"),
          fieldWithPath("[].rst_off_water_info").description("除水補正"),
          fieldWithPath("[].rst_device_set_info").description("装置設定情報"),
          fieldWithPath("[].weight_scale_no").description("体重測定記録番号"),
          fieldWithPath("[].rst_weight_info").description("体重情報"),
          fieldWithPath("[].rst_vital_info").description("バイタル情報"),
          fieldWithPath("[].rst_complaint_info").description("愁訴情報"),
          fieldWithPath("[].rst_treatment_info").description("愁訴処置情報"),
          fieldWithPath("[].rst_treat_staff_info").description("愁訴処置者情報"),
          fieldWithPath("[].rst_rounds_info").description("回診記録情報"),
          fieldWithPath("[].up_date").description("更新日時(排他制御用)"),
          fieldWithPath("[].merge_ord_no").description("マージ元のオーダ番号").optional(),
          fieldWithPath("[].upd_staff_id").description("更新者ID").optional(),
          fieldWithPath("[].monitor_merge").type(Boolean.class).description("モニタ情報のマージ有無(true:マージする、false:マージしない)").optional(),
          fieldWithPath("[].vital_merge").type(Boolean.class).description("バイタル情報のマージ有無(true:マージする、false:マージしない)").optional(),
          fieldWithPath("[].rst_purification_cnt").description("特殊浄化回数").optional(),
          fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )))
    ;
  }

  /**
   * getResultMergeList()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていない
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.before.sql")
  public void test_getResultMergeList_失敗_該当データなし() throws Exception {
    // arrange
    final Long ordNo = Long.MAX_VALUE;

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/result-merge/get/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )))
    ;
  }

  /**
   * getResultMergeList()の検証.
   * 条件: オーダ番号に該当するレコードが削除済み
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.before.sql")
  public void test_getResultMergeList_失敗_該当データ削除済み() throws Exception {
    // arrange
    final Long ordNo = 2L;

    // action
    ResultActions result = mockMvc
      .perform(get("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isInternalServerError())
    ;
  }

  /**
   * updateResultMerge()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.before.sql")
  public void test_updateResultMerge_成功_治療記録のうち実績マージ情報を更新できること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final TreatmentRecordResultMerge beUpdated = treatmentRecordDao.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);

    beUpdated.setOrdNo(99L);
    beUpdated.setPatId(99L);
    beUpdated.setHospPatId("000000000099");
    beUpdated.setPatName("テスト患者");
    beUpdated.setRstInputClass(2);
    beUpdated.setRstDialysisState("4");
    beUpdated.setRstTreatmentName("テスト治療方法2");
    beUpdated.setRstKurCd(2L);
    beUpdated.setRstKurName("テストクール名2");
    beUpdated.setRstBedCd(3L);
    beUpdated.setRstBedName("テストベッド名2");
    beUpdated.setRstMachineName("テスト装置名2");
    beUpdated.setRstCondSendDate(Timestamp.valueOf("2019-06-27 09:00:00"));
    beUpdated.setRstAcceptDate(Timestamp.valueOf("2019-06-27 09:30:00"));
    beUpdated.setRstStartDate(Timestamp.valueOf("2019-06-27 10:00:00"));
    beUpdated.setRstEndDate(Timestamp.valueOf("2019-06-27 13:00:00"));
    beUpdated.setRstReturnHomeDate(Timestamp.valueOf("2019-06-27 14:00:00"));
    beUpdated.setRstInOutClass(1);
    beUpdated.setRstDialysisCnt(3);
    beUpdated.setRstWardCd(4);
    beUpdated.setRstWardName("テスト病棟名2");
    beUpdated.setRstCourseCd(5);
    beUpdated.setRstCourseName("テスト診療科名2");
    beUpdated.setRstDw(new BigDecimal("66.30"));
    beUpdated.setRstPunctureUserInfo("{\"date\": \"2019-02-13T13:00:00.000+09:00\", \"date_1\": \"2019-02-13T14:00:00.000+09:00\", \"user_id_1\": 101, \"user_last_name_1\": \"穿刺1\", \"user_first_name_1\": \"太郎\"}");
    beUpdated.setRstReturnUserInfo("{\"date\": \"2019-02-13T13:30:00.000+09:00\", \"date_1\": \"2019-02-13T14:30:00.000+09:00\", \"user_id_1\": 103, \"user_last_name_1\": \"返血1\", \"user_first_name_1\": \"太郎\"}");
    beUpdated.setRstChargeUserInfo("{\"date_1\": \"2019-02-14T14:30:00.000+09:00\", \"user_id_1\": 105, \"user_last_name_1\": \"担当1\", \"user_first_name_1\": \"太郎\"}");
    beUpdated.setRstBloodCirculateTotal(new BigDecimal("201.24"));
    beUpdated.setRstRunningTime(181);
    beUpdated.setRstKtV(new BigDecimal("8.50"));
    beUpdated.setRecSetDate(Timestamp.valueOf("2019-06-27 16:00:00"));
    beUpdated.setSendCtlNo(6L);
    beUpdated.setBloodPurifierName("テスト浄化装置2");
    beUpdated.setPullLeaveAmount(new BigDecimal("9.30"));
    beUpdated.setRstCondInfo("{\"2\": {\"unit\": null, \"value\": \"0400\", \"ind_user_id\": 101, \"input_class\": 1, \"is_editable\": 1, \"upd_user_id\": 201, \"cop_order_no\": null, \"value_name_1\": null, \"value_name_2\": null, \"value_name_3\": null, \"value_name_4\": null, \"value_name_5\": null, \"value_name_6\": null, \"value_name_7\": null, \"value_name_8\": null, \"value_name_9\": null, \"medicine_type\": null, \"value_name_10\": null, \"ind_user_last_name\": \"yamada\", \"upd_user_last_name\": \"tanaka\", \"ind_user_first_name\": \"taro1\", \"upd_user_first_name\": \"hanako1\"}}");
    beUpdated.setRstMediInfo("[{\"cd\": 2, \"no\": 1, \"name\": \"テスト抗凝固剤１\", \"unit\": \"抗\", \"amount\": 2, \"comment\": \"コメント\", \"class_cd\": 1, \"timing_cd\": 2, \"class_name\": \"抗凝固剤\", \"class_type\": 1, \"effect_flg\": 0, \"short_name\": \"\", \"effect_date\": \"\", \"ind_user_id\": 101, \"input_class\": 1, \"is_editable\": 1, \"timing_name\": \"透析中\", \"upd_user_id\": 102, \"cop_order_no\": 1, \"procedure_cd\": 3, \"medicine_type\": 1, \"effect_user_id\": 103, \"procedure_name\": \"静脈側回路内注射\", \"ind_user_last_name\": \"指示者1\", \"upd_user_last_name\": \"更新者1\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"次郎\", \"effect_user_last_name\": \"実施者1\", \"effect_user_first_name\": \"三郎\"}]");
    beUpdated.setRstEquipInfo("[{\"cd\": 3, \"name\": \"テスト吸着カラム\", \"unit\": \"本\", \"amount\": 5, \"class_cd\": 3, \"class_name\": \"吸着カラム\", \"class_type\": 4, \"short_name\": \"\", \"ind_user_id\": 101, \"input_class\": 1, \"is_editable\": 1, \"needle_type\": 0, \"upd_user_id\": 102, \"cop_order_no\": 1, \"ind_user_last_name\": \"指示者1\", \"upd_user_last_name\": \"更新者1\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"次郎\"}]");
    beUpdated.setRstIndCommentInfo("[{\"no\": 2, \"content\": \"指示コメント１\", \"ind_user_id\": 1, \"input_class\": 1, \"is_editable\": \"1\", \"upd_user_id\": 1, \"cop_order_no\": \"1\", \"ind_user_last_name\": \"山田\", \"upd_user_last_name\": \"山田\", \"ind_user_first_name\": \"太郎\", \"upd_user_first_name\": \"太郎\"}]");
    beUpdated.setRstTareInfo("{\"after\": {\"name_1\": \"[後]スリッパ2\", \"name_2\": \"[後]服\", \"name_3\": \"[後]義足\", \"name_4\": \"[後]その他風袋１\", \"name_5\": \"[後]その他風袋２\", \"weight_1\": 310, \"weight_2\": 1210, \"weight_3\": 410, \"weight_4\": 410, \"weight_5\": 12910, \"wheel_chair_cd\": \"1\", \"wheel_chair_name\": \"[後]車いす\", \"wheel_chair_weight\": 3510}, \"before\": {\"name_1\": \"[前]スリッパ\", \"name_2\": \"[前]服\", \"name_3\": \"[前]義足\", \"name_4\": \"[前]その他風袋１\", \"name_5\": \"[前]その他風袋２\", \"weight_1\": 300, \"weight_2\": 1200, \"weight_3\": 400, \"weight_4\": 400, \"weight_5\": 12900, \"wheel_chair_cd\": \"1\", \"wheel_chair_name\": \"[前]車いす\", \"wheel_chair_weight\": 3500}}");
    beUpdated.setRstOffWaterInfo("{\"name_1\": \"除水補正１１\", \"name_2\": \"除水補正２\", \"name_3\": \"除水補正３\", \"name_4\": \"除水補正４\", \"name_5\": \"除水補正５\", \"weight_1\": 300, \"weight_2\": 1200, \"weight_3\": 600, \"weight_4\": 1200, \"weight_5\": 1500}");
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    beUpdated.setRstDeviceSetInfo("{\"bp1\": {\"dev\": {\"A\": {\"190\": 30, \"191\": \"0\", \"192\": 180, \"193\": \"1\", \"194\": \"0\", \"195\": \"1\", \"211\": 200, \"212\": 80, \"213\": 160, \"214\": 50, \"215\": 180, \"216\": 60, \"217\": 170, \"218\": 50, \"219\": \"1\", \"220\": \"1\", \"221\": \"1\", \"222\": \"1\", \"223\": \"1\", \"224\": \"1\", \"225\": \"1\", \"226\": \"1\", \"227\": 40, \"228\": 40, \"229\": 0, \"230\": 0, \"231\": 0, \"232\": 0, \"233\": 0, \"234\": 0, \"235\": 0, \"236\": 0, \"237\": \"0\", \"238\": \"0\", \"239\": \"1\"}}}}");
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    beUpdated.setWeightScaleNo(303L);
    beUpdated.setRstWeightInfo("{\"ctr\": 12, \"urr\": 17, \"add_total\": 14, \"ctr_weight\": 72, \"kt_v_measure\": 16, \"weight_after\": 59.2, \"weight_before\": 60, \"re_loop_rate_1\": {\"date\": \"2019-03-20T09:00:00+09:00\", \"value\": 50}, \"re_loop_rate_2\": {\"date\": \"2019-03-20T09:10:00+09:00\", \"value\": 55}, \"re_loop_rate_3\": {\"date\": \"2019-03-20T09:20:00+09:00\", \"value\": 60}, \"re_loop_rate_4\": {\"date\": \"2019-03-20T09:30:00+09:00\", \"value\": 65}, \"re_loop_rate_5\": {\"date\": \"2019-03-20T09:40:00+09:00\", \"value\": 70}, \"add_water_total\": 15, \"ctr_measure_date\": \"2019-03-20T12:10:05.055+09:00\", \"weight_decreased\": 18, \"re_loop_rate_main\": 11, \"water_removal_rst\": 13, \"weight_after_date\": \"2019-03-20T15:30:00.000+09:00\", \"weight_before_date\": \"2018-04-04T00:00:00.000+09:00\", \"water_removal_target\": 12, \"weight_measure_after\": 58.9, \"weight_measure_before\": 60.28}");
//    beUpdated.setRstVitalInfo("[{\"pulse\": 61, \"bp_ave\": 125, \"bp_max\": 150, \"bp_min\": 90, \"is_del\": \"0\", \"bp_class\": \"1\", \"occur_date\": \"2019-05-10T13:02:00.000+09:00\", \"temperature\": 36.3, \"bio_moni_ctl_no\": 39, \"blood_sugar_level\": 120}]");
    beUpdated.setRstComplaintInfo("[{\"ctl_no\": 2, \"comp_cd\": 1, \"complaint\": \"筋肉のつれ\", \"occur_date\": \"2019-03-27T13:50:00.000+09:00\", \"input_class\": 0}]");
    beUpdated.setRstTreatmentInfo("[{\"unit\": 1, \"amount\": null, \"ctl_no\": 1, \"row_no\": 1, \"treat_cd\": 1, \"occur_date\": \"2019-03-27T13:50:00.000+09:00\", \"treat_name\": \"下肢拳上\", \"input_class\": 0, \"is_editable\": \"1\", \"medicine_cd\": null, \"oxygen_time\": null, \"treat_class\": 1, \"cop_order_no\": 1, \"oxygen_speed\": null, \"oxygen_start\": null, \"procedure_cd\": null, \"medicine_name\": null, \"oxygen_amount\": null, \"procedure_name\": null, \"treat_medicine_cd\": null, \"treat_medicine_name\": null, \"electrocardiogram_type\": null}]");
    beUpdated.setRstTreatStaffInfo("[{\"ctl_no\": 2, \"row_no\": 1, \"occur_date\": \"2019-03-27T13:50:00.000+09:00\", \"input_class\": 0, \"is_editable\": \"1\", \"cop_order_no\": 1, \"treat_staff_cd\": 1, \"treat_staff_name\": \"スタッフ００１\"}]");
    beUpdated.setRstRoundsInfo("[{\"ctl_no\": 2, \"content\": \"内容1\"}]");
    beUpdated.setUpDate(Timestamp.valueOf("2019-06-26 19:00:00.000"));

    final String requestBody = objectMapper.writeValueAsString(beUpdated);

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result-merge", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/result-merge/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の実績オーダ情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("ord_no").ignored(),
          fieldWithPath("pat_id").ignored(),
          fieldWithPath("hosp_pat_id").ignored(),
          fieldWithPath("pat_name").ignored(),
          fieldWithPath("rst_input_class").ignored(),
          fieldWithPath("rst_dialysis_state").ignored(),
          fieldWithPath("rst_treatment_cd").ignored(),
          fieldWithPath("rst_treatment_name").ignored(),
          fieldWithPath("rst_kur_cd").description("クールコード"),
          fieldWithPath("rst_kur_name").description("クール名"),
          fieldWithPath("rst_bed_cd").description("ベッドコード"),
          fieldWithPath("rst_bed_name").description("ベッド名"),
          fieldWithPath("rst_machine_name").ignored(),
          fieldWithPath("rst_cond_send_date").description("条件送信日時(ISO8601形式文字列)"),
          fieldWithPath("rst_accept_date").description("受付日時(ISO8601形式文字列)"),
          fieldWithPath("rst_start_date").description("治療開始日時(ISO8601形式文字列)"),
          fieldWithPath("rst_end_date").description("治療終了日時(ISO8601形式文字列)"),
          fieldWithPath("rst_return_home_date").description("帰宅日時(ISO8601形式文字列)"),
          fieldWithPath("rst_in_out_class").description("入外区分"),
          fieldWithPath("rst_dialysis_cnt").description("透析回数"),
          fieldWithPath("rst_ward_cd").description("病棟コード"),
          fieldWithPath("rst_ward_name").description("病棟名"),
          fieldWithPath("rst_course_cd").description("診療科コード"),
          fieldWithPath("rst_course_name").description("診療科名"),
          fieldWithPath("rst_dw").ignored(),
          fieldWithPath("rst_puncture_user_info").description("穿刺者情報"),
          fieldWithPath("rst_return_user_info").description("返血者情報"),
          fieldWithPath("rst_charge_user_info").description("担当者情報"),
          fieldWithPath("rst_blood_circulate_total").description("血液循環積算値"),
          fieldWithPath("rst_running_time").description("透析運転時間"),
          fieldWithPath("rst_kt_v").description("Kt/V"),
          fieldWithPath("rec_set_date").description("透析記録確認日時(ISO8601形式文字列)"),
          fieldWithPath("send_ctl_no").description("送信管理番号"),
          fieldWithPath("blood_purifier_name").description("血液浄化装置名称"),
          fieldWithPath("pull_leave_amount").description("プログラム補液引き残し量"),
          fieldWithPath("rst_cond_info").description("治療条件情報"),
          fieldWithPath("rst_medi_info").description("投与薬剤情報"),
          fieldWithPath("rst_equip_info").description("医療材料情報"),
          fieldWithPath("rst_ind_comment_info").description("指示コメント情報"),
          fieldWithPath("rst_tare_info").description("風袋補正"),
          fieldWithPath("rst_off_water_info").description("除水補正"),
          fieldWithPath("rst_device_set_info").description("装置設定情報"),
          fieldWithPath("weight_scale_no").description("体重測定記録番号"),
          fieldWithPath("rst_weight_info").description("体重情報"),
          fieldWithPath("rst_vital_info").description("バイタル情報"),
          fieldWithPath("rst_complaint_info").description("愁訴情報"),
          fieldWithPath("rst_treatment_info").description("愁訴処置情報"),
          fieldWithPath("rst_treat_staff_info").description("愁訴処置者情報"),
          fieldWithPath("rst_rounds_info").description("回診記録情報"),
          fieldWithPath("up_date").description("更新日時(排他制御用)"),
          fieldWithPath("merge_ord_no").type(Long.class).description("マージ元のオーダ番号").optional(),
          fieldWithPath("upd_staff_id").type(Long.class).description("更新者ID").optional(),
          fieldWithPath("monitor_merge").type(Boolean.class).description("モニタ情報のマージ有無(true:マージする、false:マージしない)").optional(),
          fieldWithPath("vital_merge").type(Boolean.class).description("バイタル情報のマージ有無(true:マージする、false:マージしない)").optional(),
          fieldWithPath("rst_purification_cnt").description("特殊浄化回数").optional(),
          fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の治療記録（実績マージ情報）を検証
    final TreatmentRecordResultMerge updated = treatmentRecordDao.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);
    assertThat(updated.getOrdNo()).isEqualTo(1L);
    assertThat(updated.getPatId()).isEqualTo(2L);
    assertThat(updated.getHospPatId()).isNull();
    assertThat(updated.getPatName()).isNull();
    assertThat(updated.getRstInputClass()).isEqualTo(1);
    assertThat(updated.getRstDialysisState()).isEqualTo("3");
    assertThat(updated.getRstTreatmentName()).isEqualTo("テスト治療方法");
    assertThat(updated.getRstKurCd()).isEqualTo(beUpdated.getRstKurCd());
    assertThat(updated.getRstKurName()).isEqualTo(beUpdated.getRstKurName());
    assertThat(updated.getRstBedCd()).isEqualTo(beUpdated.getRstBedCd());
    assertThat(updated.getRstBedName()).isEqualTo(beUpdated.getRstBedName());
    assertThat(updated.getRstMachineName()).isEqualTo("テスト装置名");
    assertThat(updated.getRstCondSendDate()).isEqualTo(beUpdated.getRstCondSendDate());
    assertThat(updated.getRstAcceptDate()).isEqualTo(beUpdated.getRstAcceptDate());
    assertThat(updated.getRstStartDate()).isEqualTo(beUpdated.getRstStartDate());
    assertThat(updated.getRstEndDate()).isEqualTo(beUpdated.getRstEndDate());
    assertThat(updated.getRstReturnHomeDate()).isEqualTo(beUpdated.getRstReturnHomeDate());
    assertThat(updated.getRstInOutClass()).isEqualTo(beUpdated.getRstInOutClass());
    assertThat(updated.getRstDialysisCnt()).isEqualTo(beUpdated.getRstDialysisCnt());
    assertThat(updated.getRstWardCd()).isEqualTo(beUpdated.getRstWardCd());
    assertThat(updated.getRstWardName()).isEqualTo(beUpdated.getRstWardName());
    assertThat(updated.getRstCourseCd()).isEqualTo(beUpdated.getRstCourseCd());
    assertThat(updated.getRstCourseName()).isEqualTo(beUpdated.getRstCourseName());
    assertThat(updated.getRstDw()).isEqualTo(new BigDecimal("55.30"));
    assertThat(updated.getRstPunctureUserInfo()).isEqualTo(beUpdated.getRstPunctureUserInfo());
    assertThat(updated.getRstReturnUserInfo()).isEqualTo(beUpdated.getRstReturnUserInfo());
    assertThat(updated.getRstChargeUserInfo()).isEqualTo(beUpdated.getRstChargeUserInfo());
    assertThat(updated.getRstBloodCirculateTotal()).isEqualTo(beUpdated.getRstBloodCirculateTotal());
    assertThat(updated.getRstRunningTime()).isEqualTo(beUpdated.getRstRunningTime());
    assertThat(updated.getRstKtV()).isEqualTo(beUpdated.getRstKtV());
    assertThat(updated.getRecSetDate()).isEqualTo(beUpdated.getRecSetDate());
    assertThat(updated.getSendCtlNo()).isEqualTo(beUpdated.getSendCtlNo());
    assertThat(updated.getBloodPurifierName()).isEqualTo(beUpdated.getBloodPurifierName());
    assertThat(updated.getPullLeaveAmount()).isEqualTo(beUpdated.getPullLeaveAmount());
    assertThat(updated.getRstCondInfo()).isEqualTo(beUpdated.getRstCondInfo());
    assertThat(updated.getRstMediInfo()).isEqualTo(beUpdated.getRstMediInfo());
    assertThat(updated.getRstEquipInfo()).isEqualTo(beUpdated.getRstEquipInfo());
    assertThat(updated.getRstIndCommentInfo()).isEqualTo(beUpdated.getRstIndCommentInfo());
    assertThat(updated.getRstTareInfo()).isEqualTo(beUpdated.getRstTareInfo());
    assertThat(updated.getRstOffWaterInfo()).isEqualTo(beUpdated.getRstOffWaterInfo());
//    assertThat(updated.getRstDeviceSetInfo()).isEqualTo(beUpdated.getRstDeviceSetInfo());// del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
    assertThat(updated.getWeightScaleNo()).isEqualTo(beUpdated.getWeightScaleNo());
    assertThat(updated.getRstWeightInfo()).isEqualTo(beUpdated.getRstWeightInfo());
//    assertThat(updated.getRstVitalInfo()).isEqualTo(beUpdated.getRstVitalInfo());
    assertThat(updated.getRstComplaintInfo()).isEqualTo(beUpdated.getRstComplaintInfo());
    assertThat(updated.getRstTreatmentInfo()).isEqualTo(beUpdated.getRstTreatmentInfo());
    assertThat(updated.getRstTreatStaffInfo()).isEqualTo(beUpdated.getRstTreatStaffInfo());
    assertThat(updated.getRstRoundsInfo()).isEqualTo(beUpdated.getRstRoundsInfo());
  }

  /**
   * updateResultMerge()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.before.sql")
  public void test_updateResultMerge_失敗_治療記録に存在しないOrdNoを指定した場合_409が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long notExistOrdNo = 100L; // 存在しないオーダ番号
    final TreatmentRecordResultMerge beUpdated = treatmentRecordDao.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);

    final String requestBody = objectMapper.writeValueAsString(beUpdated);

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result-merge", notExistOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    result
      .andExpect(status().isConflict())
      .andDo(document("treatment_record/result-merge/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ));
  }

  /**
   * updateResultMerge()の検証.
   * 条件: オーダ番号に該当するレコードが削除済みレコード（is_del='1'）であること
   * 結果: HTTPステータス500が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.before.sql")
  public void test_updateResultMerge_失敗_治療記録が削除済みの場合_500が返ること() throws Exception {
    // arrange
    final Long ordNo = 1L;
    final Long deletedOrdNo = 2L;
    final TreatmentRecordResultMerge beUpdated = treatmentRecordDao.selectTreatmentRecordResultMergeByOrdNo(ordNo).get(0);

    final String requestBody = objectMapper.writeValueAsString(beUpdated);

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/result-merge", deletedOrdNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateTreatmentRecordVital()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordVitalForMniMonitor_成功_バイタル情報を登録出来る事() throws Exception {
    // arrange
    final Long ordNo = 10000L;
    final Long bioMniCtlNo = 0L;
    final short dataType = 3;
    final Long patId = 3L;
    final Long updStaffId = 1L;
    final String monitorData = "{\"90\": \"140\", \"91\": \"70\", \"92\": \"120\", \"93\": \"60\"}";
    List<MniMonitor> request = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType, ordNo, patId, monitorData, updStaffId)
    );
    VitalMonitorData vitalMonitorData = new VitalMonitorData(){{
      setVitalData(request);
    }};
    String requestBody = objectMapper.writeValueAsString(vitalMonitorData);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/vital-monitor-data", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/vital-monitor-data/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたバイタル情報を装置モニタデータテーブルに登録するAPI"),
            key("operationTargetTable").value("操作対象テーブル：装置モニタデータ(mni_monitor)")
          ),
          fieldWithPath("vital_data").type(List.class).description("登録する装置モニタデータの配列"),
          fieldWithPath("vital_data[].bio_moni_ctl_no").type(Long.class).description("生体モニタリング番号　新規登録時はゼロを指定"),
          fieldWithPath("vital_data[].facility_cd").type(String.class).description("未使用：施設コード"),
          fieldWithPath("vital_data[].machine_type_cd").type(String.class).description("未使用：型式コード"),
          fieldWithPath("vital_data[].machine_serial").type(String.class).description("製造番号"),
          fieldWithPath("vital_data[].ord_no").type(Long.class).description("オーダ番号"),
          fieldWithPath("vital_data[].pat_id").type(Long.class).description("患者ID"),
          fieldWithPath("vital_data[].data_type").type(Short.class).description("データ種別"),
          fieldWithPath("vital_data[].monitor_data").type(String.class).description("モニタデータ"),
          fieldWithPath("vital_data[].is_del").type(String.class).description("削除フラグ"),
          fieldWithPath("vital_data[].occur_date").type(Timestamp.class).description("発生日時"),
          fieldWithPath("vital_data[].reg_date").type(Timestamp.class).description("登録日時"),
          fieldWithPath("vital_data[].up_date").type(Timestamp.class).description("更新日時"),
          fieldWithPath("vital_data[].upd_staff_id").type(Long.class).description("更新者ID"),
          fieldWithPath("vital_data[].operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("vital_data[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ));

    // 登録の確認
    List<MniMonitor> mniMonitorList = this.mniMonitorDao.selectByOrdNo(ordNo);
    assertThat(mniMonitorList).hasSize(1);
    assertThat(mniMonitorList.get(0).getBioMoniCtlNo()).isEqualTo(1000L);
    assertThat(mniMonitorList.get(0).getFacilityCd()).isEqualTo("nkknkk");
    assertThat(mniMonitorList.get(0).getMachineTypeCd()).isEqualTo("001");
    assertThat(mniMonitorList.get(0).getMachineSerial()).isEqualTo("00000002");
    assertThat(mniMonitorList.get(0).getOrdNo()).isEqualTo(ordNo);
    assertThat(mniMonitorList.get(0).getPatId()).isEqualTo(patId);
    assertThat(mniMonitorList.get(0).getDataType()).isEqualTo(dataType);
    assertThat(mniMonitorList.get(0).getMonitorData()).isEqualTo(monitorData);
    assertThat(mniMonitorList.get(0).getIsDel()).isEqualTo("0");
    assertThat(mniMonitorList.get(0).getOccurDate()).isEqualTo(Timestamp.valueOf("2019-11-21 12:00:00.000"));
    assertThat(mniMonitorList.get(0).getUpdStaffId()).isEqualTo(updStaffId);
    assertThat(mniMonitorList.get(0).getRegDate()).isNotNull();
    assertThat(mniMonitorList.get(0).getUpDate()).isNotNull();
  }

  /**
   * updateResultMerge()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていないこと
   * 結果: HTTPステータス409が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.getTreatmentRecordResultMerge.before.sql")
  public void test_updateTreatmentRecordVitalForMniMonitor_失敗_存在しないオーダ番号を指定した場合にエラーが返ること() throws Exception {
    // arrange
    // 存在しないオーダ番号
    final Long ordNo = 10001L;
    final Long bioMniCtlNo = 0L;
    final short dataType = 3;
    final Long patId = 3L;
    final Long updStaffId = 1L;
    final String monitorData = "{\"90\": \"140\", \"91\": \"70\", \"92\": \"120\", \"93\": \"60\"}";
    List<MniMonitor> request = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType, ordNo, patId, monitorData, updStaffId)
    );
    VitalMonitorData vitalMonitorData = new VitalMonitorData(){{
      setVitalData(request);
    }};
    String requestBody = objectMapper.writeValueAsString(vitalMonitorData);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/vital-monitor-data", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/vital-monitor-data/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )));
  }

  /**
   * updateTreatmentRecordVital()の検証.
   * 条件: オーダ番号に該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  @Sql("classpath:resource.script/TreatmentRecordResourceIntegrationTest.updateTreatmentRecordVitalForMniMonitor.before.sql")
  public void test_updateTreatmentRecordVitalForMniMonitor_成功_バイタル情報が更新出来る事() throws Exception {
    // arrange
    final Long ordNo = 10000L;
    final Long bioMniCtlNo = 1000L;
    final short dataType = 3;
    final Long patId = 3L;
    final Long updStaffId = 1L;
    final String monitorData = "{\"90\": \"140\", \"91\": \"70\", \"92\": \"120\", \"93\": \"60\"}";
    List<MniMonitor> request = Arrays.asList(
      getMniMonitor(bioMniCtlNo, dataType, ordNo, patId, monitorData, updStaffId)
    );
    VitalMonitorData vitalMonitorData = new VitalMonitorData(){{
      setVitalData(request);
    }};
    String requestBody = objectMapper.writeValueAsString(vitalMonitorData);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/treatment-record/{ord_no}/vital-monitor-data", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // assert
    result.andExpect(status().isOk());

    // 登録の確認
    List<MniMonitor> mniMonitorList = this.mniMonitorDao.selectByOrdNo(ordNo);
    assertThat(mniMonitorList).hasSize(1);
    assertThat(mniMonitorList.get(0).getBioMoniCtlNo()).isEqualTo(bioMniCtlNo);
    assertThat(mniMonitorList.get(0).getDataType()).isEqualTo(dataType);
    assertThat(objectMapper.writeValueAsString(mniMonitorList.get(0).getMonitorData())).isEqualTo(objectMapper.writeValueAsString(monitorData));
    assertThat(mniMonitorList.get(0).getIsDel()).isEqualTo("0");
    assertThat(mniMonitorList.get(0).getUpdStaffId()).isEqualTo(updStaffId);
    assertThat(mniMonitorList.get(0).getRegDate()).isNotNull();
    assertThat(mniMonitorList.get(0).getUpDate()).isNotNull();
  }

  /**
   * テスト用：登録、更新する{@link MniMonitor}作成.
   * @param dataType データ種別
   * @param ordNo オーダ番号
   * @param patId 患者番号
   * @param monitorData モニタデータ
   * @return 登録する装置モニタデータ
   */
  private MniMonitor getMniMonitor(
    Long bioMniCtlNo,
    Short dataType,
    Long ordNo,
    Long patId,
    String monitorData,
    Long updStaffId) {
    MniMonitor insertTestMonitorData = new MniMonitor();
    insertTestMonitorData.setBioMoniCtlNo(bioMniCtlNo);
    insertTestMonitorData.setOrdNo(ordNo);
    insertTestMonitorData.setPatId(patId);
    insertTestMonitorData.setDataType(dataType);
    insertTestMonitorData.setIsDel("0");
    insertTestMonitorData.setMonitorData(monitorData);
    insertTestMonitorData.setOccurDate(Timestamp.valueOf("2019-11-21 12:00:00.000"));
    insertTestMonitorData.setUpdStaffId(updStaffId);
    return insertTestMonitorData;
  }
}
