package com.fnsi.cloudconverter.refresh.pg;

import com.fnsi.cloudconverter.mapping.fk.entity.FkMigrationConfig;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
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
class MstUserTmpLogSearchConditionFkRefreshTest {

    private static final long JOB_ID = 990020L;
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    @Autowired
    private FkRefreshServiceImpl service;

    @Autowired
    @Qualifier("converterJdbc")
    private JdbcTemplate converterJdbc;

    @Autowired
    @Qualifier("transitJdbc2")
    private JdbcTemplate transitJdbc2;

    @Autowired
    @Qualifier("transitJdbc3")
    private JdbcTemplate transitJdbc3;

    @Test
    void shouldRefreshTmpLogSearchConditionPatIdAndUserId() throws Exception {
        createTable();
        seedRow();
        seedPkMapping("pat_main", 1001L, 9001L);
        seedPkMapping("mst_user", 2002L, 8002L);

        long updated = service.refreshConfigs(transitJdbc2, configs(), "TEST_TMP_LOG_SEARCH");
        assertTrue(updated >= 1, "Expected tmp_log_search_condition JSON FK rules to update the test row.");

        JsonNode root = OBJECT_MAPPER.readTree(fetchJson());
        assertEquals(9001, root.get(0).get("condition").get("patId").get(0).get("cd").asInt());
        assertEquals(8002, root.get(0).get("condition").get("userId").get(0).get("cd").asInt());
        assertEquals(7777, root.get(0).get("condition").get("serviceName").get(0).get("cd").asInt());
        assertEquals(9999, root.get(1).get("condition").get("patId").get(0).get("cd").asInt());
    }

    @Test
    void shouldSkipGracefullyWhenTableDoesNotExistOnOtherDatabase() {
        seedPkMapping("pat_main", 1001L, 9001L);

        long updated = service.refreshConfigs(
                transitJdbc3,
                List.of(cfg("mst_user", "[].condition.patId.[].cd", "pat_main")),
                "TEST_TMP_LOG_SEARCH_MISSING_TABLE");

        assertEquals(0, updated);
    }

    @AfterEach
    void tearDown() {
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_mst_user");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.pk_mapping_local");
        transitJdbc3.execute("DROP TABLE IF EXISTS ntss.pk_mapping_local");
    }

    private void createTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_mst_user (
                    user_id bigint PRIMARY KEY,
                    tmp_log_search_condition jsonb
                )
                """);
    }

    private void seedRow() {
        transitJdbc2.update("""
                INSERT INTO ntss.zz_verify_mst_user (user_id, tmp_log_search_condition)
                VALUES (?, CAST(? AS jsonb))
                """,
                1L,
                """
                [
                  {
                    "idFilter": null,
                    "condition": {
                      "patId": [
                        {"cd": 1001, "name": "P1", "cdType": 1}
                      ],
                      "userId": [
                        {"cd": 2002, "name": "U1", "cdType": 1}
                      ],
                      "serviceName": [
                        {"cd": 7777, "name": "svc", "cdType": 1}
                      ]
                    },
                    "nameFilter": "A"
                  },
                  {
                    "idFilter": null,
                    "condition": {
                      "patId": [
                        {"cd": 9999, "name": "keep", "cdType": 1}
                      ],
                      "userId": []
                    },
                    "nameFilter": "B"
                  }
                ]
                """);
    }

    private void seedPkMapping(String tableName, long oldId, long newId) {
        converterJdbc.update("""
                INSERT INTO pk_mapping (table_name, old_id, new_id, job_id)
                VALUES (?, ?, ?, ?)
                """, tableName, oldId, newId, JOB_ID);
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                cfg("zz_verify_mst_user", "[].condition.patId.[].cd", "pat_main"),
                cfg("zz_verify_mst_user", "[].condition.userId.[].cd", "mst_user")
        );
    }

    private FkMigrationConfig cfg(String tableName, String jsonPath, String refTable) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName(tableName);
        cfg.setFkType("JSON");
        cfg.setJsonColumn("tmp_log_search_condition");
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        return cfg;
    }

    private String fetchJson() {
        return transitJdbc2.queryForObject(
                "SELECT tmp_log_search_condition::text FROM ntss.zz_verify_mst_user WHERE user_id = 1",
                String.class
        );
    }
}
