package com.fnsi.cloudconverter.facility;

import com.fnsi.cloudconverter.facility.model.FacilityCountResponse;
import com.fnsi.cloudconverter.facility.model.FacilityInfo;
import com.fnsi.cloudconverter.facility.model.FacilityListResponse;
import com.fnsi.cloudconverter.facility.model.FacilitySeqReservePlanItem;
import com.fnsi.cloudconverter.facility.model.FacilitySeqReservePlanResponse;
import com.fnsi.cloudconverter.migration.pg.PgDumpConfig;
import com.fnsi.cloudconverter.migration.pg.PgTableConfig;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 施設一覧サービス実装
 * 在線生産 RDS (onlineDefaultJdbc / onlinePersonalJdbc) に対してクエリを実行する
 * 参照: 03_module.md § Module 16 / 02_api.md § 5,6
 */
@Service
public class FacilityServiceImpl implements FacilityService {

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(FacilityServiceImpl.class);

    /** on2off で実際にシーケンス予約対象とする DB */
    private static final Set<String> COUNTABLE_DBS = Set.of("ntss_db5", "ntss_db6");

    private final JdbcTemplate onlineDefaultJdbc;
    private final JdbcTemplate onlinePersonalJdbc;
    private final PgDumpConfig pgDumpConfig;

    public FacilityServiceImpl(
            @Qualifier("onlineDefaultJdbc") JdbcTemplate onlineDefaultJdbc,
            @Qualifier("onlinePersonalJdbc") JdbcTemplate onlinePersonalJdbc,
            PgDumpConfig pgDumpConfig) {
        this.onlineDefaultJdbc  = onlineDefaultJdbc;
        this.onlinePersonalJdbc = onlinePersonalJdbc;
        this.pgDumpConfig       = pgDumpConfig;
    }

    @Override
    public FacilityListResponse getFacilities(int page, int size, String keyword) {
        long total;
        List<FacilityInfo> facilities;

        if (keyword != null && !keyword.isBlank()) {
            String like = "%" + keyword + "%";
            total = countFacilities(like);
            facilities = queryFacilities(like, size, (long) page * size);
        } else {
            total = countFacilities(null);
            facilities = queryFacilities(null, size, (long) page * size);
        }

        log.debug("[FACILITY] 一覧取得: total={}, page={}, size={}, keyword={}", total, page, size, keyword);
        return new FacilityListResponse(total, page, size, facilities);
    }

    private long countFacilities(String like) {
        if (like != null) {
            Long count = onlineDefaultJdbc.queryForObject(
                    "SELECT COUNT(*) FROM ntss.mst_facility WHERE facility_name LIKE ?",
                    Long.class, like);
            return count != null ? count : 0L;
        } else {
            Long count = onlineDefaultJdbc.queryForObject(
                    "SELECT COUNT(*) FROM ntss.mst_facility", Long.class);
            return count != null ? count : 0L;
        }
    }

    private List<FacilityInfo> queryFacilities(String like, int limit, long offset) {
        if (like != null) {
            return onlineDefaultJdbc.query(
                    "SELECT facility_cd, facility_name " +
                    "FROM ntss.mst_facility WHERE facility_name LIKE ? " +
                    "ORDER BY facility_cd LIMIT ? OFFSET ?",
                    this::mapFacility, like, limit, offset);
        } else {
            return onlineDefaultJdbc.query(
                    "SELECT facility_cd, facility_name " +
                    "FROM ntss.mst_facility ORDER BY facility_cd LIMIT ? OFFSET ?",
                    this::mapFacility, limit, offset);
        }
    }

    private FacilityInfo mapFacility(ResultSet rs, int row) throws SQLException {
        return new FacilityInfo(
                rs.getString("facility_cd"),
                rs.getString("facility_name"),
                null, null, null);
    }

