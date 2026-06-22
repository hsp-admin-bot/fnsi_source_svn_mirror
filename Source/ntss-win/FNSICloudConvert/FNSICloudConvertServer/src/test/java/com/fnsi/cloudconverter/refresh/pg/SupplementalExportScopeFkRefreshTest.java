package com.fnsi.cloudconverter.refresh.pg;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fnsi.cloudconverter.mapping.fk.entity.FkMigrationConfig;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.NONE,
        properties = {
                "connectivity.check.log-initial-delay-ms=600000",
                "connectivity.check.timeout-ms=300"
        }
)
@ActiveProfiles("dev")
class SupplementalExportScopeFkRefreshTest {

    private static final long JOB_ID = 990022L;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private FkRefreshServiceImpl fkRefreshService;

    @Autowired
    @Qualifier("converterJdbc")
    private JdbcTemplate converterJdbc;

    @Autowired
    @Qualifier("transitJdbc2")
    private JdbcTemplate transitJdbc2;

    @Test
    void shouldRefreshSupplementalExportScopeRules() throws Exception {
        cleanup();
        try {
            createTables();
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(transitJdbc2, configs(), "VERIFY_SUPPLEMENTAL_EXPORT_SCOPE");
            assertTrue(updated >= 10, "Expected supplemental export-scope FK rules to update target rows.");

            assertEquals(9202201L, fetchLong("zz_verify_sys_notification_list", "user_id"));
            assertEquals(9202202L, fetchLong("zz_verify_ord_main_restore", "pat_id"));
            assertEquals(9202203L, fetchJsonLong("zz_verify_ord_main_restore", "ind_equip_info", 0, "cd"));
            assertEquals(9202204L, fetchJsonLong("zz_verify_ord_main_restore", "ind_equip_info", 0, "ind_user_id"));

            assertEquals(9202205L, fetchJsonLong("zz_verify_pat_exam_main_hst", "exam_order_info", 0, "item_cd"));
            assertEquals(9202206L, fetchJsonLong("zz_verify_pat_exam_main_hst", "exam_order_info", 0, "set_cd"));
            assertEquals(9202207L, fetchJsonLong("zz_verify_pat_exam_main_hst", "order_exam_set_info", 0, "set_cd"));
            assertEquals(9202208L, fetchJsonLong("zz_verify_pat_exam_main_hst", "order_label_info", 0, "spitz_cd"));

            assertEquals(9202209L, fetchLong("zz_verify_pat_exam_pattern", "order_exam_set_cd"));
            assertEquals(9202210L, fetchJsonLong("zz_verify_pat_exam_pattern", "exam_order_info", 0, "exam_item_cd"));

            assertEquals(9202211L, fetchJsonLong("zz_verify_pat_rad_main_hst", "order_rad_set_info", 0, "rad_set_cd"));
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                columnCfg("zz_verify_sys_notification_list", "user_id", "mst_user"),
                columnCfg("zz_verify_ord_main_restore", "pat_id", "pat_main"),
                jsonCfg("zz_verify_ord_main_restore", "ind_equip_info", "{cd}", "mst_equipment",
                        "(ind_equip_info->>'equip_type')::int = 0"),
                jsonCfg("zz_verify_ord_main_restore", "ind_equip_info", "{ind_user_id}", "mst_user", null),

                jsonCfg("zz_verify_pat_exam_main_hst", "exam_order_info", "{item_cd}", "mst_exam_item", null),
                jsonCfg("zz_verify_pat_exam_main_hst", "exam_order_info", "{set_cd}", "mst_exam_set", null),
                jsonCfg("zz_verify_pat_exam_main_hst", "order_exam_set_info", "{set_cd}", "mst_exam_set", null),
                jsonCfg("zz_verify_pat_exam_main_hst", "order_label_info", "[].spitz_cd", "mst_spitz", null),

                columnCfg("zz_verify_pat_exam_pattern", "order_exam_set_cd", "mst_exam_set"),
                jsonCfg("zz_verify_pat_exam_pattern", "exam_order_info", "[].exam_item_cd", "mst_exam_item", null),

                jsonCfg("zz_verify_pat_rad_main_hst", "order_rad_set_info", "{rad_set_cd}", "mst_rad_set", null)
        );
    }

