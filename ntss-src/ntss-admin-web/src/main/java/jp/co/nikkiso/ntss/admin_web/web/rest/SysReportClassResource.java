package jp.co.nikkiso.ntss.admin_web.web.rest;


import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysReportClass.sysReportClassService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.SysReportClass;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 帳票種別定義（sys_report_class）系のリソースクラス
 */
@Slf4j
@RestController
@RequestMapping(AdminWebConstant.Uri.SYS_REPORT_CLASS)
public class SysReportClassResource {

  /**
   * 帳票種別定義サービス.
   */
  @Autowired
  private sysReportClassService sysReportClassService;

  @Autowired
  LogService logService;

  /**
   * 帳票種別定義を全取得する.
   */
  @GetMapping("/getSysReportClassAll")
  public ResponseEntity<?> getSysReportClassAll(int classCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("帳票種別定義取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);

    // レスポンス生成
    List<SysReportClass> response = sysReportClassService.getAllSysReportClass(classCd);

    // ログ出力
    eventLogMessage.setLogMessage("帳票種別定義取得:取得数[" + response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
}