    @Override
    public FacilityCountResponse getTableCounts(List<String> facilityCodes) {
        Map<String, Long> tableCounts = new LinkedHashMap<>();

        Map<String, PgTableConfig> configByName = configByName();
        List<PgTableConfig> targets = seqReserveTargets();
        long totalStartedAt = System.nanoTime();

        log.info("[FACILITY] テーブル件数取得開始: facilityCount={}, tables={}",
                facilityCount(facilityCodes), targets.size());

        for (int i = 0; i < targets.size(); i++) {
            PgTableConfig cfg = targets.get(i);
            long tableStartedAt = System.nanoTime();
            log.info("[FACILITY] テーブル件数取得中: {}/{} db={}, table={}, idColumn={}",
                    i + 1, targets.size(), cfg.getDb(), cfg.getName(), cfg.getIdColumn());
            try {
                long count = countDistinctIds(cfg, configByName, facilityCodes);
                tableCounts.put(cfg.getName(), count);
                log.info("[FACILITY] テーブル件数取得完了: {}/{} db={}, table={}, count={}, elapsedMs={}",
                        i + 1, targets.size(), cfg.getDb(), cfg.getName(), count, elapsedMillis(tableStartedAt));
            } catch (Exception e) {
                log.warn("[FACILITY] テーブル件数取得失敗: {}/{} db={}, table={}, elapsedMs={}, error={}",
                        i + 1, targets.size(), cfg.getDb(), cfg.getName(),
                        elapsedMillis(tableStartedAt), e.getMessage(), e);
                tableCounts.put(cfg.getName(), 0L);
            }
        }

        long totalRows = tableCounts.values().stream().mapToLong(Long::longValue).sum();

        log.info("[FACILITY] 行数集計完了: facilityCount={}, totalRows={}, tables={}, elapsedMs={}",
                facilityCount(facilityCodes), totalRows, tableCounts.size(), elapsedMillis(totalStartedAt));
        return new FacilityCountResponse(facilityCodes, tableCounts, totalRows, Instant.now());
    }

    @Override
    public FacilitySeqReservePlanResponse getSeqReservePlan(List<String> facilityCodes) {
        Map<String, PgTableConfig> configByName = configByName();
        List<PgTableConfig> targets = seqReserveTargets();
        List<FacilitySeqReservePlanItem> tablePlans = new ArrayList<>();
        long totalStartedAt = System.nanoTime();

        log.info("[FACILITY] sequence 予約件数取得開始: facilityCount={}, tables={}",
                facilityCount(facilityCodes), targets.size());

        for (int i = 0; i < targets.size(); i++) {
            PgTableConfig cfg = targets.get(i);
            long tableStartedAt = System.nanoTime();
            String seqName = effectiveSeqName(cfg);
            long reserveCount;
            log.info("[FACILITY] sequence 予約件数取得中: {}/{} db={}, table={}, idColumn={}, seqName={}",
                    i + 1, targets.size(), cfg.getDb(), cfg.getName(), cfg.getIdColumn(), seqName);
            try {
                reserveCount = countDistinctIds(cfg, configByName, facilityCodes);
                log.info("[FACILITY] sequence 予約件数取得完了: {}/{} db={}, table={}, reserveCount={}, elapsedMs={}",
                        i + 1, targets.size(), cfg.getDb(), cfg.getName(), reserveCount, elapsedMillis(tableStartedAt));
            } catch (Exception e) {
                log.warn("[FACILITY] sequence 予約件数取得失敗: {}/{} db={}, table={}, elapsedMs={}, error={}",
                        i + 1, targets.size(), cfg.getDb(), cfg.getName(),
                        elapsedMillis(tableStartedAt), e.getMessage(), e);
                reserveCount = 0L;
            }

            tablePlans.add(new FacilitySeqReservePlanItem(
                    cfg.getName(),
                    cfg.getDb(),
                    cfg.getIdColumn(),
                    seqName,
                    reserveCount
            ));
        }

        long totalReserveCount = tablePlans.stream()
                .mapToLong(FacilitySeqReservePlanItem::reserveCount)
                .sum();

        log.info("[FACILITY] sequence 予約プラン作成完了: facilityCount={}, totalReserveCount={}, tables={}, elapsedMs={}",
                facilityCount(facilityCodes), totalReserveCount, tablePlans.size(), elapsedMillis(totalStartedAt));
        return new FacilitySeqReservePlanResponse(facilityCodes, tablePlans, totalReserveCount, Instant.now());
    }

    private int facilityCount(List<String> facilityCodes) {
        return facilityCodes != null ? facilityCodes.size() : 0;
    }

