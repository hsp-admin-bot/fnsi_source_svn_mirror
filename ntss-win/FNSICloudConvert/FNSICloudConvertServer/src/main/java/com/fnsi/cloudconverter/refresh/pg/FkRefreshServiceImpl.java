package com.fnsi.cloudconverter.refresh.pg;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.LongNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.TextNode;
import com.fnsi.cloudconverter.log.MigrationLogService;
import com.fnsi.cloudconverter.mapping.fk.entity.FkMigrationConfig;
import com.fnsi.cloudconverter.mapping.fk.repository.FkMigrationConfigRepository;
import com.fnsi.cloudconverter.migration.pg.PgDumpConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * PG FK 刷新サービス実装
 * fk_migration_config の設定に基づき FK カラムを一括更新。
 * TASK4 実行時に convert_db の pk_mapping を ntss.pk_mapping_local（永続テーブル）に
 * コピーし、FDW を使わずローカル JOIN で高速処理する。
 * TEMP TABLE は接続プールの接続切替で見えなくなるため永続テーブルを使用。
 */
@Slf4j
@Service
public class FkRefreshServiceImpl implements FkRefreshService {

    private static final String PAT_VIEWER_PATH = "[].categoryItem.[].subCategoryItem.[].itemNo";
    private static final String PAT_IND_APPROVE_TOP_LEVEL_PATH = "itemInfo.itemCd";
    private static final String PAT_IND_APPROVE_NESTED_PATH = "subCategoryItem.[].itemInfo.itemCd";
    private static final String TMP_LOG_SEARCH_PAT_ID_PATH = "[].condition.patId.[].cd";
    private static final String TMP_LOG_SEARCH_USER_ID_PATH = "[].condition.userId.[].cd";
    private static final String MST_KUR_USER_ID_PATH = "{data,user_id}";
    private static final String MST_KUR_DISP_USER_ID_PATH = "{data,disp_user_id}";

    private final FkMigrationConfigRepository fkConfigRepository;
    private final PgDumpConfig pgDumpConfig;
    private final JdbcTemplate converterJdbc;
    private final MigrationLogService logService;
    private final Map<String, ColumnTypeKind> columnTypeCache = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final ThreadPoolTaskExecutor threadPoolTaskExecutor;

    public FkRefreshServiceImpl(
            FkMigrationConfigRepository fkConfigRepository,
            PgDumpConfig pgDumpConfig,
            @Qualifier("converterJdbc") JdbcTemplate converterJdbc,
            MigrationLogService logService,
            @Qualifier("refreshJsonExecutor") ThreadPoolTaskExecutor threadPoolTaskExecutor) {
        this.fkConfigRepository = fkConfigRepository;
        this.pgDumpConfig = pgDumpConfig;
        this.converterJdbc = converterJdbc;
        this.logService = logService;
        this.threadPoolTaskExecutor = threadPoolTaskExecutor;
    }

    @Override
    public long refreshAll(JdbcTemplate targetJdbc, java.util.List<String> codes,long jobId, String taskName) {
        return refreshAll(targetJdbc, codes, jobId, taskName, null);
    }

    @Override
    public long refreshAll(JdbcTemplate targetJdbc, java.util.List<String> codes,long jobId, String taskName, String dbLabel) {
        return refreshAll(targetJdbc, codes, jobId, taskName, null, null, dbLabel);
    }

    @Override
    public long refreshAll(JdbcTemplate targetJdbc, java.util.List<String> codes,long jobId, String taskName,
                           String direction, String dbName, String dbLabel) {
        List<FkMigrationConfig> configs =
                fkConfigRepository.findByEnabledTrueOrderByExecutionOrderAsc();
        if (direction != null && dbName != null) {
            java.util.Set<String> allowedTables = pgDumpConfig.allTableNamesForDb(direction, dbName);
            configs = configs.stream()
                    .filter(cfg -> allowedTables.contains(cfg.getTableName()))
                    .toList();
        }

        String taskLabel = taskName;
        log.info("[{}] 開始: jobId={}, db={}, 対象設定数={}", taskLabel, jobId,
                (dbLabel == null || dbLabel.isBlank()) ? "-" : dbLabel, configs.size());

        return refreshConfigs(targetJdbc, configs, taskLabel, jobId, dbLabel, codes);
    }

    long refreshConfigs(JdbcTemplate targetJdbc, List<FkMigrationConfig> configs, String taskName) {
        return refreshConfigs(targetJdbc, configs, taskName, 0L, null,null);
    }

    long refreshConfigs(JdbcTemplate targetJdbc, List<FkMigrationConfig> configs, String taskName, long jobId) {
        return refreshConfigs(targetJdbc, configs, taskName, jobId, null,null);
    }

    long refreshConfigs(JdbcTemplate targetJdbc, List<FkMigrationConfig> configs, String taskName, long jobId, String dbLabel,List<String> codes) {
        log.info("[{}] FK 刷新開始: 対象設定数={}", taskName, configs.size());
        java.util.Set<String> relnames = new java.util.HashSet<>(
                targetJdbc.queryForList(
                        "select relname from pg_stat_user_tables",
                        String.class
                )
        );
        Map<String, List<FkMigrationConfig>> tableGroupedMap =
                configs.stream()
                        .filter(cfg -> relnames.contains(cfg.getTableName()))
                        .collect(java.util.stream.Collectors.groupingBy(
                                FkMigrationConfig::getTableName,
                                LinkedHashMap::new,
                                java.util.stream.Collectors.toList()
                        ));
        List<java.util.concurrent.CompletableFuture<Integer>> futures = new ArrayList<>();
        for (Map.Entry<String, List<FkMigrationConfig>> entry : tableGroupedMap.entrySet()) {
            List<FkMigrationConfig> cfgList = entry.getValue();


            java.util.concurrent.CompletableFuture<Integer> future =
                    java.util.concurrent.CompletableFuture.supplyAsync(()->{
                        int totalUpdated = 0;
                        List<FkMigrationConfig> groupedList;

                        Map<Boolean, List<FkMigrationConfig>> grouped = cfgList.stream()
                                .collect(Collectors.partitioningBy(cfg -> "COLUMN".equals(cfg.getFkType())));
                        int currentUpdated = refreshColumnFk(targetJdbc, grouped.get(Boolean.TRUE), taskName, codes);
                        totalUpdated += currentUpdated;

                        groupedList = grouped.get(Boolean.FALSE);
                        for (int i = 0; i < groupedList.size(); i++) {
                            FkMigrationConfig cfg = groupedList.get(i);
                            try {
                                logService.info(jobId, null, String.format(
                                        "[%s] %s設定開始 (%d/%d): %s.%s -> %s",
                                        taskName, formatDbLabel(dbLabel), i+1, groupedList.size(),
                                        cfg.getTableName(),
                                        "COLUMN".equals(cfg.getFkType()) ? cfg.getColumnName() : cfg.getJsonColumn(),
                                        cfg.getRefTable()));
                                if ("JSON".equals(cfg.getFkType())) {
                                    if(cfg.getTableName().equals("pat_event") && cfg.getJsonColumn().equals("input_params") ){
                                        String aa="";
                                    }
                                    currentUpdated = refreshJsonFk(targetJdbc, cfg, taskName,codes);
                                } else if("JsonIntArray".equals(cfg.getFkType())){
                                    currentUpdated = refreshJsonArray(targetJdbc, cfg,codes);
                                }else if("JSON_MULTI".equals(cfg.getFkType())){

                                    currentUpdated = refreshWildcardMultiFieldJsonFk(targetJdbc, cfg,taskName,codes);
                                }
                                totalUpdated += currentUpdated;
                                logService.info(jobId, null, String.format(
                                        "[%s] %s設定完了 (%d/%d): %s.%s updated=%d",
                                        taskName, formatDbLabel(dbLabel), i+1, groupedList.size(),
                                        cfg.getTableName(),
                                        "COLUMN".equals(cfg.getFkType()) ? cfg.getColumnName() : cfg.getJsonColumn(),
                                        currentUpdated));
                            } catch (Exception e) {
                                log.error("[{}] FK更新に失敗しました: table={}, type={}", taskName, cfg.getTableName(), cfg.getFkType(), e);
                            }
                        }
                        return totalUpdated;
                    },threadPoolTaskExecutor).exceptionally(ex -> {
                        log.error("[{}] FK更新に失敗しました", taskName, ex);
                        return 0;
                    });
            futures.add(future);
        }
        java.util.concurrent.CompletableFuture.allOf(futures.toArray(new java.util.concurrent.CompletableFuture[0])).join();
        long total = futures.stream().mapToLong(java.util.concurrent.CompletableFuture::join).sum();
        if("db5".equals(dbLabel)) {//order by
            int orderRefreshNum = refreshMstSelector(targetJdbc, codes);
            if (orderRefreshNum > 0) {
                log.info("refreshMstSelector: orderRefreshNum = {}", orderRefreshNum);
            }
        }
        log.info("[{}] 完了: totalUpdated={}", taskName, total);
        return total;
    }

