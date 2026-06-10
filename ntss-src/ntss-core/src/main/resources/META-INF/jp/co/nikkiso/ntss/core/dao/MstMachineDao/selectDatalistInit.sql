SELECT
    mst.machine_type_cd,                                                       -- 型式コード
    mst.machine_serial,                                                        -- 製造番号
    mst.machine_name,                                                          -- 装置名
    mst.machine_no,                                                            -- 装置番号
    mtype.machine_type,                                                        -- 型式
    mbed.bed_name,                                                             -- ベッド名
    mst.setting_date,                                                          -- 設置日
    mpoint.point_name,                                                         -- 水質検査箇所名
    mpoint.survey_point_cd,                                                    -- 水質検査箇所コード
    mwtype.survey_type_name                                                    -- 水質検査種別名
FROM
    mst_machine mst                                                            -- 装置マスタ
    LEFT JOIN mst_machine_type mtype                                           -- 型式マスタ
    ON mtype.machine_type_cd = mst.machine_type_cd                             -- 型式コード
    LEFT JOIN mst_bed mbed                                                     -- ベッドマスタ
    ON mbed.machine_no = mst.machine_no                                        -- 装置番号
    AND mbed.is_del = '0'                                                      -- 削除フラグ
    AND mbed.is_disp = '1'                                                     -- 表示フラグ
    LEFT JOIN mst_water_survey_point mpoint                                    -- 水質検査箇所マスタ
    ON mst.machine_no = mpoint.machine_no                                      -- 装置番号
    AND mpoint.is_del = '0'                                                    -- 削除フラグ
    AND mpoint.is_disp = '1'                                                   -- 表示フラグ
    LEFT JOIN mst_water_survey_type mwtype                                     -- 水質検査種別マスタ
    ON mpoint.survey_type_cd = mwtype.survey_type_cd                           -- 水質検査種別コード
    AND mwtype.is_del = '0'                                                    -- 削除フラグ
    AND mwtype.is_disp = '1'                                                   -- 表示フラグ
WHERE
    mst.facility_cd = /*facilityCd*/NULL                                       -- 施設コード
    AND mst.is_del = '0'                                                       -- 削除フラグ
    AND mst.is_disp = '1'                                                      -- 表示フラグ
ORDER BY
    mst.machine_type_cd,                                                       -- 型式コード
    mst.machine_serial                                                         -- 製造番号
