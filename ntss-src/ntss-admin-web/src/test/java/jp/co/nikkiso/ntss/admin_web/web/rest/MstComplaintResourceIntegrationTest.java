package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.dao.MstCompTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstComplaintDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.requestFields;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql(value = "classpath:resource.script/MstComplaintResourceIntegrationTest.before.sql")
public class MstComplaintResourceIntegrationTest extends AbstractResourceIntegrationTest {

  @Autowired
  private MstComplaintDao mstComplaintDao;

  @Autowired
  private MstCompTreatmentDao mstCompTreatmentDao;

  @Autowired
  private MstSelectorDao mstSelectorDao;

  @Autowired
  private ObjectMapper objectMapper;

  /**
   * 愁訴マスタEntityの初期化.
   * @return 愁訴マスタのEntity
   */
  private List<MstComplaint> createComplaintEntity() {
    return Arrays.asList(
      new MstComplaint() {{
        setComplaintCd(1);
        setComplaintName("rename1");
        setFacilityCd("1001");
        setIsDisp("1");
        setIsDel("0");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(true);
      }},
      new MstComplaint() {{
        setComplaintCd(5);
        setComplaintName("name5");
        setFacilityCd("1001");
        setIsDisp("1");
        setIsDel("0");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(false);
      }},
      new MstComplaint() {{
        setComplaintCd(null);
        setComplaintName("addname8");
        setFacilityCd("1001");
        setIsDisp("1");
        setIsDel("0");
        setIsUpdate(false);
      }},
      new MstComplaint() {{
        setComplaintCd(2);
        setComplaintName("rename2");
        setFacilityCd("1001");
        setIsDisp("1");
        setIsDel("0");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(true);
      }},
      new MstComplaint() {{
        setComplaintCd(null);
        setComplaintName("addname9");
        setFacilityCd("1001");
        setIsDisp("1");
        setIsDel("0");
        setIsUpdate(false);
      }},
      new MstComplaint() {{
        setComplaintCd(3);
        setComplaintName("name3");
        setFacilityCd("1001");
        setIsDisp("0");
        setIsDel("0");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(false);
      }},
      new MstComplaint() {{
        setComplaintCd(4);
        setComplaintName("rename4");
        setFacilityCd("1001");
        setIsDisp("0");
        setIsDel("0");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(true);
      }}
    );
  }

  /**
   * 処置マスタEntityの初期化.
   * @return 処置マスタのEntity
   */
  private List<MstCompTreatment> createCompTreatmentEntity() {
    return Arrays.asList(
      new MstCompTreatment() {{
        setCompTreatmentCd(1);
        setFacilityCd("1001");
        setTreatment("rename1");
        setTreatClass(2);
        setTreatMedicineCd(null);
        setAmount(null);
        setProcedureCd(null);
        setTakeMedicineCd(null);
        setIsDel("0");
        setIsDisp("1");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(true);
      }},
      new MstCompTreatment() {{
        setCompTreatmentCd(5);
        setFacilityCd("1001");
        setTreatment("name5");
        setTreatClass(0);
        setTreatMedicineCd(12);
        setAmount(new BigDecimal("13.12"));
        setProcedureCd(14);
        setTakeMedicineCd(15);
        setIsDel("0");
        setIsDisp("1");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(false);
      }},
      new MstCompTreatment() {{
        setFacilityCd("1001");
        setTreatment("addname8");
        setTreatClass(2);
        setTreatMedicineCd(null);
        setAmount(null);
        setProcedureCd(null);
        setTakeMedicineCd(null);
        setIsDel("0");
        setIsDisp("1");
        setIsUpdate(false);
      }},
      new MstCompTreatment() {{
        setCompTreatmentCd(2);
        setFacilityCd("1001");
        setTreatment("rename2");
        setTreatClass(2);
        setTreatMedicineCd(null);
        setAmount(null);
        setProcedureCd(null);
        setTakeMedicineCd(null);
        setIsDel("0");
        setIsDisp("1");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(true);
      }},
      new MstCompTreatment() {{
        setFacilityCd("1001");
        setTreatment("addname9");
        setTreatClass(0);
        setTreatMedicineCd(92);
        setAmount(new BigDecimal("99.12"));
        setProcedureCd(94);
        setTakeMedicineCd(95);
        setIsDel("0");
        setIsDisp("1");
        setIsUpdate(false);
      }},
      new MstCompTreatment() {{
        setCompTreatmentCd(3);
        setFacilityCd("1001");
        setTreatment("name3");
        setTreatClass(2);
        setTreatMedicineCd(null);
        setAmount(null);
        setProcedureCd(null);
        setTakeMedicineCd(null);
        setIsDel("0");
        setIsDisp("0");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(false);
      }},
      new MstCompTreatment() {{
        setCompTreatmentCd(4);
        setFacilityCd("1001");
        setTreatment("rename4");
        setTreatClass(1);
        setTreatMedicineCd(2);
        setAmount(new BigDecimal("3.12"));
        setProcedureCd(4);
        setTakeMedicineCd(5);
        setIsDel("0");
        setIsDisp("0");
        setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
        setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
        setIsUpdate(true);
      }}
    );
  }

