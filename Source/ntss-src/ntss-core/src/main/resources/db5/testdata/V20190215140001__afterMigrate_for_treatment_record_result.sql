-- ord_main(治療情報)　のデータ追加
INSERT INTO ord_main
(
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_start_date,
  rst_end_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  up_date,
  reg_date
) VALUES (
  2,
  '00003',
  '20190213',
  1,
  '009999',
  'テスト施設名',
  1,
  '午前',
  2,
  '101号室1',
  '2019/02/13 12:00:00.000',
  '2019/02/13 18:00:00.000',
  1,
  2,
  2,
  '腎科',
  10,
  '糖尿内科',
  '{
    "user_id_1": 101,
    "user_last_name_1": "穿刺1",
    "user_first_name_1": "太郎",
    "user_id_2": 102,
    "user_last_name_2": "穿刺2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:00:00.000+0900"
  }',
  '{
    "user_id_1": 103,
    "user_last_name_1": "返血1",
    "user_first_name_1": "太郎",
    "user_id_2": 104,
    "user_last_name_2": "返血2",
    "user_first_name_2": "次郎",
    "date": "2019-02-13T13:30:00.000+0900"
  }',
  '{
    "user_id_1": 105,
    "user_last_name_1": "担当1",
    "user_first_name_1": "太郎",
    "user_id_2": 106,
    "user_last_name_2": "担当2",
    "user_first_name_2": "次郎"
  }',
  '2019/02/13 14:30:00.000',
  '2019/02/13 14:00:00.000'
);

-- ベッドマスタ
INSERT INTO mst_bed
  (bed_cd, facility_cd, bed_no, bed_name, shunt_position, is_infection, emergency_class, machine_no, output_printer, is_autoprint_before, is_autoprint_after, is_autoprint_commit, fn_bed_no, is_disp, is_del, reg_date, up_date)
VALUES 
  (1, '009999', 1, '101号室1', 0, '0', 0, 0, NULL, '0', '0', NULL, 0, '1', '0', '2019-02-15 14:44:17.031', '2019-02-15 14:46:00.861')
 , (2, '009999', 2, '101号室2', 1, '0', 0, 0, NULL, '0', '0', NULL, 0, '1', '0', '2019-02-15 14:44:17.123', '2019-02-15 14:46:00.876')
 , (3, '009999', 3, '101号室3', 2, '1', 0, 0, NULL, '1', '1', NULL, 0, '1', '0', '2019-02-15 14:44:17.179', '2019-02-15 14:46:00.96')
 , (4, '009999', 4, '101号室4', 3, '1', 0, 0, NULL, '1', '1', NULL, 0, '1', '0', '2019-02-15 14:44:17.287', '2019-02-15 14:46:01.019')
 , (5, '009999', 5, '102号室1', 1, '0', 0, 0, NULL, NULL, '1', NULL, 0, '1', '0', '2019-02-15 14:44:17.353', '2019-02-15 14:46:01.067')
 , (6, '009999', 6, '102号室2', 1, '1', 0, 0, NULL, NULL, NULL, NULL, 0, '1', '0', '2019-02-15 14:44:17.408', '2019-02-15 14:44:17.408')
 , (7, '009999', 7, '102号室3', 1, NULL, 1, 0, NULL, '1', NULL, NULL, 0, '1', '0', '2019-02-15 14:44:17.521', '2019-02-15 14:46:01.135')
 , (8, '009999', 8, '102号室4', 0, NULL, 1, 0, NULL, NULL, NULL, NULL, 0, '1', '0', '2019-02-15 14:44:17.579', '2019-02-15 14:44:17.579')
 , (9, '009999', 9, '103号室1', 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, 0, '1', '0', '2019-02-15 14:44:17.679', '2019-02-15 14:44:17.679')
 , (10, '009999', 10, '103号室2', 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, 0, '1', '0', '2019-02-15 14:44:17.78', '2019-02-15 14:44:17.78')
;
SELECT setval('mst_bed_bed_cd_seq', 10);

-- クールマスタ
INSERT INTO mst_kur
  (kur_cd, facility_cd, fn_kur_cd, kur_name, kur_start_time, kur_end_time, kur_standard_start_time, in_hospital_cd_1, is_del, reg_date, up_date)
