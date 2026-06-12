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
class OrdMaterialSaveFkRefreshTest {

    private static final long JOB_ID = 990002L;

    private static final long ROW_MAIN = 1900000101L;
    private static final long ROW_PRESCRIPTION = 1900000102L;

    private static final long OLD_PAT_ID = 9102101L;
    private static final long NEW_PAT_ID = 9202101L;
    private static final long OLD_ORD_MAIN_ID = 9102102L;
    private static final long NEW_ORD_MAIN_ID = 9202102L;
    private static final long OLD_ORD_PRESCRIPTION_ID = 9102103L;
    private static final long NEW_ORD_PRESCRIPTION_ID = 9202103L;
    private static final long OLD_SUPPLIES_CD = 9102104L;
    private static final long NEW_SUPPLIES_CD = 9202104L;
    private static final long OLD_RECEIPT_CONVERSION_CD = 9102105L;
    private static final long NEW_RECEIPT_CONVERSION_CD = 9202105L;
    private static final long OLD_MEDICINE_MIX_CD = 9102106L;
    private static final long NEW_MEDICINE_MIX_CD = 9202106L;
    private static final long OLD_CLASS_CD = 9102107L;
    private static final long NEW_CLASS_CD = 9202107L;
    private static final long OLD_PROCEDURE_CD = 111L;
    private static final long NEW_PROCEDURE_CD = 211L;
    private static final long OLD_TIMING_CD = 112L;
    private static final long NEW_TIMING_CD = 212L;

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
    void shouldRefreshOrdMaterialSaveStringColumnsAndPolymorphicBaseNo() throws Exception {
        cleanup();

        try {
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    ordMaterialSaveConfigs(),
                    "VERIFY_ORD_MATERIAL_SAVE"
            );

            assertTrue(updated >= 2, "ord_material_save should have updated rows.");

            assertMainSourceRow();
            assertPrescriptionSourceRow();
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> ordMaterialSaveConfigs() {
        return List.of(
                cfg("COLUMN", "pat_id", null, null, "pat_main", null),
                cfg("COLUMN", "supplies_base_no", null, null, "ord_main", "supplies_source_class IN ('0','1','2','3')"),
                cfg("COLUMN", "supplies_base_no", null, null, "ord_prescription", "supplies_source_class = '4'"),
                cfg("COLUMN", "supplies_cd", null, null, "mst_medicine", "supplies_class = '14'"),
                cfg("COLUMN", "medicine_mix_cd", null, null, "mst_medicine_mix", null),
                cfg("COLUMN", "class_cd", null, null, "mst_medicine_class", "supplies_class = '14'"),
                cfg("COLUMN", "procedure_cd", null, null, "mst_procedure", null),
                cfg("COLUMN", "timing_cd", null, null, "mst_medicate_timing", null),
                cfg("JSON", null, "receipt_conversion", "{cd}", "mst_medicine", null)
        );
    }

    private FkMigrationConfig cfg(
            String fkType,
            String columnName,
            String jsonColumn,
            String jsonPath,
            String refTable,
            String whereTemplate) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("ord_material_save");
        cfg.setFkType(fkType);
        cfg.setColumnName(columnName);
        cfg.setJsonColumn(jsonColumn);
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(110);
        cfg.setEnabled(true);
        cfg.setWhereTemplate(whereTemplate);
        return cfg;
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"pat_main", OLD_PAT_ID, NEW_PAT_ID, JOB_ID},
                        new Object[]{"ord_main", OLD_ORD_MAIN_ID, NEW_ORD_MAIN_ID, JOB_ID},
                        new Object[]{"ord_prescription", OLD_ORD_PRESCRIPTION_ID, NEW_ORD_PRESCRIPTION_ID, JOB_ID},
                        new Object[]{"mst_medicine", OLD_SUPPLIES_CD, NEW_SUPPLIES_CD, JOB_ID},
                        new Object[]{"mst_medicine", OLD_RECEIPT_CONVERSION_CD, NEW_RECEIPT_CONVERSION_CD, JOB_ID},
                        new Object[]{"mst_medicine_mix", OLD_MEDICINE_MIX_CD, NEW_MEDICINE_MIX_CD, JOB_ID},
                        new Object[]{"mst_medicine_class", OLD_CLASS_CD, NEW_CLASS_CD, JOB_ID},
                        new Object[]{"mst_procedure", OLD_PROCEDURE_CD, NEW_PROCEDURE_CD, JOB_ID},
                        new Object[]{"mst_medicate_timing", OLD_TIMING_CD, NEW_TIMING_CD, JOB_ID}
                )
        );
    }

    private void insertRows() {
        String receiptConversion = """
                [
                  {"cd": 9102105, "amount": 1, "solvent": "0"},
                  {"cd": 9999999, "amount": 2, "solvent": "0"}
                ]
                """;

        insertRow(ROW_MAIN, "0", OLD_ORD_MAIN_ID);
        insertRow(ROW_PRESCRIPTION, "4", OLD_ORD_PRESCRIPTION_ID);

        transitJdbc2.update(
                "UPDATE ntss.ord_material_save SET receipt_conversion = CAST(? AS jsonb) WHERE ord_material_save_no IN (?, ?)",
                receiptConversion,
                ROW_MAIN,
                ROW_PRESCRIPTION
        );
    }

    private void insertRow(long rowNo, String sourceClass, long suppliesBaseNo) {
        transitJdbc2.update(
                """
                INSERT INTO ntss.ord_material_save (
                    ord_material_save_no,
                    facility_cd,
                    pat_id,
                    supplies_base_date,
                    supplies_base_no,
                    supplies_source_class,
                    supplies_class,
                    supplies_cd,
                    medicine_mix_cd,
                    class_cd,
                    ind_rst_class,
                    ind_rst_value,
                    receipt_value,
                    is_confirm,
                    reg_date,
                    up_date,
                    medicine_no,
                    procedure_cd,
                    timing_cd,
                    prescription_unit,
                    frequency_flg,
                    frequency_num,
                    ind_unit,
                    receipt_unit,
                    effect_flg
                ) VALUES (
                    ?, 'OM0001', ?, '20260402', ?, ?, '14', ?, ?, ?, '1', '1', '1', '1',
                    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CAST('{\"no\":1}' AS json), ?, ?, 'amp', '0', '1', 'A', 'R', '0'
                )
                """,
                rowNo,
                OLD_PAT_ID,
                suppliesBaseNo,
                sourceClass,
                String.valueOf(OLD_SUPPLIES_CD),
                String.valueOf(OLD_MEDICINE_MIX_CD),
                String.valueOf(OLD_CLASS_CD),
                String.valueOf(OLD_PROCEDURE_CD),
                String.valueOf(OLD_TIMING_CD)
        );
    }

    private void assertMainSourceRow() throws Exception {
        var row = transitJdbc2.queryForMap(
                """
                SELECT pat_id,
                       supplies_base_no,
                       supplies_cd,
                       medicine_mix_cd,
                       class_cd,
                       procedure_cd,
                       timing_cd,
                       receipt_conversion::text AS receipt_conversion
                  FROM ntss.ord_material_save
                 WHERE ord_material_save_no = ?
                """,
                ROW_MAIN
        );

        assertEquals(NEW_PAT_ID, ((Number) row.get("pat_id")).longValue());
        assertEquals(NEW_ORD_MAIN_ID, ((Number) row.get("supplies_base_no")).longValue());
        assertEquals(String.valueOf(NEW_SUPPLIES_CD), row.get("supplies_cd"));
        assertEquals(String.valueOf(NEW_MEDICINE_MIX_CD), row.get("medicine_mix_cd"));
        assertEquals(String.valueOf(NEW_CLASS_CD), row.get("class_cd"));
        assertEquals(String.valueOf(NEW_PROCEDURE_CD), row.get("procedure_cd"));
        assertEquals(String.valueOf(NEW_TIMING_CD), row.get("timing_cd"));

        JsonNode receiptConversion = objectMapper.readTree((String) row.get("receipt_conversion"));
        assertEquals(NEW_RECEIPT_CONVERSION_CD, receiptConversion.get(0).path("cd").asLong());
        assertEquals(9999999L, receiptConversion.get(1).path("cd").asLong());
    }

    private void assertPrescriptionSourceRow() {
        var row = transitJdbc2.queryForMap(
                """
                SELECT supplies_base_no,
                       supplies_cd,
                       medicine_mix_cd,
                       class_cd,
                       procedure_cd,
                       timing_cd
                  FROM ntss.ord_material_save
                 WHERE ord_material_save_no = ?
                """,
                ROW_PRESCRIPTION
        );

        assertEquals(NEW_ORD_PRESCRIPTION_ID, ((Number) row.get("supplies_base_no")).longValue());
        assertEquals(String.valueOf(NEW_SUPPLIES_CD), row.get("supplies_cd"));
        assertEquals(String.valueOf(NEW_MEDICINE_MIX_CD), row.get("medicine_mix_cd"));
        assertEquals(String.valueOf(NEW_CLASS_CD), row.get("class_cd"));
        assertEquals(String.valueOf(NEW_PROCEDURE_CD), row.get("procedure_cd"));
        assertEquals(String.valueOf(NEW_TIMING_CD), row.get("timing_cd"));
    }

    private void cleanup() {
        transitJdbc2.update(
                "DELETE FROM ntss.ord_material_save WHERE ord_material_save_no IN (?, ?)",
                ROW_MAIN,
                ROW_PRESCRIPTION
        );
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
