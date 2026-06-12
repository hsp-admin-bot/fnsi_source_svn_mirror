package com.fnsi.cloudconverter.job.model;

/**
 * off2on JOB 起動時のアップロードID群 (02_api.md § 7)
 */
public record UploadIds(
        String pgDump,
        String mongoDump,
        String files
) {}
