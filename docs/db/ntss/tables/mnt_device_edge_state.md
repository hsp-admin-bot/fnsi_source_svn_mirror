# mnt_device_edge_state

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_device_edge_state`
- Logical name: デバイスエッジ状態管理
- Physical name: `mnt_device_edge_state`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,device_edge_no`
- Column count: 11
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
| 1 | デバイスエッジ番号 | device_edge_no | numeric | 2,0 | 1 |  |  |
|  | 死活監視ステータス | alive_moni_status | character varying | 2 |  |  | ステータス（00～FF）<br>　01：正常<br>　F0：手動停止<br>　F1：通信異常<br>　F2：デバイスエッジ異常<br>　※2桁目が「0」は正常系、「F」は異常系 |
|  | 死活監視メール送信状況 | send_mail_status | smallint |  |  |  | 通信異常メール送信状況<br>0:送信不要／送信済み<br>1:通信異常、メール未送信<br>2:通信復旧、メール未送信 |
|  | 死活監視ステータス変更日時 | alive_moni_status_change_date | timestamp(3) |  |  |  | alive_moni_statusの値が最後に変化した日時 |
|  | バージョン情報 | version_information | jsonb |  |  |  |  |
|  | 予約更新指示番号 | manage_no | bigint |  |  |  | mnt_device_edge_manage.manage_no |
|  | 予約更新日時 | manage_plan_date | timestamp(3) |  |  |  |  |
|  | 最終確認日時 | last_moni_time | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
