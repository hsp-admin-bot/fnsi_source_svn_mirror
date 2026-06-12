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
class MstComsvSettingLcdStaffListFkRefreshTest {

    private static final long JOB_ID = 990005L;
    private static final long ROW_ID = 1L;

    private static final long OLD_USER_ID_1 = 9105001L;
    private static final long NEW_USER_ID_1 = 9205001L;
    private static final long OLD_USER_ID_2 = 9105002L;
    private static final long NEW_USER_ID_2 = 9205002L;
    private static final long UNMAPPED_USER_ID = 9999999L;

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
    void shouldRefreshNestedArrayUserIdsInLcdStaffList() throws Exception {
        cleanup();

        try {
            createTestTable();
            insertPkMappings();
            insertRow();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    List.of(config()),
                    "VERIFY_LCD_STAFF_LIST"
            );

            assertTrue(updated >= 1, "Expected lcd_staff_list JSON to be updated.");

            JsonNode json = objectMapper.readTree(transitJdbc2.queryForObject(
                    "SELECT lcd_staff_list::text FROM ntss.zz_verify_mst_comsv_setting WHERE id = ?",
                    String.class,
                    ROW_ID
            ));

            assertEquals(NEW_USER_ID_1, json.path("staff_list").get(0).path("user_id").asLong());
            assertEquals(NEW_USER_ID_2, json.path("staff_list").get(1).path("user_id").asLong());
            assertEquals(UNMAPPED_USER_ID, json.path("staff_list").get(2).path("user_id").asLong());
            assertTrue(json.path("staff_list").get(0).path("user_id").isNumber());
        } finally {
            cleanup();
        }
    }

    private FkMigrationConfig config() {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_mst_comsv_setting");
        cfg.setFkType("JSON");
        cfg.setJsonColumn("lcd_staff_list");
        cfg.setJsonPath("staff_list.[].user_id");
        cfg.setRefTable("mst_user");
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        return cfg;
    }

    private void createTestTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_mst_comsv_setting (
                    id bigint PRIMARY KEY,
                    lcd_staff_list jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_user", OLD_USER_ID_1, NEW_USER_ID_1, JOB_ID},
                        new Object[]{"mst_user", OLD_USER_ID_2, NEW_USER_ID_2, JOB_ID}
                )
        );
    }

    private void insertRow() {
        transitJdbc2.update(
                "INSERT INTO ntss.zz_verify_mst_comsv_setting (id, lcd_staff_list) VALUES (?, CAST(? AS jsonb))",
                ROW_ID,
                """
                {
                  "staff_list": [
                    {"no": 1, "user_id": 9105001},
                    {"no": 2, "user_id": 9105002},
                    {"no": 3, "user_id": 9999999}
                  ]
                }
                """
        );
    }

    private void cleanup() {
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_mst_comsv_setting");
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
