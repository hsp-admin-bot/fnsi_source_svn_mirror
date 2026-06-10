# sys_master_define

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_master_define`
- Logical name: マスタ定義
- Physical name: `sys_master_define`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `master_physical_name`
- Column count: 23
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | マスタ物理名称 | master_physical_name | character varying | 40 | 1 |  |  |
|  | マスタ名 | master_name | character varying | 40 |  |  |  |
|  | 表示区分 | disp_class | character varying | 1 |  |  | 1:日機装社員のみ、2:制限なし |
|  | 表示管理レベル | edit_level | character varying | 1 |  |  | 1:全ユーザ、2:管理者のみ、<br>3:日機装社員のみ、4:日機装社員・管理者のみ<br>5:管理者または日機装社員のみ<br>1～5以外：非表示 |
|  | モード | mode | character varying | 1 |  |  | 1:共通マスタ画面を使用、2:個別マスタ画面を使用 |
|  | 並び替え可否 | allow_sort | character varying | 1 |  |  | 0：変更不可、1:変更可能 |
|  | 新規レコード追加可否 | allow_add_record | character varying | 1 |  |  | 0：変更不可、1:変更可能 |
|  | 表示順 | disp_order | numeric | 5 |  |  |  |
|  | カラム情報 | column_info | jsonb |  |  |  |  |
|  | コンボデータ | combo_data | jsonb |  |  |  |  |
|  | 参照型コンボの構造データ | reference_combo_def | jsonb |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | システム利用表示区分 | system_use_disp | character varying | 1 |  |  | 1：警報通知マスタ<br>3：施設マスタ、デバイスエッジマスタ、利用者マスタ、装置マスタ、ベッドマスタ、送信先グループマスタ<br>上記以外は2 |
|  | 【カラム情報の保有イメージ】 |  |  |  |  |  |  |
|  | 物理項目名 |  |  |  |  |  |  |
|  | 日本語項目名 |  |  |  |  |  |  |
|  | タイプ | string：文字列、number：数値、date：日付、Type4：コンボボックス(固定)、Type5：コンボボックス(テーブル) |  |  |  |  |  |
|  | サイズ | 許容できる桁数 |  |  |  |  |  |
|  | 有効範囲 | 最小値 : 最大値 |  |  |  |  |  |
|  | 必須 | 入力を必須とするか |  |  |  |  |  |
|  | コンボデータ | コード情報(コード・名称の配列) Or 対象テーブル情報(テーブル名、コードカラム、名称カラム) |  |  |  |  |  |
|  | 固定 | 固定列とするか(true:固定列対象, falseまたは未定義：可変列対象) |  |  |  |  |  |
