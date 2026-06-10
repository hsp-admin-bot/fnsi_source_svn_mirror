# mst_weight_print

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_weight_print `
- Logical name: 体重計印字項目マスタ
- Physical name: `mst_weight_print`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `content_cd`
- Column count: 12
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_weight_print.md](../config/mst_weight_print.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 項目コード | content_cd | serial |  | 1 |  |  |
|  | 項目名 | content_name | character varying | 20 |  |  |  |
|  | 印刷区分 | print_class | numeric | 2,0 |  |  | 足し算 1:前体重、2;後体重、4:スケジュールなし 8:患者未設定 |
|  | データ種別 | print_item_type | character varying | 10 |  |  | number/date/text/<br>用紙カット(cut)や罫線(hr)、バーコードなど<br>要検討 |
|  | 印刷フォーマット | default_data_format | character varying | 10 |  |  | 日付型ならyyyyMMdd。少数2桁数値型なら3.2など |
|  | データ前文字列 | default_before_word | character varying | 50 |  |  |  |
|  | データ後文字列 | default_after_word | character varying | 50 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
