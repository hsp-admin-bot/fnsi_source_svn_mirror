# mnt_device_edge_manage

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_device_edge_manage`
- Logical name: デバイスエッジ制御指示管理
- Physical name: `mnt_device_edge_manage`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `manage_no`
- Column count: 10
- NOT NULL columns: 7

## Related Config / Notes

- [../config/mnt_device_edge_manage.md](../config/mnt_device_edge_manage.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | DE管理番号 | manage_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_faciliyu.facility_cd |
|  | デバイスエッジ番号 | device_edge_no | numeric | 2,0 | 1 |  | mst_device_edge.device_edge_no |
|  | 指示者 | user_id | bigint |  | 1 |  | mst_user.user_id |
|  | 指示種別 | order_class | smallint |  | 1 |  | 0: アプリ更新<br>1: アプリレストア<br>2: ログ収集<br>3: アプリ再起動<br>4: アプリ停止<br>5: アプリ開始<br>6: OS再起動<br>7: 設定ファイル収集<br>8: 設定ファイル更新<br>9: 予約キャンセル |
|  | 指示対象 | order_target_class | smallint |  | 1 |  | 指示対象識別子<br>　0：メインアプリ<br>　1：アップデータアプリ |
|  | 応答ステータス | response_status | smallint |  | 1 |  | ステータス<br>　-2：異常<br>　-1：拒否<br>　0：依頼中（応答なし含む）<br>　1：処理中<br>　2：完了<br>　3：予約 |
|  | 情報 | manage_info | jsonb |  |  |  | @mnt_device_edge_manage |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
