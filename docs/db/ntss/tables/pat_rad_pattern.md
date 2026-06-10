# pat_rad_pattern

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_rad_pattern`
- Logical name: 患者放射線検査パターン
- Physical name: `pat_rad_pattern`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `rad_pattern_cd`
- Column count: 17
- NOT NULL columns: 5

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者放射線検査パターンコード | rad_pattern_cd | bigserial |  | 1 |  |  |
|  | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | FNW+で管理する施設内の一意な患者ID | fn_pat_id | character varying | 12 |  |  | FNW+フィードバック用 |
|  | 登録時放射線検査日時 | reg_rad_date | timestamp(3) |  | 1 |  |  |
|  | 登録時放射線検査区分 | reg_order_class | character varying | 1 | 1 |  | 1:透析前 2:透析後 0:その他 |
|  | 放射線検査依頼パターン | rad_pattern | smallint |  |  |  | 1:「指定日1回分」、2:「月１：第1週」、3:「月１：第2週」、4:「月１：第3週」、5:「月１：第4週」、6:「月２：第1週、第3週」、7:「月２：第2週、第4週」、8:「年間複数日指定」、9: 「隔週」 |
|  | 指定曜日 | rad_week | smallint |  |  |  | 1：月曜日 ～ 7：日曜日 |
|  | 指定期間開始日 | rad_from | timestamp(3) |  |  |  | この日から開始 |
|  | 指定期間終了日 | rad_to | timestamp(3) |  |  |  | この日まで継続（ずっとは2099/12/31） |
|  | 放射線検査依頼コード | order_rad_set_cd | bigint |  |  |  | mst_rad_set.rad_set_cd |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 登録スタッフ | reg_staff | bigint |  |  |  | 登録時スタッフID |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 最終更新スタッフ | up_staff | bigint |  |  |  | 最終更新スタッフID |
|  | 指示者 | ind_user_id | bigint |  |  |  | 指示スタッフID |
