package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.authority.UserAuthorityRequest;
import jp.co.nikkiso.ntss.admin_web.service.authority.UserAuthorityService;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.Assert.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.anyBoolean;
import static org.mockito.Mockito.anyList;
import static org.mockito.Mockito.anyLong;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * {@link UserAuthorityResource}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class UserAuthorityResourceTest extends AbstractResourceTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 利用者権限Service.
   */
  @MockitoBean
  private UserAuthorityService userAuthorityService;

  /**
   * getUserAuthority()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getUserAuthority_成功() throws Exception {
    // 事前準備
    Long userId = 1L;
    List<String> authorities = Arrays.asList("101", "102", "103");

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(authorities);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/user-authority/{user_id}/list", userId)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(userId);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$[0]", is(authorities.get(0))))
      .andExpect(jsonPath("$[1]", is(authorities.get(1))))
      .andExpect(jsonPath("$[2]", is(authorities.get(2))))
    ;
  }

  /**
   * getUserAuthority()の検証.
   * <p>
   * 条件：失敗
   * 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getUserAuthority_失敗() throws Exception {
    // 事前準備
    Long userId = 1L;

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willThrow(new NotExistException("利用者マスタが見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/user-authority/{user_id}/list", userId)
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(userId);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * getLoginUserAuthority()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 1)
  public void test_getLoginUserAuthority_成功() throws Exception {
    // 事前準備
    Long userId = 1L;
    List<String> authorities = Arrays.asList("101", "102", "103");

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willReturn(authorities);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/user-authority/login/list")
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(userId);
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$[0]", is(authorities.get(0))))
      .andExpect(jsonPath("$[1]", is(authorities.get(1))))
      .andExpect(jsonPath("$[2]", is(authorities.get(2))))
    ;
  }

  /**
   * getLoginUserAuthority()の検証.
   * <p>
   * 条件：失敗
   * 結果：失敗レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(userId = 1)
  public void test_getLoginUserAuthority_失敗() throws Exception {
    // 事前準備
    Long userId = 1L;

    // Mock化
    given(userAuthorityService.getAuthorizedAuthorities(anyLong())).willThrow(new NotExistException("利用者マスタが見つからない"));

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/user-authority/login/list")
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(userAuthorityService, times(1)).getAuthorizedAuthorities(userId);
    result
      .andExpect(status().isInternalServerError());
  }

  /**
   * updateUserAuthority()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_updateUserAuthority_成功() throws Exception {
    // 事前準備(Request)
    Long userId1 = 1L;
    List<String> authorities1 = Arrays.asList("101", "102", "103");
    Long userId2 = 2L;
    List<String> authorities2 = Arrays.asList("201", "202", "203");
    Boolean signoutFlg = false;
    List<UserAuthorityRequest> request = Arrays.asList(
      new UserAuthorityRequest() {
        {
          setUserId(userId1);
          setAuthorities(authorities1);
          setSignoutFlg(signoutFlg);
        }
      },
      new UserAuthorityRequest() {
        {
          setUserId(userId2);
          setAuthorities(authorities2);
          setSignoutFlg(signoutFlg);
        }
      }
    );
    String requestBody = mapper.writeValueAsString(request);

    ArgumentCaptor<Long> args1 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<List<String>> args2 = ArgumentCaptor.forClass(List.class);
    ArgumentCaptor<Boolean> args3 = ArgumentCaptor.forClass(Boolean.class);

    // Mock化
    doNothing().when(userAuthorityService).updateAuthorizedAuthorities(args1.capture(), args2.capture(), args3.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/user-authority/list")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userAuthorityService, times(2)).updateAuthorizedAuthorities(anyLong(), anyList(), anyBoolean());
    assertThat(args1.getAllValues().get(0), is(userId1));
    assertThat(args1.getAllValues().get(1), is(userId2));
    assertThat(mapper.writeValueAsString(args2.getAllValues().get(0)), is(mapper.writeValueAsString(authorities1)));
    assertThat(mapper.writeValueAsString(args2.getAllValues().get(1)), is(mapper.writeValueAsString(authorities2)));
    result.andExpect(status().isOk());
  }

  /**
   * updateUserAuthority()の検証.
   * <p>
   * 条件：失敗（該当データなし）
   * 結果：失敗レスポンス(Status:500)が返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_updateUserAuthority_失敗_該当データなし() throws Exception {
    // 事前準備(Request)
    Long userId = 1L;
    List<String> authorities = Arrays.asList("101", "102", "103");
    Boolean signoutFlg = false;
    List<UserAuthorityRequest> request = Arrays.asList(
      new UserAuthorityRequest() {
        {
          setUserId(userId);
          setAuthorities(authorities);
          setSignoutFlg(signoutFlg);
        }
      }
    );
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    doThrow(new NotExistException("")).when(userAuthorityService).updateAuthorizedAuthorities(anyLong(), anyList(), anyBoolean());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/user-authority/list")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(userAuthorityService, times(1)).updateAuthorizedAuthorities(anyLong(), anyList(), anyBoolean());
    result.andExpect(status().isInternalServerError());
  }

}
