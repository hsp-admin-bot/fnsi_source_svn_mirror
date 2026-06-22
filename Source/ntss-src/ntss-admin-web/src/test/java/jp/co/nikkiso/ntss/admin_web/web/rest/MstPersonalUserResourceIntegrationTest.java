package jp.co.nikkiso.ntss.admin_web.web.rest;

import static jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import static jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
@Transactional
@Sql(value = "classpath:resource.script/MstPersonalUserResourceIntegrationTest.before.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
public class MstPersonalUserResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * 利用者マスタのサービス
   */
  @Autowired
  private PersonalUserService personalUserService;

  /**
   * getNameAndHasEmailAddressの検証.
   *
   * 条件：成功, 利用者マスタに利用者あり
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "0001")
  public void 利用者名とメールアドレス登録有無を取得できること() throws Exception {
    // action
    mockMvc
      .perform(get("/api/personal_user/has_email"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.personalUsers", hasSize(3)))
      .andExpect(jsonPath("$.personalUsers[0].userId", is(1)))
      .andExpect(jsonPath("$.personalUsers[0].lastName", is("lastName1")))
      .andExpect(jsonPath("$.personalUsers[0].firstName", is("firstName1")))
      .andExpect(jsonPath("$.personalUsers[0].hasEmailAddress1", is(true)))
      .andExpect(jsonPath("$.personalUsers[0].hasEmailAddress2", is(true)))
      .andExpect(jsonPath("$.personalUsers[1].userId", is(2)))
      .andExpect(jsonPath("$.personalUsers[1].lastName", is("lastName2")))
      .andExpect(jsonPath("$.personalUsers[1].firstName", is("firstName2")))
      .andExpect(jsonPath("$.personalUsers[1].hasEmailAddress1", is(true)))
      .andExpect(jsonPath("$.personalUsers[1].hasEmailAddress2", is(false)))
      .andExpect(jsonPath("$.personalUsers[2].userId", is(3)))
      .andExpect(jsonPath("$.personalUsers[2].lastName", is("lastName3")))
      .andExpect(jsonPath("$.personalUsers[2].firstName", is("firstName3")))
      .andExpect(jsonPath("$.personalUsers[2].hasEmailAddress1", is(true)))
      .andExpect(jsonPath("$.personalUsers[2].hasEmailAddress2", is(false)))
      .andDo(document("personal_user/has_email/get/ok",
        responseFields(
          attributes(
            key("description").value("概要:ログイン中のユーザーが所属する施設内の利用者の名前と、メールアドレス登録有無を取得する")
            , key("operationTargetTable").value("操作対象テーブル:利用者マスタ（mst_personal_user）")
          ),
          fieldWithPath("personalUsers").description("利用者の名前とメールアドレス登録有無")
          , fieldWithPath("personalUsers[].userId").description("[必須]利用者ID")
          , fieldWithPath("personalUsers[].lastName").description("[必須]利用者名（姓）")
          , fieldWithPath("personalUsers[].firstName").description("[必須]利用者名（名）")
          , fieldWithPath("personalUsers[].hasEmailAddress1").description("[必須]メールアドレス1登録有無（true: 登録あり）")
          , fieldWithPath("personalUsers[].hasEmailAddress2").description("[必須]メールアドレス2登録有無（true: 登録あり）")
        )))
    ;
  }

  /**
   * getNameAndHasEmailAddressの検証.
   *
   * 条件：成功, 利用者マスタに利用者なし
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "0002")
  public void 指定した施設に利用者名がいない場合_空のリストを取得できること() throws Exception {
    // action
    mockMvc
      .perform(get("/api/personal_user/has_email"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.personalUsers", hasSize(0)))
    ;
  }
}
