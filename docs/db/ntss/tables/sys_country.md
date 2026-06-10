# sys_country

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_country`
- Logical name: 国名マスタ
- Physical name: `sys_country`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `country_cd_alpha3`
- Column count: 6
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 国名コード(alpha-3) | country_cd_alpha3 | character varying | 3 | 1 |  |  |
|  | 国名コード(alpha-2) | country_cd_alpha2 | character varying | 2 |  |  |  |
|  | 国名コード(Numeric) | country_cd_numeric | character varying | 3 |  |  |  |
|  | 国名 | country_name | character varying |  |  |  |  |
|  | 国名(英語) | country_name_alpha | character varying |  |  |  |  |
|  | 地域 | region | character varying |  |  |  |  |
