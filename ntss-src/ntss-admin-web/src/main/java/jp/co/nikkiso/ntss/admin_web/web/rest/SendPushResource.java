package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.SysNotificationList;
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
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.webPush.WebPushService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

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
      @RequestBody Map<String, String> param,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      String facilityCd = param.get("facilityCd");
      if (facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
        // #11205 mod 20260421 start
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "terminalUniqueString=" + param.get("terminalUniqueString") + " " + "userId=" + param.get("userId") + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        // #11205 mod 20260421 end
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
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
      @PathVariable String terminalUniqueString,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
// #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      List<SysNotificationList> sysNotificationLists = webPushService.searchNotificationDestination(terminalUniqueString, null, null);
      if (sysNotificationLists == null || sysNotificationLists.isEmpty()) {
        // #11205 mod 20260421 start
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "terminalUniqueString=" + terminalUniqueString + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        // #11205 mod 20260421 end
      }
      for (SysNotificationList sysNotificationList : sysNotificationLists) {
        if (sysNotificationList.getFacilityCd() != null && !sysNotificationList.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          // #11205 mod 20260421 start
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + sysNotificationList.getFacilityCd() + " " + "terminalUniqueString=" + terminalUniqueString + " " + "userId=" + sysNotificationList.getUserId() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          // #11205 mod 20260421 end
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
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
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 start
  //@PutMapping("/pushSearch/{terminalUniqueString}")
  //public ResponseEntity<?> searchPushData(
  //  @PathVariable String terminalUniqueString) {
  //  return new ResponseEntity<>(webPushService.searchNotificationDestination(terminalUniqueString), HttpStatus.OK);
  //}
  @PutMapping("/pushSearch/{terminalUniqueString}")
  public ResponseEntity<?> searchPushData(
      @PathVariable String terminalUniqueString,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    String facilityCd = ntssUser.getFacilityCd();
    String userId = ntssUser.getUserId().toString();
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
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
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end

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
