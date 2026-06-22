package com.fnsi.cloudconverter.migration.pg;

/**
 * pg_dump / pg_restore 実行結果
 */
public record DumpResult(
        String  tableName,
        boolean success,
        long    rows,
        String  errorOutput
) {
    public static DumpResult ok(String tableName, long rows) {
        return new DumpResult(tableName, true, rows, null);
    }

    public static DumpResult fail(String tableName, String errorOutput) {
        return new DumpResult(tableName, false, 0L, errorOutput);
    }
}