    private int refreshColumnFk(JdbcTemplate jdbc, List<FkMigrationConfig> cfgList, String taskName,List<String> facilityCd) {
        if (cfgList == null || cfgList.isEmpty()) {
            return 0;
        }

        List<String> sqlStatements = new ArrayList<>(cfgList.size());

        for (FkMigrationConfig cfg : cfgList) {

            ColumnTypeKind columnTypeKind = resolveColumnTypeKind(jdbc, cfg);
            String columnExpr;
            if (Boolean.TRUE.equals(cfg.getEncryptFlag())) {
                columnExpr = "ntss.personal_info_decrypt(t.\"" + cfg.getColumnName() + "\")";
            } else {
                columnExpr = "t.\"" + cfg.getColumnName() + "\"";
            }

            StringBuilder sql = new StringBuilder();
            sql.append("UPDATE ntss.\"").append(cfg.getTableName()).append("\" t")
                    .append(" SET \"").append(cfg.getColumnName()).append("\" = ")
                    .append(buildColumnAssignmentExpression(columnTypeKind, "m.new_id", cfg))
                    .append(" FROM ntss.pk_mapping_local m")
                    .append(" WHERE ")
                    .append(buildColumnMatchCondition(columnTypeKind, columnExpr, "m.old_id"))
                    .append(" AND m.table_name = '").append(escapeSql(cfg.getRefTable())).append("'");

            if (cfg.getWhereTemplate() != null) {
                sql.append(" AND (").append(cfg.getWhereTemplate()).append(")");
            }

            String cds = facilityCd.stream().map(this::escapeSql).collect(Collectors.joining("','"));

            sql.append(" AND facility_cd IN ('").append(cds).append("')");

            sqlStatements.add(sql.toString());
        }

        try {
            int[] updateCounts = jdbc.batchUpdate(sqlStatements.toArray(new String[0]));
            int totalUpdated = Arrays.stream(updateCounts).sum();

            log.info("[{}] バッチ更新完了: 処理構成数={}, 総更新行数={}",
                    taskName, sqlStatements.size(), totalUpdated);
            return totalUpdated;
        } catch (Exception e) {
            log.warn("[{}] バッチ更新失敗: {}", taskName, e.getMessage());
            return 0;
        }
    }

    /**
     * 简单的 SQL 字符串转义（单引号 -> 两个单引号）
     */
    private String escapeSql(String value) {
        if (value == null) {
            return null;
        }
        return value.replace("'", "''");
    }

    private int refreshColumnFk(JdbcTemplate jdbc, FkMigrationConfig cfg, String taskName,List<String> facilityCds) {
        ColumnTypeKind columnTypeKind = resolveColumnTypeKind(jdbc, cfg);
        String columnExpr;

        if (Boolean.TRUE.equals(cfg.getEncryptFlag())) {

            columnExpr =
                    "ntss.personal_info_decrypt(t.\""
                            + cfg.getColumnName()
                            + "\")";
        } else {

            columnExpr ="t.\"" + cfg.getColumnName() + "\"";
        }

        String  sql = "UPDATE ntss.\"" + cfg.getTableName() + "\" t"
                + " SET \"" + cfg.getColumnName() + "\" = " + buildColumnAssignmentExpression(columnTypeKind, "m.new_id", cfg)
                + " FROM ntss.pk_mapping_local m"
                + " WHERE " + buildColumnMatchCondition(columnTypeKind, columnExpr, "m.old_id")
                + " AND m.table_name = ?";
        if (cfg.getWhereTemplate() != null) {
            sql += " AND (" + cfg.getWhereTemplate() + ")";
        }
        String placeholders = facilityCds.stream()
                .map(v -> "?")
                .collect(Collectors.joining(","));
        sql += " AND t.facility_cd IN (" + placeholders + ")";
        try {
            List<Object> params = new ArrayList<>();
            params.add(cfg.getRefTable());
            params.addAll(facilityCds);
            int updated = jdbc.update(sql, params.toArray());
            if (updated > 0) {
                log.info("[{}] COLUMN 完了: table={}, column={}, refTable={}, where={}, updated={}",
                        taskName, cfg.getTableName(), cfg.getColumnName(), cfg.getRefTable(),
                        cfg.getWhereTemplate(), updated);
            } else {
                log.debug("[{}] COLUMN スキップ（更新なし）: table={}, column={}, refTable={}, where={}",
                        taskName, cfg.getTableName(), cfg.getColumnName(), cfg.getRefTable(),
                        cfg.getWhereTemplate());
            }
            return updated;
        } catch (Exception e) {
            log.warn("[{}] COLUMN スキップ（エラー）: table={}, column={}, reason={}",
                    taskName, cfg.getTableName(), cfg.getColumnName(), e.getMessage());
            return 0;
        }
    }

    private int refreshMstSelector(JdbcTemplate jdbc, List<String> facilityCds) {

        String placeholders = facilityCds.stream()
                .map(v -> "?")
                .collect(Collectors.joining(","));

        String sql = """
        WITH updated_rows AS (
            SELECT
                ms.ctid,
                jsonb_set(
                    ms.order_settings,
                    '{items}',
                    updated_items.new_items
                ) AS updated_json
            FROM ntss.mst_selector ms
            CROSS JOIN LATERAL (
                SELECT jsonb_agg(
                    CASE
                        WHEN pm.new_id IS NOT NULL THEN
                            jsonb_set(
                                item,
                                '{code}',
                                to_jsonb(pm.new_id)
                            )
                        ELSE
                            item
                    END
                    ORDER BY ordinality
                ) AS new_items
                FROM jsonb_array_elements(ms.order_settings -> 'items')
                     WITH ORDINALITY arr(item, ordinality)
                LEFT JOIN ntss.pk_mapping_local pm
                       ON pm.table_name = ms.master_physical_name
                      AND pm.old_id =
                            CASE
                                WHEN (item ->> 'code') ~ '^[0-9]+$'
                                THEN (item ->> 'code')::bigint
                                ELSE NULL
                            END
            ) updated_items
              WHERE ms.facility_cd IN (%s)
              AND jsonb_typeof(ms.order_settings -> 'items') = 'array'
        )
        UPDATE ntss.mst_selector ms
           SET order_settings = ur.updated_json,
               up_date = CURRENT_TIMESTAMP
          FROM updated_rows ur
         WHERE ms.ctid = ur.ctid
           AND ms.order_settings IS DISTINCT FROM ur.updated_json
        """;
        sql = sql.formatted(placeholders);
        return jdbc.update(sql,facilityCds.toArray());
    }
//     JSON	   json_path
//     [1,2,3]	[]
//     {"detail":[1,2,3]}	detail
//     {"a":{"b":[1,2,3]}}	a.b
//     [{"items":[1,2,3]}]	[].items
//     [{"a":{"b":[1,2,3]}}]	[].a.b
//     {"list":[{"items":[1,2,3]}]}	 list.[].items

//    [].result_value.staff_info.staff_cd
//    [
//    {
//        "format_class": 10,
//            "result_value": {
//        "staff_info": {
//            "target": "0",
//                    "staff_cd": [31075,31076,31078]
//        }
//    }
//    }
//]
    private int refreshJsonArray(
            JdbcTemplate jdbc,
            FkMigrationConfig cfg,
            List<String> facilityCds
    ) {


        JsonPathSpec path = JsonPathSpec.parse(cfg.getJsonPath());
        List<Object> params = new ArrayList<>();

        String rootExpr =
                "t." + quotedJsonColumn(cfg);

        String updateExpr =
                buildJsonUpdateSql(
                        rootExpr,
                        path.segments(),
                        0,
                        cfg,
                        "m",
                        params
                );

        String existsExpr =
                buildJsonExistsSql(
                        rootExpr,
                        path.segments(),
                        0,
                        cfg,
                        "m2",
                        params
                );
        String placeholders = facilityCds.stream()
                .map(v -> "?")
                .collect(Collectors.joining(","));

        String sql =
                "UPDATE ntss.\"" + cfg.getTableName() + "\" t "
                        + "SET \"" + cfg.getJsonColumn() + "\" = "
                        + updateExpr
                        + " WHERE EXISTS ("
                        + existsExpr
                        + ")"
                        + " AND t.facility_cd IN (" + placeholders + ")"
                        + buildArrayWhereColumn(cfg, "t.");

        params.addAll(facilityCds);
        return jdbc.update(
                sql,
                params.toArray()
        );
    }
    private String buildJsonUpdateSql(
            String currentExpr,
            List<String> segments,
            int idx,
            FkMigrationConfig cfg,
            String mappingAlias,
            List<Object> params
    ) {

        // array<int>
        if (idx >= segments.size()) {

            params.add(cfg.getRefTable());

            return """
            (
                SELECT jsonb_agg(
                    COALESCE(%s.new_id, elem.value::bigint)
                    ORDER BY elem.ordinality
                )
                FROM jsonb_array_elements_text(%s)
                     WITH ORDINALITY elem(value, ordinality)
                LEFT JOIN ntss.pk_mapping_local %s
                    ON %s.old_id = elem.value::bigint
                   AND %s.table_name = ?
            )
            """.formatted(
                    mappingAlias,
                    currentExpr,
                    mappingAlias,
                    mappingAlias,
                    mappingAlias
            );
        }

        String seg = segments.get(idx);

        /*
         * int[]
         * path = []
         */
        if ("[]".equals(seg)
                && idx == segments.size() - 1) {

            return buildJsonUpdateSql(
                    currentExpr,
                    segments,
                    idx + 1,
                    cfg,
                    mappingAlias,
                    params
            );
        }

        /*
         * array<object>
         */
        if ("[]".equals(seg)) {

            String child =
                    buildJsonUpdateSql(
                            "obj",
                            segments,
                            idx + 1,
                            cfg,
                            mappingAlias,
                            params
                    );

            return """
            (
                SELECT jsonb_agg(
                    %s
                    ORDER BY ordinality
                )
                FROM jsonb_array_elements(%s)
                     WITH ORDINALITY arr(obj, ordinality)
            )
            """.formatted(
                    child,
                    currentExpr
            );
        }

        /*
         * object
         */
        String nextExpr =
                currentExpr + " -> '" + seg + "'";

        String child =
                buildJsonUpdateSql(
                        nextExpr,
                        segments,
                        idx + 1,
                        cfg,
                        mappingAlias,
                        params
                );

//        return """
//        jsonb_set(
//            %s,
//            '{%s}',
//            %s
//        )
//        """.formatted(
//                currentExpr,
//                seg,
//                child
//        );
        return """
    CASE
        WHEN %s IS NULL
        THEN %s
        ELSE jsonb_set(
            %s,
            '{%s}',
            %s
        )
    END
    """.formatted(
                nextExpr,
                currentExpr,
                currentExpr,
                seg,
                child
        );
    }
    private String buildJsonExistsSql(
            String currentExpr,
            List<String> segments,
            int idx,
            FkMigrationConfig cfg,
            String mappingAlias,
            List<Object> params
    ) {

        if (idx >= segments.size()) {

            params.add(cfg.getRefTable());

            return """
            SELECT 1
            FROM jsonb_array_elements_text(%s) elem
            JOIN ntss.pk_mapping_local %s
              ON %s.old_id = elem.value::bigint
             AND %s.table_name = ?
            """.formatted(
                    currentExpr,
                    mappingAlias,
                    mappingAlias,
                    mappingAlias
            );
        }

        String seg = segments.get(idx);

        /*
         * int[]
         */
        if ("[]".equals(seg)
                && idx == segments.size() - 1) {

            return buildJsonExistsSql(
                    currentExpr,
                    segments,
                    idx + 1,
                    cfg,
                    mappingAlias,
                    params
            );
        }

        /*
         * array<object>
         */
        if ("[]".equals(seg)) {

            String child =
                    buildJsonExistsSql(
                            "obj",
                            segments,
                            idx + 1,
                            cfg,
                            mappingAlias,
                            params
                    );

            return """
            SELECT 1
            FROM jsonb_array_elements(%s) arr(obj)
            WHERE EXISTS (
                %s
            )
            """.formatted(
                    currentExpr,
                    child
            );
        }

        return buildJsonExistsSql(
                currentExpr + " -> '" + seg + "'",
                segments,
                idx + 1,
                cfg,
                mappingAlias,
                params
        );
    }

