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
class MstPatViewerLayoutDispItemInfoFkRefreshTest {

    private static final long JOB_ID = 990015L;
    private static final long ROW_ID = 1L;

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
    void shouldRefreshNestedDispItemInfoFksWithoutTouchingGenericMedicineCodes() throws Exception {
        cleanup();

        try {
            createTestTable();
            insertPkMappings();
            insertRows();

            long updated = fkRefreshService.refreshConfigs(
                    transitJdbc2,
                    configs(),
                    "VERIFY_PAT_VIEWER_LAYOUT"
            );

            assertTrue(updated >= 1, "Expected mst_pat_viewer_layout.disp_item_info row to be updated.");

            JsonNode root = objectMapper.readTree(transitJdbc2.queryForObject(
                    "SELECT disp_item_info::text FROM ntss.zz_verify_pat_viewer_layout WHERE id = ?",
                    String.class,
                    ROW_ID
            ));

            JsonNode examResultItem = root.get(0).path("categoryItem").get(0).path("subCategoryItem").get(0);
            assertEquals(9201501L, examResultItem.path("itemNo").asLong());

            JsonNode drugGraphItems = root.get(1).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals(9201502L, drugGraphItems.get(0).path("itemNo").asLong());
            assertEquals("MEDICINE9201503", drugGraphItems.get(1).path("itemNo").asText());
            assertEquals("MEDICINE2649735SAZZZ", drugGraphItems.get(2).path("itemNo").asText());
            assertEquals("MEDICINE_MIX9201504", drugGraphItems.get(3).path("itemNo").asText());
            assertEquals("MEDICINE_GROUP9201505", drugGraphItems.get(4).path("itemNo").asText());
            assertEquals("MEDICINE_GROUPS9201506", drugGraphItems.get(5).path("itemNo").asText());

            JsonNode complaintItems = root.get(2).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals("Complaints*9201507", complaintItems.get(0).path("itemNo").asText());
            assertEquals("CompTreatment*9201508", complaintItems.get(1).path("itemNo").asText());

            JsonNode medicalItems = root.get(3).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals(9201509L, medicalItems.get(0).path("itemNo").asLong());

            JsonNode dialyzerItems = root.get(4).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals(9201510L, dialyzerItems.get(0).path("itemNo").asLong());

            JsonNode patientEventItems = root.get(5).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals("PAT_EVENT*9201511", patientEventItems.get(0).path("itemNo").asText());
            assertEquals("PAT_EVENT_SUB*9201512", patientEventItems.get(1).path("itemNo").asText());

            JsonNode rstInfoItems = root.get(6).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals("Complaints*9201513", rstInfoItems.get(0).path("itemNo").asText());
            assertEquals("CompTreatment*9201514", rstInfoItems.get(1).path("itemNo").asText());

            JsonNode vitalItems = root.get(7).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals("1*1*10222", vitalItems.get(0).path("itemNo").asText());
            assertEquals(10223L, vitalItems.get(1).path("itemNo").asLong());
            assertEquals("1*1*90", vitalItems.get(2).path("itemNo").asText());

            JsonNode comprehensiveItems = root.get(8).path("categoryItem").get(0).path("subCategoryItem");
            assertEquals(9201515L, comprehensiveItems.get(0).path("itemNo").asLong());
            assertEquals(9201516L, comprehensiveItems.get(1).path("itemNo").asLong());
            assertEquals("MEDICINE9201517", comprehensiveItems.get(2).path("itemNo").asText());
            assertEquals("MEDICINE2649735SBZZZ", comprehensiveItems.get(3).path("itemNo").asText());
            assertEquals("MEDICINE_MIX9201518", comprehensiveItems.get(4).path("itemNo").asText());
            assertEquals("MEDICINE_GROUPS9201519", comprehensiveItems.get(5).path("itemNo").asText());
            assertEquals("1*2*10224", comprehensiveItems.get(6).path("itemNo").asText());
            assertEquals(10224L, comprehensiveItems.get(6).path("moniNo").asLong());
            assertEquals("1*2*72", comprehensiveItems.get(7).path("itemNo").asText());
            assertEquals(72L, comprehensiveItems.get(7).path("moniNo").asLong());
        } finally {
            cleanup();
        }
    }

