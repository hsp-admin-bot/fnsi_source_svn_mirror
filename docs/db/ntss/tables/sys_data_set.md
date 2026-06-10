# sys_data_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_data_set`
- Logical name: データセット
- Physical name: `sys_data_set`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `sql_cd`
- Column count: 11
- NOT NULL columns: 4

## Related Config / Notes

- [../config/sys_data_set.md](../config/sys_data_set.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | SQLCD | sql_cd | bigserial |  | 1 |  | シーケンス使用 |
|  | SQL | sql | character varying |  | 1 |  | SQL本文 |
|  | DB種別 | db_class | integer |  | 1 |  | 接続先DBを判断する<br>1 : db4<br>2 : db5<br>3 : db6<br>4 : MongoDB<br><br>■MongoDB関連<br>@sys_data_set MongoDB関連 |
|  | 詳細 | detail | jsonb |  | 1 |  | ■Json構造<br>@sys_data_set 詳細 |
|  | 事前取得データ情報 | pre_sql_info | jsonb |  |  |  | SQL構築に必要なパラメータを取得するために実行する他SQLの情報<br><br>■Json構造<br>@sys_data_set 事前取得データ情報 |
|  | 繰返し可否フラグ | can_repeat | character varying | 1 |  |  | 複数件のレコードの戻りがあるかどうか<br>0 : 戻りが1件<br>1 : 複数件のレコードの戻りがある |
|  | 使用用途 | use_application | jsonb |  |  |  | 帳票、連携、コンバートなどの利用判断用<br><br>■Json構造<br>@sys_data_set 使用用途 |
|  | 帳票種別 | report_class | jsonb |  |  |  | 単患者帳票、透析レポートなどのレポート種類<br><br>■Json構造<br>@sys_data_set 帳票種別 |
|  | 備考 | memo | character varying | 256 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
