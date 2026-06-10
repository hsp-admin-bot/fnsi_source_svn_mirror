# mst_machine_type

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_machine_type`
- Logical name: 型式マスタ
- Physical name: `mst_machine_type`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `machine_type_cd`
- Column count: 9
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_machine_type.md](../config/mst_machine_type.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 型式コード | machine_type_cd | character varying | 3 | 1 |  |  |
|  | 型式 | machine_type | character varying | 20 | 1 |  |  |
|  | 機種 | model | character varying | 3 |  |  | 001：RO<br>002：供給装置<br>003：溶解装置<br>004：個人用透析装置<br>005：透析装置<br>006：溶解装置（A粉対応）<br>007：溶解装置（B粉対応） |
|  | メーカー | maker | character varying | 50 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 通信種別 | com_type | jsonb |  |  |  | 「@mst_machine_type」シート参照 |
|  | 装置モード | treat_mode | character varying | 11 |  |  | 「@mst_machine_type」シート参照 |
|  |  | over_nxseries | character varying | 1 |  |  | 1：100nxシリーズ以上の装置<br>0：未満の装置 |