VALUES
  (1, '009999', '11', '午前', '080000', '120000', '083000', NULL, '0', '2019-02-15 14:48:39.705', '2019-02-15 14:48:39.705')
 , (2, '009999', '21', '午後', '130000', '170000', '130000', NULL, '0', '2019-02-15 14:48:39.731', '2019-02-15 14:48:39.731')
 , (3, '009999', '22', '夜間', '190000', '230000', '190000', NULL, '0', '2019-02-15 14:48:39.764', '2019-02-15 14:48:39.764')
;
SELECT setval('mst_kur_kur_cd_seq', 3);

-- 病棟マスタ
INSERT INTO mst_ward
  (ward_cd, facility_cd, fn_ward_cd, ward_name, in_hospital_cd_1, is_disp, is_del, reg_date, up_date)
VALUES
   (1, '009999', '11', '腫瘍センター', NULL, '1', '0', '2019-02-15 14:51:31.341', '2019-02-15 14:51:31.341')
  , (2, '009999', '21', '腎センター', NULL, '1', '0', '2019-02-15 14:51:31.41', '2019-02-15 14:51:31.41')
  , (3, '009999', '31', '運動器センター', NULL, '1', '0', '2019-02-15 14:51:31.465', '2019-02-15 14:51:31.465')
  , (4, '009999', '41', '生活習慣病センター', NULL, '1', '0', '2019-02-15 14:51:31.522', '2019-02-15 14:51:31.522')
  , (5, '009999', '51', '皮膚・頭頸部センター', NULL, '1', '0', '2019-02-15 14:51:31.565', '2019-02-15 14:51:31.565')
  , (6, '009999', '61', '呼吸器センター', NULL, '1', '0', '2019-02-15 14:51:31.594', '2019-02-15 14:51:31.594')
  , (7, '009999', '71', '消化器センター', NULL, '1', '0', '2019-02-15 14:51:31.635', '2019-02-15 14:51:31.635')
  , (8, '009999', '81', '脳・神経センター', NULL, '1', '0', '2019-02-15 14:51:31.671', '2019-02-15 14:51:31.671')
  , (9, '009999', '91', '循環器センター', NULL, '1', '0', '2019-02-15 14:51:31.733', '2019-02-15 14:51:31.733')
  , (10, '009999', '111', '成育・女性医療センター', NULL, '1', '0', '2019-02-15 14:51:31.79', '2019-02-15 14:51:31.79')
;
SELECT setval('mst_ward_ward_cd_seq', 10);

-- 診療科マスタ
INSERT INTO mst_course
  (course_cd, facility_cd, fn_course_cd, course_name, standard_course_cd, in_hospital_cd_1, is_disp, is_del, reg_date, up_date)
VALUES
  (1, '009999', '11', '血液透析科', 0, NULL, '1', '0', '2019-02-15 14:33:43.205', '2019-02-15 14:33:43.205')
 , (2, '009999', '21', '糖尿病科', 0, NULL, '1', '0', '2019-02-15 14:33:43.375', '2019-02-15 14:33:43.375')
 , (3, '009999', '31', '腎臓内科', 0, NULL, '1', '0', '2019-02-15 14:33:43.467', '2019-02-15 14:33:43.467')
 , (4, '009999', '41', '腎移植科', 0, NULL, '1', '0', '2019-02-15 14:33:43.503', '2019-02-15 14:33:43.503')
 , (5, '009999', '51', '代謝内科', 0, NULL, '1', '0', '2019-02-15 14:33:43.537', '2019-02-15 14:33:43.537')
 , (6, '009999', '61', '内分泌内科', 0, NULL, '1', '0', '2019-02-15 14:33:43.565', '2019-02-15 14:33:43.565')
 , (7, '009999', '71', '救急医学科', 0, NULL, '1', '0', '2019-02-15 14:33:43.634', '2019-02-15 14:33:43.634')
 , (8, '009999', '81', '血液科', 0, NULL, '1', '0', '2019-02-15 14:33:43.71', '2019-02-15 14:33:43.71')
 , (9, '009999', '91', '血液内科', 0, NULL, '1', '0', '2019-02-15 14:33:43.793', '2019-02-15 14:33:43.793')
 , (10, '009999', '111', '糖尿内科', 0, NULL, '0', '0', '2019-02-15 14:33:43.812', '2019-02-15 14:33:43.812')
;
SELECT setval('mst_course_course_cd_seq', 10);

