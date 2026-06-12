package com.fnsi.cloudconverter.mapping.fkmongo.repository;

import com.fnsi.cloudconverter.mapping.fkmongo.entity.FkMongoMigrationConfig;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * Mongo FK 設定リポジトリ (03_module.md § Module 7)
 */
public interface FkMongoMigrationConfigRepository extends JpaRepository<FkMongoMigrationConfig, Long> {

    List<FkMongoMigrationConfig> findByEnabledTrueOrderByExecutionOrderAscIdAsc();

    List<FkMongoMigrationConfig> findByCollectionNameAndEnabledTrue(String collectionName);
}
