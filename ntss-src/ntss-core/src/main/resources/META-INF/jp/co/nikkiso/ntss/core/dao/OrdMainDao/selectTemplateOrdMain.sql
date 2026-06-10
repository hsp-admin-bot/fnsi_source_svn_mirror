SELECT pat_id                                                                                -- 患者ID
     , ord_no                                                                                -- システムで管理する一意なオーダ番号
     , treat_date                                                                            -- 治療日
     , rst_complaint_info                                                                    -- 実績：愁訴情報
     , rst_treatment_info                                                                    -- 実績：愁訴処置情報
     , rst_treat_staff_info                                                                  -- 実績：愁訴処置者情報
  FROM ord_main                                                                              -- 治療情報
 WHERE is_del                 = '0'                                                          -- 削除フラグ
   AND facility_cd            = /*facilityCd*/NULL                                           -- 施設コード
   AND pat_id                 IN /* patIdList */(NULL)                                       -- 患者ID
   AND rst_dialysis_state     > '0'                                                          -- 実績：治療状況
   AND (
           (   treat_date     >= REPLACE(/*startDate*/NULL,'-','')                           -- 治療日
           AND treat_date     <= REPLACE(/*endDate*/NULL,'-',''))                            -- 治療日
        OR (   rst_start_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp  -- 実績：治療開始日時
           AND rst_start_date <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp) -- 実績：治療開始日時
        OR (   rst_end_date   >= TO_TIMESTAMP(/* startDate */null, 'YYYY-MM-DD')::timestamp  -- 実績：治療終了日時
           AND rst_end_date   <= TO_TIMESTAMP(/* endDate   */null, 'YYYY-MM-DD')::timestamp) -- 実績：治療終了日時
       )
