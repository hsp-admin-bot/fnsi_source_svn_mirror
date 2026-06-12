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
class AdditionalJsonFkRefreshTest {

    private static final long JOB_ID = 990003L;
    private static final long ROW_ID = 1L;

    private static final long OLD_MAINTE_LAYOUT_CD = 9103001L;
    private static final long NEW_MAINTE_LAYOUT_CD = 9203001L;
    private static final long OLD_MEDICINE_CD = 9103002L;
    private static final long NEW_MEDICINE_CD = 9203002L;
    private static final long OLD_MEDICINE_MIX_CD = 9103003L;
    private static final long NEW_MEDICINE_MIX_CD = 9203003L;
    private static final long OLD_EQUIPMENT_CD = 9103004L;
    private static final long NEW_EQUIPMENT_CD = 9203004L;
    private static final long OLD_DIALYZER_CD = 9103005L;
    private static final long NEW_DIALYZER_CD = 9203005L;

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
    void shouldRefreshScalarAndPolymorphicArrayJsonFks() throws Exception {
        cleanup();

        try {
            createTestTable();
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    configs(),
                    "VERIFY_ADDITIONAL_JSON"
            );

            assertTrue(updated >= 2, "Expected both scalar and array JSON FKs to be updated.");

            JsonNode reportJson = objectMapper.readTree(transitJdbc2.queryForObject(
                    "SELECT report_json::text FROM ntss.zz_verify_additional_json_fk WHERE id = ?",
                    String.class,
                    ROW_ID
            ));
            assertEquals(String.valueOf(NEW_MAINTE_LAYOUT_CD), reportJson.path("mainte_layout_cd").asText());
            assertTrue(reportJson.path("mainte_layout_cd").isTextual(), "mainte_layout_cd should remain a JSON string.");

            JsonNode tabooJson = objectMapper.readTree(transitJdbc2.queryForObject(
                    "SELECT taboo_json::text FROM ntss.zz_verify_additional_json_fk WHERE id = ?",
                    String.class,
                    ROW_ID
            ));
            assertEquals(NEW_MEDICINE_CD, tabooJson.get(0).path("cd").asLong());
            assertEquals(NEW_MEDICINE_MIX_CD, tabooJson.get(1).path("cd").asLong());
            assertEquals(NEW_EQUIPMENT_CD, tabooJson.get(2).path("cd").asLong());
            assertEquals(NEW_DIALYZER_CD, tabooJson.get(3).path("cd").asLong());
            assertEquals(9999999L, tabooJson.get(4).path("cd").asLong());
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                cfg("report_json", "mainte_layout_cd", "mst_mainte_layout", null),
                cfg("taboo_json", "[].cd", "mst_medicine", "(@->>'classCd') = '1'"),
                cfg("taboo_json", "[].cd", "mst_medicine_mix", "(@->>'classCd') = '2'"),
                cfg("taboo_json", "[].cd", "mst_equipment", "(@->>'classCd') = '3'"),
                cfg("taboo_json", "[].cd", "mst_dialyzer", "(@->>'classCd') = '4'")
        );
    }

    private FkMigrationConfig cfg(String jsonColumn, String jsonPath, String refTable, String whereTemplate) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_additional_json_fk");
        cfg.setFkType("JSON");
        cfg.setJsonColumn(jsonColumn);
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        cfg.setWhereTemplate(whereTemplate);
        return cfg;
    }

    private void createTestTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_additional_json_fk (
                    id bigint PRIMARY KEY,
                    report_json jsonb,
                    taboo_json jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_mainte_layout", OLD_MAINTE_LAYOUT_CD, NEW_MAINTE_LAYOUT_CD, JOB_ID},
                        new Object[]{"mst_medicine", OLD_MEDICINE_CD, NEW_MEDICINE_CD, JOB_ID},
                        new Object[]{"mst_medicine_mix", OLD_MEDICINE_MIX_CD, NEW_MEDICINE_MIX_CD, JOB_ID},
                        new Object[]{"mst_equipment", OLD_EQUIPMENT_CD, NEW_EQUIPMENT_CD, JOB_ID},
                        new Object[]{"mst_dialyzer", OLD_DIALYZER_CD, NEW_DIALYZER_CD, JOB_ID}
                )
        );
    }

    private void insertRows() {
        transitJdbc2.update(
                """
                INSERT INTO ntss.zz_verify_additional_json_fk (id, report_json, taboo_json)
                VALUES (
                    ?,
                    CAST(? AS jsonb),
                    CAST(? AS jsonb)
                )
                """,
                ROW_ID,
                """
                {"layout_class":"1","mainte_layout_cd":"9103001","detail_info_class":"1"}
                """,
                """
                [
                  {"cd":9103002,"classCd":"1"},
                  {"cd":9103003,"classCd":"2"},
                  {"cd":9103004,"classCd":"3"},
                  {"cd":9103005,"classCd":"4"},
                  {"cd":9999999,"classCd":"9"}
                ]
                """
        );
    }

    private void cleanup() {
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_additional_json_fk");
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
