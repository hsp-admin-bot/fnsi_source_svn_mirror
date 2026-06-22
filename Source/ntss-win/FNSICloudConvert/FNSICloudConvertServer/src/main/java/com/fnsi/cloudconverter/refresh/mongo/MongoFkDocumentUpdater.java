package com.fnsi.cloudconverter.refresh.mongo;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fnsi.cloudconverter.mapping.fkmongo.entity.FkMongoMigrationConfig;
import org.bson.Document;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

@Component
class MongoFkDocumentUpdater {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    boolean apply(Document document, FkMongoMigrationConfig config, Map<Long, Long> mapping) {
        if (mapping.isEmpty()) {
            return false;
        }

        MongoPathSpec path = MongoPathSpec.parse(config.getFieldPath());
        if ("JSON_STRING".equals(config.getFieldEncoding())) {
            return applyJsonString(document, config, path, mapping);
        }
        return applyBson(document, config, path, mapping);
    }

    void collectOldIds(Document document, FkMongoMigrationConfig config, Set<Long> oldIds) {
        MongoPathSpec path = MongoPathSpec.parse(config.getFieldPath());
        if ("JSON_STRING".equals(config.getFieldEncoding())) {
            collectJsonStringOldIds(document, config, path, oldIds);
            return;
        }
        collectBsonOldIds(document, config, path, oldIds);
    }

    private boolean applyBson(Document document, FkMongoMigrationConfig config, MongoPathSpec path, Map<Long, Long> mapping) {
        return applyToNode(document, path.segments(), 0, parseWhereCondition(config), mapping);
    }

    private void collectBsonOldIds(Document document, FkMongoMigrationConfig config, MongoPathSpec path, Set<Long> oldIds) {
        collectOldIdsFromNode(document, path.segments(), 0, parseWhereCondition(config), oldIds);
    }

    private boolean applyJsonString(Document document, FkMongoMigrationConfig config, MongoPathSpec path, Map<Long, Long> mapping) {
        if (path.segments().isEmpty()) {
            return false;
        }

        MongoPathSegment containerSegment = path.segments().getFirst();
        if (containerSegment.type() != MongoPathSegmentType.FIELD || !(document.get(containerSegment.value()) instanceof String rawJson)) {
            return false;
        }
        if (rawJson == null || rawJson.isBlank()) {
            return false;
        }

        Object parsed;
        try {
            parsed = OBJECT_MAPPER.readValue(rawJson, Object.class);
        } catch (JsonProcessingException e) {
            return false;
        }

        boolean updated = applyToNode(parsed, path.segments().subList(1, path.segments().size()), 0, parseWhereCondition(config), mapping);
        if (!updated) {
            return false;
        }

        try {
            document.put(containerSegment.value(), OBJECT_MAPPER.writeValueAsString(parsed));
            return true;
        } catch (JsonProcessingException e) {
            return false;
        }
    }

    private void collectJsonStringOldIds(Document document, FkMongoMigrationConfig config, MongoPathSpec path, Set<Long> oldIds) {
        if (path.segments().isEmpty()) {
            return;
        }

        MongoPathSegment containerSegment = path.segments().getFirst();
        if (containerSegment.type() != MongoPathSegmentType.FIELD || !(document.get(containerSegment.value()) instanceof String rawJson)) {
            return;
        }
        if (rawJson == null || rawJson.isBlank()) {
            return;
        }

        try {
            Object parsed = OBJECT_MAPPER.readValue(rawJson, Object.class);
            collectOldIdsFromNode(parsed, path.segments().subList(1, path.segments().size()), 0,
                    parseWhereCondition(config), oldIds);
        } catch (JsonProcessingException ignored) {
        }
    }

    private boolean applyToNode(Object node,
                                List<MongoPathSegment> segments,
                                int index,
                                Map<String, Object> whereCondition,
                                Map<Long, Long> mapping) {
        if (node == null || index >= segments.size()) {
            return false;
        }

        MongoPathSegment segment = segments.get(index);
        boolean isLeaf = index == segments.size() - 1;

        return switch (segment.type()) {
            case FIELD -> applyField(node, segment.value(), segments, index, isLeaf, whereCondition, mapping);
            case ARRAY -> applyArray(node, segments, index, whereCondition, mapping);
            case OBJECT_WILDCARD -> applyWildcard(node, segments, index, whereCondition, mapping);
        };
    }

