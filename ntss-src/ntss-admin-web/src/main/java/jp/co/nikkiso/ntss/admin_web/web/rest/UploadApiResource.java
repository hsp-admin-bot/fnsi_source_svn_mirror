package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.Base64;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.webApi.UploadResponse;
import jp.co.nikkiso.ntss.admin_web.service.file.FileControlService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

@RestController
@RequestMapping(Uri.FILE_UPLOAD)
public class UploadApiResource {

  @Autowired
  private FileControlService fileControlService;

  @Autowired
  LogService logService;

  // MOD #10637 2024/09/05 Thach Start
  
  @PostMapping("")
  public ResponseEntity<?> uploadToS3(@RequestParam("file") MultipartFile[] multipartFile,
      @RequestParam("facilityCd") String facilityCd) {

    UploadResponse errResponse = new UploadResponse();
    try {
      if (multipartFile.length == 0 || multipartFile[0].isEmpty()) {
        errResponse.isSuccess = false;
        errResponse.isException = false;
        errResponse.webApiStatus = HttpStatus.BAD_REQUEST;
        errResponse.errorMessage = "アップロードファイルなし";
        return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
      }
      if (facilityCd == null || facilityCd.length() == 0) {
        errResponse.isSuccess = false;
        errResponse.isException = false;
        errResponse.webApiStatus = HttpStatus.BAD_REQUEST;
        errResponse.errorMessage = "アップロード先情報なし";
        return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
      }
      String[] pathArray;
      try {
        // Base64のデータをデコード
        facilityCd = new String(Base64.getDecoder().decode(facilityCd));
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[fileUpload2S3]ファイルアップロード: 受信データ facilityCd のBase64デコード結果[" + facilityCd + "]");
        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      } catch (Exception ex) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("File Upload 指定内容エラー " + ex.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        errResponse.isSuccess = false;
        errResponse.isException = false;
        errResponse.webApiStatus = HttpStatus.BAD_REQUEST;
        errResponse.errorMessage = "アップロード先情報不備";
        errResponse.exceptionMessage = ex.getLocalizedMessage();
        return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
      }

      for (MultipartFile file : multipartFile) {
        try {
          boolean r = fileControlService.fileUpload2S3(file, facilityCd);
          if (!r) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("File Upload failed. " + file.getOriginalFilename());
            logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            errResponse.isSuccess = false;
            errResponse.isException = false;
            errResponse.webApiStatus = HttpStatus.BAD_REQUEST;
            errResponse.errorMessage = file.getOriginalFilename() + "アップロード失敗";
            return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
          }
        } catch (Exception ex) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("File Upload エラー " + ex.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          errResponse.isSuccess = false;
          errResponse.isException = true;
          errResponse.errorMessage = "アップロード処理で一般例外発生";
          errResponse.exceptionMessage = ex.getMessage();
          return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
        }
      }
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("File Upload API： upload success.");
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      errResponse.isSuccess = true;
      errResponse.isException = false;
      errResponse.errorMessage = "アップロード成功";
      return new ResponseEntity<>(errResponse, HttpStatus.OK);
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("File Upload API：一般例外発生 " + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      errResponse.isSuccess = false;
      errResponse.isException = true;
      errResponse.webApiStatus = null;
      errResponse.errorMessage = "一般例外発生";
      errResponse.exceptionMessage = ex.getMessage();
      return new ResponseEntity<>(errResponse, HttpStatus.BAD_REQUEST);
    }
  }
  
  // ADD #10637 2024/09/05 Thach End
}
