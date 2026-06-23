DELETE FROM ntss.sys_data_set 
WHERE sql_cd='142';

INSERT 
INTO ntss.sys_data_set( 
    sql_cd                                      -- SQLCD
    , "sql"                                     -- SQL
    , db_class                                  -- DB種別
    , detail                                    -- 詳細
    , can_repeat                                -- 繰返し可否フラグ
    , use_application                           -- 使用用途
    , report_class                              -- 帳票種別
    , memo                                      -- 備考
    , reg_date                                  -- 登録日時
    , up_date                                   -- 更新日時
    , pre_sql_info                              -- 事前取得データ情報
) 
VALUES ( 
    (select max(sql_cd)+1 from ntss.sys_data_set)
    ,'SELECT
 ( o ->> ''Rp'' ) AS Rp, --RP番号
 ( o ->> ''R'' ) AS R,   --薬剤名称
 ( o ->> ''F5'' ) AS F5, --量
 ( o ->> ''F6'' ) AS F6, --単位
 ( o ->> ''type'' ) AS type, --type
 to_date(op.issue_date, ''YYYYMMDD'') issue_date,--交付日
 to_date(op.expiration_date, ''YYYYMMDD'') expiration_date, --使用期限
 op.issue_state AS issue_state, --交付状態
 op.ord_prescription_no  AS ord_prescription_no --処方オーダー番号
FROM
 ord_prescription AS op,
 jsonb_array_elements (prescription_detail) AS o 
WHERE
 op.facility_cd = @facilityCd
 AND
 op.pat_id = @patId
 AND
 ord_prescription_no in (@ordPrescriptionNos)
 order by op asc ,type asc'
    ,2
    , '[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "rp", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "r", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f5", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "f6", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2018/01/02", "can_calc": "0", "data_code": "issue_date", "data_name": "交付日", "data_type": "DateTime", "conv_table": [], "data_class": "簡易処方", "field_name": "issue_date", "disp_format": "yyyy/mm/dd", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2018/02/03", "can_calc": "0", "data_code": "expiration_date", "data_name": "使用期限", "data_type": "DateTime", "conv_table": [], "data_class": "簡易処方", "field_name": "expiration_date", "disp_format": "yyyy/mm/dd", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未交付", "can_calc": "0", "data_code": "issue_state", "data_name": "交付状態", "data_type": "string", "conv_table": [{"code": "0", "disp": "未交付", "item": "未交付"}, {"code": "1", "disp": "交付済み", "item": "交付済み"}], "data_class": "簡易処方", "field_name": "issue_state", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456", "can_calc": "0", "data_code": "ord_prescription_no", "data_name": "処方オーダー番号", "data_type": "string", "conv_table": [], "data_class": "簡易処方", "field_name": "ord_prescription_no", "disp_format": "", "data_category": "簡易処方", "facility_table": "", "facility_filter_type": "0"}]'
    , 1
    , '{"applications": [1]}'
    , '{"classes": [2]}'
    , '処方：@facilityCd @patId @ordPrescriptionNo  使用'
    , '2021/03/31 14:09:45'
    , '2021/03/31 14:09:45'                          
    ,'[]'
);

