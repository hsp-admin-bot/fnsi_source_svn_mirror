package jp.co.nikkiso.ntss.admin_web.service.patHistory.patUniqueHistoryDetail;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

// 身体情報
@Getter
@Setter
public class PhysicalInfo {
    // 管理番号
    private Integer ctl_no;
    // 検査日時
    private String exam_date;
    // 検査区分
    private Integer order_class;
    // 身長
    private String height;
    // 検査時の体重
    private BigDecimal ctr_weight;
    // 心横径
    private String breast_dia;
    // 胸郭横径
    private String chest_dia;
    // CTR
    private String ctr;
    // DW
    private String dw;
    // 目標体重
    private String target_weight;
    // 指示者
    private String indicator_cd;
    // 指示者名
    private String indicator_name;
    // 更新者
    private String changer_cd;
    // 更新者名
    private String changer_name;
    // 指示開始日
    private String indicator_start_date;
    // メモ
    private String memo;
    // 前体重許容割合（上限）
    private String pre_scale_upper;
    // 前体重許容割合（下限）
    private String pre_scale_lower;
    // 施設コード
    private String facility_cd;
    // 施設名
    private String facility_name;
    // 検査日
    private String inspect_date;


    // 「目標重量」チェック・ボックス
    private Boolean target_weight_chkbox;
    // 測定時の体重
    private Integer tr_weight;

}
