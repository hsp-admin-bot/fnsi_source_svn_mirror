# mst_kur

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_kur`
- Logical name: クールマスタ
- Physical name: `mst_kur`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `kur_cd`
- Column count: 12
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | クールコード | kur_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意なクールコード | fn_kur_cd | character varying | 3 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | クール名 | kur_name | character varying |  |  |  |  |
|  | クール開始時刻 | kur_start_time | character varying | 6 |  |  | HH24MISS形式 |
|  | クール終了時刻 | kur_end_time | character varying | 6 |  |  | HH24MISS形式 |
|  | クール内標準治療開始時刻 | kur_standard_start_time | character varying | 6 |  |  | HH24MISS形式 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 担当医情報 | mst_user_authentication | jsonb |  |  |  |  |
