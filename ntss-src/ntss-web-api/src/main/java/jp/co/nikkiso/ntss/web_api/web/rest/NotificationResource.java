package jp.co.nikkiso.ntss.web_api.web.rest;

import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.SysNotificationDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.SysNotification;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.web_api.request.RecipientsRequest;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.fileIO.FileIOService;
import jp.co.nikkiso.ntss.web_api.service.notification.NotificationService;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javax.validation.Valid;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 通知一覧のResourceクラス.
 */
@RestController
@RequestMapping("util")
public class NotificationResource {

  /**
   * 通知系Service.
   */
  @Autowired
  private NotificationService notificationService;

  /**
   * 施設マスタのDAOインターフェース
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * 利用者マスタのDAOインターフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 通知定義のDAOインターフェース
   */
  @Autowired
  private SysNotificationDao sysNotificationDao;

  /**
   * 施設マスタハッシュのDAOインターフェース
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  @Autowired
  private FileIOService fileIOSv;

  @Autowired
  private LogService logService;
  /**
   * 汎用通知レシーバー
   * sys_notificationに登録済みの通知登録用
   *
   * @param request  通知メッセージ情報
   * @return
   */
  @PostMapping("/notificationReciever")
  public ResponseEntity<?> genericNotificationReciever(
    @Valid @RequestBody String request
    ) throws IOException {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to register notification message");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 送られたデータのJSON化
    JSONObject requestJson = new JSONObject(request);

    // 通知定義番号と置換データの取得
    Long notificationNo = null;
    JSONObject replaceData = null;
    String facilityCd = "";
    try {
      notificationNo = requestJson.getLong("notificationNo");
      // 置換データはBase64デコード(UTF-8)
      String strReplaceData = requestJson.has("replaceData")
        ? new String(Base64.getDecoder().decode(requestJson.getString("replaceData")), StandardCharsets.UTF_8)
        : null;
      replaceData = new JSONObject(strReplaceData);
      facilityCd = requestJson.getString("facilityCd");
      // ログ改善対応 毛 Add
      eventLogMessage.setFacilityCd(facilityCd);
    } catch (Exception e) {
      // JSONの値取得に失敗した場合はBad Requestを返す
      eventLogMessage.setLogMessage("JSONの値取得に失敗しました。");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }

    //add FNSi6531通知が重複して行われる 周 start
//    //通知メッセージを登録済みですかを確認する
//    try {
//      if(notificationNo > 0) {
//        int notificationCnt = notificationService.getNotificationMessage(facilityCd, notificationNo);
//        if(notificationCnt > 0) {
//          return new ResponseEntity<>(null, HttpStatus.OK);
//        }
//      }
//    } catch (Exception e) {
//      eventLogMessage.setLogMessage("通知情報の取得に失敗しました。facilityCd: " + facilityCd + ". notificationNo: " + notificationNo);
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
//      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
//    }
    //add FNSi6531通知が重複して行われる 周 end

    // 通知定義の取得
    SysNotification notification = sysNotificationDao.selectByCd(notificationNo);

    // 正規表現の抽出
    Pattern pattern = Pattern.compile("\\[(.*?)\\]");
    Matcher keysInMessage = pattern.matcher(notification.getMessage());
    Matcher keysInInfo = pattern.matcher(notification.getAdditionalInfo());

    // 置換処理
    String replacedContent = notification.getMessage();
    String replacedAdditionalInfo = notification.getAdditionalInfo();

    while (keysInMessage.find()) {
      String matchStr = keysInMessage.group();
      String matchKey = matchStr.replace("[", "").replace("]", "");
      try {
		// add 9500 by kangjie 20231009 start
//        replacedContent = replacedContent.replace(matchStr, replaceData.getString(matchKey));
        if (replaceData.has(matchKey)){
        replacedContent = replacedContent.replace(matchStr, replaceData.getString(matchKey));
        }else {
          replacedContent = replacedContent.replace(matchStr, "");
        }
		// add 9500 by kangjie 20231009 end
      } catch (Exception e) {
        // 置換処理に失敗した場合はBad Requestを返す
        eventLogMessage.setLogMessage("メッセージ定義の置換処理に失敗しました。");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
      }
    }

    while (keysInInfo.find()) {
      String matchStr = keysInInfo.group();
      String matchKey = matchStr.replace("[", "").replace("]", "");
      try {
		// add 9500 by kangjie 20231009 start
//        replacedAdditionalInfo = replacedAdditionalInfo.replace(matchStr, replaceData.getString(matchKey));
        if (replaceData.has(matchKey)) {
        replacedAdditionalInfo = replacedAdditionalInfo.replace(matchStr, replaceData.getString(matchKey));
        } else {
          replacedAdditionalInfo = replacedAdditionalInfo.replace(matchStr, "");
        }
		// add 9500 by kangjie 20231009 end
      } catch (Exception e) {
        // 置換処理に失敗した場合はBad Requestを返す
        eventLogMessage.setLogMessage("付加情報定義の置換処理に失敗しました。");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
      }
    }

    // 特定ユーザーのみに通知する設定のフラグ
    // 通知対象のユーザーIDはreplaceData内の"USERID"キーに入れておく
    Boolean isOnlySpecificUser =
        notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET) ||
        notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET) ||
          //5794 add 担当者に設定された際の通知が関係のないユーザーに発生する 関俊楠 start
          notificationNo.equals(CoreConstant.NotificationDefinition.SET_CHARGE_STAFF);
          //5794 add 担当者に設定された際の通知が関係のないユーザーに発生する 関俊楠 end
    // add 9500 by 9500 20231016 start
    if (notificationNo.equals(CoreConstant.NotificationDefinition.ADD_FACILTY_EVENT) &&
            !replaceData.has("USERID") ) {
      // send message to everybody
      isOnlySpecificUser = false;
    } else if(notificationNo.equals(CoreConstant.NotificationDefinition.ADD_FACILTY_EVENT) &&
            replaceData.has("USERID")) {
      // send message to selected people
      isOnlySpecificUser = true;
    }
    // add 9500 by 9500 20231016 end
    Long SpecificUserId = 0L;
    if (isOnlySpecificUser) {
      SpecificUserId = Long.parseLong(replaceData.getString("USERID"));
    }

    // 通知定義の受信をONにしているユーザー一覧の抽出
    List<RecipientsRequest> recipientsReqList = new ArrayList<RecipientsRequest>();
    // 施設リストを取得する
    List<MstFacility> mstFacilityList = mstFacilityDao.selectAll();
    // 通知設定タブのタブ定義コード
    Integer tabDefineCd = 8;
    // 通知処理改善対応 毛 Add
    Boolean isTargetSetting = false;
    Boolean isNotificationOn = false;
    // 登録されている全利用者を取得する
    for (MstFacility facilityData : mstFacilityList) {
      //add FNSi7631 修正 chen start
      if (!"nkknkk".equals(facilityCd) && !facilityCd.equals(facilityData.getFacilityCd())) {
        continue;
      }
      //add FNSi7631 修正 chen end
      // 施設ごとのユーザーリスト
      List<MstPersonalUser> mstPersonalUserList = mstPersonalUserDao.selectAll(facilityData.getFacilityCd(), "0");
      // 施設のシステム利用設定
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityData.getFacilityCd());
      // 利用者ごとに通知のON/OFFを参照する
      for (MstPersonalUser userData : mstPersonalUserList) {
        // 特定ユーザーのみに通知する設定の場合、通知対象のユーザー以外には通知しない
        if (isOnlySpecificUser && !SpecificUserId.equals(userData.getUserId())) {
          continue;
        }
        // add bug 6522 修正 chen start
        // if (isOnlySpecificUser) {
        //   List<MntNotificationMessage> MntNotificationMessage = notificationService.hasNotificationMessage(
        //     replacedContent, userData.getUserId(), replacedAdditionalInfo, facilityCd, notificationNo);
        //   if (MntNotificationMessage != null && MntNotificationMessage.size() > 0) {
        //     continue;
        //   }
        // }
        // add bug 6522 修正 chen end
        List<MstUser.SettingValue> userSettings = notificationService.getPersonalSettings(userData.getUserId(), tabDefineCd);
        // 対象の通知定義がONになっているユーザーをリストに追加する
        if (userSettings.size() > 0) {
          for (MstUser.SettingValue setting : userSettings) {
            // 通知処理改善対応 毛
            try {
            isTargetSetting = notificationNo.equals(Long.parseLong(setting.getSettingId()));
            isNotificationOn = "true".equals(setting.getSettingValue().toString());
            if (isTargetSetting && isNotificationOn) {
              RecipientsRequest recipientsData = new RecipientsRequest();
              recipientsData.setUserId(userData.getUserId());
              recipientsData.setFacilityCd(facilityData.getFacilityCd());
              recipientsData.setSystemUseSetting(mstFacilityHash.getSystemUseSetting());
              recipientsReqList.add(recipientsData);
            }
            } catch (Exception e) {
              eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
              eventLogMessage.setLogMessage("対象ユーザーに送信失敗：" + userData.getUserId() + "  エラー情報: " + e.getMessage());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            }
          }
        }
      }
    }

    // add bug 6522 修正 chen start
    // if (isOnlySpecificUser && recipientsReqList.size() == 0) {
    //   return new ResponseEntity<>(null, HttpStatus.OK);
    // }
    // add bug 6522 修正 chen end

    // ユーザーIDのみを抽出
    List<Long> recipientsList = recipientsReqList.stream()
        .map(item -> item.getUserId())
        .collect(Collectors.toList());

    // 通知メッセージを登録する
    // mod FNSI-重要通知設定の追加 江 start
    //Long messageNo = notificationService.registerNotificationMessage(
    //  replacedContent, recipientsReqList, replacedAdditionalInfo, facilityCd);
    Long messageNo = notificationService.registerNotificationMessage(
      replacedContent, recipientsReqList, replacedAdditionalInfo, facilityCd, notificationNo);
    // mod FNSI-重要通知設定の追加 江 end

    // クライアントに通知する
    // add bug 6531 修正 chen start
    // if (isOnlySpecificUser) {
    //   return new ResponseEntity<>(null, HttpStatus.OK);
    // }
    // add bug 6531 修正 chen end
    //del FNSi6531通知が重複して行われる 周 start
    //notificationService.notifyNotificationMessage(messageNo, recipientsList);
    //del FNSi6531通知が重複して行われる 周 end

    //mod FNSi6531通知が重複して行われる 周 start
    //mod FNSi7631 修正 chen start
    // add オンプレミスの場合、通知しない 劉
    /**
     * Send webSocket Message
     */
    // add FNSi6531通知が重複して行われる chen start
    if (notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET) ||
            notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET)) {
      try {
        Thread.sleep(2000);
      } catch (InterruptedException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessageNew.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
    }
    // add FNSi6531通知が重複して行われる chen end
    notificationService.notifyNotificationMessage(messageNo, recipientsList);
    /* modify by chamaojia 2023-09-12 [9599] デスクトップ通知送信の判断条件の変更  --start */
    /**
     * push google FCM
     */
//    if (!fileIOSv.ChkOnPremise().getIsOnPremise()){
    if (fileIOSv.chkSesOn()){
      // WebPush通知を送る
      notificationService.sendPushMessage(
        recipientsReqList,
        replacedContent
      );
    }
    /* modify by chamaojia 2023-09-12 [9599] デスクトップ通知送信の判断条件の変更  --end */
    //mod FNSi7631 修正 chen end
    //mod FNSi6531通知が重複して行われる 周 end

    // レスポンス生成
    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  /**
   * メーカー通知レシーバー
   * 画面からメーカー通知を送信したときの処理
   *
   * @param request  通知メッセージ情報
   * @return
   */
  @PostMapping("/makerNoticeReciever")
  public ResponseEntity<?> MakerNoticeReciever(
    @Valid @RequestBody String request
    ) {

    // 送られたデータのJSON化
    JSONObject requestJson = new JSONObject(request);

    // 送信メッセージ、ユーザーリスト、追加情報、通知定義番号の取得
    String content = null;
    List<Long> recipientsList = new ArrayList<Long>();
    String additionalInfo = null;
    String facilityCd = "";
    // add FNSI-重要通知設定の追加 江 start
    Long notificationNo = null;
    // add FNSI-重要通知設定の追加 江 end
    JSONArray recipientsJson =  requestJson.getJSONArray("recipients");
    try {
      content = requestJson.has("content")
          ? new String(Base64.getDecoder().decode(requestJson.getString("content")))
          : null;
      additionalInfo = requestJson.has("additionalInfo")
          ? new String(Base64.getDecoder().decode(requestJson.getString("additionalInfo")))
          : null;
      for (int i = 0; i < recipientsJson.length(); i++) {
        recipientsList.add(recipientsJson.getLong(i));
      }
      facilityCd = requestJson.has("facilityCd")
          ? new String(Base64.getDecoder().decode(requestJson.getString("facilityCd")))
          : null;
      // add FNSI-重要通知設定の追加 江 start
      notificationNo = requestJson.getLong("notificationNo");
      // add FNSI-重要通知設定の追加 江 end
    } catch (Exception e) {
      // JSONの値取得に失敗した場合はBad Requestを返す
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("JSONの値取得に失敗しました。");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
    }

    // ユーザーと施設コードの組み合わせ
    List<RecipientsRequest> recipientsReqList = new ArrayList<RecipientsRequest>();
    recipientsList.stream().forEach(userId -> {
      MstPersonalUser userData = mstPersonalUserDao.selectById(userId);
      RecipientsRequest recipientsData = new RecipientsRequest();
      recipientsData.setUserId(userId);
      recipientsData.setFacilityCd(userData.getFacilityCd());
      // 施設のシステム利用設定
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(userData.getFacilityCd());
      //mod FNSi6143メーカー通知で正常に通知しない 周 start
      //recipientsData.setSystemUseSetting(mstFacilityHash.getSystemUseSetting());
      if(null != mstFacilityHash) {
        recipientsData.setSystemUseSetting(mstFacilityHash.getSystemUseSetting());
      }
      //mod FNSi6143メーカー通知で正常に通知しない 周 end
      recipientsReqList.add(recipientsData);
    });

    // 通知メッセージを登録する
    // mod FNSI-重要通知設定の追加 江 start
    //Long messageNo = notificationService.registerNotificationMessage(
    // content, recipientsReqList, additionalInfo, facilityCd);
    Long messageNo = notificationService.registerNotificationMessage(
      content, recipientsReqList, additionalInfo, facilityCd,notificationNo);
    // mod FNSI-重要通知設定の追加 江 end

    // クライアントに通知する
    notificationService.notifyNotificationMessage(messageNo, recipientsList);

    // WebPush通知を送る
    notificationService.sendPushMessage(
        recipientsReqList,
        content
    );

    // レスポンス生成
    return new ResponseEntity<>(null, HttpStatus.OK);
  }
}
