SELECT
    mst.machine_type_cd,                                                       -- 型式コード
    mst.machine_serial,                                                        -- 製造番号
    mst.machine_name,                                                          -- 装置名
    mst.machine_no,                                                            -- 装置番号
    mtype.machine_type,                                                        -- 型式
    mbed.bed_name,                                                             -- ベッド名
    mst.setting_date                                                          -- 設置日
FROM
    mst_machine mst                                                            -- 装置マスタ
    LEFT JOIN mst_machine_type mtype                                           -- 型式マスタ
    ON mtype.machine_type_cd = mst.machine_type_cd                             -- 型式コード
    LEFT JOIN mst_bed mbed                                                     -- ベッドマスタ
    ON mbed.machine_no = mst.machine_no                                        -- 装置番号
    AND mbed.is_del = '0'                                                      -- 削除フラグ
    AND mbed.is_disp = '1'                                                     -- 表示フラグ
WHERE
    mst.facility_cd = /*facilityCd*/NULL                                       -- 施設コード
    AND mst.is_del = '0'                                                       -- 削除フラグ
    AND mst.is_disp = '1'                                                      -- 表示フラグ
ORDER BY
    mst.machine_type_cd,                                                       -- 型式コード
    mst.machine_serial                                                         -- 製造番号