    private int refreshJsonFk(JdbcTemplate jdbc, FkMigrationConfig cfg, String taskName,List<String> facilityCds ) {
        if (isPatViewerDispItemInfoConfig(cfg)) {
            return refreshPatViewerDispItemInfoFk(jdbc, cfg, taskName);
        }
        if (isPatIndApproveConfig(cfg)) {
            return refreshPatIndApproveJsonFk(jdbc, cfg, taskName);
        }
        if (isTmpLogSearchConditionConfig(cfg)) {
            return refreshTmpLogSearchConditionJsonFk(jdbc, cfg, taskName);
        }
        if (isMstKurAuthenticationConfig(cfg)) {
            return refreshMstKurAuthenticationJsonFk(jdbc, cfg, taskName);
        }

        JsonPathSpec path = JsonPathSpec.parse(cfg.getJsonPath());
        int updated = 0;
        try {
            if (!path.hasWildcard()) {
                updated = refreshScalarJsonFk(jdbc, cfg, path,facilityCds);
            } else {
                updated = refreshArrayJsonFk(jdbc, cfg, path, facilityCds);
            }
            if (updated > 0) {
                log.info("[{}] JSON 完了: table={}, jsonColumn={}, path={}, refTable={}, where={}, updated={} (scalar={}, array={})",
                        taskName, cfg.getTableName(), cfg.getJsonColumn(), cfg.getJsonPath(),
                        cfg.getRefTable(), cfg.getWhereTemplate(), updated, !path.hasWildcard() ? updated : 0, path.hasWildcard() ? updated : 0);
            } else {
                log.debug("[{}] JSON スキップ（更新なし）: table={}, jsonColumn={}, path={}, refTable={}, where={}",
                        taskName, cfg.getTableName(), cfg.getJsonColumn(), cfg.getJsonPath(),
                        cfg.getRefTable(), cfg.getWhereTemplate());
            }
            return updated;
        } catch (Exception e) {
            log.warn("[{}] JSON スキップ（エラー）: table={}, jsonColumn={}, path={}, reason={}",
                    taskName, cfg.getTableName(), cfg.getJsonColumn(), cfg.getJsonPath(), e.getMessage());
            return 0;
        }
    }

    private boolean isPatViewerDispItemInfoConfig(FkMigrationConfig cfg) {
        return "disp_item_info".equals(cfg.getJsonColumn())
                && PAT_VIEWER_PATH.equals(normalizeJsonPath(cfg.getJsonPath()));
    }

    private boolean isPatIndApproveConfig(FkMigrationConfig cfg) {
        if (!List.of("content_for_map", "approve_content", "check_content").contains(cfg.getJsonColumn())) {
            return false;
        }
        String normalizedPath = normalizeJsonPath(cfg.getJsonPath());
        return PAT_IND_APPROVE_TOP_LEVEL_PATH.equals(normalizedPath)
                || PAT_IND_APPROVE_NESTED_PATH.equals(normalizedPath);
    }

    private boolean isTmpLogSearchConditionConfig(FkMigrationConfig cfg) {
        if (!"tmp_log_search_condition".equals(cfg.getJsonColumn())) {
            return false;
        }
        String normalizedPath = normalizeJsonPath(cfg.getJsonPath());
        return TMP_LOG_SEARCH_PAT_ID_PATH.equals(normalizedPath)
                || TMP_LOG_SEARCH_USER_ID_PATH.equals(normalizedPath);
    }

    private boolean isMstKurAuthenticationConfig(FkMigrationConfig cfg) {
        if (!"mst_user_authentication".equals(cfg.getJsonColumn()) || !"mst_user".equals(cfg.getRefTable())) {
            return false;
        }
        String normalizedPath = normalizeJsonPath(cfg.getJsonPath());
        return MST_KUR_USER_ID_PATH.equals(normalizedPath)
                || MST_KUR_DISP_USER_ID_PATH.equals(normalizedPath);
    }

    private String normalizeJsonPath(String rawPath) {
        if (rawPath == null) {
            return null;
        }
        return rawPath.replace(" ", "");
    }

    private String formatDbLabel(String dbLabel) {
        if (dbLabel == null || dbLabel.isBlank()) {
            return "";
        }
        return "[" + dbLabel + "] ";
    }

    private void processJsonRowsSafely(
            JdbcTemplate jdbc,
            FkMigrationConfig cfg,
            String taskName,
            String handlerName,
            JsonRowConsumer consumer) {
        String sql = "SELECT ctid::text AS row_id, \"" + cfg.getJsonColumn() + "\"::text AS json_text "
                + "FROM ntss.\"" + cfg.getTableName() + "\" "
                + "WHERE \"" + cfg.getJsonColumn() + "\" IS NOT NULL";
        try {
            jdbc.query(sql, (RowCallbackHandler) rs -> consumer.accept(rs.getString("row_id"), rs.getString("json_text")));
        } catch (Exception e) {
            log.warn("[{}] {} スキップ（取得エラー）: table={}, column={}, reason={}",
                    taskName, handlerName, cfg.getTableName(), cfg.getJsonColumn(), e.getMessage());
        }
    }

    @FunctionalInterface
    private interface JsonRowConsumer {
        void accept(String rowId, String jsonText);
    }

