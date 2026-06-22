package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.destinationGroup.DestinationGroupNameResponse;
import jp.co.nikkiso.ntss.admin_web.service.DestinationGroupService;

/**
 * DestinationGroupResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class DestinationGroupResourceTest extends AbstractResourceTest {
  /**
   * 装置記録サービスクラス.
   */
  @MockitoBean
  private DestinationGroupService destinationGroupService;

  /**
   * createDestinationGroupNameResponseの検証.
   *
   * 条件：送信先グループに該当のデータがある
   * 結果：送信先グループコードに該当する送信先グループ名が取得できること
   */
  @Test
  public void test_createDestinationGroupNameResponse_正常_送信先グループに該当のデータがある() throws Exception {
    DestinationGroupNameResponse response = new DestinationGroupNameResponse("Group1");
    given(destinationGroupService.createDestinationGroupNameResponse(any())).willReturn(response);

    mockMvc
      .perform(get("/api/destination_group/{destinationGroupCd}/name", "1"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.name", is("Group1")))
    ;

    // assert
    verify(destinationGroupService, times(1)).createDestinationGroupNameResponse(1L);
  }

  /**
   * createDestinationGroupNameResponseの検証.
   *
   * 条件：送信先グループに該当のデータがない
   * 結果：空の送信先グループ名が取得できること
   */
  @Test
  public void test_createDestinationGroupNameResponse_正常_送信先グループに該当のデータがない() throws Exception {
    DestinationGroupNameResponse response = new DestinationGroupNameResponse("");
    given(destinationGroupService.createDestinationGroupNameResponse(any())).willReturn(response);

    mockMvc
      .perform(get("/api/destination_group/{destinationGroupCd}/name", "999"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.name", is("")))
    ;

    // assert
    verify(destinationGroupService, times(1)).createDestinationGroupNameResponse(999L);
  }
}
