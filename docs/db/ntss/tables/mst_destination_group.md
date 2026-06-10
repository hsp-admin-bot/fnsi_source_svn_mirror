# mst_destination_group

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_destination_group`
- Logical name: 送信先グループマスタ
- Physical name: `mst_destination_group`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `destination_group_cd`
- Column count: 9
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 送信先グループコード | destination_group_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 送信先グループ名 | destination_group_name | character varying |  |  |  |  |
|  | 送信対象 | destination_target | jsonb |  | 1 | {"users": []} | ■Json構造<br>{ "users" :<br> [<br>  {<br>  "user_id": 利用者マスタ.利用者ID (bigserial),<br>  "is_address1_send": アドレス1送信フラグ(boolean),<br>  "is_address2_send": アドレス2送信フラグ(boolean)<br>  }<br> ]<br>}<br>■概要<br>送信対象者毎に、送信対象となるアドレスを指定する。 |
|  | メーカー通知フラグ | is_notice | character varying | 1 |  | '0' | '0'：通知OFF、'1'：通知ON |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