    private int refreshPatViewerDispItemInfoFk(JdbcTemplate jdbc, FkMigrationConfig cfg, String taskName) {
        Map<Long, Long> mapping = loadPkMapping(jdbc, cfg.getRefTable());
        if (mapping.isEmpty()) {
            log.debug("[{}] JSON(PAT_VIEWER) スキップ（mappingなし）: refTable={}", taskName, cfg.getRefTable());
            return 0;
        }

        PathConditionSet conditions = PathConditionSet.parse(cfg.getWhereTemplate(), objectMapper);

        int[] updatedRows = {0};
        processJsonRowsSafely(jdbc, cfg, taskName, "JSON(PAT_VIEWER)", (rowId, jsonText) -> {
            try {
                JsonNode root = objectMapper.readTree(jsonText);
                if (!(root instanceof ArrayNode categories)) {
                    return;
                }

                boolean changed = false;
                for (JsonNode categoryNode : categories) {
                    if (!(categoryNode instanceof ObjectNode categoryObject)) {
                        continue;
                    }
                    JsonNode categoryItemNode = categoryObject.get("categoryItem");
                    if (!(categoryItemNode instanceof ArrayNode subCategories)) {
                        continue;
                    }

                    for (JsonNode subCategoryNode : subCategories) {
                        if (!(subCategoryNode instanceof ObjectNode subCategoryObject)) {
                            continue;
                        }
                        JsonNode subCategoryItemNode = subCategoryObject.get("subCategoryItem");
                        if (!(subCategoryItemNode instanceof ArrayNode items)) {
                            continue;
                        }

                        for (JsonNode itemNode : items) {
                            if (!(itemNode instanceof ObjectNode itemObject)) {
                                continue;
                            }
                            JsonNode itemNoNode = itemObject.get("itemNo");
                            if (itemNoNode == null || itemNoNode.isNull()) {
                                continue;
                            }

                            PathConditionClause matchedClause =
                                    conditions.findMatchingClause(categoryObject, subCategoryObject, itemObject, itemNoNode);
                            if (matchedClause == null) {
                                continue;
                            }

                            if ("mst_add_monitor".equals(cfg.getRefTable())) {
                                if (replacePatViewerAddMonitorFields(itemObject, mapping)) {
                                    changed = true;
                                }
                            } else {
                                JsonNode replaced = replacePatViewerItemNo(itemNoNode, mapping, matchedClause);
                                if (replaced != null && !replaced.equals(itemNoNode)) {
                                    itemObject.set("itemNo", replaced);
                                    changed = true;
                                }
                            }
                        }
                    }
                }

                if (changed) {
                    jdbc.update(
                            "UPDATE ntss.\"" + cfg.getTableName() + "\" SET \"" + cfg.getJsonColumn() + "\" = CAST(? AS jsonb) WHERE ctid = ?::tid",
                            objectMapper.writeValueAsString(root),
                            rowId
                    );
                    updatedRows[0]++;
                }
            } catch (Exception e) {
                log.warn("[{}] JSON(PAT_VIEWER) スキップ（行エラー）: table={}, rowId={}, reason={}",
                        taskName, cfg.getTableName(), rowId, e.getMessage());
            }
        });

        return updatedRows[0];
    }

    private int refreshPatIndApproveJsonFk(JdbcTemplate jdbc, FkMigrationConfig cfg, String taskName) {
        Map<Long, Long> mapping = loadPkMapping(jdbc, cfg.getRefTable());
        if (mapping.isEmpty()) {
            log.debug("[{}] JSON(PAT_IND_APPROVE) スキップ（mappingなし）: refTable={}", taskName, cfg.getRefTable());
            return 0;
        }

        PatIndApproveConditionSet conditions = PatIndApproveConditionSet.parse(cfg.getWhereTemplate(), objectMapper);
        String normalizedPath = normalizeJsonPath(cfg.getJsonPath());

        int[] updatedRows = {0};
        processJsonRowsSafely(jdbc, cfg, taskName, "JSON(PAT_IND_APPROVE)", (rowId, jsonText) -> {
            try {
                JsonNode root = objectMapper.readTree(jsonText);
                if (!(root instanceof ArrayNode entries)) {
                    return;
                }

                boolean changed = false;
                for (JsonNode entryNode : entries) {
                    if (!(entryNode instanceof ObjectNode entryObject)) {
                        continue;
                    }

                    if (PAT_IND_APPROVE_TOP_LEVEL_PATH.equals(normalizedPath)) {
                        ObjectNode itemInfo = asObjectNode(entryObject.get("itemInfo"));
                        if (itemInfo != null && conditions.matches(entryObject, itemInfo)) {
                            changed |= replaceItemCdNode(itemInfo, mapping);
                        }
                        continue;
                    }

                    JsonNode subCategoryItemNode = entryObject.get("subCategoryItem");
                    if (!(subCategoryItemNode instanceof ArrayNode items)) {
                        continue;
                    }

                    for (JsonNode itemNode : items) {
                        if (!(itemNode instanceof ObjectNode itemObject)) {
                            continue;
                        }
                        ObjectNode itemInfo = asObjectNode(itemObject.get("itemInfo"));
                        if (itemInfo == null || !conditions.matches(entryObject, itemInfo)) {
                            continue;
                        }
                        changed |= replaceItemCdNode(itemInfo, mapping);
                    }
                }

                if (changed) {
                    jdbc.update(
                            "UPDATE ntss.\"" + cfg.getTableName() + "\" SET \"" + cfg.getJsonColumn() + "\" = CAST(? AS jsonb) WHERE ctid = ?::tid",
                            objectMapper.writeValueAsString(root),
                            rowId
                    );
                    updatedRows[0]++;
                }
            } catch (Exception e) {
                log.warn("[{}] JSON(PAT_IND_APPROVE) スキップ（行エラー）: table={}, column={}, rowId={}, reason={}",
                        taskName, cfg.getTableName(), cfg.getJsonColumn(), rowId, e.getMessage());
            }
        });

        return updatedRows[0];
    }

    private int refreshTmpLogSearchConditionJsonFk(JdbcTemplate jdbc, FkMigrationConfig cfg, String taskName) {
        Map<Long, Long> mapping = loadPkMapping(jdbc, cfg.getRefTable());
        if (mapping.isEmpty()) {
            log.debug("[{}] JSON(TMP_LOG_SEARCH) スキップ（mappingなし）: refTable={}", taskName, cfg.getRefTable());
            return 0;
        }

        String normalizedPath = normalizeJsonPath(cfg.getJsonPath());
        String targetArrayName = TMP_LOG_SEARCH_PAT_ID_PATH.equals(normalizedPath) ? "patId" : "userId";

        int[] updatedRows = {0};
        processJsonRowsSafely(jdbc, cfg, taskName, "JSON(TMP_LOG_SEARCH)", (rowId, jsonText) -> {
            try {
                JsonNode root = objectMapper.readTree(jsonText);
                if (!(root instanceof ArrayNode rootArray)) {
                    return;
                }

                boolean changed = false;
                for (JsonNode filterNode : rootArray) {
                    if (!(filterNode instanceof ObjectNode filterObject)) {
                        continue;
                    }
                    JsonNode conditionNode = filterObject.get("condition");
                    if (!(conditionNode instanceof ObjectNode conditionObject)) {
                        continue;
                    }
                    JsonNode targetNode = conditionObject.get(targetArrayName);
                    if (!(targetNode instanceof ArrayNode targetArray)) {
                        continue;
                    }

                    for (JsonNode targetItemNode : targetArray) {
                        if (!(targetItemNode instanceof ObjectNode targetItemObject)) {
                            continue;
                        }
                        JsonNode cdNode = targetItemObject.get("cd");
                        JsonNode replaced = replaceNumericLikeNode(cdNode, mapping);
                        if (replaced != null && !replaced.equals(cdNode)) {
                            targetItemObject.set("cd", replaced);
                            changed = true;
                        }
                    }
                }

                if (changed) {
                    jdbc.update(
                            "UPDATE ntss.\"" + cfg.getTableName() + "\" SET \"" + cfg.getJsonColumn() + "\" = CAST(? AS jsonb) WHERE ctid = ?::tid",
                            objectMapper.writeValueAsString(root),
                            rowId
                    );
                    updatedRows[0]++;
                }
            } catch (Exception e) {
                log.warn("[{}] JSON(TMP_LOG_SEARCH) スキップ（行エラー）: table={}, rowId={}, reason={}",
                        taskName, cfg.getTableName(), rowId, e.getMessage());
            }
        });

        return updatedRows[0];
    }

    private int refreshMstKurAuthenticationJsonFk(JdbcTemplate jdbc, FkMigrationConfig cfg, String taskName) {
        Map<Long, Long> mapping = loadPkMapping(jdbc, cfg.getRefTable());
        if (mapping.isEmpty()) {
            log.debug("[{}] JSON(MST_KUR_AUTH) スキップ（mappingなし）: refTable={}", taskName, cfg.getRefTable());
            return 0;
        }

        String normalizedPath = normalizeJsonPath(cfg.getJsonPath());
        String targetField = MST_KUR_DISP_USER_ID_PATH.equals(normalizedPath) ? "disp_user_id" : "user_id";

        int[] updatedRows = {0};
        processJsonRowsSafely(jdbc, cfg, taskName, "JSON(MST_KUR_AUTH)", (rowId, jsonText) -> {
            try {
                JsonNode root = objectMapper.readTree(jsonText);
                JsonNode dataNode = root.get("data");
                if (!(dataNode instanceof ArrayNode dataArray)) {
                    return;
                }

                boolean changed = false;
                for (JsonNode scheduleNode : dataArray) {
                    if (!(scheduleNode instanceof ObjectNode scheduleObject)) {
                        continue;
                    }

                    var fields = scheduleObject.fields();
                    while (fields.hasNext()) {
                        Map.Entry<String, JsonNode> entry = fields.next();
                        ObjectNode dayObject = asObjectNode(entry.getValue());
                        if (dayObject == null) {
                            continue;
                        }
                        JsonNode valueNode = dayObject.get(targetField);
                        JsonNode replaced = replaceNumericLikeNode(valueNode, mapping);
                        if (replaced != null && !replaced.equals(valueNode)) {
                            dayObject.set(targetField, replaced);
                            changed = true;
                        }
                    }
                }

                if (changed) {
                    jdbc.update(
                            "UPDATE ntss.\"" + cfg.getTableName() + "\" SET \"" + cfg.getJsonColumn() + "\" = CAST(? AS jsonb) WHERE ctid = ?::tid",
                            objectMapper.writeValueAsString(root),
                            rowId
                    );
                    updatedRows[0]++;
                }
            } catch (Exception e) {
                log.warn("[{}] JSON(MST_KUR_AUTH) スキップ（行エラー）: table={}, rowId={}, reason={}",
                        taskName, cfg.getTableName(), rowId, e.getMessage());
            }
        });

        return updatedRows[0];
    }

