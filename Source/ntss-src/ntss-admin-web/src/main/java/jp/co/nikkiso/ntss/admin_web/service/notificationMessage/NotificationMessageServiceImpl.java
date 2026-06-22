package jp.co.nikkiso.ntss.admin_web.service.notificationMessage;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.ReadStatusRequest;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.NotificationListResponse;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.UnreadCountResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.admin_web.service.userSettings.UserSettingsService;
import jp.co.nikkiso.ntss.core.dao.MntNotificationMessageDao;
import jp.co.nikkiso.ntss.core.dao.MntNotificationStatusDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MntNotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MntNotificationStatus;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
// add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
import org.json.JSONObject;
// add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

/**
 * 通知一覧のService実装クラス.
 */
@Service
public class NotificationMessageServiceImpl implements NotificationMessageService {

  /**
   * WebSocket通知Service.
   */
  @Autowired
  private WebSocketNotifyService webSocketNofityService;

  /**
   * ユーザー設定のServiceインタフェース.
   */
  @Autowired
  private UserSettingsService userSettingsService;

  /**
   * 通知メッセージのDaoインタフェース.
   */
  @Autowired
  private MntNotificationMessageDao mntNotificationMessageDao;

  /**
   * 通知状態管理のDaoインタフェース.
   */
  @Autowired
  private MntNotificationStatusDao mntNotificationStatusDao;

