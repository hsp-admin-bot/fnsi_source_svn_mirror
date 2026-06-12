package jp.co.nikkiso.ntss.tdc_dev.web.rest;

import static org.junit.Assert.assertEquals;

import java.math.BigDecimal;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.tdc_dev.constant.AppConstant;
import jp.co.nikkiso.ntss.tdc_dev.request.SendConditionRequest;
import jp.co.nikkiso.ntss.tdc_dev.service.condition.OrdWeightScaleService;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@AutoConfigureMockMvc
@Sql("classpath:resource.script/SendConditionRestResourceTest.before.sql")
public class SendConditionRestResourceTest {

  @Autowired
  private MockMvc mockMvc;
  @Autowired
  OrdWeightScaleService ordWeightScaleService;

  @Test
  public void postSaveWeightAndChair_該当車いす重量をWAITで保存() throws Exception {
        
    SendConditionRequest request = new SendConditionRequest();
    request.setFacilityCd("nkknkk");
    request.setOrdNo(1L);
    request.setScaleCd(2L);
    request.setDeviceEdgeNo(99);
    request.setLimitOffWater(new BigDecimal("10.1"));
    
    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(request);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .post(AppConstant.Uri.SEND_CONDITION + "/save_weight_and_chair")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );

    // 200が返る
    actions.andExpect(MockMvcResultMatchers.status().isOk());
    
    OrdWeightScale ord = ordWeightScaleService.selectByOrdNo(1L).get(0);

    // 警報内容が正しく登録されていること
    assertEquals(ord.getWeightScaleStatus(), AppConstant.SendCondition.WeightScaleClass.WAIT);
    
  }
  
}
