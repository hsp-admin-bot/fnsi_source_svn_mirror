package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysSystemDefine.SysSystemDefineService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

/**
 * システム設定（sys_system_define）系のリソースクラス
 */
@RestController
@RequestMapping(Uri.SYS_SYSTEM_DEFINE)
public class SysSystemDefineResource {
  
  /**
   * システム設定サービス.
   */
  @Autowired
  SysSystemDefineService sysSystemDefineService;
  

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;


  /**
  * 通知定義データ取得.
  */
  @GetMapping("/getSysSystemDefine/{ctlNo}")
  public ResponseEntity<?> getSysSystemDefine(@PathVariable(name = "ctlNo", required = true) int ctlNo) {

    // ログ出力

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : getSysSystemDefine");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    try {
      // レスポンス生成
      List<SysSystemDefine> response = sysSystemDefineService.getSysSystemDefine(ctlNo);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
