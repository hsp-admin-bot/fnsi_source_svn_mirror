package com.fnsi.cloudconverter.refresh.file;

import com.fnsi.cloudconverter.mapping.pk.PkMappingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ファイル名 PK 置換サービス実装
 * 数値名フォルダを pk_mapping の new_id に置換してコピーする
 * 参照: 03_module.md § Module 10
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FileRenameRefreshServiceImpl implements FileRenameRefreshService {

    private final PkMappingService pkMappingService;

    @Override
    public long copyAndRename(Path sourceDir, Path targetDir, String tableName) {
        if (!Files.exists(sourceDir)) {
            log.warn("[FILE_RENAME] ソースディレクトリが存在しません: {}", sourceDir);
            return 0L;
        }

        long[] renamedCount = {0};

        try {
            Map<Long, Long> mapping = pkMappingService.findMappings(
                    tableName,
                    new ArrayList<>(collectNumericSegments(sourceDir)));
            Files.walkFileTree(sourceDir, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs)
                        throws IOException {
                    Path relative = sourceDir.relativize(dir);
                    Path destDir  = resolveWithRename(targetDir, relative, mapping, renamedCount);
                    Files.createDirectories(destDir);
                    return FileVisitResult.CONTINUE;
                }

                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
                        throws IOException {
                    Path relative = sourceDir.relativize(file);
                    Path destFile = resolveWithRename(targetDir, relative, mapping, renamedCount);
                    Files.createDirectories(destFile.getParent());
                    Files.copy(file, destFile, StandardCopyOption.REPLACE_EXISTING);
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            throw new com.fnsi.cloudconverter.common.exception.MigrationBusinessException(
                    "ファイルコピー/リネームに失敗しました: " + sourceDir, e);
        }

        log.info("[FILE_RENAME] 完了: source={}, renamed={}", sourceDir, renamedCount[0]);
        return renamedCount[0];
    }

    /**
     * 相対パスの各セグメントが数値名の場合、pk_mapping で置換してターゲットパスを構築する
     */
    private Path resolveWithRename(Path base, Path relative, Map<Long, Long> mapping,
                                   long[] renamedCount) {
        Path result = base;
        for (Path segment : relative) {
            String name = segment.toString();
            try {
                long oldId = Long.parseLong(name);
                Long newId = mapping.get(oldId);
                if (newId != null) {
                    result = result.resolve(String.valueOf(newId));
                    renamedCount[0]++;
                } else {
                    result = result.resolve(name);
                }
            } catch (NumberFormatException e) {
                result = result.resolve(name);
            }
        }
        return result;
    }

    // -------------------------------------------------------
    // カテゴリ別ルール（off2on 用）
    // -------------------------------------------------------

    @Override
    public long copyWithCategoryRules(Path sourceDir, Path targetDir,
                                      Map<String, List<String>> categoryRules) {
        if (!Files.exists(sourceDir)) {
            log.warn("[FILE_RENAME] ソースディレクトリが存在しません: {}", sourceDir);
            return 0L;
        }

        long[] renamedCount = {0};

        try {
            // 実際のファイルパスに出現する数値 ID だけを読み込み、巨大な pk_mapping 全量ロードを避ける。
            Map<String, Set<Long>> requiredIdsByTable = collectCategoryNumericSegments(sourceDir, categoryRules);
            Map<String, Map<Long, Long>> allMappings = new HashMap<>();
            for (Map.Entry<String, Set<Long>> entry : requiredIdsByTable.entrySet()) {
                allMappings.put(entry.getKey(), pkMappingService.findMappings(
                        entry.getKey(),
                        new ArrayList<>(entry.getValue())));
            }

            Files.walkFileTree(sourceDir, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs)
                        throws IOException {
                    Path relative = sourceDir.relativize(dir);
                    Path destDir = resolveWithCategoryRules(targetDir, relative,
                            categoryRules, allMappings, renamedCount);
                    Files.createDirectories(destDir);
                    return FileVisitResult.CONTINUE;
                }

                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
                        throws IOException {
                    Path relative = sourceDir.relativize(file);
                    Path destFile = resolveWithCategoryRules(targetDir, relative,
                            categoryRules, allMappings, renamedCount);
                    Files.createDirectories(destFile.getParent());
                    Files.copy(file, destFile, StandardCopyOption.REPLACE_EXISTING);
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            throw new com.fnsi.cloudconverter.common.exception.MigrationBusinessException(
                    "ファイルコピー/リネームに失敗しました: " + sourceDir, e);
        }

        log.info("[FILE_RENAME] 完了: source={}, renamed={}", sourceDir, renamedCount[0]);
        return renamedCount[0];
    }

    /**
     * カテゴリ別ルールでパスを解決する
     * パス構造: {facilityCode}/{category}/{seg0}/{seg1}/...
     *   depth 0 = facilityCode → 翻訳なし
     *   depth 1 = category    → 翻訳なし（ルール特定に使用）
     *   depth 2 = rules[0] のテーブルで翻訳
     *   depth 3 = rules[1] のテーブルで翻訳
     *   ...
     */
    private Path resolveWithCategoryRules(Path base, Path relative,
                                          Map<String, List<String>> categoryRules,
                                          Map<String, Map<Long, Long>> allMappings,
                                          long[] renamedCount) {
        Path result = base;
        String category = null;
        int depth = 0;

        for (Path segment : relative) {
            String name = segment.toString();

            if (depth == 1) {
                category = name; // カテゴリ名を記憶
                if (categoryRules.containsKey(category)) {
                    log.debug("[FILE_RENAME] カテゴリ={} → PK 置換ルール適用", category);
                } else {
                    log.debug("[FILE_RENAME] カテゴリ={} → ルールなし、そのままコピー", category);
                }
            }

            if (depth >= 2 && category != null) {
                List<String> tables = categoryRules.get(category);
                int ruleIndex = depth - 2;
                if (tables != null && ruleIndex < tables.size()) {
                    String tableName = tables.get(ruleIndex);
                    try {
                        long oldId = Long.parseLong(name);
                        Long newId = allMappings.getOrDefault(tableName, Map.of()).get(oldId);
                        if (newId != null) {
                            result = result.resolve(String.valueOf(newId));
                            renamedCount[0]++;
                            depth++;
                            continue;
                        }
                    } catch (NumberFormatException ignored) {
                        // 数値でないセグメントはそのまま
                    }
                }
            }

            result = result.resolve(name);
            depth++;
        }
        return result;
    }

    private Set<Long> collectNumericSegments(Path sourceDir) throws IOException {
        Set<Long> ids = new HashSet<>();
        Files.walkFileTree(sourceDir, new SimpleFileVisitor<>() {
            @Override
            public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
                collectNumericSegments(sourceDir.relativize(dir), ids);
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
                collectNumericSegments(sourceDir.relativize(file), ids);
                return FileVisitResult.CONTINUE;
            }
        });
        return ids;
    }

    private void collectNumericSegments(Path relative, Set<Long> ids) {
        for (Path segment : relative) {
            try {
                ids.add(Long.parseLong(segment.toString()));
            } catch (NumberFormatException ignored) {
                // 数値でないセグメントはファイル名としてそのまま扱う
            }
        }
    }

    private Map<String, Set<Long>> collectCategoryNumericSegments(
            Path sourceDir,
            Map<String, List<String>> categoryRules) throws IOException {
        Map<String, Set<Long>> idsByTable = new HashMap<>();
        Files.walkFileTree(sourceDir, new SimpleFileVisitor<>() {
            @Override
            public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
                collectCategoryNumericSegments(sourceDir.relativize(dir), categoryRules, idsByTable);
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
                collectCategoryNumericSegments(sourceDir.relativize(file), categoryRules, idsByTable);
                return FileVisitResult.CONTINUE;
            }
        });
        return idsByTable;
    }

    private void collectCategoryNumericSegments(
            Path relative,
            Map<String, List<String>> categoryRules,
            Map<String, Set<Long>> idsByTable) {
        String category = null;
        int depth = 0;

        for (Path segment : relative) {
            String name = segment.toString();
            if (depth == 1) {
                category = name;
            }

            if (depth >= 2 && category != null) {
                List<String> tables = categoryRules.get(category);
                int ruleIndex = depth - 2;
                if (tables != null && ruleIndex < tables.size()) {
                    try {
                        long oldId = Long.parseLong(name);
                        String tableName = tables.get(ruleIndex);
                        idsByTable.computeIfAbsent(tableName, ignored -> new HashSet<>()).add(oldId);
                    } catch (NumberFormatException ignored) {
                        // 数値でないセグメントはそのまま
                    }
                }
            }
            depth++;
        }
    }
}
