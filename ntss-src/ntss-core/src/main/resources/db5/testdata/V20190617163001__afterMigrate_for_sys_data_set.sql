INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date)
VALUES
(6, 'select
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  a.complaint,
  b.row_no,
  b.treat_name,
  b.treat_medicine,
  b.amount,
  b.unit,
  b.procedure,
  c.treat_staff_name
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint
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
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date
  left outer join
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
  on b.ord_no = c.ord_no and b.occur_date = c.occur_date and b.row_no = c.row_no
where
  coalesce(a.ord_no, b.ord_no) = @ordNo
order by
  occur_time
', 2, '[
  {"data_code": "occur_time", "field_name": "occur_time"},
  {"data_code": "complaint", "field_name": "complaint"},
  {"data_code": "row_no", "field_name": "row_no"},
  {"data_code": "treat_name", "field_name": "treat_name"},
  {"data_code": "treat_medicine", "field_name": "treat_medicine"},
  {"data_code": "amount", "field_name": "amount"},
  {"data_code": "unit", "field_name": "unit"},
  {"data_code": "procedure", "field_name": "procedure"},
  {"data_code": "treat_staff_name", "field_name": "treat_staff_name"}
]', '1', NULL, NULL, NULL, '2019-06-17 14:45:00.000', '2019-06-17 14:45:00.000')
;
