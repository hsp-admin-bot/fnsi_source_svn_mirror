# mnt_if_edge_healthmon

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_if_edge_healthmon`
- Logical name: 連携エッジヘルスモニタ
- Physical name: `mnt_if_edge_healthmon`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 7
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | IFエッジ番号 | if_edge_no | numeric | 2 | 1 |  |  |
|  | エッジステータス | healthmon_facility_conn | jsonb |  |  |  | 外部との通信ができているかを見ることができるモニター<br>{<br>    "ini_dial": {<br>        "status": "xx",<br>        "type" : "send" / "receive" / "request"<br>        "moni_time": "2020-01-01 00:00:01"<br>    },<br>} |
|  | サーバステータス | healthmon_server_conn | jsonb |  |  |  | REST通信ができているかを見ることができるモニター（＝エッジの生存確認）<br><br>{<br>        "status": "xx",<br>        "moni_time": "2020-01-01 00:00:01"<br>} |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
