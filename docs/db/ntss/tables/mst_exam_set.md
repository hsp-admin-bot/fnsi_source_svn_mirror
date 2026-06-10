# mst_exam_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_exam_set`
- Logical name: 検査セットマスタ
- Physical name: `mst_exam_set`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `exam_set_cd`
- Column count: 24
- NOT NULL columns: 5

## Related Config / Notes

- [../config/mst_exam_set.md](../config/mst_exam_set.md)
- [../config/advanced_settings.md](../config/advanced_settings.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な検査セットコード | exam_set_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | FNW+で管理する施設内の一意な検査セットコード | fn_exam_set_cd | character varying | 4 |  |  |  |
|  | セット種別 | set_class | character varying | 1 |  | '0' | '0'：検体検査 |
|  | 検査セット名 | exam_set_name | character varying | 40 | 1 |  |  |
|  | 省略検査セット名 | exam_set_short_name | character varying | 40 |  |  |  |
|  | セット使用区分 | exam_set_class | character varying | 1 |  | '0' | '0'：両用、'1'：依頼専用、'2'：結果専用 |
|  | 院内院外フラグ | is_in_hospital | character varying | 1 |  |  | '0':院外  '1':院内 |
|  | 至急フラグ | can_emergency | character varying | 1 |  | '0' | '0'：通常、'1'：至急可 |
|  | その他検査時刻 | other_exam_time | character varying | 4 | 1 | '0000' | HHMM |
|  | 検査項目情報 | exam_item_info | jsonb |  | 1 | []'::jsonb | ※@mst_exam_set参照 |
|  | 院内コード1 | in_hospital_cd1 | character varying | 20 |  |  |  |
|  | 属性コード1 | sbt_cd1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd2 | character varying | 20 |  |  |  |
|  | 属性コード2 | sbt_cd2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd3 | character varying | 20 |  |  |  |
|  | 属性コード3 | sbt_cd3 | character varying | 20 |  |  |  |
|  | ラベル情報 | label_info | jsonb |  |  |  | ※@mst_exam_set参照 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | グラフセット | graph_set | character varying |  |  |  |  |
|  | 検査区分 | order_class | jsonb |  |  | ["0","1","2"] | 1:透析前、2:透析後、0:その他 |
