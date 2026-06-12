package com.fnsi.cloudconverter.task;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fnsi.cloudconverter.migration.pg.DbConnectionInfo;
import com.fnsi.cloudconverter.migration.pg.DumpResult;
import com.fnsi.cloudconverter.migration.pg.PgDumpConfig;
import com.fnsi.cloudconverter.migration.pg.PgDumpService;
import com.fnsi.cloudconverter.migration.pg.PgTableConfig;
import com.fnsi.cloudconverter.refresh.pg.FkRefreshService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.postgresql.copy.CopyManager;
import org.postgresql.core.BaseConnection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.NONE,
        properties = {
                "connectivity.check.log-initial-delay-ms=600000",
                "connectivity.check.timeout-ms=300"
        }
)
@ActiveProfiles("dev")
class Task4Task7VerificationTest {

    private static final long JOB_ID = 990001L;
    private static final int TARGET_TREATMENT_SET_CD = 1900000001;
    private static final int OTHER_TREATMENT_SET_CD = 1900000002;
    private static final String TARGET_FACILITY_CD = "ZV0001";
    private static final String OTHER_FACILITY_CD = "OT0001";

    private static final long OLD_EQUIPMENT_ID = 910001L;
    private static final long NEW_EQUIPMENT_ID = 920001L;
    private static final long OLD_DIALYZER_ID = 910002L;
    private static final long NEW_DIALYZER_ID = 920002L;
    private static final long OLD_MEDICINE_ID = 910003L;
    private static final long NEW_MEDICINE_ID = 920003L;
    private static final long OLD_MEDICINE_MIX_ID = 910004L;
    private static final long NEW_MEDICINE_MIX_ID = 920004L;
    private static final long UNMAPPED_EQUIPMENT_ID = 910099L;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private FkRefreshService fkRefreshService;

    @Autowired
    private PgDumpService pgDumpService;

    @Autowired
    private PgDumpConfig pgDumpConfig;

    @Autowired
    @Qualifier("converterJdbc")
    private JdbcTemplate converterJdbc;

    @Autowired
    @Qualifier("transitJdbc2")
    private JdbcTemplate transitJdbc2;

    @Autowired
    @Qualifier("transitDataSource2")
    private DataSource transitDataSource2;

    @Autowired
    @Qualifier("transitDb2ConnInfo")
    private DbConnectionInfo transitDb2ConnInfo;

