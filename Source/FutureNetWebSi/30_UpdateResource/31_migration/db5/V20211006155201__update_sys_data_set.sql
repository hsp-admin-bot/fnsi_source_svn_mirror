update ntss.sys_data_set set "sql"='with pat_taboo_tbl as (
  select
    to_number( info->>''ctl_no'', ''99999'') as ctl_no,
    to_number( info->>''disp_order'', ''99999'') as disp_order,
    info->>''content'' as content,
    info->>''memo'' as memo,
    info->>''category_class'' as category_class,
    info->>''taboo_allergy_class'' as taboo_allergy_class,
    info->>''taboo_allergy_cd'' as taboo_allergy_cd
  from
    pat_main
    cross join lateral
      json_array_elements (pat_main.taboo_allergy_info :: json) info
  where
    pat_id = @patId
    and is_del = ''0''
)

select
  ctl_no,
  disp_order,
  content,
  memo,
  category_class,
  taboo_allergy_class,
  taboo_allergy_cd
from
  pat_taboo_tbl
order by
  disp_order, ctl_no
',db_class=2,detail='[
    {
        "preview": "テスト薬剤（禁忌・アレルギー）",
        "can_calc": "0",
        "data_code": "content",
        "data_name": "禁忌・アレルギー",
        "data_type": "string",
        "conv_table": [],
        "data_class": "禁忌・アレルギー",
        "field_name": "content",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "禁忌・アレルギーです。",
        "can_calc": "0",
        "data_code": "memo",
        "data_name": "禁忌・アレルギー備考",
        "data_type": "string",
        "conv_table": [],
        "data_class": "禁忌・アレルギー",
        "field_name": "memo",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "禁忌",
        "can_calc": "0",
        "data_code": "taboo_allergy_class",
        "data_name": "禁忌・アレルギー区分",
        "data_type": "string",
        "conv_table": [
            {
                "code": "1",
                "disp": "禁忌",
                "item": "禁忌"
            },
            {
                "code": "2",
                "disp": "アレルギー",
                "item": "アレルギー"
            }
        ],
        "data_class": "禁忌・アレルギー",
        "field_name": "taboo_allergy_class",
        "disp_format": "",
        "data_category": "患者情報",
        "facility_table": "",
        "facility_filter_type": "0"
    }
]',can_repeat='1',use_application='{"applications": [1]}',report_class='{"classes": [1, 2, 3, 9, 10, 11]}',memo='患者情報：禁忌・アレルギー　@patId使用',reg_date=now(),up_date=now(),pre_sql_info=null where sql_cd=22;
