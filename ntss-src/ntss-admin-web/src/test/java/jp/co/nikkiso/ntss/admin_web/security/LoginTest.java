package jp.co.nikkiso.ntss.admin_web.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.CoreMatchers.is;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import jp.co.nikkiso.ntss.admin_web.service.authority.UserAuthorityService;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlConfig;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.ResultMatcher;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;

import jakarta.servlet.http.HttpSession;
import java.util.Collections;

/**
 * Spring Securityログインのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional(TransactionManagerName.ALL)
@Sql(value = "classpath:resource.script/LoginTest.default.before.sql", config = @SqlConfig(dataSource = DataSourceName.DEFAULT, transactionManager = TransactionManagerName.DEFAULT))
@Sql(value = "classpath:resource.script/LoginTest.auth.before.sql", config = @SqlConfig(dataSource = DataSourceName.AUTH, transactionManager = TransactionManagerName.AUTH))
@Sql(value = "classpath:resource.script/LoginTest.personal.before.sql", config = @SqlConfig(dataSource = DataSourceName.PERSONAL, transactionManager = TransactionManagerName.PERSONAL))
public class LoginTest {

  /**
   * MockMVC.
   */
  @Autowired
  private MockMvc mockMvc;

  /**
   * 利用者権限ServiceのMockBean.
   */
  @MockitoBean
  private UserAuthorityService userAuthorityService;

  /**
   * ログインの検証.
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @Ignore("ログイン機能強化に伴い、テストケースを見直す必要がある為、本テストケースは無効化にする")
  public void test_login_成功() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    String password = "password";
    Long innerUserId = 900000000001L;
    String realFacilityCd = "900001";
    Integer userType = 0;

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(innerUserId)).willReturn(Collections.EMPTY_LIST);

    // API実行
    ResultActions result = mockMvc.perform(post("/api/login")
        .param(NtssAuthenticationConstants.Params.USERNAME, userId)
        .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
        .param(NtssAuthenticationConstants.Params.PASSWORD, password).with(csrf()));

    // 検証
    result
      .andDo(mvcResult -> {
        final HttpSession session = mvcResult.getRequest().getSession();
        assertThat(session.getMaxInactiveInterval()).isEqualTo(35 * 60);
      })
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.facilityCd", is(realFacilityCd)))
      .andExpect(jsonPath("$.userId", is(innerUserId)))
      .andExpect(jsonPath("$.userType", is(userType)));
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(innerUserId);
  }

  /**
   * ログインの検証(機能コード指定).
   * <p>
   *   条件：成功
   *   結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @Ignore("ログイン機能強化に伴い、テストケースを見直す必要がある為、本テストケースは無効化にする")
  public void test_login_成功_機能コード指定() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    Long innerUserId = 900000000001L;
    String realFacilityCd = "900001";
    Integer userType = 0;
    String funcCd = "001";

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(innerUserId)).willReturn(Collections.EMPTY_LIST);

    // API実行
    ResultActions result = mockMvc.perform(post("/api/login")
        .param(NtssAuthenticationConstants.Params.USERNAME, userId)
        .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
        .param(NtssAuthenticationConstants.Params.FUNC_CD, funcCd).with(csrf()));

    // 検証
    result
      .andDo(mvcResult -> {
        final HttpSession session = mvcResult.getRequest().getSession();
        assertThat(session.getMaxInactiveInterval()).isEqualTo(35 * 60);
      })
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.facilityCd", is(realFacilityCd)))
      .andExpect(jsonPath("$.userId", is(innerUserId)))
      .andExpect(jsonPath("$.userType", is(userType)));
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(innerUserId);
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：失敗（パスワードが違う）
   *   結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  public void test_login_失敗_パスワードが違う() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    String password = "password2";

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    // API実行
    ResultActions result = mockMvc.perform(post("/api/login")
        .param(NtssAuthenticationConstants.Params.USERNAME, userId)
        .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
        .param(NtssAuthenticationConstants.Params.PASSWORD, password).with(csrf()));

    // 検証
    result.andExpect(status().isForbidden());
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(anyLong());
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：失敗（ユーザーIDが違う）
   *   結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  public void test_login_失敗_ユーザーIDが違う() throws Exception {
    // 事前準備
    String userId = "880000000001";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    String password = "password";

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    // API実行
    ResultActions result = mockMvc.perform(post("/api/login")
        .param(NtssAuthenticationConstants.Params.USERNAME, userId)
        .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
        .param(NtssAuthenticationConstants.Params.PASSWORD, password).with(csrf()));

    // 検証
    result.andExpect(status().isForbidden());
    verify(userAuthorityService, times(0)).getAuthorizedAuthorities(anyLong());
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：失敗（施設コードが違う）
   *   結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  public void test_login_失敗_施設コードが違う() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "$2a$10$ZjibZwxMlvxV8wRUQPDmeOlmGIU7092XDEU6sTVUha0si/Qg534rC";
    String password = "password";

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    // API実行
    ResultActions result = mockMvc.perform(post("/api/login")
        .param(NtssAuthenticationConstants.Params.USERNAME, userId)
        .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
        .param(NtssAuthenticationConstants.Params.PASSWORD, password).with(csrf()));

    // 検証
    result.andExpect(status().isForbidden());
    verify(userAuthorityService, times(0)).getAuthorizedAuthorities(anyLong());
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：失敗（施設コードハッシュ値から施設コードが取得できない）
   *   結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  public void test_login_失敗_施設コードハッシュ値から施設コードが取得できない() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "invalid_hash";
    String password = "password";

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    // API実行
    ResultActions result = mockMvc.perform(post("/api/login")
        .param(NtssAuthenticationConstants.Params.USERNAME, userId)
        .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
        .param(NtssAuthenticationConstants.Params.PASSWORD, password).with(csrf()));

    // 検証
    result.andExpect(status().isForbidden());
    verify(userAuthorityService, times(0)).getAuthorizedAuthorities(anyLong());
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：4回失敗したあとに正しいパスワードを指定
   *   結果：最後のリクエストで成功レスポンスが返されること
   * </p>
   */
  @Test
  @Ignore("ログイン機能強化に伴い、テストケースを見直す必要がある為、本テストケースは無効化にする")
  public void test_login_成功_4回失敗した後に正しいパスワード() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    String[] passwords = {"a", "a", "a", "a", "password"};
    ResultMatcher[] matchers = {
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
        status().isOk(),
    };

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    for (int i = 0; i < passwords.length; i++) {
      // API実行
      ResultActions result = mockMvc.perform(post("/api/login")
          .param(NtssAuthenticationConstants.Params.USERNAME, userId)
          .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
          .param(NtssAuthenticationConstants.Params.PASSWORD, passwords[i]).with(csrf()));

      // 検証
      result.andExpect(matchers[i]);
      verify(userAuthorityService, times(i + 1)).getAuthorizedAuthorities(anyLong());
    }
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：5回失敗したあとに正しいパスワードを指定
   *   結果：最後のリクエストで失敗レスポンスが返されること
   * </p>
   */
  @Test
  public void test_login_失敗_5回失敗した後に正しいパスワード() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    String[] passwords = {"a", "a", "a", "a", "a", "password"};
    ResultMatcher[] matchers = {
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
    };

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    for (int i = 0; i < passwords.length; i++) {
      // API実行
      ResultActions result = mockMvc.perform(post("/api/login")
          .param(NtssAuthenticationConstants.Params.USERNAME, userId)
          .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
          .param(NtssAuthenticationConstants.Params.PASSWORD, passwords[i]).with(csrf()));

      // 検証
      result.andExpect(matchers[i]);
      verify(userAuthorityService, times(i + 1)).getAuthorizedAuthorities(anyLong());
    }
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：2回失敗→1回成功→4回失敗 のあとに正しいパスワードを指定
   *   結果：最後のリクエストで成功レスポンスが返されること
   * </p>
   */
  @Test
  @Ignore("ログイン機能強化に伴い、テストケースを見直す必要がある為、本テストケースは無効化にする")
  public void test_login_成功_認証成功時に失敗回数がクリアされることの確認() throws Exception {
    // 事前準備
    String userId = "800000000001";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    String[] passwords = {"a", "a", "password", "a", "a", "a", "a", "password"};
    ResultMatcher[] matchers = {
        status().isForbidden(),
        status().isForbidden(),
        status().isOk(),
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
        status().isForbidden(),
        status().isOk(),
    };

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    for (int i = 0; i < passwords.length; i++) {
      // API実行
      ResultActions result = mockMvc.perform(post("/api/login")
          .param(NtssAuthenticationConstants.Params.USERNAME, userId)
          .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
          .param(NtssAuthenticationConstants.Params.PASSWORD, passwords[i]).with(csrf()));

      // 検証
      result.andExpect(matchers[i]);
      verify(userAuthorityService, times(i + 1)).getAuthorizedAuthorities(anyLong());
    }
  }

  /**
   * ログインの検証.
   * <p>
   *   条件：失敗
   *   結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  public void test_login_失敗_データ不整合() throws Exception {
    // 事前準備
    String userId = "800000000002";
    String facilityCd = "$2a$10$Ei5Hfv.SHGLaWeFLNQKtPOljvGEBkp.kpJINs12vpIcg0/qVcbhGy";
    String password = "password";

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(Collections.EMPTY_LIST);

    // API実行
    ResultActions result = mockMvc.perform(post("/api/login")
        .param(NtssAuthenticationConstants.Params.USERNAME, userId)
        .param(NtssAuthenticationConstants.Params.FACILITY_CD, facilityCd)
        .param(NtssAuthenticationConstants.Params.PASSWORD, password).with(csrf()));

    // 検証
    result.andExpect(status().isInternalServerError())
      .andExpect(jsonPath("$.useResponseMessage", is(true)))
      .andExpect(jsonPath("$.message", is(AdminWebMessage.Error.DB_INCONSISTENCY.getMessage())));
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(anyLong());
  }

}
