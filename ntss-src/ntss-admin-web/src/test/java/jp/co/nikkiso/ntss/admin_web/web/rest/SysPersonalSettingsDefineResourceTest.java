package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.Arrays.asList;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.PersonalSettingsDefine;
import jp.co.nikkiso.ntss.admin_web.service.SysPersonalSettingsDefineService;
import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

/**
 * SysPersonalSettingsDefineResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class SysPersonalSettingsDefineResourceTest extends AbstractResourceTest {

  @MockitoBean
  private SysPersonalSettingsDefineService sysPersonalSettingsDefineService;

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
    final PersonalSettingsDefine PersonalSettingsDefine = genePersonalSettingsDefine(tabDefineCd);
    given(sysPersonalSettingsDefineService.getPersonalSettingsDefine(any(), any())).willReturn(PersonalSettingsDefine);

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
      .andExpect(jsonPath("$.item_info[0].type", is(SysPersonalSettingsDefine.ItemType.NUMBER.getValue())))
      .andExpect(jsonPath("$.item_info[0].title", is("title1")))
      .andExpect(jsonPath("$.item_info[0].identifier", is("identifier1")))
      .andExpect(jsonPath("$.item_info[0].validation.maxlength", is(1)))
      .andExpect(jsonPath("$.item_info[0].validation.min", is(0.5)))
      .andExpect(jsonPath("$.item_info[0].validation.max", is(100)))
      .andExpect(jsonPath("$.item_info[0].validation.digit", is(1)))
      .andExpect(jsonPath("$.item_info[0].validation.required", is(true)))
      .andExpect(jsonPath("$.item_info[1].type", is(SysPersonalSettingsDefine.ItemType.COMBO1.getValue())))
      .andExpect(jsonPath("$.item_info[1].title", is("title2")))
      .andExpect(jsonPath("$.item_info[1].identifier", is("identifier2")))
      .andExpect(jsonPath("$.item_info[1].validation", nullValue()))
      .andExpect(jsonPath("$.item_info[2].type", is(SysPersonalSettingsDefine.ItemType.COMBO2.getValue())))
      .andExpect(jsonPath("$.item_info[2].title", is("title3")))
      .andExpect(jsonPath("$.item_info[2].identifier", is("identifier3")))
      .andExpect(jsonPath("$.item_info[2].validation.maxlength", nullValue()))
      .andExpect(jsonPath("$.item_info[2].validation.min", nullValue()))
      .andExpect(jsonPath("$.item_info[2].validation.max", nullValue()))
      .andExpect(jsonPath("$.item_info[2].validation.digit", nullValue()))
      .andExpect(jsonPath("$.item_info[2].validation.required", is(true)))
      .andExpect(jsonPath("$.combo_data", hasSize(2)))
      .andExpect(jsonPath("$.combo_data[0].setting_identifier", is("identifier2")))
      .andExpect(jsonPath("$.combo_data[0].values", hasSize(2)))
      .andExpect(jsonPath("$.combo_data[0].values[0].text", is("text2-A")))
      .andExpect(jsonPath("$.combo_data[0].values[0].value", is(11)))
      .andExpect(jsonPath("$.combo_data[0].values[1].text", is("text2-B")))
      .andExpect(jsonPath("$.combo_data[0].values[1].value", is("hoge")))
      .andExpect(jsonPath("$.combo_data[1].setting_identifier", is("identifier3")))
      .andExpect(jsonPath("$.combo_data[1].values", hasSize(3)))
      .andExpect(jsonPath("$.combo_data[1].values[0].text", is("text3-A")))
      .andExpect(jsonPath("$.combo_data[1].values[0].value", is("fuga")))
      .andExpect(jsonPath("$.combo_data[1].values[1].text", is("text3-B")))
      .andExpect(jsonPath("$.combo_data[1].values[1].value", is(22)))
      .andExpect(jsonPath("$.combo_data[1].values[2].text", is("text3-C")))
      .andExpect(jsonPath("$.combo_data[1].values[2].value", is("piyo")))
    ;

    verify(sysPersonalSettingsDefineService, times(1)).getPersonalSettingsDefine(eq("999999"), eq(tabDefineCd));
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
    final Integer tabDefineCd = 1;
    given(sysPersonalSettingsDefineService.getPersonalSettingsDefine(any(), any())).willThrow(NotExistException.class);

    // action
    // assert
    mockMvc
      .perform(get("/api/personal_setting_define/{tab_define_cd}", tabDefineCd)
        .contentType(MediaType.APPLICATION_JSON))
      .andExpect(status().isInternalServerError())
    ;

    verify(sysPersonalSettingsDefineService, times(1)).getPersonalSettingsDefine(eq("999999"), eq(tabDefineCd));
  }

  private PersonalSettingsDefine genePersonalSettingsDefine(Integer tabDefineCd) {
    final String editLevel = "1";

    // ItemInfoDetailsを生成。
    final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetails = asList(
      new SysPersonalSettingsDefine.ItemInfoDetail(
        SysPersonalSettingsDefine.ItemType.NUMBER
        , "title1"
        , "identifier1"
        , new SysPersonalSettingsDefine.ItemInfoValidation(1, BigDecimal.valueOf(0.5), BigDecimal.valueOf(100), true, (short) 1)
      ),
      new SysPersonalSettingsDefine.ItemInfoDetail(
        SysPersonalSettingsDefine.ItemType.COMBO1
        , "title2"
        , "identifier2"
        , null
      ),
      new SysPersonalSettingsDefine.ItemInfoDetail(
        SysPersonalSettingsDefine.ItemType.COMBO2
        , "title3"
        , "identifier3"
        , new SysPersonalSettingsDefine.ItemInfoValidation(null, null, null, true, null)
      )
    );

    return new PersonalSettingsDefine(
      tabDefineCd
      , editLevel
      , itemInfoDetails
      , asList(
        new SysPersonalSettingsDefine.StaticCombo("identifier2", asList(
          new SysPersonalSettingsDefine.StaticComboValue("text2-A", 11)
          , new SysPersonalSettingsDefine.StaticComboValue("text2-B", "hoge")
        ))
        , new SysPersonalSettingsDefine.StaticCombo("identifier3", asList(
          new SysPersonalSettingsDefine.StaticComboValue("text3-A", "fuga")
          , new SysPersonalSettingsDefine.StaticComboValue("text3-B", 22)
          , new SysPersonalSettingsDefine.StaticComboValue("text3-C", "piyo")
        ))
      )
    );
  }
}
