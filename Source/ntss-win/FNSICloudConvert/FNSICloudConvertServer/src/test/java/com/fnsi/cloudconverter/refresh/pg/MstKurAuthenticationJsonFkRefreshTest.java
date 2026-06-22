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

@SpringBootTest
@ActiveProfiles("dev")
class MstKurAuthenticationJsonFkRefreshTest {

    private static final long JOB_ID = 990028L;
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    @Autowired
    private FkRefreshServiceImpl service;

    @Autowired
    @Qualifier("converterJdbc")
    private JdbcTemplate converterJdbc;

    @Autowired
    @Qualifier("transitJdbc2")
    private JdbcTemplate transitJdbc2;

    @Test
    void shouldRefreshDynamicWeekdayUserIds() throws Exception {
        createTable();
        seedRow();
        seedPkMapping(1001L, 9001L);
        seedPkMapping(2002L, 8002L);
        seedPkMapping(3003L, 7003L);

        long updated = service.refreshConfigs(transitJdbc2, configs(), "TEST_MST_KUR_AUTH");
        assertTrue(updated >= 1, "Expected mst_kur dynamic JSON FK rules to update the test row.");

        JsonNode root = OBJECT_MAPPER.readTree(fetchJson());
        JsonNode schedule = root.get("data").get(0);

        assertEquals("9001", schedule.get("All").get("user_id").asText());
        assertEquals("8002", schedule.get("All").get("disp_user_id").asText());
        assertEquals("0", schedule.get("Fri").get("user_id").asText());
        assertEquals("7003", schedule.get("Fri").get("disp_user_id").asText());
        assertEquals("manual", schedule.get("Mon").get("user_id").asText());
        assertEquals("keep", schedule.get("Mon").get("disp_user_id").asText());
    }

    @AfterEach
    void tearDown() {
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_mst_kur");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.pk_mapping_local");
    }

    private void createTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_mst_kur (
                    kur_cd bigint PRIMARY KEY,
                    mst_user_authentication jsonb
                )
                """);
    }

    private void seedRow() {
        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_mst_kur (kur_cd, mst_user_authentication)
                VALUES (?, CAST(? AS jsonb))
                """,
                1L,
                """
                {
                  "data": [
                    {
                      "All": {"user_id": "1001", "disp_user_id": "2002"},
                      "Fri": {"user_id": "0", "disp_user_id": "3003"},
                      "Mon": {"user_id": "manual", "disp_user_id": "keep"}
                    }
                  ]
                }
                """);
    }

    private void seedPkMapping(long oldId, long newId) {
        converterJdbc.update("""
                INSERT INTO pk_mapping (table_name, old_id, new_id, job_id)
                VALUES (?, ?, ?, ?)
                """, "mst_user", oldId, newId, JOB_ID);
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                cfg("{data,user_id}"),
                cfg("{data,disp_user_id}")
        );
    }

    private FkMigrationConfig cfg(String jsonPath) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_mst_kur");
        cfg.setFkType("JSON");
        cfg.setJsonColumn("mst_user_authentication");
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable("mst_user");
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        return cfg;
    }

    private String fetchJson() {
        return transitJdbc2.queryForObject(
                "SELECT mst_user_authentication::text FROM ntss.zz_verify_mst_kur WHERE kur_cd = 1",
                String.class
        );
    }
}
