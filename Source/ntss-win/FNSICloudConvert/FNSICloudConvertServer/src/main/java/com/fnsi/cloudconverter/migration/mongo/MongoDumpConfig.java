package com.fnsi.cloudconverter.migration.mongo;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * mongo_dump_config.yaml バインディング
 */
@Data
@Component
@ConfigurationProperties(prefix = "mongo-dump")
public class MongoDumpConfig {
    private List<MongoCollectionConfig> collections = new ArrayList<>();

    /** ダンプ対象コレクションのみ返す */
    public List<MongoCollectionConfig> dumpTargets() {
        return collections.stream().filter(MongoCollectionConfig::isDump).toList();
    }
}