    private List<FkMigrationConfig> configs() {
        return List.of(
                cfg("mst_exam_item", "{\"subCategory.component\":\"exam-result\",\"item.itemNoType\":\"numeric\"}"),
                cfg("mst_exam_item", "{\"subCategory.component\":\"comprehensive\",\"item.itemDivision\":\"2\",\"item.itemNoType\":\"numeric\"}"),
                cfg("mst_equipment", "{\"subCategory.component\":\"medical\",\"item.itemNoType\":\"numeric\"}"),
                cfg("mst_dialyzer", "{\"subCategory.component\":\"dialyzer\",\"item.itemNoType\":\"numeric\"}"),
                cfg("mst_medicine", "[{\"subCategory.component\":\"drugAggregate\",\"item.itemNoType\":\"numeric\"},{\"subCategory.component\":\"drug-graph\",\"item.itemNoType\":\"numeric\"},{\"subCategory.component\":\"comprehensive\",\"item.itemDivision\":\"4\",\"item.itemNoType\":\"numeric\"},{\"subCategory.component\":\"drug-graph\",\"item.itemNoPrefix\":\"MEDICINE\"},{\"subCategory.component\":\"comprehensive\",\"item.itemDivision\":\"4\",\"item.itemNoPrefix\":\"MEDICINE\"}]"),
                cfg("mst_medicine_mix", "[{\"subCategory.component\":\"drug-graph\",\"item.itemNoPrefix\":\"MEDICINE_MIX\"},{\"subCategory.component\":\"comprehensive\",\"item.itemDivision\":\"4\",\"item.itemNoPrefix\":\"MEDICINE_MIX\"}]"),
                cfg("mst_medicine_group", "[{\"subCategory.component\":\"drug-graph\",\"item.itemNoPrefix\":[\"MEDICINE_GROUPS\",\"MEDICINE_GROUP\"]},{\"subCategory.component\":\"comprehensive\",\"item.itemDivision\":\"4\",\"item.itemNoPrefix\":[\"MEDICINE_GROUPS\",\"MEDICINE_GROUP\"]}]"),
                cfg("mst_complaint", "[{\"subCategory.component\":\"complaint\",\"item.itemNoPrefix\":\"Complaints*\"},{\"subCategory.component\":\"rst-info\",\"subCategory.subCategoryNo\":\"56\",\"item.itemNoPrefix\":\"Complaints*\"}]"),
                cfg("mst_comp_treatment", "[{\"subCategory.component\":\"complaint\",\"item.itemNoPrefix\":\"CompTreatment*\"},{\"subCategory.component\":\"rst-info\",\"subCategory.subCategoryNo\":\"56\",\"item.itemNoPrefix\":\"CompTreatment*\"}]"),
                cfg("mst_pat_event_category", "{\"category.categoryNo\":\"16\",\"item.itemNoPrefix\":\"PAT_EVENT*\"}"),
                cfg("mst_pat_event_sub_category", "{\"category.categoryNo\":\"16\",\"item.itemNoPrefix\":\"PAT_EVENT_SUB*\"}"),
                cfg("mst_add_monitor", "[{\"subCategory.component\":\"vital\"},{\"subCategory.component\":\"comprehensive\",\"item.itemDivision\":\"5\"}]")
        );
    }

    private FkMigrationConfig cfg(String refTable, String whereTemplate) {
        FkMigrationConfig cfg = new FkMigrationConfig();
        cfg.setTableName("zz_verify_pat_viewer_layout");
        cfg.setFkType("JSON");
        cfg.setJsonColumn("disp_item_info");
        cfg.setJsonPath("[].categoryItem.[].subCategoryItem.[].itemNo");
        cfg.setRefTable(refTable);
        cfg.setExecutionOrder(100);
        cfg.setEnabled(true);
        cfg.setWhereTemplate(whereTemplate);
        return cfg;
    }

    private void createTestTable() {
        transitJdbc2.execute("""
                CREATE TABLE IF NOT EXISTS ntss.zz_verify_pat_viewer_layout (
                    id bigint PRIMARY KEY,
                    disp_item_info jsonb
                )
                """);
    }

    private void insertPkMappings() {
        converterJdbc.batchUpdate(
                "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?, ?, ?, ?)",
                List.of(
                        new Object[]{"mst_exam_item", 9101501L, 9201501L, JOB_ID},
                        new Object[]{"mst_medicine", 9101502L, 9201502L, JOB_ID},
                        new Object[]{"mst_medicine", 9101503L, 9201503L, JOB_ID},
                        new Object[]{"mst_medicine_mix", 9101504L, 9201504L, JOB_ID},
                        new Object[]{"mst_medicine_group", 9101505L, 9201505L, JOB_ID},
                        new Object[]{"mst_medicine_group", 9101506L, 9201506L, JOB_ID},
                        new Object[]{"mst_complaint", 9101507L, 9201507L, JOB_ID},
                        new Object[]{"mst_comp_treatment", 9101508L, 9201508L, JOB_ID},
                        new Object[]{"mst_equipment", 9101509L, 9201509L, JOB_ID},
                        new Object[]{"mst_dialyzer", 9101510L, 9201510L, JOB_ID},
                        new Object[]{"mst_pat_event_category", 9101511L, 9201511L, JOB_ID},
                        new Object[]{"mst_pat_event_sub_category", 9101512L, 9201512L, JOB_ID},
                        new Object[]{"mst_complaint", 9101513L, 9201513L, JOB_ID},
                        new Object[]{"mst_comp_treatment", 9101514L, 9201514L, JOB_ID},
                        new Object[]{"mst_exam_item", 9101515L, 9201515L, JOB_ID},
                        new Object[]{"mst_medicine", 9101516L, 9201516L, JOB_ID},
                        new Object[]{"mst_medicine", 9101517L, 9201517L, JOB_ID},
                        new Object[]{"mst_medicine_mix", 9101518L, 9201518L, JOB_ID},
                        new Object[]{"mst_medicine_group", 9101519L, 9201519L, JOB_ID},
                        new Object[]{"mst_add_monitor", 220L, 222L, JOB_ID},
                        new Object[]{"mst_add_monitor", 221L, 223L, JOB_ID},
                        new Object[]{"mst_add_monitor", 222L, 224L, JOB_ID}
                )
        );
    }

