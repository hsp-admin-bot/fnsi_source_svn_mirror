package com.fnsi.cloudconverter.clear.online.mongo;

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
public class OnlineMongoClearServiceImpl implements OnlineMongoClearService {

    private final MongoDumpConfig mongoDumpConfig;

    @Override
    public void clearFacilityData(List<String> facilityCodes, MongoDatabase prodMongo) {
        mongoDumpConfig.dumpTargets().forEach(cfg -> {
            if (cfg.getFilterField() == null) return;
            Bson filter = Filters.in(cfg.getFilterField(), facilityCodes);
            long deleted = prodMongo.getCollection(cfg.getName()).deleteMany(filter).getDeletedCount();
            log.info("[CLEAR_ONLINE_MONGO] collection={}, deleted={}", cfg.getName(), deleted);
        });
    }
}
