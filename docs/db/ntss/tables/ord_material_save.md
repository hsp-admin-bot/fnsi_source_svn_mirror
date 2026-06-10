# ord_material_save

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_material_save`
- Logical name: 計算材料保持
- Physical name: `ord_material_save`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ord_material_save_no`
- Column count: 20
- NOT NULL columns: 1

## Related Config / Notes

- [../config/receipe_conversion.md](../config/receipe_conversion.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ord_material_save_no | bigint |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 患者ID | pat_id | bigint |  |  |  | order_main：pat_id<br>pat_prescription：pat_id |
|  | データ基準日 | supplies_base_date | character varying | 8 |  |  | YYYYMMDD形式<br>order_main：treat_date<br>ord_prescription：execute_date |
|  | データ基準番号 | supplies_base_no | bigserial |  |  |  | order_main：ord_no<br>ord_prescription：prescript_no |
|  | データ発生元区分 | supplies_source_class | character varying | 2 |  |  | 0：治療条件、1：投与薬剤、2：医療材料、3：愁訴処置、4：処方 |
|  | 物品区分 | supplies_class | character varying | 2 |  |  | データの分類。<br>00：血液回路、01：ダイアライザ、02：吸着カラム、03：1次膜、04：2次膜、05：シングルニードル、06：穿刺針(A)、07、穿刺針(V)、08：透析液、09：補液、10：抗凝固剤、11：他医療材料、12：投与薬剤、13：調整薬剤、14：処置薬剤、15：処置調整薬剤、16：処方、17：抗凝固剤調製薬剤（調製薬剤） |
|  | 物品コード | supplies_cd | character varying |  |  |  | 物品区分：00、02~07、11の時 医療材料コード、01の時 ダイアライザコード、物品区分：08~10、12~16の時 薬剤コード（調整薬剤の場合、調整前の薬剤コード） |
|  | 調整薬剤コード | medicine_mix_cd | character varying |  |  |  | 物品区分：13、15の時のみ設定。<br>調整薬剤コード |
|  | 分類コード | class_㏅ | character varying |  |  |  | 物品コードに紐づく分類コード |
|  | 指示・実績区分 | ind_rst_class | character varying | 1 |  |  | 1：指示、2：実績、３：未交付、４：交付済み |
|  | 指示・実績値 | ind_rst_value | character varying |  |  |  | 小数点桁数を正しく保持する。 |
|  | レセ値 | receipt_value | character varying |  |  |  | 小数点桁数を正しく保持する。 |
|  | 確定フラグ | is_confirm | character varying | 1 |  |  | 0：未確定、1：確定<br>0：未確定のものだけマスタ更新時の更新対象 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 薬剤識別番号 | medicine_no | json |  |  |  | ■Json構造<br>(*1)<br>[<br>  {<br>    "no": (Number)識別番号<br>  }<br>]<br>(*2)<br>[<br>  {<br>    "ctl_no": (Number)管理番号,<br>    "row_no": (Number)行番号<br>  }<br>]<br>■概要<br>(*1)投与薬剤情報.識別番号 {no:1}<br>    処方：｛no:連番｝<br>(*2)実績：愁訴処置情報.管理番号{crl_no:xx,row_no:xx} |
|  | 手技コード | procedure_cd | character varying | 3 |  |  |  |
|  | 投与タイミングコード | timing_cd | character varying | 3 |  |  |  |
|  | 単位換算情報 | receipe_conversion | jsonb |  |  |  | @receipe_conversion |
