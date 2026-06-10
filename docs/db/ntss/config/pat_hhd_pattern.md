# pat_hhd_pattern

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@pat_hhd_pattern`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 指示：治療条件情報 (ind_cond_info) |  |  |
| ※ ord_mainに展開するデータのため構成はord_mainのカラム構成と同様とする。 |  |  |
| 但し、マスタの最新情報を常に使用する想定とし、コードのみ保持する形式とする |  |  |
| （下記以外のキーは固定値（null含む）で登録される） |  |  |
| { |  |  |
| 治療条件項目番号 | Number | (*1) |
| { |  |  |
| value | Number | 設定値(*2) |
| value_name_1 | String |  |
| unit | String |  |
| medicine_type | Number | 薬剤区分(*5)(*6) |
| ind_user_id | Number | 指示者コード(利用者マスタ.利用者ID)(*2) |
| ind_user_last_name | String |  |
| ind_user_first_name | String |  |
| upd_user_id | Number | 更新者コード(利用者マスタ.利用者ID)(*2) |
| upd_user_last_name | String |  |
| upd_user_first_name | String |  |
| input_class | Number |  |
| is_editable | String |  |
| cop_order_no | String |  |
| }, … |  |  |
| } |  |  |
| 指示：投与薬剤情報 (ind_medi_info) |  |  |
| ※ ord_mainに展開するデータのため構成はord_mainのカラム構成と同様とする。 |  |  |
| 但し、マスタの最新情報を常に使用する想定とし、コードのみ保持する形式とする |  |  |
| （下記以外のキーは固定値（null含む）で登録される） |  |  |
| [ |  |  |
| { |  |  |
| no | Number | 識別番号(*1) |
| class_cd | Number |  |
| class_name | String |  |
| class_type | Number |  |
| medicine_type | Number | 薬剤区分(*2)(*4) |
| cd | Number | 薬剤(調整薬剤)コード(*2) |
| name | String |  |
| short_name | String |  |
| unit | String |  |
| amount | Number | 数量(*2) |
| init_date | String |  |
| date_interval | Number |  |
| timing_cd | Number | 投与タイミングコード(*2) |
| timing_name | String |  |
| procedure_cd | Number | 手技コード(*2) |
| procedure_name | String |  |
| comment | String | コメント(*2) |
| ind_user_id | Number | 指示者コード(利用者マスタ.利用者ID)(*2) |
| ind_user_last_name | String |  |
| ind_user_first_name | String |  |
| upd_user_id | Number | 更新者コード(利用者マスタ.利用者ID)(*2) |
| upd_user_last_name | String |  |
| upd_user_first_name | String |  |
| input_class | Number |  |
| is_editable | String |  |
| cop_order_no | String |  |
| }, … |  |  |
| ] |  |  |
| 指示：医療材料情報 (ind_equip_info) |  |  |
| ※ ord_mainに展開するデータのため構成はord_mainのカラム構成と同様とする。 |  |  |
| 但し、マスタの最新情報を常に使用する想定とし、コードのみ保持する形式とする |  |  |
| （下記以外のキーは固定値（null含む）で登録される） |  |  |
| [ |  |  |
| { |  |  |
| class_cd | Number |  |
| class_name | String |  |
| class_type | Number |  |
| cd | Number | 医療材料コード(*1) |
| name | String |  |
| short_name | String |  |
| needle_type | Number | 穿刺針区分(*3) |
| amount | Number | 数量(*1) |
| unit | String |  |
| ind_user_id | Number | 指示者コード(利用者マスタ.利用者ID)(*1) |
| ind_user_last_name | String |  |
| ind_user_first_name | String |  |
| upd_user_id | Number | 更新者コード(利用者マスタ.利用者ID)(*1) |
| upd_user_last_name | String |  |
| upd_user_first_name | String |  |
| input_class | Number |  |
| is_editable | String |  |
| cop_order_no | String |  |
| equip_type | Number |  |
| }, … |  |  |
| ] |  |  |