-- mst_selector(選択肢マスタ) のデータ追加
INSERT INTO mst_selector
  (facility_cd, master_physical_name, order_settings, reg_date, up_date)
VALUES
  ('009999', 'mst_course', '{"items": [{"code": 1, "name": "血液透析科"}, {"code": 2, "name": "糖尿病科"}, {"code": 3, "name": "腎臓内科"}, {"code": 4, "name": "腎移植科"}, {"code": 5, "name": "代謝内科"}, {"code": 6, "name": "内分泌内科"}, {"code": 7, "name": "救急医学科"}, {"code": 8, "name": "血液科"}, {"code": 9, "name": "血液内科"}]}', '2019-02-15 14:33:43.893', '2019-02-15 14:33:43.893')
 , ('009999', 'mst_bed', '{"items": [{"code": 1, "name": "101号室1"}, {"code": 2, "name": "101号室2"}, {"code": 3, "name": "101号室3"}, {"code": 4, "name": "101号室4"}, {"code": 5, "name": "102号室1"}, {"code": 6, "name": "102号室2"}, {"code": 7, "name": "102号室3"}, {"code": 8, "name": "102号室4"}, {"code": 9, "name": "103号室1"}, {"code": 10, "name": "103号室2"}]}', '2019-02-15 14:44:17.824', '2019-02-15 14:46:01.15')
 , ('009999', 'mst_kur', '{"items": [{"code": 1, "name": "午前"}, {"code": 2, "name": "午後"}, {"code": 3, "name": "夜間"}]}', '2019-02-15 14:48:39.795', '2019-02-15 14:48:39.795')
 , ('009999', 'mst_ward', '{"items": [{"code": 1, "name": "腫瘍センター"}, {"code": 2, "name": "腎センター"}, {"code": 3, "name": "運動器センター"}, {"code": 4, "name": "生活習慣病センター"}, {"code": 5, "name": "皮膚・頭頸部センター"}, {"code": 6, "name": "呼吸器センター"}, {"code": 7, "name": "消化器センター"}, {"code": 8, "name": "脳・神経センター"}, {"code": 9, "name": "循環器センター"}, {"code": 10, "name": "成育・女性医療センター"}]}', '2019-02-15 14:51:31.84', '2019-02-15 14:51:31.84')
;

-- sys_master_define(マスタ定義) のデータ追加
-- ベッドマスタ
INSERT INTO sys_master_define 
( master_physical_name
, master_name
, disp_class
, mode
, allow_sort
, allow_add_record
, disp_order
, column_info
, combo_data
, reg_date
, up_date
) VALUES(
 'mst_bed'
,'ベッドマスタ'
,'2'
,'1'
,'1'
,'1'
,10
,'{"fields": [
    {"type": "number", "alias": "code", "title": "ベッドコード", "physical_name": "bed_cd"}
  , {"type": "number", "title": "ベッド番号", "physical_name": "bed_no"}
  , {"type": "string", "alias": "name", "title": "ベッド名", "physical_name": "bed_name"}
  , {"type": "number", "title": "シャント位置", "validation": {"max": 3, "min": 0}, "physical_name": "shunt_position"}
  , {"type": "combo1", "title": "感染症フラグ", "physical_name": "is_infection"}
  , {"type": "combo1", "title": "緊急区分", "physical_name": "emergency_class"}
  , {"type": "number", "title": "装置番号", "physical_name": "machine_no"}
  , {"type": "string", "title": "出力先プリンタ名", "physical_name": "output_printer"}
  , {"type": "combo1", "title": "前体重測定時の自動印刷有無", "physical_name": "is_autoprint_before"}
  , {"type": "combo1", "title": "後体重測定時の自動印刷有無", "physical_name": "is_autoprint_after"}
  , {"type": "combo1", "title": "実績確定時の自動印刷有無", "physical_name": "is_autoprint_commit"}
  , {"type": "number", "title": "FNW+", "validation": {"max": 9999, "min": 0}, "physical_name": "fn_bed_no"}
  , {"type": "del", "title": "削除", "physical_name": "is_del"}
  , {"type": "disp", "title": "削除", "physical_name": "is_disp"}
  ]}'
