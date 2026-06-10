DELETE FROM ntss.sys_data_set 
WHERE sql_cd='139';

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
    ,'select country_name as country_name from sys_country where country_cd_alpha3 = @countryCdAlpha3'
    ,2
    , '[]'
    , 0
    , '{"applications": [1]}'
    , '{"classes": []}'
    , '汎用　国籍名取得用　@countryCdAlpha3'
    , '2021/03/31 14:09:45'
    , '2021/03/31 14:09:45'                          
    ,'[]'
);

DELETE FROM ntss.sys_data_set 
WHERE sql_cd='140';

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
    ,'select * from mst_facility where facility_cd = @facilityCd'
    ,2
    , '[]'
    , 0
    , '{"applications": [1]}'
    , '{"classes": []}'
    , '汎用　施設名取得用　@facilityCd'
    , '2021/03/31 14:09:45'
    , '2021/03/31 14:09:45'                          
    ,'[]'
);