package com.fnsi.cloudconverter.job.repository;

import com.fnsi.cloudconverter.job.entity.MigrationJob;
import com.fnsi.cloudconverter.job.model.JobStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MigrationJobRepository extends JpaRepository<MigrationJob, Long> {
    List<MigrationJob> findByStatus(JobStatus status);
}