,'{"combos": [
    {
     "values": [
         {"text": "感染症なし", "value": "0"}
       , {"text": "感染症あり", "value": "1"}
      ], 
    "physical_name": "is_infection"
    },
    {
     "values": [
         {"text": "通常ベッド", "value": 0}
       , {"text": "緊急用ベッド", "value": 1}
     ],
      "physical_name": "emergency_class"
    },
    {
     "values": [
         {"text": "印刷しない", "value": "0"}
       , {"text": "印刷する", "value": "1"}
     ],
      "physical_name": "is_autoprint_before"
    },
    {
     "values": [
         {"text": "印刷しない", "value": "0"}
       , {"text": "印刷する", "value": "1"}
     ],
      "physical_name": "is_autoprint_after"
    },
    {
     "values": [
         {"text": "印刷しない", "value": "0"}
       , {"text": "印刷する", "value": "1"}
     ],
      "physical_name": "is_autoprint_commit"
    }
  ]}'
,null
,null
)
;

-- クールマスタ
INSERT INTO sys_master_define 
( master_physical_name
, master_name
, disp_class
, mode
, allow_sort
, allow_add_record
, disp_order
, column_info
, combo_data
, reg_date
, up_date
) VALUES(
 'mst_kur'
,'クールマスタ'
,'2'
,'1'
,'1'
,'1'
,11
,'{"fields": [
    {"type": "number", "alias": "code", "title": "クールコード", "physical_name": "kur_cd"}
  , {"type": "string", "title": "FNW+", "validation": {"maxlength": 3}, "physical_name": "fn_kur_cd"}
  , {"type": "string", "alias": "name", "title": "クール名", "physical_name": "kur_name"}
  , {"type": "string", "title": "クール開始時刻", "validation": {"maxlength": 6}, "physical_name": "kur_start_time"}
  , {"type": "string", "title": "クール終了時刻", "validation": {"maxlength": 6}, "physical_name": "kur_end_time"}
  , {"type": "string", "title": "クール内標準治療開始時刻", "validation": {"maxlength": 6}, "physical_name": "kur_standard_start_time"}
  , {"type": "string", "title": "院内コード1", "validation": {"maxlength": 20}, "physical_name": "in_hospital_cd_1"}
  , {"type": "del", "title": "削除", "physical_name": "is_del"}
  ]}'
,null
,null
,null
)
;

-- 病棟マスタ
INSERT INTO sys_master_define 
( master_physical_name
, master_name
, disp_class
, mode
, allow_sort
, allow_add_record
, disp_order
, column_info
, combo_data
, reg_date
, up_date
) VALUES(
 'mst_ward'
,'病棟マスタ'
,'2'
,'1'
,'1'
,'1'
,12
,'{"fields": [
    {"type": "number", "alias": "code", "title": "病棟コード", "physical_name": "ward_cd"}
  , {"type": "number", "title": "FNW+", "validation": {"maxlength": 4}, "physical_name": "fn_ward_cd"}
  , {"type": "string", "alias": "name", "title": "病棟名", "physical_name": "ward_name"}
  , {"type": "string", "title": "院内コード1", "validation": {"maxlength": 20}, "physical_name": "in_hospital_cd_1"}
  , {"type": "del", "title": "削除", "physical_name": "is_del"}
  , {"type": "disp", "title": "削除", "physical_name": "is_disp"}
  ]}'
,null
,null
,null
)
;

-- 診療科マスタ
INSERT INTO sys_master_define 
( master_physical_name
, master_name
, disp_class
, mode
, allow_sort
, allow_add_record
, disp_order
, column_info
, combo_data
, reg_date
, up_date
) VALUES(
 'mst_course'
,'診療科マスタ'
,'2'
,'1'
,'1'
,'1'
,13
,'{"fields": [
    {"type": "number", "alias": "code", "title": "診療科コード", "physical_name": "course_cd"}
  , {"type": "number", "title": "FNW+", "validation": {"maxlength": 4}, "physical_name": "fn_course_cd"}
  , {"type": "string", "alias": "name", "title": "診療科名", "physical_name": "course_name"}
  , {"type": "number", "title": "標準診療科コード", "physical_name": "standard_course_cd"}
  , {"type": "string", "title": "院内コード1", "validation": {"maxlength": 20}, "physical_name": "in_hospital_cd_1"}
  , {"type": "del", "title": "削除", "physical_name": "is_del"}
  , {"type": "disp", "title": "削除", "physical_name": "is_disp"}
  ]}'
,null
,null
,null
)
;