  /**
   * getAllMstComplaints()の検証.
   *
   * 条件：成功, 愁訴マスタに該当するデータあり
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "1001")
  public void test_getAllMstComplaints_正常_愁訴マスタに該当するデータあり() throws Exception{

    mockMvc
      .perform(RestDocumentationRequestBuilders
          .get("/api/complaint/mst-complaint"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(5)))
      .andExpect(jsonPath("$[0].complaint_cd", is(1)))
      .andExpect(jsonPath("$[0].facility_cd", is("1001")))
      .andExpect(jsonPath("$[0].complaint_name", is("name1")))
      .andExpect(jsonPath("$[0].is_disp", is("1")))
      .andExpect(jsonPath("$[0].is_del", is("0")))
      .andExpect(jsonPath("$[0].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[0].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[0].is_update", nullValue()))
      .andExpect(jsonPath("$[1].complaint_cd", is(5)))
      .andExpect(jsonPath("$[1].facility_cd", is("1001")))
      .andExpect(jsonPath("$[1].complaint_name", is("name5")))
      .andExpect(jsonPath("$[1].is_disp", is("1")))
      .andExpect(jsonPath("$[1].is_del", is("0")))
      .andExpect(jsonPath("$[1].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[1].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[1].is_update", nullValue()))
      .andExpect(jsonPath("$[2].complaint_cd", is(4)))
      .andExpect(jsonPath("$[2].facility_cd", is("1001")))
      .andExpect(jsonPath("$[2].complaint_name", is("name4")))
      .andExpect(jsonPath("$[2].is_disp", is("1")))
      .andExpect(jsonPath("$[2].is_del", is("0")))
      .andExpect(jsonPath("$[2].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[2].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[2].is_update", nullValue()))
      .andExpect(jsonPath("$[3].complaint_cd", is(2)))
      .andExpect(jsonPath("$[3].facility_cd", is("1001")))
      .andExpect(jsonPath("$[3].complaint_name", is("name2")))
      .andExpect(jsonPath("$[3].is_disp", is("0")))
      .andExpect(jsonPath("$[3].is_del", is("0")))
      .andExpect(jsonPath("$[3].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[3].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[3].is_update", nullValue()))
      .andExpect(jsonPath("$[4].complaint_cd", is(3)))
      .andExpect(jsonPath("$[4].facility_cd", is("1001")))
      .andExpect(jsonPath("$[4].complaint_name", is("name3")))
      .andExpect(jsonPath("$[4].is_disp", is("0")))
      .andExpect(jsonPath("$[4].is_del", is("0")))
      .andExpect(jsonPath("$[4].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[4].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[4].is_update", nullValue()))
      .andDo(document("complaint/mst-complaint/get/ok",
          responseFields(
            attributes(
              key("description").value("概要:施設コードに対応する愁訴マスタを取得する")
              , key("operationTargetTable").value("操作対象テーブル:愁訴マスタ（mst_complaint）")
            ),
            fieldWithPath("[]").description("愁訴マスタ")
            , fieldWithPath("[].complaint_cd").description("愁訴コード")
            , fieldWithPath("[].facility_cd").description("施設コード")
            , fieldWithPath("[].complaint_name").description("愁訴名")
            , fieldWithPath("[].is_disp").description("表示フラグ")
            , fieldWithPath("[].is_del").description("削除フラグ")
            , fieldWithPath("[].reg_date").description("登録日時")
            , fieldWithPath("[].up_date").description("更新日時")
            , fieldWithPath("[].is_update").ignored()
            , fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional()
            , fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
          )))
    ;
  }

  /**
   * getAllMstComplaints()の検証.
   *
   * 条件：成功, 愁訴マスタに該当するデータなし
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "9999")
  public void test_getAllMstComplaints_正常_愁訴マスタに該当するデータなし() throws Exception{

    mockMvc
      .perform(RestDocumentationRequestBuilders
        .get("/api/complaint/mst-complaint"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }

  /**
   * updateMstComplaints()の検証.
   * 条件: なし
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(facilityCd = "1001")
  public void test_updateMstComplaints_成功() throws Exception {
    // arrange
    final List<MstComplaint> request = createComplaintEntity();
    final String requestBody = objectMapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/complaint/mst-complaint")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("complaint/mst-complaint/put/ok",
        requestFields(
          attributes(
            key("description").value("概要：愁訴マスタを更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：愁訴マスタ (mst_complaint)")
          ),
          fieldWithPath("[]").description("愁訴マスタ")
          , fieldWithPath("[].complaint_cd").description("愁訴コード").optional()
          , fieldWithPath("[].facility_cd").description("[必須]施設コード")
          , fieldWithPath("[].complaint_name").description("[必須]愁訴名")
          , fieldWithPath("[].is_disp").description("[必須]表示フラグ")
          , fieldWithPath("[].is_del").description("[必須]削除フラグ")
          , fieldWithPath("[].reg_date").description("登録日時").optional()
          , fieldWithPath("[].up_date").description("更新日時").optional()
          , fieldWithPath("[].is_update").description("更新フラグ")
          , fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の検証
    // 愁訴マスタ
    String facilityCd = "1001";
    final List<MstComplaint> updateComplaints = mstComplaintDao.selectAllByFacilityCd(facilityCd);
    // 検証のためコード順に並び替え
    List<MstComplaint> sortedComplaints = updateComplaints.stream()
      .sorted(Comparator.comparing(MstComplaint::getComplaintCd))
      .collect(Collectors.toList());
    assertThat(sortedComplaints, hasSize(7));
    assertThat(sortedComplaints.get(0).getComplaintCd(), equalTo(1));
    assertThat(sortedComplaints.get(0).getComplaintName(), equalTo("rename1"));
    assertThat(sortedComplaints.get(0).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedComplaints.get(0).getIsDisp(), equalTo("1"));
    assertThat(sortedComplaints.get(0).getIsDel(), equalTo("0"));
    assertThat(sortedComplaints.get(0).getIsUpdate(), nullValue());
    assertThat(sortedComplaints.get(1).getComplaintCd(), equalTo(2));
    assertThat(sortedComplaints.get(1).getComplaintName(), equalTo("rename2"));
    assertThat(sortedComplaints.get(1).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedComplaints.get(1).getIsDisp(), equalTo("1"));
    assertThat(sortedComplaints.get(1).getIsDel(), equalTo("0"));
    assertThat(sortedComplaints.get(1).getIsUpdate(), nullValue());
    assertThat(sortedComplaints.get(2).getComplaintCd(), equalTo(3));
    assertThat(sortedComplaints.get(2).getComplaintName(), equalTo("name3"));
    assertThat(sortedComplaints.get(2).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedComplaints.get(2).getIsDisp(), equalTo("0"));
    assertThat(sortedComplaints.get(2).getIsDel(), equalTo("0"));
    assertThat(sortedComplaints.get(2).getIsUpdate(), nullValue());
    assertThat(sortedComplaints.get(3).getComplaintCd(), equalTo(4));
    assertThat(sortedComplaints.get(3).getComplaintName(), equalTo("rename4"));
    assertThat(sortedComplaints.get(3).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedComplaints.get(3).getIsDisp(), equalTo("0"));
    assertThat(sortedComplaints.get(3).getIsDel(), equalTo("0"));
    assertThat(sortedComplaints.get(3).getIsUpdate(), nullValue());
    assertThat(sortedComplaints.get(4).getComplaintCd(), equalTo(5));
    assertThat(sortedComplaints.get(4).getComplaintName(), equalTo("name5"));
    assertThat(sortedComplaints.get(4).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedComplaints.get(4).getIsDisp(), equalTo("1"));
    assertThat(sortedComplaints.get(4).getIsDel(), equalTo("0"));
    assertThat(sortedComplaints.get(4).getIsUpdate(), nullValue());
    assertThat(sortedComplaints.get(5).getComplaintCd(), equalTo(8));
    assertThat(sortedComplaints.get(5).getComplaintName(), equalTo("addname8"));
    assertThat(sortedComplaints.get(5).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedComplaints.get(5).getIsDisp(), equalTo("1"));
    assertThat(sortedComplaints.get(5).getIsDel(), equalTo("0"));
    assertThat(sortedComplaints.get(5).getIsUpdate(), nullValue());
    assertThat(sortedComplaints.get(6).getComplaintCd(), equalTo(9));
    assertThat(sortedComplaints.get(6).getComplaintName(), equalTo("addname9"));
    assertThat(sortedComplaints.get(6).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedComplaints.get(6).getIsDisp(), equalTo("1"));
    assertThat(sortedComplaints.get(6).getIsDel(), equalTo("0"));
    assertThat(sortedComplaints.get(6).getIsUpdate(), nullValue());

    // マスタセレクタ
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_complaint");
    assertThat(mstSelector.getOrderSettings().getItems(), hasSize(5));
    assertThat(mstSelector.getOrderSettings().getItems().get(0).getCode(), equalTo(1L));
    assertThat(mstSelector.getOrderSettings().getItems().get(0).getName(), equalTo("rename1"));
    assertThat(mstSelector.getOrderSettings().getItems().get(1).getCode(), equalTo(5L));
    assertThat(mstSelector.getOrderSettings().getItems().get(1).getName(), equalTo("name5"));
    assertThat(mstSelector.getOrderSettings().getItems().get(2).getCode(), equalTo(8L));
    assertThat(mstSelector.getOrderSettings().getItems().get(2).getName(), equalTo("addname8"));
    assertThat(mstSelector.getOrderSettings().getItems().get(3).getCode(), equalTo(2L));
    assertThat(mstSelector.getOrderSettings().getItems().get(3).getName(), equalTo("rename2"));
    assertThat(mstSelector.getOrderSettings().getItems().get(4).getCode(), equalTo(9L));
    assertThat(mstSelector.getOrderSettings().getItems().get(4).getName(), equalTo("addname9"));
  }

  /**
   * getAllMstCompTreatments()の検証.
   *
   * 条件：成功, 処置マスタに該当するデータあり
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "1001")
  public void test_getAllMstComplaints_正常_処置マスタに該当するデータあり() throws Exception{

    mockMvc
      .perform(RestDocumentationRequestBuilders
        .get("/api/complaint/mst-comp-treatment"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(5)))
      .andExpect(jsonPath("$[0].comp_treatment_cd", is(1)))
      .andExpect(jsonPath("$[0].facility_cd", is("1001")))
      .andExpect(jsonPath("$[0].treatment", is("name1")))
      .andExpect(jsonPath("$[0].treat_class", is("2")))
      .andExpect(jsonPath("$[0].treat_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[0].amount", is(nullValue())))
      .andExpect(jsonPath("$[0].procedure_cd", is(nullValue())))
      .andExpect(jsonPath("$[0].take_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[0].is_disp", is("1")))
      .andExpect(jsonPath("$[0].is_del", is("0")))
      .andExpect(jsonPath("$[0].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[0].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[0].is_update", nullValue()))
      .andExpect(jsonPath("$[0].in_hosp_astartdate", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_a1", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_a2", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_a3", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_a4", nullValue()))
      .andExpect(jsonPath("$[0].in_hosp_bstartdate", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_b1", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_b2", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_b3", nullValue()))
      .andExpect(jsonPath("$[0].in_hospital_cd_b4", nullValue()))
      .andExpect(jsonPath("$[1].comp_treatment_cd", is(5)))
      .andExpect(jsonPath("$[1].facility_cd", is("1001")))
      .andExpect(jsonPath("$[1].treatment", is("name5")))
      .andExpect(jsonPath("$[1].treat_class", is("0")))
      .andExpect(jsonPath("$[1].treat_medicine_cd", is(12)))
      .andExpect(jsonPath("$[1].amount", is(13.12)))
      .andExpect(jsonPath("$[1].procedure_cd", is(14)))
      .andExpect(jsonPath("$[1].take_medicine_cd", is(15)))
      .andExpect(jsonPath("$[1].is_disp", is("1")))
      .andExpect(jsonPath("$[1].is_del", is("0")))
      .andExpect(jsonPath("$[1].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[1].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[1].is_update", nullValue()))
      .andExpect(jsonPath("$[1].in_hosp_astartdate", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_a1", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_a2", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_a3", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_a4", nullValue()))
      .andExpect(jsonPath("$[1].in_hosp_bstartdate", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_b1", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_b2", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_b3", nullValue()))
      .andExpect(jsonPath("$[1].in_hospital_cd_b4", nullValue()))
      .andExpect(jsonPath("$[2].comp_treatment_cd", is(4)))
      .andExpect(jsonPath("$[2].facility_cd", is("1001")))
      .andExpect(jsonPath("$[2].treatment", is("name4")))
      .andExpect(jsonPath("$[2].treat_class", is("1")))
      .andExpect(jsonPath("$[2].treat_medicine_cd", is(2)))
      .andExpect(jsonPath("$[2].amount", is(3.12)))
      .andExpect(jsonPath("$[2].procedure_cd", is(4)))
      .andExpect(jsonPath("$[2].take_medicine_cd", is(5)))
      .andExpect(jsonPath("$[2].is_disp", is("1")))
      .andExpect(jsonPath("$[2].is_del", is("0")))
      .andExpect(jsonPath("$[2].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[2].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[2].is_update", nullValue()))
      .andExpect(jsonPath("$[2].in_hosp_astartdate", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_a1", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_a2", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_a3", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_a4", nullValue()))
      .andExpect(jsonPath("$[2].in_hosp_bstartdate", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_b1", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_b2", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_b3", nullValue()))
      .andExpect(jsonPath("$[2].in_hospital_cd_b4", nullValue()))
      .andExpect(jsonPath("$[3].comp_treatment_cd", is(2)))
      .andExpect(jsonPath("$[3].facility_cd", is("1001")))
      .andExpect(jsonPath("$[3].treatment", is("name2")))
      .andExpect(jsonPath("$[3].treat_class", is("2")))
      .andExpect(jsonPath("$[3].treat_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[3].amount", is(nullValue())))
      .andExpect(jsonPath("$[3].procedure_cd", is(nullValue())))
      .andExpect(jsonPath("$[3].take_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[3].is_disp", is("0")))
      .andExpect(jsonPath("$[3].is_del", is("0")))
      .andExpect(jsonPath("$[3].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[3].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[3].is_update", nullValue()))
      .andExpect(jsonPath("$[3].in_hosp_astartdate", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_a1", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_a2", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_a3", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_a4", nullValue()))
      .andExpect(jsonPath("$[3].in_hosp_bstartdate", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_b1", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_b2", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_b3", nullValue()))
      .andExpect(jsonPath("$[3].in_hospital_cd_b4", nullValue()))
      .andExpect(jsonPath("$[4].comp_treatment_cd", is(3)))
      .andExpect(jsonPath("$[4].facility_cd", is("1001")))
      .andExpect(jsonPath("$[4].treatment", is("name3")))
      .andExpect(jsonPath("$[4].treat_class", is("2")))
      .andExpect(jsonPath("$[4].treat_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[4].amount", is(nullValue())))
      .andExpect(jsonPath("$[4].procedure_cd", is(nullValue())))
      .andExpect(jsonPath("$[4].take_medicine_cd", is(nullValue())))
      .andExpect(jsonPath("$[4].is_disp", is("0")))
      .andExpect(jsonPath("$[4].is_del", is("0")))
      .andExpect(jsonPath("$[4].reg_date", is("2019-07-08T04:00:00.000+0000")))
      .andExpect(jsonPath("$[4].up_date", is("2019-07-08T05:00:00.000+0000")))
      .andExpect(jsonPath("$[4].is_update", nullValue()))
      .andExpect(jsonPath("$[4].in_hosp_astartdate", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_a1", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_a2", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_a3", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_a4", nullValue()))
      .andExpect(jsonPath("$[4].in_hosp_bstartdate", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_b1", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_b2", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_b3", nullValue()))
      .andExpect(jsonPath("$[4].in_hospital_cd_b4", nullValue()))
      .andDo(document("complaint/mst-comp-treatment/get/ok",
        responseFields(
          attributes(
            key("description").value("概要:施設コードに対応する処置マスタを取得する")
            , key("operationTargetTable").value("操作対象テーブル:処置マスタ（mst_comp_treatment）")
          ),
          fieldWithPath("[]").description("処置マスタ")
          , fieldWithPath("[].comp_treatment_cd").description("処置コード")
          , fieldWithPath("[].facility_cd").description("施設コード")
          , fieldWithPath("[].treatment").description("処置内容").optional()
          , fieldWithPath("[].treat_class").description("処置区分").optional()
          , fieldWithPath("[].treat_medicine_cd").description("処置薬剤コード").optional()
          , fieldWithPath("[].amount").description("数量").optional()
          , fieldWithPath("[].procedure_cd").description("手技コード").optional()
          , fieldWithPath("[].take_medicine_cd").description("服用コード").optional()
          , fieldWithPath("[].is_disp").description("表示フラグ")
          , fieldWithPath("[].is_del").description("削除フラグ")
          , fieldWithPath("[].reg_date").description("登録日時").optional()
          , fieldWithPath("[].up_date").description("更新日時").optional()
          , fieldWithPath("[].is_update").ignored()
          , fieldWithPath("[].in_hosp_astartdate").description("利用開始日A").optional()
          , fieldWithPath("[].in_hospital_cd_a1").description("院内コードA1").optional()
          , fieldWithPath("[].in_hospital_cd_a2").description("院内コードA2").optional()
          , fieldWithPath("[].in_hospital_cd_a3").description("院内コードA3").optional()
          , fieldWithPath("[].in_hospital_cd_a4").description("院内コードA4").optional()
          , fieldWithPath("[].in_hosp_bstartdate").description("利用開始日B").optional()
          , fieldWithPath("[].in_hospital_cd_b1").description("院内コードB1").optional()
          , fieldWithPath("[].in_hospital_cd_b2").description("院内コードB2").optional()
          , fieldWithPath("[].in_hospital_cd_b3").description("院内コードB3").optional()
          , fieldWithPath("[].in_hospital_cd_b4").description("院内コードB4").optional()
          , fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )))
    ;
  }

  /**
   * getAllMstCompTreatments()の検証.
   *
   * 条件：成功, 処置マスタに該当するデータなし
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "9999")
  public void test_getAllMstCompTreatments_正常_処置マスタに該当するデータなし() throws Exception{

    mockMvc
      .perform(RestDocumentationRequestBuilders
        .get("/api/complaint/mst-comp-treatment"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }

  /**
   * updateMstCompTreatments()の検証.
   * 条件: なし
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(facilityCd = "1001")
  public void test_updateMstCompTreatments_成功() throws Exception {
    // arrange
    final List<MstCompTreatment> request = createCompTreatmentEntity();
    final String requestBody = objectMapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/complaint/mst-comp-treatment")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("complaint/mst-comp-treatment/put/ok",
        requestFields(
          attributes(
            key("description").value("概要：処置マスタを更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：処置マスタ (mst_comp_treatment)")
          ),
          fieldWithPath("[]").description("処置マスタ")
          , fieldWithPath("[].comp_treatment_cd").description("処置コード").optional()
          , fieldWithPath("[].facility_cd").description("[必須]施設コード")
          , fieldWithPath("[].treatment").description("処置内容").optional()
          , fieldWithPath("[].treat_class").description("処置区分").optional()
          , fieldWithPath("[].treat_medicine_cd").description("処置薬剤コード").optional()
          , fieldWithPath("[].amount").description("数量").optional()
          , fieldWithPath("[].procedure_cd").description("手技コード").optional()
          , fieldWithPath("[].take_medicine_cd").description("服用コード").optional()
          , fieldWithPath("[].is_disp").description("[必須]表示フラグ")
          , fieldWithPath("[].is_del").description("[必須]削除フラグ")
          , fieldWithPath("[].reg_date").description("登録日時").optional()
          , fieldWithPath("[].up_date").description("更新日時").optional()
          , fieldWithPath("[].is_update").description("更新フラグ")
          , fieldWithPath("[].in_hosp_astartdate").description("利用開始日A").optional()
          , fieldWithPath("[].in_hospital_cd_a1").description("院内コードA1").optional()
          , fieldWithPath("[].in_hospital_cd_a2").description("院内コードA2").optional()
          , fieldWithPath("[].in_hospital_cd_a3").description("院内コードA3").optional()
          , fieldWithPath("[].in_hospital_cd_a4").description("院内コードA4").optional()
          , fieldWithPath("[].in_hosp_bstartdate").description("利用開始日B").optional()
          , fieldWithPath("[].in_hospital_cd_b1").description("院内コードB1").optional()
          , fieldWithPath("[].in_hospital_cd_b2").description("院内コードB2").optional()
          , fieldWithPath("[].in_hospital_cd_b3").description("院内コードB3").optional()
          , fieldWithPath("[].in_hospital_cd_b4").description("院内コードB4").optional()
          , fieldWithPath("[].operator_id").description("操作者ID(ログ出力用)").optional()
          , fieldWithPath("[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional()
        )
      ))
    ;

    // 更新後の検証
    // 愁訴マスタ
    String facilityCd = "1001";
    final List<MstCompTreatment> updateCompTreatments = mstCompTreatmentDao.selectAllByFacilityCd(facilityCd);
    // 検証のためコード順に並び替え
    List<MstCompTreatment> sortedCompTreatments = updateCompTreatments.stream()
      .sorted(Comparator.comparing(MstCompTreatment::getCompTreatmentCd))
      .collect(Collectors.toList());
    assertThat(sortedCompTreatments, hasSize(7));
    assertThat(sortedCompTreatments.get(0).getCompTreatmentCd(), equalTo(1));
    assertThat(sortedCompTreatments.get(0).getTreatment(), equalTo("rename1"));
    assertThat(sortedCompTreatments.get(0).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedCompTreatments.get(0).getTreatClass(), equalTo("2"));
    assertThat(sortedCompTreatments.get(0).getTreatMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(0).getAmount(), equalTo(null));
    assertThat(sortedCompTreatments.get(0).getProcedureCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(0).getTakeMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(0).getIsDisp(), equalTo("1"));
    assertThat(sortedCompTreatments.get(0).getIsDel(), equalTo("0"));
    assertThat(sortedCompTreatments.get(0).getIsUpdate(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospAStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdA1(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdA2(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdA3(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdA4(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospBStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdB1(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdB2(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdB3(), nullValue());
    assertThat(sortedCompTreatments.get(0).getInHospitalCdB4(), nullValue());
    assertThat(sortedCompTreatments.get(1).getCompTreatmentCd(), equalTo(2));
    assertThat(sortedCompTreatments.get(1).getTreatment(), equalTo("rename2"));
    assertThat(sortedCompTreatments.get(1).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedCompTreatments.get(1).getTreatClass(), equalTo("2"));
    assertThat(sortedCompTreatments.get(1).getTreatMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(1).getAmount(), equalTo(null));
    assertThat(sortedCompTreatments.get(1).getProcedureCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(1).getTakeMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(1).getIsDisp(), equalTo("1"));
    assertThat(sortedCompTreatments.get(1).getIsDel(), equalTo("0"));
    assertThat(sortedCompTreatments.get(1).getIsUpdate(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospAStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdA1(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdA2(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdA3(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdA4(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospBStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdB1(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdB2(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdB3(), nullValue());
    assertThat(sortedCompTreatments.get(1).getInHospitalCdB4(), nullValue());
    assertThat(sortedCompTreatments.get(2).getCompTreatmentCd(), equalTo(3));
    assertThat(sortedCompTreatments.get(2).getTreatment(), equalTo("name3"));
    assertThat(sortedCompTreatments.get(2).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedCompTreatments.get(2).getTreatClass(), equalTo("2"));
    assertThat(sortedCompTreatments.get(2).getTreatMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(2).getAmount(), equalTo(null));
    assertThat(sortedCompTreatments.get(2).getProcedureCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(2).getTakeMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(2).getIsDisp(), equalTo("0"));
    assertThat(sortedCompTreatments.get(2).getIsDel(), equalTo("0"));
    assertThat(sortedCompTreatments.get(2).getIsUpdate(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospAStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdA1(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdA2(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdA3(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdA4(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospBStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdB1(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdB2(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdB3(), nullValue());
    assertThat(sortedCompTreatments.get(2).getInHospitalCdB4(), nullValue());
    assertThat(sortedCompTreatments.get(3).getCompTreatmentCd(), equalTo(4));
    assertThat(sortedCompTreatments.get(3).getTreatment(), equalTo("rename4"));
    assertThat(sortedCompTreatments.get(3).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedCompTreatments.get(3).getTreatClass(), equalTo("1"));
    assertThat(sortedCompTreatments.get(3).getTreatMedicineCd(), equalTo(2));
    assertThat(sortedCompTreatments.get(3).getAmount(), equalTo(new BigDecimal("3.12")));
    assertThat(sortedCompTreatments.get(3).getProcedureCd(), equalTo(4));
    assertThat(sortedCompTreatments.get(3).getTakeMedicineCd(), equalTo(5));
    assertThat(sortedCompTreatments.get(3).getIsDisp(), equalTo("0"));
    assertThat(sortedCompTreatments.get(3).getIsDel(), equalTo("0"));
    assertThat(sortedCompTreatments.get(3).getIsUpdate(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospAStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdA1(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdA2(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdA3(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdA4(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospBStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdB1(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdB2(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdB3(), nullValue());
    assertThat(sortedCompTreatments.get(3).getInHospitalCdB4(), nullValue());
    assertThat(sortedCompTreatments.get(4).getCompTreatmentCd(), equalTo(5));
    assertThat(sortedCompTreatments.get(4).getTreatment(), equalTo("name5"));
    assertThat(sortedCompTreatments.get(4).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedCompTreatments.get(4).getTreatClass(), equalTo("0"));
    assertThat(sortedCompTreatments.get(4).getTreatMedicineCd(), equalTo(12));
    assertThat(sortedCompTreatments.get(4).getAmount(), equalTo(new BigDecimal("13.12")));
    assertThat(sortedCompTreatments.get(4).getProcedureCd(), equalTo(14));
    assertThat(sortedCompTreatments.get(4).getTakeMedicineCd(), equalTo(15));
    assertThat(sortedCompTreatments.get(4).getIsDisp(), equalTo("1"));
    assertThat(sortedCompTreatments.get(4).getIsDel(), equalTo("0"));
    assertThat(sortedCompTreatments.get(4).getIsUpdate(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospAStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdA1(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdA2(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdA3(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdA4(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospBStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdB1(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdB2(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdB3(), nullValue());
    assertThat(sortedCompTreatments.get(4).getInHospitalCdB4(), nullValue());
    assertThat(sortedCompTreatments.get(5).getCompTreatmentCd(), equalTo(8));
    assertThat(sortedCompTreatments.get(5).getTreatment(), equalTo("addname8"));
    assertThat(sortedCompTreatments.get(5).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedCompTreatments.get(5).getTreatClass(), equalTo("2"));
    assertThat(sortedCompTreatments.get(5).getTreatMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(5).getAmount(), equalTo(null));
    assertThat(sortedCompTreatments.get(5).getProcedureCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(5).getTakeMedicineCd(), equalTo(null));
    assertThat(sortedCompTreatments.get(5).getIsDisp(), equalTo("1"));
    assertThat(sortedCompTreatments.get(5).getIsDel(), equalTo("0"));
    assertThat(sortedCompTreatments.get(5).getIsUpdate(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospAStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdA1(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdA2(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdA3(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdA4(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospBStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdB1(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdB2(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdB3(), nullValue());
    assertThat(sortedCompTreatments.get(5).getInHospitalCdB4(), nullValue());
    assertThat(sortedCompTreatments.get(6).getCompTreatmentCd(), equalTo(9));
    assertThat(sortedCompTreatments.get(6).getTreatment(), equalTo("addname9"));
    assertThat(sortedCompTreatments.get(6).getFacilityCd(), equalTo(facilityCd));
    assertThat(sortedCompTreatments.get(6).getTreatClass(), equalTo("0"));
    assertThat(sortedCompTreatments.get(6).getTreatMedicineCd(), equalTo(92));
    assertThat(sortedCompTreatments.get(6).getAmount(), equalTo(new BigDecimal("99.12")));
    assertThat(sortedCompTreatments.get(6).getProcedureCd(), equalTo(94));
    assertThat(sortedCompTreatments.get(6).getTakeMedicineCd(), equalTo(95));
    assertThat(sortedCompTreatments.get(6).getIsDisp(), equalTo("1"));
    assertThat(sortedCompTreatments.get(6).getIsDel(), equalTo("0"));
    assertThat(sortedCompTreatments.get(6).getIsUpdate(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospAStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdA1(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdA2(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdA3(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdA4(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospBStartdate(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdB1(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdB2(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdB3(), nullValue());
    assertThat(sortedCompTreatments.get(6).getInHospitalCdB4(), nullValue());

    // マスタセレクタ
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_comp_treatment");
    assertThat(mstSelector.getOrderSettings().getItems(), hasSize(5));
    assertThat(mstSelector.getOrderSettings().getItems().get(0).getCode(), equalTo(1L));
    assertThat(mstSelector.getOrderSettings().getItems().get(0).getName(), equalTo("rename1"));
    assertThat(mstSelector.getOrderSettings().getItems().get(1).getCode(), equalTo(5L));
    assertThat(mstSelector.getOrderSettings().getItems().get(1).getName(), equalTo("name5"));
    assertThat(mstSelector.getOrderSettings().getItems().get(2).getCode(), equalTo(8L));
    assertThat(mstSelector.getOrderSettings().getItems().get(2).getName(), equalTo("addname8"));
    assertThat(mstSelector.getOrderSettings().getItems().get(3).getCode(), equalTo(2L));
    assertThat(mstSelector.getOrderSettings().getItems().get(3).getName(), equalTo("rename2"));
    assertThat(mstSelector.getOrderSettings().getItems().get(4).getCode(), equalTo(9L));
    assertThat(mstSelector.getOrderSettings().getItems().get(4).getName(), equalTo("addname9"));
  }
}
