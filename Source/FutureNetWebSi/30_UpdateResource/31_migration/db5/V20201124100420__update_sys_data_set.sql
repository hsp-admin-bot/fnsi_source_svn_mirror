UPDATE "ntss"."sys_data_set" SET "sql" = 'select
case when t.del_flag = 1 then t.occur_time else null end as occur_time,
t.complaint,
t.treat_name,
t.treat_medicine,
t.amount,
t.unit,
t.procedure,
t.treat_staff_name
from
(select
  to_char(to_timestamp(coalesce(a.occur_date,b.occur_date,c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.amount,
  b.unit,
  b.procedure,
  c.treat_staff_name,
	row_number() over( partition by coalesce (A.occur_date, b.occur_date, C.occur_date) order by COALESCE(a.occur_date,b.occur_date,c.occur_date),
	to_number(coalesce( a.row_no, b.row_no, c.row_no), ''9999999999'')) as del_flag
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
	  complaint->>''row_no'' as row_no
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
    order by
      ord_no,
      occur_date) a
  full outer join
  (
    select
      ord.ord_no,
      treatment->>''occur_date'' as occur_date,
      treatment->>''row_no'' as row_no,
      case
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is not null then concat(''酸素吸入開始 '', to_char(cast(treatment->>''oxygen_speed'' as numeric), ''FM999999.00''), ''L/min'')
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is null then concat(''酸素吸入終了 '' , to_char(cast(treatment->>''oxygen_amount'' as numeric), ''FM999999.00''), ''L'')
        else treatment->>''treat_name'' end
      as treat_name,
      treatment->>''treat_medicine_name'' as treat_medicine,
      treatment->>''amount'' as amount,
      treatment->>''unit'' as unit,
      treatment->>''procedure_name'' as procedure
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
    order by
      ord_no,
      occur_date,
      row_no) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no
  full outer join
  (
    select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    order by
      ord_no,
      occur_date,
      row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.occur_date,b.occur_date) = c.occur_date and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')) t
order by t.occur_time, t.del_flag' WHERE "sql_cd" = 6;
