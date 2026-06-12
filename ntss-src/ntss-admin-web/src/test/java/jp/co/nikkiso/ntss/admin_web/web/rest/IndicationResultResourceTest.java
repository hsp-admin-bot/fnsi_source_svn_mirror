package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.TimeZone;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.service.indicationResult.IndicationResultService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.IndicationResult;

/**
 * IndicationResultResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class IndicationResultResourceTest extends AbstractResourceTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 予実リストService.
   */
  @MockitoBean
  private IndicationResultService indicationResultService;

  private IndicationResult getIndicationResult(Integer indRstType, String treatmentDate) {
    IndicationResult indicationResult = new IndicationResult();
    indicationResult.setOrdNo(1L);
    indicationResult.setCategory("1");
    indicationResult.setIndRstType(indRstType);
    indicationResult.setTreatmentDate(treatmentDate);
    indicationResult.setTreatmentName("2");
    indicationResult.setKurName("3");
    indicationResult.setStartDate(Timestamp.valueOf("2019-06-20 18:01:00"));
    indicationResult.setEndDate(Timestamp.valueOf("2019-06-20 18:02:00"));
    indicationResult.setBedName("5");

    return indicationResult;
  }

  /**
   * getList()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getList_成功_データあり() throws Exception {
    // 事前準備
    Long patId = 12345L;
    String treatDateFrom = "20190610";
    String treatDateTo = "20190620";
    List<IndicationResult> response = Arrays.asList(
      getIndicationResult(1, "20190620"),
      getIndicationResult(2, "20190621")
    );
    SimpleDateFormat sf = new SimpleDateFormat(CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601);
    sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));

    // Mock化
    given(indicationResultService.getList(anyLong(), any(), any(), any())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/indication-result/{pat_id}/list", patId)
      .contentType(MediaType.APPLICATION_JSON)
      .param("treat_date_from", treatDateFrom)
      .param("treat_date_to", treatDateTo)
      .with(csrf()));

    // 検証
    verify(indicationResultService, times(1)).getList(patId, treatDateFrom, treatDateTo, any());
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(2)))
      .andExpect(jsonPath("$[0].ord_no", is(response.get(0).getOrdNo().intValue())))
      .andExpect(jsonPath("$[0].category", is(response.get(0).getCategory())))
      .andExpect(jsonPath("$[0].ind_rst_type", is(response.get(0).getIndRstType())))
      .andExpect(jsonPath("$[0].treatment_date", is(response.get(0).getTreatmentDate())))
      .andExpect(jsonPath("$[0].treatment_name", is(response.get(0).getTreatmentName())))
      .andExpect(jsonPath("$[0].kur_name", is(response.get(0).getKurName())))
      .andExpect(jsonPath("$[0].start_date", is(sf.format(response.get(0).getStartDate()))))
      .andExpect(jsonPath("$[0].end_date", is(sf.format(response.get(0).getEndDate()))))
      .andExpect(jsonPath("$[0].bed_name", is(response.get(0).getBedName())))
      .andExpect(jsonPath("$[1].ord_no", is(response.get(1).getOrdNo().intValue())))
      .andExpect(jsonPath("$[1].category", is(response.get(1).getCategory())))
      .andExpect(jsonPath("$[1].ind_rst_type", is(response.get(1).getIndRstType())))
      .andExpect(jsonPath("$[1].treatment_date", is(response.get(1).getTreatmentDate())))
      .andExpect(jsonPath("$[1].treatment_name", is(response.get(1).getTreatmentName())))
      .andExpect(jsonPath("$[1].kur_name", is(response.get(1).getKurName())))
      .andExpect(jsonPath("$[1].start_date", is(sf.format(response.get(1).getStartDate()))))
      .andExpect(jsonPath("$[1].end_date", is(sf.format(response.get(1).getEndDate()))))
      .andExpect(jsonPath("$[1].bed_name", is(response.get(1).getBedName())));
  }

  /**
   * getList()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getList_成功_データ0件() throws Exception {
    // 事前準備
    Long patId = 12345L;
    String treatDateFrom = "20190610";
    String treatDateTo = "20190620";
    List<IndicationResult> response = Collections.emptyList();

    // Mock化
    given(indicationResultService.getList(anyLong(), any(), any(), any())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/indication-result/{pat_id}/list", patId)
      .contentType(MediaType.APPLICATION_JSON)
      .param("treat_date_from", treatDateFrom)
      .param("treat_date_to", treatDateTo)
      .with(csrf()));

    // 検証
    verify(indicationResultService, times(1)).getList(patId, treatDateFrom, treatDateTo, any());
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", notNullValue()))
      .andExpect(jsonPath("$", hasSize(0)));
  }
}
