package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.entity.SysCoopNo;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.sysCoopNo.SysCoopNoService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@RequestMapping(Uri.SYS_COOP_NO)
public class SysCoopNoResource {

   /**
   * 連携オーダ採番サービス
   */
  @Autowired
  SysCoopNoService creationService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 施設CDまたは連携電文CDで連携電文設定マスタを取得
   * @param facilityCd
   * @return
   */
  @GetMapping("/getByFacility/{facilityCd}")
  public ResponseEntity<?> selectSysCoopNoByFacilityCd(@PathVariable String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      // #11205 mod 20260421 start
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      // #11205 mod 20260421 end
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SYS_COOP_NO + "/getByFacility";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<SysCoopNo> sysCoopNos = creationService.selectSysCoopNoByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(sysCoopNos, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携バージョンに一致する連携オーダ採番テンプレートを取得
   * @param coopVersion
   * @return
   */
  @GetMapping("/source/{coopVersion}")
  public ResponseEntity<?> selectSourceSysCoopNoByCoopVersion(@PathVariable String coopVersion) {

    String mappingUrl = Uri.SYS_COOP_NO + "/source";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      List<SysCoopNo> sysCoopNos = creationService.selectSourceSysCoopNoByCoopVersion(coopVersion);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(sysCoopNos, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 項目を登録する。
   * @param sysCoopNo
   * @param ntssUser
   * @return
   */
  @PostMapping("/submit")
  public ResponseEntity<?> submit(@RequestBody SysCoopNo sysCoopNo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SYS_COOP_NO + "/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submit(sysCoopNo, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

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

  private boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    return ntssUser != null && (ntssUser.isNkkAdminUser() || facilityCd == null || facilityCd.equals(ntssUser.getFacilityCd()));
  }
}
