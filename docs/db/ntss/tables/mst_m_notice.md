# mst_m_notice

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_m_notice`
- Logical name: 緊急発報マスタ
- Physical name: `mst_m_notice`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,machine_record_cd`
- Column count: 7
- NOT NULL columns: 4

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
| 1 | 装置記録コード | machine_record_cd | character varying | 4 | 1 |  | 日機装装置：装置記録マスタ.装置記録コード<br>医器工V4等（新規登録時）：V０００～VZZZ<br>死活監視用：装置記録マスタ.装置記録コード |
|  | 装置記録メッセージ | machine_record_message | character varying | 256 |  |  | 日機装装置：装置記録マスタ.装置記録メッセージ<br>医器工V4等（新規登録時）：任意の文字列（50バイト上限）<br>死活監視用：装置記録マスタ.装置記録メッセージ |
|  | メールアドレス | email_address | character varying | 4000 | 1 |  | 区切り文字などで複数登録可 |
|  | 宛先名称 | email_name | character varying | 4000 | 1 |  | 区切り文字などで複数登録可 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
