package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.ReadStatusRequest;
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.RegisterRequest;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.NotificationListResponse;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.UnreadCountResponse;
import jp.co.nikkiso.ntss.admin_web.service.notificationMessage.NotificationMessageService;
import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.anyList;
import static org.mockito.BDDMockito.anyLong;
import static org.mockito.BDDMockito.anyString;
import static org.mockito.BDDMockito.doNothing;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * {@link NotificationMessageResource}のテストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class NotificationMessageResourceTest extends AbstractResourceTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 通知一覧Service.
   */
  @MockitoBean
  private NotificationMessageService notificationMessageService;

  /**
   * registerNotificationMessage()の検証.
   *
   * 条件：成功
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_registerNotificationMessage_成功() throws Exception {
    // 事前準備
    String content = "テストメッセージ";
    List<Long> recipients = Arrays.asList(1L, 2L);
    String additionalInfo = "テスト付加情報";
    RegisterRequest request = new RegisterRequest() {
      {
        setContent(content);
        setRecipients(recipients);
        setAdditionalInfo(additionalInfo);
      }
    };
    String requestBody = mapper.writeValueAsString(request);
    Long messageNo = 11L;

    ArgumentCaptor<String> args1 = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<List> args2 = ArgumentCaptor.forClass(List.class);
    ArgumentCaptor<String> args3 = ArgumentCaptor.forClass(String.class);
    ArgumentCaptor<Long> args4 = ArgumentCaptor.forClass(Long.class);
    ArgumentCaptor<List> args5 = ArgumentCaptor.forClass(List.class);
    ArgumentCaptor<String> args6 = ArgumentCaptor.forClass(String.class);

    // Mock化
    given(notificationMessageService.registerNotificationMessage(args1.capture(), args2.capture(), args3.capture(), args6.capture())).willReturn(messageNo);
    doNothing().when(notificationMessageService).notifyNotificationMessage(args4.capture(), args5.capture());

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.post("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(notificationMessageService, times(0)).registerNotificationMessage(anyString(), anyList(), anyString(), anyString());
    verify(notificationMessageService, times(0)).notifyNotificationMessage(anyLong(), anyList());
    result.andExpect(status().isOk());
  }

  /**
   * registerNotificationMessage()の検証.
   *
   * 条件：失敗（メッセージ本文がNULL）
   * 結果：失敗レスポンス(Status:400)が返されること
   */
  @Test
  @NtssMockUser
  public void test_registerNotificationMessage_失敗_メッセージ本文_NULL() throws Exception {
    // 事前準備
    String content = null;
    List<Long> recipients = Arrays.asList(1L, 2L);
    String additionalInfo = "テスト付加情報";
    RegisterRequest request = new RegisterRequest() {
      {
        setContent(content);
        setRecipients(recipients);
        setAdditionalInfo(additionalInfo);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(notificationMessageService.registerNotificationMessage(anyString(), anyList(), anyString(), anyString())).willReturn(0L);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.post("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(notificationMessageService, times(0)).registerNotificationMessage(anyString(), anyList(), anyString(), anyString());
    result.andExpect(status().isBadRequest());
  }

  /**
   * registerNotificationMessage()の検証.
   *
   * 条件：失敗（メッセージ本文が空文字）
   * 結果：失敗レスポンス(Status:400)が返されること
   */
  @Test
  @NtssMockUser
  public void test_registerNotificationMessage_失敗_メッセージ本文_空文字() throws Exception {
    // 事前準備
    String content = "";
    List<Long> recipients = Arrays.asList(1L, 2L);
    String additionalInfo = "テスト付加情報";
    RegisterRequest request = new RegisterRequest() {
      {
        setContent(content);
        setRecipients(recipients);
        setAdditionalInfo(additionalInfo);
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    // Mock化
    given(notificationMessageService.registerNotificationMessage(anyString(), anyList(), anyString(), anyString())).willReturn(0L);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.post("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(notificationMessageService, times(0)).registerNotificationMessage(anyString(), anyList(), anyString(), anyString());
    result.andExpect(status().isBadRequest());
  }

  /**
   * getNotificationMessage()の検証.
   *
   * 条件：成功(該当データあり)
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_getNotificationMessage_成功_該当データあり() throws Exception {
    // 事前準備
    final String facilityCd = "000001";
    List<NotificationMessage> notifications = Arrays.asList(
      new NotificationMessage() {
        {
          setNotificationMessageNo(1L);
          setContent("1-1");
          setAdditionalInfo("1-2");
          setIsRead("1-3");
          setRegDate(Timestamp.valueOf("2019-08-07 09:00:00.000"));
        }
      }
      , new NotificationMessage() {
        {
          setNotificationMessageNo(2L);
          setContent("2-1");
          setAdditionalInfo("2-2");
          setIsRead("2-3");
          setRegDate(Timestamp.valueOf("2019-08-07 10:00:00.000"));
        }
      }
    );
    NotificationListResponse response = new NotificationListResponse(notifications, "1", 2);

    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(notificationMessageService.getNotificationMessage(args.capture(), facilityCd)).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(notificationMessageService, times(1)).getNotificationMessage(anyLong(), facilityCd);
    assertThat(args.getValue(), is(1L));
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.notification_list[0].notification_message_no", is(1)))
      .andExpect(jsonPath("$.notification_list[0].content", is("1-1")))
      .andExpect(jsonPath("$.notification_list[0].additional_info", is("1-2")))
      .andExpect(jsonPath("$.notification_list[0].is_read", is("1-3")))
      .andExpect(jsonPath("$.notification_list[0].reg_date", is("2019-08-07T09:00:00.000+09:00")))
      .andExpect(jsonPath("$.notification_list[1].notification_message_no", is(2)))
      .andExpect(jsonPath("$.notification_list[1].content", is("2-1")))
      .andExpect(jsonPath("$.notification_list[1].additional_info", is("2-2")))
      .andExpect(jsonPath("$.notification_list[1].is_read", is("2-3")))
      .andExpect(jsonPath("$.notification_list[1].reg_date", is("2019-08-07T10:00:00.000+09:00")))
      .andExpect(jsonPath("$.read_on_jump", is("1")))
      .andExpect(jsonPath("$.unread_cnt", is(2)));
  }

  /**
   * getNotificationMessage()の検証.
   *
   * 条件：成功(該当データなし)
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_getNotificationMessage_成功_該当データなし() throws Exception {
    // 事前準備
    final String facilityCd = "000001";
    List<NotificationMessage> notifications = Collections.EMPTY_LIST;
    NotificationListResponse response = new NotificationListResponse(notifications, "1", 0);

    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(notificationMessageService.getNotificationMessage(args.capture(), facilityCd)).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(notificationMessageService, times(1)).getNotificationMessage(anyLong(), facilityCd);
    assertThat(args.getValue(), is(1L));
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.notification_list", hasSize(0)))
      .andExpect(jsonPath("$.read_on_jump", is("1")))
      .andExpect(jsonPath("$.unread_cnt", is(0)));
  }

  /**
   * getNotificationMessageAll()の検証.
   *
   * 条件：成功(該当データあり)
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_getNotificationMessageAll_成功_該当データあり() throws Exception {
    // 事前準備
    List<NotificationMessage> notifications = Arrays.asList(
      new NotificationMessage() {
        {
          setNotificationMessageNo(1L);
          setContent("1-1");
          setAdditionalInfo("1-2");
          setIsRead("1-3");
          setRegDate(Timestamp.valueOf("2019-08-07 09:00:00.000"));
        }
      }
      , new NotificationMessage() {
        {
          setNotificationMessageNo(2L);
          setContent("2-1");
          setAdditionalInfo("2-2");
          setIsRead("2-3");
          setRegDate(Timestamp.valueOf("2019-08-07 10:00:00.000"));
        }
      }
    );
    NotificationListResponse response = new NotificationListResponse(notifications, "1", 2);

    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(notificationMessageService.getNotificationMessageAll(args.capture())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/notification-message/all")
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(notificationMessageService, times(1)).getNotificationMessageAll(anyLong());
    assertThat(args.getValue(), is(1L));
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.notification_list[0].notification_message_no", is(1)))
      .andExpect(jsonPath("$.notification_list[0].content", is("1-1")))
      .andExpect(jsonPath("$.notification_list[0].additional_info", is("1-2")))
      .andExpect(jsonPath("$.notification_list[0].is_read", is("1-3")))
      .andExpect(jsonPath("$.notification_list[0].reg_date", is("2019-08-07T09:00:00.000+09:00")))
      .andExpect(jsonPath("$.notification_list[1].notification_message_no", is(2)))
      .andExpect(jsonPath("$.notification_list[1].content", is("2-1")))
      .andExpect(jsonPath("$.notification_list[1].additional_info", is("2-2")))
      .andExpect(jsonPath("$.notification_list[1].is_read", is("2-3")))
      .andExpect(jsonPath("$.notification_list[1].reg_date", is("2019-08-07T10:00:00.000+09:00")))
      .andExpect(jsonPath("$.read_on_jump", is("1")))
      .andExpect(jsonPath("$.unread_cnt", is(2)));
  }

  /**
   * getNotificationMessageAll()の検証.
   *
   * 条件：成功(該当データなし)
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_getNotificationMessageAll_成功_該当データなし() throws Exception {
    // 事前準備
    List<NotificationMessage> notifications = Collections.EMPTY_LIST;
    NotificationListResponse response = new NotificationListResponse(notifications, "1", 0);

    ArgumentCaptor<Long> args = ArgumentCaptor.forClass(Long.class);

    // Mock化
    given(notificationMessageService.getNotificationMessageAll(args.capture())).willReturn(response);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/notification-message/all")
      .contentType(MediaType.APPLICATION_JSON));

    // 検証
    verify(notificationMessageService, times(1)).getNotificationMessageAll(anyLong());
    assertThat(args.getValue(), is(1L));
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.notification_list", hasSize(0)))
      .andExpect(jsonPath("$.read_on_jump", is("1")))
      .andExpect(jsonPath("$.unread_cnt", is(0)));
  }

  /**
   * updateReadStatus()の検証.
   *
   * 条件：成功
   * 結果：成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  public void test_updateReadStatus_成功() throws Exception {
    // 事前準備
    List<Long> notificationMessageNos = Arrays.asList(1L, 2L, 4L);
    final String facilityCd = "000001";
    UnreadCountResponse unreadCount = new UnreadCountResponse(2);
    Long userId = 1L;
    ReadStatusRequest request = new ReadStatusRequest() {
      {
        setNotificationMessageNos(notificationMessageNos);
        setIsRead("1");
      }
    };
    String requestBody = mapper.writeValueAsString(request);

    ArgumentCaptor<ReadStatusRequest> args1 = ArgumentCaptor.forClass(ReadStatusRequest.class);
    ArgumentCaptor<Long> args2 = ArgumentCaptor.forClass(Long.class);

    // Mock化
    doNothing().when(notificationMessageService).updateReadStatus(args1.capture(), args2.capture(), facilityCd);
    given(notificationMessageService.getUnreadCount(args2.capture())).willReturn(unreadCount);

    // API実行
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.put("/api/notification-message/status")
      .contentType(MediaType.APPLICATION_JSON).content(requestBody).with(csrf()));

    // 検証
    verify(notificationMessageService, times(1)).updateReadStatus(any(), anyLong(), facilityCd);
    assertThat(args1.getValue(), is(request));
    assertThat(args2.getValue(), is(userId));
    verify(notificationMessageService, times(1)).getUnreadCount(anyLong());
    assertThat(args2.getValue(), is(userId));
    result.andExpect(status().isOk());
  }
}
