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
class PatIndApproveJsonFkRefreshTest {

    private static final long JOB_ID = 990018L;

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
    void shouldRefreshPatIndApproveJsonFksAcrossAllColumns() throws Exception {
        cleanup();

        try {
            createTable();
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    configs(),
                    "VERIFY_PAT_IND_APPROVE"
            );

            assertTrue(updated >= 3, "Expected pat_ind_approve JSON FK rules to update all target columns.");

            assertJsonColumn("content_for_map");
            assertJsonColumn("approve_content");
            assertJsonColumn("check_content");
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        List<FkMigrationConfig> configs = new ArrayList<>();
        for (String jsonColumn : List.of("content_for_map", "approve_content", "check_content")) {
            configs.add(cfg(jsonColumn, "itemInfo.itemCd", "mst_treatment", "{\"entry.component\":\"treat-method\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_kur", "{\"entry.component\":\"schedule\",\"item.itemNo\":\"1\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_bed", "{\"entry.component\":\"schedule\",\"item.itemNo\":\"3\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_va", "{\"entry.component\":\"treat-cond\",\"item.itemNo\":\"2\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_dialyzer", "{\"entry.component\":\"treat-cond\",\"item.itemNo\":\"5\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_equipment", "{\"entry.component\":\"treat-cond\",\"item.itemNo\":[\"6\",\"7\",\"8\",\"9\",\"10\",\"11\",\"13\"]}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_medicine", "{\"entry.component\":\"treat-cond\",\"item.itemNo\":[\"15\",\"19\",\"25\"],\"item.itemType\":\"1\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_medicine_mix", "{\"entry.component\":\"treat-cond\",\"item.itemNo\":\"25\",\"item.itemType\":\"2\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_medicine", "{\"entry.component\":\"medicine\",\"item.itemType\":\"1\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_medicine_mix", "{\"entry.component\":\"medicine\",\"item.itemType\":\"2\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_equipment", "{\"entry.component\":\"equipment\",\"item.itemType\":\"0\"}"));
            configs.add(cfg(jsonColumn, "subCategoryItem.[].itemInfo.itemCd", "mst_dialyzer", "{\"entry.component\":\"equipment\",\"item.itemType\":\"1\"}"));
        }
        return configs;
    }

    private FkMigrationConfig cfg(String jsonColumn, String jsonPath, String refTable, String whereTemplate) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_pat_ind_approve");
        cfg.setFkType("JSON");
        cfg.setJsonColumn(jsonColumn);
        cfg.setJsonPath(jsonPath);
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        cfg.setWhereTemplate(whereTemplate);
        return cfg;
    }

    private void createTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_ind_approve (
                    id bigint PRIMARY KEY,
                    content_for_map jsonb,
                    approve_content jsonb,
                    check_content jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_treatment", 9101801L, 9201801L, JOB_ID},
                        new Object[]{"mst_kur", 9101802L, 9201802L, JOB_ID},
                        new Object[]{"mst_bed", 9101803L, 9201803L, JOB_ID},
                        new Object[]{"mst_va", 9101804L, 9201804L, JOB_ID},
                        new Object[]{"mst_dialyzer", 9101805L, 9201805L, JOB_ID},
                        new Object[]{"mst_equipment", 9101806L, 9201806L, JOB_ID},
                        new Object[]{"mst_medicine", 9101807L, 9201807L, JOB_ID},
                        new Object[]{"mst_medicine_mix", 9101808L, 9201808L, JOB_ID},
                        new Object[]{"mst_medicine", 9101809L, 9201809L, JOB_ID},
                        new Object[]{"mst_medicine_mix", 9101810L, 9201810L, JOB_ID},
                        new Object[]{"mst_equipment", 9101811L, 9201811L, JOB_ID},
                        new Object[]{"mst_dialyzer", 9101812L, 9201812L, JOB_ID}
                )
        );
    }

    private void insertRows() {
        String json = """
                [
                  {
                    "component":"treat-method",
                    "subCategoryNo":2,
                    "itemInfo":{"itemCd":9101801,"itemNo":1,"itemType":null,"data":{"value":{"dispVal":"HD","prefix":null,"unit":null}}},
                    "subCategoryItem":[]
                  },
                  {
                    "component":"schedule",
                    "subCategoryNo":3,
                    "subCategoryItem":[
                      {"itemInfo":{"itemCd":9101802,"itemNo":1,"itemType":null}},
                      {"itemInfo":{"itemCd":null,"itemNo":2,"itemType":null}},
                      {"itemInfo":{"itemCd":9101803,"itemNo":3,"itemType":null}}
                    ]
                  },
                  {
                    "component":"treat-cond",
                    "subCategoryNo":4,
                    "subCategoryItem":[
                      {"itemInfo":{"itemCd":9101804,"itemNo":2,"itemType":null}},
                      {"itemInfo":{"itemCd":9101805,"itemNo":5,"itemType":null}},
                      {"itemInfo":{"itemCd":9101806,"itemNo":6,"itemType":null}},
                      {"itemInfo":{"itemCd":9101807,"itemNo":15,"itemType":1}},
                      {"itemInfo":{"itemCd":9101808,"itemNo":25,"itemType":2}}
                    ]
                  },
                  {
                    "component":"medicine",
                    "subCategoryNo":5,
                    "subCategoryItem":[
                      {"itemInfo":{"itemCd":9101809,"itemNo":50,"itemType":1}},
                      {"itemInfo":{"itemCd":9101810,"itemNo":51,"itemType":2}}
                    ]
                  },
                  {
                    "component":"equipment",
                    "subCategoryNo":6,
                    "subCategoryItem":[
                      {"itemInfo":{"itemCd":9101811,"itemNo":null,"itemType":0}},
                      {"itemInfo":{"itemCd":9101812,"itemNo":null,"itemType":1}}
                    ]
                  },
                  {
                    "component":"ind-comment",
                    "subCategoryNo":7,
                    "subCategoryItem":[
                      {"itemInfo":{"itemCd":null,"itemNo":1,"itemType":null}}
                    ]
                  }
                ]
                """;

        transitJdbc2.update(
                """
                INSERT INTO ntss.zz_verify_pat_ind_approve (id, content_for_map, approve_content, check_content)
                VALUES (?, CAST(? AS jsonb), CAST(? AS jsonb), CAST(? AS jsonb))
                """,
                1L,
                json,
                json,
                json
        );
    }

    private void assertJsonColumn(String jsonColumn) throws Exception {
        JsonNode root = objectMapper.readTree(transitJdbc2.queryForObject(
                "SELECT \"" + jsonColumn + "\"::text FROM ntss.zz_verify_pat_ind_approve WHERE id = 1",
                String.class
        ));

        assertEquals(9201801L, root.get(0).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201802L, root.get(1).path("subCategoryItem").get(0).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201803L, root.get(1).path("subCategoryItem").get(2).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201804L, root.get(2).path("subCategoryItem").get(0).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201805L, root.get(2).path("subCategoryItem").get(1).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201806L, root.get(2).path("subCategoryItem").get(2).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201807L, root.get(2).path("subCategoryItem").get(3).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201808L, root.get(2).path("subCategoryItem").get(4).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201809L, root.get(3).path("subCategoryItem").get(0).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201810L, root.get(3).path("subCategoryItem").get(1).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201811L, root.get(4).path("subCategoryItem").get(0).path("itemInfo").path("itemCd").asLong());
        assertEquals(9201812L, root.get(4).path("subCategoryItem").get(1).path("itemInfo").path("itemCd").asLong());
    }

    private void cleanup() {
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_ind_approve");
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
