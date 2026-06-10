# mst_device_set_info_default

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_device_set_info_default`
- Logical name: 装置設定デフォルトマスタ
- Physical name: `mst_device_set_info_default`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd`
- Column count: 7
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_device_set_info_default.md](../config/mst_device_set_info_default.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 装置設定 | device_set_info | jsonb |  |  |  | ※「@mst_device_set_info_default」シート参照 |
|  | 風袋補正情報 | tare_info | jsonb |  |  |  | {<br>  "name_1": (String)項目1名称, "weight_1": (Number)項目1重さ,<br>  "name_2": (String)項目2名称, "weight_2": (Number)項目2重さ,<br>  "name_3": (String)項目3名称, "weight_3": (Number)項目3重さ,<br>  "name_4": (String)項目4名称, "weight_4": (Number)項目4重さ,<br>  "name_5": (String)項目5名称, "weight_5": (Number)項目5重さ<br>}<br>※重さは、g 換算で登録する(画面上で kg で表示していたとしても g に換算して登録する) |
|  | 除水補正情報 | off_water_info | jsonb |  |  |  | {<br>  "name_1": (String)項目1名称, "weight_1": (Number)項目1重さ,<br>  "name_2": (String)項目2名称, "weight_2": (Number)項目2重さ,<br>  "name_3": (String)項目3名称, "weight_3": (Number)項目3重さ,<br>  "name_4": (String)項目4名称, "weight_4": (Number)項目4重さ,<br>  "name_5": (String)項目5名称, "weight_5": (Number)項目5重さ<br>}<br>※重さは、g 換算で登録する(画面上で kg で表示していたとしても g に換算して登録する) |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | ホスト報知情報 | host_notification_info | jsonb |  |  |  | ※「@mst_device_set_info_default」シート参照 |
