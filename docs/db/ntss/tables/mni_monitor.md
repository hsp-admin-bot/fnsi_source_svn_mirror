# mni_monitor

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mni_monitor`
- Logical name: 装置モニタデータ
- Physical name: `mni_monitor`
- Prefix group: `monitoring`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `bio_moni_ctl_no`
- Column count: 13
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mni_monitor.md](../config/mni_monitor.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 生体モニタリング管理番号 | bio_moni_ctl_no | bigserial |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 型式コード | machine_type_cd | character varying | 3 |  |  | 型式マスタ.型式コード |
|  | 製造番号 | machine_serial | character varying | 8 |  |  | 装置マスタ.製造番号<br>★比較時はTrim後に比較すること |
|  | システムで管理する一意なオーダ番号 | ord_no | bigint |  |  |  | ord_main.ord_no |
|  | システムで管理する一意な患者ID | pat_id | bigint |  |  |  | pat_main.pat_id |
|  | データ種別 | data_type | smallint |  |  |  | 0：不明、1：モニタ、2：透析中血圧、<br>3:再循環率、4：体温測定、<br>5：透析前血圧、6：透析後血圧 |
|  | モニタデータ | monitor_data | jsonb |  |  |  | 「@mni_monitor」シート参照 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 発生日時 | occur_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 更新者ID | upd_staff_id | bigint |  |  |  | 利用者マスタ.利用者ID（内部用ID）<br><br>装置から受信したデータの場合 : null<br><br>治療記録のバイタル／モニタで新規追加したデータもしくは、修正した場合、サインイン者の内部利用者IDを格納 |
