package jp.co.nikkiso.ntss.web_api.service.patMainHistory.patMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 患者メモ情報
@Getter
@Setter
public class PatMemoInfo {
    // 管理番号
    private Integer ctl_no;
    // タイトル
    private String title;
    // 内容
    private String content;
}