    private void collectOldIdsFromNode(Object node,
                                       List<MongoPathSegment> segments,
                                       int index,
                                       Map<String, Object> whereCondition,
                                       Set<Long> oldIds) {
        if (node == null || index >= segments.size()) {
            return;
        }

        MongoPathSegment segment = segments.get(index);
        boolean isLeaf = index == segments.size() - 1;

        switch (segment.type()) {
            case FIELD -> collectFieldOldIds(node, segment.value(), segments, index, isLeaf, whereCondition, oldIds);
            case ARRAY -> collectArrayOldIds(node, segments, index, whereCondition, oldIds);
            case OBJECT_WILDCARD -> collectWildcardOldIds(node, segments, index, whereCondition, oldIds);
        }
    }

    @SuppressWarnings("unchecked")
    private void collectFieldOldIds(Object node,
                                    String fieldName,
                                    List<MongoPathSegment> segments,
                                    int index,
                                    boolean isLeaf,
                                    Map<String, Object> whereCondition,
                                    Set<Long> oldIds) {
        if (!(node instanceof Map<?, ?> rawMap)) {
            return;
        }
        Map<String, Object> map = (Map<String, Object>) rawMap;

        if (isLeaf) {
            if (!matchesWhereCondition(map, whereCondition)) {
                return;
            }
            Long oldId = parseLongValue(map.get(fieldName));
            if (oldId != null) {
                oldIds.add(oldId);
            }
            return;
        }

        collectOldIdsFromNode(map.get(fieldName), segments, index + 1, whereCondition, oldIds);
    }

    @SuppressWarnings("unchecked")
    private void collectArrayOldIds(Object node,
                                    List<MongoPathSegment> segments,
                                    int index,
                                    Map<String, Object> whereCondition,
                                    Set<Long> oldIds) {
        if (!(node instanceof List<?> rawList)) {
            return;
        }
        for (Object element : (List<Object>) rawList) {
            collectOldIdsFromNode(element, segments, index + 1, whereCondition, oldIds);
        }
    }

    @SuppressWarnings("unchecked")
    private void collectWildcardOldIds(Object node,
                                       List<MongoPathSegment> segments,
                                       int index,
                                       Map<String, Object> whereCondition,
                                       Set<Long> oldIds) {
        if (!(node instanceof Map<?, ?> rawMap)) {
            return;
        }
        for (Object value : ((Map<String, Object>) rawMap).values()) {
            collectOldIdsFromNode(value, segments, index + 1, whereCondition, oldIds);
        }
    }

    @SuppressWarnings("unchecked")
    private boolean applyField(Object node,
                               String fieldName,
                               List<MongoPathSegment> segments,
                               int index,
                               boolean isLeaf,
                               Map<String, Object> whereCondition,
                               Map<Long, Long> mapping) {
        if (!(node instanceof Map<?, ?> rawMap)) {
            return false;
        }
        Map<String, Object> map = (Map<String, Object>) rawMap;

        if (isLeaf) {
            Object currentValue = map.get(fieldName);
            if (!matchesWhereCondition(map, whereCondition)) {
                return false;
            }
            Long oldId = parseLongValue(currentValue);
            if (oldId == null) {
                return false;
            }
            Long newId = mapping.get(oldId);
            if (newId == null) {
                return false;
            }
            Object replacement = coerceReplacementValue(currentValue, newId);
            if (Objects.equals(currentValue, replacement)) {
                return false;
            }
            map.put(fieldName, replacement);
            return true;
        }

        return applyToNode(map.get(fieldName), segments, index + 1, whereCondition, mapping);
    }

