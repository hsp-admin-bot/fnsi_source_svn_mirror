package jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 患者グループ情報
@Getter
@Setter
public class PatGroupInfo {
    // 管理番号
    private Integer ctl_no;
    // 患者グループコード
    private String pat_group_cd;
    // 患者グループ名
    private String pat_group_name;
}
