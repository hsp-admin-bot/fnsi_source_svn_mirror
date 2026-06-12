package com.fnsi.cloudconverter.transfer;

import com.fnsi.cloudconverter.transfer.model.UploadResponse;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.multipart.MultipartFile;

/**
 * アップロード/ダウンロードサービス (03_module.md § Module 15)
 */
public interface TransferService {
    UploadResponse upload(MultipartFile file, String uploadType, String facilityCode);
    void           download(long jobId, String fileType, HttpServletResponse response);
}
