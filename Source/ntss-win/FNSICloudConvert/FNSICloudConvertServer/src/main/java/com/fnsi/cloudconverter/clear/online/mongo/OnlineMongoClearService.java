package com.fnsi.cloudconverter.clear.online.mongo;

import com.mongodb.client.MongoDatabase;
import java.util.List;

/** 在線生産 Mongo データ削除 (Module 19) */
public interface OnlineMongoClearService {
    void clearFacilityData(List<String> facilityCodes, MongoDatabase prodMongo);
}
