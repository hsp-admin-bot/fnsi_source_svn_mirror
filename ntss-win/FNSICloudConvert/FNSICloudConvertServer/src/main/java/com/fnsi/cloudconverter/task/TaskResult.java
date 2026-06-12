package com.fnsi.cloudconverter.task;

/**
 * Task 実行結果
 */
public record TaskResult(
        long    taskId,
        String  taskName,
        boolean success,
        long    affectedRows,
        String  errorMessage
) {
    public static TaskResult ok(long taskId, String taskName, long affectedRows) {
        return new TaskResult(taskId, taskName, true, affectedRows, null);
    }

    public static TaskResult fail(long taskId, String taskName, String errorMessage) {
        return new TaskResult(taskId, taskName, false, 0L, errorMessage);
    }
}