  /**
   * 利用者マスタ(認証DB)のDaoインタフェース.
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
  /**
   * 患者情報Daoインタフェース.
   */
  @Autowired
  private PatMainDao patMainDao;
  // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  //DB更新ログ出力ロジック wp end 20210128

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public Long registerNotificationMessage(String content, List<Long> recipients, String additionalInfo, String facilityCd) {

    // 通知メッセージを登録する
    Long notificationMessageNo = registerNotificationMessage(content, additionalInfo, facilityCd);

    // 通知状態を登録する
    registerNotificationStatus(notificationMessageNo, recipients, facilityCd);

    // 通知メッセージを削除する
    deleteNotificationMessage();

    return notificationMessageNo;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void notifyNotificationMessage(Long notificationMessageNo, List<Long> recipients) {
    mstUserAuthenticationDao.selectFacilityCdByUserId(recipients).stream()
      .forEach(facilityCd -> {
        final String topic = String.format("%s/%s", AdminWebConstant.WebSocketTopic.NOTIFICATION_MESSAGE, facilityCd);
        webSocketNofityService.sendMsg(SendTarget.browser, facilityCd, null, topic, notificationMessageNo.toString());
      });
  }

  /**
   * 通知メッセージを登録します.
   *
   * @param content        メッセージ本文
   * @param additionalInfo 付加情報
   * @return 通知メッセージ番号
   */
  private Long registerNotificationMessage(String content, String additionalInfo, String facilityCd) {
    // 通知メッセージを登録する
    MntNotificationMessage entity = new MntNotificationMessage() {
      {
        setContent(content);
        setAdditionalInfo(additionalInfo);
        setFacilityCd(facilityCd);
      }
    };
    mntNotificationMessageDao.insert(entity);

    // 通知メッセージ番号を返却する
    return entity.getNotificationMessageNo();
  }

  /**
   * 通知状態管理を登録します.
   *
   * @param notificationMessageNo 通知メッセージ番号
   * @param recipients            ユーザーIDのリスト
   */
  private void registerNotificationStatus(Long notificationMessageNo, List<Long> recipients, String facilityCd) {
    // 通知状態管理を登録する
    List<MntNotificationStatus> entities = recipients.stream()
      .map(recipient -> new MntNotificationStatus() {
        {
          setNotificationMessageNo(notificationMessageNo);
          setUserId(recipient);
          setFacilityCd(facilityCd);
        }
      })
      .collect(Collectors.toList());
    mntNotificationStatusDao.insert(entities);
  }

  /**
   * 通知メッセージを削除します.
   */
  private void deleteNotificationMessage() {
    // 通知メッセージを削除する
    LocalDate localDate = LocalDate.now().plusMonths(-3L);
    Timestamp timestamp = Timestamp.valueOf(localDate.atStartOfDay());
    mntNotificationMessageDao.delete(timestamp);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
  public NotificationListResponse getNotificationMessage(Long userId, String facilityCd) {
  // public NotificationListResponse getNotificationMessage(Long userId) {
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end
    // 通知メッセージ情報を取得する
    // mod FNSI-当施設の操作通知は別施設に表示を修正 江 start
    //NotificationListResponse response = getNotificationMessage(userId, MntNotificationStatus.IS_NOT_NOTIFIED, false);
    NotificationListResponse response = getNotificationMessage(userId, MntNotificationStatus.IS_NOT_NOTIFIED, false,null);
    // mod FNSI-当施設の操作通知は別施設に表示を修正 江 end

    // 通知済フラグを更新する
    List<Long> notificationMessageNos = response.getNotificationList().stream()
      .map(n -> n.getNotificationMessageNo())
      .collect(Collectors.toList())
      ;

    //DB更新ログ出力ロジック wp start

    String mmsTbN = "mnt_notification_status";

    // SQL検索条件
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
    StringBuffer wheres = getSql(userId,notificationMessageNos, facilityCd);
    // StringBuffer wheres = getSql(userId,notificationMessageNos);
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

    // logCommon設定
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //DB更新ログ出力ロジック wp end
    int ret = mntNotificationStatusDao.updateIsNotified(notificationMessageNos, userId, MntNotificationStatus.IS_NOTIFIED);
    //DB更新ログ出力ロジック wp start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    //DB更新ログ出力ロジック wp end

    return response;
  }

  // add FNSI-当施設の操作通知は別施設に表示を修正 江 start
  /**
   * {@inheritDoc}
   */
  @Override
  public NotificationListResponse getNotificationMessageList(Long userId, String facilityCd) {
    // 通知メッセージ情報を取得する
    NotificationListResponse response = getNotificationMessage(userId, MntNotificationStatus.IS_NOT_NOTIFIED, false, facilityCd);

    // 通知済フラグを更新する
    List<Long> notificationMessageNos = response.getNotificationList().stream()
      // del FNSi7119サインイン時クール・ベッド未登録通知の内容が最新でない 周 start
      // add TEST FNSi6531通知が重複して行われる 周 start
//      .filter(n -> (n.getNotificationNo() != CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET
//        && n.getNotificationNo() != CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET))
      // add TEST FNSi6531通知が重複して行われる 周 end
      // del FNSi7119サインイン時クール・ベッド未登録通知の内容が最新でない 周 end
      .map(n -> n.getNotificationMessageNo())
      .collect(Collectors.toList())
      ;

    //DB更新ログ出力ロジック wp start

    String mmsTbN = "mnt_notification_status";

    // SQL検索条件
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
    StringBuffer wheres = getSql(userId, notificationMessageNos, facilityCd);
    // StringBuffer wheres = getSql(userId, notificationMessageNos);
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

    // logCommon設定
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //DB更新ログ出力ロジック wp end
    int ret = mntNotificationStatusDao.updateIsNotified(notificationMessageNos, userId, MntNotificationStatus.IS_NOTIFIED);
    //DB更新ログ出力ロジック wp start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    //DB更新ログ出力ロジック wp end

    return response;
  }
  // add FNSI-当施設の操作通知は別施設に表示を修正 江 end

  /**
   * {@inheritDoc}
   */
  @Override
  public NotificationListResponse getNotificationMessageAll(Long userId) {
    // mod FNSI-当施設の操作通知は別施設に表示を修正 江 start
    //return getNotificationMessage(userId, null, true);
    return getNotificationMessage(userId, null, true,null);
    // mod FNSI-当施設の操作通知は別施設に表示を修正 江 end
  }

  //add FNSI-通知表示が遅いを修正 江 start
  /**
   * {@inheritDoc}
   */
  @Override
  public NotificationListResponse getNotificationMessageAll(Long userId, String facilityCd, Integer offset) {
    return getNotificationMessage(userId, null, true, offset, facilityCd);
  }
  //add FNSI-通知表示が遅いを修正 江 end

  // del #10110 通知一覧から既読にした通知以外も消える dengshen start
  // // add FNSI redmine 4893 修正 鄧シン start
  // /**
  //  * {@inheritDoc}
  //  */
  // @Override
  // public NotificationListResponse getNotificationMessageAllAfterChange(Long userId, String facilityCd, Integer offset) {
  //   return getNotificationMessageAfterChange(userId, null, true, offset, facilityCd);
  // }
  // // add FNSI redmine 4893 修正 鄧シン end
  // del #10110 通知一覧から既読にした通知以外も消える dengshen end

  /**
   * 通知メッセージ情報を取得します.
   *
   * @param userId ユーザーID
   * @param isNotified 通知済フラグ
   * @param isDesc 登録日時の降順で取得するかどうか(<code>true</code>の場合、降順、それ以外の場合、昇順)
   * @return 通知メッセージ情報
   */
  private NotificationListResponse getNotificationMessage(Long userId, String isNotified, boolean isDesc, String facilityCd) {

    // 通知メッセージを取得する
    //mod FNSI-「通知トーストに重要通知である旨が表示されない」の不具合修正　江 start
    //List<NotificationMessage> messages = mntNotificationMessageDao.selectByUserId(userId, isNotified, isDesc);
    List<MstUser.SettingValue> settingImportant=userSettingsService.getPersonalSettings(userId, NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE);
    List<Integer> notificationNoList = new ArrayList<Integer>();
    notificationNoList.add(0);
    for (int i = 0; i < settingImportant.size(); i++) {
      if(settingImportant.get(i).getSettingImportant() != null){
        if(Boolean.parseBoolean(settingImportant.get(i).getSettingImportant().toString()) == true){
          notificationNoList.add(Integer.parseInt(settingImportant.get(i).getSettingId().toString()));
        }
      }
    };
    // 通知メッセージを取得する
    List<NotificationMessage> messages = mntNotificationMessageDao.selectNotificationMessageByUserId(userId, isNotified, isDesc, notificationNoList, null, facilityCd);
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
    messages.forEach( message -> {
      try{
        JSONObject parseObject = new JSONObject(message.getAdditionalInfo());
        Long patId = Long.parseLong(parseObject.getString("PATID"));
        // 対象患者のアレルギー情報を取得
        PatMain patMain = patMainDao.selectById(patId);
        message.setIsSame(patMain.getIs_same());
      }
      catch(Exception e) {
        return;
      }
    });
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end
    //mod FNSI-「通知トーストに重要通知である旨が表示されない」の不具合修正　江 end

    // 個人設定(通知メッセージジャンプで既読)を取得する
    MstUser.SettingValue settingValue = userSettingsService
      .getPersonalSettings(userId, NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE)
      .stream()
      .filter(p -> NotificationListResponse.SETTING_IDENTIFIER_READ_ON_JUMP.equals(p.getSettingId()))
      .findFirst()
      .orElse(null);
    String readOnJump = settingValue != null ? settingValue.getSettingValue().toString() : NotificationListResponse.READ_ON_JUMP_NO;

    // 未読件数を取得する
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 start
    Integer unreadCnt = mntNotificationStatusDao.selectUnreadCountByUserIdAndFacilityCd(userId, facilityCd);
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 end

    return new NotificationListResponse(messages, readOnJump, unreadCnt);
  }

  //add FNSI-通知表示が遅いを修正 江 start
  /**
   * 通知メッセージ情報を取得します.
   *
   * @param userId ユーザーID
   * @param isNotified 通知済フラグ
   * @param isDesc 登録日時の降順で取得するかどうか(<code>true</code>の場合、降順、それ以外の場合、昇順)
   * @param offset スキップ行数
   * @return 通知メッセージ情報
   */
  private NotificationListResponse getNotificationMessage(Long userId, String isNotified, boolean isDesc, Integer offset, String facilityCd) {

    // 個人設定(通知メッセージジャンプで既読)を取得する
    MstUser.SettingValue settingValue = userSettingsService
      .getPersonalSettings(userId, NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE)
      .stream()
      .filter(p -> NotificationListResponse.SETTING_IDENTIFIER_READ_ON_JUMP.equals(p.getSettingId()))
      .findFirst()
      .orElse(null);
    String readOnJump = settingValue != null ? settingValue.getSettingValue().toString() : NotificationListResponse.READ_ON_JUMP_NO;

    List<MstUser.SettingValue> settingImportant=userSettingsService.getPersonalSettings(userId, NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE);
    List<Integer> notificationNoList = new ArrayList<Integer>();
    notificationNoList.add(0);
    for (int i = 0; i < settingImportant.size(); i++) {
      if(settingImportant.get(i).getSettingImportant() != null){
        if(Boolean.parseBoolean(settingImportant.get(i).getSettingImportant().toString()) == true){
          notificationNoList.add(Integer.parseInt(settingImportant.get(i).getSettingId().toString()));
        }
      }
    };
    // 通知メッセージを取得する
//    // mod FNSi6969-通知一覧の追加読み込みが行われない 周 start
//    Integer totalUnreadCnt = mntNotificationStatusDao.selectUnreadCountByUserIdAndFacilityCd(userId, facilityCd);
//    List<NotificationMessage> messages = new ArrayList<>();
//    if(0 == offset) {
//      int gotUnreadCnt = 0;
//      while (gotUnreadCnt < totalUnreadCnt && gotUnreadCnt < 100) {
//        List<NotificationMessage> messagesOneTime = mntNotificationMessageDao.selectNotificationMessageByUserId(userId,
//          isNotified, isDesc, notificationNoList, offset, facilityCd);
//        messages.addAll(messagesOneTime);
//        gotUnreadCnt += (int)(messagesOneTime.stream().filter(msg -> 0 == "0".compareTo(msg.getIsRead())).count());
//        offset += messagesOneTime.size();
//      }
//    } else {
//      messages = mntNotificationMessageDao.selectNotificationMessageByUserId(userId,
//        isNotified, isDesc, notificationNoList, offset, facilityCd);
//    }
//
//    // mod FNSi6969-通知一覧の追加読み込みが行われない 周 end
    List<NotificationMessage> messages = mntNotificationMessageDao.selectNotificationMessageByUserId(userId, isNotified, isDesc, notificationNoList, offset, facilityCd);
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
    // del bug 8158 修正 chen start
    // add 5695通知一覧の表示順不正 周 start
    // List<NotificationMessage> unReadImportantList = new ArrayList<>();
    // List<NotificationMessage> otherList = new ArrayList<>();
    // add 5695通知一覧の表示順不正 周 end
    // del bug 8158 修正 chen end

    // add #10110 通知一覧から既読にした通知以外も消える dengshen start
    List<Long> patIdLst = new ArrayList<>();
    // add #10110 通知一覧から既読にした通知以外も消える dengshen end

    messages.forEach( message -> {
      try{
        //add FNSI6143メーカー通知で正常に通知しない 周 start
        if(null != message.getAdditionalInfo()) {
        //add FNSI6143メーカー通知で正常に通知しない 周 end
          JSONObject parseObject = new JSONObject(message.getAdditionalInfo());
          // add 5695通知一覧の表示順不正 周 start
          // mod 2022-06-14 5607連動機能の実装確認 修正 李 start
          if (parseObject.has("PATID") && parseObject.getString("PATID").equals("") == false) {
          // mod 2022-06-14 5607連動機能の実装確認 修正 李 end
            // add 5695通知一覧の表示順不正 周 end

            // mod #10110 通知一覧から既読にした通知以外も消える dengshen start
            // Long patId = Long.parseLong(parseObject.getString("PATID"));
            // // 対象患者のアレルギー情報を取得
            // PatMain patMain = patMainDao.selectById(patId);
            //
            // if (patMain != null) {
            //   message.setIsSame(patMain.getIs_same());
            // }
            Long patId = Long.parseLong(parseObject.getString("PATID"));
            patIdLst.add(patId);
            // mod #10110 通知一覧から既読にした通知以外も消える dengshen end

            // add 5695通知一覧の表示順不正 周 start
          }
        //add FNSI6143メーカー通知で正常に通知しない 周 start
        }
        //add FNSI6143メーカー通知で正常に通知しない 周 end

        // del bug 8158 修正 chen start
        // if("0".equals(message.getIsRead()) && "1".equals(message.getIsImportant())) {
        //   unReadImportantList.add(message);
        // } else {
        //   otherList.add(message);
        // }
        // del bug 8158 修正 chen end
        // add 5695通知一覧の表示順不正 周 end
      }
      catch(Exception e) {
        return;
      }
    });
    // del bug 8158 修正 chen start
    // add 5695通知一覧の表示順不正 周 start
    // messages = unReadImportantList;
    // messages.addAll(otherList);
    // add 5695通知一覧の表示順不正 周 end
    // del bug 8158 修正 chen end
    // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end

    // add #10110 通知一覧から既読にした通知以外も消える dengshen start
    List<PatMain> patMains = patMainDao.selectByIdList(patIdLst.stream().filter(Objects::nonNull).distinct().collect(Collectors.toList()));
    messages.forEach( message -> {
      try{
        if(null != message.getAdditionalInfo()) {
          JSONObject parseObject = new JSONObject(message.getAdditionalInfo());
          if (parseObject.has("PATID") && parseObject.getString("PATID").equals("") == false) {

            Long patId = Long.parseLong(parseObject.getString("PATID"));
            // 対象患者のアレルギー情報を取得
            List<PatMain> patMain = patMains.stream().filter(item -> patId.equals(item.getPat_id())).collect(Collectors.toList());

            if (patMain != null && patMain.size() != 0) {
              message.setIsSame(patMain.get(0).getIs_same());
            }

          }
        }
      }
      catch(Exception e) {
        return;
      }
    });
    // add #10110 通知一覧から既読にした通知以外も消える dengshen end

    // 未読件数を取得する
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 start
    Integer unreadCnt = mntNotificationStatusDao.selectUnreadCountByUserIdAndFacilityCd(userId, facilityCd);
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 end

    return new NotificationListResponse(messages, readOnJump, unreadCnt);
  }
  //add FNSI-通知表示が遅いを修正 江 end

  // del #10110 通知一覧から既読にした通知以外も消える dengshen start
  // //add FNSI redmine 4893 修正 鄧シン start
  // /**
  //  * 変更後通知メッセージ情報を取得します.
  //  *
  //  * @param userId ユーザーID
  //  * @param isNotified 通知済フラグ
  //  * @param isDesc 登録日時の降順で取得するかどうか(<code>true</code>の場合、降順、それ以外の場合、昇順)
  //  * @param offset 通知行数
  //  * @return 通知メッセージ情報
  //  */
  // private NotificationListResponse getNotificationMessageAfterChange(Long userId, String isNotified, boolean isDesc, Integer offset, String facilityCd) {
  //
  //   // 個人設定(通知メッセージジャンプで既読)を取得する
  //   MstUser.SettingValue settingValue = userSettingsService
  //     .getPersonalSettings(userId, NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE)
  //     .stream()
  //     .filter(p -> NotificationListResponse.SETTING_IDENTIFIER_READ_ON_JUMP.equals(p.getSettingId()))
  //     .findFirst()
  //     .orElse(null);
  //   String readOnJump = settingValue != null ? settingValue.getSettingValue().toString() : NotificationListResponse.READ_ON_JUMP_NO;
  //
  //   List<MstUser.SettingValue> settingImportant=userSettingsService.getPersonalSettings(userId, NotificationListResponse.TAB_DEFINE_CD_NOTIFICATION_MESSAGE);
  //   List<Integer> notificationNoList = new ArrayList<Integer>();
  //   notificationNoList.add(0);
  //   for (int i = 0; i < settingImportant.size(); i++) {
  //     if(settingImportant.get(i).getSettingImportant() != null){
  //       if(Boolean.parseBoolean(settingImportant.get(i).getSettingImportant().toString()) == true){
  //         notificationNoList.add(Integer.parseInt(settingImportant.get(i).getSettingId().toString()));
  //       }
  //     }
  //   };
  //   // 通知メッセージを取得する
  //   List<NotificationMessage> messages = mntNotificationMessageDao.selectNotificationMessageAfterChangeByUserId(userId, isNotified, isDesc, notificationNoList, offset, facilityCd);
  //   // add 5695通知一覧の表示順不正 周 start
  //   List<NotificationMessage> unReadImportantList = new ArrayList<>();
  //   List<NotificationMessage> otherList = new ArrayList<>();
  //   // add 5695通知一覧の表示順不正 周 end
  //   messages.forEach( message -> {
  //     try{
  //       // mod 5695通知一覧の表示順不正 周 start
  //       if(null != message.getAdditionalInfo()) {
  //         JSONObject parseObject = new JSONObject(message.getAdditionalInfo());
  //         // add 5695通知一覧の表示順不正 周 start
  //         if(parseObject.has("PATID")) {
  //           // add 5695通知一覧の表示順不正 周 end
  //           Long patId = Long.parseLong(parseObject.getString("PATID"));
  //           // 対象患者のアレルギー情報を取得
  //           PatMain patMain = patMainDao.selectById(patId);
  //           message.setIsSame(patMain.getIs_same());
  //
  //           // add 5695通知一覧の表示順不正 周 start
  //         }
  //       }
  //       // mod 5695通知一覧の表示順不正 周 end
  //
  //       if("0".equals(message.getIsRead()) && "1".equals(message.getIsImportant())) {
  //         unReadImportantList.add(message);
  //       } else {
  //         otherList.add(message);
  //       }
  //       // add 5695通知一覧の表示順不正 周 end
  //     }
  //     catch(Exception e) {
  //       return;
  //     }
  //   });
  //   // add 5695通知一覧の表示順不正 周 start
  //   messages = unReadImportantList;
  //   messages.addAll(otherList);
  //   // add 5695通知一覧の表示順不正 周 end
  //
  //   // 未読件数を取得する
  //   Integer unreadCnt = mntNotificationStatusDao.selectUnreadCountByUserIdAndFacilityCd(userId, facilityCd);
  //
  //   return new NotificationListResponse(messages, readOnJump, unreadCnt);
  // }
  // //add FNSI redmine 4893 修正 鄧シン end
  // del #10110 通知一覧から既読にした通知以外も消える dengshen end

  // add FNSI-通知既読更新を修正 江 start
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void updateIsReadStatus(Long userId) {

    // mod 性能の改善 鄧シン start
//    String mmsTbN = "mnt_notification_status";
//
//    // SQL検索条件
//    StringBuffer sql = new StringBuffer("");
//    sql.append("  where user_id = " + userId);
//    StringBuffer wheres = sql;
//
//    // logCommon設定
//    DataUpdateLogCommonNew logCommon = getLogCommon(mntNotificationStatusDao, mmsTbN, wheres, getEventLogMessage());
//    // ログ出力カラム情報及び更新前データ情報取得
//    boolean setResult = logCommon.setInfo();
//
//    // 既読フラグの更新
//    int ret = mntNotificationStatusDao.updateAllIsRead(userId);
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && ret > 0) {
//      logCommon.updateLog();
//    }
    mntNotificationStatusDao.updateAllIsRead(userId);
    // mod 性能の改善 鄧シン　end

  }
  // add FNSI-通知既読更新を修正 江 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
  // public void updateReadStatus(ReadStatusRequest request, Long userId) {
  public void updateReadStatus(ReadStatusRequest request, Long userId, String facilityCd) {
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end


    //FNSI-修正 ログ対応 wp add start

    String mmsTbN = "mnt_notification_status";

    // SQL検索条件
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
    StringBuffer wheres = getSql(userId,request.getNotificationMessageNos(), facilityCd);
    // StringBuffer wheres = getSql(userId,request.getNotificationMessageNos());
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

    // logCommon設定
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    //FNSI-修正 ログ対応 wp add end
    // 既読フラグの更新

    int ret = mntNotificationStatusDao.updateIsRead(request.getNotificationMessageNos(), userId, request.getIsRead());
    //FNSI-修正 ログ対応 wp add start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    //FNSI-修正 ログ対応 wp add

    //FNSI-修正 ログ対応 wp add end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public UnreadCountResponse getUnreadCount(Long userId) {
    UnreadCountResponse response = new UnreadCountResponse(mntNotificationStatusDao.selectUnreadCountByUserId(userId));
    return response;
  }

  //addd FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 start
  /**
   * {@inheritDoc}
   */
  @Override
  public UnreadCountResponse getUnreadCountByFacilityCd(Long userId, String facilityCd) {
    UnreadCountResponse response = new UnreadCountResponse(mntNotificationStatusDao.selectUnreadCountByUserIdAndFacilityCd(userId, facilityCd));
    return response;
  }
  //addd FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 end
  //FNSI-修正 ログ対応 wp add start

  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  /**
   * 検索SQL

   */
  // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
  //private StringBuffer getSql(Long userid , List<Long> codeList){
  private StringBuffer getSql(Long userid, List<Long> codeList, String facilityCd){
    // FNSI-修正 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
    StringBuffer sql = new StringBuffer("");
    sql.append("  where user_id = " + userid);
    sql.append("  and facility_cd = '" + facilityCd + "'");
    sql.append("  and is_read = '0' ");
    // FNSI-修正 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

    if (codeList.size() == 0){
      return  sql;
    }

    StringBuffer code = new StringBuffer("");
    code.append(" ( ");
    for (Long no : codeList) {
      code.append( no);
      code.append(" ,");
    }
    code.deleteCharAt(code.length() - 1);
    code.append(" ) ");
    sql.append("  and notification_message_no in  " + code.toString());

    return sql;
  }

  //FNSI-修正 ログ対応 wp add end

}
