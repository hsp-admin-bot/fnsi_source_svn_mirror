package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.get;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;

/**
 * SysPersonalSettingsDefineResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/SysPersonalSettingsDefineResourceIntegrationTest.before.sql")
public class SysPersonalSettingsDefineResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * getPersonalSettingsDefine()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "999999")
  public void test_getPersonalSettingsDefine_成功_データあり() throws Exception {
    // arrange
    final Integer tabDefineCd = 1;

    // action
    // assert
    mockMvc
      .perform(get("/api/personal_setting_define/{tab_define_cd}", tabDefineCd)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$.tab_define_cd", is(tabDefineCd)))
      .andExpect(jsonPath("$.edit_level", is("1")))
      .andExpect(jsonPath("$.item_info", hasSize(3)))
      .andExpect(jsonPath("$.item_info[0].type", is(SysPersonalSettingsDefine.ItemType.STRING.getValue())))
      .andExpect(jsonPath("$.item_info[0].title", is("項目3-1")))
      .andExpect(jsonPath("$.item_info[0].identifier", is("1")))
      .andExpect(jsonPath("$.item_info[0].validation", nullValue()))
      .andExpect(jsonPath("$.item_info[1].type", is(SysPersonalSettingsDefine.ItemType.NUMBER.getValue())))
      .andExpect(jsonPath("$.item_info[1].title", is("項目3-2")))
      .andExpect(jsonPath("$.item_info[1].identifier", is("2")))
      .andExpect(jsonPath("$.item_info[1].validation", notNullValue()))
      .andExpect(jsonPath("$.item_info[1].validation.maxlength", nullValue()))
      .andExpect(jsonPath("$.item_info[1].validation.min", nullValue()))
      .andExpect(jsonPath("$.item_info[1].validation.max", is(5000)))
      .andExpect(jsonPath("$.item_info[1].validation.digit", nullValue()))
      .andExpect(jsonPath("$.item_info[1].validation.required", nullValue()))
      .andExpect(jsonPath("$.item_info[2].type", is(SysPersonalSettingsDefine.ItemType.COMBO2.getValue())))
      .andExpect(jsonPath("$.item_info[2].title", is("項目3-4")))
      .andExpect(jsonPath("$.item_info[2].identifier", is("4")))
      .andExpect(jsonPath("$.item_info[2].validation", notNullValue()))
      .andExpect(jsonPath("$.item_info[2].validation.maxlength", is(100)))
      .andExpect(jsonPath("$.item_info[2].validation.min", is(0.5)))
      .andExpect(jsonPath("$.item_info[2].validation.max", is(100)))
      .andExpect(jsonPath("$.item_info[2].validation.digit", is(2)))
      .andExpect(jsonPath("$.item_info[2].validation.required", is(true)))
      .andExpect(jsonPath("$.combo_data", hasSize(3)))
      .andExpect(jsonPath("$.combo_data[0].setting_identifier", is("1")))
      .andExpect(jsonPath("$.combo_data[0].values", hasSize(3)))
      .andExpect(jsonPath("$.combo_data[0].values[0].text", is("データ1")))
      .andExpect(jsonPath("$.combo_data[0].values[0].value", is(1)))
      .andExpect(jsonPath("$.combo_data[0].values[1].text", is("データ2")))
      .andExpect(jsonPath("$.combo_data[0].values[1].value", is(2)))
      .andExpect(jsonPath("$.combo_data[0].values[2].text", is("データ5")))
      .andExpect(jsonPath("$.combo_data[0].values[2].value", is(5)))
      .andExpect(jsonPath("$.combo_data[1].setting_identifier", is("2")))
      .andExpect(jsonPath("$.combo_data[1].values", hasSize(2)))
      .andExpect(jsonPath("$.combo_data[1].values[0].text", is("データ6")))
      .andExpect(jsonPath("$.combo_data[1].values[0].value", is("hoge")))
      .andExpect(jsonPath("$.combo_data[1].values[1].text", is("データ7")))
      .andExpect(jsonPath("$.combo_data[1].values[1].value", is("fuga")))
      .andExpect(jsonPath("$.combo_data[2].setting_identifier", is("4")))
      .andExpect(jsonPath("$.combo_data[2].values", hasSize(3)))
      .andExpect(jsonPath("$.combo_data[2].values[0].text", is("name1")))
      .andExpect(jsonPath("$.combo_data[2].values[0].value", is(100)))
      .andExpect(jsonPath("$.combo_data[2].values[1].text", is("name4")))
      .andExpect(jsonPath("$.combo_data[2].values[1].value", is(400)))
      .andExpect(jsonPath("$.combo_data[2].values[2].text", is("name2")))
      .andExpect(jsonPath("$.combo_data[2].values[2].value", is(200)))
      .andDo(document("personal_settings/define/get/ok",
        pathParameters(
              parameterWithName("tab_define_cd").description("タブ定義コード")),
          responseFields(
            attributes(
              key("description").value("概要：指定されたタブ定義コードに該当する共通設定タブ定義を取得するAPI"),
              key("operationTargetTable").value("操作対象テーブル：共通設定タブ定義 (sys_personal_settings_define)")
            ),
            fieldWithPath("tab_define_cd").description("[必須]タブ定義コード"),
            fieldWithPath("edit_level").description("[必須]表示管理レベル(1:全ユーザ、2:管理者のみ、3:日機装社員のみ、4:日機装社員・管理者のみ、1～4以外：非表示)"),
            fieldWithPath("item_info[]").description("項目情報"),
            fieldWithPath("item_info[].type").description("形式"),
            fieldWithPath("item_info[].title").description("表示名"),
            fieldWithPath("item_info[].identifier").description("設定値と紐づく文字列"),
            fieldWithPath("item_info[].validation").optional().description("バリデーション設定"),
            fieldWithPath("item_info[].validation.maxlength").description("バリデーション設定：最大長"),
            fieldWithPath("item_info[].validation.min").description("バリデーション設定：最小値"),
            fieldWithPath("item_info[].validation.max").description("バリデーション設定：最大値"),
            fieldWithPath("item_info[].validation.digit").description("バリデーション設定：小数点以下の桁数"),
            fieldWithPath("item_info[].validation.required").description("バリデーション設定：必須かどうか(true:必須、false:必須でない)"),
            fieldWithPath("combo_data[]").optional().description("コンボボックス設定"),
            fieldWithPath("combo_data[].setting_identifier").description("設定値と紐づく文字列"),
            fieldWithPath("combo_data[].values[]").description("コンボとして表示するデータ"),
            fieldWithPath("combo_data[].values[].text").description("表示名"),
            fieldWithPath("combo_data[].values[].value").description("値")
          )
      ))
    ;
  }

  /**
   * getPersonalSettingsDefine()の検証.
   * <p>
   * 条件：失敗。指定したタブ定義コードに紐づく定義が存在しない場合。
   * 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "999999")
  public void test_getPersonalSettingsDefine_失敗_データなし() throws Exception {
    // arrange
    final Integer tabDefineCd = 999;

    // action
    // assert
    mockMvc
      .perform(get("/api/personal_setting_define/{tab_define_cd}", tabDefineCd)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isInternalServerError())
      .andDo(
        document("personal_settings/define/get/not-found",
          pathParameters(
            parameterWithName("tab_define_cd").description("タブ定義コード")
          )
        )
      )
    ;
  }
}
