package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.ReadStatusRequest;
// add FNSI-コードをマージ 江 start
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.RegistMessageSendMailRequest;
// add FNSI-コードをマージ 江 end
import jp.co.nikkiso.ntss.admin_web.request.notificationMessage.RegisterRequest;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.NotificationListResponse;
import jp.co.nikkiso.ntss.admin_web.response.notificationMessage.UnreadCountResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.notificationMessage.NotificationMessageService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.MNoticeProperties;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import lombok.extern.slf4j.Slf4j;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
// add FNSI-コードをマージ 江 start
// add FNSI-コードをマージ 江 end

import jakarta.validation.Valid;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 通知一覧のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.NOTIFICATION_MESSAGE)
public class NotificationMessageResource {

  /**
   * 通知一覧Service.
   */
  @Autowired
  private NotificationMessageService notificationMessageService;

	@Autowired
	LogService logService;
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
   * WebAPI呼び出し用.
   */
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
//  add FNSI redmine 6143修正 任 start
  @Autowired
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;
//  add FNSI redmine 6143修正 任 end
  /**
   * m-notice接続設定
   */
  @Autowired
  private MNoticeProperties myPropaties;

  // add FNSI-コードをマージ 江 start
  /**
   * 通知メッセージ登録・メール送信
   * @param request 通知メッセージ情報
   */
  @PutMapping("")
  public ResponseEntity<?> registerNotificationMessageAndSendMail(
      @Valid @RequestBody RegistMessageSendMailRequest request,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // 通知メッセージ登録処理呼び出し
    String content = null;
    if (request.getContentSubject() != null) {
      content = request.getContentSubject() + System.lineSeparator();
    }
    if (request.getContentBody() != null) {
      content += request.getContentBody();
    }

    RegisterRequest reqRegistMessage = new RegisterRequest();
    reqRegistMessage.setContent(content);
    reqRegistMessage.setRecipients(request.getRecipients());
    reqRegistMessage.setAdditionalInfo(request.getAdditionalInfo());

    ResponseEntity<?> ret = registerNotificationMessage(reqRegistMessage, ntssUser);
    if (ret.getStatusCode() != HttpStatus.OK) {
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }

    // メール送信処理呼び出し
    Map<String,String> reqSendMail = new HashMap<String, String>();
    reqSendMail.put("subject", request.getContentSubject());
    reqSendMail.put("body", request.getContentBody());

    ret = sendMakerNoticeMail(reqSendMail);
    if (ret.getStatusCode() != HttpStatus.OK) {
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }

    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }
  // add FNSI-コードをマージ 江 end

