package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.ReadStatusRequest;
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.RegisterRequest;
import jp.co.nikkiso.ntss.core.dao.MntNotificationMessageDao;
import jp.co.nikkiso.ntss.core.dao.MntNotificationStatusDao;
import jp.co.nikkiso.ntss.core.entity.MntNotificationStatus;
import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
import org.assertj.core.api.Assertions;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.requestFields;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * {@link NotificationMessageResource}の結合テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/NotificationMessageResourceIntegrationTest.before.sql")
public class NotificationMessageResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * 通知メッセージDao.
   */
  @Autowired
  private MntNotificationMessageDao mntNotificationMessageDao;

  /**
   * 通知状態管理Dao.
   */
  @Autowired
  private MntNotificationStatusDao mntNotificationStatusDao;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * registerNotificationMessage()の検証.
   *
   * 条件: 通知メッセージ、通知状態管理に登録する情報が指定されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser
  @Ignore("通知機能呼び出し変更に伴い、テストケースを見直す必要がある為、本テストケースは無効化にする")
  public void test_registerNotificationMessage_成功() throws Exception {
    // arrange
    final String content = "テストメッセージ内容1";
    final List<Long> recipients = Arrays.asList(4L, 5L);
    final String additionalInfo = "{\"item01\": \"value01\", \"item02\": \"value02\"}";
    final RegisterRequest request = new RegisterRequest() {
      {
        setContent(content);
        setRecipients(recipients);
        setAdditionalInfo(additionalInfo);
      }
    };
    final String requestBody = mapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.post("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andDo(document("notification_message/post/ok",
        requestFields(
          attributes(
            key("description").value("概要：指定された情報をもとに通知メッセージ情報を登録するAPI"),
            key("operationTargetTable").value("操作対象テーブル：通知メッセージ (mnt_notification_message)、通知状態管理 (mnt_notification_status)")
          ),
          fieldWithPath("content").description("[必須]メッセージ本文")
          , fieldWithPath("recipients").description("受信者のリスト")
          , fieldWithPath("additional_info").description("付加情報")
          , fieldWithPath("facility_cd").description("施設コード")
        )
      ))
    ;

    // 通知メッセージ情報を検証
    List<NotificationMessage> messages = mntNotificationMessageDao.selectByUserId(4L, null, false);
    Assertions.assertThat(messages).hasSize(1);
    Assertions.assertThat(messages.get(0).getNotificationMessageNo()).isNotNull();
    Assertions.assertThat(messages.get(0).getContent()).isEqualTo(content);
    Assertions.assertThat(messages.get(0).getAdditionalInfo()).isEqualTo(additionalInfo);
    Assertions.assertThat(messages.get(0).getIsRead()).isEqualTo("0");
    Assertions.assertThat(messages.get(0).getRegDate()).isNotNull();
    Assertions.assertThat(messages.get(0).getUpDate()).isNull();
  }

  /**
   * registerNotificationMessage()の検証.
   *
   * 条件: リクエストにメッセージ本文が入力されていないこと
   * 結果: HTTPステータス400が返ってくること
   */
  @Test
  @NtssMockUser
  @Ignore("通知機能呼び出し変更に伴い、テストケースを見直す必要がある為、本テストケースは無効化にする")
  public void test_registerNotificationMessage_失敗_メッセージ本文が入力されていない場合_400が返ること() throws Exception {
    // arrange
    final String content = "テストメッセージ内容";
    final List<Long> recipients = Arrays.asList(1L, 2L);
    final String additionalInfo = "{\"item01\": \"value01\", \"item02\": \"value02\"}";
    final RegisterRequest request = new RegisterRequest() {
      {
        setContent(null);
        setRecipients(recipients);
        setAdditionalInfo(additionalInfo);
      }
    };
    final String requestBody = mapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.post("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isBadRequest())
      .andDo(document("notification_message/post/required-be-empty",
        requestFields(
          attributes(
            key("description").value(""),
            key("operationTargetTable").value("")
          ),
          fieldWithPath("content").description("[必須]メッセージ本文")
          , fieldWithPath("recipients").ignored()
          , fieldWithPath("additional_info").ignored()
          , fieldWithPath("facility_cd").ignored()
        )
      ));
  }

  /**
   * getNotificationMessage()の検証.
   *
   * 条件: サインインしたユーザーIDに該当する通知メッセージが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(userId = 2)
  public void test_getNotificationMessage_成功() throws Exception {

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/notification-message")
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$.notification_list[0].notification_message_no", is(10)))
      .andExpect(jsonPath("$.notification_list[0].content", is("テストメッセージ内容1")))
      .andExpect(jsonPath("$.notification_list[0].additional_info", is("{\"item01\": \"value01\", \"item02\": \"value02\"}")))
      .andExpect(jsonPath("$.notification_list[0].is_read", is("0")))
      .andExpect(jsonPath("$.notification_list[0].reg_date", is("2019-08-05T12:00:00.000+09:00")))
      .andExpect(jsonPath("$.notification_list[1].notification_message_no", is(30)))
      .andExpect(jsonPath("$.notification_list[1].content", is("テストメッセージ内容3")))
      .andExpect(jsonPath("$.notification_list[1].additional_info", is("{\"item01\": \"value01\"}")))
      .andExpect(jsonPath("$.notification_list[1].is_read", is("0")))
      .andExpect(jsonPath("$.notification_list[1].reg_date", is("2019-08-05T12:00:02.000+09:00")))
      .andExpect(jsonPath("$.notification_list[2].notification_message_no", is(50)))
      .andExpect(jsonPath("$.notification_list[2].content", is("テストメッセージ内容5")))
      .andExpect(jsonPath("$.notification_list[2].additional_info", is("{\"item01\": \"value01\"}")))
      .andExpect(jsonPath("$.notification_list[2].is_read", is("1")))
      .andExpect(jsonPath("$.notification_list[2].reg_date", is("2019-08-05T12:00:04.000+09:00")))
      .andExpect(jsonPath("$.read_on_jump", is("1")))
      .andExpect(jsonPath("$.unread_cnt", is(3)))

      .andDo(document("notification_message/get/ok",
        responseFields(
          attributes(
            key("description").value("概要：サインインしているユーザーIDに該当する通知メッセージ情報(未通知)を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：通知メッセージ (mnt_notification_message)、通知状態管理 (mnt_notification_status)、利用者マスタ (mst_user)")
          ),
          fieldWithPath("notification_list[].notification_message_no").description("通知メッセージ番号"),
          fieldWithPath("notification_list[].content").description("メッセージ本文"),
          fieldWithPath("notification_list[].additional_info").description("付加情報"),
          fieldWithPath("notification_list[].is_read").description("既読フラグ"),
          fieldWithPath("notification_list[].reg_date").description("登録日時(ISO8601形式文字列)"),
          fieldWithPath("notification_list[].operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("notification_list[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional(),
          fieldWithPath("read_on_jump").description("通知メッセージジャンプで既読"),
          fieldWithPath("unread_cnt").description("未読件数")
        )))
    ;
  }

  /**
   * getNotificationMessageAll()の検証.
   *
   * 条件: サインインしたユーザーIDに該当する通知メッセージが登録されている
   * 結果: 成功レスポンスが返されること
   */
  @Test
  @NtssMockUser(userId = 2)
  public void test_getNotificationMessageAll_成功() throws Exception {

    // action
    ResultActions result
      = mockMvc.perform(RestDocumentationRequestBuilders.get("/api/notification-message/all")
      .contentType(MediaType.APPLICATION_JSON_UTF8));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$").exists())
      .andExpect(jsonPath("$.notification_list[0].notification_message_no", is(50)))
      .andExpect(jsonPath("$.notification_list[0].content", is("テストメッセージ内容5")))
      .andExpect(jsonPath("$.notification_list[0].additional_info", is("{\"item01\": \"value01\"}")))
      .andExpect(jsonPath("$.notification_list[0].is_read", is("1")))
      .andExpect(jsonPath("$.notification_list[0].reg_date", is("2019-08-05T12:00:04.000+09:00")))
      .andExpect(jsonPath("$.notification_list[1].notification_message_no", is(40)))
      .andExpect(jsonPath("$.notification_list[1].content", is("テストメッセージ内容4")))
      .andExpect(jsonPath("$.notification_list[1].additional_info", is("{\"item01\": \"value01\"}")))
      .andExpect(jsonPath("$.notification_list[1].is_read", is("1")))
      .andExpect(jsonPath("$.notification_list[1].reg_date", is("2019-08-05T12:00:03.000+09:00")))
      .andExpect(jsonPath("$.notification_list[2].notification_message_no", is(30)))
      .andExpect(jsonPath("$.notification_list[2].content", is("テストメッセージ内容3")))
      .andExpect(jsonPath("$.notification_list[2].additional_info", is("{\"item01\": \"value01\"}")))
      .andExpect(jsonPath("$.notification_list[2].is_read", is("0")))
      .andExpect(jsonPath("$.notification_list[2].reg_date", is("2019-08-05T12:00:02.000+09:00")))
      .andExpect(jsonPath("$.notification_list[3].notification_message_no", is(20)))
      .andExpect(jsonPath("$.notification_list[3].content", is("テストメッセージ内容2")))
      .andExpect(jsonPath("$.notification_list[3].additional_info", is("{\"item01\": \"value01\"}")))
      .andExpect(jsonPath("$.notification_list[3].is_read", is("0")))
      .andExpect(jsonPath("$.notification_list[3].reg_date", is("2019-08-05T12:00:01.000+09:00")))
      .andExpect(jsonPath("$.notification_list[4].notification_message_no", is(10)))
      .andExpect(jsonPath("$.notification_list[4].content", is("テストメッセージ内容1")))
      .andExpect(jsonPath("$.notification_list[4].additional_info", is("{\"item01\": \"value01\", \"item02\": \"value02\"}")))
      .andExpect(jsonPath("$.notification_list[4].is_read", is("0")))
      .andExpect(jsonPath("$.notification_list[4].reg_date", is("2019-08-05T12:00:00.000+09:00")))
      .andExpect(jsonPath("$.read_on_jump", is("1")))
      .andExpect(jsonPath("$.unread_cnt", is(3)))

      .andDo(document("notification_message/all/get/ok",
        responseFields(
          attributes(
            key("description").value("概要：サインインしているユーザーIDに該当する通知メッセージ情報(全件)を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：通知メッセージ (mnt_notification_message)、通知状態管理 (mnt_notification_status)、利用者マスタ (mst_user)")
          ),
          fieldWithPath("notification_list[].notification_message_no").description("通知メッセージ番号"),
          fieldWithPath("notification_list[].content").description("メッセージ本文"),
          fieldWithPath("notification_list[].additional_info").description("付加情報"),
          fieldWithPath("notification_list[].is_read").description("既読フラグ"),
          fieldWithPath("notification_list[].reg_date").description("登録日時(ISO8601形式文字列)"),
          fieldWithPath("notification_list[].operator_id").description("操作者ID(ログ出力用)").optional(),
          fieldWithPath("notification_list[].target_facility_cd").description("処理対象施設コード(ログ出力用)").optional(),
          fieldWithPath("read_on_jump").description("通知メッセージジャンプで既読"),
          fieldWithPath("unread_cnt").description("未読件数")
        )))
    ;
  }

  /**
   * updateReadStatus()の検証.
   * 条件: なし
   * 結果: HTTPステータス200が返ってくること
   */
  @Test
  @NtssMockUser(userId = 2)
  public void test_updateReadStatus_成功() throws Exception {
    // arrange
    List<Long> notificationMessageNos = Arrays.asList(10L, 20L, 40L);
    String isRead = "1";
    String isNotRead = "0";
    ReadStatusRequest request = new ReadStatusRequest() {
      {
        setNotificationMessageNos(notificationMessageNos);
        setIsRead(isRead);
      }
    };

    final String requestBody = mapper.writeValueAsString(request);

    // action
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders.put("/api/notification-message/status")
      .contentType(MediaType.APPLICATION_JSON_UTF8)
      .content(requestBody)
      .with(csrf())
    );

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("unread_cnt", is(1)))
      .andDo(document("notification-message/status/put/ok",
        requestFields(
          attributes(
            key("description").value("概要：既読フラグを更新する"),
            key("operationTargetTable").value("操作対象テーブル：通知状態管理 (mnt_notification_status)")
          ),
          fieldWithPath("notification_message_nos").description("通知メッセージ番号のリスト")
          , fieldWithPath("is_read").description("既読フラグ")
        ),
        responseFields(
          attributes(
            key("description").value("概要:既読フラグ更新後の未読件数を返す")
            , key("operationTargetTable").value("操作対象テーブル：通知状態管理 (mnt_notification_status)")
          ),
          fieldWithPath("unread_cnt").description("未読件数")
        )
      ))
    ;

    // 更新後の検証
    MntNotificationStatus updated1 = mntNotificationStatusDao.selectById(10L, 2L);
    Assertions.assertThat(updated1.getIsRead()).isEqualTo(isRead);
    MntNotificationStatus updated2 = mntNotificationStatusDao.selectById(10L, 3L);
    Assertions.assertThat(updated2.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated3 = mntNotificationStatusDao.selectById(20L, 2L);
    Assertions.assertThat(updated3.getIsRead()).isEqualTo(isRead);
    MntNotificationStatus updated4 = mntNotificationStatusDao.selectById(30L, 2L);
    Assertions.assertThat(updated4.getIsRead()).isEqualTo(isNotRead);
    MntNotificationStatus updated5 = mntNotificationStatusDao.selectById(40L, 2L);
    Assertions.assertThat(updated5.getIsRead()).isEqualTo(isRead);
    MntNotificationStatus updated6 = mntNotificationStatusDao.selectById(50L, 2L);
    Assertions.assertThat(updated6.getIsRead()).isEqualTo(isRead);
  }

}
