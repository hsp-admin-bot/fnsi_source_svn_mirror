package com.fnsi.cloudconverter.migration.mongo;

/**
 * mongoexport / mongoimport 実行結果
 */
public record StreamResult(
        String  collectionName,
        boolean success,
        long    rows,
        String  errorOutput
) {
    public static StreamResult ok(String name, long rows) {
        return new StreamResult(name, true, rows, null);
    }

    public static StreamResult fail(String name, String errorOutput) {
        return new StreamResult(name, false, 0L, errorOutput);
    }
}
