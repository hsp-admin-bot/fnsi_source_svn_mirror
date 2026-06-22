package com.fnsi.cloudconverter.job;

import com.fnsi.cloudconverter.job.model.*;
import com.fnsi.cloudconverter.log.model.LogQueryResult;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * JOB 管理 API (02_api.md § 7-11)
 *
 * POST   /api/v1/jobs               — JOB 作成・起動
 * GET    /api/v1/jobs/{jobId}       — JOB ステータス取得
 * GET    /api/v1/jobs/{jobId}/logs  — ログ差分取得
 * DELETE /api/v1/jobs/{jobId}       — JOB 中断
 * POST   /api/v1/jobs/{jobId}/resume — JOB 再開
 */
@RestController
@RequestMapping("/api/v1/jobs")
@RequiredArgsConstructor
public class JobController {

    private final JobService jobService;

    /** JOB 作成・起動 */
    @PostMapping
    public ResponseEntity<CreateJobResponse> createJob(
            @Valid @RequestBody CreateJobRequest request) {
        return ResponseEntity.status(HttpStatus.ACCEPTED)
                .body(jobService.createJob(request));
    }

    /** JOB ステータス・進捗取得（1秒ポーリング用） */
    @GetMapping("/{jobId}")
    public ResponseEntity<JobStatusResponse> getJob(@PathVariable long jobId) {
        return ResponseEntity.ok(jobService.getJob(jobId));
    }

    /** ログ差分取得（オフセットポーリング用） */
    @GetMapping("/{jobId}/logs")
    public ResponseEntity<LogQueryResult> getLogs(
            @PathVariable long jobId,
            @RequestParam(defaultValue = "0")   long   offset,
            @RequestParam(defaultValue = "200") int    limit,
            @RequestParam(required = false)     String level,
            @RequestParam(required = false)     Long   taskId) {
        return ResponseEntity.ok(jobService.getLogs(jobId, offset, limit, level, taskId));
    }

    /** JOB 中断 */
    @DeleteMapping("/{jobId}")
    public ResponseEntity<InterruptJobResponse> interruptJob(
            @PathVariable long jobId,
            @RequestParam(required = false) String reason) {
        return ResponseEntity.ok(jobService.interruptJob(jobId, reason));
    }

    /** JOB 再開（断点再開） */
    @PostMapping("/{jobId}/resume")
    public ResponseEntity<ResumeJobResponse> resumeJob(
            @PathVariable long jobId,
            @RequestBody(required = false) ResumeJobRequest request) {
        return ResponseEntity.status(HttpStatus.ACCEPTED)
                .body(jobService.resumeJob(jobId, request));
    }
}
