package jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// インプラント情報
@Getter
@Setter
public class ImplantInfo {
    // 管理番号
    private Integer ctl_no;
    // 表示順
    private Integer disp_order;
    // インプラントコード
    private Integer implant_cd;
    // インプラント名
    private String implant_name;
    // 導入日
    private String reg_date;
    // 除去日
    private String remove_date;
}
