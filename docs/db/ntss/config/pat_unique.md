# pat_unique

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@pat_unique`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 入外・転入出情報 |  |  |
| [{ |  |  |
| ctl_no | Number | 管理番号 |
| disp_order | String | 表示順 |
| facility_cd | String | 登録施設コード |
| move_in_out | String | 転入出区分("1":導入, "2":転入, "3":転出, "4":入院, "5":退院, "6":外来, "7":離脱, "8":移植, "9":一時転出, "10":通院拒否・不明, "11":死亡) |
| period_start | String | 転入出期間(開始)、入外区分・在院状態更新処理用 |
| period_start_date | String | 転入出期間(開始)、カレンダー選択用 |
| period_start_year | String | 転入出期間(開始)年 |
| period_start_month | String | 転入出期間(開始)月 |
| period_start_day | String | 転入出期間(開始)日 |
| period_start_input_free | String | 転入出期間(開始)がフリー入力か判定("0"：フリー入力でない、"1"：フリー入力 |
| period_end | String | 転入出期間(終了)、入外区分・在院状態更新処理用 |
| period_end_date | String | 転入出期間(終了)、カレンダー選択用 |
| period_end_year | String | 転入出期間(終了)年 |
| period_end_month | String | 転入出期間(終了)月 |
| period_end_day | String | 転入出期間(終了)日 |
| period_end_input_free | String | 転入出期間(終了)がフリー入力か判定("0"：フリー入力でない、"1"：フリー入力 |
| in_out | Number | 入外区分(0:外来, 1:入院, 2:死亡, 3:－(不在)) |
| reason | String | 入出理由 |
| from_facility | String | 元施設 |
| from_course | String | 元科 |
| from_doctor | String | 元施設医 |
| to_facility | String | 先施設 |
| to_course | String | 先科 |
| to_doctor | String | 先施設医 |
| facility_is_free | String | 施設名がフリー入力か判定("0"：フリー入力でない、"1"：フリー入力 |
| course_is_free | String | 診療科がフリー入力か判定("0"：フリー入力でない、"1"：フリー入力 |
| doctor_is_free | String | 医師名がフリー入力か判定("0"：フリー入力でない、"1"：フリー入力 |
| to_medicalInstitutionCd | String |  |
| from_medicalInstitutionCd | String |  |
| }..] |  |  |
