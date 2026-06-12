-- =============================================================
-- fk_mongo_migration_config 全量 INSERT
-- 生成依据:
--   001-mongoDb-外键刷新分析/001-mongo-Readme.md
--   001-mongoDb-外键刷新分析/ord_main_hst.md
--   001-mongoDb-外键刷新分析/pat_main_history.md
--   001-mongoDb-外键刷新分析/pat_unique_history.md
-- 表结构:   docs/04_database.md ### 2.6 fk_mongo_migration_config
-- 生成日期: 2026-03-24
--
-- execution_order 规则:
--   100 = 基础层（只引用 mst_* / pat_personal_main / pat_group 等）
--   110 = 依赖 ord_main.ord_no 层
--   200 = DB6 テーブル引用（pat_insurance 等）
--
-- field_encoding:
--   BSON        = MongoDB 原生 BSON，直接寻址
--   JSON_STRING = 字段值是 JSON 字符串，parse→修改→stringify 后写回
--                 ord_main_hst 的所有嵌套字段均为 JSON_STRING
--
-- where_condition:
--   数组元素内兄弟字段过滤（JSON格式），NULL = 无条件
-- =============================================================

-- 统一列定义（所有 INSERT 共用）
-- (collection_name, field_path, field_encoding, ref_table_name,
--  execution_order, where_condition, enabled, remark)


-- =============================================================
-- [M-01] ind_history
-- 対応 PG テーブル: ind_history
-- 件数: 要確認（facility_cd あり）
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ind_history', 'ord_no',           'BSON', 'ord_main',          110, NULL, TRUE, NULL),
    ('ind_history', 'pat_id',           'BSON', 'pat_personal_main', 100, NULL, TRUE, NULL),
    ('ind_history', 'created_user_id',  'BSON', 'mst_user',          100, NULL, TRUE, NULL),
    ('ind_history', 'updated_user_id',  'BSON', 'mst_user',          100, NULL, TRUE, NULL)
;


-- =============================================================
-- [M-02] log_event
-- 対応 PG テーブル: log_event
-- 件数: 要確認（facility_cd あり）
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('log_event', 'mcn_type_cd', 'BSON', 'mst_machine_type', 100, NULL, TRUE, NULL),
    ('log_event', 'de_no',       'BSON', 'mst_machine',      100, NULL, TRUE, NULL),
    ('log_event', 'pat_id',      'BSON', 'pat_personal_main',100, NULL, TRUE, NULL)
;


-- =============================================================
-- [M-03] ord_main_hst
-- 対応 PG テーブル: ord_main
-- 件数: 2534（facility_cd=NKKSBR）
-- 注意: 全ての嵌套字段均为 JSON_STRING 存储
-- =============================================================

