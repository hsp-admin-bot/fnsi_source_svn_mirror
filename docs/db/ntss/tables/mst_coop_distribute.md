# mst_coop_distribute

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_coop_distribute`
- Logical name: 連携配信設定マスタ
- Physical name: `mst_coop_distribute`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 14
- NOT NULL columns: 5

## Related Config / Notes

- [../config/mst_cop_distribute.md](../config/mst_cop_distribute.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 電文種別 | coop_cd | character varying | 20 | 1 |  |  |
|  | 付帯情報（電文） | coop_cd_index | character varying | 10 | 1 | '' | （IBM)電文種別の付帯情報<br>レポート等にも使う? |
|  | 向き（送受信） | direction | character varying | 1 | 1 |  | S:送信　R:受信 |
|  | 対応ベンダー名 | coop_vender | character varying |  |  |  |  |
|  | 説明 | description | character varying |  |  |  |  |
|  | 編集可否フラグ | is_editable | character varying | 1 |  |  | '0'：編集不可、'1'：編集可 |
|  | 配信設定 | distribute_setting | jsonb |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
