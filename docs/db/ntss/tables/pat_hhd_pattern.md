# pat_hhd_pattern

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_hhd_pattern`
- Logical name: 在宅患者治療パターン
- Physical name: `pat_hhd_pattern`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_id,revision`
- Column count: 11
- NOT NULL columns: 2

## Related Config / Notes

- [../config/pat_hhd_pattern.md](../config/pat_hhd_pattern.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意<br>な患者ID | pat_id | bigint |  | 1 |  | 患者基本情報.システムで管理する一意な患者ID<br>■在宅透析開始時処理<br>ord_main.pat_idに展開する |
| 1 | 版番号 | revision | integer |  | 1 |  | 患者ごとに一意の番号 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード<br>■在宅透析開始時処理<br>ord_main.facility_cdに展開する |
|  | 適用開始日 | ind_treat_start_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | ベッドコード | bed_cd | bigint |  |  |  | ベッドマスタ.ベッドコード<br>装置番号を特定するために使用。ユーザが選択する |
|  | 装置番号 | machine_no | bigint |  |  |  | 装置マスタ.装置番号<br>ユーザが選択したベッドコードから紐づける。<br>ord_mainを作成する際に使用する |
|  | 指示：治療方法コード | ind_treatment_cd | integer |  |  |  | 治療方法マスタ.治療方法コード<br>■在宅透析開始時処理<br>ord_main.ind_treatment_cdに展開する |
|  | 指示：治療条件情報 | ind_cond_info | jsonb |  |  |  | ■Json構造 (※@pat_hhd_pattern参照)<br>■在宅透析開始時処理<br>　ord_main.ind_cond_infoに展開する |
|  | 指示：投与薬剤情報 | ind_medi_info | jsonb |  |  |  | ■Json構造 (※@pat_hhd_pattern参照)<br>■在宅透析開始時処理<br>　ord_main.ind_medi_infoに展開する |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
