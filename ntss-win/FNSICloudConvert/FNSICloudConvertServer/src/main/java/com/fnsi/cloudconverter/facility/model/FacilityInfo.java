package com.fnsi.cloudconverter.facility.model;

import java.time.Instant;

/**
 * 施設情報
 */
public record FacilityInfo(
        String  facilityCd,
        String  facilityName,
        String  region,
        String  status,
        Instant lastMigratedAt
) {}
