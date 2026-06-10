# pat_group

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_group`
- Logical name: 患者グループ
- Physical name: `pat_group`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_group_cd`
- Column count: 9
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 患者グループID（内部用ID） | pat_group_cd | bigserial |  | 1 |  |  |
|  | 患者グループ名 | pat_group_name | character varying |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意な薬剤グループコード | fn_pat_group_cd | character varying |  |  |  |  |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
