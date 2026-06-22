DELETE FROM sys_data_set
WHERE sql_cd IN (-427);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-427, 'select 
	''除水'' as detail_id,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''9999.99''),''9990.99'')) as e01,
	trim(to_char(ROUND(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_target'',''0''),''9990.99'') / TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0), 2),''9990.99'')) as e02,
	trim(to_char(TO_NUMBER(COALESCE(ord.rst_weight_info->>''water_removal_rst'',''0''),''9999.99''),''9990.99'')) as e03
from 
	ord_main ord
where
	ord.ord_no = @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom)経過情報（除水）', '2020-05-27 10:00:13.000', CURRENT_TIMESTAMP, NULL);