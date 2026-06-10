# mst_weight_scale

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_weight_scale`
- Logical name: 体重測定設定マスタ
- Physical name: `mst_weight_scale`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `weight_scale_cd`
- Column count: 15
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 体重測定設定管理コード | weight_scale_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | ICカード種別 | ic_card | numeric | 1,0 |  |  | 0:カード無し, 1:Felica |
|  | 患者バーコード有効桁 | pat_id_digit | smallint |  |  |  |  |
|  | 測定初期画面 | default_screen_class | numeric | 1,0 |  |  | 0:簡易画面, 1:詳細画面 |
|  | 検査結果有効期間 | exam_period | smallint |  |  |  | 0:未設定 それ以外:設定値 |
|  | 車いす校正有効日数 | wheel_chair_period | smallint |  |  |  | 0:未設定 それ以外:設定値 |
|  | 風袋初期単位 | tare_unit_class | numeric | 1,0 |  |  | 0:g, 1:kg |
|  | 除水初期単位 | water_unit_class | numeric | 1,0 |  |  | 0:g, 1:kg |
|  | ２回測定チェック | is_double_check | character varying | 1 |  |  | 0':無効、'1':有効 |
|  | ２回測定チェック許容値 | double_check_tolerance | numeric | 6,3 |  |  | kg単位 |
|  | 透析中条件送信画面表示 | is_during_dialysis_view | character varying | 1 |  |  | 0':無効、'1':有効 |
|  | 前回後体重取得元 | previous_weight_source_class | numeric | 1,0 |  |  | 0：治療分類毎（透析・特殊浄化を区別）、１：近日値 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
