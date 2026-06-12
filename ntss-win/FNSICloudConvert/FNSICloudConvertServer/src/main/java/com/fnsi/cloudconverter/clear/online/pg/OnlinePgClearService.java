package com.fnsi.cloudconverter.clear.online.pg;

import java.util.List;

/** 在線生産 PG データ削除 (Module 17) */
public interface OnlinePgClearService {
    void clearFacilityData(List<String> facilityCodes);
}
