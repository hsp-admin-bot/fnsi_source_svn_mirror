package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.get;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.put;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.requestFields;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordComplaintDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;

/**
 * TreatmentRecordResourceの結合テストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/TreatmentRecordComplaintResourceIntegrationTest.before.sql")
public class TreatmentRecordComplaintResourceIntegrationTest extends AbstractResourceIntegrationTest {

  @Autowired
  private ObjectMapper objectMapper;

  /**
   * 治療記録(愁訴処置)のDaoインターフェース.
   */
  @Autowired
  private TreatmentRecordComplaintDao complaintDao;

  /**
   * getTreatmentRecordComplaint()の検証
   * 条件: 治療情報に存在するOrdNoを指定する
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordComplaint_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    // action
    mockMvc
      .perform(get("/api/treatment-record/{ord_no}/complaint", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.rst_start_date", is("2019-05-29T13:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_end_date", is("2019-05-29T18:00:00.000+09:00")))
      .andExpect(jsonPath("$.rst_complaint_info", is("[{\"cd\": 1, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.rst_treatment_info", is("[{\"cd\": 11, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.rst_treat_staff_info", is("[{\"cd\": 21, \"name\": \"name1\"}, {\"cd\": 2, \"name\": \"name2\"}]")))
      .andExpect(jsonPath("$.up_date", is("2019-03-01T13:00:00.000+09:00")))
      .andExpect(jsonPath("$.operator_id", nullValue()))
      .andExpect(jsonPath("$.target_facility_cd", nullValue()))
      .andDo(
        document("treatment_record/complaint/get/ok",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          ),
          responseFields(
            attributes(
              key("description").value("概要：指定されたオーダ番号に該当する治療記録の愁訴処置情報を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
            ),
            fieldWithPath("rst_start_date").description("治療開始日時")
            , fieldWithPath("rst_end_date").description("治療終了日時")
            , fieldWithPath("rst_complaint_info").description("実績：愁訴情報")
            , fieldWithPath("rst_treatment_info").description("実績：愁訴処置情報")
            , fieldWithPath("rst_treat_staff_info").description("実績：愁訴処置者情報")
            , fieldWithPath("up_date").description("更新日時(排他制御用)")
            , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordComplaint()の検証
   * 条件: 治療情報に存在しないオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordComplaint_失敗_マスタに存在しないオーダ番号を指定する() throws Exception {
    // arrange
    final Long ordNo = 9999L;

    // action
    mockMvc
      .perform(get("/api/treatment-record/{ord_no}/complaint", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/complaint/get/not-found",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * getTreatmentRecordComplaint()の検証
   * 条件: 治療情報に存在し、削除（is_del='1'）に設定されているオーダ番号を指定する
   * 結果: HTTPステータス500 が返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_VIEW)
  public void test_getTreatmentRecordComplaint_失敗_削除に設定されているレコードを指定する() throws Exception {
    // arrange
    final Long ordNo = 2L;

    // action
    mockMvc
      .perform(get("/api/treatment-record/{ord_no}/complaint", ordNo)
        .contentType(MediaType.APPLICATION_JSON_UTF8))
      // assert
      .andExpect(status().isInternalServerError())
      .andDo(
        document("treatment_record/complaint/get/set-deleted",
          pathParameters(
            parameterWithName("ord_no").description("[必須]オーダ番号")
          )
        )
      )
    ;
  }

  /**
   * updateTreatmentRecordComplaint()の検証
   * 条件: 治療情報に存在するOrdNoを指定する
   * 結果: 成功レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordComplaint_成功() throws Exception {
    // arrange
    final Long ordNo = 1L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-12-31 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-12-31 18:00:00");
    final String rstComplaintInfoForUpdate
      = "[{\"cd\": 110, \"name\": \"name110\"}, {\"cd\": 201, \"name\": \"name201\"}]";
    final String rstTreatmentInfoForUpdate
      = "[{\"cd\": 120, \"name\": \"name120\"}, {\"cd\": 202, \"name\": \"name202\"}]";
    final String rstTreatStaffInfoForUpdate
      = "[{\"cd\": 130, \"name\": \"name130\"}, {\"cd\": 203, \"name\": \"name203\"}]";

    final TreatmentRecordComplaint treatmentRecordComplaint = new TreatmentRecordComplaint();
    treatmentRecordComplaint.setRstStartDate(rstStartDate);
    treatmentRecordComplaint.setRstEndDate(rstEndDate);
    treatmentRecordComplaint.setRstComplaintInfo(rstComplaintInfoForUpdate);
    treatmentRecordComplaint.setRstTreatmentInfo(rstTreatmentInfoForUpdate);
    treatmentRecordComplaint.setRstTreatStaffInfo(rstTreatStaffInfoForUpdate);
    String requestBody = objectMapper.writeValueAsString(treatmentRecordComplaint);

    // action
    ResultActions result = mockMvc.perform(put("/api/treatment-record/{ord_no}/complaint", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("treatment_record/complaint/put/ok",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        ),
        requestFields(
          attributes(
            key("description").value("概要：指定されたオーダ番号に該当する治療記録の愁訴処置情報を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：治療情報 (ord_main)")
          ),
          fieldWithPath("rst_start_date").ignored()
          , fieldWithPath("rst_end_date").ignored()
          , fieldWithPath("rst_complaint_info").description("実績：愁訴情報")
          , fieldWithPath("rst_treatment_info").description("実績：愁訴処置情報")
          , fieldWithPath("rst_treat_staff_info").description("実績：愁訴処置者情報")
          , fieldWithPath("up_date").description("更新日時(排他制御用)")
          , fieldWithPath("operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    final TreatmentRecordComplaint updated = complaintDao.selectTreatmentRecordComplaintByOrdNo(ordNo);
    assertThat(updated.getRstStartDate(), is(Timestamp.valueOf("2019-05-29 13:00:00")));
    assertThat(updated.getRstEndDate(), is(Timestamp.valueOf("2019-05-29 18:00:00")));
    assertThat(updated.getRstComplaintInfo(), is(rstComplaintInfoForUpdate));
    assertThat(updated.getRstTreatmentInfo(), is(rstTreatmentInfoForUpdate));
    assertThat(updated.getRstTreatStaffInfo(), is(rstTreatStaffInfoForUpdate));
  }

  /**
   * updateTreatmentRecordComplaint()の検証
   * 条件: 治療情報に存在しないOrdNoを指定する
   * 結果: 失敗レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordComplaint_失敗_該当オーダ番号なし() throws Exception {
    // arrange
    final Long ordNo = 999L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-12-31 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-12-31 18:00:00");
    final String rstComplaintInfoForUpdate
      = "[{\"cd\": 110, \"name\": \"name110\"}, {\"cd\": 201, \"name\": \"name201\"}]";
    final String rstTreatmentInfoForUpdate
      = "[{\"cd\": 120, \"name\": \"name120\"}, {\"cd\": 202, \"name\": \"name202\"}]";
    final String rstTreatStaffInfoForUpdate
      = "[{\"cd\": 130, \"name\": \"name130\"}, {\"cd\": 203, \"name\": \"name203\"}]";

    final TreatmentRecordComplaint treatmentRecordComplaint = new TreatmentRecordComplaint();
    treatmentRecordComplaint.setRstStartDate(rstStartDate);
    treatmentRecordComplaint.setRstEndDate(rstEndDate);
    treatmentRecordComplaint.setRstComplaintInfo(rstComplaintInfoForUpdate);
    treatmentRecordComplaint.setRstTreatmentInfo(rstTreatmentInfoForUpdate);
    treatmentRecordComplaint.setRstTreatStaffInfo(rstTreatStaffInfoForUpdate);
    String requestBody = objectMapper.writeValueAsString(treatmentRecordComplaint);

    // action
    ResultActions result = mockMvc.perform(put("/api/treatment-record/{ord_no}/complaint", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("treatment_record/complaint/put/not-found",
        pathParameters(
          parameterWithName("ord_no").description("[必須]オーダ番号")
        )
      ))
    ;
  }

  /**
   * updateTreatmentRecordComplaint()の検証
   * 条件: 治療情報に存在する、削除済みのOrdNoを指定する
   * 結果: 失敗レスポンスが返却されること
   */
  @Test
  @NtssMockUser(authority = AdminWebConstant.Authority.RST_EDIT)
  public void test_updateTreatmentRecordComplaint_失敗_削除済み() throws Exception {
    // arrange
    final Long ordNo = 2L;

    final Timestamp rstStartDate = Timestamp.valueOf("2019-12-31 13:00:00");
    final Timestamp rstEndDate = Timestamp.valueOf("2019-12-31 18:00:00");
    final String rstComplaintInfoForUpdate
      = "[{\"cd\": 110, \"name\": \"name110\"}, {\"cd\": 201, \"name\": \"name201\"}]";
    final String rstTreatmentInfoForUpdate
      = "[{\"cd\": 120, \"name\": \"name120\"}, {\"cd\": 202, \"name\": \"name202\"}]";
    final String rstTreatStaffInfoForUpdate
      = "[{\"cd\": 130, \"name\": \"name130\"}, {\"cd\": 203, \"name\": \"name203\"}]";

    final TreatmentRecordComplaint treatmentRecordComplaint = new TreatmentRecordComplaint();
    treatmentRecordComplaint.setRstStartDate(rstStartDate);
    treatmentRecordComplaint.setRstEndDate(rstEndDate);
    treatmentRecordComplaint.setRstComplaintInfo(rstComplaintInfoForUpdate);
    treatmentRecordComplaint.setRstTreatmentInfo(rstTreatmentInfoForUpdate);
    treatmentRecordComplaint.setRstTreatStaffInfo(rstTreatStaffInfoForUpdate);
    String requestBody = objectMapper.writeValueAsString(treatmentRecordComplaint);

    // action
    ResultActions result = mockMvc.perform(put("/api/treatment-record/{ord_no}/complaint", ordNo)
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result.andExpect(status().isInternalServerError());
  }
}
