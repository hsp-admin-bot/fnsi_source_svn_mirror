package com.fnsi.cloudconverter.util.archive;

import com.fnsi.cloudconverter.common.exception.MigrationBusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

/**
 * ZIP 圧縮/解凍サービス実装 (03_module.md § Module 11)
 */
@Slf4j
@Service
public class ArchiveServiceImpl implements ArchiveService {

    private static final int BUFFER_SIZE = 65536;

    @Override
    public Path compress(Path source, Path outputZip) {
        try {
            Files.createDirectories(outputZip.getParent());
            try (OutputStream fos = Files.newOutputStream(outputZip);
                 ZipOutputStream zos = new ZipOutputStream(fos)) {

                if (Files.isDirectory(source)) {
                    compressDirectory(source, source, zos);
                } else {
                    compressFile(source, source.getFileName().toString(), zos);
                }
            }
            log.info("[ARCHIVE] 圧縮完了: {} → {}", source, outputZip);
            return outputZip;
        } catch (IOException e) {
            throw new MigrationBusinessException("ZIP 圧縮に失敗しました: " + source, e);
        }
    }

    @Override
    public Path decompress(Path zipFile, Path targetDir) {
        // ZipFile（セントラルディレクトリ参照）を使用する。
        // ZipInputStream（ローカルヘッダー参照）は Windows の Compress-Archive 等が
        // ディレクトリエントリ名の末尾スラッシュを省略する場合があり isDirectory() が
        // 誤判定するため使用しない。
        try {
            Files.createDirectories(targetDir);
            Path normalizedTarget = targetDir.normalize();

            try (ZipFile zf = new ZipFile(zipFile.toFile())) {
                Enumeration<? extends ZipEntry> entries = zf.entries();
                while (entries.hasMoreElements()) {
                    ZipEntry entry = entries.nextElement();
                    // バックスラッシュ正規化
                    String entryName = entry.getName().replace('\\', '/');
                    // ディレクトリエントリはスキップ（createDirectories で自動作成される）
                    if (entryName.endsWith("/")) continue;
                    Path dest = normalizedTarget.resolve(entryName).normalize();
                    // ディレクトリトラバーサル防止
                    if (!dest.startsWith(normalizedTarget)) {
                        throw new MigrationBusinessException(
                                "不正な ZIP エントリ: " + entry.getName());
                    }
                    Files.createDirectories(dest.getParent());
                    try (InputStream in  = zf.getInputStream(entry);
                         OutputStream out = Files.newOutputStream(dest)) {
                        in.transferTo(out);
                    }
                }
            }
            log.info("[ARCHIVE] 解凍完了: {} → {}", zipFile, targetDir);
            return targetDir;
        } catch (IOException e) {
            log.error("[ARCHIVE] 解凍失敗: zipFile={}, cause={}", zipFile, e.getMessage(), e);
            throw new MigrationBusinessException("ZIP 解凍に失敗しました: " + zipFile, e);
        }
    }

    private void compressDirectory(Path root, Path current, ZipOutputStream zos) throws IOException {
        Files.walkFileTree(current, new SimpleFileVisitor<>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                String entryName = root.relativize(file).toString().replace('\\', '/');
                compressFile(file, entryName, zos);
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
                if (!dir.equals(root)) {
                    String entryName = root.relativize(dir).toString().replace('\\', '/') + "/";
                    zos.putNextEntry(new ZipEntry(entryName));
                    zos.closeEntry();
                }
                return FileVisitResult.CONTINUE;
            }
        });
    }

    private void compressFile(Path file, String entryName, ZipOutputStream zos) throws IOException {
        zos.putNextEntry(new ZipEntry(entryName));
        try (InputStream in = Files.newInputStream(file)) {
            byte[] buf = new byte[BUFFER_SIZE];
            int len;
            while ((len = in.read(buf)) > 0) {
                zos.write(buf, 0, len);
            }
        }
        zos.closeEntry();
    }
}
