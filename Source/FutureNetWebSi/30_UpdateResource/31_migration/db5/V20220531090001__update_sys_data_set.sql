UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH prescription_data AS (
 SELECT
        ( o ->> ''Rp'' ) AS rp,--RP番号
        ( o ->> ''unchg'' ) AS unchg,--unchg
        ( o ->> ''type'' ) AS TYPE,--type
        ( o ->> ''F1'' ) AS f1,--F1
        ( o ->> ''F2'' ) AS f2,--F2
        ( o ->> ''F3'' ) AS f3,--F3
        ( o ->> ''F4'' ) AS f4,--F4
        ( o ->> ''F5'' ) AS f5,--量
        ( o ->> ''F6'' ) AS f6,--単位
        ( o ->> ''R'' ) AS r,--薬剤名称
        to_date( op.issue_date, ''YYYYMMDD'' ) issue_date,--交付日
        to_date( op.expiration_date, ''YYYYMMDD'' ) expiration_date,--使用期限
        op.issue_state AS issue_state,--交付状態
        op.ord_prescription_no AS ord_prescription_no --処方オーダー番号        
    FROM
        ord_prescription AS op,
        jsonb_array_elements ( prescription_detail ) AS o 
    WHERE
        op.pat_id = @patId 
     AND op.is_del = ''0'' 
     AND o ->> ''type'' <> ''0'' 
     AND op.ord_prescription_no = @ordPrescriptionNo 
    ORDER BY rp ASC, TYPE ASC
)
SELECT * FROM prescription_data WHERE prescription_data.rp <> '''' 
UNION ALL
SELECT * FROM prescription_data WHERE prescription_data.rp = ''''', "db_class" = 2, "detail" = '[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "rp", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "処方箋用表示", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "r", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内服", "can_calc": "0", "data_code": "type", "data_name": "タグ", "data_type": "string", "conv_table": [{"code": "1", "disp": "薬剤", "item": "薬剤"}, {"code": "2", "disp": "内服", "item": "内服"}, {"code": "3", "disp": "外用", "item": "外用"}, {"code": "4", "disp": "頓服内服", "item": "頓服内服"}, {"code": "5", "disp": "頓服外用", "item": "頓服外用"}, {"code": "6", "disp": "コメント", "item": "コメント"}, {"code": "E", "disp": "最終行", "item": "最終行"}], "data_class": "処方詳細", "field_name": "type", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "×", "can_calc": "0", "data_code": "unchg", "data_name": "切り替え禁止", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "unchg", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "F1", "data_name": "薬剤名/用法", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "f1", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "F2", "data_name": "調剤指示名/用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "f2", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "F3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "f3", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "F4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "f4", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "f5", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "処方詳細", "field_name": "f6", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2018/01/02", "can_calc": "0", "data_code": "issue_date", "data_name": "交付日", "data_type": "DateTime", "conv_table": [], "data_class": "処方詳細", "field_name": "issue_date", "disp_format": "yyyy/mm/dd", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2018/02/03", "can_calc": "0", "data_code": "expiration_date", "data_name": "使用期限", "data_type": "DateTime", "conv_table": [], "data_class": "処方詳細", "field_name": "expiration_date", "disp_format": "yyyy/mm/dd", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未交付", "can_calc": "0", "data_code": "issue_state", "data_name": "交付状態", "data_type": "string", "conv_table": [{"code": "0", "disp": "未交付", "item": "未交付"}, {"code": "1", "disp": "交付済み", "item": "交付済み"}], "data_class": "処方詳細", "field_name": "issue_state", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [2]}', "memo" = '処方：@facilityCd @patId @ordPrescriptionNo  使用', "reg_date" = '2021-02-16 13:42:00', "up_date" = '2021-02-16 13:42:00', "pre_sql_info" = NULL WHERE "sql_cd" = 138;

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
', "db_class" = 2, "detail" = '[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "rp", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "issue_name", "data_name": "調剤指示名", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "issue_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "用法詳細", "can_calc": "0", "data_code": "usage_detail", "data_name": "用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "usage_detail", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "r", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "medicine_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "rst_value", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": [2]}', "memo" = '処方：@facilityCd @patId @ordPrescriptionNo  使用', "reg_date" = '2021-11-09 13:42:00', "up_date" = '2021-11-09 13:42:00', "pre_sql_info" = NULL WHERE "sql_cd" = 201;
