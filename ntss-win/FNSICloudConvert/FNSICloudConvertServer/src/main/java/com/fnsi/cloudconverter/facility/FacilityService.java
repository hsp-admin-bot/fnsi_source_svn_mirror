package com.fnsi.cloudconverter.facility;

import com.fnsi.cloudconverter.facility.model.FacilityCountResponse;
import com.fnsi.cloudconverter.facility.model.FacilityListResponse;
import com.fnsi.cloudconverter.facility.model.FacilitySeqReservePlanResponse;

import java.util.List;

/**
 * 施設一覧サービス (03_module.md § Module 16)
 */
public interface FacilityService {
    FacilityListResponse  getFacilities(int page, int size, String keyword);
    FacilityCountResponse getTableCounts(List<String> facilityCodes);
    FacilitySeqReservePlanResponse getSeqReservePlan(List<String> facilityCodes);
}
