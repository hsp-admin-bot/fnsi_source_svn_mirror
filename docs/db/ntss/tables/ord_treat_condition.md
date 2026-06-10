# ord_treat_condition

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_treat_condition`
- Logical name: 設定値読み込み履歴
- Physical name: `ord_treat_condition`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `condition_cd`
- Column count: 11
- NOT NULL columns: 3

## Related Config / Notes

- [../config/ord_treat_condition.md](../config/ord_treat_condition.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 治療条件管理番号 | condition_cd | bigserial |  | 1 |  |  |
|  | オーダー番号 | ord_no | bigint |  |  |  | 治療情報.オーダー番号 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 装置番号 | machine_no | bigint |  | 1 |  |  |
|  | 条件取得日時 | receive_date | timestamp(3) |  |  |  |  |
|  | 治療条件 | treat_condition | jsonb |  |  |  | ■@ord_treat_condition |
|  | 区分 | treat_class | smallint |  |  |  | 0:条件送信前<br>1:条件送信<br>2:運転開始<br>3:廃液検出<br>4:任意 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
