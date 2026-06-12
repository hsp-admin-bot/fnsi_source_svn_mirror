package jp.co.nikkiso.ntss.admin_web.service.notificationMessage;

import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.ReadStatusRequest;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.NotificationListResponse;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.UnreadCountResponse;
import jp.co.nikkiso.ntss.admin_web.service.userSettings.UserSettingsService;
import jp.co.nikkiso.ntss.core.dao.MntNotificationMessageDao;
import jp.co.nikkiso.ntss.core.dao.MntNotificationStatusDao;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MntNotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MntNotificationStatus;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.samePropertyValuesAs;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;


@RunWith(SpringRunner.class)
@SpringBootTest
public class NotificationMessageServiceImplTest {

  /**
   * テスト対象クラス
   */
  @Autowired
  private NotificationMessageService target;

  /**
   * ユーザー設定ServiceのMockBean.
   */
  @MockitoBean
  private UserSettingsService userSettingsService;

  /**
   * 通知メッセージのMockBean.
   */
  @MockitoBean
  private MntNotificationMessageDao mntNotificationMessageDao;

  /**
   * 通知状態管理のMockBean.
   */
  @MockitoBean
  private MntNotificationStatusDao mntNotificationStatusDao;

  /**
   * registerNotificationMessage()の検証.
   *
   * 条件：通知メッセージに登録する情報を指定する
   * 結果：通知メッセージ、通知状態管理が登録されること、古い通知メッセージが削除されること
   */
  @Test
  public void test_registerNotificationMessage_成功() {
    // arrange
    final String content = "テスト内容";
    final List<Long> recipients = Arrays.asList(10L, 20L);
    final String additionalInfo = "テスト付加情報";
    final String facilityCd = "000001";

    final int[] insertCount = {1, 1};

    // mock(通知メッセージ登録)
    final ArgumentCaptor<MntNotificationMessage> captor1 = ArgumentCaptor.forClass(MntNotificationMessage.class);
    given(mntNotificationMessageDao.insert(captor1.capture())).willReturn(1);

    // mock(通知状態管理登録)
    final ArgumentCaptor<List<MntNotificationStatus>> captor2 = ArgumentCaptor.forClass(List.class);
    given(mntNotificationStatusDao.insert(captor2.capture())).willReturn(insertCount);

    // mock(通知メッセージ削除)
    final ArgumentCaptor<Timestamp> captor3 = ArgumentCaptor.forClass(Timestamp.class);
    given(mntNotificationMessageDao.delete(captor3.capture())).willReturn(1);

    // action
    target.registerNotificationMessage(content, recipients, additionalInfo, facilityCd);

    // assert(通知メッセージ登録)
    final MntNotificationMessage insertedMntNotificationMessage = captor1.getValue();
    assertThat(insertedMntNotificationMessage.getContent(), is(content));
    assertThat(insertedMntNotificationMessage.getAdditionalInfo(), is(additionalInfo));
    assertThat(insertedMntNotificationMessage.getFacilityCd(), is(facilityCd));

    // assert(通知状態管理登録)
    final List<MntNotificationStatus> insertedMntNotificationStatuses = captor2.getValue();
    assertThat(insertedMntNotificationStatuses.get(0).getUserId(), is(recipients.get(0)));
    assertThat(insertedMntNotificationStatuses.get(0).getFacilityCd(), is(facilityCd));
    assertThat(insertedMntNotificationStatuses.get(1).getUserId(), is(recipients.get(1)));
    assertThat(insertedMntNotificationStatuses.get(1).getFacilityCd(), is(facilityCd));

    // assert(通知メッセージ削除)
    final Timestamp deletedTimestamp = captor3.getValue();
    // ミリ秒までの検証はできないため、設定されていること、かつ 年月日までの検証とする
    LocalDate localDate = LocalDate.now().plusMonths(-3L);
    Timestamp timestamp = Timestamp.valueOf(localDate.atStartOfDay());
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
    assertThat(deletedTimestamp, notNullValue());
    assertThat(sdf.format(deletedTimestamp), is(sdf.format(timestamp)));
  }