    private void insertRows() {
        transitJdbc2.update(
                "INSERT INTO ntss.zz_verify_pat_viewer_layout (id, disp_item_info) VALUES (?, CAST(? AS jsonb))",
                ROW_ID,
                """
                [
                  {
                    "component":"exam-result",
                    "categoryNo":1008,
                    "categoryItem":[
                      {
                        "component":"exam-result",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":9101501,"itemName":"Exam Item"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"drug-graph",
                    "categoryNo":1012,
                    "categoryItem":[
                      {
                        "component":"drug-graph",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":9101502,"itemName":"Numeric Medicine"},
                          {"itemNo":"MEDICINE9101503","itemName":"Prefixed Medicine"},
                          {"itemNo":"MEDICINE2649735SAZZZ","itemName":"Generic Medicine"},
                          {"itemNo":"MEDICINE_MIX9101504","itemName":"Mix"},
                          {"itemNo":"MEDICINE_GROUP9101505","itemName":"Group"},
                          {"itemNo":"MEDICINE_GROUPS9101506","itemName":"GroupS"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"complaint",
                    "categoryNo":1017,
                    "categoryItem":[
                      {
                        "component":"complaint",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":"Complaints*9101507","itemName":"Complaint"},
                          {"itemNo":"CompTreatment*9101508","itemName":"Treatment"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"medical",
                    "categoryNo":1018,
                    "categoryItem":[
                      {
                        "component":"medical",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":9101509,"itemName":"Equipment"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"dialyzer",
                    "categoryNo":1019,
                    "categoryItem":[
                      {
                        "component":"dialyzer",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":9101510,"itemName":"Dialyzer"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"patient-event",
                    "categoryNo":16,
                    "categoryItem":[
                      {
                        "component":"patient-event",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":"PAT_EVENT*9101511","itemName":"Pat Event"},
                          {"itemNo":"PAT_EVENT_SUB*9101512","itemName":"Pat Event Sub"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"rst-info",
                    "categoryNo":1,
                    "categoryItem":[
                      {
                        "component":"rst-info",
                        "subCategoryNo":56,
                        "subCategoryItem":[
                          {"itemNo":"Complaints*9101513","itemName":"Complaint In Treatment Info"},
                          {"itemNo":"CompTreatment*9101514","itemName":"Treatment In Treatment Info"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"vital",
                    "categoryNo":2,
                    "categoryItem":[
                      {
                        "component":"vital",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":"1*1*10220","itemName":"Add Monitor Encoded String"},
                          {"itemNo":10221,"itemName":"Add Monitor Encoded Number"},
                          {"itemNo":"1*1*90","itemName":"Fixed Sys Monitor"}
                        ]
                      }
                    ]
                  },
                  {
                    "component":"comprehensive",
                    "categoryNo":1024,
                    "categoryItem":[
                      {
                        "component":"comprehensive",
                        "subCategoryNo":1,
                        "subCategoryItem":[
                          {"itemNo":9101515,"itemDivision":2,"itemName":"Exam In Comprehensive"},
                          {"itemNo":9101516,"itemDivision":4,"itemName":"Numeric Medicine In Comprehensive"},
                          {"itemNo":"MEDICINE9101517","itemDivision":4,"itemName":"Prefixed Medicine In Comprehensive"},
                          {"itemNo":"MEDICINE2649735SBZZZ","itemDivision":4,"itemName":"Generic In Comprehensive"},
                          {"itemNo":"MEDICINE_MIX9101518","itemDivision":4,"itemName":"Mix In Comprehensive"},
                          {"itemNo":"MEDICINE_GROUPS9101519","itemDivision":4,"itemName":"Group In Comprehensive"},
                          {"itemNo":"1*2*10222","itemDivision":5,"moniNo":10222,"itemName":"Add Monitor In Comprehensive"},
                          {"itemNo":"1*2*72","itemDivision":5,"moniNo":72,"itemName":"Fixed Monitor In Comprehensive"}
                        ]
                      }
                    ]
                  }
                ]
                """
        );
    }

    private void cleanup() {
        transitJdbc2.execute("DROP TABLE IF EXISTS ntss.zz_verify_pat_viewer_layout");
        converterJdbc.update("DELETE FROM pk_mapping WHERE job_id = ?", JOB_ID);
    }
}
