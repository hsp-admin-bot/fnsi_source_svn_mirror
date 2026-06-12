package com.fnsi.cloudconverter.facility.model;

import java.time.Instant;
import java.util.List;

/**
 * on2off 用 sequence 事前予約プランレスポンス
 */
public record FacilitySeqReservePlanResponse(
        List<String> facilityCodes,
        List<FacilitySeqReservePlanItem> tablePlans,
        long totalReserveCount,
        Instant calculatedAt
) {}
