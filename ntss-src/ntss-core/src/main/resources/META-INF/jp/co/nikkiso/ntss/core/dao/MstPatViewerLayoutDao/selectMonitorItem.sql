--     #9312  Add Start
select
    /*%expand*/*
from (
 --     #9312  Add End
        select
            *
        from
            (
                select
                    1 as table_type
                     , moni_data_no as moni_data_no
                     , vital_monitor_class
                --     #9312  Modified Start
                  , moni_data_name as vital_monitor_item_name
--                      , COALESCE(moni_data_short_name, moni_data_name) as vital_monitor_item_name
                --     #9312  Modified End
                     , moni_data_type
                     , upper
                     , lower
--                      , to_number(substring(moni_data_no FROM '[-0-9.]+$'), '9999999999999999999') as moni_data_no_sort
                     ,	case
                          moni_data_no ~ '^[-+]?\d+$'
                          when true then to_number(moni_data_no,'9999999')
													else to_number(
													  ascii(left(moni_data_no, 1)) || right (moni_data_no, 1) || lpad( substring(moni_data_no, 2, length(moni_data_no) - 1), 4,	'0')
													  , '9999999')
												end as moni_data_no_sort
                     , case
                    -- モニタデータ区分がnull(透析装置)ならnull
                           when moni_data_type = null then null
                    -- モニタデータ区分がZ(特殊浄化)なら、モニタ項目番号の下一桁を抽出
                    -- Z103 なら、3 を抽出する.
                           when moni_data_type = 'Z' then to_number(substring(substring(moni_data_no FROM '[-0-9.]+$') FROM char_length(substring(moni_data_no FROM '[-0-9.]+$'))), '9')
                    -- それ以外
                           else null
                    end as  purification_type
                     , is_disp
                from
                    sys_monitor_item
                where
                    (moni_data_type is null or moni_data_type = 'Z')
                  --add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  start
                    /*%if vitalMonitorClass != null */
                  and
                        vital_monitor_class = /* vitalMonitorClass*/''
                    /*%end */
                  --add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  end
                  and
                        is_disp = '1'
            ) A
        UNION
        (select
             2 as table_type
              -- mod #10077 by zhangruixue 2023-12-8  start
        --   , to_char(vital_monitor_item_cd, 'FM9999999999999999999') as moni_data_no
              , to_char(vital_monitor_item_cd + 10000, 'FM9999999999999999999') as moni_data_no
              -- mod #10077 by zhangruixue 2023-12-8  end
              , vital_monitor_class as vital_monitor_class
              , vital_monitor_item_name as vital_monitor_item_name
              , null as moni_data_type
              , 0 as upper
              , 0 as lower
--               , vital_monitor_item_cd as moni_data_no_sort
              , case vital_monitor_class
              when '1' then vital_monitor_item_cd + 10000
              when '2' then vital_monitor_item_cd + 20000
              else vital_monitor_item_cd + 30000 end
              as moni_data_no_sort
              , null as purification_type
              , is_disp
         from
             mst_add_monitor
         where
             facility_cd = /* facilityCd*/'0'
             --add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  start
             /*%if vitalMonitorClass != null */
           and
             vital_monitor_class = /* vitalMonitorClass*/''
             /*%end */
             --add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  end
             /*%if isAllDisp == null */
           and
             is_disp = '1'
             /*%end */
           and
             is_del = '0'
        )
--     #9312  Modified Start
--         order by
--             vital_monitor_class
--                , table_type
--                , moni_data_type desc
--                -- 特殊浄化装置
--                , purification_type
--                -- モニタ項目番号
--                , moni_data_no_sort
     )  AS tmpRst
order by
  moni_data_no_sort
--     #9312  Modified End
