package jp.co.nikkiso.ntss.admin_web.service.patHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 感染症情報
@Getter
@Setter
public class InfectInfo {
    // 管理番号
    private Integer ctl_no;
    // 感染症コード
    private Integer infection_cd;
    // 感染症名
    private String infection_name;
    // 結果コード
    private String infect;
    // 検査日
    private String exam_date;
    // 更新日時
    private String up_date;
}
