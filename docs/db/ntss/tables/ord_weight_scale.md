# ord_weight_scale

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_weight_scale`
- Logical name: 体重計測定記録
- Physical name: `ord_weight_scale`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `weight_scale_no`
- Column count: 35
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 測定管理番号 | weight_scale_no | bigserial |  | 1 |  |  |
|  | オーダー番号 | ord_no | bigint |  |  |  | 治療情報.オーダー番号 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 体重計管理コード | weight_cd | bigint |  |  |  | 体重計マスタ.体重計管理コード |
|  | 体重計名称 | weight_name | character varying |  |  |  | 体重計マスタ.体重計名称 |
|  | 装置番号 | machine_no | bigint |  |  |  | 装置マスタ.装置番号 |
|  | 装置名称 | machine_name | character varying | 40 |  |  | 装置マスタ.装置名称 |
|  | 体重測定状況 | weight_scale_status | smallint |  |  |  | 0:測定済み<br>1:条件送信指示中<br>2:待機<br>3:条件送信成功<br>4:条件送信失敗 |
|  | メッセージ | message | character varying | 256 |  |  |  |
|  | 測定日時 | measure_date | timestamp(3) |  |  |  |  |
|  | クール | kur_cd | bigint |  |  |  | クールマスタ.クールコード |
|  | クール名 | kur_name | character varying |  |  |  | クールマスタ.クール名 |
|  | ベッドコード | bed_cd | bigint |  |  |  | ベッドマスタ.ベッドコード |
|  | ベッド名 | bed_name | character varying |  |  |  | ベッドマスタ.ベッド名 |
|  | 患者ID | pat_id | bigint |  |  |  | 患者マスタ.患者ＩＤ |
|  | 治療方法コード | treatment_cd | integer |  |  |  | 治療方法マスタ.治療方法コード |
|  | 治療方法名 | treatment_name | character varying |  |  |  | 治療方法マスタ.治療方法名 |
|  | 装置モード | device_mode | numeric | 2,0 |  |  | 治療方法マスタ.装置モード |
|  | 測定区分 | scale_class | smallint |  |  |  | 0:前体重（装置モード特殊浄化のときは「入室」）<br>1:後体重（装置モード特殊浄化のときは「退室」）<br>2:重量測定 |
|  | 測定モード | scale_mode | smallint |  |  |  | 0:体重<br>1:体重＋車いす<br>2:車いす |
|  | 測定値 | scale_value | numeric | 5,2 |  |  | 単位（kg） |
|  | 風袋 | rst_tare_info | jsonb |  |  |  | ord_main 指示：風袋補正と同じ構成 |
|  | 除水補正値 | rst_off_water_info | jsonb |  |  |  | ord_main 指示：除水補正と同じ構成 |
|  | 体重値 | weight_value | numeric | 6,3 |  |  | 単位（kg） |
|  | 目標体重 | target_weight_value | numeric | 6,3 |  |  | 単位（kg） |
|  | 除水制限値 | off_water_limit | numeric | 6,3 |  |  | 単位（kg） |
|  | 車いすコード | wheel_chair_cd | bigint |  |  |  | 車いすマスタ.車いすコード |
|  | 車いす名称 | wheel_chair_name | character varying | 256 |  |  | 車いすマスタ.車いす名称 |
|  | 車いす重量 | wheel_chair_weight | numeric | 6,0 |  |  | 単位（g） |
|  | スタッフ | user_id | bigint |  |  |  |  |
|  | レシート内容 | print_content | jsonb |  |  |  | レシート印刷情報<br>{<br>  row_size: (Number) 行数,<br>  row_1: {<br>     class: (Number) 種別<br>                （文字列: 0, 罫線: 1, <br>                  NW-7: 2,  JAN13: 3, <br>                  用紙カット: 4）,<br>     font_size: (Number) フォントサイズ<br>                （小：0, 中:1, 大:2),<br>     value: (String) 印刷内容<br>    },<br>  row_2: {...},<br>  ...<br>  row_N: {...}<br>} |
|  | 印刷結果 | print_status | smallint |  |  |  | 0:印刷無し<br>1:印刷指示中<br>2:印刷指示受諾<br>3:印刷成功<br>4:印刷失敗 |
|  | 印刷エラーメッセージ | print_error_message | character varying | 256 |  |  | レシート印刷失敗時のメッセージ |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
