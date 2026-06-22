package com.fnsi.cloudconverter.job.entity;

import com.fnsi.cloudconverter.job.model.JobStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;

/**
 * 移行ジョブ管理エンティティ (04_database.md § 2.1)
 */
@Entity
@Table(name = "migration_job")
@Getter
@Setter
public class MigrationJob {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "job_id")
    private Long jobId;

    @Column(name = "job_name", nullable = false)
    private String jobName;

    @Column(name = "direction", nullable = false)
    private String direction;

    @Column(name = "source_env")
    private String sourceEnv;

    @Column(name = "target_env")
    private String targetEnv;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "facility_codes", columnDefinition = "text[]", nullable = false)
    private String[] facilityCodes;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private JobStatus status = JobStatus.INIT;

    @Column(name = "note")
    private String note;

    /** JOB 作成時のリクエストパラメータ（JSON 文字列） */
    @Column(name = "job_params", columnDefinition = "text")
    private String jobParams;

    @Column(name = "started_at")
    private Instant startedAt;

    @Column(name = "finished_at")
    private Instant finishedAt;

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
