package jp.co.nikkiso.ntss.web_api.service;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.SysNotificationDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.SysNotification;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.request.RecipientsRequest;
import jp.co.nikkiso.ntss.web_api.service.fileIO.FileIOService;
import jp.co.nikkiso.ntss.web_api.service.notification.NotificationService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class NotificationBatchServiceImpl implements NotificationBatchService {
  @Autowired
  private NotificationService notificationService;
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  private SysNotificationDao sysNotificationDao;
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;
  @Autowired
  private FileIOService fileIOSv;
  @Autowired
  private LogService logService;

  @Override
  public ResponseEntity<?> genericNotificationsReceiver(String request) {

    Integer tabDefineCd = 8;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to register notification message");
    this.logService.log(LogLevel.DEBUG, eventLogMessage, null, "FNSi", null);

    JSONArray requestJsonArray = new JSONArray(request);
    BatchRequest batchReq = new BatchRequest();

    for(int i = 0; i < requestJsonArray.length(); ++i) {
      BatchRequest.Notification notification = new BatchRequest.Notification();
      JSONObject requestJson = requestJsonArray.getJSONObject(i);

      try {
        notification.notificationNo = requestJson.getLong("notificationNo");
        // 置換データはBase64デコード(UTF-8)
        String strReplaceData = requestJson.has("replaceData") ?
          new String(Base64.getDecoder().decode(requestJson.getString("replaceData")), StandardCharsets.UTF_8) : null;
        JSONObject replaceJson = new JSONObject(strReplaceData);
        replaceJson.keySet().forEach((key) -> {
          notification.replaceData.put(key, replaceJson.getString(key));
        });
        String facilityCode = requestJson.getString("facilityCd");
        if ("nkknkk".equals(facilityCode)) {
          notification.toAll = true;
        } else {
          notification.facilityCode = facilityCode;
        }

        eventLogMessage.setFacilityCd(notification.facilityCode);

        // 特定ユーザーのみに通知する設定のフラグ
        // 通知対象のユーザーIDはreplaceData内の"USERID"キーに入れておく
        Boolean isOnlySpecificUser =
          notification.notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET) ||
            notification.notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET) ||
            //5794 add 担当者に設定された際の通知が関係のないユーザーに発生する 関俊楠 start
            notification.notificationNo.equals(CoreConstant.NotificationDefinition.SET_CHARGE_STAFF);
        //5794 add 担当者に設定された際の通知が関係のないユーザーに発生する 関俊楠 end
        Long specificUserId = 0L;
        if (isOnlySpecificUser) {
          notification.userId = Long.parseLong(replaceJson.getString("USERID"));
        }
        batchReq.notifications.add(notification);
      } catch (Exception e) {
        eventLogMessage.setLogMessage("JSONの値取得に失敗しました。");
        this.logService.log(LogLevel.ERROR, eventLogMessage, null, "FNSi", null);
        return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
      }
    }

    if (batchReq.notifications.isEmpty()) {
      return new ResponseEntity<>(null, HttpStatus.OK);
    }

    if (batchReq.hasGlobal()) {
      this.mstPersonalUserDao.selectAllUserIdAndFacilityCd().forEach((u) -> {
        BatchRequest.UserBasic user = new BatchRequest.UserBasic();
        user.userId = u.getUserId();
        user.facilityCode = u.getFacilityCd();
        batchReq.allUsers.add(user);
      });
      batchReq.userSettingsMap = this.notificationService.getAllPersonalSettings(tabDefineCd);
      batchReq.facilityHashes = this.mstFacilityHashDao.selectAll();
    } else {
      List<String> facilityCodes = batchReq.getAllFacilityCodes();
      if (!facilityCodes.isEmpty()) {
        this.mstPersonalUserDao.selectUserIdByFacilityCodeList(facilityCodes).forEach((u) -> {
          BatchRequest.UserBasic user = new BatchRequest.UserBasic();
          user.userId = u.getUserId();
          user.facilityCode = u.getFacilityCd();
          batchReq.allUsers.add(user);
        });
        Map<Long, List<MstUser.SettingValue>> userSettingsMap = this.notificationService.getPersonalSettingsByFacilityCdList(facilityCodes, tabDefineCd);
        batchReq.userSettingsMap.putAll(userSettingsMap);
        batchReq.facilityHashes = this.mstFacilityHashDao.selectByFacilityCdList(facilityCodes);
      }

      List<Long> userIds = batchReq.getAllUserId();
      List<Long> existUserIds = batchReq.allUsers.stream().map((u) -> u.userId).collect(Collectors.toList());
      List<Long> otherUserIds = userIds.stream().filter((u) -> !existUserIds.contains(u)).collect(Collectors.toList());

      if (!otherUserIds.isEmpty()) {
        this.mstPersonalUserDao.selectByIdList(otherUserIds).forEach((u) -> {
          BatchRequest.UserBasic user = new BatchRequest.UserBasic();
          user.userId = u.getUserId();
          user.facilityCode = u.getFacilityCd();
          batchReq.allUsers.add(user);
        });
        Map<Long, List<MstUser.SettingValue>> userSettingsMap = this.notificationService.getPersonalSettingsByUserIds(otherUserIds, tabDefineCd);
        batchReq.userSettingsMap.putAll(userSettingsMap);
      }
    }

    List<SysNotification> sysNotifications = this.sysNotificationDao.selectByCdList(batchReq.getAllNotificationNums());

    List<NotificationService.NotificationMessage> notificationMessages = new ArrayList<>();

    for (int i = 0; i < batchReq.notifications.size(); i++) {
      NotificationService.NotificationMessage notificationMessage = new NotificationService.NotificationMessage();
      List<RecipientsRequest> recipientsReqList = new ArrayList<>();
      BatchRequest.Notification notification = batchReq.notifications.get(i);
      String facilityCode = notification.facilityCode;
      Long notificationNo = notification.notificationNo;
      SysNotification sysNotification = sysNotifications.stream().filter((n) -> n.getNotificationNo().equals(notification.notificationNo)).findFirst().orElse(null);
      if (sysNotification == null) {
        continue;
      }
      // 正規表現の抽出
      Pattern pattern = Pattern.compile("\\[(.*?)\\]");
      Matcher keysInMessage = pattern.matcher(sysNotification.getMessage());
      Matcher keysInInfo = pattern.matcher(sysNotification.getAdditionalInfo());

      // 置換処理
      String replacedContent = sysNotification.getMessage();
      String replacedAdditionalInfo = sysNotification.getAdditionalInfo();

      while (keysInMessage.find()) {
        String matchStr = keysInMessage.group();
        String matchKey = matchStr.replace("[", "").replace("]", "");
        try {
          replacedContent = replacedContent.replace(matchStr, notification.replaceData.get(matchKey));
        } catch (Exception e) {
          // 置換処理に失敗した場合はBad Requestを返す
          eventLogMessage.setLogMessage("メッセージ定義の置換処理に失敗しました。");
          logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,null);
          return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
      }

      while (keysInInfo.find()) {
        String matchStr = keysInInfo.group();
        String matchKey = matchStr.replace("[", "").replace("]", "");
        try {
          replacedAdditionalInfo = replacedAdditionalInfo.replace(matchStr, notification.replaceData.get(matchKey));
        } catch (Exception e) {
          // 置換処理に失敗した場合はBad Requestを返す
          eventLogMessage.setLogMessage("付加情報定義の置換処理に失敗しました。");
          logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,null);
          return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
      }

      notification.replacedContent = replacedContent;

      List<BatchRequest.UserBasic> recipients;
      if (notification.userId != null) {
        recipients = batchReq.allUsers.stream().filter((u) -> u.userId.equals(notification.userId)).collect(Collectors.toList());
      } else if (notification.toAll) {
        recipients = batchReq.allUsers;
      } else {
        recipients = batchReq.allUsers.stream().filter((u) -> notification.facilityCode.equals(u.facilityCode)).collect(Collectors.toList());
      }

      MstFacilityHash mstFacilityHash = batchReq.facilityHashes.stream().filter((f) -> f.getFacilityCd().equals(facilityCode)).findFirst().orElse(null);

      if (mstFacilityHash == null) {
        continue;
      }

      recipients.forEach((u) -> {
//        RecipientsRequest recipientsReq = new RecipientsRequest();
//        recipientsReq.setUserId(u.userId);
//        recipientsReq.setFacilityCd(u.facilityCode);
//        recipientsReq.setSystemUseSetting(mstFacilityHash.getSystemUseSetting());
//        recipientsReqList.add(recipientsReq);

        // add bug 6522 修正 chen start
        // if (isOnlySpecificUser) {
        //   List<MntNotificationMessage> MntNotificationMessage = notificationService.hasNotificationMessage(
        //     replacedContent, userData.getUserId(), replacedAdditionalInfo, facilityCd, notificationNo);
        //   if (MntNotificationMessage != null && MntNotificationMessage.size() > 0) {
        //     continue;
        //   }
        // }
        // add bug 6522 修正 chen end
        // 通知処理改善対応 毛 Add
        boolean isTargetSetting;
        boolean isNotificationOn;
        // 登録されている全利用者を取得する

        List<MstUser.SettingValue> userSettings = batchReq.userSettingsMap.get(u.userId);
        // 対象の通知定義がONになっているユーザーをリストに追加する
        if (userSettings.size() > 0) {
          for (MstUser.SettingValue setting : userSettings) {
            // 通知処理改善対応 毛
            try {
              isTargetSetting = notificationNo.equals(Long.parseLong(setting.getSettingId()));
              isNotificationOn = "true".equals(setting.getSettingValue().toString());
              if (isTargetSetting && isNotificationOn) {
                RecipientsRequest recipientsData = new RecipientsRequest();
                recipientsData.setUserId(u.userId);
                recipientsData.setFacilityCd(u.facilityCode);
                recipientsData.setSystemUseSetting(mstFacilityHash.getSystemUseSetting());
                recipientsReqList.add(recipientsData);
                notification.toUserIds.add(u.userId);
              }
            } catch (Exception e) {
              eventLogMessage.setFacilityCd(u.facilityCode);
              eventLogMessage.setLogMessage("対象ユーザーに送信失敗：" + u.userId + "  エラー情報: " + e.getMessage());
              logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,null);
            }
          }
        }
      });

      notification.recipientsReqList = recipientsReqList;

      notificationMessage.setContent(replacedContent);
      notificationMessage.setNotificationNo(notificationNo);
      notificationMessage.setAdditionalInfo(replacedAdditionalInfo);
      notificationMessage.setRecipients(recipientsReqList);
      notificationMessage.setFacilityCd(facilityCode);

      notificationMessages.add(notificationMessage);
    }

    List<Long> messageNums = this.notificationService.registerNotificationMessages(notificationMessages);

    if (batchReq.notifications.size() != messageNums.size()) {
      EventLogMessage message = new EventLogMessage();
      message.setLogMessage(String.format("Wrong number of notification message IDs. Expected: %d, but is %d", batchReq.notifications.size(), messageNums.size()));
      this.logService.log(LogLevel.DEBUG, eventLogMessage, null, "FNSi", null);
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    for(int i = 0; i < batchReq.notifications.size(); ++i) {
      batchReq.notifications.get(i).notificationMessageNo = messageNums.get(i);
    }

    this.executeSendTask(batchReq);

    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  @Async("notificationExecutor")
  public void executeSendTask(BatchRequest batchReq) {
    for(int i = 0; i < batchReq.notifications.size(); ++i) {
      BatchRequest.Notification notification = batchReq.notifications.get(i);
      List<Long> recipientsList = notification.toUserIds;
      this.notificationService.notifyNotificationMessage(notification.notificationMessageNo, recipientsList);
      /* modify by chamaojia 2023-09-12 [9599] デスクトップ通知送信の判断条件の変更  --start */
//      if (!this.fileIOSv.ChkOnPremise().getIsOnPremise()) {
      if (this.fileIOSv.chkSesOn()) {
        this.notificationService.sendPushMessage(notification.recipientsReqList, notification.replacedContent);
      }
      /* modify by chamaojia 2023-09-12 [9599] デスクトップ通知送信の判断条件の変更  --end */
    }
  }

  public static class BatchRequest {
    List<Notification> notifications = new ArrayList<>();
    Map<Long, List<MstUser.SettingValue>> userSettingsMap = new HashMap<>();
    List<UserBasic> allUsers = new ArrayList<>();
    List<MstFacilityHash> facilityHashes = new ArrayList<>();

    public BatchRequest() {
    }

    List<Long> getAllNotificationNums() {
      return this.notifications.stream().map((n) -> n.notificationNo).distinct().collect(Collectors.toList());
    }

    boolean hasGlobal() {
      return this.notifications.stream().anyMatch((n) -> n.toAll);
    }

    List<String> getAllFacilityCodes() {
      return this.notifications.stream().map((n) -> n.facilityCode).distinct().collect(Collectors.toList());
    }

    List<Long> getAllUserId() {
      return this.notifications.stream().map((n) -> n.userId).filter(Objects::nonNull).distinct().collect(Collectors.toList());
    }

    static class UserBasic {
      Long userId;
      String facilityCode;
    }

    static class Notification {
      Long notificationNo;
      Long notificationMessageNo;
      boolean toAll = false;
      String facilityCode;
      Long userId = null;
      Map<String, String> replaceData = new HashMap<>();
      List<Long> toUserIds = new ArrayList<>();
      List<RecipientsRequest> recipientsReqList = new ArrayList<>();
      String replacedContent;
    }
  }
}
