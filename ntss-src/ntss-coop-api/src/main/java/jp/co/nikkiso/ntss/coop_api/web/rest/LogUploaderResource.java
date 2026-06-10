package jp.co.nikkiso.ntss.coop_api.web.rest;

import jp.co.nikkiso.ntss.coop_api.response.ErrorMessage;
import jp.co.nikkiso.ntss.coop_api.service.LogUploaderService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;

/**
 * ログアップローダー系のRestクラス
 */
@RestController
@RequestMapping("/api/log/uploader")
public class LogUploaderResource {

  @Autowired
  LogService logService;

  @Autowired
  LogUploaderService logUploadService;

  /**
   * ログファイルアップロード
   */
  @PostMapping("/{mode}")
  public ResponseEntity<?> uploadFile(
    HttpServletRequest request,
    @PathVariable(name = "mode", required = true) Integer mode,
    @RequestParam(name = "logType", required = true) String logType,
    @RequestParam(name = "facilityCd", required = false) String facilityCd,
    @RequestParam(name = "appName", required = false) String appName,
    @RequestParam(name = "fileName", required = false) String fileName,
    @RequestParam(name = "upFile", required = false) MultipartFile upFile) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    String upFileName = "";
    try {
      // 本アプリケーションが稼働しているIPアドレスを取得
      eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());

      // ログ出力を依頼したクライアントIPアドレスを取得
      if (request != null) {
        // クライアントIP取得
        String clientIpAddress = request.getHeader("X-FORWARDED-FOR");
        if (StringUtils.isEmpty(clientIpAddress)) {
          clientIpAddress = request.getRemoteAddr();
        }
        eventLogMessage.setClientIp(clientIpAddress);
        // セッションID
        eventLogMessage.setSessionId(request.getRequestedSessionId());
      }

      // 施設コード
      eventLogMessage.setFacilityCd(facilityCd);

      // ファイルチェック
      if( upFile != null ) {
        // ファイルあり
        upFileName = upFile.getOriginalFilename();
        try {
          eventLogMessage.setLogMessage("ログアップロード開始 facilityCd:" + facilityCd + " uploadFile:" + upFileName + " → fileName:" + fileName);
          logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);

          // ログファイルアップロード
          logUploadService.logFileUpload(mode, logType, facilityCd, appName, fileName, upFile);

          eventLogMessage.setLogMessage("ログアップロード成功 facilityCd:" + facilityCd + " uploadFile:" + upFileName + " → fileName:" + fileName);
          logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        } catch (Exception ex) {
          eventLogMessage.setLogMessage("ログアップロードエラー。 facilityCd:" + facilityCd + " uploadFile:" + upFileName + " → fileName:" + fileName + " error:" + ex.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
          ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, eventLogMessage.getLogMessage());
          return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
        }
        ErrorMessage error = new ErrorMessage(HttpStatus.OK, "ログアップロード処理成功");
        return new ResponseEntity<>(error, HttpStatus.OK);
      } else {
        // ファイルなし
        eventLogMessage.setLogMessage("ログアップロード失敗 file:なし");
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, eventLogMessage.getLogMessage());
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ログアップロード失敗 facilityCd:" + facilityCd + " fileName:" + fileName + " error:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, eventLogMessage.getLogMessage());
      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
  }
}
