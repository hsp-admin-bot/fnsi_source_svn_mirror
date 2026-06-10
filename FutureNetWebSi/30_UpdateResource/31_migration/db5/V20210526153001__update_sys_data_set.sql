DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd"  = 156;

INSERT INTO "ntss"."sys_data_set" ( "sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info" )
VALUES
	( 156, 'select rst_bed_cd,rst_bed_name,rst_machine_no,rst_machine_name,rst_start_date,rst_dialysis_state
from ord_main ord 
where ord.facility_cd = @facilityCd
and rst_start_date >= @fromDate
and rst_start_date <= @toDate
and ord.rst_dialysis_state <>''0''
and rst_machine_name <>''''
order by rst_start_date desc
;', 2, 
'[{"preview": "20200407", "can_calc": "0", "data_code": "rst_start_date", "data_name": "使用日", "data_type": "string", "conv_table": [], "data_class": "装置一覧表", "field_name": "rst_start_date", "disp_format": "yyyymmdd", "data_category": "装置一覧表", "facility_table": "", "facility_filter_type": "0"}, 
{"preview": "ベットA", "can_calc": "0", "data_code": "rst_bed_name", "data_name": "ベット名", "data_type": "string", "conv_table": [], "data_class": "装置一覧表", "field_name": "rst_bed_name", "disp_format": "", "data_category": "装置一覧表", "facility_table": "", "facility_filter_type": "0"}, 
{"preview": "装置A", "can_calc": "0", "data_code": "rst_machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "装置一覧表", "field_name": "rst_machine_name", "disp_format": "", "data_category": "装置一覧表", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '@facilityCd  @fromdate  @todate', now(), now(), NULL );