package com.fnsi.cloudconverter.transfer;

import com.fnsi.cloudconverter.common.exception.JobNotFoundException;
import com.fnsi.cloudconverter.common.exception.MigrationBusinessException;
import com.fnsi.cloudconverter.job.entity.MigrationJob;
import com.fnsi.cloudconverter.job.model.JobStatus;
import com.fnsi.cloudconverter.job.repository.MigrationJobRepository;
import com.fnsi.cloudconverter.transfer.model.UploadResponse;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * アップロード/ダウンロードサービス実装
 * 参照: 03_module.md § Module 15 / 02_api.md § 3,4
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TransferServiceImpl implements TransferService {

    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("yyyyMMdd");

    private static final int STREAM_BUFFER_SIZE = 8192;

    /** アップロード種別ホワイトリスト */
    private static final java.util.Set<String> VALID_UPLOAD_TYPES =
            java.util.Set.of("PG_DUMP", "MONGO_DUMP", "FILES");

    /** ダウンロード種別→ファイル名マッピング（ホワイトリスト） */
    private static final java.util.Map<String, String> FILE_TYPE_MAP =
            java.util.Map.of(
                    "pg",         "pg_dump",
                    "pg_dump",    "pg_dump",
                    "mongo",      "mongo_dump",
                    "mongo_dump", "mongo_dump",
                    "files",      "files");

    @Value("${migration.storage.base-path:/tmp/migration}")
    private String basePath;

    private final MigrationJobRepository jobRepository;

    // -------------------------------------------------------
    // ZIP アップロード (02_api.md § 3)
    // -------------------------------------------------------

    @Override
    public UploadResponse upload(MultipartFile file, String uploadType, String facilityCode) {
        if (!VALID_UPLOAD_TYPES.contains(uploadType)) {
            throw new IllegalArgumentException(
                    "uploadType は PG_DUMP / MONGO_DUMP / FILES のいずれかである必要があります: " + uploadType);
        }
        if (file.isEmpty()) {
            throw new IllegalArgumentException("アップロードファイルが空です");
        }

        // アップロード ID 生成: upload-{yyyyMMdd}-{random6}
        String uploadId = "upload-" + LocalDateTime.now().format(DATE_FMT) + "-"
                          + UUID.randomUUID().toString().replace("-", "").substring(0, 6);

        // 保存先ディレクトリ作成
        Path uploadDir = Paths.get(basePath, "uploads", uploadId);
        try {
            Files.createDirectories(uploadDir);
        } catch (IOException e) {
            throw new MigrationBusinessException(
                    "アップロードディレクトリの作成に失敗しました: " + uploadDir, e);
        }

        // ファイル保存
        String originalFilename = file.getOriginalFilename() != null
                ? file.getOriginalFilename() : "upload.zip";
        Path destFile = uploadDir.resolve(originalFilename);
        try {
            file.transferTo(destFile);
        } catch (IOException e) {
            throw new MigrationBusinessException(
                    "ファイルの保存に失敗しました: " + destFile, e);
        }

        log.info("[TRANSFER] アップロード完了: uploadId={}, type={}, facility={}, size={}",
                uploadId, uploadType, facilityCode, file.getSize());

        return new UploadResponse(
                uploadId,
                uploadType,
                uploadDir.toString(),
                file.getSize(),
                Instant.now(),
                "ファイルのアップロードが完了しました");
    }

    // -------------------------------------------------------
    // ZIP ダウンロード (02_api.md § 4)
    // -------------------------------------------------------

    @Override
    public void download(long jobId, String fileType, HttpServletResponse response) {
        // JOB 存在・完了状態チェック
        MigrationJob job = jobRepository.findById(jobId)
                .orElseThrow(() -> new JobNotFoundException(jobId));

        if (job.getStatus() != JobStatus.DONE) {
            throw new MigrationBusinessException(
                    "JOB がまだ完了していません: status=" + job.getStatus());
        }

        // ファイル種別チェック
        String filePrefix = FILE_TYPE_MAP.get(fileType);
        if (filePrefix == null) {
            throw new IllegalArgumentException(
                    "fileType は pg / mongo / files のいずれかである必要があります: " + fileType);
        }

        // ダウンロードファイルパス: {basePath}/jobs/{jobId}/output/{filePrefix}_job{jobId}.zip
        String fileName = filePrefix + "_job" + jobId + ".zip";
        Path zipPath = Paths.get(basePath, "jobs", String.valueOf(jobId), "output", fileName);

        if (!Files.exists(zipPath)) {
            throw new JobNotFoundException(jobId,
                    "出力ファイルが存在しません: " + zipPath);
        }

        // レスポンスヘッダー設定
        response.setContentType(MediaType.APPLICATION_OCTET_STREAM_VALUE);
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        try {
            response.setContentLengthLong(Files.size(zipPath));
        } catch (IOException e) {
            log.warn("[TRANSFER] ファイルサイズ取得失敗: {}", zipPath);
        }

        // ストリーミング転送
        try (InputStream in = Files.newInputStream(zipPath);
             OutputStream out = response.getOutputStream()) {
            byte[] buf = new byte[STREAM_BUFFER_SIZE];
            int read;
            while ((read = in.read(buf)) != -1) {
                out.write(buf, 0, read);
            }
            out.flush();
        } catch (IOException e) {
            throw new MigrationBusinessException(
                    "ファイルのストリーミング転送に失敗しました: " + fileName, e);
        }

        log.info("[TRANSFER] ダウンロード完了: jobId={}, fileType={}, file={}", jobId, fileType, fileName);
    }
}
