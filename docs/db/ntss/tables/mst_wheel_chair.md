# mst_wheel_chair

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_wheel_chair`
- Logical name: 車いすマスタ
- Physical name: `mst_wheel_chair`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `wheel_chair_cd`
- Column count: 15
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_pat_viewer_layout.md](../config/mst_pat_viewer_layout.md)
- [../config/mst_pat_viewer_layout_2.md](../config/mst_pat_viewer_layout_2.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 車いすコード | wheel_chair_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | FNW+で管理する施設内で一意な車いすコード | fn_wheel_chair_cd | character varying | 8 |  |  | FNW+の車いすマスタ.車いすコードに相当 |
|  | 車いす名称 | wheel_chair_name | character varying | 256 |  |  |  |
|  | 重量 | wheel_chair_weight | numeric | 6,0 |  |  | 単位(g) |
|  | 重量校正日 | scale_date | timestamp(3) |  |  |  |  |
|  | 重量校正者 | scale_user_id | bigint |  |  |  | 利用者マスタ.利用者ID |
|  | 個人所有フラグ | is_personal | character varying | 1 |  | '0' | 0'：その他、'1'：患者個人所有 |
|  | 所有患者ID | pat_id | bigint |  |  |  | 個人所有フラグが'1'：個人所有の場合のみ有効。 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 連携コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 連携コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