    @Test
    void task4AndTask7_shouldRefreshJsonFkAndExportTranslatedRowOnly(@TempDir Path tempDir) throws Exception {
        cleanupVerificationData();

        try {
            insertPkMappings();
            insertTransitRows();

            long updated = fkRefreshService.refreshAll(transitJdbc2, JOB_ID, "VERIFY_TASK4");
            assertTrue(updated > 0, "TASK4 verification should update at least one FK.");

            assertTransitRowUpdated();

            PgTableConfig tableConfig = pgDumpConfig.tablesForDb("off2on", "ntss_db5").stream()
                    .filter(cfg -> "mst_treatment_set".equals(cfg.getName()))
                    .findFirst()
                    .orElseThrow(() -> new IllegalStateException("mst_treatment_set config was not found."));

            Path dbSubDir = tempDir.resolve("ntss_db5");
            DumpResult dumpResult = pgDumpService.dumpToCopy(
                    tableConfig,
                    List.of(TARGET_FACILITY_CD),
                    dbSubDir,
                    transitDb2ConnInfo
            );

            assertTrue(dumpResult.success(), dumpResult.errorOutput());

            Path dataFile = dbSubDir.resolve("mst_treatment_set.data");
            assertTrue(Files.exists(dataFile), "TASK7 should create mst_treatment_set.data");

            assertExportedData(dataFile);
        } finally {
            cleanupVerificationData();
        }
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_equipment", OLD_EQUIPMENT_ID, NEW_EQUIPMENT_ID, JOB_ID},
                        new Object[]{"mst_dialyzer", OLD_DIALYZER_ID, NEW_DIALYZER_ID, JOB_ID},
                        new Object[]{"mst_medicine", OLD_MEDICINE_ID, NEW_MEDICINE_ID, JOB_ID},
                        new Object[]{"mst_medicine_mix", OLD_MEDICINE_MIX_ID, NEW_MEDICINE_MIX_ID, JOB_ID}
                )
        );
    }

    private void insertTransitRows() {
        String indCondInfo = """
                {
                  "19": {"value": "910003", "medicine_type": 1},
                  "25": {"value": "910004", "medicine_type": 2},
                  "2": {"value": "300", "medicine_type": null}
                }
                """;
        String indEquipInfo = """
                [
                  {"cd": 910001, "amount": "2", "equip_type": 0},
                  {"cd": 910002, "amount": "3", "equip_type": 1},
                  {"cd": 910099, "amount": "4", "equip_type": 0}
                ]
                """;

        insertTreatmentSetRow(TARGET_TREATMENT_SET_CD, TARGET_FACILITY_CD, indCondInfo, indEquipInfo);
        insertTreatmentSetRow(OTHER_TREATMENT_SET_CD, OTHER_FACILITY_CD, indCondInfo, indEquipInfo);
    }

    private void insertTreatmentSetRow(int treatmentSetCd, String facilityCd, String indCondInfo, String indEquipInfo) {
        transitJdbc2.update(
                """
                INSERT INTO ntss.mst_treatment_set (
                    treatment_set_cd,
                    facility_cd,
                    treatment_set_name,
                    ind_cond_info,
                    ind_equip_info,
                    is_disp,
                    is_del,
                    reg_date,
                    up_date
                ) VALUES (?, ?, ?, CAST(? AS jsonb), CAST(? AS jsonb), '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                """,
                treatmentSetCd,
                facilityCd,
                "VERIFY_" + facilityCd,
                indCondInfo,
                indEquipInfo
        );
    }

    private void assertTransitRowUpdated() throws Exception {
        JsonNode indCondInfo = readTransitJsonColumn(TARGET_TREATMENT_SET_CD, "ind_cond_info");
        JsonNode indEquipInfo = readTransitJsonColumn(TARGET_TREATMENT_SET_CD, "ind_equip_info");

        assertEquals(String.valueOf(NEW_MEDICINE_ID), indCondInfo.path("19").path("value").asText());
        assertTrue(indCondInfo.path("19").path("value").isTextual(), "medicine value should stay as JSON string");

        assertEquals(String.valueOf(NEW_MEDICINE_MIX_ID), indCondInfo.path("25").path("value").asText());
        assertTrue(indCondInfo.path("25").path("value").isTextual(), "medicine_mix value should stay as JSON string");

        assertEquals(NEW_EQUIPMENT_ID, indEquipInfo.get(0).path("cd").asLong());
        assertTrue(indEquipInfo.get(0).path("cd").isNumber(), "equipment FK should stay numeric");

        assertEquals(NEW_DIALYZER_ID, indEquipInfo.get(1).path("cd").asLong());
        assertTrue(indEquipInfo.get(1).path("cd").isNumber(), "dialyzer FK should stay numeric");

        assertEquals(UNMAPPED_EQUIPMENT_ID, indEquipInfo.get(2).path("cd").asLong());
    }

    private void assertExportedData(Path dataFile) throws Exception {
        try (Connection connection = transitDataSource2.getConnection();
             Statement statement = connection.createStatement()) {
            statement.execute("CREATE TEMP TABLE tmp_verify_mst_treatment_set (LIKE ntss.mst_treatment_set INCLUDING DEFAULTS)");

            CopyManager copyManager = new CopyManager(connection.unwrap(BaseConnection.class));
            try (InputStream inputStream = Files.newInputStream(dataFile)) {
                long copied = copyManager.copyIn(
                        "COPY tmp_verify_mst_treatment_set FROM STDIN (FORMAT binary)",
                        inputStream
                );
                assertEquals(1L, copied, "TASK7 export should contain only the requested facility row.");
            }

            try (PreparedStatement countStatement = connection.prepareStatement(
                    "SELECT count(*) FROM tmp_verify_mst_treatment_set")) {
                try (ResultSet resultSet = countStatement.executeQuery()) {
                    assertTrue(resultSet.next());
                    assertEquals(1, resultSet.getInt(1));
                }
            }

            try (PreparedStatement rowStatement = connection.prepareStatement(
                    "SELECT facility_cd, ind_cond_info::text, ind_equip_info::text FROM tmp_verify_mst_treatment_set")) {
                try (ResultSet resultSet = rowStatement.executeQuery()) {
                    assertTrue(resultSet.next());
                    assertEquals(TARGET_FACILITY_CD, resultSet.getString("facility_cd"));

                    JsonNode indCondInfo = objectMapper.readTree(resultSet.getString("ind_cond_info"));
                    JsonNode indEquipInfo = objectMapper.readTree(resultSet.getString("ind_equip_info"));

                    assertEquals(String.valueOf(NEW_MEDICINE_ID), indCondInfo.path("19").path("value").asText());
                    assertEquals(String.valueOf(NEW_MEDICINE_MIX_ID), indCondInfo.path("25").path("value").asText());
                    assertEquals(NEW_EQUIPMENT_ID, indEquipInfo.get(0).path("cd").asLong());
                    assertEquals(NEW_DIALYZER_ID, indEquipInfo.get(1).path("cd").asLong());
                    assertEquals(UNMAPPED_EQUIPMENT_ID, indEquipInfo.get(2).path("cd").asLong());
                }
            }
        }
    }

    private JsonNode readTransitJsonColumn(int treatmentSetCd, String columnName) throws Exception {
        String json = transitJdbc2.queryForObject(
                "SELECT " + columnName + "::text FROM ntss.mst_treatment_set WHERE treatment_set_cd = ?",
                String.class,
                treatmentSetCd
        );
        assertNotNull(json);
        return objectMapper.readTree(json);
    }

    private void cleanupVerificationData() {
        transitJdbc2.update(
                "DELETE FROM ntss.mst_treatment_set WHERE treatment_set_cd IN (?, ?)",
                TARGET_TREATMENT_SET_CD,
                OTHER_TREATMENT_SET_CD
        );
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
