package com.fnsi.cloudconverter.job;

import com.fnsi.cloudconverter.job.model.*;
import com.fnsi.cloudconverter.log.model.LogQueryResult;

public interface JobService {
    CreateJobResponse  createJob(CreateJobRequest request);
    JobStatusResponse  getJob(long jobId);
    InterruptJobResponse interruptJob(long jobId, String reason);
    ResumeJobResponse  resumeJob(long jobId, ResumeJobRequest request);
    LogQueryResult     getLogs(long jobId, long offset, int limit, String level, Long taskId);
}
