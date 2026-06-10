# mnt_mainte_main

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_mainte_main`
- Logical name: 点検結果
- Physical name: `mnt_mainte_main`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `mainte_no`
- Column count: 22
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mnt_mainte_main.md](../config/mnt_mainte_main.md)
- [../config/mnt_mainte_main_2.md](../config/mnt_mainte_main_2.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 点検結果コード | mainte_no | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 検査型式 | mainte_class | character varying | 1 |  |  | '1'：日常点検用、'2'：定期点検用 |
|  | 装置番号 | machine_no | bigint |  |  |  |  |
|  | 記録番号 | rec_no | integer |  |  |  | 定期点検時：記録番号 |
|  | 点検日 | mainte_date | timestamp(3) |  |  |  | 点検実施日 |
|  | 点検レイアウトグループコード | mainte_layout_group_cd | bigint |  |  |  |  |
|  | 点検レイアウトコード | mainte_layout_cd | bigint |  |  |  |  |
|  | 点検実施者 | checker_id_1 | character varying |  |  |  | 点検実施者ID |
|  | 確認者 | checker_id_2 | character varying |  |  |  | 確認者ID |
|  | 結果入力パターン1 | mainte_ans_1 | character varying | 1 |  |  | mainte_classが1,2の場合、利用する。<br>日常点検の場合<br>''：''、'1'：合格、'2'：点検途中、'3'：不合格<br>定期点検の場合<br>null：''、'1'：合格、'2'：作業中、'3'：不合格 |
|  | 結果入力パターン2 | mainte_ans_2 | character varying | 1 |  |  | mainte_classが2の場合、利用する。 |
|  | 定期点検者コメント | mainte_comment_1 | character varying |  |  |  |  |
|  | 定期交換部品記録コメント | mainte_comment_2 | character varying |  |  |  |  |
|  | 内容 | detail | jsonb |  |  |  | @mnt_mainte_mainで参考 |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 点検レイアウトグループコード版数 | mainte_layout_group_edition | integer |  |  |  |  |
|  | 点検カテゴリコード版数 | mainte_category_cd | jsonb |  |  |  | [<br>{<br>  mst_mainte_category.category_cd(Number),<br>  mst_mainte_category.edition_no (Number)<br>}…{}<br>] |
|  | 点検レイアウトコード版数 | mainte_layout_edition | integer |  |  |  |  |
