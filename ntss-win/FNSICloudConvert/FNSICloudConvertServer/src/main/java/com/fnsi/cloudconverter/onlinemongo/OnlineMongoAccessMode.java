package com.fnsi.cloudconverter.onlinemongo;

import java.util.Locale;

public enum OnlineMongoAccessMode {
    AUTO,
    MODERN,
    DOCDB4;

    public static OnlineMongoAccessMode from(String value) {
        if (value == null || value.isBlank()) {
            return AUTO;
        }
        return switch (value.trim().toLowerCase(Locale.ROOT)) {
            case "modern" -> MODERN;
            case "docdb4", "legacy" -> DOCDB4;
            default -> AUTO;
        };
    }
}
