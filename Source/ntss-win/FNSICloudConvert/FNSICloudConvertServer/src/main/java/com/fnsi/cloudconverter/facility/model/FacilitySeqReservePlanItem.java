package com.fnsi.cloudconverter.facility.model;

/**
 * on2off 用 sequence 事前予約プラン明細
 */
public record FacilitySeqReservePlanItem(
        String tableName,
        String dbName,
        String idColumn,
        String seqName,
        long reserveCount
) {}
