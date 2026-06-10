DELETE FROM ntss.sys_data_set 
WHERE sql_cd='143';

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
      content                                   -- 内容
    , notice_start_date                         -- 掲載開始日時
    , notice_end_date                           -- 掲載終了日時
    , reg_staff_name                            -- 起票者名
    , upd_staff_name                            -- 最終更新者名
    , title                                     -- タイトル
    , notice_fac_cal_start_date                 -- 施設カレンダーイベント開始日付
    , notice_fac_cal_end_date                   -- 施設カレンダーイベント終了日付

FROM
    ntss.bbs_info 
WHERE
       facility_cd = @facilityCd
    AND
       notice_start_date >= @fromdate
    AND
       notice_end_date <= @todate
    AND
       is_disp = ''1'' 
    and 
       is_del =''0''
ORDER BY
    bbs_ctl_no'
    ,2
    , '[
    {
        "preview": "起票者１",
        "can_calc": "0",
        "data_code": "reg_staff_name",
        "data_name": "起票者",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "reg_staff_name",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "更新者１",
        "can_calc": "0",
        "data_code": "upd_staff_name",
        "data_name": "最終更新者",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "upd_staff_name",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "タイトル１",
        "can_calc": "0",
        "data_code": "title",
        "data_name": "タイトル",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "title",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "内容１",
        "can_calc": "0",
        "data_code": "content",
        "data_name": "内容",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "content",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2021/02/22",
        "can_calc": "0",
        "data_code": "notice_fac_cal_start_date",
        "data_name": "イベント開始日",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "notice_fac_cal_start_date",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2021/08/22",
        "can_calc": "0",
        "data_code": "notice_fac_cal_end_date",
        "data_name": "イベント終了日",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "notice_fac_cal_end_date",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2021/02/23",
        "can_calc": "0",
        "data_code": "notice_start_date",
        "data_name": "掲載開始日",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "notice_start_date",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    },
    {
        "preview": "2021/06/22",
        "can_calc": "0",
        "data_code": "notice_end_date",
        "data_name": "掲載終了日",
        "data_type": "string",
        "conv_table": [],
        "data_class": "施設イベント",
        "field_name": "notice_end_date",
        "disp_format": "",
        "data_category": "施設イベント",
        "facility_table": "",
        "facility_filter_type": "0"
    }
]'
    , 1
    , '{"applications": [1]}'
    , '{"classes": [10,11]}'
    , '@facilityCd  @fromdate  @todate'
    , '2021/03/31 14:09:45'
    , '2021/03/31 14:09:45'                          
    ,'[]'
);
