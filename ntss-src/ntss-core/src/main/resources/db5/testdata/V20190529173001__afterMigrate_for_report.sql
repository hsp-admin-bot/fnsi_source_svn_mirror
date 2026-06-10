INSERT INTO mst_report (facility_cd,report_name,report_path,report_class,is_disp,is_del,reg_date,up_date) VALUES
('009999','report','{"bucket": "ntss-esm", "xml_path": "透析レポート.xml", "html_path": "透析レポート.html", "xlsx_path": "xlsx_path"}',2,'1','0','2019-02-13 14:30:00.000','2019-02-13 14:00:00.000')
;

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date)
VALUES
(1, 'select
	pat_id,
	personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name
from
  pat_personal_main
where
  is_del = ''0''
and
  pat_id = @patId
', 3, '[{"data_code": "pat_id", "field_name": "pat_id"}, {"data_code": "pat_name", "field_name": "pat_name"}]', '0', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000'),
(2, 'select 
  *
from
  ord_main
where
  ord_no = @ordNo', 2, '[
    {
        "data_code": "pat_id",
        "field_name": "pat_id"
    },
    {
        "data_code": "pat_name",
        "field_name": "pat_name"
    }
]', '0', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000'),
(3, 'select 
  weight_before,
  weight_after,
  puncture_user_last_name||puncture_user_first_name as puncture_user_name
from  ( 
  select
    ord.rst_weight_info ->> ''weight_before'' as weight_before,
    ord.rst_weight_info ->> ''weight_after'' as weight_after,
    ord.rst_puncture_user_info ->> ''user_last_name_1'' as puncture_user_last_name,
    ord.rst_puncture_user_info ->> ''user_first_name_1'' as puncture_user_first_name
  from
    ord_main as ord
  where
    ord.ord_no = @ordNo
) as ordsub', 2, '[{"data_code": "weight_before", "field_name": "weight_before"}, {"data_code": "weight_after", "field_name": "weight_after"}, {"data_code": "puncture_user_name", "field_name": "puncture_user_name"}]', '0', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000'),
(4, 'select
  medi ->> ''name'' as medi_name,
  medi ->> ''amount'' as medi_amount,
  medi ->> ''timing_name'' as medi_timing_name
from
  ord_main as ord
cross join lateral
  json_array_elements (ord.rst_medi_info :: json) medi
where
    ord.ord_no = @ordNo
', 2, '[{"data_code": "medi_name", "field_name": "medi_name"}, {"data_code": "medi_amount", "field_name": "medi_amount"}, {"data_code": "medi_timing_name", "field_name": "medi_timing_name"}]', '1', NULL, NULL, NULL, '2019-05-29 17:24:00.000', '2019-05-29 17:24:00.000')
;
