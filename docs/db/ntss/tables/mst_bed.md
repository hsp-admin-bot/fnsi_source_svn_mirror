# mst_bed

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_bed`
- Logical name: ベッドマスタ
- Physical name: `mst_bed`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `bed_cd`
- Column count: 20
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | ベッドコード | bed_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | ベッド番号 | bed_no | integer |  |  |  | 手入力(新規登録時はMAX+1が自動で設定されている状態とする)<br>他ベッドと重複可 |
|  | ベッド名 | bed_name | character varying |  |  |  |  |
|  | シャント位置 | shunt_position | smallint | 1,0 |  |  | 0：両方、1：左、2：右、3：なし<br>※FN2に「なし」「両方」が存在するのか？「なし」が必要なのか？<br>→FN2に存在する |
|  | 感染症フラグ | is_infection | character varying | 1 |  |  | '0':感染症なし、'1':感染症あり |
|  | 緊急区分 | emergency_class | numeric | 1,0 |  |  | 0:通常ベッド、1:緊急用ベッド |
|  | 装置番号 | machine_no | bigint |  |  |  | 装置マスタ.装置番号<br>※上記を追加するか検討が必要<br>※装置マスタ側をシーケンス(※非主キー)とする<br>※この項目を編集した場合、mnt_machine_stateのベッドコード、ベッド名の更新が必要となる<br>※この項目の編集可否については、表示フラグと同条件とする |
|  | 出力先プリンタ名 | output_printer | character varying |  |  |  | ※自動印刷で使用するベッドごとのプリンタ<br>※自動印刷時は必ずこのプリンタを使用する(他のプリンタ設定は無視する) |
|  | 前体重測定時の自動印刷有無 | is_autoprint_before | character varying | 1 |  |  | '0'：印刷しない、'1'：印刷する |
|  | 後体重測定時の自動印刷有無 | is_autoprint_after | character varying | 1 |  |  | '0'：印刷しない、'1'：印刷する<br>※FNW+では、後体重測定時ではなく、実績確定時に行っている<br>→コンバート時に注意すること<br>　(FNW+のこの項目は「実績確定時の自動印刷有無」に登録し、この項目は「0」とする) |
|  | 実績確定時の自動印刷有無 | is_autoprint_commit | character varying | 1 |  |  | 0'：印刷しない、'1'：印刷する |
|  | FNW+で管理する施設内の一意なベッド番号 | fn_bed_no | numeric | 4,0 |  |  | FNW+フィードバック用 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | 0'：非表示、'1'：表示<br>画面上で削除とした場合、このベッドに紐付く治療予定の更新が必要<br>・編集対象となる治療予定<br>　本日以降で治療未実施の治療予定<br>　(条件送信前)<br>※過去日の未実施治療予定は編集対象としない<br>・治療状況リストに該当ベッドのエントリがある場合、削除不可(表示フラグをOFFにできないように制御) |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 在宅フラグ | is_home_dialysis | character varying | 1 |  | '0' | 0':施設内ベッド、'1':在宅患者用ベッド |
