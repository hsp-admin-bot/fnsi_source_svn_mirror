package com.fnsi.cloudconverter.job.model;

/**
 * JOB 実行オプション (02_api.md § 7)
 */
public record JobOptions(
        Integer parallelTasks,
        Integer retryLimit
) {
    public int parallelTasksOrDefault() {
        return parallelTasks != null ? parallelTasks : 4;
    }

    public int retryLimitOrDefault() {
        return retryLimit != null ? retryLimit : 3;
    }
}
