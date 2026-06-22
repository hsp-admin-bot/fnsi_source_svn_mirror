package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.roundType.RoundTypeNameAndContentResponse;
import jp.co.nikkiso.ntss.admin_web.service.RoundTypeService;

/**
 * RoundTypeResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class RoundTypeResourceTest extends AbstractResourceTest {
  /**
   * 種別マスタサービスクラス.
   */
  @MockitoBean
  private RoundTypeService roundTypeService;

  /**
   * getRoundTypeNameAndContentの検証.
   *
   * 条件：種別マスタに該当のデータがある
   * 結果：施設コードに該当する種別マスタが取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getRoundTypeNameAndContent_正常_種別マスタに該当のデータがある() throws Exception {
    List<RoundTypeNameAndContentResponse> response =
        Arrays.asList
        (
            new RoundTypeNameAndContentResponse(1L, "name1", "content1", "0", "0", "1",any()),
            new RoundTypeNameAndContentResponse(2L, "name2", "content2", "1", "1", "0",any())
        );
    given(roundTypeService.createRoundTypeNameAndContentResponse(any())).willReturn(response);

    mockMvc
      .perform(get("/api/round-type/{facilityCd}/name-and-content", "1"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$[0].round_type_cd", is(1)))
      .andExpect(jsonPath("$[0].round_type_name", is("name1")))
      .andExpect(jsonPath("$[0].content", is("content1")))
      .andExpect(jsonPath("$[0].is_content_omission", is("0")))
      .andExpect(jsonPath("$[0].comment_post_default", is("0")))
      .andExpect(jsonPath("$[0].posting_class_default", is("1")))
      .andExpect(jsonPath("$[1].round_type_cd", is(2)))
      .andExpect(jsonPath("$[1].round_type_name", is("name2")))
      .andExpect(jsonPath("$[1].content", is("content2")))
      .andExpect(jsonPath("$[1].is_content_omission", is("1")))
      .andExpect(jsonPath("$[1].comment_post_default", is("1")))
      .andExpect(jsonPath("$[1].posting_class_default", is("0")))
    ;

    // assert
    verify(roundTypeService, times(1)).createRoundTypeNameAndContentResponse("1");
  }

  /**
   * getRoundTypeNameAndContentの検証.
   *
   * 条件：種別マスタに該当のデータがない
   * 結果：空の種別マスタが取得できること
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getRoundTypeNameAndContent_正常_種別マスタに該当のデータがない() throws Exception {
    given(roundTypeService.createRoundTypeNameAndContentResponse(any())).willReturn(Collections.emptyList());

      // assert
      mockMvc
      .perform(get("/api/round-type/{facilityCd}/name-and-content", "999"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;

    // assert
    verify(roundTypeService, times(1)).createRoundTypeNameAndContentResponse("999");
  }
}
