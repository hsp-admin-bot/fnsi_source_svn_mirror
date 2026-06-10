# mst_alarm_notification

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_alarm_notification`
- Logical name: 警報通知マスタ
- Physical name: `mst_alarm_notification`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `alarm_notification_cd`
- Column count: 39
- NOT NULL columns: 16

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 警報通知コード | alarm_notification_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 警報通知名 | alarm_notification_name | character varying |  |  |  |  |
|  | 送信先施設コード | destination_facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 送信先グループコード | destination_group_cd | bigint |  |  |  | 送信先グループマスタ.送信先グループコード |
|  | 対象装置記録 | target_machine_record | jsonb |  | 1 | {"cds": []} | ■Json構造<br>{ "cds":<br> [<br>  {<br>  "machine_record_cd": 装置記録マスタ.装置記録コード (bigserial)<br>  }<br> ]<br>}<br>■概要<br>送信対象となる装置記録を保有する |
|  | 通知フラグ(月) | is_notice_mon | character varying | 1 | 1 | '1' | '0'：通知しない、'1'：通知する |
|  | 開始時間(月) | start_time_mon | character varying | 5 |  |  | "hh:mm" |
|  | 終了時間(月) | end_time_mon | character varying | 5 |  |  | "hh:mm" |
|  | 翌日フラグ(月) | is_next_day_mon | character varying | 1 | 1 | '0' | '0':当日、'1':翌日 |
|  | 通知フラグ(火) | is_notice_tue | character varying | 1 | 1 | '1' | '0'：通知しない、'1'：通知する |
|  | 開始時間(火) | start_time_tue | character varying | 5 |  |  | "hh:mm" |
|  | 終了時間(火) | end_time_tue | character varying | 5 |  |  | "hh:mm" |
|  | 翌日フラグ(火) | is_next_day_tue | character varying | 1 | 1 | '0' | '0':当日、'1':翌日 |
|  | 通知フラグ(水) | is_notice_wed | character varying | 1 | 1 | '1' | '0'：通知しない、'1'：通知する |
|  | 開始時間(水) | start_time_wed | character varying | 5 |  |  | "hh:mm" |
|  | 終了時間(水) | end_time_wed | character varying | 5 |  |  | "hh:mm" |
|  | 翌日フラグ(水) | is_next_day_wed | character varying | 1 | 1 | '0' | '0':当日、'1':翌日 |
|  | 通知フラグ(木) | is_notice_thu | character varying | 1 | 1 | '1' | '0'：通知しない、'1'：通知する |
|  | 開始時間(木) | start_time_thu | character varying | 5 |  |  | "hh:mm" |
|  | 終了時間(木) | end_time_thu | character varying | 5 |  |  | "hh:mm" |
|  | 翌日フラグ(木) | is_next_day_thu | character varying | 1 | 1 | '0' | '0':当日、'1':翌日 |
|  | 通知フラグ(金) | is_notice_fri | character varying | 1 | 1 | '1' | '0'：通知しない、'1'：通知する |
|  | 開始時間(金) | start_time_fri | character varying | 5 |  |  | "hh:mm" |
|  | 終了時間(金) | end_time_fri | character varying | 5 |  |  | "hh:mm" |
|  | 翌日フラグ(金) | is_next_day_fri | character varying | 1 | 1 | '0' | '0':当日、'1':翌日 |
|  | 通知フラグ(土) | is_notice_sat | character varying | 1 | 1 | '1' | '0'：通知しない、'1'：通知する |
|  | 開始時間(土) | start_time_sat | character varying | 5 |  |  | "hh:mm" |
|  | 終了時間(土) | end_time_sat | character varying | 5 |  |  | "hh:mm" |
|  | 翌日フラグ(土) | is_next_day_sat | character varying | 1 | 1 | '0' | '0':当日、'1':翌日 |
|  | 通知フラグ(日) | is_notice_sun | character varying | 1 | 1 | '1' | '0'：通知しない、'1'：通知する |
|  | 開始時間(日) | start_time_sun | character varying | 5 |  |  | "hh:mm" |
|  | 終了時間(日) | end_time_sun | character varying | 5 |  |  | "hh:mm" |
|  | 翌日フラグ(日) | is_next_day_sun | character varying | 1 | 1 | '0' | '0':当日、'1':翌日 |
|  | SMS通知先電話番号 | sms_tel | character varying | 30 |  |  | 暗号化対象 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
