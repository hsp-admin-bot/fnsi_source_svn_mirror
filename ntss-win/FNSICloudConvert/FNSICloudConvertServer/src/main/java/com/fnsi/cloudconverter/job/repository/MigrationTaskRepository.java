package com.fnsi.cloudconverter.job.repository;

import com.fnsi.cloudconverter.job.entity.MigrationTask;
import com.fnsi.cloudconverter.job.model.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MigrationTaskRepository extends JpaRepository<MigrationTask, Long> {

    List<MigrationTask> findByJobIdOrderByTaskId(Long jobId);

    List<MigrationTask> findByJobIdAndStatus(Long jobId, TaskStatus status);

    @Query("SELECT COUNT(t) FROM MigrationTask t WHERE t.jobId = :jobId AND t.status = :status")
    long countByJobIdAndStatus(@Param("jobId") Long jobId, @Param("status") TaskStatus status);

    /** FAILED タスクを PENDING にリセット（断点再開用） */
    @Modifying
    @Query("UPDATE MigrationTask t SET t.status = 'PENDING', t.retryCount = 0, t.lastError = null " +
           "WHERE t.jobId = :jobId AND t.status = 'FAILED'")
    int resetFailedTasks(@Param("jobId") Long jobId);
}
