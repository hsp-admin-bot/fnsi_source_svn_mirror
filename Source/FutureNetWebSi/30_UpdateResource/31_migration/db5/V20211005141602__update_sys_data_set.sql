update ntss.sys_data_set set "sql"='select
    s.rst_weight_info ->> ''ctr'' as last_ctr
  , s.rst_weight_info ->> ''ctr_weight'' as last_ctr_weight
  , s.rst_weight_info ->> ''weight_before'' as last_weight_before
  , s.rst_weight_info ->> ''weight_after'' as last_weight_after
  , s.rst_weight_info ->> ''weight_decreased'' as last_weight_decreased
  , substr(to_char(cast( s.rst_weight_info ->> ''ctr_measure_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_ctr_measure_date
  , substr(to_char(cast( s.rst_weight_info ->> ''weight_after_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_weight_after_date
  , substr(to_char(cast( s.rst_weight_info ->> ''weight_before_date''  as TIMESTAMP),''YYYY/MM/DD hh24:mi:ss''),0,17)  as last_weight_before_date
  , (s.rst_puncture_user_info ->> ''user_last_name_1'') || (s.rst_puncture_user_info ->> ''user_first_name_1'') as last_puncture_user_name
from
  ord_main as ord   LEFT OUTER JOIN ord_main s ON (
    ord.ord_no <> s.ord_no
    AND ord.pat_id = s.pat_id
    AND ord.facility_cd = s.facility_cd
    AND ord.rst_start_date > s.rst_start_date
    AND s.is_del = ''0''
  )
WHERE
  ord.ord_no = @ordNo 
AND
  ord.is_del = ''0''
AND ord.rst_dialysis_state >''0'' and ord.rst_dialysis_state <''6''  

ORDER BY
  s.rst_start_date DESC',db_class=2,detail='[
    {
        "preview": "56.78",
        "can_calc": "1",
        "data_code": "last_weight_before",
        "data_name": "前体重(前回)",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "体重情報（過去実績）",
        "field_name": "last_weight_before",
        "disp_format": "0.00",
        "data_category": "実績（治療中）",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2011/3/12  8:21",
        "can_calc": "1",
        "data_code": "last_weight_before_date",
        "data_name": "前体重測定日時(前回)",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "体重情報（過去実績）",
        "field_name": "last_weight_before_date",
        "disp_format": "",
        "data_category": "実績（治療中）",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "56.78",
        "can_calc": "1",
        "data_code": "last_weight_after",
        "data_name": "後体重(前回)",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "体重情報（過去実績）",
        "field_name": "last_weight_after",
        "disp_format": "0.00",
        "data_category": "実績（治療中）",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2011/3/12  8:21",
        "can_calc": "1",
        "data_code": "last_weight_after_date",
        "data_name": "後体重測定日時(前回)",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "体重情報（過去実績）",
        "field_name": "last_weight_after_date",
        "disp_format": "",
        "data_category": "実績（治療中）",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "50",
        "can_calc": "1",
        "data_code": "last_ctr",
        "data_name": "CTR(前回)",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "体重情報（過去実績）",
        "field_name": "last_ctr",
        "disp_format": "0.00",
        "data_category": "実績（治療中）",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2011/3/12  8:21",
        "can_calc": "1",
        "data_code": "last_ctr_measure_date",
        "data_name": "CTR測定日時(前回)",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "体重情報（過去実績）",
        "field_name": "last_ctr_measure_date",
        "disp_format": "",
        "data_category": "実績（治療中）",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "56.78",
        "can_calc": "1",
        "data_code": "last_ctr_weight",
        "data_name": "CTR測定時体重(前回)",
        "data_type": "decimal",
        "conv_table": [],
        "data_class": "体重情報（過去実績）",
        "field_name": "last_ctr_weight",
        "disp_format": "0.00",
        "data_category": "実績（治療中）",
        "facility_table": "",
        "facility_filter_type": "0"
    }
]',can_repeat='0',use_application='{"applications": [1]}',report_class='{"classes": [1, 2, 3, 9, 10, 11]}',memo='実績（治療中）(前回体重)',reg_date='2021-08-05T13:30:00',up_date='2021-08-05T13:30:00',pre_sql_info=null where sql_cd=179;
