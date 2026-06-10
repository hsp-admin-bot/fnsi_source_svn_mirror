INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (201, 'with prescription_tbl as ( 
    SELECT
          (o ->> ''Rp'') AS rp
        , (o ->> ''F1'') AS issue_name--調剤指示名
        , (o ->> ''F2'') AS usage_detail--用法詳細
        , op.ord_prescription_no AS ord_prescription_no 
    FROM
        ord_prescription AS op
        , jsonb_array_elements(prescription_detail) AS o 
    WHERE
        op.facility_cd = @facilityCd 
        AND op.pat_id = @patId 
        AND op.is_del = ''0'' 
        AND o ->> ''type'' <> ''1'' 
        AND o ->> ''type'' <> ''6'' 
        AND o ->> ''type'' <> ''E'' 
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
						,( o ->> ''R'' ) AS r --薬剤名称
            , op.ord_prescription_no AS ord_prescription_no 
        FROM
            ord_prescription AS op
            , jsonb_array_elements(prescription_detail) AS o 
        WHERE
            op.facility_cd = @facilityCd 
            AND op.pat_id = @patId  
            AND op.is_del = ''0'' 
            AND o ->> ''type'' = ''1'' 
            AND op.ord_prescription_no = @ordPrescriptionNo 
        ORDER BY
            rp ASC
    ) ord_pt 
    left join prescription_tbl pt 
        on pt.rp = ord_pt.rp

', 2, '[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "rp", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "medicine_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "issue_name", "data_name": "調剤指示名", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "issue_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "用法詳細", "can_calc": "0", "data_code": "usage_detail", "data_name": "用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "usage_detail", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "rst_value", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "r", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [2]}', '処方：@facilityCd @patId @ordPrescriptionNo  使用', '2021-11-09 13:42:00', '2021-11-09 13:42:00', NULL);
