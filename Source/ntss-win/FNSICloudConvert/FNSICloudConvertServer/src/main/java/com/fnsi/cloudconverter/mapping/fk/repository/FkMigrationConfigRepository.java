package com.fnsi.cloudconverter.mapping.fk.repository;

import com.fnsi.cloudconverter.mapping.fk.entity.FkMigrationConfig;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * FK 設定リポジトリ (03_module.md § Module 6)
 */
public interface FkMigrationConfigRepository extends JpaRepository<FkMigrationConfig, Long> {

    List<FkMigrationConfig> findByEnabledTrueOrderByExecutionOrderAsc();

    List<FkMigrationConfig> findByTableNameAndEnabledTrue(String tableName);
}
