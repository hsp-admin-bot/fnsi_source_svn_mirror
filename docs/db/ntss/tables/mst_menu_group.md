# mst_menu_group

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_menu_group`
- Logical name: メニューグループマスタ
- Physical name: `mst_menu_group`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `menu_group_cd`
- Column count: 9
- NOT NULL columns: 4

## Related Config / Notes

- [../config/icon_info.md](../config/icon_info.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意なURLコード | menu_group_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | メニューグループ名 | menu_group_name | character varying | 256 |  |  |  |
|  | メニュー一覧 | menu_list | jsonb | 4 | 1 | []'::jsonb | function_cdの配列　[string, …]<br><br>※施設マスタにて対象施設に許可されている機能のみ登録<br>※施設マスタで許可機能を本マスタ設定後にOFFにしてもデータは残る。再度ONにしたときには有効設定として見える |
|  | アイコン情報 | icon_info | jsonb | 4 | 1 | {}'::jsonb | @icon_infoで参考 |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
