DELETE FROM "ntss"."sys_data_set" where sql_cd in (101, 108, 109, 110, 111, 127, 262, 263, 96);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (101, 'with
machine_tbl as (
  SELECT
		mm.machine_no,
		mm.machine_type_cd,
		mm.machine_serial,
		mm.facility_cd
  FROM
    mst_machine as mm
  WHERE
    mm.machine_no in ( @machineNos )
  AND
    mm.facility_cd = @facilityCd
  AND
    mm.is_disp =''1''
  AND
    mm.is_del = ''0''
), mente_tbl as (
  SELECT
    mmr.*
  FROM
    mnt_motion_record mmr
      inner join machine_tbl as mt
        on mmr.facility_cd = mt.facility_cd
          and mmr.machine_type_cd = mt.machine_type_cd
          and mmr.machine_serial = mt.machine_serial
  WHERE
    mt.facility_cd = @facilityCd
	AND
    mmr.event_reg_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  AND
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
		  when tbl4.contents->>''65'' is null then ''''
		else ''0''
	  end as dt4_data65,

	  tbl5.event_reg_date as dt5_date,
	  tbl5.contents->>''5'' as dt5_data5,
	  case
		when tbl5.contents->>''6'' = ''0001'' then ''1''
		  when tbl5.contents->>''6'' is null then ''''
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
			when tbl6.contents->>''6'' is null then ''''
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
) a
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no)
', 2, '[{"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt1_date", "data_name": "配管自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt2_date", "data_name": "漏血テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt4_date", "data_name": "濃度自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt3_date", "data_name": "透析液流量自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt5_date", "data_name": "配管テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt6_date", "data_name": "希釈テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt7_date", "data_name": "通信共通自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt1_data47", "data_name": "配管自己診断測定結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt1_data47", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13", "can_calc": "0", "data_code": "dt1_data43", "data_name": "配管系漏れ(陰圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data43", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "dt1_data44", "data_name": "配管系漏れ(陽圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data44", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-3", "can_calc": "0", "data_code": "dt1_data48", "data_name": "除水テスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data48", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40", "can_calc": "0", "data_code": "dt1_data46", "data_name": "バランステスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data46", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "dt1_data45", "data_name": "CFフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data45", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dt1_data49", "data_name": "CF2フィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data49", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.203", "can_calc": "0", "data_code": "dt2_data53", "data_name": "赤電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data53", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.426", "can_calc": "0", "data_code": "dt2_data54", "data_name": "緑電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data54", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt4_data65", "data_name": "濃度自己診断結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt4_data65", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data63", "data_name": "B原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data63", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data64", "data_name": "A原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data64", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt3_data58", "data_name": "透析液流量測定値", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_data58", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt5_data5", "data_name": "排液判定時間", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data5", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt5_data6", "data_name": "配管テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt5_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10", "can_calc": "0", "data_code": "dt5_data7", "data_name": "給水圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data7", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "dt5_data8", "data_name": "送液圧（低）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data8", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "dt5_data9", "data_name": "送液圧（高）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data9", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt5_data10", "data_name": "濃度セル3", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data10", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "dt5_data11", "data_name": "濃度セル4", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data11", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "dt6_data4", "data_name": "B液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data4", "disp_format": "0.00", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt6_data5", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data5", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt6_data6", "data_name": "希釈テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt6_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自己診断メッセージです。", "can_calc": "0", "data_code": "dt7_message", "data_name": "通信共通自己診断測定結果", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_message", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：自己診断 @machineNos @facilityCd @fromDate @toDate使用', '2020-03-30 16:59:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (108, 'with
machine_tbl as (
	SELECT unnest(ARRAY[@machineNos]) AS machine_no
)
-- 予定
, layout_order AS (
  SELECT
    one_json ->> ''code'' as layout_cd
    , json_idx as layout_order 
	FROM
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
  AND
		master_physical_name = ''mst_mainte_layout''
)
, mainte_layout_tbl as (
  SELECT
    inf.layout_order AS mainte_layout_index,
    *
  FROM
    mst_mainte_layout as mml
	left join layout_order as inf
		on (inf.layout_cd ::text = mml.mainte_layout_cd::text)
  WHERE
    facility_cd = @facilityCd
  AND
    layout_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
	ORDER BY inf.layout_order ASC
)
, mainte_work as (
  SELECT
    *
  FROM
    mnt_mainte_main
  WHERE
		machine_no in (@machineNos)
	AND
    facility_cd = @facilityCd
	AND
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  AND
    mainte_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
	ORDER BY mainte_date
)
, mainte_tbl as (
	select
		CASE 
			WHEN mw.machine_no IS NOT NULL THEN mw.machine_no
			ELSE -1
		END AS mainte_machine_no,
		
		mt.mainte_layout_index,
		mt.mainte_layout_cd,
		mt.edition_no AS mainte_layout_edition,
		mt.layout_name,
		
		mw.mainte_no,
		mw.mainte_class,
		mw.rec_no,
		mw.mainte_date,
		mg.group_name,
		
		mw.checker_id_1,
		mw.checker_id_2,
		mw.mainte_ans_1,
		to_char(mw.up_date, ''YYYY/MM/DD'') as up_date
	from
		mainte_layout_tbl as mt
	left join mainte_work mw
		on mw.mainte_layout_cd = mt.mainte_layout_cd
		and mt.facility_cd = mw.facility_cd
	left join mst_mainte_layout_group as mg 
		on mg.mainte_layout_group_cd = mw.mainte_layout_group_cd
		and mg.facility_cd = mw.facility_cd
)
SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN (
	select * from mainte_tbl where mainte_machine_no in (@machineNos)
) a ON mt.machine_no = a.mainte_machine_no
ORDER BY a.mainte_layout_index, a.mainte_date, ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no)	
', 2, '[{"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細無し）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：日常点検　@machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (109, 'with
machine_tbl as (
	SELECT unnest(ARRAY[@machineNos]) AS machine_no
)
, layout_order AS (
  select
    one_json ->> ''code'' as layout_cd
    , json_idx as layout_order 
	from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_mainte_layout''
)
, category_order AS (
  select
    one_json ->> ''code'' as category_cd
    , json_idx as category_order 
	from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_mainte_category''
)
, detail_order AS (
  select
    one_json ->> ''code'' as detail_cd
    , json_idx as detail_order 
	from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_mainte_detail''
)
, mainte_work as (
	SELECT
		mainte_no,
		mainte_layout_cd,
		mainte_layout_edition,
		rec_no,
		mainte_date,
		checker_id_1,
		checker_id_2,
		machine_no,
		mainte_ans_1,
		mainte_comment_1,
    CAST(detail_info ->> ''cate_cd'' AS INTEGER) AS mainte_category_cd,
		CAST(detail_info ->> ''cate_edi'' AS INTEGER) AS mainte_category_edition,
    CAST(detail_info ->> ''detail_cd'' AS INTEGER) AS mainte_detail_cd,
		CAST(detail_info ->> ''detail_edi'' AS INTEGER) AS mainte_detail_edition,
		detail_info ->> ''judge'' as judge,
		detail_info ->> ''comment'' as comment,
		detail_info ->> ''user_id'' as user_id,
		detail_info ->> ''date'' as date,
		up_date
	FROM
		mnt_mainte_main
	CROSS JOIN LATERAL jsonb_array_elements(detail) detail_info
	WHERE
		machine_no in ( @machineNos )
	AND
		facility_cd = @facilityCd
	AND
		mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND
    mainte_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
	ORDER BY mainte_date
)
-- 予定
, mainte_layout_tbl as (
  SELECT
    mlo.layout_order,
    mainte_layout_cd,
		edition_no,
		layout_name
  FROM
    mst_mainte_layout as la
	LEFT JOIN layout_order AS mlo ON (mlo.layout_cd::text = la.mainte_layout_cd::text)
  WHERE
    facility_cd = @facilityCd
  AND
    layout_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
)
, mainte_tbl as (
		SELECT
		mw.machine_no AS mainte_machine_no,
		
		mw.mainte_no,
		
		mw.mainte_layout_cd,
		mw.mainte_layout_edition,
		mt.layout_name,
		
		mw.rec_no,
		mw.mainte_date,
		mw.checker_id_1,
		mw.checker_id_2,
		mw.mainte_ans_1,
		
		mco.category_order as mainte_category_idx,
		mw.mainte_category_cd,
		mw.mainte_category_edition,
		mct.category_name,

		mdo.detail_order as mainte_detail_idx,
		mw.mainte_detail_cd,
		mw.mainte_detail_edition,
		mdt.mainte_content_1,
		mdt.mainte_content_2,
		mdt.mainte_content_3,
		
		mw.judge,
		mw.comment,
		mw.user_id,
		mw.date,
		to_char(mw.up_date, ''YYYY/MM/DD'') as up_date
	FROM
		mainte_work mw
	LEFT JOIN mainte_layout_tbl as mt ON mw.mainte_layout_cd = mt.mainte_layout_cd AND mw.mainte_layout_edition = mt.edition_no 
	LEFT JOIN mst_mainte_category as mct ON mw.mainte_category_cd = mct.mainte_category_cd AND mw.mainte_category_edition = mct.edition_no 
	LEFT JOIN mst_mainte_detail as mdt ON mw.mainte_detail_cd = mdt.mainte_detail_cd AND mw.mainte_detail_edition = mdt.edition_no
	LEFT JOIN category_order as mco ON (mco.category_cd::text = mw.mainte_category_cd::text)
	LEFT JOIN detail_order as mdo ON (mdo.detail_cd::text = mw.mainte_detail_cd::text)
	WHERE
		mt.layout_name IS NOT NULL
)
-- 実績
, mainte_layout_hst as (
  SELECT
    *
  FROM
    mst_mainte_layout_hst
  WHERE
    facility_cd = @facilityCd
  AND
    layout_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
)
, mainte_hst as (
	SELECT
		mhw.machine_no AS mainte_machine_no,
		
		mhw.mainte_no,
		
		mhw.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,
		
		mhw.rec_no,
		mhw.mainte_date,
		mhw.checker_id_1,
		mhw.checker_id_2,
		mhw.mainte_ans_1,
		
		mco.category_order as mainte_category_idx,
		mhw.mainte_category_cd,
		mhw.mainte_category_edition,
		mch.category_name,

		mdo.detail_order as mainte_detail_idx,
		mhw.mainte_detail_cd,
		mhw.mainte_detail_edition,
		mdh.mainte_content_1,
		mdh.mainte_content_2,
		mdh.mainte_content_3,
		
		mhw.judge,
		mhw.comment,
		mhw.user_id,
		mhw.date,
		to_char(mhw.up_date, ''YYYY/MM/DD'') as up_date
	from
		 mainte_work mhw
	LEFT JOIN mainte_layout_hst as mlh ON mhw.mainte_layout_cd = mlh.mainte_layout_cd AND mhw.mainte_layout_edition = mlh.edition_no 
	LEFT JOIN mst_mainte_category_hst as mch ON mhw.mainte_category_cd = mch.mainte_category_cd AND mhw.mainte_category_edition = mch.edition_no 
	LEFT JOIN mst_mainte_detail_hst as mdh ON mhw.mainte_detail_cd = mdh.mainte_detail_cd AND mhw.mainte_detail_edition = mdh.edition_no
	LEFT JOIN category_order as mco ON (mco.category_cd::text = mhw.mainte_category_cd::text)
	LEFT JOIN detail_order as mdo ON (mdo.detail_cd::text = mhw.mainte_detail_cd::text)
	WHERE
		mlh.layout_name IS NOT NULL
)
, result_tbl as (
	SELECT
		CASE WHEN a.mainte_layout_cd IS NULL THEN -1
			ELSE a.mainte_machine_no END AS mainte_machine_no,
		
		a.mainte_no,
		
		la.layout_order as mainte_layout_index,
		CASE WHEN a.mainte_layout_cd IS NULL THEN la.mainte_layout_cd
			ELSE a.mainte_layout_cd END AS mainte_layout_cd,
		CASE WHEN a.mainte_layout_edition IS NULL THEN la.edition_no
			ELSE a.mainte_layout_edition END AS mainte_layout_edition,
		CASE WHEN a.layout_name IS NULL THEN la.layout_name
			ELSE a.layout_name END AS layout_name,
		
		a.rec_no,
		a.mainte_date,
		a.checker_id_1,
		a.checker_id_2,
		a.mainte_ans_1,
		
		a.mainte_category_idx,
		a.mainte_category_cd,
		a.mainte_category_edition,
		a.category_name,

		a.mainte_detail_idx,
		a.mainte_detail_cd,
		a.mainte_detail_edition,
		a.mainte_content_1,
		a.mainte_content_2,
		a.mainte_content_3,
		
		a.judge,
		a.comment,
		a.user_id,
		a.date,
		a.up_date
	FROM
		mainte_layout_tbl as la
	LEFT JOIN (
		SELECT
			*
		FROM
			mainte_hst
		UNION ALL
		SELECT
			*
		FROM
			mainte_tbl
		WHERE
			mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)
	) a ON la.mainte_layout_cd = a.mainte_layout_cd
	ORDER BY la.layout_order
)


SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN result_tbl as a ON mt.machine_no = a.mainte_machine_no
ORDER BY a.mainte_layout_index, a.mainte_date, ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_category_idx, a.mainte_detail_idx
', 2, '[{"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "group_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "合否", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "点検コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "category_cd", "data_name": "点検カテゴリコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検者", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/17", "can_calc": "0", "data_code": "date", "data_name": "個別点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "date", "disp_format": "yyyy/mm/dd", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：日常点検詳細 @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (110, 'with
machine_tbl as (
	SELECT
		machine_no,
		machine_type_cd
	FROM
		mst_machine
	WHERE 
		machine_no in (@machineNos)
	AND
		is_disp =''1''
	AND
		is_del = ''0''
)
-- 予定
, mainte_layout_group_tbl as (
	SELECT
		*
	FROM
		mst_mainte_layout_group
	WHERE
		facility_cd = @facilityCd
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, mainte_layout_tbl as (
	SELECT
		*
	FROM
		mst_mainte_layout
	WHERE
		facility_cd = @facilityCd
	AND
		layout_class = ''2''
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, mainte_work as (
	SELECT
		*
	FROM
		mnt_mainte_main
	WHERE 
		facility_cd = @facilityCd
	AND
		machine_no in (@machineNos)
	AND
		mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND
		mainte_class = ''2''
	AND
		mainte_layout_edition is null
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, mainte_tbl as (
	SELECT
		mw.machine_no AS mainte_machine_no,
		
		mw.mainte_layout_group_cd,
		mw.mainte_layout_group_edition,
		mlgt.group_name as layout_group_name,
		
		mlt.mainte_layout_cd,
		mw.mainte_layout_edition,
		mlt.layout_name,
		
		mw.mainte_no,
		mw.mainte_class,
		mw.rec_no,
		mw.mainte_date,
		mw.checker_id_1,
		mw.checker_id_2,
		mw.mainte_ans_1,
		mw.mainte_comment_1,
		mw.up_date
	FROM
		mainte_work as mw
	inner join machine_tbl as mt
		on mw.machine_no = mt.machine_no
	left join mainte_layout_group_tbl as mlgt
		on mw.mainte_layout_group_cd = mlgt.mainte_layout_group_cd
	inner join mainte_layout_tbl as mlt
		on (mlt.mainte_layout_cd::text  in (SELECT json_array_elements_text((SELECT to_json(mlgt.layout_list)))::text))
		and mt.machine_type_cd::text in (SELECT json_array_elements_text((SELECT to_json(mlt.type_info)))::text)
)
-- 実績
, mainte_layout_group_hst as (
	SELECT
		*
	FROM
		mst_mainte_layout_group_hst
	WHERE
		facility_cd = @facilityCd
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, mainte_layout_hst as (
	SELECT
		*
	FROM
		mst_mainte_layout_hst
	WHERE
		facility_cd = @facilityCd
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, mainte_hst_work as (
	SELECT
		*
	FROM
		mnt_mainte_main
	WHERE 
		facility_cd = @facilityCd
	AND
		machine_no in (@machineNos)
	AND
		mainte_date between date_trunc(''day'',@fromDate ::timestamp ) and date_trunc(''day'',@toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND
		mainte_class = ''2''
	AND
		mainte_layout_edition is not null
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, mainte_hst as (
	SELECT
		mhw.machine_no AS mainte_machine_no,
		
		mhw.mainte_layout_group_cd,
		mhw.mainte_layout_group_edition,
		mlgh.group_name as layout_group_name,
		
		mlh.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,
		
		mhw.mainte_no,
		mhw.mainte_class,
		mhw.rec_no,
		mhw.mainte_date,
		mhw.checker_id_1,
		mhw.checker_id_2,
		mhw.mainte_ans_1,		
		mhw.mainte_comment_1,
		mhw.up_date
	FROM
		mainte_hst_work mhw
	inner join machine_tbl as mt
		on mhw.machine_no = mt.machine_no
	left join mainte_layout_group_hst as mlgh
		on mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd and mhw.mainte_layout_group_edition = mlgh.edition_no
	inner join mainte_layout_hst as mlh
		on mlh.mainte_layout_cd ::text in
			(SELECT json_array_elements_text((SELECT to_json(mlgh.layout_list)))::text) and mhw.mainte_layout_edition = mlh.edition_no
		and mhw.mainte_layout_cd = mlh.mainte_layout_cd 
)

SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN (
	select
		*
	from
		mainte_tbl 
	union all
	select
		*
	from
		mainte_hst  
) a ON mt.machine_no = a.mainte_machine_no
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_date, a.layout_name
', 2, '[{"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_group_cd", "data_name": "点検レイアウトグループコード", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "mainte_layout_group_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "layout_group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "layout_group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "定期点検記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "作業中", "item": "作業中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検（詳細無し）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "checker_id_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：定期点検　@machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (111, 'with
machine_tbl as (
	SELECT
		machine_no,
		machine_type_cd
	FROM
		mst_machine
	WHERE 
		machine_no in (@machineNos)
	AND
		is_disp =''1''
	AND
		is_del = ''0''
)
, mainte_work as (
	SELECT
		mainte_no,
		mainte_layout_group_cd,
		mainte_layout_group_edition,
		mainte_layout_cd,
		mainte_layout_edition,
		rec_no,
		mainte_date,
		checker_id_1,
		checker_id_2,
		machine_no,
		mainte_ans_1,
		mainte_comment_1,
		detail_info ->> ''tableIndex'' AS tabIndex,
    CAST(detail_info ->> ''cate_cd'' AS INTEGER) AS mainte_category_cd,
		CAST(detail_info ->> ''cate_edi'' AS INTEGER) AS mainte_category_edition,
    CAST(detail_info ->> ''detail_cd'' AS INTEGER) AS mainte_detail_cd,
		CAST(detail_info ->> ''edition'' AS INTEGER) AS mainte_detail_edition,
		detail_info ->> ''judge'' as judge,
		CASE WHEN detail_info ->> ''tableIndex'' = ''1'' THEN detail_info ->> ''comment'' ELSE '''' END as header_mainte_comment_1,
		CASE WHEN detail_info ->> ''tableIndex'' = ''2'' THEN detail_info ->> ''comment'' ELSE '''' END as header_mainte_comment_2,
		detail_info ->> ''user_id'' as user_id,
		detail_info ->> ''date'' as date,
		up_date
	FROM
		mnt_mainte_main
	CROSS JOIN LATERAL jsonb_array_elements(detail) outer_arr
	CROSS JOIN LATERAL jsonb_array_elements(outer_arr) detail_info
	WHERE
		machine_no in (@machineNos)
	AND
		facility_cd = @facilityCd
	AND
		mainte_date between date_trunc(''day'', @fromDate::timestamp ) and date_trunc(''day'', @toDate::timestamp) + ''1 days - 1 milliseconds''
	AND
		mainte_class = ''2''
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
-- 予定
, mainte_tbl as (
	select
		mw.machine_no AS mainte_machine_no,
		
		mw.mainte_no,
		
		mw.mainte_layout_group_cd,
		mw.mainte_layout_group_edition,
		mlgt.group_name,
		
		mw.mainte_layout_cd,
		mw.mainte_layout_edition,
		mlt.layout_name,

		mw.rec_no,
		mw.mainte_date,
		mw.checker_id_1,
		mw.checker_id_2,
		mw.mainte_ans_1,
		mw.mainte_comment_1,
		
		mw.tabIndex,
		
		mw.mainte_category_cd,
		mw.mainte_category_edition,
		mct.category_name,
		
		mw.mainte_detail_cd,
		mw.mainte_detail_edition,
		mdt.mainte_content_1 as ment_content_1,
		mdt.mainte_content_2,
		mdt.mainte_content_3,
		
		null as judge,
		mw.header_mainte_comment_1,
		mw.header_mainte_comment_2,
		mw.user_id,
		mw.date,
		mw.up_date
	from
		mainte_work as mw
		LEFT JOIN mst_mainte_layout_group as mlgt ON mw.mainte_layout_group_cd = mlgt.mainte_layout_group_cd AND mw.mainte_layout_group_edition = mlgt.edition_no
		LEFT JOIN mst_mainte_layout as mlt ON mw.mainte_layout_cd = mlt.mainte_layout_cd AND mw.mainte_layout_edition = mlt.edition_no 
		LEFT JOIN mst_mainte_category as mct ON mw.mainte_category_cd = mct.mainte_category_cd AND mw.mainte_category_edition = mct.edition_no 
		LEFT JOIN mst_mainte_detail as mdt ON mw.mainte_detail_cd = mdt.mainte_detail_cd AND mw.mainte_detail_edition = mdt.edition_no 
)
-- 実績
, mainte_hst as (
	SELECT
		mhw.machine_no AS mainte_machine_no,
		
		mhw.mainte_no,
		
		mhw.mainte_layout_group_cd,
		mhw.mainte_layout_group_edition,
		mlgh.group_name,
		
		mhw.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,
		
		mhw.rec_no,
		mhw.mainte_date,
		mhw.checker_id_1,
		mhw.checker_id_2,
		mhw.mainte_ans_1,
		mhw.mainte_comment_1,
		
		mhw.tabIndex,

		mhw.mainte_category_cd,
		mhw.mainte_category_edition,
		mch.category_name,

		mhw.mainte_detail_cd,
		mhw.mainte_detail_edition,
		mdh.mainte_content_1 as ment_content_1,
		mdh.mainte_content_2,
		mdh.mainte_content_3,
		CASE 
			WHEN LENGTH(mhw.judge) <> 0 AND LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','' ,mhw.judge) 
			WHEN LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','')
			ELSE NULL
		END as judge,
		mhw.header_mainte_comment_1,
		mhw.header_mainte_comment_2,
		mhw.user_id,
		mhw.date,
		mhw.up_date
	from
		mainte_work as mhw
	LEFT JOIN mst_mainte_layout_group_hst as mlgh ON mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd AND mhw.mainte_layout_group_edition = mlgh.edition_no
	LEFT JOIN mst_mainte_layout_hst as mlh ON mhw.mainte_layout_cd = mlh.mainte_layout_cd AND mhw.mainte_layout_edition = mlh.edition_no 
	LEFT JOIN mst_mainte_category_hst as mch ON mhw.mainte_category_cd = mch.mainte_category_cd AND mhw.mainte_category_edition = mch.edition_no 
	LEFT JOIN mst_mainte_detail_hst as mdh ON mhw.mainte_detail_cd = mdh.mainte_detail_cd AND mhw.mainte_detail_edition = mdh.edition_no	
)

SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN (
	SELECT
		*
	FROM
		mainte_hst
	UNION ALL
	SELECT
		*
	FROM
		mainte_tbl
	WHERE
		mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)
) a ON mt.machine_no = a.mainte_machine_no
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_date, a.layout_name, a.tabindex
', 2, '[{"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "group_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "header_mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "header_mainte_comment_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "header_mainte_comment_2", "data_name": "定期交換部品記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "header_mainte_comment_2", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "定期点検詳細記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "作業中", "item": "作業中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "judge", "data_name": "確認", "data_type": "string", "conv_table": [{"code": "1,", "disp": "", "item": ""}, {"code": "1,1", "disp": "レ", "item": "レ"}, {"code": "1,2", "disp": "〇", "item": "〇"}, {"code": "1,3", "disp": "✖", "item": "✖"}, {"code": "1,4", "disp": "A", "item": "A"}, {"code": "1,5", "disp": "T", "item": "T"}, {"code": "1,6", "disp": "C", "item": "C"}, {"code": "2,", "disp": "", "item": ""}, {"code": "2,1", "disp": "交換済み", "item": "交換済み"}], "data_class": "定期点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_comment_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "category_cd", "data_name": "点検カテゴリコード", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "ment_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "ment_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準/交換部品", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準/交換部品", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1500", "can_calc": "0", "data_code": "mainte_content_3", "data_name": "交換推奨時間", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_3", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_2", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：定期点検詳細 @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (127, 'with
water_survey_type_tbl as (
  SELECT
    survey_type_cd,
    survey_type_name,
    integer_digits,
    decimal_digits
  FROM
    mst_water_survey_type
  WHERE
    facility_cd = @facilityCd
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
)
, point_order AS (
  SELECT
    one_json ->> ''code'' as point_cd
    , json_idx as point_order 
	FROM
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
  AND
		master_physical_name = ''mst_water_survey_point''
)
, water_survey_point_select as(
	SELECT
     A.*,
		 ms.point_order
  FROM
    mst_water_survey_point A
	LEFT JOIN point_order ms ON A.survey_point_cd = CAST(ms.point_cd AS numeric)
	WHERE
		facility_cd = @facilityCd
	AND
    A.is_del = ''0''
  AND
    A.is_disp = ''1''
  ORDER BY ms.point_order
)
, water_survey_point_tb as (
  SELECT
    case when mwsp.machine_no is not null then mwsp.machine_no
		else -1 end as machine_no,
    mwsp.survey_type_cd,
		mwsp.survey_point_cd,
    mwsp.point_name,
		mwsp.in_hospital_cd_1 as point_in_hospital_cd_1,
		mwsp.in_hospital_cd_2 as point_in_hospital_cd_2,
		mwsp.point_order
  FROM
    water_survey_point_select as mwsp
  WHERE
    mwsp.facility_cd = @facilityCd
  AND
    mwsp.is_disp = ''1''
  AND
    mwsp.is_del = ''0''
)
, water_survey_point_tbl as (
  select
    survey_point_cd,
    point_name,
		point_in_hospital_cd_1,
		point_in_hospital_cd_2,
    machine_no,
    survey_type_cd,
    point_order
  from
    water_survey_point_tb
  where
    machine_no in (@machineNos)
)
, water_servey_tbl as (
  select
    mws.survey_record_no,
		mws.inspection_date,
    survey_data_json ->> ''point_cd'' as point_cd,
    survey_data_json ->> ''plan'' as plan,
    survey_data_json ->> ''time'' as time,
    survey_data_json ->> ''picker'' as picker,
    survey_data_json ->> ''value'' as value,
    survey_data_json ->> ''unit'' as unit,
    survey_data_json ->> ''text'' as text,
    survey_data_json ->> ''inspector'' as inspector,
    survey_data_json ->> ''memo'' as memo
  from
    mnt_water_survey as mws
    CROSS JOIN LATERAL json_array_elements(mws.survey_data ::json) survey_data_json
		LEFT JOIN water_survey_point_tbl as wsp on CAST(wsp.survey_point_cd as TEXT) = survey_data_json ->> ''point_cd''
  where
    facility_cd = @facilityCd
  and
    inspection_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	and 
		wsp.survey_point_cd is not null	
  and
    is_disp = ''1''
  and
    is_del = ''0''
)
, inspection_date_records as (
  select
    to_char(inspection_date, ''yyyy/mm/dd'') as inspection_date 
  from
    water_servey_tbl
  group by water_servey_tbl.inspection_date
)
, cells as (
  select
    *
    ,inspection_date_records.inspection_date as inspection_date_str
  from
    water_survey_point_tbl, inspection_date_records
	where
		water_survey_point_tbl.machine_no in (@machineNos)
)
, inspection_records as (
  select
    wspt.survey_point_cd as s_p_code,
    wst.*,
	case
      when (wst.value <> '''') then 
				(CASE WHEN wst.value::numeric < (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits))::text
					WHEN wst.value::numeric = (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN ROUND(wst.value::numeric, wstt.decimal_digits)::text
				WHEN wst.value::numeric >= ROUND(wst.value::numeric, wstt.decimal_digits) AND LENGTH(SPLIT_PART(wst.value, ''.'', 2)) > wstt.decimal_digits
					THEN SPLIT_PART(wst.value, ''.'', 1) || ''.'' || TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))
				ELSE wst.value::text END) 
				|| coalesce(wst.unit, '''') 
				|| (case when (wst.text is not null and wst.text <> ''0'' and wst.text <> '''') then wst.text else '''' end)
      when (wst.memo <> '''' or wst.time <> '''' or CAST(wst.picker AS INTEGER) != 0 or CAST(wst.inspector AS INTEGER) != 0) then ''検査中''
      when (wst.text is not null and wst.text <> ''0'' and wst.text <> '''') then wst.text
      when wst.plan = ''1'' then ''〇''
      else null
    end as result
  from
    water_survey_point_tbl as wspt
      left join water_servey_tbl as wst
         on wst.point_cd = wspt.survey_point_cd ::TEXT
      left join water_survey_type_tbl as wstt
        on wspt.survey_type_cd = wstt.survey_type_cd
)

