# ord_checklist

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_checklist`
- Logical name: チェックリスト実績
- Physical name: `ord_checklist`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `checklist_ctl_no`
- Column count: 14
- NOT NULL columns: 1

## Related Config / Notes

- [../config/ord_checklist.md](../config/ord_checklist.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | チェックリスト管理番号 | checklist_ctl_no | bigserial |  | 1 |  |  |
|  | システムで管理する一意なオーダ番号 | ord_no | bigint |  |  |  | ord_main.ord_no |
|  | 実施状態 | is_check | character varying | 1 |  | 0' | 0'：未実施、'1'：実施済み |
|  | 実績区分 | rst_class | smallint |  |  |  | 0：条件送信前、1：条件送信後、2：初版確定、9：リスト基準 |
|  | リストコード | list_cd | smallint |  |  |  | チェックリストマスタ.チェックリスト設定.リストコード<br>1～8で固定で使用 |
|  | 機能種別 | func_class | smallint |  |  |  | チェックリストマスタ.チェックリスト設定.機能リスト.機能種別<br>0：通常リスト、1：治療条件、2：医療材料、３：投与薬剤 |
|  | チェックリスト項目情報 | rst_checklist_info | jsonb |  |  |  | チェックリスト項目情報（詳細■@ord_checklist）<br>{<br>  "checklist_cd":(Number)チェックリストマスタ.チェックリストコード,<br>  "item_number":(Number)チェックリストマスタ.チェックリスト設定.機能リスト.項目番号,<br>  "class_cd":(Number)チェックリストマスタ.チェックリスト設定.機能リスト.分類コード,<br>  "code":(Number)医療材料マスタ.医療材料コード,<br>  "code_update":(String)医療材料マスタ.更新日時,<br>  "name":(String)項目名称,<br>  "needle_type":(Number)穿刺針区分(0: 未指定、1: A針、2: V針、3: SN),<br> "medicine_type": (Number)薬剤区分( 1: 通常薬剤、2: 調製薬剤),<br>  "amount":(String)数量,<br>  "unit":(String)単位<br>} |
|  | 実施者情報 | reg_staff_info | jsonb |  |  | E'{"reg_staff_cd":null,"reg_staff_update":null}' | 実施者情報<br>{<br>  "reg_staff_cd":(Number)スタッフマスタ.スタッフコード　※実施者コード<br>  "reg_staff_update":(String)スタッフマスタ.更新日時　※実施者コード更新日時<br>} |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 発生日時 | occur_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
