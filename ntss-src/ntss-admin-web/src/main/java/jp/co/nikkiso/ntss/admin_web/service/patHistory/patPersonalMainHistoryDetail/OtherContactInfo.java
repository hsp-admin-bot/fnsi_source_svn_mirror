package jp.co.nikkiso.ntss.admin_web.service.patHistory.patPersonalMainHistoryDetail;

import lombok.Getter;
import lombok.Setter;

// 連絡先情報
@Getter
@Setter
public class OtherContactInfo {
    // 管理番号
    private Integer ctl_no;
    // 表示順
    private Integer disp_order;
    // キーパーソン
    private String is_key_person;
    // 患者ID(登録患者指定時)
    private String pat_id;
    // 姓
    private String last_name;
    // 名
    private String first_name;
    // セイ
    private String last_name_kana;
    // メイ
    private String first_name_kana;
    // 続柄コード
    private Integer relation_cd;
    // 続柄名
    private String relation_name;
    // 郵便番号
    private String zip_cd;
    // 住所
    private String address;
    // 電話番号1
    private String tel1;
    // 電話番号2
    private String tel2;
    // Fax番号
    private String fax;
    // メールアドレス
    private String e_mail;
    // 勤務先名
    private String work_name;
    // 勤務先電話番号
    private String work_tel;
    // メモ1
    private String memo1;
    // メモ2
    private String memo2;
    // 勤務先住所
    private String work_address;


}
