# mst_rad_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_rad_set`
- Logical name: 放射線検査セットマスタ
- Physical name: `mst_rad_set`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `rad_set_cd`
- Column count: 16
- NOT NULL columns: 4

## Related Config / Notes

- [../config/mst_rad_set.md](../config/mst_rad_set.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な放射線検査セットコード | rad_set_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | FNW+で管理する施設内の一意な検査セットコード | fn_exam_set_cd | character varying | 4 |  |  |  |
|  | 放射線検査セット名 | rad_set_name | character varying | 40 | 1 |  |  |
|  | 省略 放射線検査セット名 | rad_set_abb_name | character varying | 40 |  |  |  |
|  | 放射線検査項目情報 | rad_item_info | jsonb |  | 1 | [<br>  {<br>    "ctl_no":コード区分（1:方法　2:区分　3:部位　4:左右　5:体位　6:方向）<br>　"ctl_name":null "item_cd":null<br>  },<br>※コード区分分（常に6個）繰り返し<br>] | ※@mst_rad_set参照 |
|  | 院内コード1 | in_hospital_cd1 | character varying | 20 |  |  | 自動生成 |
|  | 属性コード1 | sbt_cd1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd2 | character varying | 20 |  |  |  |
|  | 属性コード2 | sbt_cd2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd3 | character varying | 20 |  |  |  |
|  | 属性コード3 | sbt_cd3 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
