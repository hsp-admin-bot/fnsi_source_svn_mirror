# sys_facility

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_facility`
- Logical name: 全施設マスタ
- Physical name: `sys_facility`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medical_institution_cd`
- Column count: 19
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 医療機関コード | medical_institution_cd | character varying | 10 | 1 |  |  |
|  | 都道府県コード | prefectures_cd | character varying | 2 |  |  | 都道府県マスタ.都道府県コード |
|  | 施設名 | facility_name | character varying |  |  |  |  |
|  | 短縮施設名 | facility_short_name | character varying |  |  |  |  |
|  | JSDT施設コード | jsdt_facility_cd | character varying | 6 |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 日機装管理のコード(セールスフォース) |
|  | 郵便番号 | zipcd | character varying |  |  |  |  |
|  | 住所 | address | character varying |  |  |  |  |
|  | 住所カナ | address_kana | character varying |  |  |  |  |
|  | 電話番号1 | phone_no_1 | character varying |  |  |  |  |
|  | 電話番号2 | phone_no_2 | character varying |  |  |  |  |
|  | FAX1 | fax_no_1 | character varying |  |  |  |  |
|  | FAX2 | fax_no_2 | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  |  | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 電話番号1 | phone_no1 | character varying |  |  |  |  |
|  | 電話番号2 | phone_no2 | character varying |  |  |  |  |
