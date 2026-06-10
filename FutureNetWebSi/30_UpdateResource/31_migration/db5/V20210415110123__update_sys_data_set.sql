UPDATE "ntss"."sys_data_set" SET "sql" = '			SELECT
	* 
FROM
	(SELECT		
	      content                                   -- 内容		
	    , 	CASE
			WHEN notice_start_date IS NOT NULL and notice_start_date <> '''' THEN
			date_trunc( ''day'', notice_start_date :: TIMESTAMP ) ELSE null 
		END AS notice_start_date                         -- 掲載開始日時		
	    , CASE
			WHEN notice_end_date IS NOT NULL and notice_end_date <> '''' THEN
			date_trunc( ''day'', notice_end_date :: TIMESTAMP ) ELSE null
		END AS notice_end_date                            -- 掲載終了日時		
	    , reg_staff_name                            -- 起票者名		
	    , upd_staff_name                            -- 最終更新者名		
	    , title                                     -- タイトル		
	    , 	CASE
			WHEN notice_fac_cal_start_date IS NOT NULL and notice_fac_cal_start_date <> '''' THEN
			date_trunc( ''day'', notice_fac_cal_start_date :: TIMESTAMP ) ELSE null
		END AS notice_fac_cal_start_date   -- 施設カレンダーイベント開始日付		
	    , 	CASE
			WHEN notice_fac_cal_end_date  IS NOT NULL and notice_fac_cal_end_date  <> '''' THEN
			date_trunc( ''day'', notice_fac_cal_end_date  :: TIMESTAMP ) ELSE null
		END AS notice_fac_cal_end_date                   -- 施設カレンダーイベント終了日付		
	FROM
		ntss.bbs_info 
	WHERE
		facility_cd = ''996996'' 
		AND is_disp = ''1'' 
		AND is_del = ''0'' 
	ORDER BY
		bbs_ctl_no 
	) AS bbs 	
WHERE
	bbs.notice_start_date >= date_trunc( ''day'', @fromDate :: TIMESTAMP ) 
	AND bbs.notice_end_date <= date_trunc( ''day'', @toDate :: TIMESTAMP )

', "detail" = '[{"preview": "2021/02/22", "can_calc": "0", "data_code": "notice_fac_cal_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_fac_cal_start_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/08/22", "can_calc": "0", "data_code": "notice_fac_cal_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_fac_cal_end_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/02/23", "can_calc": "0", "data_code": "notice_start_date", "data_name": "掲載開始日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_start_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/06/22", "can_calc": "0", "data_code": "notice_end_date", "data_name": "掲載終了日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_end_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "起票者１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "reg_staff_name", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "更新者１", "can_calc": "0", "data_code": "upd_staff_name", "data_name": "最終更新者", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "upd_staff_name", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "タイトル１", "can_calc": "0", "data_code": "title", "data_name": "タイトル", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "title", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容１", "can_calc": "0", "data_code": "content", "data_name": "内容", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "content", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}]'
WHERE "sql_cd" = 139;