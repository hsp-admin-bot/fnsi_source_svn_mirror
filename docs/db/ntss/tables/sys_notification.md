# sys_notification

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_notification`
- Logical name: 通知状態管理
- Physical name: `sys_notification`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `notification_no`
- Column count: 12
- NOT NULL columns: 1

## Related Config / Notes

- [../config/sys_notification.md](../config/sys_notification.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 通知定義番号 | notification_no | bigint |  | 1 |  |  |
|  | 通知カテゴリ | notification_category | bigint |  |  |  | @sys_system_defineのctl_no：012を参照 |
|  | 通知設定名 | setting_name | character varying |  |  |  |  |
|  | メッセージ定義 | message | character varying |  |  |  | 通知メッセージの定義。<br>メッセージ中に置換箇所を表すキー情報を入れる。 |
|  | 付加情報定義 | additional_info | jsonb |  |  |  | 付加情報の定義。<br>JSONデータ中に置換箇所を表すキー情報を入れる。 |
|  | 表示順 | disp_order | numeric | 5 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 使用可能キー | available_keys | character varying |  |  |  | トリガー側から送られてくるキー情報を記載しておくカラム。 |
|  | 通知内容説明 | help | character varying |  |  |  |  |
