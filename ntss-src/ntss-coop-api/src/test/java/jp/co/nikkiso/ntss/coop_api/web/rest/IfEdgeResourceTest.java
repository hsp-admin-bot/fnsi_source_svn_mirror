package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.File;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.IfEdgeWebsocketRequest;
import jp.co.nikkiso.ntss.coop_api.response.IfEdgeRestResult;
import jp.co.nikkiso.ntss.coop_api.service.IfEdgeServiceImpl;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.IfedgeFixedResult;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage.EdgeResult;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage.InnerEdgeResult;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/IfEdgeResourceTest/IfEdgeResourceTest.db5.before.sql")
public class IfEdgeResourceTest extends AbstractResourceTest {

  @MockBean
  IfEdgeServiceImpl service;

  @Test
  public void 正常系() {

    String facilityCd = "001";

    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus("200");
    EdgeResult edgeResult = new EdgeResult();
    edgeResult.setSystem("NTSS");
    edgeResult.setStatus("result");
    edgeResult.setFacilityCd(facilityCd);
    InnerEdgeResult innerEdgeResult = new InnerEdgeResult();
    innerEdgeResult.setCtlNo(999L);
    innerEdgeResult.setMessage(IfedgeFixedResult.TIMEOUT.getMessage());
    innerEdgeResult.setStatus(IfedgeFixedResult.TIMEOUT.getStatus());
    edgeResult.setResult(innerEdgeResult);
    result.setResult(edgeResult);

    given(service.devide(any())).willReturn(result);

    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/IfEdgeResourceTest/success.json").getFile());
      try {
        IfEdgeWebsocketRequest expect = ObjectMapperUtil.readFile(expectFile, IfEdgeWebsocketRequest.class);
        mockMvc
          .perform(post("/ifedge/maintenance")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON)
          )
          .andExpect(status().isOk())
          .andExpect(jsonPath("$.status", is("200")))
          .andExpect(jsonPath("$.result.system", is("NTSS")))
          .andExpect(jsonPath("$.result.facility_cd", is(facilityCd)))
          .andExpect(jsonPath("$.result.result.ctl_no", is(999)))
          .andExpect(jsonPath("$.result.result.message", is(IfedgeFixedResult.TIMEOUT.getMessage())))
          .andExpect(jsonPath("$.result.result.status", is(IfedgeFixedResult.TIMEOUT.getStatus())));

      } catch(Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
        fail("IfEdgeREST呼び出し失敗", e);
      }
  }

  @Test
  public void 異常系＿施設コード必須エラー() {

    String facilityCd = "004";

    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus("200");
    EdgeResult edgeResult = new EdgeResult();
    edgeResult.setSystem("NTSS");
    edgeResult.setStatus("result");
    edgeResult.setFacilityCd(facilityCd);
    InnerEdgeResult innerEdgeResult = new InnerEdgeResult();
    innerEdgeResult.setCtlNo(999L);
    innerEdgeResult.setMessage("hoge");
    innerEdgeResult.setStatus(200);
    edgeResult.setResult(innerEdgeResult);
    result.setResult(edgeResult);

    given(service.devide(any())).willReturn(result);

    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/IfEdgeResourceTest/facility_cd_nothing.json").getFile());
      try {
        IfEdgeWebsocketRequest expect = ObjectMapperUtil.readFile(expectFile, IfEdgeWebsocketRequest.class);
        mockMvc
          .perform(post("/ifedge/maintenance")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON)
          )
          .andExpect(status().isBadRequest());

      } catch(Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
        fail("IfEdgeREST呼び出し失敗", e);
      }
  }

  @Test
  public void 異常系＿指示種別コード必須エラー() {

    String facilityCd = "005";

    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus("200");
    EdgeResult edgeResult = new EdgeResult();
    edgeResult.setSystem("NTSS");
    edgeResult.setStatus("result");
    edgeResult.setFacilityCd(facilityCd);
    InnerEdgeResult innerEdgeResult = new InnerEdgeResult();
    innerEdgeResult.setCtlNo(999L);
    innerEdgeResult.setMessage("hoge");
    innerEdgeResult.setStatus(200);
    edgeResult.setResult(innerEdgeResult);
    result.setResult(edgeResult);

    given(service.devide(any())).willReturn(result);

    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/IfEdgeResourceTest/type_nothing.json").getFile());
      try {
        IfEdgeWebsocketRequest expect = ObjectMapperUtil.readFile(expectFile, IfEdgeWebsocketRequest.class);
        mockMvc
          .perform(post("/ifedge/maintenance")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON)
          )
          .andExpect(status().isBadRequest());

      } catch(Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
        fail("IfEdgeREST呼び出し失敗", e);
      }
  }

  @Test
  public void 異常系＿先頭文字エラー() {

    String facilityCd = "006";

    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus("200");
    EdgeResult edgeResult = new EdgeResult();
    edgeResult.setSystem("NTSS");
    edgeResult.setStatus("result");
    edgeResult.setFacilityCd(facilityCd);
    InnerEdgeResult innerEdgeResult = new InnerEdgeResult();
    innerEdgeResult.setCtlNo(999L);
    innerEdgeResult.setMessage("hoge");
    innerEdgeResult.setStatus(200);
    edgeResult.setResult(innerEdgeResult);
    result.setResult(edgeResult);

    given(service.devide(any())).willReturn(result);

    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/IfEdgeResourceTest/dirPathFirstInvalid.json").getFile());
      try {
        IfEdgeWebsocketRequest expect = ObjectMapperUtil.readFile(expectFile, IfEdgeWebsocketRequest.class);
        mockMvc
          .perform(post("/ifedge/maintenance")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON)
          )
          .andExpect(status().isBadRequest());

      } catch(Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
        fail("IfEdgeREST呼び出し失敗", e);
      }
  }
}
