package jp.co.nikkiso.ntss.admin_web.service.patHistory.patUniqueHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 既往歴情報
@Getter
@Setter
public class MedicalHstInfo {
    // 管理番号
    private Integer ctl_no;
    // 表示順
    private Integer disp_order;
    // 登録施設コード
    private String facility_cd;
    // 登録施設名
    private String facility_name;
    // 主病名
    private String is_main_disease;
    // 告知
    private String is_notice;
    // 発症日
    private String disease_date;
    // 病名マスタ.病名コード
    private Integer disease_cd;
    // 病名マスタ.病名
    private String disease_name;
    // 病名マスタ.病名連携コード1
    private String dis_in_hospital_cd_1;
    // 転帰
    private String out_come;
    // 転帰変更日
    private String out_come_date;
    // スタッフマスタ.スタッフコード
    private Object diagnostician_cd;
    // スタッフマスタ.スタッフ名
    private String diagnostician_name;
    // コメント
    private String memo;
    // 診断年
    private String diagnosis_year;
    // 診断月
    private String diagnosis_month;
    // 診断日
    private String diagnosis_day;
    // 診断日
    private String diagnosis_date;
    // 施設 施設マスタ.施設コード
    private String diagnosis_facility_cd;
    // 施設 施設マスタ.施設名
    private String diagnosis_facility_name;
    // 診断施設がフリー入力されているか
    private String diagnosis_facility_is_free;
    // 診療科 診療科マスタ.診療科コード
    private Object course_cd;
    // 診療科 診療科マスタ.診療科名
    private String course_name;
    // 生検確認あり
    private String is_confirmation_biopsy;
    // 確定診断あり
    private String is_diagnosed;
    // 透析導入原疾患として扱う
    private String is_dialysis_underlying_disease;
    // 発症年
    private String disease_year;
    // 発症月
    private String disease_month;
    // 発症日
    private String disease_day;
    // 診療科がフリー入力されているか
    private String course_is_free;
    // 診断医がフリー入力されているか
    private String diagnostician_is_free;
    // 死亡日
    private String die_date;


    // 死因コード
    private Integer cause_death;
    // 原疾患
    private String is_primary_illness;
    // 編集不可
    private String readonly;

}
