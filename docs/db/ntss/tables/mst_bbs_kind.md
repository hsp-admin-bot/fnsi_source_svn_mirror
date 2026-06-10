# mst_bbs_kind

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_bbs_kind`
- Logical name: 掲示板種別マスタ
- Physical name: `mst_bbs_kind`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `kind_no`
- Column count: 10
- NOT NULL columns: 2

## Related Config / Notes

- [../config/sheet_3.md](../config/sheet_3.md)
- [../config/sheet_4.md](../config/sheet_4.md)
- [../config/sheet_5.md](../config/sheet_5.md)
- [../config/sheet_6.md](../config/sheet_6.md)
- [../config/sheet_7.md](../config/sheet_7.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | kind_no | bigserial |  | 1 |  | 施設イベント,<br>在庫,<br>スタッフ予定,<br>製品保守,<br>検査,<br>申し送り,<br>警告,<br>その他,<br>※上記の項目についてはデフォルトデータとして、施設追加時に登録 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 種別名 | kind_name | character varying |  |  |  | 施設イベント<br>在庫<br>スタッフ予定<br>製品保守<br>検査<br>申し送り<br>警告<br>その他<br>※上記のデフォルトデータの名称 |
|  | デフォルト内容 | default_contents | character varying |  |  |  |  |
|  | FNW+で管理する施設内の一意なカテゴリID | fn_category_id | character varying |  |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード<br>上記のデフォルトデータについては以下のID固定<br>'01':施設イベント,<br>'05':在庫,<br>'06':スタッフ予定,<br>'07':製品保守,<br>'08':検査,<br>'09':申し送り,<br>'10':警告,<br>'12':その他, |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | 0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | 0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | デフォルトタイトル | default_title | character varying |  |  |  |  |
