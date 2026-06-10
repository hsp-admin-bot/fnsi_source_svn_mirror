package jp.co.nikkiso.ntss.admin_web.web.rest;


import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysReportSetting.sysReportSettingService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.SysReportSetting;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 機能帳票設定（sys_report_setting）系のリソースクラス
 */
@Slf4j
@RestController
@RequestMapping(AdminWebConstant.Uri.SYS_REPORT_SETTING)
public class SysReportSettingResource {

  /**
   * 標機能帳票設定サービス.
   */
  @Autowired
  private sysReportSettingService sysReportSettingService;

  @Autowired
  LogService logService;

  /**
   * 機能帳票設定を全取得する.
   */
  @GetMapping("/getSysRepotrSettingAll")
  //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 start
  //public ResponseEntity<?> getSysMedicineAll()
   public ResponseEntity<?> getSysMedicineAll(@RequestParam(value = "facilityCd") String facilityCd){
    //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 end
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("機能帳票設定取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);

    // レスポンス生成
    //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 start
    //List<SysReportSetting> response = sysReportSettingService.getAllSysReportSetting();
    List<SysReportSetting> response = sysReportSettingService.getAllSysReportSetting(facilityCd);
    //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 end
    // ログ出力
    eventLogMessage.setLogMessage("機能帳票設定取得:取得数[" + response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
}
