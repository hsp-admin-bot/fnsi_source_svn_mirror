package com.fnsi.cloudconverter.refresh.file;

import java.nio.file.Path;
import java.util.List;
import java.util.Map;

/**
 * ファイル名 PK 置換サービス (03_module.md § Module 10)
 */
public interface FileRenameRefreshService {
    /**
     * ソースディレクトリをターゲットにコピーしつつ、
     * PK 関連フォルダ名を pk_mapping を参照して置換する（単一テーブル）
     *
     * @param sourceDir  コピー元ディレクトリ
     * @param targetDir  コピー先ディレクトリ
     * @param tableName  pk_mapping の参照テーブル名
     * @return 置換されたフォルダ数
     */
    long copyAndRename(Path sourceDir, Path targetDir, String tableName);

    /**
     * カテゴリ別ルールに基づいてコピー＆PK 置換する（off2on 用）
     * <p>
     * パス構造: {sourceDir}/{facilityCode}/{category}/{seg0}/{seg1}/...
     * categoryRules: カテゴリ名 → 各深さで使う pk_mapping テーブル名リスト
     * 例: {"BBS" → ["bbs_info"], "PEvent" → ["pat_main", "pat_event"]}
     * リストに含まれないカテゴリ（Report, DEConf 等）は翻訳なしでコピー
     *
     * @param sourceDir      コピー元ディレクトリ
     * @param targetDir      コピー先ディレクトリ
     * @param categoryRules  カテゴリ → テーブル名リスト（深さ順）
     * @return 置換されたフォルダ数
     */
    long copyWithCategoryRules(Path sourceDir, Path targetDir, Map<String, List<String>> categoryRules);
}
