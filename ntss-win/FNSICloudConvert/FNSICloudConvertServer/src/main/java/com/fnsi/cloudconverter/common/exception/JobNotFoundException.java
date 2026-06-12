package com.fnsi.cloudconverter.common.exception;

public class JobNotFoundException extends RuntimeException {
    public JobNotFoundException(long jobId) {
        super("JOB が見つかりません: " + jobId);
    }

    public JobNotFoundException(long jobId, String detail) {
        super("JOB が見つかりません: " + jobId + " (" + detail + ")");
    }
}
