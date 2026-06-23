update ntss.sys_data_set set "sql"='with set_tbl as ( 
    SELECT
        CASE 
            WHEN num = 1 
                THEN pi.insu_set_info ->> ''insu_cd'' 
            WHEN num = 2 
                THEN pi.insu_set_info ->> ''insu_pub1_cd'' 
            WHEN num = 3 
                THEN pi.insu_set_info ->> ''insu_pub2_cd'' 
            WHEN num = 4 
                THEN pi.insu_set_info ->> ''insu_pub3_cd'' 
            WHEN num = 5 
                THEN pi.insu_set_info ->> ''insu_pub4_cd'' 
            END as insu_cd 
    FROM
        pat_insurance pi 
        CROSS JOIN generate_series(1, 5) AS s(num) 
    where
        pi.pat_id = @patId 
        and pi.insu_class = 2 
        and pi.is_selected = ''1''
) 
, insu_work as ( 
    select
        pi.insurance_cd
        , pi.is_selected as selected_flg
        , insu_info ->> ''insu_no'' as insu_no
        , personal_info_decrypt(insu_info ->> ''insu_pat_name'') as insu_pat_name
        , personal_info_decrypt(insu_info ->> ''insu_pat_no'') as insu_pat_no
        , insu_info ->> ''insu_kbn'' as insu_kbn
        , personal_info_decrypt(insu_info ->> ''insu_pat_mark'') as insu_pat_mark
        , insu_info ->> ''cki_class'' as cki_class
        , insu_info ->> ''kki_class'' as kki_class
        , insu_info ->> ''und_six'' as und_six
        , insu_info ->> ''futan-g'' as futan_g
        , insu_info ->> ''futan-n'' as futan_n
        , personal_info_decrypt(insu_pub_info ->> ''insu_pub_name'') as insu_pub_name
        , personal_info_decrypt(insu_pub_info ->> ''insu_pub_no'') as insu_pub_no
        , personal_info_decrypt(insu_pub_info ->> ''insu_pub_pat_no'') as insu_pub_pat_no
        , is_selected as is_selected
        , insu_name as insu_name
        , start_date as insu_start_date
        , end_date as insu_end_date
        , check_date as insu_check_date 
    from
        pat_insurance as pi 
    where
        pi.is_del = ''0'' 
        and pi.is_disp = ''1'' 
        and pi.pat_id = @patId 
        and pi.insu_class <> 2
) 
select
    A.* 
from
    insu_work A 
    inner join set_tbl wk 
        on (A.insurance_cd ::text = wk.insu_cd) 
union all 
select
    B.* 
from
    insu_work B 
where
    B.selected_flg = ''1'';
',db_class=3,detail='[
    {
        "preview": "12345678",
        "can_calc": "1",
        "data_code": "insu_no",
        "data_name": "保険者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_no",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "日機装　太郎",
        "can_calc": "1",
        "data_code": "insu_pat_name",
        "data_name": "保険者名称",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_pat_name",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "123456789",
        "can_calc": "1",
        "data_code": "insu_pat_no",
        "data_name": "被保険者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_pat_no",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "自費",
        "can_calc": "1",
        "data_code": "insu_kbn",
        "data_name": "保険区分",
        "data_type": "string",
        "conv_table": [
            {
                "code": "0",
                "disp": "被保険者",
                "item": "被保険者"
            },
            {
                "code": "1",
                "disp": "被扶養者",
                "item": "被扶養者"
            }
        ],
        "data_class": "保険情報",
        "field_name": "insu_kbn",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "",
        "can_calc": "1",
        "data_code": "insu_pat_mark",
        "data_name": "被保険者記号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_pat_mark",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "対象外",
        "can_calc": "1",
        "data_code": "cki_class",
        "data_name": "長期高額療養",
        "data_type": "string",
        "conv_table": [
            {
                "code": "0",
                "disp": "対象外",
                "item": "対象外"
            },
            {
                "code": "1",
                "disp": "対象者",
                "item": "対象者"
            },
            {
                "code": "2",
                "disp": "１０００円対象者",
                "item": "１０００円対象者"
            },
            {
                "code": "3",
                "disp": "２０００円対象者",
                "item": "２０００円対象者"
            }
        ],
        "data_class": "保険情報",
        "field_name": "cki_class",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "一般",
        "can_calc": "1",
        "data_code": "kki_class",
        "data_name": "高額受給後期高齢",
        "data_type": "string",
        "conv_table": [
            {
                "code": "0",
                "disp": "対象外",
                "item": "対象外"
            },
            {
                "code": "1",
                "disp": "一般",
                "item": "一般"
            },
            {
                "code": "2",
                "disp": "７割給付",
                "item": "７割給付"
            }
        ],
        "data_class": "保険情報",
        "field_name": "kki_class",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "６歳未満",
        "can_calc": "1",
        "data_code": "und_six",
        "data_name": "6歳未満",
        "data_type": "string",
        "conv_table": [
            {
                "code": "0",
                "disp": "対象外",
                "item": "対象外"
            },
            {
                "code": "1",
                "disp": "６歳未満",
                "item": "６歳未満"
            }
        ],
        "data_class": "保険情報",
        "field_name": "und_six",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "70",
        "can_calc": "1",
        "data_code": "futan_g",
        "data_name": "負担率(外来)",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "futan_g",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "30",
        "can_calc": "1",
        "data_code": "futan_n",
        "data_name": "負担率(入院)",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "futan_n",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "日機装　次郎",
        "can_calc": "1",
        "data_code": "insu_pub_no",
        "data_name": "公費負担者名",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_pub_no",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1234567",
        "can_calc": "1",
        "data_code": "insu_pub_no",
        "data_name": "公費負担者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_pub_no",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "123456789",
        "can_calc": "1",
        "data_code": "insu_pub_pat_no",
        "data_name": "公費受給者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_pub_pat_no",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "主保険",
        "can_calc": "1",
        "data_code": "is_selected",
        "data_name": "主保険フラグ",
        "data_type": "string",
        "conv_table": [
            {
                "code": "0",
                "disp": "主保険ではない",
                "item": "主保険ではない"
            },
            {
                "code": "1",
                "disp": "主保険",
                "item": "主保険"
            }
        ],
        "data_class": "保険情報",
        "field_name": "is_selected",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "XX保険",
        "can_calc": "1",
        "data_code": "insu_name",
        "data_name": "保険名称",
        "data_type": "string",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_name",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2020/2/15",
        "can_calc": "1",
        "data_code": "insu_start_date",
        "data_name": "開始日",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_start_date",
        "disp_format": "yyyy/mm/dd",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2021/2/15",
        "can_calc": "1",
        "data_code": "insu_end_date",
        "data_name": "終了日",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_end_date",
        "disp_format": "yyyy/mm/dd",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2021/2/16",
        "can_calc": "1",
        "data_code": "insu_check_date",
        "data_name": "確認日",
        "data_type": "DateTime",
        "conv_table": [],
        "data_class": "保険情報",
        "field_name": "insu_check_date",
        "disp_format": "yyyy/mm/dd",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    }
]',can_repeat='0',use_application='{"applications": [1]}',report_class='{"classes": [1, 2, 3, 9, 10, 11]}',memo='患者情報：保険情報　@patId使用',reg_date=now(),up_date=now(),pre_sql_info=null where sql_cd=14;
