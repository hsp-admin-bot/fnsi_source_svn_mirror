package jp.co.nikkiso.ntss.tdc_dev.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.MntWeightState;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.tdc_dev.constant.AppConstant;
import jp.co.nikkiso.ntss.tdc_dev.request.WeightRequest;
import jp.co.nikkiso.ntss.tdc_dev.service.weight.MntWeightStateService;
import jp.co.nikkiso.ntss.tdc_dev.service.weight.MstWeightService;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/WeightSettingResourceTest.before.sql")
public class WeightSettingResourceTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  MstWeightService mstWeightService;
  
  @Test
  public void getWeight_該当体重計を取得すること() throws Exception {

    final String facilityCd = "999999";
    List<MstWeight> rcd = mstWeightService.selectByFacilityCd(facilityCd);
    
    MstWeight param = rcd.get(0);
    
    ResultActions result = mockMvc.perform(get(AppConstant.Uri.WEIGHT_SETTING + "/get/{scaleCd}", param.getScaleCd()));

    result.andExpect(status().isOk())
    .andExpect(jsonPath("$.facilityCd", is(facilityCd)));    
  }

  @Test
  public void getWeight_該当体重計のない場合は空データを取得すること() throws Exception {
    
    final Long scaleCd = 9999L;
    ResultActions result = mockMvc.perform(get(AppConstant.Uri.WEIGHT_SETTING + "/get/{scaleCd}", scaleCd));

    result.andExpect(status().isOk())
    .andExpect(content().string("")); 
  }
  
  @Test
  public void getWeight_該当施設の体重計を取得すること() throws Exception {
    
    final String facilityCd = "999999";
    ResultActions result = mockMvc.perform(get(AppConstant.Uri.WEIGHT_SETTING + "/find/{facilityCd}", facilityCd));

    result.andExpect(status().isOk())
    .andExpect(jsonPath("$[0].facilityCd", is("999999")));    
  }

  @Test
  public void getWeightState_該当体重計のない場合は空データを取得すること() throws Exception {

    final String facilityCd = "000000";
    ResultActions result = mockMvc.perform(get(AppConstant.Uri.WEIGHT_SETTING + "/find/{facilityCd}", facilityCd));

    result.andExpect(status().isOk())
    .andExpect(jsonPath("$", hasSize(0)));
  }
  
  static class testJson
  {
      public String testdata;
  }
    
  @Test
  public void postInsert_データ登録できること() throws Exception {

    final String facilityCd = "999900";
    
    MstWeight param = new MstWeight();
    param.setFacilityCd(facilityCd);
    param.setWeightNo(99);
    
    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .post(AppConstant.Uri.WEIGHT_SETTING + "/insert")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );
    
    // 200が返る
    actions.andExpect(MockMvcResultMatchers.status().isOk());
    
    // テストデータがDBに保存されていること
    List<MstWeight> rcd = mstWeightService.selectByFacilityCd(facilityCd);
    
    assertEquals(rcd.size(), 1);
    assertEquals(rcd.get(0).getWeightNo().intValue(), 99);
  }

  @Test
  public void putUpdate_データ登録できること() throws Exception {

    final String facilityCd = "999999";
    List<MstWeight> rcd = mstWeightService.selectByFacilityCd(facilityCd);
    
    MstWeight param = rcd.get(0);
    param.setPortNo((short) 9999);
    
    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .put(AppConstant.Uri.WEIGHT_SETTING + "/update")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );
    
    // 200が返る
    actions.andExpect(MockMvcResultMatchers.status().isOk());
    
    // テストデータがDBに保存されていること
    rcd = mstWeightService.selectByFacilityCd(facilityCd);
    
    assertEquals(rcd.size(), 1);
    assertEquals(rcd.get(0).getPortNo().shortValue(), (short)9999);
  }
  
}
