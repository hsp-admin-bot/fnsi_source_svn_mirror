# ord_schedule

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_schedule`
- Logical name: 治療スケジュール
- Physical name: `ord_schedule`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,treat_date,kur_cd,bed_cd`
- Column count: 10
- NOT NULL columns: 5

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 治療情報.施設コード |
| 1 | オーダ番号 | ord_no | bigint |  | 1 |  | 治療情報.システムで管理する一意なオーダ番号 |
| 1 | 治療日 | treat_date | character varying | 8 | 1 |  | 治療情報.治療日 |
| 1 | クールコード | kur_cd | bigint |  | 1 |  | 治療情報.指示：クールコード |
| 1 | ベッドコード | bed_cd | bigint |  | 1 |  | 治療情報.指示：ベッドコード |
|  | 患者ID | pat_id | bigint |  |  |  | 治療情報.システムで管理する一意な患者ID |
|  | ダミーフラグ | is_dummy | character varying | 1 |  |  | '0'：メイン、'1'：ダミー |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 治療曜日 | treat_week | smallint |  |  |  | 1：月曜日 ～ 7：日曜日<br>※検索用 |
