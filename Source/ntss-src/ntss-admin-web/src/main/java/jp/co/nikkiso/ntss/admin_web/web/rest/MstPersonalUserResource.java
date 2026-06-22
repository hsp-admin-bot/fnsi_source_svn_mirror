package jp.co.nikkiso.ntss.admin_web.web.rest;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
// #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
// #11205 -ペンテスト2－4認可制御の不備  add 20260420 end

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.response.personalUser.NameWithHasEmailResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;
import lombok.extern.slf4j.Slf4j;
/**
 * 利用者（mst_personal_user）系のリソースクラス
 */
@RestController
@RequestMapping(Uri.PERSONAL_USER)
@Slf4j
public class MstPersonalUserResource {

  /**
   * 利用者マスタサービス
   */
  @Autowired
  private PersonalUserService personalUserService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 利用者の名前とメールアドレス登録有無を取得する
   *
   * @param ntssUser NTSS認証ユーザー
   * @return 利用者の名前とメールアドレス登録有無のセット
   */
  @GetMapping("/has_email")
  public ResponseEntity<NameWithHasEmailResponse> getNameAndHasEmailAddress(@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PERSONAL_USER + "/has_email";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    final String facilityCd = ntssUser.getFacilityCd();
    final NameWithHasEmailResponse nameAndHasEmail = personalUserService.getNameAndHasEmailByFacilityCd(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(nameAndHasEmail, HttpStatus.OK);
  }

  /**
   * 利用者の名前とメールアドレス登録有無を取得する
   *
   * @param facilityCd NTSS認証ユーザー
   * @return 利用者の名前とメールアドレス登録有無のセット
   */
  @GetMapping("/has_email/data/{facilityCd}")
  public ResponseEntity<NameWithHasEmailResponse> getNameAndHasEmailAddressByFacilityCd(
    @PathVariable(name = "facilityCd", required = true) String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.isEmpty() && !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PERSONAL_USER + "/has_email/data";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End
    final NameWithHasEmailResponse nameAndHasEmail = personalUserService.getNameAndHasEmailByFacilityCd(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(nameAndHasEmail, HttpStatus.OK);
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


}
