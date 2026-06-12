package com.fnsi.cloudconverter.facility;

import com.fnsi.cloudconverter.facility.model.FacilityCountResponse;
import com.fnsi.cloudconverter.facility.model.FacilityListResponse;
import com.fnsi.cloudconverter.facility.model.FacilitySeqReservePlanResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;

/**
 * 施設管理 API (02_api.md § 5-6)
 *
 * GET /api/v1/facilities       — 施設一覧取得
 * GET /api/v1/facilities/count — テーブル行数取得
 * GET /api/v1/facilities/seq-plan — on2off sequence 事前予約プラン取得
 */
@RestController
@RequestMapping("/api/v1/facilities")
@RequiredArgsConstructor
public class FacilityController {

    private final FacilityService facilityService;

    /** 施設一覧取得 */
    @GetMapping
    public ResponseEntity<FacilityListResponse> getFacilities(
            @RequestParam(defaultValue = "0")   int    page,
            @RequestParam(defaultValue = "100") int    size,
            @RequestParam(required = false)     String keyword) {
        return ResponseEntity.ok(facilityService.getFacilities(page, size, keyword));
    }

    /** テーブル行数取得（カンマ区切り施設コードリスト） */
    @GetMapping("/count")
    public ResponseEntity<FacilityCountResponse> getCount(
            @RequestParam("facility_cd") String facilityCd) {
        return ResponseEntity.ok(facilityService.getTableCounts(parseFacilityCodes(facilityCd)));
    }

    /** on2off 用 sequence 事前予約プラン取得（カンマ区切り施設コードリスト） */
    @GetMapping("/seq-plan")
    public ResponseEntity<FacilitySeqReservePlanResponse> getSeqPlan(
            @RequestParam("facility_cd") String facilityCd) {
        return ResponseEntity.ok(facilityService.getSeqReservePlan(parseFacilityCodes(facilityCd)));
    }

    private List<String> parseFacilityCodes(String facilityCd) {
        List<String> facilityCodes = Arrays.stream(facilityCd.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();

        if (facilityCodes.isEmpty()) {
            throw new IllegalArgumentException("facility_cd パラメータが未指定です");
        }
        return facilityCodes;
    }
}
