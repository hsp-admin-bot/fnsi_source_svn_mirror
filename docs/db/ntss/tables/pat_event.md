# pat_event

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_event`
- Logical name: 患者イベント情報
- Physical name: `pat_event`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_event_cd`
- Column count: 30
- NOT NULL columns: 2

## Related Config / Notes

- [../config/letter_info.md](../config/letter_info.md)
- [../config/pat_event.md](../config/pat_event.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者イベントコード | pat_event_cd | bigserial |  | 1 |  |  |
|  | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | FNW+で管理する施設内の一意なシーケンスID | fn_ctl_no | bigint |  |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 状況区分 | event_status | character varying | 1 |  |  | ’0'：予定、'1'：実績あり |
|  | テンプレートコード | template_cd | bigint |  |  |  | mst_pat_event_template.template_cd |
|  | テンプレート名称 | template_name | character varying | 40 |  |  | mst_pat_event_template.template_name |
|  | カテゴリコード | category_cd | bigint |  |  |  | mst_pat_event_category.category_cd |
|  | カテゴリ名称 | category_name | character varying | 40 |  |  | mst_pat_event_category.category_name |
|  | 利用種別 | use_type | smallint |  |  |  | 0:通常, 1:VA, 2:観察記録, 3:紹介状 |
|  | システムで管理する一意なオーダ番号 | ord_no | bigint |  |  |  | 透析情報.オーダ番号 |
|  | 項目情報 | input_params | jsonb |  |  |  | mst_pat_event_template.input_params |
|  | イベント開始日 | event_start_date | character varying | 8 |  |  |  |
|  | イベント終了日 | event_end_date | character varying | 8 |  |  |  |
|  | サブカテゴリコード | sub_category_cd | bigint |  |  |  | mst_pat_event_sub_category.sub_category_cd |
|  | サブカテゴリ名称 | sub_category_name | character varying | 40 |  |  | mst_pat_event_category.category_name |
|  | 項目実績 | result_params | jsonb |  |  |  | @pat_event 項目実績情報 |
|  | スコア合計 | score_total | integer |  |  |  |  |
|  | 起票者情報 | reg_staff_info | jsonb |  |  | E'{"reg_staff_cd":null,"reg_staff_name":null}' | @pat_event 起票者情報 |
|  | 編集者情報 | up_staff_info | jsonb |  |  | E'{"up_staff_cd":null,"up_staff_name":null}' | @pat_event 編集者情報 |
|  | 掲示板管理番号 | bbs_ctl_no | bigint |  |  |  | 掲示板登録情報.掲示板管理番号 |
|  | 最新フラグ | is_newest | character varying | 1 |  | '1' | '0':過去データ、'1':最新データ |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 紹介状情報 | letter_info | jsonb |  |  |  | @letter_infoを参考 |
|  | イベント開始時刻 | event_start_time | character varying | 4 |  |  |  |
|  | イベント終了時刻 | event_end_time | character varying | 4 |  |  |  |
|  | テンプレートのアドレス | report_url | varchar | 100 |  |  | 取込PDFテンプレートのS3の格納アドレス |
|  | 転入転出日付 | report_date | varchar | 10 |  |  | 患者情報連携用転入転出日付 |
