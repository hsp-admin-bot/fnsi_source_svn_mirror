package com.fnsi.cloudconverter.util.archive;

import java.nio.file.Path;

/**
 * ZIP 圧縮/解凍サービス (03_module.md § Module 11)
 */
public interface ArchiveService {
    /**
     * ディレクトリまたはファイルを ZIP 圧縮する
     */
    Path compress(Path source, Path outputZip);

    /**
     * ZIP ファイルを解凍する
     */
    Path decompress(Path zipFile, Path targetDir);
}
