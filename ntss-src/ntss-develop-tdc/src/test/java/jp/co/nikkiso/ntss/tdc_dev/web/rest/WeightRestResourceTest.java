package jp.co.nikkiso.ntss.tdc_dev.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

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

import jp.co.nikkiso.ntss.core.entity.MntWeightState;
import jp.co.nikkiso.ntss.tdc_dev.constant.AppConstant;
import jp.co.nikkiso.ntss.tdc_dev.request.WeightRequest;
import jp.co.nikkiso.ntss.tdc_dev.service.weight.MntWeightStateService;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/WeightRestResourceTest.before.sql")
public class WeightRestResourceTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  MntWeightStateService mntWeightStateService;

  @Test
  public void getWeightState_該当体重計の状態を取得すること() throws Exception {

    final Long scaleCd = 1L;
    ResultActions result = mockMvc.perform(get(AppConstant.Uri.WEIGHT + "/state/{scaleCd}", scaleCd));

    result.andExpect(status().isOk())
    .andExpect(jsonPath("$.facilityCd", is("999999")));
  }

  @Test
  public void getWeightState_該当体重計のない場合は空データを取得すること() throws Exception {

    final Long scaleCd = 9999L;
    ResultActions result = mockMvc.perform(get(AppConstant.Uri.WEIGHT + "/state/{scaleCd}", scaleCd));

    result.andExpect(status().isOk())
    .andExpect(content().string(""));
  }

  static class cardValeTestJson
  {
      public String testdata;
  }

  @Test
  public void postWeightState_cardの読み取り結果をDBに格納しwebsocketでカード読み取りを通知すること() throws Exception {

    final Long scaleCd = 1L;
    final String cardReadVale = "{\"testdata\":\"test\"}";

    WeightRequest param = new WeightRequest();
    param.setScaleCd(scaleCd);
    param.setFacilityCd("999999");
    param.setWeightNo(99);
    param.setDeviceEdgeNo(99);
    param.setCardReadValue(cardReadVale);

    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .put(AppConstant.Uri.WEIGHT + "/card")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );

    // Websocket通知に失敗して500が返る
    actions.andExpect(MockMvcResultMatchers.status().isInternalServerError());

    // テストデータがDBに保存されていること
    MntWeightState rcd = mntWeightStateService.selectByScaleCd(scaleCd);

    cardValeTestJson resBody = mapper.readValue(rcd.getCardReadValue(), cardValeTestJson.class);
    assertEquals(resBody.testdata, "test");
  }

  @Test
  public void postWeightState_体重計の読み取り結果をDBに格納しwebsocketでカード読み取りを通知すること() throws Exception {

    final Long scaleCd = 1L;

    WeightRequest param = new WeightRequest();
    param.setScaleCd(scaleCd);
    param.setFacilityCd("999999");
    param.setWeightNo(99);
    param.setDeviceEdgeNo(99);
    param.setScaleValue(new BigDecimal("55.555"));

    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .put(AppConstant.Uri.WEIGHT + "/scale_value")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );

    // Websocket通知に失敗して500が返る
    actions.andExpect(MockMvcResultMatchers.status().isInternalServerError());

    // テストデータがDBに保存されていること
    MntWeightState rcd = mntWeightStateService.selectByScaleCd(scaleCd);

    assertEquals(rcd.getScaleValue(), new BigDecimal("55.555"));
  }

  @Test
  public void postWeightState_カードの書き込み内容をDBに格納しwebsocketでカード書き込み指示を通知すること() throws Exception {

    final Long scaleCd = 1L;
    final String cardVale = "{\"testdata\":\"test\"}";

    WeightRequest param = new WeightRequest();
    param.setScaleCd(scaleCd);
    param.setFacilityCd("999999");
    param.setWeightNo(99);
    param.setDeviceEdgeNo(99);
    param.setCardWriteValue(cardVale);

    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .put(AppConstant.Uri.WEIGHT + "/write_card")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );

    // Websocket通知に失敗して500が返る
    actions.andExpect(MockMvcResultMatchers.status().isInternalServerError());

    // テストデータがDBに保存されていること
    MntWeightState rcd = mntWeightStateService.selectByScaleCd(scaleCd);

    cardValeTestJson resBody = mapper.readValue(rcd.getCardWriteValue(), cardValeTestJson.class);
    assertEquals(resBody.testdata, "test");
  }

  @Test
  public void postWeightState_カードの書き込み結果をDBに格納しwebsocketでカード書き込み完了を通知すること() throws Exception {

    final Long scaleCd = 1L;

    WeightRequest param = new WeightRequest();
    param.setScaleCd(scaleCd);
    param.setFacilityCd("999999");
    param.setWeightNo(99);
    param.setDeviceEdgeNo(99);
    param.setWriteResult(1);

    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .put(AppConstant.Uri.WEIGHT + "/write_card_result")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );

    // Websocket通知に失敗して500が返る
    actions.andExpect(MockMvcResultMatchers.status().isInternalServerError());

    // テストデータがDBに保存されていること
    MntWeightState rcd = mntWeightStateService.selectByScaleCd(scaleCd);

    assertEquals(rcd.getWriteResult(), 1);
  }

  @Test
  public void postWeightState_体重計通信状態をDBに格納しwebsocketで通知すること() throws Exception {

    final Long scaleCd = 1L;

    WeightRequest param = new WeightRequest();
    param.setScaleCd(scaleCd);
    param.setFacilityCd("999999");
    param.setWeightNo(99);
    param.setDeviceEdgeNo(99);
    param.setIsConnect("0");

    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .put(AppConstant.Uri.WEIGHT + "/weight_connect")
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );

    // Websocket通知に失敗して500が返る
    actions.andExpect(MockMvcResultMatchers.status().isInternalServerError());

    // テストデータがDBに保存されていること
    MntWeightState rcd = mntWeightStateService.selectByScaleCd(scaleCd);

    assertEquals(rcd.getIsConnect(), "0");
  }


}
