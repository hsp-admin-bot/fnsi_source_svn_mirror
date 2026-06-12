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

import java.util.ArrayList;
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
class RemainingAiOutputJsonFkRefreshTest {

    private static final long JOB_ID = 990017L;

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
    void shouldRefreshRemainingAiOutputJsonFks() throws Exception {
        cleanup();

        try {
            createTables();
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    configs(),
                    "VERIFY_REMAINING_AI_OUTPUT"
            );

            assertTrue(updated >= 6, "Expected remaining ai_output JSON FK rules to update multiple rows.");

            assertPatMainRow();
            assertComsvRow();
            assertDefaultSettingsRow();
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        List<FkMigrationConfig> configs = new ArrayList<>();

        configs.add(cfg("zz_verify_pat_main_remaining", "acceptance_status_info", "[].ord_no", "ord_main", null));
        configs.add(cfg("zz_verify_pat_main_remaining", "implant_info", "[].implant_cd", "mst_implant", null));

        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph1", "graph1_item.[].code1", "mst_exam_item", "coalesce(@->>'code1', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph1", "graph1_item.[].code2", "mst_exam_item", "coalesce(@->>'code2', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph1", "graph1_item.[].code3", "mst_exam_item", "coalesce(@->>'code3', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph2", "graph2_item.[].code_bfr1", "mst_exam_item", "coalesce(@->>'code_bfr1', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph2", "graph2_item.[].code_afr1", "mst_exam_item", "coalesce(@->>'code_afr1', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph2", "graph2_item.[].code_bar1", "mst_exam_item", "coalesce(@->>'code_bar1', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph2", "graph2_item.[].code_bfr2", "mst_exam_item", "coalesce(@->>'code_bfr2', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph2", "graph2_item.[].code_afr2", "mst_exam_item", "coalesce(@->>'code_afr2', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_graph2", "graph2_item.[].code_bar2", "mst_exam_item", "coalesce(@->>'code_bar2', '') !~ '^0+[0-9]+$'"));
        configs.add(cfg("zz_verify_comsv_setting_remaining", "lcd_radar", "radar_item.[].code", "mst_exam_item", "coalesce(@->>'code', '') !~ '^0+[0-9]+$'"));

        configs.add(cfg("zz_verify_job_remaining", "default_disp_settings", "schedule-list.bedGroupCd", "mst_room_bed_group", null));
        configs.add(cfg("zz_verify_job_remaining", "default_disp_settings", "pat-viewer.setSelectedLayoutCd", "mst_pat_viewer_layout", null));
        configs.add(cfg("zz_verify_job_remaining", "default_disp_settings", "patient-search.bedCdListString", "mst_room_bed_group", null));

        return configs;
    }

    private FkMigrationConfig cfg(
            String tableName,
            String jsonColumn,
            String jsonPath,
            String refTable,
            String whereTemplate) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName(tableName);
        cfg.setFkType("JSON");
        cfg.setJsonColumn(jsonColumn);
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        cfg.setWhereTemplate(whereTemplate);
        return cfg;
    }

    private void createTables() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_main_remaining (
                    id bigint PRIMARY KEY,
                    acceptance_status_info jsonb,
                    implant_info jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_comsv_setting_remaining (
                    id bigint PRIMARY KEY,
                    lcd_graph1 jsonb,
                    lcd_graph2 jsonb,
                    lcd_radar jsonb
                )
                """);
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_job_remaining (
                    id bigint PRIMARY KEY,
                    default_disp_settings jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"ord_main", 9101701L, 9201701L, JOB_ID},
                        new Object[]{"mst_implant", 9101702L, 9201702L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101703L, 9201703L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101704L, 9201704L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101705L, 9201705L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101706L, 9201706L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101707L, 9201707L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101708L, 9201708L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101709L, 9201709L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101710L, 9201710L, JOB_ID},
                        new Object[]{"mst_room_bed_group", 9101711L, 9201711L, JOB_ID},
                        new Object[]{"mst_pat_viewer_layout", 9101712L, 9201712L, JOB_ID},
                        new Object[]{"mst_room_bed_group", 9101713L, 9201713L, JOB_ID}
                )
        );
    }

    private void insertRows() {
        transitJdbc2.update(
                """
                INSERT INTO ntss.zz_verify_pat_main_remaining (id, acceptance_status_info, implant_info)
                VALUES (?, CAST(? AS jsonb), CAST(? AS jsonb))
                """,
                1L,
                """
                [{"class":"5","ord_no":"9101701","start_date_time":"2026-04-01T10:00:00"}]
                """,
                """
                [{"ctl_no":1,"implant_cd":9101702,"remove_date":null}]
                """
        );

        transitJdbc2.update(
                """
                INSERT INTO ntss.zz_verify_comsv_setting_remaining (id, lcd_graph1, lcd_graph2, lcd_radar)
                VALUES (?, CAST(? AS jsonb), CAST(? AS jsonb), CAST(? AS jsonb))
                """,
                1L,
                """
                {"graph1_item":[{"no":1,"code1":"9101703","code2":"0000000003","code3":"9101704"}]}
                """,
                """
                {"graph2_item":[{"no":1,"code_bfr1":"9101705","code_afr1":"9101706","code_bar1":"9101707","code_bfr2":"9101708","code_afr2":"9101709","code_bar2":"0000000042"}]}
                """,
                """
                {"radar_item":[{"no":1,"code":"9101710"},{"no":2,"code":"0000000005"}]}
                """
        );

        transitJdbc2.update(
                """
                INSERT INTO ntss.zz_verify_job_remaining (id, default_disp_settings)
                VALUES (?, CAST(? AS jsonb))
                """,
                1L,
                """
                {
                  "schedule-list":{"bedGroupCd":"9101711"},
                  "pat-viewer":{"setSelectedLayoutCd":"9101712"},
                  "patient-search":{"bedCdListString":"9101713"}
                }
                """
        );
    }

    private void assertPatMainRow() throws Exception {
        JsonNode acceptance = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT acceptance_status_info::text FROM ntss.zz_verify_pat_main_remaining WHERE id = 1",
                String.class
        ));
        assertEquals("9201701", acceptance.get(0).path("ord_no").asText());
        assertTrue(acceptance.get(0).path("ord_no").isTextual());

        JsonNode implant = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT implant_info::text FROM ntss.zz_verify_pat_main_remaining WHERE id = 1",
                String.class
        ));
        assertEquals(9201702L, implant.get(0).path("implant_cd").asLong());
    }

    private void assertComsvRow() throws Exception {
        JsonNode graph1 = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT lcd_graph1::text FROM ntss.zz_verify_comsv_setting_remaining WHERE id = 1",
                String.class
        ));
        assertEquals("9201703", graph1.path("graph1_item").get(0).path("code1").asText());
        assertEquals("0000000003", graph1.path("graph1_item").get(0).path("code2").asText());
        assertEquals("9201704", graph1.path("graph1_item").get(0).path("code3").asText());

        JsonNode graph2 = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT lcd_graph2::text FROM ntss.zz_verify_comsv_setting_remaining WHERE id = 1",
                String.class
        ));
        assertEquals("9201705", graph2.path("graph2_item").get(0).path("code_bfr1").asText());
        assertEquals("9201706", graph2.path("graph2_item").get(0).path("code_afr1").asText());
        assertEquals("9201707", graph2.path("graph2_item").get(0).path("code_bar1").asText());
        assertEquals("9201708", graph2.path("graph2_item").get(0).path("code_bfr2").asText());
        assertEquals("9201709", graph2.path("graph2_item").get(0).path("code_afr2").asText());
        assertEquals("0000000042", graph2.path("graph2_item").get(0).path("code_bar2").asText());

        JsonNode radar = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT lcd_radar::text FROM ntss.zz_verify_comsv_setting_remaining WHERE id = 1",
                String.class
        ));
        assertEquals("9201710", radar.path("radar_item").get(0).path("code").asText());
        assertEquals("0000000005", radar.path("radar_item").get(1).path("code").asText());
    }

    private void assertDefaultSettingsRow() throws Exception {
        JsonNode settings = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT default_disp_settings::text FROM ntss.zz_verify_job_remaining WHERE id = 1",
                String.class
        ));
        assertEquals("9201711", settings.path("schedule-list").path("bedGroupCd").asText());
        assertEquals("9201712", settings.path("pat-viewer").path("setSelectedLayoutCd").asText());
        assertEquals("9201713", settings.path("patient-search").path("bedCdListString").asText());
    }

    private void cleanup() {
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_job_remaining");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_comsv_setting_remaining");
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_main_remaining");
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
