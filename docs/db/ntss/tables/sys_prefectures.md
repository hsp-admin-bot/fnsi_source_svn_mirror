# sys_prefectures

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_prefectures`
- Logical name: 都道府県マスタ
- Physical name: `sys_prefectures`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pref_cd`
- Column count: 4
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 都道府県コード | pref_cd | character varying | 2 | 1 |  |  |
|  | 都道府県名称 | pref_name | character varying | 8 | 1 |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
