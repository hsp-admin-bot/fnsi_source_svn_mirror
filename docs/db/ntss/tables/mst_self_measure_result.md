# mst_self_measure_result

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_self_measure_result`
- Logical name: 自己診断判定マスタ
- Physical name: `mst_self_measure_result`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `self_measure_result_cd`
- Column count: 10
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_self_measure_result.md](../config/mst_self_measure_result.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 自己診断判定コード | self_measure_result_cd | bigserial |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 対象機種 | disp_machine_name | character varying |  |  |  | 対象機種名＋バージョンを1件毎に改行して設定 |
|  | 対象機種情報 | machine_info | jsonb |  |  |  | 「@mst_self_measure_result」参照 |
|  | 自己診断情報 | self_measure_result | jsonb |  |  |  | 「@mst_self_measure_result」参照 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | 0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意な職種コード | fn_self_measure_result_cd | character varying | 23 |  |  |  |
