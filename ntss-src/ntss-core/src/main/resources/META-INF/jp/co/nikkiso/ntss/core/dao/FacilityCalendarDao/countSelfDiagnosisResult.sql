WITH  data1 AS (
     SELECT mnt.machine_serial                                                      -- 製造番号
          , mnt.machine_record_cd                                                   -- 装置記録コード
          , TO_CHAR( mnt.reg_date, 'YYYYMMDD' ) AS reg_date                         -- 登録日時
          , ROW_NUMBER ( ) OVER ( PARTITION BY TO_CHAR( mnt.reg_date, 'YYYYMMDD' )
                                           , mnt.machine_serial
                                    ORDER BY mnt.reg_date DESC ) AS row_num         -- ランク
       FROM mnt_motion_record mnt                                                   -- 装置動作記録テーブル
      INNER JOIN mst_machine_type mst                                               -- 型式マスタテーブル
         ON mnt.machine_type_cd = mst.machine_type_cd                               -- 型式コード
        AND mst.model BETWEEN '004' AND '005'                                       -- 機種
      WHERE mnt.facility_cd = /*facilityCd*/NULL                                    -- 施設コード
        AND mnt.reg_date >= /*startDate*/NULL                                       -- 登録日時
        AND mnt.reg_date <= /*endDate*/NULL                                         -- 登録日時
        --mod #10063 by zhangruixue 2023-11-17 --start
--         AND mnt.machine_record_cd IN ('-   ', '-  ', '- ')                         -- 装置記録コード
        AND mnt.machine_record_cd IN ('G100', 'G101', 'G102')
        --mod #10063 by zhangruixue 2023-11-17 --end
    )
    , data2 AS ( SELECT * FROM data1 )
    , data3 AS (
     SELECT COUNT(*) AS sum_count                                                   -- 診断対象の合計
       FROM mst_machine machine                                                     -- 装置マスタテーブル
      INNER JOIN mst_machine_type mst                                               -- 型式マスタテーブル
         ON machine.machine_type_cd = mst.machine_type_cd                           -- 型式コード
        AND mst.model BETWEEN '004' AND '005'                                       -- 機種
      WHERE machine.facility_cd = /*facilityCd*/NULL                                -- 施設コード
        AND machine.is_disp = '1'                                                   -- 表示フラグ
        AND machine.is_del = '0'                                                    -- 削除フラグ
    )
     SELECT data2.reg_date                                                          -- 登録日時
          , data2.machine_record_cd                                                 -- 装置記録コード
          , COUNT(data2.*) AS result_count                                          -- 数
          , data3.sum_count - SUM(COUNT(data2.*))
                              OVER(PARTITION BY data2.reg_date) AS not_done_count   -- 未実施数
       FROM data2
      CROSS JOIN data3
      GROUP BY data2.reg_date                                                       -- 登録日時
          , data2.machine_record_cd                                                 -- 装置記録コード
          , data3.sum_count                                                         -- 診断対象の合計
      ORDER BY data2.reg_date                                                       -- 登録日時
          , data2.machine_record_cd                                                 -- 装置記録コード
