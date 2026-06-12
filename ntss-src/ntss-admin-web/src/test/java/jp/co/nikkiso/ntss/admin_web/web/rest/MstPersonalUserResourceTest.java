package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.Arrays.asList;
import static java.util.Collections.emptyList;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.personalUser.NameWithHasEmailResponse;
import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class MstPersonalUserResourceTest extends AbstractResourceTest {

  /**
   * 利用者マスタのサービス
   */
  @MockitoBean
  private PersonalUserService personalUserService;

  /**
   * getNameAndHasEmailAddressの検証.
   *
   * 条件：成功, 利用者マスタに利用者あり
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void 利用者IDと利用者名とメールアドレス登録有無を取得できること() throws Exception {
    // arrange
    final List<NameWithHasEmailResponse.NameWithHasEmail> nameWithHasEmailList = asList(
      new NameWithHasEmailResponse.NameWithHasEmail(1L, "lastName1", "firstName1", true, true)
      , new NameWithHasEmailResponse.NameWithHasEmail(2L, "lastName2", "firstName2", true, false)
      , new NameWithHasEmailResponse.NameWithHasEmail(3L,"lastName3", "firstName3", true, false)
    );
    final NameWithHasEmailResponse response = new NameWithHasEmailResponse(nameWithHasEmailList);
    given(personalUserService.getNameAndHasEmailByFacilityCd(any())).willReturn(response);

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
    ;

    // assert
    verify(personalUserService, times(1)).getNameAndHasEmailByFacilityCd("facilityCd");
  }

  /**
   * getNameAndHasEmailAddressの検証.
   *
   * 条件：成功, 利用者マスタに利用者なし
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void 指定した施設に利用者名がいない場合_空のリストを取得できること() throws Exception {
    // arrange
    final List<NameWithHasEmailResponse.NameWithHasEmail> nameWithHasEmailList = emptyList();
    final NameWithHasEmailResponse response = new NameWithHasEmailResponse(nameWithHasEmailList);
    given(personalUserService.getNameAndHasEmailByFacilityCd(any())).willReturn(response);

    // action
    mockMvc
      .perform(get("/api/personal_user/has_email"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.personalUsers", hasSize(0)))
    ;

    // assert
    verify(personalUserService, times(1)).getNameAndHasEmailByFacilityCd("facilityCd");
  }
}
