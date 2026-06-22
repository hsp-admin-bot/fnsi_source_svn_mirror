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
class MntNotificationMessageAdditionalInfoFkRefreshTest {

    private static final long JOB_ID = 990004L;
    private static final long ROW_006 = 1L;
    private static final long ROW_031 = 2L;
    private static final long ROW_02002 = 3L;
    private static final long ROW_027 = 4L;
    private static final long ROW_02303 = 5L;

    private static final long OLD_ORD_NO_A = 9104001L;
    private static final long NEW_ORD_NO_A = 9204001L;
    private static final long OLD_PAT_ID_A = 9104002L;
    private static final long NEW_PAT_ID_A = 9204002L;
    private static final long OLD_CTL_NO = 9104003L;
    private static final long NEW_CTL_NO = 9204003L;
    private static final long OLD_ORD_NO_B = 9104004L;
    private static final long NEW_ORD_NO_B = 9204004L;
    private static final long OLD_BBS_CTL_NO = 9104005L;
    private static final long NEW_BBS_CTL_NO = 9204005L;
    private static final long OLD_PAT_ID_B = 9104006L;
    private static final long NEW_PAT_ID_B = 9204006L;
    private static final long OLD_PAT_EVENT_CD = 9104007L;
    private static final long NEW_PAT_EVENT_CD = 9204007L;
    private static final long OLD_PAT_GROUP_CD = 9104008L;
    private static final long NEW_PAT_GROUP_CD = 9204008L;

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
    void shouldRefreshAdditionalInfoByFuncSpecificRules() throws Exception {
        cleanup();

        try {
            createTestTable();
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    configs(),
                    "VERIFY_NOTIFICATION_ADDITIONAL_INFO"
            );

            assertTrue(updated >= 8, "Expected func-specific JSON FK rules to update multiple values.");

            assertRow(
                    ROW_006,
                    "006",
                    String.valueOf(NEW_ORD_NO_A),
                    String.valueOf(NEW_PAT_ID_A),
                    null,
                    null,
                    null,
                    null
            );
            assertRow(
                    ROW_031,
                    "031",
                    String.valueOf(NEW_ORD_NO_B),
                    null,
                    String.valueOf(NEW_CTL_NO),
                    null,
                    null,
                    null
            );
            assertRow(
                    ROW_02002,
                    "02002",
                    null,
                    null,
                    null,
                    String.valueOf(NEW_BBS_CTL_NO),
                    null,
                    null
            );
            assertRow(
                    ROW_027,
                    "027",
                    null,
                    String.valueOf(NEW_PAT_ID_B),
                    null,
                    null,
                    String.valueOf(NEW_PAT_EVENT_CD),
                    null
            );
            assertRow(
                    ROW_02303,
                    "02303",
                    null,
                    null,
                    null,
                    null,
                    null,
                    String.valueOf(NEW_PAT_GROUP_CD)
            );
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                cfg("ORDNO", "ord_main", "(@->>'FUNC') = '006'"),
                cfg("PATID", "pat_main", "(@->>'FUNC') = '006'"),
                cfg("CTLNO", "sys_coop_no", "(@->>'FUNC') = '031'"),
                cfg("ORDNO", "ord_main", "(@->>'FUNC') = '031'"),
                cfg("BBSCTLNO", "bbs_info", "(@->>'FUNC') = '02002'"),
                cfg("PATID", "pat_main", "(@->>'FUNC') = '007'"),
                cfg("PATID", "pat_main", "(@->>'FUNC') = '014'"),
                cfg("PATID", "pat_main", "(@->>'FUNC') = '027'"),
                cfg("PATEVENTCD", "pat_event", "(@->>'FUNC') = '027'"),
                cfg("PATGROUPCD", "pat_group", "(@->>'FUNC') = '02303'")
        );
    }

    private FkMigrationConfig cfg(String jsonPath, String refTable, String whereTemplate) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_notification_message");
        cfg.setFkType("JSON");
        cfg.setJsonColumn("additional_info");
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(110);
        cfg.setEnabled(true);
        cfg.setWhereTemplate(whereTemplate);
        return cfg;
    }

    private void createTestTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_notification_message (
                    id bigint PRIMARY KEY,
                    additional_info jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"ord_main", OLD_ORD_NO_A, NEW_ORD_NO_A, JOB_ID},
                        new Object[]{"pat_main", OLD_PAT_ID_A, NEW_PAT_ID_A, JOB_ID},
                        new Object[]{"sys_coop_no", OLD_CTL_NO, NEW_CTL_NO, JOB_ID},
                        new Object[]{"ord_main", OLD_ORD_NO_B, NEW_ORD_NO_B, JOB_ID},
                        new Object[]{"bbs_info", OLD_BBS_CTL_NO, NEW_BBS_CTL_NO, JOB_ID},
                        new Object[]{"pat_main", OLD_PAT_ID_B, NEW_PAT_ID_B, JOB_ID},
                        new Object[]{"pat_event", OLD_PAT_EVENT_CD, NEW_PAT_EVENT_CD, JOB_ID},
                        new Object[]{"pat_group", OLD_PAT_GROUP_CD, NEW_PAT_GROUP_CD, JOB_ID}
                )
        );
    }

    private void insertRows() {
        insertRow(ROW_006, """
                {"FUNC":"006","ORDNO":"9104001","PATID":"9104002","FACILITYCD":"NKKSBR"}
                """);
        insertRow(ROW_031, """
                {"FUNC":"031","CTLNO":"9104003","ORDNO":"9104004","COOP_CD":"rep_dial","TARGET_DATE":"2026-03-03"}
                """);
        insertRow(ROW_02002, """
                {"FUNC":"02002","BBSCTLNO":"9104005","FACILITYCD":"NKKSBR"}
                """);
        insertRow(ROW_027, """
                {"FUNC":"027","PATID":"9104006","FACILITYCD":"NKKSBR","PATEVENTCD":"9104007"}
                """);
        insertRow(ROW_02303, """
                {"FUNC":"02303","FACILITYCD":"CNV112","PATGROUPCD":"9104008"}
                """);
    }

    private void insertRow(long id, String json) {
        transitJdbc2.update(
                "INSERT INTO ntss.zz_verify_notification_message (id, additional_info) VALUES (?, CAST(? AS jsonb))",
                id,
                json
        );
    }

    private void assertRow(
            long id,
            String func,
            String expectedOrdNo,
            String expectedPatId,
            String expectedCtlNo,
            String expectedBbsCtlNo,
            String expectedPatEventCd,
            String expectedPatGroupCd) throws Exception {
        String json = transitJdbc2.queryForObject(
                "SELECT additional_info::text FROM ntss.zz_verify_notification_message WHERE id = ?",
                String.class,
                id
        );
        JsonNode node = objectMapper.readTree(json);
        assertEquals(func, node.path("FUNC").asText());
        if (expectedOrdNo != null) {
            assertEquals(expectedOrdNo, node.path("ORDNO").asText());
            assertTrue(node.path("ORDNO").isTextual());
        }
        if (expectedPatId != null) {
            assertEquals(expectedPatId, node.path("PATID").asText());
            assertTrue(node.path("PATID").isTextual());
        }
        if (expectedCtlNo != null) {
            assertEquals(expectedCtlNo, node.path("CTLNO").asText());
            assertTrue(node.path("CTLNO").isTextual());
        }
        if (expectedBbsCtlNo != null) {
            assertEquals(expectedBbsCtlNo, node.path("BBSCTLNO").asText());
            assertTrue(node.path("BBSCTLNO").isTextual());
        }
        if (expectedPatEventCd != null) {
            assertEquals(expectedPatEventCd, node.path("PATEVENTCD").asText());
            assertTrue(node.path("PATEVENTCD").isTextual());
        }
        if (expectedPatGroupCd != null) {
            assertEquals(expectedPatGroupCd, node.path("PATGROUPCD").asText());
            assertTrue(node.path("PATGROUPCD").isTextual());
        }
    }

    private void cleanup() {
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_notification_message");
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
