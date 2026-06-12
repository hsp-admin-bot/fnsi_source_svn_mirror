package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.authority.UserAuthorityRequest;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
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

/**
 * {@link UserAuthorityResource}の結合テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/UserAuthorityResourceIntegrationTest.before.sql")
public class UserAuthorityResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper objectMapper;

  /**
   * getUserAuthority()の検証.
   * 条件: ユーザーIDに該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_getUserAuthority_成功() throws Exception {
    // arrange
    Long userId = 2L;

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/user-authority/{user_id}/list", userId)
        .contentType(MediaType.APPLICATION_JSON));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$[0]", is("001")))
      .andExpect(jsonPath("$[1]", is("002")))
      .andExpect(jsonPath("$[2]", is("003")))

      .andDo(document("user_authority/list/get/ok",
        pathParameters(
          parameterWithName("user_id").description("[必須]ユーザーID")
        ),
        responseFields(
          attributes(
            key("description").value("概要：指定されたユーザーIDに該当する利用者マスタの許可権限情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：利用者マスタ (mst_user)")
          ),
          fieldWithPath("[]").description("許可されている権限のリスト")
        )))
    ;
  }

  /**
   * getUserAuthority()の検証.
   * 条件: ユーザーIDに該当するレコードが登録されていない
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser
  public void test_getUserAuthority_失敗_該当データなし() throws Exception {
    // arrange
    Long userId = Long.MAX_VALUE;

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/user-authority/{user_id}/list", userId)
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("user_authority/list/get/not-found"))
    ;
  }

  /**
   * getLoginUserAuthority()の検証.
   * 条件: ユーザーIDに該当するレコードが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(userId = 2)
  public void test_getLoginUserAuthority_成功() throws Exception {
    // arrange
    Long userId = 2L;

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/user-authority/login/list")
        .contentType(MediaType.APPLICATION_JSON));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$[0]", is("001")))
      .andExpect(jsonPath("$[1]", is("002")))
      .andExpect(jsonPath("$[2]", is("003")))

      .andDo(document("user_authority/login/list/get/ok",
        responseFields(
          attributes(
            key("description").value("概要：指定されたユーザーIDに該当する利用者マスタの許可権限情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：利用者マスタ (mst_user)")
          ),
          fieldWithPath("[]").description("許可されている権限のリスト")
        )))
    ;
  }

  /**
   * getLoginUserAuthority()の検証.
   * 条件: ユーザーIDに該当するレコードが登録されていない
   * 結果: HttpStatus 500 が返却されること
   */
  @Test
  @NtssMockUser(userId = Long.MAX_VALUE)
  public void test_getLoginUserAuthority_失敗_該当データなし() throws Exception {
    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.get("/api/user-authority/login/list")
        .contentType(MediaType.APPLICATION_JSON));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("user_authority/login/list/get/not-found"))
    ;
  }

  /**
   * updateUserAuthority()の検証.
   * 条件: ユーザーIDに該当するレコードが登録されていること
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser
  public void test_updateUserAuthority_成功_利用マスタのうちユーザー情報を更新できること() throws Exception {
    // arrange
    final Long userId1 = 2L;
    final MstUser beUpdated1 = mstUserDao.selectById(userId1);
    List<String> authorities1 = Arrays.asList("004", "005", "006");
    beUpdated1.getUserSettings().setAuthorizedAuthorities(authorities1);

    final Long userId2 = 3L;
    final MstUser beUpdated2 = mstUserDao.selectById(userId2);
    List<String> authorities2 = Arrays.asList("204", "205", "206");
    beUpdated2.getUserSettings().setAuthorizedAuthorities(authorities2);

    List<UserAuthorityRequest> userAuthorities = Arrays.asList(
      new UserAuthorityRequest() {
        {
          setUserId(userId1);
          setAuthorities(authorities1);
          setSignoutFlg(false);
        }
      },
      new UserAuthorityRequest() {
        {
          setUserId(userId2);
          setAuthorities(authorities2);
          setSignoutFlg(false);
        }
      }
    );
    final String requestBody = objectMapper.writeValueAsString(userAuthorities);

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.put("/api/user-authority/list")
        .contentType(MediaType.APPLICATION_JSON)
        .content(requestBody)
        .with(csrf())
      );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("user_authority/list/put/ok",
        requestFields(
          attributes(
            key("description").value("概要：指定されたユーザーIDに該当する利用者マスタの許可権限情報（ユーザー情報）を更新するAPI"),
            key("operationTargetTable").value("操作対象テーブル：利用者マスタ (mst_user)")
          ),
          fieldWithPath("[]").description("利用者権限情報のリスト"),
          fieldWithPath("[].userId").description("ユーザーID"),
          fieldWithPath("[].authorities").description("許可する権限のリスト"),
          fieldWithPath("[].signoutFlg").description("サインアウトフラグ")
        )
      ))
    ;

    // 更新後の利用者マスタを検証
    final MstUser updated1 = mstUserDao.selectById(userId1);
    assertThat(updated1.getUserId()).isEqualTo(beUpdated1.getUserId());
    assertThat(updated1.getUserSettings().getAuthorizedAuthorities()).isEqualTo(beUpdated1.getUserSettings().getAuthorizedAuthorities());
    // ユーザー情報の許可権限情報以外が変更されていないことの検証は、他の1項目で行う
    assertThat(updated1.getUserSettings().getTheme()).isEqualTo(beUpdated1.getUserSettings().getTheme());
    assertThat(updated1.getIsProvisional()).isEqualTo(beUpdated1.getIsProvisional());
    assertThat(updated1.getIsDisp()).isEqualTo(beUpdated1.getIsDisp());
    assertThat(updated1.getIsDel()).isEqualTo(beUpdated1.getIsDel());

    final MstUser updated2 = mstUserDao.selectById(userId2);
    assertThat(updated2.getUserId()).isEqualTo(beUpdated2.getUserId());
    assertThat(updated2.getUserSettings().getAuthorizedAuthorities()).isEqualTo(beUpdated2.getUserSettings().getAuthorizedAuthorities());
  }

  /**
   * updateUserAuthority()の検証.
   * 条件: ユーザーIDに該当するレコードが登録されていないこと
   * 結果: HTTPステータス500が返ってくること
   */
  @Test
  @NtssMockUser
  public void test_updateUserAuthority_失敗_利用者マスタに存在しないユーザーIDを指定した場合_500が返ること() throws Exception {
    final Long userId = Long.MAX_VALUE;

    List<UserAuthorityRequest> userAuthorities = Arrays.asList(
      new UserAuthorityRequest() {
        {
          setUserId(userId);
          setAuthorities(Collections.emptyList());
          setSignoutFlg(false);
        }
      }
    );
    final String requestBody = objectMapper.writeValueAsString(userAuthorities);

    // action
    ResultActions result = mockMvc
      .perform(RestDocumentationRequestBuilders.put("/api/user-authority/list")
        .contentType(MediaType.APPLICATION_JSON).content(requestBody));

    // assert
    result
      .andExpect(status().isInternalServerError())
      .andDo(document("user_authority/list/put/not-found",
        requestFields(
          attributes(
            key("description").value(""),
            key("operationTargetTable").value("")
          ),
          fieldWithPath("[]").description("利用者権限情報のリスト"),
          fieldWithPath("[].userId").description("ユーザーID"),
          fieldWithPath("[].authorities").description("許可する権限のリスト"),
          fieldWithPath("[].signoutFlg").description("サインアウトフラグ")
        )
      ))
    ;

  }

}
