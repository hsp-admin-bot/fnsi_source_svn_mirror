DELETE FROM "ntss"."sys_data_set" where sql_cd in (101);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (101, 'with machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no in ( @machineNos )
  and
    is_disp =''1''
  and
    is_del = ''0''

), mente_tbl as (
  select
    mmr.*
  from
    mnt_motion_record mmr
      inner join machine_tbl as mt
        on mmr.facility_cd = mt.facility_cd
          and mmr.machine_type_cd = mt.machine_type_cd
          and mmr.machine_serial = mt.machine_serial
  where
    mmr.event_reg_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    mmr.data_type = 4

), mente_tbl1 as (
  select
		ROW_NUMBER() OVER (PARTITION BY machine_type_cd, machine_serial ORDER BY event_reg_date DESC) AS idx,
    *
  from
    mente_tbl
  where
    test_type = 1
  order by
    event_reg_date desc
), mente_tbl2 as (
  select
		ROW_NUMBER() OVER (PARTITION BY machine_type_cd, machine_serial ORDER BY event_reg_date DESC) AS idx,
    *
  from
    mente_tbl
  where
    test_type = 2
  order by
    event_reg_date desc
), mente_tbl3 as (
  select
		ROW_NUMBER() OVER (PARTITION BY machine_type_cd, machine_serial ORDER BY event_reg_date DESC) AS idx,
    *
  from
    mente_tbl
  where
    test_type = 3
  order by
    event_reg_date desc
), mente_tbl4 as (
  select
    ROW_NUMBER() OVER (PARTITION BY machine_type_cd, machine_serial ORDER BY event_reg_date DESC) AS idx,
		*
  from
    mente_tbl
  where
    test_type = 4
  order by
    event_reg_date desc
), mente_tbl5 as (
  select
    ROW_NUMBER() OVER (PARTITION BY machine_type_cd, machine_serial ORDER BY event_reg_date DESC) AS idx,
		*
  from
    mente_tbl
  where
    test_type = 5
  order by
    event_reg_date desc
), mente_tbl6 as (
  select
    ROW_NUMBER() OVER (PARTITION BY machine_type_cd, machine_serial ORDER BY event_reg_date DESC) AS idx,
		*
  from
    mente_tbl
  where
    test_type = 6
  order by
    event_reg_date desc
), mente_tbl7 as (
  select
    ROW_NUMBER() OVER (PARTITION BY machine_type_cd, machine_serial ORDER BY event_reg_date DESC) AS idx,
		*
  from
    mente_tbl
  where
    test_type = 7
  order by
    event_reg_date desc
)