    private ObjectNode asObjectNode(JsonNode node) {
        return node instanceof ObjectNode objectNode ? objectNode : null;
    }

    private boolean replaceItemCdNode(ObjectNode itemInfo, Map<Long, Long> mapping) {
        JsonNode itemCdNode = itemInfo.get("itemCd");
        JsonNode replacedNode = replaceNumericLikeNode(itemCdNode, mapping);
        if (replacedNode == null || replacedNode.equals(itemCdNode)) {
            return false;
        }
        itemInfo.set("itemCd", replacedNode);
        return true;
    }

    private JsonNode replaceNumericLikeNode(JsonNode valueNode, Map<Long, Long> mapping) {
        if (valueNode == null || valueNode.isNull()) {
            return null;
        }

        if (valueNode.isNumber()) {
            Long newId = mapping.get(valueNode.longValue());
            return newId == null ? null : LongNode.valueOf(newId);
        }

        if (valueNode.isTextual()) {
            String value = valueNode.asText();
            if (!value.matches("^[0-9]+$")) {
                return null;
            }
            Long newId = mapping.get(Long.parseLong(value));
            return newId == null ? null : TextNode.valueOf(String.valueOf(newId));
        }

        return null;
    }

    private Map<Long, Long> loadPkMapping(JdbcTemplate jdbc, String refTable) {
        Map<Long, Long> mapping = new LinkedHashMap<>();
        jdbc.query(
                "SELECT old_id, new_id FROM ntss.pk_mapping_local WHERE table_name = ?",
                (RowCallbackHandler) rs -> mapping.put(rs.getLong("old_id"), rs.getLong("new_id")),
                refTable);
        return mapping;
    }

    private JsonNode replacePatViewerItemNo(JsonNode itemNoNode, Map<Long, Long> mapping, PathConditionClause matchedClause) {
        List<String> prefixes = matchedClause.itemNoPrefixes();
        if (!prefixes.isEmpty()) {
            if (!itemNoNode.isTextual()) {
                return null;
            }
            String value = itemNoNode.asText();
            for (String prefix : prefixes) {
                if (!value.startsWith(prefix)) {
                    continue;
                }
                String suffix = value.substring(prefix.length());
                if (!suffix.matches("^[0-9]+$")) {
                    return null;
                }
                Long newId = mapping.get(Long.parseLong(suffix));
                if (newId == null) {
                    return null;
                }
                return TextNode.valueOf(prefix + newId);
            }
            return null;
        }

        if (matchedClause.requiresNumericItemNo()) {
            if (itemNoNode.isNumber()) {
                Long newId = mapping.get(itemNoNode.longValue());
                return newId == null ? null : LongNode.valueOf(newId);
            }
            if (itemNoNode.isTextual()) {
                String value = itemNoNode.asText();
                if (!value.matches("^[0-9]+$")) {
                    return null;
                }
                Long newId = mapping.get(Long.parseLong(value));
                return newId == null ? null : TextNode.valueOf(String.valueOf(newId));
            }
            return null;
        }

        if (itemNoNode.isTextual()) {
            String value = itemNoNode.asText();
            if (!value.matches("^[0-9]+$")) {
                return null;
            }
            Long newId = mapping.get(Long.parseLong(value));
            return newId == null ? null : TextNode.valueOf(String.valueOf(newId));
        }
        if (itemNoNode.isNumber()) {
            Long newId = mapping.get(itemNoNode.longValue());
            return newId == null ? null : LongNode.valueOf(newId);
        }
        return null;
    }

    private boolean replacePatViewerAddMonitorFields(ObjectNode itemObject, Map<Long, Long> mapping) {
        boolean changed = false;

        JsonNode itemNoNode = itemObject.get("itemNo");
        JsonNode replacedItemNo = replaceAddMonitorEncodedNode(itemNoNode, mapping);
        if (replacedItemNo != null && !replacedItemNo.equals(itemNoNode)) {
            itemObject.set("itemNo", replacedItemNo);
            changed = true;
        }

        JsonNode moniNoNode = itemObject.get("moniNo");
        JsonNode replacedMoniNo = replaceAddMonitorEncodedNode(moniNoNode, mapping);
        if (replacedMoniNo != null && !replacedMoniNo.equals(moniNoNode)) {
            itemObject.set("moniNo", replacedMoniNo);
            changed = true;
        }

        return changed;
    }

    private JsonNode replaceAddMonitorEncodedNode(JsonNode encodedNode, Map<Long, Long> mapping) {
        if (encodedNode == null || encodedNode.isNull()) {
            return null;
        }

        if (encodedNode.isTextual()) {
            String value = encodedNode.asText();
            if (value.matches("^[^*]+\\*[^*]+\\*[0-9]+$")) {
                String[] parts = value.split("\\*");
                long encodedId = Long.parseLong(parts[2]);
                if (encodedId <= 10000) {
                    return null;
                }
                Long mappedId = mapping.get(encodedId - 10000);
                if (mappedId == null) {
                    return null;
                }
                return TextNode.valueOf(parts[0] + "*" + parts[1] + "*" + (mappedId + 10000));
            }
            if (value.matches("^[0-9]+$")) {
                long encodedId = Long.parseLong(value);
                if (encodedId <= 10000) {
                    return null;
                }
                Long mappedId = mapping.get(encodedId - 10000);
                if (mappedId == null) {
                    return null;
                }
                return TextNode.valueOf(String.valueOf(mappedId + 10000));
            }
            return null;
        }

        if (encodedNode.isNumber()) {
            long encodedId = encodedNode.longValue();
            if (encodedId <= 10000) {
                return null;
            }
            Long mappedId = mapping.get(encodedId - 10000);
            if (mappedId == null) {
                return null;
            }
            return LongNode.valueOf(mappedId + 10000);
        }

        return null;
    }

    private int refreshScalarJsonFk(JdbcTemplate jdbc, FkMigrationConfig cfg, JsonPathSpec path,List<String> facilityCds) {
        String rootExpr = quotedJsonColumn(cfg);
        String targetExpr = buildJsonExtractExpression(rootExpr, path.scalarSegments());
        String matchCondition = buildPkMatchCondition(targetExpr, "m");
        String replacementExpr = buildReplacementJsonExpression(targetExpr, "m.new_id");
        String sql = "UPDATE ntss.\"" + cfg.getTableName() + "\""
                + " SET \"" + cfg.getJsonColumn() + "\" = "
                + buildJsonSetExpression(rootExpr, path.scalarSegments(), replacementExpr)
                + " FROM ntss.pk_mapping_local m"
                + " WHERE COALESCE(jsonb_typeof(" + rootExpr + "), '') <> 'array'"
                + " AND " + matchCondition
                + " AND m.table_name = ?";
        String whereClause = adaptWhereTemplate(cfg, rootExpr, false);
        if (whereClause != null) {
            sql += " AND (" + whereClause + ")";
        }

        String placeholders = facilityCds.stream()
                .map(v -> "?")
                .collect(Collectors.joining(","));
        sql += " AND facility_cd IN ("+placeholders+")";
        List<Object> params = new ArrayList<>();
        params.add(cfg.getRefTable());
        params.addAll(facilityCds);
        return jdbc.update(sql,  params.toArray());
    }


