package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.sysReleaseInfo.SysReleaseInfoService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.SysReleaseInfo;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 通知定義（sysReleaseInfo）系のリソースクラス
 */
@RestController
@RequestMapping(Uri.SYS_RELEASE_INFO)
public class SysReleaseInfoResource {

  /**
   * 通知定義サービス.
   */
  @Autowired
  private SysReleaseInfoService sysReleaseInfoService;

  @Autowired
  LogService logService;

  /**
  * リリース一覧情報取得
  * @return リリース一覧情報
  */
  @GetMapping("/getSysReleaseInfoAll/")
  public ResponseEntity<?> getSysReleaseInfoAll() {

    // debugログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get SysReleaseInfo : getSysReleaseInfoAll");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,null);

    try {
      // レスポンス生成
      List<SysReleaseInfo> response = sysReleaseInfoService.getSysReleaseInfoAll();
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("REST request error by get SysReleaseInfo : {} " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * リリース明細情報
   * @return リリース明細htmlテキスト
   */
  @GetMapping("/getReleaseDetail/{ctl_no}")
  public ResponseEntity<String> getDeviceSetInfoPat(@PathVariable Long ctl_no) {

    // debugログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get releaseDetail : selectPath");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,null);

    String releaseDetail = null;
    try {
      releaseDetail = sysReleaseInfoService.getReleaseDetail(ctl_no);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("REST request error by get releaseDetail : {} " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
    return new ResponseEntity<>(releaseDetail, HttpStatus.OK);
  }
}
