package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

/**
 * ComboResourceの結合テストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/ComboResourceIntegrationTest.before.sql")
public class ComboResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * getComboList()の検証.
   * 条件: 参照先のマスタにデータ1件が登録されている<br>
   * 結果: レスポンスが生成されること
   */
  @Test
  @NtssMockUser
  public void test_getComboList_成功_1件取得() throws Exception {
    // arrange
    final String targetTableName = "test_table_has_a_record";
    final String cdColName = "key1";
    final String textColName = "col1_1";

    // action
    ResultActions result
      = mockMvc.perform(get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", targetTableName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(1)))
      .andExpect(jsonPath("$[0].text", is("record1-1")))
      .andExpect(jsonPath("$[0].cd", is(1)))
    ;
  }

  /**
   * getComboList()の検証.
   * 条件: 参照先のマスタにデータ複数件が登録されている<br>
   * 結果: レスポンスが返却されること
   */
  @Test
  @NtssMockUser
  public void test_getComboList_成功_複数件取得() throws Exception {
    // arrange
    final String targetTableName = "test_table_has_some_records";
    final String cdColName = "key2";
    final String textColName = "col2_1";

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", targetTableName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(3)))
      .andExpect(jsonPath("$[0].text", is("record2-1")))
      .andExpect(jsonPath("$[0].cd", is(11)))
      .andExpect(jsonPath("$[1].text", is("record2-2")))
      .andExpect(jsonPath("$[1].cd", is(12)))
      .andExpect(jsonPath("$[2].text", is("record2-4")))
      .andExpect(jsonPath("$[2].cd", is(14)))
      .andDo(document("combo/ok",
        pathParameters(
          parameterWithName("master_physical_name").description("[必須]コンボの元となるマスタの物理名"),
          parameterWithName("text_column_physical_name").description("[必須]コンボに表示するカラムの物理名"),
          parameterWithName("cd_column_physical_name").description("[必須]主キーであるカラムの物理名")
        ),
        responseFields(
          attributes(
            key("description").value("概要：参照型コンボを表示するためのデータを取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：不定。パラメータmaster_physical_nameで指定するテーブルが操作対象となる")
          ),
          fieldWithPath("[].text").description("[必須]text_column_physical_nameで指定したカラムの値（表示用）"),
          fieldWithPath("[].cd").description("[必須]マスタのシリアル値（コンボのvalue用）")
        )))
    ;
  }

  /**
   * getComboList()の検証.
   * 条件: 参照先のマスタにデータが登録されてない<br>
   * 結果: 空のレスポンスが返却されること
   */
  @Test
  @NtssMockUser
  public void test_getComboList_成功_0件取得_コンボの元となるマスタにレコードが存在しない() throws Exception {
    // arrange
    final String targetTableName = "test_table_has_no_records";
    final String cdColName = "key3";
    final String textColName = "col3_1";

    // action
    ResultActions result
      = mockMvc.perform(get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", targetTableName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }

  /**
   * getComboList()の検証.
   * 条件: 並び順マスタに参照先のマスタが登録されてない<br>
   * 結果: 空のレスポンスが返却されること
   */
  @Test
  @NtssMockUser
  public void test_getComboList_成功_0件取得_並び順マスタにレコードが存在しない() throws Exception {
    // arrange
    final String targetTableName = "test_table_not_present_at_mst_selector";
    final String cdColName = "key4";
    final String textColName = "col4_1";

    // action
    ResultActions result
      = mockMvc.perform(get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", targetTableName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }

  /**
   * getComboList()の検証.
   * 条件: パラメータに存在しないマスタ物理名を指定する
   * 結果: HttpStatus 400 が返却されること
   */
  @Test
  @NtssMockUser
  public void test_getComboList_失敗_マスタ物理名間違い() throws Exception {
    // arrange
    final String targetTableName = "xxx_not_exist";
    final String cdColName = "anything_good";
    final String textColName = "anything_good";

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", targetTableName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.message", is("スキーマ情報の定義に誤りがあります。")))
      .andDo(document("combo/invalid-master",
        pathParameters(
          parameterWithName("master_physical_name").description("[必須]コンボの元となるマスタの物理名"),
          parameterWithName("text_column_physical_name").description("[必須]コンボに表示するカラムの物理名"),
          parameterWithName("cd_column_physical_name").description("[必須]主キーであるカラムの物理名")
        )))
    ;
  }

  /**
   * getComboList()の検証.
   * 条件: パラメータに存在しないカラム物理名を指定する
   * 結果: HttpStatus 400 が返却されること
   */
  @Test
  @NtssMockUser
  public void test_getComboList_失敗_カラム物理名間違い() throws Exception {
    // arrange
    final String targetTableName = "test_table_has_some_records";
    final String cdColName = "xxx_not_exist";
    final String textColName = "anything_good";

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", targetTableName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.message", is("スキーマ情報の定義に誤りがあります。")))
      .andDo(document("combo/invalid-column",
        pathParameters(
          parameterWithName("master_physical_name").description("[必須]コンボの元となるマスタの物理名"),
          parameterWithName("text_column_physical_name").description("[必須]コンボに表示するカラムの物理名"),
          parameterWithName("cd_column_physical_name").description("[必須]主キーであるカラムの物理名")
        )))
    ;
  }
}