    private FkMigrationConfig columnCfg(String tableName, String columnName, String refTable) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName(tableName);
        cfg.setFkType("COLUMN");
        cfg.setColumnName(columnName);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        return cfg;
    }

    private FkMigrationConfig jsonCfg(String tableName, String jsonColumn, String jsonPath, String refTable, String whereTemplate) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName(tableName);
        cfg.setFkType("JSON");
        cfg.setJsonColumn(jsonColumn);
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(110);
        cfg.setEnabled(true);
        cfg.setWhereTemplate(whereTemplate);
        return cfg;
    }

    private void createTables() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_sys_notification_list (
                    id bigint PRIMARY KEY,
                    user_id bigint,
                    notification_data jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_ord_main_restore (
                    id bigint PRIMARY KEY,
                    pat_id bigint,
                    ind_equip_info jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_exam_main_hst (
                    id bigint PRIMARY KEY,
                    exam_order_info jsonb,
                    order_exam_set_info jsonb,
                    order_label_info jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_exam_pattern (
                    id bigint PRIMARY KEY,
                    order_exam_set_cd bigint,
                    exam_order_info jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_rad_main_hst (
                    id bigint PRIMARY KEY,
                    order_rad_set_info jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_user", 9102201L, 9202201L, JOB_ID},
                        new Object[]{"pat_main", 9102202L, 9202202L, JOB_ID},
                        new Object[]{"mst_equipment", 9102203L, 9202203L, JOB_ID},
                        new Object[]{"mst_user", 9102204L, 9202204L, JOB_ID},
                        new Object[]{"mst_exam_item", 9102205L, 9202205L, JOB_ID},
                        new Object[]{"mst_exam_set", 9102206L, 9202206L, JOB_ID},
                        new Object[]{"mst_exam_set", 9102207L, 9202207L, JOB_ID},
                        new Object[]{"mst_spitz", 9102208L, 9202208L, JOB_ID},
                        new Object[]{"mst_exam_set", 9102209L, 9202209L, JOB_ID},
                        new Object[]{"mst_exam_item", 9102210L, 9202210L, JOB_ID},
                        new Object[]{"mst_rad_set", 9102211L, 9202211L, JOB_ID}
                )
        );
    }

    private void insertRows() {
        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_sys_notification_list (id, user_id, notification_data)
                VALUES (?, ?, CAST(? AS jsonb))
                """, 1L, 9102201L, """
                {"endpoint":"https://example.invalid/push"}
                """);

        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_ord_main_restore (id, pat_id, ind_equip_info)
                VALUES (?, ?, CAST(? AS jsonb))
                """, 1L, 9102202L, """
                [{"cd":9102203,"equip_type":0,"ind_user_id":9102204}]
                """);

        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_pat_exam_main_hst (id, exam_order_info, order_exam_set_info, order_label_info)
                VALUES (?, CAST(? AS jsonb), CAST(? AS jsonb), CAST(? AS jsonb))
                """, 1L,
                """
                [{"item_cd":9102205,"set_cd":9102206}]
                """,
                """
                [{"set_cd":9102207}]
                """,
                """
                [{"spitz_cd":9102208}]
                """);

        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_pat_exam_pattern (id, order_exam_set_cd, exam_order_info)
                VALUES (?, ?, CAST(? AS jsonb))
                """, 1L, 9102209L, """
                [{"exam_item_cd":9102210,"exam_item_name":"N_検証"}]
                """);

        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_pat_rad_main_hst (id, order_rad_set_info)
                VALUES (?, CAST(? AS jsonb))
                """, 1L, """
                [{"no":1,"rad_set_cd":9102211,"rad_set_name":"X線_検証用"}]
                """);
    }

    private long fetchLong(String tableName, String columnName) {
        return transitJdbc2.queryForObject(
                "SELECT \"" + columnName + "\" FROM ntss.\"" + tableName + "\" WHERE id = 1",
                Long.class
        );
    }

    private long fetchJsonLong(String tableName, String jsonColumn, int index, String fieldName) throws Exception {
        JsonNode root = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT \"" + jsonColumn + "\"::text FROM ntss.\"" + tableName + "\" WHERE id = 1",
                String.class
        ));
        return root.get(index).path(fieldName).asLong();
    }

    private void cleanup() {
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_sys_notification_list");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_ord_main_restore");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_exam_main_hst");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_exam_pattern");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_rad_main_hst");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.pk_mapping_local");
    }
}
