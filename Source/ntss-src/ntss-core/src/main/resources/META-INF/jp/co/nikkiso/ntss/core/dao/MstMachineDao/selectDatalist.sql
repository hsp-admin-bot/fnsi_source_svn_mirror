SELECT mp.survey_point_cd                                                 -- 水質検査箇所コード
     , mnt.inspection_date                                                -- 検査日
     , mwtype.initial_string                                              -- しきい値判断上下区分
     , ( sd ->> 'time' )      :: TEXT AS time                             -- 採取時刻
     , ( sd ->> 'value' )     :: TEXT AS value                            -- 結果
     , ( sd ->> 'unit' )      :: TEXT AS unit                             -- 結果
     , ( sd ->> 'text' )      :: TEXT AS text                             -- 結果
     , ( sd ->> 'picker' )    ::  INT AS picker                           -- 採取者
     , ( sd ->> 'inspector' ) :: TEXT AS inspector                        -- 検査者
  FROM mnt_water_survey mnt                                               -- 水質管理
 CROSS JOIN jsonb_array_elements(survey_data) sd                          -- 水質データ
 INNER JOIN mst_water_survey_point mp                                     -- 水質検査箇所マスタ
    ON sd ->> 'point_cd' = mp.survey_point_cd::text                       -- 水質検査箇所コード
   AND mp.facility_cd    = /*facilityCd*/NULL                             -- 施設コード
   AND mp.is_del         = '0'                                            -- 削除フラグ
   AND mp.is_disp        = '1'                                            -- 表示フラグ
 INNER JOIN mst_machine mst                                               -- 装置マスタ
    ON mst.machine_no    = mp.machine_no                                  -- 装置番号
   AND mst.is_del        = '0'                                            -- 削除フラグ
   AND mst.is_disp       = '1'                                            -- 表示フラグ
  LEFT JOIN mst_water_survey_type mwtype                                  -- 水質検査種別マスタ
    ON mp.survey_type_cd = mwtype.survey_type_cd                          -- 水質検査種別コード
   AND mwtype.is_del     = '0'                                            -- 削除フラグ
   AND mwtype.is_disp    = '1'                                            -- 表示フラグ
 WHERE to_char(mnt.inspection_date, 'YYYY-MM-DD') >= /*startDate*/NULL                     -- 検査日
   AND to_char(mnt.inspection_date, 'YYYY-MM-DD') <= /*endDate*/NULL                       -- 検査日
   AND mnt.is_del        = '0'                                            -- 削除フラグ
   AND mnt.is_disp       = '1'                                            -- 表示フラグ
 ORDER BY mp.survey_point_cd                                              -- 水質検査箇所コード
     , mnt.inspection_date                                                -- 検査日
