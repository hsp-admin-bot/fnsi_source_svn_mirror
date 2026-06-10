# mst_disease

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_disease`
- Logical name: 病名マスタ
- Physical name: `mst_disease`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `disease_cd`
- Column count: 16
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 病名コード | disease_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な病名コード | fn_disease_cd | character varying | 20 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 病名 | disease_name | character varying |  |  |  |  |
|  | 省略病名 | disease_short_name | character varying |  |  |  |  |
|  | 標準病名コード | standard_disease_cd | integer    character varying |  |  |  | 標準病名マスタ.標準病名コード |
|  | 原疾患生検なしコード | p_disease_biopsy_none_cd | character varying |  |  |  | 画面上で手入力 |
|  | 原疾患生検ありコード | p_disease_biopsy_exist_cd | character varying |  |  |  | 画面上で手入力 |
|  | 死因確診なしコード | die_confirmed_diagnosis_none_cd | character varying |  |  |  | 画面上で手入力 |
|  | 死因確診ありコード | die_confirmed_diagnosis_exist_cd | character varying |  |  |  | 画面上で手入力 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 死因フラグ | is_die | character varying | 1 |  | '0' | 0'：死因以外、'1'：死因<br>※現状データコンバートのみ使用 |
