package com.fnsi.cloudconverter.job.entity;

import com.fnsi.cloudconverter.job.model.TaskStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

/**
 * 移行タスク管理エンティティ (04_database.md § 2.2)
 */
@Entity
@Table(name = "migration_task")
@Getter
@Setter
public class MigrationTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "task_id")
    private Long taskId;

    @Column(name = "job_id", nullable = false)
    private Long jobId;

    @Column(name = "task_name", nullable = false)
    private String taskName;

    @Column(name = "phase", nullable = false)
    private String phase;

    @Column(name = "table_name", nullable = false)
    private String tableName = "";

    @Column(name = "slice_type", nullable = false)
    private String sliceType = "FULL";

    @Column(name = "slice_from")
    private String sliceFrom;

    @Column(name = "slice_to")
    private String sliceTo;

    @Column(name = "sql_text", nullable = false)
    private String sqlText = "";

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private TaskStatus status = TaskStatus.PENDING;

    @Column(name = "retry_count", nullable = false)
    private int retryCount = 0;

    @Column(name = "max_retry", nullable = false)
    private int maxRetry = 3;

    @Column(name = "estimated_rows")
    private Long estimatedRows;

    @Column(name = "affected_rows")
    private Long affectedRows;

    @Column(name = "started_at")
    private Instant startedAt;

    @Column(name = "finished_at")
    private Instant finishedAt;

    @Column(name = "last_error")
    private String lastError;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @PrePersist
    void prePersist() {
        createdAt = updatedAt = Instant.now();
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = Instant.now();
    }
}
