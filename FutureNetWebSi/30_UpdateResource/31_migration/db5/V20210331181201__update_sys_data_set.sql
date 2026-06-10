DELETE FROM ntss.sys_data_set 
WHERE memo='紹介状　指示：投薬(未来有効）　@facilityCd@patId@fromdate@todate使用';

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
    ,'select
    weekmedi_info.cd as f_medi_cd,
    mmd.medicine_name as f_medi_name,
    weekmedi_info.amount as f_medi_amount,
    weekmedi_info.unit as f_medicine_unit,
    array_agg(weekmedi_info.week) as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    to_number(medi ->>''amount'',''99999.9999'') as amount,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd and 
      ord.treat_date between @fromdate and @todate and 
      ord.pat_id = @patId and 
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    left outer join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'')
      group by weekmedi_info.cd,mmd.medicine_name,weekmedi_info.amount,weekmedi_info.unit'
    ,2
    , '[{"preview": "1", "can_calc": "0", "data_code": "f_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_cd", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "f_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_name", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "f_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_amount", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "f_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medicine_unit", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "火,水,木", "can_calc": "0", "data_code": "f_week", "data_name": "指示曜日", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_week", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]'
    , '1'
    , '{"applications": [1]}'
    , '{"classes": [1, 9]}'
    , '紹介状　指示：投薬(未来有効）　@facilityCd@patId@fromdate@todate使用'
    , '2021/03/31 14:09:45'
    , '2021/03/31 14:09:45'                          
    ,'[]'
);