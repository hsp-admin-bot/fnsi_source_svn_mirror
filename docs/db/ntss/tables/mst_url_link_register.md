# mst_url_link_register

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_url_link_register`
- Logical name: 外部リンクメニューマスタ
- Physical name: `mst_url_link_register`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `url_cd`
- Column count: 8
- NOT NULL columns: 3

## Related Config / Notes

- [../config/url_info.md](../config/url_info.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意なURLコード | url_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 機能名 | function_name | character varying | 256 |  |  |  |
|  | 外部リンク情報 | url_info | jsonb | 4 | 1 | {}'::jsonb | @url_infoで参考 |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
