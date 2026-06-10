UPDATE sys_data_set 
SET SQL = 'SELECT
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
       notice_start_date >= @fromDate
    AND
       notice_end_date <= @toDate
    AND
       is_disp = ''1'' 
    and 
       is_del =''0''
ORDER BY
    bbs_ctl_no'
WHERE
	sql_cd = '146'