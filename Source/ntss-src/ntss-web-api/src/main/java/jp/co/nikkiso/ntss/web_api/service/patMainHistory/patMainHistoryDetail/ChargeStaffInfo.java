package jp.co.nikkiso.ntss.web_api.service.patMainHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 担当スタッフ情報
@Getter
@Setter
public class ChargeStaffInfo {
    // 管理番号
    private Integer ctl_no;
    // 表示順
    private Integer disp_order;
    // スタッフコード
    private Integer staff_cd;
    // スタッフ表示用コード
    private String staff_disp_cd;
    // スタッフ名
    private String staff_name;
    // 主治医
    private String is_main;
    // 受持ち
    private String is_charge;
    // 穿刺
    private String is_puncture;
}
