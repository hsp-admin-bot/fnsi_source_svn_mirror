package com.fnsi.cloudconverter.clear.transit.mongo;

import com.fnsi.cloudconverter.migration.mongo.MongoDumpConfig;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.bson.conversions.Bson;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class TransitMongoClearServiceImpl implements TransitMongoClearService {

    private final MongoDumpConfig mongoDumpConfig;

    @Override
    public void clearFacilityData(List<String> facilityCodes, MongoDatabase transitMongo) {
        mongoDumpConfig.dumpTargets().forEach(cfg -> {
            if (cfg.getFilterField() == null) return;
            Bson filter = Filters.in(cfg.getFilterField(), facilityCodes);
            long deleted = transitMongo.getCollection(cfg.getName()).deleteMany(filter).getDeletedCount();
            log.info("[CLEAR_TRANSIT_MONGO] collection={}, deleted={}", cfg.getName(), deleted);
        });
    }
}
