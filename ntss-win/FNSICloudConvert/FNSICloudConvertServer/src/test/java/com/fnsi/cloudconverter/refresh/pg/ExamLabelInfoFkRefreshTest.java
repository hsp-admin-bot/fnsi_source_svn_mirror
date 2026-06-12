package com.fnsi.cloudconverter.refresh.pg;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fnsi.cloudconverter.mapping.fk.entity.FkMigrationConfig;
import org.junit.jupiter.api.AfterEach;
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
class ExamLabelInfoFkRefreshTest {

    private static final long JOB_ID = 990021L;
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
    void shouldRefreshExamLabelInfoSpitzCd() throws Exception {
        cleanup();
        try {
            createTables();
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(transitJdbc2, configs(), "VERIFY_EXAM_LABEL_INFO");
            assertTrue(updated >= 3, "Expected exam label info JSON FK rules to update all target rows.");

            assertEquals(9202101L, fetchFirstSpitzCd("zz_verify_exam_set_label", "label_info"));
            assertEquals(9202102L, fetchFirstSpitzCd("zz_verify_pat_exam_main_label", "order_label_info"));
            assertEquals(9202103L, fetchFirstSpitzCd("zz_verify_pat_exam_pattern_label", "order_label_info"));
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                cfg("zz_verify_exam_set_label", "label_info"),
                cfg("zz_verify_pat_exam_main_label", "order_label_info"),
                cfg("zz_verify_pat_exam_pattern_label", "order_label_info")
        );
    }

    private FkMigrationConfig cfg(String tableName, String jsonColumn) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName(tableName);
        cfg.setFkType("JSON");
        cfg.setJsonColumn(jsonColumn);
        cfg.setJsonPath("[].spitz_cd");
        cfg.setRefTable("mst_spitz");
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        return cfg;
    }

    private void createTables() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_exam_set_label (
                    id bigint PRIMARY KEY,
                    label_info jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_exam_main_label (
                    id bigint PRIMARY KEY,
                    order_label_info jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_exam_pattern_label (
                    id bigint PRIMARY KEY,
                    order_label_info jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_spitz", 9102101L, 9202101L, JOB_ID},
                        new Object[]{"mst_spitz", 9102102L, 9202102L, JOB_ID},
                        new Object[]{"mst_spitz", 9102103L, 9202103L, JOB_ID}
                )
        );
    }

    private void insertRows() {
        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_exam_set_label (id, label_info)
                VALUES (?, CAST(? AS jsonb))
                """, 1L, """
                [{"spitz_cd":9102101,"disp_order":1,"label_cnt":2}]
                """);

        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_pat_exam_main_label (id, order_label_info)
                VALUES (?, CAST(? AS jsonb))
                """, 1L, """
                [{"spitz_cd":9102102}]
                """);

        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_pat_exam_pattern_label (id, order_label_info)
                VALUES (?, CAST(? AS jsonb))
                """, 1L, """
                [{"spitz_cd":9102103,"label_cnt":1,"disp_order":5}]
                """);
    }

    private long fetchFirstSpitzCd(String tableName, String jsonColumn) throws Exception {
        JsonNode root = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT \"" + jsonColumn + "\"::text FROM ntss.\"" + tableName + "\" WHERE id = 1",
                String.class
        ));
        return root.get(0).path("spitz_cd").asLong();
    }

    private void cleanup() {
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_exam_set_label");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_exam_main_label");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_exam_pattern_label");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.pk_mapping_local");
    }
}