    @SuppressWarnings("unchecked")
    private boolean applyArray(Object node,
                               List<MongoPathSegment> segments,
                               int index,
                               Map<String, Object> whereCondition,
                               Map<Long, Long> mapping) {
        if (!(node instanceof List<?> rawList)) {
            return false;
        }
        List<Object> list = (List<Object>) rawList;
        boolean updated = false;
        for (Object element : list) {
            updated |= applyToNode(element, segments, index + 1, whereCondition, mapping);
        }
        return updated;
    }

    @SuppressWarnings("unchecked")
    private boolean applyWildcard(Object node,
                                  List<MongoPathSegment> segments,
                                  int index,
                                  Map<String, Object> whereCondition,
                                  Map<Long, Long> mapping) {
        if (!(node instanceof Map<?, ?> rawMap)) {
            return false;
        }
        Map<String, Object> map = (Map<String, Object>) rawMap;
        boolean updated = false;
        for (Object value : map.values()) {
            updated |= applyToNode(value, segments, index + 1, whereCondition, mapping);
        }
        return updated;
    }

    private Map<String, Object> parseWhereCondition(FkMongoMigrationConfig config) {
        if (config.getWhereCondition() == null || config.getWhereCondition().isBlank()) {
            return Map.of();
        }
        try {
            Object parsed = OBJECT_MAPPER.readValue(config.getWhereCondition(), Object.class);
            if (parsed instanceof Map<?, ?> rawMap) {
                Map<String, Object> result = new java.util.LinkedHashMap<>();
                for (Map.Entry<?, ?> entry : rawMap.entrySet()) {
                    result.put(String.valueOf(entry.getKey()), entry.getValue());
                }
                return result;
            }
        } catch (JsonProcessingException ignored) {
        }
        return Map.of();
    }

    private boolean matchesWhereCondition(Map<String, Object> context, Map<String, Object> whereCondition) {
        if (whereCondition.isEmpty()) {
            return true;
        }
        for (Map.Entry<String, Object> entry : whereCondition.entrySet()) {
            Object actual = context.get(entry.getKey());
            Object expected = entry.getValue();
            if (!looselyEquals(actual, expected)) {
                return false;
            }
        }
        return true;
    }

    private boolean looselyEquals(Object actual, Object expected) {
        if (actual == null || expected == null) {
            return actual == expected;
        }
        if (actual instanceof Number actualNumber && expected instanceof Number expectedNumber) {
            return actualNumber.longValue() == expectedNumber.longValue();
        }
        return String.valueOf(actual).equals(String.valueOf(expected));
    }

    private Long parseLongValue(Object value) {
        if (value instanceof Number number) {
            return number.longValue();
        }
        if (value instanceof String stringValue && stringValue.matches("^\\d+$")) {
            return Long.parseLong(stringValue);
        }
        return null;
    }

    private Object coerceReplacementValue(Object originalValue, Long newId) {
        if (originalValue instanceof String) {
            return newId.toString();
        }
        if (originalValue instanceof Integer) {
            return Math.toIntExact(newId);
        }
        if (originalValue instanceof Short) {
            return newId.shortValue();
        }
        return newId;
    }

    record MongoPathSpec(List<MongoPathSegment> segments) {
        static MongoPathSpec parse(String rawPath) {
            List<MongoPathSegment> parsed = new ArrayList<>();
            for (String token : rawPath.split("\\.")) {
                if ("*".equals(token)) {
                    parsed.add(new MongoPathSegment(MongoPathSegmentType.OBJECT_WILDCARD, token));
                    continue;
                }
                if (token.endsWith("[]")) {
                    String fieldName = token.substring(0, token.length() - 2);
                    if (!fieldName.isBlank()) {
                        parsed.add(new MongoPathSegment(MongoPathSegmentType.FIELD, fieldName));
                    }
                    parsed.add(new MongoPathSegment(MongoPathSegmentType.ARRAY, "[]"));
                    continue;
                }
                parsed.add(new MongoPathSegment(MongoPathSegmentType.FIELD, token));
            }
            return new MongoPathSpec(List.copyOf(parsed));
        }
    }

    record MongoPathSegment(MongoPathSegmentType type, String value) {
    }

    enum MongoPathSegmentType {
        FIELD,
        ARRAY,
        OBJECT_WILDCARD
    }
}
