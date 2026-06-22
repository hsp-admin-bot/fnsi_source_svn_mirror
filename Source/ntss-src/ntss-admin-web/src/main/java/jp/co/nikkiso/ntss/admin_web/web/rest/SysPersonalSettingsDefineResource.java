package jp.co.nikkiso.ntss.admin_web.web.rest;

import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.PersonalSettingsDefine;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.SysPersonalSettingsDefineService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

/**
 * 共通設定タブ定義のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.SYS_PERSONAL_SETTINGS_DEFINE)
public class SysPersonalSettingsDefineResource {

  /**
   * 共通設定タブ定義のService.
   */
  @Autowired
  private SysPersonalSettingsDefineService sysPersonalSettingsDefineService;

  @Autowired
	LogService logService;
  @GetMapping("/{tab_define_cd}")
  public ResponseEntity<PersonalSettingsDefine> getPersonalSettingsDefine(
    @PathVariable("tab_define_cd") Integer tabDefineCd,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get sys_personal_settings_define : "+ tabDefineCd);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // レスポンス生成
    try{
      final PersonalSettingsDefine response
        = sysPersonalSettingsDefineService.getPersonalSettingsDefine(ntssUser.getFacilityCd(), tabDefineCd);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch(NotExistException e) {
      eventLogMessage.setLogMessage("There is no sys_personal_settings_define.");
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