  /**
   * getNotificationMessage()の検証.
   *
   * 条件：指定された利用者のユーザー設定が存在しない
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getNotificationMessage_正常_ユーザー設定が存在しない() {
    // arrange
    final Long userId = 1L;
    final String facilityCd = "000001";
    final List<NotificationMessage> messages = Arrays.asList(
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
    final List<Long> notificationMessageNos = messages.stream().map(m -> m.getNotificationMessageNo()).collect(Collectors.toList());
    final List<MstUser.SettingValue> settingValues = Collections.EMPTY_LIST;
    final int unreadCount = 99;
    final int updateCount = 9;

    NotificationListResponse expected = new NotificationListResponse(messages, NotificationListResponse.READ_ON_JUMP_NO, unreadCount);

    // mock(通知メッセージ取得)
    final ArgumentCaptor<Long> captor1_1 = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<String> captor1_2 = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<Boolean> captor1_3 = ArgumentCaptor.forClass(Boolean.class);
    given(mntNotificationMessageDao.selectByUserId(captor1_1.capture(), captor1_2.capture(), captor1_3.capture())).willReturn(messages);

    // mock(個人設定情報取得)
    final ArgumentCaptor<Long> captor2_1 = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<Integer> captor2_2 = ArgumentCaptor.forClass(Integer.class);
    given(userSettingsService.getPersonalSettings(captor2_1.capture(), captor2_2.capture())).willReturn(settingValues);

    // mock(未読件数取得)
    final ArgumentCaptor<Long> captor3_1 = ArgumentCaptor.forClass(Long.class);
    given(mntNotificationStatusDao.selectUnreadCountByUserId(captor3_1.capture())).willReturn(unreadCount);

    // mock(通知済フラグ更新)
    final ArgumentCaptor<List> captor4_1 = ArgumentCaptor.forClass(List.class);
    final ArgumentCaptor<Long> captor4_2 = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<String> captor4_3 = ArgumentCaptor.forClass(String.class);
    given(mntNotificationStatusDao.updateIsNotified(captor4_1.capture(), captor4_2.capture(), captor4_3.capture())).willReturn(updateCount);

    // action
    NotificationListResponse response = target.getNotificationMessage(userId, facilityCd);

    // assert(通知メッセージ取得)
    verify(mntNotificationMessageDao, times(1)).selectByUserId(anyLong(), anyString(), anyBoolean());
    assertThat(captor1_1.getValue(), is(userId));
    assertThat(captor1_2.getValue(), is(MntNotificationStatus.IS_NOT_NOTIFIED));
    assertThat(captor1_3.getValue(), is(false));

    // assert(利用者マスタ取得)
    verify(userSettingsService, times(1)).getPersonalSettings(anyLong(), anyInt());
    assertThat(captor2_1.getValue(), is(userId));
    assertThat(captor2_2.getValue(), is(NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE));

    // assert(未読件数取得)
    verify(mntNotificationStatusDao, times(1)).selectUnreadCountByUserId(anyLong());
    assertThat(captor3_1.getValue(), is(userId));

    // assert(通知済フラグ更新)
    verify(mntNotificationStatusDao, times(1)).updateIsNotified(anyList(), anyLong(), anyString());
    assertThat(captor4_1.getValue(), is(notificationMessageNos));
    assertThat(captor4_2.getValue(), is(userId));
    assertThat(captor4_3.getValue(), is(MntNotificationStatus.IS_NOTIFIED));

    // assert(response)
    assertThat(response, is(samePropertyValuesAs(expected)));
  }

  /**
   * getNotificationMessage()の検証.
   *
   * 条件：通知メッセージジャンプで既読(ユーザー設定)に "既読にする" が設定されている
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getNotificationMessage_正常_ユーザー設定に既読にするが設定されている() {
    // arrange
    final Long userId = 1L;
    final String facilityCd = "000001";
    final List<NotificationMessage> messages = Collections.EMPTY_LIST;
    final List<MstUser.SettingValue> settingValues = Arrays.asList(
      new MstUser.SettingValue() {
        {
          setSettingId(NotificationListResponse.SETTING_IDENTIFIER_READ_ON_JUMP);
          setSettingValue(NotificationListResponse.READ_ON_JUMP_YES);
        }
      }
    );
    final int unreadCount = 0;
    final int updateCount = 0;

    NotificationListResponse expected = new NotificationListResponse(messages, NotificationListResponse.READ_ON_JUMP_YES, unreadCount);

    // mock
    given(mntNotificationMessageDao.selectByUserId(anyLong(), anyString(), anyBoolean())).willReturn(messages);
    given(userSettingsService.getPersonalSettings(anyLong(), anyInt())).willReturn(settingValues);
    given(mntNotificationStatusDao.selectUnreadCountByUserId(anyLong())).willReturn(unreadCount);
    given(mntNotificationStatusDao.updateIsNotified(anyList(), anyLong(), anyString())).willReturn(updateCount);

    // action
    NotificationListResponse response = target.getNotificationMessage(userId, facilityCd);

    // assert
    verify(mntNotificationMessageDao, times(1)).selectByUserId(anyLong(), anyString(), anyBoolean());
    verify(userSettingsService, times(1)).getPersonalSettings(anyLong(), anyInt());
    verify(mntNotificationStatusDao, times(1)).selectUnreadCountByUserId(anyLong());
    verify(mntNotificationStatusDao, times(1)).updateIsNotified(anyList(), anyLong(), anyString());
    assertThat(response, is(samePropertyValuesAs(expected)));
  }

  /**
   * getNotificationMessageAll()の検証.
   *
   * 条件：なし
   * 結果：成功レスポンスが返却されること
   */
  @Test
  public void test_getNotificationMessageAll_正常() {
    // arrange
    final Long userId = 1L;
    final List<NotificationMessage> messages = Arrays.asList(
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
    final List<MstUser.SettingValue> settingValues = Arrays.asList(
      new MstUser.SettingValue() {
        {
          setSettingId(NotificationListResponse.SETTING_IDENTIFIER_READ_ON_JUMP);
          setSettingValue("9");
        }
      }
    );
    final int unreadCount = 99;

    NotificationListResponse expected = new NotificationListResponse(messages, "9", unreadCount);

    // mock(通知メッセージ取得)
    final ArgumentCaptor<Long> captor1_1 = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<String> captor1_2 = ArgumentCaptor.forClass(String.class);
    final ArgumentCaptor<Boolean> captor1_3 = ArgumentCaptor.forClass(Boolean.class);
    given(mntNotificationMessageDao.selectByUserId(captor1_1.capture(), captor1_2.capture(), captor1_3.capture())).willReturn(messages);

    // mock(利用者マスタ取得)
    final ArgumentCaptor<Long> captor2_1 = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<Integer> captor2_2 = ArgumentCaptor.forClass(Integer.class);
    given(userSettingsService.getPersonalSettings(captor2_1.capture(), captor2_2.capture())).willReturn(settingValues);

    // mock(未読件数取得)
    final ArgumentCaptor<Long> captor3_1 = ArgumentCaptor.forClass(Long.class);
    given(mntNotificationStatusDao.selectUnreadCountByUserId(captor3_1.capture())).willReturn(unreadCount);

    // action
    NotificationListResponse response = target.getNotificationMessageAll(userId);

    // assert(通知メッセージ取得)
    verify(mntNotificationMessageDao, times(1)).selectByUserId(anyLong(), any(), anyBoolean());
    assertThat(captor1_1.getValue(), is(userId));
    assertThat(captor1_2.getValue(), nullValue());
    assertThat(captor1_3.getValue(), is(true));

    // assert(利用者マスタ取得)
    verify(userSettingsService, times(1)).getPersonalSettings(anyLong(), anyInt());
    assertThat(captor2_1.getValue(), is(userId));
    assertThat(captor2_2.getValue(), is(NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE));

    // assert(未読件数取得)
    verify(mntNotificationStatusDao, times(1)).selectUnreadCountByUserId(anyLong());
    assertThat(captor3_1.getValue(), is(userId));

    // assert(response)
    assertThat(response, is(samePropertyValuesAs(expected)));
  }

  /**
   * updateReadStatus()の検証.
   *
   * 条件：なし
   * 結果：既読フラグの更新ができること
   */
  @Test
  public void test_updateReadStatus_成功_既読フラグの更新ができること() {
    // arrange
    List<Long> notificationMessageNos = Arrays.asList(1L, 2L, 4L);
    int updateCount = 3;
    Long userId = 1L;
    String isRead = "1";
    final String facilityCd = "000001";
    ReadStatusRequest request = new ReadStatusRequest() {
      {
        setNotificationMessageNos(notificationMessageNos);
        setIsRead(isRead);
      }
    };

    final ArgumentCaptor<List<Long>> captor1 = ArgumentCaptor.forClass(List.class);
    final ArgumentCaptor<Long> captor2 = ArgumentCaptor.forClass(Long.class);
    final ArgumentCaptor<String> captor3 = ArgumentCaptor.forClass(String.class);
    given(mntNotificationStatusDao.updateIsRead(captor1.capture(),captor2.capture(), captor3.capture()))
      .willReturn(updateCount);

    // action
    target.updateReadStatus(request, userId, facilityCd);

    // assert
    verify(mntNotificationStatusDao, times(1)).updateIsRead(any(), anyLong(), anyString());
    assertThat(captor1.getValue(), is(notificationMessageNos));
    assertThat(captor2.getValue(), is(userId));
    assertThat(captor3.getValue(), is(isRead));
  }

  /**
   * getUnreadCount()の検証.
   *
   * 条件：なし
   * 結果：未読件数が取得ができること
   */
  @Test
  public void test_getUnreadCount_成功_未読件数が取得ができること() {
    // arrange
    int unreadCount = 2;
    Long userId = 1L;

    final ArgumentCaptor<Long> captor = ArgumentCaptor.forClass(Long.class);
    given(mntNotificationStatusDao.selectUnreadCountByUserId(captor.capture())).willReturn(unreadCount);

    // action
    UnreadCountResponse result = target.getUnreadCount(userId);

    // assert
    assertThat(result.getUnreadCnt(), is(unreadCount));

    verify(mntNotificationStatusDao, times(1)).selectUnreadCountByUserId(any());
    assertThat(captor.getValue(), is(userId));
  }

}
