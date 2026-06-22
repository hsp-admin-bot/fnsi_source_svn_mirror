package com.fnsi.cloudconverter.facility.model;

import java.time.Instant;
import java.util.List;
import java.util.Map;

/**
 * 施設テーブル行数レスポンス (02_api.md § 6)
 */
public record FacilityCountResponse(
        List<String>       facilityCodes,
        Map<String, Long>  tableCounts,
        long               totalRows,
        Instant            calculatedAt
) {}
