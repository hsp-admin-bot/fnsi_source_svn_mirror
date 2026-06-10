# sys_subscription_plan

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_subscription_plan`
- Logical name: プラン定義
- Physical name: `sys_subscription_plan`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `subscription_plan_no`
- Column count: 9
- NOT NULL columns: 5

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 申込プラン番号 | subscription_plan_no | bigserial |  | 1 |  | シーケンス |
|  | 申込プラン名 | subscription_plan_name | character varying |  |  |  |  |
|  | 申込プラン機能 | subscription_plan_fnc | jsonb |  |  |  | sys_function.function_cdのリスト<br>{    <br> item_cd: [ subscription_item_cd　（文字列型）,...<br> ]   <br>} |
|  | 申込プラン拡張機能 | subscription_plan_adv | jsonb |  |  |  | sys_function_advanced.function_adv_cdのリスト<br>{    <br> item_cd: [ subscription_item_cd　（文字列型）,...<br> ]   <br>} |
|  | 表示順 | disp_order | integer |  |  |  |  |
|  | 表示設定 | is_disp | character varying | 1 | 1 | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 | 1 | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  | 1 |  |  |
|  | 更新日時 | up_date | timestamp(3) |  | 1 |  |  |