  /**
   * 通知メッセージ登録.
   *
   * @param request  通知メッセージ情報
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PostMapping("")
  public ResponseEntity<?> registerNotificationMessage(
    @Valid @RequestBody RegisterRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to register notification message");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);


    // エンコード処理
    String base64Content = request.getContent() == null
        ? null
        : Base64.getEncoder().encodeToString(request.getContent().getBytes());
    String base64AdditionalInfo = request.getAdditionalInfo() == null
        ? null
        : Base64.getEncoder().encodeToString(request.getAdditionalInfo().getBytes());
    String base64FacilityCd = Base64.getEncoder().encodeToString(ntssUser.getFacilityCd().getBytes());

    // エンコード文字列を含むリクエスト作成
    RegisterRequest encodedRequest = request;
    encodedRequest.setContent(base64Content);
    encodedRequest.setAdditionalInfo(base64AdditionalInfo);
    encodedRequest.setFacilityCd(base64FacilityCd);

    // WebAPIの通知処理を呼び出す
    try {
      webApiCallCommonUtil.registerMakerNotice(encodedRequest);
    } catch (URISyntaxException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    } catch (RuntimeException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }

    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * 通知メッセージ取得(未通知).
   *
   * @param ntssUser NTSS認証ユーザ
   * @return 通知メッセージ情報
   */
  @GetMapping("")
  public ResponseEntity<?> getNotificationMessage(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get notification message not notified : "+ ntssUser.getUserId());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    // 通知メッセージを取得する
    // mod FNSI-当施設の操作通知は別施設に表示を修正 江 start
    //NotificationListResponse response = notificationMessageService.getNotificationMessage(ntssUser.getUserId());
    NotificationListResponse response = notificationMessageService.getNotificationMessageList(ntssUser.getUserId(),ntssUser.getFacilityCd());
    // mod FNSI-当施設の操作通知は別施設に表示を修正 江 end

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  // add bug 6531 修正 chen start
  /**
   * 通知メッセージ取得(未通知).
   *
   * @param ntssUser NTSS認証ユーザ
   * @return 通知メッセージ情報
   */
  @GetMapping("/login")
  public ResponseEntity<?> getNotificationMessageForLogin(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get notification message not notified : "+ ntssUser.getUserId());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
      null);

    // 通知メッセージを取得する
    NotificationListResponse response = notificationMessageService.getNotificationMessageList(ntssUser.getUserId(),ntssUser.getFacilityCd());
    List<NotificationMessage> notificationList = response.getNotificationList();
    // mod FNSi6531通知が重複して行われる 周 start
    List<NotificationMessage> notificationListTmp = new ArrayList<NotificationMessage>();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String strToday = sdf.format(new Date());
    for (NotificationMessage notification : notificationList) {
      Long notificationNo = notification.getNotificationNo();
//      if (!notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET) &&
//        !notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET)) {
//        notificationListTmp.add(notification);
//      }
      if((notificationNo != CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET
          && notificationNo != CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET)
        || ((notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET)
            || notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET))
            && (0 == notification.getRegDate().toString().substring(0, 10).compareTo(strToday)))) {
        notificationListTmp.add(notification);
      }
    }
    notificationList = notificationListTmp;
    response.setNotificationList(notificationListTmp);
    // mod FNSi6531通知が重複して行われる 周 end
    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add bug 6531 修正 chen end

//del FNSI-通知表示が遅いを修正 江 start
//  /**
//   * 通知メッセージ取得(全件).
//   *
//   * @param ntssUser NTSS認証ユーザ
//   * @return 通知メッセージ情報
//   */
//  @GetMapping("/all")
//  public ResponseEntity<?> getNotificationMessageAll(
//    @AuthenticationPrincipal NtssUser ntssUser) {
//
//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage( "REST request to get notification message all : "+ ntssUser.getUserId());
//    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
//    null);
//
//    // 通知メッセージを取得する
//    NotificationListResponse response = notificationMessageService.getNotificationMessageAll(ntssUser.getUserId());
//
//    // レスポンス生成
//    return new ResponseEntity<>(response, HttpStatus.OK);
//  }
//del FNSI-通知表示が遅いを修正 江 end

  //add FNSI-通知表示が遅いを修正 江 start
  /**
   * 通知メッセージ取得(全件).
   *
   * @param ntssUser NTSS認証ユーザ
   * @return 通知メッセージ情報
   */
  @GetMapping("/all/{offset}")
  public ResponseEntity<?> getNotificationMessageAll(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable Integer offset) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get notification message all : "+ ntssUser.getUserId());
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    // 通知メッセージを取得する
    NotificationListResponse response = notificationMessageService.getNotificationMessageAll(ntssUser.getUserId(),ntssUser.getFacilityCd(), offset);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  //add FNSI-通知表示が遅いを修正 江 end

  // del #10110 通知一覧から既読にした通知以外も消える dengshen start
  // // add FNSI redmine 4893 修正 鄧シン start
  // /**
  //  * 変更後通知メッセージ取得(全件).
  //  *
  //  * @param ntssUser NTSS認証ユーザ
  //  * @return 通知メッセージ情報
  //  */
  // @GetMapping("/allAfterChange/{offset}")
  // public ResponseEntity<?> getNotificationMessageAllAfterChange(
  //   @AuthenticationPrincipal NtssUser ntssUser,
  //   @PathVariable Integer offset) {
  //   // ログ出力
  //   EventLogMessage eventLogMessage = new EventLogMessage();
  //   eventLogMessage.setLogMessage( "REST request to get notification message all : "+ ntssUser.getUserId());
  //   logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
  //     null);
  //
  //   // 通知メッセージを取得する
  //   NotificationListResponse response = notificationMessageService.getNotificationMessageAllAfterChange(ntssUser.getUserId(),ntssUser.getFacilityCd(), offset);
  //
  //   // レスポンス生成
  //   return new ResponseEntity<>(response, HttpStatus.OK);
  // }
  // // add FNSI redmine 4893 修正 鄧シン end
  // del #10110 通知一覧から既読にした通知以外も消える dengshen end

  // add FNSI-通知既読更新を修正 江 start
  /**
   * 既読の更新.
   *
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/allIsRead")
  public ResponseEntity<?> updateisReadStatus(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update isread status");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
      null);

    // 既読フラグを更新する
    notificationMessageService.updateIsReadStatus(ntssUser.getUserId());

    // 未読件数を取得する
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 start
    UnreadCountResponse response = notificationMessageService.getUnreadCountByFacilityCd(ntssUser.getUserId(), ntssUser.getFacilityCd());
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 end

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add FNSI-通知既読更新を修正 江 end

  /**
   * 既読/未読の更新.
   *
   * @param request  既読/未読情報
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/status")
  public ResponseEntity<?> updateReadStatus(
    @Valid @RequestBody ReadStatusRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update read status");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    // 既読フラグを更新する
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 Start
    // notificationMessageService.updateReadStatus(request, ntssUser.getUserId());
    notificationMessageService.updateReadStatus(request, ntssUser.getUserId(), ntssUser.getFacilityCd());
    // 通知コードがない場合、全テーブル検査になってしまうため、必須条件をつけるように修正 end

    // 未読件数を取得する
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 start
    UnreadCountResponse response = notificationMessageService.getUnreadCountByFacilityCd(ntssUser.getUserId(), ntssUser.getFacilityCd());
    //mod FNSI-【redmine #4440 別の施設に対する通知が表示される】を修正 江 end

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * メーカー通知対象ユーザ取得.
   *
   * @return 対象ユーザ
   */
  @GetMapping("/getUser")
  public ResponseEntity<List<Long>> getMakerNoticeUser() {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get maker notification user");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
    null);

    List<Long> userList = new ArrayList<Long>();
    // 施設リストを取得する
