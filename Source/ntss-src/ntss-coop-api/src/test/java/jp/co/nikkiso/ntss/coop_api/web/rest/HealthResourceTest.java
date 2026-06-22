package jp.co.nikkiso.ntss.coop_api.web.rest;

import static org.assertj.core.api.Assertions.fail;
import static org.hamcrest.CoreMatchers.is;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.File;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.HealthUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.service.HealthService;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeHealthmonDao;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/HealthResourceTest/HealthResourceTest.db5.before.sql")
public class HealthResourceTest extends AbstractResourceTest {
  @MockitoSpyBean
  private HealthService healthService;

  @MockitoBean
  ClockWrapper clockWrapper;

  @MockitoSpyBean
  private MntIfEdgeHealthmonDao mntIfEdgeHealthmonDao;

  @Test
  public void 正常系_ヘルスモニタ情報更新API_リクエストパラメータ通り正しく登録されている_全部入力されている() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_all.json").getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isOk())
          .andExpect(jsonPath("$.status", is(200)))
          .andExpect(jsonPath("$.ctl_no", is(2)))
          .andExpect(jsonPath("$.facility_cd", is(expect.getFacilityCd())))
          .andExpect(jsonPath("$.if_edge_no", is(expect.getIfEdgeNo())))
          .andExpect(jsonPath("$.healthmon_facility_conn.ini_dial.status",
              is(expect.getHealthmonFacilityConn().get("ini_dial").getStatus())))
          .andExpect(jsonPath("$.healthmon_facility_conn.ini_dial.type", is("receive")))
          .andExpect(jsonPath("$.healthmon_facility_conn.ini_dial.moni_time", is(formatDate(getMockClockMillis(), "yyyy-MM-dd hh:mm:ss"))))
          .andExpect(jsonPath("$.healthmon_server_conn.status", is(expect.getHealthmonServerConn().getStatus())))
          .andExpect(jsonPath("$.healthmon_server_conn.moni_time", is(formatDate(getMockClockMillis(), "yyyy-MM-dd hh:mm:ss"))));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ヘルスモニタ情報更新API_リクエストパラメータ通り正しく登録されている_サーバステータスのみ() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_server_only.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isOk())
          .andExpect(jsonPath("$.status", is(200)))
          .andExpect(jsonPath("$.ctl_no", is(2)))
          .andExpect(jsonPath("$.facility_cd", is(expect.getFacilityCd())))
          .andExpect(jsonPath("$.if_edge_no", is(expect.getIfEdgeNo())))
          .andExpect(jsonPath("$.healthmon_facility_conn").doesNotExist())
          .andExpect(jsonPath("$.healthmon_server_conn.status", is(expect.getHealthmonServerConn().getStatus())))
          .andExpect(jsonPath("$.healthmon_server_conn.moni_time", is(formatDate(getMockClockMillis(), "yyyy-MM-dd hh:mm:ss"))));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 正常系_ヘルスモニタ情報更新API_リクエストパラメータ通り正しく登録されている_エッジステータスのみ() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_facility_only.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isOk())
          .andExpect(jsonPath("$.status", is(200)))
          .andExpect(jsonPath("$.ctl_no", is(2)))
          .andExpect(jsonPath("$.facility_cd", is(expect.getFacilityCd())))
          .andExpect(jsonPath("$.if_edge_no", is(expect.getIfEdgeNo())))
          .andExpect(jsonPath("$.healthmon_facility_conn.ini_dial.status",
              is(expect.getHealthmonFacilityConn().get("ini_dial").getStatus())))
          .andExpect(jsonPath("$.healthmon_facility_conn.ini_dial.type", is("receive")))
          .andExpect(jsonPath("$.healthmon_facility_conn.ini_dial.moni_time", is(formatDate(getMockClockMillis(), "yyyy-MM-dd hh:mm:ss"))))
          .andExpect(jsonPath("$.healthmon_server_conn").doesNotExist());
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_リクエストパラメータが足りない_施設コード() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_facility_cd.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isBadRequest())
          .andExpect(jsonPath("$.status", is(400)))
          .andExpect(jsonPath("$.message", is("リクエストパラメータが不正または不足しています。"
              + "facility_cd:[null],"
              + "if_edge_no:[3],"
              + "healthmon_facility_conn:[{ini_dial=HealthmonFacility(status=01, type=null, moniTime=null)}],"
              + "healthmon_server_conn:[HealthmonServer(status=01, moniTime=null)]")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_リクエストパラメータが足りない_エッジ番号() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_edge_no.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isBadRequest())
          .andExpect(jsonPath("$.status", is(400)))
          .andExpect(jsonPath("$.message", is("リクエストパラメータが不正または不足しています。"
              + "facility_cd:[000011],"
              + "if_edge_no:[null],"
              + "healthmon_facility_conn:[{ini_dial=HealthmonFacility(status=01, type=null, moniTime=null)}],"
              + "healthmon_server_conn:[HealthmonServer(status=01, moniTime=null)]")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_リクエストパラメータが足りない_ステータス() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_healthmon.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isBadRequest())
          .andExpect(jsonPath("$.status", is(400)))
          .andExpect(jsonPath("$.message", is("リクエストパラメータが不正または不足しています。"
              + "facility_cd:[000011],"
              + "if_edge_no:[3],"
              + "healthmon_facility_conn:[null],"
              + "healthmon_server_conn:[null]")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_リクエストパラメータが足りない_サーバステータス() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_server.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isBadRequest())
          .andExpect(jsonPath("$.status", is(400)))
          .andExpect(jsonPath("$.message", is("リクエストパラメータが不正または不足しています。"
              + "facility_cd:[000011],"
              + "if_edge_no:[3],"
              + "healthmon_facility_conn:[{ini_dial=HealthmonFacility(status=01, type=null, moniTime=null)}],"
              + "healthmon_server_conn:[HealthmonServer(status=null, moniTime=null)]")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_リクエストパラメータが足りない_エッジステータスの要素数0() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_facility.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isBadRequest())
          .andExpect(jsonPath("$.status", is(400)))
          .andExpect(jsonPath("$.message", is("リクエストパラメータが不正または不足しています。"
              + "facility_cd:[000011],"
              + "if_edge_no:[3],"
              + "healthmon_facility_conn:[{}],"
              + "healthmon_server_conn:[HealthmonServer(status=01, moniTime=null)]")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_リクエストパラメータが足りない_エッジステータスの要素がNULL() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_facility2.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isBadRequest())
          .andExpect(jsonPath("$.status", is(400)))
          .andExpect(jsonPath("$.message", is("リクエストパラメータが不正または不足しています。"
              + "facility_cd:[000011],"
              + "if_edge_no:[3],"
              + "healthmon_facility_conn:[{ini_dial=null}],"
              + "healthmon_server_conn:[HealthmonServer(status=01, moniTime=null)]")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_リクエストパラメータが足りない_エッジステータスの要素の属性がない() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_facility3.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isBadRequest())
          .andExpect(jsonPath("$.status", is(400)))
          .andExpect(jsonPath("$.message", is("リクエストパラメータが不正または不足しています。"
              + "facility_cd:[000011],"
              + "if_edge_no:[3],"
              + "healthmon_facility_conn:[{ini_dial=HealthmonFacility(status=null, type=null, moniTime=null)}],"
              + "healthmon_server_conn:[HealthmonServer(status=01, moniTime=null)]")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_更新対象がない() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_no_target.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isNoContent())
          .andExpect(jsonPath("$.status", is(204)))
          .andExpect(jsonPath("$.message", is("マスタデータに更新対象となるレコードが存在しません。")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }

  @Test
  public void 異常系_ヘルスモニタ情報更新API_更新対象の電文種別がない() {
    File expectFile = new File(
        getClass().getClassLoader().getResource("resource.json/HealthResourceTest/update_error_no_coop_cd.json")
            .getFile());
    // システム日時をモック化
    given(clockWrapper.getClockMillis()).willReturn(getMockClockMillis());

    try {
      HealthUpdateRequest expect = ObjectMapperUtil.readFile(expectFile, HealthUpdateRequest.class);
      mockMvc
          .perform(post("/health/update")
              .content(ObjectMapperUtil.write(expect))
              .contentType(MediaType.APPLICATION_JSON))
          .andExpect(status().isInternalServerError())
          .andExpect(jsonPath("$.status", is(500)))
          .andExpect(jsonPath("$.message", is("エッジヘルスモニタ更新APIにて例外が発生しました。")));
    } catch (Exception e) {
      fail("ヘルスモニタ情報更新に失敗しました", e);
    }
  }
}