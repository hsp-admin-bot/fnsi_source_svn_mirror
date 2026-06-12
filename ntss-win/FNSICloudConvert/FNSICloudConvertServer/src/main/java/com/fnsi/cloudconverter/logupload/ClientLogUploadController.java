package com.fnsi.cloudconverter.logupload;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * クライアントログアップロード API。
 *
 * 互換エンドポイント:
 * POST /ntss-admin-web/api/log/uploader/{appName}
 */
@Slf4j
@RestController
@RequestMapping("/ntss-admin-web/api/log")
@RequiredArgsConstructor
public class ClientLogUploadController {

    private final ClientLogUploadService clientLogUploadService;

    @PostMapping(
            value = "/uploader/{appName}",
            consumes = {MediaType.TEXT_PLAIN_VALUE, MediaType.APPLICATION_OCTET_STREAM_VALUE},
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<ClientLogUploadResponse> upload(
            @PathVariable String appName,
            @RequestParam(required = false) String logDate,
            @RequestBody(required = false) byte[] body) {
        try {
            ClientLogUploadResponse response = clientLogUploadService.upload(appName, body, logDate);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            log.warn("[CLIENT_LOG_UPLOAD] 不正なリクエスト: appName={}, logDate={}, reason={}", appName, logDate, e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ClientLogUploadResponse(false, null, e.getMessage()));
        } catch (Exception e) {
            log.error("[CLIENT_LOG_UPLOAD] 保存失敗: appName={}, logDate={}", appName, logDate, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ClientLogUploadResponse(false, null, e.getMessage()));
        }
    }

    @PostMapping(
            value = "/uploader/{mode:\\d+}",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<ClientLogUploadResponse> uploadLegacy(
            @PathVariable int mode,
            @RequestParam String appName,
            @RequestParam String fileName,
            @RequestPart("upFile") MultipartFile upFile) {
        try {
            ClientLogUploadResponse response = clientLogUploadService.uploadLegacy(mode, appName, fileName, upFile);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            log.warn("[CLIENT_LOG_UPLOAD] 旧互換アップロード不正: mode={}, appName={}, fileName={}, reason={}",
                    mode, appName, fileName, e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ClientLogUploadResponse(false, null, e.getMessage()));
        } catch (Exception e) {
            log.error("[CLIENT_LOG_UPLOAD] 旧互換アップロード失敗: mode={}, appName={}, fileName={}",
                    mode, appName, fileName, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ClientLogUploadResponse(false, null, e.getMessage()));
        }
    }
}
