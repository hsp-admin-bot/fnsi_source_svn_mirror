# インデックス一覧

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `インデックス一覧`
- Category: overview

## Content

| インデックス一覧 | col2 | col3 | ↓インデックス名記入 | col5 | col6 | ↓インデックスの用途を記入 | col8 | ↓インデックスに適用するカラム名（物理名）を記入 | col10 | col11 | col12 | col13 | col14 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| NTSSデータベース設計書.xlsm | ■ | No | インデックス名 | テーブル名 | カラム | 用途 | 最終更新日時 | カラム1 | カラム2 | カラム3 | カラム4 | カラム5 | SQL |
|  | ■ | 1 | idx_mni_monitor_01 | mni_monitor | facility_cd,machine_type_cd,machine_serial,occur_date | 生体モニタリング用 | 43452 | facility_cd | machine_type_cd | machine_serial | occur_date |  | CREATE INDEX CONCURRENTLY idx_mni_monitor_01 ON mni_monitor (facility_cd,machine_type_cd,machine_serial,occur_date); |
|  | ■ | 2 | idx_mnt_motion_record_01 | mnt_motion_record | facility_cd,machine_type_cd | 稼働ビューア用 | 43453 | facility_cd | machine_type_cd |  |  |  | CREATE INDEX CONCURRENTLY idx_mnt_motion_record_01 ON mnt_motion_record (facility_cd,machine_type_cd); |
|  | ■ | 3 | idx_ord_main_01 | ord_main | facility_cd,pat_id | 治療情報用 | 43553 | facility_cd | pat_id |  |  |  | CREATE INDEX CONCURRENTLY idx_ord_main_01 ON ord_main (facility_cd,pat_id); |
|  | ■ | 4 | idx_sys_medicine_01 | sys_medicine | standard_medicine_cd | 標準医薬品マスタ用 | 43931 | standard_medicine_cd |  |  |  |  | CREATE INDEX CONCURRENTLY idx_sys_medicine_01 ON sys_medicine (standard_medicine_cd); |
|  | ■ | 5 | idx_mnt_motion_record_02 | mnt_motion_record | facility_cd,machine_type_cd,data_type | 遠隔監視-装置一覧用 | 44272 | facility_cd | machine_type_cd | data_type |  |  | CREATE INDEX CONCURRENTLY idx_mnt_motion_record_02 ON mnt_motion_record (facility_cd,machine_type_cd,data_type); |
|  | ■ | 6 | idx_ord_weight_scale_03 | ord_weight_scale | facility_cd,measure_date | 体重計測定記録用 | 46091 | facility_cd | measure_date |  |  |  | CREATE INDEX CONCURRENTLY idx_ord_weight_scale_03 ON ord_weight_scale (facility_cd,measure_date); |
|  |  | 7 |  |  |  |  | =IFERROR(VLOOKUP(D9,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 8 |  |  |  |  | =IFERROR(VLOOKUP(D10,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 9 |  |  |  |  | =IFERROR(VLOOKUP(D11,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 10 |  |  |  |  | =IFERROR(VLOOKUP(D12,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 11 |  |  |  |  | =IFERROR(VLOOKUP(D13,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 12 |  |  |  |  | =IFERROR(VLOOKUP(D14,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 13 |  |  |  |  | =IFERROR(VLOOKUP(D15,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 14 |  |  |  |  | =IFERROR(VLOOKUP(D16,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 15 |  |  |  |  | =IFERROR(VLOOKUP(D17,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 16 |  |  |  |  | =IFERROR(VLOOKUP(D18,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 17 |  |  |  |  | =IFERROR(VLOOKUP(D19,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 18 |  |  |  |  | =IFERROR(VLOOKUP(D20,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 19 |  |  |  |  | =IFERROR(VLOOKUP(D21,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 20 |  |  |  |  | =IFERROR(VLOOKUP(D22,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 21 |  |  |  |  | =IFERROR(VLOOKUP(D23,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 22 |  |  |  |  | =IFERROR(VLOOKUP(D24,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 23 |  |  |  |  | =IFERROR(VLOOKUP(D25,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 24 |  |  |  |  | =IFERROR(VLOOKUP(D26,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 25 |  |  |  |  | =IFERROR(VLOOKUP(D27,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 26 |  |  |  |  | =IFERROR(VLOOKUP(D28,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 27 |  |  |  |  | =IFERROR(VLOOKUP(D29,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 28 |  |  |  |  | =IFERROR(VLOOKUP(D30,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 29 |  |  |  |  | =IFERROR(VLOOKUP(D31,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 30 |  |  |  |  | =IFERROR(VLOOKUP(D32,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 31 |  |  |  |  | =IFERROR(VLOOKUP(D33,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 32 |  |  |  |  | =IFERROR(VLOOKUP(D34,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 33 |  |  |  |  | =IFERROR(VLOOKUP(D35,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 34 |  |  |  |  | =IFERROR(VLOOKUP(D36,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 35 |  |  |  |  | =IFERROR(VLOOKUP(D37,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 36 |  |  |  |  | =IFERROR(VLOOKUP(D38,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 37 |  |  |  |  | =IFERROR(VLOOKUP(D39,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 38 |  |  |  |  | =IFERROR(VLOOKUP(D40,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 39 |  |  |  |  | =IFERROR(VLOOKUP(D41,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 40 |  |  |  |  | =IFERROR(VLOOKUP(D42,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 41 |  |  |  |  | =IFERROR(VLOOKUP(D43,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 42 |  |  |  |  | =IFERROR(VLOOKUP(D44,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 43 |  |  |  |  | =IFERROR(VLOOKUP(D45,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 44 |  |  |  |  | =IFERROR(VLOOKUP(D46,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 45 |  |  |  |  | =IFERROR(VLOOKUP(D47,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 46 |  |  |  |  | =IFERROR(VLOOKUP(D48,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 47 |  |  |  |  | =IFERROR(VLOOKUP(D49,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 48 |  |  |  |  | =IFERROR(VLOOKUP(D50,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 49 |  |  |  |  | =IFERROR(VLOOKUP(D51,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 50 |  |  |  |  | =IFERROR(VLOOKUP(D52,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 51 |  |  |  |  | =IFERROR(VLOOKUP(D53,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 52 |  |  |  |  | =IFERROR(VLOOKUP(D54,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 53 |  |  |  |  | =IFERROR(VLOOKUP(D55,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 54 |  |  |  |  | =IFERROR(VLOOKUP(D56,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 55 |  |  |  |  | =IFERROR(VLOOKUP(D57,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 56 |  |  |  |  | =IFERROR(VLOOKUP(D58,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 57 |  |  |  |  | =IFERROR(VLOOKUP(D59,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 58 |  |  |  |  | =IFERROR(VLOOKUP(D60,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 59 |  |  |  |  | =IFERROR(VLOOKUP(D61,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 60 |  |  |  |  | =IFERROR(VLOOKUP(D62,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 61 |  |  |  |  | =IFERROR(VLOOKUP(D63,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 62 |  |  |  |  | =IFERROR(VLOOKUP(D64,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 63 |  |  |  |  | =IFERROR(VLOOKUP(D65,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 64 |  |  |  |  | =IFERROR(VLOOKUP(D66,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 65 |  |  |  |  | =IFERROR(VLOOKUP(D67,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  | =IF(E68<>"",HYPERLINK("["&$A$2&"]"&E68&"!A1","■"),"") | 66 |  | =IFERROR(MID(D68,5,(LEN(D68)-7)),"") |  |  | =IFERROR(VLOOKUP(D68,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  | =IF(D68<>"","CREATE INDEX CONCURRENTLY "&D68&" ON "&E68&" ("&F68&");","") |
|  |  | 67 |  |  | =IF(I69="","",I69)&IF(J69="","",","&J69)&IF(K69="","",","&K69)&IF(L69="","",","&L69)&IF(M69="","",","&M69) |  | =IFERROR(VLOOKUP(D69,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 68 |  |  |  |  | =IFERROR(VLOOKUP(D70,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 69 |  |  |  |  | =IFERROR(VLOOKUP(D71,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 70 |  |  |  |  | =IFERROR(VLOOKUP(D72,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 71 |  |  |  |  | =IFERROR(VLOOKUP(D73,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 72 |  |  |  |  | =IFERROR(VLOOKUP(D74,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 73 |  |  |  |  | =IFERROR(VLOOKUP(D75,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 74 |  |  |  |  | =IFERROR(VLOOKUP(D76,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 75 |  |  |  |  | =IFERROR(VLOOKUP(D77,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 76 |  |  |  |  | =IFERROR(VLOOKUP(D78,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 77 |  |  |  |  | =IFERROR(VLOOKUP(D79,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 78 |  |  |  |  | =IFERROR(VLOOKUP(D80,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 79 |  |  |  |  | =IFERROR(VLOOKUP(D81,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 80 |  |  |  |  | =IFERROR(VLOOKUP(D82,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 81 |  |  |  |  | =IFERROR(VLOOKUP(D83,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 82 |  |  |  |  | =IFERROR(VLOOKUP(D84,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 83 |  |  |  |  | =IFERROR(VLOOKUP(D85,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 84 |  |  |  |  | =IFERROR(VLOOKUP(D86,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 85 |  |  |  |  | =IFERROR(VLOOKUP(D87,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 86 |  |  |  |  | =IFERROR(VLOOKUP(D88,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 87 |  |  |  |  | =IFERROR(VLOOKUP(D89,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 88 |  |  |  |  | =IFERROR(VLOOKUP(D90,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 89 |  |  |  |  | =IFERROR(VLOOKUP(D91,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 90 |  |  |  |  | =IFERROR(VLOOKUP(D92,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 91 |  |  |  |  | =IFERROR(VLOOKUP(D93,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 92 |  |  |  |  | =IFERROR(VLOOKUP(D94,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 93 |  |  |  |  | =IFERROR(VLOOKUP(D95,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 94 |  |  |  |  | =IFERROR(VLOOKUP(D96,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 95 |  |  |  |  | =IFERROR(VLOOKUP(D97,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 96 |  |  |  |  | =IFERROR(VLOOKUP(D98,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 97 |  |  |  |  | =IFERROR(VLOOKUP(D99,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 98 |  |  |  |  | =IFERROR(VLOOKUP(D100,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 99 |  |  |  |  | =IFERROR(VLOOKUP(D101,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 100 |  |  |  |  | =IFERROR(VLOOKUP(D102,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 101 |  |  |  |  | =IFERROR(VLOOKUP(D103,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 102 |  |  |  |  | =IFERROR(VLOOKUP(D104,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 103 |  |  |  |  | =IFERROR(VLOOKUP(D105,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 104 |  |  |  |  | =IFERROR(VLOOKUP(D106,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 105 |  |  |  |  | =IFERROR(VLOOKUP(D107,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 106 |  |  |  |  | =IFERROR(VLOOKUP(D108,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 107 |  |  |  |  | =IFERROR(VLOOKUP(D109,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 108 |  |  |  |  | =IFERROR(VLOOKUP(D110,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 109 |  |  |  |  | =IFERROR(VLOOKUP(D111,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 110 |  |  |  |  | =IFERROR(VLOOKUP(D112,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 111 |  |  |  |  | =IFERROR(VLOOKUP(D113,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 112 |  |  |  |  | =IFERROR(VLOOKUP(D114,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 113 |  |  |  |  | =IFERROR(VLOOKUP(D115,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 114 |  |  |  |  | =IFERROR(VLOOKUP(D116,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 115 |  |  |  |  | =IFERROR(VLOOKUP(D117,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 116 |  |  |  |  | =IFERROR(VLOOKUP(D118,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 117 |  |  |  |  | =IFERROR(VLOOKUP(D119,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 118 |  |  |  |  | =IFERROR(VLOOKUP(D120,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 119 |  |  |  |  | =IFERROR(VLOOKUP(D121,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 120 |  |  |  |  | =IFERROR(VLOOKUP(D122,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 121 |  |  |  |  | =IFERROR(VLOOKUP(D123,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 122 |  |  |  |  | =IFERROR(VLOOKUP(D124,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 123 |  |  |  |  | =IFERROR(VLOOKUP(D125,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 124 |  |  |  |  | =IFERROR(VLOOKUP(D126,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 125 |  |  |  |  | =IFERROR(VLOOKUP(D127,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 126 |  |  |  |  | =IFERROR(VLOOKUP(D128,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 127 |  |  |  |  | =IFERROR(VLOOKUP(D129,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 128 |  |  |  |  | =IFERROR(VLOOKUP(D130,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 129 |  |  |  |  | =IFERROR(VLOOKUP(D131,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  | =IF(E132<>"",HYPERLINK("["&$A$2&"]"&E132&"!A1","■"),"") | 130 |  | =IFERROR(MID(D132,5,(LEN(D132)-7)),"") |  |  | =IFERROR(VLOOKUP(D132,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  | =IF(D132<>"","CREATE INDEX CONCURRENTLY "&D132&" ON "&E132&" ("&F132&");","") |
|  |  | 131 |  |  | =IF(I133="","",I133)&IF(J133="","",","&J133)&IF(K133="","",","&K133)&IF(L133="","",","&L133)&IF(M133="","",","&M133) |  | =IFERROR(VLOOKUP(D133,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 132 |  |  |  |  | =IFERROR(VLOOKUP(D134,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 133 |  |  |  |  | =IFERROR(VLOOKUP(D135,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 134 |  |  |  |  | =IFERROR(VLOOKUP(D136,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 135 |  |  |  |  | =IFERROR(VLOOKUP(D137,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 136 |  |  |  |  | =IFERROR(VLOOKUP(D138,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 137 |  |  |  |  | =IFERROR(VLOOKUP(D139,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 138 |  |  |  |  | =IFERROR(VLOOKUP(D140,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 139 |  |  |  |  | =IFERROR(VLOOKUP(D141,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 140 |  |  |  |  | =IFERROR(VLOOKUP(D142,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 141 |  |  |  |  | =IFERROR(VLOOKUP(D143,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 142 |  |  |  |  | =IFERROR(VLOOKUP(D144,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 143 |  |  |  |  | =IFERROR(VLOOKUP(D145,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 144 |  |  |  |  | =IFERROR(VLOOKUP(D146,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 145 |  |  |  |  | =IFERROR(VLOOKUP(D147,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 146 |  |  |  |  | =IFERROR(VLOOKUP(D148,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 147 |  |  |  |  | =IFERROR(VLOOKUP(D149,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 148 |  |  |  |  | =IFERROR(VLOOKUP(D150,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 149 |  |  |  |  | =IFERROR(VLOOKUP(D151,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 150 |  |  |  |  | =IFERROR(VLOOKUP(D152,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 151 |  |  |  |  | =IFERROR(VLOOKUP(D153,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 152 |  |  |  |  | =IFERROR(VLOOKUP(D154,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 153 |  |  |  |  | =IFERROR(VLOOKUP(D155,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 154 |  |  |  |  | =IFERROR(VLOOKUP(D156,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 155 |  |  |  |  | =IFERROR(VLOOKUP(D157,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 156 |  |  |  |  | =IFERROR(VLOOKUP(D158,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 157 |  |  |  |  | =IFERROR(VLOOKUP(D159,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 158 |  |  |  |  | =IFERROR(VLOOKUP(D160,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 159 |  |  |  |  | =IFERROR(VLOOKUP(D161,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 160 |  |  |  |  | =IFERROR(VLOOKUP(D162,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 161 |  |  |  |  | =IFERROR(VLOOKUP(D163,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 162 |  |  |  |  | =IFERROR(VLOOKUP(D164,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 163 |  |  |  |  | =IFERROR(VLOOKUP(D165,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 164 |  |  |  |  | =IFERROR(VLOOKUP(D166,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 165 |  |  |  |  | =IFERROR(VLOOKUP(D167,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 166 |  |  |  |  | =IFERROR(VLOOKUP(D168,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 167 |  |  |  |  | =IFERROR(VLOOKUP(D169,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 168 |  |  |  |  | =IFERROR(VLOOKUP(D170,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 169 |  |  |  |  | =IFERROR(VLOOKUP(D171,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 170 |  |  |  |  | =IFERROR(VLOOKUP(D172,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 171 |  |  |  |  | =IFERROR(VLOOKUP(D173,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 172 |  |  |  |  | =IFERROR(VLOOKUP(D174,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 173 |  |  |  |  | =IFERROR(VLOOKUP(D175,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 174 |  |  |  |  | =IFERROR(VLOOKUP(D176,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 175 |  |  |  |  | =IFERROR(VLOOKUP(D177,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 176 |  |  |  |  | =IFERROR(VLOOKUP(D178,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 177 |  |  |  |  | =IFERROR(VLOOKUP(D179,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 178 |  |  |  |  | =IFERROR(VLOOKUP(D180,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 179 |  |  |  |  | =IFERROR(VLOOKUP(D181,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 180 |  |  |  |  | =IFERROR(VLOOKUP(D182,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 181 |  |  |  |  | =IFERROR(VLOOKUP(D183,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 182 |  |  |  |  | =IFERROR(VLOOKUP(D184,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 183 |  |  |  |  | =IFERROR(VLOOKUP(D185,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 184 |  |  |  |  | =IFERROR(VLOOKUP(D186,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 185 |  |  |  |  | =IFERROR(VLOOKUP(D187,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 186 |  |  |  |  | =IFERROR(VLOOKUP(D188,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 187 |  |  |  |  | =IFERROR(VLOOKUP(D189,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 188 |  |  |  |  | =IFERROR(VLOOKUP(D190,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 189 |  |  |  |  | =IFERROR(VLOOKUP(D191,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 190 |  |  |  |  | =IFERROR(VLOOKUP(D192,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 191 |  |  |  |  | =IFERROR(VLOOKUP(D193,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 192 |  |  |  |  | =IFERROR(VLOOKUP(D194,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 193 |  |  |  |  | =IFERROR(VLOOKUP(D195,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  | =IF(E196<>"",HYPERLINK("["&$A$2&"]"&E196&"!A1","■"),"") | 194 |  | =IFERROR(MID(D196,5,(LEN(D196)-7)),"") |  |  | =IFERROR(VLOOKUP(D196,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  | =IF(D196<>"","CREATE INDEX CONCURRENTLY "&D196&" ON "&E196&" ("&F196&");","") |
|  |  | 195 |  |  | =IF(I197="","",I197)&IF(J197="","",","&J197)&IF(K197="","",","&K197)&IF(L197="","",","&L197)&IF(M197="","",","&M197) |  | =IFERROR(VLOOKUP(D197,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 196 |  |  |  |  | =IFERROR(VLOOKUP(D198,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 197 |  |  |  |  | =IFERROR(VLOOKUP(D199,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 198 |  |  |  |  | =IFERROR(VLOOKUP(D200,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 199 |  |  |  |  | =IFERROR(VLOOKUP(D201,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
|  |  | 200 |  |  |  |  | =IFERROR(VLOOKUP(D202,変更履歴!$A$3:$G$1062,7,FALSE),"") |  |  |  |  |  |  |
