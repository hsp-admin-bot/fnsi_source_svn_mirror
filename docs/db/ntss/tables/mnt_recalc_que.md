# mnt_recalc_que

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_recalc_que`
- Logical name: 検査再計算依頼キューテーブル
- Physical name: `mnt_recalc_que`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `recalc_que_cd`
- Column count: 14
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 処理順(登録順） | recalc_que_cd | bigserial | 19 | 1 |  |  |
|  | ステータス | status | character varying | 6 |  |  | ステータス (2:処理完了、1:処理中、0:未処理、3:スキップ、４:処理中断、8:エラー（スキップ）、9:中止) |
|  | 施設コード | facility_cd | character varying |  |  |  |  |
|  | 依頼日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 完了日時 | end_date | timestamp(3) |  |  |  |  |
|  | 内容 | content | jsonb |  |  |  | {<br>    "item": [<br>        {<br>            "exam_item_cd": 検査項目コード,<br>            "compute_cover":再計算して上書きする　<br>        },     ..........                                                                                                    <br>    ],<br>    "pat_id": [患者ID],<br>    "to_date": 対象期間,<br>    "from_date": 対象期間<br>} |
|  | 進捗 | detail | jsonb |  |  |  | {<br>    "done_cnt": 処理済件数,<br>    "total_cnt": 検査件数,<br>    "exam_main_cd": オーダ番号順<br>} |
|  | 依頼者id | reg_id | numeric |  |  |  |  |
|  | 更新者ID | up_id | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying |  |  | '1' | 0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying |  |  | '0' | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | ログ | journal | character |  |  |  |  |
|  | 再計算済患者ID | calc_pat_id | jsonb |  |  |  | {<br>    "pat_id": [患者ID]<br>} |
