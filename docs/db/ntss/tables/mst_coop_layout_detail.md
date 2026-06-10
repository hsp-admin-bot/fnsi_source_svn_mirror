# mst_coop_layout_detail

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_coop_layout_detail`
- Logical name: 連携電文設定マスタ詳細
- Physical name: `mst_coop_layout_detail`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 16
- NOT NULL columns: 6

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 電文種別 | coop_cd | character varying | 20 | 1 |  |  |
|  | 向き（送受信） | direction | character varying | 1 | 1 |  | S:送信　R:受信 |
|  | 電文種別詳細コード | coop_cd_detail | character varying |  | 1 |  |  |
|  | 電文種別詳細補足コード | coop_cd_detail_sub | character varying |  | 1 |  | pre:プレロジック<br>その他自由 |
|  | レイアウト名称 | coop_name | character varying |  |  |  |  |
|  | 説明 | description | character varying |  |  |  |  |
|  | 編集可否フラグ | is_editable | character varying | 1 |  |  | '0'：編集不可、'1'：編集可 |
|  | 連携設定 | coop_setting | XML |  |  |  |  |
|  | 拡張設定 | coop_ext_setting | jsonb |  |  |  | 機能拡張用の設定 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
