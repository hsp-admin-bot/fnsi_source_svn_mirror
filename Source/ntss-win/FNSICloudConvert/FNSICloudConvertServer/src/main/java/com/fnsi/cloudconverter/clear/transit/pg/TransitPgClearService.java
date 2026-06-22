package com.fnsi.cloudconverter.clear.transit.pg;

import java.util.List;

/** 中転 PG データ削除 (Module 18) */
public interface TransitPgClearService {
    void clearFacilityData(List<String> facilityCodes);
}
