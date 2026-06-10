WITH data1 AS (
    SELECT pat_id                                                                                  -- 患者ID
         , ord_no                                                                                  -- システムで管理する一意なオーダ番号
         , treat_date                                                                            -- 治療日
      FROM ord_main                                                                                -- 治療情報
     WHERE facility_cd            = /*facilityCd*/NULL                                             -- 施設コード
       AND pat_id                 IN /* patIdList */(NULL)                                         -- 患者ID
       AND rst_dialysis_state     > '0'                                                            -- 実績：治療状況
       AND (
               (   treat_date     >= REPLACE(/*startDate*/NULL,'-','')                             -- 治療日
               AND treat_date     <= REPLACE(/*endDate*/NULL,'-',''))                              -- 治療日
            OR (   rst_start_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp    -- 実績：治療開始日時
               AND rst_start_date <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp)   -- 実績：治療開始日時
            OR (   rst_end_date   >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp    -- 実績：治療終了日時
               AND rst_end_date   <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp)   -- 実績：治療終了日時
           )
)
, data2 AS (
    SELECT mst.machine_record_cd                                                                   -- 装置記録コード
         , COALESCE(ctrl.disp_flg, mst.disp_flg) AS disp_flg                                       -- 表示フラグ
      FROM mst_machine_record mst                                                                  -- 装置記録マスタ
      LEFT JOIN mst_machine_record_control ctrl                                                    -- 装置記録マスタControl
        ON ctrl.machine_record_cd = mst.machine_record_cd and facility_cd = /*facilityCd*/NULL     -- 装置記録コード
)
SELECT data1.pat_id                                                                                -- 患者ID
     , main.ord_no                                                                                 -- システムで管理する一意なオーダ番号
     , mnt.event_reg_date                                                                          -- イベント発生日時
     , mnt.machine_record_message                                                                  -- 装置記録メッセージ
     , data1.treat_date                                                                            -- 治療日
  FROM data1
 INNER JOIN ord_main main                                                                          -- 治療情報
    ON main.ord_no                = data1.ord_no                                                   -- システムで管理する一意なオーダ番号
 INNER JOIN mnt_motion_record mnt                                                                  -- 装置動作記録
    ON mnt.ord_no                 = main.ord_no and mnt.facility_cd = /*facilityCd*/NULL       -- システムで管理する一意なオーダ番号  //No.7167 upd Paging Optimization runtime by ztc
 INNER JOIN data2 mst                                                                              -- 装置記録マスタ
    ON mst.machine_record_cd      = mnt.machine_record_cd                                          -- 装置記録コード
 WHERE mnt.report_disp_flg        = '1'                                                            -- レポート表示フラグ
    OR (   mnt.report_disp_flg    = '0'                                                            -- レポート表示フラグ
       AND mst.disp_flg           BETWEEN '1' AND '2')                                             -- 表示フラグ
order by mnt.event_reg_date
