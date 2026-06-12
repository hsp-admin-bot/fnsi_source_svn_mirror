package com.fnsi.cloudconverter.transfer;

import com.fnsi.cloudconverter.transfer.model.UploadResponse;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * ファイル転送 API (02_api.md § 3-4)
 *
 * POST /api/v1/upload                      — ZIP アップロード
 * GET  /api/v1/download/{jobId}/{fileType} — ZIP ダウンロード
 */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class TransferController {

    private final TransferService transferService;

    /** ZIP アップロード（202 Accepted） */
    @PostMapping("/upload")
    public ResponseEntity<UploadResponse> upload(
            @RequestParam("file")         MultipartFile file,
            @RequestParam("uploadType")   String        uploadType,
            @RequestParam("facilityCode") String        facilityCode) {
        return ResponseEntity.status(HttpStatus.ACCEPTED)
                .body(transferService.upload(file, uploadType, facilityCode));
    }

    /** ZIP ダウンロード（ストリーミング） */
    @GetMapping("/download/{jobId}/{fileType}")
    public void download(
            @PathVariable long   jobId,
            @PathVariable String fileType,
            HttpServletResponse  response) {
        transferService.download(jobId, fileType, response);
    }
}
