package com.fnsi.cloudconverter.facility.model;

import java.util.List;

/**
 * 施設一覧レスポンス (02_api.md § 5)
 */
public record FacilityListResponse(
        long              total,
        int               page,
        int               size,
        List<FacilityInfo> facilities
) {}
