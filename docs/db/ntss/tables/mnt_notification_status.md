# mnt_notification_status

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_notification_status`
- Logical name: 通知状態管理
- Physical name: `mnt_notification_status`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `notification_message_no,user_id`
- Column count: 7
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 通知メッセージ番号 | notification_message_no | bigint |  | 1 |  | mnt_notification_message.notification_message_no |
| 1 | 利用者ID | user_id | bigint |  | 1 |  | mst_user,user_id |
|  | 通知済フラグ | is_notified | character varying | 1 |  | '0' | '0'：未通知、'1'：通知済 |
|  | 既読フラグ | is_read | character varying | 1 |  | '0' | '0':未読、'1'既読 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
