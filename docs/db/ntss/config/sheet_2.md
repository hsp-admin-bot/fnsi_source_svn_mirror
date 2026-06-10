# マルチ患者レイアウトマスタ

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@マルチ患者レイアウトマスタ`
- Category: config/reference

## Content

| 項目一覧 | col2 | col3 | col4 | mst_pat_list_layout.disp_item_info に登録する構造 | col6 | col7 |
| --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  | ※値はすべて String |  |
| category | カテゴリ名 | items | 項目名 |  |  | ※Jsonには表示対象のカテゴリ情報群のみ格納する。 |
| person_info | 本人情報 | pat_name_kana | 患者名(カナ) |  | [ | ※表示対象のカテゴリにおいて、itemsには表示対象の項目キー名を配列で格納する。 |
| 1 | 1 | pat_name_alpha | 患者名(英語) |  | { |  |
| 1 | 1 | in_out_class | 入外 |  | "category": "person_info", |  |
| 1 | 1 | pat_birthday | 生年月日 |  | "items": [ |  |
| 1 | 1 | pat_sex | 性別 |  | "pat_name_kana", |  |
| 1 | 1 | pat_blood_type_abo | 血液型(ABO) |  | "pat_name_alpha", |  |
| 1 | 1 | pat_blood_type_rh | 血液型(Rh) |  | "in_out_class", |  |
| 1 | 1 | pat_blood_type_serovar | 血液型(亜型) |  | "pat_birthday", |  |
| 1 | 1 | nationality | 国籍 |  | "pat_sex", |  |
| 1 | 1 | zip_cd | 郵便番号 |  | "pat_blood_type_abo", |  |
| 1 | 1 | address | 住所 |  | "pat_blood_type_rh", |  |
| 1 | 1 | tel1 | 電話番号 |  | "pat_blood_type_serovar", |  |
| 1 | 1 | tel2 | 電話番号2 |  | "nationality", |  |
| 1 | 1 | fax | FAX |  | "zip_cd", |  |
| 1 | 1 | e_mail | Email |  | "address", |  |
| 1 | 1 | memo1 | メモ1 |  | "tel1", |  |
| 1 | 1 | memo2 | メモ2 |  | "tel2", |  |
| other_contact_info | 連絡先1 | last_name | 氏名(姓) |  | "fax", |  |
|  |  | first_name | 氏名(名) |  | "e_mail", |  |
|  |  | relation_name | 続柄 |  | "memo1", |  |
| 1 | 1 | zip_cd | 郵便番号 |  | "memo2" |  |
| 1 | 1 | address | 住所 |  | ] |  |
| 1 | 1 | tel1 | 電話番号 |  | }, |  |
| 1 | 1 | tel2 | 電話番号2 |  | { |  |
| 1 | 1 | fax | FAX |  | "category": "other_contact_info", |  |
| 1 | 1 | e_mail | Email |  | "items": [ |  |
| 1 | 1 | work_name | 勤務先 |  | "last_name", |  |
| 1 | 1 | work_tel | 勤務先電話番号 |  | "first_name", |  |
| 1 | 1 | memo1 | メモ1 |  | "relation_name", |  |
| 1 | 1 | memo2 | メモ2 |  | "zip_cd", |  |
| other_contact_info_2 | 連絡先2 | last_name | 氏名(姓) |  | "address", |  |
|  |  | first_name | 氏名(名) |  | "tel1", |  |
|  |  | relation_name | 続柄 |  | "tel2", |  |
| 1 | 1 | zip_cd | 郵便番号 |  | "fax", |  |
| 1 | 1 | address | 住所 |  | "e_mail", |  |
| 1 | 1 | tel1 | 電話番号 |  | "work_name", |  |
| 1 | 1 | tel2 | 電話番号2 |  | "work_tel", |  |
| 1 | 1 | fax | FAX |  | "memo1", |  |
| 1 | 1 | e_mail | Email |  | "memo2" |  |
| 1 | 1 | work_name | 勤務先 |  | ] |  |
| 1 | 1 | work_tel | 勤務先電話番号 |  | }, |  |
| 1 | 1 | memo1 | メモ1 |  | { |  |
| 1 | 1 | memo2 | メモ2 |  | "category": "other_contact_info_2", |  |
| other_contact_info_3 | 連絡先3 | last_name | 氏名(姓) |  | "items": [ |  |
|  |  | first_name | 氏名(名) |  | "last_name", |  |
|  |  | relation_name | 続柄 |  | "first_name", |  |
| 1 | 1 | zip_cd | 郵便番号 |  | "relation_name", |  |
| 1 | 1 | address | 住所 |  | "zip_cd", |  |
| 1 | 1 | tel1 | 電話番号 |  | "address", |  |
| 1 | 1 | tel2 | 電話番号2 |  | "tel1", |  |
| 1 | 1 | fax | FAX |  | "tel2", |  |
| 1 | 1 | e_mail | Email |  | "fax", |  |
| 1 | 1 | work_name | 勤務先 |  | "e_mail", |  |
| 1 | 1 | work_tel | 勤務先電話番号 |  | "work_name", |  |
| 1 | 1 | memo1 | メモ1 |  | "work_tel", |  |
| 1 | 1 | memo2 | メモ2 |  | "memo1", |  |
| vendor_contact_info | 連絡先(業者)1 | company_name | 会社名 |  | "memo2" |  |
| 1 | 1 | zip_cd | 郵便番号 |  | ] |  |
| 1 | 1 | address | 住所 |  | }, |  |
| 1 | 1 | company_tel | 代表電話番号 |  | { |  |
| 1 | 1 | fax | 代表FAX |  | "category": "other_contact_info_3", |  |
| 1 | 1 | worker_last_name | 担当者名(姓) |  | "items": [ |  |
| 1 | 1 | worker_first_name | 担当者名(名) |  | "last_name", |  |
| 1 | 1 | worker_tel | 電話番号 |  | "first_name", |  |
| 1 | 1 | worker_e_mail | Email |  | "relation_name", |  |
| 1 | 1 | memo1 | メモ1 |  | "zip_cd", |  |
| 1 | 1 | memo2 | メモ2 |  | "address", |  |
| vendor_contact_info_2 | 連絡先(業者)2 | company_name | 会社名 |  | "tel1", |  |
| 1 | 1 | zip_cd | 郵便番号 |  | "tel2", |  |
| 1 | 1 | address | 住所 |  | "fax", |  |
| 1 | 1 | company_tel | 代表電話番号 |  | "e_mail", |  |
| 1 | 1 | fax | 代表FAX |  | "work_name", |  |
| 1 | 1 | worker_last_name | 担当者名(姓) |  | "work_tel", |  |
| 1 | 1 | worker_first_name | 担当者名(名) |  | "memo1", |  |
| 1 | 1 | worker_tel | 電話番号 |  | "memo2" |  |
| 1 | 1 | worker_e_mail | Email |  | ] |  |
| 1 | 1 | memo1 | メモ1 |  | }, |  |
| 1 | 1 | memo2 | メモ2 |  | { |  |
| vendor_contact_info_3 | 連絡先(業者)3 | company_name | 会社名 |  | "category": "vendor_contact_info", |  |
| 1 | 1 | zip_cd | 郵便番号 |  | "items": [ |  |
| 1 | 1 | address | 住所 |  | "company_name", |  |
| 1 | 1 | company_tel | 代表電話番号 |  | "zip_cd", |  |
| 1 | 1 | fax | 代表FAX |  | "address", |  |
| 1 | 1 | worker_last_name | 担当者名(姓) |  | "company_tel", |  |
| 1 | 1 | worker_first_name | 担当者名(名) |  | "fax", |  |
| 1 | 1 | worker_tel | 電話番号 |  | "worker_last_name", |  |
| 1 | 1 | worker_e_mail | Email |  | "worker_first_name", |  |
| 1 | 1 | memo1 | メモ1 |  | "worker_tel", |  |
| 1 | 1 | memo2 | メモ2 |  | "worker_e_mail", |  |
| pat_memo_info | 患者メモ | title_1 | タイトル1 |  | "memo1", |  |
| 1 | 1 | content_1 | 内容1 |  | "memo2" |  |
| 1 | 1 | ～ | ～ |  | ] |  |
|  |  | title_20 | タイトル20 |  | }, |  |
|  |  | content_20 | 内容20 |  | { |  |
| dialysis_is_main | 透析困難(主) | dialysis_is_main | 透析困難(主) |  | "category": "vendor_contact_info_2", |  |
| dialysis | 透析困難 | dialysis | 透析困難 |  | "items": [ |  |
| severity_cd | 重症度 | severity_cd | 重症度 |  | "company_name", |  |
| transport_cd | 搬送区分 | transport_cd | 搬送区分 |  | "zip_cd", |  |
| medical_care_info | 診療情報 | main_course_cd | 診療科 |  | "address", |  |
|  |  | dialysis_course_cd | 透析実施科 |  | "company_tel", |  |
|  |  | ward_cd | 病棟 |  | "fax", |  |
|  |  | dialysis_count | 通算透析回数 |  | "worker_last_name", |  |
|  |  | fac_dialysis_count | 自施設通算透析回数 |  | "worker_first_name", |  |
|  |  | purification_count | 通算特殊浄化回数 |  | "worker_tel", |  |
|  |  | fac_purification_count | 自施設通算特殊浄化回数 |  | "worker_e_mail", |  |
|  |  | dialysis_start_date | 導入日 |  | "memo1", |  |
|  |  | dialysis_facility | 導入施設 |  | "memo2" |  |
|  |  | dial_hst_year_month | 透析歴 |  | ] |  |
| charge_staff_info | 担当者 | is_main | 主治医① |  | }, |  |
|  |  | is_main_2 | 主治医② |  | { |  |
|  |  | is_charge_1 | 担当① |  | "category": "vendor_contact_info_3", |  |
|  |  | is_charge_2 | 担当② |  | "items": [ |  |
|  |  | is_charge_3 | 担当③ |  | "company_name", |  |
|  |  | is_puncture_1 | 穿刺① |  | "zip_cd", |  |
|  |  | is_puncture_2 | 穿刺② |  | "address", |  |
| taboo_allergy_info | 禁忌・アレルギー | taboo | 禁忌 |  | "company_tel", |  |
|  |  | allergy | アレルギー |  | "fax", |  |
| infect_info | 感染症 | positive_infection | 感染症(+) |  | "worker_last_name", |  |
|  |  | negative_infection | 感染症(-) |  | "worker_first_name", |  |
|  |  | unclear_infection | 感染症(不明) |  | "worker_tel", |  |
|  |  | infection | 感染症 |  | "worker_e_mail", |  |
| implant_info | インプラント | implant | インプラント |  | "memo1", |  |
| medical_hst_info | 既往歴 | disease_cd | 透析導入原疾患 |  | "memo2" |  |
|  |  | is_confirmation_biopsy | 生検確認有無 |  | ] |  |
|  |  | disease_date | 透析導入原疾患発症日 |  | }, |  |
|  |  | out_come_date | 死亡日 |  | { |  |
|  |  | cause_death | 死因 |  | "category": "pat_memo_info", |  |
|  |  | is_diagnosed | 確診有無 |  | "items": [ |  |
|  |  | is_diabetes | 糖尿病患者 |  | "title_1", |  |
|  |  | is_blood_suger_exam | 血糖検査 |  | "content_1", |  |
|  |  | is_notice | 主病名① |  | "title_2", |  |
|  |  | is_notice_2 | 主病名② |  | "content_2", |  |
|  |  | is_notice_3 | 主病名③ |  | "title_3", |  |
| physical_info | 身体情報(追加登録) | exam_date | 測定日 |  | "content_3", |  |
|  |  | exam_time | 測定時刻 |  | "title_4", |  |
|  |  | order_clas | 測定区分 |  | "content_4", |  |
|  |  | height | 身長 |  | "title_5", |  |
|  |  | tr_weight | 測定時の体重 |  | "content_5", |  |
|  |  | breast_dia | 心横径 |  | "title_6", |  |
|  |  | chest_dia | 胸郭横径 |  | "content_6", |  |
|  |  | ctr | CTR |  | "title_7", |  |
|  |  | dw | DW |  | "content_7", |  |
|  |  | target_weight | 目標体重 |  | "title_8", |  |
|  |  | indicator_start | 指示開始日 |  | "content_8", |  |
|  |  | indicator_cd | 指示者 |  | "title_9", |  |
|  |  | memo | メモ |  | "content_9", |  |
| physical_info_height | 身体情報(最新：身長) | exam_date | 測定日 |  | "title_10", |  |
|  |  | exam_time | 測定時刻 |  | "content_10", |  |
|  |  | height | 身長 |  | "title_11", |  |
| physical_info_dw | 身体情報(最新：DW) | exam_date | 測定日 |  | "content_11", |  |
|  |  | exam_time | 測定時刻 |  | "title_12", |  |
|  |  | order_clas | 測定区分 |  | "content_12", |  |
|  |  | tr_weight | 測定時の体重 |  | "title_13", |  |
|  |  | breast_dia | 心横径 |  | "content_13", |  |
|  |  | chest_dia | 胸郭横径 |  | "title_14", |  |
|  |  | ctr | CTR |  | "content_14", |  |
|  |  | dw | DW |  | "title_15", |  |
| physical_info_ctr | 身体情報(最新：CTR) | exam_date | 測定日 |  | "content_15", |  |
|  |  | exam_time | 測定時刻 |  | "title_16", |  |
|  |  | order_clas | 測定区分 |  | "content_16", |  |
|  |  | tr_weight | 測定時の体重 |  | "title_17", |  |
|  |  | breast_dia | 心横径 |  | "content_17", |  |
|  |  | chest_dia | 胸郭横径 |  | "title_18", |  |
|  |  | ctr | CTR |  | "content_18", |  |
|  |  | dw | DW |  | "title_19", |  |
|  |  |  |  |  | "content_19", |  |
|  |  |  |  |  | "title_20", |  |
|  |  |  |  |  | "content_20" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "dialysis_is_main", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "dialysis_is_main" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "dialysis", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "dialysis" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "severity_cd", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "severity_cd" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "transport_cd", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "transport_cd" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "medical_care_info", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "main_course_cd", |  |
|  |  |  |  |  | "dialysis_course_cd", |  |
|  |  |  |  |  | "ward_cd", |  |
|  |  |  |  |  | "dialysis_count", |  |
|  |  |  |  |  | "fac_dialysis_count", |  |
|  |  |  |  |  | "purification_count", |  |
|  |  |  |  |  | "fac_purification_count", |  |
|  |  |  |  |  | "dialysis_start_date", |  |
|  |  |  |  |  | "dialysis_facility", |  |
|  |  |  |  |  | "dial_hst_year_month" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "charge_staff_info", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "is_main", |  |
|  |  |  |  |  | "is_main_2", |  |
|  |  |  |  |  | "is_charge_1", |  |
|  |  |  |  |  | "is_charge_2", |  |
|  |  |  |  |  | "is_charge_3", |  |
|  |  |  |  |  | "is_puncture_1", |  |
|  |  |  |  |  | "is_puncture_2" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "taboo_allergy_info", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "taboo", |  |
|  |  |  |  |  | "allergy" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "infect_info", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "positive_infection", |  |
|  |  |  |  |  | "negative_infection", |  |
|  |  |  |  |  | "unclear_infection", |  |
|  |  |  |  |  | "infection" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "implant_info", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "implant" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "medical_hst_info", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "disease_cd", |  |
|  |  |  |  |  | "is_confirmation_biopsy", |  |
|  |  |  |  |  | "disease_date", |  |
|  |  |  |  |  | "out_come_date", |  |
|  |  |  |  |  | "cause_death", |  |
|  |  |  |  |  | "is_diagnosed", |  |
|  |  |  |  |  | "is_diabetes", |  |
|  |  |  |  |  | "is_blood_suger_exam", |  |
|  |  |  |  |  | "is_notice", |  |
|  |  |  |  |  | "is_notice_2", |  |
|  |  |  |  |  | "is_notice_3" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "physical_info", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "exam_date", |  |
|  |  |  |  |  | "exam_time", |  |
|  |  |  |  |  | "order_clas", |  |
|  |  |  |  |  | "height", |  |
|  |  |  |  |  | "tr_weight", |  |
|  |  |  |  |  | "breast_dia", |  |
|  |  |  |  |  | "chest_dia", |  |
|  |  |  |  |  | "ctr", |  |
|  |  |  |  |  | "dw", |  |
|  |  |  |  |  | "target_weight", |  |
|  |  |  |  |  | "indicator_start", |  |
|  |  |  |  |  | "indicator_cd", |  |
|  |  |  |  |  | "memo" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "physical_info_height", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "exam_date", |  |
|  |  |  |  |  | "exam_time", |  |
|  |  |  |  |  | "height" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "physical_info_dw", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "exam_date", |  |
|  |  |  |  |  | "exam_time", |  |
|  |  |  |  |  | "order_clas", |  |
|  |  |  |  |  | "tr_weight", |  |
|  |  |  |  |  | "breast_dia", |  |
|  |  |  |  |  | "chest_dia", |  |
|  |  |  |  |  | "ctr", |  |
|  |  |  |  |  | "dw" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | }, |  |
|  |  |  |  |  | { |  |
|  |  |  |  |  | "category": "physical_info_ctr", |  |
|  |  |  |  |  | "items": [ |  |
|  |  |  |  |  | "exam_date", |  |
|  |  |  |  |  | "exam_time", |  |
|  |  |  |  |  | "order_clas", |  |
|  |  |  |  |  | "tr_weight", |  |
|  |  |  |  |  | "breast_dia", |  |
|  |  |  |  |  | "chest_dia", |  |
|  |  |  |  |  | "ctr", |  |
|  |  |  |  |  | "dw" |  |
|  |  |  |  |  | ] |  |
|  |  |  |  |  | } |  |
|  |  |  |  |  | ] |  |
