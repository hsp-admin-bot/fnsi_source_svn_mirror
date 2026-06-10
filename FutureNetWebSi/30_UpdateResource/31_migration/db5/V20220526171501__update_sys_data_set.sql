UPDATE "ntss"."sys_data_set" SET "sql" = 'with prescription_tbl as ( 
    SELECT
          (o ->> ''Rp'') AS rp
        , (o ->> ''F1'') AS issue_name--調剤指示名
        , CASE WHEN (o ->> ''type'') IN (''3'', ''5'') THEN (o ->> ''F2'') || '' '' || (o ->> ''F3'') || '' '' || (o ->> ''F4'')
               ELSE (o ->> ''F2'') END AS usage_detail--用法詳細
        , op.ord_prescription_no AS ord_prescription_no 
    FROM
        ord_prescription AS op
        , jsonb_array_elements(prescription_detail) AS o 
    WHERE
        op.pat_id = @patId  
    AND op.is_del = ''0''
    AND o ->> ''type'' <> ''1'' 
    AND o ->> ''type'' <> ''6'' 
    AND o ->> ''type'' <> ''E'' 
    AND o ->> ''type'' <> ''0'' 
    AND op.ord_prescription_no = @ordPrescriptionNo 
) 
select
    ord_pt.rp
    , ord_pt.medicine_name
    , ord_pt.mix_name
    , pt.issue_name
    , pt.usage_detail 
    ,ord_pt.rst_value
    ,ord_pt.unit
    ,ord_pt.r
from
    ( 
        SELECT
            (o ->> ''Rp'') AS rp
            , (o ->> ''F1'') AS medicine_name--薬剤名
            , (o ->> ''F2'') AS mix_name--用法
            ,( o ->> ''F5'' ) AS rst_value--量
            ,( o ->> ''F6'' ) AS unit--単位
            ,( o ->> ''R'' ) AS r --薬剤処方箋用表示
            , op.ord_prescription_no AS ord_prescription_no 
        FROM
            ord_prescription AS op
            , jsonb_array_elements(prescription_detail) AS o 
        WHERE
            op.pat_id = @patId  
        AND op.is_del = ''0'' 
        AND o ->> ''type'' = ''1'' 
        AND op.ord_prescription_no = @ordPrescriptionNo 
        ORDER BY rp ASC
    ) ord_pt
    left join prescription_tbl pt 
        on pt.rp = ord_pt.rp
', "db_class" = 2, "detail" = '[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "rp", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "issue_name", "data_name": "調剤指示名", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "issue_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "用法詳細", "can_calc": "0", "data_code": "usage_detail", "data_name": "用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "usage_detail", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "r", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "medicine_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "rst_value", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "medicine_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "rst_value", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [2]}', "memo" = '処方：@facilityCd @patId @ordPrescriptionNo  使用', "reg_date" = '2021-11-09 13:42:00', "up_date" = '2021-11-09 13:42:00', "pre_sql_info" = NULL WHERE "sql_cd" = 201;
