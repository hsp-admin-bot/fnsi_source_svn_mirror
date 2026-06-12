package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.hamcrest.Matchers.is;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;

import jp.co.nikkiso.ntss.admin_web.response.GatheringStatusResponse;
import jp.co.nikkiso.ntss.admin_web.service.motionRecords.MotionRecordsService;

/**
 * MotionRecordResourceのテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class MotionRecordResourceTest extends AbstractResourceTest {

  /**
   * 装置動作記録Service.
   */
  @MockitoBean
  private MotionRecordsService motionRecordsService;

  /**
   * getGatheringStatus()の検証.
   * 正常
   */
  @Test
  public void test_getGatheringStatus_正常() throws Exception {

    // 事前準備
    Long userId = 1L;
    String facilityCd = "900001";

    // Mock化
    given(motionRecordsService.getGatheringStatus(anyLong(), anyString())).willReturn(new GatheringStatusResponse(2));

    // API実行
    ResultActions result =  mockMvc.perform(get("/api/motion_record/gathering_status/{userId}/{facilityCd}", userId, facilityCd).with(csrf()));

    // 検証
    verify(motionRecordsService, times(1)).getGatheringStatus(userId, facilityCd);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.gatheringStatus", is(2)));

  }

  // TODO:既存メソッドのテストを追加してください
}
