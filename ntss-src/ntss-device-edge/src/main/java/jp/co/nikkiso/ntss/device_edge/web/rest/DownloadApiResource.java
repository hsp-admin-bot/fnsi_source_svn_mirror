package jp.co.nikkiso.ntss.device_edge.web.rest;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.request.DownloadRequest;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.download.DownloadFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;

import jakarta.validation.Valid;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;

import jp.co.nikkiso.ntss.core.utils.HexCodecUtils;

@RestController
@RequestMapping("/api/s3/download")
public class DownloadApiResource {

  @Autowired
  private LogService logService;

//  #10977 Mod by Z.t. There's no needs to send a request which cross several services to visit S3 bucket.
//  @Autowired
//  private MyProperties myPropaties;
  /** Amazon S3. */
  @Autowired
  private S3Client s3;

  @Autowired
  private DownloadFileService downloadFileService;

  // #10977 MOD by Z.t. There's no needs to send a request which cross several services to visit S3 bucket. Start
  /**
   * ファイルダウンロードAPI
   *
   * @param request ファイル名とバケット.
   * @return  ファイルダウンロード状況
   */
  @PostMapping("")
  public ResponseEntity<?> downloadFromS3(@Valid @RequestBody DownloadRequest request) {

//    try {
//      // 送信URI
//      URI uri = new URI(myPropaties.getRest().getDownload());
//      RestTemplate rt = new RestTemplate();
//
//      // リクエスト作成
//      RequestEntity<DownloadRequest> callApiReq = RequestEntity
//          .post(uri)
//          .contentType(MediaType.APPLICATION_JSON)
//          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
//          .body(request);
//
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("REST API呼び出し:[" + uri + "], body:{ bucket:" + request.getBucket() + ", fileName:"
//              + request.getFilename() + "}");
//      //FNSI-修正 ログ対応 xiebzh add start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      //FNSI-修正 ログ対応 xiebzh add end
//      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
//      // リクエスト処理
//      eventLogMessage.setLogMessage("ファイルダウンロードAPI：RestAPI呼び出し [" + callApiReq.getUrl().toString() + "] body[ bucket:" + request.getBucket()
//      + ", filename:" + request.getFilename() + "]");
//      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
//      ResponseEntity<String> response = rt.exchange(callApiReq, String.class);
//      HttpStatus status = response.getStatusCode();
//      if (HttpStatus.OK != status) {
//        eventLogMessage.setLogMessage("ファイルダウンロードAPI：RestAPI側でダウンロード失敗 " + status);
//        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
//        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
//        //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
//      }
//      return response;
//    } catch (HttpServerErrorException ex) {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("ファイルダウンロードAPI：RestAPI呼び出し処理でHttpServerException発生 " + ex.getMessage());
//        //FNSI-修正 ログ対応 xiebzh add start
//        eventLogMessage.setInvokeClass(this.getClass().getName());
//        //FNSI-修正 ログ対応 xiebzh add end
//        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
//        return new ResponseEntity<>(ex.getStatusCode());
//    } catch (Exception ex) {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("ファイルダウンロードAPI：RestAPI呼び出し処理で一般例外発生 " + ex.getMessage());
//        //FNSI-修正 ログ対応 xiebzh add start
//        eventLogMessage.setInvokeClass(this.getClass().getName());
//        //FNSI-修正 ログ対応 xiebzh add end
//        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
//        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
//        //return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
//    }

    EventLogMessage eventLogMessage = new EventLogMessage();

    // Get parameters
    String bucket = request.getBucket();
    String filename = request.getFilename();

    // #12003 2025.07.24 add bucket名から"s3://"を取り除く TDC片口 start
    // "s3://"を付与している事でS3からS3Objectの取得が出来ない為
    bucket = bucket.replace("s3://", "");
    // #12003 2025.07.24 add bucket名から"s3://"を取り除く TDC片口 end

    // Get premise settings
    Map<String, String> premiseResultMap = this.downloadFileService.getSystemDefineOfPremise();

    // Parameter checks
    if (!StringUtils.hasText(bucket) || !StringUtils.hasText(filename)
      || premiseResultMap == null || premiseResultMap.isEmpty()
      || !premiseResultMap.containsKey("path") || !premiseResultMap.containsKey("status")
    ) {
      eventLogMessage.setLogMessage("There are legitimate Parameters appears at downloading files process.");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
      return new ResponseEntity<>("Parameters are empty or System setting are not defined.", HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // Start to download file.
    try {
      // Download file form server local store.
      if ("on".equals(premiseResultMap.get("status"))) {
        String fileLocation = premiseResultMap.get("path") + "/" + bucket + "/" + filename;
        byte[] bytes = Files.readAllBytes(Paths.get(fileLocation));
        // 16進数文字列に変換
        return new ResponseEntity<>(HexCodecUtils.printHexBinary(bytes), HttpStatus.OK);
      }
      // Download file from S3 server.
      else {
        try (ResponseInputStream<GetObjectResponse> is = s3.getObject(GetObjectRequest.builder()
            .bucket(bucket)
            .key(filename)
            .build());
             ByteArrayOutputStream os = new ByteArrayOutputStream()) {
          byte[] buffer = new byte[1024];
          while (true) {
            int len = is.read(buffer);
            if (len < 0) {
              break;
            }
            os.write(buffer, 0, len);
          }
          byte[] content = os.toByteArray();
          // 16進数文字列に変換
          return new ResponseEntity<>(HexCodecUtils.printHexBinary(content), HttpStatus.OK);
        }
      }
    } catch (IOException e) {
      eventLogMessage.setLogMessage("ファイルダウンロードAPI：ファイルダウンロード処理で例外発生 " + e.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }
  // #10977 MOD by Z.t. There's no needs to send a request which cross several services to visit S3 bucket. End
}
