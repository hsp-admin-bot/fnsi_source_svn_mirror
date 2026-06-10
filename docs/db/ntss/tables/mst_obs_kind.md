# mst_obs_kind

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_obs_kind`
- Logical name: 観察記録種別情報
- Physical name: `mst_obs_kind`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `kind_no`
- Column count: 13
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | kind_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 種別名 | kind_name | character varying | 40 |  |  |  |
|  | 種別区分 | kind_class | integer |  | 1 |  | 0：その他<br>1：SOAP<br>2：FDAR |
|  | 掲示板への掲載有無 | is_post_bbs | character varying | 1 |  | '0' | '0':なし、'1':あり<br>※観察記録詳細画面でのカテゴリ選択時の初期値 |
|  | 期間 | post_period | integer |  |  | 0 | ※観察記録詳細画面でのカテゴリ選択時の初期値 |
|  | 周知先 | post_address_class | integer |  |  | 0 | 0:全員<br>1:個人<br>※観察記録詳細画面でのカテゴリ選択時の初期値 |
|  | 治療実績とリンク有無 | is_link_ord_no | character varying | 1 |  | '0' | '0':なし、'1':あり<br>※観察記録詳細画面でのカテゴリ選択時の初期値 |
|  | FNW+で管理する施設内の一意な種別ID | fn_kind_id | integer |  |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0':非表示、'1':表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
