-- =============================================================
-- fk_migration_config 全量 INSERT（COLUMN + JSON 合并版）
-- 生成依据:
--   002-Column字段主外键关联分析/002-README.md
--   003-JSON字段详细分析/（Review状态=完成）
-- 表结构:   docs/04_database.md ### 2.5 fk_migration_config
-- 生成日期: 2026-03-20
--
-- 变更说明（相比旧版）:
--   1. 去除 ref_column（由 pk_mapping 推断主键列）
--   2. 新增 where_template（多态FK条件，NULL=无条件）
--   3. id 由序列自动生成（不显式指定）
--
-- execution_order 规则:
--   10-20 = DB4
--   100   = DB5 基础层（只引用 mst_* / pat_main）
--   110   = DB5 依赖 ord_main 层
--   200   = DB6
-- =============================================================

-- 统一列定义（所有 INSERT 共用）
-- (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
-- COLUMN 型: json_column=NULL, json_path=NULL
-- JSON   型: column_name=NULL


-- =============================================================
-- COLUMN 型 FK
-- =============================================================


-- -------------------------------------------------------------
-- [C-01] NTSS_DB4: 认证与安全数据库（order=10/20）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_user_authentication', 'COLUMN', 'user_id', NULL, NULL, 'mst_user',                10, TRUE, NULL, 'DB4->DB5 跨数据库引用'),
    ('sys_signin_manager',      'COLUMN', 'user_id', NULL, NULL, 'mst_user_authentication', 20, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [C-02] NTSS_DB5 order=100: 基础层（只引用 mst_* / pat_main）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    -- bbs_info
    ('bbs_info', 'COLUMN', 'kind_no', NULL, NULL, 'mst_bbs_kind', 100, TRUE, NULL, NULL),
    ('bbs_info', 'COLUMN', 'pat_id',  NULL, NULL, 'pat_main',     100, TRUE, NULL, NULL),

    -- medicine_latest_no
    ('medicine_latest_no', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 100, TRUE, NULL, NULL),

    -- mnt_machine_state（bed_cd 仅引用 mst_bed，order=100）
    ('mnt_machine_state', 'COLUMN', 'bed_cd', NULL, NULL, 'mst_bed', 100, TRUE, NULL, NULL),

    -- mnt_mainte_main
    ('mnt_mainte_main', 'COLUMN', 'machine_no', NULL, NULL, 'mst_machine', 100, TRUE, NULL, NULL),

    -- mnt_motion_record
    ('mnt_motion_record', 'COLUMN', 'job_cd',  NULL, NULL, 'mst_job',  100, TRUE, NULL, NULL),
    ('mnt_motion_record', 'COLUMN', 'user_id', NULL, NULL, 'mst_user', 100, TRUE, NULL, NULL),

    -- mnt_notification_status
    ('mnt_notification_status', 'COLUMN', 'user_id', NULL, NULL, 'mst_user', 100, TRUE, NULL, NULL),

    -- mnt_water_survey
    ('mnt_water_survey', 'COLUMN', 'survey_point_cd', NULL, NULL, 'mst_water_survey_point', 100, TRUE, NULL, NULL),
    ('mnt_water_survey', 'COLUMN', 'survey_type_cd',  NULL, NULL, 'mst_water_survey_type',  100, TRUE, NULL, NULL),

    -- ord_checklist
    ('ord_checklist', 'COLUMN', 'checklist_cd', NULL, NULL, 'mst_checklist', 100, TRUE, NULL, NULL),
    ('ord_checklist', 'COLUMN', 'pat_id',       NULL, NULL, 'pat_main',      100, TRUE, NULL, NULL),

    -- ord_exception_period
    ('ord_exception_period', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 100, TRUE, NULL, NULL),

    -- ord_main（引用 mst_*、pat_main 及跨库 pat_insurance）
    ('ord_main', 'COLUMN', 'ind_va_cd',        NULL, NULL, 'mst_va',        100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'ind_treatment_cd', NULL, NULL, 'mst_treatment', 100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'rst_treatment_cd', NULL, NULL, 'mst_treatment', 100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'ind_kur_cd',       NULL, NULL, 'mst_kur',       100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'rst_kur_cd',       NULL, NULL, 'mst_kur',       100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'ind_bed_cd',       NULL, NULL, 'mst_bed',       100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'rst_bed_cd',       NULL, NULL, 'mst_bed',       100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'ind_dialyzer_cd',  NULL, NULL, 'mst_dialyzer',  100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'ind_disease_cd',   NULL, NULL, 'mst_disease',   100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'ind_equip_cd',     NULL, NULL, 'mst_equipment', 100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'rst_course_cd',    NULL, NULL, 'mst_course',    100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'rst_ward_cd',      NULL, NULL, 'mst_ward',      100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'pat_id',           NULL, NULL, 'pat_main',      100, TRUE, NULL, NULL),
    ('ord_main', 'COLUMN', 'insurance_cd',     NULL, NULL, 'pat_insurance', 100, TRUE, NULL, 'DB5->DB6 跨数据库引用'),

    -- pat_coop_detail
    ('pat_coop_detail', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 100, TRUE, NULL, NULL),

    -- pat_event（pat_id 在 order=100，ord_no 在 order=110）
    ('pat_event', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 100, TRUE, NULL, NULL),

    -- pat_exam_main（同上）
    ('pat_exam_main', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 100, TRUE, NULL, NULL),

    -- pat_group_detail
    ('pat_group_detail', 'COLUMN', 'pat_group_cd', NULL, NULL, 'pat_group', 100, TRUE, NULL, NULL),
    ('pat_group_detail', 'COLUMN', 'pat_id',       NULL, NULL, 'pat_main',  100, TRUE, NULL, NULL),

    -- pat_rad_main（pat_id order=100，其余 order=110）
    ('pat_rad_main', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 100, TRUE, NULL, NULL),

    -- pat_treatment_pattern
    ('pat_treatment_pattern', 'COLUMN', 'ind_treatment_cd', NULL, NULL, 'mst_treatment', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'COLUMN', 'ind_kur_cd',       NULL, NULL, 'mst_kur',       100, TRUE, NULL, NULL),

    -- pat_unique
    ('pat_unique', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [C-03] NTSS_DB5 order=110: 依赖 ord_main 层（普通FK）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    -- mni_monitor
    ('mni_monitor', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('mni_monitor', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 110, TRUE, NULL, NULL),

    -- mnt_machine_state（引用 ord_main 的字段）
    ('mnt_machine_state', 'COLUMN', 'ord_no',      NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('mnt_machine_state', 'COLUMN', 'next_ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('mnt_machine_state', 'COLUMN', 'next_kur_cd', NULL, NULL, 'mst_kur',  110, TRUE, NULL, NULL),
    ('mnt_machine_state', 'COLUMN', 'pat_id',      NULL, NULL, 'pat_main', 110, TRUE, NULL, NULL),
    ('mnt_machine_state', 'COLUMN', 'next_patid',  NULL, NULL, 'pat_main', 110, TRUE, NULL, NULL),

    -- ord_coop_no
    ('ord_coop_no', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('ord_coop_no', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 110, TRUE, NULL, NULL),

    -- ord_material_save（普通FK）
    ('ord_material_save', 'COLUMN', 'pat_id',          NULL, NULL, 'pat_main',           110, TRUE, NULL, NULL),
    ('ord_material_save', 'COLUMN', 'supplies_base_no',NULL, NULL, 'ord_main',            110, TRUE, NULL, NULL),
    ('ord_material_save', 'COLUMN', 'medicine_mix_cd', NULL, NULL, 'mst_medicine_mix',    110, TRUE, NULL, NULL),
    ('ord_material_save', 'COLUMN', 'procedure_cd',    NULL, NULL, 'mst_procedure',       110, TRUE, NULL, NULL),
    ('ord_material_save', 'COLUMN', 'timing_cd',       NULL, NULL, 'mst_medicate_timing', 110, TRUE, NULL, NULL),

    -- ord_prescription
    ('ord_prescription', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('ord_prescription', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 110, TRUE, NULL, NULL),

    -- ord_schedule
    ('ord_schedule', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('ord_schedule', 'COLUMN', 'kur_cd', NULL, NULL, 'mst_kur',  110, TRUE, NULL, NULL),
    ('ord_schedule', 'COLUMN', 'bed_cd', NULL, NULL, 'mst_bed',  110, TRUE, NULL, NULL),
    ('ord_schedule', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 110, TRUE, NULL, NULL),

    -- ord_treat_condition
    ('ord_treat_condition', 'COLUMN', 'ord_no',     NULL, NULL, 'ord_main',    110, TRUE, NULL, NULL),
    ('ord_treat_condition', 'COLUMN', 'machine_no', NULL, NULL, 'mst_machine', 110, TRUE, NULL, NULL),

    -- ord_weight_scale
    ('ord_weight_scale', 'COLUMN', 'bed_cd', NULL, NULL, 'mst_bed',  110, TRUE, NULL, NULL),
    ('ord_weight_scale', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('ord_weight_scale', 'COLUMN', 'pat_id', NULL, NULL, 'pat_main', 110, TRUE, NULL, NULL),

    -- pat_event（ord_no）
    ('pat_event', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),

    -- pat_exam_main（ord_no）
    ('pat_exam_main', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),

    -- pat_ind_approve
    ('pat_ind_approve', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),

    -- pat_ind_approve_history
    ('pat_ind_approve_history', 'COLUMN', 'ord_no', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),

    -- pat_rad_main
    ('pat_rad_main', 'COLUMN', 'cop_order_no1', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('pat_rad_main', 'COLUMN', 'cop_order_no2', NULL, NULL, 'ord_main', 110, TRUE, NULL, NULL),
    ('pat_rad_main', 'COLUMN', 'ind_user_id',   NULL, NULL, 'mst_user', 110, TRUE, NULL, NULL),
    ('pat_rad_main', 'COLUMN', 'reg_staff',     NULL, NULL, 'mst_user', 110, TRUE, NULL, NULL),
    ('pat_rad_main', 'COLUMN', 'up_staff',      NULL, NULL, 'mst_user', 110, TRUE, NULL, NULL),
    ('pat_rad_main', 'COLUMN', 'user_id',       NULL, NULL, 'mst_user', 110, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [C-04] NTSS_DB5 order=110: 多态FK（where_template 区分分支）
-- supplies_source_class: 内部枚举(0-4)，非FK，不插入
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    -- supplies_cd（多态：由 supplies_class 决定目标表）
    ('ord_material_save', 'COLUMN', 'supplies_cd', NULL, NULL, 'mst_equipment',
     110, TRUE,
     'supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'')',
     '多态FK: 器材型 → mst_equipment'),

    ('ord_material_save', 'COLUMN', 'supplies_cd', NULL, NULL, 'mst_dialyzer',
     110, TRUE,
     'supplies_class = ''01''',
     '多态FK: ダイアライザ → mst_dialyzer'),

    ('ord_material_save', 'COLUMN', 'supplies_cd', NULL, NULL, 'mst_medicine',
     110, TRUE,
     'supplies_class IN (''08'',''09'',''10'',''12'',''14'',''16'',''20'',''21'',''22'',''23'')',
     '多态FK: 通常薬剤 → mst_medicine'),

    ('ord_material_save', 'COLUMN', 'supplies_cd', NULL, NULL, 'mst_medicine_mix',
     110, TRUE,
     'supplies_class IN (''13'',''15'',''17'')',
     '多态FK: 調製薬剤 → mst_medicine_mix'),

    -- class_cd（多态：由 supplies_class 决定目标表）
    ('ord_material_save', 'COLUMN', 'class_cd', NULL, NULL, 'mst_equipment_class',
     110, TRUE,
     'supplies_class IN (''00'',''01'',''02'',''03'',''04'',''05'',''06'',''07'',''11'')',
     '多态FK: 器材型 → mst_equipment_class'),

    ('ord_material_save', 'COLUMN', 'class_cd', NULL, NULL, 'mst_medicine_class',
     110, TRUE,
     'supplies_class IN (''08'',''09'',''10'',''12'',''13'',''14'',''15'',''16'',''17'',''20'',''21'',''22'',''23'',''24'')',
     '多态FK: 薬品型 → mst_medicine_class')
;


-- -------------------------------------------------------------
-- [C-05] NTSS_DB6 order=200
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('pat_insurance',             'COLUMN', 'pat_id',       NULL, NULL, 'pat_personal_main', 200, TRUE, NULL, NULL),
    ('ord_personal_prescription', 'COLUMN', 'pat_id',       NULL, NULL, 'pat_personal_main', 200, TRUE, NULL, NULL),
    ('ord_personal_prescription', 'COLUMN', 'insurance_cd', NULL, NULL, 'pat_insurance',     200, TRUE, NULL, NULL)
;


-- =============================================================
-- JSON 型 FK
-- =============================================================


-- -------------------------------------------------------------
-- [J-01] NTSS_DB5 order=100: bbs_info.staff_info
-- 结构: {"read":[uid,...], "detail":[uid,...], "target":[uid,...]}
-- 数组中每个元素即为 user_id（整数数组，非对象数组）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('bbs_info', 'JSON', NULL, 'staff_info', '{read}',   'mst_user', 100, TRUE, NULL, '数组元素即 user_id'),
    ('bbs_info', 'JSON', NULL, 'staff_info', '{detail}', 'mst_user', 100, TRUE, NULL, '数组元素即 user_id'),
    ('bbs_info', 'JSON', NULL, 'staff_info', '{target}', 'mst_user', 100, TRUE, NULL, '数组元素即 user_id')
;


-- -------------------------------------------------------------
-- [J-02] NTSS_DB5 order=100: mnt_water_survey.survey_data
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mnt_water_survey', 'JSON', NULL, 'survey_data', '{point_cd}',  'mst_water_survey_point', 100, TRUE, NULL, NULL),
    ('mnt_water_survey', 'JSON', NULL, 'survey_data', '{picker}',    'mst_user',               100, TRUE, NULL, '检查员'),
    ('mnt_water_survey', 'JSON', NULL, 'survey_data', '{inspector}', 'mst_user',               100, TRUE, NULL, '监督员')
;


-- -------------------------------------------------------------
-- [J-03] NTSS_DB5 order=100: mst_exam_set / mst_kur
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_exam_set', 'JSON', NULL, 'exam_item_info', '{exam_item_cd}', 'mst_exam_item', 100, TRUE,  NULL, NULL),
    -- mst_kur.mst_user_authentication: 动态键结构，需自定义处理
    ('mst_kur', 'JSON', NULL, 'mst_user_authentication', '{data,user_id}',      'mst_user', 100, FALSE, NULL, '需自定义处理：data内为动态键{data,<key>,user_id}'),
    ('mst_kur', 'JSON', NULL, 'mst_user_authentication', '{data,disp_user_id}', 'mst_user', 100, FALSE, NULL, '需自定义处理：data内为动态键{data,<key>,disp_user_id}')
;


-- -------------------------------------------------------------
-- [J-04] NTSS_DB5 order=100: mst_mainte_category / mst_mainte_layout
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_mainte_category', 'JSON', NULL, 'detail',        '{code}', 'mst_mainte_detail',   100, TRUE, NULL, NULL),
    ('mst_mainte_layout',   'JSON', NULL, 'detail_info_1', '{cd}',   'mst_mainte_category', 100, TRUE, NULL, NULL),
    ('mst_mainte_layout',   'JSON', NULL, 'detail_info_2', '{cd}',   'mst_mainte_category', 100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-05] NTSS_DB5 order=100: mst_medicine_group / mst_medicine_mix
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_medicine_group', 'JSON', NULL, 'reg_medicine_info', '{cd}',      'mst_medicine',       100, TRUE, NULL, NULL),
    ('mst_medicine_group', 'JSON', NULL, 'reg_medicine_info', '{classCd}', 'mst_medicine_class', 100, TRUE, NULL, NULL),
    ('mst_medicine_mix',   'JSON', NULL, 'mix_info',          '{cd}',      'mst_medicine',       100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-06] NTSS_DB5 order=100: mst_medicine_support
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_medicine_support', 'JSON', NULL, 'detail_info', '{examItemAverage,value}', 'mst_exam_item', 100, TRUE, NULL, NULL),
    ('mst_medicine_support', 'JSON', NULL, 'detail_info', '{examItemCycling,value}', 'mst_exam_item', 100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-07] NTSS_DB5 order=100: mst_self_measure_result
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_self_measure_result', 'JSON', NULL, 'machine_info',        '{type_cd}', 'mst_machine_type', 100, FALSE, NULL, '请核实 mst_machine_type 表及其PK列名是否存在'),
    ('mst_self_measure_result', 'JSON', NULL, 'self_measure_result', '{key}',     'sys_monitor_item', 100, FALSE, NULL, '需自定义处理：JSON key 即为 FK 值')
;


-- -------------------------------------------------------------
-- [J-08] NTSS_DB5 order=100: mst_treatment / mst_trend_graph_*
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_treatment',              'JSON', NULL, 'monitor_data_item_print',  '{moni_data_no}', 'sys_monitor_item', 100, TRUE, NULL, NULL),
    ('mst_treatment',              'JSON', NULL, 'monitor_data_item_screen', '{moni_data_no}', 'sys_monitor_item', 100, TRUE, NULL, NULL),
    ('mst_trend_graph_monitor_set','JSON', NULL, 'series_info',              '{code}',         'sys_monitor_item', 100, TRUE, NULL, NULL),
    ('mst_trend_graph_template',   'JSON', NULL, 'series_info',              '{moni_cd}',      'sys_monitor_item', 100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-09] NTSS_DB5 order=100: mst_treatment_set（ind_equip_info / ind_medi_info）
-- equip_type=0 → mst_equipment, equip_type=1 → mst_dialyzer（多态FK）
-- medicine_type=1 → mst_medicine, medicine_type=2 → mst_medicine_mix（多态FK）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_treatment_set', 'JSON', NULL, 'ind_equip_info', '{cd}',
     'mst_equipment',       100, TRUE, '(ind_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_equip_info', '{cd}',
     'mst_dialyzer',        100, TRUE, '(ind_equip_info->>''equip_type'')::int = 1', '多态FK: equip_type=1'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_equip_info', '{class_cd}',
     'mst_equipment_class', 100, TRUE, '(ind_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0时有效'),

    ('mst_treatment_set', 'JSON', NULL, 'ind_medi_info', '{cd}',
     'mst_medicine',     100, TRUE, '(ind_medi_info->>''medicine_type'')::int = 1', '多态FK: medicine_type=1'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_medi_info', '{cd}',
     'mst_medicine_mix', 100, TRUE, '(ind_medi_info->>''medicine_type'')::int = 2', '多态FK: medicine_type=2'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_medi_info', '{timing_cd}',   'mst_medicate_timing', 100, TRUE, NULL, NULL),
    ('mst_treatment_set', 'JSON', NULL, 'ind_medi_info', '{procedure_cd}','mst_procedure',       100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-10] NTSS_DB5 order=100: mst_treatment_set.ind_cond_info
-- 结构: {"2":{"value":"..."},"5":{"value":"..."},...}
-- 编号15/19/25 含 medicine_type，多态FK
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{2,value}',  'mst_va',        100, TRUE, NULL, '编号2: VA血管通路'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{5,value}',  'mst_dialyzer',  100, TRUE, NULL, '编号5: ダイアライザ'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{6,value}',  'mst_equipment', 100, TRUE, NULL, '编号6: 吸着カラム'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{7,value}',  'mst_equipment', 100, TRUE, NULL, '编号7: 1次膜'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{8,value}',  'mst_equipment', 100, TRUE, NULL, '编号8: 2次膜'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{9,value}',  'mst_equipment', 100, TRUE, NULL, '编号9: 穿刺針(A針)'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{10,value}', 'mst_equipment', 100, TRUE, NULL, '编号10: 穿刺針(V針)'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{11,value}', 'mst_equipment', 100, TRUE, NULL, '编号11: 穿刺針(SN)'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{13,value}', 'mst_equipment', 100, TRUE, NULL, '编号13: 血液回路'),

    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{15,value}', 'mst_medicine',
     100, TRUE, '(ind_cond_info->''15''->>''medicine_type'')::int = 1', '编号15: 透析液 medicine_type=1'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{15,value}', 'mst_medicine_mix',
     100, TRUE, '(ind_cond_info->''15''->>''medicine_type'')::int = 2', '编号15: 透析液 medicine_type=2'),

    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{19,value}', 'mst_medicine',
     100, TRUE, '(ind_cond_info->''19''->>''medicine_type'')::int = 1', '编号19: 補液 medicine_type=1'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{19,value}', 'mst_medicine_mix',
     100, TRUE, '(ind_cond_info->''19''->>''medicine_type'')::int = 2', '编号19: 補液 medicine_type=2'),

    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{25,value}', 'mst_medicine',
     100, TRUE, '(ind_cond_info->''25''->>''medicine_type'')::int = 1', '编号25: 抗凝固剤 medicine_type=1'),
    ('mst_treatment_set', 'JSON', NULL, 'ind_cond_info', '{25,value}', 'mst_medicine_mix',
     100, TRUE, '(ind_cond_info->''25''->>''medicine_type'')::int = 2', '编号25: 抗凝固剤 medicine_type=2')
;


-- -------------------------------------------------------------
-- [J-11] NTSS_DB5 order=100: pat_main
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('pat_main', 'JSON', NULL, 'addition_info',      '{cd}',                 'mst_addition',     100, TRUE, NULL, NULL),
    ('pat_main', 'JSON', NULL, 'charge_staff_info',  '{staff_cd}',           'mst_user',         100, TRUE, NULL, NULL),
    ('pat_main', 'JSON', NULL, 'infect_info',        '{infection_cd}',       'mst_infection',    100, TRUE, NULL, NULL),
    ('pat_main', 'JSON', NULL, 'medical_care_info',  '{ward_cd}',            'mst_ward',         100, TRUE, NULL, NULL),
    ('pat_main', 'JSON', NULL, 'medical_care_info',  '{main_course_cd}',     'mst_course',       100, TRUE, NULL, NULL),
    ('pat_main', 'JSON', NULL, 'medical_care_info',  '{dialysis_course_cd}', 'mst_course',       100, TRUE, NULL, NULL),
    ('pat_main', 'JSON', NULL, 'pat_group_info',     '{patGroupCd}',         'pat_group',        100, TRUE, NULL, NULL),
    ('pat_main', 'JSON', NULL, 'taboo_allergy_info', '{taboo_allergy_cd}',   'mst_taboo_allergy',100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-12] NTSS_DB5 order=100: pat_treatment_pattern.ind_device_set_info
-- dc/na/dia/ufr/ihdf/qbqd/bvufc 各模块含 ind_user_id/upd_user_id
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{dc,ind_user_id}',    'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{dc,upd_user_id}',    'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{na,ind_user_id}',    'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{na,upd_user_id}',    'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{dia,ind_user_id}',   'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{dia,upd_user_id}',   'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{ufr,ind_user_id}',   'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{ufr,upd_user_id}',   'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{ihdf,ind_user_id}',  'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{ihdf,upd_user_id}',  'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{qbqd,ind_user_id}',  'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{qbqd,upd_user_id}',  'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{bvufc,ind_user_id}', 'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_device_set_info', '{bvufc,upd_user_id}', 'mst_user', 100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-13] NTSS_DB5 order=100: pat_treatment_pattern（ind_equip/medi/sch_info）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_equip_info', '{cd}',
     'mst_equipment',       100, TRUE, '(ind_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_equip_info', '{cd}',
     'mst_dialyzer',        100, TRUE, '(ind_equip_info->>''equip_type'')::int = 1', '多态FK: equip_type=1'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_equip_info', '{class_cd}',
     'mst_equipment_class', 100, TRUE, '(ind_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0时有效'),

    ('pat_treatment_pattern', 'JSON', NULL, 'ind_medi_info', '{cd}',
     'mst_medicine',     100, TRUE, '(ind_medi_info->>''medicine_type'')::int = 1', '多态FK: medicine_type=1'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_medi_info', '{cd}',
     'mst_medicine_mix', 100, TRUE, '(ind_medi_info->>''medicine_type'')::int = 2', '多态FK: medicine_type=2'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_medi_info', '{timing_cd}',    'mst_medicate_timing', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_medi_info', '{procedure_cd}', 'mst_procedure',       100, TRUE, NULL, NULL),

    ('pat_treatment_pattern', 'JSON', NULL, 'ind_sch_info', '{ind_bed_cd}',       'mst_bed',  100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_sch_info', '{ind_user_id}',      'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_sch_info', '{upd_user_id}',      'mst_user', 100, TRUE, NULL, NULL),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_sch_info', '{ind_kur_cd_before}','mst_kur',  100, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-14] NTSS_DB5 order=100: pat_treatment_pattern.ind_cond_info
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{2,value}',  'mst_va',        100, TRUE, NULL, '编号2: VA血管通路'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{5,value}',  'mst_dialyzer',  100, TRUE, NULL, '编号5: ダイアライザ'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{6,value}',  'mst_equipment', 100, TRUE, NULL, '编号6: 吸着カラム'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{7,value}',  'mst_equipment', 100, TRUE, NULL, '编号7: 1次膜'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{8,value}',  'mst_equipment', 100, TRUE, NULL, '编号8: 2次膜'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{9,value}',  'mst_equipment', 100, TRUE, NULL, '编号9: 穿刺針(A針)'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{10,value}', 'mst_equipment', 100, TRUE, NULL, '编号10: 穿刺針(V針)'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{11,value}', 'mst_equipment', 100, TRUE, NULL, '编号11: 穿刺針(SN)'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{13,value}', 'mst_equipment', 100, TRUE, NULL, '编号13: 血液回路'),

    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{15,value}', 'mst_medicine',
     100, TRUE, '(ind_cond_info->''15''->>''medicine_type'')::int = 1', '编号15: 透析液 medicine_type=1'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{15,value}', 'mst_medicine_mix',
     100, TRUE, '(ind_cond_info->''15''->>''medicine_type'')::int = 2', '编号15: 透析液 medicine_type=2'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{19,value}', 'mst_medicine',
     100, TRUE, '(ind_cond_info->''19''->>''medicine_type'')::int = 1', '编号19: 補液 medicine_type=1'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{19,value}', 'mst_medicine_mix',
     100, TRUE, '(ind_cond_info->''19''->>''medicine_type'')::int = 2', '编号19: 補液 medicine_type=2'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{25,value}', 'mst_medicine',
     100, TRUE, '(ind_cond_info->''25''->>''medicine_type'')::int = 1', '编号25: 抗凝固剤 medicine_type=1'),
    ('pat_treatment_pattern', 'JSON', NULL, 'ind_cond_info', '{25,value}', 'mst_medicine_mix',
     100, TRUE, '(ind_cond_info->''25''->>''medicine_type'')::int = 2', '编号25: 抗凝固剤 medicine_type=2')
;


-- -------------------------------------------------------------
-- [J-15] NTSS_DB5 order=110: ord_checklist / ord_main（addition/bvms/ind_device_set_info）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('ord_checklist', 'JSON', NULL, 'reg_staff_info', '{reg_staff_cd}', 'mst_user', 110, TRUE, NULL, NULL),

    -- ord_main: addition_info
    ('ord_main', 'JSON', NULL, 'addition_info', '{cd}', 'mst_addition', 110, TRUE, NULL, NULL),

    -- ord_main: bvms_path
    ('ord_main', 'JSON', NULL, 'bvms_path', '{ind_user_id}',     'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'bvms_path', '{reg_user_id}',     'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'bvms_path', '{create_user_id}',  'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'bvms_path', '{created_user_id}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'bvms_path', '{updated_user_id}', 'mst_user', 110, TRUE, NULL, NULL),

    -- ord_main: ind_device_set_info（dc/na/dia/ufr/ihdf/qbqd/bvufc × ind/upd_user_id）
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{dc,ind_user_id}',    'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{dc,upd_user_id}',    'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{na,ind_user_id}',    'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{na,upd_user_id}',    'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{dia,ind_user_id}',   'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{dia,upd_user_id}',   'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{ufr,ind_user_id}',   'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{ufr,upd_user_id}',   'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{ihdf,ind_user_id}',  'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{ihdf,upd_user_id}',  'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{qbqd,ind_user_id}',  'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{qbqd,upd_user_id}',  'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{bvufc,ind_user_id}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_device_set_info', '{bvufc,upd_user_id}', 'mst_user', 110, TRUE, NULL, NULL),

    -- ord_main: ind_dw_user_info
    ('ord_main', 'JSON', NULL, 'ind_dw_user_info', '{ind_user_id}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_dw_user_info', '{upd_user_id}', 'mst_user', 110, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-16] NTSS_DB5 order=110: ord_main（ind_equip_info / ind_medi_info）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('ord_main', 'JSON', NULL, 'ind_equip_info', '{cd}',
     'mst_equipment',       110, TRUE, '(ind_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0'),
    ('ord_main', 'JSON', NULL, 'ind_equip_info', '{cd}',
     'mst_dialyzer',        110, TRUE, '(ind_equip_info->>''equip_type'')::int = 1', '多态FK: equip_type=1'),
    ('ord_main', 'JSON', NULL, 'ind_equip_info', '{class_cd}',
     'mst_equipment_class', 110, TRUE, '(ind_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0时有效'),
    ('ord_main', 'JSON', NULL, 'ind_equip_info', '{ind_user_id}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_equip_info', '{upd_user_id}', 'mst_user', 110, TRUE, NULL, NULL),

    ('ord_main', 'JSON', NULL, 'ind_medi_info', '{cd}',
     'mst_medicine',     110, TRUE, '(ind_medi_info->>''medicine_type'')::int = 1', '多态FK: medicine_type=1'),
    ('ord_main', 'JSON', NULL, 'ind_medi_info', '{cd}',
     'mst_medicine_mix', 110, TRUE, '(ind_medi_info->>''medicine_type'')::int = 2', '多态FK: medicine_type=2'),
    ('ord_main', 'JSON', NULL, 'ind_medi_info', '{class_cd}',     'mst_medicine_class',  110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_medi_info', '{timing_cd}',    'mst_medicate_timing', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_medi_info', '{procedure_cd}', 'mst_procedure',       110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_medi_info', '{ind_user_id}',  'mst_user',            110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_medi_info', '{upd_user_id}',  'mst_user',            110, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-17] NTSS_DB5 order=110: ord_main（rst_* 系列）
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    -- ind_schedule_user_info
    ('ord_main', 'JSON', NULL, 'ind_schedule_user_info', '{ind_user_id}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'ind_schedule_user_info', '{upd_user_id}', 'mst_user', 110, TRUE, NULL, NULL),

    -- rst_charge_user_info
    ('ord_main', 'JSON', NULL, 'rst_charge_user_info', '{user_id_1}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_charge_user_info', '{user_id_2}', 'mst_user', 110, TRUE, NULL, NULL),

    -- rst_complaint_info
    ('ord_main', 'JSON', NULL, 'rst_complaint_info', '{comp_cd}', 'mst_complaint', 110, TRUE, NULL, NULL),

    -- rst_equip_info（多态FK，同 ind_equip_info）
    ('ord_main', 'JSON', NULL, 'rst_equip_info', '{cd}',
     'mst_equipment',       110, TRUE, '(rst_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0'),
    ('ord_main', 'JSON', NULL, 'rst_equip_info', '{cd}',
     'mst_dialyzer',        110, TRUE, '(rst_equip_info->>''equip_type'')::int = 1', '多态FK: equip_type=1'),
    ('ord_main', 'JSON', NULL, 'rst_equip_info', '{class_cd}',
     'mst_equipment_class', 110, TRUE, '(rst_equip_info->>''equip_type'')::int = 0', '多态FK: equip_type=0时有效'),
    ('ord_main', 'JSON', NULL, 'rst_equip_info', '{ind_user_id}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_equip_info', '{upd_user_id}', 'mst_user', 110, TRUE, NULL, NULL),

    -- rst_medi_info（无多态，固定指向 mst_medicine）
    ('ord_main', 'JSON', NULL, 'rst_medi_info', '{cd}',             'mst_medicine',        110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_medi_info', '{class_cd}',       'mst_medicine_class',  110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_medi_info', '{timing_cd}',      'mst_medicate_timing', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_medi_info', '{procedure_cd}',   'mst_procedure',       110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_medi_info', '{effect_user_id}', 'mst_user',            110, TRUE, NULL, NULL),

    -- rst_puncture_user_info
    ('ord_main', 'JSON', NULL, 'rst_puncture_user_info', '{user_id_1}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_puncture_user_info', '{user_id_2}', 'mst_user', 110, TRUE, NULL, NULL),

    -- rst_return_user_info
    ('ord_main', 'JSON', NULL, 'rst_return_user_info', '{user_id_1}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_return_user_info', '{user_id_2}', 'mst_user', 110, TRUE, NULL, NULL),

    -- rst_rounds_info
    ('ord_main', 'JSON', NULL, 'rst_rounds_info', '{ind_user_id}',     'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_rounds_info', '{reg_user_id}',     'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_rounds_info', '{created_user_id}', 'mst_user', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_rounds_info', '{updated_user_id}', 'mst_user', 110, TRUE, NULL, NULL),

    -- rst_tare_info
    ('ord_main', 'JSON', NULL, 'rst_tare_info', '{wheel_chair_cd}', 'mst_wheel_chair', 110, TRUE, NULL, NULL),

    -- rst_treat_staff_info
    ('ord_main', 'JSON', NULL, 'rst_treat_staff_info', '{treat_staff_cd}', 'mst_user', 110, TRUE, NULL, NULL),

    -- rst_treatment_info
    ('ord_main', 'JSON', NULL, 'rst_treatment_info', '{treat_cd}',          'mst_comp_treatment', 110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_treatment_info', '{procedure_cd}',      'mst_procedure',      110, TRUE, NULL, NULL),
    ('ord_main', 'JSON', NULL, 'rst_treatment_info', '{treat_medicine_cd}', 'mst_medicine',       110, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-18] NTSS_DB5 order=110: ord_main.ind_cond_info
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{2,value}',  'mst_va',        110, TRUE, NULL, '编号2: VA血管通路'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{5,value}',  'mst_dialyzer',  110, TRUE, NULL, '编号5: ダイアライザ'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{6,value}',  'mst_equipment', 110, TRUE, NULL, '编号6: 吸着カラム'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{7,value}',  'mst_equipment', 110, TRUE, NULL, '编号7: 1次膜'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{8,value}',  'mst_equipment', 110, TRUE, NULL, '编号8: 2次膜'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{9,value}',  'mst_equipment', 110, TRUE, NULL, '编号9: 穿刺針(A針)'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{10,value}', 'mst_equipment', 110, TRUE, NULL, '编号10: 穿刺針(V針)'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{11,value}', 'mst_equipment', 110, TRUE, NULL, '编号11: 穿刺針(SN)'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{13,value}', 'mst_equipment', 110, TRUE, NULL, '编号13: 血液回路'),

    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{15,value}', 'mst_medicine',
     110, TRUE, '(ind_cond_info->''15''->>''medicine_type'')::int = 1', '编号15: 透析液 medicine_type=1'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{15,value}', 'mst_medicine_mix',
     110, TRUE, '(ind_cond_info->''15''->>''medicine_type'')::int = 2', '编号15: 透析液 medicine_type=2'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{19,value}', 'mst_medicine',
     110, TRUE, '(ind_cond_info->''19''->>''medicine_type'')::int = 1', '编号19: 補液 medicine_type=1'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{19,value}', 'mst_medicine_mix',
     110, TRUE, '(ind_cond_info->''19''->>''medicine_type'')::int = 2', '编号19: 補液 medicine_type=2'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{25,value}', 'mst_medicine',
     110, TRUE, '(ind_cond_info->''25''->>''medicine_type'')::int = 1', '编号25: 抗凝固剤 medicine_type=1'),
    ('ord_main', 'JSON', NULL, 'ind_cond_info', '{25,value}', 'mst_medicine_mix',
     110, TRUE, '(ind_cond_info->''25''->>''medicine_type'')::int = 2', '编号25: 抗凝固剤 medicine_type=2')
;


-- -------------------------------------------------------------
-- [J-19] NTSS_DB5 order=110: ord_material_save / ord_prescription / pat_* / pat_rad_main
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    -- ord_material_save: receipt_conversion（cd → mst_medicine，已由 MD 文件确认）
    ('ord_material_save', 'JSON', NULL, 'receipt_conversion', '{cd}', 'mst_medicine', 110, TRUE, NULL, NULL),

    -- ord_prescription: prescription_detail（medicine_cd 多态FK）
    ('ord_prescription', 'JSON', NULL, 'prescription_detail', '{medicine_cd}', 'mst_medicine',
     110, TRUE, '(prescription_detail->>''medicine_type'')::int = 1', '多态FK: medicine_type=1'),
    ('ord_prescription', 'JSON', NULL, 'prescription_detail', '{medicine_cd}', 'mst_medicine_mix',
     110, TRUE, '(prescription_detail->>''medicine_type'')::int = 2', '多态FK: medicine_type=2'),

    -- pat_event
    ('pat_event', 'JSON', NULL, 'letter_info',    '{report_cd}',    'mst_report', 110, TRUE, NULL, NULL),
    ('pat_event', 'JSON', NULL, 'reg_staff_info', '{reg_staff_cd}', 'mst_user',   110, TRUE, NULL, NULL),
    ('pat_event', 'JSON', NULL, 'result_params',  '{va_cd}',        'mst_va',     110, TRUE, NULL, 'format_class=2 时有效'),
    ('pat_event', 'JSON', NULL, 'up_staff_info',  '{up_staff_cd}',  'mst_user',   110, TRUE, NULL, NULL),

    -- pat_exam_main
    ('pat_exam_main', 'JSON', NULL, 'exam_order_info',     '{set_cd}',  'mst_exam_set',  110, TRUE, NULL, NULL),
    ('pat_exam_main', 'JSON', NULL, 'exam_order_info',     '{item_cd}', 'mst_exam_item', 110, TRUE, NULL, NULL),
    ('pat_exam_main', 'JSON', NULL, 'exam_result_info',    '{item_cd}', 'mst_exam_item', 110, TRUE, NULL, NULL),
    ('pat_exam_main', 'JSON', NULL, 'order_exam_set_info', '{set_cd}',  'mst_exam_set',  110, TRUE, NULL, NULL),

    -- pat_rad_main
    ('pat_rad_main', 'JSON', NULL, 'order_rad_set_info', '{rad_set_cd}', 'mst_rad_set', 110, TRUE, NULL, NULL)
;


-- -------------------------------------------------------------
-- [J-20] NTSS_DB6 order=200: pat_insurance / ord_personal_prescription / pat_personal_main
-- -------------------------------------------------------------
INSERT INTO fk_migration_config
    (table_name, fk_type, column_name, json_column, json_path, ref_table, execution_order, enabled, where_template, remark)
VALUES
    -- pat_insurance.insu_set_info（自引用）
    ('pat_insurance', 'JSON', NULL, 'insu_set_info', '{insu_cd}',      'pat_insurance', 200, TRUE, NULL, '自引用'),
    ('pat_insurance', 'JSON', NULL, 'insu_set_info', '{insu_pub1_cd}', 'pat_insurance', 200, TRUE, NULL, '自引用'),
    ('pat_insurance', 'JSON', NULL, 'insu_set_info', '{insu_pub2_cd}', 'pat_insurance', 200, TRUE, NULL, '自引用'),
    ('pat_insurance', 'JSON', NULL, 'insu_set_info', '{insu_pub3_cd}', 'pat_insurance', 200, TRUE, NULL, '自引用'),
    ('pat_insurance', 'JSON', NULL, 'insu_set_info', '{insu_pub4_cd}', 'pat_insurance', 200, TRUE, NULL, '自引用'),

    -- ord_personal_prescription.insu_set_info
    ('ord_personal_prescription', 'JSON', NULL, 'insu_set_info', '{insu_cd}',      'pat_insurance', 200, TRUE, NULL, 'insu_class=0时有效'),
    ('ord_personal_prescription', 'JSON', NULL, 'insu_set_info', '{insu_pub1_cd}', 'pat_insurance', 200, TRUE, NULL, 'insu_class=1时有效'),
    ('ord_personal_prescription', 'JSON', NULL, 'insu_set_info', '{insu_pub2_cd}', 'pat_insurance', 200, TRUE, NULL, 'insu_class=1时有效'),
    ('ord_personal_prescription', 'JSON', NULL, 'insu_set_info', '{insu_pub3_cd}', 'pat_insurance', 200, TRUE, NULL, 'insu_class=1时有效'),
    ('ord_personal_prescription', 'JSON', NULL, 'insu_set_info', '{insu_pub4_cd}', 'pat_insurance', 200, TRUE, NULL, 'insu_class=1时有效'),

    -- pat_personal_main
    ('pat_personal_main', 'JSON', NULL, 'dial_diff_com_info', '{dial_diff_cd}', 'mst_dialysis_difficulty', 200, TRUE, NULL, NULL),
    ('pat_personal_main', 'JSON', NULL, 'other_contact_info', '{relation_cd}',  'mst_relationship',        200, TRUE, NULL, NULL)
;


-- =============================================================
-- 统计: 合计 277 行
--   COLUMN 型:  82 行（id  1 ~  82）
--     DB4 order=10/20 :  2 行
--     DB5 order=100   : 36 行
--     DB5 order=110   : 35 行（普通）+ 6 行（多态）= 41 行
--     DB6 order=200   :  3 行
--   JSON 型:   195 行（id 83 ~ 277）
--     DB5 order=100   : 93 行
--     DB5 order=110   : 90 行
--     DB6 order=200   : 12 行
--
-- 跳过项（不生成 INSERT）:
--   sys_function / sys_function_advanced 引用 → 不参与外键刷新
--   facility_cd → 多租户ID，不参与外键刷新
--   supplies_source_class → 内部枚举(0-4)，非FK
-- =============================================================
