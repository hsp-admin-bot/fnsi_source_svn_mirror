# mst_treatment

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_treatment`
- Logical name: 治療方法マスタ
- Physical name: `mst_treatment`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `treatment_cd`
- Column count: 32
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_treatment.md](../config/mst_treatment.md)
- [../config/report_graph_setting.md](../config/report_graph_setting.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 治療方法コード | treatment_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な治療方法コード | fn_treatment_cd | character varying | 20 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 治療方法名 | treatment_name | character varying |  |  |  |  |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 装置モード | device_mode | numeric | 2,0 |  |  | 該当する治療方法を行う場合に透析装置に送信する装置モード<br>-1:不明、0:HD、1:ECUM,2:HDF、3:HF、4:HD+補液、5:ECUM+補液、6:AFBF、7:OHDF、8:OHF、9:特殊浄化、10:I-HDF |
|  | 治療経過表ID | report_id | integer |  |  |  |  |
|  | 治療経過表ID（手書き） | report_id_hw | integer |  |  |  |  |
|  | 治療経過表ID（前体重） | report_id_bw | integer |  |  |  |  |
|  | 治療経過表ID（後体重） | report_id_aw | integer |  |  |  |  |
|  | 治療経過表ID（装置画像転送用） | report_id_dev | integer |  |  |  |  |
|  | グラフ時間幅 | graph_time_scale | numeric | 2,0 |  |  | 単位は時間。6,8,10のみを許容。 |
|  | 治療条件設定 | treatment_condition_setting | jsonb |  |  |  | 表示項目については<br>シート「@mst_treatment」を参照 |
|  | モニタデータ項目(帳票用) | monitor_data_item_print | jsonb |  |  |  | 要検討 |
|  | モニタデータ項目(画面用) | monitor_data_item_screen | jsonb |  |  |  | 要検討 |
|  | 帳票グラフ設定 | report_graph_setting | jsonb |  |  |  | @report_graph_setting' を参照 |
|  | 利用開始日A | in_hosp_a_startdate | timestamp(3) |  |  |  |  |
|  | 院内コードA1 | in_hospital_cd_a1 | character varying | 20 |  |  |  |
|  | 院内コードA2 | in_hospital_cd_a2 | character varying | 20 |  |  |  |
|  | 院内コードA3 | in_hospital_cd_a3 | character varying | 20 |  |  |  |
|  | 院内コードA4 | in_hospital_cd_a4 | character varying | 20 |  |  |  |
|  | 利用開始日B | in_hosp_b_startdate | timestamp(3) |  |  |  |  |
|  | 院内コードB1 | in_hospital_cd_b1 | character varying | 20 |  |  |  |
|  | 院内コードB2 | in_hospital_cd_b2 | character varying | 20 |  |  |  |
|  | 院内コードB3 | in_hospital_cd_b3 | character varying | 20 |  |  |  |
|  | 院内コードB4 | in_hospital_cd_b4 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 治療経過表ID（実績確定） | report_id_act | integer |  |  |  |  |