-- --- 顶层 BSON 字段 ---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'ord_no',           'BSON', 'ord_main',          110, NULL, TRUE, NULL),
    ('ord_main_hst', 'pat_id',           'BSON', 'pat_personal_main', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'ind_treatment_cd', 'BSON', 'mst_treatment',     100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_treatment_cd', 'BSON', 'mst_treatment',     100, NULL, TRUE, NULL),
    ('ord_main_hst', 'ind_kur_cd',       'BSON', 'mst_kur',           100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_kur_cd',       'BSON', 'mst_kur',           100, NULL, TRUE, NULL),
    ('ord_main_hst', 'ind_bed_cd',       'BSON', 'mst_bed',           100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_bed_cd',       'BSON', 'mst_bed',           100, NULL, TRUE, NULL),
    ('ord_main_hst', 'up_ind_user_id',   'BSON', 'mst_user',          100, NULL, TRUE, NULL),
    ('ord_main_hst', 'up_user_id',       'BSON', 'mst_user',          100, NULL, TRUE, NULL),
    ('ord_main_hst', 'ind_va_cd',        'BSON', 'mst_va',            100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_ward_cd',      'BSON', 'mst_ward',          100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_course_cd',    'BSON', 'mst_course',        100, NULL, TRUE, NULL)
;

-- --- ind_schedule_user_info（JSON_STRING） ---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'ind_schedule_user_info.ind_user_id',    'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'ind_schedule_user_info.upd_user_id',    'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'ind_schedule_user_info.ind_kur_cd_before', 'JSON_STRING', 'mst_kur', 100, NULL, TRUE,
     '值为0时表示无前次kur，刷新时跳过（pk_mapping未命中则自然跳过）')
;

-- --- rst_puncture_user_info / rst_return_user_info / rst_charge_user_info（JSON_STRING） ---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'rst_puncture_user_info.user_id_1', 'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_puncture_user_info.user_id_2', 'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_return_user_info.user_id_1',   'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_return_user_info.user_id_2',   'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_charge_user_info.user_id_1',   'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'rst_charge_user_info.user_id_2',   'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL)
;

-- --- ind_dw_user_info（JSON_STRING） ---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'ind_dw_user_info.ind_user_id', 'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL),
    ('ord_main_hst', 'ind_dw_user_info.upd_user_id', 'JSON_STRING', 'mst_user', 100, NULL, TRUE, NULL)
;

-- --- ind_cond_info（JSON_STRING / 数字 key 对象）---
-- * = 遍历所有数字字符串 key（2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25 等）
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    -- ユーザー（ind_cond_info のみ、rst_cond_info には存在しない）
    ('ord_main_hst', 'ind_cond_info.*.ind_user_id', 'JSON_STRING', 'mst_user', 100, NULL, TRUE,
     '* = 任意数字key下的 ind_user_id; ind_cond_info のみ'),
    ('ord_main_hst', 'ind_cond_info.*.upd_user_id', 'JSON_STRING', 'mst_user', 100, NULL, TRUE,
     '* = 任意数字key下的 upd_user_id; ind_cond_info のみ'),
    -- 編号 2: VA
    ('ord_main_hst', 'ind_cond_info.2.value',  'JSON_STRING', 'mst_va',       100, NULL, TRUE, '編号2 → VA'),
    -- 編号 5: ダイアライザ
    ('ord_main_hst', 'ind_cond_info.5.value',  'JSON_STRING', 'mst_dialyzer', 100, NULL, TRUE, '編号5 → ダイアライザ'),
    -- 編号 6-13: 器材
    ('ord_main_hst', 'ind_cond_info.6.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号6 → 器材'),
    ('ord_main_hst', 'ind_cond_info.7.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号7 → 器材'),
    ('ord_main_hst', 'ind_cond_info.8.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号8 → 器材'),
    ('ord_main_hst', 'ind_cond_info.9.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号9 → 器材'),
    ('ord_main_hst', 'ind_cond_info.10.value', 'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号10 → 器材'),
    ('ord_main_hst', 'ind_cond_info.11.value', 'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号11 → 器材'),
    ('ord_main_hst', 'ind_cond_info.13.value', 'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号13 → 器材'),
    -- 編号 15/19/25: 薬剤（多態FK）
    ('ord_main_hst', 'ind_cond_info.15.value', 'JSON_STRING', 'mst_medicine',     100, '{"medicine_type": 1}', TRUE, '編号15 多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'ind_cond_info.15.value', 'JSON_STRING', 'mst_medicine_mix', 100, '{"medicine_type": 2}', TRUE, '編号15 多態FK: medicine_type=2 → 調製薬剤'),
    ('ord_main_hst', 'ind_cond_info.19.value', 'JSON_STRING', 'mst_medicine',     100, '{"medicine_type": 1}', TRUE, '編号19 多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'ind_cond_info.19.value', 'JSON_STRING', 'mst_medicine_mix', 100, '{"medicine_type": 2}', TRUE, '編号19 多態FK: medicine_type=2 → 調製薬剤'),
    ('ord_main_hst', 'ind_cond_info.25.value', 'JSON_STRING', 'mst_medicine',     100, '{"medicine_type": 1}', TRUE, '編号25 多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'ind_cond_info.25.value', 'JSON_STRING', 'mst_medicine_mix', 100, '{"medicine_type": 2}', TRUE, '編号25 多態FK: medicine_type=2 → 調製薬剤')
;

-- --- rst_cond_info（JSON_STRING / 数字 key 对象、ind_user_id/upd_user_id なし）---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'rst_cond_info.2.value',  'JSON_STRING', 'mst_va',       100, NULL, TRUE, '編号2 → VA'),
    ('ord_main_hst', 'rst_cond_info.5.value',  'JSON_STRING', 'mst_dialyzer', 100, NULL, TRUE, '編号5 → ダイアライザ'),
    ('ord_main_hst', 'rst_cond_info.6.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号6 → 器材'),
    ('ord_main_hst', 'rst_cond_info.7.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号7 → 器材'),
    ('ord_main_hst', 'rst_cond_info.8.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号8 → 器材'),
    ('ord_main_hst', 'rst_cond_info.9.value',  'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号9 → 器材'),
    ('ord_main_hst', 'rst_cond_info.10.value', 'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号10 → 器材'),
    ('ord_main_hst', 'rst_cond_info.11.value', 'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号11 → 器材'),
    ('ord_main_hst', 'rst_cond_info.13.value', 'JSON_STRING', 'mst_equipment',100, NULL, TRUE, '編号13 → 器材'),
    ('ord_main_hst', 'rst_cond_info.15.value', 'JSON_STRING', 'mst_medicine',     100, '{"medicine_type": 1}', TRUE, '編号15 多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'rst_cond_info.15.value', 'JSON_STRING', 'mst_medicine_mix', 100, '{"medicine_type": 2}', TRUE, '編号15 多態FK: medicine_type=2 → 調製薬剤'),
    ('ord_main_hst', 'rst_cond_info.19.value', 'JSON_STRING', 'mst_medicine',     100, '{"medicine_type": 1}', TRUE, '編号19 多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'rst_cond_info.19.value', 'JSON_STRING', 'mst_medicine_mix', 100, '{"medicine_type": 2}', TRUE, '編号19 多態FK: medicine_type=2 → 調製薬剤'),
    ('ord_main_hst', 'rst_cond_info.25.value', 'JSON_STRING', 'mst_medicine',     100, '{"medicine_type": 1}', TRUE, '編号25 多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'rst_cond_info.25.value', 'JSON_STRING', 'mst_medicine_mix', 100, '{"medicine_type": 2}', TRUE, '編号25 多態FK: medicine_type=2 → 調製薬剤')
;

-- --- ind_medi_info（JSON_STRING 数组）---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'ind_medi_info[].cd',          'JSON_STRING', 'mst_medicine',          100, '{"medicine_type": 1}', TRUE, '多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'ind_medi_info[].cd',          'JSON_STRING', 'mst_medicine_mix',      100, '{"medicine_type": 2}', TRUE, '多態FK: medicine_type=2 → 調製薬剤'),
    ('ord_main_hst', 'ind_medi_info[].class_cd',    'JSON_STRING', 'mst_medicine_class',    100, NULL,                  TRUE, 'null または -1 の場合はスキップ'),
    ('ord_main_hst', 'ind_medi_info[].timing_cd',   'JSON_STRING', 'mst_medicate_timing',   100, NULL,                  TRUE, NULL),
    ('ord_main_hst', 'ind_medi_info[].procedure_cd','JSON_STRING', 'mst_procedure',         100, NULL,                  TRUE, NULL),
    ('ord_main_hst', 'ind_medi_info[].ind_user_id', 'JSON_STRING', 'mst_user',              100, NULL,                  TRUE, NULL),
    ('ord_main_hst', 'ind_medi_info[].upd_user_id', 'JSON_STRING', 'mst_user',              100, NULL,                  TRUE, NULL)
;

-- --- rst_medi_info（JSON_STRING 数组、ind/upd_user_id なし）---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'rst_medi_info[].cd',          'JSON_STRING', 'mst_medicine',       100, '{"medicine_type": 1}', TRUE, '多態FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'rst_medi_info[].cd',          'JSON_STRING', 'mst_medicine_mix',   100, '{"medicine_type": 2}', TRUE, '多態FK: medicine_type=2 → 調製薬剤'),
    ('ord_main_hst', 'rst_medi_info[].class_cd',    'JSON_STRING', 'mst_medicine_class', 100, NULL,                  TRUE, 'null または -1 の場合はスキップ'),
    ('ord_main_hst', 'rst_medi_info[].timing_cd',   'JSON_STRING', 'mst_medicate_timing',100, NULL,                  TRUE, NULL),
    ('ord_main_hst', 'rst_medi_info[].procedure_cd','JSON_STRING', 'mst_procedure',      100, NULL,                  TRUE, NULL)
;

-- --- ind_equip_info（JSON_STRING 数组）---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'ind_equip_info[].cd',          'JSON_STRING', 'mst_equipment', 100, '{"equip_type": 0}', TRUE, '多態FK: equip_type=0 → 器材'),
    ('ord_main_hst', 'ind_equip_info[].cd',          'JSON_STRING', 'mst_dialyzer',  100, '{"equip_type": 1}', TRUE, '多態FK: equip_type=1 → ダイアライザ'),
    ('ord_main_hst', 'ind_equip_info[].ind_user_id', 'JSON_STRING', 'mst_user',      100, NULL,                TRUE, NULL),
    ('ord_main_hst', 'ind_equip_info[].upd_user_id', 'JSON_STRING', 'mst_user',      100, NULL,                TRUE, NULL)
;

-- --- rst_equip_info（JSON_STRING 数组、ind/upd_user_id なし）---
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'rst_equip_info[].cd', 'JSON_STRING', 'mst_equipment', 100, '{"equip_type": 0}', TRUE, '多態FK: equip_type=0 → 器材'),
    ('ord_main_hst', 'rst_equip_info[].cd', 'JSON_STRING', 'mst_dialyzer',  100, '{"equip_type": 1}', TRUE, '多態FK: equip_type=1 → ダイアライザ')
;

-- --- ind_device_set_info（JSON_STRING / 任意デバイス種別 key）---
-- 構造: {"dc": {"ind_user_id": ..., "upd_user_id": ..., "dev": {...}}, "bp": {...}, ...}
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('ord_main_hst', 'ind_device_set_info.*.ind_user_id', 'JSON_STRING', 'mst_user', 100, NULL, TRUE,
     '* = 任意デバイス種別key（dc, bp, bv 等）下の ind_user_id'),
    ('ord_main_hst', 'ind_device_set_info.*.upd_user_id', 'JSON_STRING', 'mst_user', 100, NULL, TRUE,
     '* = 任意デバイス種別key（dc, bp, bv 等）下の upd_user_id')
;


-- =============================================================
-- [M-04] pat_group_detail_history
-- 対応 PG テーブル: pat_group_detail
-- 件数: 49（facility_cd=NKKSBR）
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('pat_group_detail_history', 'pat_id',       'BSON', 'pat_personal_main', 100, NULL, TRUE, NULL),
    ('pat_group_detail_history', 'pat_group_cd', 'BSON', 'pat_group',         100, NULL, TRUE, NULL)
;


-- =============================================================
-- [M-05] pat_insurance_history
-- 対応 PG テーブル: pat_insurance（DB6）
-- 件数: 94（facility_cd=NKKSBR）
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('pat_insurance_history', 'pat_id',       'BSON', 'pat_personal_main', 100, NULL, TRUE, NULL),
    ('pat_insurance_history', 'insurance_cd', 'BSON', 'pat_insurance',     200, NULL, TRUE, 'DB6 テーブル参照')
;


-- =============================================================
-- [M-06] pat_main_history
-- 対応 PG テーブル: pat_main
-- 件数: 104（facility_cd=NKKSBR）
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('pat_main_history', 'pat_id',                               'BSON', 'pat_personal_main',  100, NULL, TRUE, NULL),
    ('pat_main_history', 'addition_info[].cd',                   'BSON', 'mst_addition',        100, NULL, TRUE, NULL),
    ('pat_main_history', 'charge_staff_info[].staff_cd',         'BSON', 'mst_user',            100, NULL, TRUE, NULL),
    ('pat_main_history', 'pat_group_info[].pat_group_cd',        'BSON', 'pat_group',           100, NULL, TRUE, NULL),
    ('pat_main_history', 'taboo_allergy_info[].taboo_allergy_cd','BSON', 'mst_taboo_allergy',   100, NULL, TRUE, NULL),
    ('pat_main_history', 'infect_info[].infection_cd',           'BSON', 'mst_infection',       100, NULL, TRUE, NULL),
    ('pat_main_history', 'implant_info[].implant_cd',            'BSON', 'mst_implant',         100, NULL, TRUE, NULL)
;


-- =============================================================
-- [M-07] pat_personal_main_history
-- 対応 PG テーブル: pat_personal_main
-- 件数: 90（facility_cd=NKKSBR）
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('pat_personal_main_history', 'pat_id',                        'BSON', 'pat_personal_main',          100, NULL, TRUE, NULL),
    ('pat_personal_main_history', 'dial_diff_com_info[].dial_diff_cd', 'BSON', 'mst_dialysis_difficulty', 100, NULL, TRUE, NULL)
;


-- =============================================================
-- [M-08] pat_unique_history
-- 対応 PG テーブル: pat_unique
-- 件数: 100（facility_cd=NKKSBR）
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('pat_unique_history', 'pat_id',                                      'BSON', 'pat_personal_main', 100, NULL,                    TRUE, NULL),
    -- medical_hst_info
    ('pat_unique_history', 'medical_hst_info[].disease_cd',               'BSON', 'mst_disease',       100, NULL,                    TRUE, NULL),
    ('pat_unique_history', 'medical_hst_info[].course_cd',                'BSON', 'mst_course',        100, NULL,                    TRUE, 'null 可; course_is_free="0" の場合のみ有効（null スキップで対応）'),
    ('pat_unique_history', 'medical_hst_info[].diagnostician_cd',         'BSON', 'mst_user',          100, '{"diagnostician_is_free": "0"}', TRUE, '自由入力時はFK刷新しない'),
    -- in_out_visit_history_info
    ('pat_unique_history', 'in_out_visit_history_info[].from_doctor',     'BSON', 'mst_user',          100, '{"doctor_is_free": "0"}',       TRUE, '自由入力時はFK刷新しない'),
    ('pat_unique_history', 'in_out_visit_history_info[].to_doctor',       'BSON', 'mst_user',          100, '{"doctor_is_free": "0"}',       TRUE, '自由入力時はFK刷新しない'),
    ('pat_unique_history', 'in_out_visit_history_info[].from_course',     'BSON', 'mst_course',        100, '{"course_is_free": "0"}',       TRUE, '自由入力時はFK刷新しない'),
    ('pat_unique_history', 'in_out_visit_history_info[].to_course',       'BSON', 'mst_course',        100, '{"course_is_free": "0"}',       TRUE, '自由入力時はFK刷新しない'),
    -- physical_info
    ('pat_unique_history', 'physical_info[].indicator_cd',                'BSON', 'mst_user',          100, NULL,                    TRUE, 'null 可（担当者 user_id）'),
    ('pat_unique_history', 'physical_info[].changer_cd',                  'BSON', 'mst_user',          100, NULL,                    TRUE, '最終更新者 user_id')
;


-- =============================================================
-- [M-09] rst_history
-- facility_cd フィールドなし（全施設共通）
-- 件数: 22618
-- =============================================================
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, enabled, remark)
VALUES
    ('rst_history', 'ord_no',      'BSON', 'ord_main', 110, NULL, TRUE, NULL),
    ('rst_history', 'up_user_id',  'BSON', 'mst_user', 100, NULL, TRUE, 'up_user_id は文字列型で格納')
;