    private int refreshArrayJsonFk(
            JdbcTemplate jdbc,
            FkMigrationConfig cfg,
            JsonPathSpec path,List<String> facilityCds
    ) {

        List<Object> params = new ArrayList<>();
        String rootExpr =
                "t." + quotedJsonColumn(cfg);


        if (Boolean.TRUE.equals(cfg.getEncryptFlag())) {
            rootExpr =
                    "ntss.personal_info_decrypt("
                            + rootExpr
                            + ")";
        }

        String updateExpr =
                buildRecursiveUpdateSql(
                        rootExpr,
                        path.segments(),
                        0,
                        cfg,
                        "m",
                        params
                );

        String existsExpr =
                buildRecursiveExistsSql(
                        rootExpr,
                        path.segments(),
                        0,
                        cfg,
                        "m2",
                        params
                );
        if (Boolean.TRUE.equals(cfg.getEncryptFlag())) {
            updateExpr =
                    "ntss.personal_info_encrypt("
                            + updateExpr
                            + ")";

        }

        String placeholders = facilityCds.stream()
                .map(v -> "?")
                .collect(Collectors.joining(","));
        String sql =
                "UPDATE ntss.\"" + cfg.getTableName() + "\" t "
                        + "SET \"" + cfg.getJsonColumn() + "\" = "
                        + updateExpr
                        + " WHERE " +
                        "  EXISTS ("
                        + existsExpr
                        + ")"
                        + " AND facility_cd IN ("+placeholders+")"
                        + buildArrayWhereColumn(cfg,"t.");
        params.addAll(facilityCds);
        return jdbc.update(
                sql,
                params.toArray()
        );
    }
    private String buildRecursiveUpdateSql(
            String currentExpr,
            List<String> segments,
            int index,
            FkMigrationConfig cfg,
            String mappingAlias,
            List<Object> params
    ) {

        if (index == segments.size() - 1) {

            String field =
                    segments.get(index);

            String targetExpr =
                    currentExpr + " #> '{" + field + "}'";

            String matchCondition =
                    buildPkMatchCondition(
                            targetExpr,
                            mappingAlias
                    );

            String replacementExpr =
                    buildReplacementJsonExpression(
                            targetExpr,
                            mappingAlias + ".new_id"
                    );

            return
                    "CASE "
                            + "WHEN (" + matchCondition + ") "
                            + "AND " + mappingAlias + ".new_id IS NOT NULL "
                            + "THEN "
                            + "jsonb_set("
                            + currentExpr
                            + ", '{"
                            + field
                            + "}', "
                            + replacementExpr
                            + ") "
                            + "ELSE "
                            + currentExpr
                            + " END";
        }

        String segment =
                segments.get(index);

        if ("[]".equals(segment)) {

            String arrAlias =
                    "arr" + index;

            String childExpr =
                    buildRecursiveUpdateSql(
                            arrAlias + ".elem",
                            segments,
                            index + 1,
                            cfg,
                            mappingAlias,
                            params
                    );
            params.add(cfg.getRefTable());
            String whereCondition =
                    buildArrayWhereCondition(
                            cfg,
                            arrAlias + ".elem"
                    );
            return
                    "("
                            + "SELECT jsonb_agg("
                            + childExpr
                            + " ORDER BY "
                            + arrAlias
                            + ".ord)"
                            + " FROM jsonb_array_elements("
                            + currentExpr
                            + ") WITH ORDINALITY AS "
                            + arrAlias
                            + "(elem, ord)"

                            + " LEFT JOIN ntss.pk_mapping_local "
                            + mappingAlias

                            + " ON "
                            + buildPkMatchCondition(
                            buildJsonAccessExpr(
                                    arrAlias + ".elem",
                                    segments,
                                    index + 1
                            ),
                            mappingAlias
                    )

                            + " AND "
                            + mappingAlias
                            + ".table_name = ?"
                            + whereCondition
                            + " )";
        }

        String updatedChild =
                buildRecursiveUpdateSql(
                        currentExpr + " -> '" + segment + "'",
                        segments,
                        index + 1,
                        cfg,
                        mappingAlias,
                        params
                );

        return
                "jsonb_set("
                        + currentExpr
                        + ", '{"
                        + segment
                        + "}', "
                        + updatedChild
                        + ")";
    }
    private String buildJsonAccessExpr(
            String rootExpr,
            List<String> segments,
            int startIndex
    ) {

        String expr = rootExpr;

        for (int i = startIndex; i < segments.size() - 1; i++) {

            String seg = segments.get(i);

            if ("[]".equals(seg)) {
                continue;
            }

            expr += " -> '" + seg + "'";
        }

        expr += " #> '{"
                + segments.get(segments.size() - 1)
                + "}'";

        return expr;
    }

    private String buildRecursiveExistsSql(
            String currentExpr,
            List<String> segments,
            int index,
            FkMigrationConfig cfg,
            String mappingAlias,
            List<Object> params
    ) {

        if (index == segments.size() - 1) {

            String field =
                    segments.get(index);

            String targetExpr =
                    currentExpr + " #> '{" + field + "}'";

            String matchCondition =
                    buildPkMatchCondition(
                            targetExpr,
                            mappingAlias
                    );

            params.add(cfg.getRefTable());

            return
                    "SELECT 1 "
                            + "FROM ntss.pk_mapping_local "
                            + mappingAlias
                            + " WHERE "
                            + matchCondition
                            + " AND "
                            + mappingAlias
                            + ".table_name = ?";
        }

        String segment =
                segments.get(index);

        if ("[]".equals(segment)) {

            String arrAlias =
                    "arrx" + index;

            return
                    "SELECT 1 "
                            + "FROM jsonb_array_elements("
                            + currentExpr
                            + ") AS "
                            + arrAlias
                            + "(elem) "
                            + " WHERE EXISTS ("
                            + buildRecursiveExistsSql(
                            arrAlias + ".elem",
                            segments,
                            index + 1,
                            cfg,
                            mappingAlias,
                            params
                    )
                            + ")";
        }

        return buildRecursiveExistsSql(
                currentExpr + " -> '" + segment + "'",
                segments,
                index + 1,
                cfg,
                mappingAlias,
                params
        );
    }
    private String buildArrayWhereCondition(FkMigrationConfig cfg, String contextExpr) {
        String whereClause = adaptWhereTemplate(cfg, contextExpr, true);
        return whereClause != null ? " AND (" + whereClause + ")" : "";
    }

    private String buildArrayWhereColumn(FkMigrationConfig cfg, String contextExpr) {

        String whereClause = cfg.getWhereColumn();
        return whereClause != null ? " AND (" + contextExpr+whereClause + ")" : "";
    }

    private String buildExistsWhereClause(FkMigrationConfig cfg, String contextExpr) {
        String whereClause = adaptWhereTemplate(cfg, contextExpr, true);
        return whereClause != null ? " WHERE (" + whereClause + ")" : "";
    }

    private String adaptWhereTemplate(FkMigrationConfig cfg, String contextExpr, boolean arrayContext) {
        if (cfg.getWhereTemplate() == null || cfg.getWhereTemplate().isBlank()) {
            return null;
        }

        String adapted = cfg.getWhereTemplate();
        if (adapted.contains("@")) {
            return adapted.replace("@", contextExpr);
        }

        if (!arrayContext) {
            return adapted;
        }

        adapted = adapted.replace("\"" + cfg.getJsonColumn() + "\"", contextExpr);

        String tokenPattern = "(?<![A-Za-z0-9_])"
                + Pattern.quote(cfg.getJsonColumn())
                + "(?![A-Za-z0-9_])";
        return adapted.replaceAll(tokenPattern, Matcher.quoteReplacement(contextExpr));
    }

    private String quotedJsonColumn(FkMigrationConfig cfg) {
        return "\"" + cfg.getJsonColumn() + "\"";
    }

    private String buildJsonExtractExpression(String rootExpr, List<String> pathSegments) {
        if (pathSegments.isEmpty()) {
            return rootExpr;
        }
        return rootExpr + "#>'" + toPgTextArrayLiteral(pathSegments) + "'";
    }

    private String buildJsonSetExpression(String rootExpr, List<String> pathSegments, String replacementExpr) {
        if (pathSegments.isEmpty()) {
            return replacementExpr;
        }
        return "jsonb_set(" + rootExpr + ", '" + toPgTextArrayLiteral(pathSegments) + "', " + replacementExpr + ")";
    }

    private String buildPkMatchCondition(String jsonExpr, String mappingAlias) {
        String typeExpr = "jsonb_typeof(" + jsonExpr + ")";
        String scalarTextExpr = "(" + jsonExpr + " #>> '{}')";
        return "CASE"
                + " WHEN " + typeExpr + " IN ('number', 'string')"
                + " AND " + scalarTextExpr + " ~ '^[0-9]+$'"
                + " THEN " + scalarTextExpr + "::bigint = " + mappingAlias + ".old_id"
                + " ELSE FALSE"
                + " END";
    }

    private String buildReplacementJsonExpression(String jsonExpr, String newIdExpr) {
        String typeExpr = "jsonb_typeof(" + jsonExpr + ")";
        return "CASE WHEN " + typeExpr + " = 'string'"
                + " THEN to_jsonb((" + newIdExpr + ")::text)"
                + " ELSE to_jsonb(" + newIdExpr + ") END";
    }

    private ColumnTypeKind resolveColumnTypeKind(JdbcTemplate jdbc, FkMigrationConfig cfg) {
        String cacheKey = cfg.getTableName() + "." + cfg.getColumnName();
        return columnTypeCache.computeIfAbsent(cacheKey, key -> jdbc.query(
                """
                SELECT data_type, udt_name
                  FROM information_schema.columns
                 WHERE table_schema = 'ntss'
                   AND table_name = ?
                   AND column_name = ?
                """,
                (rs, rowNum) -> classifyColumnType(rs.getString("data_type"), rs.getString("udt_name")),
                cfg.getTableName(),
                cfg.getColumnName()
        ).stream().findFirst().orElse(ColumnTypeKind.NUMERIC));
    }

