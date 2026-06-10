package jp.co.nikkiso.ntss.admin_web.service.patHistory.patPersonalMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 透析困難情報
@Getter
@Setter
public class DialDiffComInfo {
    // 管理番号
    private Integer ctl_no;
    // 透析困難コード
    private Integer dial_diff_cd;
    // 透析困難名
    private String dial_diff_name;
    // 透析困難理由連携コード1
    private String in_hospital_cd_1;
    // 透析困難理由連携コード2
    private String in_hospital_cd_2;
    // 主たる透析困難フラグ
    private String is_main;
    // 透析困難フラグ
    private String is_dial_diff;
    // 登録日時
    private String reg_date;
}
