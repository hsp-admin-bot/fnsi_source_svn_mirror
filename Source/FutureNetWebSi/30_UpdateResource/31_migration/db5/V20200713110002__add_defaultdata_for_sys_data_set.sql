INSERT INTO sys_data_set (sql,db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info,sql_cd) VALUES 
('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''6''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11029)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''7''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11030)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''8''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11031)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11032)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''11''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11035)
,('SELECT count(DISTINCT pat_id) AS count
FROM pat_exam_main
WHERE date(reg_exam_date) >= @dateFrom
  AND date(reg_exam_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11036)
,('SELECT count(DISTINCT pat_id) AS count
FROM pat_rad_main
WHERE date(reg_rad_date) >= @dateFrom
  AND date(reg_rad_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11037)
,('SELECT count(DISTINCT e.pat_id) AS count
FROM pat_event AS e,
     mst_pat_event_sub_category AS s
WHERE date(e.event_date) >= @dateFrom
  AND date(e.event_date) <= @dateTo
  AND e.is_del = ''0''
  AND s.sub_category_cd = e.sub_category_cd
  AND s.is_del = ''0''
  AND e.facility_cd = @facilityCd
  AND s.facility_cd = @facilityCd
  AND s.sub_category_cd = @id
',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11038)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''2''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11025)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''3''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11026)
,
('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''4''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11027)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''5''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11028)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_end'' >= @dateFrom
  AND elem ->> ''period_end'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11033)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''10''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11034)
,('select unit from mst_equipment where equipment_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11006)
,(' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''25''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) as count
',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11001)
,('select unit from mst_medicine where medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11002)
,(' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''25''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) as count
',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11003)
,('select case when @kubun = 1 then mstMedi.unit else mstMediMix.unit END AS unit
from 
mst_medicine as mstMedi full join mst_medicine_mix as mstMediMix on mstMedi.class_cd = mstMediMix.class_cd 
where mstMedi.medicine_cd = @id or mstMediMix.medicine_mix_cd = @id',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11004)
,(' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999'') =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) +
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_treatment_info::json) mediInfo 
      where to_number(mediInfo->>''treat_medicine_cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) 
as count',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11009)
,
(' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) as count',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11011)
,('select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' ',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11012)
,('select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' ',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11013)
,('select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_dialysis_state = ''6'' and facility_cd = @facilityCd AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11017)
,('select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_in_out_class = 1 and facility_cd = @facilityCd AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11018)
,('select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_in_out_class = 0 and facility_cd = @facilityCd AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11019)
,('select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11020)
,('select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11021)
,('select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd = @id AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11022)
,(' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''5''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) as count',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11007)
,
(' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999'') =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) +
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_treatment_info::json) mediInfo 
      where to_number(mediInfo->>''treat_medicine_cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) 
as count',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11008)
,('select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' ',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11014)
,('select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0'' ',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11015)
,('select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11016)
,('select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd = @id AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11023)
,(' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''6''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''7''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''8''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''9''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''10''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''11''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) as count',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11005)
,('SELECT  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''1''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11024)
,(' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''6''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''7''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''8''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''9''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''10''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''11''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) as count',2,'[]','0','{"applications": []}','{"classes": []}','データリスト',now(),now(),NULL,-11010)
;