package jp.co.nikkiso.ntss.admin_web.service.patHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 禁忌・アレルギー情報
@Getter
@Setter
public class TabooAllergyInfo {
    // 管理番号
    private Integer ctl_no;
    // 表示順
    private Integer disp_order;
    // 内容
    private String content;
    // 備考
    private String memo;
    // 対象区分
    private String category_class;
    // 禁忌アレルギー区分
    private String taboo_allergy_class;
    // 禁忌・アレルギーコード
    private String taboo_allergy_cd;
}
