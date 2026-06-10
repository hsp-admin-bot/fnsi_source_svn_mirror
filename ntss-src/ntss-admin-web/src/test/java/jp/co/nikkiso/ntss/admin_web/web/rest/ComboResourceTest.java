package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.Arrays.asList;
import static java.util.Collections.emptyList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.exception.InvalidSchemaDefinitionException;

/**
 * ComboResourceのテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class ComboResourceTest extends AbstractResourceTest {

  /**
   * 参照型コンボボックス用Service.
   */
  @MockBean
  private ReferenceComboService referenceComboService;

  /**
   * getComboList()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getComboList_成功_取得1件() throws Exception {

    // 事前準備
    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      asList(new ReferenceCombo(1L, "テスト値", 1L))
    );

    // API実行
    String masterName = "hoge";
    String textColName = "fuga";
    String cdColName = "foober";
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders
        .get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", masterName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(referenceComboService, times(1)).build(any(), any());
    String facilityCdCaptorValue = facilityCdCaptor.getValue();
    assertThat(facilityCdCaptorValue).isEqualTo("facilityCd");
    ReferenceComboTargetTable captorValue = targetTableArgsCaptor.getValue();
    assertThat(captorValue.getName()).isEqualTo("hoge");
    assertThat(captorValue.getDisplayColumn()).isEqualTo("fuga");
    assertThat(captorValue.getReferencedColumn()).isEqualTo("foober");
    assertThat(captorValue.getIdentifier()).isEqualTo("foober");
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(1)))
      .andExpect(jsonPath("$[0].text", is("テスト値")))
      .andExpect(jsonPath("$[0].cd", is(1)))
    ;
  }

  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getComboList_成功_取得複数件() throws Exception {

    // 事前準備
    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      asList(
        new ReferenceCombo(1L, "テスト値", 1L),
        new ReferenceCombo(2L,"テスト値2", 2L)
      )
    );

    // API実行
    String masterName = "hoge";
    String textColName = "fuga";
    String cdColName = "foober";
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders
        .get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", masterName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(referenceComboService, times(1)).build(any(), any());
    String facilityCdCaptorValue = facilityCdCaptor.getValue();
    assertThat(facilityCdCaptorValue).isEqualTo("facilityCd");
    ReferenceComboTargetTable captorValue = targetTableArgsCaptor.getValue();
    assertThat(captorValue.getName()).isEqualTo("hoge");
    assertThat(captorValue.getDisplayColumn()).isEqualTo("fuga");
    assertThat(captorValue.getReferencedColumn()).isEqualTo("foober");
    assertThat(captorValue.getIdentifier()).isEqualTo("foober");
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(2)))
      .andExpect(jsonPath("$[0].text", is("テスト値")))
      .andExpect(jsonPath("$[0].cd", is(1)))
      .andExpect(jsonPath("$[1].text", is("テスト値2")))
      .andExpect(jsonPath("$[1].cd", is(2)))
    ;
  }

  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getComboList_成功_取得0件() throws Exception {

    // 事前準備
    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willReturn(
      emptyList()
    );

    // API実行
    String masterName = "hoge";
    String textColName = "fuga";
    String cdColName = "foober";
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders
        .get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", masterName, textColName, cdColName)
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(referenceComboService, times(1)).build(any(), any());
    String facilityCdCaptorValue = facilityCdCaptor.getValue();
    assertThat(facilityCdCaptorValue).isEqualTo("facilityCd");
    ReferenceComboTargetTable captorValue = targetTableArgsCaptor.getValue();
    assertThat(captorValue.getName()).isEqualTo("hoge");
    assertThat(captorValue.getDisplayColumn()).isEqualTo("fuga");
    assertThat(captorValue.getReferencedColumn()).isEqualTo("foober");
    assertThat(captorValue.getIdentifier()).isEqualTo("foober");
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)))
    ;
  }

  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getComboList_失敗_マスタ物理名間違い() throws Exception {
    // 事前準備
    final ArgumentCaptor<String> facilityCdCaptor = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<ReferenceComboTargetTable> targetTableArgsCaptor = ArgumentCaptor.forClass(ReferenceComboTargetTable.class);
    given(referenceComboService.build(facilityCdCaptor.capture(), targetTableArgsCaptor.capture())).willThrow(InvalidSchemaDefinitionException.class);

    // API実行
    String masterName = "hoge";
    String textColName = "fuga";
    String cdColName = "foober";
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders
      .get("/api/combo/{master_physical_name}/{text_column_physical_name}/{cd_column_physical_name}", masterName, textColName, cdColName)
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(referenceComboService, times(1)).build(any(), any());
    String facilityCdCaptorValue = facilityCdCaptor.getValue();
    assertThat(facilityCdCaptorValue).isEqualTo("facilityCd");
    ReferenceComboTargetTable captorValue = targetTableArgsCaptor.getValue();
    assertThat(captorValue.getName()).isEqualTo("hoge");
    assertThat(captorValue.getDisplayColumn()).isEqualTo("fuga");
    assertThat(captorValue.getReferencedColumn()).isEqualTo("foober");
    assertThat(captorValue.getIdentifier()).isEqualTo("foober");
    result
      .andExpect(status().isBadRequest())
      .andExpect(jsonPath("message", is("スキーマ情報の定義に誤りがあります。")))
    ;
  }

}
