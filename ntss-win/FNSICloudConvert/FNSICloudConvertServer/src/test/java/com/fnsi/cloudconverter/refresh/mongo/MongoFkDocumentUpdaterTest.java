package com.fnsi.cloudconverter.refresh.mongo;
import com.fnsi.cloudconverter.mapping.fkmongo.entity.FkMongoMigrationConfig;
import org.bson.Document;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class MongoFkDocumentUpdaterTest {

    private final MongoFkDocumentUpdater updater = new MongoFkDocumentUpdater();

    @Test
    void updatesBsonArrayElementWhenWhereConditionMatches() {
        Document document = new Document("in_out_visit_history_info", List.of(
                new Document("from_doctor", 100L).append("doctor_is_free", "0"),
                new Document("from_doctor", 200L).append("doctor_is_free", "1")
        ));

        FkMongoMigrationConfig config = config(
                "in_out_visit_history_info[].from_doctor",
                "BSON",
                "{\"doctor_is_free\": \"0\"}"
        );

        boolean updated = updater.apply(document, config, Map.of(100L, 900L, 200L, 901L));

        assertThat(updated).isTrue();
        List<?> values = document.getList("in_out_visit_history_info", Object.class);
        Document first = (Document) values.getFirst();
        Document second = (Document) values.get(1);
        assertThat(first.get("from_doctor")).isEqualTo(900L);
        assertThat(second.get("from_doctor")).isEqualTo(200L);
    }

    @Test
    void updatesJsonStringArrayElementWithSiblingCondition() {
        Document document = new Document("ind_medi_info",
                "[{\"cd\":100,\"medicine_type\":1},{\"cd\":200,\"medicine_type\":2}]");

        FkMongoMigrationConfig config = config(
                "ind_medi_info[].cd",
                "JSON_STRING",
                "{\"medicine_type\": 1}"
        );

        boolean updated = updater.apply(document, config, Map.of(100L, 910L, 200L, 920L));

        assertThat(updated).isTrue();
        assertThat(document.getString("ind_medi_info"))
                .isEqualTo("[{\"cd\":910,\"medicine_type\":1},{\"cd\":200,\"medicine_type\":2}]");
    }

    @Test
    void updatesJsonStringArrayElementForEquipmentClassOnlyWhenEquipTypeZero() {
        Document document = new Document("ind_equip_info",
                "[{\"class_cd\":10,\"equip_type\":0},{\"class_cd\":20,\"equip_type\":1}]");

        FkMongoMigrationConfig config = config(
                "ind_equip_info[].class_cd",
                "JSON_STRING",
                "{\"equip_type\": 0}"
        );

        boolean updated = updater.apply(document, config, Map.of(10L, 910L, 20L, 920L));

        assertThat(updated).isTrue();
        assertThat(document.getString("ind_equip_info"))
                .isEqualTo("[{\"class_cd\":910,\"equip_type\":0},{\"class_cd\":20,\"equip_type\":1}]");
    }

    @Test
    void updatesJsonStringWildcardObjectKeys() {
        Document document = new Document("ind_cond_info",
                "{\"15\":{\"ind_user_id\":100},\"19\":{\"ind_user_id\":200}}");

        FkMongoMigrationConfig config = config(
                "ind_cond_info.*.ind_user_id",
                "JSON_STRING",
                null
        );

        boolean updated = updater.apply(document, config, Map.of(100L, 910L, 200L, 920L));

        assertThat(updated).isTrue();
        assertThat(document.getString("ind_cond_info"))
                .isEqualTo("{\"15\":{\"ind_user_id\":910},\"19\":{\"ind_user_id\":920}}");
    }

    @Test
    void updatesNestedBsonObjectField() {
        Document document = new Document("medical_care_info",
                new Document("main_course_cd", 100L)
                        .append("dialysis_course_cd", 200L)
                        .append("ward_cd", 300L));

        FkMongoMigrationConfig mainCourse = config("medical_care_info.main_course_cd", "BSON", null);
        FkMongoMigrationConfig dialysisCourse = config("medical_care_info.dialysis_course_cd", "BSON", null);
        FkMongoMigrationConfig ward = config("medical_care_info.ward_cd", "BSON", null);

        boolean updatedMain = updater.apply(document, mainCourse, Map.of(100L, 910L));
        boolean updatedDialysis = updater.apply(document, dialysisCourse, Map.of(200L, 920L));
        boolean updatedWard = updater.apply(document, ward, Map.of(300L, 930L));

        assertThat(updatedMain).isTrue();
        assertThat(updatedDialysis).isTrue();
        assertThat(updatedWard).isTrue();
        Document medicalCareInfo = document.get("medical_care_info", Document.class);
        assertThat(medicalCareInfo.get("main_course_cd")).isEqualTo(910L);
        assertThat(medicalCareInfo.get("dialysis_course_cd")).isEqualTo(920L);
        assertThat(medicalCareInfo.get("ward_cd")).isEqualTo(930L);
    }

    @Test
    void updatesAcceptanceStatusInfoOrdNoFromJsonString() {
        Document document = new Document("acceptance_status_info",
                "[{\"ord_no\":100,\"class\":\"5\"},{\"ord_no\":200,\"class\":\"6\"}]");

        FkMongoMigrationConfig config = config(
                "acceptance_status_info[].ord_no",
                "JSON_STRING",
                null
        );

        boolean updated = updater.apply(document, config, Map.of(100L, 910L, 200L, 920L));

        assertThat(updated).isTrue();
        assertThat(document.getString("acceptance_status_info"))
                .isEqualTo("[{\"ord_no\":910,\"class\":\"5\"},{\"ord_no\":920,\"class\":\"6\"}]");
    }

    @Test
    void skipsCourseCdWhenMedicalHistoryIsFreeInput() {
        Document document = new Document("medical_hst_info", List.of(
                new Document("course_cd", "42").append("course_is_free", "0"),
                new Document("course_cd", "42").append("course_is_free", "1"),
                new Document("course_cd", "山田内科").append("course_is_free", "1")
        ));

        FkMongoMigrationConfig config = config(
                "medical_hst_info[].course_cd",
                "BSON",
                "{\"course_is_free\": \"0\"}"
        );

        boolean updated = updater.apply(document, config, Map.of(42L, 1042L));

        assertThat(updated).isTrue();
        List<?> values = document.getList("medical_hst_info", Object.class);
        Document first = (Document) values.getFirst();
        Document second = (Document) values.get(1);
        Document third = (Document) values.get(2);
        assertThat(first.get("course_cd")).isEqualTo("1042");
        assertThat(second.get("course_cd")).isEqualTo("42");
        assertThat(third.get("course_cd")).isEqualTo("山田内科");
    }

    @Test
    void preservesStringTypeForTopLevelBsonField() {
        Document document = new Document("up_user_id", "100");

        FkMongoMigrationConfig config = config(
                "up_user_id",
                "BSON",
                null
        );

        boolean updated = updater.apply(document, config, Map.of(100L, 990L));

        assertThat(updated).isTrue();
        assertThat(document.getString("up_user_id")).isEqualTo("990");
    }

    private FkMongoMigrationConfig config(String fieldPath, String fieldEncoding, String whereCondition) {
        FkMongoMigrationConfig config = new FkMongoMigrationConfig();
        config.setFieldPath(fieldPath);
        config.setFieldEncoding(fieldEncoding);
        config.setWhereCondition(whereCondition);
        return config;
    }
}
