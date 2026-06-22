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
class PatUniqueUserJsonFkRefreshTest {

    private static final long JOB_ID = 990023L;
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
    void shouldRefreshOnlyNumericLikePatUniqueUserFields() throws Exception {
        cleanup();
        try {
            createTable();
            insertPkMappings();
            insertRow();

            long updated = fkRefreshService.refreshConfigs(transitJdbc2, configs(), "VERIFY_PAT_UNIQUE_USER_JSON");
            assertTrue(updated >= 1, "Expected pat_unique user JSON rules to update the target row.");

            JsonNode medicalHstInfo = readJson("medical_hst_info");
            assertEquals("9202301", medicalHstInfo.get(0).path("diagnostician_cd").asText());
            assertEquals("山田太郎", medicalHstInfo.get(1).path("diagnostician_cd").asText());

            JsonNode physicalInfo = readJson("physical_info");
            assertEquals("9202302", physicalInfo.get(0).path("indicator_cd").asText());
            assertEquals(9202303L, physicalInfo.get(1).path("indicator_cd").asLong());
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                cfg("medical_hst_info", "[].diagnostician_cd"),
                cfg("physical_info", "[].indicator_cd")
        );
    }

    private FkMigrationConfig cfg(String jsonColumn, String jsonPath) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_pat_unique");
        cfg.setFkType("JSON");
        cfg.setJsonColumn(jsonColumn);
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable("mst_user");
        cfg.setExecutionOrder(110);
        cfg.setEnabled(true);
        return cfg;
    }

    private void createTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_unique (
                    id bigint PRIMARY KEY,
                    medical_hst_info jsonb,
                    physical_info jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_user", 9102301L, 9202301L, JOB_ID},
                        new Object[]{"mst_user", 9102302L, 9202302L, JOB_ID},
                        new Object[]{"mst_user", 9102303L, 9202303L, JOB_ID}
                )
        );
    }

    private void insertRow() {
        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_pat_unique (id, medical_hst_info, physical_info)
                VALUES (?, CAST(? AS jsonb), CAST(? AS jsonb))
                """, 1L,
                """
                [
                  {"diagnostician_cd":"9102301","memo":"numeric-like id"},
                  {"diagnostician_cd":"山田太郎","memo":"free text name"}
                ]
                """,
                """
                [
                  {"indicator_cd":"9102302","facility_cd":"CONV97"},
                  {"indicator_cd":9102303,"facility_cd":"CONV98"}
                ]
                """);
    }

    private JsonNode readJson(String columnName) throws Exception {
        return objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT \"" + columnName + "\"::text FROM ntss.zz_verify_pat_unique WHERE id = 1",
                String.class
        ));
    }

    private void cleanup() {
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_unique");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.pk_mapping_local");
    }
}