    private ColumnTypeKind classifyColumnType(String dataType, String udtName) {
        String normalizedDataType = dataType == null ? "" : dataType.toLowerCase();
        String normalizedUdtName = udtName == null ? "" : udtName.toLowerCase();
        if (normalizedDataType.contains("character")
                || normalizedDataType.equals("text")
                || normalizedUdtName.equals("varchar")
                || normalizedUdtName.equals("bpchar")
                || normalizedUdtName.equals("text")) {
            return ColumnTypeKind.STRING;
        }
        return ColumnTypeKind.NUMERIC;
    }

    private String buildColumnMatchCondition(ColumnTypeKind columnTypeKind, String columnExpr, String oldIdExpr) {
        if (columnTypeKind == ColumnTypeKind.STRING) {
            return "CASE"
                    + " WHEN " + columnExpr + " ~ '^[0-9]+$'"
                    + " THEN " + columnExpr + "::bigint = " + oldIdExpr
                    + " ELSE FALSE"
                    + " END";
        }
        return columnExpr + " = " + oldIdExpr;
    }

    private String buildColumnAssignmentExpression(ColumnTypeKind columnTypeKind, String newIdExpr, FkMigrationConfig cfg) {

        String valueExpr;

        if (columnTypeKind == ColumnTypeKind.STRING) {
            valueExpr = "(" + newIdExpr + ")::text";
        } else {
            valueExpr = newIdExpr;
        }

        // encrypt
        if (Boolean.TRUE.equals(cfg.getEncryptFlag())) {

            valueExpr = "ntss.personal_info_encrypt(" + valueExpr + ")";
        }

        return valueExpr;
    }

    private String toPgTextArrayLiteral(List<String> segments) {
        return "{" + segments.stream().map(this::escapePgPathSegment).reduce((a, b) -> a + "," + b).orElse("") + "}";
    }

    private String escapePgPathSegment(String segment) {
        String escaped = segment.replace("\\", "\\\\").replace("\"", "\\\"");
        if (escaped.matches("[A-Za-z0-9_\\-]+")) {
            return escaped;
        }
        return "\"" + escaped + "\"";
    }

    private record JsonArrayPathSpec(
            List<String> arrayPrefixSegments,
            List<String> elementTargetSegments,
            boolean explicitWildcard
    ) {}

    private record PathConditionSet(List<PathConditionClause> clauses) {
        static PathConditionSet parse(String raw, ObjectMapper objectMapper) {
            if (raw == null || raw.isBlank()) {
                return new PathConditionSet(List.of(new PathConditionClause(Map.of())));
            }

            String trimmed = raw.trim();
            if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {
                return new PathConditionSet(List.of(new PathConditionClause(Map.of())));
            }

            try {
                JsonNode node = objectMapper.readTree(trimmed);
                if (node.isObject()) {
                    return new PathConditionSet(List.of(PathConditionClause.from((ObjectNode) node)));
                }
                if (node.isArray()) {
                    List<PathConditionClause> clauses = new ArrayList<>();
                    for (JsonNode clauseNode : node) {
                        if (clauseNode instanceof ObjectNode objectNode) {
                            clauses.add(PathConditionClause.from(objectNode));
                        }
                    }
                    return new PathConditionSet(clauses.isEmpty()
                            ? List.of(new PathConditionClause(Map.of()))
                            : clauses);
                }
            } catch (Exception ignored) {
                // 旧来の SQL where_template はこの特殊処理では使わない
            }

            return new PathConditionSet(List.of(new PathConditionClause(Map.of())));
        }

        PathConditionClause findMatchingClause(ObjectNode category, ObjectNode subCategory, ObjectNode item, JsonNode itemNo) {
            return clauses.stream()
                    .filter(clause -> clause.matches(category, subCategory, item, itemNo))
                    .findFirst()
                    .orElse(null);
        }
    }

    private record PathConditionClause(Map<String, List<String>> conditions) {
        static PathConditionClause from(ObjectNode objectNode) {
            Map<String, List<String>> parsed = new LinkedHashMap<>();
            objectNode.fields().forEachRemaining(entry -> {
                JsonNode value = entry.getValue();
                if (value.isArray()) {
                    List<String> values = new ArrayList<>();
                    value.forEach(node -> values.add(node.asText()));
                    parsed.put(entry.getKey(), values);
                } else {
                    parsed.put(entry.getKey(), List.of(value.asText()));
                }
            });
            return new PathConditionClause(parsed);
        }

        boolean matches(ObjectNode category, ObjectNode subCategory, ObjectNode item, JsonNode itemNoNode) {
            for (Map.Entry<String, List<String>> entry : conditions.entrySet()) {
                if (!matchesCondition(entry.getKey(), entry.getValue(), category, subCategory, item, itemNoNode)) {
                    return false;
                }
            }
            return true;
        }

        List<String> values(String key) {
            return conditions.getOrDefault(key, List.of());
        }

        List<String> itemNoPrefixes() {
            return values("item.itemNoPrefix").stream()
                    .distinct()
                    .sorted(Comparator.comparingInt(String::length).reversed())
                    .toList();
        }

        boolean requiresNumericItemNo() {
            return values("item.itemNoType").stream().anyMatch("numeric"::equalsIgnoreCase);
        }

        private boolean matchesCondition(
                String key,
                List<String> expectedValues,
                ObjectNode category,
                ObjectNode subCategory,
                ObjectNode item,
                JsonNode itemNoNode) {
            if ("item.itemNoType".equals(key)) {
                return expectedValues.stream().anyMatch(value -> matchesItemNoType(value, itemNoNode));
            }
            if ("item.itemNoPrefix".equals(key)) {
                return itemNoNode.isTextual()
                        && expectedValues.stream().anyMatch(prefix -> itemNoNode.asText().startsWith(prefix));
            }

            JsonNode actualNode = resolveNode(key, category, subCategory, item);
            if (actualNode == null || actualNode.isNull()) {
                return false;
            }
            String actualValue = actualNode.asText();
            return expectedValues.contains(actualValue);
        }

        private boolean matchesItemNoType(String expectedType, JsonNode itemNoNode) {
            return switch (expectedType) {
                case "numeric" -> isNumericItemNo(itemNoNode);
                case "text" -> itemNoNode.isTextual();
                default -> false;
            };
        }

        private boolean isNumericItemNo(JsonNode itemNoNode) {
            if (itemNoNode == null || itemNoNode.isNull()) {
                return false;
            }
            if (itemNoNode.isNumber()) {
                return true;
            }
            return itemNoNode.isTextual() && itemNoNode.asText().matches("^[0-9]+$");
        }

        private JsonNode resolveNode(String key, ObjectNode category, ObjectNode subCategory, ObjectNode item) {
            String[] parts = key.split("\\.");
            if (parts.length != 2) {
                return null;
            }
            return switch (parts[0]) {
                case "category" -> category.get(parts[1]);
                case "subCategory" -> subCategory.get(parts[1]);
                case "item" -> item.get(parts[1]);
                default -> null;
            };
        }
    }

    private record PatIndApproveConditionSet(List<PatIndApproveConditionClause> clauses) {
        static PatIndApproveConditionSet parse(String raw, ObjectMapper objectMapper) {
            if (raw == null || raw.isBlank()) {
                return new PatIndApproveConditionSet(List.of(new PatIndApproveConditionClause(Map.of())));
            }

            String trimmed = raw.trim();
            if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {
                return new PatIndApproveConditionSet(List.of(new PatIndApproveConditionClause(Map.of())));
            }

            try {
                JsonNode node = objectMapper.readTree(trimmed);
                if (node.isObject()) {
                    return new PatIndApproveConditionSet(List.of(PatIndApproveConditionClause.from((ObjectNode) node)));
                }
                if (node.isArray()) {
                    List<PatIndApproveConditionClause> clauses = new ArrayList<>();
                    for (JsonNode clauseNode : node) {
                        if (clauseNode instanceof ObjectNode objectNode) {
                            clauses.add(PatIndApproveConditionClause.from(objectNode));
                        }
                    }
                    return new PatIndApproveConditionSet(clauses.isEmpty()
                            ? List.of(new PatIndApproveConditionClause(Map.of()))
                            : clauses);
                }
            } catch (Exception ignored) {
                // 旧来の SQL where_template はこの特殊処理では使わない
            }

            return new PatIndApproveConditionSet(List.of(new PatIndApproveConditionClause(Map.of())));
        }

        boolean matches(ObjectNode entry, ObjectNode itemInfo) {
            return clauses.stream().anyMatch(clause -> clause.matches(entry, itemInfo));
        }
    }

    private record PatIndApproveConditionClause(Map<String, List<String>> conditions) {
        static PatIndApproveConditionClause from(ObjectNode objectNode) {
            Map<String, List<String>> parsed = new LinkedHashMap<>();
            objectNode.fields().forEachRemaining(entry -> {
                JsonNode value = entry.getValue();
                if (value.isArray()) {
                    List<String> values = new ArrayList<>();
                    value.forEach(node -> values.add(node.asText()));
                    parsed.put(entry.getKey(), values);
                } else {
                    parsed.put(entry.getKey(), List.of(value.asText()));
                }
            });
            return new PatIndApproveConditionClause(parsed);
        }

