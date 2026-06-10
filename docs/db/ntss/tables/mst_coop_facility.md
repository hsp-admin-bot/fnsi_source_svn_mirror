# mst_coop_facility

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_coop_facility`
- Logical name: 連携設定マスタ
- Physical name: `mst_coop_facility`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 10
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_coop_facility.md](../config/mst_coop_facility.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 説明 | description | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | IFエッジ設定 | if_edge_setting | jsonb |  |  |  | IFエッジ側で使用する設定 |
|  | 各機能共通設定 | common_setting | jsonb |  |  |  | 将来の拡張用 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
