-- dummy
DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1103001, -1103003);


-- ファイル名特定用
DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
  -1103005, -1103006, -1103007, -1103008, -1103009
);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103001, '-- SQL: -1103001 begin
-- これはdummyのSQLです。(SQL作成完了後、このコメントは削除してください)
select  
    ''01'' as detail_id,
    generate_series(1, 5) as rp_no,
    ''dummy_item_no'' as item_no,
    ''dummy_hosp_cd'' as hosp_cd,
    ''dummy_amount''as amount,
    ''dummy_unit''as unit;
-- SQL: -1103001 end

-- =========== ord =========== (SQL作成完了後、このコメントは削除してください)
-- WITH ord_medi_infos as (
-- 	--通常薬剤の実施済みの治療情報.実績：投与薬剤情報
-- 	select
--         mst_medicine.in_hospital_cd_1 as medi_cd,
-- 		round((ord_medi_info ->> ''amount'') :: numeric, 2) as medi_amount
-- 	from
-- 		ord_main
-- 		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) as ord_medi_info
-- 		LEFT JOIN mst_medicine on ord_medi_info ->> ''cd'' = mst_medicine.medicine_cd :: text
-- 		LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
-- 	where
-- 		ord_no = @ordNo
--         and ord_main.facility_cd = @facilityCd
-- 		and ord_main.is_del = ''0''
-- 		and ord_medi_info ->> ''effect_flg'' = ''1''
--         and ord_medi_info ->> ''medicine_type'' = ''1''
-- 		and mst_medicine.is_shot = ''1''
-- 	UNION
-- 	ALL
--     --調整薬剤の治療情報.実績：投与薬剤情報
-- 	select
--         mst_medicine.in_hospital_cd_1 as medi_cd,
-- 		CASE
-- 			medi_mix_info ->> ''solvent''
-- 			WHEN ''0'' THEN round(
-- 				(ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
-- 				2
-- 			)
-- 			WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
-- 		END as medi_amount
-- 	from
-- 		ord_main
-- 		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) as ord_medi_info
-- 		LEFT JOIN mst_medicine_mix on ord_medi_info ->> ''cd'' = mst_medicine_mix.medicine_mix_cd :: text
-- 		LEFT JOIN json_array_elements(mst_medicine_mix.mix_info :: json) medi_mix_info on true
-- 		LEFT JOIN mst_medicine on medi_mix_info ->> ''cd'' = mst_medicine.medicine_cd :: text
-- 	where
-- 		ord_no = @ordNo
--         and ord_main.facility_cd = @facilityCd
-- 		and ord_main.is_del = ''0''
-- 		and ord_medi_info ->> ''effect_flg'' = ''1''
-- 		and ord_medi_info ->> ''medicine_type'' = ''2''
--         and mst_medicine.is_shot = ''1''
--         and mst_medicine.is_disp = ''1''
--  )
-- SELECT
--     ROW_NUMBER() OVER(order by medi_cd) as seq_no,
--     medi_cd,
--     SUM(medi_amount) as medi_amount,
--     @ordNo as ord_no,
--     @facilityCd as facility_cd,
--     ''01'' as detail_id
-- FROM
--     ord_medi_infos
-- GROUP BY
--     medi_cd
 ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', '2025-06-05 17:06:30.883', '2025-06-05 17:06:30.883', NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103003, '-- SQL: -1103003 begin
-- これはdummyのSQLです。(SQL作成完了後、このコメントは削除してください)
select  
    ''01'' as detail_id,
    generate_series(1, 5) as rp_no;
-- SQL: -1103003 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_オーダーインデックス', '2025-07-16 14:50:48.578', '2025-07-16 14:50:48.578', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103005, 'select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_オーダーインデックス', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103006, 'select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置ヘッダー', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103007, 'select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置単位', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103008, 'select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置項目', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103009, 'select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_ファイル作成終了', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);