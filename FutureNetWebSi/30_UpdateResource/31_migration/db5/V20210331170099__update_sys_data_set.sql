DELETE FROM ntss.sys_data_set 
WHERE sql_cd='141';
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
 opp.insu_no, --保険者番号
 opp.insu_pat_mark, --被保険者証記号
 opp.insu_pat_no, --被保険者証番号
 opp.insu_pub_no, --公費負担者番号
 opp.insu_pub_pat_no, --公費負担受給者番号
 opp.insu_kbn,--保険区分
 opp.remarks, --備考欄情報
 opp.insu_dr_id, --保険医ID
 opp.insu_dr_name,--保険医名称
 opp.insu_dr_sign,--保険医署名
 mpu.anesthesiologist_license_no,--麻薬施用者番号
 pi.insu_name --保険名称
FROM
 ord_personal_prescription opp
 LEFT JOIN mst_personal_user mpu ON opp.insu_dr_id = mpu.user_id and mpu.is_del =''0'' and mpu.is_disp =''1''
 LEFT JOIN pat_insurance pi ON opp.insurance_cd = pi.insurance_cd  and pi.is_del =''0'' and pi.is_disp =''1''
WHERE
 opp.ord_prescription_no = @ordPrescriptionNo
 and opp.is_del =''0'' and opp.is_disp =''1''  '
    ,3
    , '[
    {
        "preview": "123456789",
        "can_calc": "0",
        "data_code": "insu_no",
        "data_name": "保険者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_no",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "12345678",
        "can_calc": "0",
        "data_code": "insu_pat_mark",
        "data_name": "被保険者証記号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_pat_mark",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "1234567",
        "can_calc": "0",
        "data_code": "insu_pat_no",
        "data_name": "被保険者証番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_pat_no",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "xxxxxxx",
        "can_calc": "0",
        "data_code": "insu_pub_no",
        "data_name": "公費負担者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_pub_no",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "xxxxx",
        "can_calc": "0",
        "data_code": "insu_pub_pat_no",
        "data_name": "公費負担受給者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_pub_pat_no",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "被保険者",
        "can_calc": "0",
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
        "data_class": "簡易処方",
        "field_name": "insu_kbn",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "なし",
        "can_calc": "0",
        "data_code": "remarks",
        "data_name": "備考欄情報",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "remarks",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "xxxxxx",
        "can_calc": "0",
        "data_code": "insu_dr_id",
        "data_name": "保険医ID",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_dr_id",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "日機装　太郎",
        "can_calc": "0",
        "data_code": "insu_dr_name",
        "data_name": "保険医名称",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_dr_name",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "日機装　太郎",
        "can_calc": "0",
        "data_code": "insu_dr_sign",
        "data_name": "保険医署名",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_dr_sign",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "xxxxxxxx",
        "can_calc": "0",
        "data_code": "anesthesiologist_license_no",
        "data_name": "麻薬施用者番号",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "anesthesiologist_license_no",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "xxx保険",
        "can_calc": "0",
        "data_code": "insu_name",
        "data_name": "保険名称",
        "data_type": "string",
        "conv_table": [],
        "data_class": "簡易処方",
        "field_name": "insu_name",
        "disp_format": "",
        "data_category": "簡易処方",
        "facility_table": "",
        "facility_filter_type": "0"
    }
]'
    , 0
    , '{"applications": [1]}'
    , '{"classes": [2]}'
    , '処方：@facilityCd @patId @ordPrescriptionNo  使用'
    , '2021/03/31 14:09:45'
    , '2021/03/31 14:09:45'                          
    ,'[]'
);
