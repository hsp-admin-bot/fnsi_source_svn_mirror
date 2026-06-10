package jp.co.nikkiso.ntss.admin_web.web.rest;


import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.webApi.UploadResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogUploaderService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;


/**
 * ログアップローダー系のRestクラス
 */
@RestController
@RequestMapping(Uri.LOG_UPLOADER)
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
      @RequestParam(name = "appName", required = true) String appName,
      @RequestParam(name = "fileName", required = true) String fileName,
      @RequestParam(name = "upFile", required = true) MultipartFile upFile,
      @AuthenticationPrincipal NtssUser ntssUser) {
    UploadResponse errResponse = new UploadResponse();
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
      // 利用者情報を設定
      if (ntssUser != null) {
        // 施設コード
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
        // 利用者ID
        eventLogMessage.setUserId(ntssUser.getUserId().toString());
      }

      // ファイルチェック
      if( upFile != null ) {
        // ファイルあり
        upFileName = upFile.getOriginalFilename();
        try {
          eventLogMessage.setLogMessage("ログアップロード開始 mode:" + mode + " appName:" + appName + " uploadFile:" + upFileName + " → fileName:" + fileName);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

          // ログファイルアップロード
          logUploadService.logFileUpload(mode, ntssUser.getFacilityCd(), appName, fileName, upFile);

          eventLogMessage.setLogMessage("ログアップロード成功 mode:" + mode + " appName:" + appName + " uploadFile:" + upFileName + " → fileName:" + fileName);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        } catch (Exception ex) {
          eventLogMessage.setLogMessage("ログアップロードエラー mode:" + mode + " appName:" + appName + " uploadFile:" + upFileName + " → fileName:" + fileName + " error:" + ex.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          errResponse.isSuccess = false;
          errResponse.isException = true;
          errResponse.errorMessage = "ログアップロード処理で例外発生";
          errResponse.exceptionMessage = ex.getMessage();
          return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
        }
        errResponse.isSuccess = true;
        errResponse.isException = false;
        errResponse.errorMessage = "ログアップロード処理成功";
        errResponse.exceptionMessage = null;
        return new ResponseEntity<>(errResponse, HttpStatus.OK);
      } else {
        // ファイルなし
        eventLogMessage.setLogMessage("ログアップロード失敗 file:なし");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        errResponse.isSuccess = false;
        errResponse.isException = false;
        errResponse.errorMessage = "ログアップロード処理でアップロードファイルなし";
        errResponse.exceptionMessage = null;
        return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ログアップロード失敗 mode:"  + mode + " appName:" + appName + " uploadFile:" + upFileName + " → fileName:" + fileName + " error:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      errResponse.isSuccess = false;
      errResponse.isException = true;
      errResponse.errorMessage = "ログアップロード処理で例外発生";
      errResponse.exceptionMessage = e.getMessage();
      return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
    }
  }
}
