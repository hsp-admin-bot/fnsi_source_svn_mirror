package jp.co.nikkiso.ntss.device_edge_updater.web.rest;

import static org.junit.Assert.assertEquals;

import java.util.Base64;

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

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage.ManageInfo;
import jp.co.nikkiso.ntss.device_edge_updater.service.DeviceEdgeUpdaterManageService;
import lombok.Data;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/UpdateResourceTest.before.sql")
public class UpdateResourceTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private DeviceEdgeUpdaterManageService deviceEdgeUpdaterManageService;

  @Test
  public void test_Response_旧形式の応答でもエラーにならないこと() throws Exception {

    @Data
    class OldContent {
      public String content;
    }
    OldContent body = new OldContent();
    body.content = Base64.getEncoder().encodeToString("1_2".getBytes());

    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(body);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
            .post("/api/update/response")
            .contentType(MediaType.APPLICATION_JSON)
            .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
            .content(json));

    // 200が返る
    actions.andExpect(MockMvcResultMatchers.status().isOk());

    MntDeviceEdgeManage d = deviceEdgeUpdaterManageService.selectByManageNo(1L);

    // statusが2になっていること
    assertEquals(d.getResponseStatus().intValue(), 2);
  }

  @Test
  public void test_Response_新形式の応答でエラーにならないこと() throws Exception {

    ResponseData body = new ResponseData();
    body.content = Base64.getEncoder().encodeToString("1".getBytes());
    body.status = Base64.getEncoder().encodeToString("-2".getBytes());
    body.info = Base64.getEncoder().encodeToString(
        "{\"message\": \"更新データ反映失敗\", \"updater_info\": \"1{TAB}0{TAB}s3://ntss-test4/update{TAB}ntss_main_1115.zip\", \"download_file\": \"ntss_main_1115.zip\", \"download_bucket\": \"s3://ntss-test4/update\"}"
            .getBytes());

    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(body);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
            .post("/api/update/response")
            .contentType(MediaType.APPLICATION_JSON)
            .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
            .content(json));

    // 200が返る
    actions.andExpect(MockMvcResultMatchers.status().isOk());

    MntDeviceEdgeManage d = deviceEdgeUpdaterManageService.selectByManageNo(1L);

    // statusが-2になっていること
    ManageInfo info = d.getManageInfo();
    assertEquals(d.getResponseStatus().intValue(), -2);
    assertEquals(info.getMessage(), "更新データ反映失敗");
    assertEquals(info.getPayload(), "");
    assertEquals(info.getDownloadFile(), "ntss_main_1115.zip");
    assertEquals(info.getDownloadBucket(), "s3://ntss-test4/update");
  }

  static class ResponseData {
    public String content;
    public String status;
    public String info;
  }

  static class ResponseInfoData {
    public String message;
    public String updater_info;
    public String download_file;
    public String download_bucket;
  }
}
