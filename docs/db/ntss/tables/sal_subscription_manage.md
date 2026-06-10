# sal_subscription_manage

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sal_subscription_manage`
- Logical name: オプション申込
- Physical name: `sal_subscription_manage`
- Prefix group: `sales`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `subscription_no`
- Column count: 18
- NOT NULL columns: 4

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 申込管理番号 | subscription_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 初回申込フラグ | is_first | character varying | 1 |  |  | 0：2回目以降、1：初回申込 |
|  | 初回申込プラン名 | subscription_plan_name | character varying |  |  |  | sys_subscription_plan.subscription_plan_nameを転記。<br>初回以外はNULL |
|  | 申込機能 | subscription_fnc | jsonb |  |  |  | sys_function.function_cdのリスト<br>{    <br> item_cd: [ subscription_item_cd　（文字列型）,...<br> ]   <br>} |
|  | 申込拡張機能 | subscription_adv | jsonb |  |  |  | sys_function_advanced.function_adv_cdのリスト<br>{    <br> item_cd: [ subscription_item_cd　（文字列型）,...<br> ]   <br>} |
|  | 申込ステータス | subscription_status | character varying | 1 |  |  | 0:未受付、1:受付済み、2:完了、9:キャンセル |
|  | 申込者 | applicant | integer |  |  |  | 利用者マスタ.利用者ID |
|  | 受付担当者 | receptionist | integer |  |  |  | 利用者マスタ.利用者ID |
|  | 受付日時 | reception_date | timestamp(3) |  |  |  | 受付済に変更した日時 |
|  | 完了担当者 | completer | integer |  |  |  | 利用者マスタ.利用者ID |
|  | 完了日時 | complete_date | timestamp(3) |  |  |  | 完了済みに変更した日時 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 | 1 |  | 0:非表示、1:表示 |
|  | 削除フラグ | is_del | character varying | 1 | 1 |  | 0:通常、1:削除 |
|  | キャンセル日時 | cancel_date | bigint |  |  |  |  |
|  | キャンセラー | canceller | timestamp(3) |  |  |  |  |
