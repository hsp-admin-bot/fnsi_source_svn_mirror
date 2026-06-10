package jp.co.nikkiso.ntss.admin_web.service.patHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 加算情報
@Getter
@Setter
public class AdditionInfo {
    // 管理番号
    private Integer ctl_no;
    // 加算・管理料コード
    private Integer cd;
    // 加算・管理料コード名称
    private String name;
    // 加算形式
    private String kind;
    // 有効フラグ
    private String is_enable;
    // 登録日
    private String reg_date;
    // 最終算定日
    private String last_date;
    // 指定日
    private String start_date;
}
