UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null 
group by treat_date 
order by treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11012;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd 
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' 
 AND ordMain.rst_dialysis_state = ''0'' and ordMain.pat_id is not null
 group by ordMain.treat_date
 order by ordMain.treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11014;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_dialysis_state = ''6'' and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null 
group by treat_date 
order by treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11017;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and rst_in_out_class = 1 and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null 
group by treat_date 
order by treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11018;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and (rst_in_out_class <> 1 or rst_in_out_class is null) and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null 
group by treat_date 
order by treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11019;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd 
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null 
group by ordMain.treat_date 
order by ordMain.treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11020;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd 
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null 
group by ordMain.treat_date 
order by ordMain.treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11021;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''1''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11024;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''2''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11025;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''3''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11026;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''4''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11027;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''5''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11028;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''6''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11029;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''7''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11030;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''8''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11031;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11032;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_end'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_end'' >= @dateFrom
  AND elem ->> ''period_end'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11033;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''10''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11034;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''11''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11035;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  to_char(reg_exam_date, ''YYYYMMDD'') as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_exam_main
WHERE date(reg_exam_date) >= @dateFrom
  AND date(reg_exam_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11036;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT
  to_char(reg_rad_date, ''YYYYMMDD'') as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_rad_main
WHERE date(reg_rad_date) >= @dateFrom
  AND date(reg_rad_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by treat_date
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11037;
