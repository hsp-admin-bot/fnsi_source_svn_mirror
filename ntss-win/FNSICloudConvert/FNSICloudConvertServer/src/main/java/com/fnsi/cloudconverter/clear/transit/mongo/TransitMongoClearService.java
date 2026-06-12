package com.fnsi.cloudconverter.clear.transit.mongo;

import com.mongodb.client.MongoDatabase;
import java.util.List;

/** 中転 Mongo データ削除 (Module 20) */
public interface TransitMongoClearService {
    void clearFacilityData(List<String> facilityCodes, MongoDatabase transitMongo);
}
