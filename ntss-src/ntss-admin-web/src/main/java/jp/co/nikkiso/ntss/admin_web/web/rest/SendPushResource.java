package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.webPush.WebPushService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping(Uri.SEND_PUSH)
public class SendPushResource {

  /**
   * プッシュ通知Service.
   */
  @Autowired
  private WebPushService webPushService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * キー取得 & 生成
   * @return
   */
  @GetMapping("/publicKey")
  public ResponseEntity<String> generateKey() {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/publicKey";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(webPushService.getKeyPair(), HttpStatus.OK);
  }

  /**
   * プッシュ通知先を保存
   * @param param
   * @return
   */
  @PostMapping("/pushSave")
  public ResponseEntity<?> savePushData(
      @RequestBody Map<String, String> param) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/pushSave";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      param);
    // wp アプリケーションログの適正化 Add End


    webPushService.saveNotificationDestination(param);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      param);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(HttpStatus.OK);
  }

  /**
   * プッシュ通知先を削除
   * @param terminalUniqueString
   * @return
   */
  @PutMapping("/pushDelete/{terminalUniqueString}")
  public ResponseEntity<?> deletePushData(
      @PathVariable String terminalUniqueString) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/pushDelete";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      terminalUniqueString);
    // wp アプリケーションログの適正化 Add End
    webPushService.deleteNotificationDestination(terminalUniqueString);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      terminalUniqueString);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(HttpStatus.OK);
  }

  /**
   * プッシュ通知先を検索
   * @param terminalUniqueString
   * @return
   */
  // mod FNSI-外結バッグを修正する 江 start
  //@PutMapping("/pushSearch/{terminalUniqueString}")
  //public ResponseEntity<?> searchPushData(
  //  @PathVariable String terminalUniqueString) {
  //  return new ResponseEntity<>(webPushService.searchNotificationDestination(terminalUniqueString), HttpStatus.OK);
  //}
  @PutMapping("/pushSearch/{terminalUniqueString}/{facilityCd}/{userId}")
  public ResponseEntity<?> searchPushData(
      @PathVariable String terminalUniqueString,
      @PathVariable String facilityCd,
      @PathVariable String userId) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SEND_PUSH + "/pushSearch";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      terminalUniqueString);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      terminalUniqueString);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(webPushService.searchNotificationDestination(terminalUniqueString, facilityCd, userId), HttpStatus.OK);
  }
  // mod FNSI-外結バッグを修正する 江 end

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

}
