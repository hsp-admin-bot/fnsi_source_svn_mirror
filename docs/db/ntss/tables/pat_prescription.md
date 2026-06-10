# pat_prescription

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_prescription`
- Logical name: 患者処方情報
- Physical name: `pat_prescription`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_id,prescript_no`
- Column count: 10
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_personal.pat_id |
| 1 | 処方番号 | prescript_no | integer |  | 1 |  |  |
|  | 登録施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 交付日 | execute_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 使用期限 | end_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 指示スタッフ情報 | ind_staff_info | jsonb |  |  | E'{"prescripter_cd":null,"prescripter_update":null,"prescripter_name":null,"updater_cd":null}' | 指示スタッフ情報<br>{<br>  "prescripter_cd":スタッフマスタ.スタッフコード　※処方者コード<br>  "prescripter_update":スタッフマスタ.更新日時　※処方者コード更新日時<br>  "prescripter_name":スタッフマスタ.スタッフ名　※処方者名<br>  "updater_cd":スタッフマスタ.スタッフコード　※更新者コード<br>} |
|  | 指示情報 | ind_info | jsonb |  |  | E'{"cop_order_no":null,"is_editable":"1"}' | 指示情報<br>{<br>  "cop_order_no":連携オーダ番号　※電子カルテからの予約オーダを登録する際に使用<br>  "is_editable":編集可能フラグ　※'0':編集不可、'1':編集可能<br>} |
|  | 備考 | note | character varying | 1024 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