    private long elapsedMillis(long startedAtNanos) {
        return (System.nanoTime() - startedAtNanos) / 1_000_000L;
    }

    private Map<String, PgTableConfig> configByName() {
        return pgDumpConfig.getTables().stream()
                .collect(Collectors.toMap(PgTableConfig::getName, cfg -> cfg, (a, b) -> a, LinkedHashMap::new));
    }

    private List<PgTableConfig> seqReserveTargets() {
        return pgDumpConfig.tablesFor("on2off").stream()
                .filter(PgTableConfig::hasIdColumn)
                .filter(cfg -> cfg.getSharedPkTable() == null || cfg.getSharedPkTable().isBlank())
                .filter(cfg -> COUNTABLE_DBS.contains(cfg.getDb()))
                .toList();
    }

    private long countDistinctIds(
            PgTableConfig baseConfig,
            Map<String, PgTableConfig> configByName,
            List<String> facilityCodes) {
        JdbcTemplate jdbc = jdbcFor(baseConfig.getDb());
        List<String> targetTables = new ArrayList<>();
        targetTables.add(baseConfig.getName());
        if (baseConfig.getPkGroupTables() != null) {
            targetTables.addAll(baseConfig.getPkGroupTables());
        }

        if (targetTables.size() == 1) {
            String sql = "SELECT COUNT(*) FROM ntss." + quoteIdentifier(baseConfig.getName());
            String where = buildWhereClause(baseConfig.getWhereTemplate(), facilityCodes);
            if (where != null && !where.isBlank()) {
                sql += " WHERE " + where;
            }
            Long count = jdbc.queryForObject(sql, Long.class);
            return count != null ? count : 0L;
        }

        List<String> selects = new ArrayList<>();
        for (String tableName : targetTables) {
            PgTableConfig tableConfig = configByName.getOrDefault(tableName, baseConfig);
            String idColumn = effectiveIdColumn(tableConfig, baseConfig);
            String select = "SELECT " + quoteIdentifier(idColumn)
                    + " AS old_id FROM ntss." + quoteIdentifier(tableName);
            String where = buildWhereClause(tableConfig.getWhereTemplate(), facilityCodes);
            if (where != null && !where.isBlank()) {
                select += " WHERE " + where;
            }
            selects.add(select);
        }

        String sql = "SELECT COUNT(DISTINCT old_id) FROM ("
                + String.join(" UNION ALL ", selects)
                + ") u";
        Long count = jdbc.queryForObject(sql, Long.class);
        return count != null ? count : 0L;
    }

    private JdbcTemplate jdbcFor(String dbName) {
        return "ntss_db6".equals(dbName) ? onlinePersonalJdbc : onlineDefaultJdbc;
    }

    private String buildWhereClause(String template, List<String> facilityCodes) {
        if (template == null || template.isBlank() || facilityCodes == null || facilityCodes.isEmpty()) {
            return null;
        }

        String facilityList = facilityCodes.stream()
                .map(this::sanitizeFacilityCode)
                .map(code -> "'" + code + "'")
                .collect(Collectors.joining(","));
        return template.replace(":facilityList", facilityList);
    }

    private String sanitizeFacilityCode(String code) {
        return code == null ? "" : code.replaceAll("[^A-Za-z0-9_-]", "");
    }

    private String effectiveIdColumn(PgTableConfig tableConfig, PgTableConfig baseConfig) {
        if (tableConfig != null && tableConfig.hasIdColumn()) {
            return tableConfig.getIdColumn();
        }
        if (baseConfig != null && baseConfig.hasIdColumn()) {
            return baseConfig.getIdColumn();
        }
        throw new IllegalStateException("idColumn が解決できません: table="
                + (tableConfig != null ? tableConfig.getName() : "(null)")
                + ", baseTable="
                + (baseConfig != null ? baseConfig.getName() : "(null)"));
    }

    private String effectiveSeqName(PgTableConfig cfg) {
        if (cfg.getSeqName() != null && !cfg.getSeqName().isBlank()) {
            return cfg.getSeqName();
        }
        return cfg.getName() + "_" + cfg.getIdColumn() + "_seq";
    }

    private String quoteIdentifier(String name) {
        return "\"" + name.replace("\"", "\"\"") + "\"";
    }
}