select a.* from (
	select
		cells.machine_no
		,cells.survey_type_cd
		,case
			when (cells.survey_type_cd is not null) then water_survey_type_tbl.survey_type_name
			else null
		end as survey_type_name
		,cells.point_order
		,cells.survey_point_cd
		,cells.point_name
		,cells.point_in_hospital_cd_1
		,cells.point_in_hospital_cd_2
		,cells.inspection_date_str
		,inspection_records.*
	from
		cells
		left outer join inspection_records
			on cells.survey_point_cd = inspection_records.s_p_code
			and cells.inspection_date = to_char(inspection_records.inspection_date, ''yyyy/mm/dd'')
		left outer join water_survey_type_tbl
			on cells.survey_type_cd = water_survey_type_tbl.survey_type_cd
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no), a.point_order, a.survey_type_cd, a.inspection_date_str;
', 2, '[{"preview":"1","can_calc":"0","data_code":"survey_type_cd","data_name":"水質検査種別コード","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"survey_type_cd","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"ET","can_calc":"0","data_code":"survey_type_name","data_name":"水質検査種別名","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"survey_type_name","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"survey_point_cd","data_name":"水質検査箇所コード","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"survey_point_cd","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"B原液タンク(ET)","can_calc":"0","data_code":"point_name","data_name":"水質検査箇所名","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_name","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"point_in_hospital_cd_1","data_name":"水質検査箇所連携コード1","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_in_hospital_cd_1","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"point_in_hospital_cd_2","data_name":"水質検査箇所連携コード2","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_in_hospital_cd_2","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"2025/01/24","can_calc":"0","data_code":"inspection_date_str","data_name":"検査日","data_type":"DateTime","conv_table":[],"data_class":"水質管理","field_name":"inspection_date_str","disp_format":"yyyy/mm/dd","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"200EU/mL未満","can_calc":"0","data_code":"result","data_name":"検査結果","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"result","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '水質管理：水質管理 @machineNos @facilityCd @fromDate @toDate', '2020-04-02 00:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (262, 'with
survey_type_order AS(
	SELECT
		ms.code AS survey_type_cd,
		ms.name,
		row_number() over() AS survey_type_order
	FROM
		mst_selector
	cross join lateral jsonb_to_recordset(order_settings->''items'') AS ms (code bigint, name text)
	WHERE
		facility_cd = @facilityCd
	AND
		master_physical_name = ''mst_water_survey_type''
)
, water_survey_type_tbl AS (
	SELECT
		survey_type_cd,
		survey_type_name,
		integer_digits,
		decimal_digits
	FROM
		mst_water_survey_type
	WHERE
		facility_cd = @facilityCd
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, survey_point_order AS(
	SELECT
		ms.code AS survey_point_cd,
		ms.name,
		row_number() over() AS survey_point_order
	FROM
		mst_selector
	cross join lateral jsonb_to_recordset(order_settings->''items'') AS ms (code bigint, name text)
	WHERE
		facility_cd = @facilityCd
	AND
		master_physical_name = ''mst_water_survey_point''
)
, water_survey_point_select AS(
	SELECT
		*
	FROM
		mst_water_survey_point
	WHERE
		facility_cd = @facilityCd
	AND
		is_del = ''0''
	AND
		is_disp = ''1''
)
, water_survey_point_tb AS (
	SELECT
		case
			when mwsp.machine_no is not null then mwsp.machine_no
			else -1 
		end as machine_no,
		mwsp.survey_type_cd,
		wstt.survey_type_name,
		sto.survey_type_order,
		mwsp.survey_point_cd,
		mwsp.point_name AS survey_point_name,
		mwsp.in_hospital_cd_1 AS survey_point_in_hospital_cd_1,
		mwsp.in_hospital_cd_2 AS survey_point_in_hospital_cd_2,
		ms.survey_point_order
	FROM
		water_survey_point_select AS mwsp
	LEFT JOIN water_survey_type_tbl AS wstt ON mwsp.survey_type_cd = wstt.survey_type_cd
	LEFT JOIN survey_type_order AS sto ON mwsp.survey_type_cd = sto.survey_type_cd
	LEFT JOIN survey_point_order AS ms ON mwsp.survey_point_cd = ms.survey_point_cd
	ORDER BY
		ms.survey_point_order
)
, water_survey_point_tbl as (
	SELECT
		*
	FROM
		water_survey_point_tb
	WHERE
		machine_no IN (@machineNos)
)
, water_servey_tbl AS (
	SELECT
		mws.facility_cd,
		mws.inspection_date,
		survey_data_json ->> ''point_cd'' as point_cd,
		survey_data_json ->> ''plan'' as plan,
		CASE
			WHEN survey_data_json ->> ''time'' IS NOT NULL AND survey_data_json ->> ''time'' <> ''''
			THEN (to_char(mws.inspection_date, ''YYYY-MM-DD'') || '' '' || to_char(TO_TIMESTAMP(survey_data_json ->> ''time'', ''HH24:MI''), ''HH24:MI'') || '':00'')::TIMESTAMP
			ELSE NULL
		END	as time,
		CASE
			WHEN survey_data_json ->> ''picker'' <> ''0'' THEN survey_data_json ->> ''picker''
			ELSE NULL
		END AS picker,
		survey_data_json ->> ''value'' as value,
		survey_data_json ->> ''unit'' as unit,
		survey_data_json ->> ''text'' as text,
		CASE
			WHEN survey_data_json ->> ''inspector'' <> ''0'' THEN survey_data_json ->> ''inspector''
			ELSE NULL
		END AS inspector,
		survey_data_json ->> ''memo'' as memo
	FROM
		mnt_water_survey AS mws
	CROSS JOIN LATERAL json_array_elements(mws.survey_data ::json) survey_data_json
		LEFT JOIN water_survey_point_tbl AS wsp ON CAST(wsp.survey_point_cd AS TEXT) = survey_data_json ->> ''point_cd''
	WHERE
		facility_cd = @facilityCd
	AND
		inspection_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND 
		wsp.survey_point_cd is not null	
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
select a.* from (
	SELECT
		wspt.machine_no
		
		,wspt.survey_type_order
		,wspt.survey_type_cd
		,case
			when (wspt.survey_type_cd is not null) then wstt.survey_type_name
			else null
		end as survey_type_name
		
		,wspt.survey_point_order
		,wspt.survey_point_cd
		,wspt.survey_point_name
		,wspt.survey_point_in_hospital_cd_1
		,wspt.survey_point_in_hospital_cd_2
		
		,wst.*
		,case
			when (wst.value <> '''') then 
				(CASE WHEN wst.value::numeric < (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits))::text
					WHEN wst.value::numeric = (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN ROUND(wst.value::numeric, wstt.decimal_digits)::text
				WHEN wst.value::numeric >= ROUND(wst.value::numeric, wstt.decimal_digits) AND LENGTH(SPLIT_PART(wst.value, ''.'', 2)) > wstt.decimal_digits
					THEN SPLIT_PART(wst.value, ''.'', 1) || ''.'' || TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))
				ELSE wst.value::text END) 
				|| coalesce(wst.unit, '''') 
			else null
		end as result
	FROM
		water_servey_tbl AS wst
	LEFT JOIN water_survey_point_tbl AS wspt ON wst.point_cd = wspt.survey_point_cd::TEXT
	LEFT JOIN water_survey_type_tbl AS wstt ON wspt.survey_type_cd = wstt.survey_type_cd
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no), a.survey_point_order, a.survey_type_order, a.inspection_date;
', 2, '[{"preview": "2025/01/24", "can_calc": "0", "data_code": "inspection_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "水質検査", "field_name": "inspection_date", "disp_format": "yyyy/mm/dd", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ET", "can_calc": "0", "data_code": "survey_type_name", "data_name": "水質検査種別名", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "survey_type_name", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "B原液タンク(ET)", "can_calc": "0", "data_code": "survey_point_name", "data_name": "水質検査箇所名", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "survey_point_name", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "survey_point_in_hospital_cd_1", "data_name": "水質検査箇所連携コード1", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "survey_point_in_hospital_cd_1", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "survey_point_in_hospital_cd_2", "data_name": "水質検査箇所連携コード2", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "survey_point_in_hospital_cd_2", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "plan", "data_name": "予定", "data_type": "string", "conv_table": [{"code": "0", "disp": "×", "item": "予定無し"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "水質検査", "field_name": "plan", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00:00", "can_calc": "0", "data_code": "time", "data_name": "採取時刻", "data_type": "DateTime", "conv_table": [], "data_class": "水質検査", "field_name": "time", "disp_format": "hh:mm", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "picker", "data_name": "採取者", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "picker", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200EU/mL", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "result", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未満", "can_calc": "0", "data_code": "result_flag", "data_name": "検査結果しきい値区分", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "text", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "inspector", "data_name": "検査者", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "inspector", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未満", "can_calc": "0", "data_code": "memo", "data_name": "備考", "data_type": "string", "conv_table": [], "data_class": "水質検査", "field_name": "memo", "disp_format": "", "filter_type": "WQTestType", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '水質管理：水質検査 @machineNos @facilityCd @fromDate @toDate', '2026-03-04 21:18:37.51', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (263, 'with
machine_option_tbl as (
	SELECT
		key as option_key, 
		name as option_name
	FROM 
		jsonb_to_recordset(''[{"key": "opt_1_0", "name": "予約"}, {"key": "opt_1_1", "name": "HDF/HF"}, {"key": "opt_1_2", "name": "サンプリングポート"}, {"key": "opt_1_3", "name": "透析液フィルタ種類"}, {"key": "opt_1_4", "name": "レベル調整ポンプ"}, {"key": "opt_1_5", "name": "予約"}, {"key": "opt_1_6", "name": "血圧計"}, {"key": "opt_1_7", "name": "予約"}, {"key": "opt_1_8", "name": "ブラッドボリューム計（ＢＶ）"}, {"key": "opt_1_9", "name": "透析量モニタ（ＤＤＭ）"}, {"key": "opt_1_10", "name": "BVplus"}, {"key": "opt_1_11", "name": "通信"}, {"key": "opt_1_12", "name": "自動プライミング"}, {"key": "opt_1_13", "name": "血液ポンプ（右回転）"}, {"key": "opt_1_14", "name": "クリップ式気泡検出器"}, {"key": "opt_1_15", "name": "ダイアライザ入口圧"}, {"key": "opt_2_0", "name": "シングルﾎﾟﾝﾌﾟシングルニードル"}, {"key": "opt_2_1", "name": "熱交換器"}, {"key": "opt_2_2", "name": "循環電磁弁"}, {"key": "opt_2_3", "name": "ＣＦ使用選択"}, {"key": "opt_2_4", "name": "予約"}, {"key": "opt_2_5", "name": "ＣＦ２"}, {"key": "opt_2_6", "name": "予約"}, {"key": "opt_2_7", "name": "補液ポンプ"}, {"key": "opt_2_8", "name": "増設補液ハンガー"}, {"key": "opt_2_9", "name": "熱湯薬液消毒補助ヒータユニット"}, {"key": "opt_2_10", "name": "ＣＦカード"}, {"key": "opt_2_11", "name": "オンライン補充液（透析液）"}, {"key": "opt_2_12", "name": "透析量プログラム"}, {"key": "opt_2_13", "name": "D-FAS"}, {"key": "opt_2_14", "name": "アクセス再循環"}, {"key": "opt_2_15", "name": "予備"}, {"key": "opt_3_0", "name": "予約"}, {"key": "opt_3_1", "name": "Ｂ原液ノズル洗浄ユニット"}, {"key": "opt_3_2", "name": "予約"}, {"key": "opt_3_3", "name": "予約"}, {"key": "opt_3_4", "name": "Ａ原液ノズル洗浄"}, {"key": "opt_3_5", "name": "Ｎａ注入"}, {"key": "opt_3_6", "name": "予備"}, {"key": "opt_3_7", "name": "BV除水制御"}, {"key": "opt_3_8", "name": "予備"}, {"key": "opt_3_9", "name": "予備"}, {"key": "opt_3_10", "name": "予備"}, {"key": "opt_3_11", "name": "予備"}, {"key": "opt_3_12", "name": "予備"}, {"key": "opt_3_13", "name": "予備"}, {"key": "opt_3_14", "name": "予備"}, {"key": "opt_3_15", "name": "予備"}, {"key": "opt_4_0", "name": "予備"}, {"key": "opt_4_1", "name": "予備"}, {"key": "opt_4_2", "name": "予備"}, {"key": "opt_4_3", "name": "予備"}, {"key": "opt_4_4", "name": "予備"}, {"key": "opt_4_5", "name": "予備"}, {"key": "opt_4_6", "name": "予備"}, {"key": "opt_4_7", "name": "予備"}, {"key": "opt_4_8", "name": "予備"}, {"key": "opt_4_9", "name": "予備"}, {"key": "opt_4_10", "name": "予備"}, {"key": "opt_4_11", "name": "予備"}, {"key": "opt_4_12", "name": "予備"}, {"key": "opt_4_13", "name": "予備"}, {"key": "opt_4_14", "name": "予備"}, {"key": "opt_4_15", "name": "予備"}, {"key": "opt_5_0", "name": "予備"}, {"key": "opt_5_1", "name": "予備"}, {"key": "opt_5_2", "name": "予備"}, {"key": "opt_5_3", "name": "予備"}, {"key": "opt_5_4", "name": "予備"}, {"key": "opt_5_5", "name": "予備"}, {"key": "opt_5_6", "name": "予備"}, {"key": "opt_5_7", "name": "予備"}, {"key": "opt_5_8", "name": "予備"}, {"key": "opt_5_9", "name": "予備"}, {"key": "opt_5_10", "name": "予備"}, {"key": "opt_5_11", "name": "予備"}, {"key": "opt_5_12", "name": "予備"}, {"key": "opt_5_13", "name": "予備"}, {"key": "opt_5_14", "name": "予備"}, {"key": "opt_5_15", "name": "予備"}]'') AS ms (key text, name text)
)
, machine_tbl as (
  SELECT
		mm.*,
		bed.bed_name,
		mmt.machine_type,
		dev.device_name as device_edge_name,
		(
			SELECT string_agg(opt.option_name, '', '') FROM jsonb_each_text(machine_option::jsonb)
			LEFT JOIN machine_option_tbl opt ON opt.option_key = key
			WHERE value = ''1''
		) as machine_option_select_info
  FROM
    mst_machine as mm
	LEFT JOIN mst_bed as bed on mm.machine_no = bed.machine_no and mm.facility_cd = bed.facility_cd
	LEFT JOIN mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
	LEFT JOIN mst_device_edge as dev on mm.device_edge_no = dev.device_edge_no and mm.facility_cd = dev.facility_cd
  WHERE
    mm.machine_no in ( @machineNos )
  AND
    mm.facility_cd = @facilityCd
  AND
    mm.is_disp =''1''
  AND
    mm.is_del = ''0''
)

select a.* from (
	SELECT
		facility_cd,
		machine_type_cd,
		machine_type,
		machine_serial,
		machine_name,
		machine_no,
		bed_name,
		ip_address,
		port,
		com_format_cd,
		com_type,
		device_edge_no,
		device_edge_name,
		is_ftp,
		is_va,
		is_blood_purify_use,
		setting_date,
		in_hospital_cd_1,
		in_hospital_cd_2,
		version,
		machine_option,
		machine_option_select_info,
		memo
	FROM
		machine_tbl as mt
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no)
', 2, '[{"preview":"DCS-100NX_113","can_calc":"0","data_code":"machine_name","data_name":"装置名","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"machine_name","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"BED-01","can_calc":"0","data_code":"bed_name","data_name":"ベッド名","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"bed_name","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"I7012104","can_calc":"0","data_code":"machine_serial","data_name":"製造番号","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"machine_serial","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"DCS3","can_calc":"0","data_code":"machine_type","data_name":"型式","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"machine_type","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"DCS3","can_calc":"0","data_code":"version","data_name":"バージョン","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"version","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"オフライン運用","can_calc":"0","data_code":"com_type","data_name":"通信種別","data_type":"string","conv_table":[{"code":"0","disp":"オフライン運用","item":"オフライン運用"},{"code":"1","disp":"新通信","item":"新通信"},{"code":"3","disp":"透析通信共通プロトコル","item":"透析通信共通プロトコル"}],"data_class":"基本設定","field_name":"com_type","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"P","can_calc":"0","data_code":"com_format_cd","data_name":"通信フォーマット","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"com_format_cd","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"127.0.0.1","can_calc":"0","data_code":"ip_address","data_name":"IPアドレス","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"ip_address","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"1401","can_calc":"0","data_code":"port","data_name":"ポート番号","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"port","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"DeviceEdge_1","can_calc":"0","data_code":"device_edge_name","data_name":"デバイスエッジ","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"device_edge_name","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"データ収集しない","can_calc":"0","data_code":"is_ftp","data_name":"データ収集実績","data_type":"string","conv_table":[{"code":"0","disp":"データ収集しない","item":"データ収集しない"},{"code":"1","disp":"データ収集する","item":"データ収集する"}],"data_class":"基本設定","field_name":"is_ftp","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"使用しない","can_calc":"0","data_code":"is_va","data_name":"装置ビューア使用","data_type":"string","conv_table":[{"code":"0","disp":"使用しない","item":"使用しない"},{"code":"1","disp":"使用する","item":"使用する"}],"data_class":"基本設定","field_name":"is_va","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"OFF","can_calc":"0","data_code":"is_blood_purify_use","data_name":"特殊浄化通信アプリで使用","data_type":"string","conv_table":[{"code":"0","disp":"OFF","item":"OFF"},{"code":"1","disp":"ON","item":"ON"}],"data_class":"基本設定","field_name":"is_blood_purify_use","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"2026/02/28","can_calc":"0","data_code":"setting_date","data_name":"設置日","data_type":"DateTime","conv_table":[],"data_class":"基本設定","field_name":"setting_date","disp_format":"yyyy/mm/dd","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"in_hospital_cd_1","data_name":"連携コード1","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"in_hospital_cd_1","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"2","can_calc":"0","data_code":"in_hospital_cd_2","data_name":"連携コード2","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"in_hospital_cd_2","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"メモ","can_calc":"0","data_code":"memo","data_name":"メモ","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"memo","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"HDF/HF","can_calc":"0","data_code":"machine_option_select_info","data_name":"有効オプション","data_type":"string","conv_table":[],"data_class":"オプション","field_name":"machine_option_select_info","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置情報 @machineNos @facilityCd使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