        boolean matches(ObjectNode entry, ObjectNode itemInfo) {
            for (Map.Entry<String, List<String>> condition : conditions.entrySet()) {
                JsonNode actualNode = resolveNode(condition.getKey(), entry, itemInfo);
                if (actualNode == null || actualNode.isNull()) {
                    return false;
                }
                if (!condition.getValue().contains(actualNode.asText())) {
                    return false;
                }
            }
            return true;
        }

        private JsonNode resolveNode(String key, ObjectNode entry, ObjectNode itemInfo) {
            String[] parts = key.split("\\.");
            if (parts.length != 2) {
                return null;
            }

            return switch (parts[0]) {
                case "entry" -> entry.get(parts[1]);
                case "item" -> itemInfo.get(parts[1]);
                default -> null;
            };
        }
    }

    private enum ColumnTypeKind {
        NUMERIC,
        STRING
    }

    private record JsonPathSpec(
            List<String> segments,
            List<Integer> wildcardIndexes,
            boolean legacyBraceSyntax
    ) {

        static JsonPathSpec parse(String rawPath) {

            if (rawPath == null || rawPath.isBlank()) {
                throw new IllegalArgumentException("json_path が未設定です。");
            }

            String trimmed = rawPath.trim();
            
            if (trimmed.startsWith("{") && trimmed.endsWith("}")) {

                String body =
                        trimmed.substring(1, trimmed.length() - 1).trim();

                List<String> parts =
                        body.isEmpty()
                                ? List.of()
                                : List.of(body.split("\\s*,\\s*"));

                return new JsonPathSpec(
                        parts,
                        List.of(),
                        true
                );
            }

            List<String> parts =
                    List.of(trimmed.split("\\."));

            List<Integer> wildcards = new ArrayList<>();

            for (int i = 0; i < parts.size(); i++) {

                if ("[]".equals(parts.get(i))) {
                    wildcards.add(i);
                }
            }

            return new JsonPathSpec(
                    parts,
                    wildcards,
                    false
            );
        }

        boolean hasWildcard() {
            return !wildcardIndexes.isEmpty();
        }

        int wildcardDepth() {
            return wildcardIndexes.size();
        }

        List<String> scalarSegments() {
            return segments.stream()
                    .filter(s -> !"[]".equals(s))
                    .toList();
        }

        boolean isWildcardSegment(int index) {
            return wildcardIndexes.contains(index);
        }




    }

    /*
     *
     * [].{a,b}
     * *.{a,b}
     *
     * 例えば:
     *
     * [].{ind_user_id,upd_user_id}
     * *.{ind_user_id,upd_user_id}
     */
// JSON                                json_path
// {"id":1}                            id
// {"a":{"id":1}}                      a.id
// [{"id":1}]                          [].id
// {"list":[{"id":1}]}                 list.[].id
// {"ind_user_id":1,"upd_user_id":2}  {ind_user_id,upd_user_id}
// [{"ind_user_id":1,"upd_user_id":2}] [].{ind_user_id,upd_user_id}
    private int refreshWildcardMultiFieldJsonFk(
            JdbcTemplate jdbc,
            FkMigrationConfig cfg,
            String taskName,
            List<String> facilityCds
    ) {

        //JsonPathSpec path=JsonPathSpec.parse(cfg.getJsonPath());

        List<Object> params = new ArrayList<>();

        String rootExpr =
                "t." + quotedJsonColumn(cfg);

        /*
         * decrypt
         */
        if (Boolean.TRUE.equals(cfg.getEncryptFlag())) {

            rootExpr =
                    "ntss.personal_info_decrypt("
                            + rootExpr
                            + ")";
        }

        String jsonPath = cfg.getJsonPath();

        boolean arrayMode =
                jsonPath.startsWith("[].");

        /*
         * {a,b,c}
         */
        String fieldPart =
                jsonPath.substring(
                        jsonPath.indexOf('{') + 1,
                        jsonPath.indexOf('}')
                );

        List<String> fields =
                Arrays.stream(fieldPart.split(","))
                        .map(String::trim)
                        .toList();

        /*
         * build update sql
         */
        String updateExpr =
                buildWildcardMultiFieldUpdateSql(
                        rootExpr,
                        fields,
                        arrayMode,
                        cfg,
                        "m",
                        params
                );

        /*
         * build exists sql
         */
        String existsExpr =
                buildWildcardMultiFieldExistsSql(
                        rootExpr,
                        fields,
                        arrayMode,
                        cfg,
                        "m2",
                        params
                );

        /*
         * encrypt
         */
        if (Boolean.TRUE.equals(cfg.getEncryptFlag())) {

            updateExpr =
                    "ntss.personal_info_encrypt("
                            + updateExpr
                            + ")";
        }

        String placeholders = facilityCds.stream()
                .map(v -> "?")
                .collect(Collectors.joining(","));

        String sql =
                "UPDATE ntss.\""
                        + cfg.getTableName()
                        + "\" t "
                        + "SET \""
                        + cfg.getJsonColumn()
                        + "\" = "
                        + updateExpr
                        + " WHERE EXISTS ("
                        + existsExpr
                        + ")"
                       + " AND facility_cd IN ("+placeholders+") "
                        + buildArrayWhereColumn(cfg, "t.");

        params.addAll(facilityCds);
        int len=0;
        try {
            len=   jdbc.update(
                    sql,
                    params.toArray());
        }catch (Exception e) {
            log.error("[{}] FK更新に失敗しました: table={}, type={}", taskName, cfg.getTableName(), cfg.getFkType(), e);
        }

        return len;

    }

    private String buildWildcardMultiFieldUpdateSql(
            String rootExpr,
            List<String> fields,
            boolean arrayMode,
            FkMigrationConfig cfg,
            String mappingAlias,
            List<Object> params
    ) {

        String baseExpr =
                arrayMode ? "obj" : "e.value";

        String resultExpr = baseExpr;

        for (String field : fields) {

            params.add(cfg.getRefTable());

            resultExpr = """
            jsonb_set(
                %s,
                '{%s}',
                CASE
                    WHEN %s -> '%s' IS NOT NULL
                     AND (%s ->> '%s') ~ '^[0-9]+$'
                    THEN to_jsonb(
                            COALESCE(
                                (
                                    SELECT %s.new_id
                                    FROM ntss.pk_mapping_local %s
                                    WHERE %s.old_id =
                                        (%s ->> '%s')::bigint
                                      AND %s.table_name = ?
                                ),
                                (%s ->> '%s')::bigint
                            )
                         )
                    ELSE to_jsonb(%s -> '%s')
                END
            )
            """.formatted(
                    resultExpr,
                    field,
                    baseExpr,
                    field,
                    baseExpr,
                    field,
                    mappingAlias,
                    mappingAlias,
                    mappingAlias,
                    baseExpr,
                    field,
                    mappingAlias,
                    baseExpr,
                    field,
                    baseExpr,
                    field
            );
        }

        if (arrayMode) {

            return """
            (
                SELECT jsonb_agg(
                    %s
                    ORDER BY ordinality
                )
                FROM jsonb_array_elements(%s)
                     WITH ORDINALITY arr(obj, ordinality)
            )
            """.formatted(
                    resultExpr,
                    rootExpr
            );
        }

        return """
        (
            SELECT jsonb_object_agg(
                e.key,
                %s
            )
            FROM jsonb_each(%s) e
        )
        """.formatted(
                resultExpr,
                rootExpr
        );
    }


    private String buildWildcardMultiFieldExistsSql(
            String rootExpr,
            List<String> fields,
            boolean arrayMode,
            FkMigrationConfig cfg,
            String mappingAlias,
            List<Object> params
    ) {

        String existsCondition =
                fields.stream()
                        .map(field -> {

                            params.add(cfg.getRefTable());

                            return """
                            (
                                %s -> '%s' IS NOT NULL
                                AND (%s ->> '%s') ~ '^[0-9]+$'
                                AND EXISTS (
                                    SELECT 1
                                    FROM ntss.pk_mapping_local %s
                                    WHERE %s.old_id =
                                        (%s ->> '%s')::bigint
                                      AND %s.table_name = ?
                                )
                            )
                            """.formatted(
                                    arrayMode ? "obj" : "e.value",
                                    field,
                                    arrayMode ? "obj" : "e.value",
                                    field,
                                    mappingAlias,
                                    mappingAlias,
                                    arrayMode ? "obj" : "e.value",
                                    field,
                                    mappingAlias
                            );
                        })
                        .collect(Collectors.joining(" OR "));

        /*
         * [].{a,b}
         */
        if (arrayMode) {

            return """
            SELECT 1
            FROM jsonb_array_elements(%s) arr(obj)
            WHERE %s
            """.formatted(
                    rootExpr,
                    existsCondition
            );
        }

        /*
         * *.{a,b}
         */
        return """
        SELECT 1
        FROM jsonb_each(%s) e
        WHERE %s
        """.formatted(
                rootExpr,
                existsCondition
        );
    }



}
