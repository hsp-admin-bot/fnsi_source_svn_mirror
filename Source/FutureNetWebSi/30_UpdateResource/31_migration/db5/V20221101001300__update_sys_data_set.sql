delete from ntss.sys_data_set where sql_cd = '2';
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2, 'select
  om.rst_start_date
  , om.rst_end_date
  , regexp_replace(date_part(''day'', date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date)) * 24 + date_part(''hour'', date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date)) || '':'' || to_char(date_part(''minute'', date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date)), ''09''), '' '', '''') as rst_date
from
  ord_main om
where
  ord_no = @ordNo
and is_del = ''0''
and rst_dialysis_state <>''0''
', 2, '[{"preview": "2011/3/12  08:21", "can_calc": "0", "data_code": "rst_start_date", "data_name": "透析開始日時", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_start_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "rst_end_date", "data_name": "透析終了日時", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_end_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:45", "can_calc": "0", "data_code": "rst_date", "data_name": "透析時間", "data_type": "", "conv_table": [], "data_class": "実績情報", "field_name": "rst_date", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 9]}', NULL, '2019-05-29 17:24:00', CURRENT_TIMESTAMP, NULL);
