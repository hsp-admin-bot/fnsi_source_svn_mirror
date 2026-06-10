# mst_medicine_support

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_medicine_support`
- Logical name: 投薬支援マスタ
- Physical name: `mst_medicine_support`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medicine_support_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 投薬支援コード | medicine_support_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 投薬支援パターン名 | medicine_support_name | character varying |  |  |  |  |
|  | 目標検査値 | target_inspection | numeric | 8,2 |  |  |  |
|  | 詳細 | detail_info | jsonb |  |  |  | {<br> "examItemCycling": [],       --検査項目(cycling・予測値)<br> "examItemAverage": [],     --検査項目(検査平均値)<br> "examItemRegression": [], --検査項目(回帰直線)<br> "medicineAverage": [],     --薬剤（薬剤平均値）<br> "medicineESA": [],            --薬剤（ESA投与支援）<br> "initialRangeExam": 1,      --初期レンジ（検査平均値）<br> "initialRangeMedicine": 4 --初期レンジ（薬剤平均投与量）<br>}<br>*検査項目のJSONの項目<br> {<br>   "text": "HBs抗体価(半定量)[PA]",      --検査項目名<br>   "value": 20                                        --検査項目コード<br>  }<br>*薬剤のJSONの項目<br>{<br>   "text": "(薬剤)抗凝固剤",                   --薬剤名<br>   "type": 1,             --1:通常薬剤;2:調製薬剤;3:薬効換算;<br>   "value": 119                                      --薬剤コード<br>  }<br>*初期レンジの項目<br>0:’‘<br>1:３か月<br>2:６か月<br>3:１年<br>4:２年 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | 0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 検査値単位 | target_unit | character varying | 20 |  |  |  |
|  | FNW+で管理する施設内の一意な職種コード | fn_medicine_support_cd | character varying | 5 |  |  |  |
