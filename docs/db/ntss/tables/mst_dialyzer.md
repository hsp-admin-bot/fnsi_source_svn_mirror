# mst_dialyzer

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_dialyzer`
- Logical name: ダイアライザマスタ
- Physical name: `mst_dialyzer`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `dialyzer_cd`
- Column count: 33
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | ダイアライザコード | dialyzer_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意なダイアライザコード | fn_dialyzer_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | メーカ名 | maker | character varying |  |  |  |  |
|  | 型番 | model_number | character varying |  |  |  |  |
|  | ダイアライザ種別 | dialyzer_type | character varying | 1 |  | '0' | '0':中空糸　'1':積層 |
|  | 機能分類 | function_class | character varying |  |  |  |  |
|  | 面積 | area | numeric | 2,1 |  | 0 |  |
|  | UFR | ufr | numeric | 8,2 |  | 0 |  |
|  | KoA | koa | numeric | 4 |  |  |  |
|  | 材質 | material | character varying |  |  |  |  |
|  | WET/DRY | wetdry | character varying | 1 |  | '0' | '1':ＷＥＴ、'2':ＤＲＹ、'0':不明 |
|  | 滅菌 | sterilization | character varying |  |  |  |  |
|  | UFR警告点上限 | ufr_warning_max | numeric | 5,2 |  | 1 |  |
|  | UFR警告点下限 | ufr_warning_min | numeric | 5,2 |  | 0 |  |
|  | UFR低下警報点 | ufr_warning_reduction | numeric | 2 |  | 0 |  |
|  | 血流量 | bloodamt | numeric | 3 |  | 200 | 以下の条件で値が設定される。<br>「尿素クリアランス」≦「血流量」 |
|  | 透析液流量 | alqd_flood_vol | numeric | 3 |  | 500 | 以下の条件で値が設定される。<br>「尿素クリアランス」≦「透析液流量」 |
|  | 尿素クリアランス | urea_clearance | numeric | 3 |  | 190 | 以下の条件で値が設定される。<br>「尿素クリアランス」≦「血流量」<br>「尿素クリアランス」≦「透析液流量」 |
|  | ガスパージ時間 | gas_purge_time | numeric | 2 |  | 5 |  |
|  | 置換洗浄量（透析液） | substituent_wash_amt | numeric | 4 |  | 1000 |  |
|  | 膜洗浄（中空糸） | membrane_wash | character varying | 1 |  | '0' | '0':使用しない、'1':使用する |
|  | 入り数 | in_number | numeric | 5 |  |  |  |
|  | 使用開始日 | use_start_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 使用終了日 | use_end_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd_3 | character varying | 20 |  |  |  |
|  | 院内コード4 | in_hospital_cd_4 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
