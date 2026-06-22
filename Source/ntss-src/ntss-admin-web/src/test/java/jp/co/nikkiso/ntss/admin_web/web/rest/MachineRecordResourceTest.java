package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.Arrays.asList;
import static java.util.Collections.emptyList;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;

import jp.co.nikkiso.ntss.admin_web.response.MachineRecordResponse;
import jp.co.nikkiso.ntss.admin_web.service.MachineRecordService;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class MachineRecordResourceTest extends AbstractResourceTest {

  /**
   * 装置記録サービスクラス.
   */
  @MockitoBean
  private MachineRecordService machineRecordService;

  /**
  /**
   * getMachineRecordの検証.
   *
   * 条件：成功, 装置記録にデータあり
   * 結果：成功レスポンスが返されること
   */
  @Test
  public void test_getMachineRecord_正常_データあり() throws Exception{
    List<MachineRecordResponse.MachineRecord> machineRecords = asList(
        new MachineRecordResponse.MachineRecord("0050", "投与", "1", "1", "1")
        , new MachineRecordResponse.MachineRecord("0060", "酸素吸入開始", "1", "2", "3")
        , new MachineRecordResponse.MachineRecord("0103", "ケア", "1", "4", "6")
        , new MachineRecordResponse.MachineRecord("0106", null, "0", "2", "4")
        , new MachineRecordResponse.MachineRecord("0109", "引き残し量", "0", "1", "1")
      );
    MachineRecordResponse response = new MachineRecordResponse(machineRecords);
    given(machineRecordService.getAllMachineRecords(null)).willReturn(response);

    mockMvc
      .perform(get("/api/machine_record"))
      // assert
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.machineRecords", hasSize(5)))
      .andExpect(jsonPath("$.machineRecords[0].code", is("0050")))
      .andExpect(jsonPath("$.machineRecords[0].message", is("投与")))
      .andExpect(jsonPath("$.machineRecords[0].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[0].log_class", is("1")))
      .andExpect(jsonPath("$.machineRecords[0].target_model", is("1")))
      .andExpect(jsonPath("$.machineRecords[1].code", is("0060")))
      .andExpect(jsonPath("$.machineRecords[1].message", is("酸素吸入開始")))
      .andExpect(jsonPath("$.machineRecords[1].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[1].log_class", is("2")))
      .andExpect(jsonPath("$.machineRecords[1].target_model", is("3")))
      .andExpect(jsonPath("$.machineRecords[2].code", is("0103")))
      .andExpect(jsonPath("$.machineRecords[2].message", is("ケア")))
      .andExpect(jsonPath("$.machineRecords[2].is_default", is("1")))
      .andExpect(jsonPath("$.machineRecords[2].log_class", is("4")))
      .andExpect(jsonPath("$.machineRecords[2].target_model", is("6")))
      .andExpect(jsonPath("$.machineRecords[3].code", is("0106")))
      .andExpect(jsonPath("$.machineRecords[3].message", is(nullValue())))
      .andExpect(jsonPath("$.machineRecords[3].is_default", is("0")))
      .andExpect(jsonPath("$.machineRecords[3].log_class", is("2")))
      .andExpect(jsonPath("$.machineRecords[3].target_model", is("4")))
      .andExpect(jsonPath("$.machineRecords[4].code", is("0109")))
      .andExpect(jsonPath("$.machineRecords[4].message", is("引き残し量")))
      .andExpect(jsonPath("$.machineRecords[4].is_default", is("0")))
      .andExpect(jsonPath("$.machineRecords[4].log_class", is("1")))
      .andExpect(jsonPath("$.machineRecords[4].target_model", is("1")))
    ;

    // assert
    verify(machineRecordService, times(1)).getAllMachineRecords(null);
  }

  /**
   * getMachineRecordの検証.
   *
   * 条件：成功, 装置記録にデータなし
   * 結果：成功レスポンスが返されること
   */
  @Test
  public void test_getMachineRecord_正常＿データなし() throws Exception {
    List<MachineRecordResponse.MachineRecord> machineRecords = emptyList();
    MachineRecordResponse response = new MachineRecordResponse(machineRecords);
    given(machineRecordService.getAllMachineRecords(null)).willReturn(response);

    // action
    mockMvc
    .perform(get("/api/machine_record"))
    // assert
    .andExpect(status().isOk())
    .andExpect(jsonPath("$.machineRecords", hasSize(0)))
    ;

    // assert
    verify(machineRecordService, times(1)).getAllMachineRecords(null);
  }
}
