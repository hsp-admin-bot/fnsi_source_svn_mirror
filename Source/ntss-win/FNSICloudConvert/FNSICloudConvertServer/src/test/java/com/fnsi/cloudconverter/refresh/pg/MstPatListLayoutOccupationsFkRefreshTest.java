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
class MstPatListLayoutOccupationsFkRefreshTest {

    private static final long JOB_ID = 990006L;
    private static final long ROW_ID = 1L;

    private static final long OLD_JOB_CD_1 = 9106001L;
    private static final long NEW_JOB_CD_1 = 9206001L;
    private static final long OLD_JOB_CD_2 = 9106002L;
    private static final long NEW_JOB_CD_2 = 9206002L;
    private static final long UNMAPPED_JOB_CD = 9999999L;

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
    void shouldRefreshScalarArrayElementsExceptSentinelValue() throws Exception {
        cleanup();

        try {
            createTestTable();
            insertPkMappings();
            insertRow();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    List.of(config()),
                    "VERIFY_PAT_LIST_LAYOUT_OCCUPATIONS"
            );

            assertTrue(updated >= 1, "Expected occupations JSON array to be updated.");

            String json = transitJdbc2.queryForObject(
                    "SELECT occupations::text FROM ntss.zz_verify_pat_list_layout WHERE id = ?",
                    String.class,
                    ROW_ID
            );
            JsonNode occupations = objectMapper.readTree(json);

            assertEquals(-1L, occupations.get(0).asLong());
            assertEquals(NEW_JOB_CD_1, occupations.get(1).asLong());
            assertEquals(NEW_JOB_CD_2, occupations.get(2).asLong());
            assertEquals(UNMAPPED_JOB_CD, occupations.get(3).asLong());
            assertTrue(occupations.get(1).isNumber());
        } finally {
            cleanup();
        }
    }

    private FkMigrationConfig config() {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_pat_list_layout");
        cfg.setFkType("JSON");
        cfg.setJsonColumn("occupations");
        cfg.setJsonPath("[]");
        cfg.setRefTable("mst_job");
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        cfg.setWhereTemplate("(@ #>> '{}') <> '-1'");
        return cfg;
    }

    private void createTestTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_list_layout (
                    id bigint PRIMARY KEY,
                    occupations jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_job", OLD_JOB_CD_1, NEW_JOB_CD_1, JOB_ID},
                        new Object[]{"mst_job", OLD_JOB_CD_2, NEW_JOB_CD_2, JOB_ID}
                )
        );
    }

    private void insertRow() {
        transitJdbc2.update(
                "INSERT INTO ntss.zz_verify_pat_list_layout (id, occupations) VALUES (?, CAST(? AS jsonb))",
                ROW_ID,
                "[-1, 9106001, 9106002, 9999999]"
        );
    }

    private void cleanup() {
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_list_layout");
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
