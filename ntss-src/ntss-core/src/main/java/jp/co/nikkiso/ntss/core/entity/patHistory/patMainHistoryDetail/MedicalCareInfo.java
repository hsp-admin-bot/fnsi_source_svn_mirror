package jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 共通診療情報
@Getter
@Setter
public class MedicalCareInfo {
    // 診療科マスタ.診療科コード
    private Integer main_course_cd;
    // 診療科マスタ.診療科名
    private String main_course_name;
    // 診療科マスタ.診療科コード
    private Integer dialysis_course_cd;
    // 診療科マスタ.診療科名
    private String dialysis_course_name;
    // 診療科マスタ.診療科連携コード
    private String main_in_hospital_cd_1;
    // 病棟マスタ.病棟コード
    private Integer ward_cd;
    // 病棟マスタ.病棟名
    private String ward_name;
    // 病棟マスタ.病棟名連携コード
    private String ward_in_hospital_cd_1;
    // 透析回数
    private Integer dialysis_count;
    // 浄化治療回数
    private Integer purification_count;
    // 自施設透析回数
    private Integer pat_dialysis_count;
    // 他施設透析回数
    private Integer other_dialysis_count;
    // 施設マスタ.施設コード
    private String facility_cd;
    // 施設マスタ.施設名
    private String facility_name;
    // 透析導入日
    private String dialysis_start_date;
    // 当院開始日
    private String hospital_start_date;

    // 透析歴
    private String dyalysis_hst;
}
