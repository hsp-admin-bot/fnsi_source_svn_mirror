DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 101;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (101, 'with machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = @machineNo
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
    *
  from
    mente_tbl
  where
    test_type = 1
  order by
    event_reg_date desc
  limit 1

), mente_tbl2 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 2
  order by
    event_reg_date desc
  limit 1

), mente_tbl3 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 3
  order by
    event_reg_date desc
  limit 1

), mente_tbl4 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 4
  order by
    event_reg_date desc
  limit 1

), mente_tbl5 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 5
  order by
    event_reg_date desc
  limit 1

), mente_tbl6 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 6
  order by
    event_reg_date desc
  limit 1

), mente_tbl7 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 7
  order by
    event_reg_date desc
  limit 1

)


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
   left join mente_tbl2 as tbl2
     on mt.facility_cd = tbl2.facility_cd
       and mt.machine_type_cd = tbl2.machine_type_cd
       and mt.machine_serial = tbl2.machine_serial
   left join mente_tbl3 as tbl3
     on mt.facility_cd = tbl3.facility_cd
       and mt.machine_type_cd = tbl3.machine_type_cd
       and mt.machine_serial = tbl3.machine_serial
   left join mente_tbl4 as tbl4
     on mt.facility_cd = tbl4.facility_cd
       and mt.machine_type_cd = tbl4.machine_type_cd
       and mt.machine_serial = tbl4.machine_serial
   left join mente_tbl5 as tbl5
     on mt.facility_cd = tbl5.facility_cd
       and mt.machine_type_cd = tbl5.machine_type_cd
       and mt.machine_serial = tbl5.machine_serial
   left join mente_tbl6 as tbl6
     on mt.facility_cd = tbl6.facility_cd
       and mt.machine_type_cd = tbl6.machine_type_cd
       and mt.machine_serial = tbl6.machine_serial
   left join mente_tbl7 as tbl7
     on mt.facility_cd = tbl7.facility_cd
       and mt.machine_type_cd = tbl7.machine_type_cd
       and mt.machine_serial = tbl7.machine_serial', 2, '[{"preview": "2313", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS3", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt1_date", "data_name": "配管自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt2_date", "data_name": "漏血テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt4_date", "data_name": "濃度自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt3_date", "data_name": "透析液流量自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt5_date", "data_name": "配管テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt6_date", "data_name": "希釈テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt7_date", "data_name": "通信共通自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/01", "can_calc": "0", "data_code": "setting_date", "data_name": "設置日", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "setting_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt1_data47", "data_name": "配管自己診断測定結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt1_data47", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13", "can_calc": "0", "data_code": "dt1_data43", "data_name": "配管系漏れ(陰圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data43", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "dt1_data44", "data_name": "配管系漏れ(陽圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data44", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-3", "can_calc": "0", "data_code": "dt1_data48", "data_name": "除水テスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data48", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40", "can_calc": "0", "data_code": "dt1_data46", "data_name": "バランステスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data46", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "dt1_data45", "data_name": "CFフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data45", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dt1_data49", "data_name": "CFsフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data49", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.203", "can_calc": "0", "data_code": "dt2_data53", "data_name": "赤電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data53", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.426", "can_calc": "0", "data_code": "dt2_data54", "data_name": "緑電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data54", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt4_data65", "data_name": "濃度自己診断結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt4_data65", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data63", "data_name": "B原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data63", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data64", "data_name": "A原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data64", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt3_data58", "data_name": "透析液流量測定値", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_data58", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt5_data5", "data_name": "排液判定時間", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data5", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt5_data6", "data_name": "配管テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt5_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10", "can_calc": "0", "data_code": "dt5_data7", "data_name": "給水圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data7", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "dt5_data8", "data_name": "送液圧（低）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data8", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "dt5_data9", "data_name": "送液圧（高）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data9", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt5_data10", "data_name": "濃度セル3", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data10", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "dt5_data11", "data_name": "濃度セル4", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data11", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "dt6_data4", "data_name": "B液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data4", "disp_format": "0.00", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt6_data5", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data5", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt6_data6", "data_name": "希釈テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt6_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自己診断メッセージです。", "can_calc": "0", "data_code": "dt7_message", "data_name": "通信共通自己診断測定結果", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_message", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '装置保守：自己診断　@machineNo @fromDate @toDate使用', '2020-03-30 16:59:00', CURRENT_TIMESTAMP, NULL);

DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 108;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (108, 'with machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = @machineNo
  and
    is_disp =''1''
  and
    is_del = ''0''

-- 予定

), mainte_layout_tbl as (
  select
    *
  from
    mst_mainte_layout
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_plan_tbl as (
  select
    generate_series as mainte_date
  from
    generate_series(@fromDate::timestamp, @toDate::timestamp, ''1 day'')

), mainte_tbl as (
  select
    0 as mainte_no,
    mt.facility_cd,
    ''1''::text as mainte_class,
    null::integer as rec_no,
    mpt.mainte_date,
    null::text as group_name,
    mlt.mainte_layout_cd,
    mlt.edition_no as mainte_layout_edition,
    null::text as checker_id_1,
    null::text as checker_id_2,
    null::text as mainte_ans_1,
    null::text as mainte_ans_2,
    to_char(mpt.mainte_date, ''YYYY/MM/DD'') as up_date,    

    mt.machine_serial,
    mt.machine_type,
    mt.machine_name,
		mt.com_format_cd,
    mlt.layout_name

  from
      mainte_plan_tbl as mpt,
      machine_tbl as mt,
      mainte_layout_tbl as mlt

-- 実績
), mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''


), mainte_work as (
  select
    *

  from
    mnt_mainte_main
  where
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''


), mainte_hst as (
  select
    mw.mainte_no,
    mw.facility_cd,
    mw.mainte_class,
    mw.rec_no,
    mw.mainte_date,
    mg.group_name,
    mw.mainte_layout_cd,
    mw.mainte_layout_edition,
    mw.checker_id_1,
    mw.checker_id_2,
    mw.mainte_ans_1,
    mw.mainte_ans_2,
    to_char(mw.up_date, ''YYYY/MM/DD'') as up_date,

    mt.machine_serial,
    mt.machine_type,
    mt.machine_name,
		mt.com_format_cd,
    mlh.layout_name

  from
    mainte_work mw
      inner join machine_tbl as mt
        on mw.machine_no = mt.machine_no
      inner join mainte_layout_hst as mlh
        on mw.mainte_layout_cd = mlh.mainte_layout_cd and mw.mainte_layout_edition = mlh.edition_no
      left join mst_mainte_layout_group as mg 
        on mg.mainte_layout_group_cd = mw.mainte_layout_group_cd
        and mg.facility_cd = mw.facility_cd    
),infection_order AS (

  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order 
from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = (select facility_cd from machine_tbl)
    and master_physical_name = ''mst_mainte_layout''
)
--, maint_temp As (
select
  *
from
  mainte_hst as m
	left join   infection_order as inf  on (inf.infection_cd ::text = m.mainte_layout_cd::text)
order by  m.mainte_date, inf.infection_cd_order asc
 
--union all
--select
-- *
--from
--  mainte_tbl
--where
--  mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)
--) 

--select * from maint_temp as m
--left join   infection_order as inf   on (inf.infection_cd ::text = m.mainte_layout_cd::text)

--order by  m.mainte_date, inf.infection_cd_order asc  #6417 坚 改める', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細無し）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "up_date", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '装置保守：日常点検　@machineNo @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);

DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 110;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (110, 'with machine_tbl as (
select
mm.*,
mmt.machine_type
from
mst_machine as mm
left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
where 
machine_no = @machineNo
and
is_disp =''1''
and
is_del = ''0''

-- 予定
), mainte_layout_group_tbl as (
select
*
from
mst_mainte_layout_group
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_tbl as (
select
*
from
mst_mainte_layout
where
facility_cd = (select facility_cd from machine_tbl)
and
layout_class = ''2''
and
(select machine_type_cd from machine_tbl)::text  in
(SELECT json_array_elements_text(
(SELECT to_json(type_info)))::text)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_work as (
select
*
from
mnt_mainte_main
where 
machine_no = @machineNo
and
mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
mainte_layout_edition is null
and
is_disp = ''1''
and
is_del = ''0''


), mainte_tbl as (
select
mw.mainte_no,
mw.facility_cd,
mw.mainte_class,
mw.rec_no,
mw.mainte_date,
mg.group_name,
mw.mainte_layout_group_cd,
mw.mainte_layout_group_edition,
mlt.mainte_layout_cd,
mw.mainte_layout_edition,
mw.checker_id_1,
mw.checker_id_2,
mw.mainte_ans_1,
mw.mainte_ans_2,

mt.machine_serial,
mt.machine_type,
mt.com_format_cd,
mlgt.group_name,

mlt.layout_name,
mt.machine_name,
mw.mainte_comment_1,
mw.mainte_comment_2,
mw.up_date

from
mainte_work as mw
left join mst_mainte_layout_group as mg 
     on mg.mainte_layout_group_cd = mw.mainte_layout_group_cd
     and mg.facility_cd = mw.facility_cd 
inner join machine_tbl as mt
on mw.machine_no = mt.machine_no
inner join mainte_layout_group_tbl as mlgt
on mw.mainte_layout_group_cd = mlgt.mainte_layout_group_cd
inner join mainte_layout_tbl as mlt
on (mlt.mainte_layout_cd::text  in (SELECT json_array_elements_text(
(SELECT to_json(mlgt.layout_list)))::text))
-- 実績
), mainte_layout_group_hst as (
select
*
from
mst_mainte_layout_group_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_hst as (
select
*
from
mst_mainte_layout_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst_work as (
select
*

from
mnt_mainte_main
where 

facility_cd = (select facility_cd from machine_tbl)
and
machine_no = @machineNo
and
mainte_date between date_trunc(''day'',@fromDate ::timestamp ) and date_trunc(''day'',@toDate ::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
mainte_layout_edition is not null
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst as (
select
mhw.mainte_no,
mhw.facility_cd,
mhw.mainte_class,
mhw.rec_no,
mhw.mainte_date,
mg.group_name,
mhw.mainte_layout_group_cd,
mhw.mainte_layout_group_edition,
mlh.mainte_layout_cd,
mhw.mainte_layout_edition,
mhw.checker_id_1,
mhw.checker_id_2,
mhw.mainte_ans_1,
mhw.mainte_ans_2,

mt.machine_serial,
mt.machine_type,
mt.com_format_cd,

mlgh.group_name,

mlh.layout_name,
mt.machine_name,
mhw.mainte_comment_1,
mhw.mainte_comment_2,
mhw.up_date

from
mainte_hst_work mhw
left join mst_mainte_layout_group as mg 
     on mg.mainte_layout_group_cd = mhw.mainte_layout_group_cd
     and mg.facility_cd = mhw.facility_cd  
inner join machine_tbl as mt
on mhw.machine_no = mt.machine_no
inner join mainte_layout_group_hst as mlgh
on mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd and mhw.mainte_layout_group_edition = mlgh.edition_no
inner join mainte_layout_hst as mlh
on mlh.mainte_layout_cd ::text in
(SELECT json_array_elements_text(
(SELECT to_json(mlgh.layout_list)))::text) and mhw.mainte_layout_edition = mlh.edition_no
 and mhw.mainte_layout_cd = mlh.mainte_layout_cd 
)
select
*
from
mainte_tbl
union all
select
*
from
mainte_hst

order by
mainte_date, layout_name', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "定期点検記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検（詳細無し）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_2", "data_name": "定期交換部品記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検（詳細無し）", "field_name": "mainte_ans_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "checker_id_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_2", "data_name": "定期交換部品記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "mainte_comment_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細無し）", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '装置保守：定期点検　@machineNo @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);