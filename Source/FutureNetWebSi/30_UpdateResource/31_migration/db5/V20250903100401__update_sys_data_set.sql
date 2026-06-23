DELETE FROM "ntss"."sys_data_set" where sql_cd in (97,101,109,117);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (97, 'with dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = @facilityCd
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''
),
equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = @facilityCd
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
),
equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = @facilityCd
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''
),
dialyzer AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
	),
	equipment AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
	),
	equipment_class AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
	),
	 ord_tbl as (
  select
    facility_cd,
		json_idx,
    to_date(treat_date, ''yyyymmdd'') as treat_date,

    info->>''class_cd'' as class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,

    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no
    ,ord_no
  from
    ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( rst_equip_info ) WITH ORDINALITY AS tmp ( info, json_idx )

  where
    ord_no in ( @ordNos ) and is_del = ''0'' and rst_dialysis_state <> ''0''
)


(select
	1 AS dis_order,
  ord.*,
  dia.model_number as equip_name,
	-1 AS equip_class_cd,
  dia.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  dia.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  dia.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  dia.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  null as equip_unit,
  null as equip_class_name,
  null as equip_class_type,
	diaz.code_order as code_order,
	null as class_order

from
  ord_tbl as ord
  inner join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
	LEFT JOIN dialyzer diaz ON dia.dialyzer_cd = diaz.dia_code
where equip_type = ''1''   and dia.dialyzer_cd IN (@diaIds)
order by class_cd, cd)
UNION all
(select
	2 AS dis_order,
  ord.*,
  eqp.equipment_name as equip_name,
	eqp.class_cd AS equip_class_cd,
  eqp.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
  eqp.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
  eqp.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
  eqp.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
  eqp.unit as equip_unit,
	case when eqp.class_cd = ''-1'' then ''未分類'' else eqp_cls.class_name end as equip_class_name,
	-- eqp_cls.class_name AS equip_class_name,
  eqp_cls.class_type as equip_class_type,
	eq.code_order as code_order,
	eqc.code_order as class_order

from
  ord_tbl as ord
  inner join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
	LEFT JOIN equipment eq ON eq.equ_code = eqp.equipment_cd
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
	LEFT JOIN equipment_class eqc ON eqp_cls.class_cd = eqc.equ_class_code
	where equip_type <> ''1'' and eqp.class_cd IN (@eqIds) order by class_cd, cd)
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：医材 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
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
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no )
', 2, '[{"preview": "2313", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS3", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt1_date", "data_name": "配管自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt2_date", "data_name": "漏血テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt4_date", "data_name": "濃度自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt3_date", "data_name": "透析液流量自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt5_date", "data_name": "配管テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt6_date", "data_name": "希釈テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt7_date", "data_name": "通信共通自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/01", "can_calc": "0", "data_code": "setting_date", "data_name": "設置日", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "setting_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt1_data47", "data_name": "配管自己診断測定結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt1_data47", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13", "can_calc": "0", "data_code": "dt1_data43", "data_name": "配管系漏れ(陰圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data43", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "dt1_data44", "data_name": "配管系漏れ(陽圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data44", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-3", "can_calc": "0", "data_code": "dt1_data48", "data_name": "除水テスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data48", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40", "can_calc": "0", "data_code": "dt1_data46", "data_name": "バランステスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data46", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "dt1_data45", "data_name": "CFフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data45", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dt1_data49", "data_name": "CFsフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data49", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.203", "can_calc": "0", "data_code": "dt2_data53", "data_name": "赤電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data53", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.426", "can_calc": "0", "data_code": "dt2_data54", "data_name": "緑電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data54", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt4_data65", "data_name": "濃度自己診断結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt4_data65", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data63", "data_name": "B原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data63", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data64", "data_name": "A原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data64", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt3_data58", "data_name": "透析液流量測定値", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_data58", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt5_data5", "data_name": "排液判定時間", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data5", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt5_data6", "data_name": "配管テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt5_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10", "can_calc": "0", "data_code": "dt5_data7", "data_name": "給水圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data7", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "dt5_data8", "data_name": "送液圧（低）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data8", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "dt5_data9", "data_name": "送液圧（高）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data9", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt5_data10", "data_name": "濃度セル3", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data10", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "dt5_data11", "data_name": "濃度セル4", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data11", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "dt6_data4", "data_name": "B液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data4", "disp_format": "0.00", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt6_data5", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data5", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt6_data6", "data_name": "希釈テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt6_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自己診断メッセージです。", "can_calc": "0", "data_code": "dt7_message", "data_name": "通信共通自己診断測定結果", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_message", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '装置保守：自己診断　@machineNos @fromDate @toDate使用', '2020-03-30 16:59:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (109, 'with
bed_tbl AS (
	SELECT
		bed_cd
		, bed_name
		, machine_no
	FROM
		mst_bed
	WHERE
		facility_cd = @facilityCd
	AND
    is_disp = ''1''
  AND
    is_del = ''0''
)
, machine_tbl as (
  select
    mm.*,
    mmt.machine_type,
    bed.bed_name
  from
    mst_machine as mm
	left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
	left join bed_tbl as bed on mm.machine_no = bed.machine_no
  where
    mm.machine_no in ( @machineNos )
  and
    is_disp =''1''
  and
    is_del = ''0''
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
-- 予定
, mainte_layout_tbl as (
  select
    la.layout_order AS mainte_layout_index,
    *
  from
    mst_mainte_layout AS m
	LEFT JOIN layout_order AS la ON (la.layout_cd::text = m.mainte_layout_cd::text)
  where
    facility_cd = @facilityCd
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.layout_order ASC	
)
, mainte_layout_work as (
  select
    mainte_layout_tbl.mainte_layout_cd,
    mainte_layout_tbl.edition_no,
		mainte_layout_tbl.layout_name,
		mainte_category_idx,
    category_info::json->>''cd'' AS mainte_category_cd,
		category_info::json->>''isDisp'' AS mainte_category_isDisp
  from
    mainte_layout_tbl
      cross join lateral jsonb_array_elements_text(detail_info_1)
        with ordinality as tmp(category_info, mainte_category_idx)
)
, mainte_category_tbl as (
  select
    *
  from
    mst_mainte_category AS m
	LEFT JOIN category_order AS la ON (la.category_cd::text = m.mainte_category_cd::text)
  where
    facility_cd = @facilityCd
	and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.category_order ASC	
)
, mainte_category_work as (
  select
    mainte_category_tbl.mainte_category_cd,
    mainte_category_tbl.edition_no,
    mainte_category_tbl.category_name,
    mainte_detail_idx,
    detail_info::json->>''code'' AS mainte_detail_cd,
		detail_info::json->>''isDisp'' AS mainte_detail_isDisp
  from
    mainte_category_tbl
      cross join lateral jsonb_array_elements_text(detail)
        with ordinality as tmp(detail_info, mainte_detail_idx)
)
, mainte_detail_tbl as (
  select
    mmd.*,

		mcw.mainte_detail_idx,
    mcw.edition_no as mainte_category_edition,
    mcw.category_name,

    mlw.mainte_category_idx,
    mlw.mainte_layout_cd,
    mlw.edition_no as mainte_layout_edition,
		mlw.layout_name
  from
    mst_mainte_detail as mmd
      inner join mainte_category_work as mcw
        on mcw.mainte_detail_cd::text = mmd.mainte_detail_cd::text
      inner join mainte_layout_work as mlw
        on mlw.mainte_category_cd::text = mcw.mainte_category_cd::text
  where
    mmd.facility_cd = @facilityCd
	and
    mmd.mainte_class = ''1''
  and
    mmd.is_disp = ''1''
  and
    mmd.is_del = ''0''
)
-- 実績
, mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst AS m
	LEFT JOIN layout_order AS la ON (la.layout_cd::text = m.mainte_layout_cd::text)
  where
    facility_cd = @facilityCd
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.layout_order ASC
)
, mainte_category_hst as (
  select
    *
  from
    mst_mainte_category_hst AS m
	LEFT JOIN category_order AS la ON (la.category_cd::text = m.mainte_category_cd::text)
  where
    facility_cd = @facilityCd
	and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.category_order ASC
)
, mainte_detail_hst as (
  select
    *
  from
    mst_mainte_detail_hst
  where
    facility_cd = @facilityCd
	and
    mainte_class = ''1''	
  and
    is_disp = ''1''
  and
    is_del = ''0''
)
, mainte_work as (
  select
    *
  from
    mnt_mainte_main
  where
    facility_cd = @facilityCd
  and    
    machine_no in ( @machineNos )
  and    
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY mainte_date	
)
, mainte_main_detail_hst as (
  select
    mainte_no,
    json_idx as mainte_detail_idx,
    info->>''detail_cd'' as detail_cd,
    info->>''detail_edi'' as edition,
    info->>''judge'' as judge,
    info->>''comment'' as comment,
    info->>''user_id'' as user_id,
    info->>''date'' as date,
    info->>''cate_cd'' as cate_cd,
    info->>''cate_edi'' as cate_edi
  from
    mainte_work as mt
      cross join lateral jsonb_array_elements(detail)
        with ordinality as tmp(info, json_idx)
)
, mainte_main_category_hst as (
  select
    mainte_no,
    json_idx as mainte_category_idx,
    info->>''mainteCategoryCd'' as category_cd,
    info->>''editionNo'' as edition
  from
    mainte_work as mt
      cross join lateral jsonb_array_elements(mainte_category_cd)
        with ordinality as tmp(info, json_idx)
)
, machine_mainte_layout_all AS (
	SELECT
		mt.machine_no,
		mt.machine_serial,
		mt.machine_type,
		mt.machine_name,
		mt.facility_cd,
		mt.bed_name,
		mt.com_format_cd,
		
		mlt.mainte_layout_index,
		mlt.mainte_layout_cd, 
		mlt.layout_name,
		mlt.edition_no
	FROM
		machine_tbl as mt
	cross join mainte_layout_tbl as mlt
)
, mainte_hst as (
  select
		mt.machine_no,
		mt.machine_serial,
		mt.machine_type,
		mt.machine_name,
		mt.facility_cd,
		mt.bed_name,
		mt.com_format_cd,

		mt.mainte_layout_cd,
		mt.layout_name,
		mt.edition_no AS mainte_layout_edition,
		
    mw.mainte_no,
    mw.mainte_class,
    mw.rec_no,
    mw.mainte_date,
    mw.checker_id_1,
    mw.checker_id_2,
    mw.mainte_ans_1,
    to_char(mw.up_date, ''YYYY/MM/DD'') as up_date,

    mmdh.mainte_detail_idx,
    mmdh.detail_cd as mainte_detail_cd,
    mmdh.edition as mainte_detail_edition,
    mmdh.judge,
    mmdh.comment,
    mmdh.user_id,
    mmdh.date,

    mdh.mainte_content_1,
    mdh.mainte_content_2,
    mdh.mainte_content_3,

    mg.group_name as group_name,
   
		mmch.category_cd,
    mmch.mainte_category_idx,
		mdh.mainte_category_cd,
    mch.edition_no as mainte_category_edition,
    mch.category_name
  from
     machine_mainte_layout_all as mt
	left join mainte_work mw
		on mw.machine_no = mt.machine_no
		and mw.mainte_layout_cd = mt.mainte_layout_cd
	left join mst_mainte_layout_group as mg 
		on mg.mainte_layout_group_cd = mw.mainte_layout_group_cd
		and mg.facility_cd = mw.facility_cd	
  left join mainte_main_detail_hst as mmdh
        on mw.mainte_no = mmdh.mainte_no
	left join mainte_detail_hst as mdh
		on mmdh.detail_cd = mdh.mainte_detail_cd::text and mmdh.edition = mdh.edition_no::text
	left join mainte_main_category_hst as mmch
		on  mmdh.mainte_no = mmch.mainte_no
		and mmdh.cate_cd = mmch.category_cd::text and mmdh.cate_edi = mmch.edition::text
	left join mainte_category_hst as mch
		on mmch.category_cd::text = mch.mainte_category_cd::text and mmch.edition = mch.edition_no::text
	ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), mt.mainte_layout_index, mw.mainte_date, mmch.mainte_category_idx, mmdh.mainte_detail_idx
)
select * from mainte_hst
', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "bed_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "合否", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "点検コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "category_cd", "data_name": "点検カテゴリコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検者", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/17", "can_calc": "0", "data_code": "date", "data_name": "個別点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "up_date", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：日常点検詳細　@machineNos @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (117, 'with addition_info_expand as
(
  select
    ord_no
    ,json_idx
    ,addinfo
    ,to_date(treat_date, ''yyyymmdd'') as treat_date
  from
    ord_main
    cross join lateral jsonb_array_elements(addition_info) with ordinality as tmp(addinfo, json_idx)
  where
    is_del = ''0''
    and ord_no = @ordNo
    and rst_dialysis_state <>''0''
)
, tmp as
(
  select
    ord_no
    ,addinfo->>''cd'' as cd
    ,addinfo->>''name'' as name
    ,json_idx
    ,addinfo
   ,treat_date
  from
    addition_info_expand
)

select
  ord_no
  ,treat_date
  ,name
  ,in_hospital_cd_1 as rst_addition_in_hospital_cd_1
  ,in_hospital_cd_2 as rst_addition_in_hospital_cd_2
  ,in_hospital_cd_3 as rst_addition_in_hospital_cd_3
  ,addition_class
  ,mst_addition.addition_name
from
  tmp left outer join mst_addition on tmp.cd = mst_addition.addition_cd::text and is_disp = ''1'' and is_del = ''0''
order by json_idx
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "加算", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "透析液水質確保加算", "item": "透析液水質確保加算"}, {"code": "2", "disp": "障害者等加算", "item": "障害者等加算"}, {"code": "3", "disp": "指定病名連動", "item": "指定病名連動"}, {"code": "4", "disp": "指定治療方法連動", "item": "指定治療方法連動"}, {"code": "5", "disp": "長時間加算", "item": "長時間加算"}, {"code": "6", "disp": "指定薬剤実施連動", "item": "指定薬剤実施連動"}, {"code": "7", "disp": "指定患者イベント連動", "item": "指定患者イベント連動"}, {"code": "8", "disp": "検査依頼連動", "item": "検査依頼連動"}, {"code": "9", "disp": "導入期加算", "item": "導入期加算"}, {"code": "10", "disp": "休日加算", "item": "休日加算"}, {"code": "11", "disp": "時間外加算", "item": "時間外加算"}, {"code": "12", "disp": "汎用", "item": "汎用"}, {"code": "13", "disp": "慢性維持透析患者外来医学管理料", "item": "慢性維持透析患者外来医学管理料"}], "data_class": "加算", "field_name": "addition_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算等名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "addition_name", "data_name": "加算・管理料名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "addition_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：加算 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);