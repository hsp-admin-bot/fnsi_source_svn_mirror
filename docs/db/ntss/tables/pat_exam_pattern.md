# pat_exam_pattern

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_exam_pattern`
- Logical name: 患者検査パターン
- Physical name: `pat_exam_pattern`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `exam_pattern_cd`
- Column count: 19
- NOT NULL columns: 4

## Related Config / Notes

- [../config/pat_exam_pattern.md](../config/pat_exam_pattern.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者検査パターンコード | exam_pattern_cd | bigserial |  | 1 |  |  |
|  | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | FNW+で管理する施設内の一意な患者ID | fn_pat_id | character varying | 12 |  |  | FNW+フィードバック用 |
|  | 登録時検査日時 | reg_exam_date | timestamp(3) |  |  |  |  |
|  | 登録時検査区分 | reg_order_class | character varying | 1 | 1 |  | 1:透析前 2:透析後 0:その他 |
|  | 検査依頼パターン | exam_pattern | smallint |  |  |  | 1:「指定日1回分」、2:「月１：第1週」、3:「月１：第2週」、4:「月１：第3週」、5:「月１：第4週」、6:「月２：第1週、第3週」、7:「月２：第2週、第4週」、8:「年間複数日指定」、9: 「隔週」 |
|  | 指定曜日 | exam_week | smallint |  |  |  | 1：月曜日 ～ 7：日曜日 |
|  | 指定期間開始日 | exam_from | timestamp(3) |  |  |  | この日から開始 |
|  | 指定期間終了日 | exam_to | timestamp(3) |  |  |  | この日まで継続（ずっとは2099/12/31） |
|  | 検査依頼セットコード | order_exam_set_cd | bigint |  |  |  | "exam_set_cd":検査セットコード |
|  | 検査依頼情報 | exam_order_info | jsonb |  |  |  | ※@pat_exam_pattern参照 |
|  | ラベル情報 | order_label_info | jsonb |  |  |  | ※@pat_exam_pattern参照 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 登録スタッフ | reg_staff | bigint |  |  |  | 登録時スタッフID |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 最終更新スタッフ | up_staff | bigint |  |  |  | 最終更新スタッフID |
|  | 指示者 | ind_user_id | bigint |  |  |  | 指示スタッフID |
