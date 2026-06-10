# pat_exam_main

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_exam_main`
- Logical name: 患者検査結果
- Physical name: `pat_exam_main`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `exam_main_cd`
- Column count: 30
- NOT NULL columns: 5

## Related Config / Notes

- [../config/pat_exam_main.md](../config/pat_exam_main.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な検査結果コード | exam_main_cd | bigserial |  | 1 |  |  |
|  | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | オーダ番号 | ord_no | bigint |  |  |  | ord_main.ord_no |
|  | FNW+で管理する施設内の一意な患者ID | fn_pat_id | character varying | 12 |  |  | FNW+フィードバック用 |
|  | 登録時検査日時 | reg_exam_date | timestamp(3) |  | 1 |  | 時刻はゼロ |
|  | 登録時検査区分 | reg_order_class | character varying | 1 | 1 |  | 1:透析前 2:透析後 0:その他 |
|  | 状況区分 | exam_status | character varying | 1 |  |  | ’0'：依頼、'1'：結果あり |
|  | 依頼時コメント | order_comment | character varying | 50 |  |  |  |
|  | 検査依頼セット情報 | order_exam_set_info | jsonb |  |  |  | ※@pat_exam_main参照 |
|  | 検査依頼情報 | exam_order_info | jsonb |  |  |  | ※@pat_exam_main参照 |
|  | ラベル情報 | order_label_info | jsonb |  |  |  | ※@pat_exam_main参照 |
|  | データ登録区分 | data_gen_class | character varying | 1 |  |  | '0'：クライアント、'1'：外部取り込み　'2'：連携 |
|  | 結果時検査日時 | result_exam_date | timestamp(3) |  |  |  | 結果受信時の検査日時：依頼連携しない場合（結果だけもらう場合）もここに格納 |
|  | 結果時コメント | result_comment | character varying | 50 |  |  |  |
|  | 検査結果情報 | exam_result_info | jsonb |  |  |  | ※@pat_exam_main参照 |
|  | 連携オーダ番号１ | cop_order_no1 | bigint |  |  |  | 電子カルテとの連携用に付番 |
|  | 連携オーダ番号２ | cop_order_no2 | bigint |  |  |  | 電子カルテとの連携用に付番 |
|  | 依頼変更可否フラグ | is_lock | character varying | 1 |  |  | '0'：変更可(依頼締切前)、'1'：変更不可（依頼締切後） |
|  | 指示者 | ind_user_id | bigint |  |  |  | 指示スタッフID |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 登録スタッフ | reg_staff | bigint |  |  |  | 登録時スタッフID |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 最終更新スタッフ | up_staff | bigint |  |  |  | 最終更新スタッフID |
|  | 検査依頼登録フラグ | is_order | character varying | 1 |  |  | '0'：検査結果画面で登録したレコード、'1'：検査依頼画面で登録したレコード |
|  | 指定期間開始日 | exam_from | timestamp(3) |  |  |  |  |
|  | 検査依頼パターン | exam_pattern | bigint |  |  |  |  |
|  | 指定期間終了日 | exam_to | timestamp(3) |  |  |  |  |
|  | 指定曜日 | exam_week | bigint |  |  |  |  |