//    mod FNSI redmine 6143修正 任 start
    List<MstFacility> mstFacilityList = mstFacilityDao.selectAll();
    List<String> facilityCdList = mntFacilityCancelManageDao.getFacilityCd();
    // 登録されている全利用者を取得する
    for (MstFacility facilityData : mstFacilityList) {
      if (!facilityCdList.contains(facilityData.getFacilityCd())) {
        List<MstPersonalUser> mstPersonalUserList = mstPersonalUserDao.selectAll(facilityData.getFacilityCd(), "0");
        for (MstPersonalUser userData : mstPersonalUserList) {
          userList.add(userData.getUserId());
        }
      }
    }
//    mod FNSI redmine 6143修正 任 end
    // レスポンス生成
    return new ResponseEntity<>(userList, HttpStatus.OK);
  }

  /**
   * メーカー通知登録メール送信処理.
   *
   * @return
   */
  @PostMapping("/sendMail")
  public ResponseEntity<?> sendMakerNoticeMail(@RequestBody Map<String, String> payload) {

    HttpStatus status = HttpStatus.OK;
    String ret = null;

    // エンコード処理
    String subject = Base64.getEncoder().encodeToString(payload.get("subject").getBytes());
    String body = Base64.getEncoder().encodeToString(payload.get("body").getBytes());

    JSONObject jsonBody = new JSONObject();
    jsonBody.put("subject", subject);
    jsonBody.put("body", body);

    try {
      // 送信URI
      URI uri = new URI(myPropaties.getMNotice().getUrl()+myPropaties.getMNotice().getMakerNotice());
      RestTemplate rt = new RestTemplate();

      // リクエスト作成
      RequestEntity<String> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
          .header(myPropaties.getMNotice().getHeaderName(), myPropaties.getMNotice().getHeaderValue())
          .body(jsonBody.toString());
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<String> response = rt.exchange(request, String.class);
      status = HttpStatus.valueOf(response.getStatusCode().value());
      ret = response.getBody();
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.NotificationMessageResource");
      map.put("methodName", "sendMakerNoticeMail");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("m-notice接続失敗:"+status);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(ret, status);
      }
    } catch (Exception ex) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("m-notice呼び出し処理で例外発生:"+ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(ret, status);
    }

    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
    }

}