select a.* from (
	select
	  mt.machine_no,
	  mt.machine_type,
	  mt.com_format_cd,
	  mt.setting_date,
		mt.machine_name,
		mt.machine_serial,
	  tbl1.event_reg_date as dt1_date,
	  tbl1.contents->>''43'' as dt1_data43,
	  tbl1.contents->>''44'' as dt1_data44,
	  tbl1.contents->>''45'' as dt1_data45,
	  tbl1.contents->>''46'' as dt1_data46,
	  case
		when tbl1.contents->>''47'' in (''0001'', ''0201'', ''0301'') then ''1''
		  when tbl1.contents->>''47'' is null then ''''
		else ''0''
	  end as dt1_data47,
	  tbl1.contents->>''48'' as dt1_data48,
	  tbl1.contents->>''49'' as dt1_data49,

	  tbl2.event_reg_date as dt2_date,
	  tbl2.contents->>''53'' as dt2_data53,
	  tbl2.contents->>''54'' as dt2_data54,

	  tbl3.event_reg_date as dt3_date,
	  tbl3.contents->>''58'' as dt3_data58,

	  tbl4.event_reg_date as dt4_date,
	  tbl4.contents->>''63'' as dt4_data63,
	  tbl4.contents->>''64'' as dt4_data64,
	  case
		when tbl4.contents->>''65'' in (''3001'', ''3101'') then ''1''
		  when tbl1.contents->>''65'' is null then ''''
		else ''0''
	  end as dt4_data65,

	  tbl5.event_reg_date as dt5_date,
	  tbl5.contents->>''5'' as dt5_data5,
	  case
		when tbl5.contents->>''6'' = ''0001'' then ''1''
		  when tbl1.contents->>''6'' is null then ''''
		else ''0''
	  end as dt5_data6,
	  tbl5.contents->>''7'' as dt5_data7,
	  tbl5.contents->>''8'' as dt5_data8,
	  tbl5.contents->>''9'' as dt5_data9,
	  tbl5.contents->>''10'' as dt5_data10,
	  tbl5.contents->>''11'' as dt5_data11,

	  tbl6.event_reg_date as dt6_date,
	  tbl6.contents->>''4'' as dt6_data4,
	  tbl6.contents->>''5'' as dt6_data5,
	  case
		when tbl6.contents->>''6'' = ''3001'' then ''1''
			when tbl1.contents->>''6'' is null then ''''
		else ''0''
	  end as dt6_data6,

	  tbl7.event_reg_date as dt7_date,
	  tbl7.machine_record_message as dt7_message

	from
	  machine_tbl as mt
	   left join mente_tbl1 as tbl1
		 on mt.facility_cd = tbl1.facility_cd
		   and mt.machine_type_cd = tbl1.machine_type_cd
		   and mt.machine_serial = tbl1.machine_serial
			 and tbl1.idx = 1
	   left join mente_tbl2 as tbl2
		 on mt.facility_cd = tbl2.facility_cd
		   and mt.machine_type_cd = tbl2.machine_type_cd
		   and mt.machine_serial = tbl2.machine_serial
			 and tbl2.idx = 1
	   left join mente_tbl3 as tbl3
		 on mt.facility_cd = tbl3.facility_cd
		   and mt.machine_type_cd = tbl3.machine_type_cd
		   and mt.machine_serial = tbl3.machine_serial
			 and tbl3.idx = 1
	   left join mente_tbl4 as tbl4
		 on mt.facility_cd = tbl4.facility_cd
		   and mt.machine_type_cd = tbl4.machine_type_cd
		   and mt.machine_serial = tbl4.machine_serial
			 and tbl4.idx = 1
	   left join mente_tbl5 as tbl5
		 on mt.facility_cd = tbl5.facility_cd
		   and mt.machine_type_cd = tbl5.machine_type_cd
		   and mt.machine_serial = tbl5.machine_serial
			 and tbl5.idx = 1
	   left join mente_tbl6 as tbl6
		 on mt.facility_cd = tbl6.facility_cd
		   and mt.machine_type_cd = tbl6.machine_type_cd
		   and mt.machine_serial = tbl6.machine_serial
			 and tbl6.idx = 1
	   left join mente_tbl7 as tbl7
		 on mt.facility_cd = tbl7.facility_cd
		   and mt.machine_type_cd = tbl7.machine_type_cd
		   and mt.machine_serial = tbl7.machine_serial
			 and tbl7.idx = 1
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no )', 2, '[{"preview": "2313", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS3", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt1_date", "data_name": "配管自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt2_date", "data_name": "漏血テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt4_date", "data_name": "濃度自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt3_date", "data_name": "透析液流量自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt5_date", "data_name": "配管テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt6_date", "data_name": "希釈テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt7_date", "data_name": "通信共通自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/01", "can_calc": "0", "data_code": "setting_date", "data_name": "設置日", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "setting_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt1_data47", "data_name": "配管自己診断測定結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt1_data47", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13", "can_calc": "0", "data_code": "dt1_data43", "data_name": "配管系漏れ(陰圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data43", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "dt1_data44", "data_name": "配管系漏れ(陽圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data44", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-3", "can_calc": "0", "data_code": "dt1_data48", "data_name": "除水テスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data48", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40", "can_calc": "0", "data_code": "dt1_data46", "data_name": "バランステスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data46", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "dt1_data45", "data_name": "CFフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data45", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dt1_data49", "data_name": "CFsフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data49", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.203", "can_calc": "0", "data_code": "dt2_data53", "data_name": "赤電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data53", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.426", "can_calc": "0", "data_code": "dt2_data54", "data_name": "緑電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data54", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt4_data65", "data_name": "濃度自己診断結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt4_data65", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data63", "data_name": "B原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data63", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data64", "data_name": "A原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data64", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt3_data58", "data_name": "透析液流量測定値", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_data58", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt5_data5", "data_name": "排液判定時間", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data5", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt5_data6", "data_name": "配管テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt5_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10", "can_calc": "0", "data_code": "dt5_data7", "data_name": "給水圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data7", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "dt5_data8", "data_name": "送液圧（低）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data8", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "dt5_data9", "data_name": "送液圧（高）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data9", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt5_data10", "data_name": "濃度セル3", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data10", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "dt5_data11", "data_name": "濃度セル4", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data11", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "dt6_data4", "data_name": "B液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data4", "disp_format": "0.00", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt6_data5", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data5", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt6_data6", "data_name": "希釈テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt6_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自己診断メッセージです。", "can_calc": "0", "data_code": "dt7_message", "data_name": "通信共通自己診断測定結果", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_message", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '装置保守：自己診断　@machineNos @fromDate @toDate使用', '2020-03-30 16:59:00', CURRENT_TIMESTAMP, NULL);
